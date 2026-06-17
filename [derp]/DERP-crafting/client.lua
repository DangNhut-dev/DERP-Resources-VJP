local spawnedBenches   = {}
local currentBench     = nil
local currentBenchData = nil
local isCraftingUIOpen = false
local isCraftingInProgress = false
local craftCancelled   = false

local function IsInventoryOpen()
    return LocalPlayer.state.inv_open == true
end

local function Notify(msg, ntype)
    lib.notify({ description = msg, type = ntype or 'inform' })
end

-- Trả về level tương ứng với exp (mirror logic server)
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

-- Spawn benches + ox_target
CreateThread(function()
    for benchId, benchData in pairs(Config.Benches) do
        local obj = CreateObject(benchData.object, benchData.coords.x, benchData.coords.y, benchData.coords.z, false, false, false)
        SetEntityHeading(obj, benchData.heading)
        FreezeEntityPosition(obj, true)
        SetEntityAsMissionEntity(obj, true, true)
        spawnedBenches[benchId] = obj

        exports.ox_target:addLocalEntity(obj, {
            {
                name     = benchId,
                label    = benchData.label,
                icon     = 'fas fa-tools',
                distance = 2.5,
                onSelect = function()
                    TriggerEvent('DERP-crafting:client:openBench', { benchId = benchId })
                end,
            }
        })
    end
end)

-- Open bench
RegisterNetEvent('DERP-crafting:client:openBench')
AddEventHandler('DERP-crafting:client:openBench', function(data)
    if IsInventoryOpen() then
        Notify('Vui long dong inventory truoc!', 'error')
        return
    end

    local benchId   = data.benchId
    local benchData = Config.Benches[benchId]
    if not benchData then return end

    if benchData.jobs then
        lib.callback('DERP-crafting:server:checkJob', false, function(hasJob)
            if hasJob then
                currentBench     = benchId
                currentBenchData = benchData
                OpenCraftingUI(benchId, benchData)
            else
                Notify('Ban khong co quyen su dung ban nay!', 'error')
            end
        end, benchData.jobs)
    else
        currentBench     = benchId
        currentBenchData = benchData
        OpenCraftingUI(benchId, benchData)
    end
end)

function OpenCraftingUI(benchId, benchData)
    if IsInventoryOpen() then
        Notify('Vui long dong inventory truoc!', 'error')
        currentBench     = nil
        currentBenchData = nil
        return
    end

    lib.callback('DERP-crafting:server:getPlayerInventory', false, function(inventory, playerLevel, playerExp)
        if IsInventoryOpen() then
            Notify('Vui long dong inventory truoc!', 'error')
            currentBench     = nil
            currentBenchData = nil
            return
        end

        isCraftingUIOpen = true
        SetNuiFocus(true, true)

        local oxItems = exports.ox_inventory:Items()
        local recipesWithLabels = {}

        for itemName, recipeData in pairs(benchData.recipes) do
            local requiredLevel = tonumber(recipeData.requiredLevel) or 1
            if playerLevel >= requiredLevel then
                local label, image

                if recipeData.customLabel then
                    label = recipeData.customLabel
                else
                    local lookupName = recipeData.craftItem or itemName
                    local meta = oxItems and (oxItems[lookupName] or oxItems[string.upper(lookupName)])
                    label = meta and meta.label or lookupName
                end

                if recipeData.customImage then
                    image = recipeData.customImage
                else
                    local lookupName = recipeData.craftItem or itemName
                    local imageName  = lookupName
                    if oxItems and not oxItems[lookupName] and oxItems[string.upper(lookupName)] then
                        imageName = string.upper(lookupName)
                    end
                    image = 'nui://ox_inventory/web/images/' .. imageName .. '.png'
                end

                recipesWithLabels[itemName] = {
                    id             = recipeData.id,
                    time           = recipeData.time,
                    amount         = recipeData.amount,
                    allowQuantity  = recipeData.allowQuantity,
                    ingredients    = recipeData.ingredients,
                    label          = label,
                    image          = image,
                    expReward      = recipeData.expReward or 0,
                    requiredLevel  = requiredLevel,
                    limit          = recipeData.limit or false,
                    limitedCrafted = false,
                }
            end
        end

        local maxLevel = 1
        for lvl in pairs(Config.Levels) do
            if lvl > maxLevel then maxLevel = lvl end
        end
        local nextLevelExp    = playerLevel < maxLevel and Config.Levels[playerLevel + 1] or nil
        local currentLevelExp = Config.Levels[playerLevel] or 0

        lib.callback('DERP-crafting:server:getLimitedCrafted', false, function(limitedMap)
            for itemName, _ in pairs(recipesWithLabels) do
                local key = benchId .. ":" .. itemName
                if limitedMap[key] then
                    recipesWithLabels[itemName].limitedCrafted = true
                end
            end

            SendNUIMessage({
                action          = 'openCrafting',
                benchLabel      = benchData.label,
                recipes         = recipesWithLabels,
                inventory       = inventory,
                playerLevel     = playerLevel,
                playerExp       = playerExp,
                currentLevelExp = currentLevelExp,
                nextLevelExp    = nextLevelExp,
            })
        end)

        CreateThread(function()
            while isCraftingUIOpen do
                Wait(100)
                if IsInventoryOpen() then
                    isCraftingUIOpen = false
                    SetNuiFocus(false, false)
                    SendNUIMessage({ action = 'forceClosed' })
                    currentBench     = nil
                    currentBenchData = nil
                    Notify('Crafting da dong do mo inventory!', 'error')
                    break
                end
            end
        end)
    end, benchId)
