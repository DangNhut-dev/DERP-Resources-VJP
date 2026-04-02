-- Returns existing driver row or inserts a default one
function GetDriverData(citizenid)
    local result = MySQL.query.await('SELECT * FROM truck_driver_stats WHERE citizenid = ?', { citizenid })
    if result and result[1] then return result[1] end

    MySQL.insert('INSERT INTO truck_driver_stats (citizenid, trips_completed, total_exp, current_level) VALUES (?, ?, ?, ?)',
        { citizenid, 0, 0, 1 })

    return {
        citizenid        = citizenid,
        registered_plate = nil,
        registered_vehicle = nil,
        trips_completed  = 0,
        total_exp        = 0,
        current_level    = 1,
    }
end

-- Persists the player's registered truck plate and model
function UpdateRegisteredVehicle(citizenid, plate, vehicle)
    MySQL.update('UPDATE truck_driver_stats SET registered_plate = ?, registered_vehicle = ? WHERE citizenid = ?',
        { plate, vehicle, citizenid })
end

-- Increments trips/exp, recalculates level, returns delta info
function UpdateDriverStats(citizenid, exp)
    local data     = GetDriverData(citizenid)
    local newExp   = data.total_exp + exp
    local newTrips = data.trips_completed + 1
    local newLevel = CalculateLevel(newExp)

    MySQL.update('UPDATE truck_driver_stats SET trips_completed = ?, total_exp = ?, current_level = ? WHERE citizenid = ?',
        { newTrips, newExp, newLevel, citizenid })

    return { oldLevel = data.current_level, newLevel = newLevel, totalExp = newExp, totalTrips = newTrips }
end

-- Maps cumulative EXP to a level tier from Config
function CalculateLevel(exp)
    local level = 1
    for i = Config.MaxLevel, 1, -1 do
        if exp >= Config.LevelThresholds[i] then
            level = i
            break
        end
    end
    return level
end

-- Returns all player-owned vehicles that appear in Config.TruckWhitelist
-- Handles plain string or JSON-encoded vehicle column, normalizes to lowercase
function GetPlayerVehicles(citizenid)
    local result = MySQL.query.await('SELECT vehicle, plate FROM player_vehicles WHERE citizenid = ?', { citizenid })
    if not result then return {} end

    local whitelistedVehicles = {}
    for _, veh in ipairs(result) do
        local modelName = veh.vehicle
        if type(modelName) == 'string' and modelName:sub(1, 1) == '{' then
            local decoded = json.decode(modelName)
            modelName = decoded and (decoded.model or decoded.name) or modelName
        end
        modelName = string.lower(tostring(modelName))

        local capacity = Config.TruckWhitelist[modelName]
        if capacity then
            table.insert(whitelistedVehicles, {
                vehicle  = modelName,
                plate    = veh.plate,
                capacity = capacity,
            })
        end
    end
    return whitelistedVehicles
end

exports('GetDriverData', GetDriverData)
exports('UpdateRegisteredVehicle', UpdateRegisteredVehicle)
exports('UpdateDriverStats', UpdateDriverStats)
exports('GetPlayerVehicles', GetPlayerVehicles)

-- Lấy thông tin thuê xe đang active của player (chưa hết hạn)
function GetActiveRental(citizenid)
    local result = MySQL.query.await(
        'SELECT *, UNIX_TIMESTAMP(expire_time) AS expire_unix FROM truck_rentals WHERE citizenid = ? AND expire_time > NOW() LIMIT 1',
        { citizenid }
    )
    return result and result[1] or nil
end

-- Kiểm tra biển số đã tồn tại trong truck_rentals chưa
function IsRentalPlateTaken(plate)
    local result = MySQL.query.await(
        'SELECT id FROM truck_rentals WHERE plate = ?',
        { plate }
    )
    return result and #result > 0
end

-- Thêm bản ghi thuê xe vào truck_rentals
function CreateRental(citizenid, plate, model, pricePerDay, rentalDays, totalPrice)
    MySQL.insert(
        [[INSERT INTO truck_rentals
            (citizenid, plate, vehicle_model, price_per_day, rental_days, total_price, expire_time)
          VALUES (?, ?, ?, ?, ?, ?, DATE_ADD(NOW(), INTERVAL ? DAY))]],
        { citizenid, plate, model, pricePerDay, rentalDays, totalPrice, rentalDays }
    )
end

-- Thêm xe thuê vào player_vehicles (như xe bình thường, state = 0 = trong garage)
function AddRentalToPlayerVehicles(citizenid, plate, model)
    local exists = MySQL.query.await(
        'SELECT plate FROM player_vehicles WHERE plate = ?',
        { plate }
    )
    if exists and #exists > 0 then return end  -- tránh duplicate

    MySQL.insert(
        'INSERT INTO player_vehicles (citizenid, vehicle, plate, state) VALUES (?, ?, ?, ?)',
        { citizenid, model, plate, 0 }
    )
end

-- Dọn rental hết hạn: xóa player_vehicles + truck_rentals
-- Chỉ cần xóa DB, xe sẽ tự mất sau khi restart server
function CleanExpiredRentals()
    local expired = MySQL.query.await(
        'SELECT plate, citizenid FROM truck_rentals WHERE expire_time <= NOW()',
        {}
    )
    if not expired or #expired == 0 then return end

    for _, row in ipairs(expired) do
        MySQL.query('DELETE FROM player_vehicles WHERE plate = ?', { row.plate })
    end

    MySQL.query('DELETE FROM truck_rentals WHERE expire_time <= NOW()', {})

    print(('[Tommy Trucker] Đã dọn %d rental hết hạn'):format(#expired))
end

exports('GetActiveRental',          GetActiveRental)
exports('IsRentalPlateTaken',       IsRentalPlateTaken)
exports('CreateRental',             CreateRental)
exports('AddRentalToPlayerVehicles', AddRentalToPlayerVehicles)
exports('CleanExpiredRentals',      CleanExpiredRentals)