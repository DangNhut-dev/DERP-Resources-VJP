if not Config.Voice.RecordNearby then
    return
end

local nearbyPlayers = {}
local updateInterval = nil

local function calculateVolume(distance)
    local maxDistance = GetVoiceMaxDistance()
    if distance <= 0 then
        return 1.0
    elseif distance >= maxDistance then
        return 0.0
    end
    local volume = 1 - (distance / maxDistance)
    volume = volume ^ 2
    return math.floor(volume * 100) / 100
end

local function updateVolumes()
    local playerCoords = GetEntityCoords(PlayerPedId())
    for _, player in ipairs(nearbyPlayers) do
        local pedCoords = GetEntityCoords(player.ped)
        local distance = #(playerCoords - pedCoords)
        local volume = calculateVolume(distance)
        if volume ~= player.volume then
            player.volume = volume
            SendReactMessage("voice:setVolume", { channel = player.channel, volume = volume })
        end
    end
end

local function updateNearbyPlayers()
    local newNearby = {}
    local players = GetNearbyPlayers()
    local playerCoords = GetEntityCoords(PlayerPedId())

    for _, player in ipairs(players) do
        local state = Player(player.source).state
        if state and state.lbTabletListeningPeerId then
            local pedCoords = GetEntityCoords(player.ped)
            local distance = #(playerCoords - pedCoords)
            if distance <= 25.0 then
                local newPlayer = {
                    source = player.source,
                    ped = player.ped,
                    channel = state.lbTabletListeningPeerId
                }
                table.insert(newNearby, newPlayer)

                for _, existing in ipairs(nearbyPlayers) do
                    if existing.source == player.source then
                        newPlayer.volume = existing.volume
                        goto continue
                    end
                end
                newPlayer.volume = calculateVolume(distance)
                SendReactMessage("voice:joinChannel", { channel = newPlayer.channel, volume = newPlayer.volume })
                ::continue::
            end
        end
    end

    nearbyPlayers = newNearby

    if #nearbyPlayers > 0 and not updateInterval then
        updateInterval = SetInterval(updateVolumes, 50)
    elseif #nearbyPlayers == 0 and updateInterval then
        ClearInterval(updateInterval)
        updateInterval = nil
    end
end

SetInterval(updateNearbyPlayers, 1000)

RegisterNetEvent("tablet:startedListening", function(source, peerId)
    local player = GetPlayerFromServerId(source)
    if not player or player == PlayerId() or player == -1 then
        return
    end

    local localPed = PlayerPedId()
    local targetPed = GetPlayerPed(player)
    local localCoords = GetEntityCoords(localPed)
    local targetCoords = GetEntityCoords(targetPed)
    local distance = #(localCoords - targetCoords)

    if not DoesEntityExist(targetPed) or targetPed == localPed or distance > 25.0 then
        return
    end

    for i, existing in ipairs(nearbyPlayers) do
        if existing.source == source then
            if existing.channel == peerId then
                debugprint("tablet:startedListening: already listening", source, peerId)
                return
            end
            nearbyPlayers[i] = nil
            debugprint("tablet:startedListening: leaving channel", source, peerId)
            SendReactMessage("voice:leaveChannel", existing.channel)
            break
        end
    end

    table.insert(nearbyPlayers, {
        source = source,
        ped = targetPed,
        channel = peerId,
        volume = calculateVolume(distance)
    })

    SendReactMessage("voice:joinChannel", { channel = peerId, volume = calculateVolume(distance) })
end)

RegisterNetEvent("tablet:stoppedListening", function(peerId)
    debugprint("stoppedListening", peerId)
    SendReactMessage("voice:leaveChannel", peerId)
end)

ReactCallback("setListeningPeerId", function(peerId)
    TriggerServerEvent("tablet:setListeningPeerId", peerId)
end, "ok")

ReactCallback("voice:getConfig", function()
    return {
        RecordNearbyVoices = Config.Voice.RecordNearby,
        RTCConfig = Config.RTCConfig
    }
end)