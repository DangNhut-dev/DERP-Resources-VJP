Scheduler = {}

-- Tick moi 30s check expired orders va listings
local function ExpireTick()
    -- Fail orders qua deadline
    local expiredOrders = MySQL.query.await([[
        SELECT id, citizenid, npc_id FROM derp_weed_orders
        WHERE status = 'pending' AND deadline_at < NOW()
    ]], {})
    if expiredOrders then
        for i = 1, #expiredOrders do
            Orders.FailOrder(expiredOrders[i].id, 'expired')
        end
    end

    -- Expire listings het han
    MySQL.update.await([[
        UPDATE derp_weed_listings
        SET status = 'expired'
        WHERE status = 'active' AND expires_at < NOW()
    ]], {})
end

-- Tick moi X phut: NPC random nhan tin cho listings active
local function BuyerMatchTick()
    local listings = MySQL.query.await([[
        SELECT l.id, l.citizenid, l.item, l.amount, l.price_per_unit
        FROM derp_weed_listings l
        WHERE l.status = 'active' AND l.expires_at > NOW()
    ]], {})

    if not listings or #listings == 0 then
        if Config.Debug then print('[weedshop] BuyerMatchTick: khong co listing active') end
        return
    end

    if Config.Debug then
        print(('[weedshop] BuyerMatchTick: %d listings active'):format(#listings))
    end

    for i = 1, #listings do
        local listing = listings[i]

        local unlocked = Relationship.GetUnlockedNPCIds(listing.citizenid)
        if #unlocked == 0 then
            if Config.Debug then
                print(('[weedshop]   Listing #%d (%s): player %s chua unlock NPC nao'):format(
                    listing.id, listing.item, listing.citizenid))
            end
        else
            local avgTrust = 0
            for _, npcId in ipairs(unlocked) do
                avgTrust = avgTrust + Relationship.GetTrust(listing.citizenid, npcId)
            end
            avgTrust = avgTrust / #unlocked

            local chance = Config.Customer.messageChanceBase + (avgTrust * Config.Customer.messageChancePerTrust)
            local roll = math.random()
            if Config.Debug then
                print(('[weedshop]   Listing #%d (%s x%d @ $%d/g): %d NPC unlocked, avgTrust=%.1f, chance=%.2f, roll=%.2f'):format(
                    listing.id, listing.item, listing.amount, listing.price_per_unit,
                    #unlocked, avgTrust, chance, roll))
            end

            if roll < chance then
                local npcId = Customers.PickBuyerFor(listing.citizenid, listing)
                if npcId then
                    local ok = Customers.CreateInitialOffer(listing.citizenid, npcId, listing)
                    if Config.Debug then
                        print(('[weedshop]     -> NPC #%d gui offer, ok=%s'):format(npcId, tostring(ok)))
                    end
                    if ok then
                        local src = GetSourceByCitizenId(listing.citizenid)
                        if src then
                            TriggerClientEvent('derp-weedshop:client:newMessage', src, { npcId = npcId })
                        end
                    end
                else
                    if Config.Debug then
                        print('[weedshop]     -> khong NPC nao chiu gia nay (PickBuyerFor tra nil)')
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

CreateThread(function()
    Wait(10000)
    while true do
        local ok, err = pcall(ExpireTick)
        if not ok and Config.Debug then
            print('[derp-weedshop] ExpireTick error:', err)
        end
        Wait(30000)
    end
end)

CreateThread(function()
    Wait(15000)
    while true do
        local ok, err = pcall(BuyerMatchTick)
        if not ok and Config.Debug then
            print('[derp-weedshop] BuyerMatchTick error:', err)
        end
        -- Dung phut game -> giay real
        local waitMs = Config.Customer.messageTickMinutes * Config.GameToRealSecondsRatio * 1000
        Wait(waitMs)
    end
end)

_G.Scheduler = Scheduler
_G.GetSourceByCitizenId = GetSourceByCitizenId