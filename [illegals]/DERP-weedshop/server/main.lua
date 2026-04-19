local ox_inventory = exports.ox_inventory

-- ==================== HELPERS ====================

function GetCitizenId(src)
    if not src or src <= 0 then return nil end
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return nil end
    return player.PlayerData.citizenid
end

-- Tra ve so ngay game (kieu epoch day) dua tren real time
-- Dung de reset daily counter mỗi ngày game
-- 1 ngay game = 24 * 60 phut game = 24 * 60 * GameToRealSecondsRatio giay real
function GetCurrentGameDayNumber()
    local secondsPerGameDay = 24 * 60 * Config.GameToRealSecondsRatio
    return math.floor(os.time() / secondsPerGameDay)
end

function NotifyPlayer(src, title, desc, type)
    TriggerClientEvent('ox_lib:notify', src, {
        title = title,
        description = desc,
        type = type or 'inform'
    })
end

function IsValidItem(itemName)
    return Config.Items[itemName] ~= nil
end

function HasItemCount(src, itemName, amount)
    if not src or not itemName or not amount then return false end
    local count = ox_inventory:Search(src, 'count', itemName)
    return type(count) == 'number' and count >= amount
end

-- Liet ke items weed player co trong inv
function ListMyWeedItems(src)
    local result = {}
    for itemName, cfg in pairs(Config.Items) do
        local count = ox_inventory:Search(src, 'count', itemName)
        if type(count) == 'number' and count > 0 then
            result[#result + 1] = {
                name = itemName,
                label = cfg.label,
                count = count,
                priceMin = cfg.priceMin,
                priceMax = cfg.priceMax
            }
        end
    end
    return result
end

-- Enrich listing voi label
function EnrichListings(listings)
    if not listings then return {} end
    for i = 1, #listings do
        local cfg = Config.Items[listings[i].item]
        listings[i].item_label = cfg and cfg.label or listings[i].item
    end
    return listings
end

-- Enrich order voi npc name + location + label + unix deadline
function EnrichOrders(orders)
    if not orders then return {} end
    for i = 1, #orders do
        local loc = Locations.GetByIdx(orders[i].location_idx)
        orders[i].location = loc and {
            label = loc.label,
            coords = { x = loc.coords.x, y = loc.coords.y, z = loc.coords.z, w = loc.coords.w }
        } or nil
        local cfg = Config.Items[orders[i].item]
        orders[i].item_label = cfg and cfg.label or orders[i].item
        local npc = NPCs.GetById(orders[i].npc_id)
        if npc then
            orders[i].npc = {
                id = npc.id,
                name = npc.name,
                ped = npc.ped
            }
            orders[i].npc_name = npc.name
        else
            orders[i].npc_name = 'NPC #' .. orders[i].npc_id
        end
        -- Convert deadline_at -> unix seconds cho client countdown chinh xac
        if orders[i].deadline_at then
            if type(orders[i].deadline_at) == 'string' then
                orders[i].deadline_unix = Orders.ParseMySQLTimestamp(orders[i].deadline_at)
            elseif type(orders[i].deadline_at) == 'number' then
                -- Neu la ms (>1e12) -> chuyen ve giay
                local v = orders[i].deadline_at
                orders[i].deadline_unix = v > 1e12 and math.floor(v / 1000) or v
            end
        end
    end
    return orders
end

-- Enrich conversations voi npc_name
function EnrichConversations(convs)
    if not convs then return {} end
    for i = 1, #convs do
        local npc = NPCs.GetById(convs[i].npc_id)
        convs[i].npc_name = npc and npc.name or ('NPC #' .. convs[i].npc_id)
    end
    return convs
end

function RemoveItem(src, itemName, amount)
    if not src or not itemName or not amount then return false end
    return ox_inventory:RemoveItem(src, itemName, amount)
end

function AddBlackMoney(src, amount)
    if not src or not amount or amount <= 0 then return false end
    return ox_inventory:AddItem(src, Config.BlackMoneyItem, amount)
end

-- ==================== STATS ====================

function GetOrCreateStats(citizenid)
    if not citizenid then return nil end
    local row = MySQL.single.await('SELECT * FROM derp_weed_stats WHERE citizenid = ?', { citizenid })
    if not row then
        MySQL.insert.await(
            'INSERT INTO derp_weed_stats (citizenid) VALUES (?)',
            { citizenid }
        )
        return {
            citizenid = citizenid, total_earned = 0, total_deals = 0,
            successful_deals = 0, total_trust_points = 0,
            deals_today = 0, last_deal_date = nil
        }
    end
    return row
