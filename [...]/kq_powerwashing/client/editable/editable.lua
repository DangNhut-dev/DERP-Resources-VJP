function IsPlayerUnreachable()
    return UseCache('IsPlayerUnreachable', function()
        local playerPed = PlayerPedId()
        return IsPedInAnyVehicle(playerPed) or IsPedRagdoll(playerPed) or IsEntityDead(playerPed)
    end, 250)
end

function DoesPlayerHavePowerwashingJob()
    if not Config.jobName then
        return true
    end

    local job = exports.kq_link:GetPlayerJob()

    return job == Config.jobName
end

function ShowKeybindHint(message)
    SetTextComponentFormat("STRING")
    AddTextComponentString(message)
    EndTextCommandDisplayHelp(0, 0, 0, 4000)
end

function ApplyVehicleLevelUpgrades(vehicle, level)
    SetVehicleModKit(vehicle, 0)

    local brakesUpgrade = Config.levelUpgrades['vehicle_brakes']
    if brakesUpgrade and level >= brakesUpgrade.level then
        SetVehicleMod(vehicle, 12, 3, false)
    end

    local engineUpgrade = Config.levelUpgrades['vehicle_engine']
    if engineUpgrade and level >= engineUpgrade.level then
        SetVehicleMod(vehicle, 11, 3, false)
        SetVehicleMod(vehicle, 13, 3, false)
    end

    local tintUpgrade = Config.levelUpgrades['vehicle_tint']
    if tintUpgrade and level >= tintUpgrade.level then
        SetVehicleWindowTint(vehicle, 3)
    end

    local turboUpgrade = Config.levelUpgrades['vehicle_turbo']
    if turboUpgrade and level >= turboUpgrade.level then
        ToggleVehicleMod(vehicle, 18, true)
    end
end

Dummy = {
    -- Called when the powerwasher gun hits. Could be used for external usage
    OnPowerwasherHit = function(coords, entity)

    end
}
