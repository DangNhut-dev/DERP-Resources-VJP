
Locations = {
    CurrentLocation = "last",
    Data = {},
    Camera = false,
    UseThread = false
}

-- Initialize locations selection
function Locations.Init()
    NUI.UsageOfKeydowns(false)
    
    local ped = PlayerPedId()
    local gameplayCamCoords = GetGameplayCamCoord()
    local gameplayCamRot = GetGameplayCamRot(2)
    local entityCoords = GetEntityCoords(ped)
    
    local camPosForward = GetOffsetFromEntityInWorldCoords(ped, Config.CameraOffsets.coords.x, 0.0, 5.0, false, false, false, true)
    local camPosAbove = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, 4.0)
    
    local camRotation = Cameras.GetEulerRotationsFromCoords(
        GetOffsetFromEntityInWorldCoords(ped, Config.CameraOffsets.coords.x, 0.0, -5.0),
        camPosForward,
        false,
        false,
        false,
        true
    )
    
    local highAltitudeCoords = vector3(gameplayCamCoords.x, gameplayCamCoords.y, 3020.0)
    local mainCamRot = GetCamRot(Entity.Vars.MainCamera, 2)
    
    -- Find closest location to player
    local closest = {
        key = false,
        diffrence = false
    }
    
    for key, location in pairs(Locations.Data) do
        if location.coords then
            location.visible = true
            
            local locationPos = vector2(location.coords.x, location.coords.y)
            local playerPos = vector2(camPosAbove.x, camPosAbove.y)
            local distance = #(locationPos - playerPos)
            
            if closest.diffrence then
                if distance < closest.diffrence then
                    closest.key = key
                    closest.diffrence = distance
                end
            else
                closest.key = key
                closest.diffrence = distance
            end
            
            -- Hide locations too close to last location
            if Locations.Data.last.coords and key ~= "last" then
                local locPos = vector2(location.coords.x, location.coords.y)
                local lastPos = vector2(Locations.Data.last.coords.x, Locations.Data.last.coords.y)
                local distanceToLast = #(locPos - lastPos)
                
                if distanceToLast < 25.0 then
                    location.visible = false
                end
            end
        end
    end
    
    TriggerEvent("DERP-multicharacter:Listener:LocationsInitializing")
    WorkerBeforeLocationsInitialization()
    
    Locations.Data[closest.key].active = true
    NUI.Init(false)
    SetNuiFocus(true, true)
    Locations.Thread()
    
    local mainCamFov = GetCamFov(Entity.Vars.MainCamera)
    NUI.PlaySFX("FX_WIND_1")
    
    Cameras.CamEaseIn(
        Entity.Vars.MainCamera,
        {
            coords = camPosAbove,
            rot = vector3(camRotation.x, camRotation.y, mainCamRot.z),
            fov = GetCamFov(Entity.Vars.MainCamera)
        },
        {
            coords = GetCamCoord(Entity.Vars.MainCamera),
            rot = mainCamRot,
            fov = GetCamFov(Entity.Vars.MainCamera)
        },
        800,
        2,
        nil,
        function()
            NUI.PlaySFX("FX_WIND_2")
            
            Citizen.CreateThread(function()
                Filters.Disable(1000)
            end)
            
            NUI.Music("VOLUME_DOWN")
            
            local mainCamCoords = GetCamCoord(Entity.Vars.MainCamera)
            local mainCamRot = GetCamRot(Entity.Vars.MainCamera, 2)
            
            Locations.Camera = CreateCamWithParams(
                "DEFAULT_SCRIPTED_FLY_CAMERA",
                mainCamCoords,
                vector3(-90.0, 90.0, 0.0),
                GetCamFov(Entity.Vars.MainCamera),
                false,
                2
            )
            
            SetFlyCamCoordAndConstrain(Locations.Camera, mainCamCoords.x, mainCamCoords.y, mainCamCoords.z)
            SetCamActive(Locations.Camera, true)
            SetFlyCamMaxHeight(Locations.Camera, 1020.0)
            RenderScriptCams(true, true)
            
            SendNUIMessage({
                type = "LOCATIONS_INIT",
                state = true,
                locations = Locations.Data
            })
            
            Locations.Data[closest.key].active = false
            
            Cameras.CamEaseInFly(
                Locations.Camera,
                {
                    coords = vector3(entityCoords.x, entityCoords.y, 820.0),
                    rot = vector3(camRotation.x, camRotation.y, mainCamRot.z),
                    fov = 85.0
                },
                {
                    coords = GetCamCoord(Locations.Camera),
                    rot = mainCamRot,
                    fov = mainCamFov
                },
                3000,
                2,
                nil,
                function()
                    WorkerAfterLocationsAreInitialized()
                    NUI.UsageOfKeydowns(true)
                end
            )
        end
    )
    
    SetNuiFocus(true, true)
