local ActiveJobs      = {}
local OrderCooldowns  = {}
local OrderTaken      = {}
local CancelCooldowns = {}

-- ─── PARTY (memory-based, max 2 players) ────────────────────────────────────

local Parties      = {}   -- [visibleId] = { leader, member, jobData }
local PlayerParty  = {}   -- [src]       = visibleId
local PartyInvites = {}   -- [targetSrc] = { from, visibleId, time }
local NextPartyId  = 1
local JobLoadingLock = {}
local OccupiedSpawnSlots = {}

-- Helper: sinh biển TRUCK + 3 số random, kiểm tra trùng trong DB
local function GenerateTruckPlate()
    for _ = 1, 20 do
        local plate = 'TRUCK' .. string.format('%03d', math.random(0, 999))
        if not IsRentalPlateTaken(plate) then
            return plate
        end
    end
    return nil   -- không tạo được sau 20 lần (cực hiếm)
end

-- Trả về index slot còn trống, hoặc nil nếu hết
local function GetFreeSpawnSlot()
    for i, point in ipairs(Config.RentalSpawnPoints) do
        if not OccupiedSpawnSlots[i] then
            return i, point
        end
    end
    return nil, nil
end

local function GeneratePartyId()
    local id = NextPartyId
    NextPartyId = NextPartyId + 1
    return id
end

local function GetPlayerParty(src)
    local visibleId = PlayerParty[src]
    if visibleId and Parties[visibleId] then
        return Parties[visibleId], visibleId
    end
    return nil, nil
end

local function IsPlayerInParty(src)
    return PlayerParty[src] ~= nil
end

local function IsPartyLeader(src)
    local party = GetPlayerParty(src)
    return party and party.leader == src
end

local function DisbandParty(visibleId, reason)
    local party = Parties[visibleId]
    if not party then return end

    local members = { party.leader, party.member }

    if party.jobData then
        for _, memberSrc in ipairs(members) do
            if memberSrc then
                ActiveJobs[memberSrc] = nil
                TriggerClientEvent('tommy-trucker:client:clearJob', memberSrc)
                lib.notify(memberSrc, { description = reason or locale('party_disbanded'), type = 'error' })
            end
        end
    end

    for _, memberSrc in ipairs(members) do
        if memberSrc then
            PlayerParty[memberSrc] = nil
            TriggerClientEvent('tommy-trucker:client:partyDisbanded', memberSrc)
        end
    end

    Parties[visibleId] = nil
end

-- Distributes reward/exp after full delivery; handles both party and solo paths
function CompleteDeliveryParty(src, job)
    local order = job.order
    if not order then return end

    if job.isPartyJob and job.visibleId then
        local party = Parties[job.visibleId]
        if not party then return end

        -- local rewardEach = math.floor(order.reward / 2) -- Chia đều
        local rewardEach = math.floor(order.reward)
        local expEach    = order.exp
        local members    = { party.leader, party.member }

        for _, memberSrc in ipairs(members) do
            if memberSrc then
                local MemberPlayer = exports.qbx_core:GetPlayer(memberSrc)
                if MemberPlayer then
                    MemberPlayer.Functions.AddMoney('cash', rewardEach, 'trucking-job-reward-party')

                    for _, itemData in ipairs(order.items) do
                        if math.random(1, 100) <= itemData.chance then
                            exports.ox_inventory:AddItem(memberSrc, itemData.item, 1)
                        end
                    end

                    UpdateDriverStats(MemberPlayer.PlayerData.citizenid, expEach)

                    lib.notify(memberSrc, {
                        description = locale('success_delivered_party', { money = rewardEach, exp = expEach }),
                        type        = 'success',
                    })
                end

                ActiveJobs[memberSrc] = nil
                TriggerClientEvent('tommy-trucker:client:clearJob', memberSrc)
            end
        end

        party.jobData = nil
    else
        local Player = exports.qbx_core:GetPlayer(src)
        if not Player then return end

        Player.Functions.AddMoney('cash', order.reward, 'trucking-job-reward')

        for _, itemData in ipairs(order.items) do
            if math.random(1, 100) <= itemData.chance then
                exports.ox_inventory:AddItem(src, itemData.item, 1)
            end
        end

        UpdateDriverStats(Player.PlayerData.citizenid, order.exp)

        ActiveJobs[src] = nil
        TriggerClientEvent('tommy-trucker:client:clearJob', src)
    end
