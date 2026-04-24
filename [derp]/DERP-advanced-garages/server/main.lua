local QBX = exports.qbx_core
local cooldowns = {}

local function HasJobAccess(player, garageName)
    local garage = Config.Garages[garageName]
    if not garage then return false end

    if garage.type == 'public' then return true end

    if garage.type == 'job' then
        if not garage.job then return false end
        if not player or not player.PlayerData or not player.PlayerData.job then return false end
        return player.PlayerData.job.name == garage.job
    end

    return false
end

local function IsAdmin(source)
    if not source or source == 0 then return false end
    return IsPlayerAceAllowed(tostring(source), 'group.admin')
        or IsPlayerAceAllowed(tostring(source), 'command.garagesAdmin')
end

local function IsPlayerNearGarage(source, garageName)
    local playerPed    = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)
    local garage       = Config.Garages[garageName]

    if not garage then return false end

    local targetCoords = garage.storeZone and garage.storeZone.coords or garage.npc.coords
    local maxDistance  = garage.storeZone and garage.storeZone.radius or Config.InteractDistance

    return #(playerCoords - targetCoords) <= (maxDistance + 5.0)
end

local function IsOnCooldown(source)
    local currentTime = GetGameTimer()
    if cooldowns[source] and (currentTime - cooldowns[source]) < Config.SpawnCooldown then
        return true
    end
    return false
end

local function SetCooldown(source)
    cooldowns[source] = GetGameTimer()
end

local function HasLEOJob(player)
    if not player or not player.PlayerData or not player.PlayerData.job then return false end
    return player.PlayerData.job.type == Config.Impound.AllowedJobType
end

local function CalculateTimeLeft(impoundStartTime, impoundDuration)
    if not impoundStartTime or not impoundDuration then return 0 end

    local elapsedTime   = os.time() * 1000 - impoundStartTime
    local totalDuration = impoundDuration * 60 * 1000
    return math.max(0, math.floor((totalDuration - elapsedTime) / 60000))
end

lib.callback.register('DERP-advanced-garages:server:getVehicles', function(source, garageName)
    local player = QBX:GetPlayer(source)
    if not player then return {} end

    if not Config.Garages[garageName] then return {} end

    if not HasJobAccess(player, garageName) then
        TriggerClientEvent('QBCore:Notify', source, 'Bạn không có quyền truy cập garage này!', 'error')
        return {}
    end

    local citizenid = player.PlayerData.citizenid

    local result = MySQL.query.await([[
        SELECT
            vehicle, plate, label, fuel, engine, body,
            mods, status, hash, garage, lock_state,
            impound_price, impound_duration, impound_reason,
            impound_by, impound_start_time
        FROM player_vehicles
        WHERE citizenid = ? AND state = 1 AND garage = ?
    ]], { citizenid, garageName })

    if result and #result > 0 and Config.Garages[garageName].isImpound then
        for _, vehicle in ipairs(result) do
            vehicle.impound_time_left = CalculateTimeLeft(vehicle.impound_start_time, vehicle.impound_duration)
        end
    end

    return result or {}
end)

lib.callback.register('DERP-advanced-garages:server:updateLabel', function(source, plate, newLabel)
    local player = QBX:GetPlayer(source)
    if not player then return false end

    if not plate or type(plate) ~= 'string' then return false end

    local citizenid = player.PlayerData.citizenid

    local result = MySQL.query.await([[
        SELECT id FROM player_vehicles
        WHERE citizenid = ? AND plate = ?
        LIMIT 1
    ]], { citizenid, plate })

    if not result or #result == 0 then return false end

    local sanitized = newLabel and string.sub(tostring(newLabel), 1, 50) or nil

    MySQL.update.await([[
        UPDATE player_vehicles SET label = ?
        WHERE plate = ? AND citizenid = ?
    ]], { sanitized, plate, citizenid })

    return true
end)

