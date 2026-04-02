local isPolice           = false
local isInAllowedVehicle = false
local radialActive       = false

local RADIAL_ID      = 'gunrack_open'
local vehicleHashSet = {}

local function buildVehicleHashSet()
    vehicleHashSet = {}
    for i = 1, #Config.GunRack.AllowedVehicles do
        vehicleHashSet[GetHashKey(Config.GunRack.AllowedVehicles[i])] = true
    end
end

buildVehicleHashSet() 

local function addRadialItem()
    lib.addRadialItem({
        id       = RADIAL_ID,
        label    = 'Mở Giá Đựng Súng',
        icon     = 'gun',
        onSelect = function()
            TriggerServerEvent('gunrack:server:open')
        end,
    })
end

local function removeRadialItem()
    lib.removeRadialItem(RADIAL_ID)
end

local function updateRadial()
    local shouldShow = isPolice and isInAllowedVehicle
    if shouldShow and not radialActive then
        radialActive = true
        addRadialItem()
    elseif not shouldShow and radialActive then
        radialActive = false
        removeRadialItem()
    end
end

local function checkJob(job)
    isPolice = false
    for i = 1, #Config.GunRack.AllowedJobs do
        if Config.GunRack.AllowedJobs[i] == job.name then
            isPolice = true
            break
        end
    end
end

lib.onCache('vehicle', function(vehicle)
    if vehicle then
        isInAllowedVehicle = vehicleHashSet[GetEntityModel(vehicle)] == true
    else
        isInAllowedVehicle = false
    end
    updateRadial()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    local PlayerData = exports.qbx_core:GetPlayerData()
    if PlayerData and PlayerData.job then
        checkJob(PlayerData.job)
    end
    updateRadial()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    checkJob(job)
    updateRadial()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    if radialActive then
        removeRadialItem()
    end
end)

CreateThread(function()
    local PlayerData = exports.qbx_core:GetPlayerData()
    if PlayerData and PlayerData.job then
        checkJob(PlayerData.job)
        local vehicle = cache.vehicle
        if vehicle then
            isInAllowedVehicle = vehicleHashSet[GetEntityModel(vehicle)] == true
        end
        updateRadial()
    end
end)