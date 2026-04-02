-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================



local CrutchManager, test

function test()
  local globalState = GlobalState["p_dmvschool/Schools"]
  if globalState then
    globalState = globalState[k]
    if globalState then
      globalState = globalState.theoryQuestions
    end
  end
end

-- Wait for Config.BodyBag to be available
while not (Config and Config.BodyBag) do
  Wait(1)
end

-- Check if crutch feature is enabled
if not Config.Crutch.enabled then
  return
end

-- Initialize crutch manager
CrutchManager = {
  players = {}
}

GlobalState["p_ambulancejob/crutchPlayers"] = CrutchManager.players

-- Initialize crutch timer thread
function CrutchManager.init(self)
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(5000)
      
      -- Check all players with active crutches
      for playerId, expiryTime in pairs(self.players) do
        local currentTime = os.time()
        
        if expiryTime < currentTime then
          -- Remove expired crutch
          self.players[playerId] = nil
          
          local playerPed = GetPlayerPed(playerId)
          if playerPed and playerPed ~= 0 then
            -- Notify player that crutch has been removed
            Bridge.Notify.showNotify(playerId, locale("crutch_removed"), "inform")
            
            -- Trigger client-side removal
            TriggerClientEvent("p_ambulancejob/crutch/client/removeCrutch", playerId)
            
            -- Log the removal
            local playerName = Bridge.Framework.getPlayerName(playerId)
            local logMessage = string.format("Player %s has had their crutch removed", playerName)
            local webhook = Webhooks and Webhooks.crutch or nil
            Bridge.Logs.Send(_source, "Crutch Removed", logMessage, webhook)
          end
        end
      end
      
      -- Update global state
      GlobalState["p_ambulancejob/crutchPlayers"] = self.players
    end
  end)
end

-- Add a crutch to a player for a specific duration
function CrutchManager.newPlayer(self, sourcePlayer, targetPlayerId, durationMinutes)
  -- Calculate expiry time
  local expiryTime = os.time() + (durationMinutes * 60)
  self.players[targetPlayerId] = expiryTime
  
  -- Update global state
  GlobalState["p_ambulancejob/crutchPlayers"] = self.players
  
  -- Log the action
  local playerName = Bridge.Framework.getPlayerName(targetPlayerId)
  local logMessage = string.format("Player %s has been given a crutch for %s minutes", playerName, durationMinutes)
  local webhook = Webhooks and Webhooks.crutch or nil
  Bridge.Logs.Send(sourcePlayer, "Crutch Added", logMessage, webhook)
end

-- Event: Force crutch on self
RegisterNetEvent("p_ambulancejob/server/crutch/forceSelfCrutch", function(durationMinutes)
  -- Validate duration
  if not durationMinutes or type(durationMinutes) ~= "number" or durationMinutes < 1 then
    return
  end
  
  local sourcePlayer = source
  
  -- Add crutch to the player
  CrutchManager:newPlayer(sourcePlayer, sourcePlayer, durationMinutes)
  
  -- Trigger client-side crutch application
  TriggerClientEvent("p_ambulancejob/crutch/client/forceCrutch", sourcePlayer)
end)

-- Event: Force crutch on another player
RegisterNetEvent("p_ambulancejob/server/crutch/forceCrutch", function(data)
  -- Validate input data
  if not data or type(data) ~= "table" or not data.targetId or not data.time then
    return
  end
  
  local sourcePlayer = source
  
  -- Get player's job
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  if not playerJob then
    return
  end
  
  -- Check if player has permission (job and grade)
  local allowedJobs = Config.Crutch.allowedJobs
  local requiredGrade = allowedJobs[playerJob.name]
  
  if not requiredGrade or playerJob.grade < requiredGrade then
    Bridge.Notify.showNotify(sourcePlayer, locale("not_allowed"), "error")
    return
  end
  
  -- Add crutch to target player
  CrutchManager:newPlayer(sourcePlayer, data.targetId, data.time)
  
  -- Trigger client-side crutch application
  TriggerClientEvent("p_ambulancejob/crutch/client/forceCrutch", data.targetId)
end)

-- Event: Remove crutch from a player
RegisterNetEvent("p_ambulancejob/server/crutch/remove", function(targetPlayerId)
  -- Validate target player ID
  if not targetPlayerId or type(targetPlayerId) ~= "number" or targetPlayerId < 1 then
    return
  end
  
  local sourcePlayer = source
  
  -- Get player's job
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  if not playerJob then
    return
  end
  
  -- Check if player has permission (job and grade)
  local allowedJobs = Config.Crutch.allowedJobs
  local requiredGrade = allowedJobs[playerJob.name]
  
  if not requiredGrade or playerJob.grade < requiredGrade then
    Bridge.Notify.showNotify(sourcePlayer, locale("not_allowed"), "error")
    return
  end
  
  -- Check distance between source and target player
  local sourceCoords = GetEntityCoords(GetPlayerPed(sourcePlayer))
  local targetCoords = GetEntityCoords(GetPlayerPed(targetPlayerId))
  local distance = #(sourceCoords - targetCoords)
  
  if distance > 7.0 then
    return
  end
  
  -- Check if target player has an active crutch
  if not CrutchManager.players[targetPlayerId] then
    return
  end
  
  -- Remove crutch from player
  CrutchManager.players[targetPlayerId] = nil
  
  -- Trigger client-side removal
  TriggerClientEvent("p_ambulancejob/crutch/client/removeCrutch", targetPlayerId)
  
  -- Update global state
  GlobalState["p_ambulancejob/crutchPlayers"] = CrutchManager.players
  
  -- Log the removal
  local playerName = Bridge.Framework.getPlayerName(targetPlayerId)
  local logMessage = string.format("Player %s has had their crutch removed", playerName)
  local webhook = Webhooks and Webhooks.crutch or nil
  Bridge.Logs.Send(sourcePlayer, "Crutch Removed", logMessage, webhook)
end)

-- Start the crutch manager
CrutchManager:init()