end

-- ─── LOADING / UNLOADING GATE ────────────────────────────────────────────────

lib.callback.register('tommy-trucker:server:canLoadCargo', function(source)
    local src = source
    if not ActiveJobs[src] then return false, locale('error_no_order') end

    local job     = ActiveJobs[src]
    local lockKey = job.isPartyJob and ('load_' .. job.visibleId) or ('load_solo_' .. src)

    if job.loaded >= job.totalKg then return false, locale('error_already_loaded') end

    local isLastBox = (job.loaded + Config.KgPerTrip) >= job.totalKg

    if isLastBox and JobLoadingLock[lockKey] then return false, locale('error_teammate_loading') end
    if isLastBox then JobLoadingLock[lockKey] = src end

    return true, nil
end)

lib.callback.register('tommy-trucker:server:canDeliverCargo', function(source)
    local src = source
    if not ActiveJobs[src] then return false, locale('error_no_order') end

    local job     = ActiveJobs[src]
    local lockKey = job.isPartyJob and ('unload_' .. job.visibleId) or ('unload_solo_' .. src)

    if job.unloaded >= job.totalKg then return false, locale('error_already_delivered') end

    local isLastBox = (job.unloaded + Config.KgPerTrip) >= job.totalKg

    if isLastBox and JobLoadingLock[lockKey] then return false, locale('error_teammate_delivering') end
    if isLastBox then JobLoadingLock[lockKey] = src end

    return true, nil
end)

RegisterNetEvent('tommy-trucker:server:cancelLoadUnlock', function(isLoading)
    local src = source
    if not ActiveJobs[src] then return end

    local job     = ActiveJobs[src]
    local lockKey

    if isLoading then
        lockKey = job.isPartyJob and ('load_' .. job.visibleId) or ('load_solo_' .. src)
    else
        lockKey = job.isPartyJob and ('unload_' .. job.visibleId) or ('unload_solo_' .. src)
    end

    if JobLoadingLock[lockKey] == src then
        JobLoadingLock[lockKey] = nil
    end
end)

-- ─── PARTY CALLBACKS ─────────────────────────────────────────────────────────

lib.callback.register('tommy-trucker:server:getPartyData', function(source)
    local src    = source
    local party, visibleId = GetPlayerParty(src)

    if not party then return { inParty = false } end

    local leaderPlayer = exports.qbx_core:GetPlayer(party.leader)
    local memberPlayer = party.member and exports.qbx_core:GetPlayer(party.member)

    return {
        inParty      = true,
        visibleId    = visibleId,
        isLeader     = party.leader == src,
        leader       = {
            src       = party.leader,
            name      = leaderPlayer and (leaderPlayer.PlayerData.charinfo.firstname .. ' ' .. leaderPlayer.PlayerData.charinfo.lastname) or 'Unknown',
            citizenid = leaderPlayer and leaderPlayer.PlayerData.citizenid or nil,
        },
        member       = party.member and {
            src       = party.member,
            name      = memberPlayer and (memberPlayer.PlayerData.charinfo.firstname .. ' ' .. memberPlayer.PlayerData.charinfo.lastname) or 'Unknown',
            citizenid = memberPlayer and memberPlayer.PlayerData.citizenid or nil,
        } or nil,
        hasActiveJob = party.jobData ~= nil,
    }
end)

lib.callback.register('tommy-trucker:server:getNearbyPlayers', function(source)
    local src          = source
    local playerPed    = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)
    local nearby       = {}

    for _, targetSrc in ipairs(GetPlayers()) do
        local targetId = tonumber(targetSrc)          
        if targetId and targetId ~= src then
            local TargetPlayer = exports.qbx_core:GetPlayer(targetId)
            if TargetPlayer then
                local dist = #(playerCoords - GetEntityCoords(GetPlayerPed(targetId)))
                if dist <= 10.0 and not IsPlayerInParty(targetId) then
                    table.insert(nearby, {
                        src      = targetId,
                        id       = targetId,
                        distance = math.floor(dist * 10) / 10,
                    })
                end
            end
        end
    end

    return nearby
end)

-- ─── PARTY EVENTS ────────────────────────────────────────────────────────────

