-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================


-- Wait for config to load
while not Config or not Config.Stretcher do
  Citizen.Wait(1)
end

-- Exit if stretcher system is disabled
if not Config.Stretcher.enabled then
  return
end

-- Initialize Stretcher state table
Stretcher = {}
Stretcher.isAttached = false
Stretcher.attachedTo = false
Stretcher.folded = {}

-- Setup target options for stretcher system
Citizen.CreateThread(function()
  Citizen.Wait(2000)
  
  -- Setup global detach/vehicle options if enabled
  if Config.Stretcher.useDetachTarget then
    Bridge.Target.addGlobal({
      {
        name = "p_ambulancejob/stretcher/detach",
        label = locale("put_down_stretcher"),
        icon = "fa-solid fa-hand",
        distance = 2.0,
        groups = Editable.allJobs,
        onSelect = function()
          Stretcher:detach()
        end,
        canInteract = function()
          return Stretcher.isAttached
        end
      },
      {
        name = "p_ambulancejob/stretcher/putInVehicle",
        label = locale("put_stretcher_in_vehicle"),
        icon = "fa-solid fa-car",
        distance = 2.0,
        groups = Editable.allJobs,
        onSelect = function()
          Stretcher:vehicle(true)
        end,
        canInteract = function()
          return Stretcher.isAttached
        end
      }
    })
  end
  
  -- Setup vehicle target options
  Bridge.Target.addVehicle({
    {
      name = "p_ambulancejob/stretcher/removeFromVehicle",
      label = locale("pickup_stretcher"),
      icon = "fa-solid fa-hand",
      distance = 3.0,
      groups = Editable.allJobs,
      onSelect = function()
        Stretcher:vehicle(false)
      end,
      canInteract = function(vehicle)
        if Bridge and Bridge.Config and Bridge.Config.Debug then
          print(vehicle, Stretcher.object, DoesEntityExist(Stretcher.object), "checking stretcher entity")
        end
        
        if not Stretcher.object or not DoesEntityExist(Stretcher.object) then
          return false
        end
        
        if Bridge and Bridge.Config and Bridge.Config.Debug then
          print(GetEntityAttachedTo(Stretcher.object), "attached to entity")
        end
        
        return GetEntityAttachedTo(Stretcher.object) == vehicle
      end
    }
  })
  
  -- Setup player target options
  Bridge.Target.addPlayer({
    {
      name = "p_ambulancejob/stretcher/putOnStretcher",
      label = locale("put_player_on_stretcher"),
      icon = "fa-solid fa-person-walking",
      distance = 2.0,
      groups = Editable.allJobs,
      onSelect = function(data)
        local targetEntity = type(data) == "number" and data or data.entity
        
        if not targetEntity or targetEntity == 0 then
          return
        end
        
        local targetPlayerId = NetworkGetPlayerIndexFromPed(targetEntity)
        local targetServerId = GetPlayerServerId(targetPlayerId)
        Stretcher:attachPlayer(targetServerId)
      end,
      canInteract = function(entity)
        if not Stretcher.object then
          return false
        end
        
        if Stretcher.attachedPlayer then
          return false
        end
        
        local playerPos = GetEntityCoords(entity)
        local stretcherPos = GetEntityCoords(Stretcher.object)
        local distance = #(playerPos - stretcherPos)
        
        return distance < 7.0
      end
    }
  })
  
  -- Setup stretcher model target options
  local stretcherModels = {
    Config.Stretcher.prop.model,
    Config.Stretcher.prop.foldModel
  }
  
  local stretcherOptions = {
    {
      name = "p_ambulancejob/stretcher/toggleFold",
      label = locale("toggle_fold"),
      icon = "fa-solid fa-compress",
      distance = 2.0,
      groups = Editable.allJobs,
      onSelect = function()
        Stretcher:toggleFold()
      end,
      canInteract = function(entity)
        return Stretcher.object and Stretcher.object == entity
      end
    },
    {
      name = "p_ambulancejob/stretcher/pickup",
      label = locale("pickup_stretcher"),
      icon = "fa-solid fa-hand",
      distance = 2.0,
      groups = Editable.allJobs,
      onSelect = function(data)
        local stretcherEntity = type(data) == "number" and data or data.entity
        Stretcher:attach(stretcherEntity)
      end,
      canInteract = function(entity)
        return Stretcher.object and Stretcher.object == entity
      end
    },
    {
      name = "p_ambulancejob/stretcher/remove",
      label = locale("remove_stretcher"),
      icon = "fa-solid fa-trash",
      distance = 2.0,
      groups = Editable.allJobs,
      onSelect = function(data)
        local stretcherEntity = type(data) == "number" and data or data.entity
        Stretcher:delete(stretcherEntity)
      end
    },
    {
      name = "p_ambulancejob/stretcher/putInVehicle",
      label = locale("put_stretcher_in_vehicle"),
      icon = "fa-solid fa-car",
      distance = 2.0,
      groups = Editable.allJobs,
      onSelect = function()
        Stretcher:vehicle(true)
      end,
      canInteract = function(entity)
        return Stretcher.object and Stretcher.object == entity
      end
    },
    {
      name = "p_ambulancejob/stretcher/takePlayerOut",
      label = locale("take_player_out_stretcher"),
      icon = "fa-solid fa-person-walking",
      distance = 2.0,
      groups = Editable.allJobs,
      onSelect = function()
        Stretcher:detachPlayer()
      end,
      canInteract = function(entity)
        return Stretcher.object and Stretcher.object == entity
      end
    },
    {
      name = "p_ambulancejob/stretcher/placeBodyBag",
      label = locale("place_bodybag_on_stretcher"),
      icon = "fa-solid fa-skull",
      distance = 2.0,
      groups = Editable.allJobs,
      onSelect = function()
        BodyBag:attachToStretcher()
      end,
      canInteract = function(entity)
        return BodyBag.isCarrying and Stretcher.object and not Stretcher.attachedBag and Stretcher.object == entity
      end
    },
    {
      name = "p_ambulancejob/stretcher/removeBodyBag",
      label = locale("remove_bodybag_from_stretcher"),
      icon = "fa-solid fa-skull",
      distance = 2.0,
      groups = Editable.allJobs,
      onSelect = function()
        if not Stretcher.attachedBag or not DoesEntityExist(Stretcher.attachedBag) then
          return
        end
        BodyBag:detachFromStretcher()
      end,
      canInteract = function(entity)
        return Stretcher.object and Stretcher.attachedBag and DoesEntityExist(Stretcher.attachedBag) and Stretcher.object == entity
      end
    }
  }
  
  Bridge.Target.addModel(stretcherModels, stretcherOptions)
end)

