-- Walkable Camera functionality for LB Phone
-- Handles camera controls, selfie mode, vehicle camera, and freeze functionality

-- Camera configuration constants
local maxFOV = Config.Camera and Config.Camera.MaxFOV or 70.0
local defaultFOV = Config.Camera and Config.Camera.DefaultFOV or 60.0
local minFOV = Config.Camera and Config.Camera.MinFOV or 10.0
local maxLookUp = Config.Camera and Config.Camera.MaxLookUp or 80.0
local maxLookDown = Config.Camera and Config.Camera.MaxLookDown or -80.0
local allowRunning = Config.Camera and Config.Camera.AllowRunning == true
local vehicleZoomEnabled = Config.Camera and Config.Camera.Vehicle and Config.Camera.Vehicle.Zoom == true
local vehicleMaxFOV = Config.Camera and Config.Camera.Vehicle and Config.Camera.Vehicle.MaxFOV or 80.0
local vehicleDefaultFOV = Config.Camera and Config.Camera.Vehicle and Config.Camera.Vehicle.DefaultFOV or 60.0
local vehicleMinFOV = Config.Camera and Config.Camera.Vehicle and Config.Camera.Vehicle.MinFOV or 10.0
local vehicleMaxLookUp = Config.Camera and Config.Camera.Vehicle and Config.Camera.Vehicle.MaxLookUp or 50.0
local vehicleMaxLookDown = Config.Camera and Config.Camera.Vehicle and Config.Camera.Vehicle.MaxLookDown or -30.0
local vehicleMaxLeftRight = Config.Camera and Config.Camera.Vehicle and Config.Camera.Vehicle.MaxLeftRight or 120.0
local vehicleMinLeftRight = Config.Camera and Config.Camera.Vehicle and Config.Camera.Vehicle.MinLeftRight or -120.0
local selfieMaxFOV = Config.Camera and Config.Camera.Selfie and Config.Camera.Selfie.MaxFOV or 80.0
local selfieDefaultFOV = Config.Camera and Config.Camera.Selfie and Config.Camera.Selfie.DefaultFOV or 60.0
local selfieMinFOV = Config.Camera and Config.Camera.Selfie and Config.Camera.Selfie.MinFOV or 50.0
local freezeEnabled = Config.Camera and Config.Camera.Freeze and Config.Camera.Freeze.Enabled == true
local freezeMaxDistance = Config.Camera and Config.Camera.Freeze and Config.Camera.Freeze.MaxDistance or 10.0
local freezeMaxTime = (Config.Camera and Config.Camera.Freeze and Config.Camera.Freeze.MaxTime or 60) * 1000
local selfieOffset = Config.Camera and Config.Camera.Selfie and Config.Camera.Selfie.Offset or vector3(0.1, 0.55, 0.6)
local selfieRotation = Config.Camera and Config.Camera.Selfie and Config.Camera.Selfie.Rotation or vector3(10.0, 0.0, -180.0)
local rollEnabled = Config.Camera and Config.Camera.Roll == true

-- Camera state variables
local rearCamOffset = vector3(0.0, 0.5, 0.6)
local pitchAngle = 0.0
local rollAngle = 0.0
local currentFOV = 60.0
local originalCamMode = 0
local vehicleRollAngle = 0.0
local isSelfieMode = false
local isMoving = false
local isFrozen = false
local freezeEndTime = 0
local playerPed = PlayerPedId()
local isRadioDisabled = false
local mouseSensitivity = 0.0
local lookSensitivity = GetProfileSetting(754) + 10
local currentZoom = 1.0
local camera = nil

-- Camera modes
local CameraModes = {
    REAR = 0,
    SELFIE = 1,
    IN_VEHICLE = 2
}
local currentCameraMode = CameraModes.REAR

-- Get FOV limits based on current camera mode
local function getFOVLimits()
    local inVehicle = IsPedInAnyVehicle(playerPed, true)
    
    local maxFov = isSelfieMode and selfieMaxFOV or (inVehicle and vehicleMaxFOV or maxFOV)
    local minFov = isSelfieMode and selfieMinFOV or (inVehicle and vehicleZoomEnabled and vehicleMinFOV or (inVehicle and vehicleMaxFOV or minFOV))
    local defaultFov = isSelfieMode and selfieDefaultFOV or (inVehicle and vehicleDefaultFOV or defaultFOV)
    
    return maxFov, minFov, defaultFov
end

