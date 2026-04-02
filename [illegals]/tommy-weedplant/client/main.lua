local isPlanting = false
local activePlants = {}
local playerPlantCount = 0
local lastActionTime = {
    plant = 0, water = 0, harvest = 0,
    process = 0, fertilizer = 0, uvlight = 0,
}
local isProcessing = false
local currentPlantUI = nil
local currentSeedType = nil

local function HasItem(itemName)
    return exports.ox_inventory:Search('count', itemName) > 0
end

local function IsPlantTooClose(coords, minDistance)
    for plantId, plant in pairs(activePlants) do
        local distance2D = #(vector2(coords.x, coords.y) - vector2(plant.coords.x, plant.coords.y))
        if distance2D < minDistance then
            return true, distance2D
        end
    end
    return false, 0
end

local function CheckCooldown(actionType)
    local currentTime = GetGameTimer()
    local timeSinceLastAction = currentTime - lastActionTime[actionType]
    local cooldownMap = {
        plant = 'MinTimeBetweenPlants', water = 'MinTimeBetweenWatering',
        harvest = 'MinTimeBetweenHarvest', process = 'MinTimeBetweenProcessing',
        fertilizer = 'MinTimeBetweenFertilizer', uvlight = 'MinTimeBetweenUVLight',
    }
    local configKey = cooldownMap[actionType]
    if not configKey then return true end
    local requiredCooldown = Config.AntiExploit[configKey]
    if not requiredCooldown then return true end
    if timeSinceLastAction < requiredCooldown then return false end
    lastActionTime[actionType] = currentTime
    return true
end

local function CheckDistance(coords, maxDistance)
    local playerCoords = GetEntityCoords(cache.ped)
    return #(playerCoords - coords) <= maxDistance
end

local function PlantSeed(seedType)
    if isPlanting then
        lib.notify({ description = Config.Notifications['already_planting'], type = 'error' })
        return
    end
    if not CheckCooldown('plant') then
        lib.notify({ description = Config.Notifications['too_fast_planting'], type = 'error' })
        return
    end
    if playerPlantCount >= Config.MaxPlantsPerPlayer then
        lib.notify({ description = string.format(Config.Notifications['max_plants_reached'], Config.MaxPlantsPerPlayer), type = 'error' })
        return
    end

    local ped = cache.ped
    local pedCoords = GetEntityCoords(ped)
    local pedHeading = GetEntityHeading(ped)
    local distance = Config.PlantDistance or 1.5
    local forwardX = pedCoords.x + math.sin(math.rad(-pedHeading)) * distance
    local forwardY = pedCoords.y + math.cos(math.rad(-pedHeading)) * distance

    local tempCoords = vector3(forwardX, forwardY, 0)
    local isTooClose, closestDistance = IsPlantTooClose(tempCoords, Config.MinPlantDistance)
    if isTooClose then
        lib.notify({ description = string.format('Quá gần cây khác! Phải cách %.1fm (hiện tại: %.2fm)', Config.MinPlantDistance, closestDistance), type = 'error' })
        return
    end

    local plantCoords = vector3(forwardX, forwardY, pedCoords.z - 1)

    isPlanting = true
    local seedConfig = Config.SeedTypes[seedType]

    lib.requestAnimDict('amb@world_human_gardener_plant@male@base')
    TaskPlayAnim(ped, 'amb@world_human_gardener_plant@male@base', 'base', 8.0, -8.0, 3000, 1, 0, false, false, false)

    if lib.progressBar({
        duration = 3000,
        label = 'Đang gieo hạt ' .. seedConfig.label .. '...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
    }) then
        ClearPedTasks(ped)
        TriggerServerEvent('tommy-weedplant:server:plantSeed', plantCoords, seedType)
    else
        ClearPedTasks(ped)
    end
    isPlanting = false
end

