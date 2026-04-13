local shopCooldowns = {}
local allEvents = {
    ["derp-lootbox:shop:buyCart"] = false,
    ["derp-lootbox:shop:buyItem"] = false
}

local fiveguard_resource = "svc_runtime"

AddEventHandler("fg:ExportsLoaded", function(fiveguard_res, res)
    if res == "*" or res == GetCurrentResourceName() then
        fiveguard_resource = fiveguard_res
        for event,cross_scripts in pairs(allEvents) do
            local retval, errorText = exports[fiveguard_res]:RegisterSafeEvent(event, {
                ban = true,
                log = true
            }, cross_scripts)
            if not retval then
                print("[fiveguard safe-events] "..errorText)
            end
        end
    end
end)

local function getCoinLogMeta(meta)
    local source = 0
    local reason = nil
    local title = nil
    local silent = false

    if type(meta) == 'table' then
        source = tonumber(meta.source or meta.src or 0) or 0
        reason = meta.reason or meta.note
        title = meta.title
        silent = meta.silent == true or meta.log == false
    elseif type(meta) == 'number' then
        source = tonumber(meta) or 0
    elseif type(meta) == 'string' then
        reason = meta
    end

    return source, reason, title, silent
end

local function buildCoinLogMoney(source, coinBalance)
    if source and source > 0 then
        return DERP_GetPlayerMoneySnapshot(source, { coins = coinBalance })
    end

    return {
        coins = tonumber(coinBalance) or 0,
    }
end

local function buildShopItemEntries(items)
    local out = {}

    for i = 1, #items do
        local entry = items[i]
        if entry and entry.name then
            out[#out + 1] = {
                name = entry.name,
                count = tonumber(entry.amount) or tonumber(entry.count) or 1,
            }
        end
    end

    return out
end