end

function IncrementDealsToday(citizenid)
    if not citizenid then return end
    MySQL.update.await([[
        INSERT INTO derp_weed_stats (citizenid, deals_today, last_deal_date)
        VALUES (?, 1, CURDATE())
        ON DUPLICATE KEY UPDATE
            deals_today = IF(last_deal_date = CURDATE(), deals_today + 1, 1),
            last_deal_date = CURDATE()
    ]], { citizenid })
end

function GetDealsToday(citizenid)
    if not citizenid then return 0 end
    local row = MySQL.single.await([[
        SELECT deals_today FROM derp_weed_stats
        WHERE citizenid = ? AND last_deal_date = CURDATE()
    ]], { citizenid })
    return row and row.deals_today or 0
end

function AddEarnings(citizenid, amount)
    if not citizenid or not amount then return end
    MySQL.update.await(
        'UPDATE derp_weed_stats SET total_earned = total_earned + ?, successful_deals = successful_deals + 1 WHERE citizenid = ?',
        { amount, citizenid }
    )
end

function IncrementTotalDeals(citizenid)
    if not citizenid then return end
    MySQL.update.await(
        'UPDATE derp_weed_stats SET total_deals = total_deals + 1 WHERE citizenid = ?',
        { citizenid }
    )
end

-- Anti-abuse cooldown tracking
local playerCooldowns = {}

function CheckCooldown(src, key, seconds)
    local now = GetGameTimer()
    local pc = playerCooldowns[src]
    if not pc then
        playerCooldowns[src] = {}
        pc = playerCooldowns[src]
    end
    if pc[key] and now - pc[key] < seconds * 1000 then
        return false
    end
    pc[key] = now
    return true
end

function ClearCooldowns(src)
    playerCooldowns[src] = nil
end

-- ==================== INIT ====================