local function ShowPlantInfo(plantId)
    if not activePlants[plantId] then return end
    local plant = activePlants[plantId]
    local seedConfig = Config.SeedTypes[plant.seedType]
    if not seedConfig then return end

    currentPlantUI = plantId
    local timeRemaining = plant.timeRemaining or seedConfig.growthTime
    if not plant.growthStartedAt then timeRemaining = seedConfig.growthTime end

    SendNUIMessage({
        action = 'showPlantInfo',
        plantData = {
            seedName = seedConfig.label,
            stage = plant.stage or 1,
            waterLevel = plant.waterLevel or 0,
            maxWater = seedConfig.waterRequirement.maxWater,
            timeRemaining = timeRemaining,
            growthTime = seedConfig.growthTime,
            isReady = plant.isReady or false,
            isWithered = plant.isWithered or false,
            needsWater = not plant.growthStartedAt,
            hasFertilizer = plant.hasFertilizer or false,
            hasUVLight = plant.hasUVLight or false,
            fertilizerBonus = seedConfig.fertilizerBonus,
            harvestAmount = plant.hasUVLight and seedConfig.harvestAmount.withUVLight or seedConfig.harvestAmount.base,
        }
    })
    SetNuiFocus(true, true)
end

local function ClosePlantInfoUI()
    if not currentPlantUI then return end
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closePlantInfo' })
    currentPlantUI = nil
end

local function WaterPlant(plantId)
    if not activePlants[plantId] then return end
    if not CheckCooldown('water') then
        lib.notify({ description = Config.Notifications['too_fast_watering'], type = 'error' })
        return
    end
    if not CheckDistance(activePlants[plantId].coords, Config.AntiExploit.MaxDistanceFromPlant) then
        lib.notify({ description = Config.Notifications['too_far_from_plant'], type = 'error' })
        return
    end
    if exports.ox_inventory:Search('count', Config.WaterItemName) < 1 then
        lib.notify({ description = Config.Notifications['no_water'], type = 'error' })
        return
    end

    local ped = cache.ped
    lib.requestAnimDict('weapon@w_sp_jerrycan')
    TaskPlayAnim(ped, 'weapon@w_sp_jerrycan', 'fire', 8.0, -8.0, 2000, 1, 0, false, false, false)

    if lib.progressBar({
        duration = 2000,
        label = Config.Notifications['watering'],
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
    }) then
        ClearPedTasks(ped)
        TriggerServerEvent('tommy-weedplant:server:waterPlant', plantId)
    else
        ClearPedTasks(ped)
    end
end

local function FertilizePlant(plantId)
    if not activePlants[plantId] then return end
    if not CheckCooldown('fertilizer') then
        lib.notify({ description = Config.Notifications['too_fast_fertilizing'], type = 'error' })
        return
    end
    if not CheckDistance(activePlants[plantId].coords, Config.AntiExploit.MaxDistanceFromPlant) then
        lib.notify({ description = Config.Notifications['too_far_from_plant'], type = 'error' })
        return
    end
    if exports.ox_inventory:Search('count', Config.FertilizerItemName) < 1 then
        lib.notify({ description = Config.Notifications['no_fertilizer'], type = 'error' })
        return
    end

    local ped = cache.ped
    lib.requestAnimDict('amb@world_human_gardener_plant@male@base')
    TaskPlayAnim(ped, 'amb@world_human_gardener_plant@male@base', 'base', 8.0, -8.0, 2000, 1, 0, false, false, false)

    if lib.progressBar({
        duration = 2000,
        label = Config.Notifications['fertilizing'],
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
    }) then
        ClearPedTasks(ped)
        TriggerServerEvent('tommy-weedplant:server:fertilizePlant', plantId)
    else
        ClearPedTasks(ped)
    end
end

local function PlaceUVLight(plantId)
    if not activePlants[plantId] then return end
    if not CheckCooldown('uvlight') then
        lib.notify({ description = Config.Notifications['too_fast_uv'], type = 'error' })
        return
    end
    if not CheckDistance(activePlants[plantId].coords, Config.AntiExploit.MaxDistanceFromPlant) then
        lib.notify({ description = Config.Notifications['too_far_from_plant'], type = 'error' })
        return
    end
    if exports.ox_inventory:Search('count', Config.UVLightItemName) < 1 then
        lib.notify({ description = Config.Notifications['no_uv_light'], type = 'error' })
        return
    end

    local ped = cache.ped
    lib.requestAnimDict('amb@world_human_hammering@male@base')
    TaskPlayAnim(ped, 'amb@world_human_hammering@male@base', 'base', 8.0, -8.0, 3000, 1, 0, false, false, false)

    if lib.progressBar({
        duration = 3000,
        label = Config.Notifications['placing_uv_light'],
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
    }) then
        ClearPedTasks(ped)
        TriggerServerEvent('tommy-weedplant:server:placeUVLight', plantId)
    else
        ClearPedTasks(ped)
    end
end