RegisterNetEvent('tommy-trucker:server:createParty', function()
    local src    = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end

    if IsPlayerInParty(src) then
        lib.notify(src, { description = locale('error_already_in_party'), type = 'error' })
        return
    end

    if ActiveJobs[src] then
        lib.notify(src, { description = locale('error_has_active_job'), type = 'error' })
        return
    end

    local visibleId = GeneratePartyId()
    Parties[visibleId]  = { leader = src, member = nil, jobData = nil, createdAt = os.time() }
    PlayerParty[src]    = visibleId

    lib.notify(src, { description = locale('success_party_created'), type = 'success' })
    TriggerClientEvent('tommy-trucker:client:partyUpdated', src)
end)

RegisterNetEvent('tommy-trucker:server:inviteToParty', function(targetSrc)
    local src    = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end

    local party, visibleId = GetPlayerParty(src)

    if not party then
        lib.notify(src, { description = locale('error_no_party'), type = 'error' })
        return
    end
    if party.leader ~= src then
        lib.notify(src, { description = locale('error_not_leader'), type = 'error' })
        return
    end
    if party.member then
        lib.notify(src, { description = locale('error_party_full'), type = 'error' })
        return
    end

    local TargetPlayer = exports.qbx_core:GetPlayer(targetSrc)
    if not TargetPlayer then
        lib.notify(src, { description = locale('error_player_not_found'), type = 'error' })
        return
    end
    if IsPlayerInParty(targetSrc) then
        lib.notify(src, { description = locale('error_target_in_party'), type = 'error' })
        return
    end
    if ActiveJobs[targetSrc] then
        lib.notify(src, { description = locale('error_target_has_job'), type = 'error' })
        return
    end

    PartyInvites[targetSrc] = { from = src, visibleId = visibleId, time = os.time() }

    local playerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    lib.notify(src, { description = locale('success_invite_sent'), type = 'success' })
    TriggerClientEvent('tommy-trucker:client:receivePartyInvite', targetSrc, src, playerName)

    SetTimeout(30000, function()
        if PartyInvites[targetSrc] and PartyInvites[targetSrc].from == src then
            PartyInvites[targetSrc] = nil
        end
    end)
end)

RegisterNetEvent('tommy-trucker:server:acceptPartyInvite', function()
    local src    = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end

    local invite = PartyInvites[src]
    if not invite then
        lib.notify(src, { description = locale('error_no_invite'), type = 'error' })
        return
    end

    local party = Parties[invite.visibleId]
    if not party then
        lib.notify(src, { description = locale('error_party_not_found'), type = 'error' })
        PartyInvites[src] = nil
        return
    end
    if party.member then
        lib.notify(src, { description = locale('error_party_full'), type = 'error' })
        PartyInvites[src] = nil
        return
    end

    party.member     = src
    PlayerParty[src] = invite.visibleId
    PartyInvites[src] = nil

    local memberName = 'ID: ' .. src
    lib.notify(src,           { description = locale('success_joined_party'), type = 'success' })
    lib.notify(party.leader,  { description = locale('success_member_joined', { name = memberName }), type = 'success' })

    TriggerClientEvent('tommy-trucker:client:partyUpdated', src)
    TriggerClientEvent('tommy-trucker:client:partyUpdated', party.leader)
    TriggerClientEvent('tommy-trucker:client:forceRefreshPartyUI', src)
    TriggerClientEvent('tommy-trucker:client:forceRefreshPartyUI', party.leader)
end)

RegisterNetEvent('tommy-trucker:server:declinePartyInvite', function()
    local src    = source
    local invite = PartyInvites[src]
    if invite then
        lib.notify(invite.from, { description = locale('error_invite_declined'), type = 'error' })
        PartyInvites[src] = nil
    end
end)

RegisterNetEvent('tommy-trucker:server:leaveParty', function()
    local src       = source
    local party, visibleId = GetPlayerParty(src)
    if not party then
        lib.notify(src, { description = locale('error_not_in_party'), type = 'error' })
        return
    end
    DisbandParty(visibleId, locale('party_member_left'))
end)

