if string.upper(cfg.framework.name) == "AUTO" then
    if GetResourceState("es_extended") == "missing" then
        return
    end
elseif string.upper(cfg.framework.name) ~= "ESX" then
    return
end

local ESX = nil

CreateThread(function()
    while not ESX do
        pcall(function() 
            ESX = exports["es_extended"]:getSharedObject() 
        end)
    
        if not ESX then
            TriggerEvent("esx:getSharedObject", function(library)
                ESX = library
            end)
        end
        Wait(1)
    end
    
    while not madCore do
        Wait(10)
    end

    madCore.showNotify = function(msg, typ)
        if cfg.framework.useOxNotify then
            return lib.notify({
                description = msg,
                type = typ or "info"
            })
        end
        ESX.ShowNotification(msg)
    end
end)

RegisterNetEvent('esx:playerLoaded', function(xPlayer, isNew, skin)
    madCore.playerData = xPlayer
    madCore.identifier = xPlayer.identifier
end)