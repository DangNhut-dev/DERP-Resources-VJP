local callbacks = {}

function Functions.RegisterServerCallback(name, cb)
    callbacks[name] = cb
end

RegisterNetEvent("17mov_Callbacks:GetResponse" .. Functions.ResourceName, function(name, requestId, ...)
    local src = source
    if callbacks[name] == nil then
        return
    end
    TriggerClientEvent("17mov_Callbacks:receiveData" .. Functions.ResourceName, src, name, requestId, callbacks[name](src, ...))
end)

function GetLobbyIndex(playerSource)
    local lobbyIndex = 0
    for idx, lobby in pairs(PlayersPairs) do
        if lobby.host == playerSource then
            lobbyIndex = idx
            break
        end
        for i = 1, #lobby.clients, 1 do
            if lobby.clients[i] == playerSource then
                lobbyIndex = idx
                break
            end
        end
    end
    return lobbyIndex
end

function TriggerForClients(lobbyIndex, eventName, ...)
    local clients = PlayersPairs[lobbyIndex].clients
    for i = 1, #clients, 1 do
        TriggerClientEvent(eventName, clients[i], ...)
    end
end
