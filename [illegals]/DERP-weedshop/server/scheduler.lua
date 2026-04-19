Scheduler = {}

-- Set track order da gui late reminder (in-memory, reset khi restart)
local remindedOrders = {}

-- Tick moi 15s check: orders vao late (reminder), orders qua het han (fail), listings het han
local function ExpireTick()
    local now = os.time()
    local ontimeSec = Config.DeliveryWindows.ontimeWindowMinutes * 60
    local lateSec = Config.DeliveryWindows.lateWindowMinutes * 60

    -- Lay tat ca order pending + deadline_at unix seconds
    local orders = MySQL.query.await([[
        SELECT id, citizenid, npc_id, UNIX_TIMESTAMP(deadline_at) AS deadline_unix
        FROM derp_weed_orders WHERE status = 'pending'
    ]], {})
    if orders then
        for i = 1, #orders do
            local o = orders[i]
            local deadlineTs = tonumber(o.deadline_unix) or 0
            local lateStart = deadlineTs + ontimeSec
            local failAt = deadlineTs + ontimeSec + lateSec

            -- Qua thoi gian late -> fail
            if now >= failAt then
                Orders.FailOrder(o.id, 'expired')
                remindedOrders[o.id] = nil
            -- Vao giai doan late -> gui reminder (1 lan)
            elseif now >= lateStart and not remindedOrders[o.id] then
                remindedOrders[o.id] = true
                local template = Utils.PickTemplate('late_reminder')
                if template then
                    Customers.InsertMessage(o.citizenid, o.npc_id, 'npc', template, 'text', {
                        order_id = o.id,
                        kind = 'late_reminder'
                    })
                    local src = GetSourceByCitizenId(o.citizenid)
                    if src then
                        TriggerClientEvent('derp-weedshop:client:newMessage', src, { npcId = o.npc_id })
                    end
                end
            end
        end
    end

    -- Expire listings het han
    MySQL.update.await([[
        UPDATE derp_weed_listings
        SET status = 'expired'
        WHERE status = 'active' AND expires_at < NOW()
    ]], {})
end

-- Tick: NPC random nhan tin cho listings active
local function BuyerMatchTick()
    local listings = MySQL.query.await([[
        SELECT l.id, l.citizenid, l.item, l.amount, l.price_per_unit
        FROM derp_weed_listings l
        WHERE l.status = 'active' AND l.expires_at > NOW()
    ]], {})

    if not listings or #listings == 0 then return end

    for i = 1, #listings do
        local listing = listings[i]
        local unlocked = Relationship.GetUnlockedNPCIds(listing.citizenid)
        if #unlocked > 0 then
            local avgTrust = 0
            for _, npcId in ipairs(unlocked) do
                avgTrust = avgTrust + Relationship.GetTrust(listing.citizenid, npcId)
            end
            avgTrust = avgTrust / #unlocked

            local chance = Config.Customer.messageChanceBase + (avgTrust * Config.Customer.messageChancePerTrust)
            if math.random() < chance then
                local npcId = Customers.PickBuyerFor(listing.citizenid, listing)
                if npcId then
                    local ok = Customers.CreateInitialOffer(listing.citizenid, npcId, listing)
                    if ok then
                        local src = GetSourceByCitizenId(listing.citizenid)
                        if src then
                            TriggerClientEvent('derp-weedshop:client:newMessage', src, { npcId = npcId })
                        end
                    end
                end
            end
        end
    end
end

function GetSourceByCitizenId(citizenid)
    if not citizenid then return nil end
    local players = exports.qbx_core:GetQBPlayers()
    for src, player in pairs(players) do
        if player.PlayerData.citizenid == citizenid then
            return tonumber(src)
        end
    end
    return nil
end

-- Cleanup tracking khi order ket thuc
function Scheduler.ClearRemindedOrder(orderId)
    remindedOrders[orderId] = nil
end

CreateThread(function()
    Wait(10000)
    while true do
        local ok, err = pcall(ExpireTick)
        if not ok and Config.Debug then
            print('[derp-weedshop] ExpireTick error:', err)
        end
        Wait(15000)
    end
end)

CreateThread(function()
    Wait(15000)
    while true do
        local ok, err = pcall(BuyerMatchTick)
        if not ok and Config.Debug then
            print('[derp-weedshop] BuyerMatchTick error:', err)
        end
        Wait(Config.Customer.messageTickSeconds * 1000)
    end
end)

_G.Scheduler = Scheduler
_G.GetSourceByCitizenId = GetSourceByCitizenId