-- Create a new stretcher
function Stretcher:create()
  -- Check job permissions
  local playerJob = Bridge.Framework.fetchPlayerJob()
  
  if not playerJob or not Editable.allJobs[playerJob.name] then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  -- Load stretcher model
  local stretcherModel = lib.requestModel(Config.Stretcher.prop.model)
  local playerPos = GetEntityCoords(cache.ped)
  
  -- Remove stretcher item from inventory
  TriggerServerEvent("p_bridge/server/removeItem", "stretcher", 1)
  
  -- Create stretcher object
  self.object = CreateObject(stretcherModel, playerPos, true, false, false)
  local networkId = NetworkGetNetworkIdFromEntity(self.object)
  
  -- Setup network entity
  SetEntityAsMissionEntity(self.object, true, true)
  SetNetworkIdExistsOnAllMachines(networkId, true)
  SetNetworkIdCanMigrate(networkId, true)
  SetEntityCollision(self.object, true, true)
  NetworkRequestControlOfEntity(self.object)
  
  -- Attach to player
  self:attach()
end

RegisterNetEvent("p_ambulancejob/client/stretcher/create", function()
  Stretcher:create()
end)

-- Delete stretcher
function Stretcher:delete(stretcherEntity)
  if stretcherEntity and DoesEntityExist(stretcherEntity) then
    TriggerServerEvent("p_ambulancejob/server/stretcher/remove", {
      netId = Utils:getNetId(stretcherEntity)
    })
  end
end

