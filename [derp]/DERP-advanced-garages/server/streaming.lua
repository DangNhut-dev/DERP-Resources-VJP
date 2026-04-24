local QBX = exports.qbx_core

local TrackedVehicles    = {}
local PlayerGrid         = {}
local VehicleStatusCache = {}
local RecentlyDespawned  = {}

local function DebugPrint(message)
    if Config.Streaming.Debug then
        print('^3[STREAMING]^7 ' .. message)
    end
end

local function MarkVehicleDirty(plate)
    if not TrackedVehicles[plate] then return end
    TrackedVehicles[plate].isDirty       = true
    TrackedVehicles[plate].lastModified  = os.time()
    DebugPrint('Marked dirty: ' .. plate)
end

local function CoordsToGrid(coords)
    return math.floor(coords.x / Config.Streaming.GridSize),
           math.floor(coords.y / Config.Streaming.GridSize)
end

local function UpdatePlayerGrid()
    PlayerGrid = {}

    for _, playerId in ipairs(GetPlayers()) do
        local ped = GetPlayerPed(playerId)
        if DoesEntityExist(ped) then
            local coords = GetEntityCoords(ped)
            local gx, gy = CoordsToGrid(coords)

            local key = gx .. '_' .. gy
            if not PlayerGrid[key] then PlayerGrid[key] = {} end

            table.insert(PlayerGrid[key], { playerId = playerId, coords = coords })
        end
    end
end

local function GetNearestPlayerDistance(vehicleCoords)
    if not vehicleCoords then return 9999.0 end

    local vx = vehicleCoords.x or vehicleCoords[1]
    local vy = vehicleCoords.y or vehicleCoords[2]
    local vz = vehicleCoords.z or vehicleCoords[3]

    if not vx then return 9999.0 end

    local gx, gy = math.floor(vx / Config.Streaming.GridSize),
                   math.floor(vy / Config.Streaming.GridSize)

    local nearest = 9999.0
    local vecV    = vector3(vx, vy, vz)

    for dx = -1, 1 do
        for dy = -1, 1 do
            local key  = (gx + dx) .. '_' .. (gy + dy)
            local cell = PlayerGrid[key]

            if cell then
                for _, entry in ipairs(cell) do
                    local dist = #(entry.coords - vecV)
                    if dist < nearest then nearest = dist end
                end
            end
        end
    end

    return nearest
end

local function GetNearestPlayerSource(coords)
    if not coords then return nil end

    local nearestSrc  = nil
    local nearestDist = math.huge

    for _, playerId in ipairs(GetPlayers()) do
        local ped = GetPlayerPed(playerId)
        if DoesEntityExist(ped) then
            local dist = #(GetEntityCoords(ped) - coords)
            if dist < nearestDist then
                nearestDist = dist
                nearestSrc  = tonumber(playerId)
            end
        end
    end

    return nearestSrc, nearestDist
end

local function GiveVehicleKeysToOwner(citizenid, plate, vehicle, silent)
    if not citizenid or not plate or not vehicle then return false end
    if silent == nil then silent = true end

    local ownerSource = nil
    for src, player in pairs(QBX:GetQBPlayers()) do
        if player.PlayerData.citizenid == citizenid then
            ownerSource = src
            break
        end
    end

    if not ownerSource then
        DebugPrint('Owner offline for plate: ' .. plate .. ' - keys deferred')
        if TrackedVehicles[plate] then TrackedVehicles[plate].pendingKeys = true end
        return false
    end

    if DoesEntityExist(vehicle) then
        local success = exports.qbx_vehiclekeys:GiveKeys(ownerSource, vehicle, silent)
        if success then
            DebugPrint('Gave keys to owner: ' .. citizenid .. ' (plate: ' .. plate .. ')')
            if TrackedVehicles[plate] then TrackedVehicles[plate].pendingKeys = false end
            return true
        end
    end

    return false
end

RegisterNetEvent('DERP-advanced-garages:server:checkVehicleOwnership', function(plate, netId, silent)
    local src    = source
    local player = QBX:GetPlayer(src)
    if not player then return end

    local result = MySQL.query.await([[
        SELECT id FROM player_vehicles WHERE citizenid = ? AND plate = ? LIMIT 1
    ]], { player.PlayerData.citizenid, plate })

    if result and #result > 0 then
        local vehicle = NetworkGetEntityFromNetworkId(netId)
        if vehicle and DoesEntityExist(vehicle) then
            exports.qbx_vehiclekeys:GiveKeys(src, vehicle, silent or false)
            if TrackedVehicles[plate] then TrackedVehicles[plate].pendingKeys = false end
            DebugPrint('Gave keys to owner entering vehicle: ' .. plate)
        end
    end
end)

-- lockState đi chung với status
RegisterNetEvent('DERP-advanced-garages:server:receiveVehicleStatus', function(plate, netId, data)
    if not plate or not data then return end

    VehicleStatusCache[plate] = {
        status     = data.status,
        mods       = data.mods,
        fuel       = data.fuel,
        engine     = data.engine,
        body       = data.body,
        coords     = data.coords,
        lockState  = data.lockState,
        receivedAt = os.time()
    }

    if TrackedVehicles[plate] then
        if data.coords then
            TrackedVehicles[plate].coords = vector4(
                data.coords.x, data.coords.y, data.coords.z, data.coords.w or 0.0)
        end
        TrackedVehicles[plate].fuel   = data.fuel
        TrackedVehicles[plate].engine = data.engine
        TrackedVehicles[plate].body   = data.body
        if data.status    then TrackedVehicles[plate].status    = data.status    end
        if data.mods      then TrackedVehicles[plate].mods      = data.mods      end
        if data.lockState then TrackedVehicles[plate].lockState = data.lockState end
        MarkVehicleDirty(plate)
    end

    DebugPrint('Received and updated status for plate: ' .. plate)
end)

