local glm = require("glm")

Cameras = {}

function Cameras.CamEaseIn(camera, targetData, startData, duration, rotationOrder, bezierCurve, callback)
    local startTime = GetGameTimer()
    local startCoords = startData.coords
    local startRot = startData.rot
    local startFov = startData.fov
    local currentTime = startTime
    local endTime = startTime + duration
    local multiplier = 1.0
    
    local coordDelta = {
        x = targetData.coords.x - startCoords.x,
        y = targetData.coords.y - startCoords.y,
        z = math.floor((targetData.coords.z - startCoords.z) * 1000) / 1000
    }
    
    local rotDelta = {
        x = targetData.rot.x - startRot.x,
        y = targetData.rot.y - startRot.y,
        z = targetData.rot.z - startRot.z
    }
    
    local fovDelta = targetData.fov - startFov
    
    local currentData = {
        coord = startCoords,
        rot = startRot,
        fov = startFov
    }
    
    local rotXDist = shortestAngularDistance(currentData.rot.x, targetData.rot.x)
    local rotYDist = shortestAngularDistance(currentData.rot.y, targetData.rot.y)
    local rotZDist = shortestAngularDistance(currentData.rot.z, targetData.rot.z)
    
    Citizen.CreateThread(function()
        while currentTime < endTime do
            local progress = (currentTime - startTime) / duration
            
            local bezier1 = (bezierCurve and bezierCurve[1]) or 0
            local bezier2 = (bezierCurve and bezierCurve[2]) or 0.5
            local bezier3 = (bezierCurve and bezierCurve[3]) or 1
            local bezier4 = (bezierCurve and bezierCurve[4]) or 1
            
            local easedProgress = cubicBezier(progress, bezier1, bezier2, bezier3, bezier4)
            local adjustedProgress = easedProgress * multiplier
            
            local newCoords = vector3(
                coordDelta.x * adjustedProgress + currentData.coord.x,
                coordDelta.y * adjustedProgress + currentData.coord.y,
                math.floor((coordDelta.z * adjustedProgress + currentData.coord.z) * 1000) / 1000
            )
            
            local newRot = vector3(
                smoothTransition(currentData.rot.x, rotXDist, adjustedProgress),
                smoothTransition(currentData.rot.y, rotYDist, adjustedProgress),
                smoothTransition(currentData.rot.z, rotZDist, adjustedProgress)
            )
            
            local newFov = fovDelta * adjustedProgress + currentData.fov
            
            SetCamCoord(camera, newCoords)
            SetCamRot(camera, newRot, rotationOrder)
            SetCamFov(camera, newFov)
            
            currentTime = GetGameTimer()
            Wait(0)
        end
        
        if callback ~= nil then
            callback()
        end
    end)
end

function Cameras.CamEaseInFly(camera, targetData, startData, duration, rotationOrder, bezierCurve, callback)
    local startTime = GetGameTimer()
    local startCoords = startData.coords
    local startRot = startData.rot
    local startFov = startData.fov
    local currentTime = startTime
    local endTime = startTime + duration
    local multiplier = 1.0
    
    local coordDelta = {
        x = targetData.coords.x - startCoords.x,
        y = targetData.coords.y - startCoords.y,
        z = math.floor((targetData.coords.z - startCoords.z) * 1000) / 1000
    }
    
    local rotDelta = {
        x = targetData.rot.x - startRot.x,
        y = targetData.rot.y - startRot.y,
        z = targetData.rot.z - startRot.z
    }
    
    local fovDelta = targetData.fov - startFov
    
    local currentData = {
        coord = startCoords,
        rot = startRot,
        fov = startFov
    }
    
    local rotXDist = shortestAngularDistance(currentData.rot.x, targetData.rot.x)
    local rotYDist = shortestAngularDistance(currentData.rot.y, targetData.rot.y)
    local rotZDist = shortestAngularDistance(currentData.rot.z, targetData.rot.z)
    
    Citizen.CreateThread(function()
        while currentTime < endTime do
            local progress = (currentTime - startTime) / duration
            
            local bezier1 = (bezierCurve and bezierCurve[1]) or 0
            local bezier2 = (bezierCurve and bezierCurve[2]) or 0.5
            local bezier3 = (bezierCurve and bezierCurve[3]) or 1
            local bezier4 = (bezierCurve and bezierCurve[4]) or 1
            
            local easedProgress = cubicBezier(progress, bezier1, bezier2, bezier3, bezier4)
            local adjustedProgress = easedProgress * multiplier
            
            local newCoords = vector3(
                coordDelta.x * adjustedProgress + currentData.coord.x,
                coordDelta.y * adjustedProgress + currentData.coord.y,
                math.floor((coordDelta.z * adjustedProgress + currentData.coord.z) * 1000) / 1000
            )
            
            local newRot = vector3(
                smoothTransition(currentData.rot.x, rotXDist, adjustedProgress),
                smoothTransition(currentData.rot.y, rotYDist, adjustedProgress),
                smoothTransition(currentData.rot.z, rotZDist, adjustedProgress)
            )
            
            local newFov = fovDelta * adjustedProgress + currentData.fov
            
            SetFlyCamCoordAndConstrain(camera, newCoords)
            SetCamRot(camera, newRot, rotationOrder)
            SetCamFov(camera, newFov)
            
            currentTime = GetGameTimer()
            Wait(0)
        end
        
        if callback ~= nil then
            callback()
        end
    end)