lib.callback.register('DERP-advanced-garages:server:spawnVehicle', function(source, plate, spawnCoords, garageName)
    local player = QBX:GetPlayer(source)
    if not player then return false end

    if not plate or not spawnCoords or not garageName then return false end
    if not Config.Garages[garageName] then return false end

    if not HasJobAccess(player, garageName) then
        TriggerClientEvent('QBCore:Notify', source, 'Bạn không có quyền truy cập garage này!', 'error')
        return false
    end

    if IsOnCooldown(source) then
        TriggerClientEvent('QBCore:Notify', source, Config.Lang['cooldown_active'], 'error')
        return false
    end

    local citizenid = player.PlayerData.citizenid

    local result = MySQL.query.await([[
        SELECT vehicle, mods, fuel, engine, body, status, hash, lock_state,
               impound_price, impound_duration, impound_reason,
               impound_by, impound_start_time
        FROM player_vehicles
        WHERE citizenid = ? AND plate = ? AND state = 1 AND garage = ?
        LIMIT 1
    ]], { citizenid, plate, garageName })

    if not result or #result == 0 then
        TriggerClientEvent('QBCore:Notify', source, 'Xe không tồn tại hoặc không phải của bạn!', 'error')
        return false
    end

    local vehicleData = result[1]

    if Config.Garages[garageName].isImpound then
        local timeLeft     = CalculateTimeLeft(vehicleData.impound_start_time, vehicleData.impound_duration)
        local impoundPrice = vehicleData.impound_price or 0

        if timeLeft > 0 then
            TriggerClientEvent('QBCore:Notify', source,
                string.format(Config.Lang['impound_time_remaining'], timeLeft), 'error')
            return false
        end

        if impoundPrice > 0 then
            local cash = player.Functions.GetMoney('cash')
            local bank = player.Functions.GetMoney('bank')

            if (cash + bank) < impoundPrice then
                TriggerClientEvent('QBCore:Notify', source,
                    string.format(Config.Lang['not_enough_money'], impoundPrice), 'error')
                return false
            end

            if cash >= impoundPrice then
                player.Functions.RemoveMoney('cash', impoundPrice, 'impound-release')
            else
                if cash > 0 then player.Functions.RemoveMoney('cash', cash, 'impound-release') end
                player.Functions.RemoveMoney('bank', impoundPrice - cash, 'impound-release')
            end

            TriggerClientEvent('QBCore:Notify', source,
                string.format(Config.Lang['impound_released'], impoundPrice), 'success')
        end

        -- if Config.Impound.ResetHealthOnRelease then
        --     vehicleData.engine = Config.Impound.DefaultEngineHealth
        --     vehicleData.body   = Config.Impound.DefaultBodyHealth
        -- end

        if Config.Impound.ResetHealthOnRelease then
            vehicleData.engine = Config.Impound.DefaultEngineHealth
            vehicleData.body   = Config.Impound.DefaultBodyHealth
            vehicleData.status = nil
        end

        MySQL.update.await([[
            UPDATE player_vehicles
            SET impound_price = NULL, impound_duration = NULL,
                impound_reason = NULL, impound_by = NULL, impound_start_time = NULL
            WHERE plate = ?
        ]], { plate })
    end

    MySQL.update.await([[
        UPDATE player_vehicles SET state = 0, coords = ? WHERE plate = ?
    ]], { json.encode(spawnCoords), plate })

    SetCooldown(source)

    local modsData = type(vehicleData.mods) == 'string' and json.decode(vehicleData.mods) or vehicleData.mods

    return {
        success   = true,
        vehicle   = vehicleData.vehicle,
        mods      = modsData,
        fuel      = vehicleData.fuel   or 100,
        engine    = vehicleData.engine or 1000,
        body      = vehicleData.body   or 1000,
        status    = vehicleData.status,
        plate     = plate,
        citizenid = citizenid,
        lockState = vehicleData.lock_state or 2
    }
end)

