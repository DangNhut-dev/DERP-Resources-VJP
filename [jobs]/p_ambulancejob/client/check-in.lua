-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================


-- Wait for Config to be loaded
while not (Config and Config.CheckIn) do
  Wait(100)
end

-- Exit early if check-in system is disabled
if not Config.CheckIn.enabled then
  return
end

-- Initialize CheckIn module
CheckIn = {
  AiMedicActive = false
}

-- Test function (appears to be debugging remnant)
function test()
  local schools = GlobalState["p_dmvschool/Schools"]
  if schools and schools[k] then
    return schools[k].theoryQuestions
  end
end

-- Plays death/unconscious animation during check-in
function CheckIn.animation(state)
  Citizen.CreateThread(function()
    -- Only animate if player is not already dead
    if Death.deathType ~= "none" then
      return
    end

    -- Load animation dictionary
    local animDict = lib.requestAnimDict("dead")
    
    -- Animation loop while check-in is active
    while state.isActive do
      -- Disable all controls except camera movement
      DisableAllControlActions(0)
      EnableControlAction(0, 0, true)  -- Camera left/right
      EnableControlAction(0, 1, true)  -- Camera up/down
      EnableControlAction(0, 2, true)  -- Camera zoom

      -- Play death animation if not already playing
      if not IsEntityPlayingAnim(cache.ped, "dead", "dead_e", 3) then
        TaskPlayAnim(cache.ped, animDict, "dead_e", -8.0, 8.0, -1, 1, 1.0)
      end

      Wait(1)
    end

    -- Clean up animation dictionary
    RemoveAnimDict(animDict)
  end)
end

-- Controls camera during check-in process
function CheckIn.camera(state, enable)
  if not Config.CheckIn.camera.enabled then
    return
  end

  if enable then
    -- Create scripted camera
    state.cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    
    local playerCoords = GetEntityCoords(cache.ped)
    local cameraOffset = Config.CheckIn.camera.offset
    
    -- Position camera with offset from player
    local camCoords = GetOffsetFromEntityInWorldCoords(
      cache.ped,
      cameraOffset.x,
      cameraOffset.y,
      cameraOffset.z
    )
    
    SetCamCoord(state.cam, camCoords.x, camCoords.y, camCoords.z)
    PointCamAtCoord(state.cam, playerCoords.x, playerCoords.y, playerCoords.z - 0.75)
    SetCamFov(state.cam, 65.0)
    SetCamActive(state.cam, true)
    RenderScriptCams(true, false, 0, true, true)
  else
    -- Destroy camera and return to normal view
    if state.cam then
      SetCamActive(state.cam, false)
      RenderScriptCams(false, false, 0, true, true)
      DestroyCam(state.cam, true)
      state.cam = nil
    end
  end
end

-- Finds an available bed at the specified hospital
function CheckIn.findBed(self, hospitalId)
  local beds = Config.CheckIn.beds[hospitalId]
  
  if not beds then
    return nil
  end

  -- Check each bed for nearby players
  for i = 1, #beds do
    local bedCoords = vec3(beds[i].xyz)
    local nearbyPlayers = lib.getNearbyPlayers(bedCoords, 1.5, false)
    
    -- Return first available bed (no players within 1.5m)
    if #nearbyPlayers < 1 then
      return beds[i]
    end
  end

  return nil
end

-- Main check-in function - handles the entire check-in process
function CheckIn.start(self, hospitalId, paymentType, dropItems)
  -- Find available bed
  local bed = self:findBed(hospitalId)
  if not bed then
    Bridge.Notify.showNotify(locale("no_available_beds"), "error")
    return
  end

  -- Server-side validation
  local canUse = lib.callback.await("p_ambulancejob/server/checkIn/canUse", false, hospitalId, paymentType)
  if not canUse then
    return
  end

  local hospitalConfig = Config.CheckIn.points[hospitalId]
  local action = (paymentType == "none") and "respawn" or "check-in"
  
  -- Trigger onStart callback
  Config.CheckIn.onStart(hospitalId, action)

  -- Drop items if configured
  if dropItems then
    TriggerServerEvent("p_ambulancejob/server/death/dropItems")
  end

  self.isActive = true

  -- Fade out screen
  Utils:fadeOutScreen(1000)
  Wait(500)

  -- Clear death state if player is dead
  if Death.deathType ~= "none" then
    Death:setDeathState({ state = false, type = "death" })
    Wait(100)
  end

  -- Teleport player to bed
  SetEntityCoords(cache.ped, bed.x, bed.y, bed.z + 0.5)
  SetEntityHeading(cache.ped, bed.w)

  -- Start animation and camera
  self:animation()
  self:camera(true)

  Wait(500)
  Utils:fadeInScreen(1000)

  -- Restore player health
  SetEntityHealth(cache.ped, GetEntityMaxHealth(cache.ped))
  Config.Death.commands.revive.clientFunction()
  TriggerServerEvent("p_ambulancejob/server/death/reviveUtils")

  -- Show progress bar
  local duration = hospitalConfig.duration or 5000
  local success = lib.progressBar({
      duration     = duration,
      label        = locale("checking_in"),
      position     = 'center',
      useWhileDead = true,
      canCancel    = false,
  })

  if success then
    self.isActive = false

    -- Fade out and clean up
    Utils:fadeOutScreen(1000)
    self:camera(false)
    Wait(500)

    TriggerEvent("p_ambulancejob/client/death/revive")
    Bridge.Notify.showNotify(locale("checked_in"), "success")
    ClearPedTasks(cache.ped)

    -- Trigger onFinish callback if configured
    if Config.CheckIn.onFinish then
      Config.CheckIn.onFinish(hospitalId)
    end

    Wait(1000)
    Utils:fadeInScreen(1000)
  else
    self.isActive = false
    self:camera(false)
  end