local function RemoveUVLight(plantId)
    if not activePlants[plantId] then return end
    if not CheckDistance(activePlants[plantId].coords, Config.AntiExploit.MaxDistanceFromPlant) then
        lib.notify({ description = Config.Notifications['too_far_from_plant'], type = 'error' })
        return
    end

    local ped = cache.ped
    lib.requestAnimDict('amb@world_human_hammering@male@base')
    TaskPlayAnim(ped, 'amb@world_human_hammering@male@base', 'base', 8.0, -8.0, 2000, 1, 0, false, false, false)

    if lib.progressBar({
        duration = 2000,
        label = 'Đang gỡ đèn UV...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
    }) then
        ClearPedTasks(ped)
        TriggerServerEvent('tommy-weedplant:server:removeUVLight', plantId)
    else
        ClearPedTasks(ped)
    end
end

local function HarvestPlant(plantId)
    if not activePlants[plantId] then return end
    if not CheckCooldown('harvest') then
        lib.notify({ description = Config.Notifications['too_fast_harvesting'], type = 'error' })
        return
    end
    if not CheckDistance(activePlants[plantId].coords, Config.AntiExploit.MaxDistanceFromPlant) then
        lib.notify({ description = Config.Notifications['too_far_from_plant'], type = 'error' })
        return
    end

    local ped = cache.ped
    lib.requestAnimDict('amb@world_human_gardener_plant@male@base')
    TaskPlayAnim(ped, 'amb@world_human_gardener_plant@male@base', 'base', 8.0, -8.0, 3000, 1, 0, false, false, false)

    if lib.progressBar({
        duration = 3000,
        label = Config.Notifications['harvesting'],
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
    }) then
        ClearPedTasks(ped)
        TriggerServerEvent('tommy-weedplant:server:harvestPlant', plantId)
    else
        ClearPedTasks(ped)
    end
end

local function BurnPlant(plantId)
    if not activePlants[plantId] then return end
    if not CheckCooldown('harvest') then
        lib.notify({ description = Config.Notifications['too_fast_harvesting'], type = 'error' })
        return
    end
    if not CheckDistance(activePlants[plantId].coords, Config.AntiExploit.MaxDistanceFromPlant) then
        lib.notify({ description = Config.Notifications['too_far_from_plant'], type = 'error' })
        return
    end

    local ped = cache.ped
    lib.requestAnimDict('amb@world_human_gardener_plant@male@base')
    TaskPlayAnim(ped, 'amb@world_human_gardener_plant@male@base', 'base', 8.0, -8.0, 5000, 1, 0, false, false, false)

    if lib.progressBar({
        duration = 5000,
        label = Config.Notifications['burning_plant'],
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
    }) then
        ClearPedTasks(ped)
        TriggerServerEvent('tommy-weedplant:server:burnPlant', plantId)
    else
        ClearPedTasks(ped)
    end
end

local function CreatePlantTarget(plantId, plantObject, coords)
    local plant = activePlants[plantId]
    if not plant then return end
    local seedConfig = Config.SeedTypes[plant.seedType]
    if not seedConfig then return end

    exports.ox_target:addLocalEntity(plantObject, {
        {
            name = 'weed_info_' .. plantId,
            icon = 'fas fa-info-circle',
            label = 'Xem Thông Tin',
            distance = 2.5,
            onSelect = function() ShowPlantInfo(plantId) end,
        },
        {
            name = 'weed_water_' .. plantId,
            icon = 'fas fa-hand-holding-water',
            label = 'Tưới Nước Dinh Dưỡng',
            distance = 2.5,
            canInteract = function()
                local p = activePlants[plantId]
                return p and not p.isWithered
            end,
            onSelect = function() WaterPlant(plantId) end,
        },
        {
            name = 'weed_fertilize_' .. plantId,
            icon = 'fas fa-seedling',
            label = 'Bón Phân',
            distance = 2.5,
            canInteract = function()
                local p = activePlants[plantId]
                return p and not p.isWithered and not p.hasFertilizer
                    and not p.growthStartedAt and HasItem(Config.FertilizerItemName)
            end,
            onSelect = function() FertilizePlant(plantId) end,
        },
        {
            name = 'weed_uv_' .. plantId,
            icon = 'fas fa-lightbulb',
            label = 'Đặt Đèn UV',
            distance = 2.5,
            canInteract = function()
                local p = activePlants[plantId]
                return p and not p.isWithered and not p.hasUVLight
                    and not p.growthStartedAt and HasItem(Config.UVLightItemName)
            end,
            onSelect = function() PlaceUVLight(plantId) end,
        },
        {
            name = 'weed_harvest_' .. plantId,
            icon = 'fas fa-cannabis',
            label = 'Thu Hoạch',
            distance = 2.5,
            canInteract = function()
                local p = activePlants[plantId]
                return p and p.isReady and not p.isWithered
            end,
            onSelect = function() HarvestPlant(plantId) end,
        },
        {
            name = 'weed_burn_' .. plantId,
            icon = 'fas fa-fire',
            label = 'Phá Cây',
            distance = 2.5,
            canInteract = function()
                local p = activePlants[plantId]
                return p and (p.isWithered or not p.isReady)
            end,
            onSelect = function() BurnPlant(plantId) end,
        },
    })
