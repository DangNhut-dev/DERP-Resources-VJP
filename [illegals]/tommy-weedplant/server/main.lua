local plants = {}
local plantIdCounter = 0

local function CalculatePlantStage(plant)
    if not plant.growthStartedAt then return 1, false end
    local seedConfig = Config.SeedTypes[plant.seedType]
    if not seedConfig then return 1, false end

    local currentTime = os.time() * 1000
    local effectiveCurrentTime = currentTime
    if plant.waterLevel <= 0 and plant.growthPausedAt then
        effectiveCurrentTime = plant.growthPausedAt
    end

    local timePassed = effectiveCurrentTime - plant.growthStartedAt
    local effectiveGrowthTime = seedConfig.growthTime
    if plant.hasFertilizer then
        effectiveGrowthTime = effectiveGrowthTime * (1 - seedConfig.fertilizerBonus)
    end

    if timePassed >= effectiveGrowthTime then
        local timeAfterReady = timePassed - effectiveGrowthTime
        if timeAfterReady >= seedConfig.witherTime then return 4, true end
        return 3, false
    end

    local progressPercent = (timePassed / effectiveGrowthTime) * 100
    if progressPercent < 33.33 then return 1, false
    elseif progressPercent < 66.66 then return 2, false
    else return 3, false end
end

local function GeneratePlantId()
    plantIdCounter = plantIdCounter + 1
    return 'plant_' .. os.time() .. '_' .. plantIdCounter
end

local function IsPlantTooClose(coords, minDistance)
    for plantId, plant in pairs(plants) do
        local distance2D = math.sqrt(
            math.pow(coords.x - plant.coords.x, 2) +
            math.pow(coords.y - plant.coords.y, 2)
        )
        if distance2D < minDistance then return true, distance2D end
    end
    return false, 0
end

