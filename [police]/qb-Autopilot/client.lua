---------- CONFIG
local useESXanimations = false      -- If you use esx_animations change it to true (no need for extra loop reading X key to clear ped tasks)
local speed = 25.0                  -- GetVehicleModelMaxSpeed(model) / 2 -- vehicle's speed
local speed2 = 70.0   --33.38
local speed3 = 8.38
local city = 13.9
local QBCore = exports['qb-core']:GetCoreObject()

local sundayDrivingEnabled = false
local speedMultiplier = (Config.speedunits == 'km/h') and 3.6 or 2.236936
--local speedMultiplier = 2.236936
local speedLimit = Config.defaultspeedlimit

local function CalculateSpeedLimit()
  CreateThread(function()
      while sundayDrivingEnabled do
          local currentSpeedLimit = speedLimit
          if cache.seat then
              speedLimit = Config.defaultspeedlimit
              local pos = GetEntityCoords(cache.ped)
              local street = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
              local streetName = GetStreetNameFromHashKey(street)
              for i = 1, #Config.streets do
                  if streetName == Config.streets[i].name then
                      speedLimit = Config.streets[i].speed
                      break
                  end
              end
          end
          -- Notify player if speed limit changes
          if currentSpeedLimit ~= speedLimit then 
              local notifyType = (GetEntitySpeed(cache.vehicle) * speedMultiplier > speedLimit) and 'warning' or 'inform'
              lib.notify({description = string.format(Config.notifyspeedlimit, speedLimit), type = notifyType})
          end
          Wait(1000)
      end
  end)
end

local function ApplySpeedLimit(veh, speedLimit)
  local currentSpeed = GetEntitySpeed(veh) * speedMultiplier
  if currentSpeed <= speedLimit then
      SetVehicleMaxSpeed(veh, speedLimit / speedMultiplier)
  end
end

local function EngageDrivingLimits()
  while sundayDrivingEnabled do
      if cache.seat then
          local veh = cache.vehicle
          -- Apply speed limit
          if Config.speedlimiter then
              ApplySpeedLimit(veh, speedLimit)
          end
          -- Apply RPM limit
          local maxRpm = 0.2 + (GetEntitySpeed(veh) / (Config.rpmlimiter * GetVehicleCurrentGear(veh)))
          if GetVehicleCurrentRpm(veh) > maxRpm then
              SetVehicleCurrentRpm(veh, maxRpm)
          end
      end
      Wait(10)
  end
end

local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
  }

local autopilotActive = false
local blipX = 0.0
local blipY = 0.0
local blipZ = 0.0
RegisterNetEvent("autopilot:start")
AddEventHandler("autopilot:start", function()
  local player = PlayerPedId()
  local vehicle = GetVehiclePedIsIn(player,false)
  local model = GetEntityModel(vehicle)
  local displaytext = GetDisplayNameFromVehicleModel(model)
  local blip = GetFirstBlipInfoId(8)
  if (blip ~= nil and blip ~= 0) then
      local coord = GetBlipCoords(blip)
      blipX = coord.x
      blipY = coord.y
      blipZ = coord.z
      local pos = GetEntityCoords(PlayerPedId())
        if pos.y >= 650 or pos.y <= -6938 or pos.x <= -3390 or pos.x >= 1200 then
              TaskVehicleDriveToCoordLongrange(player, vehicle, blipX, blipY, blipZ, speed2, 2883621, 1.0) -- 1074528293 786603
        else
              TaskVehicleDriveToCoordLongrange(player, vehicle, blipX, blipY, blipZ, speed, 2883621, 1.0) -- 427
        end
      autopilotActive = true   
  else
    QBCore.Functions.Notify("Thiết lập lộ trình trước")
  end
end)

RegisterNetEvent("autopilot:patrol")
AddEventHandler("autopilot:patrol", function()
  local player = PlayerPedId()
  local vehicle = GetVehiclePedIsIn(player,false)
  local model = GetEntityModel(vehicle)
  local displaytext = GetDisplayNameFromVehicleModel(model)
  local blip = GetFirstBlipInfoId(8)
  if (blip ~= nil and blip ~= 0) then
      local coord = GetBlipCoords(blip)
      blipX = coord.x
      blipY = coord.y
      blipZ = coord.z
      TaskVehicleDriveToCoordLongrange(player, vehicle, blipX, blipY, blipZ, speed3, 427, 1.0) -- 427
      autopilotActive = true   
  else
    QBCore.Functions.Notify("Thiết lập lộ trình trước")
  end
end)

RegisterNetEvent("autopilot:city")
AddEventHandler("autopilot:city", function()
  local player = PlayerPedId()
  local vehicle = GetVehiclePedIsIn(player,false)
  local model = GetEntityModel(vehicle)
  local displaytext = GetDisplayNameFromVehicleModel(model)
  local blip = GetFirstBlipInfoId(8)
  if (blip ~= nil and blip ~= 0) then
      local coord = GetBlipCoords(blip)
      blipX = coord.x
      blipY = coord.y
      blipZ = coord.z
      SetDriverAbility(player, 1.0)
      SetDriverAggressiveness(player, 1.0)
      TaskVehicleDriveToCoordLongrange(player, vehicle, blipX, blipY, blipZ, speed2 / 2.236936, 787371, 1.0) -- 787371
      SetDriverAbility(player, 1.0)
      autopilotActive = true   
      --sundayDrivingEnabled = true 
      CalculateSpeedLimit()
      EngageDrivingLimits() 
  else
    QBCore.Functions.Notify("Thiết lập lộ trình trước")
  end
end)

function ShowNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

Citizen.CreateThread(function()
    while true do
      Citizen.Wait(200) -- no need to check it every frame
      if autopilotActive then
        local coords = GetEntityCoords(PlayerPedId())
        local blip = GetFirstBlipInfoId(8)
        local dist = Vdist(coords.x, coords.y, coords.z, blipX, blipY, coords.z)
        if dist <= 32 then
          local player = PlayerPedId()
          local vehicle = GetVehiclePedIsIn(player,false)
          ClearPedTasks(player)
          -- smooth slowdown and stop:
          SetVehicleForwardSpeed(vehicle,5.0)
          Citizen.Wait(700)
          SetVehicleForwardSpeed(vehicle,2.0)
          Citizen.Wait(300)
          SetVehicleForwardSpeed(vehicle,0.0)
          --
          QBCore.Functions.Notify("Chúng ta đã đến nơi")
          autopilotActive = false
          sundayDrivingEnabled = false 
          --SetVehicleMaxSpeed(vehicle, Config.topspeed / speedMultiplier)
        end
      else
        Citizen.Wait(2000)
      end
    end
end)

if not useESXanimations then
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(0)
      if autopilotActive == true then
        local vehicle = GetVehiclePedIsIn(player,false)
        if(IsControlJustReleased(0, Keys['A']) or IsControlJustReleased(0, Keys['S']) or IsControlJustReleased(0, Keys['D']) or IsControlJustReleased(0, Keys['W'])) and GetLastInputMethod(2) and not isDead then
          ClearPedTasks(PlayerPedId())
          autopilotActive = false
          sundayDrivingEnabled = false 
          QBCore.Functions.Notify("Hủy tự động lái")
          --SetVehicleMaxSpeed(vehicle, Config.topspeed / speedMultiplier)
        end
      end
    end
  end)
end