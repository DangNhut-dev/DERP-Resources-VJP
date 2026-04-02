-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================


-- Wait for Config to be loaded
while not (Config and Config.Death) do
  Wait(100)
end

-- Test function (debugging remnant)
function test()
  local schools = GlobalState["p_dmvschool/Schools"]
  if schools and schools[k] then
    return schools[k].theoryQuestions
  end
end

-- Initialize Death module
Death = {}

-- Saves player death data to database
function Death.save(self, playerId)
  if not playerId or playerId < 1 then
    return
  end

  -- Safely get player ped
  local success, ped = pcall(GetPlayerPed, playerId)
  if not (success and ped) or ped == 0 then
    return
  end

  Bridge.Debug(string.format("Fetched player ped for playerId: %s, ped: %s", playerId, tostring(ped)))

  -- Get player health and armor
  local health = GetEntityHealth(ped)
  local armor = GetPedArmour(ped)
  local playerState = Player(playerId).state

  -- If player is dead, set health to 0
  if playerState.isDead then
    health = 0
  end

  -- Get player identifier
  local identifier = Bridge.Framework.getUniqueId(playerId)
  Bridge.Debug(string.format("Fetched identifier for playerId %s: %s", playerId, tostring(identifier)))

  if not identifier then
    return
  end

  -- Build death data object
  local deathData = {
    health = health,
    armour = armor,
    type = playerState.deathType or "none",
    damages = playerState.damages or {},
    bloodType = playerState.bloodType or nil
  }

  -- Save to framework storage
  Editable:frameworkDataSave(identifier, deathData)
  Editable:frameworkDeathSave(playerId, deathData)

  Bridge.Debug(string.format(
    "Saving death data for playerId: %s, identifier: %s, data: %s",
    playerId,
    identifier,
    json.encode(deathData)
  ))

  -- Send webhook log
  Bridge.Logs.Send(
    playerId,
    "Player Data Saved",
    string.format("Player %s death data has been saved", Bridge.Framework.getPlayerName(playerId)),
    Webhooks and Webhooks.death or nil
  )
end