-- Convert FOV to zoom level
function ConvertFovToZoom(fov)
    local maxFov, minFov, defaultFov = getFOVLimits()
    local clampedFOV = math.clamp(fov, minFov, maxFov)
    
    if clampedFOV == defaultFov then
        return 1.0
    elseif defaultFov > clampedFOV then
        if clampedFOV <= 0 then
            return 1.0
        end
        return defaultFov / clampedFOV
    else
        local ratio = (clampedFOV - defaultFov) / (maxFov - defaultFov)
        return 1.0 - (ratio * 0.5)
    end
end

-- Convert zoom level to FOV
local function convertZoomToFOV(zoom)
    local maxFov, minFov, defaultFov = getFOVLimits()
    
    local maxZoom = 1.0
    if defaultFov < maxFov then
        maxZoom = 0.5
    end
    
    local minZoom = 1.0
    if minFov < defaultFov and minFov > 0 then
        minZoom = defaultFov / minFov
    end
    
    local clampedZoom = math.clamp(zoom, maxZoom, minZoom)
    
    if clampedZoom == 1.0 then
        return defaultFov
    elseif clampedZoom > 1.0 then
        return defaultFov / clampedZoom
    else
        local ratio = (1.0 - clampedZoom) * 2.0
        return defaultFov + (ratio * (maxFov - defaultFov))
    end
end

-- Update zoom levels for UI
local function updateZoomLevels()
    local maxFov, minFov, defaultFov = getFOVLimits()
    local maxZoomLevel = ConvertFovToZoom(maxFov)
    local minZoomLevel = ConvertFovToZoom(minFov)
    
    local zoomLevels = {1.0}
    
    if maxZoomLevel < 1.0 then
        table.insert(zoomLevels, 1, maxZoomLevel)
    end
    
    if minZoomLevel > 2.0 then
        table.insert(zoomLevels, 2)
    end
    
    if minZoomLevel > 5.0 then
        table.insert(zoomLevels, 5)
    elseif minZoomLevel > 3.0 then
        table.insert(zoomLevels, 3)
    end
    
    SendReactMessage("camera:setZoomLevels", zoomLevels)
end

-- Set camera zoom level
function SetCameraZoom(zoom)
    currentFOV = convertZoomToFOV(zoom)
end