end

function Cameras.CamEaseCoord(camera, targetCoords, startCoords, duration, bezierCurve, callback)
    local startTime = GetGameTimer()
    local currentTime = startTime
    local endTime = startTime + duration
    local multiplier = 1.0
    
    local coordDelta = {
        x = targetCoords.x - startCoords.x,
        y = targetCoords.y - startCoords.y,
        z = math.floor((targetCoords.z - startCoords.z) * 1000) / 1000
    }
    
    local currentData = {
        coord = startCoords
    }
    
    Citizen.CreateThread(function()
        while currentTime < endTime do
            local progress = (currentTime - startTime) / duration
            
            local bezier1 = (bezierCurve and bezierCurve[1]) or 0
            local bezier2 = (bezierCurve and bezierCurve[2]) or 0.5
            local bezier3 = (bezierCurve and bezierCurve[3]) or 1
            local bezier4 = (bezierCurve and bezierCurve[4]) or 1
            
            local easedProgress = cubicBezier(progress, bezier1, bezier2, bezier3, bezier4)
            local adjustedProgress = easedProgress * multiplier
            
            local newCoords = vector3(
                coordDelta.x * adjustedProgress + currentData.coord.x,
                coordDelta.y * adjustedProgress + currentData.coord.y,
                math.floor((coordDelta.z * adjustedProgress + currentData.coord.z) * 1000) / 1000
            )
            
            SetCamCoord(camera, newCoords)
            
            currentTime = GetGameTimer()
            Wait(0)
        end
        
        if callback ~= nil then
            callback()
        end
    end)
end

function Cameras.CamEaseRot(camera, targetRot, startRot, duration, rotationOrder, callback, bezierCurve)
    local startTime = GetGameTimer()
    local currentTime = startTime
    local endTime = startTime + duration
    local multiplier = 1.0
    
    local rotDelta = {
        x = targetRot.x - startRot.x,
        y = targetRot.y - startRot.y,
        z = targetRot.z - startRot.z
    }
    
    local currentData = {
        rot = startRot
    }
    
    local rotXDist = shortestAngularDistance(startRot.x, targetRot.x)
    local rotYDist = shortestAngularDistance(startRot.y, targetRot.y)
    local rotZDist = shortestAngularDistance(startRot.z, targetRot.z)
    
    Citizen.CreateThread(function()
        while currentTime < endTime do
            local progress = (currentTime - startTime) / duration
            
            local bezier1 = (bezierCurve and bezierCurve[1]) or 0
            local bezier2 = (bezierCurve and bezierCurve[2]) or 0.5
            local bezier3 = (bezierCurve and bezierCurve[3]) or 1
            local bezier4 = (bezierCurve and bezierCurve[4]) or 1
            
            local easedProgress = cubicBezier(progress, bezier1, bezier2, bezier3, bezier4)
            local adjustedProgress = easedProgress * multiplier
            
            local newRot = vector3(
                smoothTransition(startRot.x, rotXDist, adjustedProgress),
                smoothTransition(startRot.y, rotYDist, adjustedProgress),
                smoothTransition(startRot.z, rotZDist, adjustedProgress)
            )
            
            SetCamRot(camera, newRot, rotationOrder)
            
            currentTime = GetGameTimer()
            Wait(0)
        end
        
        if callback ~= nil then
            callback()
        end
    end)
