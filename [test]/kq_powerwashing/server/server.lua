-- server/server.lua
-- Main server-side event handlers for kq_powerwashing

-- ─────────────────────────────────────────────
--  Initialisation
-- ─────────────────────────────────────────────

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    InitContractPool()

    -- Register the powerwashing job with kq_jobcontracts (if the export exists)
    local ok, err = pcall(function()
        exports.kq_jobcontracts:RegisterJob("powerwashing", {
            label      = "Hogedruk Reiniger",
            maxLevel   = 50,
            xpPerLevel = 1000,
        })
    end)
    if not ok then
        DebugLog("RegisterJob failed (kq_jobcontracts may handle this differently): %s", tostring(err))
    end

    Log("Resource started. Contract pool ready with %d contracts.", #(GetContractBoardData()))
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    -- Clean up all active contracts gracefully
    for contractId, _ in pairs(WashManager.GetAllActiveContracts()) do
        WashManager.CleanupContract(contractId)
    end
    Log("Resource stopped. All contracts cleaned up.")
end)

-- ─────────────────────────────────────────────
--  Job board — player requests to open it
-- ─────────────────────────────────────────────

RegisterNetEvent("kq_powerwashing:server:openJobBoard", function()
    local source = source

    -- Job check
    if not ServerPlayerHasJob(source) then
        DebugLog("Player %d tried to open job board without the job", source)
        return
    end

    -- Cancellation ban check
    local banned, remaining = WashManager.IsPlayerBanned(source)
    if banned then
        local minutes = math.ceil(remaining / 60)
        NotifyPlayer(source,
            L("cancellation_ban.blocked", { time = tostring(minutes) }),
            "error")
        return
    end

    -- Already in a contract?
    local existing = WashManager.GetContractForPlayer(source)
    if existing and existing.active then
        DebugLog("Player %d already has an active contract", source)
        NotifyPlayer(source, "Je hebt al een actief contract.", "error")
        return
    end

    -- Build board data and open via kq_jobcontracts
    local boardContracts = GetContractBoardData()

    local ok, err = pcall(function()
        exports.kq_jobcontracts:OpenJobBoard(source, {
            title     = L("job_board.title"),
            jobKey    = "powerwashing",
            contracts = boardContracts,
            onAccept  = function(playerId, contractData)
                -- contractData.poolIndex is what the board sends back
                AcceptContract(playerId, contractData.poolIndex)
            end,
        })
    end)

    if not ok then
        -- Fallback: trigger a client-side event so the client can open its own UI
        DebugLog("OpenJobBoard export failed (%s) – falling back to client event", tostring(err))
        TriggerClientEvent("kq_powerwashing:client:openJobBoard", source, boardContracts)
    end
end)

-- ─────────────────────────────────────────────
--  Accept contract (called from job board callback or client event)
-- ─────────────────────────────────────────────

RegisterNetEvent("kq_powerwashing:server:acceptContract", function(poolIndex)
    local source = source
    if not ServerPlayerHasJob(source) then return end
    AcceptContract(source, poolIndex)
end)

function AcceptContract(playerId, poolIndex)
    -- Ban check
    local banned, remaining = WashManager.IsPlayerBanned(playerId)
    if banned then
        local minutes = math.ceil(remaining / 60)
        NotifyPlayer(playerId,
            L("cancellation_ban.blocked", { time = tostring(minutes) }),
            "error")
        return
    end

    local contractDef, poolIdx = GetContractByPoolIndex(poolIndex)
    if not contractDef then
        DebugLog("AcceptContract: poolIndex %s not found", tostring(poolIndex))
        NotifyPlayer(playerId, "Dit contract is niet meer beschikbaar.", "error")
        return
    end

    -- Remove from pool immediately
    RemoveContractFromPool(poolIdx)

    -- Create server-side contract object
    local contract = WashManager.CreateContract(contractDef, playerId)

    -- Get player job level so vehicle can have upgrades applied client-side
    local stats     = GetPlayerJobStats(playerId)
    local jobLevel  = (stats and stats.level) or 1

    -- Tell kq_jobcontracts to start the contract flow for this player
    local ok, err = pcall(function()
        exports.kq_jobcontracts:StartContract(playerId, {
            contractId  = contract.id,
            jobKey      = "powerwashing",
            name        = contractDef.name,
            description = contractDef.description,
            reward      = contractDef.reward,
            minPlayers  = contractDef.minPlayers or 1,
            maxPlayers  = contractDef.maxPlayers or 4,
            locations   = contractDef.locations,
            -- Pass extra vars the client task types need
            vars = {
                vehicleModel  = Config.defaultVehicle,
                jobLevel      = jobLevel,
                contractId    = contract.id,
            },
        })
    end)

    if not ok then
        DebugLog("StartContract failed: %s", tostring(err))
        -- Fallback: send data directly to client
        TriggerClientEvent("kq_powerwashing:client:startContract", playerId, {
            contractId  = contract.id,
            contractDef = contractDef,
            jobLevel    = jobLevel,
        })
    end

    if ServerConfig and ServerConfig.logContractEvents then
        Log("Player %d accepted contract '%s' (id: %s)", playerId, contractDef.name, contract.id)
    end
