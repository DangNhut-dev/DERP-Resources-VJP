local spawnedBenches  = {}
local currentBench    = nil
local currentBenchData = nil
local isCraftingUIOpen = false
local isCraftingInProgress = false
local craftCancelled  = false

local function IsInventoryOpen()
    return LocalPlayer.state.inv_open == true
end

local function Notify(msg, ntype)
    lib.notify({ description = msg, type = ntype or 'inform' })
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
                name    = benchId,
                label   = benchData.label,
                icon    = 'fas fa-tools',
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

-- Open UI
function OpenCraftingUI(benchId, benchData)
    if IsInventoryOpen() then
        Notify('Vui long dong inventory truoc!', 'error')
        currentBench     = nil
        currentBenchData = nil
        return
    end

    lib.callback('DERP-crafting:server:getPlayerInventory', false, function(inventory)
        if IsInventoryOpen() then
            Notify('Vui long dong inventory truoc!', 'error')
            currentBench     = nil
            currentBenchData = nil
            return
        end

        isCraftingUIOpen = true
        SetNuiFocus(true, true)

        local recipesWithLabels = {}
        for itemName, recipeData in pairs(benchData.recipes) do
            -- Support customLabel/customImage for special recipes (balo)
            local label, image

            if recipeData.customLabel then
                label = recipeData.customLabel
            else
                local meta = exports.ox_inventory:Items()[recipeData.craftItem or itemName]
                label = meta and meta.label or itemName
            end

            if recipeData.customImage then
                image = recipeData.customImage
            else
                local lookupName = recipeData.craftItem or itemName
                image = 'nui://ox_inventory/web/images/' .. lookupName .. '.png'
            end

            recipesWithLabels[itemName] = {
                id            = recipeData.id,
                time          = recipeData.time,
                amount        = recipeData.amount,
                allowQuantity = recipeData.allowQuantity,
                ingredients   = recipeData.ingredients,
                label         = label,
                image         = image,
            }
        end

        SendNUIMessage({
            action     = 'openCrafting',
            benchLabel = benchData.label,
            recipes    = recipesWithLabels,
            inventory  = inventory,
        })

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

    craftCancelled      = false
    isCraftingInProgress = true

    local totalTime = recipe.time * quantity
    local itemLabel = recipe.customLabel or (exports.ox_inventory:Items()[recipe.craftItem or data.itemName] and exports.ox_inventory:Items()[recipe.craftItem or data.itemName].label or data.itemName)

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
        TriggerServerEvent('DERP-crafting:server:craftItem', currentBench, data.itemName, quantity)
        Wait(200)
        TriggerEvent('DERP-crafting:client:updateInventory')
        Wait(200)
    end

    SendNUIMessage({ action = 'stopCrafting' })
    isCraftingInProgress = false
    craftCancelled       = false
end)

-- Update inventory
RegisterNetEvent('DERP-crafting:client:updateInventory')
AddEventHandler('DERP-crafting:client:updateInventory', function()
    if not (currentBench and isCraftingUIOpen) then return end

    lib.callback('DERP-crafting:server:getPlayerInventory', false, function(inventory)
        SendNUIMessage({ action = 'updateInventory', inventory = inventory })
    end, currentBench)
end)

-- Cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for _, obj in pairs(spawnedBenches) do
        DeleteObject(obj)
    end
end)