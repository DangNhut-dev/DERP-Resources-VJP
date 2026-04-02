-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================



local test

-- Wait for Config.Wheelchair to be available
while not (Config and Config.Wheelchair) do
  Wait(1)
end

-- Check if wheelchair feature is enabled
if not Config.Wheelchair.enabled then
  return
end

function test()
  local globalState = GlobalState["p_dmvschool/Schools"]
  if globalState then
    globalState = globalState[k]
    if globalState then
      globalState = globalState.theoryQuestions
    end
  end
end

-- Wheelchair management system
Wheelchair = {
  players = {}
}

-- Initialize wheelchair expiration thread
function Wheelchair.init(self)
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(5000) -- Check every 5 seconds
      
      local currentTime = os.time()
      
      -- Check all active wheelchairs for expiration
      for playerId, expiryTime in pairs(self.players) do
        if expiryTime < currentTime then
          -- Wheelchair has expired
          self.players[playerId] = nil
          
          local playerPed = GetPlayerPed(playerId)
          if playerPed and playerPed ~= 0 then
            -- Notify player that wheelchair has been removed
            Bridge.Notify.showNotify(playerId, locale("wheelchair_removed"), "inform")
            
            -- Trigger client-side removal
            TriggerClientEvent("p_ambulancejob/wheelchair/client/removeWheelchair", playerId)
            
            -- Log the removal
            local playerName = Bridge.Framework.getPlayerName(playerId)
            local logMessage = string.format("Player %s has had their wheelchair removed", playerName)
            local webhook = Webhooks and Webhooks.wheelchair or nil
            Bridge.Logs.Send(playerId, "Wheelchair Removed", logMessage, webhook)
          end
        end
      end
    end
  end)
end

-- Add a wheelchair to a player for a specific duration
function Wheelchair.newPlayer(self, targetPlayerId, durationMinutes)
  -- Calculate expiry time
  local expiryTime = os.time() + (durationMinutes * 60)
  self.players[targetPlayerId] = expiryTime
end

-- Event: Force wheelchair on a player
RegisterNetEvent("p_ambulancejob/server/wheelchair/forceWheelchair", function(data)
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
  local allowedJobs = Config.Wheelchair.allowedJobs
  local requiredGrade = allowedJobs[playerJob.name]
  
  if not requiredGrade or playerJob.grade < requiredGrade then
    Bridge.Notify.showNotify(sourcePlayer, locale("not_allowed"), "error")
    return
  end
  
  -- Trigger client-side wheelchair application
  TriggerClientEvent("p_ambulancejob/wheelchair/client/forceWheelchair", data.targetId)
  
  -- Add wheelchair to target player
  Wheelchair:newPlayer(data.targetId, data.time)
  
  -- Log the action
  local playerName = Bridge.Framework.getPlayerName(data.targetId)
  local logMessage = string.format(
    "Player %s has been given a wheelchair for %s minutes",
    playerName,
    data.time
  )
  local webhook = Webhooks and Webhooks.wheelchair or nil
  Bridge.Logs.Send(sourcePlayer, "Wheelchair Added", logMessage, webhook)
end)

-- Start the wheelchair system
Wheelchair:init()