RegisterNetEvent('tommy-trucker:server:kickMember', function()
    local src       = source
    local party, visibleId = GetPlayerParty(src)
    if not party then return end
    if party.leader ~= src then
        lib.notify(src, { description = locale('error_not_leader'), type = 'error' })
        return
    end
    if not party.member then
        lib.notify(src, { description = locale('error_no_member'), type = 'error' })
        return
    end
    DisbandParty(visibleId, locale('party_kicked'))
end)

-- ─── GENERAL CALLBACKS ───────────────────────────────────────────────────────

lib.callback.register('tommy-trucker:server:getDriverData', function(source)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return nil end
    return GetDriverData(Player.PlayerData.citizenid)
end)

lib.callback.register('tommy-trucker:server:getOrders', function(source)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return {} end

    local driverData    = GetDriverData(Player.PlayerData.citizenid)
    local currentTime   = os.time()
    local cancelCooldown = CancelCooldowns[Player.PlayerData.citizenid] or 0

    if currentTime < cancelCooldown then return {} end

    local availableOrders = {}
    for _, order in ipairs(Config.Orders) do
        if driverData.current_level >= order.requiredLevel then
            local cooldownEnd = OrderCooldowns[order.id] or 0
            if currentTime >= cooldownEnd then
                table.insert(availableOrders, {
                    id            = order.id,
                    label         = order.label,
                    requiredLevel = order.requiredLevel,
                    requiredKg    = order.requiredKg,
                    reward        = order.reward,
                    exp           = order.exp,
                    isIllegal     = order.isIllegal,
                })
            end
        end
    end
    return availableOrders
end)

lib.callback.register('tommy-trucker:server:getVehicles', function(source)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return {} end
    return GetPlayerVehicles(Player.PlayerData.citizenid)
end)

lib.callback.register('tommy-trucker:server:getRentalData', function(source)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then
        return { fleet = Config.RentalFleet, activeRental = nil }
    end

    local activeRental = GetActiveRental(Player.PlayerData.citizenid)
    return {
        fleet        = Config.RentalFleet,
        activeRental = activeRental,
    }
end)

-- ─── JOB EVENTS ──────────────────────────────────────────────────────────────

RegisterNetEvent('tommy-trucker:server:registerVehicle', function(plate, vehicle)
    local src    = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end

    if not Config.TruckWhitelist[vehicle] then
        lib.notify(src, { description = locale('error_no_whitelisted'), type = 'error' })
        return
    end

    UpdateRegisteredVehicle(Player.PlayerData.citizenid, plate, vehicle)
    lib.notify(src, { description = locale('success_registered', { plate = plate }), type = 'success' })
end)