end

function Cameras.AsyncEaseIn(camera, targetData, startData, duration, rotationOrder, bezierCurve, callback)
    local startTime = GetGameTimer()
    local startCoords = startData.coords
    local startRot = startData.rot
    local startFov = startData.fov
    local currentTime = startTime
    local endTime = startTime + duration
    local multiplier = 1.0
    
    local coordDelta = {
        x = targetData.coords.x - startCoords.x,
        y = targetData.coords.y - startCoords.y,
        z = math.floor((targetData.coords.z - startCoords.z) * 1000) / 1000
    }
    
    local rotDelta = {
        x = targetData.rot.x - startRot.x,
        y = targetData.rot.y - startRot.y,
        z = targetData.rot.z - startRot.z
    }
    
    local fovDelta = targetData.fov - startFov
    
    local currentData = {
        coord = startCoords,
        rot = startRot,
        fov = startFov
    }
    
    local rotXDist = shortestAngularDistance(currentData.rot.x, targetData.rot.x)
    local rotYDist = shortestAngularDistance(currentData.rot.y, targetData.rot.y)
    local rotZDist = shortestAngularDistance(currentData.rot.z, targetData.rot.z)
    
    while currentTime < endTime do
        local progress = (currentTime - startTime) / duration
        
        local bezier1 = (bezierCurve and bezierCurve[1]) or 0
        local bezier2 = (bezierCurve and bezierCurve[2]) or 0.5
        local bezier3 = (bezierCurve and bezierCurve[3]) or 1
        local bezier4 = (bezierCurve and bezierCurve[4]) or 1
        
        local easedProgress = cubicBezier(progress, bezier1, bezier2, bezier3, bezier4)
        local adjustedProgress = easedProgress * multiplier
        
        local newCoords = vector3(
            coordDelta.x * adjustedProgress + currentData.coord.x,
            coordDelta.y * adjustedProgress + currentData.coord.y,
            math.floor((coordDelta.z * adjustedProgress + currentData.coord.z) * 1000) / 1000
        )
        
        local newRot = vector3(
            smoothTransition(currentData.rot.x, rotXDist, adjustedProgress),
            smoothTransition(currentData.rot.y, rotYDist, adjustedProgress),
            smoothTransition(currentData.rot.z, rotZDist, adjustedProgress)
        )
        
        local newFov = fovDelta * adjustedProgress + currentData.fov
        
        SetCamCoord(camera, newCoords)
        SetCamRot(camera, newRot, rotationOrder)
        SetCamFov(camera, newFov)
        
        currentTime = GetGameTimer()
        Wait(0)
    end
    
    if callback ~= nil then
        callback()
    end
end

function Cameras.HandleScreens(screenPosition, isActive, screenName)
    local playerPed = PlayerPedId()
    
    if screenPosition == "left" then
        if isActive then
            local leftOffset = GetOffsetFromEntityInWorldCoords(playerPed, -2.0, 5.0, 0.0)
            
            if screenName then
                NUI.HandleScreen(screenName, isActive)
            end
            
            Cameras.CamEaseIn(
                Entity.Vars.MainCamera,
                {
                    coords = leftOffset,
                    rot = GetCamRot(Entity.Vars.MainCamera, 2),
                    fov = GetCamFov(Entity.Vars.MainCamera)
                },
                {
                    coords = GetCamCoord(Entity.Vars.MainCamera),
                    rot = GetCamRot(Entity.Vars.MainCamera, 2),
                    fov = GetCamFov(Entity.Vars.MainCamera)
                },
                700,
                2,
                nil,
                function()
                    WorkerAfterSettingsInitiated()
                end
            )
        else
            if screenName then
                NUI.HandleScreen(screenName, isActive)
            end
            
            Cameras.CamEaseIn(
                Entity.Vars.MainCamera,
                {
                    coords = Entity.Vars.BaseData.coords,
                    rot = Entity.Vars.BaseData.rot,
                    fov = GetCamFov(Entity.Vars.MainCamera)
                },
                {
                    coords = GetCamCoord(Entity.Vars.MainCamera),
                    rot = GetCamRot(Entity.Vars.MainCamera, 2),
                    fov = GetCamFov(Entity.Vars.MainCamera)
                },
                700,
                2,
                nil,
                function()
                    WorkerAfterSettingsUnloaded()
                end
            )
        end
    elseif screenPosition == "center" then
        if isActive then
            if screenName then
                NUI.HandleScreen(screenName, isActive)
            end
            
            Cameras.CamEaseIn(
                Entity.Vars.MainCamera,
                {
                    coords = Entity.Vars.BaseData.centerData.coords,
                    rot = Entity.Vars.BaseData.centerData.rot,
                    fov = GetCamFov(Entity.Vars.MainCamera)
                },
                {
                    coords = GetCamCoord(Entity.Vars.MainCamera),
                    rot = GetCamRot(Entity.Vars.MainCamera, 2),
                    fov = GetCamFov(Entity.Vars.MainCamera)
                },
                700,
                2,
                nil
            )
        else
            if screenName then
                NUI.HandleScreen(screenName, isActive)
            end
            
            Cameras.CamEaseIn(
                Entity.Vars.MainCamera,
                {
                    coords = Entity.Vars.BaseData.coords,
                    rot = Entity.Vars.BaseData.rot,
                    fov = GetCamFov(Entity.Vars.MainCamera)
                },
                {
                    coords = GetCamCoord(Entity.Vars.MainCamera),
                    rot = GetCamRot(Entity.Vars.MainCamera, 2),
                    fov = GetCamFov(Entity.Vars.MainCamera)
                },
                700,
                2,
                nil
            )
        end
    end
