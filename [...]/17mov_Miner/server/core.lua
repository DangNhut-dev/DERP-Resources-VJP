-- Functions Module
Functions = {}

-- Error logging function
function Functions.Error(...)
    local args = table.pack(...)
    local message = ""
    local first = true
    
    for _, value in ipairs(args) do
        if first then
            first = false
        else
            message = message .. " "
        end
        message = message .. tostring(value)
    end
    
    print("^5[ERROR]:^1 " .. message)
    print("^0")
end

-- Server Callback System
local ServerCallbacks = {}

function RegisterServerCallback(name, callback)
    ServerCallbacks[name] = callback
end

RegisterNetEvent("17mov_Callbacks:GetResponse" .. GetCurrentResourceName(), function(callbackName, callbackIndex, ...)
    if ServerCallbacks[callbackName] == nil then
        return
    end
    
    local playerId = source
    
    TriggerClientEvent(
        "17mov_Callbacks:receiveData" .. GetCurrentResourceName(),
        playerId,
        callbackName,
        callbackIndex,
        ServerCallbacks[callbackName](playerId, ...)
    )
end)

-- Get all party members (mugs)
function GetAllPartyMugs(hostId)
    local partyMembers = {}
    local clientsList = {}
    local lobbyIndex = 0
    
    -- Find the lobby/party for this host
    for index, party in pairs(PlayersPairs) do
        if party.host == hostId then
            lobbyIndex = index
            clientsList = party.clients
        end
    end
    
    -- Add all clients to the party members list
    for i = 1, #clientsList do
        table.insert(partyMembers, {
            id = clientsList[i],
            name = GetPlayerIdentity(clientsList[i]),
            isHost = false,
            rewardPercent = PlayersPairs[lobbyIndex].rewardsOptions[clientsList[i]]
        })
    end
    
    -- Add the host to the party members list
    if #clientsList == 0 then
        table.insert(partyMembers, {
            id = hostId,
            name = GetPlayerIdentity(hostId),
            isHost = true,
            rewardPercent = PlayersPairs[lobbyIndex].rewardsOptions[hostId]
        })
    else
        table.insert(partyMembers, {
            id = hostId,
            name = GetPlayerIdentity(hostId),
            isHost = true,
            rewardPercent = PlayersPairs[lobbyIndex].rewardsOptions[hostId]
        })
    end
    
    return partyMembers
end

-- Trigger event for all party members
function TriggerForAllMembers(hostId, eventName, ...)
    local args = table.pack(...)
    local clientsList = {}
    
    -- Get all clients in the party
    for _, party in pairs(PlayersPairs) do
        if party.host == hostId then
            clientsList = party.clients
        end
    end
    
    -- Trigger event for all members (clients + host)
    for i = 1, #clientsList + 1 do
        local playerId = clientsList[i]
        
        -- If index exceeds clients list, use host ID
        if i > #clientsList then
            playerId = hostId
        end
        
        if playerId ~= nil and type(playerId) == "number" then
            -- Special handling for specific events
            if eventName == "17mov_construction:RefreshMugs" then
                TriggerClientEvent(eventName, playerId, args[1], playerId, args[2], args[3])
            elseif eventName == "gta5vn_miner:StartJob_cl" then
                TriggerClientEvent(eventName, playerId, args[1], playerId, args[2], args[3], args[4])
            elseif eventName == "gta5vn_miner:UpdateMinecart" then
                TriggerClientEvent(eventName, playerId, args[1], playerId, hostId)
            else
                TriggerClientEvent(eventName, playerId, ...)
            end
        end
    end
end

-- Get lobby index for a player
function GetLobbyIndex(playerId)
    local lobbyIndex = 0
    
    for index, party in pairs(PlayersPairs) do
        -- Check if player is the host
        if party.host == playerId then
            lobbyIndex = index
            break
        end
        
        -- Check if player is a client
        for i = 1, #party.clients do
            if party.clients[i] == playerId then
                lobbyIndex = index
                break
            end
        end
    end
    
    return lobbyIndex
end

-- Trigger event for all clients in a lobby (excluding host)
function TriggerForClients(lobbyIndex, eventName, ...)
    local clientsList = PlayersPairs[lobbyIndex].clients
    
    for i = 1, #clientsList do
        TriggerClientEvent(eventName, clientsList[i], ...)
    end
end

-- Cleanup routing buckets when resource stops
AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    for _, playerId in pairs(ClientsInBuckets) do
        SetPlayerRoutingBucket(playerId, 0)
    end
end)