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
        duration = 20000,
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
        lib.notify({ title = 'Đã hủy', description = 'Bạn đã hủy giao hàng', type = 'error' })
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
            lib.notify({ title = title, description = desc, type = 'success' })
            TriggerEvent('derp-weedshop:client:orderEnded', orderId)
            RefreshOrders()
            TriggerEvent('derp-weedshop:client:pushAppUpdate')
        else
            lib.notify({ title = 'Giao hàng thất bại', description = res.msg or '', type = 'error' })
        end
    end, orderId)
end)

-- Nhan notification tin nhan moi tu server
RegisterNetEvent('derp-weedshop:client:newMessage', function(data)
    lib.notify({
        title = Config.AppName,
        description = 'Ban co tin nhan moi',
        type = 'inform',
        icon = 'envelope'
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