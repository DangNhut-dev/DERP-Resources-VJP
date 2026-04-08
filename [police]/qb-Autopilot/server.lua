RegisterCommand("autopilot", function(source, args, raw)
    local src = source
    TriggerClientEvent("autopilot:start", src)
end)
local QBCore = exports['qb-core']:GetCoreObject()
QBCore.Commands.Add('clear', 'Clear Chat', {}, false, function(source, args)
    TriggerClientEvent('chat:clear', source)
end, 'user')

QBCore.Commands.Add('clearall', 'Clear All Chat(Admin Only)', {}, false, function(source, args)
    TriggerClientEvent('chat:clear', -1)
end, 'admin')