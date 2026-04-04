local QBCore = exports['qb-core']:GetCoreObject()
local RentedCars = {}
local RENTAL_TTL = 10800
local STORAGE_FILE = 'rentals.json'
local rentStorage = {}

local function LoadStorage()
    local raw = LoadResourceFile(GetCurrentResourceName(), STORAGE_FILE)
    if not raw then rentStorage = {} return end
    rentStorage = json.decode(raw) or {}
end

local function SaveStorage()
    SaveResourceFile(GetCurrentResourceName(), STORAGE_FILE, json.encode(rentStorage), -1)
end

local function StorageGetAll(citizenid)
    local list = rentStorage[citizenid]
    if not list then return {} end
    local now = os.time()
    local valid = {}
    for _, entry in ipairs(list) do
        if now <= entry.expires then
            valid[#valid + 1] = entry
        end
    end
    if #valid ~= #list then
        rentStorage[citizenid] = #valid > 0 and valid or nil
        SaveStorage()
    end
    return valid
end

local function StorageGetByPlate(citizenid, plate)
    for _, entry in ipairs(StorageGetAll(citizenid)) do
        if entry.plate == plate then return entry end
    end
    return nil
end

local function StorageAdd(citizenid, plate, returnprice)
    if not rentStorage[citizenid] then
        rentStorage[citizenid] = {}
    end
    rentStorage[citizenid][#rentStorage[citizenid] + 1] = {
        plate       = plate,
        returnprice = returnprice,
        expires     = os.time() + RENTAL_TTL
    }
    SaveStorage()
end

local function StorageDeletePlate(citizenid, plate)
    local list = rentStorage[citizenid]
    if not list then return end
    for i, entry in ipairs(list) do
        if entry.plate == plate then
            table.remove(list, i)
            break
        end
    end
    if #list == 0 then rentStorage[citizenid] = nil end
    SaveStorage()
end

local function CleanupExpired()
    local now = os.time()
    local changed = false
    for citizenid, list in pairs(rentStorage) do
        local valid = {}
        for _, entry in ipairs(list) do
            if now <= entry.expires then
                valid[#valid + 1] = entry
            else
                changed = true
            end
        end
        rentStorage[citizenid] = #valid > 0 and valid or nil
        if not rentStorage[citizenid] then changed = true end
    end
    if changed then SaveStorage() end
end

LoadStorage()
CleanupExpired()

AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    local src = Player.PlayerData.source
    local citizenid = Player.PlayerData.citizenid
    local list = StorageGetAll(citizenid)
    if #list == 0 then return end
    RentedCars[src] = {}
    for _, entry in ipairs(list) do
        RentedCars[src][#RentedCars[src] + 1] = { plate = entry.plate, returnprice = entry.returnprice, veh = nil, netid = nil }
    end
end)

AddEventHandler('playerDropped', function()
    RentedCars[source] = nil
end)

RegisterServerEvent('qb-rental:server:rentcar')
AddEventHandler('qb-rental:server:rentcar', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if not data or not data.rentid or not data.vehdata then return end
    if not Config.Rentals[data.rentid] then return end

    local vehdata = data.vehdata
    if not vehdata.model or not vehdata.price or not vehdata.returnprice then return end

    local citizenid = Player.PlayerData.citizenid

    local validVeh = false
    local rentList = Config.VehicleList[Config.Rentals[data.rentid].vehiclelist]
    if rentList then
        for _, v in pairs(rentList) do
            if v.model == vehdata.model and v.price == vehdata.price and v.returnprice == vehdata.returnprice then
                validVeh = true
                break
            end
        end
    end
    if not validVeh then return end

    if Player.PlayerData.money['cash'] < vehdata.price then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.not_enough_money'), 'error')
        return
    end

    if not Player.Functions.RemoveMoney('cash', vehdata.price) then return end

    RentSpawnCar(src, citizenid, vehdata.model, Config.Rentals[data.rentid].carspawns[1], vehdata.price, vehdata.returnprice)
end)

RegisterServerEvent('qb-rental:server:startreturnvehicle')
AddEventHandler('qb-rental:server:startreturnvehicle', function(netId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local citizenid = Player.PlayerData.citizenid

    local veh = NetworkGetEntityFromNetworkId(netId)
    if not veh or veh == 0 then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.not_vehicle_nearby'), 'error')
        return
    end

    if GetVehiclePedIsIn(GetPlayerPed(src), false) ~= veh then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.not_vehicle_nearby'), 'error')
        return
    end

    local plate = string.gsub(GetVehicleNumberPlateText(veh), '^%s*(.-)%s*$', '%1')
    local stored = StorageGetByPlate(citizenid, plate)

    if not stored then
        TriggerClientEvent('QBCore:Notify', src, 'Đây không phải xe thuê của bạn!', 'error')
        return
    end

    DeleteEntity(veh)
    Player.Functions.AddMoney('cash', stored.returnprice)
    StorageDeletePlate(citizenid, plate)

    if RentedCars[src] then
        for i, entry in ipairs(RentedCars[src]) do
            if entry.plate == plate then
                table.remove(RentedCars[src], i)
                break
            end
        end
    end

    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.return_04') .. stored.returnprice .. '$', 'success')
end)

function RentSpawnCar(src, citizenid, model, carspawn, price, returnprice)
    local veh = QBCore.Functions.SpawnVehicle(src, model, carspawn, true)
    Wait(100)
    SetEntityHeading(veh, carspawn.w)
    Wait(100)

    local netId = NetworkGetNetworkIdFromEntity(veh)
    local plate = string.gsub(GetVehicleNumberPlateText(veh), '^%s*(.-)%s*$', '%1')

    StorageAdd(citizenid, plate, returnprice)

    if not RentedCars[src] then RentedCars[src] = {} end
    RentedCars[src][#RentedCars[src] + 1] = { veh = veh, netid = netId, plate = plate, returnprice = returnprice }

    TriggerClientEvent('vehiclekeys:client:SetOwner', src, plate)
    TriggerClientEvent('qb-rental:client:setupvehicle', src, netId)

    TriggerClientEvent('QBCore:Notify', src,
        Lang:t('success.return_01') .. price .. Lang:t('success.return_02') .. returnprice .. Lang:t('success.return_03'),
        'success'
    )
end