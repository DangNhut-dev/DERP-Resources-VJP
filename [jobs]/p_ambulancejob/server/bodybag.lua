-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================



local test, RegisterApplyEvent, RegisterRemoveEvent

function test()
  local globalState = GlobalState
  globalState = globalState["p_dmvschool/Schools"]
  if globalState then
    globalState = globalState[k]
    if globalState then
      globalState = globalState.theoryQuestions
    end
  end
end

-- Event handler: Apply bodybag to a player
RegisterApplyEvent = RegisterNetEvent
RegisterNetEvent("p_ambulancejob/bodybag/server/apply", function(targetPlayerId)
  -- Validate target player ID
  if not targetPlayerId or type(targetPlayerId) ~= "number" or targetPlayerId < 1 then
    return
  end
  
  local sourcePlayer = source
  
  -- Check if player has required job permissions
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  if not playerJob or not Editable.allJobs[playerJob.name] then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  -- Verify player is within valid distance
  if not Utils:checkDistance(sourcePlayer, targetPlayerId) then
    return
  end
  
  -- Check if player has bodybag item in inventory
  local bodybagCount = Bridge.Inventory.getItemCount(sourcePlayer, "bodybag")
  if not bodybagCount or bodybagCount < 1 then
    return
  end
  
  -- Remove bodybag from inventory
  Bridge.Inventory.removeItem(sourcePlayer, "bodybag", 1)
  
  -- Trigger client event to apply bodybag
  TriggerClientEvent("p_ambulancejob/bodybag/client/apply", targetPlayerId)
  
  -- Set player state to indicate they are in a bodybag
  local targetPlayerState = Player(targetPlayerId).state
  targetPlayerState:set("isInBodyBag", true, true)
end)

-- Event handler: Remove bodybag from a player
RegisterRemoveEvent = RegisterNetEvent
RegisterNetEvent("p_ambulancejob/bodybag/server/remove", function(targetPlayerId, bodybagNetworkId)
  -- Validate parameters
  if not targetPlayerId or type(targetPlayerId) ~= "number" or targetPlayerId < 1 or not bodybagNetworkId then
    return
  end
  
  local sourcePlayer = source
  
  -- Check if player has required job permissions
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  if not playerJob or not Editable.allJobs[playerJob.name] then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  -- Verify player is within valid distance
  if not Utils:checkDistance(sourcePlayer, targetPlayerId) then
    return
  end
  
  -- Delete the bodybag entity
  local bodybagEntity = NetworkGetEntityFromNetworkId(bodybagNetworkId)
  if bodybagEntity and DoesEntityExist(bodybagEntity) then
    DeleteEntity(bodybagEntity)
  end
  
  -- Return bodybag to inventory
  Bridge.Inventory.addItem(sourcePlayer, "bodybag", 1)
  
  -- Trigger client event to remove bodybag
  TriggerClientEvent("p_ambulancejob/bodybag/client/remove", targetPlayerId)
  
  -- Update player state to indicate they are no longer in a bodybag
  local targetPlayerState = Player(targetPlayerId).state
  targetPlayerState:set("isInBodyBag", false, true)
end)

-- Event handler: Respawn player from bodybag
RegisterNetEvent("p_ambulancejob/bodybag/server/respawnPlayer", function(targetPlayerId, hospitalId)
  -- Check if respawn feature is enabled
  if not Config.BodyBag.respawnPlayer then
    return
  end
  
  local sourcePlayer = source
  
  -- Check if player has required job permissions
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  if not playerJob or not Editable.allJobs[playerJob.name] then
    Bridge.Notify.showNotify(sourcePlayer, locale("no_access"), "error")
    return
  end
  
  -- Verify target player is actually in a bodybag
  local isInBodyBag = Player(targetPlayerId).state.isInBodyBag
  if not isInBodyBag then
    return
  end
  
  -- Trigger respawn on client
  TriggerClientEvent("p_ambulancejob/check-in/client/respawnPlayer", targetPlayerId, hospitalId)
end)