-- Clear stretcher state
RegisterNetEvent("p_ambulancejob/client/stretcher/clear", function()
  Stretcher.object = nil
  Stretcher.attachedPlayer = nil
  LocalPlayer.state:set("usingStretcher", false, true)
end)

-- Attach stretcher to player
function Stretcher:attach(stretcherEntity)
  if self.isAttached then
    return
  end
  
  local stretcher = stretcherEntity or self.object
  
  -- Request control of stretcher
  NetworkRequestControlOfEntity(stretcher)
  
  while not NetworkHasControlOfEntity(stretcher) do
    Citizen.Wait(1)
    NetworkRequestControlOfEntity(stretcher)
  end
  
  LocalPlayer.state:set("usingStretcher", true, true)
  
  -- Attach to player bone
  local boneIndex = GetPedBoneIndex(cache.ped, Config.Stretcher.prop.bone)
  
  AttachEntityToEntity(
    stretcher,
    cache.ped,
    boneIndex,
    Config.Stretcher.prop.coords,
    Config.Stretcher.prop.rot,
    true, true, false, true, 1, true
  )
  
  self.isAttached = true
  
  -- Start carry animation thread
  Citizen.CreateThread(function()
    local animDict = Config.Stretcher.anims.carry.dict
    local animClip = Config.Stretcher.anims.carry.clip
    
    lib.requestAnimDict(animDict)
    TaskPlayAnim(cache.ped, animDict, animClip, 8.0, 8.0, -1, 50, 0, false, false, false)
    
    -- Show text UI if not using target
    if not Config.Stretcher.useDetachTarget then
      lib.showTextUI(locale("put_down_stretcher_textui"), {position = "left-center"})
    end
    
    -- Main carry loop
    while self.isAttached do
      local waitTime = Config.Stretcher.useDetachTarget and 500 or 1
      Citizen.Wait(waitTime)
      
      -- Replay animation if stopped
      if not IsEntityPlayingAnim(cache.ped, animDict, animClip, 3) then
        TaskPlayAnim(cache.ped, animDict, animClip, 8.0, 8.0, -1, 50, 0, false, false, false)
      end
      
      -- Check for detach key press (X by default)
      if not Config.Stretcher.useDetachTarget then
        if IsControlJustPressed(0, 73) then
          self:detach()
          break
        end
      end
    end
    
    lib.hideTextUI()
    ClearPedTasks(cache.ped)
    RemoveAnimDict(animDict)
  end)
end

-- Detach stretcher from player
function Stretcher:detach()
  Citizen.CreateThread(function()
    if not self.isAttached then
      return
    end
    
    -- Detach body bag if attached
    if self.attachedBag then
      FreezeEntityPosition(self.attachedBag, true)
      DetachEntity(self.attachedBag, true, true)
      
      local bagOffset = GetOffsetFromEntityInWorldCoords(self.object, 0.0, 0.0, 2.0)
      SetEntityCoordsNoOffset(self.attachedBag, bagOffset, true, true, true)
      Citizen.Wait(10)
    end
    
    LocalPlayer.state:set("usingStretcher", false, true)
    SetEntityNoCollisionEntity(self.object, self.attachedBag, true)
    
    -- Detach and place stretcher
    DetachEntity(self.object, true, true)
    PlaceObjectOnGroundProperly(self.object)
    FreezeEntityPosition(self.object, true)
    self.isAttached = false
    
    Citizen.Wait(50)
    ClearPedTasks(cache.ped)
    PlaceObjectOnGroundProperly(self.object)
    
    -- Re-attach body bag if it was attached
    if self.attachedBag then
      Citizen.Wait(50)
      
      local heightOffset = self.isFolded and 0.7 or 1.1
      AttachEntityToEntity(
        self.attachedBag,
        self.object,
        0,
        0.225, 0.0, heightOffset,
        0.0, 0.0, 270.0,
        false, false, false, false, 2, true
      )
      
      FreezeEntityPosition(self.attachedBag, false)
    end
  end)
end

