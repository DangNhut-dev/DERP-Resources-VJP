local defaultServicingData = {
    suspension = 100,
    tyres = 100,
    brakePads = 100,
    engineOil = 100,
    clutch = 100,
    airFilter = 100,
    sparkPlugs = 100,
    evMotor = 100,
    evBattery = 100,
    evCoolant = 100
}

-- Clone table to avoid modifying default
local function cloneTable(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = v
    end
    return copy
end


AddStateBagChangeHandler("vehicleMileage", "", function(bagName, key, value)
    -- print("Statebag triggered:", bagName, key, value)

    if not Config.EnableVehicleServicing then
        return
    end

    -- Must define vehicle BEFORE printing model
    local vehicle = GetEntityFromStateBagName(bagName)

    if vehicle == 0 or not DoesEntityExist(vehicle) then
        -- print("Vehicle not valid:", vehicle)
        return
    end

    if not (cache.vehicle == vehicle and cache.seat == -1) then
        -- print("Not driver seat:", cache.vehicle, cache.seat)
        return
    end

    local archetypeName = GetEntityArchetypeName(vehicle)
    if Config.ServicingBlacklist and lib.table.contains(Config.ServicingBlacklist, archetypeName) then
        -- print("Vehicle blacklisted:", archetypeName)
        return
    end

    -- mileage must be integer
    if value % 1 ~= 0 or value < 1 then
        return
    end

    local model = GetEntityModel(vehicle)
    local isElectric = isVehicleElectric(archetypeName)
    local isSupportedVehicle =
        IsThisModelACar(model) or
        IsThisModelABike(model) or
        IsThisModelAQuadbike(model)

    if not isSupportedVehicle then
        -- print("Unsupported vehicle type:", model)
        return
    end

    local vehicleState = Entity(vehicle).state
    local currentServicingData = vehicleState.servicingData or cloneTable(defaultServicingData)

    -- print("IS ELECTRIC?", isElectric)

    -- Correct servicing logic
    for part, partConfig in pairs(Config.Servicing) do

        -- FIXED RESTRICTION LOGIC:
        local allow =
            (partConfig.restricted == nil) or
            (partConfig.restricted == "electric" and isElectric) or
            (partConfig.restricted == "combustion" and not isElectric)

        if allow then
            local wearRate = 100 / (partConfig.lifespanInKm or 1)
            local newHealth = round(math.max(0, currentServicingData[part] - wearRate), 5)
            currentServicingData[part] = newHealth
        end
    end

    setVehicleStatebag(vehicle, "servicingData", currentServicingData, true)

    -- Notify if any part is below threshold
    for part, health in pairs(currentServicingData) do
        if health <= Config.ServiceRequiredThreshold then
            Framework.Client.Notify(Locale.serviceVehicleSoon, "error")
            break
        end
    end
end)



RegisterNUICallback("service-vehicle", function(data, cb)
    local partName = data.name
    local partConfig = Config.Servicing[partName]
    if not partConfig then return cb(false) end

    local vehicle = LocalPlayer.state.tabletConnectedVehicle and LocalPlayer.state.tabletConnectedVehicle.vehicleEntity
    if not vehicle or not DoesEntityExist(vehicle) then return cb(false) end

    local vehiclePlate = Framework.Client.GetPlate(vehicle)
    local vehicleState = Entity(vehicle).state
    local servicingData = vehicleState.servicingData
    local minigameProp = (partName == "tyres" or partName == "brakePads") and "wheel" or "spanner"

    playMinigame(vehicle, "prop", { prop = minigameProp }, function(success)
        showTabletAfterInteractionPrompt()
        SetNuiFocus(true, true)

        if not success then return cb(false) end

        local paymentSuccess = lib.callback.await("DERP-mechanic:server:pay-for-service", false, vehiclePlate, partName)
        if not paymentSuccess then return cb(false) end

        Framework.Client.Notify(Locale.partServiced:format(Locale[partName] or partName), "success")
        servicingData[partName] = 100
        setVehicleStatebag(vehicle, "servicingData", servicingData, true)
        cb(true)
    end)
end)



RegisterNUICallback("get-service-history", function(data, cb)
    local vehicle = LocalPlayer.state.tabletConnectedVehicle and LocalPlayer.state.tabletConnectedVehicle.vehicleEntity
    if not vehicle or not DoesEntityExist(vehicle) then return cb(false) end

    local plate = Framework.Client.GetPlate(vehicle)
    local history = lib.callback.await("DERP-mechanic:server:get-servicing-history", false, plate)
    cb(history)
end)
