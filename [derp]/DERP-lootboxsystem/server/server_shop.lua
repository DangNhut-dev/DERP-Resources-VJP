local shopCooldowns = {}

MySQL.query([[
    CREATE TABLE IF NOT EXISTS derp_coin (
        id         INT AUTO_INCREMENT PRIMARY KEY,
        citizenid  VARCHAR(50) NOT NULL UNIQUE,
        coin       INT         NOT NULL DEFAULT 0
    )
]], {})

-- Return current coin balance for citizenid
local function GetPlayerCoin(citizenid)
    local result = MySQL.scalar.await('SELECT coin FROM derp_coin WHERE citizenid = ?', { citizenid })
    return result or 0
end

-- Deduct coins; returns false if insufficient
local function RemovePlayerCoin(citizenid, amount)
    local current = GetPlayerCoin(citizenid)
    if current < amount then return false end
    MySQL.update.await('UPDATE derp_coin SET coin = coin - ? WHERE citizenid = ?', { amount, citizenid })
    return true
end

-- Add coins to player, inserting row if missing
local function AddPlayerCoin(citizenid, amount)
    MySQL.update.await([[
        INSERT INTO derp_coin (citizenid, coin)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE coin = coin + ?
    ]], { citizenid, amount, amount })
end

exports('GetPlayerCoin',    GetPlayerCoin)
exports('RemovePlayerCoin', RemovePlayerCoin)
exports('AddPlayerCoin',    AddPlayerCoin)

-- Return shop item list + player info for the requested NPC
lib.callback.register('derp-lootbox:shop:getShopData', function(source, npcId)
    if type(npcId) ~= 'string' then return nil end

    local npcConfig = Config.Shop.NPCs[npcId]
    if not npcConfig then return nil end

    local player = exports.qbx_core:GetPlayer(source)
    if not player then return nil end

    local citizenid  = player.PlayerData.citizenid
    local charinfo   = player.PlayerData.charinfo
    local playerName = (charinfo.firstname or '') .. ' ' .. (charinfo.lastname or '')
    local coinBalance = GetPlayerCoin(citizenid)
    local cashBalance = player.Functions.GetMoney('cash') or player.PlayerData.money.cash or 0

    local items = {}
    for itemName, itemData in pairs(npcConfig.items) do
        local contents = nil
        if Config.Lootboxes and Config.Lootboxes[itemName] then
            local raw = Config.Lootboxes[itemName].items
            contents = {}
            for _, entry in ipairs(raw) do
                contents[#contents + 1] = {
                    name   = entry.name,
                    type   = isClothItem(entry.name) and 'cloth' or 'normal',
                    rarity = getItemRarity(entry.name)
                }
            end
        end
        items[#items + 1] = {
            name     = itemName,
            label    = itemData.label,
            id       = itemData.id,
            price    = itemData.price,
            tags     = itemData.tags,
            contents = contents
        }
    end

    return { items = items, playerName = playerName, coinBalance = coinBalance, cashBalance = cashBalance }
end)

-- Validate and process a single lootbox purchase (legacy, kept for compat)
RegisterNetEvent('derp-lootbox:shop:buyItem', function(npcId, itemName, amount, paymentType)
    local source = source

    if type(npcId) ~= 'string' or type(itemName) ~= 'string' then return end
    if type(amount) ~= 'number' or amount < 1 or amount > 99 or math.floor(amount) ~= amount then return end
    if paymentType ~= 'coin' and paymentType ~= 'cash' then return end

    local now = os.time()
    if shopCooldowns[source] and (now - shopCooldowns[source]) < Config.Shop.BuyCooldown then
        TriggerClientEvent('derp-lootbox:shop:buyResult', source, false, 'Mua hàng quá nhanh, vui lòng chờ!')
        return
    end

    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    local npcConfig = Config.Shop.NPCs[npcId]
    if not npcConfig then return end

    local itemConfig = npcConfig.items[itemName]
    if not itemConfig then return end

    local unitPrice = itemConfig.price.coin
    if not unitPrice or unitPrice <= 0 then
        TriggerClientEvent('derp-lootbox:shop:buyResult', source, false, 'Vật phẩm không hợp lệ!')
        return
    end

    local citizenid  = player.PlayerData.citizenid

    if paymentType == 'coin' then
        local unitCoin = itemConfig.price.coin
        if not unitCoin or unitCoin <= 0 then
            TriggerClientEvent('derp-lootbox:shop:buyResult', source, false, 'Vật phẩm không hỗ trợ Coin!')
            return
        end
        local totalPrice = unitCoin * amount
        local removed = RemovePlayerCoin(citizenid, totalPrice)
        if not removed then
            TriggerClientEvent('derp-lootbox:shop:buyResult', source, false, 'Không đủ DERP Coin!')
            return
        end
        TriggerClientEvent('derp-lootbox:shop:updateCoin', source, GetPlayerCoin(citizenid))
    elseif paymentType == 'cash' then
        local unitCash = itemConfig.price.cash
        if not unitCash or unitCash <= 0 then
            TriggerClientEvent('derp-lootbox:shop:buyResult', source, false, 'Vật phẩm không hỗ trợ tiền mặt!')
            return
        end
        local totalPrice = unitCash * amount
        local cashBalance = player.Functions.GetMoney('cash') or player.PlayerData.money.cash or 0
        if cashBalance < totalPrice then
            TriggerClientEvent('derp-lootbox:shop:buyResult', source, false, 'Không đủ tiền mặt!')
            return
        end
        player.Functions.RemoveMoney('cash', totalPrice, 'derp-shop-purchase')
    end

    exports.ox_inventory:AddItem(source, itemName, amount)
    shopCooldowns[source] = now

    TriggerClientEvent('derp-lootbox:shop:buyResult', source, true,
        ('Đã mua %dx %s thành công!'):format(amount, itemConfig.label))
end)