RegisterNetEvent('DERP-advanced-garages:server:storeVehicle', function(plate, garageName, vehicleData, netId)
    local src    = source
    local player = QBX:GetPlayer(src)
    if not player then return end

    if not plate or not garageName or not vehicleData then return end
    if not Config.Garages[garageName] then return end

    if not HasJobAccess(player, garageName) then
        TriggerClientEvent('QBCore:Notify', src, 'Bạn không có quyền cất xe vào garage này!', 'error')
        return
    end

    if not IsPlayerNearGarage(src, garageName) then
        TriggerClientEvent('QBCore:Notify', src, Config.Lang['too_far'], 'error')
        return
    end

    local hasKeys = false
    if netId then
        local vehicle = NetworkGetEntityFromNetworkId(netId)
        if vehicle and vehicle ~= 0 then
            local ok, result = pcall(function()
                return exports.qbx_vehiclekeys:HasKeys(src, vehicle)
            end)
            if ok then hasKeys = result == true end
        end
    end

    if not hasKeys then
        local ownerCitizenId = MySQL.scalar.await(
            'SELECT citizenid FROM player_vehicles WHERE plate = ? LIMIT 1', { plate })
        if ownerCitizenId == player.PlayerData.citizenid then hasKeys = true end
    end

    if not hasKeys then
        TriggerClientEvent('QBCore:Notify', src, 'Bạn không có chìa khoá xe này!', 'error')
        return
    end

    local exists = MySQL.scalar.await('SELECT id FROM player_vehicles WHERE plate = ? LIMIT 1', { plate })
    if not exists then return end

    local serverFuel   = vehicleData.fuel   or 100
    local serverEngine = vehicleData.engine or 1000
    local serverBody   = vehicleData.body   or 1000
    local serverMods   = nil
    -- print('[FUEL DEBUG SERVER] Plate: ' .. plate .. ' | clientFuel: ' .. tostring(vehicleData.fuel))

    if netId then
        local vehicle = NetworkGetEntityFromNetworkId(netId)
        if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
            serverEngine = GetVehicleEngineHealth(vehicle)
            serverBody   = GetVehicleBodyHealth(vehicle)
        end
    end
    -- print('[FUEL DEBUG SERVER] After server check | serverFuel: ' .. tostring(serverFuel) .. ' | stateBagFuel: ' .. tostring(netId and NetworkGetEntityFromNetworkId(netId) and Entity(NetworkGetEntityFromNetworkId(netId)).state.fuel or 'N/A'))
    -- Lấy mods từ DB hiện tại nếu client không gửi (đảm bảo không mất mods khi store)
    if not vehicleData.mods then
        local currentMods = MySQL.scalar.await(
            'SELECT mods FROM player_vehicles WHERE plate = ? LIMIT 1', { plate })
        if currentMods then
            serverMods = currentMods
        end
    else
        local modsTable = type(vehicleData.mods) == 'string' and json.decode(vehicleData.mods) or vehicleData.mods
        if modsTable and type(modsTable) == 'table' then
            modsTable.plate = nil
            serverMods = json.encode(modsTable)
        else
            serverMods = type(vehicleData.mods) == 'string' and vehicleData.mods or json.encode(vehicleData.mods)
        end
    end

    local serverLockState = vehicleData.lockState or 2

    -- print('[FUEL DEBUG SERVER] Final saving fuel: ' .. tostring(serverFuel) .. ' for plate: ' .. plate)
    MySQL.update.await([[
        UPDATE player_vehicles
        SET state = 1, garage = ?, fuel = ?, engine = ?, body = ?, status = ?, mods = COALESCE(?, mods), lock_state = ?, coords = NULL
        WHERE plate = ?
    ]], {
        garageName,
        serverFuel,
        serverEngine,
        serverBody,
        json.encode(vehicleData.status),
        serverMods,
        serverLockState,
        plate
    })

    if Config.Streaming and Config.Streaming.Enabled then
        exports['DERP-advanced-garages']:UnregisterVehicle(plate)
    end

    TriggerClientEvent('QBCore:Notify', src, Config.Lang['vehicle_stored'], 'success')
end)

lib.addCommand('giamxe', {
    help = 'Giam xe vi phạm (đứng cạnh xe)',
    restricted = false
}, function(source)
    local player = QBX:GetPlayer(source)
    if not player then return end

    if not HasLEOJob(player) then
        TriggerClientEvent('QBCore:Notify', source, Config.Lang['not_authorized_impound'], 'error')
        return
    end

    TriggerClientEvent('DERP-advanced-garages:client:startImpoundProcess', source)
end)

