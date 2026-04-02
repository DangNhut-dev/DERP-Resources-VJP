if CFG.Framework ~= 'qb' and CFG.DetectedFramework ~= 'qb' then return end

local QBCore = exports['qb-core']:GetCoreObject()

TriggerServerCallback = function(name, data)
    return QBCore.Functions.TriggerCallback(name, data)
end
