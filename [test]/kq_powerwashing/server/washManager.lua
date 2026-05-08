-- washManager.lua
-- Manages active powerwashing contracts, wash areas, and team members

WashManager = {}

-- Active contracts: key = contractId, value = contract data table
local activeContracts = {}

-- Player -> contractId mapping
local playerContracts = {}

-- Cancellation ban tracking: key = playerId (string), value = unban timestamp
local cancellationBans = {}

local function GetTimestamp()
    return os.time()
end

-- ─────────────────────────────────────────────
--  Contract lifecycle
-- ─────────────────────────────────────────────

function WashManager.CreateContract(contractDef, leaderId)
    local contractId = tostring(leaderId) .. "_" .. tostring(GetGameTimer())

    local washAreas = {}
    local areaIndex = 1
    if contractDef.locations then
        for _, location in ipairs(contractDef.locations) do
            if location.spots then
                for _, spot in ipairs(location.spots) do
                    if spot.areas then
                        for _, area in ipairs(spot.areas) do
                            local wa = WashArea.new(areaIndex, contractId, area)
                            washAreas[areaIndex] = wa
                            areaIndex = areaIndex + 1
                        end
                    end
                end
            end
        end
    end

    local contract = {
        id          = contractId,
        def         = contractDef,
        leaderId    = leaderId,
        members     = { leaderId },
        washAreas   = washAreas,
        startTime   = GetTimestamp(),
        active      = true,
        finished    = false,
        vehicleNet  = nil,
    }

    activeContracts[contractId] = contract
    playerContracts[tostring(leaderId)] = contractId

    if Config.debug then
        print(("[kq_powerwashing] Contract created: %s by player %s"):format(contractId, leaderId))
    end

    return contract
end

function WashManager.GetContractForPlayer(playerId)
    local cid = playerContracts[tostring(playerId)]
    if not cid then return nil end
    return activeContracts[cid]
end

function WashManager.GetContract(contractId)
    return activeContracts[contractId]
end

function WashManager.AddMemberToContract(contractId, playerId)
    local contract = activeContracts[contractId]
    if not contract then return false end

    for _, mid in ipairs(contract.members) do
        if mid == playerId then return true end -- already in
    end

    table.insert(contract.members, playerId)
    playerContracts[tostring(playerId)] = contractId
    return true
end

function WashManager.RemoveMemberFromContract(playerId)
    local cid = playerContracts[tostring(playerId)]
    if not cid then return end

    local contract = activeContracts[cid]
    if contract then
        for i, mid in ipairs(contract.members) do
            if mid == playerId then
                table.remove(contract.members, i)
                break
            end
        end

        -- If no members left, clean up the contract
        if #contract.members == 0 then
            WashManager.CleanupContract(cid)
        end
    end

    playerContracts[tostring(playerId)] = nil

    -- Apply cancellation ban if configured and contract was still active
    if Config.cancellationBan and Config.cancellationBan.enabled then
        if contract and contract.active and not contract.finished then
            local banUntil = GetTimestamp() + (Config.cancellationBan.duration * 60)
            cancellationBans[tostring(playerId)] = banUntil
            if Config.debug then
                print(("[kq_powerwashing] Player %s banned from new contracts until %d"):format(playerId, banUntil))
            end
        end
    end
end

function WashManager.IsPlayerBanned(playerId)
    local ban = cancellationBans[tostring(playerId)]
    if not ban then return false, 0 end
    if GetTimestamp() >= ban then
        cancellationBans[tostring(playerId)] = nil
        return false, 0
    end
    return true, ban - GetTimestamp()
end

function WashManager.CleanupContract(contractId)
    local contract = activeContracts[contractId]
    if not contract then return end

    -- Remove all player->contract mappings for this contract
    for _, mid in ipairs(contract.members) do
        playerContracts[tostring(mid)] = nil
    end

    activeContracts[contractId] = nil

    if Config.debug then
        print(("[kq_powerwashing] Contract cleaned up: %s"):format(contractId))
    end
end

