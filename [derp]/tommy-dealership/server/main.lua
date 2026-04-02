local SharedVehicles = {}

CreateThread(function()
    Wait(500)
    SharedVehicles = exports.qbx_core:GetVehiclesByName() or {}
end)

AddEventHandler('onServerResourceStart', function(resource)
    if resource == 'qbx_core' then
        SharedVehicles = exports.qbx_core:GetVehiclesByName() or {}
    end
end)

-- Locale
local Locale = {}

local function LoadLocale(lang)
    local file = LoadResourceFile(GetCurrentResourceName(), ('locales/%s.lua'):format(lang))
    if not file then return {} end
    local fn = load(file)
    return fn and fn() or {}
end

Locale = LoadLocale('vi')

-- Coin helpers (derp_coin)
local function GetPlayerCoin(citizenid)
    return MySQL.scalar.await('SELECT coin FROM derp_coin WHERE citizenid = ?', { citizenid }) or 0
end

local function RemovePlayerCoin(citizenid, amount)
    local affected = MySQL.update.await(
        'UPDATE derp_coin SET coin = coin - ? WHERE citizenid = ? AND coin >= ?',
        { amount, citizenid, amount }
    )
    return affected > 0
end

-- Plate generator
local _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
local _nums  = '0123456789'

local function GeneratePlate()
    local plate = 'DE' .. string.format('%06d', math.random(0, 999999))
    local exists = MySQL.scalar.await('SELECT plate FROM player_vehicles WHERE plate = ?', { plate })
    if exists then return GeneratePlate() end
    return plate
end

-- Vehicle label helper
local function GetVehicleLabel(model)
    return SharedVehicles[model] and SharedVehicles[model].name or model
end

