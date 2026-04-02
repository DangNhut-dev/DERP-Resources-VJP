-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================


-- Wait for Config.Defibrilator to be available
while not (Config and Config.Defibrilator) do
  Citizen.Wait(100)
end

-- Exit early if defibrilator system is disabled
if not Config.Defibrilator.enabled then
  return
end

-- Test function (legacy)
function test()
  local schools = GlobalState["p_dmvschool/Schools"]
  if schools and schools[k] then
    return schools[k].theoryQuestions
  end
end

-- Initialize Defibrilator module
Defibrilator = {}
Defibrilator.points = {}

-- Setup target interactions for defibrilator
Citizen.CreateThread(function()
  Citizen.Wait(3000)
  
  local propModel = Config.Defibrilator.propModel or "lifepak15"
  
  Bridge.Target.addModel(propModel, {
    -- Attach defibrilator to patient
    {
      name = "p_ambulancejob/defibrilator/attach",
      label = locale("attach_defibrilator"),
      icon = "fa-solid fa-magnifying-glass",
      distance = 2.0,
      groups = Editable.allJobs,
      onSelect = function()
        local playerOptions = {}
        local nearbyPlayers = lib.getNearbyPlayers(GetEntityCoords(cache.ped), 7.0, false)
        
        for i = 1, #nearbyPlayers do
          local serverId = GetPlayerServerId(nearbyPlayers[i].id)
          
          playerOptions[#playerOptions + 1] = {
            title = locale("player", serverId),
            icon = "fa-solid fa-user",
            onSelect = function()
              Defibrilator:attach(serverId)
            end
          }
        end
        
        lib.registerContext({
          id = "defibrilator_attach",
          title = locale("select_player"),
          options = playerOptions
        })
        
        lib.showContext("defibrilator_attach")
      end,
      canInteract = function()
        return Defibrilator.object ~= nil
      end
    },
    -- Use defibrilator on attached patient
    {
      name = "p_ambulancejob/defibrilator/use",
      label = locale("use_defibrilator"),
      icon = "fa-solid fa-heart-pulse",
      distance = 2.0,
      groups = Editable.allJobs,
      onSelect = function()
        Defibrilator:useOnPatient()
      end,
      canInteract = function()
        return Defibrilator.attachedPlayer ~= nil
      end
    },
    -- Remove defibrilator
    {
      name = "p_ambulancejob/defibrilator/remove",
      label = locale("remove_defibrilator"),
      icon = "fa-solid fa-trash",
      distance = 2.0,
      groups = Editable.allJobs,
      onSelect = function()
        Defibrilator:remove()
      end,
      canInteract = function()
        return Defibrilator.object ~= nil
      end
    }
  })
end)

-- Use defibrilator (place mode)
function Defibrilator:use()
  if self.isUsing then
    return
  end
  
  -- Check if player is in vehicle
  if cache.vehicle and cache.vehicle ~= 0 then
    return
  end
  
  -- Check job permission
  local playerJob = Bridge.Framework.fetchPlayerJob()
  
  if not (playerJob and Editable.allJobs[playerJob.name]) then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  self.isUsing = true
  
  -- Spawn defibrilator prop for placement
  local propModel = Config.Defibrilator.propModel or "lifepak15"
  local model = lib.requestModel(propModel)
  local playerCoords = GetEntityCoords(cache.ped)
  local previewObject = CreateObject(model, playerCoords, false, true, true)
  
  FreezeEntityPosition(previewObject, true)
  SetEntityCollision(previewObject, false, false)
  SetEntityAlpha(previewObject, 200)
  PlaceObjectOnGroundProperly(previewObject)
  
  -- Disable controls during placement
  local disabledControls = {24, 69, 92, 106, 257}
  
  Citizen.CreateThread(function()
    while self.isUsing do
      Citizen.Wait(1)
      
      for _, control in pairs(disabledControls) do
        DisableControlAction(0, control, true)
      end
      DisableControlAction(1, 24, true)
    end
  end)
  
  -- Placement loop
  while self.isUsing do
    Citizen.Wait(0)
    
    -- Disable controls
    for _, control in pairs(disabledControls) do
      DisableControlAction(0, control, true)
    end
    DisableControlAction(1, 24, true)
    
    -- Raycast from camera to position object
    local hit, entityHit, coords = lib.raycast.fromCamera(511, 4, 10.0)
    
    if hit and hit ~= 0 then
      SetEntityCoordsNoOffset(previewObject, coords.x, coords.y, coords.z, true, true, true)
      PlaceObjectOnGroundProperly(previewObject)
    end
    
    -- Rotate with arrow keys
    if IsControlPressed(0, 174) then -- Left arrow
      SetEntityHeading(previewObject, GetEntityHeading(previewObject) + 1.0)
    end
    
    if IsControlPressed(0, 175) then -- Right arrow
      SetEntityHeading(previewObject, GetEntityHeading(previewObject) - 1.0)
    end
    
    -- Confirm placement (Left Click)
    if IsDisabledControlPressed(0, 24) then
      local finalCoords = GetEntityCoords(previewObject)
      local finalHeading = GetEntityHeading(previewObject)
      
      self:spawn(finalCoords, finalHeading)
      DeleteEntity(previewObject)
      self.isUsing = false
      break
    end
    
    -- Cancel placement (X key)
    if IsControlPressed(0, 73) then
      DeleteEntity(previewObject)
      SetModelAsNoLongerNeeded(model)
      self.isUsing = false
      break
    end
  end
end

RegisterNetEvent("p_ambulancejob/client/defibrilator/use", function()
  Defibrilator:use()
end)

