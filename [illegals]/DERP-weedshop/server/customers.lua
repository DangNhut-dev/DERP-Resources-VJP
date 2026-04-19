Customers = {}

-- In-memory: active deal sessions (khong can persistent, reset khi restart)
-- key = citizenid .. ':' .. npcId
-- value = { listingId, item, amount, currentOffer, round, lastActor, createdAt }
local activeDeals = {}

local function DealKey(citizenid, npcId)
    return citizenid .. ':' .. npcId
end

-- ==================== MESSAGES ====================

function Customers.InsertMessage(citizenid, npcId, sender, message, msgType, metadata)
    if not citizenid or not npcId or not sender or not message then return nil end
    return MySQL.insert.await([[
        INSERT INTO derp_weed_messages
        (citizenid, npc_id, sender, message, message_type, metadata)
        VALUES (?, ?, ?, ?, ?, ?)
    ]], { citizenid, npcId, sender, message, msgType or 'text', metadata and json.encode(metadata) or nil })
end

function Customers.GetMessages(citizenid, npcId, limit)
    if not citizenid or not npcId then return {} end
    -- Lay N messages gan nhat (DESC), sau do dao lai ASC de hien thi theo thu tu
    local rows = MySQL.query.await([[
        SELECT id, sender, message, message_type, metadata, created_at, read_at
        FROM (
            SELECT id, sender, message, message_type, metadata, created_at, read_at
            FROM derp_weed_messages
            WHERE citizenid = ? AND npc_id = ?
            ORDER BY id DESC
            LIMIT ?
        ) t
        ORDER BY id ASC
    ]], { citizenid, npcId, limit or 100 })

    if not rows then return {} end
    for i = 1, #rows do
        local r = rows[i]
        if r.metadata and type(r.metadata) == 'string' then
            local ok, decoded = pcall(json.decode, r.metadata)
            r.metadata = ok and decoded or nil
        end
    end
    return rows
end

function Customers.GetConversations(citizenid)
    if not citizenid then return {} end
    local rows = MySQL.query.await([[
        SELECT
            m.npc_id,
            m.message AS last_message,
            m.sender AS last_sender,
            m.message_type AS last_type,
            m.created_at AS last_at,
            (SELECT COUNT(*) FROM derp_weed_messages
             WHERE citizenid = m.citizenid AND npc_id = m.npc_id
             AND sender = 'npc' AND read_at IS NULL) AS unread_count
        FROM derp_weed_messages m
        INNER JOIN (
            SELECT npc_id, MAX(id) AS max_id
            FROM derp_weed_messages
            WHERE citizenid = ?
            GROUP BY npc_id
        ) latest ON m.id = latest.max_id
        WHERE m.citizenid = ?
        ORDER BY m.created_at DESC
    ]], { citizenid, citizenid })
    return rows or {}
end

function Customers.MarkRead(citizenid, npcId)
    if not citizenid or not npcId then return end
    MySQL.update.await([[
        UPDATE derp_weed_messages
        SET read_at = NOW()
        WHERE citizenid = ? AND npc_id = ? AND sender = 'npc' AND read_at IS NULL
    ]], { citizenid, npcId })
end

function Customers.GetUnreadCount(citizenid)
    if not citizenid then return 0 end
    local row = MySQL.single.await([[
        SELECT COUNT(*) AS c FROM derp_weed_messages
        WHERE citizenid = ? AND sender = 'npc' AND read_at IS NULL
    ]], { citizenid })
    return row and row.c or 0
end

-- ==================== DEAL SESSIONS ====================

function Customers.GetActiveDeal(citizenid, npcId)
    return activeDeals[DealKey(citizenid, npcId)]
end

function Customers.SetActiveDeal(citizenid, npcId, data)
    activeDeals[DealKey(citizenid, npcId)] = data
end

function Customers.ClearActiveDeal(citizenid, npcId)
    activeDeals[DealKey(citizenid, npcId)] = nil
end

-- ==================== NPC SENDS INITIAL OFFER ====================

