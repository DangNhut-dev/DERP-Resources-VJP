local usableItems = {} 
local allowedModels = {} 
local allowedLocations = {} 
local stealableModels = {} 
local playerCooldowns = {} 
local stolenLocations = {} 
local cooldownLocations = {} 

local function loadAllowedLocations()
    local letterboxes = lib.loadJson('data/letterboxes')

    for k, v in pairs(letterboxes) do
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

local function getLockpickData(playerId)
    local allSlots = bridge.inv.searchInventory(playerId, usableItems)
    if not allSlots then
        return
    end

    for i = 1, #allSlots do
        local item = allSlots[i]
        local data = SvConfig.LetterBoxes.openingItems[item.name]
        if not data then
            goto continue
        end

        local requiredDurability = data.durabilityLossOnSuccess or 10
        if item.metadata and item.metadata.durability and item.metadata.durability >= requiredDurability then
            return item, data
        end

        ::continue::
    end

    return nil
end

function GetLetterboxData()
    return {
        models = stealableModels,
        items = usableItems
    }
end

CreateThread(function()
    loadAllowedLocations()

    for item in pairs(SvConfig.LetterBoxes.openingItems) do
        table.insert(usableItems, item)
    end

    while true do
        Wait(SvConfig.LetterBoxes.cooldownResetInterval * 1000)

        pcall(function()
            resetCooldowns()
        end)
    end
end)

RegisterNetEvent('prp-pettycrime:server:letterboxSteal', function(entityName, entityModel, entityCoords)
    local playerId = source
    local stateId = bridge.fw.getIdentifier(playerId)
    if not stateId then
        return
    end

    if playerCooldowns[playerId] then
        TriggerClientEvent("prp-bridge:notify", playerId, "error", locale("notifications.letterbox.player_cooldown"))
        return
    end

    local ped = GetPlayerPed(playerId)
    if not ped or not DoesEntityExist(ped) then
        return
    end

    if GetVehiclePedIsIn(ped, false) ~= 0 then
        return
    end

    local coords = GetEntityCoords(ped)
    if #(coords - entityCoords) > Config.LetterBoxes.targetDistance then
        TriggerClientEvent("prp-bridge:notify", playerId, "error", locale("notifications.letterbox.too_far"))
        bridge.log.send(
            SvConfig.LogWebhook,
            locale("logs.letterbox.too_far.title"),
            locale("logs.letterbox.too_far.description"),
            {
                character_id = stateId,
                player_name = GetPlayerName(playerId),
                player_coords = FormatVec3(coords),
                entity_coords = FormatVec3(entityCoords),
                entity_model = entityName
            }
        )
        return
    end

    local locationKey = GetLocationKey(entityCoords)
    if stolenLocations[locationKey] then
        TriggerClientEvent("prp-bridge:notify", playerId, "error", locale("notifications.letterbox.location_cooldown"))
        return
    end

    if not allowedLocations[locationKey] then
        TriggerClientEvent("prp-bridge:notify", playerId, "error", locale("notifications.letterbox.cant_open"))
        bridge.log.send(
            SvConfig.LogWebhook,
            locale("logs.letterbox.invalid_location.title"),
            locale("logs.letterbox.invalid_location.description"),
            {
                character_id = stateId,
                player_name = GetPlayerName(playerId),
                entity_coords = FormatVec3(entityCoords),
                entity_model = entityName
            }
        )

        return
    end

    if not allowedModels[entityModel] or entityModel ~= allowedLocations[locationKey] then
        bridge.log.send(
            SvConfig.LogWebhook,
            locale("logs.letterbox.invalid_model.title"),
            locale("logs.letterbox.invalid_model.description"),
            {
                character_id = stateId,
                player_name = GetPlayerName(playerId),
                entity_coords = FormatVec3(entityCoords),
                entity_model = entityName
            }
        )

        return
    end

    local item, data = getLockpickData(playerId)
    if not item or not data then
        TriggerClientEvent("prp-bridge:notify", playerId, "error", locale("notifications.letterbox.no_item"))
        return
    end

    stolenLocations[locationKey] = true

    local actionData = SvConfig.LetterBoxes
    local gameData = actionData.minigame
    local minigameResult = lib.callback.await("prp-bridge:minigame", playerId, gameData.type, gameData.gameOptions, gameData.otherOptions)
    local degradeBy = minigameResult and data.durabilityLossOnSuccess or data.durabilityLossOnFailure
    local newDurability = item.metadata.durability - degradeBy
    local itemAltered = false

    if newDurability > 0 then
        itemAltered = bridge.inv.setItemMetaDataKey(playerId, item.slot, 'durability', newDurability)
    else
        itemAltered = bridge.inv.removeItem(playerId, item.name, 1, nil, item.slot)
    end

    if not minigameResult then
        stolenLocations[locationKey] = nil
        TriggerClientEvent("prp-bridge:notify", playerId, "error", locale("notifications.letterbox.failed_minigame"))
        return
    end

    if not itemAltered then
        stolenLocations[locationKey] = nil
        TriggerClientEvent("prp-bridge:notify", playerId, "error", locale("notifications.letterbox.item_failed"))
        return
    end

    local progressBarData = actionData.stealProgressBar
    local progressResult = lib.callback.await("prp-bridge:progress", playerId, {
        duration = progressBarData.duration,
        label = progressBarData.text,
        controlDisables = progressBarData.disable,
        animation = {
            animDict = progressBarData.anim.dict,
            animClip = progressBarData.anim.clip,
            animFlag = progressBarData.anim.flag
        }
    })

    if not progressResult then
        stolenLocations[locationKey] = nil
        return
    end

    local nothingRolled = GiveRewards(playerId, actionData.lootRolls, actionData.lootTable, actionData.guaranteedRarities)
    if nothingRolled then
        TriggerClientEvent("prp-bridge:notify", playerId, "info", locale("notifications.letterbox.found_nothing"))
    else
        TriggerClientEvent("prp-bridge:notify", playerId, "info", locale("notifications.letterbox.found_item"))

        if SvConfig.LetterBoxes.rep.enabled then
            bridge.fw.addRep(playerId, SvConfig.LetterBoxes.rep.type, SvConfig.LetterBoxes.rep.amount, "petty_crime_letterbox_steal")
        end
    end

    local cooldownDuration = math.random(actionData.minCooldown, actionData.maxCooldown)
    cooldownLocations[locationKey] = os.time() + (60 * cooldownDuration)

    HeatAction(playerId, "letterbox", entityCoords)
    playerCooldowns[playerId] = os.time() + (60 * actionData.personalCooldown)
end)