end

local function SpawnPlant(plantId, coords, stage, isReady, waterLevel, plantedAt, owner,
                          lastWateredAt, growthStartedAt, isWithered, seedType, hasFertilizer,
                          hasUVLight, uvLightCoords, timeRemaining)
    local seedConfig = Config.SeedTypes[seedType]
    if not seedConfig then return end

    local modelName
    if isWithered then modelName = seedConfig.props.withered
    elseif stage == 1 then modelName = seedConfig.props.stage1
    elseif stage == 2 then modelName = seedConfig.props.stage2
    else modelName = seedConfig.props.stage3 end

    local modelHash = GetHashKey(modelName)
    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 100 do
        Wait(100)
        timeout = timeout + 1
    end
    if not HasModelLoaded(modelHash) then return end

    local plant = CreateObject(modelHash, coords.x, coords.y, coords.z, false, true, false)
    FreezeEntityPosition(plant, true)
    SetEntityAsMissionEntity(plant, true, true)

    local finalTimeRemaining = timeRemaining or seedConfig.growthTime

    activePlants[plantId] = {
        object = plant, coords = coords, stage = stage or 1,
        isReady = isReady or false, isWithered = isWithered or false,
        waterLevel = waterLevel or 0, plantedAt = plantedAt or 0,
        timeRemaining = finalTimeRemaining, owner = owner,
        lastWateredAt = lastWateredAt, growthStartedAt = growthStartedAt,
        seedType = seedType, hasFertilizer = hasFertilizer or false,
        hasUVLight = hasUVLight or false, uvLightCoords = uvLightCoords,
    }

    local PlayerData = exports.qbx_core:GetPlayerData()
    if owner == PlayerData.citizenid then
        playerPlantCount = playerPlantCount + 1
    end

    CreatePlantTarget(plantId, plant, coords)

    if hasUVLight and uvLightCoords then
        local uvModelHash = GetHashKey(Config.UVLightProp)
        RequestModel(uvModelHash)
        local uvTimeout = 0
        while not HasModelLoaded(uvModelHash) and uvTimeout < 100 do
            Wait(100)
            uvTimeout = uvTimeout + 1
        end
        if HasModelLoaded(uvModelHash) then
            local uvLight = CreateObject(uvModelHash, uvLightCoords.x, uvLightCoords.y, uvLightCoords.z + 1, false, true, false)
            FreezeEntityPosition(uvLight, true)
            SetEntityAsMissionEntity(uvLight, true, true)
            activePlants[plantId].uvLightObject = uvLight
        end
    end
    return plant
end

local function RemovePlant(plantId)
    if not activePlants[plantId] then return end
    local PlayerData = exports.qbx_core:GetPlayerData()
    if activePlants[plantId].owner == PlayerData.citizenid then
        playerPlantCount = math.max(0, playerPlantCount - 1)
    end
    if DoesEntityExist(activePlants[plantId].object) then
        exports.ox_target:removeLocalEntity(activePlants[plantId].object, {
            'weed_info_' .. plantId, 'weed_water_' .. plantId,
            'weed_fertilize_' .. plantId, 'weed_uv_' .. plantId,
            'weed_harvest_' .. plantId, 'weed_burn_' .. plantId,
        })
        DeleteEntity(activePlants[plantId].object)
    end
    if activePlants[plantId].uvLightObject and DoesEntityExist(activePlants[plantId].uvLightObject) then
        DeleteEntity(activePlants[plantId].uvLightObject)
    end
    activePlants[plantId] = nil
end