end

-- NUI close
RegisterNUICallback('close', function(_, cb)
    isCraftingUIOpen = false
    SetNuiFocus(false, false)
    currentBench     = nil
    currentBenchData = nil
    cb('ok')
end)

-- NUI cancel craft
RegisterNUICallback('cancelCraft', function(_, cb)
    craftCancelled = true
    FreezeEntityPosition(PlayerPedId(), false)
    ClearPedTasks(PlayerPedId())
    SendNUIMessage({ action = 'stopCrafting' })
    cb('ok')
end)

-- NUI craft item
RegisterNUICallback('craftItem', function(data, cb)
    if IsInventoryOpen() or not currentBench then cb('error') return end

    local benchData = Config.Benches[currentBench]
    local recipe    = benchData and benchData.recipes[data.itemName]
    if not recipe then cb('error') return end

    local quantity = math.floor(tonumber(data.quantity) or 1)
    if quantity < 1 or quantity > 999 then cb('error') return end
    if not recipe.allowQuantity and quantity > 1 then quantity = 1 end

    cb('ok')

    craftCancelled       = false
    isCraftingInProgress = true

    local totalTime = recipe.time * quantity
    local oxItems   = exports.ox_inventory:Items()
    local itemLabel = recipe.customLabel
        or (oxItems[recipe.craftItem or data.itemName] and oxItems[recipe.craftItem or data.itemName].label)
        or data.itemName

    SendNUIMessage({
        action    = 'startCrafting',
        itemName  = data.itemName,
        itemLabel = itemLabel,
        craftTime = totalTime,
        quantity  = quantity,
    })

    RequestAnimDict('mini@repair')
    while not HasAnimDictLoaded('mini@repair') do Wait(0) end
    TaskPlayAnim(PlayerPedId(), 'mini@repair', 'fixing_a_ped', 8.0, -8.0, -1, 1, 0, false, false, false)

    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, true)

    local startTime = GetGameTimer()
    while GetGameTimer() - startTime < totalTime do
        Wait(100)
        if craftCancelled then break end
    end

    FreezeEntityPosition(playerPed, false)
    ClearPedTasks(playerPed)

    if not craftCancelled then
        if GetResourceState('svc_runtime') == 'started' then
            exports['svc_runtime']:ExecuteServerEvent('DERP-crafting:server:craftItem', currentBench, data.itemName, quantity)
        else
            TriggerServerEvent('DERP-crafting:server:craftItem', currentBench, data.itemName, quantity)
        end
        Wait(200)
        TriggerEvent('DERP-crafting:client:updateInventory')
        Wait(200)
    end

    SendNUIMessage({ action = 'stopCrafting' })
    isCraftingInProgress = false
    craftCancelled       = false
end)