end

-- Set locations data manually
function Locations.SetDataManually(data, merge)
    local backup = Locations.Data
    
    if merge then
        for key, location in pairs(data) do
            if not Locations.Data[key] then
                Locations.Data[key] = location
            end
        end
    else
        Locations.Data = data
    end
    
    -- Validate that last location exists
    if not Locations.Data.last then
        Locations.Data = backup
        debugPrint("Could not manually overwrite the locations data. You need to use the function after player finishes loading! Replacing the object with original one [/]")
        return
    end
    
    SendNUIMessage({
        type = "SET_PLAYER_LOCATIONS_MANUALLY",
        locations = Locations.Data
    })
end

-- Set locations disabled state
function Locations.SetLocationsDisabled(state)
    SendNUIMessage({
        type = "OVERRIDE_LOCATIONS_STATE",
        state = state
    })
end

-- Change player coordinates to selected location
function Locations.ChangeCoords(locationKey)
    local coords = Locations.Data[locationKey].coords
    Locations.CurrentLocation = locationKey
    
    World.PrepareCoords(coords)
    SetEntityCoords(PlayerPedId(), coords)
    World.AlgorithmFailuresCount = 0
    World.EntityOnGround(coords)
    Algorithms.CheckHeading()
end

-- Disable locations selection
function Locations.Disable(locationKey)
    NUI.UsageOfKeydowns(false)
    
    -- Update character position if location was selected
    if locationKey ~= "noneSelected" then
        local currentLocation = Locations.Data[Locations.CurrentLocation]
        Entity.Vars.currentCharacter.position = {
            x = currentLocation.coords.x,
            y = currentLocation.coords.y,
            z = currentLocation.coords.z,
            heading = 0.0
        }
    else
        locationKey = Locations.CurrentLocation
    end
    
    Locations.ChangeCoords(locationKey)
    
    local locationCamCoord = GetCamCoord(Locations.Camera)
    local entityCoords = GetEntityCoords(PlayerPedId())
    
    WorkerBeforeLocationsUnload()
    
    -- Async ease camera back to entity
    Cameras.AsyncEaseIn(
        Locations.Camera,
        {
            coords = vector3(entityCoords.x, entityCoords.y, locationCamCoord.z),
            rot = GetCamRot(Locations.Camera, 2),
            fov = GetCamFov(Locations.Camera)
        },
        {
            coords = GetCamCoord(Locations.Camera),
            rot = GetCamRot(Locations.Camera, 2),
            fov = GetCamFov(Locations.Camera)
        },
        1000,
        2,
        nil
    )
    
    NUI.PlaySFX("FX_WIND_2")
    
    local ped = PlayerPedId()
    local rotOffset = GetOffsetFromEntityInWorldCoords(ped, Config.CameraOffsets.rot.x, Config.CameraOffsets.rot.y, Config.CameraOffsets.rot.z)
    local coordsOffset = GetOffsetFromEntityInWorldCoords(ped, Config.CameraOffsets.coords.x, Config.CameraOffsets.coords.y, Config.CameraOffsets.coords.z)
    local targetRotation = Cameras.GetEulerRotationsFromCoords(rotOffset, coordsOffset, false, false, false, false)
    
    local aboveOffset = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, 4.0)
    local lookRotation = Cameras.GetEulerRotationsFromCoords(
        GetOffsetFromEntityInWorldCoords(ped, Config.CameraOffsets.coords.x, 0.0, -5.0),
        GetOffsetFromEntityInWorldCoords(ped, Config.CameraOffsets.coords.x, 0.0, 5.0),
        false,
        false,
        false,
        true
    )
    
    local locationCamFov = GetCamFov(Locations.Camera)
    local locationCamRot = GetCamRot(Locations.Camera, 2)
    
    SendNUIMessage({
        type = "LOCATIONS_INIT",
        state = false
    })
    
    Cameras.CamEaseInFly(
        Locations.Camera,
        {
            coords = aboveOffset,
            rot = vector3(lookRotation.x, lookRotation.y, targetRotation.z),
            fov = Config.CameraFOV
        },
        {
            coords = GetCamCoord(Locations.Camera),
            rot = GetCamRot(Locations.Camera, 2),
            fov = locationCamFov
        },
        2000,
        2,
        nil,
        function()
            Filters.Init(1000)
            
            local finalCamCoord = GetCamCoord(Locations.Camera)
            SetCamCoord(Entity.Vars.MainCamera, finalCamCoord)
            SetCamRot(Entity.Vars.MainCamera, lookRotation, 2)
            SetCamActive(Entity.Vars.MainCamera, true)
            RenderScriptCams(true, true)
            NUI.PlaySFX("FX_WIND_1")
            
            Cameras.CamEaseIn(
                Entity.Vars.MainCamera,
                {
                    coords = coordsOffset,
                    rot = targetRotation,
                    fov = Config.CameraFOV
                },
                {
                    coords = finalCamCoord,
                    rot = vector3(lookRotation.x, lookRotation.y, targetRotation.z),
                    fov = Config.CameraFOV
                },
                700,
                2,
                nil,
                function()
                    Locations.UseThread = false
                    TriggerEvent("DERP-multicharacter:Listener:LocationsDisabled")
                    WorkerAfterLocationsUnload()
                    NUI.UsageOfKeydowns(true)
                    DestroyCam(Locations.Camera)
                    NUI.Init(true)
                    NUI.Music("VOLUME_UP")
                    
                    Entity.Vars.BaseData.coords = GetCamCoord(Entity.Vars.MainCamera)
                    Entity.Vars.BaseData.rot = GetCamRot(Entity.Vars.MainCamera, 2)
                    Cameras.HandleMotionBlur(true)
                end
            )
        end
    )