-- ESX player loaded event
AddEventHandler("esx:playerLoaded", function(playerId)
  if not playerId or playerId < 1 then
    return
  end

  Wait(2500)

  local playerState = Player(playerId).state
  local savedData = Editable:frameworkDataFetch(playerId)

  -- Restore damages if they exist
  if savedData and savedData.damages then
    playerState:set("damages", savedData.damages, true)
  end

  -- Handle blood types
  if Config.BloodTypes and Config.BloodTypes.enabled then
    local bloodType = savedData and savedData.bloodType

    -- Assign random blood type if none exists
    if not bloodType then
      local bloodTypes = Config.BloodTypes.types
      bloodType = bloodTypes[math.random(1, #bloodTypes)]

      -- Initialize saved data if it doesn't exist
      if not savedData then
        savedData = {
          health = 200,
          armour = 0,
          type = "none"
        }
      end

      savedData.bloodType = bloodType

      Bridge.Debug(string.format(
        "Assigned blood type %s to playerId: %s, identifier: %s",
        bloodType,
        playerId,
        tostring(Bridge.Framework.getUniqueId(playerId))
      ))
    end

    -- Set blood type in player state and framework
    if bloodType then
      playerState:set("bloodType", bloodType, true)
      
      local player = Bridge.Framework.getPlayerById(playerId)
      player.set("bloodType", bloodType)
    end
  end

  -- Store ambulance data in player state
  playerState:set("ambulanceData", savedData, true)

  Bridge.Debug(string.format(
    "Fetched ambulance data for playerId: %s, identifier: %s, data: %s",
    playerId,
    tostring(Bridge.Framework.getUniqueId(playerId)),
    json.encode(savedData)
  ))
end)

-- QBCore player loaded event
RegisterNetEvent("QBCore:Server:OnPlayerLoaded", function()
  local playerId = source
  if not playerId or playerId < 1 then
    return
  end

  -- Skip if ESX is running
  if GetResourceState("es_extended") == "started" then
    return
  end

  Wait(3000)

  local playerState = Player(playerId).state
  local savedData = Editable:frameworkDataFetch(playerId)

  -- Restore damages if they exist
  if savedData and savedData.damages then
    playerState:set("damages", savedData.damages, true)
  end

  if Bridge and Bridge.Config and Bridge.Config.Debug then
    lib.print.info("Player loaded, initializing damages and blood type")
  end

  -- Handle blood types for QBCore
  if Config.BloodTypes and Config.BloodTypes.enabled then
    local player = Bridge.Framework.getPlayerById(playerId)
    local bloodType

    -- Determine blood type source
    if Config.BloodTypes.overwriteQB then
      bloodType = savedData and savedData.bloodType
    else
      bloodType = player.PlayerData.metadata.bloodtype
    end

    -- Assign random blood type if none exists
    if not bloodType then
      local bloodTypes = Config.BloodTypes.types
      bloodType = bloodTypes[math.random(1, #bloodTypes)]

      -- Initialize saved data if it doesn't exist
      if not savedData then
        savedData = {
          health = 200,
          armour = 0,
          type = "none"
        }
      end

      player.Functions.SetMetaData("bloodtype", bloodType)

      Bridge.Debug(string.format(
        "Assigned blood type %s to playerId: %s, identifier: %s",
        bloodType,
        playerId,
        tostring(Bridge.Framework.getUniqueId(playerId))
      ))
    end

    savedData.bloodType = bloodType
    playerState:set("bloodType", bloodType, true)
  end

  -- Store ambulance data in player state
  playerState:set("ambulanceData", savedData, true)

  Bridge.Debug(string.format(
    "Fetched ambulance data for playerId: %s, identifier: %s, data: %s",
    playerId,
    tostring(Bridge.Framework.getUniqueId(playerId)),
    json.encode(savedData)
  ))
end)

-- Player disconnect event - save data
AddEventHandler("playerDropped", function()
  local playerId = source
  if not playerId or playerId < 1 then
    return
  end

  Death:save(playerId)
end)

-- Death state change event
RegisterNetEvent("p_ambulancejob/onDeathStateChange", function(deathType, deathInfo)
  local playerId = source
  
  -- Save death data
  Death:save(playerId)

  -- Log death details if info provided
  if deathInfo then
    local victimCoords = deathInfo.victimCoords and 
      string.format("vec3(%.2f, %.2f, %.2f)", deathInfo.victimCoords.x, deathInfo.victimCoords.y, deathInfo.victimCoords.z) or
      "N/A"

    local killerCoords = deathInfo.killerCoords and
      string.format("vec3(%.2f, %.2f, %.2f)", deathInfo.killerCoords.x, deathInfo.killerCoords.y, deathInfo.killerCoords.z) or
      "N/A"

    local distance = deathInfo.distance and tostring(deathInfo.distance) or "N/A"
    local killerId = deathInfo.killer and tostring(deathInfo.killer) or "N/A"
    local killerName = deathInfo.killer and GetPlayerName(deathInfo.killer) or "N/A"
    local killerLicense = deathInfo.killer and Bridge.Framework.getUniqueId(deathInfo.killer) or "N/A"
    local cause = deathInfo.cause and DeathCauses[tostring(deathInfo.cause)] or "N/A"

    Bridge.Logs.Send(
      playerId,
      "Death State Changed",
      string.format([[
Death type: %s
Victim Coords: %s
Killer Coords: %s
Distance: %s
Killer ID: %s
Killer Name: %s
Killer License: %s
Cause: %s]], tostring(deathType), victimCoords, killerCoords, distance, killerId, killerName, killerLicense, cause),
      Webhooks and Webhooks.death or nil
    )
  elseif deathType == "none" then
    -- Player was revived
    Bridge.Logs.Send(
      playerId,
      "Player Revived",
      "Player has been revived",
      Webhooks and Webhooks.death or nil
    )
  end
end)

-- Initial wait before setting up commands
Wait(1000)

-- =====================================================
-- ADMIN COMMANDS
-- =====================================================

-- /kill command - Kill a specific player
if Config.Death.commands.kill and Config.Death.commands.kill.enabled then
  lib.addCommand(Config.Death.commands.kill.names, {
    help = locale("command_kill_help"),
    params = {
      {
        name = "target",
        help = locale("command_kill_param_target"),
        optional = true
      }
    },
    restricted = Config.Death.commands.kill.restricted
  }, function(source, args, raw)
    local playerId = source
    local targetId = playerId

    -- Parse target parameter
    if args.target and tonumber(args.target) then
      targetId = tonumber(args.target)
    end

    -- Validate target player exists
    local targetPlayer = Bridge.Framework.getPlayerById(targetId)
    if not targetPlayer then
      Bridge.Notify.showNotify(playerId, locale("player_not_found"), "error")
      return
    end

    -- Check permissions if canUse function is defined
    if Config.Death.commands.kill.canUse then
      if not Config.Death.commands.kill.canUse(source, targetId) then
        Bridge.Notify.showNotify(source, locale("no_access"), "error")
        return
      end
    end

    -- Execute kill
    TriggerClientEvent("p_ambulancejob/client/death/kill", targetId)

    -- Log action
    local executor = (not playerId or playerId == 0) and "Console" or playerId
    Bridge.Logs.Send(
      executor,
      "Player Killed",
      string.format(
        "Player %s has been killed (ID: %s, License: %s)",
        Bridge.Framework.getPlayerName(targetId),
        targetId,
        Bridge.Framework.getUniqueId(targetId)
      ),
      Webhooks and Webhooks.kill or nil
    )
  end)
end

-- /killall command - Kill all players
if Config.Death.commands.killall and Config.Death.commands.killall.enabled then
  lib.addCommand(Config.Death.commands.killall.names, {
    help = locale("command_killall_help"),
    restricted = Config.Death.commands.killall.restricted
  }, function(source, args, raw)
    local playerId = source

    -- Check permissions if canUse function is defined
    if Config.Death.commands.killall.canUse then
      if not Config.Death.commands.killall.canUse(playerId, -1) then
        Bridge.Notify.showNotify(playerId, locale("no_access"), "error")
        return
      end
    end

    -- Execute kill all
    TriggerClientEvent("p_ambulancejob/client/death/kill", -1)

    -- Log action
    local executor = (not playerId or playerId == 0) and "Console" or playerId
    Bridge.Logs.Send(
      executor,
      "All Players Killed",
      "All players have been killed",
      Webhooks and Webhooks.kill or nil
    )
  end)
end

-- /killradius command - Kill players in radius
if Config.Death.commands.killradius and Config.Death.commands.killradius.enabled then
  lib.addCommand(Config.Death.commands.killradius.names, {
    help = locale("command_killradius_help"),
    params = {
      {
        name = "radius",
        type = "number",
        help = locale("command_killradius_param_radius"),
        optional = true
      }
    },
    restricted = Config.Death.commands.killradius.restricted
  }, function(source, args, raw)
    local playerId = source
    args.radius = args.radius or 2.0

    -- Check permissions if canUse function is defined
    if Config.Death.commands.killradius.canUse then
      if not Config.Death.commands.killradius.canUse(playerId, "radius") then
        Bridge.Notify.showNotify(playerId, locale("no_access"), "error")
        return
      end
    end

    -- Get nearby players
    local ped = GetPlayerPed(playerId)
    local nearbyPlayers = lib.getNearbyPlayers(GetEntityCoords(ped), args.radius, true)

    -- Kill each nearby player (except command executor)
    for i = 1, #nearbyPlayers do
      if nearbyPlayers[i].id ~= playerId then
        TriggerClientEvent("p_ambulancejob/client/death/kill", nearbyPlayers[i].id)
      end
    end

    -- Log action
    local executor = (not playerId or playerId == 0) and "Console" or playerId
    Bridge.Logs.Send(
      executor,
      "Players Killed in Radius",
      string.format("Player in %s radius has been killed", args.radius),
      Webhooks and Webhooks.kill or nil
    )
  end)
end

-- /revive command - Revive a specific player
if Config.Death.commands.revive and Config.Death.commands.revive.enabled then
  lib.addCommand(Config.Death.commands.revive.names, {
    help = locale("command_revive_help"),
    params = {
      {
        name = "target",
        help = locale("command_revive_param_target"),
        optional = true
      }
    },
    restricted = Config.Death.commands.revive.restricted
  }, function(source, args, raw)
    local playerId = source
    local targetId = playerId

    -- Parse target parameter
    if args.target and tonumber(args.target) then
      targetId = tonumber(args.target)
    elseif args.target == "me" then
      targetId = playerId
    end

    -- Validate target player exists
    local targetPlayer = Bridge.Framework.getPlayerById(targetId)
    if not targetPlayer then
      Bridge.Notify.showNotify(playerId, locale("player_not_found"), "error")
      return
    end

    -- Check permissions if canUse function is defined
    if Config.Death.commands.revive.canUse then
      if not Config.Death.commands.revive.canUse(playerId, targetId) then
        Bridge.Notify.showNotify(playerId, locale("no_access"), "error")
        return
      end
    end

    -- Execute revive
    TriggerClientEvent("p_ambulancejob/client/death/revive", targetId)

    -- Log action
    local executor = (not playerId or playerId == 0) and "Console" or playerId
    Bridge.Logs.Send(
      executor,
      "Player Revived",
      string.format(
        "Player %s has been revived (ID: %s, License: %s)",
        Bridge.Framework.getPlayerName(targetId),
        targetId,
        Bridge.Framework.getUniqueId(targetId)
      ),
      Webhooks and Webhooks.revive or nil
    )
  end)
end

-- Revive utilities event
RegisterNetEvent("p_ambulancejob/server/death/reviveUtils", function()
  local playerId = source
  Config.Death.commands.revive.serverFunction(nil, playerId)
end)

-- Heal utilities event
RegisterNetEvent("p_ambulancejob/server/death/healUtils", function()
  local playerId = source
  Config.Death.commands.heal.serverFunction(nil, playerId)
end)

-- Target revive event (for medic players)
RegisterNetEvent("p_ambulancejob/server/death/targetRevive", function(targetId)
  local playerId = source
  
  -- Get peds and positions
  local medicPed = GetPlayerPed(playerId)
  local targetPed = GetPlayerPed(targetId)
  local medicCoords = GetEntityCoords(medicPed)
  local targetCoords = GetEntityCoords(targetPed)

  -- Check distance (max 7 meters)
  local distance = #(medicCoords - targetCoords)
  if distance > 7.0 then
    return
  end

  -- Execute revive
  Config.Death.commands.revive.serverFunction(nil, targetId)
  TriggerClientEvent("p_ambulancejob/client/death/revive", targetId)
end)

-- /reviveall command - Revive all players
if Config.Death.commands.reviveall and Config.Death.commands.reviveall.enabled then
  lib.addCommand(Config.Death.commands.reviveall.names, {
    help = locale("command_revive_help"),
    restricted = Config.Death.commands.reviveall.restricted
  }, function(source, args, raw)
    local playerId = source

    -- Check permissions if canUse function is defined
    if Config.Death.commands.reviveall.canUse then
      if not Config.Death.commands.reviveall.canUse(playerId, -1) then
        Bridge.Notify.showNotify(playerId, locale("no_access"), "error")
        return
      end
    end

    -- Execute revive all
    TriggerClientEvent("p_ambulancejob/client/death/revive", -1)

    -- Log action
    local executor = (not playerId or playerId == 0) and "Console" or playerId
    Bridge.Logs.Send(
      executor,
      "All Players Revived",
      "All players have been revived",
      Webhooks and Webhooks.revive or nil
    )
  end)
end

-- /reviveradius command - Revive players in radius
if Config.Death.commands.reviveradius and Config.Death.commands.reviveradius.enabled then
  lib.addCommand(Config.Death.commands.reviveradius.names, {
    help = locale("command_reviveradius_help"),
    params = {
      {
        name = "radius",
        type = "number",
        help = locale("command_reviveradius_param_radius"),
        optional = true
      }
    },
    restricted = Config.Death.commands.reviveradius.restricted
  }, function(source, args, raw)
    local playerId = source
    args.radius = args.radius or 2.0

    -- Check permissions if canUse function is defined
    if Config.Death.commands.reviveradius.canUse then
      if not Config.Death.commands.reviveradius.canUse(playerId, "radius") then
        Bridge.Notify.showNotify(playerId, locale("no_access"), "error")
        return
      end
    end

    -- Get nearby players
    local ped = GetPlayerPed(playerId)
    local nearbyPlayers = lib.getNearbyPlayers(GetEntityCoords(ped), args.radius, true)

    -- Revive each nearby player (except command executor)
    for i = 1, #nearbyPlayers do
      if nearbyPlayers[i].id ~= playerId then
        TriggerClientEvent("p_ambulancejob/client/death/revive", nearbyPlayers[i].id)
      end
    end

    -- Log action
    local executor = (not playerId or playerId == 0) and "Console" or playerId
    Bridge.Logs.Send(
      executor,
      "All Players Revived",
      "Players in radius have been revived",
      Webhooks and Webhooks.revive or nil
    )
  end)
end

-- /heal command - Heal a specific player
if Config.Death.commands.heal and Config.Death.commands.heal.enabled then
  lib.addCommand(Config.Death.commands.heal.names, {
    help = locale("command_heal_help"),
    params = {
      {
        name = "target",
        help = locale("command_heal_param_target"),
        optional = true
      }
    },
    restricted = Config.Death.commands.heal.restricted
  }, function(source, args, raw)
    local playerId = source
    local targetId = playerId

    -- Parse target parameter
    if args.target and tonumber(args.target) then
      targetId = tonumber(args.target)
    elseif args.target == "me" then
      targetId = playerId
    end

    -- Check permissions if canUse function is defined
    if Config.Death.commands.heal.canUse then
      if not Config.Death.commands.heal.canUse(playerId, targetId) then
        Bridge.Notify.showNotify(playerId, locale("no_access"), "error")
        return
      end
    end

    -- Validate target player exists
    local targetPlayer = Bridge.Framework.getPlayerById(targetId)
    if not targetPlayer then
      Bridge.Notify.showNotify(playerId, locale("player_not_found"), "error")
      return
    end

    -- Execute heal
    TriggerClientEvent("p_ambulancejob/client/death/heal", targetId, playerId)

    -- Log action
    local executor = (not playerId or playerId == 0) and "Console" or playerId
    Bridge.Logs.Send(
      executor,
      "Player Healed",
      string.format(
        "Player %s has been healed (ID: %s, License: %s)",
        Bridge.Framework.getPlayerName(targetId),
        targetId,
        Bridge.Framework.getUniqueId(targetId)
      ),
      Webhooks and Webhooks.heal or nil
    )
  end)
end