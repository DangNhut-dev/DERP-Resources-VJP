local allowedModels = {} 
local allowedLocations = {} 
local stealableModels = {} 
local playerCooldowns = {} 
local stolenLocations = {} 
local cooldownLocations = {} 

local function loadAllowedLocations()
    local parkingMeters = lib.loadJson("data/parkingmeters")

    for k, v in pairs(parkingMeters) do
        local coords = vector3(v.Position.X, v.Position.Y, v.Position.Z)
        local key = GetLocationKey(coords)
        local modelHash = joaat(v.Name)

        allowedLocations[key] = modelHash

        if not allowedModels[modelHash] then
            allowedModels[modelHash] = true
            table.insert(stealableModels, modelHash)
        end
    end
end

local function resetCooldowns()
    local timeNow = os.time()

    local availableKeys = {}

    for key, expiresAt in pairs(cooldownLocations) do
        if timeNow > expiresAt then
            table.insert(availableKeys, key)
        end
    end

    if #availableKeys < 1 then
        return
    end

    for _, key in pairs(availableKeys) do
        stolenLocations[key] = nil
    end
end

function GetParkingMeterData()
    return {
        models = stealableModels,
        weapons = SvConfig.ParkingMeters.allowedWeapons,
    }
end

CreateThread(function()
    loadAllowedLocations()

    while true do
        Wait(SvConfig.ParkingMeters.cooldownResetInterval * 1000)

        pcall(function()
            resetCooldowns()
        end)
    end
end)

RegisterNetEvent("prp-pettycrime:server:parkingMeterSteal", function(entityName, entityModel, entityCoords, locationLabel)    local src = source
    local currentTime = os.time()
    HeatAction(src, "parking_meter", entityCoords)

    local stateId = bridge.fw.getIdentifier(src)
    if not stateId then
        return
    end

    if playerCooldowns[src] and (currentTime < playerCooldowns[src]) then
        TriggerClientEvent("prp-bridge:notify", src, "error", locale("notifications.parking_meters.player_cooldown"))
        return
    end

    local ped = GetPlayerPed(src)
    if not ped or not DoesEntityExist(ped) then
        return
    end

    local pedCoords = GetEntityCoords(ped)
    if #(pedCoords - entityCoords) > Config.ParkingMeters.targetDistance then
        TriggerClientEvent("prp-bridge:notify", src, "error", locale("notifications.parking_meters.too_far"))
        bridge.log.send(
            SvConfig.LogWebhook,
            locale("logs.parking_meters.too_far.title"),
            locale("logs.parking_meters.too_far.description"),
            {
                character_id = stateId,
                player_name = GetPlayerName(src),
                player_coords = FormatVec3(pedCoords),
                entity_coords = FormatVec3(entityCoords),
                entity_model = entityName
            }
        )
        return
    end

    local locationKey = GetLocationKey(entityCoords)
    if stolenLocations[locationKey] then
        TriggerClientEvent("prp-bridge:notify", src, "error", locale("notifications.parking_meters.location_cooldown"))
        return
    end

    if not allowedLocations[locationKey] then
        TriggerClientEvent("prp-bridge:notify", src, "error", locale("notifications.parking_meters.cant_smash"))
        bridge.log.send(
            SvConfig.LogWebhook,
            locale("logs.parking_meters.invalid_location.title"),
            locale("logs.parking_meters.invalid_location.description"),
            {
                character_id = stateId,
                player_name = GetPlayerName(src),
                entity_coords = FormatVec3(entityCoords),
                entity_model = entityName
            }
        )

        return
    end

    if not allowedModels[entityModel] or entityModel ~= allowedLocations[locationKey] then
        bridge.log.send(
            SvConfig.LogWebhook,
            locale("logs.parking_meters.invalid_model.title"),
            locale("logs.parking_meters.invalid_model.description"),
            {
                character_id = stateId,
                player_name = GetPlayerName(src),
                entity_coords = FormatVec3(entityCoords),
                entity_model = entityName
            }
        )

        return
    end

    if GetVehiclePedIsIn(ped, false) ~= 0 then
        return
    end

    stolenLocations[locationKey] = true

    local actionData = SvConfig.ParkingMeters
    local minigameData = actionData.minigame

    HeatAction(src, "parking_meter", entityCoords, locationLabel)

    local minigameResult = lib.callback.await("prp-bridge:minigame", src, minigameData.type, minigameData.options, minigameData.otherOptions)
    if not minigameResult then
        stolenLocations[locationKey] = nil
        TriggerClientEvent("prp-bridge:notify", src, "error", locale("notifications.parking_meters.cant_smash"))
        return
    end

    local progressBarData = actionData.smashProgressBar
    local finished = lib.callback.await("prp-bridge:progress", src, {
        duration = progressBarData.duration,
        label = progressBarData.text,
        controlDisables = progressBarData.disable,
        animation = {
            animDict = progressBarData.anim.dict,
            animClip = progressBarData.anim.clip,
            animFlag = progressBarData.anim.flag
        }
    })

    if not finished then
        stolenLocations[locationKey] = nil
        return
    end

    if SvConfig.ParkingMeters.stress.enabled then
        bridge.fw.setMetadata(src, {
            ["stress"] = {
                type = "add",
                value = SvConfig.ParkingMeters.stress.amount
            }
        })
    end

    local nothingRolled = GiveRewards(src, actionData.lootRolls, actionData.lootTable, actionData.guaranteedRarities)
    if nothingRolled then
        TriggerClientEvent("prp-bridge:notify", src, "error", locale("notifications.parking_meters.found_nothing"))
    else
        TriggerClientEvent("prp-bridge:notify", src, "info", locale("notifications.parking_meters.found_item"))

        if SvConfig.ParkingMeters.rep.enabled then
            bridge.fw.addRep(src, SvConfig.ParkingMeters.rep.type, SvConfig.ParkingMeters.rep.amount, "petty_crime_parkingmeter_smash")
        end
    end

    local cooldownDuration = math.random(actionData.minCooldown, actionData.maxCooldown)
    cooldownLocations[locationKey] = os.time() + (60 * cooldownDuration)

    playerCooldowns[src] = os.time() + (60 * actionData.personalCooldown)
end)