end

function Cameras.HandleMotionBlur(enable)
    if enable then
        Citizen.CreateThread(function()
            local startTime = GetGameTimer()
            local currentTime = startTime
            local duration = 2000
            local endTime = startTime + duration
            local startStrength = 0.0
            local targetFarDof = 30.0
            local farDofDelta = targetFarDof - 12.3
            
            while currentTime < endTime do
                local progress = (currentTime - startTime) / duration
                local newStrength = startStrength + (3.8 * progress)
                local newFarDof = targetFarDof - (farDofDelta * progress)
                
                SetCamFarDof(Entity.Vars.MainCamera, newFarDof)
                SetCamDofStrength(Entity.Vars.MainCamera, newStrength)
                
                currentTime = GetGameTimer()
                Citizen.Wait(0)
            end
        end)
    else
        Citizen.CreateThread(function()
            local startTime = GetGameTimer()
            local currentTime = startTime
            local duration = 2000
            local endTime = startTime + duration
            local startStrength = GetCamDofStrength(Entity.Vars.MainCamera)
            local startFarDof = GetCamFarDof(Entity.Vars.MainCamera)
            
            while currentTime < endTime do
                local progress = (currentTime - startTime) / duration
                local newStrength = startStrength - (startStrength * progress)
                local targetFarDof = 10.0
                
                SetCamFarDof(Entity.Vars.MainCamera, targetFarDof)
                SetCamDofStrength(Entity.Vars.MainCamera, newStrength)
                
                currentTime = GetGameTimer()
                Citizen.Wait(0)
            end
        end)
    end
end

function Cameras.GetBasicQuaterion(angle1, angle2)
    local angleDiff = angle1 - angle2
    local quaternion = quat(vec(0, 1, 0), angleDiff)
    return quaternion
end

local upVector = glm.vec3(0, 0, 1)
local yAxisVector = glm.vec3(0, 1, 0)

Cameras._prevQuat = nil

local function quaternionDot(quat1, quat2)
    return quat1.w * quat2.w + quat1.x * quat2.x + quat1.y * quat2.y + quat1.z * quat2.z
end

