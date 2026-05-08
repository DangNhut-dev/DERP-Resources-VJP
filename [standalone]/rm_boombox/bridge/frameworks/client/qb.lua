if string.upper(cfg.framework.name) == "AUTO" then
    if GetResourceState("qb-core") == "missing" and GetResourceState("qbx_core") == "missing" then
        return
    end
elseif string.upper(cfg.framework.name) ~= "QB" then
    return
end

local QBCore = nil

CreateThread(function()
    pcall(function() 
        QBCore = exports["qb-core"]:GetCoreObject() 
    end)

    if not QBCore then
        pcall(function() 
            QQBCoreB = exports["qb-core"]:GetSharedObject() 
        end)
    end

    if not QBCore then
        TriggerEvent("QBCore:GetObject", function(obj) 
            QBCore = obj 
        end)
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
        QBCore.Functions.Notify(msg)
    end
end)


AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    madCore.playerData = QBCore.Functions.GetPlayerData()
    madCore.identifier = madCore.playerData.citizenid
end)