local function LoadPlantsFromDatabase()
    local result = exports.oxmysql:executeSync('SELECT * FROM cannabis_plants', {})
    if not result then return end
    for _, row in ipairs(result) do
        local coords = json.decode(row.coords)
        local uvLightCoords = row.uv_light_coords and json.decode(row.uv_light_coords) or nil
        plants[row.plant_id] = {
            id = row.plant_id, coords = vector3(coords.x, coords.y, coords.z),
            owner = row.citizenid, seedType = row.seed_type,
            plantedAt = row.planted_at, waterLevel = row.water_level or 0,
            waterCount = row.water_count or 0, isReady = row.is_ready == 1,
            isWithered = row.is_withered == 1, lastWateredAt = row.last_watered_at,
            growthStartedAt = row.growth_started_at, growthPausedAt = row.growth_paused_at,
            hasFertilizer = row.has_fertilizer == 1,
            hasUVLight = (row.has_uv_light == 1 or row.has_uv_light == true),
            uvLightCoords = uvLightCoords and vector3(uvLightCoords.x, uvLightCoords.y, uvLightCoords.z) or nil,
        }
        local stage, isWithered = CalculatePlantStage(plants[row.plant_id])
        plants[row.plant_id].stage = stage
        plants[row.plant_id].isWithered = isWithered

        local currentTime = os.time() * 1000
        local seedConfig = Config.SeedTypes[plants[row.plant_id].seedType]
        if seedConfig and plants[row.plant_id].growthStartedAt then
            local effectiveGrowthTime = seedConfig.growthTime
            if plants[row.plant_id].hasFertilizer then
                effectiveGrowthTime = effectiveGrowthTime * (1 - seedConfig.fertilizerBonus)
            end
            local timePassed = currentTime - plants[row.plant_id].growthStartedAt
            plants[row.plant_id].timeRemaining = math.max(0, effectiveGrowthTime - timePassed)
        else
            plants[row.plant_id].timeRemaining = seedConfig and seedConfig.growthTime or 0
        end
    end
    print('^2[tommy-weedplant]^7 Loaded ' .. #result .. ' plants from database')
    Wait(1000)
    TriggerClientEvent('tommy-weedplant:client:syncPlants', -1, plants)
end

local function SavePlantToDatabase(plant)
    local coords = json.encode({x = plant.coords.x, y = plant.coords.y, z = plant.coords.z})
    local uvLightCoords = plant.uvLightCoords and json.encode({x = plant.uvLightCoords.x, y = plant.uvLightCoords.y, z = plant.uvLightCoords.z}) or nil
    exports.oxmysql:execute([[
        INSERT INTO cannabis_plants
        (plant_id, citizenid, seed_type, coords, water_level, water_count, is_ready, is_withered,
         planted_at, last_watered_at, growth_started_at, growth_paused_at, has_fertilizer, has_uv_light, uv_light_coords)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        plant.id, plant.owner, plant.seedType, coords, plant.waterLevel, plant.waterCount,
        plant.isReady and 1 or 0, plant.isWithered and 1 or 0, plant.plantedAt,
        plant.lastWateredAt, plant.growthStartedAt, plant.growthPausedAt,
        plant.hasFertilizer and 1 or 0, plant.hasUVLight and 1 or 0, uvLightCoords,
    })
end

local function UpdatePlantInDatabase(plant)
    local uvLightCoords = plant.uvLightCoords and json.encode({x = plant.uvLightCoords.x, y = plant.uvLightCoords.y, z = plant.uvLightCoords.z}) or nil
    exports.oxmysql:execute([[
        UPDATE cannabis_plants
        SET water_level=?, water_count=?, is_ready=?, is_withered=?,
            last_watered_at=?, growth_started_at=?, growth_paused_at=?, has_fertilizer=?,
            has_uv_light=?, uv_light_coords=?
        WHERE plant_id=?
    ]], {
        plant.waterLevel, plant.waterCount, plant.isReady and 1 or 0, plant.isWithered and 1 or 0,
        plant.lastWateredAt, plant.growthStartedAt, plant.growthPausedAt,
        plant.hasFertilizer and 1 or 0, plant.hasUVLight and 1 or 0, uvLightCoords, plant.id,
    })
end

local function DeletePlantFromDatabase(plantId)
    exports.oxmysql:execute('DELETE FROM cannabis_plants WHERE plant_id = ?', {plantId})
end

local function GetPlayerPlantCount(citizenid)
    local count = 0
    for _, plant in pairs(plants) do
        if plant.owner == citizenid then count = count + 1 end
    end
    return count
end

local function UpdatePlantGrowth(plantId)
    if not plants[plantId] then return end
    local plant = plants[plantId]
    local seedConfig = Config.SeedTypes[plant.seedType]
    if not seedConfig or not plant.growthStartedAt then return end

    local currentTime = os.time() * 1000

    if plant.waterLevel > 0 and not plant.isReady and not plant.isWithered then
        if seedConfig.waterRequirement.enabled then
            local timeSinceLastUpdate = currentTime - (plant.lastWaterUpdate or plant.growthStartedAt)
            local secondsPassed = timeSinceLastUpdate / 1000
            local waterDrain = secondsPassed * seedConfig.waterRequirement.drainRate
            local oldWaterLevel = plant.waterLevel
            plant.waterLevel = math.max(0, plant.waterLevel - waterDrain)
            plant.lastWaterUpdate = currentTime

            if oldWaterLevel > 0 and plant.waterLevel <= 0 then
                plant.growthPausedAt = currentTime
                UpdatePlantInDatabase(plant)
                local player = exports.qbx_core:GetPlayerByCitizenId(plant.owner)
                if player then
                    TriggerClientEvent('ox_lib:notify', player.PlayerData.source, {
                        description = Config.Notifications['water_depleted'], type = 'error'
                    })
                end
            end
        end
    end

    local canGrow = (plant.waterLevel > 0 or not seedConfig.waterRequirement.enabled) and not plant.growthPausedAt

    if canGrow then
        local newStage, isWithered = CalculatePlantStage(plant)
        local stageChanged = plant.stage ~= newStage
        local witheredChanged = plant.isWithered ~= isWithered
        plant.stage = newStage
        plant.isWithered = isWithered

        local effectiveGrowthTime = seedConfig.growthTime
        if plant.hasFertilizer then effectiveGrowthTime = effectiveGrowthTime * (1 - seedConfig.fertilizerBonus) end
        local timePassed = currentTime - plant.growthStartedAt

        if timePassed >= effectiveGrowthTime and not plant.isReady then
            plant.isReady = true
            if not isWithered then plant.stage = 3 end
            UpdatePlantInDatabase(plant)
            TriggerClientEvent('tommy-weedplant:client:updatePlantStage', -1, plantId, plant.stage,
                plant.isReady, plant.waterLevel, 0, plant.lastWateredAt, plant.growthStartedAt,
                plant.isWithered, plant.hasUVLight, plant.hasFertilizer)
        elseif witheredChanged and isWithered then
            plant.stage = 4
            UpdatePlantInDatabase(plant)
            TriggerClientEvent('tommy-weedplant:client:updatePlantStage', -1, plantId, plant.stage,
                plant.isReady, plant.waterLevel, 0, plant.lastWateredAt, plant.growthStartedAt,
                plant.isWithered, plant.hasUVLight, plant.hasFertilizer)
        elseif stageChanged then
            local timeRemaining = math.max(0, effectiveGrowthTime - timePassed)
            TriggerClientEvent('tommy-weedplant:client:updatePlantStage', -1, plantId, plant.stage,
                plant.isReady, plant.waterLevel, timeRemaining, plant.lastWateredAt, plant.growthStartedAt,
                plant.isWithered, plant.hasUVLight, plant.hasFertilizer)
        else
            TriggerClientEvent('tommy-weedplant:client:updatePlantWater', -1, plantId, plant.waterLevel)
        end
    else
        if plant.waterLevel <= 0 then
            TriggerClientEvent('tommy-weedplant:client:updatePlantWater', -1, plantId, 0)
        end
    end
end

CreateThread(function()
    while true do
        Wait(1000)
        for plantId, _ in pairs(plants) do
            UpdatePlantGrowth(plantId)
        end
    end
end)

local function ValidateDistance(source, coords, maxDistance)
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    return #(playerCoords - vector3(coords.x, coords.y, coords.z)) <= maxDistance
end

RegisterNetEvent('tommy-weedplant:server:plantSeed', function(coords, seedType)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    local seedConfig = Config.SeedTypes[seedType]
    if not seedConfig then
        TriggerClientEvent('ox_lib:notify', src, { description = 'Loại hạt không hợp lệ!', type = 'error' })
        return
    end

    local citizenid = player.PlayerData.citizenid
    local currentPlantCount = GetPlayerPlantCount(citizenid)

    if currentPlantCount >= Config.MaxPlantsPerPlayer then
        TriggerClientEvent('ox_lib:notify', src, {
            description = string.format(Config.Notifications['max_plants_reached'], Config.MaxPlantsPerPlayer),
            type = 'error'
        })
        return
    end

    local isTooClose, closestDistance = IsPlantTooClose(coords, Config.MinPlantDistance)
    if isTooClose then
        TriggerClientEvent('ox_lib:notify', src, {
            description = string.format('Quá gần cây khác! Phải cách tối thiểu %.1fm', Config.MinPlantDistance),
            type = 'error'
        })
        return
    end

    if exports.ox_inventory:Search(src, 'count', seedType) < 1 then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['no_seed'], type = 'error' })
        return
    end

    exports.ox_inventory:RemoveItem(src, seedType, 1)

    local plantId = GeneratePlantId()
    local currentTime = os.time() * 1000

    plants[plantId] = {
        id = plantId, coords = coords, owner = citizenid, seedType = seedType,
        plantedAt = currentTime, stage = 1, waterLevel = 0, waterCount = 0,
        isReady = false, isWithered = false, lastWateredAt = nil,
        growthStartedAt = nil, growthPausedAt = nil, hasFertilizer = false,
        hasUVLight = false, uvLightCoords = nil, lastWaterUpdate = currentTime,
    }

    SavePlantToDatabase(plants[plantId])
    TriggerClientEvent('tommy-weedplant:client:spawnPlant', -1, plantId, coords, 1, false, 0,
        currentTime, citizenid, nil, nil, false, seedType, false, false, nil, seedConfig.growthTime)
    TriggerClientEvent('tommy-weedplant:client:updatePlantCount', src, currentPlantCount + 1)
    TriggerClientEvent('ox_lib:notify', src, {
        description = string.format(Config.Notifications['plant_placed'], seedConfig.label),
        type = 'success'
    })
end)

