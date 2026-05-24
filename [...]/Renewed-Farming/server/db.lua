local MySQL = MySQL
local db = {}

local INSERT_FARM = 'INSERT INTO `farms` (`x`, `y`, `z`, `heading`, `spots`) VALUES (?, ?, ?, ?, ?)'
function db.createFarm(coords, spots)
    return MySQL.prepare.await(INSERT_FARM, { coords.x, coords.y, coords.z, coords.w, json.encode(spots) })
end

local INSERT_FARM_WITH_ID = 'INSERT INTO `farms` (`id`, `x`, `y`, `z`, `heading`, `spots`) VALUES (?, ?, ?, ?, ?, ?)'
function db.createFarmWithId(id, coords, spots)
    return MySQL.prepare.await(INSERT_FARM_WITH_ID, { id, coords.x, coords.y, coords.z, coords.w, json.encode(spots) })
end

local UPDATE_FARM_COORDS = 'UPDATE `farms` SET `x` = ?, `y` = ?, `z` = ?, `heading` = ? WHERE `id` = ?'
function db.updateFarmCoords(id, coords)
    return MySQL.prepare.await(UPDATE_FARM_COORDS, { coords.x, coords.y, coords.z, coords.w, id })
end

local GET_FARMS = 'SELECT * FROM `farms`'
function db.getFarms()
    return MySQL.query.await(GET_FARMS)
end

local UPDATE_FARM_SPOTS = 'UPDATE `farms` SET `spots` = ? WHERE `id` = ?'
function db.updateFarmSpots(id, spots)
    return MySQL.prepare.await(UPDATE_FARM_SPOTS, { json.encode(spots), id })
end

local GET_RENTALS = 'SELECT * FROM `farm_rentals`'
function db.getRentals()
    return MySQL.query.await(GET_RENTALS)
end

local INSERT_RENTAL = 'INSERT INTO `farm_rentals` (`plot_id`, `citizenid`, `char_name`, `rented_at`, `expires_at`) VALUES (?, ?, ?, NOW(), DATE_ADD(NOW(), INTERVAL ? DAY))'
function db.createRental(plotId, citizenid, charName, days)
    return MySQL.prepare.await(INSERT_RENTAL, { plotId, citizenid, charName, days })
end

local DELETE_RENTAL = 'DELETE FROM `farm_rentals` WHERE `plot_id` = ?'
function db.deleteRental(plotId)
    return MySQL.prepare.await(DELETE_RENTAL, { plotId })
end

local DELETE_EXPIRED = 'DELETE FROM `farm_rentals` WHERE `expires_at` <= NOW()'
function db.deleteExpiredRentals()
    return MySQL.query.await(DELETE_EXPIRED)
end

local GET_RENTAL_BY_CITIZEN = 'SELECT * FROM `farm_rentals` WHERE `citizenid` = ? LIMIT 1'
function db.getRentalByCitizen(citizenid)
    return MySQL.prepare.await(GET_RENTAL_BY_CITIZEN, { citizenid })
end

local GET_RENTAL_BY_PLOT = 'SELECT * FROM `farm_rentals` WHERE `plot_id` = ? LIMIT 1'
function db.getRentalByPlot(plotId)
    return MySQL.prepare.await(GET_RENTAL_BY_PLOT, { plotId })
end

return db