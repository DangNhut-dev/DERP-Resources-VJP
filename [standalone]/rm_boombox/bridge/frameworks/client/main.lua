madCore = {}
madCore.identifier = nil
madCore.playerData = nil
madCore.scriptName = GetCurrentResourceName()
madCore.triggerCallback = lib.callback

madCore.debug = function(msg)
    if cfg.framework.debug then
        print(("^1[%s]^0 --> %s"):format(madCore.scriptName, msg))
    end
end

madCore.getPhrase = function(str)
    return Strings[str] or ('locale not found: %s'):format(str)
end

madCore.showTextUI = function(msg)
    lib.showTextUI(msg)
end

madCore.hideTextUI = function()
    lib.hideTextUI()
end

madCore.requestModel = function(model)
    if HasModelLoaded(model) then
        return
    end

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
end

madCore.requestAnimDict = function(animDict)
    if HasAnimDictLoaded(animDict) then
        return
    end

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(10)
    end
end

madCore.loadPtfxAsset = function(ptfx)
    while not HasNamedPtfxAssetLoaded(ptfx) do
        RequestNamedPtfxAsset(ptfx)
        Wait(50)
    end
end

madCore.progressBar = function(time, label)
    return lib.progressCircle({
        duration = time * 1000,
        position = 'bottom',
        label = label or 'Loading...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
        },
    })
end

madCore.createBlip = function(coords, name, display)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, 1)
    SetBlipColour(blip, 5)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, false)
    SetBlipDisplay(blip, display and 5 or 2)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)
    return blip
end

RegisterNetEvent(('%s:client:showNotification'):format(madCore.scriptName), function(notify)
    madCore.showNotify(notify)
end)

RegisterNetEvent(('%s:client:setIdentifier'):format(madCore.scriptName), function(id)
    if not id then return end
    madCore.identifier = id
    madCore.debug(("identifier resolved via push -> %s"):format(tostring(id)))
end)

CreateThread(function()
    while not madCore.identifier do
        TriggerServerEvent(('%s:server:requestIdentifier'):format(madCore.scriptName))
        local timeout = 0
        while not madCore.identifier and timeout < 20 do
            Wait(100)
            timeout = timeout + 1
        end
        if madCore.identifier then break end
        Wait(2000)
    end
end)