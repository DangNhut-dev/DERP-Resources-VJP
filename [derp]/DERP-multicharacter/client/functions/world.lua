
InitialContent = {}

-- Show initial content screen
function InitialContent.Show(state, text)
    SendNUIMessage({
        type = "INITIAL_SCREEN_INIT",
        state = state,
        text = GetPlayerName(PlayerId())
    })
end

-- Auto-initialization thread
Citizen.CreateThread(function()
    -- Wait for network to be active
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(0)
    end
    
    -- Disable spawnmanager auto-spawn if active
    if GetResourceState("spawnmanager") == "started" then
        exports.spawnmanager:setAutoSpawn(false)
    end
    
    -- Skip if custom initialization is enabled
    if Config.CustomInitialization then
        return
    end
    
    -- Skip if UIV2 auto-handle is enabled
    if IsUIV2Active and Config.AutoHandleUIV2 then
        return
    end
    
    InitializeMulticharacter()
end)

-- Initialize multicharacter system
function InitializeMulticharacter()
    Client.HandlePreWarmup()
    
    local frameworkName = false
    
    debugPrint("Awaiting framework [/]")
    
    -- Wait for framework to load
    if FrameworkSelected == "ESX" then
        while not ESX do
            Wait(0)
        end
        frameworkName = "ESX"
    elseif FrameworkSelected == "QBCore" then
        while not QBCore do
            Wait(0)
        end
        frameworkName = "QBCore"
    end
    
    debugPrint("Framework [" .. frameworkName .. "] loaded!")
    
    NUI.SendUserConfig()
    
    debugPrint("Awaiting storage data [/]")
    
    -- Wait for storage data
    while not Storage.Data do
        Wait(0)
    end
    
    debugPrint("Storage data loaded!")
    
    -- Check if player is already active
    local p = promise.new()
    local isPlayerActive = false
    
    Framework.TriggerServerCallback("DERP-multicharacter:IsPlayerActive", function(result)
        isPlayerActive = result
        p:resolve()
        debugPrint("Player checked, continue [/]")
    end)
    
    debugPrint("Checking if player is active [/]")
    Citizen.Await(p)
    
    if isPlayerActive then
        debugPrint("Player was already loaded. Skipping.")
        return
    end
    
    SetEntityCoords(PlayerPedId(), Config.SpawnCoords.coords)
    
    Framework.TriggerServerCallback("DERP-multicharacter:Get:CharactersExists", function(hasCharacters)
        DisplayRadar(false)
        TriggerEvent("DERP-multicharacter:Listener:MainInitialized")
        
        if hasCharacters then
            debugPrint("Main Initialize [/]")
            Entity.Cam(true)
        else
            debugPrint("Creator Initialize [/]")
            TriggerServerEvent("DERP-multicharacter:Event:SetPlayerState", "LOG_OFF_USER")
            DoScreenFadeOut(100)
            Wait(1250)
            
            -- Wait for music to be ready
            while not Music.Ready do
                Wait(0)
            end
            
            -- Handle UIV2 if configured to start before
            if UserInterfaceActive and Config.UserInterface == "START_BEFORE" then
                Wait(500)
                debugPrint("Starting Interface on \"START_BEFORE\"")
                exports.ZSX_UI:InitializeMulticharacter()
                
                while not exports.ZSX_UI:GetUIState("Game") do
                    Wait(0)
                end
                
                debugPrint("Game Ready continue")
            end
            
            NUI.Music("START")
            
            if UserInterfaceActive then
                exports.ZSX_UI:HideUI(true)
            end
            
            HandleHud(true)
            InitialContent.Show(true)
            Wait(6500)
            InitialContent.Show(false)
            Wait(3500)
            ConfigIdentity.ShowIdentity()
            Wait(1000)
            DoScreenFadeIn(100)
        end
    end)
end

-- Export initialize function
exports("Initialize", InitializeMulticharacter)

World = {
    canSwapCoords = true,
    AlgorithmFailuresCount = 0,
    HeadingAlgorithmFailures = 0,
    DistanceAlgorithmFailures = 0
}

-- Prevent coordinate swapping
function World.PreventSwapCoords(state)
    World.canSwapCoords = state
end