RegisterNetEvent('tommy-trucker:server:rentVehicle', function(data)
    local src    = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end

    local citizenid = Player.PlayerData.citizenid

    -- ── Kiểm tra đang có rental chưa ──────────────────────────
    local existing = GetActiveRental(citizenid)
    if existing then
        lib.notify(src, {
            description = ('Bạn đang thuê xe %s, hết hạn mới được thuê tiếp!'):format(existing.plate),
            type        = 'error',
        })
        return
    end

    -- ── Validate dữ liệu từ client ─────────────────────────────
    local model      = data.model
    local rentalDays = tonumber(data.rentalDays)

    if not model or not rentalDays then
        lib.notify(src, { description = 'Dữ liệu thuê xe không hợp lệ.', type = 'error' })
        return
    end

    if rentalDays < 1 or rentalDays > 7 then
        lib.notify(src, { description = 'Số ngày thuê phải từ 1 đến 7 ngày.', type = 'error' })
        return
    end

    -- ── Validate model có trong Config.RentalFleet không ──────
    local validTruck = nil
    for _, truck in ipairs(Config.RentalFleet) do
        if truck.model == model then
            validTruck = truck
            break
        end
    end

    if not validTruck then
        lib.notify(src, { description = 'Xe không tồn tại trong danh sách cho thuê.', type = 'error' })
        return
    end

    -- ── Tìm slot spawn còn trống ───────────────────────────────
    local slotIndex, spawnPoint = GetFreeSpawnSlot()
    if not slotIndex then
        lib.notify(src, {
            description = 'Tất cả vị trí đỗ xe đang bận, vui lòng thử lại sau.',
            type        = 'error',
        })
        return
    end

    -- ── Tính giá server-side ───────────────────────────────────
    local realTotal = validTruck.pricePerDay * rentalDays

    -- ── Kiểm tra tiền mặt ──────────────────────────────────────
    local cash = Player.PlayerData.money['cash'] or 0
    if cash < realTotal then
        lib.notify(src, {
            description = ('Không đủ tiền mặt! Cần $%s, bạn có $%s.'):format(realTotal, cash),
            type        = 'error',
        })
        return
    end

    -- ── Sinh biển số TRUCK + 3 số ──────────────────────────────
    local plate = GenerateTruckPlate()
    if not plate then
        lib.notify(src, { description = 'Không tạo được biển số, thử lại sau.', type = 'error' })
        return
    end

    -- ── Đánh dấu slot đang dùng (tạm thời, sẽ release sau 10s) ─
    OccupiedSpawnSlots[slotIndex] = true
    SetTimeout(10000, function()
        OccupiedSpawnSlots[slotIndex] = nil
    end)

    -- ── Trừ tiền ───────────────────────────────────────────────
    Player.Functions.RemoveMoney('cash', realTotal, 'truck-rental')

    -- ── Thêm vào player_vehicles ───────────────────────────────
    AddRentalToPlayerVehicles(citizenid, plate, model)

    -- ── Ghi vào truck_rentals ──────────────────────────────────
    CreateRental(citizenid, plate, model, validTruck.pricePerDay, rentalDays, realTotal)

    -- ── Tính expire unix ───────────────────────────────────────
    local expireUnix = os.time() + (rentalDays * 86400)

    -- ── Trigger client spawn xe ────────────────────────────────
    TriggerClientEvent('tommy-trucker:client:spawnRentalVehicle', src, {
        model        = model,
        plate        = plate,
        spawnCoords  = {
            x       = spawnPoint.coords.x,
            y       = spawnPoint.coords.y,
            z       = spawnPoint.coords.z,
            heading = spawnPoint.coords.w,
        },
        expireUnix   = expireUnix,
        rentalDays   = rentalDays,
        totalPrice   = realTotal,
    })

    lib.notify(src, {
        description = ('🚛 Thuê xe thành công! Biển số: %s | %d ngày | $%s\nHãy đến điểm đỗ xe!'):format(
            plate, rentalDays, realTotal
        ),
        type     = 'success',
        duration = 7000,
    })
end)

RegisterNetEvent('tommy-trucker:server:acceptOrder', function(orderId, vehicleNetId)
    local src    = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end

    if not vehicleNetId then
        lib.notify(src, { description = locale('error_vehicle_not_nearby'), type = 'error' })
        return
    end
    if ActiveJobs[src] then
        lib.notify(src, { description = locale('error_active_job'), type = 'error' })
        return
    end

    local driverData = GetDriverData(Player.PlayerData.citizenid)
    if not driverData or not driverData.registered_plate then
        lib.notify(src, { description = locale('error_no_vehicle'), type = 'error' })
        return
    end

    local order = nil
    for _, o in ipairs(Config.Orders) do
        if o.id == orderId then order = o break end
    end

    if not order then
        lib.notify(src, { description = locale('error_order_not_found'), type = 'error' })
        return
    end
    if driverData.current_level < order.requiredLevel then
        lib.notify(src, { description = locale('error_level_required', { level = order.requiredLevel }), type = 'error' })
        return
    end

    local vehicleCapacity = Config.TruckWhitelist[driverData.registered_vehicle]
    if not vehicleCapacity or vehicleCapacity < order.requiredKg then
        lib.notify(src, { description = locale('error_vehicle_too_small'), type = 'error' })
        return
    end

    local party, visibleId = GetPlayerParty(src)
    local isPartyJob = party ~= nil
    local memberSrc  = nil

    if isPartyJob then
        if party.leader ~= src then
            lib.notify(src, { description = locale('error_not_leader'), type = 'error' })
            return
        end
        if not party.member then
            lib.notify(src, { description = locale('error_party_not_full'), type = 'error' })
            return
        end
        memberSrc = party.member
        if ActiveJobs[memberSrc] then
            lib.notify(src, { description = locale('error_member_has_job'), type = 'error' })
            return
        end
    end

    OrderCooldowns[orderId] = os.time() + order.cooldown

    local jobData = {
        orderId         = orderId,
        order           = order,
        registeredPlate = driverData.registered_plate,
        vehicleNetId    = vehicleNetId,
        loaded          = 0,
        unloaded        = 0,
        totalKg         = order.requiredKg,
        hasLoadedCargo  = false,
        isPartyJob      = isPartyJob,
        visibleId       = visibleId,
    }

    ActiveJobs[src] = jobData

    if isPartyJob and memberSrc then
        ActiveJobs[memberSrc] = jobData
        party.jobData = jobData
        TriggerClientEvent('tommy-trucker:client:startJob', src,       order, driverData.registered_plate, true)
        TriggerClientEvent('tommy-trucker:client:startJob', memberSrc, order, driverData.registered_plate, true)
    else
        TriggerClientEvent('tommy-trucker:client:startJob', src, order, driverData.registered_plate, false)
    end
end)

