Orders = {}

-- ==================== LISTINGS ====================

function Orders.CountActiveListings(citizenid)
    if not citizenid then return 0 end
    local row = MySQL.single.await(
        "SELECT COUNT(*) AS c FROM derp_weed_listings WHERE citizenid = ? AND status = 'active'",
        { citizenid }
    )
    return row and row.c or 0
end

function Orders.GetActiveListings(citizenid)
    if not citizenid then return {} end
    local rows = MySQL.query.await([[
        SELECT id, item, amount, price_per_unit, created_at, expires_at
        FROM derp_weed_listings
        WHERE citizenid = ? AND status = 'active' AND expires_at > NOW()
        ORDER BY created_at DESC
    ]], { citizenid })
    return rows or {}
end

function Orders.CreateListing(src, citizenid, itemName, amount, pricePerUnit)
    if not src or not citizenid or not itemName or not amount or not pricePerUnit then
        return false, 'Thieu du lieu'
    end

    local item = Config.Items[itemName]
    if not item then return false, 'Item khong hop le' end

    amount = tonumber(amount)
    pricePerUnit = tonumber(pricePerUnit)
    if not amount or not pricePerUnit then return false, 'Du lieu khong hop le' end
    if amount < 1 or amount > 1000 then return false, 'So luong khong hop le' end
    if pricePerUnit < 1 then return false, 'Gia phai lon hon 0' end

    -- Check player co du hang
    if not HasItemCount(src, itemName, amount) then
        return false, 'Khong du hang trong tui'
    end

    -- Check gioi han active orders (listings + pending orders)
    local activeCount = Orders.CountActiveListings(citizenid) + Orders.CountPendingOrders(citizenid)
    if activeCount >= Config.MaxActiveOrders then
        return false, string.format('Toi da %d order cung luc', Config.MaxActiveOrders)
    end

    -- Insert
    local expiresAtMs = os.time() + (Config.ListingDurationMinutes * 60)
    local insertId = MySQL.insert.await([[
        INSERT INTO derp_weed_listings (citizenid, item, amount, price_per_unit, expires_at)
        VALUES (?, ?, ?, ?, FROM_UNIXTIME(?))
    ]], { citizenid, itemName, amount, pricePerUnit, expiresAtMs })

    if not insertId then return false, 'Loi DB' end
    return true, insertId
end

function Orders.CancelListing(citizenid, listingId)
    if not citizenid or not listingId then return false end
    local affected = MySQL.update.await([[
        UPDATE derp_weed_listings
        SET status = 'cancelled'
        WHERE id = ? AND citizenid = ? AND status = 'active'
    ]], { listingId, citizenid })
    return affected and affected > 0
end

function Orders.GetListing(listingId)
    if not listingId then return nil end
    return MySQL.single.await(
        'SELECT * FROM derp_weed_listings WHERE id = ?',
        { listingId }
    )
end

function Orders.MarkListingSold(listingId)
    MySQL.update.await(
        "UPDATE derp_weed_listings SET status = 'sold' WHERE id = ?",
        { listingId }
    )
end

-- ==================== ORDERS ====================

function Orders.CountPendingOrders(citizenid)
    if not citizenid then return 0 end
    local row = MySQL.single.await(
        "SELECT COUNT(*) AS c FROM derp_weed_orders WHERE citizenid = ? AND status = 'pending'",
        { citizenid }
    )
    return row and row.c or 0
end

function Orders.GetPendingOrders(citizenid)
    if not citizenid then return {} end
    local rows = MySQL.query.await([[
        SELECT id, listing_id, npc_id, item, amount, price_per_unit, total_price,
               location_idx, deadline_at, created_at
        FROM derp_weed_orders
        WHERE citizenid = ? AND status = 'pending'
        ORDER BY deadline_at ASC
    ]], { citizenid })
    return rows or {}
end

function Orders.GetOrder(orderId)
    if not orderId then return nil end
    return MySQL.single.await('SELECT * FROM derp_weed_orders WHERE id = ?', { orderId })
end

-- Sau khi NPC accept, order duoc tao voi location mac dinh va cho player chon deadline
-- Flow: create order (pending chon deadline) -> player chon preset -> commit
-- De don gian: tao luon voi deadline default, player co the dieu chinh tren client
-- Cach khac: tao order ngay voi location, client send preset -> server update deadline
-- Toi se theo cach 2: NPC accept -> return location + yeu cau client gui deliveryMinutes