-- Put stretcher in/take from vehicle
function Stretcher:vehicle(putInVehicle)
  local closestVehicle, distance = lib.getClosestVehicle(GetEntityCoords(cache.ped), 7.0, true)
  
  if not closestVehicle or closestVehicle == 0 then
    return
  end
  
  -- Check if vehicle model is allowed
  local vehicleModel = joaat(GetEntityModel(closestVehicle))
  local vehicleConfig = Config.Stretcher.vehicleModels[vehicleModel]
  
  if not vehicleConfig then
    Bridge.Notify.showNotify(locale("you_cant_put_stretcher_in_this_vehicle"), "error")
    return
  end
  
  -- Get network IDs
  local vehicleNetId = Utils:getNetId(closestVehicle)
  if not vehicleNetId or vehicleNetId == 0 then
    return
  end
  
  local stretcherNetId = Utils:getNetId(self.object)
  if not stretcherNetId or stretcherNetId == 0 then
    return
  end
  
  -- Detach if currently attached
  if putInVehicle and self.isAttached then
    self:detach()
    Citizen.Wait(250)
  end
  
  LocalPlayer.state:set("usingStretcher", false, true)
  
  TriggerServerEvent("p_ambulancejob/server/stretcher/vehicle", {
    netId = stretcherNetId,
    vehicleId = vehicleNetId,
    state = putInVehicle
  })
end

-- Handle vehicle storage network event
RegisterNetEvent("p_ambulancejob/client/stretcher/vehicle", function(data)
  local stretcher = Utils:getEntityFromNetId(data.netId)
  if not stretcher or stretcher == 0 or not DoesEntityExist(stretcher) then
    return
  end
  
  local vehicle = Utils:getEntityFromNetId(data.vehicleId)
  if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
    return
  end
  
  local vehicleModel = joaat(GetEntityModel(vehicle))
  local vehicleConfig = Config.Stretcher.vehicleModels[vehicleModel]
  
  if not vehicleConfig then
    return
  end
  
  if data.state then
    -- Put in vehicle
    AttachEntityToEntity(
      stretcher,
      vehicle,
      0,
      vehicleConfig.coords,
      vehicleConfig.rot,
      true, true, false, false, 1, true
    )
  else
    -- Take from vehicle
    DetachEntity(stretcher, true, true)
    Citizen.Wait(250)
    
    if Stretcher.object and Stretcher.object == stretcher then
      Stretcher:attach()
    end
  end
end)

-- Toggle fold state
function Stretcher:toggleFold()
  self.isFolded = not self.isFolded
  
  local stretcherEntity = Entity(self.object)
  stretcherEntity.state:set("isFolded", self.isFolded, true)
end

-- Attach player to stretcher
function Stretcher:attachPlayer(targetServerId)
  if self.attachedPlayer then
    return
  end
  
  local stretcherNetId = Utils:getNetId(self.object)
  if not stretcherNetId or stretcherNetId == 0 then
    return
  end
  
  TriggerServerEvent("p_ambulancejob/server/stretcher/attachPlayer", targetServerId, stretcherNetId)
  self.attachedPlayer = targetServerId
end

-- Detach player from stretcher
function Stretcher:detachPlayer()
  if not self.attachedPlayer then
    return
  end
  
  local stretcherNetId = Utils:getNetId(self.object)
  if not stretcherNetId or stretcherNetId == 0 then
    return
  end
  
  TriggerServerEvent("p_ambulancejob/server/stretcher/detachPlayer", self.attachedPlayer, stretcherNetId)
  self.attachedPlayer = nil
end

