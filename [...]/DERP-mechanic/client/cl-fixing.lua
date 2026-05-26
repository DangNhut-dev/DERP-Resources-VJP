RegisterNetEvent("DERP-mechanic:client:fix-vehicle-admin", function()
  local isAdmin = lib.callback.await("DERP-mechanic:server:is-admin", false)
  if not isAdmin then
    return
  end

  local vehicle = cache.vehicle
  if not vehicle then
    Framework.Client.Notify(Locale.notInsideVehicle, "error")
    return
  end

  Framework.Client.RepairVehicle(cache.vehicle)
end)

RegisterNetEvent("DERP-mechanic:client:clean-vehicle", function()
  local hasItem = lib.callback.await("DERP-mechanic:server:has-item", 250, "cleaning_kit")
  if not hasItem then
    return
  end

  local playerPed = cache.ped
  local closestVehicle = lib.getClosestVehicle(GetEntityCoords(playerPed), 3.0, true)

  if not closestVehicle then
    return Framework.Client.Notify(Locale.noVehicleNearby, "error")
  end

  if IsPedInVehicle(playerPed, closestVehicle, true) then
    TaskLeaveVehicle(playerPed, closestVehicle, 16)
  end

  local anim = {
    dict = "amb@world_human_maid_clean@",
    name = "base"
  }
  local prop = {
    model = "prop_sponge_01",
    bone = 28422,
    coords = vector3(0.0, 0.0, -0.01),
    rotation = vector3(90.0, 0.0, 0.0)
  }

  Framework.Client.ProgressBar(Locale.cleaningVehicle, 3500, anim, prop, function()
    SetVehicleDirtLevel(closestVehicle, 0.0)
    WashDecalsFromVehicle(closestVehicle, 1.0)
    Framework.Client.Notify(Locale.vehicleCleaned, "success")
    TriggerServerEvent("DERP-mechanic:server:remove-item", "cleaning_kit")
  end, function()
    -- Cancel callback
  end)
end)

RegisterNetEvent("DERP-mechanic:client:repair-vehicle", function()
  local hasItem = lib.callback.await("DERP-mechanic:server:has-item", 250, "repair_kit")
  if not hasItem then
    return
  end

  local playerPed = cache.ped
  local closestVehicle = lib.getClosestVehicle(GetEntityCoords(playerPed), 3.0, true)

  if not closestVehicle then
    return Framework.Client.Notify(Locale.noVehicleNearby, "error")
  end

  if cache.vehicle then
    return Framework.Client.Notify(Locale.leaveVehicleFirst, "error")
  end

  playMinigame(closestVehicle, "prop", { prop = "spanner" }, function(success)
    if not success then return end

    local hasRepairKit = lib.callback.await("DERP-mechanic:server:has-item", false, "repair_kit")
    if not hasRepairKit then return end

    Framework.Client.RepairVehicle(closestVehicle)
    Framework.Client.Notify(Locale.vehicleRepaired, "success")
    TriggerServerEvent("DERP-mechanic:server:remove-item", "repair_kit")
  end)
end)

RegisterNetEvent("DERP-mechanic:client:use-duct-tape", function()
  local hasItem = lib.callback.await("DERP-mechanic:server:has-item", 250, "duct_tape")
  if not hasItem then
    return
  end

  local playerPed = cache.ped
  local closestVehicle = lib.getClosestVehicle(GetEntityCoords(playerPed), 3.0, true)

  if not closestVehicle then
    return Framework.Client.Notify(Locale.noVehicleNearby, "error")
  end

  local engineHealth = GetVehicleEngineHealth(closestVehicle)
  if engineHealth > Config.DuctTapeMinimumEngineHealth then
    return Framework.Client.Notify(Locale.ductTapeEngineHealthTooHigh, "error")
  end

  playMinigame(closestVehicle, "prop", { prop = "spanner" }, function(success)
    if not success then return end

    local hasDuctTape = lib.callback.await("DERP-mechanic:server:has-item", false, "duct_tape")
    if not hasDuctTape then return end

    SetVehicleUndriveable(closestVehicle, false)
    SetVehicleEngineHealth(closestVehicle, engineHealth + Config.DuctTapeEngineHealthIncrease)
    Framework.Client.Notify(Locale.ductTapeUsed, "success")
    TriggerServerEvent("DERP-mechanic:server:remove-item", "duct_tape")
  end)
end)