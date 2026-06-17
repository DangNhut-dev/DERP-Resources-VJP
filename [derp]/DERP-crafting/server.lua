local allEvents = {
    ["DERP-crafting:server:craftItem"] = false
}
local fiveguard_resource = "svc_runtime"
AddEventHandler("fg:ExportsLoaded", function(fiveguard_res, res)
    if res == "*" or res == GetCurrentResourceName() then
        fiveguard_resource = fiveguard_res
        for event, cross_scripts in pairs(allEvents) do
            local retval, errorText = exports[fiveguard_res]:RegisterSafeEvent(event, {
                ban = true,
                log = true
            }, cross_scripts)
            if not retval then
                print("[fiveguard safe-events] " .. errorText)
            end
        end
    end
end)

local function GetPlayer(src)
    return exports.qbx_core:GetPlayer(src)
end

local function Notify(src, msg, ntype)
    TriggerClientEvent('ox_lib:notify', src, { description = msg, type = ntype or 'inform' })
end

local function IsJsRankingStarted()
    return GetResourceState('js_ranking') == 'started'
end

local function TryAddJsRankingLog(anyPlayer, actionText, opts)
    if not IsJsRankingStarted() then return false end
    if not actionText or actionText == '' then return false end
    local ok = pcall(function()
        exports['js_ranking']:AddActionLog(anyPlayer, actionText, opts)
    end)
    return ok
end

exports('AddActionLog', function(anyPlayer, actionText, opts)
    return TryAddJsRankingLog(anyPlayer, actionText, opts)
end)

local function NormalizeGender(gender)
    if gender == nil then return nil end
    if type(gender) == 'number' then
        if gender == 0 then return 'nam' end
        if gender == 1 then return 'nu' end
        return tostring(gender)
    end
    local text = tostring(gender):lower()
    if text == 'male' or text == 'm' or text == '0' then return 'nam' end
    if text == 'female' or text == 'f' or text == '1' then return 'nu' end
    return tostring(gender)
end

local function GetItemData(name)
    if not name then return nil end
    local items = exports.ox_inventory:Items()
    if not items then return nil end
    if items[name] then return items[name] end
    local upper = string.upper(name)
    if items[upper] then return items[upper] end
    return nil
end

