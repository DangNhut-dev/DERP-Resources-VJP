--[[
░▒▓████████▓▒░▒▓██████▓▒░       ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░  
   ░▒▓█▓▒░  ░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
   ░▒▓█▓▒░  ░▒▓█▓▒░             ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
   ░▒▓█▓▒░  ░▒▓█▓▒░             ░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░  
   ░▒▓█▓▒░  ░▒▓█▓▒░             ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
   ░▒▓█▓▒░  ░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
   ░▒▓█▓▒░   ░▒▓██████▓▒░       ░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░░▒▓███████▓▒░  
                                                                         
 This File Leaked By TC HUB Team, Join Our Server For More
 DISCORD: - https://discord.gg/k3S8RjkPWc - https://t.me/+RgDxwPX3L7w2ODBk - https://tchub.shop/
--]]

local busyPedNetIds = {} 
local playerCooldowns = {} 

RegisterNetEvent("prp-pettycrime:server:pickpocketPed", function(netId, zoneScumminess)
    local playerId = source
    local currentTime = os.time()

    local stateId = bridge.fw.getIdentifier(playerId)
    if not stateId then
        return
    end

    if playerCooldowns[playerId] and (currentTime < playerCooldowns[playerId]) then
        TriggerClientEvent("prp-bridge:notify", playerId, "error", locale("notifications.pickpocket.player_cooldown"))
        return
    end

    if busyPedNetIds[netId] and (currentTime < busyPedNetIds[netId]) then
        TriggerClientEvent("prp-bridge:notify", playerId, "error", locale("notifications.pickpocket.npc_cooldown"))
        return
    end

    busyPedNetIds[netId] = currentTime + SvConfig.PickPocket.npcCooldown

    local progressBarData = SvConfig.PickPocket.progress
    local finished = lib.callback.await("prp-bridge:progress", playerId, {
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
        return
    end

    local ped = GetPlayerPed(playerId)
    if not ped or not DoesEntityExist(ped) then
        return
    end

    local entity = NetworkGetEntityFromNetworkId(netId)
    if not entity or not DoesEntityExist(entity) then
        return
    end

    if GetEntityType(entity) ~= 1 then
        return
    end

    local pedCoords = GetEntityCoords(ped)
    local entityCoords = GetEntityCoords(entity)

    if #(pedCoords - entityCoords) > 30.0 then
        bridge.log.send(
            SvConfig.LogWebhook,
            locale("logs.pickpocket.too_far.title"),
            locale("logs.pickpocket.too_far.description"),
            {
                character_id = stateId,
                player_name = GetPlayerName(playerId),
                player_coords = FormatVec3(pedCoords),
                entity_coords = FormatVec3(entityCoords),
                ped_net_id = netId
            }
        )
        return
    end

    local minigameData = SvConfig.PickPocket.minigame
    local minigameResult = lib.callback.await("prp-bridge:minigame", playerId, minigameData.type, minigameData.options, minigameData.otherOptions)
    if not minigameResult then
        bridge.fw.notify(playerId, "error", locale("notifications.pickpocket.npc_escaped"))
        return
    end

    if #(pedCoords - entityCoords) > Config.PickPocket.targetDistance then
        TriggerClientEvent("prp-bridge:notify", playerId, "error", locale("notifications.pickpocket.npc_escaped"))
        return
    end

    local lootData = lib.table.deepclone(SvConfig.PickPocket.lootTables[zoneScumminess])
    if not lootData then
        TriggerClientEvent("prp-bridge:notify", playerId, "error", locale("notifications.pickpocket.nothing_found"))
        return
    end

    GiveRewards(playerId, lootData.lootRolls, lootData.lootTable, lootData.guaranteedRaritiese)
    TriggerClientEvent("prp-bridge:notify", playerId, "info", locale("notifications.pickpocket.found_items"))

    if SvConfig.PickPocket.rep.enabled then
        bridge.fw.addRep(playerId, SvConfig.PickPocket.rep.type, SvConfig.PickPocket.rep.amount, "pick_pocket")
    end

    currentTime = os.time()
    playerCooldowns[playerId] = currentTime + SvConfig.PickPocket.playerCooldown
end)

