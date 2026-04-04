Identity = {
    Cam = false,
    AwaitingID = false
}

-- Show identity screen
function Identity.Show()
    SendNUIMessage({
        type = "SHOW_IDENTITY",
        state = true
    })
    
    StartAudioScene("DEATH_SCENE")
    SetNuiFocus(true, true)
end

-- Identity animation sequence
function Identity.Anim(characterName, gender, callbacks, useClothingTimer)
    SetNuiFocus(false, false)
    
    -- Hide UI if active
    if UserInterfaceActive then
        exports.ZSX_UI:HideUI(true)
    end
    
    HandleHud(true)
    
    -- Disable controls during animation
    local controlsDisabled = true
    Citizen.CreateThread(function()
        while controlsDisabled do
            DisableAllControlActions(0)
            Wait(0)
        end
    end)
    
    Cameras.HandleMotionBlur(false)
    Cinematics.Show(true)
    
    local ped = PlayerPedId()
    
    -- Spawn player at spawn coords if configured
    if Config.Identity.SpawnPlayerAtSpawnCoords then
        World.PrepareCoords(Config.SpawnCoords.coords)
        
        -- Wait until player is at spawn coords
        while #(GetEntityCoords(PlayerPedId()) - Config.SpawnCoords.coords) > 10.0 do
            World.PrepareCoords(Config.SpawnCoords.coords)
            Wait(0)
        end
        
        SetEntityHeading(ped, Config.SpawnCoords.heading)
    end

    -- Set default skin based on gender
    Framework.SetSkin(nil, gender == "male")

    TriggerServerEvent('apartments:server:CreateApartmentOnly', 'apartment', 'Apartment')

    Wait(2000)
    
    if FrameworkSelected == "ESX" then
        TriggerEvent("playerSpawned")
    end
    
    Wait(500)
    
    -- Switch player bucket if not configured otherwise
    if not Config.Identity.SwitchPlayerBucketOnLoad and not Config.Identity.SetInBucketOnAppearance then
        TriggerServerEvent("DERP-multicharacter:Event:SetPlayerState", "LOG_IN_USER")
    end
    
    callbacks.onPlayerSwitchState()
    Wait(250)
    
    -- Destroy entity main camera if it exists
    if DoesCamExist(Entity.Vars.MainCamera) then
        DestroyCam(Entity.Vars.MainCamera)
        DestroyCam(Entity.Vars.MainCamera, true)
        Entity.Vars.MainCamera = false
    end
    
    -- Use camera animation if configured
    if Config.Identity.UseCameraAnimation then
        local ped = PlayerPedId()
        local camPos1 = GetOffsetFromEntityInWorldCoords(ped, -4.0, 5.0, 0.7)
        local camPos2 = GetOffsetFromEntityInWorldCoords(ped, -2.0, 5.0, 1.3)
        local camRot = Cameras.GetEulerRotationsFromCoords(camPos2, camPos1)
        
        Identity.Cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", camPos1, camRot, 20.0, true, 2)
        SetCamActive(Identity.Cam, true)
        RenderScriptCams(true, true)
    end
    
    DisableDispatch()
    SetGameplayCamRelativeRotation(0.0, 0.0, 0.0)
    SetGameplayCamRelativePitch(0.0, 1.0)
    Wait(500)
    
    if Config.Identity.UseCameraAnimation then
        callbacks.onCameraAnimationStart()
        
        Citizen.CreateThread(function()
            Wait(2500)
            Cinematics.SetText(true, characterName)
            Wait(3500)
            
            Citizen.CreateThread(function()
                Filters.Disable(1500)
            end)
            
            FX.LoadBucketAnim()
            Entity.DisabledControlsOn = false
            NUI.Music("STOP")
            Wait(1900)
            Cinematics.Show(false)
        end)
        
        local gameplayCamCoords = GetGameplayCamCoord()
        local gameplayCamRot = GetGameplayCamRot(2)
        local gameplayCamFov = GetGameplayCamFov()
        
        StopAudioScene("DEATH_SCENE")
        
        Cameras.CamEaseIn(
            Identity.Cam,
            {
                coords = gameplayCamCoords,
                rot = gameplayCamRot,
                fov = gameplayCamFov
            },
            {
                coords = GetCamCoord(Identity.Cam),
                rot = GetCamRot(Identity.Cam),
                fov = GetCamFov(Identity.Cam)
            },
            8000,
            2,
            nil,
            function()
                TriggerEvent("DERP-multicharacter:Listener:MainFinishedWork")
                FreezeEntityPosition(PlayerPedId(), false)
                controlsDisabled = false
                DestroyCam(Identity.Cam)
                Identity.Cam = false
                RenderScriptCams(false)
                Cinematics.SetText(false)
                Wait(1500)
                SetPlayerInvincible(PlayerId(), 0)
                callbacks.onCameraAnimationEnd()
            end
        )
        if useClothingTimer then
            CreateThread(function()
                Wait(3500)
                Clothing.Timer(gender)
            end)
        end
    else
        Cinematics.Show(false)
        TriggerEvent("DERP-multicharacter:Listener:MainFinishedWork")
        controlsDisabled = false
        DestroyCam(Identity.Cam)
        Identity.Cam = false
        RenderScriptCams(false)
        Entity.DisabledControlsOn = false
        callbacks.onIdentityFinish()
        
        if useClothingTimer then
            Citizen.CreateThread(function()
                Wait(2000)
                Clothing.Timer(gender)
            end)
        end
    end
