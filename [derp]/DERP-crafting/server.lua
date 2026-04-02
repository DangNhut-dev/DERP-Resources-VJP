local function GetPlayer(src)
    return exports.qbx_core:GetPlayer(src)
end

local function Notify(src, msg, ntype)
    TriggerClientEvent('ox_lib:notify', src, { description = msg, type = ntype or 'inform' })
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

    if success then
        local label = recipe.customLabel or (exports.ox_inventory:Items()[outputItem] and exports.ox_inventory:Items()[outputItem].label or outputItem)
        Notify(src, 'Che tao thanh cong: ' .. label, 'success')
    else
        -- Rollback ingredients
        for ingredient, baseAmount in pairs(recipe.ingredients) do
            exports.ox_inventory:AddItem(src, ingredient, baseAmount * quantity)
        end
        Notify(src, 'Khong the them item, da hoan nguyen lieu!', 'error')
    end
end)