end

-- Creates check-in points for a hospital
function CheckIn.create(self, hospitalId, pointConfig)
  -- Check if this hospital is enabled
  local isSelected = Utils:isSelectedHospital(hospitalId)
  if not isSelected then
    return
  end

  -- Create NPC and point if ped model is specified
  if pointConfig.ped then
    local point = lib.points.new({
      coords = vec3(pointConfig.coords.xyz),
      distance = 25.0
    })

    -- Spawn NPC when player enters zone
    function point:onEnter()
      local ped, prop = Utils:createPed({
        model = pointConfig.ped,
        coords = pointConfig.coords,
        anim = pointConfig.anim,
        prop = pointConfig.prop
      })
      self.ped = ped
      self.prop = prop
    end

    -- Handle player proximity
    function point:nearby()
      local distance = self.currentDistance

      -- Track if player is within interaction distance
      if distance < 4.0 then
        if not CheckIn.closeToPoint then
          CheckIn.closeToPoint = hospitalId
        end
      elseif distance >= 4.0 then
        if CheckIn.closeToPoint then
          CheckIn.closeToPoint = nil
        end
      end

      -- Handle text UI display
      if Config.CheckIn.useTextUI then
        if distance < 3.0 then
          if not self.textUI then
            self.textUI = true
            Bridge.TextUI.show(locale("check_in_textui"))
          end
        elseif distance > 3.0 then
          if self.textUI then
            self.textUI = false
            Bridge.TextUI.hide()
          end
        end
      end

      -- Handle interaction key press
      if self.textUI and IsControlJustReleased(0, 74) then
        self:showPaymentMenu(hospitalId, pointConfig.price)
      end
    end

    -- Clean up when player leaves zone
    function point:onExit()
      if self.ped and DoesEntityExist(self.ped) then
        DeleteEntity(self.ped)
        self.ped = nil
      end
      if self.prop and DoesEntityExist(self.prop) then
        DeleteEntity(self.prop)
        self.prop = nil
      end
      if Config.CheckIn.useTextUI then
        Bridge.TextUI.hide()
      end
    end

    -- Helper function to show payment menu
    function point:showPaymentMenu(hospitalId, prices)
      local options = {}
      local icons = {
        money = "fa-solid fa-money-bill",
        bank = "fa-solid fa-credit-card",
        black_money = "fa-solid fa-sack-dollar",
        insurance = "fa-solid fa-file-invoice"
      }

      for paymentType, price in pairs(prices) do
        local description
        if paymentType == "insurance" then
          description = locale("pay_for_check_in_desc_insurance")
        else
          description = locale("pay_for_check_in_desc", price)
        end

        options[#options + 1] = {
          title = locale("pay_for_check_in_" .. paymentType),
          description = description,
          icon = icons[paymentType],
          onSelect = function()
            CheckIn:start(hospitalId, paymentType)
          end
        }
      end

      lib.registerContext({
        id = "check_in_menu",
        title = locale("check_in"),
        options = options
      })
      lib.showContext("check_in_menu")
    end

    pointIds[#pointIds + 1] = point
  end

  -- Create target zone if not using text UI
  if not Config.CheckIn.useTextUI then
    local targetId = Bridge.Target.addSphereZone({
      coords = pointConfig.coords,
      radius = pointConfig.radius or 0.75,
      options = {{
        name = "p_ambulancejob/checkIn_" .. hospitalId,
        label = locale("check_in"),
        icon = "fa-solid fa-bandage",
        distance = 2.0,
        onSelect = function()
          local options = {}
          local icons = {
            money = "fa-solid fa-money-bill",
            bank = "fa-solid fa-credit-card",
            black_money = "fa-solid fa-sack-dollar",
            insurance = "fa-solid fa-file-invoice"
          }

          for paymentType, price in pairs(pointConfig.price) do
            local description
            if paymentType == "insurance" then
              description = locale("pay_for_check_in_desc_insurance")
            else
              description = locale("pay_for_check_in_desc", price)
            end

            options[#options + 1] = {
              title = locale("pay_for_check_in_" .. paymentType),
              description = description,
              icon = icons[paymentType],
              onSelect = function()
                self:start(hospitalId, paymentType)
              end
            }
          end

          lib.registerContext({
            id = "check_in_menu",
            title = locale("check_in"),
            options = options
          })
          lib.showContext("check_in_menu")
        end
      }}
    })
    targetIds[#targetIds + 1] = targetId
  end
end

-- Shows local respawn menu for dead players
function CheckIn.localRespawn(self, dropItems)
  -- Check if AI medic is already active
  if self.AiMedicActive then
    Bridge.Notify.showNotify(locale("medic_ai_active"), "error")
    return
  end

  -- Check for envi-medic integration
  if Config.Death.useEnviMedic then
    if GetResourceState("envi-medic") == "started" then
      exports["envi-medic"]:SendHelp()
      if dropItems then
        TriggerServerEvent("p_ambulancejob/server/death/dropItems")
      end
      return
    end
  end

  -- Build respawn options for each hospital
  local options = {}
  for hospitalId, hospitalData in pairs(Config.CheckIn.points) do
    if Utils:isSelectedHospital(hospitalId) then
      options[#options + 1] = {
        title = locale("respawn_at", hospitalData.label),
        description = locale("respawn_at_desc", hospitalData.label),
        icon = "bed",
        onSelect = function()
          if Death.deathType == "none" then
            return
          end

          -- Check if AI medic is enabled and configured
          local aiMedicEnabled = Config.CheckIn.AiMedic and Config.CheckIn.AiMedic.enabled
          if aiMedicEnabled then
            CheckIn:MedicAI(hospitalId, dropItems)
            return
          end

          self:start(hospitalId, "none", dropItems)
        end
      }
    end
  end

  lib.registerContext({
    id = "local_respawn_menu",
    title = locale("local_respawn_menu"),
    options = options
  })
  lib.showContext("local_respawn_menu")
end

-- Shows respawn menu for players in body bags
function CheckIn.bodyBagRespawn(self, targetServerId)
  local options = {}
  
  for hospitalId, hospitalData in pairs(Config.CheckIn.points) do
    if Utils:isSelectedHospital(hospitalId) then
      options[#options + 1] = {
        title = locale("respawn_at", hospitalData.label),
        description = locale("respawn_at_desc", hospitalData.label),
        icon = "bed",
        onSelect = function()
          TriggerServerEvent("p_ambulancejob/bodybag/server/respawnPlayer", targetServerId, hospitalId)
        end
      }
    end
  end

  lib.registerContext({
    id = "bodybag_respawn_menu",
    title = locale("local_respawn_menu"),
    options = options
  })
  lib.showContext("bodybag_respawn_menu")
end

-- Handles AI medic ambulance system
function CheckIn.MedicAI(self, hospitalId, dropItems)
  self.AiMedicActive = true

  -- Get player position
  local playerCoords = GetEntityCoords(cache.ped)

  -- Find random road node near player (50-70 nodes away)
  local nodeFound, nodeCoords = GetNthClosestVehicleNode(
    playerCoords.x,
    playerCoords.y,
    playerCoords.z,
    math.random(50, 70),
    0, 0, 0
  )

  if not nodeFound then
    return
  end

  local spawnX, spawnY, spawnZ = table.unpack(nodeCoords)
  if not spawnX then
    return
  end

  -- Determine destination (driveCoords or bed location)
  local destination = Config.CheckIn.points[hospitalId].driveCoords
  if not destination then
    destination = self:findBed(hospitalId)
  end

  if not destination then
    return
  end

  -- Spawn ambulance vehicle
  local vehModel = lib.requestModel(Config.CheckIn.AiMedic.vehModel)
  local vehicle = CreateVehicle(vehModel, spawnX, spawnY, spawnZ, 0, false, true)
  SetEntityAsMissionEntity(vehicle, true, true)
  SetVehicleEngineOn(vehicle, true, true, false)
  SetModelAsNoLongerNeeded(vehicle)
  SetVehicleSiren(vehicle, true)

  -- Spawn AI medic driver
  local pedModel = lib.requestModel(Config.CheckIn.AiMedic.model)
  local medic = CreatePedInsideVehicle(vehicle, 26, pedModel, -1, false, true)
  SetAmbientVoiceName(medic, "A_M_M_EASTSA_02_LATINO_FULL_01")
  SetBlockingOfNonTemporaryEvents(medic, true)
  SetEntityAsMissionEntity(medic, true, true)
  SetModelAsNoLongerNeeded(pedModel)

  -- Drive to player
  TaskVehicleDriveToCoord(
    medic, vehicle,
    playerCoords.x, playerCoords.y, playerCoords.z,
    40.0, 0, GetEntityModel(vehicle), 786469, 10.0
  )
  SetPedKeepTask(medic, true)

  -- Wait for ambulance to reach player (max 15 seconds)
  local startTime = GetGameTimer()
  while true do
    local medicCoords = GetEntityCoords(medic)
    local currentPlayerCoords = GetEntityCoords(cache.ped)
    
    local distance = #(vec3(medicCoords.x, medicCoords.y, medicCoords.z) - 
                       vec3(currentPlayerCoords.x, currentPlayerCoords.y, currentPlayerCoords.z))
    
    local elapsed = GetGameTimer() - startTime
    
    if elapsed > 15000 or distance < 10 then
      break
    end
    
    Wait(1000)
  end

  -- Put player in ambulance
  Utils:fadeOutScreen(500)
  ClearPedTasks(medic)
  TaskWarpPedIntoVehicle(cache.ped, vehicle, 2)
  Wait(200)

  -- Drive to hospital
  TaskVehicleDriveToCoord(
    medic, vehicle,
    destination.x, destination.y, destination.z,
    40.0, 0, GetEntityModel(vehicle), 786469, 10.0
  )
  SetPedKeepTask(medic, true)

  Wait(500)
  Utils:fadeInScreen(500)

  -- Wait for arrival at hospital (max 60 seconds)
  startTime = GetGameTimer()
  while true do
    local currentPlayerCoords = GetEntityCoords(cache.ped)
    
    local distance = #(vec3(destination.x, destination.y, destination.z) - 
                       vec3(currentPlayerCoords.x, currentPlayerCoords.y, currentPlayerCoords.z))
    
    local elapsed = GetGameTimer() - startTime
    
    if elapsed > 60000 or distance < 15 then
      break
    end
    
    Wait(500)
  end

  -- Clean up and start check-in
  Utils:fadeOutScreen(500)
  TaskLeaveVehicle(cache.ped, vehicle, 16)
  SetVehicleSiren(vehicle, false)
  DeleteEntity(vehicle)
  DeleteEntity(medic)

  self:start(hospitalId, "none", dropItems)
