-- Pre-built hash set từ config
local vehicleHashSet = {}
for i = 1, #Config.GunRack.AllowedVehicles do
    vehicleHashSet[GetHashKey(Config.GunRack.AllowedVehicles[i])] = true
end

local function isJobAllowed(jobName)
    for i = 1, #Config.GunRack.AllowedJobs do
        if Config.GunRack.AllowedJobs[i] == jobName then return true end
    end
    return false
end

RegisterNetEvent('gunrack:server:open', function()
    local src    = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end

    -- Validate job
    if not isJobAllowed(Player.PlayerData.job.name) then
        lib.notify(src, { type = 'error', description = 'Bạn không có chìa khóa để mở!' })
        return
    end

    -- Validate player đang trong xe
    local ped     = GetPlayerPed(src)
    local vehicle = GetVehiclePedIsIn(ped, false)
    if not vehicle or vehicle == 0 then
        lib.notify(src, { type = 'error', description = 'Bạn phải ngồi trong xe!' })
        return
    end

    -- Validate model xe
    local model = GetEntityModel(vehicle)
    if not vehicleHashSet[model] then
        lib.notify(src, { type = 'error', description = 'Xe này không có Gun Rack!' })
        return
    end

    -- Stash gắn theo biển số xe → mỗi xe có rack riêng
    local plate   = GetVehicleNumberPlateText(vehicle):gsub('%s+', ''):upper()
    local stashId = 'GunRack_' .. plate

    exports.ox_inventory:RegisterStash(stashId, 'Police Gun Rack', Config.GunRack.Slots, Config.GunRack.MaxWeight)
    exports.ox_inventory:forceOpenInventory(src, 'stash', stashId)
end)