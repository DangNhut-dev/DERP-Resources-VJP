-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================


-- Test function for GlobalState access
function test()
  local schools = GlobalState["p_dmvschool/Schools"]
  if schools and schools[k] then
    return schools[k].theoryQuestions
  end
end

-- Initialize Garage object
Garage = {}
Garage.__index = Garage
Garage.antiSpam = GetGameTimer()
Garage.entities = {}
Garage.currentGarage = nil

-- Initialize all garages from config
function Garage.init(self)
  Citizen.CreateThread(function()
    -- Wait for Config.Garages to be available
    while not Config.Garages do
      Wait(100)
    end
    
    -- Create new garage instance for each configured garage
    for garageId, garageData in pairs(Config.Garages) do
      self:new(garageId, garageData)
    end
  end)
end

-- Open garage UI and load vehicles
function Garage.open(self, garageId)
  -- Check anti-spam timer
  if self.antiSpam > GetGameTimer() then
    Bridge.Notify.showNotify(locale("wait_before_next_action"), "error")
    return
  end
  
  self.currentGarage = garageId
  local vehicles = self:getVehicles(garageId)
  
  -- Show garage UI
  SendNUIMessage({
    action = "setVisibleGarage",
    data = true
  })
  
  SendNUIMessage({
    action = "loadGarage",
    data = vehicles
  })
  
  SetNuiFocus(true, true)
end

-- Close garage UI
function Garage.close(self)
  self.antiSpam = GetGameTimer() + 1000
  
  SendNUIMessage({
    action = "setVisibleGarage",
    data = false
  })
  
  self.currentGarage = nil
  SetNuiFocus(false, false)
end

-- Take out a vehicle from garage
function Garage.takeOut(self, vehicleModel)
  -- Debug logging
  if Bridge and Bridge.Config and Bridge.Config.Debug then
    lib.print.info("[Garage] Anti Spam Check", self.antiSpam, GetGameTimer())
  end
  
  -- Check anti-spam timer
  if self.antiSpam > GetGameTimer() then
    Bridge.Notify.showNotify(locale("wait_before_next_action"), "error")
    return
  end
  
  self.antiSpam = GetGameTimer() + 1000
  
  -- Debug: Check if vehicle already exists
  if Bridge and Bridge.Config and Bridge.Config.Debug then
    lib.print.info("[Garage] Existing Vehicle Check", self.entities[vehicleModel])
  end
  
  -- Check if vehicle is already out
  if self.entities[vehicleModel] then
    Bridge.Notify.showNotify(locale("vehicle_already_out"), "error")
    return
  end
  
  -- Get spawn coordinates
  local spawnCoords = self:getSpawn(self.currentGarage)
  
  if Bridge and Bridge.Config and Bridge.Config.Debug then
    lib.print.info("[Garage] Vehicle Spawn Coords", spawnCoords)
  end
  
  if not spawnCoords then
    Bridge.Notify.showNotify(locale("no_spawn_available"), "error")
    return
  end
  
  if Bridge and Bridge.Config and Bridge.Config.Debug then
    lib.print.info("[Garage] Current Garage", self.currentGarage)
  end
  
  if not self.currentGarage then
    return
  end
  
  local garageConfig = Config.Garages[self.currentGarage]
  
  -- Spawn the vehicle
  local modelHash = lib.requestModel(vehicleModel)
  local vehicle = CreateVehicle(modelHash, spawnCoords, true, true)
  
  -- Set license plate
  local plate = self:createPlate(garageConfig.platePrefix or "EMS")
  SetVehicleNumberPlateText(vehicle, plate)
  SetEntityAsMissionEntity(vehicle, true, true)
  SetVehicleOnGroundProperly(vehicle)
  
  -- Set fuel if bridge supports it
  if Bridge.Fuel then
    Bridge.Fuel.SetFuel(vehicle, 100.0)
  end
  
  -- Warp player into vehicle if configured
  if garageConfig.spawnInVehicle then
    TaskWarpPedIntoVehicle(cache.ped, vehicle, -1)
  end
  
  -- Apply vehicle modifications
  local vehicleMods = garageConfig.vehicles[vehicleModel]
  if vehicleMods and vehicleMods.mods then
    SetVehicleModKit(vehicle, 0)
    for modType, modIndex in pairs(vehicleMods.mods) do
      SetVehicleMod(vehicle, modType, modIndex, false)
    end
  end
  
  -- Give keys after delay
  SetTimeout(1000, function()
    if Bridge.CarKeys then
      if Bridge and Bridge.Config and Bridge.Config.Debug then
        lib.print.info("[Garage] Giving Keys", plate, vehicle)
      end
      Bridge.CarKeys.CreateKeys(plate, vehicle)
    end
  end)
  
  -- Track spawned vehicle
  self.entities[vehicleModel] = vehicle
  
  -- Trigger editable callback
  Editable:onGarageVehicleCreated(vehicle)
  
  SetModelAsNoLongerNeeded(modelHash)
  self:close()
  
  Bridge.Notify.showNotify(locale("taken_out_vehicle"), "success")
