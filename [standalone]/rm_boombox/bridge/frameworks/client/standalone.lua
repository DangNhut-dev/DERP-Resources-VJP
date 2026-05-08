if string.upper(cfg.framework.name) == "AUTO" then
    if GetResourceState("qb-core") ~= "missing" or GetResourceState("qbx_core") ~= "missing" or GetResourceState("es_extended") ~= "missing" then
        return
    end
elseif string.upper(cfg.framework.name) ~= "STANDALONE" then
    return
end


CreateThread(function()
    madCore.showNotify = function(msg, typ)
        return lib.notify({
            description = msg,
            type = typ
        })
    end
end)

CreateThread(function()
    while true do
        if NetworkIsPlayerActive(PlayerId()) then
            TriggerServerEvent("boombox:server:playerLoaded")
            break
        end
        Wait(1000)
    end
end)

RegisterNetEvent('boombox:client:playerLoaded', function(identifier)
    madCore.identifier = identifier
end)