RegisterNetEvent('tommy-trucker:server:loadCargo', function()
    local src = source
    if not ActiveJobs[src] then return end

    local job     = ActiveJobs[src]
    local lockKey = job.isPartyJob and ('load_' .. job.visibleId) or ('load_solo_' .. src)

    if job.loaded >= job.totalKg then return end

    job.loaded = math.min(job.loaded + Config.KgPerTrip, job.totalKg)

    if job.isPartyJob and job.visibleId then
        local party = Parties[job.visibleId]
        if party then
            if party.leader then TriggerClientEvent('tommy-trucker:client:updateLoading', party.leader, job.loaded, job.totalKg) end
            if party.member then TriggerClientEvent('tommy-trucker:client:updateLoading', party.member, job.loaded, job.totalKg) end
        end
    else
        TriggerClientEvent('tommy-trucker:client:updateLoading', src, job.loaded, job.totalKg)
    end

    if job.loaded >= job.totalKg then
        job.hasLoadedCargo = true
        JobLoadingLock[lockKey] = nil

        if job.isPartyJob and job.visibleId then
            local party = Parties[job.visibleId]
            if party then
                if party.leader then TriggerClientEvent('tommy-trucker:client:allLoaded', party.leader) end
                if party.member then TriggerClientEvent('tommy-trucker:client:allLoaded', party.member) end
            end
        else
            TriggerClientEvent('tommy-trucker:client:allLoaded', src)
        end
    end
end)

RegisterNetEvent('tommy-trucker:server:deliverCargo', function()
    local src    = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player or not ActiveJobs[src] then return end

    local job     = ActiveJobs[src]
    local lockKey = job.isPartyJob and ('unload_' .. job.visibleId) or ('unload_solo_' .. src)

    if job.unloaded >= job.totalKg then return end

    job.unloaded = math.min(job.unloaded + Config.KgPerTrip, job.totalKg)

    if job.isPartyJob and job.visibleId then
        local party = Parties[job.visibleId]
        if party then
            if party.leader then TriggerClientEvent('tommy-trucker:client:updateDelivery', party.leader, job.unloaded, job.totalKg) end
            if party.member then TriggerClientEvent('tommy-trucker:client:updateDelivery', party.member, job.unloaded, job.totalKg) end
        end
    else
        TriggerClientEvent('tommy-trucker:client:updateDelivery', src, job.unloaded, job.totalKg)
    end

    if job.unloaded >= job.totalKg then
        JobLoadingLock[lockKey] = nil
        CompleteDeliveryParty(src, job)
    end
end)

RegisterNetEvent('tommy-trucker:server:cancelJob', function()
    local src    = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player or not ActiveJobs[src] then return end

    local job = ActiveJobs[src]

    if job.isPartyJob and job.visibleId then
        local party = Parties[job.visibleId]
        if party then
            for _, memberSrc in ipairs({ party.leader, party.member }) do
                if memberSrc then
                    local MemberPlayer = exports.qbx_core:GetPlayer(memberSrc)
                    if MemberPlayer then
                        CancelCooldowns[MemberPlayer.PlayerData.citizenid] = os.time() + 600
                    end
                    ActiveJobs[memberSrc] = nil
                    lib.notify(memberSrc, { description = locale('error_job_canceled_party'), type = 'error' })
                    TriggerClientEvent('tommy-trucker:client:clearJob', memberSrc)
                end
            end
            party.jobData = nil
        end
    else
        ActiveJobs[src] = nil
        CancelCooldowns[Player.PlayerData.citizenid] = os.time() + 600
        lib.notify(src, { description = locale('error_canceled'), type = 'error' })
        TriggerClientEvent('tommy-trucker:client:clearJob', src)
    end
end)

