-- Record Nearby Voices functionality for LB Phone
-- Handles voice recording and proximity-based voice chat for nearby players

local GetEntityCoords = GetEntityCoords
local nearbyVoices = {}

-- Update nearby voices list based on proximity
local function updateNearbyVoices()
    local newVoices = {}
    local nearbyPlayers = GetNearbyPlayers()
    local playerCoords = GetEntityCoords(PlayerPedId())
    
    for i = 1, #nearbyPlayers do
        local player = nearbyPlayers[i]
        local playerState = Player(player.source).state
        local listeningPeerId = playerState and playerState.listeningPeerId
        
        if listeningPeerId then
            local playerPedCoords = GetEntityCoords(player.ped)
            local distance = #(playerCoords - playerPedCoords)
            
            -- Only include players within 25 units
            if distance <= 25.0 then
                local voiceData = {
                    source = player.source,
                    ped = player.ped,
                    channel = playerState.listeningPeerId
                }
                
                -- Check if this player was already in the list to preserve volume
                for j = 1, #nearbyVoices do
                    local existingVoice = nearbyVoices[j]
                    if existingVoice.source == player.source then
                        voiceData.volume = existingVoice.volume
                        break
                    end
                end
                
                -- Set initial volume if not found in existing list
                if not voiceData.volume then
                    voiceData.volume = GetVoiceVolume(distance)
                    SendReactMessage("voice:joinChannel", {
                        channel = playerState.listeningPeerId,
                        volume = GetVoiceVolume(distance)
                    })
                end
                
                newVoices[#newVoices + 1] = voiceData
            end
        end
    end
    
    nearbyVoices = newVoices
end

-- Update voice volumes based on distance changes
local function updateVoiceVolumes()
    local playerCoords = GetEntityCoords(PlayerPedId())
    
    for i = 1, #nearbyVoices do
        local voice = nearbyVoices[i]
        local voicePedCoords = GetEntityCoords(voice.ped)
        local distance = #(playerCoords - voicePedCoords)
        local newVolume = GetVoiceVolume(distance)
        
        -- Update volume if it changed
        if newVolume ~= voice.volume then
            voice.volume = newVolume
            SendReactMessage("voice:setVolume", {
                channel = voice.channel,
                volume = newVolume
            })
        end
    end
end

-- Exit early if RecordNearby is disabled
if not Config.Voice.RecordNearby then
    return
end

-- Thread to update nearby voices list
CreateThread(function()
    while true do
        Wait(1000)
        updateNearbyVoices()
    end
end)

-- Thread to update voice volumes
CreateThread(function()
    while true do
        if #nearbyVoices > 0 then
            updateVoiceVolumes()
            Wait(50)
        else
            Wait(500)
        end
    end
end)

-- Handle when a player starts listening (from server)
RegisterNetEvent("phone:startedListening", function(source, channel)
    local playerId = GetPlayerFromServerId(source)
    
    -- Validate player
    if not playerId or playerId == PlayerId() or playerId == -1 then
        return
    end
    
    local playerPed = PlayerPedId()
    local otherPlayerPed = GetPlayerPed(playerId)
    local playerCoords = GetEntityCoords(playerPed)
    local otherPlayerCoords = GetEntityCoords(otherPlayerPed)
    local distance = #(playerCoords - otherPlayerCoords)
    
    -- Check if player exists, is not self, and is within range
    if not DoesEntityExist(otherPlayerPed) or otherPlayerPed == playerPed or distance > 25.0 then
        return
    end
    
    -- Check if already in list
    for i = 1, #nearbyVoices do
        local voice = nearbyVoices[i]
        if voice.source == source then
            return
        end
    end
    
    -- Add to nearby voices list
    nearbyVoices[#nearbyVoices + 1] = {
        source = source,
        ped = otherPlayerPed,
        channel = channel,
        volume = GetVoiceVolume(distance)
    }
    
    -- Notify UI
    SendReactMessage("voice:joinChannel", {
        channel = channel,
        volume = GetVoiceVolume(distance)
    })
end)

-- Handle when a player stops listening (from server)
RegisterNetEvent("phone:stoppedListening", function(channel)
    SendReactMessage("voice:leaveChannel", channel)
end)

-- Handle setting listening peer ID from UI
RegisterNUICallback("setListeningPeerId", function(data, callback)
    TriggerServerEvent("phone:setListeningPeerId", data)
    callback("ok")
end)

-- Handle voice config request from UI
RegisterNUICallback("voice:getConfig", function(data, callback)
    callback({
        recordNearbyVoices = Config.Voice.RecordNearby,
        rtc = Config.RTCConfig
    })
end)