-- Prepare coordinates with collision loading
function World.PrepareCoords(coords)
    debugPrint("Checking for collisions [/]")
    
    FreezeEntityPosition(PlayerPedId(), true)
    SetPedCoordsKeepVehicle(PlayerPedId(), coords)
    
    NewLoadSceneStart(coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 50.0, 0)
    
    local startTime = GetGameTimer()
    
    -- Wait for network scene to load (max 5 seconds)
    while IsNetworkLoadingScene() do
        if (GetGameTimer() - startTime) > 5000 then
            break
        end
        Wait(0)
    end
    
    NewLoadSceneStop()
    SetPedCoordsKeepVehicle(PlayerPedId(), coords)
    
    startTime = GetGameTimer()
    
    -- Wait for collision to load (max 5 seconds)
    while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
        RequestCollisionAtCoord(coords)
        
        if (GetGameTimer() - startTime) > 5000 then
            break
        end
        
        Wait(0)
    end
    
    SetPedCoordsKeepVehicle(PlayerPedId(), coords)
    FreezeEntityPosition(PlayerPedId(), false)
    
    debugPrint("Collisions loaded")
    Wait(500)
end

-- Force entity to ground with fallback algorithms
function World.EntityOnGround(coords)
    NUI.InfoText(true, Translations.InfoText.preparing_z_coords)
    FreezeEntityPosition(PlayerPedId(), false)
    
    -- Check if algorithm has failed too many times
    if World.AlgorithmFailuresCount >= Config.MaxAmountOfCoordsChecks then
        World.AlgorithmFailuresCount = 0
        NUI.InfoText(false)
        debugPrint("Algorithm could not properly force the player coords. You may spawn in not exact coords as you supposed to be.")
        return
    end
    
    local needsAirCheck = true
    local heightAboveGround = GetEntityHeightAboveGround(PlayerPedId())
    
    -- Check if entity is in the air or below ground
    if heightAboveGround > 2.0 or heightAboveGround < 0.0 then
        debugPrint("Entity is in the air, forcing ground [/]")
        
        local foundGround, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 10.0, false)
        
        if not foundGround then
            -- Try to find safe coords
            local foundSafe, safeCoords = GetSafeCoordForPed(coords.x, coords.y, coords.z, true, 16)
            
            if not foundSafe then
                debugPrint("Could not find safe coords, finding road instead [/]")
                local roadFound, roadCoords, roadHeading = GetClosestRoad(coords.x, coords.y, coords.z, 1.0, 1, false)
                SetEntityCoords(PlayerPedId(), roadCoords)
                
                if roadFound ~= 1 then
                    debugPrint("Could not find road coords, setting Z coords instead [/]")
                    local foundGroundRetry, groundZRetry = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 10.0, true)
                    
                    if foundGroundRetry then
                        SetEntityCoords(PlayerPedId(), coords.x, coords.y, groundZRetry + 0.4)
                        Wait(100)
                        World.AlgorithmFailuresCount = World.AlgorithmFailuresCount + 1
                        return World.EntityOnGround(vector3(coords.x, coords.y, groundZRetry + 0.4))
                    end
                end
            else
                debugPrint("Found proper safe coords, setting it [/]")
                SetEntityCoords(PlayerPedId(), safeCoords)
            end
        else
            debugPrint("Found ground coords.")
            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
        end
    elseif IsEntityInWater(PlayerPedId()) then
        debugPrint("Entity is in water. Checking other coords [/]")
        local foundSafe, safeCoords = GetSafeCoordForPed(coords.x, coords.y, coords.z, true, 16)
        
        if not foundSafe then
            debugPrint("Could not find safe coords, finding road instead [/]")
            local roadFound, roadCoords, roadHeading = GetClosestRoad(coords.x, coords.y, coords.z, 1.0, 1, false)
            SetEntityCoords(PlayerPedId(), roadCoords)
            
            if roadFound ~= 1 then
                debugPrint("Could not find road coords, setting Z coords instead [/]")
                local foundGround, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, -1000.0, true)
                
                if foundGround then
                    SetEntityCoords(PlayerPedId(), coords.x, coords.y, groundZ + 0.4)
                    Wait(100)
                    World.AlgorithmFailuresCount = World.AlgorithmFailuresCount + 1
                    return World.EntityOnGround(vector3(coords.x, coords.y, groundZ + 0.4))
                end
            end
        else
            debugPrint("Found proper safe coords, setting it [/]")
            SetEntityCoords(PlayerPedId(), safeCoords)
        end
    else
        needsAirCheck = false
        debugPrint("Entity is not in the air so we skip that part")
    end
    
    -- Wait for entity to settle on ground
    if needsAirCheck then
        local startTime = GetGameTimer()
        local endTime = startTime + Config.AirCheckerDuration
        
        while GetEntityHeightAboveGround(PlayerPedId()) > 1.3 do
            if GetGameTimer() >= endTime then
                break
            end
            
            FreezeEntityPosition(PlayerPedId(), false)
            Wait(0)
        end
    end
    
    debugPrint("Entity has been set on ground properly")
end
