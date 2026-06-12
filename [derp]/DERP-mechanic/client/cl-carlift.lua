local MIN_HEIGHT = -1.025
local MAX_HEIGHT = 0.85
local HEIGHT_INCREMENT = 0.01
local activeCarLift = nil
local isMovingUp = false
local isMovingDown = false
local liftSound = nil

RegisterNUICallback("carlift-up", function(data, cb)
    if not activeCarLift or isMovingUp then
        cb(false)
        return
    end

    local shouldAttachVehicle = data.vAttach
    local platformProp = activeCarLift.platformProp
    local platformCoords = GetEntityCoords(platformProp)
    activeCarLift.height = platformCoords.z - activeCarLift.coords.z
    isMovingUp = true

    local closestVehicle, closestVehicleCoords = lib.getClosestVehicle(platformCoords, 3.0, true)

    liftSound = Framework.Client.PlaySound("hydraulic", vector3(activeCarLift.coords.x, activeCarLift.coords.y, activeCarLift.coords.z))

    CreateThread(function()
        while isMovingUp and activeCarLift and activeCarLift.height < MAX_HEIGHT do
            activeCarLift.height = activeCarLift.height + HEIGHT_INCREMENT
            local newZ = activeCarLift.coords.z + activeCarLift.height
            SetEntityCoords(platformProp, activeCarLift.coords.x, activeCarLift.coords.y, newZ, false, false, false, false)

            if shouldAttachVehicle and closestVehicle and closestVehicleCoords and DoesEntityExist(closestVehicle) then
                SetEntityCoords(closestVehicle, closestVehicleCoords.x, closestVehicleCoords.y, newZ, false, false, false, false)
            end
            Wait(25)
        end

        if activeCarLift and activeCarLift.height >= MAX_HEIGHT and liftSound then
            Framework.Client.StopSound(liftSound)
        end
    end)
    cb(true)
end)

RegisterNUICallback("carlift-down", function(data, cb)
    if not activeCarLift or isMovingDown then
        cb(false)
        return
    end

    local shouldAttachVehicle = data.vAttach
    local platformProp = activeCarLift.platformProp
    local platformCoords = GetEntityCoords(platformProp)
    activeCarLift.height = platformCoords.z - activeCarLift.coords.z
    isMovingDown = true

    local closestVehicle, closestVehicleCoords = lib.getClosestVehicle(platformCoords, 3.0, true)

    liftSound = Framework.Client.PlaySound("hydraulic", vector3(activeCarLift.coords.x, activeCarLift.coords.y, activeCarLift.coords.z))

    CreateThread(function()
        while isMovingDown and activeCarLift and activeCarLift.height > MIN_HEIGHT do
            activeCarLift.height = activeCarLift.height - HEIGHT_INCREMENT
            local newZ = activeCarLift.coords.z + activeCarLift.height
            SetEntityCoords(platformProp, activeCarLift.coords.x, activeCarLift.coords.y, newZ, false, false, false, false)

            if shouldAttachVehicle and closestVehicle and closestVehicleCoords and DoesEntityExist(closestVehicle) then
                SetEntityCoords(closestVehicle, closestVehicleCoords.x, closestVehicleCoords.y, newZ, false, false, false, false)
            end
            Wait(25)
        end

        if activeCarLift and activeCarLift.height <= MIN_HEIGHT and liftSound then
            Framework.Client.StopSound(liftSound)
        end
    end)
    cb(true)
end)

RegisterNUICallback("carlift-stop", function(data, cb)
    if not activeCarLift or not liftSound then
        cb(false)
        return
    end

    Framework.Client.StopSound(liftSound)
    isMovingDown = false
    isMovingUp = false
    cb(true)
end)

RegisterNUICallback("hide-carlift-controls", function(data, cb)
    SendNUIMessage({ showCarLift = false })
    SetNuiFocus(false, false)
    cb(true)
end)

function openCarLiftMenu()
    SetNuiFocus(true, true)
    SendNUIMessage({
        showCarLift = true,
        locale = Locale
    })
end

function onEnterCarliftZone(zoneData)
    if not zoneData then return end

    local platformProp = NetworkGetEntityFromNetworkId(zoneData.platform)
    local standProp = NetworkGetEntityFromNetworkId(zoneData.stand)

    Framework.Client.ShowTextUI(Config.UseCarLiftPrompt)

    activeCarLift = {
        platformProp = platformProp,
        standProp = standProp,
        coords = zoneData.coords,
        height = 0
    }

    CreateThread(function()
        while activeCarLift do
            if IsControlJustPressed(0, Config.UseCarLiftKey) then
                openCarLiftMenu()
            end
            Wait(0)
        end
    end)
end

function onExitCarliftZone()
    activeCarLift = nil
    Framework.Client.HideTextUI()
    SetNuiFocus(false, false)
    SendNUIMessage({ showCarLift = false })
end