RegisterNetEvent('DERP-advanced-garages:server:impoundVehicle', function(netId, plate, impoundData, vehicleState)
    local src    = source
    local player = QBX:GetPlayer(src)
    if not player then return end

    if not HasLEOJob(player) then
        TriggerClientEvent('QBCore:Notify', src, Config.Lang['not_authorized_impound'], 'error')
        return
    end

    if not plate or type(plate) ~= 'string' then return end
    if not netId or type(netId) ~= 'number' then return end

    -- local vehicleRecord = MySQL.query.await([[
    --     SELECT plate FROM player_vehicles WHERE plate = ? AND state = 0 LIMIT 1
    -- ]], { plate })

    -- if not vehicleRecord or #vehicleRecord == 0 then
    --     TriggerClientEvent('QBCore:Notify', src, 'Xe không hợp lệ hoặc đang trong garage!', 'error')
    --     return
    -- end

    local price    = math.max(0, math.floor(tonumber(impoundData.price)    or Config.Impound.DefaultPrice))
    local duration = math.max(1, math.floor(tonumber(impoundData.duration) or Config.Impound.DefaultDuration))
    local reason   = type(impoundData.reason) == 'string' and string.sub(impoundData.reason, 1, 200) or 'Vi phạm luật giao thông'

    local serverFuel   = 100
    local serverEngine = 1000
    local serverBody   = 1000
    local serverStatus = vehicleState and vehicleState.status or nil

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
        serverFuel   = Entity(vehicle).state.fuel or 100
        serverEngine = GetVehicleEngineHealth(vehicle)
        serverBody   = GetVehicleBodyHealth(vehicle)
    end

    local impoundedBy = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname

    MySQL.update.await([[
        UPDATE player_vehicles
        SET state = 1, garage = 'impound',
            fuel = ?, engine = ?, body = ?, status = ?,
            impound_price = ?, impound_duration = ?,
            impound_reason = ?, impound_by = ?,
            impound_start_time = ?, coords = NULL
        WHERE plate = ?
    ]], {
        serverFuel, serverEngine, serverBody,
        serverStatus and json.encode(serverStatus) or nil,
        price, duration, reason, impoundedBy,
        os.time() * 1000,
        plate
    })

    if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
    end

    TriggerClientEvent('DERP-advanced-garages:client:deleteVehicle', -1, netId)

    SetTimeout(2000, function()
        local e = NetworkGetEntityFromNetworkId(netId)
        if e and e ~= 0 and DoesEntityExist(e) then
            DeleteEntity(e)
        end
    end)

    if Config.Streaming and Config.Streaming.Enabled then
        pcall(function()
            exports['DERP-advanced-garages']:UnregisterVehicle(plate)
        end)
    end

    TriggerClientEvent('QBCore:Notify', src,
        string.format(Config.Lang['vehicle_impounded'], price, duration), 'success')
end)

-- FIX: Validate netId type và retry entity resolution
RegisterNetEvent('DERP-advanced-garages:server:registerSpawn', function(plate, netId, coords)
    local src    = source
    local player = QBX:GetPlayer(src)
    if not player or not plate or not netId then return end
    if type(netId) ~= 'number' or netId <= 0 then return end

    if not (Config.Streaming and Config.Streaming.Enabled) then return end

    local entity = nil
    local retries = 0
    while retries < 5 do
        entity = NetworkGetEntityFromNetworkId(netId)
        if entity and entity ~= 0 and DoesEntityExist(entity) then break end
        Wait(500)
        retries = retries + 1
    end

    if not entity or entity == 0 or not DoesEntityExist(entity) then return end

    -- Validate plate server-side
    local serverPlate = string.gsub(GetVehicleNumberPlateText(entity), '^%s*(.-)%s*$', '%1')
    if serverPlate ~= plate then return end

    local citizenid = player.PlayerData.citizenid

    local result = MySQL.query.await([[
        SELECT mods, status, fuel, engine, body
        FROM player_vehicles
        WHERE plate = ? AND citizenid = ?
        LIMIT 1
    ]], { plate, citizenid })

    exports['DERP-advanced-garages']:RegisterVehicleSpawn(
        plate, entity, coords, citizenid, result and result[1] or nil)
end)

