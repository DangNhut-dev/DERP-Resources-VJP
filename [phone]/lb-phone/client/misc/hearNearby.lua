-- Hear Nearby functionality for LB Phone
-- Handles proximity-based voice chat for Instagram Live streams and phone calls

-- Exit early if HearNearby is disabled
if not Config.Voice.HearNearby then
    return
end

local liveStreamProximity = {}
local listeningToPlayers = {}
local callProximityPlayers = {}

-- Handle entering Instagram Live stream proximity
local function enterLiveProximity(liveId)
    if not liveStreamProximity[liveId] then
        liveStreamProximity[liveId] = true
        debugprint("entered live", liveId)
        TriggerServerEvent("phone:instagram:enteredLiveProximity", liveId)
    end
end

-- Handle leaving Instagram Live stream proximity
local function leaveLiveProximity(liveId)
    if liveStreamProximity[liveId] then
        liveStreamProximity[liveId] = nil
        debugprint("left live 1", liveId)
        TriggerServerEvent("phone:instagram:leftLiveProximity", liveId)
    end
end

-- Handle Instagram Live stream ending
RegisterNetEvent("phone:instagram:endLive", function(liveId, phoneNumber)
    if not phoneNumber then
        liveStreamProximity[liveId] = nil
        debugprint("left live 2", liveId)
        return
    end
    
    if liveStreamProximity[liveId] then
        liveStreamProximity[liveId] = nil
        TriggerServerEvent("phone:instagram:leftLiveProximity", phoneNumber, true)
    end
end)

-- Start listening to a player's voice
local function startListeningToPlayer(phoneNumber)
    if not phoneNumber or table.contains(listeningToPlayers, phoneNumber) then
        return
    end
    
    debugprint("started listening to", phoneNumber)
    TriggerServerEvent("phone:phone:listenToPlayer", phoneNumber)
    listeningToPlayers[#listeningToPlayers + 1] = phoneNumber
    return true
end

-- Stop listening to a player's voice
local function stopListeningToPlayer(phoneNumber)
    if not phoneNumber then
        return
    end
    
    local isListening, index = table.contains(listeningToPlayers, phoneNumber)
    if not isListening then
        return
    end
    
    debugprint("stopped listening to", phoneNumber)
    TriggerServerEvent("phone:phone:stopListeningToPlayer", phoneNumber)
    table.remove(listeningToPlayers, index)
    return true
end

-- Handle leaving call proximity (start talking to nearby player)
local function leaveCallProximity(source)
    if not source then
        return
    end
    
    local isInProximity, index = table.contains(callProximityPlayers, source)
    if not isInProximity then
        return
    end
    
    debugprint("started talking to", source)
    TriggerServerEvent("phone:phone:leftCallProximity", source)
    table.remove(callProximityPlayers, index)
    return true
end

-- Handle entering call proximity (stop talking to nearby player)
local function enterCallProximity(source)
    if not source or table.contains(callProximityPlayers, source) then
        return
    end
    
    debugprint("stopped talking to", source)
    TriggerServerEvent("phone:phone:enteredCallProximity", source)
    callProximityPlayers[#callProximityPlayers + 1] = source
    return true
end

-- Main proximity detection loop
while true do
    Wait(250)
    
    local nearbyPlayers = GetNearbyPlayers()
    local playerCoords = GetEntityCoords(PlayerPedId())
    
    for i = 1, #nearbyPlayers do
        local player = nearbyPlayers[i]
        local playerState = Player(player.source).state
        
        -- Check for active phone call with speakerphone
        local isOnCall = playerState.onCallWith and playerState.speakerphone and playerState.callAnswered
        
        -- Check for Instagram Live stream
        local isLiveStreaming = playerState.instapicIsLive
        
        local playerPedCoords = GetEntityCoords(player.ped)
        local distance = #(playerCoords - playerPedCoords)
        
        -- Handle proximity-based interactions (within 5 units)
        if distance <= 5 then
            -- Handle Instagram Live stream proximity
            if isLiveStreaming then
                enterLiveProximity(isLiveStreaming)
            end
            
            -- Handle phone call proximity
            if isOnCall then
                if playerState.otherMutedCall then
                    -- Other player is muted, start listening to the call target
                    if stopListeningToPlayer(playerState.onCallWith) then
                        if not playerState.mutedCall then
                            TriggerServerEvent("phone:phone:enteredCallProximity", player.source)
                        end
                    end
                else
                    -- Normal call, start listening to call target
                    startListeningToPlayer(playerState.onCallWith)
                end
                
                if playerState.mutedCall then
                    -- Player is muted, handle call proximity
                    if leaveCallProximity(player.source) then
                        if not playerState.otherMutedCall then
                            TriggerServerEvent("phone:phone:listenToPlayer", playerState.onCallWith)
                        end
                    end
                else
                    -- Player not muted, enter call proximity
                    enterCallProximity(player.source)
                end
            else
                -- Player not on call, clean up any existing connections
                if playerState.onCallWith then
                    stopListeningToPlayer(playerState.onCallWith)
                    leaveCallProximity(player.source)
                end
            end
        else
            -- Player is too far away, clean up connections
            if isLiveStreaming then
                leaveLiveProximity(isLiveStreaming)
            else
                if playerState.onCallWith then
                    stopListeningToPlayer(playerState.onCallWith)
                    leaveCallProximity(player.source)
                end
            end
        end
    end
end