-- Main camera update function
local function updateCamera()
    local inVehicle = IsPedInAnyVehicle(playerPed, true)
    
    -- Determine camera mode
    local newCameraMode = isSelfieMode and CameraModes.SELFIE or CameraModes.REAR
    if inVehicle then
        newCameraMode = newCameraMode | CameraModes.IN_VEHICLE
    end
    
    -- Handle camera mode changes
    if currentCameraMode ~= newCameraMode then
        local maxFov, minFov, defaultFov = getFOVLimits()
        currentCameraMode = newCameraMode
        currentFOV = defaultFov
        
        debugprint("Camera mode changed to: " .. currentCameraMode)
        updateZoomLevels()
        SetCamFov(camera, currentFOV)
    end
    
    -- Check if player is moving
    isMoving = IsDisabledControlPressed(0, 33) or IsDisabledControlPressed(0, 34) or 
               (IsDisabledControlPressed(0, 35) and not inVehicle)
    
    -- Disable default camera controls
    SetFollowPedCamViewMode(0)
    SetGameplayCamRelativeHeading(0.0)
    
    -- Disable various control actions
    DisableControlAction(0, 1, true)   -- Look left/right
    DisableControlAction(0, 14, true)  -- Weapon wheel
    DisableControlAction(0, 15, true)  -- Weapon wheel
    DisableControlAction(0, 16, true)  -- Select next weapon
    DisableControlAction(0, 17, true)  -- Select prev weapon
    DisableControlAction(0, 99, true)  -- VEH_SELECT_NEXT_WEAPON
    DisableControlAction(0, 100, true) -- VEH_SELECT_PREV_WEAPON
    DisableControlAction(0, 115, true) -- VEH_FLY_SELECT_NEXT_WEAPON
    DisableControlAction(0, 116, true) -- VEH_FLY_SELECT_PREV_WEAPON
    DisableControlAction(0, 261, true) -- INPUT_VEH_MELEE_LEFT
    DisableControlAction(0, 262, true) -- INPUT_VEH_MELEE_RIGHT
    
    SetPedResetFlag(playerPed, 47, true)
    
    -- Handle frozen camera
    if isFrozen and not inVehicle then
        local playerCoords = GetEntityCoords(playerPed)
        local camCoords = GetCamCoord(camera)
        local distance = #(playerCoords - camCoords)
        
        if distance > freezeMaxDistance or GetGameTimer() > freezeEndTime then
            isFrozen = false
            TogglePhoneAnimation(true, "camera")
        end
        return
    end
    
    -- Disable sprint if not allowed
    if not allowRunning then
        DisableControlAction(0, 21, true)
    end
    
    -- Position camera based on mode
    if isSelfieMode and not inVehicle then
        AttachCamToPedBone_2(camera, playerPed, 0, 
            selfieRotation.x + pitchAngle, selfieRotation.y, selfieRotation.z,
            selfieOffset.x, selfieOffset.y, selfieOffset.z, true)
    elseif not isSelfieMode and not inVehicle then
        local camPos = GetOffsetFromEntityInWorldCoords(playerPed, rearCamOffset.x, rearCamOffset.y, rearCamOffset.z)
        local headCoords = GetPedBoneCoords(playerPed, 31086, 0.0, 0.0, 0.0)
        
        -- Adjust Z coordinate based on head position
        local zCoord = math.abs(headCoords.z - camPos.z) > 0.2 and headCoords.z or camPos.z
        
        DetachCam(camera)
        SetCamCoord(camera, camPos.x, camPos.y, zCoord)
        SetCamRot(camera, pitchAngle, rollAngle, GetEntityHeading(playerPed), 2)
    elseif isSelfieMode and inVehicle then
        AttachCamToPedBone_2(camera, playerPed, 0, 
            80.0 + pitchAngle, 0.0, -180.0,
            0.0, 0.2, 0.5, true)
    elseif not isSelfieMode and inVehicle then
        SetEntityLocallyInvisible(GetPhoneObject())
        SetEntityLocallyInvisible(playerPed)
        AttachCamToPedBone_2(camera, playerPed, GetPedBoneIndex(playerPed, 11816),
            pitchAngle, 0.0, vehicleRollAngle,
            0.0, 0.0, 0.55, true)
    end
    
    -- Handle vehicle radio
    if inVehicle then
        if not isRadioDisabled then
            isRadioDisabled = true
            SetUserRadioControlEnabled(false)
        end
    else
        if isRadioDisabled then
            isRadioDisabled = false
            SetUserRadioControlEnabled(true)
        end
        vehicleRollAngle = 0.0
    end
    
    -- Handle movement controls
    if isMoving then
        SetPedResetFlag(playerPed, 69, true)
    else
        if not isSelfieMode and not inVehicle then
            DisableControlAction(0, 30, true) -- Move left/right
        end
    end
    
    -- Update FOV limits and clamp current FOV
    local maxFov, minFov = getFOVLimits()
    currentFOV = math.clamp(currentFOV, minFov, maxFov)
    
    -- Update zoom display
    local currentCamFOV = GetCamFov(camera)
    local displayZoom = math.round(ConvertFovToZoom(currentCamFOV), 1)
    
    if displayZoom ~= currentZoom then
        debugprint("Zoom changed to: " .. displayZoom, ConvertFovToZoom(currentCamFOV), currentCamFOV)
        currentZoom = displayZoom
        SendReactMessage("camera:setZoom", displayZoom)
    end
    
    -- Smooth FOV transition
    if math.abs(currentFOV - currentCamFOV) > 0.05 then
        SetCamFov(camera, currentCamFOV + ((currentFOV - currentCamFOV) / 25))
    end
    
    -- Skip input handling if NUI is focused
    if IsNuiFocused() then
        return
    end
    
    -- Calculate look sensitivity
    lookSensitivity = (GetProfileSetting(754) + 10) * (currentFOV / maxFOV) / 5
    
    -- Handle horizontal look
    local horizontalInput = GetDisabledControlNormal(0, 1)
    if inVehicle then
        vehicleRollAngle = math.clamp(vehicleRollAngle - (horizontalInput * lookSensitivity), 
                                     vehicleMinLeftRight, vehicleMaxLeftRight)
    elseif horizontalInput ~= 0.0 then
        SetEntityHeading(playerPed, GetEntityHeading(playerPed) - (horizontalInput * lookSensitivity))
    end
    
    -- Handle zoom controls
    if IsDisabledControlPressed(0, 180) then -- Zoom in
        currentFOV = currentFOV + 5
    elseif IsDisabledControlPressed(0, 181) then -- Zoom out
        currentFOV = currentFOV - 5
    end
    
    -- Handle vertical look
    local verticalInput = GetDisabledControlNormal(0, 2)
    if verticalInput ~= 0.0 then
        local pitchChange = verticalInput * lookSensitivity
        if inVehicle then
            pitchAngle = math.clamp(pitchAngle - pitchChange, vehicleMaxLookDown, vehicleMaxLookUp)
        else
            pitchAngle = math.clamp(pitchAngle - pitchChange, maxLookDown, maxLookUp)
        end
    end
