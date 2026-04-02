-- ────────────────────────────────────────────────────────────
-- HANDHELD MEGAPHONE (dùng item)
-- ────────────────────────────────────────────────────────────

local megaphoneEnabled = false

RegisterNetEvent('DERP-megaphone:client:usemegaphone', function()
    megaphoneEnabled = not megaphoneEnabled
    toggleMegaphone('handHeld', megaphoneEnabled)
end)

-- ────────────────────────────────────────────────────────────
-- VEHICLE MEGAPHONE
-- ────────────────────────────────────────────────────────────

local vehMegaEnabled = false

local function isPlayerInVehicle()
    return IsPedInAnyVehicle(PlayerPedId(), false)
end

local function isAllowedVehicle()
    local ped     = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then return false end

    local model = GetEntityModel(vehicle)

    if Config.specifyVehicles then
        for _, name in ipairs(Config.vehicles) do
            if model == GetHashKey(name) then return true end
        end
    else
        local class = GetVehicleClass(vehicle)
        for _, allowed in ipairs(Config.vehicleClass) do
            if class == allowed then return true end
        end
    end
    return false
end

-- Tự tắt nếu rời xe
CreateThread(function()
    while true do
        Wait(1000)
        if vehMegaEnabled and (not isPlayerInVehicle() or not isAllowedVehicle()) then
            toggleMegaphone('vehicle', false)
            vehMegaEnabled = false
        end
    end
end)

RegisterCommand('vehmega', function()
    if isPlayerInVehicle() and isAllowedVehicle() then
        vehMegaEnabled = not vehMegaEnabled
        toggleMegaphone('vehicle', vehMegaEnabled)
    end
end)

RegisterKeyMapping('vehmega', '(Voice) Vehicle Megaphone', 'keyboard', Config.keybind)
