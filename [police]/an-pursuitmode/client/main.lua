local vehicleHashes = {}

for tier, vehicles in pairs(Option.VehicleTiers) do
    for _, model in pairs(vehicles) do
        local hash = GetHashKey(model)
        vehicleHashes[hash] = { model = model, tier = tier }
        print('Vehicle ' .. model .. ' assigned tier: ' .. tier)
    end
end

local gear, currentVehicle = 1, 0
local currentVehicleMode = Option.VehicleModes[1]
local playerJob = { name = 'unemployed' }

function GetVehicleData()
    local vehicleEntity = GetVehiclePedIsIn(PlayerPedId(), false)
    return vehicleHashes[GetEntityModel(vehicleEntity)]
end

function IsCheckValid()
    local vehicleData = GetVehicleData()
    local vehicleEntity = GetVehiclePedIsIn(PlayerPedId(), false)
    if DoesEntityExist(vehicleEntity) and IsAuthorizedToSwitchMode() and vehicleData and Option.TierConfig[vehicleData.tier] then
        return vehicleEntity
    end
    return false
end

function GetHandlingConfig()
    local vehicleMode = GetVehicleMode()
    local vehicleData = GetVehicleData()
    if not vehicleData or not vehicleData.tier then return nil end
    local tierData = Option.TierConfig[vehicleData.tier]
    if not tierData then return nil end
    return tierData[vehicleMode]
end

function UpdateHandling(vehicle)
    local handlingConfig = GetHandlingConfig()
    if not handlingConfig then return end
    for k, v in pairs(handlingConfig) do
        if math.type(v) == 'float' then
            SetVehicleHandlingFloat(vehicle, "CHandlingData", k, v)
        elseif math.type(v) == 'integer' then
            SetVehicleHandlingInt(vehicle, "CHandlingData", k, v)
        elseif type(v) == 'vector3' then
            SetVehicleHandlingVector(vehicle, "CHandlingData", k, v)
        end
    end
    FixVehicleHandling(vehicle)
end

function GetVehicleMode()
    return currentVehicleMode
end

function UpdatePlayerInfo()
    local playerData = exports.qbx_core:GetPlayerData()
    playerJob = playerData.job
end

function UpdateVehicleMode(vehicle)
    gear = gear % #Option.VehicleModes + 1
    if vehicle ~= currentVehicle then
        gear = 1
    end
    currentVehicle = vehicle
    currentVehicleMode = Option.VehicleModes[gear]
    print('Current vehicle mode: ' .. currentVehicleMode)
end

function IsAuthorizedToSwitchMode()
    if next(Option.AuthorizedJobs) == nil then
        return true
    end
    local playerData = exports.qbx_core:GetPlayerData()
    if not playerData or not playerData.job then return false end
    local job = playerData.job
    for _, v in ipairs(Option.AuthorizedJobs) do
        if job.name == v then
            local gradeLevel = type(job.grade) == 'table' and job.grade.level or job.grade
            return (gradeLevel or 0) >= Option.AuthorizedGradeMin
        end
    end
    return false
end

function ApplyVehicleMods(vehicle)
    local vehicleMode = Option.VehicleModes[gear]
    local mods = Option.VehicleModifications[vehicleMode]
    if not mods then return end
    ToggleVehicleMod(vehicle, 18, mods.Turbo)
    SetVehicleMod(vehicle, 11, mods.Engine, false)
    SetVehicleMod(vehicle, 12, mods.Brakes, false)
    SetVehicleMod(vehicle, 13, mods.Transmission, false)
end

function FixVehicleHandling(veh)
    SetVehicleModKit(veh, 0)
    for _, modIndex in ipairs({0,1,2,3,4,5,6,7,8,9,10,11,12,13,15,16,25,27,28,30,33,34,35}) do
        SetVehicleMod(veh, modIndex, GetVehicleMod(veh, modIndex), false)
    end
    for i = 0, 3 do
        SetVehicleWheelIsPowered(veh, i, true)
    end
end

AddEventHandler('qbx_core:playerLoaded', function(playerData)
    playerJob = playerData.job
end)

AddEventHandler('qbx_core:onJobUpdate', function(job)
    playerJob = job
end)

RegisterNetEvent('patrol_system:client:updatemode')
AddEventHandler('patrol_system:client:updatemode', function()
    local vehicle = IsCheckValid()
    if vehicle then
        UpdateVehicleMode(vehicle)
        UpdateHandling(vehicle)
        ApplyVehicleMods(vehicle)
        lib.notify({
            title = 'Drive Mode',
            description = Option.Notification:format(currentVehicleMode),
            type = 'success',
            duration = 1500,
        })
    end
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    UpdatePlayerInfo()
end)

RegisterCommand('pursuitmode', function()
    TriggerEvent('patrol_system:client:updatemode')
end, false)

RegisterKeyMapping('pursuitmode', 'Change pursuitmode', 'keyboard', Option.DefaultKey)