function WashManager.FinishContract(contractId)
    local contract = activeContracts[contractId]
    if not contract then return nil end

    contract.active   = false
    contract.finished = true
    contract.endTime  = GetTimestamp()

    local duration   = contract.endTime - contract.startTime
    local memberCount = #contract.members

    -- Calculate base payout
    local reward = contract.def.reward or 0

    -- Salary upgrade bonus (take the highest applicable)
    local salaryBonus = 0
    -- (GetPlayerJobStats is async and per-player; handled in server.lua during payout)

    -- Teamwork bonus
    local teamBonus = 0
    if Config.bonuses and Config.bonuses.teamWorkBonuses and Config.bonuses.teamWorkBonuses.enabled then
        local bonusTable = Config.bonuses.teamWorkBonuses.memberCounts
        if bonusTable then
            local key = math.min(memberCount, 4)
            teamBonus = bonusTable[key] or 0
        end
    end

    -- Time bonus: estimate star rating based on contract size and time taken
    local timeBonus = 0
    local totalAreas = 0
    for _ in pairs(contract.washAreas) do totalAreas = totalAreas + 1 end
    local expectedTime = math.max(60, totalAreas * 90)   -- rough: 90s per area
    local ratio = duration / expectedTime
    if ratio <= 0.75 then
        timeBonus = Config.bonuses and Config.bonuses.perfectTime or 15
    elseif ratio <= 1.1 then
        timeBonus = Config.bonuses and Config.bonuses.goodTime or 5
    end

    local result = {
        contractId  = contractId,
        reward      = reward,
        teamBonus   = teamBonus,
        timeBonus   = timeBonus,
        members     = contract.members,
        memberCount = memberCount,
        duration    = duration,
    }

    if ServerConfig and ServerConfig.logCompletions then
        print(("[kq_powerwashing] Contract %s finished in %ds | reward: $%d | members: %d"):format(
            contractId, duration, reward, memberCount))
    end

    return result
end

-- ─────────────────────────────────────────────
--  Wash area delta updates
-- ─────────────────────────────────────────────

function WashManager.ApplyWashDelta(playerId, areaId, delta)
    local contract = WashManager.GetContractForPlayer(playerId)
    if not contract then return false end

    local wa = contract.washAreas[areaId]
    if not wa then return false end

    wa:ApplyDelta(delta)

    -- Broadcast updated area state to all contract members
    WashManager.BroadcastWashAreas(contract)

    return true
end

function WashManager.BroadcastWashAreas(contract)
    local serialized = {}
    for id, wa in pairs(contract.washAreas) do
        serialized[id] = wa:Serialize()
    end

    -- Use configured sync method
    if Config.syncMethod == 'statebag' then
        local bag = GlobalState
        if bag then
            bag["kq_powerwashing_washAreas_" .. contract.id] = serialized
        end
    end

    -- Also send event to all members for immediate update
    for _, mid in ipairs(contract.members) do
        TriggerClientEvent('kq_powerwashing:client:washAreasUpdate', mid, contract.id, serialized)
    end
end

function WashManager.UpdateProximity(playerId, proximityData)
    local contract = WashManager.GetContractForPlayer(playerId)
    if not contract then return end

    -- Store proximity data on contract for use by other systems
    if not contract.proximityData then
        contract.proximityData = {}
    end
    contract.proximityData[tostring(playerId)] = proximityData
end

-- ─────────────────────────────────────────────
--  Getters
-- ─────────────────────────────────────────────

function WashManager.GetAllActiveContracts()
    return activeContracts
end

function WashManager.GetContractWashAreas(contractId)
    local contract = activeContracts[contractId]
    if not contract then return nil end
    return contract.washAreas
end

function WashManager.GetContractCompletion(contractId)
    local contract = activeContracts[contractId]
    if not contract then return 0.0 end

    local total    = 0
    local complete = 0
    for _, wa in pairs(contract.washAreas) do
        total = total + 1
        if wa:IsComplete() then complete = complete + 1 end
    end

    if total == 0 then return 100.0 end
    return (complete / total) * 100.0
end