RegisterNetEvent('tommy-weedplant:server:waterPlant', function(plantId)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player or not plants[plantId] then return end

    local plant = plants[plantId]
    local seedConfig = Config.SeedTypes[plant.seedType]
    if not seedConfig then return end

    if not ValidateDistance(src, plant.coords, Config.AntiExploit.MaxDistanceFromPlant) then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['too_far_from_plant'], type = 'error' })
        return
    end

    if plant.waterLevel >= seedConfig.waterRequirement.maxWater then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['water_full'], type = 'error' })
        return
    end

    local currentTime = os.time() * 1000
    if plant.lastWateredAt then
        local timeSinceLastWater = currentTime - plant.lastWateredAt
        if timeSinceLastWater < Config.WaterCooldown then
            local remainingTime = math.ceil((Config.WaterCooldown - timeSinceLastWater) / 1000)
            TriggerClientEvent('ox_lib:notify', src, {
                description = string.format(Config.Notifications['water_cooldown'], remainingTime), type = 'error'
            })
            return
        end
    end

    if exports.ox_inventory:Search(src, 'count', Config.WaterItemName) < 1 then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['no_water'], type = 'error' })
        return
    end

    exports.ox_inventory:RemoveItem(src, Config.WaterItemName, 1)

    local isFirstWater = plant.waterCount == 0
    plant.waterLevel = seedConfig.waterRequirement.maxWater
    plant.waterCount = plant.waterCount + 1
    plant.lastWateredAt = currentTime
    plant.lastWaterUpdate = currentTime

    if plant.growthPausedAt then
        local pausedDuration = currentTime - plant.growthPausedAt
        plant.growthStartedAt = plant.growthStartedAt + pausedDuration
        plant.growthPausedAt = nil
    end

    if isFirstWater and seedConfig.waterRequirement.enabled then
        plant.growthStartedAt = currentTime
        plant.stage = 1
    end

    UpdatePlantInDatabase(plant)

    local effectiveGrowthTime = seedConfig.growthTime
    if plant.hasFertilizer then effectiveGrowthTime = effectiveGrowthTime * (1 - seedConfig.fertilizerBonus) end
    local timeRemaining = effectiveGrowthTime
    if plant.growthStartedAt then
        local timePassed = currentTime - plant.growthStartedAt
        timeRemaining = math.max(0, effectiveGrowthTime - timePassed)
    end

    TriggerClientEvent('tommy-weedplant:client:updatePlantStage', -1, plantId, plant.stage,
        plant.isReady, plant.waterLevel, timeRemaining, plant.lastWateredAt, plant.growthStartedAt,
        plant.isWithered, plant.hasUVLight, plant.hasFertilizer)
    TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['plant_watered'], type = 'success' })
