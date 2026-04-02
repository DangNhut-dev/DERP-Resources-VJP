-- =====================================================
--  GPS Tracking System for Ambulance Job
-- =====================================================

-- Unused test function (retained for compatibility)
local function test()
  local schools = GlobalState["p_dmvschool/Schools"]
  if schools then
    schools = schools[k]
    if schools then
      return schools.theoryQuestions
    end
  end
end

-- Initialize GPS system
GPS = {}
GPS.players = {}

-- Sync GPS data to global state
GlobalState["p_ambulancejob/gpsData"] = GPS.players

-- Determine vehicle/movement type
function GPS.getType(self, ped)
  local vehicle = GetVehiclePedIsIn(ped, false)
  
  if vehicle and vehicle ~= 0 then
    local vehicleType = GetVehicleType(vehicle)
    
    if vehicleType == "boat" then
      return "boat"
    elseif vehicleType == "plane" then
      return "plane"
    elseif vehicleType == "heli" then
      return "heli"
    elseif vehicleType == "bike" then
      return "bike"
    else
      return "car"
    end
  end
  
  return "walk"
end

-- Update player GPS data
function GPS.update(self, playerId)
  if not playerId or playerId == 0 then
    return
  end
  
  local success, ped = pcall(GetPlayerPed, playerId)
  
  if success and ped and ped ~= 0 then
    local vehicle = GetVehiclePedIsIn(ped, false)
    local playerName = Bridge.Framework.getPlayerName(playerId)
    local playerJob = Bridge.Framework.getPlayerJob(playerId)
    
    -- Determine entity to track (vehicle or ped)
    local trackedEntity = vehicle ~= 0 and vehicle or ped
    
    -- Build player GPS entry
    local gpsData = {
      label = string.format("%s - %s", playerName, playerJob.grade_label),
      heading = GetEntityHeading(trackedEntity),
      coords = GetEntityCoords(trackedEntity),
      type = self:getType(ped),
      sirens = (vehicle ~= 0 and IsVehicleSirenOn(vehicle)) or false,
      vehicle = vehicle ~= 0 and vehicle or nil
    }
    
    self.players[playerId] = gpsData
  else
    -- Remove player if ped is invalid
    self.players[playerId] = nil
  end
end

-- Toggle GPS for a player
function GPS.toggle(self, playerId)
  local playerJob = Bridge.Framework.getPlayerJob(playerId)
  
  -- Check if player has access to GPS
  if not playerJob or not Editable.allJobs[playerJob.name] then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  -- Toggle GPS on/off
  if self.players[playerId] then
    self.players[playerId] = nil
    Bridge.Notify.showNotify(playerId, locale("deactivated_gps"), "inform")
  else
    self:update(playerId)
    Bridge.Notify.showNotify(playerId, locale("activated_gps"), "inform")
  end
end

-- Initialize GPS system with update loop
function GPS.init(self)
  -- Configuration
  local UPDATE_INTERVAL = 1000 -- Fast update for type/siren changes
  local POSITION_SYNC_INTERVAL = 3000 -- Position updates every 3 seconds
  local lastPositionSync = 0
  
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(UPDATE_INTERVAL)
      
      local needsSync = false
      local currentTime = GetGameTimer()
      local playerIds = {}
      
      -- Collect player IDs first (avoid issues with table modification during iteration)
      for playerId in pairs(self.players) do
        playerIds[#playerIds + 1] = playerId
      end
      
      -- Update all active GPS players
      for _, playerId in ipairs(playerIds) do
        local gpsData = self.players[playerId]
        
        if gpsData then
          -- Check if GPS item is required (optional config)
          local hasRequiredItem = true
          -- GPS item check disabled by default since Config.GPS doesn't exist
          
          -- Update player data if they still have access
          if hasRequiredItem then
            local oldType = gpsData.type
            local oldSirens = gpsData.sirens
            
            self:update(playerId)
            
            -- Check if important data changed (vehicle type or siren state)
            local newData = self.players[playerId]
            if newData and (oldType ~= newData.type or oldSirens ~= newData.sirens) then
              needsSync = true
            end
          end
        end
      end
      
      -- Sync to global state if something important changed OR it's time for position update
      local timeForPositionSync = (currentTime - lastPositionSync) >= POSITION_SYNC_INTERVAL
      
      if needsSync or timeForPositionSync then
        GlobalState["p_ambulancejob/gpsData"] = self.players
        if timeForPositionSync then
          lastPositionSync = currentTime
        end
      end
    end
  end)
end

-- Register network event for GPS toggle
RegisterNetEvent("p_ambulancejob/gps/server/toggle", function()
  local playerId = source
  GPS:toggle(playerId)
end)

-- Start GPS system
GPS:init()