end

-- Event: Respawn player at hospital (from body bag)
RegisterNetEvent("p_ambulancejob/check-in/client/respawnPlayer", function(hospitalId)
  if Death.deathType == "none" then
    return
  end

  Citizen.CreateThread(function()
    BodyBag:remove()
  end)

  CheckIn:start(hospitalId, "none", false)
end)

-- Initialize check-in points on resource start
Citizen.CreateThread(function()
  -- Wait for config to be loaded
  while not Config.CheckIn.points do
    Wait(100)
  end

  -- Create all check-in points
  for hospitalId, pointConfig in pairs(Config.CheckIn.points) do
    CheckIn:create(hospitalId, pointConfig)
  end

  -- Setup "pay for other player" feature if enabled
  if Config.CheckIn.canPayForOther then
    Bridge.Target.addPlayer({
      {
        name = "p_ambulancejob/checkIn_payForOther",
        label = locale("pay_for_other_check_in"),
        icon = "fa-solid fa-hand-holding-medical",
        distance = 2.0,
        onSelect = function(entity)
          if not CheckIn.closeToPoint then
            return
          end

          -- Get target player's server ID
          local targetPed = (type(entity) == "number") and entity or entity.entity
          local targetServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))

          -- Build payment options (exclude insurance)
          local options = {}
          local icons = {
            money = "fa-solid fa-money-bill",
            bank = "fa-solid fa-credit-card",
            black_money = "fa-solid fa-sack-dollar"
          }

          local hospitalConfig = Config.CheckIn.points[CheckIn.closeToPoint]
          for paymentType, price in pairs(hospitalConfig.price) do
            if paymentType ~= "insurance" then
              options[#options + 1] = {
                title = locale("pay_for_check_in_" .. paymentType),
                description = locale("pay_for_check_in_desc", price),
                icon = icons[paymentType],
                onSelect = function()
                  TriggerServerEvent(
                    "p_ambulancejob/server/checkIn/payForOther",
                    targetServerId,
                    CheckIn.closeToPoint,
                    paymentType
                  )
                end
              }
            end
          end

          lib.registerContext({
            id = "check_in_menu",
            title = locale("check_in"),
            options = options
          })
          lib.showContext("check_in_menu")
        end,
        canInteract = function(entity)
          if not CheckIn.closeToPoint then
            return false
          end
          
          local playerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
          return Player(playerId).state.isDead
        end
      }
    })
  end
end)

-- Event: Start check-in from external trigger
RegisterNetEvent("p_ambulancejob/client/checkIn/startCheckIn", function(hospitalId)
  CheckIn:start(hospitalId, "none", false)
end)