-- ADMIN ONLY EVENTS
RegisterNetEvent('DERP-advanced-garages:server:toggleVehicleState', function(plate)
    local src = source
    if not IsAdmin(src) then
        TriggerClientEvent('QBCore:Notify', src, 'Không có quyền!', 'error')
        return
    end

    if not plate or type(plate) ~= 'string' then return end

    local result = MySQL.query.await([[
        SELECT state FROM player_vehicles WHERE plate = ? LIMIT 1
    ]], { plate })

    if not result or #result == 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Xe không tồn tại!', 'error')
        return
    end

    local newState = result[1].state == 0 and 1 or 0

    MySQL.update.await('UPDATE player_vehicles SET state = ? WHERE plate = ?', { newState, plate })

    local stateText = newState == 0 and 'ngoài garage' or 'trong garage'
    TriggerClientEvent('QBCore:Notify', src, 'Đã đổi state xe ' .. plate .. ' thành ' .. stateText, 'success')
end)

RegisterNetEvent('DERP-advanced-garages:server:teleportToVehicle', function(plate)
    local src = source
    if not IsAdmin(src) then
        TriggerClientEvent('QBCore:Notify', src, 'Không có quyền!', 'error')
        return
    end

    if not plate or type(plate) ~= 'string' then return end

    local result = MySQL.query.await([[
        SELECT coords, state FROM player_vehicles WHERE plate = ? LIMIT 1
    ]], { plate })

    if not result or #result == 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Xe không tồn tại!', 'error')
        return
    end

    if result[1].state ~= 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Xe đang trong garage!', 'error')
        return
    end

    if not result[1].coords then
        TriggerClientEvent('QBCore:Notify', src, 'Không có vị trí xe!', 'error')
        return
    end

    local coords = json.decode(result[1].coords)
    if coords and coords.x and coords.y and coords.z then
        TriggerClientEvent('DERP-advanced-garages:client:teleportTo', src, coords)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Vị trí xe không hợp lệ!', 'error')
    end
end)

RegisterNetEvent('DERP-advanced-garages:server:moveVehicleToGarage', function(plate, targetGarage)
    local src = source
    if not IsAdmin(src) then
        TriggerClientEvent('QBCore:Notify', src, 'Không có quyền!', 'error')
        return
    end

    if not plate or type(plate) ~= 'string' then return end
    if not Config.Garages[targetGarage] then
        TriggerClientEvent('QBCore:Notify', src, 'Garage không tồn tại!', 'error')
        return
    end

    MySQL.update.await([[
        UPDATE player_vehicles SET garage = ?, state = 1, coords = NULL WHERE plate = ?
    ]], { targetGarage, plate })

    if Config.Streaming and Config.Streaming.Enabled then
        exports['DERP-advanced-garages']:UnregisterVehicle(plate)
    end

    TriggerClientEvent('QBCore:Notify', src, 'Đã chuyển xe ' .. plate .. ' về ' .. targetGarage, 'success')
end)

lib.callback.register('DERP-advanced-garages:server:getAllVehicles', function(source)
    if not IsAdmin(source) then return nil end

    local result = MySQL.query.await([[
        SELECT
            pv.vehicle, pv.plate, pv.label, pv.fuel, pv.engine, pv.body,
            pv.garage, pv.state, pv.coords, pv.citizenid,
            CONCAT(
                JSON_UNQUOTE(JSON_EXTRACT(p.charinfo, '$.firstname')),
                ' ',
                JSON_UNQUOTE(JSON_EXTRACT(p.charinfo, '$.lastname'))
            ) as owner_name
        FROM player_vehicles pv
        LEFT JOIN players p ON pv.citizenid = p.citizenid
        ORDER BY pv.plate ASC
    ]])

    return result or {}
end)