end

-- Register new player
function Identity.RegisterNewPlayer(data, callback)
    Framework.TriggerServerCallback("DERP-multicharacter:Create:Player", function(result)
        if FrameworkSelected == "ESX" then
            Citizen.CreateThread(function()
                Wait(1000)
                TriggerEvent("playerSpawned")
                TriggerServerEvent("esx:onPlayerSpawn")
                TriggerEvent("esx:onPlayerSpawn")
                TriggerEvent("esx:restoreLoadout")
            end)
        end
        
        callback(result)
    end, data)
end

-- Check if name is available
function Identity.CheckNameAvailability(firstName, lastName, callback)
    if not Config.IdentityDuplicateCheck then
        callback(true)
        return
    end
    
    Framework.TriggerServerCallback("DERP-multicharacter:CheckNameAvailability", function(isAvailable)
        callback(isAvailable)
    end, firstName, lastName)
end

-- NUI Callback: Check name availability
RegisterNUICallback("checkNameAvailability", function(data, cb)
    Identity.CheckNameAvailability(data.firstName, data.lastName, function(isAvailable)
        cb(isAvailable)
    end)
end)

-- NUI Callback: User identity created
RegisterNUICallback("userIdentityCreated", function(data, cb)
    ConfigIdentity.PlayerRegistered(data, function()
        cb(true)
    end)
end)

-- Track if identity is being created
local isCreatingIdentity = false

-- NUI Callback: Create new character
RegisterNUICallback("createNewCharacter", function(data, cb)
    Identity.AwaitingID = data.id
    isCreatingIdentity = true
    ConfigIdentity.ShowIdentity()
end)

-- NUI Callback: Go back from identity
RegisterNUICallback("goBackFromIdentity", function(data, cb)
    if not isCreatingIdentity then
        return cb(false)
    end
    
    isCreatingIdentity = false
    cb(true)
    Entity.Cam(true)
    StopAudioScene("DEATH_SCENE")
end)

-- Cinematics system
Cinematics = {}

-- Show/hide cinematics
function Cinematics.Show(state)
    SendNUIMessage({
        type = "CINEMATICS_INIT",
        state = state
    })
end

-- Set cinematics text
function Cinematics.SetText(state, text)
    SendNUIMessage({
        type = "CINEMATICS_TEXT_BOX",
        state = state,
        text = text
    })
end

RegisterNetEvent('apartments:client:ApartmentCreated', function(apartmentId, apartmentType)
    _G.PendingApartmentId = apartmentId
    _G.PendingApartmentType = apartmentType
end)