end

-- ─────────────────────────────────────────────
--  Join existing contract (team member)
-- ─────────────────────────────────────────────

RegisterNetEvent("kq_powerwashing:server:joinContract", function(contractId)
    local source = source
    if not ServerPlayerHasJob(source) then return end

    local banned = WashManager.IsPlayerBanned(source)
    if banned then
        NotifyPlayer(source, L("cancellation_ban.blocked", { time = "?" }), "error")
        return
    end

    local contract = WashManager.GetContract(contractId)
    if not contract or not contract.active then
        NotifyPlayer(source, "Dit contract bestaat niet of is al beëindigd.", "error")
        return
    end

    local maxPlayers = contract.def.maxPlayers or 4
    if #contract.members >= maxPlayers then
        NotifyPlayer(source, "Dit contract zit al vol.", "error")
        return
    end

    WashManager.AddMemberToContract(contractId, source)

    local stats    = GetPlayerJobStats(source)
    local jobLevel = (stats and stats.level) or 1

    -- Broadcast updated wash areas to the new member
    WashManager.BroadcastWashAreas(contract)

    -- Tell kq_jobcontracts the player has joined
    pcall(function()
        exports.kq_jobcontracts:JoinContract(source, contractId)
    end)

    if ServerConfig and ServerConfig.logContractEvents then
        Log("Player %d joined contract %s", source, contractId)
    end
end)

-- ─────────────────────────────────────────────
--  Wash delta — client sends cleaned pixel data
-- ─────────────────────────────────────────────

RegisterNetEvent("kq_powerwashing:server:washDelta", function(deltaData)
    local source = source

    if not deltaData or type(deltaData) ~= "table" then return end

    local contract = WashManager.GetContractForPlayer(source)
    if not contract or not contract.active then return end

    -- deltaData = { [areaId] = { ["x_y"] = {x, y, amount}, ... }, ... }
    for areaId, pixels in pairs(deltaData) do
        local areaIdNum = tonumber(areaId) or areaId
        local wa = contract.washAreas[areaIdNum]
        if wa then
            -- Convert pixel entries to a simple {pixelKey = amount} map
            local simplified = {}
            for pixelKey, pixelEntry in pairs(pixels) do
                if type(pixelEntry) == "table" and pixelEntry.amount then
                    simplified[pixelKey] = pixelEntry.amount
                end
            end
            wa:ApplyDelta(simplified)
        end
    end

    -- Broadcast updated state to all team members
    WashManager.BroadcastWashAreas(contract)

    DebugLog("washDelta from player %d – contract %s", source, contract.id)
end)

-- Statebag variant: client sets LocalPlayer.state.washDelta
AddStateBagChangeHandler("washDelta", nil, function(bagName, _, value)
    if not value then return end

    -- Extract server ID from bag name "player:N"
    local serverId = tonumber(bagName:match("player:(%d+)"))
    if not serverId then return end

    local contract = WashManager.GetContractForPlayer(serverId)
    if not contract or not contract.active then return end

    for areaId, pixels in pairs(value) do
        local areaIdNum = tonumber(areaId) or areaId
        local wa = contract.washAreas[areaIdNum]
        if wa then
            local simplified = {}
            for pixelKey, pixelEntry in pairs(pixels) do
                if type(pixelEntry) == "table" and pixelEntry.amount then
                    simplified[pixelKey] = pixelEntry.amount
                end
            end
            wa:ApplyDelta(simplified)
        end
    end

    WashManager.BroadcastWashAreas(contract)
end)

-- ─────────────────────────────────────────────
--  Proximity update — client sends nearby area IDs
-- ─────────────────────────────────────────────

RegisterNetEvent("kq_powerwashing:server:updateProximity", function(proximityList)
    local source = source
    if type(proximityList) ~= "table" then return end
    WashManager.UpdateProximity(source, proximityList)
end)

-- ─────────────────────────────────────────────
--  Contract completion — called when all tasks done
-- ─────────────────────────────────────────────