-- Handle player being attached to stretcher
RegisterNetEvent("p_ambulancejob/client/stretcher/attachPlayer", function(stretcherNetId)
  local stretcher = Utils:getEntityFromNetId(stretcherNetId)
  if not stretcher or stretcher == 0 or not DoesEntityExist(stretcher) then
    return
  end
  
  -- Attach player to stretcher
  AttachEntityToEntity(
    cache.ped,
    stretcher,
    0, 0,
    0.0, 2.1,
    195.0, 0.0, 90.0, 0.0,
    false, false, false, false, 2
  )
  
  Stretcher.attachedTo = stretcher
  
  -- Load lay animation
  local layAnim = Config.Stretcher.anims.lay
  local animDict = lib.requestAnimDict(layAnim.dict)
  
  -- Animation loop while on stretcher
  Citizen.CreateThread(function()
    while Stretcher.attachedTo do
      -- Check if stretcher still exists
      if not Stretcher.attachedTo or not DoesEntityExist(Stretcher.attachedTo) then
        Stretcher.attachedTo = false
        DetachEntity(cache.ped, true, true)
        ClearPedTasks(cache.ped)
        return
      end
      
      -- Play lay animation if alive
      if Death.deathType == "none" and Stretcher.attachedTo then
        if not IsEntityPlayingAnim(cache.ped, layAnim.dict, layAnim.clip, 3) then
          TaskPlayAnim(cache.ped, layAnim.dict, layAnim.clip, -8.0, 8.0, -1, 1, 1)
        end
      end
      
      Citizen.Wait(500)
    end
    
    RemoveAnimDict(animDict)
  end)
end)

-- Handle player being detached from stretcher
RegisterNetEvent("p_ambulancejob/client/stretcher/detachPlayer", function(stretcherNetId)
  local stretcher = NetworkGetEntityFromNetworkId(stretcherNetId)
  if not stretcher or stretcher == 0 or not DoesEntityExist(stretcher) then
    return
  end
  
  if not Stretcher.attachedTo or Stretcher.attachedTo ~= stretcher then
    return
  end
  
  -- Detach and position player
  local detachOffset = GetOffsetFromEntityInWorldCoords(stretcher, 1.0, 0.0, 0.0)
  DetachEntity(cache.ped, true, true)
  ClearPedTasks(cache.ped)
  Stretcher.attachedTo = nil
  
  Citizen.Wait(100)
  SetEntityCoordsNoOffset(cache.ped, detachOffset.x, detachOffset.y, detachOffset.z, true, true, true)
end)

-- Handle fold state changes
AddStateBagChangeHandler("isFolded", nil, function(bagName, key, value, reserved, replicated)
  if replicated then
    return
  end
  
  local entity = GetEntityFromStateBagName(bagName)
  if not entity or entity == 0 or not DoesEntityExist(entity) then
    return
  end
  
  local networkId = NetworkGetNetworkIdFromEntity(entity)
  if not networkId or networkId == 0 then
    return
  end
  
  local entityPos = GetEntityCoords(entity)
  
  -- Determine models for swap
  local oldModel = GetHashKey(value and Config.Stretcher.prop.model or Config.Stretcher.prop.foldModel)
  local newModel = GetHashKey(value and Config.Stretcher.prop.foldModel or Config.Stretcher.prop.model)
  
  -- Remove old model swap if exists
  if Stretcher.folded[networkId] then
    RemoveModelSwap(
      entityPos.x, entityPos.y, entityPos.z,
      1.25,
      Stretcher.folded[networkId].modelOne,
      Stretcher.folded[networkId].modelTwo,
      true
    )
    Citizen.Wait(100)
  end
  
  -- Create new model swap
  CreateModelSwap(
    entityPos.x, entityPos.y, entityPos.z,
    1.25,
    oldModel,
    newModel,
    true
  )
  
  Stretcher.folded[networkId] = {
    value = value,
    modelOne = oldModel,
    modelTwo = newModel
  }
  
  -- Re-attach body bag if present
  if Stretcher.object and Stretcher.object == entity and Stretcher.attachedBag then
    local heightOffset = value and 0.7 or 1.1
    AttachEntityToEntity(
      Stretcher.attachedBag,
      Stretcher.object,
      0,
      0.225, 0.0, heightOffset,
      0.0, 0.0, 270.0,
      false, false, false, false, 2, true
    )
  end
  
  -- Re-attach player if present
  if Stretcher.attachedTo and Stretcher.attachedTo == entity then
    local heightOffset = value and 1.7 or 2.1
    AttachEntityToEntity(
      cache.ped,
      entity,
      0, 0,
      0.0, heightOffset,
      195.0, 0.0, 90.0, 0.0,
      false, false, false, false, 2
    )
  end
end)