-- Tao offer khoi tao tu NPC khi "find buyer"
function Customers.CreateInitialOffer(citizenid, npcId, listing)
    if not citizenid or not npcId or not listing then
        if Config.Debug then print('[weedshop] CreateInitialOffer: thieu param') end
        return false
    end

    local npc = NPCs.GetById(npcId)
    if not npc then
        if Config.Debug then print('[weedshop] CreateInitialOffer: NPC #' .. npcId .. ' khong ton tai') end
        return false
    end

    local item = Config.Items[listing.item]
    if not item then
        if Config.Debug then
            print('[weedshop] CreateInitialOffer: item "' .. tostring(listing.item) .. '" khong co trong Config.Items')
        end
        return false
    end

    local trust = Relationship.GetTrust(citizenid, npcId)

    -- NPC random so luong muon mua (trong gioi han listing)
    local minAmt = math.max(Config.Customer.offerAmountMin, 1)
    local maxAmt = math.min(Config.Customer.offerAmountMax, listing.amount)
    if minAmt > maxAmt then
        if Config.Debug then
            print(('[weedshop] CreateInitialOffer: so luong khong hop le (listing.amount=%d, min=%d)'):format(
                listing.amount, Config.Customer.offerAmountMin))
        end
        return false
    end
    local amount = math.random(minAmt, maxAmt)

    -- NPC offer gia thap hon listing (chua counter)
    local listingPrice = listing.price_per_unit
    local acceptable = Utils.CalculateAcceptablePrice(trust, item)
    local initialOffer = math.min(listingPrice, acceptable) * (0.75 + math.random() * 0.15)
    initialOffer = math.max(item.priceMin, math.floor(initialOffer))

    -- 1 tin nhan duy nhat (text), co du item + amount + price
    local offerTpl = Utils.PickTemplate('initial_offer')
    local msg = string.format(offerTpl, amount, item.label, initialOffer)
    Customers.InsertMessage(citizenid, npcId, 'npc', msg, 'text', nil)

    -- Luu active deal
    Customers.SetActiveDeal(citizenid, npcId, {
        listingId = listing.id,
        item = listing.item,
        amount = amount,
        currentOffer = initialOffer,
        round = 0,
        lastActor = 'npc',
        createdAt = os.time()
    })

    return true
end

-- ==================== PLAYER COUNTERS ====================

function Customers.PlayerCounter(citizenid, npcId, newPrice)
    local deal = Customers.GetActiveDeal(citizenid, npcId)
    if not deal then return false, 'Deal khong ton tai' end
    if deal.lastActor == 'player' then return false, 'Dang cho NPC phan hoi' end
    if deal.round >= Config.Customer.maxCounterRounds then
        return false, 'Het luot counter'
    end

    local item = Config.Items[deal.item]
    if not item then return false, 'Item loi' end
    newPrice = math.floor(tonumber(newPrice) or 0)
    if newPrice <= 0 then
        return false, 'Gia khong hop le'
    end

    -- Player gui counter (text thuong)
    local playerTpl = Utils.PickTemplate('counter_player')
    Customers.InsertMessage(citizenid, npcId, 'player',
        string.format(playerTpl, newPrice),
        'text',
        nil
    )

    deal.round = deal.round + 1
    deal.lastActor = 'player'

    -- NPC quyet dinh: accept / counter / walk away
    local trust = Relationship.GetTrust(citizenid, npcId)
    local acceptable = Utils.CalculateAcceptablePrice(trust, item)
    local acceptThreshold = acceptable * Config.Customer.acceptThreshold

    -- Gia qua cao (> 1.5x acceptable) -> NPC tu choi thang, khong counter
    if newPrice > acceptable * 1.5 then
        Customers.NPCDecline(citizenid, npcId)
        return true, 'declined'
    end

    if newPrice <= acceptThreshold then
        -- Accept
        deal.currentOffer = newPrice
        deal.lastActor = 'npc'
        deal.accepted = true
        Customers.SetActiveDeal(citizenid, npcId, deal)
        Customers.NPCAccept(citizenid, npcId, deal)
        return true, 'accepted'
    elseif deal.round >= Config.Customer.maxCounterRounds then
        -- NPC walk away
        Customers.NPCDecline(citizenid, npcId)
        return true, 'declined'
    else
        -- NPC counter
        local reduction = (newPrice - deal.currentOffer) * Config.Customer.counterReduction
        local counterPrice = math.floor(deal.currentOffer + reduction)
        counterPrice = math.max(item.priceMin, counterPrice)
        deal.currentOffer = counterPrice
        deal.lastActor = 'npc'
        Customers.SetActiveDeal(citizenid, npcId, deal)

        local template = Utils.PickTemplate('counter_npc')
        local msg = string.format(template, counterPrice)
        Customers.InsertMessage(citizenid, npcId, 'npc', msg, 'text', nil)
        return true, 'countered'
    end
