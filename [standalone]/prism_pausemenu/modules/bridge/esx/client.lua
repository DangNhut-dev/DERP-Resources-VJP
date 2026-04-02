if CFG.Framework ~= 'esx' and CFG.DetectedFramework ~= 'esx' then return end

ESX = exports['es_extended']:getSharedObject()  

TriggerServerCallback = function(name, data)
    local data2 = nil

    ESX.TriggerServerCallback(name, function(data3) 
        data2 = data3
    end, data)

    while data2 == nil do
        Wait(0)
    end

    return data2
end