-- Discord webhook
local function SendDiscordLog(webhookData)
    if not Config.DiscordWebhook or Config.DiscordWebhook == '' then return end

    local function GetColorName(idx)
        for _, c in pairs(Config.VehicleColors) do
            if c.colorindex == idx then return c.name end
        end
        return 'Unknown'
    end

    local function FormatMoney(amount)
        local s = tostring(amount):reverse():gsub('(%d%d%d)', '%1,')
        return '$' .. s:reverse():gsub('^,', '')
    end

    local embedColor   = webhookData.saleType == 'dealer' and 3066993 or 3447003
    local saleTypeText = webhookData.saleType == 'dealer' and '🤝 Bán qua Dealer' or '🛒 Tự Mua'

    local fields = {
        { name = '🏪 Đại Lý',  value = webhookData.shopName or 'N/A',         inline = true },
        { name = '🚗 Xe',      value = string.upper(webhookData.vehicle),       inline = true },
        { name = '🔖 Biển Số', value = webhookData.plate,                       inline = true },
    }

    if webhookData.sellerName then
        fields[#fields + 1] = {
            name  = '👤 Người Bán',
            value = ('%s\n`%s`'):format(webhookData.sellerName, webhookData.sellerCitizenId),
            inline = true
        }
    end

    fields[#fields + 1] = {
        name  = '👥 Người Mua',
        value = ('%s\n`%s`'):format(webhookData.buyerName, webhookData.buyerCitizenId),
        inline = true
    }

    if webhookData.sellerName then
        fields[#fields + 1] = { name = '​', value = '​', inline = true }
    end

    fields[#fields + 1] = {
        name  = '💰 Giá Bán',
        value = webhookData.paymentType == 'gc' and (webhookData.price .. ' DE-Coin') or FormatMoney(webhookData.price),
        inline = true
    }

    local paymentText = '💵 Tiền Mặt'
    if webhookData.paymentType == 'bank' then
        paymentText = '🏦 Ngân Hàng'
    elseif webhookData.paymentType == 'gc' then
        paymentText = '🪙 DE-Coin'
    end
    fields[#fields + 1] = { name = '💳 Thanh Toán', value = paymentText, inline = true }

    if webhookData.commission and webhookData.commission > 0 then
        fields[#fields + 1] = {
            name  = '💸 Hoa Hồng',
            value = FormatMoney(webhookData.commission) .. (' (%d%%)'):format(webhookData.commissionPercent),
            inline = true
        }
    else
        fields[#fields + 1] = { name = '​', value = '​', inline = true }
    end

    fields[#fields + 1] = { name = '🎨 Màu Xe', value = GetColorName(webhookData.color or 0), inline = true }

    PerformHttpRequest(Config.DiscordWebhook, function(code)
        if code ~= 200 and code ~= 204 then
            print(('[tommy-dealership] Discord error: %s'):format(tostring(code)))
        end
    end, 'POST', json.encode({
        username = 'Baby Blue Cars',
        embeds = {{
            title     = saleTypeText,
            color     = embedColor,
            fields    = fields,
            footer    = { text = 'Baby Blue Cars' },
            timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
        }}
    }), { ['Content-Type'] = 'application/json' })
end

-- Callbacks
lib.callback.register('tommy-dealership:server:GetSelfPurchaseData', function(source, shop)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return nil end

    local data = {
        shop       = shop,
        vehicles   = {},
        playerGC   = GetPlayerCoin(player.PlayerData.citizenid)
    }

    local stock = MySQL.query.await(
        'SELECT vehicle, stock, price, gc_price, allow_self_purchase, description FROM vehicle_stock WHERE shop = ? ORDER BY price ASC',
        { shop }
    )

    for _, row in ipairs(stock) do
        local allowSelf    = row.allow_self_purchase == 1 or row.allow_self_purchase == true
        local dealerPrice  = row.price
        local selfPrice    = math.floor(dealerPrice * (1 + Config.SelfPurchaseMarkup))
        local dealerGC     = row.gc_price or 0
        local selfGC       = math.floor(dealerGC * (1 + Config.SelfPurchaseMarkup))

        data.vehicles[#data.vehicles + 1] = {
            vehicle           = row.vehicle,
            stock             = row.stock,
            price             = selfPrice,
            dealerPrice       = dealerPrice,
            gcPrice           = selfGC,
            dealerGCPrice     = dealerGC,
            allowSelfPurchase = allowSelf,
            description       = row.description,
            label             = GetVehicleLabel(row.vehicle)
        }
    end

    return data
end)

lib.callback.register('tommy-dealership:server:ToggleSelfPurchase', function(source, shop, vehicle, enabled)
    local player = exports.qbx_core:GetPlayer(source)
    if not player                                              then return false, Locale['player_not_found'] end
    if player.PlayerData.job.name ~= Config.DealerJob         then return false, Locale['not_dealer']       end
    if player.PlayerData.job.grade.level < Config.ManagementGrade then return false, Locale['no_permission'] end

    MySQL.update.await(
        'UPDATE vehicle_stock SET allow_self_purchase = ? WHERE shop = ? AND vehicle = ?',
        { enabled and 1 or 0, shop, vehicle }
    )

    local msg = enabled
        and (Locale['self_purchase_enabled']  or 'Đã bật bán tự động')
        or  (Locale['self_purchase_disabled'] or 'Đã tắt bán tự động')
    return true, msg
end)

lib.callback.register('tommy-dealership:server:PurchaseVehicleSelf', function(source, shop, data)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false, Locale['player_not_found'] end

    if type(data.vehicle) ~= 'string' or type(data.paymentType) ~= 'string' then
        return false, 'Invalid data'
    end

    local shopData = Config.Shops[shop]
    if not shopData then return false, 'Invalid shop' end

    local pCoords = GetEntityCoords(GetPlayerPed(source))
    local dist    = #(pCoords - vector3(shopData.Location.x, shopData.Location.y, shopData.Location.z))
    if dist > 100.0 then return false, Locale['too_far_from_dealership'] or 'Bạn đứng quá xa đại lý!' end

    local affected = MySQL.update.await(
        'UPDATE vehicle_stock SET stock = stock - 1 WHERE shop = ? AND vehicle = ? AND stock >= 1 AND allow_self_purchase = 1',
        { shop, data.vehicle }
    )
    if affected == 0 then return false, Locale['not_enough_stock'] or 'Hết hàng hoặc không cho phép tự mua!' end

    local stockRow = MySQL.query.await('SELECT price, gc_price FROM vehicle_stock WHERE shop = ? AND vehicle = ?', { shop, data.vehicle })
    if not stockRow[1] then
        MySQL.update('UPDATE vehicle_stock SET stock = stock + 1 WHERE shop = ? AND vehicle = ?', { shop, data.vehicle })
        return false, Locale['vehicle_not_found'] or 'Không tìm thấy xe!'
    end

    local dealerPrice = stockRow[1].price
    local selfPrice   = math.floor(dealerPrice * (1 + Config.SelfPurchaseMarkup))
    local dealerGC    = stockRow[1].gc_price or 0
    local selfGC      = math.floor(dealerGC * (1 + Config.SelfPurchaseMarkup))
    local finalPrice  = selfPrice

    local hasEnough = false
    if data.paymentType == 'gc' then
        if dealerGC <= 0 then
            MySQL.update('UPDATE vehicle_stock SET stock = stock + 1 WHERE shop = ? AND vehicle = ?', { shop, data.vehicle })
            return false, Locale['gc_not_available'] or 'Xe này không hỗ trợ thanh toán DE-Coin!'
        end
        finalPrice = selfGC
        hasEnough  = GetPlayerCoin(player.PlayerData.citizenid) >= selfGC
    elseif data.paymentType == 'cash' then
        hasEnough = player.PlayerData.money.cash >= selfPrice
    else
        hasEnough = player.PlayerData.money.bank >= selfPrice
    end

    if not hasEnough then
        MySQL.update('UPDATE vehicle_stock SET stock = stock + 1 WHERE shop = ? AND vehicle = ?', { shop, data.vehicle })
        return false, Locale['not_enough_money'] or 'Không đủ tiền!'
    end

    local removed = false
    if data.paymentType == 'gc' then
        removed = RemovePlayerCoin(player.PlayerData.citizenid, selfGC)
    elseif data.paymentType == 'cash' then
        removed = player.Functions.RemoveMoney('cash', selfPrice, 'vehicle-self-purchase')
    else
        removed = player.Functions.RemoveMoney('bank', selfPrice, 'vehicle-self-purchase')
    end

    if not removed then
        MySQL.update('UPDATE vehicle_stock SET stock = stock + 1 WHERE shop = ? AND vehicle = ?', { shop, data.vehicle })
        return false, Locale['not_enough_money'] or 'Lỗi trừ tiền!'
    end

    if data.paymentType ~= 'gc' then
        exports['Renewed-Banking']:addAccountMoney(Config.BankAccount, selfPrice, 'Self Purchase: ' .. data.vehicle)
    end

    local plate = GeneratePlate()
    local mods  = json.encode({ color1 = data.color or 0, color2 = data.color or 0, pearlescentColor = data.color or 0, wheelColor = data.color or 0 })

    local insertId = MySQL.insert.await(
        'INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        { player.PlayerData.license, player.PlayerData.citizenid, data.vehicle, GetHashKey(data.vehicle), mods, plate, Config.DefaultGarage, 0 }
    )

    if not insertId then
        if data.paymentType == 'gc' then
            MySQL.update('UPDATE derp_coin SET coin = coin + ? WHERE citizenid = ?', { selfGC, player.PlayerData.citizenid })
        elseif data.paymentType == 'cash' then
            player.Functions.AddMoney('cash', selfPrice, 'vehicle-purchase-rollback')
        else
            player.Functions.AddMoney('bank', selfPrice, 'vehicle-purchase-rollback')
        end
        MySQL.update('UPDATE vehicle_stock SET stock = stock + 1 WHERE shop = ? AND vehicle = ?', { shop, data.vehicle })
        if data.paymentType ~= 'gc' then
            exports['Renewed-Banking']:removeAccountMoney(Config.BankAccount, selfPrice, 'Purchase Rollback')
        end
        return false, 'Lỗi tạo xe! Đã hoàn tiền.'
    end

    MySQL.insert(
        'INSERT INTO dealership_self_purchases (shop, citizenid, vehicle, plate, price, payment_type) VALUES (?, ?, ?, ?, ?, ?)',
        { shop, player.PlayerData.citizenid, data.vehicle, plate, finalPrice, data.paymentType }
    )

    SendDiscordLog({
        saleType      = 'self',
        shopName      = shopData.ShopLabel or shop,
        vehicle       = data.vehicle,
        plate         = plate,
        buyerName     = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname,
        buyerCitizenId = player.PlayerData.citizenid,
        price         = finalPrice,
        paymentType   = data.paymentType,
        color         = data.color or 0
    })

    TriggerClientEvent('tommy-dealership:client:SpawnVehicle', source, { model = data.vehicle, plate = plate, color = data.color or 0 }, shop)

    return true, Locale['vehicle_purchased'] or 'Đã mua xe thành công!'
end)

lib.callback.register('tommy-dealership:server:GetShowroomVehicles', function(source, shop)
    local result   = MySQL.query.await('SELECT slot, vehicle, color FROM dealership_showroom WHERE shop = ?', { shop })
    local vehicles = {}
    for _, row in ipairs(result) do
        vehicles[row.slot] = { vehicle = row.vehicle, color = row.color or 0 }
    end
    return vehicles
end)

lib.callback.register('tommy-dealership:server:GetDealershipData', function(source, shop)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return nil end

    local data = {
        shop             = shop,
        shopLabel        = Config.Shops[shop] and Config.Shops[shop].ShopLabel or shop,
        playerGrade      = player.PlayerData.job.grade.level,
        showroomVehicles = {},
        stock            = {},
        sales            = {},
        totalSales       = 0,
        totalCommission  = 0
    }

    local showroom = MySQL.query.await('SELECT slot, vehicle, color FROM dealership_showroom WHERE shop = ?', { shop })
    for _, row in ipairs(showroom) do
        data.showroomVehicles['slot_' .. tonumber(row.slot)] = { slot = tonumber(row.slot), vehicle = row.vehicle, color = row.color or 0 }
    end

    local stock = MySQL.query.await(
        'SELECT vehicle, stock, price, gc_price, allow_self_purchase, description FROM vehicle_stock WHERE shop = ?',
        { shop }
    )
    for _, row in ipairs(stock) do
        data.stock[#data.stock + 1] = {
            vehicle           = row.vehicle,
            stock             = row.stock,
            price             = row.price,
            gcPrice           = row.gc_price or 0,
            allowSelfPurchase = row.allow_self_purchase == 1 or row.allow_self_purchase == true,
            description       = row.description,
            label             = GetVehicleLabel(row.vehicle)
        }
    end

    if player.PlayerData.job.grade.level >= Config.ManagementGrade then
        data.sales = MySQL.query.await('SELECT * FROM dealership_sales WHERE shop = ? ORDER BY sold_at DESC LIMIT 50', { shop })

        local totals = MySQL.query.await('SELECT SUM(price) as ts, SUM(commission) as tc FROM dealership_sales WHERE shop = ?', { shop })
        if totals[1] then
            data.totalSales      = totals[1].ts or 0
            data.totalCommission = totals[1].tc or 0
        end

        local selfPurchases = MySQL.query.await([[
            SELECT sp.*,
                CONCAT(JSON_UNQUOTE(JSON_EXTRACT(p.charinfo, '$.firstname')), ' ', JSON_UNQUOTE(JSON_EXTRACT(p.charinfo, '$.lastname'))) as buyer_name
            FROM dealership_self_purchases sp
            LEFT JOIN players p ON p.citizenid COLLATE utf8mb4_unicode_ci = sp.citizenid COLLATE utf8mb4_unicode_ci
            WHERE sp.shop = ?
            ORDER BY sp.purchased_at DESC LIMIT 50
        ]], { shop })
        data.selfPurchases = selfPurchases or {}

        local spTotal = MySQL.query.await('SELECT SUM(price) as total FROM dealership_self_purchases WHERE shop = ?', { shop })
        data.totalSelfPurchase = (spTotal[1] and spTotal[1].total) or 0
    end

    return data
end)

lib.callback.register('tommy-dealership:server:SellVehicle', function(source, shop, data)
    local player = exports.qbx_core:GetPlayer(source)
    local target = exports.qbx_core:GetPlayer(data.targetId)

    if not player or not target then return false, Locale['player_not_found'] end
    if player.PlayerData.job.name ~= Config.DealerJob then return false, Locale['not_dealer'] end

    if type(data.vehicle) ~= 'string' or type(data.paymentType) ~= 'string' then
        return false, 'Invalid data'
    end

    local affected = MySQL.update.await(
        'UPDATE vehicle_stock SET stock = stock - 1 WHERE shop = ? AND vehicle = ? AND stock >= 1',
        { shop, data.vehicle }
    )
    if affected == 0 then return false, Locale['not_enough_stock'] or 'Hết hàng!' end

    local stockRow = MySQL.query.await('SELECT price, gc_price FROM vehicle_stock WHERE shop = ? AND vehicle = ?', { shop, data.vehicle })
    if not stockRow[1] then
        MySQL.update('UPDATE vehicle_stock SET stock = stock + 1 WHERE shop = ? AND vehicle = ?', { shop, data.vehicle })
        return false, Locale['vehicle_not_found'] or 'Không tìm thấy xe!'
    end

    local price      = stockRow[1].price
    local gcPrice    = stockRow[1].gc_price or 0
    local finalPrice = price

    local hasEnough = false
    if data.paymentType == 'gc' then
        if gcPrice <= 0 then
            MySQL.update('UPDATE vehicle_stock SET stock = stock + 1 WHERE shop = ? AND vehicle = ?', { shop, data.vehicle })
            return false, Locale['gc_not_available'] or 'Xe này không hỗ trợ thanh toán DE-Coin!'
        end
        finalPrice = gcPrice
        hasEnough  = GetPlayerCoin(target.PlayerData.citizenid) >= gcPrice
    elseif data.paymentType == 'cash' then
        hasEnough = target.PlayerData.money.cash >= price
    else
        hasEnough = target.PlayerData.money.bank >= price
    end

    if not hasEnough then
        MySQL.update('UPDATE vehicle_stock SET stock = stock + 1 WHERE shop = ? AND vehicle = ?', { shop, data.vehicle })
        return false, Locale['not_enough_money'] or 'Không đủ tiền!'
    end

    local removed = false
    if data.paymentType == 'gc' then
        removed = RemovePlayerCoin(target.PlayerData.citizenid, gcPrice)
    elseif data.paymentType == 'cash' then
        removed = target.Functions.RemoveMoney('cash', price, 'vehicle-bought')
    else
        removed = target.Functions.RemoveMoney('bank', price, 'vehicle-bought')
    end

    if not removed then
        MySQL.update('UPDATE vehicle_stock SET stock = stock + 1 WHERE shop = ? AND vehicle = ?', { shop, data.vehicle })
        return false, Locale['not_enough_money'] or 'Lỗi trừ tiền!'
    end

    local commission        = 0
    local commissionPercent = 0

    if data.paymentType ~= 'gc' then
        local rate          = Config.Commission[player.PlayerData.job.grade.level] or 0.02
        commission          = math.floor(price * rate)
        commissionPercent   = rate * 100
        player.Functions.AddMoney('bank', commission, 'vehicle-sold-commission')
        TriggerClientEvent('ox_lib:notify', source, {
            description = ('Hoa hồng: $%s (%s%%) đã được chuyển vào tài khoản'):format(commission, commissionPercent),
            type = 'success'
        })
        exports['Renewed-Banking']:addAccountMoney(Config.BankAccount, price, 'Employee Sale: ' .. data.vehicle)
    else
        TriggerClientEvent('ox_lib:notify', source, { description = 'Bán xe thành công! (Thanh toán DE-Coin - Không hoa hồng)', type = 'success' })
    end

    local plate = GeneratePlate()
    local mods  = json.encode({ color1 = data.color or 0, color2 = data.color or 0, pearlescentColor = data.color or 0, wheelColor = data.color or 0 })

    local insertId = MySQL.insert.await(
        'INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        { target.PlayerData.license, target.PlayerData.citizenid, data.vehicle, GetHashKey(data.vehicle), mods, plate, Config.DefaultGarage, 0 }
    )

    if not insertId then
        if data.paymentType == 'gc' then
            MySQL.update('UPDATE derp_coin SET coin = coin + ? WHERE citizenid = ?', { gcPrice, target.PlayerData.citizenid })
        elseif data.paymentType == 'cash' then
            target.Functions.AddMoney('cash', price, 'vehicle-purchase-rollback')
        else
            target.Functions.AddMoney('bank', price, 'vehicle-purchase-rollback')
        end
        if data.paymentType ~= 'gc' then
            player.Functions.RemoveMoney('bank', commission, 'commission-rollback')
            exports['Renewed-Banking']:removeAccountMoney(Config.BankAccount, price, 'Sale Rollback')
        end
        MySQL.update('UPDATE vehicle_stock SET stock = stock + 1 WHERE shop = ? AND vehicle = ?', { shop, data.vehicle })
        return false, 'Lỗi tạo xe! Đã hoàn tiền.'
    end

    MySQL.insert(
        'INSERT INTO dealership_sales (shop, seller_citizenid, seller_name, buyer_citizenid, buyer_name, vehicle, plate, price, commission, payment_type) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        {
            shop,
            player.PlayerData.citizenid,
            player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname,
            target.PlayerData.citizenid,
            target.PlayerData.charinfo.firstname .. ' ' .. target.PlayerData.charinfo.lastname,
            data.vehicle, plate, finalPrice, commission, data.paymentType
        }
    )

    SendDiscordLog({
        saleType        = 'dealer',
        shopName        = Config.Shops[shop].ShopLabel or shop,
        vehicle         = data.vehicle,
        plate           = plate,
        sellerName      = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname,
        sellerCitizenId = player.PlayerData.citizenid,
        buyerName       = target.PlayerData.charinfo.firstname .. ' ' .. target.PlayerData.charinfo.lastname,
        buyerCitizenId  = target.PlayerData.citizenid,
        price           = finalPrice,
        commission      = commission > 0 and commission or nil,
        commissionPercent = commissionPercent > 0 and commissionPercent or nil,
        paymentType     = data.paymentType,
        color           = data.color or 0
    })

    TriggerClientEvent('ox_lib:notify', data.targetId, { description = Locale['vehicle_purchased'], type = 'success' })
    TriggerClientEvent('tommy-dealership:client:SpawnVehicle', data.targetId, { model = data.vehicle, plate = plate, color = data.color or 0 }, shop)

    return true, Locale['vehicle_sold']
end)

lib.callback.register('tommy-dealership:server:StartTestDrive', function(source, shop, data)
    local player = exports.qbx_core:GetPlayer(source)
    local target = exports.qbx_core:GetPlayer(data.targetId)

    if not player or not target then return false, Locale['player_not_found'] end
    if player.PlayerData.job.name ~= Config.DealerJob then return false, Locale['not_dealer'] end

    local stockRow = MySQL.query.await('SELECT stock FROM vehicle_stock WHERE shop = ? AND vehicle = ?', { shop, data.vehicle })
    if not stockRow[1] or stockRow[1].stock < 1 then return false, Locale['not_enough_stock'] end

    -- Dùng targetId làm bucket riêng, tránh conflict nhiều người test drive cùng lúc
    local bucket = 10000 + data.targetId
    SetPlayerRoutingBucket(data.targetId, bucket)

    TriggerClientEvent('tommy-dealership:client:StartTestDriveForCustomer', data.targetId, data.vehicle, data.color, Config.TestDriveTimeLimit * 60, shop)
    return true, Locale['test_drive_started'] or 'Test drive bắt đầu!'
end)

RegisterNetEvent('tommy-dealership:server:EndTestDrive', function(shop)
    local src      = source
    local shopData = Config.Shops[shop]
    SetPlayerRoutingBucket(src, 0)
    TriggerClientEvent('tommy-dealership:client:EndTestDrive', src, shopData.ReturnLocation)
end)

lib.callback.register('tommy-dealership:server:RestockVehicle', function(source, shop, data)
    local player = exports.qbx_core:GetPlayer(source)
    if not player                                              then return false, Locale['player_not_found'] end
    if player.PlayerData.job.name ~= Config.DealerJob         then return false, Locale['not_dealer']       end
    if player.PlayerData.job.grade.level < Config.ManagementGrade then return false, Locale['no_permission'] end

    MySQL.update(
        'UPDATE vehicle_stock SET stock = stock + ?, price = ?, gc_price = ? WHERE shop = ? AND vehicle = ?',
        { data.amount, data.price, data.gcPrice or 0, shop, data.vehicle }
    )
    return true, Locale['stock_updated']
end)

lib.callback.register('tommy-dealership:server:ImportVehicle', function(source, shop, data)
    local player = exports.qbx_core:GetPlayer(source)
    if not player                                              then return false, Locale['player_not_found'] end
    if player.PlayerData.job.name ~= Config.DealerJob         then return false, Locale['not_dealer']       end
    if player.PlayerData.job.grade.level < Config.ManagementGrade then return false, Locale['no_permission'] end

    if type(data.vehicle) ~= 'string' or not SharedVehicles[data.vehicle] then
        return false, Locale['invalid_vehicle']
    end

    local exists = MySQL.scalar.await('SELECT id FROM vehicle_stock WHERE shop = ? AND vehicle = ?', { shop, data.vehicle })
    if exists then
        MySQL.update(
            'UPDATE vehicle_stock SET stock = stock + ?, description = ? WHERE shop = ? AND vehicle = ?',
            { data.quantity, data.description or '', shop, data.vehicle }
        )
    else
        MySQL.insert(
            'INSERT INTO vehicle_stock (shop, vehicle, stock, price, gc_price, allow_self_purchase, description) VALUES (?, ?, ?, ?, ?, ?, ?)',
            { shop, data.vehicle, data.quantity, data.price or 0, data.gcPrice or 0, 0, data.description or '' }
        )
    end
    return true, Locale['vehicle_imported']
end)

lib.callback.register('tommy-dealership:server:UpdateVehicleDescription', function(source, shop, data)
    local player = exports.qbx_core:GetPlayer(source)
    if not player                                              then return false, Locale['player_not_found'] end
    if player.PlayerData.job.name ~= Config.DealerJob         then return false, Locale['not_dealer']       end
    if player.PlayerData.job.grade.level < Config.ManagementGrade then return false, Locale['no_permission'] end

    local affected = MySQL.update.await(
        'UPDATE vehicle_stock SET description = ? WHERE shop = ? AND vehicle = ?',
        { data.description or '', shop, data.vehicle }
    )
    if affected > 0 then return true, Locale['description_updated'] or 'Đã cập nhật mô tả thành công!' end
    return false, Locale['update_failed'] or 'Cập nhật thất bại!'
end)

lib.callback.register('tommy-dealership:server:ChangeShowroomVehicle', function(source, shop, data)
    local player = exports.qbx_core:GetPlayer(source)
    if not player                              then return false, Locale['player_not_found'] end
    if player.PlayerData.job.name ~= Config.DealerJob then return false, Locale['not_dealer'] end

    local stockRow = MySQL.query.await('SELECT stock FROM vehicle_stock WHERE shop = ? AND vehicle = ?', { shop, data.vehicle })
    if not stockRow[1] or stockRow[1].stock < 1 then return false, Locale['not_enough_stock'] end

    local color  = data.color or Config.VehicleColors[math.random(#Config.VehicleColors)].colorindex
    local exists = MySQL.scalar.await('SELECT id FROM dealership_showroom WHERE shop = ? AND slot = ?', { shop, data.slot })

    if exists then
        MySQL.update('UPDATE dealership_showroom SET vehicle = ?, color = ? WHERE shop = ? AND slot = ?', { data.vehicle, color, shop, data.slot })
    else
        MySQL.insert('INSERT INTO dealership_showroom (shop, slot, vehicle, color) VALUES (?, ?, ?, ?)', { shop, data.slot, data.vehicle, color })
    end

    TriggerClientEvent('tommy-dealership:client:UpdateShowroomVehicle', -1, shop, data.slot, data.vehicle, color)
    return true, Locale['showroom_updated']
end)

lib.callback.register('tommy-dealership:server:ChangeShowroomColor', function(source, shop, data)
    local player = exports.qbx_core:GetPlayer(source)
    if not player                              then return false, Locale['player_not_found'] end
    if player.PlayerData.job.name ~= Config.DealerJob then return false, Locale['not_dealer'] end

    MySQL.update('UPDATE dealership_showroom SET color = ? WHERE shop = ? AND slot = ?', { data.color, shop, data.slot })

    local row = MySQL.scalar.await('SELECT vehicle FROM dealership_showroom WHERE shop = ? AND slot = ?', { shop, data.slot })
    if row then
        TriggerClientEvent('tommy-dealership:client:UpdateShowroomVehicle', -1, shop, data.slot, row, data.color)
    end
    return true, 'Color changed successfully'
end)

lib.callback.register('tommy-dealership:server:ClearShowroomSlot', function(source, shop, data)
    local player = exports.qbx_core:GetPlayer(source)
    if not player                              then return false, Locale['player_not_found'] end
    if player.PlayerData.job.name ~= Config.DealerJob then return false, Locale['not_dealer'] end

    MySQL.update('UPDATE dealership_showroom SET vehicle = NULL, color = 0 WHERE shop = ? AND slot = ?', { shop, data.slot })
    TriggerClientEvent('tommy-dealership:client:UpdateShowroomVehicle', -1, shop, data.slot, nil, 0)
    return true, Locale['showroom_updated']
end)

lib.callback.register('tommy-dealership:server:GetPlayerNames', function(source, playerIds)
    local names = {}
    for _, info in ipairs(playerIds) do
        local p = exports.qbx_core:GetPlayer(info.id)
        if p then
            local ci = p.PlayerData.charinfo
            names[info.id] = (ci and ci.firstname and ci.lastname)
                and (ci.firstname .. ' ' .. ci.lastname)
                or  ('Player ' .. info.id)
        else
            names[info.id] = 'Player ' .. info.id
        end
    end
    return names
end)

lib.callback.register('tommy-dealership:server:GetNearbyPlayers', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return {} end

    local playerPed    = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)
    local players      = {}

    players[#players + 1] = {
        id       = source,
        name     = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname .. ' (Me)',
        distance = 0
    }

    for _, pid in pairs(GetPlayers()) do
        local targetId = tonumber(pid)          
        if targetId and targetId ~= source then
            local tp = exports.qbx_core:GetPlayer(targetId)
            if tp then
                local tCoords = GetEntityCoords(GetPlayerPed(targetId))
                local dist    = #(playerCoords - tCoords)
                if dist < 10.0 then
                    players[#players + 1] = {
                        id       = targetId,
                        name     = tp.PlayerData.charinfo.firstname .. ' ' .. tp.PlayerData.charinfo.lastname,
                        distance = math.floor(dist)
                    }
                end
            end
        end
    end

    return players
end)

lib.callback.register('tommy-dealership:server:UpdateVehiclePrice', function(source, shop, data)
    local player = exports.qbx_core:GetPlayer(source)
    if not player                                              then return false, Locale['player_not_found'] end
    if player.PlayerData.job.name ~= Config.DealerJob         then return false, Locale['not_dealer']       end
    if player.PlayerData.job.grade.level < Config.ManagementGrade then return false, Locale['no_permission'] end
    if not data.price or data.price < 0                        then return false, Locale['invalid_price'] or 'Giá không hợp lệ' end

    local affected = MySQL.update.await(
        'UPDATE vehicle_stock SET price = ? WHERE shop = ? AND vehicle = ?',
        { data.price, shop, data.vehicle }
    )
    if affected > 0 then return true, Locale['price_updated'] or 'Đã cập nhật giá thành công!' end
    return false, Locale['update_failed'] or 'Cập nhật thất bại!'
end)

lib.callback.register('tommy-dealership:server:UpdateVehicleGCPrice', function(source, shop, data)
    local player = exports.qbx_core:GetPlayer(source)
    if not player                                              then return false, Locale['player_not_found'] end
    if player.PlayerData.job.name ~= Config.DealerJob         then return false, Locale['not_dealer']       end
    if player.PlayerData.job.grade.level < Config.ManagementGrade then return false, Locale['no_permission'] end
    if data.gcPrice == nil or data.gcPrice < 0                 then return false, Locale['invalid_price'] or 'Giá DE-Coin không hợp lệ' end

    local affected = MySQL.update.await(
        'UPDATE vehicle_stock SET gc_price = ? WHERE shop = ? AND vehicle = ?',
        { data.gcPrice, shop, data.vehicle }
    )
    if affected > 0 then return true, Locale['gc_price_updated'] or 'Đã cập nhật giá DE-Coin thành công!' end
    return false, Locale['update_failed'] or 'Cập nhật thất bại!'
end)