-- Validate and process a cart checkout (multiple items, single payment)
RegisterNetEvent('derp-lootbox:shop:buyCart', function(npcId, cartItems, paymentType)
    local source = source

    if type(npcId) ~= 'string' then return end
    if type(cartItems) ~= 'table' or #cartItems == 0 or #cartItems > 20 then return end
    if paymentType ~= 'coin' and paymentType ~= 'cash' then return end

    local now = os.time()
    if shopCooldowns[source] and (now - shopCooldowns[source]) < Config.Shop.BuyCooldown then
        TriggerClientEvent('derp-lootbox:shop:buyResult', source, false, 'Mua hàng quá nhanh, vui lòng chờ!')
        return
    end

    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    local npcConfig = Config.Shop.NPCs[npcId]
    if not npcConfig then return end

    local validItems = {}
    local totalPrice = 0

    for _, entry in ipairs(cartItems) do
        if type(entry.name) ~= 'string' then return end
        if type(entry.amount) ~= 'number' or entry.amount < 1 or entry.amount > 99 or math.floor(entry.amount) ~= entry.amount then return end

        local itemConfig = npcConfig.items[entry.name]
        if not itemConfig then return end

        local unitPrice = paymentType == 'coin' and itemConfig.price.coin or itemConfig.price.cash

        if not unitPrice or unitPrice <= 0 then
            TriggerClientEvent('derp-lootbox:shop:buyResult', source, false,
                ('"%s" không hỗ trợ thanh toán này!'):format(itemConfig.label))
            return
        end

        totalPrice = totalPrice + unitPrice * entry.amount
        validItems[#validItems + 1] = { name = entry.name, amount = entry.amount }
    end

    local citizenid = player.PlayerData.citizenid

    if paymentType == 'coin' then
        local removed = RemovePlayerCoin(citizenid, totalPrice)
        if not removed then
            TriggerClientEvent('derp-lootbox:shop:buyResult', source, false, 'Không đủ DERP Coin!')
            return
        end
        TriggerClientEvent('derp-lootbox:shop:updateCoin', source, GetPlayerCoin(citizenid))
    elseif paymentType == 'cash' then
        local cashBalance = player.Functions.GetMoney('cash') or player.PlayerData.money.cash or 0
        if cashBalance < totalPrice then
            TriggerClientEvent('derp-lootbox:shop:buyResult', source, false, 'Không đủ tiền mặt!')
            return
        end
        player.Functions.RemoveMoney('cash', totalPrice, 'derp-shop-purchase')
        local newCash = player.Functions.GetMoney('cash') or 0
        TriggerClientEvent('derp-lootbox:shop:updateCash', source, newCash)
    end

    for _, item in ipairs(validItems) do
        exports.ox_inventory:AddItem(source, item.name, item.amount)
    end

    shopCooldowns[source] = now

    local currency = paymentType == 'cash' and ('$%d'):format(totalPrice) or ('%d Coin'):format(totalPrice)
    TriggerClientEvent('derp-lootbox:shop:buyResult', source, true,
        ('Thanh toán giỏ hàng thành công! (%s)'):format(currency))
end)

AddEventHandler('playerDropped', function()
    shopCooldowns[source] = nil
end)