local function GetItemLabel(name, metadata)
    local item = GetItemData(name)
    local label = item and item.label or tostring(name or '')
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
        local gender = NormalizeGender(metadata.gender)
        if gender then
            extras[#extras + 1] = gender
        end
    end
    if #extras > 0 then
        label = ('%s [%s]'):format(label, table.concat(extras, ' '))
    end
    return label
end

local function FormatItem(name, count, metadata, mode)
    local displayName = tostring(name or '')
    local label = GetItemLabel(displayName, metadata)
    if label ~= '' and label ~= displayName then
        displayName = ('%s(%s)'):format(displayName, label)
    end
    local prefix = ''
    if mode == 'add' then prefix = '+'
    elseif mode == 'remove' then prefix = '-' end
    count = tonumber(count) or 0
    if count > 0 then
        return ('%s%s x%s'):format(prefix, displayName, math.floor(count))
    end
    return prefix .. displayName
end

local function FormatIngredientList(ingredients, quantity)
    local parts = {}
    for ingredient, baseAmount in pairs(ingredients or {}) do
        parts[#parts + 1] = FormatItem(ingredient, (tonumber(baseAmount) or 0) * (tonumber(quantity) or 1), nil, 'remove')
    end
    table.sort(parts)
    return table.concat(parts, ', ')
end

local function BuildActionText(title, details)
    local message = ('[crafting] | %s'):format(tostring(title or ''))
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

local function AddActionLog(anyPlayer, title, details, opts)
    return TryAddJsRankingLog(anyPlayer, BuildActionText(title, details), opts)
end

-- Trả về level tương ứng với lượng exp hiện tại
local function GetLevelFromExp(exp)
    exp = tonumber(exp) or 0
    local currentLevel = 1
    local maxLevel = 1
    for lvl in pairs(Config.Levels) do
        if lvl > maxLevel then maxLevel = lvl end
    end
    for lvl = maxLevel, 1, -1 do
        local required = Config.Levels[lvl]
        if required and exp >= required then
            currentLevel = lvl
            break
        end
    end
    return currentLevel
end

-- Lấy exp từ DB theo citizenid, trả về 0 nếu chưa có
local function GetPlayerExp(citizenid, cb)
    MySQL.query('SELECT exp FROM derp_crafting_exp WHERE citizenid = ?', { citizenid }, function(result)
        if result and result[1] then
            cb(tonumber(result[1].exp) or 0)
        else
            cb(0)
        end
    end)
end

-- Upsert exp, gọi cb(newExp, newLevel, oldLevel) sau khi xong
local function AddPlayerExp(citizenid, amount, cb)
    amount = tonumber(amount) or 0
    GetPlayerExp(citizenid, function(currentExp)
        local oldLevel = GetLevelFromExp(currentExp)
        local newExp = currentExp + amount
        local newLevel = GetLevelFromExp(newExp)
        MySQL.update(
            'INSERT INTO derp_crafting_exp (citizenid, exp) VALUES (?, ?) ON DUPLICATE KEY UPDATE exp = ?',
            { citizenid, newExp, newExp },
            function()
                if cb then cb(newExp, newLevel, oldLevel) end
            end
        )
    end)
end

-- Check job
lib.callback.register('DERP-crafting:server:checkJob', function(source, requiredJobs)
    local Player = GetPlayer(source)
    if not Player then return false end
    local job = Player.PlayerData.job
    for jobName, minGrade in pairs(requiredJobs) do
        if job.name == jobName and job.grade.level >= minGrade then
            return true
        end
    end
    return false
end)

-- Trả về inventory + level/exp hiện tại của player
lib.callback.register('DERP-crafting:server:getPlayerInventory', function(source, benchId)
    local src = source
    local Player = GetPlayer(src)
    if not Player then return {}, 1, 0 end

    local citizenid = Player.PlayerData.citizenid
    local inventory = {}

    local items = exports.ox_inventory:GetInventoryItems(src) or {}
    for _, item in pairs(items) do
        if item and item.name then
            if not inventory[item.name] then
                local meta = GetItemData(item.name)
                inventory[item.name] = {
                    name   = item.name,
                    label  = meta and meta.label or item.name,
                    amount = 0,
                    image  = meta and ('nui://ox_inventory/web/images/' .. item.name .. '.png') or nil,
                }
            end
            inventory[item.name].amount = inventory[item.name].amount + item.count
        end
    end

    if benchId and Config.Benches[benchId] then
        for _, recipe in pairs(Config.Benches[benchId].recipes) do
            for ingredientName in pairs(recipe.ingredients) do
                if not inventory[ingredientName] then
                    local meta = GetItemData(ingredientName)
                    inventory[ingredientName] = {
                        name   = ingredientName,
                        label  = meta and meta.label or ingredientName,
                        amount = 0,
                        image  = meta and ('nui://ox_inventory/web/images/' .. ingredientName .. '.png') or nil,
                    }
                end
            end
        end
    end

    -- Lấy exp/level bất đồng bộ rồi trả về cùng callback
    -- ox_lib callback không hỗ trợ async natively, dùng coroutine wrapper
    local co = coroutine.running()
    local playerExp, playerLevel

    GetPlayerExp(citizenid, function(exp)
        playerExp   = exp
        playerLevel = GetLevelFromExp(exp)
        coroutine.resume(co)
    end)

    coroutine.yield()

    return inventory, playerLevel, playerExp
end)

local limitedCraftedPlayers = {}

lib.callback.register('DERP-crafting:server:getLimitedCrafted', function(source)
    local Player = GetPlayer(source)
    if not Player then return {} end
    local citizenid = Player.PlayerData.citizenid
    return limitedCraftedPlayers[citizenid] or {}
end)

-- Craft item
RegisterNetEvent('DERP-crafting:server:craftItem', function(benchId, itemName, quantity)
    local src = source

    if fiveguard_resource ~= "" and GetResourceState(fiveguard_resource) == 'started' then
        if not exports[fiveguard_resource]:VerifyToken(src) then return end
    end

    local Player = GetPlayer(src)
    if not Player then return end

    local citizenid = Player.PlayerData.citizenid
    local benchData = Config.Benches[benchId]
    if not benchData then return end

    local recipe = benchData.recipes[itemName]
    if not recipe then return end

    if recipe.limit then
        if not limitedCraftedPlayers[citizenid] then
            limitedCraftedPlayers[citizenid] = {}
        end
        if limitedCraftedPlayers[citizenid][benchId .. ":" .. itemName] then
            Notify(src, 'Bạn đã đạt giới hạn trong 1 buổi!', 'error')
            return
        end
    end

    quantity = math.floor(tonumber(quantity) or 1)
    if quantity < 1 or quantity > 999 then
        Notify(src, 'So luong khong hop le!', 'error')
        return
    end

    if not recipe.allowQuantity and quantity > 1 then
        quantity = 1
    end

    if benchData.jobs then
        local hasJob = false
        local job = Player.PlayerData.job
        for jobName, minGrade in pairs(benchData.jobs) do
            if job.name == jobName and job.grade.level >= minGrade then
                hasJob = true
                break
            end
        end
        if not hasJob then
            Notify(src, 'Ban khong co quyen!', 'error')
            return
        end
    end

    local co = coroutine.running()
    local playerExp

    GetPlayerExp(citizenid, function(exp)
        playerExp = exp
        coroutine.resume(co)
    end)

    coroutine.yield()

    local playerLevel   = GetLevelFromExp(playerExp)
    local requiredLevel = tonumber(recipe.requiredLevel) or 1

    if playerLevel < requiredLevel then
        Notify(src, 'Cap do khong du!', 'error')
        return
    end

    for ingredient, baseAmount in pairs(recipe.ingredients) do
        local required = baseAmount * quantity
        local count    = exports.ox_inventory:GetItemCount(src, ingredient)
        if count < required then
            local label = GetItemLabel(ingredient)
            Notify(src, 'Thieu nguyen lieu: ' .. label .. ' (can ' .. required .. ')', 'error')
            return
        end
    end

    -- Remove ingredients
    for ingredient, baseAmount in pairs(recipe.ingredients) do
        exports.ox_inventory:RemoveItem(src, ingredient, baseAmount * quantity)
    end

    local outputItem      = recipe.craftItem or itemName
    local craftAmount     = (recipe.amount or 1) * quantity
    local metadata        = recipe.craftMeta and table.clone(recipe.craftMeta) or nil
    local benchLabel      = benchData.label or tostring(benchId)
    local craftedLabel    = recipe.customLabel or GetItemLabel(outputItem, metadata)
    local ingredientText  = FormatIngredientList(recipe.ingredients, quantity)
    local craftedItemText = FormatItem(outputItem, craftAmount, metadata, 'add')

    CreateThread(function()
        local success = exports.ox_inventory:AddItem(src, outputItem, craftAmount, metadata)
        if success == nil then success = true end

        if success then
            if recipe.limit then
                limitedCraftedPlayers[citizenid][benchId .. ":" .. itemName] = true
                TriggerClientEvent('DERP-crafting:client:markLimitedCrafted', src, benchId, itemName)
            end

            Notify(src, 'Chế Tạo Thành Công: ' .. craftedLabel, 'success')

            local expGain = (tonumber(recipe.expReward) or 0) * quantity
            if expGain > 0 then
                AddPlayerExp(citizenid, expGain, function(newExp, newLevel, oldLevel)
                    local leveledUp = newLevel > oldLevel
                    TriggerClientEvent('DERP-crafting:client:expGained', src, {
                        expGain   = expGain,
                        newExp    = newExp,
                        newLevel  = newLevel,
                        leveledUp = leveledUp,
                        oldLevel  = oldLevel,
                    })

                    AddActionLog(src, 'Chế Tạo Thành Công', {
                        { 'ban',         benchLabel },
                        { 'cong_thuc',   tostring(itemName) },
                        { 'nhan',        craftedItemText },
                        { 'nguyen_lieu', ingredientText },
                        { 'so_luong',    tostring(quantity) },
                        { 'exp_nhan',    tostring(expGain) },
                        { 'exp_moi',     tostring(newExp) },
                        { 'level_moi',   tostring(newLevel) },
                        { 'len_level',   leveledUp and 'co' or 'khong' },
                    })
                end)
            else
                AddActionLog(src, 'Chế Tạo Thành Công', {
                    { 'ban',         benchLabel },
                    { 'cong_thuc',   tostring(itemName) },
                    { 'nhan',        craftedItemText },
                    { 'nguyen_lieu', ingredientText },
                    { 'so_luong',    tostring(quantity) },
                    { 'exp_nhan',    '0' },
                })
            end
        else
            for ingredient, baseAmount in pairs(recipe.ingredients) do
                exports.ox_inventory:AddItem(src, ingredient, baseAmount * quantity)
            end
            Notify(src, 'Chế tạo thất bại!', 'error')

            AddActionLog(src, 'Chế tạo thất bại', {
                { 'ban',         benchLabel },
                { 'cong_thuc',   tostring(itemName) },
                { 'khong_nhan',  craftedItemText },
                { 'hoan_nguyen', ingredientText },
                { 'so_luong',    tostring(quantity) },
                { 'ly_do',       'khong the them item, da rollback' },
            })
        end
    end)
end)