end

-- Park vehicle back in garage
function Garage.parkIn(self, vehicleModel)
  -- Check anti-spam timer
  if self.antiSpam > GetGameTimer() then
    return
  end
  
  self.antiSpam = GetGameTimer() + 1000
  
  -- Check if vehicle exists in tracking
  if not self.entities[vehicleModel] then
    return
  end
  
  local vehicle = self.entities[vehicleModel]
  
  if DoesEntityExist(vehicle) then
    local engineHealth = GetVehicleEngineHealth(vehicle)
    
    -- Check if vehicle is destroyed
    if engineHealth < 200.0 then
      if Bridge.CarKeys then
        Bridge.CarKeys.RemoveKeys(GetVehicleNumberPlateText(vehicle), vehicle)
      end
      DeleteEntity(vehicle)
      self.entities[vehicleModel] = nil
      Bridge.Notify.showNotify(locale("vehicle_parked"), "success")
    else
      -- Check distance to garage
      local vehicleCoords = GetEntityCoords(vehicle)
      local playerCoords = GetEntityCoords(cache.ped)
      local distance = #(vehicleCoords - playerCoords)
      local maxDistance = Config.Garages[self.currentGarage].parkDistance or 10.0
      
      if distance > maxDistance then
        Bridge.Notify.showNotify(locale("too_far_from_vehicle"), "error")
        return
      end
      
      -- Park vehicle
      if Bridge.CarKeys then
        Bridge.CarKeys.RemoveKeys(GetVehicleNumberPlateText(vehicle), vehicle)
      end
      DeleteEntity(vehicle)
      self.entities[vehicleModel] = nil
      Bridge.Notify.showNotify(locale("vehicle_parked"), "success")
    end
  else
    -- Vehicle doesn't exist, remove from tracking
    self.entities[vehicleModel] = nil
    Bridge.Notify.showNotify(locale("vehicle_parked"), "success")
  end
  
  self:close()
end

-- NUI Callback: Take out vehicle
RegisterNUICallback("garages/takeOut", function(data)
  if Bridge and Bridge.Config and Bridge.Config.Debug then
    lib.print.info("[Garage] Taking Out Vehicle", data)
  end
  Garage:takeOut(data.model)
end)

-- NUI Callback: Park vehicle
RegisterNUICallback("garages/parkIn", function(data)
  Garage:parkIn(data.model)
end)

-- NUI Callback: Hide frame
RegisterNUICallback("hideFrame", function(data)
  if data.name == "setVisibleGarage" then
    Garage:close()
  end
end)

