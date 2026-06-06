-- Tu dong detect ten resource cua phone (co the la derp-blackphone hoac DERP-blackphone)
local _phoneResourceName = nil
local function GetPhoneResource()
    if _phoneResourceName then return _phoneResourceName end
    local candidates = { 'derp-blackphone', 'DERP-blackphone' }
    for _, name in ipairs(candidates) do
        if GetResourceState(name) == 'started' then
            _phoneResourceName = name
            return name
        end
    end
    return nil
end

local function PhoneNotify(payload)
    local resName = GetPhoneResource()
    if not resName then
        print('[weedshop] PhoneNotify: khong tim thay resource phone')
        return false
    end
    local ok, err = pcall(function()
        return exports[resName]:Notify(payload)
    end)
    if not ok then
        print(('[weedshop] PhoneNotify error: %s'):format(tostring(err)))
    end
    return ok
end

-- Sync orders tu server ve cho NPC spawner
local function RefreshOrders()
    lib.callback('derp-weedshop:server:getOrders', false, function(orders)
        TriggerEvent('derp-weedshop:client:syncOrders', orders or {})
    end)
end

-- Interact NPC de giao hang
RegisterNetEvent('derp-weedshop:client:tryDeliver', function(orderId)
    if not orderId then return end

    -- Progress bar 20s giao hang
    local success = lib.progressBar({
        duration = 45000,
        label = 'Đang giao hàng...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false
        },
        anim = {
            dict = 'mp_common',
            clip = 'givetake1_a'
        }
    })

    if not success then
        PhoneNotify({
            appId = 'weedshop',
            title = 'Đã hủy',
            body = 'Bạn đã hủy giao hàng'
        })
        return
    end

    lib.callback('derp-weedshop:server:deliver', false, function(res)
        if not res then return end
        if res.ok then
            local title, desc
            if res.status == 'delivered_early' then
                title = 'Giao hàng sớm'
                desc = ('Nhận %d black money (+10%% bonus)'):format(res.payout or 0)
            elseif res.status == 'delivered_ontime' then
                title = 'Giao hàng đúng giờ'
                desc = ('Nhận %d black money'):format(res.payout or 0)
            elseif res.status == 'delivered_late' then
                title = 'Giao hàng trễ'
                desc = ('Nhận %d black money (-20%%)'):format(res.payout or 0)
            end
            PhoneNotify({
                appId = 'weedshop', title = title, body = desc,
                onClick = { tab = 'orders' }
            })
            TriggerEvent('derp-weedshop:client:orderEnded', orderId)
            RefreshOrders()
            TriggerEvent('derp-weedshop:client:pushAppUpdate')
        else
            PhoneNotify({
                appId = 'weedshop',
                title = 'Giao hàng thất bại',
                body = res.msg or 'Lỗi không xác định'
            })
        end
    end, orderId)
end)

-- Nhan notification tin nhan moi tu server
RegisterNetEvent('derp-weedshop:client:newMessage', function(data)
    if not data then return end

    -- Hien banner phone notification
    local title = data.npcName or 'Tin nhắn mới'
    local body = data.body or 'Bạn có tin nhắn mới'

    PhoneNotify({
        appId = 'weedshop',
        title = title,
        body = body,
        onClick = {
            tab = 'messages',
            npcId = data.npcId
        }
    })

    TriggerEvent('derp-weedshop:client:pushAppUpdate')
end)

-- Refresh orders khi player load
CreateThread(function()
    Wait(5000)
    RefreshOrders()
end)

-- Periodic refresh orders (giu sync voi server khi expire)
CreateThread(function()
    while true do
        Wait(60000)
        RefreshOrders()
    end
end)

-- Event de trigger refresh tu file khac trong cung resource
RegisterNetEvent('derp-weedshop:client:refreshOrders', function()
    RefreshOrders()
end)

-- Export de app trigger refresh
exports('RefreshOrders', RefreshOrders)