-- server.lua
local oxItemCache = nil

local function GetItemLabel(itemName)
    if not oxItemCache then
        oxItemCache = exports.ox_inventory:Items() or {}
    end
    local item = oxItemCache[itemName]
    return item and item.label or itemName
end

local function GenerateDepartmentId()
    return ('DE-%06d'):format(math.random(0, 999999))
end

local function FormatTimestamp(ts)
    if not ts then return 'N/A' end
    local t = type(ts) == 'number' and math.floor(ts / 1000) or tonumber(ts)
    return t and os.date('%d/%m/%Y %H:%M', t) or tostring(ts)
end

local function GetPlayerInfo(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return nil end

    local pd  = player.PlayerData
    local mdl = GetEntityModel(GetPlayerPed(source))
    local ci  = pd.charinfo

    return {
        citizenid = pd.citizenid,
        charname  = ci and (ci.firstname .. ' ' .. ci.lastname) or pd.citizenid,
        job       = pd.job.name,
        grade     = pd.job.grade.level,
        isboss    = pd.job.isboss,
        gender    = mdl == `mp_f_freemode_01` and 1 or 0,
    }
end

local function GetGradeOutfits(job, grade)
    local jobCfg = Config.Jobs[job]
    if not jobCfg then return {} end
    local gradeCfg = jobCfg.grades[grade]
    if not gradeCfg then return {} end
    return gradeCfg.outfits or {}
end

local function GetActiveRecords(citizenid, job)
    return MySQL.query.await(
        'SELECT id, item_name, department_id, drawable, texture, gender FROM department_items WHERE citizenid = ? AND job = ? AND returned_at IS NULL',
        { citizenid, job }
    ) or {}
end

local function HasActiveItem(citizenid, job, itemName)
    return MySQL.scalar.await(
        'SELECT 1 FROM department_items WHERE citizenid = ? AND job = ? AND item_name = ? AND returned_at IS NULL',
        { citizenid, job, itemName }
    ) ~= nil
end

local function GiveItem(targetSource, info, itemCfg)
    if HasActiveItem(info.citizenid, info.job, itemCfg.name) then
        return false, 'already_received'
    end

    local genderCfg
    if info.gender == 1 then
        genderCfg = itemCfg.female
    else
        genderCfg = itemCfg.male
    end
    if not genderCfg then return false, 'skipped' end

    local deptId = GenerateDepartmentId()
    local metadata = {
        drawableId   = genderCfg.drawable,
        textureId    = genderCfg.texture,
        gender       = info.gender,
        level        = itemCfg.level or info.grade,
        departmentId = deptId,
    }

    if not exports.ox_inventory:AddItem(targetSource, itemCfg.name, 1, metadata) then
        return false, 'inventory_full'
    end

    MySQL.insert.await(
        'INSERT INTO department_items (citizenid, charname, job, grade, item_name, drawable, texture, gender, department_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        { info.citizenid, info.charname, info.job, info.grade, itemCfg.name, genderCfg.drawable, genderCfg.texture, info.gender, deptId }
    )

    return true
end

RegisterNetEvent('departmentitems:server:getMenuData', function()
    local source = source
    local info   = GetPlayerInfo(source)
    if not info then return end

    local jobCfg = Config.Jobs[info.job]
    if not jobCfg then
        return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Bạn không thuộc ban ngành này' })
    end

    local activeRecords = GetActiveRecords(info.citizenid, info.job)

    local enrichedRecords = {}
    for _, rec in ipairs(activeRecords) do
        enrichedRecords[#enrichedRecords + 1] = {
            item_name = rec.item_name,
            label     = GetItemLabel(rec.item_name),
        }
    end

    local outfits     = GetGradeOutfits(info.job, info.grade)
    local outfitList  = {}
    for i, o in ipairs(outfits) do
        outfitList[i] = { index = i, label = o.label }
    end

    local bossData = nil
    if info.isboss then
        local rawRecords = MySQL.query.await(
            'SELECT citizenid, charname, grade, item_name, received_at FROM department_items WHERE job = ? AND returned_at IS NULL ORDER BY charname, received_at DESC',
            { info.job }
        ) or {}

        local peopleMap, peopleOrder = {}, {}
        for _, rec in ipairs(rawRecords) do
            if not peopleMap[rec.citizenid] then
                peopleMap[rec.citizenid] = {
                    citizenid = rec.citizenid,
                    charname  = rec.charname or rec.citizenid,
                    items     = {},
                }
                peopleOrder[#peopleOrder + 1] = rec.citizenid
            end
            peopleMap[rec.citizenid].items[#peopleMap[rec.citizenid].items + 1] = {
                label       = GetItemLabel(rec.item_name),
                grade       = rec.grade,
                received_at = FormatTimestamp(rec.received_at),
            }
        end

        bossData = {}
        for _, cid in ipairs(peopleOrder) do
            bossData[#bossData + 1] = peopleMap[cid]
        end
    end

    TriggerClientEvent('departmentitems:client:openMenu', source, {
        jobLabel      = jobCfg.label,
        outfits       = outfitList,
        activeRecords = enrichedRecords,
        canReceive    = #activeRecords == 0,
        isboss        = info.isboss,
        bossData      = bossData,
    })
end)

RegisterNetEvent('departmentitems:server:receiveOutfit', function(outfitIndex)
    local source = source
    if type(outfitIndex) ~= 'number' or outfitIndex < 1 or outfitIndex > 50 then return end

    local info = GetPlayerInfo(source)
    if not info then return end
    if not Config.Jobs[info.job] then return end

    local activeRecords = GetActiveRecords(info.citizenid, info.job)
    if #activeRecords > 0 then
        return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Bạn đang giữ đồ ban ngành, hãy trả lại trước' })
    end

    local outfits = GetGradeOutfits(info.job, info.grade)
    local outfit  = outfits[outfitIndex]
    if not outfit then
        return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Bộ đồng phục không tồn tại' })
    end

    local given = 0
    for _, item in ipairs(outfit.items) do
        local ok, reason = GiveItem(source, info, item)
        if ok then
            given = given + 1
        elseif reason == 'inventory_full' then
            TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Túi đầy, không thể nhận thêm đồ' })
            return
        end
    end

    if given > 0 then
        TriggerClientEvent('ox_lib:notify', source, {
            type        = 'success',
            description = ('Đã nhận %d món đồ ban ngành'):format(given),
        })
    else
        TriggerClientEvent('ox_lib:notify', source, { type = 'warning', description = 'Bạn đã nhận đủ đồ ban ngành' })
    end
end)

RegisterNetEvent('departmentitems:server:returnAll', function()
    local source = source
    local info   = GetPlayerInfo(source)
    if not info then return end

    local records = MySQL.query.await(
        'SELECT id, item_name, department_id, drawable, texture, gender FROM department_items WHERE citizenid = ? AND job = ? AND returned_at IS NULL',
        { info.citizenid, info.job }
    ) or {}

    if #records == 0 then
        return TriggerClientEvent('ox_lib:notify', source, { type = 'warning', description = 'Không có đồ nào để trả' })
    end

    local returned, notFound = 0, 0
    for _, rec in ipairs(records) do
        local removed    = false
        local playerInv  = exports.ox_inventory:GetInventoryItems(source, false)

        if playerInv then
            for slotNum, slotItem in pairs(playerInv) do
                if slotItem.name == rec.item_name and slotItem.metadata then
                    local meta = slotItem.metadata

                    if rec.department_id and meta.departmentId == rec.department_id then
                        removed = exports.ox_inventory:RemoveItem(source, rec.item_name, 1, nil, slotNum)
                        break
                    end

                    if not rec.department_id
                        and not meta.departmentId
                        and meta.drawableId == rec.drawable
                        and meta.textureId  == rec.texture
                        and meta.gender     == rec.gender
                    then
                        removed = exports.ox_inventory:RemoveItem(source, rec.item_name, 1, nil, slotNum)
                        break
                    end
                end
            end
        end

        if removed then
            MySQL.update.await('UPDATE department_items SET returned_at = NOW() WHERE id = ?', { rec.id })
            returned = returned + 1
        else
            notFound = notFound + 1
        end
    end

    if returned > 0 then
        TriggerClientEvent('ox_lib:notify', source, {
            type        = 'success',
            description = ('Đã trả %d món đồ ban ngành'):format(returned),
        })
    end
    if notFound > 0 then
        TriggerClientEvent('ox_lib:notify', source, {
            type        = 'warning',
            description = ('%d món không tìm thấy trong túi'):format(notFound),
        })
    end
end)

RegisterNetEvent('departmentitems:server:bossResetItems', function(targetCitizenId)
    local source = source
    if type(targetCitizenId) ~= 'string' or #targetCitizenId > 50 then return end

    local bossInfo = GetPlayerInfo(source)
    if not bossInfo or not bossInfo.isboss then return end

    local row = MySQL.single.await(
        'SELECT charname, COUNT(*) as cnt FROM department_items WHERE citizenid = ? AND job = ? AND returned_at IS NULL',
        { targetCitizenId, bossInfo.job }
    )

    if not row or (row.cnt or 0) == 0 then
        return TriggerClientEvent('ox_lib:notify', source, { type = 'warning', description = 'Nhân viên không có bản ghi đồ nào đang hoạt động' })
    end

    MySQL.update.await(
        'UPDATE department_items SET returned_at = NOW() WHERE citizenid = ? AND job = ? AND returned_at IS NULL',
        { targetCitizenId, bossInfo.job }
    )

    local charname = row.charname or targetCitizenId

    TriggerClientEvent('ox_lib:notify', source, {
        type        = 'success',
        description = ('Đã reset %d bản ghi của %s. Họ có thể tự nhận đồ mới.'):format(row.cnt, charname),
    })

    local targetPlayer = exports.qbx_core:GetPlayerByCitizenId(targetCitizenId)
    if targetPlayer then
        TriggerClientEvent('ox_lib:notify', targetPlayer.PlayerData.source, {
            type        = 'info',
            description = 'Cấp trên đã cho phép bạn nhận đồ ban ngành mới tại NPC',
        })
    end
end)