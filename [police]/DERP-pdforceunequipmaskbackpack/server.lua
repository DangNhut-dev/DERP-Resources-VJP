local cooldowns = {}

local VALID_ITEM_TYPES = { mask = true, backpack = true }

local NOTIFY_LABELS = {
    mask     = 'mặt nạ',
    backpack = 'balo',
}

local SLOT_EMPTY_MSGS = {
    mask     = 'Người chơi không đeo mặt nạ',
    backpack = 'Người chơi không mang balo',
}

local function AddActionLog(anyPlayer, actionText, opts)
    if GetResourceState('js_ranking') ~= 'started' then return false end
    if not actionText or actionText == '' then return false end

    local ok = pcall(function()
        exports['js_ranking']:AddActionLog(anyPlayer, actionText, opts)
    end)

    return ok
end

exports('AddActionLog', AddActionLog)

local function normalizeGender(gender)
    if gender == nil then return nil end

    if type(gender) == 'number' then
        if gender == 0 then return 'nam' end
        if gender == 1 then return 'nu' end
        return tostring(gender)
    end

    local text = tostring(gender):lower()

    if text == 'male' or text == 'm' or text == '0' then
        return 'nam'
    end

    if text == 'female' or text == 'f' or text == '1' then
        return 'nu'
    end

    return tostring(gender)
end

local function getItemLabel(name, metadata)
    if type(metadata) == 'table' and metadata.label and metadata.label ~= '' then
        return tostring(metadata.label)
    end

    local label = tostring(name or '')
    local ok, itemData = pcall(function()
        return exports.ox_inventory:Items(name)
    end)

    if ok and type(itemData) == 'table' and itemData.label and itemData.label ~= '' then
        label = tostring(itemData.label)
    end

    local extras = {}

    if type(metadata) == 'table' then
        if metadata.level ~= nil then
            extras[#extras + 1] = ('lv%s'):format(tostring(metadata.level))
        end

        if metadata.drawableId ~= nil then
            extras[#extras + 1] = ('d%s'):format(tostring(metadata.drawableId))
        end

        if metadata.textureId ~= nil then
            extras[#extras + 1] = ('t%s'):format(tostring(metadata.textureId))
        end

        local gender = normalizeGender(metadata.gender)
        if gender then
            extras[#extras + 1] = gender
        end
    end

    if #extras > 0 then
        label = ('%s [%s]'):format(label, table.concat(extras, ' '))
    end

    return label
end

local function formatItem(name, count, metadata, mode)
    name = tostring(name or '')
    count = tonumber(count) or 0

    local label = getItemLabel(name, metadata)
    local display = name

    if label ~= '' and label ~= name then
        display = ('%s(%s)'):format(name, label)
    end

    local prefix = ''
    if mode == 'add' then
        prefix = '+'
    elseif mode == 'remove' then
        prefix = '-'
    end

    if count > 0 then
        return ('%s%s x%s'):format(prefix, display, math.floor(count))
    end

    return prefix .. display
end

local function buildActionText(title, details)
    local message = ('[pdforceunequipmaskbackpack] | %s'):format(tostring(title or ''))

    if type(details) == 'table' and #details > 0 then
        local parts = {}

        for i = 1, #details do
            local entry = details[i]
            local key = entry and entry[1]
            local value = entry and entry[2]

            if key and value ~= nil and value ~= '' then
                parts[#parts + 1] = ('%s: %s'):format(tostring(key), tostring(value))
            end
        end

        if #parts > 0 then
            message = message .. ' | ' .. table.concat(parts, ' | ')
        end
    end

    return message
end

local function getPlayerDisplay(src)
    src = tonumber(src)
    if not src or src <= 0 then return 'unknown' end

    local name = GetPlayerName(src)
    if name and name ~= '' then
        return ('%s (%s)'):format(name, src)
    end

    return tostring(src)
end

local function logForceUnequip(actorSrc, targetSrc, itemType, itemData)
    if not itemData or not itemData.name then return end

    local itemLabel = NOTIFY_LABELS[itemType] or tostring(itemType or 'item')
    local itemText = formatItem(itemData.name, 1, itemData.metadata, 'add')
    local actorText = buildActionText(('Canh sat cuong che thao %s'):format(itemLabel), {
        { 'muc_tieu', getPlayerDisplay(targetSrc) },
        { 'item', itemText },
    })
    AddActionLog(actorSrc, actorText)

    local targetText = buildActionText(('Bi canh sat cuong che thao %s'):format(itemLabel), {
        { 'canh_sat', getPlayerDisplay(actorSrc) },
        { 'item', formatItem(itemData.name, 1, itemData.metadata, 'remove') },
    })
    AddActionLog(targetSrc, targetText)
end

local function IsPoliceOnDuty(src)
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return false end
    local job = player.PlayerData.job
    return job.name == Config.PoliceJob and job.onduty == true
end

local function CheckCooldown(src)
    local now = GetGameTimer()
    if cooldowns[src] and (now - cooldowns[src]) < Config.CooldownMs then
        return false
    end
    cooldowns[src] = now
    return true
end

local function Notify(src, ntype, msg)
    TriggerClientEvent('DERP-unequipmaskandbaloPD:notify', src, ntype, msg)
end

RegisterNetEvent('DERP-unequipmaskandbaloPD:requestUnequip', function(targetSrc, itemType)
    local src = source

    targetSrc = tonumber(targetSrc)
    if not targetSrc or not VALID_ITEM_TYPES[itemType] then return end
    if src == targetSrc then return end

    if not CheckCooldown(src) then
        return Notify(src, 'error', 'Thao tác quá nhanh')
    end

    if not IsPoliceOnDuty(src) then
        return Notify(src, 'error', 'Bạn không phải cảnh sát đang làm việc')
    end

    if not GetPlayerName(targetSrc) then
        return Notify(src, 'error', 'Người chơi không hợp lệ')
    end

    local clothSlot = Config.ClothSlots[itemType]

    local result = exports['ox_inventory']:ForceStripClothSlot(targetSrc, clothSlot)

    if not result or not result.success then
        local err = result and result.err
        if err == 'slot_empty' then
            return Notify(src, 'error', SLOT_EMPTY_MSGS[itemType])
        else
            return Notify(src, 'error', 'Thao tác thất bại: ' .. tostring(err))
        end
    end

    local itemData = result.itemData
    if not itemData or not itemData.name then
        return Notify(src, 'error', 'Không lấy được thông tin vật phẩm')
    end

    local canCarry = exports.ox_inventory:CanCarryItem(src, itemData.name, 1)
    if not canCarry then
        exports.ox_inventory:AddItem(targetSrc, itemData.name, 1, itemData.metadata)
        return Notify(src, 'error', 'Túi đồ của bạn không đủ chỗ')
    end

    local added = exports.ox_inventory:AddItem(src, itemData.name, 1, itemData.metadata)
    if not added then
        exports.ox_inventory:AddItem(targetSrc, itemData.name, 1, itemData.metadata)
        return Notify(src, 'error', 'Không thể thêm vật phẩm vào túi')
    end

    logForceUnequip(src, targetSrc, itemType, itemData)

    local label = NOTIFY_LABELS[itemType]
    Notify(src, 'success', ('Đã tháo %s và cất vào túi'):format(label))
    Notify(targetSrc, 'error', ('Cảnh sát đã tháo %s của bạn'):format(label))
end)

AddEventHandler('playerDropped', function()
    cooldowns[source] = nil
end)