end)

RegisterNetEvent('tommy-weedplant:server:fertilizePlant', function(plantId)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player or not plants[plantId] then return end

    local plant = plants[plantId]
    local seedConfig = Config.SeedTypes[plant.seedType]
    if not seedConfig then return end

    if not ValidateDistance(src, plant.coords, Config.AntiExploit.MaxDistanceFromPlant) then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['too_far_from_plant'], type = 'error' })
        return
    end
    if plant.hasFertilizer then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['already_fertilized'], type = 'error' })
        return
    end
    if exports.ox_inventory:Search(src, 'count', Config.FertilizerItemName) < 1 then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['no_fertilizer'], type = 'error' })
        return
    end

    exports.ox_inventory:RemoveItem(src, Config.FertilizerItemName, 1)
    plant.hasFertilizer = true
    UpdatePlantInDatabase(plant)

    TriggerClientEvent('tommy-weedplant:client:updatePlantStage', -1, plantId, plant.stage,
        plant.isReady, plant.waterLevel, 0, plant.lastWateredAt, plant.growthStartedAt,
        plant.isWithered, plant.hasUVLight, plant.hasFertilizer)

    local bonusPercent = math.floor(seedConfig.fertilizerBonus * 100)
    TriggerClientEvent('ox_lib:notify', src, {
        description = string.format(Config.Notifications['fertilizer_applied'], bonusPercent), type = 'success'
    })
end)

RegisterNetEvent('tommy-weedplant:server:placeUVLight', function(plantId)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player or not plants[plantId] then return end

    local plant = plants[plantId]
    if not ValidateDistance(src, plant.coords, Config.AntiExploit.MaxDistanceFromPlant) then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['too_far_from_plant'], type = 'error' })
        return
    end
    if plant.hasUVLight then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['already_has_uv'], type = 'error' })
        return
    end
    if exports.ox_inventory:Search(src, 'count', Config.UVLightItemName) < 1 then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['no_uv_light'], type = 'error' })
        return
    end

    exports.ox_inventory:RemoveItem(src, Config.UVLightItemName, 1)
    plant.hasUVLight = true
    plant.uvLightCoords = vector3(
        plant.coords.x + Config.UVLightOffset.x,
        plant.coords.y + Config.UVLightOffset.y,
        plant.coords.z + Config.UVLightOffset.z
    )
    UpdatePlantInDatabase(plant)

    TriggerClientEvent('tommy-weedplant:client:placeUVLight', -1, plantId, plant.uvLightCoords)
    TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['uv_light_placed'], type = 'success' })
end)

RegisterNetEvent('tommy-weedplant:server:removeUVLight', function(plantId)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player or not plants[plantId] then return end

    local plant = plants[plantId]
    if not plant.hasUVLight then return end
    if not ValidateDistance(src, plant.coords, Config.AntiExploit.MaxDistanceFromPlant) then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['too_far_from_plant'], type = 'error' })
        return
    end

    exports.ox_inventory:AddItem(src, Config.UVLightItemName, 1)
    plant.hasUVLight = false
    plant.uvLightCoords = nil
    UpdatePlantInDatabase(plant)

    TriggerClientEvent('tommy-weedplant:client:removeUVLight', -1, plantId)
    TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['uv_light_removed'], type = 'success' })
