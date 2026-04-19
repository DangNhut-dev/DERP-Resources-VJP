Relationship = {}

-- Lay toan bo relationship cua player
function Relationship.GetAll(citizenid)
    if not citizenid then return {} end
    local rows = MySQL.query.await(
        'SELECT * FROM derp_weed_relationships WHERE citizenid = ? ORDER BY trust DESC',
        { citizenid }
    )
    return rows or {}
end

-- Lay trust cua player voi 1 NPC
function Relationship.GetTrust(citizenid, npcId)
    if not citizenid or not npcId then return 0 end
    local row = MySQL.single.await(
        'SELECT trust FROM derp_weed_relationships WHERE citizenid = ? AND npc_id = ?',
        { citizenid, npcId }
    )
    return row and row.trust or 0
end

-- Tong trust cua player
function Relationship.GetTotalTrust(citizenid)
    if not citizenid then return 0 end
    local row = MySQL.single.await(
        'SELECT COALESCE(SUM(trust), 0) AS total FROM derp_weed_relationships WHERE citizenid = ? AND trust > 0',
        { citizenid }
    )
    return row and tonumber(row.total) or 0
end

-- Dam bao relationship record ton tai
function Relationship.Ensure(citizenid, npcId)
    if not citizenid or not npcId then return end
    MySQL.update.await([[
        INSERT INTO derp_weed_relationships (citizenid, npc_id, trust)
        VALUES (?, ?, 0)
        ON DUPLICATE KEY UPDATE citizenid = citizenid
    ]], { citizenid, npcId })
end

-- Cap nhat trust (delta co the am/duong)
function Relationship.UpdateTrust(citizenid, npcId, delta)
    if not citizenid or not npcId or not delta then return 0 end
    Relationship.Ensure(citizenid, npcId)
    MySQL.update.await([[
        UPDATE derp_weed_relationships
        SET trust = GREATEST(0, LEAST(100, trust + ?)),
            last_deal_at = NOW()
        WHERE citizenid = ? AND npc_id = ?
    ]], { delta, citizenid, npcId })
    return Relationship.GetTrust(citizenid, npcId)
end

-- Tang so deal + update daily counter + last_completed_at
function Relationship.IncrementDeals(citizenid, npcId, success)
    if not citizenid or not npcId then return end
    -- Lay ngay game hien tai
    local gameDay = _G.GetCurrentGameDayNumber and GetCurrentGameDayNumber() or 0

    if success then
        MySQL.update.await([[
            UPDATE derp_weed_relationships
            SET total_deals = total_deals + 1,
                successful_deals = successful_deals + 1,
                deals_today = IF(deals_today_game_day = ?, deals_today + 1, 1),
                deals_today_game_day = ?,
                last_completed_at = NOW()
            WHERE citizenid = ? AND npc_id = ?
        ]], { gameDay, gameDay, citizenid, npcId })
    else
        MySQL.update.await([[
            UPDATE derp_weed_relationships
            SET total_deals = total_deals + 1,
                deals_today = IF(deals_today_game_day = ?, deals_today + 1, 1),
                deals_today_game_day = ?,
                last_completed_at = NOW()
            WHERE citizenid = ? AND npc_id = ?
        ]], { gameDay, gameDay, citizenid, npcId })
    end
end

-- Check NPC co ban khong: cooldown chua het hoac daily limit dat roi
-- return: busy (bool), reason (string)
function Relationship.IsNPCBusy(citizenid, npcId)
    if not citizenid or not npcId then return true, 'invalid' end
    local row = MySQL.single.await([[
        SELECT deals_today, deals_today_game_day, last_completed_at,
            TIMESTAMPDIFF(SECOND, last_completed_at, NOW()) AS seconds_since
        FROM derp_weed_relationships
        WHERE citizenid = ? AND npc_id = ?
    ]], { citizenid, npcId })

    if not row then return false end -- Chua co relationship -> NPC moi

    -- Daily limit check (chi ap dung cho ngay game hien tai)
    local gameDay = _G.GetCurrentGameDayNumber and GetCurrentGameDayNumber() or 0
    if row.deals_today_game_day == gameDay and row.deals_today >= Config.Customer.maxDealsPerNpcPerDay then
        return true, 'daily_limit'
    end

    -- Cooldown check
    if row.last_completed_at and row.seconds_since then
        local cooldownSeconds = Config.Customer.npcCooldownGameMinutes * Config.GameToRealSecondsRatio
        if row.seconds_since < cooldownSeconds then
            return true, 'cooldown'
        end
    end

    return false
end

-- Sync total_trust_points trong stats
function Relationship.SyncTotalPoints(citizenid)
    if not citizenid then return 0 end
    local total = Relationship.GetTotalTrust(citizenid)
    MySQL.update.await(
        'UPDATE derp_weed_stats SET total_trust_points = ? WHERE citizenid = ?',
        { total, citizenid }
    )
    return total
end

-- Lay danh sach NPC da unlock cho player
function Relationship.GetUnlockedNPCIds(citizenid)
    if not citizenid then return {} end
    local total = Relationship.GetTotalTrust(citizenid)
    local unlockCount = Utils.GetUnlockedCount(total)
    local ids = {}
    for i = 1, unlockCount do
        if NPCs[i] then ids[#ids + 1] = NPCs[i].id end
    end
    return ids
end

-- Lay full data unlocked NPCs + trust
function Relationship.GetUnlockedNPCsWithTrust(citizenid)
    if not citizenid then return {} end
    local total = Relationship.GetTotalTrust(citizenid)
    local unlockCount = Utils.GetUnlockedCount(total)
    local rels = Relationship.GetAll(citizenid)
    local trustMap = {}
    for i = 1, #rels do
        trustMap[rels[i].npc_id] = rels[i]
    end

    local list = {}
    for i = 1, unlockCount do
        local npc = NPCs[i]
        if npc then
            local rel = trustMap[npc.id]
            list[#list + 1] = {
                id = npc.id,
                name = npc.name,
                personality = npc.personality,
                trust = rel and rel.trust or 0,
                total_deals = rel and rel.total_deals or 0,
                successful_deals = rel and rel.successful_deals or 0,
                last_deal_at = rel and rel.last_deal_at or nil
            }
        end
    end
    return list
end

-- Check player co unlock NPC nay chua
function Relationship.HasUnlocked(citizenid, npcId)
    if not citizenid or not npcId then return false end
    local unlocked = Relationship.GetUnlockedNPCIds(citizenid)
    for i = 1, #unlocked do
        if unlocked[i] == npcId then return true end
    end
    return false
end

_G.Relationship = Relationship