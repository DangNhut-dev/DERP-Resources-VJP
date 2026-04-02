-- =====================================================
--  GPS Tracking System - Client Side
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
GPS.state = false
GPS.blips = {}

-- Initialize GPS blips for all tracked players
function GPS.init(self, gpsData)
  self:clear()
  Citizen.Wait(10)
  
  AddTextEntryByHash(1248374007, "GPS~w~")
  
  for playerId, playerData in pairs(gpsData) do
    -- Default GPS type config (fallback if Config.GPS doesn't exist)
    local sprite = 1
    if playerData.type == 'walk' then
      sprite = 1
    elseif playerData.type == 'car' then
      sprite = 227
    elseif playerData.type == 'bike' then
      sprite = 661
    elseif playerData.type == 'boat' then
      sprite = 754
    elseif playerData.type == 'heli' then
      sprite = 422
    elseif playerData.type == 'plane' then
      sprite = 575
    end
    
    local typeConfig = {
      sprite = sprite,
      color = 1,
      sirenColor = 3,
      scale = 0.9
    }
    
    -- Use Config.GPS if available
    if Config and Config.GPS and Config.GPS.types and Config.GPS.types[playerData.type] then
      typeConfig = Config.GPS.types[playerData.type]
    end
    
    local targetPed = GetPlayerPed(GetPlayerFromServerId(playerId))
    local blip
    
    -- Create blip based on whether player is found
    if targetPed and targetPed ~= 0 then
      -- Skip if it's the local player
      if targetPed ~= cache.ped and playerId ~= cache.serverId then
        -- Check if player is in a vehicle and create blip for vehicle instead of ped
        local targetVehicle = GetVehiclePedIsIn(targetPed, false)
        if targetVehicle and targetVehicle ~= 0 then
          blip = AddBlipForEntity(targetVehicle)
        else
          blip = AddBlipForEntity(targetPed)
        end
      end
    else
      -- Player not found, create coord blip
      blip = AddBlipForCoord(playerData.coords.x, playerData.coords.y, playerData.coords.z)
    end
    
    -- Configure blip appearance
    if blip then
      -- Set color based on siren state
      local blipColor = playerData.sirens and typeConfig.sirenColor or typeConfig.color
      
      SetBlipSprite(blip, typeConfig.sprite)
      SetBlipColour(blip, blipColor)
      SetBlipScale(blip, typeConfig.scale)
      SetBlipShrink(blip, true)
      SetBlipPriority(blip, 10)
      ShowHeightOnBlip(blip, false)
      SetBlipHiddenOnLegend(blip, false)
      SetBlipCategory(blip, 7)
      SetBlipAsShortRange(blip, true)
      ShowNumberOnBlip(blip, "10")
      ShowHeadingIndicatorOnBlip(blip, true)
      SetBlipRotation(blip, math.ceil(playerData.heading))
      
      -- Set blip name
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(playerData.label)
      EndTextCommandSetBlipName(blip)
      
      -- Store blip with additional data for tracking
      self.blips[playerId] = {
        blip = blip,
        lastType = playerData.type,
        lastSirenState = playerData.sirens
      }
    end
  end
end

-- Clear all GPS blips
function GPS.clear(self)
  for playerId, blipData in pairs(self.blips) do
    local blip = type(blipData) == "table" and blipData.blip or blipData
    if DoesBlipExist(blip) then
      RemoveBlip(blip)
    end
  end
  self.blips = {}
end

-- Toggle GPS on/off
function GPS.toggle(self)
  local playerJob = Bridge.Framework.fetchPlayerJob()
  
  -- Check if player has access to GPS
  if not Editable.allJobs[playerJob.name] then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  -- Toggle state
  self.state = not self.state
  
  -- Keep own blip visible at all times
  SetBlipScale(GetMainPlayerBlipId(), 0.9)
  
  -- Notify server
  TriggerServerEvent("p_ambulancejob/gps/server/toggle")
  
  -- Clear blips if turning off
  if not self.state then
    self:clear()
  end
end

-- Export for checking GPS state
exports("isGpsActive", function()
  return GPS.state
end)

-- Network event to toggle GPS
RegisterNetEvent("p_ambulancejob/client/gps/toggle", function()
  GPS:toggle()
end)

-- Update only changed blips instead of recreating all
function GPS.updateBlips(self, gpsData)
  if not gpsData then return end
  
  -- Track which players are still active
  local activePlayerIds = {}
  
  for playerId, playerData in pairs(gpsData) do
    activePlayerIds[playerId] = true
    local existingBlip = self.blips[playerId]
    
    -- Default GPS type config (fallback if Config.GPS doesn't exist)
    local sprite = 1
    if playerData.type == 'walk' then
      sprite = 1
    elseif playerData.type == 'car' then
      sprite = 227
    elseif playerData.type == 'bike' then
      sprite = 661
    elseif playerData.type == 'boat' then
      sprite = 754
    elseif playerData.type == 'heli' then
      sprite = 422
    elseif playerData.type == 'plane' then
      sprite = 575
    end
    
    local typeConfig = {
      sprite = sprite,
      color = 1,
      sirenColor = 3,
      scale = 0.9
    }
    
    -- Use Config.GPS if available
    if Config and Config.GPS and Config.GPS.types and Config.GPS.types[playerData.type] then
      typeConfig = Config.GPS.types[playerData.type]
    end
    
    -- Check if blip needs update
    local needsUpdate = not existingBlip or 
    existingBlip.lastType ~= playerData.type or 
    existingBlip.lastSirenState ~= playerData.sirens
    
    if needsUpdate then
      -- Remove old blip if exists
      if existingBlip then
        local oldBlip = existingBlip.blip
        if DoesBlipExist(oldBlip) then
          RemoveBlip(oldBlip)
        end
      end
      
      -- Create new blip
      local targetPed = GetPlayerPed(GetPlayerFromServerId(playerId))
      local blip
      
      if targetPed and targetPed ~= 0 then
        -- Skip if it's the local player
        if targetPed ~= cache.ped and playerId ~= cache.serverId then
          local targetVehicle = GetVehiclePedIsIn(targetPed, false)
          if targetVehicle and targetVehicle ~= 0 then
            blip = AddBlipForEntity(targetVehicle)
          else
            blip = AddBlipForEntity(targetPed)
          end
        end
      else
        blip = AddBlipForCoord(playerData.coords.x, playerData.coords.y, playerData.coords.z)
      end
      
      if blip then
        local blipColor = playerData.sirens and typeConfig.sirenColor or typeConfig.color
        
        SetBlipSprite(blip, typeConfig.sprite)
        SetBlipColour(blip, blipColor)
        SetBlipScale(blip, typeConfig.scale)
        SetBlipShrink(blip, true)
        SetBlipPriority(blip, 10)
        ShowHeightOnBlip(blip, false)
        SetBlipHiddenOnLegend(blip, false)
        SetBlipCategory(blip, 7)
        SetBlipAsShortRange(blip, true)
        ShowNumberOnBlip(blip, "10")
        ShowHeadingIndicatorOnBlip(blip, true)
        SetBlipRotation(blip, math.ceil(playerData.heading))
        
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(playerData.label)
        EndTextCommandSetBlipName(blip)
        
        self.blips[playerId] = {
          blip = blip,
          lastType = playerData.type,
          lastSirenState = playerData.sirens
        }
      end
    else
      -- Just update rotation for existing blip
      local blip = existingBlip.blip
      if DoesBlipExist(blip) then
        SetBlipRotation(blip, math.ceil(playerData.heading))
      end
    end
  end
  
  -- Remove blips for players no longer in GPS data
  for playerId, blipData in pairs(self.blips) do
    if not activePlayerIds[playerId] then
      local blip = blipData.blip
      if DoesBlipExist(blip) then
        RemoveBlip(blip)
      end
      self.blips[playerId] = nil
    end
  end
end

-- Handle GPS data updates from server
AddStateBagChangeHandler("p_ambulancejob/gpsData", "global", function(bagName, key, gpsData)
  -- Only process if GPS is active
  if not GPS.state then
    return
  end
  
  local playerJob = Bridge.Framework.fetchPlayerJob()
  
  -- Verify player still has access
  if not playerJob or not Editable.allJobs[playerJob.name] then
    GPS:clear()
    return
  end
  
  -- Use optimized update instead of full recreation
  GPS:updateBlips(gpsData)
end)