RegisterNetEvent('tommy-trucker:server:rentalVehicleSpawned', function(plate)
    local src    = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player or not plate then return end

    -- Cho chìa khoá xe — dùng qbx_vehiclekeys nếu có, fallback notify
    local success, err = pcall(function()
        -- Nếu dùng qbx_vehiclekeys:
        exports['qbx_vehiclekeys']:GiveVehicleKeys(src, plate)
    end)

    if not success then
        -- Fallback: thử vehiclekeys tiêu chuẩn của QBX
        pcall(function()
            TriggerClientEvent('vehiclekeys:client:SetOwner', src, plate)
        end)
    end
end)

lib.callback.register('tommy-trucker:server:checkCargo', function(source, targetNetId)
    for _, job in pairs(ActiveJobs) do
        if job.vehicleNetId == targetNetId then
            if job.hasLoadedCargo then
                return { hasCargo = true, isIllegal = job.order.isIllegal }
            end
            return { hasCargo = false }
        end
    end
    return { hasCargo = false }
end)

lib.callback.register('tommy-trucker:server:confiscateCargo', function(source, targetNetId)
    local policeSource = source
    local Police       = exports.qbx_core:GetPlayer(policeSource)

    if not Police then return { success = false } end
    if Police.PlayerData.job.name ~= 'police' then return { success = false } end

    local targetSource, targetJob = nil, nil
    for src, job in pairs(ActiveJobs) do
        if job.vehicleNetId == targetNetId then
            targetSource = src
            targetJob    = job
            break
        end
    end

    if not targetJob                 then return { success = false } end
    if not targetJob.hasLoadedCargo  then return { success = false } end
    if not targetJob.order.isIllegal then return { success = false, wasIllegal = false } end

    local Driver = exports.qbx_core:GetPlayer(targetSource)
    if Driver then
        lib.notify(targetSource, { description = locale('error_cargo_confiscated'), type = 'error', duration = 7000 })
        CancelCooldowns[Driver.PlayerData.citizenid] = os.time() + 600
        ActiveJobs[targetSource] = nil
        TriggerClientEvent('tommy-trucker:client:clearJob', targetSource)
    end

    return { success = true, wasIllegal = true }
end)

-- ─── DOOR SYNC ───────────────────────────────────────────────────────────────

RegisterNetEvent('tommy-trucker:server:toggleDoors', function(vehicleNetId, shouldClose)
    local src = source
    if not ActiveJobs[src] then return end

    local job = ActiveJobs[src]

    if job.isPartyJob and job.visibleId then
        local party = Parties[job.visibleId]
        if party then
            if party.leader then TriggerClientEvent('tommy-trucker:client:toggleDoors', party.leader, vehicleNetId, shouldClose) end
            if party.member then TriggerClientEvent('tommy-trucker:client:toggleDoors', party.member, vehicleNetId, shouldClose) end
        end
    else
        TriggerClientEvent('tommy-trucker:client:toggleDoors', src, vehicleNetId, shouldClose)
    end
end)

-- ─── CLEANUP ─────────────────────────────────────────────────────────────────

AddEventHandler('playerDropped', function()
    local src           = source
    local party, visibleId = GetPlayerParty(src)
    if party then DisbandParty(visibleId, locale('party_member_disconnected')) end
    PartyInvites[src] = nil
    ActiveJobs[src]   = nil
end)

CreateThread(function()
    while true do
        Wait(60000)
        local now = os.time()
        for orderId, t in pairs(OrderCooldowns)  do if now >= t then OrderCooldowns[orderId]  = nil end end
        for cid,     t in pairs(CancelCooldowns) do if now >= t then CancelCooldowns[cid]      = nil end end

        CleanExpiredRentals()
    end
end)

-- ─── EXPORTS ─────────────────────────────────────────────────────────────────

exports('GetActiveJob',        function(source) return ActiveJobs[source] end)
exports('IsOrderAvailable',    function(orderId) return OrderTaken[orderId] == nil and (OrderCooldowns[orderId] == nil or os.time() >= OrderCooldowns[orderId]) end)