-- Buoc 1: chi luu deal accepted (trong memory activeDeal), return location proposal
function Orders.ProposeLocation(citizenid, npcId)
    local deal = Customers.GetActiveDeal(citizenid, npcId)
    if not deal or not deal.accepted then return nil end

    -- Lay danh sach location index dang bi chiem (order pending toan server)
    local busyIdx = {}
    local rows = MySQL.query.await([[
        SELECT DISTINCT location_idx FROM derp_weed_orders WHERE status = 'pending'
    ]])
    if rows then
        for i = 1, #rows do
            busyIdx[tonumber(rows[i].location_idx)] = true
        end
    end

    -- Cong them location dang duoc propose (accepted + locationIdx) tu activeDeals in-memory
    local proposedIdx = Customers.GetProposedLocationIndices()
    for _, idx in ipairs(proposedIdx) do busyIdx[idx] = true end

    -- Tim location rảnh
    local loc = Locations.GetRandomExcluding(busyIdx)
    -- Fallback: neu het thi dung random bat ky (chap nhan trung)
    if not loc then
        loc = Locations.GetRandom()
        if not loc then return nil end
    end

    deal.locationIdx = loc.idx
    Customers.SetActiveDeal(citizenid, npcId, deal)
    return loc
end

-- Buoc 2: player confirm voi deliveryMinutes -> tao order thuc su
function Orders.CreateFromDeal(citizenid, npcId, deal, deliveryMinutes)
    -- Neu chua co deliveryMinutes, chi tao "accepted" state va cho
    if not deliveryMinutes then
        deal.accepted = true
        Customers.SetActiveDeal(citizenid, npcId, deal)
        return true, 'waiting_delivery_time'
    end

    deliveryMinutes = tonumber(deliveryMinutes)
    if not deliveryMinutes then return false, 'Invalid time' end

    -- Validate preset
    local validPreset = false
    for i = 1, #Config.DeliveryPresets do
        if Config.DeliveryPresets[i] == deliveryMinutes then
            validPreset = true
            break
        end
    end
    if not validPreset then return false, 'Thoi gian khong hop le' end

    -- Propose location neu chua co
    if not deal.locationIdx then
        local loc = Locations.GetRandom()
        if not loc then return false, 'Khong co dia diem' end
        deal.locationIdx = loc.idx
    end

    local item = Config.Items[deal.item]
    if not item then return false, 'Item loi' end

    -- Proactive: NPC tra thap hon, apply multiplier
    local effectivePrice = deal.currentOffer
    if deal.proactive then
        effectivePrice = math.floor(deal.currentOffer * Config.Customer.proactiveCallPayoutMultiplier)
    end
    local totalPrice = deal.amount * effectivePrice
    -- Deadline theo phut REAL (khong con game time)
    local deadlineSeconds = deliveryMinutes * 60
    local deadlineUnix = os.time() + deadlineSeconds

    local orderId = MySQL.insert.await([[
        INSERT INTO derp_weed_orders
        (listing_id, citizenid, npc_id, item, amount, price_per_unit, total_price, location_idx, deadline_at, status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, FROM_UNIXTIME(?), 'pending')
    ]], {
        deal.listingId, citizenid, npcId, deal.item,
        deal.amount, effectivePrice, totalPrice,
        deal.locationIdx, deadlineUnix
    })

    if not orderId then return false, 'Loi DB' end

    -- Trir so luong khoi listing (neu co - proactive khong co listing)
    if deal.listingId then
        local listing = Orders.GetListing(deal.listingId)
        if listing then
            if listing.amount <= deal.amount then
                Orders.MarkListingSold(deal.listingId)
            else
                MySQL.update.await(
                    'UPDATE derp_weed_listings SET amount = amount - ? WHERE id = ?',
                    { deal.amount, deal.listingId }
                )
            end
        end
    end

    -- Gui tin nhan accept + location (text thuong, full info)
    local loc = Locations.GetByIdx(deal.locationIdx)

    if deal.proactive then
        -- Proactive: player xac nhan truoc, NPC confirm sau (realistic)
        local playerConfirmTpl = Utils.PickTemplate('proactive_player_confirm')
        if playerConfirmTpl then
            Customers.InsertMessage(citizenid, npcId, 'player',
                string.format(playerConfirmTpl, loc.label, deliveryMinutes),
                'text', nil
            )
        end
    end

    local acceptTplKey = deal.proactive and 'proactive_accept' or 'accept'
    local acceptTemplate = Utils.PickTemplate(acceptTplKey)
    local msg = string.format(acceptTemplate, loc.label, deliveryMinutes)
    Customers.InsertMessage(citizenid, npcId, 'npc', msg, 'text', {
        order_id = orderId,
        location_idx = deal.locationIdx,
        location_label = loc.label,
        deadline_minutes = deliveryMinutes,
        total_price = totalPrice,
        proactive = deal.proactive or nil
    })

    Customers.ClearActiveDeal(citizenid, npcId)
    IncrementTotalDeals(citizenid)

    -- Broadcast cho player khac thay NPC + location
    if _G.BroadcastForeignOrderAdd then
        local order = Orders.GetOrder(orderId)
        local ownerSrc = _G.GetSourceByCitizenId and GetSourceByCitizenId(citizenid)
        if order then BroadcastForeignOrderAdd(order, ownerSrc) end
    end

    return true, orderId