local function UpdatePlantModel(plantId, newStage)
    if not activePlants[plantId] then return end
    local plant = activePlants[plantId]
    local seedConfig = Config.SeedTypes[plant.seedType]
    if not seedConfig or plant.stage == newStage then return end

    local oldObject = plant.object
    local coords = plant.coords

    if DoesEntityExist(oldObject) then
        exports.ox_target:removeLocalEntity(oldObject, {
            'weed_info_' .. plantId, 'weed_water_' .. plantId,
            'weed_fertilize_' .. plantId, 'weed_uv_' .. plantId,
            'weed_harvest_' .. plantId, 'weed_burn_' .. plantId,
        })
        DeleteEntity(oldObject)
    end

    local modelName
    if plant.isWithered then modelName = seedConfig.props.withered
    elseif newStage == 1 then modelName = seedConfig.props.stage1
    elseif newStage == 2 then modelName = seedConfig.props.stage2
    else modelName = seedConfig.props.stage3 end

    local modelHash = GetHashKey(modelName)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Wait(100) end

    local newObject = CreateObject(modelHash, coords.x, coords.y, coords.z, false, true, false)
    FreezeEntityPosition(newObject, true)
    SetEntityAsMissionEntity(newObject, true, true)

    plant.object = newObject
    plant.stage = newStage
    CreatePlantTarget(plantId, newObject, coords)
end

RegisterNUICallback('closePlantInfo', function(data, cb)
    ClosePlantInfoUI()
    cb('ok')
end)

