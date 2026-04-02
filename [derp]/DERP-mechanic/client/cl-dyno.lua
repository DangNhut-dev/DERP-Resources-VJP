local isDynoActive = false

local function setWheelRotationSpeedBasedOnDrivetrain(vehicle, speed)
  local driveBiasFront = getVehicleHandlingValue(vehicle, "CHandlingData", "fDriveBiasFront")

  if driveBiasFront > 0.5 or driveBiasFront == 0.5 then
    SetVehicleWheelRotationSpeed(vehicle, 0, speed)
    SetVehicleWheelRotationSpeed(vehicle, 1, speed)
  end

  if driveBiasFront < 0.5 or driveBiasFront == 0.5 then
    SetVehicleWheelRotationSpeed(vehicle, 2, speed)
    SetVehicleWheelRotationSpeed(vehicle, 3, speed)
  end
end

local function startDynoRun(vehicle)
  CreateThread(function()
    local startTime = 0
    isDynoActive = true
    local timeout = startTime
    SetVehicleGravity(vehicle, false)

    while timeout < 33500 do
      if not isDynoActive then
        break
      end

      local tickStart = GetGameTimer()
      Entity(vehicle).state:set("vehicleDyno", {
        rpm = math.min(1.0, (timeout + 7500) / 33500 + 0.0),
        wheelSpeed = timeout / 200 + 0.0
      }, true)

      Wait(50)
      timeout = timeout + (GetGameTimer() - tickStart)
    end

    Entity(vehicle).state:set("vehicleDyno", false, true)
    SetVehicleGravity(vehicle, true)
  end)
end

AddStateBagChangeHandler("vehicleDyno", "", function(bagName, key, value)
  local vehicle = GetEntityFromStateBagName(bagName)
  if vehicle ~= 0 and DoesEntityExist(vehicle) then
    if not value then
      setWheelRotationSpeedBasedOnDrivetrain(vehicle, 0)
      return
    end

    local rpm = value.rpm
    local wheelSpeed = value.wheelSpeed
    SetVehicleCurrentRpm(vehicle, rpm)
    setWheelRotationSpeedBasedOnDrivetrain(vehicle, wheelSpeed)
  end
end)

RegisterNUICallback("start-dyno", function(data, cb)
  local playerPed = cache.ped
  local vehicle = LocalPlayer.state.tabletConnectedVehicle and LocalPlayer.state.tabletConnectedVehicle.vehicleEntity

  if not vehicle or not DoesEntityExist(vehicle) then
    return cb(false)
  end

  CreateThread(function()
    SetNuiFocus(false, false)

    if GetPedInVehicleSeat(vehicle, -1) ~= playerPed then
      hideTabletToShowInteractionPrompt(Locale.enterVehicleToStartDynoMsg)
      while GetPedInVehicleSeat(vehicle, -1) ~= playerPed do
        Wait(100)
      end
    end

    hideTabletToShowInteractionPrompt(Locale.startDynoMsg)
    while not IsControlJustPressed(0, 201) do
      Wait(0)
    end

    SetNuiFocus(true, true)
    showTabletAfterInteractionPrompt()

    cb({
      maxSpeed = getVehicleHandlingValue(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel"),
      fDriveInertia = getVehicleHandlingValue(vehicle, "CHandlingData", "fDriveInertia"),
      fInitialDriveForce = getVehicleHandlingValue(vehicle, "CHandlingData", "fInitialDriveForce")
    })
    startDynoRun(vehicle)
  end)
end)

RegisterNUICallback("stop-dyno", function(data, cb)
  isDynoActive = false
  cb(true)
end)

RegisterNUICallback("dyno-share-with-player", function(data, cb)
  local player = data.player
  local results = data.results

  if not player or not results then
    return cb(false)
  end

  local success = lib.callback.await("DERP-mechanic:server:dyno-share-with-player", false, player, results)
  cb(success)
end)

RegisterNetEvent("DERP-mechanic:client:dyno-show-results-sheet", function(results)
  SetNuiFocus(true, true)
  SendNUIMessage({
    type = "show-dyno-share-sheet",
    results = results,
    locale = Locale,
    config = Config
  })
end)