-- Create new garage instance with interaction zone
function Garage.new(self, garageId, garageData)
  local isSelectedHospital, jobRestriction = Utils:isSelectedHospital(garageId)
  
  if not isSelectedHospital then
    return
  end
  
  -- Create blip if configured
  if garageData.blip then
    Utils:createBlip({
      sprite = garageData.blip.sprite,
      color = garageData.blip.color,
      scale = garageData.blip.scale,
      name = garageData.blip.label or locale("garage"),
      coords = garageData.coords,
      jobs = (isSelectedHospital or nil) and jobRestriction or nil
    })
  end
  
  -- Create interaction point
  local point = lib.points.new({
    coords = vec3(garageData.coords.xyz),
    distance = 25
  })
  
  -- On enter: spawn NPC
  function point:onEnter()
    if garageData.ped then
      local ped, prop = Utils:createPed({
        model = garageData.ped,
        coords = garageData.coords,
        anim = garageData.anim,
        prop = garageData.prop
      })
      self.ped = ped
      self.prop = prop
      
      -- Add target interaction to NPC
      Bridge.Target.addLocalEntity(self.ped, {
        {
          name = "p_ambulancejob/garage/" .. garageId,
          label = locale("open_garage"),
          icon = "fa-solid fa-warehouse",
          distance = 2.0,
          groups = jobRestriction or nil,
          onSelect = function()
            Garage:open(garageId)
          end
        }
      })
    end
  end
  
  -- On exit: remove NPC
  function point:onExit()
    if self.ped then
      DeleteEntity(self.ped)
      self.ped = nil
    end
  end
end

-- Get list of vehicles available in garage
function Garage.getVehicles(self, garageId)
  local garageVehicles = Config.Garages[garageId] and Config.Garages[garageId].vehicles
  
  if not garageVehicles then
    return nil
  end
  
  local vehicles = {}
  local playerJob = Bridge.Framework.fetchPlayerJob()
  
  -- Build vehicle list based on player's job grade
  for model, vehicleData in pairs(garageVehicles) do
    if lib.table.contains(vehicleData.allowedGrades, playerJob.grade) then
      local index = #vehicles + 1
      
      -- Determine vehicle state (in or out)
      local state = self.entities[model] and "out" or "in"
      
      vehicles[index] = {
        model = model,
        label = vehicleData.label,
        image = vehicleData.image,
        state = state
      }
    end
  end
  
  return vehicles
end

-- Find available spawn point closest to player
function Garage.getSpawn(self, garageId)
  local spawnPoints = Config.Garages[garageId] and Config.Garages[garageId].spawnPoints
  
  if not spawnPoints then
    return nil
  end
  
  local closestSpawn = nil
  local playerCoords = GetEntityCoords(cache.ped)
  
  -- Find closest available spawn point
  for i = 1, #spawnPoints do
    local spawnPoint = spawnPoints[i]
    
    -- Check if this spawn is closer than current closest
    if closestSpawn then
      local currentDistance = #(vec3(spawnPoint.xyz) - playerCoords)
      local closestDistance = #(vec3(closestSpawn.xyz) - playerCoords)
      
      if currentDistance >= closestDistance then
        goto continue
      end
    end
    
    -- Check if spawn point is occupied
    local nearbyVehicles = lib.getNearbyVehicles(vec3(spawnPoint.xyz), 1.0)
    if #nearbyVehicles == 0 then
      closestSpawn = spawnPoint
    end
    
    ::continue::
  end
  
  return closestSpawn
end

-- Generate random string for plate
local function generateRandomString(length)
  local result = ""
  local charset = "abcdefghijklmnoprstwyxyuzABCDEFGHIJKLMNOPRSTWUXYZ1234567890"
  
  for i = 1, length do
    local randomIndex = math.random(1, charset:len())
    result = result .. charset:sub(randomIndex, randomIndex)
  end
  
  return result
end

-- Create license plate with prefix
function Garage.createPlate(self, prefix)
  if not prefix then
    prefix = generateRandomString(3)
  end
  
  local plate = prefix .. generateRandomString(8 - prefix:len())
  return plate:upper()
end

-- Initialize garage system
Citizen.CreateThread(function()
  Garage:init()
end)