-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================



local test

function test()
  local globalState = GlobalState["p_dmvschool/Schools"]
  if globalState then
    globalState = globalState[k]
    if globalState then
      globalState = globalState.theoryQuestions
    end
  end
end

-- Defibrilator module
Defibrilator = {}

-- Use defibrilator on a patient
function Defibrilator.useOnPatient(self, sourcePlayer, targetPlayerId, success)
  -- Notify source player of result
  local resultKey = success and "success" or "fail"
  Bridge.Notify.showNotify(sourcePlayer, locale("defibrilator_used_" .. resultKey), "inform")
  
  -- If successful, reset target player's pulse
  if success then
    TriggerClientEvent("p_ambulancejob/client/pulse/reset", targetPlayerId)
  end
end

-- Event: Use defibrilator on a patient
RegisterNetEvent("p_ambulancejob/server/defibrilator/useOnPatient", function(data)
  local sourcePlayer = source
  
  -- Check if player has required job permissions
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  if not playerJob or not Editable.allJobs[playerJob.name] then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  -- Process defibrilator usage
  Defibrilator:useOnPatient(sourcePlayer, data.targetId, data.result)
end)

-- Event: Sync defibrilator DUI (screen interface) to all clients
RegisterNetEvent("p_ambulancejob/server/defibrilator/sync", function(targetPlayerId)
  local sourcePlayer = source
  
  -- Get coordinates for distance check
  local sourcePed = GetPlayerPed(sourcePlayer)
  local sourceCoords = GetEntityCoords(sourcePed)
  local targetCoords = GetEntityCoords(GetPlayerPed(targetPlayerId))
  local distance = #(sourceCoords - targetCoords)
  
  -- Verify player is within range
  if distance > 6.0 then
    return
  end
  
  -- Check if player has required job permissions
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  if not playerJob or not Editable.allJobs[playerJob.name] then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  -- Sync defibrilator DUI to all clients
  local targetPlayerName = Bridge.Framework.getPlayerName(targetPlayerId)
  TriggerClientEvent("p_ambulancejob/client/defibrilator/syncDUI", -1, targetPlayerId, targetPlayerName)
end)

-- Event: Remove defibrilator from world
RegisterNetEvent("p_ambulancejob/server/defibrilator/remove", function(defibrilatorNetId, duiId)
  -- Get entity from network ID
  local defibrilatorEntity = NetworkGetEntityFromNetworkId(defibrilatorNetId)
  
  -- Validate entity exists
  if not defibrilatorEntity or defibrilatorEntity == 0 or not DoesEntityExist(defibrilatorEntity) then
    return
  end
  
  local sourcePlayer = source
  
  -- Check distance to defibrilator
  local sourcePed = GetPlayerPed(sourcePlayer)
  local sourceCoords = GetEntityCoords(sourcePed)
  local defibrilatorCoords = GetEntityCoords(defibrilatorEntity)
  local distance = #(sourceCoords - defibrilatorCoords)
  
  if distance > 6.0 then
    return
  end
  
  -- Check if player has required job permissions
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  if not playerJob or not Editable.allJobs[playerJob.name] then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  -- Delete the defibrilator entity
  DeleteEntity(defibrilatorEntity)
  
  -- Return defibrilator item to player's inventory
  Bridge.Inventory.addItem(sourcePlayer, "defibrilator", 1)
  
  -- Remove DUI from all clients
  TriggerClientEvent("p_ambulancejob/client/defibrilator/removeDUI", -1, duiId)
end)