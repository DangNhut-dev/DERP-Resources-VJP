local config = require 'qbx_ignore.config'

---@TODO test if this needs to be called in a loop
CreateThread(function()
    while true do
        for _, sctyp in next, config.blacklisted.scenarioTypes do
            SetScenarioTypeEnabled(sctyp, false)
        end
        for _, scmdl in next, config.blacklisted.suppressedModels do
            SetVehicleModelIsSuppressed(joaat(scmdl), true)
        end
        for _, scgrp in next, config.blacklisted.scenarioGroups do
            SetScenarioGroupEnabled(scgrp, false)
        end
        Wait(10000)
    end
end)

AddEventHandler('populationPedCreating', function(x, y, z, _, pedType)
    if pedType == 4 then return end -- bỏ qua scenario peds nếu cần
    CreateThread(function()
        Wait(500)
        local _, handle = GetClosestPed(x, y, z, 1.0)
        if handle and handle ~= 0 and DoesEntityExist(handle) then
            SetPedDropsWeaponsWhenDead(handle, false)
        end
    end)
end)

CreateThread(function() -- all these should only need to be called once
    if config.disable.ambience then
        StartAudioScene('CHARACTER_CHANGE_IN_SKY_SCENE')
    end
    SetAudioFlag('PoliceScannerDisabled', true)
    SetGarbageTrucks(false)
    SetCreateRandomCops(false)
    SetCreateRandomCopsNotOnScenarios(false)
    SetCreateRandomCopsOnScenarios(false)
    DistantCopCarSirens(false)
    SetFarDrawVehicles(false)
    RemoveVehiclesFromGeneratorsInArea(335.2616 - 300.0, -1432.455 - 300.0, 46.51 - 300.0, 335.2616 + 300.0, -1432.455 + 300.0, 46.51 + 300.0) -- central los santos medical center
    RemoveVehiclesFromGeneratorsInArea(441.8465 - 500.0, -987.99 - 500.0, 30.68 -500.0, 441.8465 + 500.0, -987.99 + 500.0, 30.68 + 500.0) -- police station mission row
    RemoveVehiclesFromGeneratorsInArea(316.79 - 300.0, -592.36 - 300.0, 43.28 - 300.0, 316.79 + 300.0, -592.36 + 300.0, 43.28 + 300.0) -- pillbox
    RemoveVehiclesFromGeneratorsInArea(-2150.44 - 500.0, 3075.99 - 500.0, 32.8 - 500.0, -2150.44 + 500.0, -3075.99 + 500.0, 32.8 + 500.0) -- military
    RemoveVehiclesFromGeneratorsInArea(-1108.35 - 300.0, 4920.64 - 300.0, 217.2 - 300.0, -1108.35 + 300.0, 4920.64 + 300.0, 217.2 + 300.0) -- nudist
    RemoveVehiclesFromGeneratorsInArea(-458.24 - 300.0, 6019.81 - 300.0, 31.34 - 300.0, -458.24 + 300.0, 6019.81 + 300.0, 31.34 + 300.0) -- police station paleto
    RemoveVehiclesFromGeneratorsInArea(1854.82 - 300.0, 3679.4 - 300.0, 33.82 - 300.0, 1854.82 + 300.0, 3679.4 + 300.0, 33.82 + 300.0) -- police station sandy
    RemoveVehiclesFromGeneratorsInArea(-724.46 - 300.0, -1444.03 - 300.0, 5.0 - 300.0, -724.46 + 300.0, -1444.03 + 300.0, 5.0 + 300.0) -- REMOVE CHOPPERS WOW
end)

if config.disable.idleCamera then
    CreateThread(function()
        while true do
            DisableIdleCamera(true)
            DisableVehiclePassengerIdleCamera(true)
            Wait(1000)
        end
    end)
end

if config.disable.headshots then
    lib.onCache('ped', function(ped)
        SetPedSuffersCriticalHits(ped, false)
    end)
end

local function pistolWhipLoop()
    CreateThread(function()
        local sleep
        while cache.weapon do
            sleep = 500
            if IsPedArmed(cache.ped, 6) then
                sleep = 0
                DisableControlAction(1, 140, true)
                DisableControlAction(1, 141, true)
                DisableControlAction(1, 142, true)
            end

            if cache.weapon == `WEAPON_FIREEXTINGUISHER` or cache.weapon == `WEAPON_PETROLCAN` then
                if IsPedShooting(cache.ped) then
                    SetPedInfiniteAmmo(cache.ped, true, `WEAPON_FIREEXTINGUISHER`)
                    SetPedInfiniteAmmo(cache.ped, true, `WEAPON_PETROLCAN`)
                end
            end
            Wait(sleep)
        end
    end)
end

lib.onCache('weapon', function(weapon)
    Wait(5)
    if not weapon then return end
    pistolWhipLoop()
end)