RegisterNetEvent('qb-vehiclekeys:server:setVehLockState', function(netId, lockState)
    if not netId or not lockState then return end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
        -- print('^1[LOCK DEBUG] Entity not found for netId: ' .. tostring(netId))
        return
    end

    local plate = string.gsub(GetVehicleNumberPlateText(vehicle), '^%s*(.-)%s*$', '%1')
    if not plate or plate == '' then
        -- print('^1[LOCK DEBUG] Empty plate for netId: ' .. tostring(netId))
        return
    end

    if TrackedVehicles[plate] then
        TrackedVehicles[plate].lockState = lockState
        MarkVehicleDirty(plate)
        -- print('^2[LOCK DEBUG] Updated lockState=' .. lockState .. ' for ' .. plate .. ' | isDirty=' .. tostring(TrackedVehicles[plate].isDirty))
    else
        -- print('^3[LOCK DEBUG] Plate not tracked: ' .. plate)
    end
end)

local function RequestVehicleStatusWithRetry(plate, netId, coords, timeoutMs)
    timeoutMs = timeoutMs or (Config.Streaming.RequestStatusTimeout or 4000)
    local maxRetries = Config.Streaming.RequestStatusRetries or 2

    for attempt = 1, maxRetries do
        local targetSrc = nil

        if coords then
            targetSrc = GetNearestPlayerSource(type(coords) == 'table' and vector3(coords.x or coords[1], coords.y or coords[2], coords.z or coords[3]) or coords)
        end

        if not targetSrc then
            targetSrc = -1
        end

        VehicleStatusCache[plate] = nil
        TriggerClientEvent('DERP-advanced-garages:client:requestVehicleStatus', targetSrc, netId, plate)

        local waited = 0
        while not VehicleStatusCache[plate] and waited < timeoutMs do
            Wait(100)
            waited = waited + 100
        end

        if VehicleStatusCache[plate] then
            DebugPrint('Status received for ' .. plate .. ' on attempt ' .. attempt)
            return true
        end

        DebugPrint('Status timeout for ' .. plate .. ' attempt ' .. attempt .. '/' .. maxRetries)
    end

    return false
end

