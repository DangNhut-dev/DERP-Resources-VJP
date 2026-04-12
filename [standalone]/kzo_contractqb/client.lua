AddEventHandler('kzo_contract:useitem', function()
    local coords = GetEntityCoords(cache.ped)
    local vehicle = lib.getClosestVehicle(coords, 3.5, false)
    local player = lib.getClosestPlayer(coords, 3.5)

    if not vehicle or not DoesEntityExist(vehicle) then
        exports.qbx_core:Notify('Không có xe gần bạn!', 'error')
        return
    end

    if not player then
        exports.qbx_core:Notify('Không có người chơi gần bạn!', 'error')
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    local targetId = GetPlayerServerId(player)

    lib.callback('kzo_contract:getclosestplayername', false, function(name, playername)
        if not name or not playername then
            exports.qbx_core:Notify('Lỗi lấy thông tin người chơi.', 'error')
            return
        end
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'opencontract',
            plate = plate,
            name = name,
            playername = playername,
            closestid = targetId,
        })
    end, targetId)
end)

RegisterNetEvent('kzo_contract:showAnim', function()
    if GetInvokingResource() then return end
    TaskStartScenarioInPlace(cache.ped, 'WORLD_HUMAN_CLIPBOARD', 0, true)
    Wait(10000)
    ClearPedTasks(cache.ped)
end)

RegisterNUICallback('escape', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('writecontract', function(data, cb)
    if not data.player or not data.vehicle then cb('error') return end
    TriggerServerEvent('kzo_contract:writecontact', data.player, data.vehicle)
    cb('ok')
end)