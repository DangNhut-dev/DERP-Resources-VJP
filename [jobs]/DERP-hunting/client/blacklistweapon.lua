-- blacklistweapon.lua

local blacklistedWeapons = {
    GetHashKey('WEAPON_MUSKET'),
}

local jobActive = false

RegisterNetEvent('DERP-hunting:client:jobStarted')
AddEventHandler('DERP-hunting:client:jobStarted',     function() jobActive = true  end)

RegisterNetEvent('DERP-hunting:client:jobEnded')
AddEventHandler('DERP-hunting:client:jobEnded',       function() jobActive = false end)

RegisterNetEvent('DERP-hunting:client:groupDisbanded')
AddEventHandler('DERP-hunting:client:groupDisbanded', function() jobActive = false end)

local function isBlacklisted(weaponHash)
    for _, hash in ipairs(blacklistedWeapons) do
        if hash == weaponHash then return true end
    end
    return false
end

local function blockFiring()
    DisablePlayerFiring(PlayerId(), true)
    DisableControlAction(0, 24, true)
    DisableControlAction(0, 25, true)
    DisableControlAction(0, 257, true)
    DisableControlAction(0, 263, true)
end

local function isAimingAtAnyPlayer()
    local camRot = GetGameplayCamRot(2)
    local rad    = math.pi / 180.0
    local aimDir = vector3(
        -math.sin(rad * camRot.z) * math.abs(math.cos(rad * camRot.x)),
         math.cos(rad * camRot.z) * math.abs(math.cos(rad * camRot.x)),
         math.sin(rad * camRot.x)
    )
    local origin = GetEntityCoords(cache.ped)

    for _, pid in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(pid)
        if targetPed ~= cache.ped and DoesEntityExist(targetPed) then
            local toTarget = GetEntityCoords(targetPed) - origin
            local dist     = #toTarget
            if dist < 200.0 then
                local dot = (toTarget.x * aimDir.x + toTarget.y * aimDir.y + toTarget.z * aimDir.z) / dist
                if dot > 0.92 then return true end
            end
        end
    end
    return false
end

Citizen.CreateThread(function()
    while true do
        if isBlacklisted(GetSelectedPedWeapon(cache.ped)) then
            if not jobActive or isAimingAtAnyPlayer() then
                blockFiring()
            end
        end
        Citizen.Wait(0)
    end
end)