end

function Orders.CancelOrder(citizenid, orderId)
    if not citizenid or not orderId then return false, 'Thieu data' end
    local order = Orders.GetOrder(orderId)
    if not order then return false, 'Order khong ton tai' end
    if order.citizenid ~= citizenid then return false, 'Khong phai cua ban' end
    if order.status ~= 'pending' then return false, 'Order da ket thuc' end

    MySQL.update.await(
        "UPDATE derp_weed_orders SET status = 'cancelled', completed_at = NOW() WHERE id = ?",
        { orderId }
    )

    Relationship.UpdateTrust(citizenid, order.npc_id, Config.TrustChanges.cancelled)
    Relationship.IncrementDeals(citizenid, order.npc_id, false)

    local template = Utils.PickTemplate('cancelled')
    Customers.InsertMessage(citizenid, order.npc_id, 'npc', template, 'text', nil)

    -- Broadcast remove foreign order
    if _G.BroadcastForeignOrderRemove then
        local ownerSrc = _G.GetSourceByCitizenId and GetSourceByCitizenId(citizenid)
        BroadcastForeignOrderRemove(orderId, ownerSrc)
    end
    return true
end

-- ==================== DELIVERY ====================

-- Server validate va xu ly giao hang
-- src: source
-- orderId: order ID
-- return: success, message, payout
function Orders.DeliverOrder(src, orderId)
    local citizenid = GetCitizenId(src)
    if not citizenid then return false, 'Khong xac dinh player' end

    local order = Orders.GetOrder(orderId)
    if not order then return false, 'Order khong ton tai' end
    if order.citizenid ~= citizenid then return false, 'Khong phai cua ban' end
    if order.status ~= 'pending' then return false, 'Order da ket thuc' end

    -- Check hang trong tui
    if not HasItemCount(src, order.item, order.amount) then
        return false, 'Khong du hang'
    end

    -- Check radius
    local loc = Locations.GetByIdx(order.location_idx)
    if not loc then return false, 'Location loi' end
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return false, 'Ped loi' end
    local coords = GetEntityCoords(ped)
    local dist = #(coords - vector3(loc.coords.x, loc.coords.y, loc.coords.z))
    if dist > Config.DeliveryRadius then
        return false, 'Khong o dia diem hen'
    end

    -- Tinh window hien tai
    local now = os.time()
    local deadlineTs = order.deadline_at
    if type(deadlineTs) == 'string' then
        deadlineTs = Orders.ParseMySQLTimestamp(deadlineTs)
    elseif type(deadlineTs) == 'number' then
        -- oxmysql co the tra ve ms (>1e12) - convert ve seconds
        if deadlineTs > 1e12 then
            deadlineTs = math.floor(deadlineTs / 1000)
        end
    end

    local earlySec = Config.DeliveryWindows.earlyWindowMinutes * 60
    local ontimeSec = Config.DeliveryWindows.ontimeWindowMinutes * 60
    local lateSec = Config.DeliveryWindows.lateWindowMinutes * 60

    local status, multiplier, trustDelta
    -- Truoc deadline - earlyWindow: chua toi gio, khong cho giao
    if now < (deadlineTs - earlySec) then
        return false, 'Chua toi gio giao'
    -- [deadline - earlyWindow, deadline): giao som
    elseif now < deadlineTs then
        status = 'delivered_early'
        multiplier = Config.Payout.earlyMultiplier
        trustDelta = Config.TrustChanges.delivered_early
    -- [deadline, deadline + ontimeWindow): dung gio
    elseif now < (deadlineTs + ontimeSec) then
        status = 'delivered_ontime'
        multiplier = Config.Payout.onTimeMultiplier
        trustDelta = Config.TrustChanges.delivered_ontime
    -- [deadline + ontimeWindow, deadline + ontimeWindow + lateWindow): tre
    elseif now < (deadlineTs + ontimeSec + lateSec) then
        status = 'delivered_late'
        multiplier = Config.Payout.lateMultiplier
        trustDelta = Config.TrustChanges.delivered_late
    else
        -- Qua tre, fail
        Orders.FailOrder(orderId, 'too_late')
        return false, 'Qua tre, don bi huy'
    end

    -- Tru hang
    if not RemoveItem(src, order.item, order.amount) then
        return false, 'Khong tru duoc hang'
    end

    -- Cong tien
    local payout = math.floor(order.total_price * multiplier)
    AddBlackMoney(src, payout)

    -- Update DB
    MySQL.update.await([[
        UPDATE derp_weed_orders
        SET status = ?, final_payout = ?, completed_at = NOW()
        WHERE id = ?
    ]], { status, payout, orderId })

    -- Update relationship
    Relationship.UpdateTrust(citizenid, order.npc_id, trustDelta)
    Relationship.IncrementDeals(citizenid, order.npc_id, true)
    Relationship.SyncTotalPoints(citizenid)

    AddEarnings(citizenid, payout)
    IncrementDealsToday(citizenid)

    -- Message
    local templateKey = status == 'delivered_early' and 'delivered_early'
                    or status == 'delivered_late' and 'delivered_late'
                    or 'delivered_ontime'
    local template = Utils.PickTemplate(templateKey)
    Customers.InsertMessage(citizenid, order.npc_id, 'npc', template, 'text', {
        order_id = orderId,
        payout = payout,
        status = status
    })

    -- Log action cho js_ranking (chi log ban hang, khong log khac)
    if _G.LogWeedSale then
        LogWeedSale(src, order, payout, status)
    end

    -- Broadcast remove foreign order cho player khac
    if _G.BroadcastForeignOrderRemove then
        BroadcastForeignOrderRemove(orderId, src)
    end

    return true, status, payout
