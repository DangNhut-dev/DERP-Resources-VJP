-- Register app vao blackphone
local function RegisterAppWithPhone()
    local attempts = 0
    local lastErr = nil
    while attempts < 30 do
        attempts = attempts + 1
        local ok, err = pcall(function()
            local result = exports['DERP-blackphone']:RegisterApp({
                id = Config.AppId,
                name = Config.AppName,
                icon = Config.AppIcon,
                color = Config.AppColor,
                resource = GetCurrentResourceName()
            })
            if result == false then
                error('RegisterApp tra ve false (co the app da dang ky)')
            end
            return result
        end)
        if ok then
            print(('[derp-weedshop] App "%s" registered vao blackphone sau %d lan thu'):format(Config.AppId, attempts))
            return true
        end
        lastErr = err
        Wait(500)
    end
    print(('[derp-weedshop] Khong the dang ky app sau 30 lan. Loi cuoi: %s'):format(tostring(lastErr)))
    return false
end

CreateThread(function()
    Wait(1000)
    RegisterAppWithPhone()
end)

-- Re-register khi blackphone restart
AddEventHandler('onClientResourceStart', function(resource)
    if resource == 'DERP-blackphone' then
        Wait(2000)
        RegisterAppWithPhone()
    end
end)

-- Unregister khi weedshop stop
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    pcall(function()
        exports['DERP-blackphone']:UnregisterApp(Config.AppId)
    end)
end)

-- Blackphone tu xu ly iframe mount khi user bam vao app (via app.external flag)
-- Khong can xu ly DERP-blackphone:client:appOpen o day

-- NUI callbacks (NUI tu weedshop app goi truc tiep ve resource nay)
RegisterNUICallback('getInitialData', function(_, cb)
    lib.callback('derp-weedshop:server:getInitialData', false, function(data)
        cb(data or {})
    end)
end)

RegisterNUICallback('getMyItems', function(_, cb)
    lib.callback('derp-weedshop:server:getMyItems', false, function(items)
        cb(items or {})
    end)
end)

RegisterNUICallback('createListing', function(data, cb)
    lib.callback('derp-weedshop:server:createListing', false, function(res)
        cb(res or { ok = false })
    end, data)
end)

RegisterNUICallback('cancelListing', function(data, cb)
    lib.callback('derp-weedshop:server:cancelListing', false, function(res)
        cb(res or { ok = false })
    end, data and data.listingId)
end)

RegisterNUICallback('getListings', function(_, cb)
    lib.callback('derp-weedshop:server:getListings', false, function(rows) cb(rows or {}) end)
end)

RegisterNUICallback('getOrders', function(_, cb)
    lib.callback('derp-weedshop:server:getOrders', false, function(rows)
        cb(rows or {})
        TriggerEvent('derp-weedshop:client:syncOrders', rows or {})
    end)
end)

RegisterNUICallback('getContacts', function(_, cb)
    lib.callback('derp-weedshop:server:getContacts', false, function(rows) cb(rows or {}) end)
end)

RegisterNUICallback('getConversations', function(_, cb)
    lib.callback('derp-weedshop:server:getConversations', false, function(rows) cb(rows or {}) end)
end)

RegisterNUICallback('getMessages', function(data, cb)
    lib.callback('derp-weedshop:server:getMessages', false, function(res)
        cb(res or {})
    end, data and data.npcId)
end)

RegisterNUICallback('dealCounter', function(data, cb)
    lib.callback('derp-weedshop:server:deal:counter', false, function(res) cb(res or {}) end, data)
end)

RegisterNUICallback('dealAccept', function(data, cb)
    lib.callback('derp-weedshop:server:deal:accept', false, function(res) cb(res or {}) end, data)
end)

RegisterNUICallback('dealConfirmDelivery', function(data, cb)
    lib.callback('derp-weedshop:server:deal:confirmDelivery', false, function(res)
        cb(res or {})
        if res and res.ok then
            TriggerEvent('derp-weedshop:client:refreshOrders')
        end
    end, data)
end)

RegisterNUICallback('dealDecline', function(data, cb)
    lib.callback('derp-weedshop:server:deal:decline', false, function(res) cb(res or {}) end, data)
end)

RegisterNUICallback('cancelOrder', function(data, cb)
    lib.callback('derp-weedshop:server:cancelOrder', false, function(res)
        cb(res or {})
        if res and res.ok then
            TriggerEvent('derp-weedshop:client:refreshOrders')
        end
    end, data and data.orderId)
end)

RegisterNUICallback('setWaypoint', function(data, cb)
    if data and data.x and data.y then
        SetNewWaypoint(data.x + 0.0, data.y + 0.0)
    end
    cb({ ok = true })
end)

RegisterNUICallback('getProactiveInfo', function(data, cb)
    lib.callback('derp-weedshop:server:getProactiveInfo', false, function(res)
        cb(res or { items = {}, contacts = {} })
    end)
end)

RegisterNUICallback('proactiveCall', function(data, cb)
    lib.callback('derp-weedshop:server:proactiveCall', false, function(res)
        cb(res or {})
    end, data)
end)

RegisterNUICallback('resumeDelivery', function(data, cb)
    lib.callback('derp-weedshop:server:deal:resumeDelivery', false, function(res)
        cb(res or {})
    end, data)
end)

-- Server push event -> forward qua blackphone toi app NUI (iframe)
RegisterNetEvent('derp-weedshop:client:pushAppUpdate', function()
    pcall(function()
        exports['DERP-blackphone']:PushAppMessage(Config.AppId, {
            action = 'weedshop:refresh'
        })
    end)
end)