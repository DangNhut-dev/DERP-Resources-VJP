-- Flashlight functionality for LB Phone
-- Handles phone flashlight toggle and synchronized flashlight rendering for nearby players

flashlightEnabled = false

-- Default flashlight drawing function if not already defined
if not DrawFlashlight then
    function DrawFlashlight(ped)
        local boneCoords = GetPedBoneCoords(ped, 28422, 0.5, 0.0, 0.0)
        local forwardVector = GetEntityForwardVector(ped)
        
        -- Draw main flashlight beam
        DrawSpotLightWithShadow(
            boneCoords.x, boneCoords.y, boneCoords.z,
            forwardVector.x, forwardVector.y, forwardVector.z,
            255, 255, 255, -- RGB color
            15.0, 3.0, 0.0, 50.0, 100.0, 1
        )
        
        -- Draw secondary wider beam
        DrawSpotLightWithShadow(
            boneCoords.x, boneCoords.y, boneCoords.z,
            forwardVector.x, forwardVector.y, forwardVector.z,
            255, 255, 255, -- RGB color
            30.0, 10.0, 0.0, 20.0, 25.0, 1
        )
    end
end

-- Toggle flashlight on/off
local function toggleFlashlight(enabled)
    local wasEnabled = flashlightEnabled
    flashlightEnabled = enabled == true
    
    -- Don't trigger if state hasn't changed
    if flashlightEnabled == wasEnabled then
        return
    end
    
    -- Sync flashlight state with server
    TriggerServerEvent("phone:toggleFlashlight", flashlightEnabled)
    
    -- Start flashlight rendering thread if enabled
    if flashlightEnabled then
        Citizen.CreateThreadNow(function()
            local playerPed = PlayerPedId()
            
            while flashlightEnabled do
                if phoneOpen then
                    DrawFlashlight(playerPed)
                else
                    Wait(500)
                end
                Wait(0)
            end
        end)
    end
end

-- Handle flashlight toggle from UI
RegisterNUICallback("toggleFlashlight", function(data, callback)
    toggleFlashlight(data.toggled)
    
    SetTimeout(100, function()
        callback(flashlightEnabled)
    end)
end)

-- Export function to toggle flashlight
exports("ToggleFlashlight", function(enabled)
    if not phoneOpen then
        return
    end
    
    toggleFlashlight(enabled)
    SendReactMessage("toggleFlashlight", flashlightEnabled)
end)

-- Export function to get flashlight state
exports("GetFlashlight", function()
    return flashlightEnabled == true
end)

-- Synchronized flashlight rendering for nearby players
if not Config.SyncFlash then
    return
end

local nearbyFlashlights = {}
local isDrawingFlashlights = false

-- Start flashlight drawing thread
local function startFlashlightDrawing()
    if isDrawingFlashlights then
        return
    end
    
    isDrawingFlashlights = true
    
    Citizen.CreateThreadNow(function()
        debugprint("Started drawing flashlights")
        
        while isDrawingFlashlights do
            -- Draw all nearby flashlights
            for i = 1, #nearbyFlashlights do
                DrawFlashlight(nearbyFlashlights[i])
            end
            Wait(0)
        end
        
        debugprint("Stopped drawing flashlights")
    end)
end

-- Handle flashlight state changes from other players
AddStateBagChangeHandler("flashlight", nil, function(bagName, key, value, reserved, replicated)
    local playerId = GetPlayerFromStateBagName(bagName)
    
    -- Ignore own flashlight or invalid players
    if not playerId or playerId == 0 or playerId == PlayerId() then
        return
    end
    
    local playerPed = GetPlayerPed(playerId)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local otherPlayerCoords = GetEntityCoords(playerPed)
    local distance = #(playerCoords - otherPlayerCoords)
    
    -- Only sync flashlights within 30 units
    if distance > 30.0 then
        return
    end
    
    local isInList, index = table.contains(nearbyFlashlights, playerPed)
    
    -- Add to list if flashlight enabled and not already in list
    if not isInList and value then
        nearbyFlashlights[#nearbyFlashlights + 1] = playerPed
    -- Remove from list if flashlight disabled and in list
    elseif isInList and not value then
        table.remove(nearbyFlashlights, index)
    end
    
    -- Start or stop drawing thread based on list size
    if #nearbyFlashlights > 0 then
        startFlashlightDrawing()
    else
        isDrawingFlashlights = false
    end
end)

-- Periodic cleanup and refresh of nearby flashlights
CreateThread(function()
    while true do
        -- Clear the list periodically
        if #nearbyFlashlights > 0 then
            table.wipe(nearbyFlashlights)
        end
        
        local playerCoords = GetEntityCoords(PlayerPedId())
        local nearbyPlayers = GetNearbyPlayers()
        
        -- Check all nearby players for active flashlights
        for i = 1, #nearbyPlayers do
            local player = nearbyPlayers[i]
            local playerState = Player(player.source).state
            
            if playerState.flashlight and playerState.phoneOpen then
                local otherPlayerCoords = GetEntityCoords(player.ped)
                local distance = #(playerCoords - otherPlayerCoords)
                
                if distance <= 30.0 then
                    nearbyFlashlights[#nearbyFlashlights + 1] = player.ped
                end
            end
        end
        
        -- Start or stop drawing thread based on list size
        if #nearbyFlashlights > 0 then
            startFlashlightDrawing()
        else
            isDrawingFlashlights = false
        end
        
        Wait(1000)
    end
end)