end

-- Update location positions on screen (render thread)
function Locations.Thread()
    Locations.UseThread = true
    
    Citizen.CreateThread(function()
        while Locations.UseThread do
            -- Set clear weather
            SetCloudsAlpha(0.0)
            SetWeatherTypePersist("CLEAR")
            SetWeatherTypeNowPersist("CLEAR")
            SetWeatherTypeNow("CLEAR")
            SetOverrideWeather("CLEAR")
            
            -- Update each location's screen position
            for key, location in pairs(Locations.Data) do
                local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(
                    location.coords.x,
                    location.coords.y,
                    location.coords.z,
                    1.0,
                    1.0
                )
                
                SendNUIMessage({
                    type = "UPDATE_LOCATION",
                    data = {
                        onScreen = onScreen,
                        key = key,
                        screen = {
                            x = screenX * 100,
                            y = screenY * 100
                        }
                    }
                })
            end
            
            Wait(0)
        end
    end)
end

-- NUI Callback: Handle location click
RegisterNUICallback("handleLocationClick", function(data, cb)
    local locationKey = data.key
    local locationData = Locations.Data[locationKey]
    
    if locationData then
        local coords = locationData.coords
        local currentCamCoord = GetCamCoord(Locations.Camera)
        
        Cameras.CamEaseIn(
            Locations.Camera,
            {
                coords = vector3(coords.x, coords.y, currentCamCoord.z),
                rot = GetCamRot(Locations.Camera, 2),
                fov = GetCamFov(Locations.Camera)
            },
            {
                coords = GetCamCoord(Locations.Camera),
                rot = GetCamRot(Locations.Camera, 2),
                fov = GetCamFov(Locations.Camera)
            },
            1000,
            2,
            {0, 0, 1, 1},
            function()
                TriggerEvent("DERP-multicharacter:Listener:ChangedLocation", coords)
                cb("OK")
            end
        )
    end
end)

-- NUI Callback: Initialize locations
RegisterNUICallback("locationsInit", function()
    Locations.Init()
end)

-- NUI Callback: Disable locations
RegisterNUICallback("locationsDisable", function(data)
    Locations.Disable(data.key)
end)
