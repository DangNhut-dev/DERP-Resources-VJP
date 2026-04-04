local isUIOpen = false
local isAdmin = false

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    lib.callback('DERP-donatesystem:checkAdmin', false, function(result)
        isAdmin = result
        RegisterRadialItems()
        if isAdmin then
            TriggerServerEvent('DERP-donatesystem:requestPendingState')
        end
    end)
end)

function RegisterRadialItems()
    if not Config.RadialMenu.enabled then return end
    lib.addRadialItem({
        {
            id = 'derp_donate',
            label = 'Donate',
            icon = 'hand-holding-heart',
            onSelect = OpenDonateUI
        }
    })
    -- if isAdmin then
    --     lib.addRadialItem({
    --         {
    --             id = 'derp_admin',
    --             label = 'Admin Donate',
    --             icon = 'shield-halved',
    --             onSelect = OpenAdminUI
    --         }
    --     })
    -- end
end

function OpenDonateUI()
    if isUIOpen then return end
    lib.callback('DERP-donatesystem:getCoinBalance', false, function(coin)
        isUIOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'openUI',
            page = 'donate',
            config = {
                payment  = Config.Payment,
                donate   = Config.Donate,
                qr       = Config.QR,
                isAdmin  = isAdmin,
                playerName = GetPlayerName(PlayerId()),
                coin     = coin or 0
            }
        })
    end)
end

function OpenAdminUI()
    if not isAdmin then return end
    if isUIOpen then return end
    lib.callback('DERP-donatesystem:getCoinBalance', false, function(coin)
        isUIOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'openUI',
            page = 'admin',
            config = {
                payment  = Config.Payment,
                donate   = Config.Donate,
                qr       = Config.QR,
                isAdmin  = isAdmin,
                playerName = GetPlayerName(PlayerId()),
                coin     = coin or 0
            }
        })
    end)
end

RegisterNUICallback('closeUI', function(_, cb)
    isUIOpen = false
    SetNuiFocus(false, false)
    cb({ success = true })
end)

RegisterNUICallback('ping', function(_, cb)
    print('[DERP-donate] PING received from NUI')
    cb({ pong = true })
end)

RegisterNUICallback('createTicket', function(data, cb)
    local amount = tonumber(data.amount)
    local note = tostring(data.note or '')
    if not amount or amount <= 0 then
        lib.notify({ title = 'Ủng Hộ Thành Phố', description = 'Số tiền không hợp lệ', type = 'error', duration = 5000 })
        cb({ success = false })
        return
    end
    lib.callback('DERP-donatesystem:createTicket', false, function(result)
        if not result then
            lib.notify({ title = 'Ủng Hộ Thành Phố', description = 'Không nhận được phản hồi từ server', type = 'error', duration = 5000 })
            cb({ success = false })
            return
        end
        if result.success then
            lib.notify({ title = 'Ủng Hộ Thành Phố', description = result.message, type = 'success', duration = 5000 })
        else
            lib.notify({ title = 'Ủng Hộ Thành Phố', description = result.message or 'Có lỗi xảy ra', type = 'error', duration = 5000 })
        end
        cb(result)
    end, amount, note)
end)

RegisterNUICallback('getMyTickets', function(_, cb)
    lib.callback('DERP-donatesystem:getMyTickets', false, function(tickets)
        cb({ success = true, tickets = tickets or {} })
    end)
end)

RegisterNUICallback('adminGetTickets', function(data, cb)
    if not isAdmin then cb({ success = false, tickets = {} }) return end
    lib.callback('DERP-donatesystem:adminGetTickets', false, function(result)
        cb(result or { success = false, tickets = {} })
    end, data.filter, data.search)
end)

RegisterNUICallback('adminConfirmTicket', function(data, cb)
    if not isAdmin then cb({ success = false }) return end
    lib.callback('DERP-donatesystem:adminConfirmTicket', false, function(result)
        cb(result or { success = false })
    end, data.ticketId)
end)

RegisterNUICallback('adminRejectTicket', function(data, cb)
    if not isAdmin then cb({ success = false }) return end
    lib.callback('DERP-donatesystem:adminRejectTicket', false, function(result)
        cb(result or { success = false })
    end, data.ticketId)
end)

RegisterNUICallback('getRevenue', function(_, cb)
    if not isAdmin then cb({ success = false }) return end
    lib.callback('DERP-donatesystem:getRevenue', false, function(result)
        cb(result or { success = false })
    end)
end)

RegisterNUICallback('cancelTicket', function(data, cb)
    lib.callback('DERP-donatesystem:cancelTicket', false, function(result)
        cb(result or { success = false })
    end, data.ticketId)
end)

RegisterNetEvent('DERP-donatesystem:notify', function(ntype, message)
    lib.notify({
        title = 'Ủng Hộ Thành Phố',
        description = message,
        type = ntype,
        duration = 5000
    })
end)

RegisterCommand('donate', function()
    OpenDonateUI()
end, false)

RegisterNetEvent('DERP-donatesystem:showPendingOverlay', function()
    if not isAdmin then return end
    SendNUIMessage({ action = 'showPendingOverlay' })
end)

RegisterNetEvent('DERP-donatesystem:hidePendingOverlay', function()
    if not isAdmin then return end
    SendNUIMessage({ action = 'hidePendingOverlay' })
end)