local function SaveDirtyVehicles()
    local dirtyVehicles = {}
    local currentTime   = os.time()

    local totalTracked = 0
    for _ in pairs(TrackedVehicles) do totalTracked = totalTracked + 1 end
    -- print('^3[SAVE DEBUG] SaveDirtyVehicles called, checking ' .. totalTracked .. ' vehicles')

    for plate, tracked in pairs(TrackedVehicles) do
        local shouldSave = tracked.isDirty

        if tracked.state == "spawned" and tracked.entity then
            if (currentTime - (tracked.lastSave or 0)) >= Config.Streaming.MaxSaveInterval then
                shouldSave = true
                MarkVehicleDirty(plate)
            end
        end

        if shouldSave then
            -- print('^3[SAVE DEBUG] Dirty: ' .. plate .. ' | state=' .. tostring(tracked.state) .. ' | lockState=' .. tostring(tracked.lockState))
            table.insert(dirtyVehicles, plate)
        end
    end

    if #dirtyVehicles == 0 then
        -- print('^3[SAVE DEBUG] No dirty vehicles to save')
        return
    end

    -- print('^3[SAVE DEBUG] Saving ' .. #dirtyVehicles .. ' dirty vehicles')

    for _, plate in ipairs(dirtyVehicles) do
        local tracked = TrackedVehicles[plate]
        if tracked and tracked.state == "spawned" and tracked.netId then
            local entityCoords = tracked.entity and DoesEntityExist(tracked.entity) and GetEntityCoords(tracked.entity) or tracked.coords
            RequestVehicleStatusWithRetry(plate, tracked.netId, entityCoords, 3000)
        end
    end

    Wait(math.min(3000, Config.Streaming.RequestStatusTimeout or 4000))

    local batchSize  = Config.Streaming.SQLBatchSize or 50
    local savedCount = 0

    for i = 1, #dirtyVehicles, batchSize do
        for j = i, math.min(i + batchSize - 1, #dirtyVehicles) do
            local plate   = dirtyVehicles[j]
            local tracked = TrackedVehicles[plate]
            if not tracked then goto nextVehicle end

            local coords    = tracked.coords
            local fuel      = tracked.fuel
            local engine    = tracked.engine
            local body      = tracked.body
            local status    = tracked.status
            local mods      = tracked.mods
            local lockState = tracked.lockState or 2

            if VehicleStatusCache[plate] then
                local cached = VehicleStatusCache[plate]
                fuel   = cached.fuel   or fuel
                engine = cached.engine or engine
                body   = cached.body   or body
                if cached.status    then status    = cached.status    end
                if cached.mods      then mods      = cached.mods      end
                if cached.lockState then lockState = cached.lockState end
                if cached.coords then
                    coords = vector4(cached.coords.x, cached.coords.y, cached.coords.z, cached.coords.w or 0.0)
                end
            end

            if tracked.entity and DoesEntityExist(tracked.entity) then
                local lc = GetEntityCoords(tracked.entity)
                local lh = GetEntityHeading(tracked.entity)
                coords = vector4(lc.x, lc.y, lc.z, lh)

                if not VehicleStatusCache[plate] then
                    fuel   = Entity(tracked.entity).state.fuel or fuel
                    engine = GetVehicleEngineHealth(tracked.entity)
                    body   = GetVehicleBodyHealth(tracked.entity)
                end
            end

            -- MySQL.update.await([[
            --     UPDATE player_vehicles
            --     SET coords = ?, fuel = ?, engine = ?, body = ?, status = ?, mods = ?, lock_state = ?
            --     WHERE plate = ? AND state = 0
            -- ]], {
            --     json.encode(coords), fuel, engine, body,
            --     status and json.encode(status) or nil,
            --     mods   and json.encode(mods)   or nil,
            --     lockState,
            --     plate
            -- })

            MySQL.update.await([[
                UPDATE player_vehicles
                SET coords = ?, fuel = ?, engine = ?, body = ?, mods = ?, lock_state = ?
                WHERE plate = ? AND state = 0
            ]], {
                json.encode(coords), fuel, engine, body,
                mods   and json.encode(mods)   or nil,
                lockState,
                plate
            })

            TrackedVehicles[plate].isDirty  = false
            TrackedVehicles[plate].lastSave = os.time()
            VehicleStatusCache[plate]       = nil
            savedCount = savedCount + 1

            ::nextVehicle::
        end

        if i + batchSize <= #dirtyVehicles then Wait(100) end
    end

    if savedCount > 0 then
        DebugPrint('Periodic save: ' .. savedCount .. ' vehicles saved')
    end
end

local function DespawnVehicle(plate)
    if not TrackedVehicles[plate] then return end

    local tracked = TrackedVehicles[plate]

    tracked.state           = "despawning"
    tracked.despawnMarkedAt = 0

    CreateThread(function()
        DebugPrint('Despawning (async): ' .. plate)

        if tracked.entity and DoesEntityExist(tracked.entity) then
            local liveCoords  = GetEntityCoords(tracked.entity)
            local liveHeading = GetEntityHeading(tracked.entity)

            local fuel   = Entity(tracked.entity).state.fuel or tracked.fuel or 100
            local engine = GetVehicleEngineHealth(tracked.entity)
            local body   = GetVehicleBodyHealth(tracked.entity)
            local status = tracked.status
            local mods   = tracked.mods

            -- Request status (bao gồm lockState) với retry
            if tracked.netId then
                RequestVehicleStatusWithRetry(plate, tracked.netId, liveCoords)
            end

            if VehicleStatusCache[plate] then
                local cached = VehicleStatusCache[plate]
                fuel   = cached.fuel   or fuel
                engine = cached.engine or engine
                body   = cached.body   or body
                -- if cached.status    then status = cached.status               end
                if cached.mods      then mods   = cached.mods                 end
                if cached.lockState then tracked.lockState = cached.lockState end
                if cached.coords then
                    liveCoords  = vector3(cached.coords.x, cached.coords.y, cached.coords.z)
                    liveHeading = cached.coords.w or liveHeading
                end
            end

            if not mods then
                local dbMods = MySQL.scalar.await(
                    'SELECT mods FROM player_vehicles WHERE plate = ? LIMIT 1', { plate })
                if dbMods then
                    mods = type(dbMods) == 'string' and json.decode(dbMods) or dbMods
                    DebugPrint('Despawn fallback: loaded mods from DB for ' .. plate)
                end
            end

            if DoesEntityExist(tracked.entity) then
                local freshCoords  = GetEntityCoords(tracked.entity)
                local freshHeading = GetEntityHeading(tracked.entity)
                liveCoords  = freshCoords
                liveHeading = freshHeading
            end

            tracked.coords = vector4(liveCoords.x, liveCoords.y, liveCoords.z, liveHeading)
            tracked.fuel   = fuel
            tracked.engine = engine
            tracked.body   = body
            tracked.status = status
            tracked.mods   = mods

            DebugPrint('Despawn saving: ' .. plate
                .. ' | Engine: ' .. math.floor(engine)
                .. ' | Lock: ' .. tostring(tracked.lockState or 2)
                .. ' | Mods: ' .. (mods and 'YES (len=' .. #json.encode(mods) .. ')' or 'NO/NIL'))

            -- local success = MySQL.update.await([[
            --     UPDATE player_vehicles
            --     SET coords = ?, fuel = ?, engine = ?, body = ?, status = ?, mods = ?, lock_state = ?
            --     WHERE plate = ? AND state = 0
            -- ]], {
            --     json.encode(tracked.coords), fuel, engine, body,
            --     status and json.encode(status) or nil,
            --     mods   and json.encode(mods)   or nil,
            --     tracked.lockState or 2,
            --     plate
            -- })

            local success = MySQL.update.await([[
                UPDATE player_vehicles
                SET coords = ?, fuel = ?, engine = ?, body = ?, mods = ?, lock_state = ?
                WHERE plate = ? AND state = 0
            ]], {
                json.encode(tracked.coords), fuel, engine, body,
                mods   and json.encode(mods)   or nil,
                tracked.lockState or 2,
                plate
            })

            DebugPrint('Despawn save ' .. (success and 'OK' or 'FAILED') .. ': ' .. plate)

            local entity = tracked.entity
            local netId  = tracked.netId

            if DoesEntityExist(entity) then
                DeleteEntity(entity)
            end

            SetTimeout(1000, function()
                if DoesEntityExist(entity) then DeleteEntity(entity) end
            end)

            SetTimeout(3000, function()
                if netId then
                    local e = NetworkGetEntityFromNetworkId(netId)
                    if e and e ~= 0 and DoesEntityExist(e) then DeleteEntity(e) end
                end
            end)
        else
            MarkVehicleDirty(plate)
        end

        if TrackedVehicles[plate] then
            TrackedVehicles[plate].entity   = nil
            TrackedVehicles[plate].netId    = nil
            TrackedVehicles[plate].state    = "saved"
            TrackedVehicles[plate].lastSave = os.time()
        end

        VehicleStatusCache[plate]    = nil
        RecentlyDespawned[plate]     = os.time()

        DebugPrint('Despawn complete (async): ' .. plate)
    end)
end

local function SpawnVehicleFromDB(plate)
    if not TrackedVehicles[plate] then return end

    local tracked = TrackedVehicles[plate]

    if tracked.state == "spawning" or tracked.state == "spawned" then return end
    if tracked.entity and DoesEntityExist(tracked.entity) then return end

    if RecentlyDespawned[plate] then
        local timeSince = os.time() - RecentlyDespawned[plate]
        if timeSince < 10 then
            DebugPrint('Skip spawn - recently despawned: ' .. plate .. ' (' .. timeSince .. 's ago)')
            return
        end
        RecentlyDespawned[plate] = nil
    end

    for _, vehicle in ipairs(GetAllVehicles()) do
        if DoesEntityExist(vehicle) then
            local existing = string.gsub(GetVehicleNumberPlateText(vehicle), '^%s*(.-)%s*$', '%1')
            if existing == plate then
                DebugPrint('Vehicle already in world: ' .. plate)
                tracked.entity = vehicle
                tracked.netId  = NetworkGetNetworkIdFromEntity(vehicle)
                tracked.state  = "spawned"
                return
            end
        end
    end

    tracked.state = "spawning"

    local result = MySQL.query.await([[
        SELECT *, lock_state FROM player_vehicles WHERE plate = ? AND state = 0 LIMIT 1
    ]], { plate })

    if not result or #result == 0 then
        tracked.state = "saved"
        return
    end

    local rec = result[1]

    DebugPrint('Loading from DB: ' .. plate
        .. ' | Engine: ' .. (rec.engine or 'nil')
        .. ' | Body: ' .. (rec.body or 'nil')
        .. ' | Lock: ' .. tostring(rec.lock_state or 2)
        .. ' | Mods: ' .. (rec.mods and 'YES' or 'NO/NIL'))

    local decoded = type(rec.coords) == 'string' and json.decode(rec.coords) or rec.coords
    if not decoded or not decoded.x then tracked.state = "saved" return end

    local coords  = vector4(decoded.x + 0.0, decoded.y + 0.0, decoded.z + 0.0, decoded.w or 0.0)
    local vehicle = CreateVehicleServerSetter(GetHashKey(rec.vehicle), "automobile",
        coords.x, coords.y, coords.z, coords.w)

    if not vehicle or vehicle == 0 then tracked.state = "saved" return end

    local timeout = 0
    while not DoesEntityExist(vehicle) and timeout < 50 do
        Wait(50)
        timeout = timeout + 1
    end

    if not DoesEntityExist(vehicle) then tracked.state = "saved" return end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if not netId or netId == 0 then
        DeleteEntity(vehicle)
        tracked.state = "saved"
        return
    end

    SetVehicleNumberPlateText(vehicle, plate)

    Wait(300)

    local modsToApply = nil
    if rec.mods then
        modsToApply = type(rec.mods) == 'string' and json.decode(rec.mods) or rec.mods
    end

    if modsToApply and type(modsToApply) == 'table' then
        modsToApply.plate = plate
        Entity(vehicle).state:set('pendingMods', modsToApply, true)
        TriggerClientEvent('derp:applyVehicleProps', -1, netId, modsToApply)
        DebugPrint('Set pendingMods + triggered applyVehicleProps for: ' .. plate)
    end

    Wait(200)

    SetVehicleNumberPlateText(vehicle, plate)

    SetTimeout(1000, function()
        local e = NetworkGetEntityFromNetworkId(netId)
        if e and e ~= 0 and DoesEntityExist(e) then
            SetVehicleNumberPlateText(e, plate)
        end
    end)

    local engineHealth = rec.engine or 1000.0
    local bodyHealth   = rec.body   or 1000.0
    local fuelLevel    = rec.fuel   or 100
    local lockState    = rec.lock_state or tracked.lockState or 2

    DebugPrint('Applying state: ' .. plate .. ' | Engine: ' .. engineHealth .. ' | Body: ' .. bodyHealth .. ' | Fuel: ' .. fuelLevel .. ' | Lock: ' .. lockState)

    Entity(vehicle).state:set('fuel', fuelLevel, true)

    TriggerClientEvent('derp:applyVehicleState', -1, netId, {
        fuel   = fuelLevel,
        engine = engineHealth,
        body   = bodyHealth
    })

    Wait(200)

    -- if rec.status then
    --     local status = type(rec.status) == 'string' and json.decode(rec.status) or rec.status
    --     if status then
    --         TriggerClientEvent('derp:applyVehicleStatus', -1, netId, status)
    --         DebugPrint('Applied status for: ' .. plate)
    --     end
    -- end

    TriggerClientEvent('derp:applyVehicleLockState', -1, netId, lockState)
    Entity(vehicle).state:set('doorslockstate', lockState, true)

    tracked.entity    = vehicle
    tracked.netId     = netId
    tracked.coords    = coords
    tracked.fuel      = fuelLevel
    tracked.engine    = engineHealth
    tracked.body      = bodyHealth
    tracked.lockState = lockState
    -- tracked.status    = type(rec.status) == 'string' and json.decode(rec.status) or rec.status
    tracked.status    = nil
    tracked.mods      = modsToApply
    tracked.state     = "spawned"
    tracked.despawnMarkedAt = 0
    tracked.lastSave        = os.time()

    tracked.gridX, tracked.gridY = CoordsToGrid(coords)

    CreateThread(function()
        local maxRetries = 5
        for i = 1, maxRetries do
            Wait(2000)
            if not DoesEntityExist(vehicle) then return end
            local success = GiveVehicleKeysToOwner(rec.citizenid, plate, vehicle, true)
            if success then return end
        end
        DebugPrint('Failed to give keys after ' .. maxRetries .. ' retries: ' .. plate)
    end)

    DebugPrint('Spawned: ' .. plate .. ' (NetID: ' .. netId .. ')')
end

local function StreamingMainLoop()
    CreateThread(function()
        while true do
            Wait(Config.Streaming.CheckInterval)

            if not Config.Streaming.Enabled then goto continue end

            UpdatePlayerGrid()

            local despawnedCount = 0
            local spawnedCount   = 0
            local spawnProcessed = 0

            for plate, tracked in pairs(TrackedVehicles) do
                DebugPrint('Phase1 check: ' .. plate .. ' state=' .. tostring(tracked.state)
                    .. ' entity=' .. tostring(tracked.entity ~= nil and DoesEntityExist(tracked.entity)))

                if tracked.state ~= "spawned" and tracked.state ~= "pending_despawn" then
                    goto nextDespawnCheck
                end

                local entityExists = tracked.entity and DoesEntityExist(tracked.entity)
                local currentCoords

                if entityExists then
                    currentCoords  = GetEntityCoords(tracked.entity)
                    tracked.coords = currentCoords
                    tracked.gridX, tracked.gridY = CoordsToGrid(currentCoords)
                else
                    currentCoords = tracked.coords
                    if tracked.entity then
                        DebugPrint('Entity lost: ' .. plate)
                        tracked.entity = nil
                        tracked.netId  = nil
                    end
                end

                local nearestDist = GetNearestPlayerDistance(currentCoords)

                if nearestDist > Config.Streaming.DespawnDistance then
                    if tracked.despawnMarkedAt == 0 then
                        tracked.despawnMarkedAt = os.time()
                        tracked.state = "pending_despawn"
                        DebugPrint('Marked for despawn: ' .. plate .. ' (' .. math.floor(nearestDist) .. 'm)')
                    elseif (os.time() - tracked.despawnMarkedAt) >= Config.Streaming.DespawnDelay then
                        DespawnVehicle(plate)
                        despawnedCount = despawnedCount + 1
                    end
                else
                    if tracked.despawnMarkedAt > 0 then
                        tracked.despawnMarkedAt = 0
                        tracked.state = "spawned"
                        DebugPrint('Despawn cancelled: ' .. plate)
                    end

                    if not entityExists and tracked.state == "spawned" then
                        DebugPrint('Entity lost but player near - respawning: ' .. plate)
                        tracked.state = "saved"
                    end
                end

                ::nextDespawnCheck::
            end

            for plate, tracked in pairs(TrackedVehicles) do
                if spawnProcessed >= Config.Streaming.MaxVehiclesPerCycle then break end

                if tracked.state == "saved" and tracked.coords then
                    if GetNearestPlayerDistance(tracked.coords) <= Config.Streaming.RespawnDistance then
                        SpawnVehicleFromDB(plate)
                        spawnedCount   = spawnedCount + 1
                        spawnProcessed = spawnProcessed + 1
                    end
                end

                if spawnProcessed % 10 == 0 and spawnProcessed > 0 then Wait(50) end
            end

            if Config.Streaming.Debug and (despawnedCount > 0 or spawnedCount > 0) then
                DebugPrint(string.format('Cycle: Despawned=%d, Spawned=%d',
                    despawnedCount, spawnedCount))
            end

            ::continue::
        end
    end)
end

local function PeriodicSaveLoop()
    CreateThread(function()
        while true do
            Wait(Config.Streaming.SaveInterval)
            if Config.Streaming.Enabled then
                -- print('^3[SAVE DEBUG] PeriodicSaveLoop triggered')
                SaveDirtyVehicles()
            else
                -- print('^1[SAVE DEBUG] Streaming not enabled, skipping save')
            end
        end
    end)
end

local function BackgroundStatusSync()
    CreateThread(function()
        while true do
            Wait(Config.Streaming.StatusSyncInterval or 30000)

            if not Config.Streaming.Enabled then goto continue end

            local syncCount = 0

            for plate, tracked in pairs(TrackedVehicles) do
                if tracked.state == "spawned" and tracked.entity
                    and DoesEntityExist(tracked.entity) and tracked.netId then

                    local nearestSrc, nearestDist = GetNearestPlayerSource(GetEntityCoords(tracked.entity))

                    if nearestSrc and nearestDist < Config.Streaming.DespawnDistance then
                        VehicleStatusCache[plate] = nil
                        TriggerClientEvent('DERP-advanced-garages:client:requestVehicleStatus',
                            nearestSrc, tracked.netId, plate)
                        syncCount = syncCount + 1
                        if tracked.pendingKeys and tracked.entity then
                            GiveVehicleKeysToOwner(tracked.owner, plate, tracked.entity, true)
                        end

                        if syncCount % 5 == 0 then Wait(500) end
                    end
                end
            end

            if syncCount > 0 then
                DebugPrint('Background sync: ' .. syncCount .. ' vehicles')
            end

            ::continue::
        end
    end)
end

local function LoadStreamedVehiclesOnStart()
    if not Config.Streaming.AutoRecoverOnStart then return end

    DebugPrint('Loading streamed vehicles from database...')

    local result = MySQL.query.await([[
        SELECT *, lock_state FROM player_vehicles WHERE state = 0 AND coords IS NOT NULL
    ]])

    if not result then
        DebugPrint('No vehicles to recover')
        return
    end

    for _, rec in ipairs(result) do
        local plate   = rec.plate
        local decoded = type(rec.coords) == 'string' and json.decode(rec.coords) or rec.coords

        if decoded and decoded.x then
            local coords = vector4(decoded.x + 0.0, decoded.y + 0.0, decoded.z + 0.0, decoded.w or 0.0)
            local gx, gy = CoordsToGrid(coords)

            TrackedVehicles[plate] = {
                entity  = nil,
                netId   = nil,
                coords  = coords,
                heading = coords.w or 0.0,
                owner   = rec.citizenid,

                fuel      = rec.fuel   or 100,
                engine    = rec.engine or 1000,
                body      = rec.body   or 1000,
                lockState = rec.lock_state or 2,
                status    = type(rec.status) == 'string' and json.decode(rec.status) or rec.status,
                mods      = type(rec.mods)   == 'string' and json.decode(rec.mods)   or rec.mods,

                state = "saved",

                isDirty           = false,
                lastModified      = os.time(),
                lastSave          = os.time(),
                lastDistanceCheck = 0,

                gridX = gx,
                gridY = gy,

                despawnMarkedAt = 0,
                idleSince       = 0
            }

            DebugPrint('Registered for streaming: ' .. plate)
        end
    end

    DebugPrint('Loaded ' .. #result .. ' vehicles into streaming system')
end

function RegisterVehicleSpawn(plate, entity, coords, owner, dbRecord)
    if not plate or not entity then return end
    if not DoesEntityExist(entity) then return end

    local netId = NetworkGetNetworkIdFromEntity(entity)
    if not netId or netId == 0 then return end

    if type(coords) == "table" then
        coords = vector4(coords.x, coords.y, coords.z, coords.w or 0.0)
    end

    if not coords or not coords.x then return end

    local gx, gy = CoordsToGrid(coords)

    local mods   = nil
    local status = nil
    local fuel   = 100
    local engine = 1000
    local body   = 1000

    if dbRecord then
        mods   = type(dbRecord.mods)   == 'string' and json.decode(dbRecord.mods)   or dbRecord.mods
        status = type(dbRecord.status) == 'string' and json.decode(dbRecord.status) or dbRecord.status
        fuel   = dbRecord.fuel   or 100
        engine = dbRecord.engine or 1000
        body   = dbRecord.body   or 1000
    end

    TrackedVehicles[plate] = {
        lockState = 2,
        entity  = entity,
        netId   = netId,
        coords  = coords,
        heading = coords.w or 0.0,
        owner   = owner,

        fuel   = fuel,
        engine = engine,
        body   = body,
        mods   = mods,
        status = status,

        state = "spawned",

        isDirty           = false,
        lastModified      = os.time(),
        lastSave          = 0,
        lastDistanceCheck = 0,

        gridX = gx,
        gridY = gy,

        despawnMarkedAt = 0,
        idleSince       = 0
    }

    MarkVehicleDirty(plate)

    if owner then GiveVehicleKeysToOwner(owner, plate, entity, false) end

    DebugPrint('Registered vehicle spawn: ' .. plate .. ' | Mods: ' .. (mods and 'YES' or 'NO'))
end

function UnregisterVehicle(plate)
    if not plate then return end

    if TrackedVehicles[plate] then
        local entity = TrackedVehicles[plate].entity
        if entity and DoesEntityExist(entity) then
            SetTimeout(500, function()
                if DoesEntityExist(entity) then DeleteEntity(entity) end
            end)
        end
        TrackedVehicles[plate] = nil
    end

    DebugPrint('Unregistered vehicle: ' .. plate)
end

-- Helper: build save data từ tracked + cache
local function BuildSaveData(plate, tracked)
    local saveData = {
        plate     = plate,
        coords    = tracked.coords,
        fuel      = tracked.fuel   or 100,
        engine    = tracked.engine or 1000,
        body      = tracked.body   or 1000,
        status    = tracked.status,
        mods      = tracked.mods,
        lockState = tracked.lockState or 2
    }

    if tracked.state == "spawned" and tracked.entity and DoesEntityExist(tracked.entity) then
        local lc = GetEntityCoords(tracked.entity)
        local lh = GetEntityHeading(tracked.entity)
        saveData.coords = vector4(lc.x, lc.y, lc.z, lh)

        if VehicleStatusCache[plate] then
            local cached    = VehicleStatusCache[plate]
            saveData.fuel   = cached.fuel   or saveData.fuel
            saveData.engine = cached.engine or saveData.engine
            saveData.body   = cached.body   or saveData.body
            if cached.status    then saveData.status    = cached.status    end
            if cached.mods      then saveData.mods      = cached.mods      end
            if cached.lockState then saveData.lockState = cached.lockState end
        else
            saveData.fuel   = Entity(tracked.entity).state.fuel or tracked.fuel
            saveData.engine = GetVehicleEngineHealth(tracked.entity) or tracked.engine
            saveData.body   = GetVehicleBodyHealth(tracked.entity)  or tracked.body
        end
    end

    return saveData
end

-- Helper: execute save query
local function ExecuteSaveQuery(record, isSync)
    -- print('^2[SAVE DEBUG] Saving ' .. record.plate .. ' | lockState=' .. tostring(record.lockState))
    
    -- local params = {
    --     json.encode(record.coords),
    --     record.fuel, record.engine, record.body,
    --     record.status and json.encode(record.status) or nil,
    --     record.mods   and json.encode(record.mods)   or nil,
    --     record.lockState or 2,
    --     record.plate
    -- }

    -- local query = [[
    --     UPDATE player_vehicles
    --     SET coords = ?, fuel = ?, engine = ?, body = ?, status = ?, mods = ?, lock_state = ?
    --     WHERE plate = ? AND state = 0
    -- ]]

    local params = {
        json.encode(record.coords),
        record.fuel, record.engine, record.body,
        record.mods   and json.encode(record.mods)   or nil,
        record.lockState or 2,
        record.plate
    }

    local query = [[
        UPDATE player_vehicles
        SET coords = ?, fuel = ?, engine = ?, body = ?, mods = ?, lock_state = ?
        WHERE plate = ? AND state = 0
    ]]

    if isSync then
        return MySQL.Sync.execute(query, params)
    else
        return MySQL.update.await(query, params)
    end
end

function SaveAllTrackedVehicles()
    DebugPrint('Force-saving all tracked vehicles...')

    local toSave       = {}
    local savedCount   = 0
    local skippedCount = 0

    local statusRequests = {}
    for plate, tracked in pairs(TrackedVehicles) do
        if tracked.state == "spawned" and tracked.entity
            and DoesEntityExist(tracked.entity) and tracked.netId then
            table.insert(statusRequests, { plate = plate, netId = tracked.netId, entity = tracked.entity })
        end
    end

    if #statusRequests > 0 then
        DebugPrint('Requesting status for ' .. #statusRequests .. ' vehicles...')

        for _, req in ipairs(statusRequests) do
            local entityCoords = DoesEntityExist(req.entity) and GetEntityCoords(req.entity) or nil
            local targetSrc = entityCoords and GetNearestPlayerSource(entityCoords) or -1
            VehicleStatusCache[req.plate] = nil
            TriggerClientEvent('DERP-advanced-garages:client:requestVehicleStatus',
                targetSrc or -1, req.netId, req.plate)
        end

        Wait(5000)

        local received = 0
        for _, req in ipairs(statusRequests) do
            if VehicleStatusCache[req.plate] then received = received + 1 end
        end
        DebugPrint('Received ' .. received .. '/' .. #statusRequests .. ' status responses')
    end

    for plate, tracked in pairs(TrackedVehicles) do
        local saveData = BuildSaveData(plate, tracked)

        if not saveData.coords then
            skippedCount = skippedCount + 1
            goto skipVehicle
        end

        table.insert(toSave, saveData)
        ::skipVehicle::
    end

    local batchSize = Config.Streaming.SQLBatchSize or 50

    for i = 1, #toSave, batchSize do
        for j = i, math.min(i + batchSize - 1, #toSave) do
            local record  = toSave[j]
            local success = ExecuteSaveQuery(record, false)

            if success then
                savedCount = savedCount + 1
                if TrackedVehicles[record.plate] then
                    TrackedVehicles[record.plate].lastSave = os.time()
                    TrackedVehicles[record.plate].isDirty  = false
                end
                VehicleStatusCache[record.plate] = nil
            end
        end

        if i + batchSize <= #toSave then Wait(100) end
    end

    DebugPrint(string.format('Force-save complete: %d saved, %d skipped', savedCount, skippedCount))

    return savedCount
end

local function CountTrackedVehicles()
    local count = 0
    for _ in pairs(TrackedVehicles) do count = count + 1 end
    return count
end

local function DespawnAllVehicles()
    local despawnedCount = 0
    local savedCount     = 0

    DebugPrint('Despawning all tracked vehicles...')

    -- Best effort: request fresh status từ client trước khi save
    local statusRequests = {}
    for plate, tracked in pairs(TrackedVehicles) do
        if tracked.state == "spawned" and tracked.entity
            and DoesEntityExist(tracked.entity) and tracked.netId then
            local entityCoords = GetEntityCoords(tracked.entity)
            local nearSrc = GetNearestPlayerSource(entityCoords)
            if nearSrc then
                VehicleStatusCache[plate] = nil
                TriggerClientEvent('DERP-advanced-garages:client:requestVehicleStatus',
                    nearSrc, tracked.netId, plate)
                table.insert(statusRequests, plate)
            end
        end
    end

    if #statusRequests > 0 then
        Wait(2000)
        local received = 0
        for _, p in ipairs(statusRequests) do
            if VehicleStatusCache[p] then received = received + 1 end
        end
        DebugPrint('DespawnAll pre-save: received ' .. received .. '/' .. #statusRequests .. ' status')
    end

    for plate, tracked in pairs(TrackedVehicles) do
        local saveData = BuildSaveData(plate, tracked)

        if saveData.coords then
            local success = ExecuteSaveQuery(saveData, true)
            if success then savedCount = savedCount + 1 end
        end

        if tracked.entity and DoesEntityExist(tracked.entity) then
            local entity = tracked.entity
            local netId  = tracked.netId

            DeleteEntity(entity)

            SetTimeout(500,  function() if DoesEntityExist(entity) then DeleteEntity(entity) end end)
            SetTimeout(1000, function()
                if netId then
                    local e = NetworkGetEntityFromNetworkId(netId)
                    if e and e ~= 0 and DoesEntityExist(e) then DeleteEntity(e) end
                end
            end)

            despawnedCount = despawnedCount + 1
        end
    end

    return despawnedCount, savedCount
end

AddEventHandler('playerDropped', function(reason)
    if not Config.Streaming.SaveOnPlayerQuit then return end

    local src    = source
    local player = QBX:GetPlayer(src)
    if not player then return end

    local ped          = GetPlayerPed(src)
    local playerCoords = DoesEntityExist(ped) and GetEntityCoords(ped) or nil
    if not playerCoords then return end

    local toSave = {}

    for plate, tracked in pairs(TrackedVehicles) do
        local shouldSave = tracked.owner == player.PlayerData.citizenid

        if not shouldSave and tracked.state == "spawned" and tracked.entity and DoesEntityExist(tracked.entity) then
            if #(playerCoords - GetEntityCoords(tracked.entity)) <= (Config.Streaming.PlayerQuitSaveRadius or 150) then
                shouldSave = true
            end
        end

        if shouldSave then
            local saveData = BuildSaveData(plate, tracked)
            if saveData.coords then table.insert(toSave, saveData) end
        end
    end

    for _, record in ipairs(toSave) do
        ExecuteSaveQuery(record, true)
    end

    if #toSave > 0 then
        DebugPrint('Player disconnect save: ' .. #toSave .. ' vehicles for ' .. player.PlayerData.citizenid)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    DebugPrint('RESOURCE STOP: ' .. CountTrackedVehicles() .. ' tracked vehicles')

    if Config.Streaming.DespawnOnResourceStop then
        local d, s = DespawnAllVehicles()
        DebugPrint('Despawn complete: ' .. d .. ' despawned, ' .. s .. ' saved')
    elseif Config.Streaming.SaveOnResourceStop then
        local savedCount = 0

        for plate, tracked in pairs(TrackedVehicles) do
            local saveData = BuildSaveData(plate, tracked)

            if saveData.coords then
                local ok = ExecuteSaveQuery(saveData, true)
                if ok then savedCount = savedCount + 1 end
            end
        end

        DebugPrint('Save complete: ' .. savedCount .. ' vehicles')
    end

    TrackedVehicles    = {}
    VehicleStatusCache = {}
    PlayerGrid         = {}
    RecentlyDespawned  = {}

    DebugPrint('RESOURCE STOP COMPLETE')
end)

AddEventHandler('txAdmin:events:serverShuttingDown', function()
    local total = CountTrackedVehicles()
    DebugPrint('SERVER SHUTDOWN: ' .. total .. ' tracked vehicles')

    if total == 0 then
        DebugPrint('Already saved by onResourceStop')
        return
    end

    local requested = 0
    for plate, tracked in pairs(TrackedVehicles) do
        if tracked.state == "spawned" and tracked.entity
            and DoesEntityExist(tracked.entity) and tracked.netId then
            local entityCoords = GetEntityCoords(tracked.entity)
            local nearSrc = GetNearestPlayerSource(entityCoords)
            if nearSrc then
                VehicleStatusCache[plate] = nil
                TriggerClientEvent('DERP-advanced-garages:client:requestVehicleStatus',
                    nearSrc, tracked.netId, plate)
                requested = requested + 1
            end
        end
    end

    if requested > 0 then
        Wait(2000)
    end

    local savedCount = 0

    for plate, tracked in pairs(TrackedVehicles) do
        local saveData = BuildSaveData(plate, tracked)

        if saveData.coords then
            local ok = ExecuteSaveQuery(saveData, true)
            if ok then savedCount = savedCount + 1 end
        end
    end

    DebugPrint('SERVER SHUTDOWN SAVE COMPLETE: ' .. savedCount .. ' vehicles')
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    Wait(5000)
    LoadStreamedVehiclesOnStart()

    Wait(2000)
    StreamingMainLoop()
    PeriodicSaveLoop()
    BackgroundStatusSync()

    DebugPrint('Streaming system started')
end)

CreateThread(function()
    while true do
        Wait(300000)

        local currentTime = os.time()
        local cleaned     = 0

        for plate, data in pairs(VehicleStatusCache) do
            if (currentTime - data.receivedAt) > 300 then
                VehicleStatusCache[plate] = nil
                cleaned = cleaned + 1
            end
        end

        if cleaned > 0 then DebugPrint('Cleaned ' .. cleaned .. ' status cache entries') end
    end
end)

CreateThread(function()
    while true do
        Wait(30000)

        local currentTime = os.time()
        local cleaned     = 0

        for plate, timestamp in pairs(RecentlyDespawned) do
            if (currentTime - timestamp) > 30 then
                RecentlyDespawned[plate] = nil
                cleaned = cleaned + 1
            end
        end

        if cleaned > 0 then DebugPrint('Cleaned ' .. cleaned .. ' recently despawned entries') end
    end
end)

lib.addCommand('streaming:stats', {
    help = 'Get streaming system statistics',
    restricted = 'group.admin'
}, function(source)
    local stats = { spawned = 0, saved = 0, pending = 0, spawning = 0, dirty = 0 }

    for _, tracked in pairs(TrackedVehicles) do
        if     tracked.state == "spawned"         then stats.spawned  = stats.spawned  + 1
        elseif tracked.state == "saved"           then stats.saved    = stats.saved    + 1
        elseif tracked.state == "pending_despawn" then stats.pending  = stats.pending  + 1
        elseif tracked.state == "spawning"        then stats.spawning = stats.spawning + 1
        end
        if tracked.isDirty then stats.dirty = stats.dirty + 1 end
    end

    print(string.format('^2[STREAMING STATS] Spawned=%d | Saved=%d | Pending=%d | Spawning=%d | Dirty=%d | Total=%d',
        stats.spawned, stats.saved, stats.pending, stats.spawning, stats.dirty,
        stats.spawned + stats.saved + stats.pending + stats.spawning))
end)

lib.addCommand('streaming:force_save', {
    help = 'Force save all vehicles',
    restricted = 'group.admin'
}, function(source)
    local count = SaveAllTrackedVehicles()
    TriggerClientEvent('QBCore:Notify', source, 'Saved ' .. count .. ' vehicles', 'success')
end)

lib.addCommand('streaming:emergency_save', {
    help = 'Emergency force-save (use before restart)',
    restricted = 'group.admin'
}, function(source)
    local count   = SaveAllTrackedVehicles()
    local message = string.format('Emergency save complete: %d vehicles saved', count)
    print('^2' .. message .. '^7')
    if source and source > 0 then
        TriggerClientEvent('QBCore:Notify', source, message, 'success', 5000)
    end
end)

lib.addCommand('streaming:check_engine', {
    help = 'Check engine health of vehicle in',
    restricted = 'group.admin'
}, function(source)
    local ped     = GetPlayerPed(source)
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 then
        TriggerClientEvent('QBCore:Notify', source, 'Not in vehicle', 'error')
        return
    end

    local plate = string.gsub(GetVehicleNumberPlateText(vehicle), '^%s*(.-)%s*$', '%1')
    local netId = NetworkGetNetworkIdFromEntity(vehicle)

    VehicleStatusCache[plate] = nil
    TriggerClientEvent('DERP-advanced-garages:client:requestVehicleStatus', source, netId, plate)

    Wait(2000)

    if VehicleStatusCache[plate] then
        local c   = VehicleStatusCache[plate]
        local msg = string.format('Plate: %s | Engine: %.0f | Body: %.0f | Fuel: %.0f | Lock: %s | Mods: %s',
            plate, c.engine or 0, c.body or 0, c.fuel or 0, tostring(c.lockState), c.mods and 'YES' or 'NO')
        print('^2' .. msg)
        TriggerClientEvent('QBCore:Notify', source, msg, 'success', 5000)
    else
        TriggerClientEvent('QBCore:Notify', source, 'No status received', 'error')
    end
end)

lib.addCommand('streaming:check_mods', {
    help = 'Check tracked mods for a plate',
    restricted = 'group.admin',
    params = {
        { name = 'plate', help = 'Vehicle plate', type = 'string' }
    }
}, function(source, args)
    local plate = args.plate
    if not TrackedVehicles[plate] then
        print('^1[MODS CHECK] Plate not tracked: ' .. plate)
        TriggerClientEvent('QBCore:Notify', source, 'Plate not tracked: ' .. plate, 'error')
        return
    end

    local tracked = TrackedVehicles[plate]
    local msg = string.format('Plate: %s | State: %s | Lock: %s | Mods: %s',
        plate, tracked.state, tostring(tracked.lockState),
        tracked.mods and ('YES len=' .. #json.encode(tracked.mods)) or 'NO/NIL')

    print('^2[MODS CHECK] ' .. msg)

    if tracked.mods then
        print('^2  color1: ' .. tostring(tracked.mods.color1))
        print('^2  color2: ' .. tostring(tracked.mods.color2))
        print('^2  modEngine: ' .. tostring(tracked.mods.modEngine))
        print('^2  livery: ' .. tostring(tracked.mods.livery))
        print('^2  plate: ' .. tostring(tracked.mods.plate))
    end

    TriggerClientEvent('QBCore:Notify', source, msg, 'success', 5000)
end)

exports('GetTrackedVehiclesForDebug', function()
    local snapshot = {}
    for plate, data in pairs(TrackedVehicles) do
        snapshot[plate] = {
            netId = data.netId,
            state = data.state,
        }
    end
    return snapshot
end)

exports('RegisterVehicleSpawn',   RegisterVehicleSpawn)
exports('UnregisterVehicle',      UnregisterVehicle)
exports('SaveAllTrackedVehicles', SaveAllTrackedVehicles)

print('^2[STREAMING] ^7Optimized system loaded successfully!')