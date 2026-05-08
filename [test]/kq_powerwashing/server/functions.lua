-- server/functions.lua
-- Helper functions used by server.lua

-- ─────────────────────────────────────────────
--  Logging
-- ─────────────────────────────────────────────

function Log(msg, ...)
    if ... then
        msg = string.format(msg, ...)
    end
    print("[kq_powerwashing] " .. tostring(msg))
end

function DebugLog(msg, ...)
    if not Config.debug then return end
    if ... then
        msg = string.format(msg, ...)
    end
    print("[kq_powerwashing][DEBUG] " .. tostring(msg))
end

-- ─────────────────────────────────────────────
--  Job validation
-- ─────────────────────────────────────────────

--- Returns true when the player has the powerwashing job (or no job restriction is set)
function ServerPlayerHasJob(source)
    if not Config.jobName then
        return true
    end
    local ok, job = pcall(function()
        return exports.kq_link:GetPlayerJob(source)
    end)
    if not ok then
        DebugLog("GetPlayerJob failed for player %d: %s", source, tostring(job))
        return false
    end
    return job == Config.jobName
end

-- ─────────────────────────────────────────────
--  Money / reward
-- ─────────────────────────────────────────────

--- Give money to a player via kq_link
function GivePlayerMoney(source, amount)
    if amount <= 0 then return end
    local ok, err = pcall(function()
        exports.kq_link:GiveMoney(source, amount)
    end)
    if not ok then
        DebugLog("GiveMoney failed for player %d: %s", source, tostring(err))
    end
end

--- Give XP to a player via kq_jobcontracts
function GivePlayerJobXp(source, xpAmount)
    if xpAmount <= 0 then return end
    local ok, err = pcall(function()
        exports.kq_jobcontracts:AddJobXp(source, "powerwashing", xpAmount)
    end)
    if not ok then
        DebugLog("AddJobXp failed for player %d: %s", source, tostring(err))
    end
end

--- Get a player's powerwashing job stats (level, xp, etc.)
--- Returns table or nil on failure
function GetPlayerJobStats(source)
    local ok, stats = pcall(function()
        return exports.kq_jobcontracts:GetPlayerJobStats(source, "powerwashing")
    end)
    if not ok or not stats then
        DebugLog("GetPlayerJobStats failed for player %d", source)
        return { level = 1, xp = 0 }
    end
    return stats
end

--- Calculate salary bonus percentage for a player based on their level upgrades
function GetSalaryBonusPercent(playerLevel)
    local best = 0
    if not Config.levelUpgrades then return best end
    for _, upgrade in pairs(Config.levelUpgrades) do
        if upgrade.bonusPercentage and playerLevel >= upgrade.level then
            if upgrade.bonusPercentage > best then
                best = upgrade.bonusPercentage
            end
        end
    end
    return best
end

-- ─────────────────────────────────────────────
--  Notifications
-- ─────────────────────────────────────────────

--- Send a notification to a player via kq_link
function NotifyPlayer(source, message, notifType)
    notifType = notifType or "info"
    local ok, err = pcall(function()
        exports.kq_link:Notify(source, message, notifType)
    end)
    if not ok then
        DebugLog("Notify failed for player %d: %s", source, tostring(err))
    end
end

-- ─────────────────────────────────────────────
--  Contract board pool management
-- ─────────────────────────────────────────────

local contractPool   = {}   -- currently available contracts on the board
local lastReplenish  = 0    -- os.time() of last replenishment

