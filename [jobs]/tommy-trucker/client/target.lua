local NPCEntity = nil
local NPCBlip   = nil

-- ─── SPAWN NPC ───────────────────────────────────────────────────────────────

CreateThread(function()
    local model = Config.NPCLocation.model
    lib.requestModel(model)

    NPCEntity = CreatePed(4, model,
        Config.NPCLocation.coords.x,
        Config.NPCLocation.coords.y,
        Config.NPCLocation.coords.z - 1,
        Config.NPCLocation.coords.w,
        false, true)

    SetEntityAsMissionEntity(NPCEntity, true, true)
    SetPedFleeAttributes(NPCEntity, 0, 0)
    SetPedDiesWhenInjured(NPCEntity, false)
    SetPedKeepTask(NPCEntity, true)
    SetBlockingOfNonTemporaryEvents(NPCEntity, true)
    SetEntityInvincible(NPCEntity, true)
    FreezeEntityPosition(NPCEntity, true)

    if Config.NPCLocation.scenario then
        TaskStartScenarioInPlace(NPCEntity, Config.NPCLocation.scenario, 0, true)
    end

    -- Blip cho điểm nhận đơn hàng
    NPCBlip = AddBlipForCoord(
        Config.NPCLocation.coords.x,
        Config.NPCLocation.coords.y,
        Config.NPCLocation.coords.z
    )
    SetBlipSprite(NPCBlip, Config.NPCBlip.sprite or 477)
    SetBlipDisplay(NPCBlip, 4)
    SetBlipScale(NPCBlip, Config.NPCBlip.scale or 0.8)
    SetBlipColour(NPCBlip, Config.NPCBlip.color or 3)
    SetBlipAsShortRange(NPCBlip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.NPCBlip.label or locale('target_npc_label'))
    EndTextCommandSetBlipName(NPCBlip)

    -- Register ox_target on the NPC entity
    exports.ox_target:addLocalEntity(NPCEntity, {
        {
            icon     = 'fas fa-truck',
            label    = locale('target_npc_label'),
            distance = 2.5,
            onSelect = function()
                OpenTruckerUI()
            end,
        },
    })
end)

-- ─── POLICE COMMANDS ─────────────────────────────────────────────────────────

local function GetClosestTruck(coords)
    local PlayerData = exports.qbx_core:GetPlayerData()
    if PlayerData.job.name ~= 'police' then
        Notify(locale('error_not_police'), 'error')
        return nil
    end

    for _, vehicle in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(vehicle) then
            local dist = #(coords - GetEntityCoords(vehicle))
            if dist <= 5.0 then
                local vehicleName = string.lower(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
                if Config.TruckWhitelist[vehicleName] then
                    return vehicle
                end
            end
        end
    end

    Notify(locale('error_no_truck_nearby'), 'error')
    return nil
end

RegisterCommand('checkcargo', function()
    local ped     = PlayerPedId()
    local coords  = GetEntityCoords(ped)
    local vehicle = GetClosestTruck(coords)
    if vehicle then PoliceCheckCargo(vehicle) end
end, false)

RegisterCommand('confiscatecargo', function()
    local ped     = PlayerPedId()
    local coords  = GetEntityCoords(ped)
    local vehicle = GetClosestTruck(coords)
    if vehicle then PoliceConfiscateCargo(vehicle) end
end, false)

TriggerEvent('chat:addSuggestion', '/checkcargo',     locale('cmd_checkcargo'))
TriggerEvent('chat:addSuggestion', '/confiscatecargo', locale('cmd_confiscatecargo'))

-- ─── POLICE CHECK ────────────────────────────────────────────────────────────

function PoliceCheckCargo(vehicle)
    local ped   = PlayerPedId()
    local netId = NetworkGetNetworkIdFromEntity(vehicle)

    local success = lib.progressBar({
        duration = 5000,
        label    = locale('police_checking'),
        useWhileDead = false,
        canCancel    = true,
        disable = { move = true, car = true, combat = true },
        anim = {
            dict  = 'amb@world_human_clipboard@male@idle_a',
            clip  = 'idle_c',
            flag  = 49,
        },
    })

    ClearPedTasks(ped)

    if success then
        lib.callback('tommy-trucker:server:checkCargo', false, function(data)
            if data.hasCargo then
                if data.isIllegal then
                    Notify(locale('police_found_illegal'), 'error', 5000)
                else
                    Notify(locale('police_found_legal'), 'success')
                end
            else
                Notify(locale('police_no_cargo'), 'inform')
            end
        end, netId)
    end
end

-- ─── CLEANUP ─────────────────────────────────────────────────────────────────

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if NPCBlip and DoesBlipExist(NPCBlip) then
        RemoveBlip(NPCBlip)
        NPCBlip = nil
    end
    if NPCEntity then
        exports.ox_target:removeLocalEntity(NPCEntity)
        DeleteEntity(NPCEntity)
    end
end)