RegisterNetEvent("kq_powerwashing:server:finishContract", function(contractId, vehicleNetId, vehicleHealth)
    local source = source
    local contract = WashManager.GetContractForPlayer(source)

    if not contract then return end
    if contract.id ~= contractId then return end
    if contract.finished then return end

    -- Only the leader can trigger the final payout
    if contract.leaderId ~= source then
        NotifyPlayer(source, "Alleen de teamleider kan het contract afronden.", "error")
        return
    end

    -- Store vehicle data for penalty calculation
    contract.vehicleNetId  = vehicleNetId
    contract.vehicleHealth = vehicleHealth

    local finishResult = WashManager.FinishContract(contractId)
    if not finishResult then return end

    -- Vehicle damage penalty
    local vehicleDamagePenalty = 0
    if vehicleHealth and vehicleHealth < 900.0 then
        local dmgRatio = math.max(0, (900.0 - vehicleHealth) / 900.0)
        local maxPenalty = Config.bonuses and Config.bonuses.maxVehicleDamagePenalty or 1250
        vehicleDamagePenalty = math.floor(dmgRatio * maxPenalty)
    end

    -- Vehicle missing penalty
    local vehicleMissingPenalty = 0
    if vehicleNetId == nil or vehicleNetId == 0 then
        vehicleMissingPenalty = Config.bonuses and Config.bonuses.missingVehiclePenalty or 1500
    end

    -- Calculate and distribute payout to every member
    local payouts = CalculatePayout(finishResult)

    for _, payout in ipairs(payouts) do
        local finalAmount = math.max(0, payout.amount - vehicleDamagePenalty - vehicleMissingPenalty)

        GivePlayerMoney(payout.source, finalAmount)
        GivePlayerJobXp(payout.source, payout.xp)

        -- Notify the player with their breakdown
        TriggerClientEvent("kq_powerwashing:client:contractFinished", payout.source, {
            reward              = payout.amount,
            finalReward         = finalAmount,
            xp                  = payout.xp,
            bonusPct            = payout.bonusPct,
            vehicleDamagePenalty = vehicleDamagePenalty,
            vehicleMissingPenalty = vehicleMissingPenalty,
            playerLevel         = payout.playerLevel,
        })

        DebugLog("Payout player %d: $%d (xp: %d)", payout.source, finalAmount, payout.xp)
    end

    -- Clean up the contract server-side
    WashManager.CleanupContract(contractId)

    -- Notify kq_jobcontracts the contract is done
    pcall(function()
        exports.kq_jobcontracts:CompleteContract(source, contractId, "powerwashing")
    end)

    Log("Contract %s completed. %d players paid out.", contractId, #payouts)
end)

-- ─────────────────────────────────────────────
--  Leave / cancel contract
-- ─────────────────────────────────────────────

RegisterNetEvent("kq_powerwashing:server:leaveContract", function()
    local source = source
    HandlePlayerLeaveContract(source)
end)

function HandlePlayerLeaveContract(playerId)
    local contract = WashManager.GetContractForPlayer(playerId)
    if not contract then return end

    WashManager.RemoveMemberFromContract(playerId)

    -- Notify remaining team members
    local remaining = WashManager.GetContract(contract.id)
    if remaining then
        for _, mid in ipairs(remaining.members) do
            TriggerClientEvent("kq_powerwashing:client:memberLeft", mid, playerId)
        end
    end

    -- Tell kq_jobcontracts the player left
    pcall(function()
        exports.kq_jobcontracts:LeaveContract(playerId, contract.id)
    end)

    -- Inform the player of any ban applied
    local banned, remaining_secs = WashManager.IsPlayerBanned(playerId)
    if banned then
        local minutes = math.ceil(remaining_secs / 60)
        NotifyPlayer(playerId,
            L("cancellation_ban.applied", { time = tostring(minutes) }),
            "error")
    end

    if ServerConfig and ServerConfig.logContractEvents then
        Log("Player %d left contract %s", playerId, contract.id)
    end
end

-- ─────────────────────────────────────────────
--  Vehicle spawn tracking
-- ─────────────────────────────────────────────

RegisterNetEvent("kq_powerwashing:server:vehicleSpawned", function(vehicleNetId)
    local source = source
    local contract = WashManager.GetContractForPlayer(source)
    if not contract then return end

    contract.vehicleNetId = vehicleNetId

    -- Set the job level state bag on the vehicle so client can apply upgrades
    local stats    = GetPlayerJobStats(source)
    local jobLevel = (stats and stats.level) or 1
    SetVehicleJobLevel(vehicleNetId, jobLevel)

    DebugLog("Vehicle netId %d registered for contract %s (level %d)", vehicleNetId, contract.id, jobLevel)
end)

-- ─────────────────────────────────────────────
--  Player disconnect cleanup
-- ─────────────────────────────────────────────

AddEventHandler("playerDropped", function(reason)
    local source = source
    HandlePlayerLeaveContract(source)
    DebugLog("Player %d disconnected (%s) – contract cleaned up if active", source, tostring(reason))
end)

-- ─────────────────────────────────────────────
--  Safe restart command (debug only)
-- ─────────────────────────────────────────────

if Config.debug then
    RegisterCommand("pw_restart", function(source, args, rawCommand)
        if source ~= 0 then
            -- Only allow from server console or admins
            return
        end
        local resourceName = GetCurrentResourceName()
        TriggerClientEvent(resourceName .. ":client:safeRestart", -1, 0)
        Log("Safe restart triggered from console.")
    end, true)
end

-- ─────────────────────────────────────────────
--  Exports for external resources
-- ─────────────────────────────────────────────

exports("GetContractForPlayer", function(playerId)
    return WashManager.GetContractForPlayer(playerId)
end)

exports("GetContractCompletion", function(contractId)
    return WashManager.GetContractCompletion(contractId)
end)

exports("IsPlayerInContract", function(playerId)
    local c = WashManager.GetContractForPlayer(playerId)
    return c ~= nil and c.active
end)

Log("Server initialised.")