AddEventHandler('playerDropped', function()
    local src = source
    if cooldowns[src] then cooldowns[src] = nil end
end)

lib.addCommand('garageinfo', {
    help  = 'Get garage debug info',
    restricted = 'group.admin'
}, function(source)
    local playerPed = GetPlayerPed(source)
    local coords    = GetEntityCoords(playerPed)
    local player    = QBX:GetPlayer(source)

    print('^2[DERP-advanced-garages] Player coords: ' .. tostring(coords))
    if player and player.PlayerData and player.PlayerData.job then
        print('^2[DERP-advanced-garages] Player job: ' .. player.PlayerData.job.name)
    end

    for name, garage in pairs(Config.Garages) do
        local hasAccess = HasJobAccess(player, name)
        print('^3Garage: ^7' .. name .. ' ^3Type: ^7' .. garage.type .. ' ^3Access: ^7' .. tostring(hasAccess))

        if garage.storeZone then
            print('^3  Store Zone Distance: ^7' .. #(coords - garage.storeZone.coords))
        end
        if garage.npc then
            print('^3  NPC Distance: ^7' .. #(coords - garage.npc.coords))
        end
    end
end)

lib.addCommand('garagesAdmin', {
    help = 'Mở bảng quản lý xe (Admin)',
    restricted = 'group.admin'
}, function(source)
    TriggerClientEvent('DERP-advanced-garages:client:openAdminUI', source)
end)

print('^2[DERP-advanced-garages] ^7Server script loaded successfully!')

-- ============================================================
-- WATER IMPOUND SYSTEM
-- ============================================================

local waterImpoundCooldowns = {}

RegisterNetEvent('DERP-advanced-garages:server:waterImpound', function(plate, netId)
    local src = source
    local player = QBX:GetPlayer(src)
    if not player then return end

    if not Config.WaterImpound or not Config.WaterImpound.Enabled then return end
    if not plate or type(plate) ~= 'string' then return end
    if not netId or type(netId) ~= 'number' or netId <= 0 then return end

    local now = GetGameTimer()
    if waterImpoundCooldowns[plate] and (now - waterImpoundCooldowns[plate]) < 60000 then return end

    local record = MySQL.query.await([[
        SELECT citizenid, vehicle, fuel, engine, body, mods, status
        FROM player_vehicles WHERE plate = ? AND state = 0 LIMIT 1
    ]], { plate })

    if not record or #record == 0 then return end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end

    local serverPlate = string.gsub(GetVehicleNumberPlateText(vehicle), '^%s*(.-)%s*$', '%1')
    if serverPlate ~= plate then return end

    waterImpoundCooldowns[plate] = now

    local fuel = Entity(vehicle).state.fuel or record[1].fuel or 100
    local engine = GetVehicleEngineHealth(vehicle)
    local body = GetVehicleBodyHealth(vehicle)

    local impoundGarage = Config.WaterImpound.ImpoundGarage or 'impound'
    local impoundDuration = Config.WaterImpound.ImpoundDuration or 15

    MySQL.update.await([[
        UPDATE player_vehicles
        SET state = 1, garage = ?,
            fuel = ?, engine = ?, body = ?,
            impound_price = 0, impound_duration = ?,
            impound_reason = ?, impound_by = ?,
            impound_start_time = ?, coords = NULL
        WHERE plate = ?
    ]], {
        impoundGarage,
        fuel, engine, body,
        impoundDuration,
        'Xe chìm dưới nước',
        'Hệ thống',
        os.time() * 1000,
        plate
    })

    DeleteEntity(vehicle)

    TriggerClientEvent('DERP-advanced-garages:client:deleteVehicle', -1, netId)

    SetTimeout(2000, function()
        local e = NetworkGetEntityFromNetworkId(netId)
        if e and e ~= 0 and DoesEntityExist(e) then
            DeleteEntity(e)
        end
    end)

    if Config.Streaming and Config.Streaming.Enabled then
        pcall(function()
            exports['DERP-advanced-garages']:UnregisterVehicle(plate)
        end)
    end
end)