end

function Orders.FailOrder(orderId, reason)
    local order = Orders.GetOrder(orderId)
    if not order then return end
    if order.status ~= 'pending' then return end

    MySQL.update.await([[
        UPDATE derp_weed_orders
        SET status = 'failed', completed_at = NOW()
        WHERE id = ?
    ]], { orderId })

    Relationship.UpdateTrust(order.citizenid, order.npc_id, Config.TrustChanges.failed)
    Relationship.IncrementDeals(order.citizenid, order.npc_id, false)
    Relationship.SyncTotalPoints(order.citizenid)

    local template = Utils.PickTemplate('failed')
    Customers.InsertMessage(order.citizenid, order.npc_id, 'npc', template, 'text', {
        order_id = orderId,
        reason = reason
    })

    -- Cleanup scheduler tracking
    if _G.Scheduler and Scheduler.ClearRemindedOrder then
        Scheduler.ClearRemindedOrder(orderId)
    end

    -- Notify client despawn NPC
    local src = _G.GetSourceByCitizenId and GetSourceByCitizenId(order.citizenid)
    if src then
        TriggerClientEvent('derp-weedshop:client:orderEnded', src, orderId)
        TriggerClientEvent('derp-weedshop:client:newMessage', src, { npcId = order.npc_id })
    end

    -- Broadcast remove foreign order cho player khac
    if _G.BroadcastForeignOrderRemove then
        BroadcastForeignOrderRemove(orderId, src)
    end
end

-- Parse MySQL timestamp string -> unix
function Orders.ParseMySQLTimestamp(str)
    if not str or type(str) ~= 'string' then return 0 end
    local y, mo, d, h, mi, s = str:match('(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)')
    if not y then return 0 end
    return os.time({
        year = tonumber(y), month = tonumber(mo), day = tonumber(d),
        hour = tonumber(h), min = tonumber(mi), sec = tonumber(s)
    })
end

_G.Orders = Orders