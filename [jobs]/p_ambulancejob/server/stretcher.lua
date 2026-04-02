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

-- Event: Remove/pickup stretcher from world
RegisterNetEvent("p_ambulancejob/server/stretcher/remove", function(data)
  -- Validate input data
  if not data or not data.netId then
    return
  end
  
  -- Get stretcher entity from network ID
  local stretcherEntity = NetworkGetEntityFromNetworkId(data.netId)
  
  -- Validate entity exists
  if not stretcherEntity or stretcherEntity == 0 or not DoesEntityExist(stretcherEntity) then
    return
  end
  
  local sourcePlayer = source
  
  -- Check distance between player and stretcher
  local playerCoords = GetEntityCoords(GetPlayerPed(sourcePlayer))
  local stretcherCoords = GetEntityCoords(stretcherEntity)
  local distance = #(playerCoords - stretcherCoords)
  
  if distance > 7.0 then
    return
  end
  
  -- Check if player has required job permissions
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  if not playerJob or not Editable.allJobs[playerJob.name] then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  -- Clear stretcher on owner's client if they exist
  local stretcherOwner = NetworkGetEntityOwner(stretcherEntity)
  if stretcherOwner and stretcherOwner ~= 0 then
    TriggerClientEvent("p_ambulancejob/client/stretcher/clear", stretcherOwner)
  end
  
  -- Return stretcher item to player's inventory
  Bridge.Inventory.addItem(sourcePlayer, "stretcher", 1)
  
  -- Delete stretcher entity from world
  DeleteEntity(stretcherEntity)
end)

-- Event: Attach player to stretcher
RegisterNetEvent("p_ambulancejob/server/stretcher/attachPlayer", function(targetPlayerId, stretcherNetId)
  -- Validate parameters
  if not targetPlayerId or type(targetPlayerId) ~= "number" or targetPlayerId < 1 then
    return
  end
  
  if not stretcherNetId or type(stretcherNetId) ~= "number" then
    return
  end
  
  local sourcePlayer = source
  
  -- Check distance between medic and target player
  local sourceCoords = GetEntityCoords(GetPlayerPed(sourcePlayer))
  local targetCoords = GetEntityCoords(GetPlayerPed(targetPlayerId))
  local distance = #(sourceCoords - targetCoords)
  
  if distance > 7.0 then
    return
  end
  
  -- Get stretcher entity
  local stretcherEntity = NetworkGetEntityFromNetworkId(stretcherNetId)
  
  -- Validate stretcher exists
  if not stretcherEntity or stretcherEntity == 0 or not DoesEntityExist(stretcherEntity) then
    return
  end
  
  -- Check distance between target player and stretcher
  local stretcherCoords = GetEntityCoords(stretcherEntity)
  local targetToStretcherDistance = #(targetCoords - stretcherCoords)
  
  if targetToStretcherDistance > 7.0 then
    return
  end
  
  -- Check if player has required job permissions
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  if not playerJob or not Editable.allJobs[playerJob.name] then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  -- Trigger client-side attachment
  TriggerClientEvent("p_ambulancejob/client/stretcher/attachPlayer", targetPlayerId, stretcherNetId)
end)

-- Event: Detach player from stretcher
RegisterNetEvent("p_ambulancejob/server/stretcher/detachPlayer", function(targetPlayerId, stretcherNetId)
  -- Validate parameters
  if not targetPlayerId or type(targetPlayerId) ~= "number" or targetPlayerId < 1 then
    return
  end
  
  if not stretcherNetId or type(stretcherNetId) ~= "number" then
    return
  end
  
  local sourcePlayer = source
  
  -- Check distance between medic and target player
  local sourceCoords = GetEntityCoords(GetPlayerPed(sourcePlayer))
  local targetCoords = GetEntityCoords(GetPlayerPed(targetPlayerId))
  local distance = #(sourceCoords - targetCoords)
  
  if distance > 7.0 then
    return
  end
  
  -- Get stretcher entity
  local stretcherEntity = NetworkGetEntityFromNetworkId(stretcherNetId)
  
  -- Validate stretcher exists
  if not stretcherEntity or stretcherEntity == 0 or not DoesEntityExist(stretcherEntity) then
    return
  end
  
  -- Check distance between target player and stretcher
  local stretcherCoords = GetEntityCoords(stretcherEntity)
  local targetToStretcherDistance = #(targetCoords - stretcherCoords)
  
  if targetToStretcherDistance > 7.0 then
    return
  end
  
  -- Check if player has required job permissions
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  if not playerJob or not Editable.allJobs[playerJob.name] then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  -- Trigger client-side detachment
  TriggerClientEvent("p_ambulancejob/client/stretcher/detachPlayer", targetPlayerId, stretcherNetId)
end)

-- Event: Load/unload stretcher into/from vehicle
RegisterNetEvent("p_ambulancejob/server/stretcher/vehicle", function(data)
  -- Validate input data
  if not data or not data.netId or type(data.state) ~= "boolean" then
    return
  end
  
  local sourcePlayer = source
  
  -- Check distance between player and stretcher
  local playerCoords = GetEntityCoords(GetPlayerPed(sourcePlayer))
  
  -- Get stretcher entity
  local stretcherEntity = NetworkGetEntityFromNetworkId(data.netId)
  
  -- Validate stretcher exists
  if not stretcherEntity or stretcherEntity == 0 or not DoesEntityExist(stretcherEntity) then
    return
  end
  
  local stretcherCoords = GetEntityCoords(stretcherEntity)
  local distance = #(playerCoords - stretcherCoords)
  
  if distance > 7.0 then
    return
  end
  
  -- Get vehicle entity
  local vehicleEntity = NetworkGetEntityFromNetworkId(data.vehicleId)
  
  -- Validate vehicle exists
  if not vehicleEntity or vehicleEntity == 0 or not DoesEntityExist(vehicleEntity) then
    return
  end
  
  -- Check if player has required job permissions
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  if not playerJob or not Editable.allJobs[playerJob.name] then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  if data.state then
    -- Loading stretcher into vehicle
    
    -- Check if vehicle already has a stretcher
    if Entity(vehicleEntity).state.hasStretcher then
      Bridge.Notify.showNotify(sourcePlayer, locale("vehicle_already_has_stretcher"), "error")
      return
    end
    
    -- Set vehicle state to indicate it has a stretcher
    Entity(vehicleEntity).state:set("hasStretcher", data.netId, true)
  else
    -- Unloading stretcher from vehicle
    Entity(vehicleEntity).state:set("hasStretcher", false, true)
  end
  
  -- Sync to vehicle owner if they exist
  local vehicleOwner = NetworkGetEntityOwner(vehicleEntity)
  if vehicleOwner and vehicleOwner ~= 0 then
    TriggerClientEvent("p_ambulancejob/client/stretcher/vehicle", vehicleOwner, data)
  end
  
  -- Sync to source player
  TriggerClientEvent("p_ambulancejob/client/stretcher/vehicle", sourcePlayer, data)
end)