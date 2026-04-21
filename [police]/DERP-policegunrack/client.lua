local vehicleHashSet = {}

local function buildVehicleHashSet()
    vehicleHashSet = {}
    for i = 1, #Config.GunRack.AllowedVehicles do
        vehicleHashSet[GetHashKey(Config.GunRack.AllowedVehicles[i])] = true
    end
end

buildVehicleHashSet()

local function isInAllowedVehicle()
    local vehicle = cache.vehicle
    if not vehicle then return false end
    return vehicleHashSet[GetEntityModel(vehicle)] == true
end

-- Event cho qbx_radialmenu jobItems.police gọi vào
RegisterNetEvent('gunrack:client:openFromRadial', function()
    if not isInAllowedVehicle() then
        exports.qbx_core:Notify('Bạn không ở trong xe cảnh sát hợp lệ', 'error')
        return
    end
    TriggerServerEvent('gunrack:server:open')
end)