CreateThread(function()
    Wait(2000)
    if Config.Debug then
        print('[derp-weedshop] Initialized. NPCs:', #NPCs, '| Locations:', #Locations)
    end
end)

-- Cleanup khi player drop
AddEventHandler('playerDropped', function()
    local src = source
    ClearCooldowns(src)
end)

-- ==================== OX_LIB CALLBACKS ====================

-- Lay toan bo initial data khi mo app
lib.callback.register('derp-weedshop:server:getInitialData', function(src)
    local citizenid = GetCitizenId(src)
    if not citizenid then return nil end

    GetOrCreateStats(citizenid)

    local itemsList = ListMyWeedItems(src)

    return {
        stats = MySQL.single.await('SELECT * FROM derp_weed_stats WHERE citizenid = ?', { citizenid }),
        listings = EnrichListings(Orders.GetActiveListings(citizenid)),
        orders = EnrichOrders(Orders.GetPendingOrders(citizenid)),
        contacts = Relationship.GetUnlockedNPCsWithTrust(citizenid),
        conversations = EnrichConversations(Customers.GetConversations(citizenid)),
        unreadCount = Customers.GetUnreadCount(citizenid),
        myItems = itemsList,
        config = {
            deliveryPresets = Config.DeliveryPresets,
            maxActiveOrders = Config.MaxActiveOrders,
            maxDealsPerDay = Config.MaxDealsPerDay,
            listingDurationMinutes = Config.ListingDurationMinutes
        }
    }
end)

-- Lay items cua player trong inventory
lib.callback.register('derp-weedshop:server:getMyItems', function(src)
    return ListMyWeedItems(src)
end)

-- Dang listing moi
lib.callback.register('derp-weedshop:server:createListing', function(src, data)
    local citizenid = GetCitizenId(src)
    if not citizenid then return { ok = false, msg = 'Khong xac dinh' } end

    if not CheckCooldown(src, 'createListing', 3) then
        return { ok = false, msg = 'Thao Tác Quá Nhanh' }
    end

    if not data or type(data) ~= 'table' then
        return { ok = false, msg = 'Du lieu khong hop le' }
    end

    local ok, result = Orders.CreateListing(src, citizenid, data.item, data.amount, data.pricePerUnit)
    if not ok then return { ok = false, msg = result } end
    return { ok = true, listingId = result }
end)

-- Huy listing
lib.callback.register('derp-weedshop:server:cancelListing', function(src, listingId)
    local citizenid = GetCitizenId(src)
    if not citizenid then return { ok = false } end
    if not CheckCooldown(src, 'cancelListing', 2) then
        return { ok = false, msg = 'Thao Tác Quá Nhanh' }
    end
    local ok = Orders.CancelListing(citizenid, listingId)
    return { ok = ok }
end)

-- Lay listings
lib.callback.register('derp-weedshop:server:getListings', function(src)
    local citizenid = GetCitizenId(src)
    if not citizenid then return {} end
    return EnrichListings(Orders.GetActiveListings(citizenid))
end)

-- Lay orders
lib.callback.register('derp-weedshop:server:getOrders', function(src)
    local citizenid = GetCitizenId(src)
    if not citizenid then return {} end
    return EnrichOrders(Orders.GetPendingOrders(citizenid))
end)

-- Lay contacts
lib.callback.register('derp-weedshop:server:getContacts', function(src)
    local citizenid = GetCitizenId(src)
    if not citizenid then return {} end
    return Relationship.GetUnlockedNPCsWithTrust(citizenid)
end)

-- Lay conversations
lib.callback.register('derp-weedshop:server:getConversations', function(src)
    local citizenid = GetCitizenId(src)
    if not citizenid then return {} end
    return EnrichConversations(Customers.GetConversations(citizenid))
end)

-- Lay messages cua 1 conversation
lib.callback.register('derp-weedshop:server:getMessages', function(src, npcId)
    local citizenid = GetCitizenId(src)
    if not citizenid or not npcId then return {} end

    -- Check co unlock NPC nay khong
    if not Relationship.HasUnlocked(citizenid, npcId) then return {} end

    local msgs = Customers.GetMessages(citizenid, npcId, 100)
    Customers.MarkRead(citizenid, npcId)

    local npc = NPCs.GetById(npcId)
    local deal = Customers.GetActiveDeal(citizenid, npcId)

    local dealData = nil
    if deal then
        local itemCfg = Config.Items[deal.item]
        dealData = {
            round = deal.round,
            maxRounds = Config.Customer.maxCounterRounds,
            currentOffer = deal.currentOffer,
            amount = deal.amount,
            item = deal.item,
            itemLabel = itemCfg and itemCfg.label or deal.item,
            marketPrice = itemCfg and math.floor((itemCfg.priceMin + itemCfg.priceMax) / 2) or nil,
            lastActor = deal.lastActor,
            accepted = deal.accepted or false,
            hasLocation = deal.locationIdx ~= nil
        }
    end

    return {
        messages = msgs,
        npc = npc and { id = npc.id, name = npc.name, personality = npc.personality } or nil,
        activeDeal = dealData,
        trust = Relationship.GetTrust(citizenid, npcId)
    }
end)

-- Player gui counter
lib.callback.register('derp-weedshop:server:deal:counter', function(src, data)
    local citizenid = GetCitizenId(src)
    if not citizenid then return { ok = false } end
    if not CheckCooldown(src, 'dealCounter', 2) then
        return { ok = false, msg = 'Thao Tác Quá Nhanh' }
    end
    if not data or not data.npcId or not data.price then
        return { ok = false, msg = 'Thieu data' }
    end
    local ok, result = Customers.PlayerCounter(citizenid, data.npcId, data.price)
    return { ok = ok, result = result }
end)

-- Player accept gia hien tai -> tao pre-order, tra ve de client chon delivery time
lib.callback.register('derp-weedshop:server:deal:accept', function(src, data)
    local citizenid = GetCitizenId(src)
    if not citizenid then return { ok = false } end
    if not data or not data.npcId then return { ok = false, msg = 'Thieu data' } end
    if not CheckCooldown(src, 'dealAccept', 2) then
        return { ok = false, msg = 'Thao Tác Quá Nhanh' }
    end

    local deal = Customers.GetActiveDeal(citizenid, data.npcId)
    if not deal then return { ok = false, msg = 'Khong co deal' } end
    if deal.lastActor == 'player' then return { ok = false, msg = 'Dang cho NPC' } end

    deal.accepted = true
    Customers.SetActiveDeal(citizenid, data.npcId, deal)

    -- Propose location
    local loc = Orders.ProposeLocation(citizenid, data.npcId)
    if not loc then return { ok = false, msg = 'Khong co dia diem' } end

    -- Tin nhan temp
    local playerAcceptTpl = Utils.PickTemplate('player_accept')
    Customers.InsertMessage(citizenid, data.npcId, 'player', playerAcceptTpl, 'text', nil)

    return {
        ok = true,
        needsDeliveryTime = true,
        location = { idx = loc.idx, label = loc.label },
        deliveryPresets = Config.DeliveryPresets
    }
end)

-- Player confirm delivery time -> finalize order
lib.callback.register('derp-weedshop:server:deal:confirmDelivery', function(src, data)
    local citizenid = GetCitizenId(src)
    if not citizenid then return { ok = false } end
    if not data or not data.npcId or not data.deliveryMinutes then
        return { ok = false, msg = 'Thieu data' }
    end

    local deal = Customers.GetActiveDeal(citizenid, data.npcId)
    if not deal or not deal.accepted then
        return { ok = false, msg = 'Deal chua accept' }
    end

    local ok, result = Orders.CreateFromDeal(citizenid, data.npcId, deal, data.deliveryMinutes)
    if not ok then return { ok = false, msg = result } end
    return { ok = true, orderId = result }
end)

-- Player decline
lib.callback.register('derp-weedshop:server:deal:decline', function(src, data)
    local citizenid = GetCitizenId(src)
    if not citizenid then return { ok = false } end
    if not data or not data.npcId then return { ok = false } end
    local ok = Customers.PlayerDecline(citizenid, data.npcId)
    return { ok = ok }
end)

-- Huy order
lib.callback.register('derp-weedshop:server:cancelOrder', function(src, orderId)
    local citizenid = GetCitizenId(src)
    if not citizenid then return { ok = false } end
    if not CheckCooldown(src, 'cancelOrder', 3) then
        return { ok = false, msg = 'Thao Tác Quá Nhanh' }
    end
    local ok, msg = Orders.CancelOrder(citizenid, orderId)
    return { ok = ok, msg = msg }
end)

-- Giao hang (goi tu client khi interact NPC)
lib.callback.register('derp-weedshop:server:deliver', function(src, orderId)
    if not CheckCooldown(src, 'deliver', Config.AntiAbuse.deliverCooldownSeconds) then
        return { ok = false, msg = 'Thao Tác Quá Nhanh' }
    end
    local ok, result, payout = Orders.DeliverOrder(src, orderId)
    return { ok = ok, status = result, payout = payout }
end)

-- Tra ve order data cho client (khi can spawn NPC)
lib.callback.register('derp-weedshop:server:getOrderForDelivery', function(src, orderId)
    local citizenid = GetCitizenId(src)
    if not citizenid then return nil end
    local order = Orders.GetOrder(orderId)
    if not order or order.citizenid ~= citizenid then return nil end
    if order.status ~= 'pending' then return nil end

    local npc = NPCs.GetById(order.npc_id)
    local loc = Locations.GetByIdx(order.location_idx)
    return {
        id = order.id,
        item = order.item,
        amount = order.amount,
        total_price = order.total_price,
        location = loc and { idx = loc.idx, label = loc.label,
            coords = { x = loc.coords.x, y = loc.coords.y, z = loc.coords.z, w = loc.coords.w } } or nil,
        npc = npc and { id = npc.id, name = npc.name, ped = npc.ped } or nil,
        deadline_at = order.deadline_at
    }
end)

-- Dispatch PD (client trigger khi vao radius)
RegisterNetEvent('derp-weedshop:server:triggerDispatch', function(data)
    local src = source
    if not src or src <= 0 then return end
    if not data or not data.coords or not data.streetLabel then return end
    if not CheckCooldown(src, 'dispatch', 60) then return end

    -- Random chance
    if math.random() > Config.DispatchChance then return end

    if not exports['lb-tablet'] then return end

    exports['lb-tablet']:AddDispatch({
        priority = 'medium',
        code = Config.DispatchCode,
        title = Config.DispatchTitle,
        description = Config.DispatchDescription .. ' tai ' .. (data.streetLabel or 'khong xac dinh'),
        location = {
            label = data.streetLabel or 'Khong xac dinh',
            coords = vec2(data.coords.x, data.coords.y)
        },
        time = 180,
        job = 'police',
        fields = {
            { icon = 'fas fa-map-marker-alt', label = 'Vi tri', value = data.streetLabel or 'Khong ro' }
        },
        blip = {
            sprite = 469,
            color = 2,
            size = 1.3,
            label = Config.DispatchTitle
        }
    })
end)