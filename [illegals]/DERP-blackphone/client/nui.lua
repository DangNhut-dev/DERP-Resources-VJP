-- Callback dong phone tu NUI
RegisterNUICallback('close', function(_, cb)
    ClosePhone()
    cb(1)
end)

-- Callback mo app (forward ra event rieng cho tung app xu ly)
RegisterNUICallback('openApp', function(data, cb)
    if not data or not data.appId then cb({ ok = false }) return end
    local app = Apps.Get(data.appId)
    if not app or not app.enabled then cb({ ok = false }) return end

    TriggerEvent('derp-blackphone:client:appOpen', app.id, data)
    cb({ ok = true })
end)

-- Callback app action chung (forward len server)
RegisterNUICallback('appAction', function(data, cb)
    if not data or not data.appId or not data.action then cb({ ok = false }) return end
    local app = Apps.Get(data.appId)
    if not app or not app.enabled then cb({ ok = false }) return end

    TriggerEvent('derp-blackphone:client:appAction', app.id, data.action, data.payload or {})
    cb({ ok = true })
end)

-- Callback debug log tu NUI (chi bat khi Config.Debug)
RegisterNUICallback('log', function(data, cb)
    if Config.Debug then
        print(('[blackphone NUI] %s'):format(data and data.msg or ''))
    end
    cb(1)
end)