end)

RegisterNetEvent('tommy-weedplant:server:harvestPlant', function(plantId)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player or not plants[plantId] then return end

    local plant = plants[plantId]
    local seedConfig = Config.SeedTypes[plant.seedType]
    if not seedConfig then return end

    if not ValidateDistance(src, plant.coords, Config.AntiExploit.MaxDistanceFromPlant) then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['too_far_from_plant'], type = 'error' })
        return
    end
    if plant.isWithered then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['plant_withered'], type = 'error' })
        return
    end
    if not plant.isReady then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['not_ready'], type = 'error' })
        return
    end

    local rewardAmount = plant.hasUVLight and seedConfig.harvestAmount.withUVLight or seedConfig.harvestAmount.base
    exports.ox_inventory:AddItem(src, seedConfig.harvestItem, rewardAmount)

    local seedReward = 0
    if Config.SeedReward.enabled then
        local randomChance = math.random(1, 100)
        local cumulativeChance = 0
        for _, rewardTier in ipairs(Config.SeedReward.chances) do
            cumulativeChance = cumulativeChance + rewardTier.chance
            if randomChance <= cumulativeChance then
                seedReward = rewardTier.amount
                break
            end
        end
        if seedReward > 0 then
            exports.ox_inventory:AddItem(src, plant.seedType, seedReward)
        end
    end

    TriggerClientEvent('ox_lib:notify', src, {
        description = string.format(Config.Notifications['harvest_success'], seedConfig.harvestItem, rewardAmount),
        type = 'success'
    })

    local citizenid = player.PlayerData.citizenid
    TriggerClientEvent('tommy-weedplant:client:updatePlantCount', src, GetPlayerPlantCount(citizenid) - 1)
    TriggerClientEvent('tommy-weedplant:client:removePlant', -1, plantId)
    DeletePlantFromDatabase(plantId)
    plants[plantId] = nil
end)

RegisterNetEvent('tommy-weedplant:server:burnPlant', function(plantId)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player or not plants[plantId] then return end

    local plant = plants[plantId]
    if not ValidateDistance(src, plant.coords, Config.AntiExploit.MaxDistanceFromPlant) then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['too_far_from_plant'], type = 'error' })
        return
    end
    if plant.isReady and not plant.isWithered then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['cannot_burn_ready'], type = 'error' })
        return
    end

    TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['plant_burned'], type = 'success' })
    local citizenid = player.PlayerData.citizenid
    TriggerClientEvent('tommy-weedplant:client:updatePlantCount', src, GetPlayerPlantCount(citizenid) - 1)
    TriggerClientEvent('tommy-weedplant:client:removePlant', -1, plantId)
    DeletePlantFromDatabase(plantId)
    plants[plantId] = nil
end)

lib.callback.register('tommy-weedplant:server:hasItem', function(source, itemName)
    return exports.ox_inventory:Search(source, 'count', itemName) >= 1
end)

RegisterNetEvent('tommy-weedplant:server:requestSync', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end
    TriggerClientEvent('tommy-weedplant:client:syncPlants', src, plants)
    local citizenid = player.PlayerData.citizenid
    TriggerClientEvent('tommy-weedplant:client:updatePlantCount', src, GetPlayerPlantCount(citizenid))
end)

AddEventHandler('ox_inventory:usedItem', function(src, itemName)
    if not itemName then return end

    if Config.SeedTypes[itemName] then
        TriggerClientEvent('tommy-weedplant:client:useSeed', src, itemName)
    elseif itemName == Config.UVLightItemName then
        TriggerClientEvent('tommy-weedplant:client:useUVLight', src)
    elseif itemName == Config.DryingRack.item then
        TriggerClientEvent('tommy-weedplant:client:useDryingRack', src)
    elseif itemName == Config.InfusionTableItem then
        TriggerClientEvent('tommy-weedplant:client:useInfusionTable', src)
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Wait(1000)
        LoadPlantsFromDatabase()
        print('^2[tommy-weedplant]^7 Resource started!')
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for plantId, plant in pairs(plants) do UpdatePlantInDatabase(plant) end
        Wait(500)
        TriggerClientEvent('tommy-weedplant:client:syncPlants', -1, {})
        print('^3[tommy-weedplant]^7 Resource stopped. All plants saved.')
    end
end)