RegisterNUICallback('closeInfusion', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNetEvent('tommy-weedplant:client:showPlantInfo', function(data)
    ShowPlantInfo(data.plantId)
end)

RegisterNetEvent('tommy-weedplant:client:waterPlant', function(data)
    WaterPlant(data.plantId)
end)

RegisterNetEvent('tommy-weedplant:client:fertilizePlant', function(data)
    FertilizePlant(data.plantId)
end)

RegisterNetEvent('tommy-weedplant:client:placeUVLight', function(data)
    if type(data) == 'table' and data.plantId then
        PlaceUVLight(data.plantId)
    end
end)

RegisterNetEvent('tommy-weedplant:client:removeUVLight', function(data)
    if type(data) == 'table' and data.plantId then
        RemoveUVLight(data.plantId)
    end
end)

RegisterNetEvent('tommy-weedplant:client:harvestPlant', function(data)
    HarvestPlant(data.plantId)
end)

RegisterNetEvent('tommy-weedplant:client:burnPlant', function(data)
    BurnPlant(data.plantId)
end)

RegisterNetEvent('tommy-weedplant:client:useSeed', function(seedType)
    print('[DEBUG CLIENT] useSeed received, seedType:', seedType)
    currentSeedType = seedType
    PlantSeed(seedType)
end)

RegisterNetEvent('tommy-weedplant:client:useUVLight', function()
    local playerCoords = GetEntityCoords(cache.ped)
    local closestDist = 999999
    local closestPlant = nil
    for plantId, plant in pairs(activePlants) do
        local dist = #(playerCoords - plant.coords)
        if dist < closestDist and dist < 3.0 then
            closestDist = dist
            closestPlant = plantId
        end
    end
    if closestPlant then
        PlaceUVLight(closestPlant)
    else
        lib.notify({ description = 'Không có cây nào gần đây!', type = 'error' })
    end
end)

RegisterNetEvent('tommy-weedplant:client:spawnPlant', function(plantId, coords, stage, isReady, waterLevel,
                                                                plantedAt, owner, lastWateredAt, growthStartedAt,
                                                                isWithered, seedType, hasFertilizer, hasUVLight,
                                                                uvLightCoords, timeRemaining)
    SpawnPlant(plantId, coords, stage, isReady, waterLevel, plantedAt, owner,
        lastWateredAt, growthStartedAt, isWithered, seedType, hasFertilizer, hasUVLight, uvLightCoords, timeRemaining)
end)

RegisterNetEvent('tommy-weedplant:client:removePlant', function(plantId)
    if currentPlantUI == plantId then ClosePlantInfoUI() end
    RemovePlant(plantId)
end)

RegisterNetEvent('tommy-weedplant:client:updatePlantStage', function(plantId, stage, isReady, waterLevel,
                                                                      timeRemaining, lastWateredAt, growthStartedAt,
                                                                      isWithered, hasUVLight, hasFertilizer)
    if not activePlants[plantId] then return end
    local oldStage = activePlants[plantId].stage
    if oldStage ~= stage then UpdatePlantModel(plantId, stage) end

    activePlants[plantId].isReady = isReady
    activePlants[plantId].isWithered = isWithered or false
    activePlants[plantId].waterLevel = waterLevel or activePlants[plantId].waterLevel
    activePlants[plantId].timeRemaining = timeRemaining or activePlants[plantId].timeRemaining
    activePlants[plantId].lastWateredAt = lastWateredAt
    activePlants[plantId].growthStartedAt = growthStartedAt
    activePlants[plantId].hasUVLight = hasUVLight or false
    activePlants[plantId].hasFertilizer = hasFertilizer or false

    if currentPlantUI == plantId then
        local seedConfig = Config.SeedTypes[activePlants[plantId].seedType]
        if seedConfig then
            SendNUIMessage({
                action = 'updatePlantInfo',
                plantData = {
                    seedName = seedConfig.label, stage = stage,
                    waterLevel = waterLevel, maxWater = seedConfig.waterRequirement.maxWater,
                    timeRemaining = timeRemaining, growthTime = seedConfig.growthTime,
                    isReady = isReady, isWithered = isWithered,
                    hasStartedGrowing = growthStartedAt ~= nil,
                    lastWateredAt = lastWateredAt, hasFertilizer = hasFertilizer,
                    hasUVLight = hasUVLight, fertilizerBonus = seedConfig.fertilizerBonus,
                    harvestAmount = hasUVLight and seedConfig.harvestAmount.withUVLight or seedConfig.harvestAmount.base,
                }
            })
        end
    end
end)

RegisterNetEvent('tommy-weedplant:client:updatePlantWater', function(plantId, waterLevel)
    if not activePlants[plantId] then return end
    activePlants[plantId].waterLevel = waterLevel
    if currentPlantUI == plantId then
        SendNUIMessage({ action = 'updateWaterOnly', waterLevel = waterLevel })
    end
end)

RegisterNetEvent('tommy-weedplant:client:placeUVLight', function(plantId, coords)
    if not activePlants[plantId] then return end
    local modelHash = GetHashKey(Config.UVLightProp)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Wait(100) end
    local uvLight = CreateObject(modelHash, coords.x, coords.y, coords.z + 1, false, true, false)
    FreezeEntityPosition(uvLight, true)
    SetEntityAsMissionEntity(uvLight, true, true)
    activePlants[plantId].uvLightObject = uvLight
    activePlants[plantId].hasUVLight = true
end)

RegisterNetEvent('tommy-weedplant:client:removeUVLight', function(plantId)
    if not activePlants[plantId] then return end
    if activePlants[plantId].uvLightObject and DoesEntityExist(activePlants[plantId].uvLightObject) then
        DeleteEntity(activePlants[plantId].uvLightObject)
        activePlants[plantId].uvLightObject = nil
    end
    activePlants[plantId].hasUVLight = false
end)

RegisterNetEvent('tommy-weedplant:client:syncPlants', function(plants)
    for plantId, _ in pairs(activePlants) do RemovePlant(plantId) end
    playerPlantCount = 0
    for plantId, plantData in pairs(plants) do
        SpawnPlant(plantId, plantData.coords, plantData.stage, plantData.isReady,
            plantData.waterLevel, plantData.plantedAt, plantData.owner,
            plantData.lastWateredAt, plantData.growthStartedAt, plantData.isWithered,
            plantData.seedType, plantData.hasFertilizer, plantData.hasUVLight,
            plantData.uvLightCoords, plantData.timeRemaining)
    end
end)

RegisterNetEvent('tommy-weedplant:client:updatePlantCount', function(count)
    playerPlantCount = count
end)

CreateThread(function()
    while true do
        Wait(1000)
        for plantId, plant in pairs(activePlants) do
            if not plant.isReady and plant.waterLevel > 0 then
                plant.timeRemaining = math.max(0, plant.timeRemaining - 1000)
                if currentPlantUI == plantId then
                    SendNUIMessage({ action = 'updateTimeOnly', timeRemaining = plant.timeRemaining })
                end
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, 322) then ClosePlantInfoUI() end
    end
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    Wait(1000)
    TriggerServerEvent('tommy-weedplant:server:requestSync')
end)

CreateThread(function()
    Wait(1000)
    if LocalPlayer.state.isLoggedIn then
        TriggerServerEvent('tommy-weedplant:server:requestSync')
    end
end)