RegisterNUICallback('requestInventoryRefresh', function(_, cb)
    cb('ok')
    if not (currentBench and isCraftingUIOpen) then return end

    lib.callback('DERP-crafting:server:getPlayerInventory', false, function(inventory, newPlayerLevel, newPlayerExp)
        if not isCraftingUIOpen then return end

        local benchData = Config.Benches[currentBench]
        if not benchData then return end

        local oxItems = exports.ox_inventory:Items()

        local recipesWithLabels = {}
        for itemName, recipeData in pairs(benchData.recipes) do
            local requiredLevel = tonumber(recipeData.requiredLevel) or 1
            if newPlayerLevel >= requiredLevel then
                local label, image

                if recipeData.customLabel then
                    label = recipeData.customLabel
                else
                    local lookupName = recipeData.craftItem or itemName
                    local meta = oxItems and (oxItems[lookupName] or oxItems[string.upper(lookupName)])
                    label = meta and meta.label or lookupName
                end

                if recipeData.customImage then
                    image = recipeData.customImage
                else
                    local lookupName = recipeData.craftItem or itemName
                    local imageName  = lookupName
                    if oxItems and not oxItems[lookupName] and oxItems[string.upper(lookupName)] then
                        imageName = string.upper(lookupName)
                    end
                    image = 'nui://ox_inventory/web/images/' .. imageName .. '.png'
                end

                recipesWithLabels[itemName] = {
                    id            = recipeData.id,
                    time          = recipeData.time,
                    amount        = recipeData.amount,
                    allowQuantity = recipeData.allowQuantity,
                    ingredients   = recipeData.ingredients,
                    label         = label,
                    image         = image,
                    expReward     = recipeData.expReward or 0,
                    requiredLevel = requiredLevel,
                    limitedCrafted = false,
                }
            end
        end

        local maxLevel = 1
        for lvl in pairs(Config.Levels) do
            if lvl > maxLevel then maxLevel = lvl end
        end
        local nextLevelExp    = newPlayerLevel < maxLevel and Config.Levels[newPlayerLevel + 1] or nil
        local currentLevelExp = Config.Levels[newPlayerLevel] or 0

        SendNUIMessage({
            action          = 'refreshRecipes',
            recipes         = recipesWithLabels,
            inventory       = inventory,
            playerLevel     = newPlayerLevel,
            playerExp       = newPlayerExp,
            currentLevelExp = currentLevelExp,
            nextLevelExp    = nextLevelExp,
        })
    end, currentBench)
end)

-- Update inventory sau khi craft
RegisterNetEvent('DERP-crafting:client:updateInventory')
AddEventHandler('DERP-crafting:client:updateInventory', function()
    if not (currentBench and isCraftingUIOpen) then return end

    lib.callback('DERP-crafting:server:getPlayerInventory', false, function(inventory, playerLevel, playerExp)
        if not isCraftingUIOpen then return end

        local maxLevel = 1
        for lvl in pairs(Config.Levels) do
            if lvl > maxLevel then maxLevel = lvl end
        end
        local nextLevelExp    = playerLevel < maxLevel and Config.Levels[playerLevel + 1] or nil
        local currentLevelExp = Config.Levels[playerLevel] or 0

        SendNUIMessage({
            action          = 'updateInventory',
            inventory       = inventory,
            playerLevel     = playerLevel,
            playerExp       = playerExp,
            currentLevelExp = currentLevelExp,
            nextLevelExp    = nextLevelExp,
        })
    end, currentBench)
end)

-- Nhận EXP gain từ server sau khi craft thành công
RegisterNetEvent('DERP-crafting:client:expGained')
AddEventHandler('DERP-crafting:client:expGained', function(expData)
    if not isCraftingUIOpen then return end

    local maxLevel = 1
    for lvl in pairs(Config.Levels) do
        if lvl > maxLevel then maxLevel = lvl end
    end
    local nextLevelExp    = expData.newLevel < maxLevel and Config.Levels[expData.newLevel + 1] or nil
    local currentLevelExp = Config.Levels[expData.newLevel] or 0

    SendNUIMessage({
        action          = 'expGained',
        expGain         = expData.expGain,
        newExp          = expData.newExp,
        newLevel        = expData.newLevel,
        leveledUp       = expData.leveledUp,
        oldLevel        = expData.oldLevel,
        currentLevelExp = currentLevelExp,
        nextLevelExp    = nextLevelExp,
    })
end)

RegisterNetEvent('DERP-crafting:client:markLimitedCrafted')
AddEventHandler('DERP-crafting:client:markLimitedCrafted', function(benchId, itemName)
    SendNUIMessage({
        action   = 'markLimitedCrafted',
        benchId  = benchId,
        itemName = itemName,
    })
end)

-- Cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for _, obj in pairs(spawnedBenches) do
        DeleteObject(obj)
    end
end)