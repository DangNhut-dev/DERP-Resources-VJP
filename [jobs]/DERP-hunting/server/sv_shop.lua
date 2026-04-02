-- ============================
--   HUNTING SHOP - SERVER
--   Thêm vào sv_main.lua hoặc để file riêng sv_shop.lua
-- ============================

RegisterServerEvent('DERP-hunting:server:buyShopItem')
AddEventHandler('DERP-hunting:server:buyShopItem', function(itemName, price, qty)
    local src    = source
    local Player = exports['qbx_core']:GetPlayer(src)
    if not Player then return end

    qty = tonumber(qty)
    if not qty or qty < 1 or qty > 100 then return end

    local validItem = false
    for _, shopItem in ipairs(Config.ShopNPC.items) do
        if shopItem.item == itemName and shopItem.price == price then
            validItem = true
            break
        end
    end

    if not validItem then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Item không hợp lệ!' })
        return
    end

    local total        = price * qty
    local playerMoney  = Player.PlayerData.money['cash']

    if playerMoney < total then
        TriggerClientEvent('ox_lib:notify', src, {
            type        = 'error',
            description = 'Không đủ tiền! Cần $' .. total,
        })
        return
    end

    exports['qbx_core']:RemoveMoney(src, 'cash', total, 'hunting-shop-purchase')
    exports['ox_inventory']:AddItem(src, itemName, qty)

    -- TriggerClientEvent('ox_lib:notify', src, {
    --     type        = 'success',
    --     description = 'Đã mua ' .. qty .. 'x ' .. itemName .. '! -$' .. total,
    -- })
end)

-- ============================
--   BAN DA (hide) - validate tu Config.HideSystem
-- ============================

RegisterServerEvent('DERP-hunting:server:sellHide')
AddEventHandler('DERP-hunting:server:sellHide', function(itemName, pricePerUnit)
    local src    = source
    local Player = exports['qbx_core']:GetPlayer(src)
    if not Player then return end

    -- Validate item + gia trong Config.HideSystem
    local validGrade = nil
    for _, grade in ipairs(Config.HideSystem.grades) do
        if grade.item == itemName and grade.sellPrice == pricePerUnit then
            validGrade = grade
            break
        end
    end

    if not validGrade then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Item khong hop le!' })
        return
    end

    local count = exports['ox_inventory']:GetItemCount(src, itemName)
    if not count or count <= 0 then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Ban khong co ' .. validGrade.label .. '!' })
        return
    end

    local total = pricePerUnit * count
    exports['ox_inventory']:RemoveItem(src, itemName, count)
    exports['qbx_core']:AddMoney(src, 'cash', total, 'hunting-sell-hide')
    TriggerClientEvent('ox_lib:notify', src, {
        type        = 'success',
        description = 'Da ban ' .. count .. 'x ' .. validGrade.label .. ' duoc $' .. total,
        duration    = 5000,
    })
end)