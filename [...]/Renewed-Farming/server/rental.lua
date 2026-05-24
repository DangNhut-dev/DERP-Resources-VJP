lib.locale()

local Config = require 'shared.Rental'
local db = require 'server.db'
local utils = require 'server.utils'

local ox_inventory = exports.ox_inventory
local rentalFarms = {}
local rentalPlotToFarm = {}

local function isRentalFarm(farmId)
    local pId = tonumber(farmId)
    for _, plot in pairs(Config.plots) do
        if plot.id == pId then
            return true
        end
    end
    return false
end

local function getRentalOwner(farmId)
    local rental = rentalFarms[tostring(farmId)]
    if rental then
        return rental.citizenid
    end
    return nil
end

exports('isRentalFarm', isRentalFarm)
exports('getRentalOwner', getRentalOwner)

local function activateRental(rental)
    local plotId = tostring(rental.plot_id)
    rentalFarms[plotId] = {
        citizenid = rental.citizenid,
        char_name = rental.char_name,
        expires_at = rental.expires_at,
    }
    exports['Renewed-Farming']:updateFarmOwner(tonumber(plotId), rental.citizenid)
end

local function deactivateRental(plotId)
    local pId = tostring(plotId)
    local rental = rentalFarms[pId]
    if not rental then return end
    rentalFarms[pId] = nil
    exports['Renewed-Farming']:updateFarmOwner(tonumber(pId), nil)
    TriggerClientEvent('Renewed-Farming:client:rentalExpired', -1, tonumber(pId), tonumber(pId))
end

local function saveRentals()
    print('^3[Renewed-Farming DEBUG] Saving rentals data to rentals.json...^0')
    local success, encoded = pcall(json.encode, rentalFarms, { indent = true })
    if success then
        SaveResourceFile(GetCurrentResourceName(), 'rentals.json', encoded, -1)
        print('^2[Renewed-Farming DEBUG] Successfully saved rentals.json^0')
    else
        print('^1[Renewed-Farming DEBUG] ERROR: Failed to encode rentals to JSON!^0')
    end
end

local function checkExpired()
    local now = os.time()
    local changed = false

    for plotId, rental in pairs(rentalFarms) do
        local expiresAt = tonumber(rental.expires_at)
        if expiresAt and expiresAt <= now then
            deactivateRental(plotId)
            changed = true
        end
    end
    
    if changed then
        saveRentals()
    end
end

local function ensureRentalPlotsInitialized()
    local farms = exports['Renewed-Farming']:getFarmsTable()
    local changed = false

    for _, plot in pairs(Config.plots) do
        local farm = farms[plot.id]
        local coords = plot.coords

        if not farm then
            print('^3[Renewed-Farming DEBUG] Rental plot #' .. plot.id .. ' missing in DB. Initializing...^0')

            local spots = {}
            local headingRad = math.rad(-coords.w)
            local cosH = math.cos(headingRad)
            local sinH = math.sin(headingRad)

            for i, offset in ipairs(Config.spotOffsets) do
                local rotX = offset.x * cosH - offset.y * sinH
                local rotY = offset.x * sinH + offset.y * cosH
                local spotCoords = vec3(coords.x + rotX, coords.y + rotY, coords.z + offset.z)
                spots[i] = { coords = { x = spotCoords.x, y = spotCoords.y, z = spotCoords.z } }
            end

            local success = db.createFarmWithId(plot.id, coords, spots)
            if success then
                print('^2[Renewed-Farming DEBUG] Successfully initialized rental plot #' .. plot.id .. ' in DB.^0')
                
                -- Call the global addFarm function from main.lua to load it immediately
                if addFarm then
                    pcall(addFarm, plot.id, coords, spots)
                    print('^2[Renewed-Farming DEBUG] Plot #' .. plot.id .. ' has been loaded into the game.^0')
                else
                    changed = true
                end
            else
                print('^1[Renewed-Farming DEBUG] Failed to initialize rental plot #' .. plot.id .. ' in DB!^0')
            end
        else
            -- Check if coordinates match (within small tolerance)
            local dist = #(vec3(farm.coords.x, farm.coords.y, farm.coords.z) - coords.xyz)
            if dist > 0.1 then
                print('^3[Renewed-Farming DEBUG] Updating coordinates for rental plot #' .. plot.id .. '^0')
                db.updateFarmCoords(plot.id, coords)
                -- Update the live farm object as well
                farm.coords = coords
            end
        end
    end

    return changed
end