local function ShuffleTable(t)
    local n = #t
    for i = n, 2, -1 do
        local j = math.random(1, i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end

--- Build the initial contract pool from Config.contracts
function InitContractPool()
    contractPool = {}
    if not Config.contracts then return end

    local all = {}
    for i, c in ipairs(Config.contracts) do
        table.insert(all, { index = i, contract = c })
    end
    ShuffleTable(all)

    local max = Config.maxAvailableContracts or 15
    for i = 1, math.min(max, #all) do
        table.insert(contractPool, all[i])
    end

    lastReplenish = os.time()
    DebugLog("Contract pool initialised with %d contracts", #contractPool)
end

--- Remove a contract from the pool by index (after a player takes it)
--- Schedules a replenishment after Config.contractReplenishDelay seconds
function RemoveContractFromPool(poolIndex)
    table.remove(contractPool, poolIndex)
    -- Schedule replenishment
    local delay = (Config.contractReplenishDelay or 30) * 1000
    SetTimeout(delay, function()
        ReplenishContractPool()
    end)
end

--- Add one random contract back to the pool (up to max)
function ReplenishContractPool()
    if not Config.contracts then return end
    local max = Config.maxAvailableContracts or 15
    if #contractPool >= max then return end

    local all = {}
    for i, c in ipairs(Config.contracts) do
        -- Avoid exact duplicates already in the pool
        local already = false
        for _, p in ipairs(contractPool) do
            if p.index == i then already = true; break end
        end
        if not already then
            table.insert(all, { index = i, contract = c })
        end
    end

    if #all == 0 then
        -- All contracts already present – pick any random one
        for i, c in ipairs(Config.contracts) do
            table.insert(all, { index = i, contract = c })
        end
    end

    if #all > 0 then
        local pick = all[math.random(1, #all)]
        table.insert(contractPool, pick)
        DebugLog("Contract pool replenished – now %d contracts", #contractPool)
    end
end

--- Return the current pool as a sanitised list for the job board UI
function GetContractBoardData()
    local out = {}
    for i, entry in ipairs(contractPool) do
        local c = entry.contract
        -- Strip server-only / heavy data before sending to client
        local stripped = {
            poolIndex   = i,
            name        = c.name,
            description = c.description,
            reward      = c.reward,
            minPlayers  = c.minPlayers or 1,
            maxPlayers  = c.maxPlayers or 4,
        }
        table.insert(out, stripped)
    end
    return out
end

--- Return the full contract definition for a given pool index (for starting a contract)
function GetContractByPoolIndex(poolIndex)
    local entry = contractPool[poolIndex]
    if not entry then return nil end
    return entry.contract, poolIndex
end

-- ─────────────────────────────────────────────
--  Payout calculation
-- ─────────────────────────────────────────────

--- Build the complete payout for every member of a finished contract.
--- Returns a list: { { source, amount, xp }, … }
function CalculatePayout(finishResult)
    local base        = finishResult.reward
    local memberCount = finishResult.memberCount
    local members     = finishResult.members
    local teamBonus   = finishResult.teamBonus or 0   -- percentage
    local timeBonus   = finishResult.timeBonus or 0   -- percentage

    local payouts = {}

    for _, playerId in ipairs(members) do
        -- Fetch individual salary bonus based on player level
        local stats      = GetPlayerJobStats(playerId)
        local playerLvl  = (stats and stats.level) or 1
        local salaryBonus = GetSalaryBonusPercent(playerLvl)

        -- Apply split if configured
        local share = base
        if Config.splitProfitsBetweenTeam and memberCount > 1 then
            share = math.floor(base / memberCount)
        end

        -- Apply bonuses (all additive percentages on top of share)
        local totalBonusPct = teamBonus + timeBonus + salaryBonus
        local bonusAmount   = math.floor(share * (totalBonusPct / 100))
        local finalAmount   = share + bonusAmount

        -- XP: 1 XP per $100 reward, multiplied by Config.xpGainMultiplier
        local xpGain = math.floor((finalAmount / 100) * (Config.xpGainMultiplier or 1.0))
        xpGain = math.max(xpGain, 1)

        table.insert(payouts, {
            source     = playerId,
            amount     = finalAmount,
            xp         = xpGain,
            bonusPct   = totalBonusPct,
            playerLevel = playerLvl,
        })
    end

    return payouts
end

-- ─────────────────────────────────────────────
--  Vehicle state bag helpers
-- ─────────────────────────────────────────────

--- Set the kq_powerwashing_level state bag on a networked vehicle entity
--- so the client can pick up upgrade data from it.
function SetVehicleJobLevel(vehicleNetId, level)
    if not vehicleNetId or vehicleNetId == 0 then return end
    local ok, err = pcall(function()
        local entityBag = ("entity:%d"):format(vehicleNetId)
        SetStateBagValue(entityBag, "kq_powerwashing_level", level, true)
    end)
    if not ok then
        DebugLog("SetVehicleJobLevel failed for netId %d: %s", vehicleNetId, tostring(err))
    end
end