end

function Customers.PlayerAccept(citizenid, npcId)
    local deal = Customers.GetActiveDeal(citizenid, npcId)
    if not deal then return false, 'Khong co deal' end
    if deal.lastActor == 'player' then return false, 'Dang cho NPC phan hoi' end

    -- Player accept gia hien tai -> NPC chot
    deal.accepted = true
    Customers.SetActiveDeal(citizenid, npcId, deal)
    return Customers.NPCAccept(citizenid, npcId, deal)
end

function Customers.PlayerDecline(citizenid, npcId)
    local deal = Customers.GetActiveDeal(citizenid, npcId)
    if not deal then return false, 'Khong co deal' end

    local playerTpl = Utils.PickTemplate('player_decline')
    Customers.InsertMessage(citizenid, npcId, 'player', playerTpl, 'text', nil)
    local npcTpl = Utils.PickTemplate('decline')
    Customers.InsertMessage(citizenid, npcId, 'npc', npcTpl, 'text', nil)

    Relationship.UpdateTrust(citizenid, npcId, Config.TrustChanges.counter_refused)
    Customers.ClearActiveDeal(citizenid, npcId)
    return true
end

-- ==================== NPC ACCEPT -> TAO ORDER ====================

function Customers.NPCAccept(citizenid, npcId, deal)
    return Orders.CreateFromDeal(citizenid, npcId, deal)
end

function Customers.NPCDecline(citizenid, npcId)
    local template = Utils.PickTemplate('decline')
    Customers.InsertMessage(citizenid, npcId, 'npc', template, 'text', nil)
    Relationship.UpdateTrust(citizenid, npcId, Config.TrustChanges.counter_refused)
    Customers.ClearActiveDeal(citizenid, npcId)
end

-- ==================== MATCHING - GHEP NPC VOI LISTING ====================

-- Chon 1 NPC phu hop de nhan tin cho player
-- return: npcId hoac nil
function Customers.PickBuyerFor(citizenid, listing)
    local item = Config.Items[listing.item]
    if not item then return nil end

    local unlocked = Relationship.GetUnlockedNPCIds(citizenid)
    if #unlocked == 0 then return nil end

    -- Lay danh sach NPC dang co pending order voi player (1 query)
    local busyOrderNpcs = {}
    local pending = MySQL.query.await(
        "SELECT DISTINCT npc_id FROM derp_weed_orders WHERE citizenid = ? AND status = 'pending'",
        { citizenid }
    )
    if pending then
        for i = 1, #pending do
            busyOrderNpcs[tonumber(pending[i].npc_id)] = true
        end
    end

    -- Filter: skip NPC co deal active, pending order, cooldown, hoac het daily limit
    local candidates = {}
    for i = 1, #unlocked do
        local npcId = unlocked[i]
        if not Customers.GetActiveDeal(citizenid, npcId)
            and not busyOrderNpcs[npcId]
            and not Relationship.IsNPCBusy(citizenid, npcId)
        then
            local trust = Relationship.GetTrust(citizenid, npcId)
            if listing.price_per_unit <= item.priceMax * 2 then
                candidates[#candidates + 1] = { id = npcId, trust = trust }
            end
        end
    end

    if #candidates == 0 then return nil end

    -- Weighted random: NPC trust cao co xac suat cao hon
    local totalWeight = 0
    for i = 1, #candidates do
        candidates[i].weight = 10 + candidates[i].trust
        totalWeight = totalWeight + candidates[i].weight
    end
    local roll = math.random() * totalWeight
    local acc = 0
    for i = 1, #candidates do
        acc = acc + candidates[i].weight
        if roll <= acc then return candidates[i].id end
    end
    return candidates[1].id
end

_G.Customers = Customers