CreateThread(function()
    print('^3[Renewed-Farming DEBUG] Waiting for main farms to load...^0')
    while not exports['Renewed-Farming']:isLoaded() do Wait(100) end
    
    if ensureRentalPlotsInitialized() then
        print('^3[Renewed-Farming DEBUG] Some rental plots were initialized for the first time. You might need to restart if they don\'t show up.^0')
    end

    print('^2[Renewed-Farming DEBUG] Main farms loaded. Starting to load rentals.json...^0')

    local data = LoadResourceFile(GetCurrentResourceName(), 'rentals.json')
    local now = os.time()
    local changed = false

    if data and data ~= '' then
        print('^3[Renewed-Farming DEBUG] rentals.json found, stripping BOM if present...^0')
        -- Strip UTF-8 BOM if present (happens when manually edited in Notepad)
        if string.byte(data, 1) == 239 and string.byte(data, 2) == 187 and string.byte(data, 3) == 191 then
            data = string.sub(data, 4)
            print('^3[Renewed-Farming DEBUG] UTF-8 BOM was stripped from rentals.json.^0')
        end
        
        local success, decoded = pcall(json.decode, data)
        if success and type(decoded) == 'table' then
            print('^2[Renewed-Farming DEBUG] Successfully decoded rentals.json^0')
            local count = 0
            for k, rental in pairs(decoded) do
                local plotId = tonumber(k)
                if plotId then
                    rental.plot_id = plotId
                    local expiresAt = tonumber(rental.expires_at)
                    if expiresAt and expiresAt <= now then
                        print('^3[Renewed-Farming DEBUG] Plot ' .. plotId .. ' rental has expired.^0')
                        changed = true
                    else
                        activateRental(rental)
                        print('^2[Renewed-Farming DEBUG] Activated rental for plot ' .. plotId .. ' (Owner: ' .. rental.citizenid .. ')^0')
                        count = count + 1
                    end
                end
            end
            print('^2[Renewed-Farming DEBUG] Total active rentals loaded: ' .. count .. '^0')
        else
            print('^1[Renewed-Farming DEBUG] ERROR decoding rentals.json! File might be corrupted.^0')
            print('^1[ERROR DETAILS]: ' .. tostring(decoded) .. '^0')
        end
    else
        print('^3[Renewed-Farming DEBUG] rentals.json is empty or not found. No rentals to load.^0')
    end

    if changed then saveRentals() end

    while true do
        Wait(60000)
        checkExpired()
    end
end)

lib.callback.register('Renewed-Farming:server:getRentalData', function(src)
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return nil end

    local citizenid = player.PlayerData.citizenid
    local plotsData = {}

    for _, plot in pairs(Config.plots) do
        local rental = rentalFarms[tostring(plot.id)]
        
        -- If rented by someone else, hide it from the list
        if rental and rental.citizenid ~= citizenid then
            goto continue
        end

        local plotInfo = {
            id = plot.id,
            name = plot.name,
            status = 'available',
            renter = nil,
            expires_at = nil,
            isOwner = false,
        }

        if rental then
            plotInfo.status = 'rented'
            plotInfo.renter = rental.char_name
            -- Format date for UI if it's a timestamp
            local expiresAt = tonumber(rental.expires_at)
            plotInfo.expires_at = expiresAt and os.date('!%Y-%m-%d %H:%M:%S', expiresAt) or rental.expires_at
            plotInfo.isOwner = true
        end

        local farmData = exports['Renewed-Farming']:getFarmsTable()[plot.id]
        if farmData then
            plotInfo.coords = { x = farmData.coords.x, y = farmData.coords.y, z = farmData.coords.z }
        end

        plotsData[#plotsData + 1] = plotInfo
        ::continue::
    end

    local myRental = nil
    for plotIdStr, rental in pairs(rentalFarms) do
        if rental.citizenid == citizenid then
            local expiresAt = tonumber(rental.expires_at)
            myRental = {
                plot_id = tonumber(plotIdStr),
                expires_at = expiresAt and os.date('!%Y-%m-%d %H:%M:%S', expiresAt) or rental.expires_at,
            }
            break
        end
    end

    return {
        plots = plotsData,
        prices = Config.prices,
        myRental = myRental,
    }
end)

lib.callback.register('Renewed-Farming:server:rentPlot', function(src, plotId, days, payType)
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return { success = false, msg = locale('rent_error') } end

    local citizenid = player.PlayerData.citizenid
    local charName = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname

    for _, rental in pairs(rentalFarms) do
        if rental.citizenid == citizenid then
            return { success = false, msg = locale('already_rented') }
        end
    end

    if rentalFarms[tostring(plotId)] then
        return { success = false, msg = locale('plot_taken') }
    end

    local plotConfig = nil
    for _, p in pairs(Config.plots) do
        if p.id == plotId then
            plotConfig = p
            break
        end
    end

    if not plotConfig then return { success = false, msg = locale('rent_error') } end

    local farmData = exports['Renewed-Farming']:getFarmsTable()[plotId]
    if not farmData then return { success = false, msg = "Farm missing in DB" } end

    local price = Config.prices[days]
    if not price then return { success = false, msg = locale('rent_error') } end

    local moneyType = payType == 'bank' and 'bank' or 'cash'
    local currentMoney = player.PlayerData.money[moneyType]

    if not currentMoney or currentMoney < price then
        return { success = false, msg = locale('not_enough_money') }
    end

    player.Functions.RemoveMoney(moneyType, price)

    local rental = {
        plot_id = plotId,
        citizenid = citizenid,
        char_name = charName,
        expires_at = os.time() + (days * 86400),
    }

    print('^2[Renewed-Farming DEBUG] Player ' .. charName .. ' (' .. citizenid .. ') is renting Plot ' .. plotId .. ' for ' .. days .. ' days.^0')
    print('^2[Renewed-Farming DEBUG] Expires at: ' .. os.date('!%Y-%m-%d %H:%M:%S', rental.expires_at) .. '^0')

    activateRental(rental)
    saveRentals()

    return {
        success = true,
        msg = locale('rent_success'),
        plotName = plotConfig.name,
        coords = { x = farmData.coords.x, y = farmData.coords.y, z = farmData.coords.z },
    }
end)
