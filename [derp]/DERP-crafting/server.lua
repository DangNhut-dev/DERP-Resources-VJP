local allEvents = {
    ["DERP-crafting:server:craftItem"] = false
}
local fiveguard_resource = "svc_runtime"
AddEventHandler("fg:ExportsLoaded", function(fiveguard_res, res)
    if res == "*" or res == GetCurrentResourceName() then
        fiveguard_resource = fiveguard_res
        for event,cross_scripts in pairs(allEvents) do
            local retval, errorText = exports[fiveguard_res]:RegisterSafeEvent(event, {
                ban = true,
                log = true
            }, cross_scripts)
            if not retval then
                print("[fiveguard safe-events] "..errorText)
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

    if text == 'male' or text == 'm' or text == '0' then
        return 'nam'
    end

    if text == 'female' or text == 'f' or text == '1' then
        return 'nu'
    end

    return tostring(gender)
end

local function GetItemData(name)
    local items = exports.ox_inventory:Items()
    return items and items[name] or nil
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
    if mode == 'add' then
        prefix = '+'
    elseif mode == 'remove' then
        prefix = '-'
    end

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

-- Get player inventory
lib.callback.register('DERP-crafting:server:getPlayerInventory', function(source, benchId)
    local src = source
    local inventory = {}

    local items = exports.ox_inventory:GetInventoryItems(src) or {}
    for _, item in pairs(items) do
        if item and item.name then
            if not inventory[item.name] then
                local meta = exports.ox_inventory:Items()[item.name]
                inventory[item.name] = {
                    name = item.name,
                    label = meta and meta.label or item.name,
                    amount = 0,
                    image = meta and ('nui://ox_inventory/web/images/' .. item.name .. '.png') or nil,
                }
            end
            inventory[item.name].amount = inventory[item.name].amount + item.count
        end
    end

    if benchId and Config.Benches[benchId] then
        for _, recipe in pairs(Config.Benches[benchId].recipes) do
            for ingredientName in pairs(recipe.ingredients) do
                if not inventory[ingredientName] then
                    local meta = exports.ox_inventory:Items()[ingredientName]
                    inventory[ingredientName] = {
                        name = ingredientName,
                        label = meta and meta.label or ingredientName,
                        amount = 0,
                        image = meta and ('nui://ox_inventory/web/images/' .. ingredientName .. '.png') or nil,
                    }
                end
            end
        end
    end

    return inventory
end)

-- Craft item
RegisterNetEvent('DERP-crafting:server:craftItem', function(benchId, itemName, quantity)
    local src = source
    if fiveguard_resource ~= "" and GetResourceState(fiveguard_resource) == 'started' then
        if not exports[fiveguard_resource]:VerifyToken(src) then return end
    end
    local Player = GetPlayer(src)
    if not Player then return end

    local benchData = Config.Benches[benchId]
    if not benchData then return end

    local recipe = benchData.recipes[itemName]
    if not recipe then return end

    quantity = math.floor(tonumber(quantity) or 1)
    if quantity < 1 or quantity > 999 then
        Notify(src, 'So luong khong hop le!', 'error')
        return
    end

    if not recipe.allowQuantity and quantity > 1 then
        quantity = 1
    end

    -- Check job
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

    -- Check ingredients
    for ingredient, baseAmount in pairs(recipe.ingredients) do
        local required = baseAmount * quantity
        local count = exports.ox_inventory:GetItemCount(src, ingredient)
        if count < required then
            local meta = exports.ox_inventory:Items()[ingredient]
            local label = meta and meta.label or ingredient
            Notify(src, 'Thieu nguyen lieu: ' .. label .. ' (can ' .. required .. ')', 'error')
            return
        end
    end

    -- Remove ingredients
    for ingredient, baseAmount in pairs(recipe.ingredients) do
        exports.ox_inventory:RemoveItem(src, ingredient, baseAmount * quantity)
    end

    -- Add crafted item (support craftItem + craftMeta for special recipes)
    local outputItem = recipe.craftItem or itemName
    local craftAmount = (recipe.amount or 1) * quantity
    local metadata = recipe.craftMeta and table.clone(recipe.craftMeta) or nil

    local success = exports.ox_inventory:AddItem(src, outputItem, craftAmount, metadata)
    local benchLabel = benchData.label or tostring(benchId)
    local craftedLabel = recipe.customLabel or GetItemLabel(outputItem, metadata)
    local ingredientText = FormatIngredientList(recipe.ingredients, quantity)
    local craftedItemText = FormatItem(outputItem, craftAmount, metadata, 'add')

    if success then
        local label = recipe.customLabel or (exports.ox_inventory:Items()[outputItem] and exports.ox_inventory:Items()[outputItem].label or outputItem)
        Notify(src, 'Che tao thanh cong: ' .. label, 'success')

        AddActionLog(src, 'Che tao thanh cong', {
            { 'ban', benchLabel },
            { 'cong_thuc', tostring(itemName) },
            { 'nhan', craftedItemText },
            { 'nguyen_lieu', ingredientText },
            { 'so_luong', tostring(quantity) },
        })
    else
        -- Rollback ingredients
        for ingredient, baseAmount in pairs(recipe.ingredients) do
            exports.ox_inventory:AddItem(src, ingredient, baseAmount * quantity)
        end
        Notify(src, 'Khong the them item, da hoan nguyen lieu!', 'error')

        AddActionLog(src, 'Che tao that bai', {
            { 'ban', benchLabel },
            { 'cong_thuc', tostring(itemName) },
            { 'khong_nhan_duoc', craftedItemText },
            { 'hoan_nguyen_lieu', ingredientText },
            { 'so_luong', tostring(quantity) },
            { 'ly_do', 'khong the them item, da rollback nguyen lieu' },
        })
    end
end)
