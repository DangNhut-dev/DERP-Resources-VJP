-- AirShare functionality for LB Phone
-- Handles sharing files/data between nearby devices (phones and tablets)

-- Get nearby players with open devices (phones or tablets)
local function getNearbyDevices()
    local nearbyDevices = {}
    local nearbyPlayers = GetNearbyPlayers()
    local playerCoords = GetEntityCoords(PlayerPedId())
    
    debugprint("Nearby players:", nearbyPlayers)
    
    for i = 1, #nearbyPlayers do
        local player = nearbyPlayers[i]
        local playerState = Player(player.source).state
        
        debugprint("Player data", player.source, player)
        
        local playerPedCoords = GetEntityCoords(player.ped)
        local distance = #(playerCoords - playerPedCoords)
        
        -- Only include players within 7.5 units
        if distance <= 7.5 then
            -- Check if player has tablet open
            if playerState.lbTabletOpen and playerState.lbTabletName then
                nearbyDevices[#nearbyDevices + 1] = {
                    name = playerState.lbTabletName,
                    source = player.source,
                    device = "tablet"
                }
            -- Check if player has phone open
            elseif playerState.phoneOpen and playerState.phoneName then
                nearbyDevices[#nearbyDevices + 1] = {
                    name = playerState.phoneName,
                    source = player.source,
                    device = "phone"
                }
            end
        end
    end
    
    debugprint("Nearby devices:", nearbyDevices)
    return nearbyDevices
end

-- Handle AirShare NUI callbacks
RegisterNUICallback("AirShare", function(data, callback)
    if not currentPhone then
        return
    end
    
    local action = data.action
    debugprint("AirShare:" .. (action or ""))
    
    if action == "getNearby" then
        -- Get list of nearby devices that can receive shares
        callback(getNearbyDevices())
    elseif action == "share" then
        -- Share data to a specific device
        TriggerCallback("airShare:share", callback, data.source, data.device, data.data)
    elseif action == "accept" then
        -- Accept an incoming share
        TriggerServerEvent("phone:airShare:interacted", data.source, data.device, true)
        callback("ok")
    elseif action == "deny" then
        -- Deny an incoming share
        TriggerServerEvent("phone:airShare:interacted", data.source, data.device, false)
        callback("ok")
    end
end)

-- Handle incoming share notifications
RegisterNetEvent("phone:airShare:received", function(shareData)
    debugprint("phone:airShare:received", shareData)
    SendReactMessage("airShare:received", shareData)
end)

-- Handle share interaction responses (accepted/denied)
RegisterNetEvent("phone:airShare:interacted", function(source, accepted)
    SendReactMessage("airShare:interacted", {
        source = source,
        accepted = accepted
    })
end)
