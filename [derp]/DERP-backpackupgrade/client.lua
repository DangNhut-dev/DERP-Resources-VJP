local upgradePed = nil
local isUIOpen   = false

-- Xóa toàn bộ ped cùng model gần coords trước khi spawn mới
local function ClearOldPeds()
    local model  = joaat(Config.PedModel)
    local coords = vec3(Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z)
    local peds   = GetGamePool('CPed')

    for _, ped in ipairs(peds) do
        if GetEntityModel(ped) == model then
            local dist = #(GetEntityCoords(ped) - coords)
            if dist < 5.0 and DoesEntityExist(ped) and not IsEntityAttached(ped) then
                SetEntityAsMissionEntity(ped, true, true)
                DeletePed(ped)
            end
        end
    end
end

-- Spawn ped tại coords và đăng ký ox_target lên entity đó
local function SpawnPed()
    ClearOldPeds()

    local model = joaat(Config.PedModel)
    lib.requestModel(model)

    upgradePed = CreatePed(
        4,
        model,
        Config.PedCoords.x,
        Config.PedCoords.y,
        Config.PedCoords.z - 1,
        Config.PedCoords.w,
        false, false
    )
    FreezeEntityPosition(upgradePed, true)
    SetEntityInvincible(upgradePed, true)
    SetBlockingOfNonTemporaryEvents(upgradePed, true)
    SetPedCanRagdoll(upgradePed, false)
    SetEntityAsMissionEntity(upgradePed, true, true)
    SetModelAsNoLongerNeeded(model)

    exports.ox_target:addLocalEntity(upgradePed, {
        {
            name     = 'backpack_upgrade_open',
            label    = 'Nâng cấp balo',
            icon     = 'fas fa-arrow-up',
            distance = 2.0,
            onSelect = function()
                if isUIOpen then return end
                lib.callback('DERP-backpackupgrade:getItems', false, function(data)
                    if not data then return end
                    isUIOpen = true
                    SetNuiFocus(true, true)
                    SendNUIMessage({
                        action       = 'open',
                        resourceName = GetCurrentResourceName(),
                        data         = data,
                    })
                end)
            end,
        },
    })
end

AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    SpawnPed()
end)

AddEventHandler('onClientResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    if upgradePed and DoesEntityExist(upgradePed) then
        exports.ox_target:removeLocalEntity(upgradePed)
        SetEntityAsMissionEntity(upgradePed, true, true)
        DeletePed(upgradePed)
        upgradePed = nil
    end
    if isUIOpen then
        SetNuiFocus(false, false)
        isUIOpen = false
    end
end)

RegisterNUICallback('closeUI', function(_, cb)
    isUIOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Gửi request upgrade lên server qua lib.callback, trả về kết quả cho NUI
RegisterNUICallback('startUpgrade', function(data, cb)
    if not data or not data.baloSlot or not data.materialSlots then
        return cb({ error = 'invalid_data' })
    end
    local arcStartDeg = type(data.arcStartDeg) == 'number' and data.arcStartDeg or 0
    lib.callback('DERP-backpackupgrade:upgrade', false, function(result)
        cb(result or { error = 'timeout' })
    end, data.baloSlot, data.materialSlots, arcStartDeg)
end)

RegisterNUICallback('confirmUpgrade', function(data, cb)
    if not data or not data.token then return cb('error') end
    if GetResourceState('svc_runtime') == 'started' then
        exports['svc_runtime']:ExecuteServerEvent('DERP-backpackupgrade:confirmUpgrade', data.token)
    else
        TriggerServerEvent('DERP-backpackupgrade:confirmUpgrade', data.token)
    end
    cb('ok')
end)