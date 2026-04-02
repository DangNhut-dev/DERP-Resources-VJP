-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================


-- Wait for Config.BodyBag to be available
while not (Config and Config.BodyBag) do
  Wait(1)
end

-- Exit early if body bag system is disabled
if not Config.BodyBag.enabled then
  return
end

-- Test function (legacy)
function test()
  local schools = GlobalState["p_dmvschool/Schools"]
  if schools and schools[k] then
    return schools[k].theoryQuestions
  end
end

-- Initialize BodyBag module
BodyBag = {}
BodyBag._index = BodyBag
BodyBag.isEnabled = false
BodyBag.isCarrying = false

-- Setup ox_target integration if available
Citizen.CreateThread(function()
  local targetState = GetResourceState("ox_target")
  
  if targetState == "started" then
    Bridge.Target.addGlobal({
      {
        name = "p_ambulancejob/bodybag/detach",
        label = locale("put_down_bodybag"),
        icon = "fa-solid fa-hand",
        distance = 2.0,
        onSelect = function()
          BodyBag:toggleCarry(BodyBag.carriedEntity)
        end,
        canInteract = function()
          return BodyBag.isCarrying
        end
      }
    })
  end
end)

-- Apply body bag to player (make them invisible inside bag)
function BodyBag:apply()
  if self.isEnabled then
    return
  end
  
  self.isEnabled = true
  
  -- Get player position and spawn body bag prop
  local playerPed = cache.ped
  local coords = GetEntityCoords(playerPed)
  local model = lib.requestModel(Config.BodyBag.prop.model)
  
  local bagObject = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)
  self.currentObject = bagObject
  
  PlaceObjectOnGroundProperly(bagObject)
  ActivatePhysics(bagObject)
  
  -- Attach bag to player and hide them
  AttachEntityToEntity(playerPed, bagObject, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
  SetEntityVisible(playerPed, false, false)
  SetModelAsNoLongerNeeded(model)
  
  -- Monitor thread to keep player attached
  Citizen.CreateThread(function()
    while self.isEnabled do
      Citizen.Wait(1000)
      
      -- Remove if bag deleted
      if not DoesEntityExist(bagObject) then
        self:remove()
        break
      end
      
      -- Re-attach if detached
      if not IsEntityAttachedToEntity(playerPed, bagObject) then
        AttachEntityToEntity(playerPed, bagObject, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
      end
    end
  end)
end

RegisterNetEvent("p_ambulancejob/bodybag/client/apply", function()
  BodyBag:apply()
end)

-- Remove body bag from player (make them visible again)
function BodyBag:remove()
  if not self.isEnabled then
    return
  end
  
  self.isEnabled = false
  
  local playerPed = cache.ped
  DetachEntity(playerPed, true, true)
  SetEntityVisible(playerPed, true, false)
  SetEntityCollision(playerPed, true, true)
  
  if DoesEntityExist(self.currentObject) then
    DeleteEntity(self.currentObject)
  end
  
  self.currentObject = nil
end

RegisterNetEvent("p_ambulancejob/bodybag/client/remove", function()
  BodyBag:remove()
end)

-- Toggle carrying a body bag
function BodyBag:toggleCarry(entity)
  self.isCarrying = not self.isCarrying
  Wait(10)
  
  if self.isCarrying then
    local playerPed = cache.ped
    local animDict = lib.requestAnimDict("anim@heists@box_carry@")
    
    Utils:requestControl(entity)
    
    -- Play carrying animation
    TaskPlayAnim(playerPed, animDict, "idle", 8.0, -8.0, -1, 49, 1.0, false, false, false)
    
    -- Attach bag to player's hand
    local boneIndex = GetPedBoneIndex(playerPed, 28422)
    local propCoords = Config.BodyBag.prop.coords
    local propRot = Config.BodyBag.prop.rot
    AttachEntityToEntity(entity, playerPed, boneIndex, propCoords, propRot, true, true, false, true, 1, true)
    
    self.carriedEntity = entity
    
    -- Monitor carrying state
    Citizen.CreateThread(function()
      local targetState = GetResourceState("ox_target")
      local waitTime = (targetState == "started") and 500 or 1
      
      -- Show text UI for non-ox_target users
      if waitTime == 1 then
        lib.showTextUI(locale("drop_bodybag"), {
          icon = "fa-solid fa-skull",
          position = "left-center"
        })
      end
      
      while self.isCarrying do
        Wait(waitTime)
        
        -- Ensure animation plays
        if not IsPedRagdoll(playerPed) and not IsEntityPlayingAnim(playerPed, animDict, "idle", 3) then
          TaskPlayAnim(playerPed, animDict, "idle", 8.0, -8.0, -1, 49, 1.0, false, false, false)
        end
        
        -- Check for drop input (X key)
        if waitTime == 1 and IsControlJustPressed(0, 73) then
          DetachEntity(entity)
          PlaceObjectOnGroundProperly(entity)
          ClearPedTasks(playerPed)
          break
        end
      end
      
      if waitTime == 1 then
        lib.hideTextUI()
      end
      
      RemoveAnimDict(animDict)
    end)
  else
    -- Drop the bag
    DetachEntity(entity)
    PlaceObjectOnGroundProperly(entity)
    ClearPedTasks(cache.ped)
    self.carriedEntity = nil
  end
end

-- Attach body bag to stretcher
function BodyBag:attachToStretcher()
  -- Validate stretcher exists
  if not (Stretcher.object and DoesEntityExist(Stretcher.object)) then
    return
  end
  
  -- Validate carried entity exists
  if not (self.carriedEntity and DoesEntityExist(self.carriedEntity)) then
    return
  end
  
  -- Check if stretcher is available
  if Stretcher.attachedPlayer then
    return
  end
  
  local stretcherNetId = Utils:getNetId(Stretcher.object)
  local bagEntity = self.carriedEntity
  
  -- Stop carrying
  self:toggleCarry(bagEntity)
  Citizen.Wait(100)
  
  -- Attach to stretcher with appropriate height offset
  local zOffset = (Stretcher.folded[stretcherNetId] and Stretcher.folded[stretcherNetId].value) and 0.7 or 1.1
  AttachEntityToEntity(bagEntity, Stretcher.object, 0, 0.225, 0.0, zOffset, 0.0, 0.0, 270.0, false, false, false, false, 2, true)
  
  Stretcher.attachedBag = bagEntity
end

-- Detach body bag from stretcher
function BodyBag:detachFromStretcher()
  -- Validate stretcher exists
  if not (Stretcher.object and DoesEntityExist(Stretcher.object)) then
    return
  end
  
  -- Validate attached bag exists
  if not (Stretcher.attachedBag and DoesEntityExist(Stretcher.attachedBag)) then
    return
  end
  
  local bagEntity = Stretcher.attachedBag
  DetachEntity(bagEntity)
  Stretcher.attachedBag = nil
  
  Citizen.Wait(100)
  self:toggleCarry(bagEntity)
end

-- Setup all target interactions
Citizen.CreateThread(function()
  Citizen.Wait(2500)
  
  -- Target interaction: Apply body bag to player
  Bridge.Target.addPlayer({
    {
      name = "p_ambulancejob/bodybag/apply",
      label = locale("apply_bodybag"),
      icon = "fa-solid fa-skull",
      distance = 2,
      groups = Editable.allJobs,
      onSelect = function(data)
        local targetEntity = (type(data) == "number") and data or data.entity
        local targetServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetEntity))
        TriggerServerEvent("p_ambulancejob/bodybag/server/apply", targetServerId)
      end,
      canInteract = function(targetPed)
        local targetServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
        local hasItem = Bridge.Inventory.getItemCount("bodybag") > 0
        local playerState = Player(targetServerId).state
        return hasItem and playerState
      end
    }
  })
  
  -- Target interactions for body bag prop
  Bridge.Target.addModel(Config.BodyBag.prop.model, {
    -- Carry body bag
    {
      name = "p_ambulancejob/bodybag/carry",
      label = locale("carry_bodybag"),
      icon = "fa-solid fa-skull",
      distance = 2,
      groups = Editable.allJobs,
      onSelect = function(data)
        local targetEntity = (type(data) == "number") and data or data.entity
        BodyBag:toggleCarry(targetEntity)
      end
    },
    -- Respawn player from body bag
    {
      name = "p_ambulancejob/bodybag/respawn",
      label = locale("respawn_player"),
      icon = "fa-solid fa-skull",
      distance = 2,
      groups = Editable.allJobs,
      onSelect = function()
        local closestPlayer, distance = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3.0, false)
        
        if not distance or distance == 0 then
          return false
        end
        
        local targetServerId = GetPlayerServerId(closestPlayer)
        local playerState = Player(targetServerId).state
        
        if not playerState.isInBodyBag then
          return
        end
        
        CheckIn:bodyBagRespawn(targetServerId)
      end,
      canInteract = function()
        return Config.BodyBag.respawnPlayer
      end
    },
    -- Remove body bag from player
    {
      name = "p_ambulancejob/bodybag/remove",
      label = locale("remove_bodybag"),
      icon = "fa-solid fa-skull",
      distance = 2,
      groups = Editable.allJobs,
      onSelect = function(data)
        local closestPlayer, distance = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3.0, false)
        
        if not distance or distance == 0 then
          return false
        end
        
        local targetServerId = GetPlayerServerId(closestPlayer)
        local playerState = Player(targetServerId).state
        
        if not playerState.isInBodyBag then
          return
        end
        
        local targetEntity = (type(data) == "number") and data or data.entity
        local entityNetId = NetworkGetNetworkIdFromEntity(targetEntity)
        TriggerServerEvent("p_ambulancejob/bodybag/server/remove", targetServerId, entityNetId)
      end,
      canInteract = function()
        local closestPlayer, distance = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3.0, false)
        
        if not distance or distance == 0 then
          return false
        end
        
        local targetServerId = GetPlayerServerId(closestPlayer)
        local playerState = Player(targetServerId).state
        return playerState.isInBodyBag
      end
    }
  })
end)