function Cameras.GetEulerRotationsFromCoords(fromCoords, toCoords, xOffset, yOffset, zOffset, useBasicMethod)
    xOffset = xOffset or 0.0
    yOffset = yOffset or false
    zOffset = zOffset or 0.0
    
    if useBasicMethod then
        local direction = fromCoords - toCoords
        local quaternion = quat(vec(0, 1, 0), direction)
        local eulerAngles = glm.deg(glm.eulerAngles(quaternion))
        
        local rotX = ((eulerAngles.x + 180 + xOffset) % 360) - 180
        local rotY = yOffset and ((eulerAngles.y + yOffset) % 360) or 0.0
        local rotZ = ((eulerAngles.z + 180 + zOffset) % 360) - 180
        
        return glm.vec3(rotX, rotY, rotZ)
    else
        local forward = glm.normalize(fromCoords - toCoords)
        local right = glm.normalize(glm.cross(forward, upVector))
        
        if glm.length(right) < 0.0001 then
            right = glm.vec3(1, 0, 0)
        end
        
        local up = glm.cross(right, forward)
        local rotationMatrix = glm.mat3(right, forward, up)
        local quaternion = glm.quat_cast(rotationMatrix)
        
        if Cameras._prevQuat then
            if quaternionDot(Cameras._prevQuat, quaternion) < 0 then
                quaternion = -quaternion
            end
        end
        
        Cameras._prevQuat = quaternion
        
        local eulerAngles = glm.deg(glm.eulerAngles(quaternion))
        
        local rotX = ((eulerAngles.x + 180 + xOffset) % 360) - 180
        local rotY = yOffset and ((eulerAngles.y + yOffset) % 360) or 0.0
        local rotZ = ((eulerAngles.z + 180 + zOffset) % 360) - 180
        
        return glm.vec3(rotX, rotY, rotZ)
    end
end

Cameras.Data = {}
Cameras.Data.Anim = Config.Cameras[1]

function Cameras.CreateRuntimeForAnimations()
    local playerPed = PlayerPedId()
    
    local rotOffsetCoords = GetOffsetFromEntityInWorldCoords(
        playerPed,
        Config.CameraOffsets.rot.x,
        Config.CameraOffsets.rot.y,
        Config.CameraOffsets.rot.z
    )
    
    local animOffsetCoords = GetOffsetFromEntityInWorldCoords(
        playerPed,
        Cameras.Data.Anim.offsets.x,
        Cameras.Data.Anim.offsets.y,
        Cameras.Data.Anim.offsets.z
    )
    
    local rotation = Cameras.GetEulerRotationsFromCoords(
        rotOffsetCoords,
        animOffsetCoords,
        Cameras.Data.Anim.rotations.x,
        Cameras.Data.Anim.rotations.y,
        Cameras.Data.Anim.rotations.z
    )
    
    return animOffsetCoords, rotation
end

Cameras.CanUseAnimationCam = true

function Cameras.PlayAnimationCam()
    if not Cameras.CanUseAnimationCam then
        return
    end
    
    Cameras.CanUseAnimationCam = false
    local playerPed = PlayerPedId()
    
    local rotOffsetCoords = GetOffsetFromEntityInWorldCoords(
        playerPed,
        Config.CameraOffsets.rot.x,
        Config.CameraOffsets.rot.y,
        Config.CameraOffsets.rot.z
    )
    
    local animCoords, animRot = Cameras.CreateRuntimeForAnimations()
    
    local baseCoords = GetOffsetFromEntityInWorldCoords(
        playerPed,
        Config.CameraOffsets.coords.x,
        Config.CameraOffsets.coords.y,
        Config.CameraOffsets.coords.z
    )
    
    local baseRot = Cameras.GetEulerRotationsFromCoords(rotOffsetCoords, baseCoords)
    
    Cameras.CamEaseIn(
        Entity.Vars.MainCamera,
        {
            coords = baseCoords,
            rot = baseRot,
            fov = Config.CameraFOV
        },
        {
            coords = animCoords,
            rot = animRot,
            fov = GetCamFov(Entity.Vars.MainCamera)
        },
        5000,
        2,
        nil,
        function()
            Cameras.CanUseAnimationCam = true
        end
    )
end

-- Utility function: Cubic Bezier easing
function cubicBezier(t, p0, p1, p2, p3)
    local oneMinusT = 1 - t
    local tSquared = t * t
    local oneMinusTSquared = oneMinusT * oneMinusT
    local oneMinusTCubed = oneMinusTSquared * oneMinusT
    local tCubed = tSquared * t
    
    return (oneMinusTCubed * p0) + 
           (3 * oneMinusTSquared * t * p1) + 
           (3 * oneMinusT * tSquared * p2) + 
           (tCubed * p3)
end

-- Utility function: Calculate shortest angular distance between two angles
function shortestAngularDistance(angle1, angle2)
    local diff = angle2 - angle1
    local normalized = (diff + 180) % 360
    return normalized - 180
end

-- Utility function: Smooth transition between angles
function smoothTransition(startAngle, angularDistance, progress)
    local targetAngle = startAngle + angularDistance
    local distance = shortestAngularDistance(startAngle, targetAngle)
    return startAngle + (distance * progress)
end