-- Spawn defibrilator at location
function Defibrilator:spawn(coords, heading)
  TriggerServerEvent("p_bridge/server/removeItem", "defibrilator", 1)
  
  local propModel = Config.Defibrilator.propModel or "lifepak15"
  local model = lib.requestModel(propModel)
  local defibObject = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)
  
  self.object = defibObject
  
  SetEntityHeading(defibObject, heading)
  FreezeEntityPosition(defibObject, true)
  PlaceObjectOnGroundProperly(defibObject)
  SetEntityAsMissionEntity(defibObject, true, true)
  SetModelAsNoLongerNeeded(model)
end

-- Sync DUI screen for player monitoring
RegisterNetEvent("p_ambulancejob/client/defibrilator/syncDUI", function(targetId, patientName)
  Defibrilator:syncDUI(targetId, patientName)
end)

-- Remove DUI screen
RegisterNetEvent("p_ambulancejob/client/defibrilator/removeDUI", function(targetId)
  Defibrilator:removeDUI(targetId)
end)

function Defibrilator:removeDUI(targetId)
  if not self.points[targetId] then
    return
  end
  
  self.points[targetId]:remove()
  self.points[targetId] = nil
end

function Defibrilator:syncDUI(targetId, patientName)
  if self.points[targetId] then
    return
  end
  
  -- Create proximity point for DUI rendering
  local point = lib.points.new({
    coords = GetEntityCoords(cache.ped),
    distance = 5
  })
  
  point.onEnter = function(self)
    -- Create DUI texture for ECG monitor
    self.dui = lib.dui:new({
      url = string.format("nui://%s/web/ecg.html", cache.resource),
      width = 1920,
      height = 1080,
      debug = Bridge.Config.Debug or false
    })
    
    Citizen.Wait(100)
    
    -- Replace texture on defibrilator model
    AddReplaceTexture("lifepak15", "55_002_lifepak15monitorde_220a_2", self.dui.dictName, self.dui.txtName)
    
    -- Update ECG data thread
    Citizen.CreateThread(function()
      while self.dui do
        local playerState = Player(targetId).state
        
        if self.dui then
          self.dui:sendMessage({
            action = "updateECG",
            value = {
              heartRate = playerState.pulse or 0,
              temperature = playerState.temperature or 0,
              patientName = patientName
            }
          })
        end
        
        Citizen.Wait(2000)
      end
    end)
  end
  
  point.onExit = function(self)
    self.dui:remove()
    self.dui = nil
    RemoveReplaceTexture("lifepak15", "55_002_lifepak15monitorde_220a_2")
  end
  
  self.points[targetId] = point
end

-- Attach defibrilator to patient
function Defibrilator:attach(targetId)
  if not self.object then
    return
  end
  
  local playerState = Player(targetId).state
  
  if not playerState.criticalPulse then
    Bridge.Notify.showNotify(locale("player_no_critical_pulse"), "error")
    return
  end
  
  self.attachedPlayer = targetId
  TriggerServerEvent("p_ambulancejob/server/defibrilator/sync", targetId)
end

-- Remove defibrilator
function Defibrilator:remove()
  if not self.object then
    return
  end
  
  local objectNetId = NetworkGetNetworkIdFromEntity(self.object)
  TriggerServerEvent("p_ambulancejob/server/defibrilator/remove", objectNetId, self.attachedPlayer)
  
  self.object = nil
  self.attachedPlayer = nil
end

-- Use defibrilator on attached patient
function Defibrilator:useOnPatient()
  if not self.cam and not self.attachedPlayer then
    return
  end
  
  local playerPed = cache.ped
  
  -- Play medical animation
  local animDict = lib.requestAnimDict("amb@medic@standing@tendtodead@base")
  TaskPlayAnim(playerPed, animDict, "base", 8.0, -8.0, -1, 1, 0, false, false, false)
  
  -- Create camera focused on patient
  self.cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
  
  local patientPed = GetPlayerPed(GetPlayerFromServerId(self.attachedPlayer))
  local camCoords = GetOffsetFromEntityInWorldCoords(patientPed, -1.25, 1.0, 0.25)
  
  SetCamCoord(self.cam, camCoords.x, camCoords.y, camCoords.z)
  SetCamFov(self.cam, 40.0)
  PointCamAtEntity(self.cam, patientPed, 0.0, 0.0, -0.5, true)
  SetCamActive(self.cam, true)
  RenderScriptCams(true, true, 1000, true, true)
  
  Citizen.Wait(2000)
  
  -- Execute defibrilator use
  local result = Config.Defibrilator.onUse()
  
  TriggerServerEvent("p_ambulancejob/server/defibrilator/useOnPatient", {
    targetId = self.attachedPlayer,
    result = result
  })
  
  -- Clean up
  StopAnimTask(playerPed, "amb@medic@standing@tendtodead@base", "base", 3.0)
  Citizen.Wait(1000)
  
  RenderScriptCams(false, true, 1000, true, true)
  SetCamActive(self.cam, false)
  DestroyCam(self.cam, false)
  
  self.cam = nil
  self.attachedPlayer = nil
end

-- Play CPR animation for reviving
function Defibrilator:playReviving()
  local animDict = lib.requestAnimDict("mini@cpr@char_b@cpr_str")
  TaskPlayAnim(cache.ped, animDict, "cpr_pumpchest", 8.0, -8.0, -1, 1, 0, false, false, false)
  RemoveAnimDict(animDict)
end

RegisterNetEvent("p_ambulancejob/client/defibrilator/playReviving", function()
  Defibrilator:playReviving()
end)