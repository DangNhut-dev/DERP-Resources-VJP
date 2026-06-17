
local usableItems = {} 
local allowedModels = {} 
local allowedLocations = {} 
local stealableModels = {} 
local lockpickedLocations = {} 
local lootableLocations = {} 
local cooldownLocations = {} 

local function loadAllowedLocations()
    local postboxes = lib.loadJson('data/postboxes')

    for k, v in pairs(postboxes) do
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
        cooldownLocations[key] = nil
        lootableLocations[key] = nil
        lockpickedLocations[key] = nil
    end

    TriggerClientEvent('prp-pettycrime:client:postboxResetOptionStates', -1, availableKeys)
end

local function getLockpickData(playerId)
    local allSlots = bridge.inv.searchInventory(playerId, usableItems)
    if not allSlots then
        return
    end

    for i = 1, #allSlots do
        local item = allSlots[i]
        local data = SvConfig.PostBoxes.openingItems[item.name]
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

function GetPostboxData()
    return {
        models = stealableModels,
        items = usableItems
    }
end

CreateThread(function()
    loadAllowedLocations()

    for item in pairs(SvConfig.PostBoxes.openingItems) do
        table.insert(usableItems, item)
    end

    while true do
        Wait(SvConfig.PostBoxes.cooldownResetInterval * 1000)

        pcall(function()
            resetCooldowns()
        end)
    end
end)

RegisterNetEvent('prp-pettycrime:server:postboxLockpick', function(entityName, entityModel, entityCoords, locationLabel)    local playerId = source
    local stateId = bridge.fw.getIdentifier(playerId)
    if not stateId then return end

    local ped = GetPlayerPed(playerId)
    if not ped or not DoesEntityExist(ped) then return end

    local coords = GetEntityCoords(ped)
    if #(coords - entityCoords) > Config.PostBoxes.targetDistance then
        bridge.log.send(SvConfig.LogWebhook, locale("logs.postbox.too_far.title"), locale("logs.postbox.too_far.description"), {
            character_id = stateId, player_name = GetPlayerName(playerId),
            player_coords = FormatVec3(coords), entity_coords = FormatVec3(entityCoords), entity_model = entityName
        })
        return
    end

    local key = GetLocationKey(entityCoords)
    if not allowedLocations[key] then
        TriggerClientEvent("prp-bridge:notify", playerId, "error", locale("notifications.letterbox.cant_open"))
        bridge.log.send(SvConfig.LogWebhook, locale("logs.postbox.invalid_location.title"), locale("logs.postbox.invalid_location.description"), {
            character_id = stateId, player_name = GetPlayerName(playerId),
            player_coords = FormatVec3(coords), entity_coords = FormatVec3(entityCoords), entity_model = entityName
        })
        return
    end

    if not allowedModels[entityModel] or entityModel ~= allowedLocations[key] then
        bridge.log.send(SvConfig.LogWebhook, locale("logs.postbox.invalid_model.title"), locale("logs.postbox.invalid_model.description"), {
            character_id = stateId, player_name = GetPlayerName(playerId),
            player_coords = FormatVec3(coords), entity_coords = FormatVec3(entityCoords), entity_model = entityName
        })
        return
    end

    if lockpickedLocations[key] then return end

    local actionData = SvConfig.PostBoxes
    local gameData = actionData.minigame

    HeatAction(playerId, "post_box", entityCoords, locationLabel)

    local minigameResult = lib.callback.await("prp-bridge:minigame", playerId, gameData.type, gameData.gameOptions, gameData.otherOptions)

    if not minigameResult then
        TriggerClientEvent("prp-bridge:notify", playerId, "error", locale("notifications.postbox.failed_minigame"))
        return
    end

    lockpickedLocations[key] = true
    lootableLocations[key] = math.random(actionData.minLootableCount, actionData.maxLootableCount)
    TriggerClientEvent('prp-pettycrime:client:postboxUpdateOptionState', -1, key, 'lockpicked')
    TriggerClientEvent("prp-bridge:notify", playerId, "info", locale("notifications.postbox.opened"))
end)

RegisterNetEvent('prp-pettycrime:server:postboxSteal', function(entityName, entityModel, entityCoords)
    local playerId = source

    HeatAction(playerId, 'post_box', entityCoords)
    local stateId = bridge.fw.getIdentifier(playerId)
    if not stateId then
        return
    end

    local ped = GetPlayerPed(playerId)
    if not ped or not DoesEntityExist(ped) then
        return
    end

    local coords = GetEntityCoords(ped)
    if #(coords - entityCoords) > 3.0 then
        bridge.log.send(
            SvConfig.LogWebhook,
            locale("logs.letterbox.too_far.title"),
            locale("logs.letterbox.too_far.description"),
            {
                character_id = stateId,
                player_name = GetPlayerName(playerId),
                player_coords = FormatVec3(coords),
                entity_coords = FormatVec3(entityCoords)
            }
        )

        return
    end

    local key = GetLocationKey(entityCoords)
    if not allowedLocations[key] then
        TriggerClientEvent("prp-bridge:notify", playerId, "error", locale("notifications.letterbox.cant_open"))
        bridge.log.send(
            SvConfig.LogWebhook,
            locale("logs.letterbox.invalid_location.title"),
            locale("logs.letterbox.invalid_location.description"),
            {
                character_id = stateId,
                player_name = GetPlayerName(playerId),
                player_coords = FormatVec3(coords),
                entity_coords = FormatVec3(entityCoords)
            }
        )

        return
    end

    if not allowedModels[entityModel] or entityModel ~= allowedLocations[key] then
        bridge.log.send(
            SvConfig.LogWebhook,
            locale("logs.letterbox.invalid_model.title"),
            locale("logs.letterbox.invalid_model.description"),
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

    if not lootableLocations[key] or not lockpickedLocations[key] then
        return
    end

    local actionData = lib.table.deepclone(SvConfig.PostBoxes)
    local progressBarData = actionData.stealProgressBar
    local result = lib.callback.await("prp-bridge:progress", playerId, {
        duration = progressBarData.duration,
        label = progressBarData.text,
        controlDisables = progressBarData.disable,
        animation = {
            animDict = progressBarData.anim.dict,
            animClip = progressBarData.anim.clip,
            animFlag = progressBarData.anim.flag
        }
    })

    if not result then
        return
    end

    if actionData.stuckChance > math.random(1, 100) then
        TriggerClientEvent('prp-pettycrime:client:postboxSetStuck', playerId, actionData.stuckAnim, actionData.unstuckAnim, actionData.unstuckMinigame, actionData.unstuckProgressBar)
        return
    end

    if lootableLocations[key] < 1 then
        local randomMessage = actionData.emptyBoxTexts[math.random(1, #actionData.emptyBoxTexts)]
        TriggerClientEvent("prp-bridge:notify", playerId, "info", randomMessage)
        return
    end

    lootableLocations[key] -= 1

    GiveRewards(playerId, actionData.lootRolls, actionData.lootTable, actionData.guaranteedRarities)
    TriggerClientEvent("prp-bridge:notify", playerId, "info", locale("notifications.postbox.found_something"))

    if lootableLocations[key] == 0 then
        if SvConfig.PostBoxes.rep.enabled then
            bridge.fw.addRep(playerId, SvConfig.PostBoxes.rep.type, SvConfig.PostBoxes.rep.value, "petty_crime_postbox_steal")
        end

        local cooldownDuration = math.random(actionData.minCooldown, actionData.maxCooldown)
        cooldownLocations[key] = os.time() + (60 * cooldownDuration)
    end
end)