local function buildShopLogDetails(itemEntries, paymentType, totalPrice, npcId, extraDetails)
    local details = {}

    details[#details + 1] = { 'items', DERP_FormatItemList(itemEntries, 'add') }
    details[#details + 1] = { 'pay', tostring(paymentType or '') }
    details[#details + 1] = { 'total', tostring(totalPrice or 0) }

    if npcId and npcId ~= '' then
        details[#details + 1] = { 'npc', npcId }
    end

    if type(extraDetails) == 'table' then
        for i = 1, #extraDetails do
            details[#details + 1] = extraDetails[i]
        end
    end

    return details
end

local function logShopPurchase(source, citizenid, title, itemEntries, paymentType, totalPrice, npcId, beforeMoney, afterMoney, extraDetails)
    if type(itemEntries) ~= 'table' or #itemEntries == 0 then
        return false
    end

    return DERP_LogAction(source > 0 and source or citizenid, title, buildShopLogDetails(itemEntries, paymentType, totalPrice, npcId, extraDetails), {
        citizenid = citizenid,
        source = source,
        beforeMoney = beforeMoney,
        afterMoney = afterMoney,
    })
end

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
local function RemovePlayerCoin(citizenid, amount, meta)
    local current = GetPlayerCoin(citizenid)
    if current < amount then return false end

    MySQL.update.await('UPDATE derp_coin SET coin = coin - ? WHERE citizenid = ?', { amount, citizenid })

    local source, reason, title, silent = getCoinLogMeta(meta)
    if not silent then
        local afterCoin = current - amount
        local details = {
            { 'coin', ('-%s'):format(tostring(amount)) },
            { 'before', tostring(current) },
            { 'after', tostring(afterCoin) },
        }

        if reason and reason ~= '' then
            details[#details + 1] = { 'reason', reason }
        end

        DERP_LogAction(source > 0 and source or citizenid, title or 'Trừ DERP Coin', details, {
            citizenid = citizenid,
            source = source,
            beforeMoney = buildCoinLogMoney(source, current),
            afterMoney = buildCoinLogMoney(source, afterCoin),
        })
    end

    return true
end

-- Add coins to player, inserting row if missing
local function AddPlayerCoin(citizenid, amount, meta)
    local current = GetPlayerCoin(citizenid)

    MySQL.update.await([[
        INSERT INTO derp_coin (citizenid, coin)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE coin = coin + ?
    ]], { citizenid, amount, amount })

    local source, reason, title, silent = getCoinLogMeta(meta)
    if not silent then
        local afterCoin = current + amount
        local details = {
            { 'coin', ('+%s'):format(tostring(amount)) },
            { 'before', tostring(current) },
            { 'after', tostring(afterCoin) },
        }

        if reason and reason ~= '' then
            details[#details + 1] = { 'reason', reason }
        end

        DERP_LogAction(source > 0 and source or citizenid, title or 'Cộng DERP Coin', details, {
            citizenid = citizenid,
            source = source,
            beforeMoney = buildCoinLogMoney(source, current),
            afterMoney = buildCoinLogMoney(source, afterCoin),
        })
    end
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
    if fiveguard_resource ~= "" and GetResourceState(fiveguard_resource) == 'started' then
        if not exports[fiveguard_resource]:VerifyToken(source) then return end
    end
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
    local beforeMoney = nil
    local afterMoney = nil
    local totalPrice = 0

    if paymentType == 'coin' then
        local beforeCoin = GetPlayerCoin(citizenid)
        beforeMoney = buildCoinLogMoney(source, beforeCoin)

        local unitCoin = itemConfig.price.coin
        if not unitCoin or unitCoin <= 0 then
            TriggerClientEvent('derp-lootbox:shop:buyResult', source, false, 'Vật phẩm không hỗ trợ Coin!')
            return
        end

        totalPrice = unitCoin * amount

        local removed = RemovePlayerCoin(citizenid, totalPrice, {
            source = source,
            silent = true,
        })
        if not removed then
            TriggerClientEvent('derp-lootbox:shop:buyResult', source, false, 'Không đủ DERP Coin!')
            return
        end

        local newCoin = GetPlayerCoin(citizenid)
        afterMoney = buildCoinLogMoney(source, newCoin)
        TriggerClientEvent('derp-lootbox:shop:updateCoin', source, newCoin)
    elseif paymentType == 'cash' then
        beforeMoney = DERP_GetPlayerMoneySnapshot(source)

        local unitCash = itemConfig.price.cash
        if not unitCash or unitCash <= 0 then
            TriggerClientEvent('derp-lootbox:shop:buyResult', source, false, 'Vật phẩm không hỗ trợ tiền mặt!')
            return
        end

        totalPrice = unitCash * amount

        local cashBalance = player.Functions.GetMoney('cash') or player.PlayerData.money.cash or 0
        if cashBalance < totalPrice then
            TriggerClientEvent('derp-lootbox:shop:buyResult', source, false, 'Không đủ tiền mặt!')
            return
        end

        player.Functions.RemoveMoney('cash', totalPrice, 'derp-shop-purchase')
        afterMoney = DERP_GetPlayerMoneySnapshot(source)
    end

    local added = exports.ox_inventory:AddItem(source, itemName, amount)
    shopCooldowns[source] = now

    if added then
        logShopPurchase(source, citizenid, 'Mua lootbox shop', buildShopItemEntries({ { name = itemName, amount = amount } }), paymentType, totalPrice, npcId, beforeMoney, afterMoney)
    end

    TriggerClientEvent('derp-lootbox:shop:buyResult', source, true,
        ('Đã mua %dx %s thành công!'):format(amount, itemConfig.label))
end)

-- Validate and process a cart checkout (multiple items, single payment)
RegisterNetEvent('derp-lootbox:shop:buyCart', function(npcId, cartItems, paymentType)
    local source = source
    if fiveguard_resource ~= "" and GetResourceState(fiveguard_resource) == 'started' then
        if not exports[fiveguard_resource]:VerifyToken(source) then return end
    end
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
    local beforeMoney = nil
    local afterMoney = nil

    if paymentType == 'coin' then
        local beforeCoin = GetPlayerCoin(citizenid)
        beforeMoney = buildCoinLogMoney(source, beforeCoin)

        local removed = RemovePlayerCoin(citizenid, totalPrice, {
            source = source,
            silent = true,
        })
        if not removed then
            TriggerClientEvent('derp-lootbox:shop:buyResult', source, false, 'Không đủ DERP Coin!')
            return
        end

        local newCoin = GetPlayerCoin(citizenid)
        afterMoney = buildCoinLogMoney(source, newCoin)
        TriggerClientEvent('derp-lootbox:shop:updateCoin', source, newCoin)
    elseif paymentType == 'cash' then
        beforeMoney = DERP_GetPlayerMoneySnapshot(source)

        local cashBalance = player.Functions.GetMoney('cash') or player.PlayerData.money.cash or 0
        if cashBalance < totalPrice then
            TriggerClientEvent('derp-lootbox:shop:buyResult', source, false, 'Không đủ tiền mặt!')
            return
        end

        player.Functions.RemoveMoney('cash', totalPrice, 'derp-shop-purchase')
        afterMoney = DERP_GetPlayerMoneySnapshot(source)

        local newCash = player.Functions.GetMoney('cash') or 0
        TriggerClientEvent('derp-lootbox:shop:updateCash', source, newCash)
    end

    local addedAny = false
    for _, item in ipairs(validItems) do
        local added = exports.ox_inventory:AddItem(source, item.name, item.amount)
        if added then
            addedAny = true
        end
    end

    shopCooldowns[source] = now

    if addedAny then
        logShopPurchase(source, citizenid, 'Thanh toán giỏ hàng lootbox', buildShopItemEntries(validItems), paymentType, totalPrice, npcId, beforeMoney, afterMoney)
    end

    local currency = paymentType == 'cash' and ('$%d'):format(totalPrice) or ('%d Coin'):format(totalPrice)
    TriggerClientEvent('derp-lootbox:shop:buyResult', source, true,
        ('Thanh toán giỏ hàng thành công! (%s)'):format(currency))
end)

AddEventHandler('playerDropped', function()
    shopCooldowns[source] = nil
end)