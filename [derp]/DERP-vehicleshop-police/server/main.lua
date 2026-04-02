local QBX = exports.qbx_core
local cooldowns = {}

local function IsPlateExist(plate)
    local result = MySQL.scalar.await('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
    return result ~= nil
end

local function GeneratePlate()
    local plate
    local attempts = 0

    repeat
        local numbers = ""
        for i = 1, 6 do
            numbers = numbers .. tostring(math.random(0, 9))
        end
        plate = "DE" .. numbers
        attempts = attempts + 1
    until not IsPlateExist(plate) or attempts > 100

    if attempts > 100 then
        print('^1[DERP-VehicleShop] CRITICAL: Cannot generate unique plate^0')
        return nil
    end

    return plate
end

local function HasPurchasedVehicle(citizenId, model)
    local result = MySQL.scalar.await('SELECT id FROM vehicle_purchases WHERE citizenid = ? AND vehicle = ?', {citizenId, model})
    return result ~= nil
end

local function RecordPurchase(citizenId, model)
    MySQL.insert('INSERT IGNORE INTO vehicle_purchases (citizenid, vehicle, purchase_date) VALUES (?, ?, ?)', {
        citizenId,
        model,
        os.time()
    })
end

local function IsOnCooldown(source)
    local currentTime = GetGameTimer()
    if cooldowns[source] and (currentTime - cooldowns[source]) < (Config.Cooldown or 2000) then
        return true
    end
    return false
end

local function SetCooldown(source)
    cooldowns[source] = GetGameTimer()
end

RegisterNetEvent('DERP-vehicleshop:server:openMenu', function(dealerIndex)
    local src = source
    local player = QBX:GetPlayer(src)

    if not player then return end
    
    if IsOnCooldown(src) then return end
    SetCooldown(src)

    local dealer = Config.Dealers[dealerIndex]
    if not dealer then return end

    if dealer.job then
        if not player.PlayerData.job or player.PlayerData.job.name ~= dealer.job then
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'error',
                description = Config.Notifications.notPolice
            })
            return
        end
    end

    local citizenId = player.PlayerData.citizenid
    local availableVehicles = {}

    for _, vehicle in ipairs(dealer.vehicles) do
        local canBuy = true

        if dealer.job and vehicle.minGrade and player.PlayerData.job.grade.level < vehicle.minGrade then
            canBuy = false
        end

        if HasPurchasedVehicle(citizenId, vehicle.model) then
            canBuy = false
        end

        table.insert(availableVehicles, {
            model = vehicle.model,
            label = vehicle.label,
            price = vehicle.price,
            minGrade = vehicle.minGrade,
            canBuy = canBuy
        })
    end

    TriggerClientEvent('DERP-vehicleshop:client:openMenu', src, availableVehicles, dealer.name)
end)

RegisterNetEvent('DERP-vehicleshop:server:buyVehicle', function(dealerIndex, vehicleModel)
    local src = source
    local player = QBX:GetPlayer(src)

    if not player then return end
    
    if IsOnCooldown(src) then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'Vui lòng đợi trước khi thực hiện lại!'
        })
        return
    end

    local dealer = Config.Dealers[dealerIndex]
    if not dealer then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = Config.Notifications.noVehicle
        })
        return
    end

    local vehicleInfo = nil
    for _, v in ipairs(dealer.vehicles) do
        if v.model == vehicleModel then
            vehicleInfo = v
            break
        end
    end

    if not vehicleInfo then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = Config.Notifications.noVehicle
        })
        return
    end

    if dealer.job then
        if not player.PlayerData.job or player.PlayerData.job.name ~= dealer.job then
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'error',
                description = Config.Notifications.notPolice
            })
            return
        end

        if player.PlayerData.job.grade.level < vehicleInfo.minGrade then
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'error',
                description = Config.Notifications.notEligible
            })
            return
        end
    end

    if HasPurchasedVehicle(player.PlayerData.citizenid, vehicleModel) then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = Config.Notifications.alreadyPurchased
        })
        return
    end

    local bankBalance = player.PlayerData.money.bank or 0
    if bankBalance < vehicleInfo.price then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = Config.Notifications.noMoney
        })
        return
    end

    player.Functions.RemoveMoney('bank', vehicleInfo.price, 'bought-vehicle')

    local plate = GeneratePlate()
    
    if not plate then
        player.Functions.AddMoney('bank', vehicleInfo.price, 'plate-generation-failed')
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'Lỗi hệ thống, vui lòng thử lại!'
        })
        return
    end

    local defaultGarage = dealer.defaultGarage or 'legion'

    MySQL.insert.await([[
        INSERT INTO player_vehicles 
        (license, citizenid, vehicle, hash, mods, plate, garage, fuel, engine, body, state, coords) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NULL)
    ]], {
        player.PlayerData.license,
        player.PlayerData.citizenid,
        vehicleModel,
        GetHashKey(vehicleModel),
        '{}',
        plate,
        defaultGarage,
        100,
        1000,
        1000,
        1
    })

    RecordPurchase(player.PlayerData.citizenid, vehicleModel)

    SetCooldown(src)

    TriggerClientEvent('ox_lib:notify', src, {
        type = 'success',
        description = ("Bạn đã mua thành công xe %s!"):format(vehicleInfo.label)
    })

    TriggerClientEvent('DERP-vehicleshop:client:spawnVehicle', src, vehicleModel, plate, dealer.spawnPoint)

    -- print(("[DERP-VehicleShop] %s (%s) đã mua xe %s với giá $%d (plate: %s)"):format(
    --     player.PlayerData.name,
    --     player.PlayerData.citizenid,
    --     vehicleModel,
    --     vehicleInfo.price,
    --     plate
    -- ))
end)

AddEventHandler('playerDropped', function()
    local src = source
    if cooldowns[src] then
        cooldowns[src] = nil
    end
end)