end

-- Handle look controls when frozen or moving
local function handleLookControls()
    local horizontalInput = GetDisabledControlNormal(0, 1)
    if horizontalInput ~= 0.0 then
        SetEntityHeading(playerPed, GetEntityHeading(playerPed) - (horizontalInput * lookSensitivity))
    end
end

-- Enable walkable camera
function EnableWalkableCam(selfieMode)
    if camera then
        return
    end
    
    isSelfieMode = selfieMode == true
    isMoving = false
    currentFOV = isSelfieMode and selfieDefaultFOV or defaultFOV
    playerPed = PlayerPedId()
    originalCamMode = GetFollowPedCamViewMode()
    pitchAngle = 0.0
    vehicleRollAngle = 0.0
    rollAngle = 0.0
    isFrozen = false
    
    camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    lookSensitivity = GetProfileSetting(754) + 10
    currentZoom = 1.0
    
    SetPhoneAction("camera")
    
    -- Create movement handling thread
    CreateThread(function()
        while camera do
            Wait(0)
            if isMoving or isFrozen then
                if not IsNuiFocused() then
                    handleLookControls()
                end
            end
        end
    end)
    
    -- Create main camera update thread
    CreateThread(function()
        while camera do
            Wait(0)
            updateCamera()
        end
        
        -- Cleanup radio state
        if isRadioDisabled then
            isRadioDisabled = false
            SetUserRadioControlEnabled(true)
        end
    end)
    
    SetCamFov(camera, currentFOV)
    RenderScriptCams(true, false, 0, true, true)
    SetCamActive(camera, true)
    SendReactMessage("camera:setZoom", 1.0)
    updateZoomLevels()
end

-- Disable walkable camera
function DisableWalkableCam()
    if not camera then
        return
    end
    
    RenderScriptCams(false, false, 0, true, true)
    DestroyCam(camera, false)
    SetFollowPedCamViewMode(originalCamMode)
    SetPhoneAction(IsInCall() and "call" or "default")
    camera = nil
    
    if isFrozen then
        TogglePhoneAnimation(true, "camera")
    end
end

-- Toggle selfie camera mode
function ToggleSelfieCam(enabled)
    local wasSelfieModeEnabled = isSelfieMode
    isSelfieMode = enabled == true
    
    if wasSelfieModeEnabled ~= isSelfieMode then
        rollAngle = 0.0
        pitchAngle = 0.0
    end
end

-- Toggle camera freeze
function ToggleCameraFrozen()
    if not freezeEnabled or not camera or isSelfieMode then
        return
    end
    
    local newFrozenState = not isFrozen
    if newFrozenState then
        TogglePhoneAnimation(false, "camera")
        freezeEndTime = GetGameTimer() + freezeMaxTime
    end
    isFrozen = newFrozenState
end

-- Check if walking camera is enabled
function IsWalkingCamEnabled()
    return camera ~= nil
end

-- Check if in selfie mode
function IsSelfieCam()
    return isSelfieMode
end

-- Handle key press events
AddEventHandler("lb-phone:keyPressed", function(key)
    if not camera then
        return
    end
    
    if key == "FreezeCamera" then
        if not freezeEnabled or isSelfieMode then
            return
        end
        ToggleCameraFrozen()
    elseif key == "RollLeft" or key == "RollRight" then
        if not rollEnabled then
            return
        end
        
        local rollDirection = key == "RollLeft" and -0.5 or 0.5
        local keyBind = Config.KeyBinds[key].bindData
        
        while keyBind.pressed do
            Wait(0)
            rollAngle = rollAngle + rollDirection
        end
    end
end)

-- Export functions
exports("EnableWalkableCam", EnableWalkableCam)
exports("DisableWalkableCam", DisableWalkableCam)
exports("ToggleSelfieCam", ToggleSelfieCam)
exports("ToggleCameraFrozen", ToggleCameraFrozen)
exports("IsWalkingCamEnabled", IsWalkingCamEnabled)
exports("IsSelfieCam", IsSelfieCam)
