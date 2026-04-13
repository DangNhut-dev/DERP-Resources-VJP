local activeDryingRacks = {}
local playerRackCount = 0
local rackReadyStatus = {}

CreateThread(function()
    while true do
        Wait(5000)
        for rackId, rack in pairs(activeDryingRacks) do
            if rack.isDrying and rack.startedAt then
                lib.callback('tommy-weedplant:server:canCollectDried', false, function(canCollect)
                    rackReadyStatus[rackId] = canCollect
                end, rackId)
            else
                rackReadyStatus[rackId] = false
            end
        end
    end
end)

local function SpawnDryingRack(rackId, coords, owner, items, startedAt, isDrying, heading)
    local modelName = isDrying and Config.DryingRack.fullProp or Config.DryingRack.emptyProp
    local modelHash = GetHashKey(modelName)

    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 100 do
        Wait(100)
        timeout = timeout + 1
    end
    if not HasModelLoaded(modelHash) then return end

    local rack = CreateObject(modelHash, coords.x, coords.y, coords.z - 1.0, false, true, false)
    SetEntityHeading(rack, heading or 0.0)
    FreezeEntityPosition(rack, true)

    activeDryingRacks[rackId] = {
        object = rack, coords = coords, owner = owner,
        items = items or {}, startedAt = startedAt,
        isDrying = isDrying or false, heading = heading or 0.0,
    }

    local PlayerData = exports.qbx_core:GetPlayerData()
    if owner == PlayerData.citizenid then
        playerRackCount = playerRackCount + 1
    end

    CreateDryingRackTarget(rackId, rack)
    return rack
end

local function RemoveDryingRack(rackId)
    if not activeDryingRacks[rackId] then return end
    local PlayerData = exports.qbx_core:GetPlayerData()
    if activeDryingRacks[rackId].owner == PlayerData.citizenid then
        playerRackCount = math.max(0, playerRackCount - 1)
    end
    if DoesEntityExist(activeDryingRacks[rackId].object) then
        exports.ox_target:removeLocalEntity(activeDryingRacks[rackId].object, {
            'rack_dry_' .. rackId,
            'rack_status_' .. rackId,
            'rack_collect_' .. rackId,
            'rack_pickup_' .. rackId,
        })
        DeleteEntity(activeDryingRacks[rackId].object)
    end
    activeDryingRacks[rackId] = nil
    rackReadyStatus[rackId] = nil
end

function CreateDryingRackTarget(rackId, rackObject)
    local rack = activeDryingRacks[rackId]
    if not rack then return end

    exports.ox_target:addLocalEntity(rackObject, {
        {
            name = 'rack_dry_' .. rackId,
            icon = 'fas fa-cannabis',
            label = 'Phơi Cần',
            distance = 2.5,
            canInteract = function()
                local r = activeDryingRacks[rackId]
                return r and not r.isDrying
            end,
            onSelect = function()
                TriggerEvent('tommy-weedplant:client:openDryingUI', { rackId = rackId })
            end,
        },
        {
            name = 'rack_status_' .. rackId,
            icon = 'fas fa-info-circle',
            label = 'Xem Thông Tin',
            distance = 2.5,
            canInteract = function()
                local r = activeDryingRacks[rackId]
                return r and r.isDrying and not rackReadyStatus[rackId]
            end,
            onSelect = function()
                TriggerEvent('tommy-weedplant:client:checkDryingStatus', { rackId = rackId })
            end,
        },
        {
            name = 'rack_collect_' .. rackId,
            icon = 'fas fa-hand-holding',
            label = 'Lấy Cần',
            distance = 2.5,
            canInteract = function()
                local r = activeDryingRacks[rackId]
                if not r or not r.isDrying then return false end
                return rackReadyStatus[rackId] == true
            end,
            onSelect = function()
                TriggerEvent('tommy-weedplant:client:collectDried', { rackId = rackId })
            end,
        },
        {
            name = 'rack_pickup_' .. rackId,
            icon = 'fas fa-hand-paper',
            label = 'Thu Kệ Phơi',
            distance = 2.5,
            canInteract = function()
                local r = activeDryingRacks[rackId]
                return r and not r.isDrying
            end,
            onSelect = function()
                TriggerEvent('tommy-weedplant:client:pickupRack', { rackId = rackId })
            end,
        },
    })
end

RegisterNetEvent('tommy-weedplant:client:useDryingRack', function()
    local ped = cache.ped
    local pedCoords = GetEntityCoords(ped)
    local pedHeading = GetEntityHeading(ped)
    local forwardX = pedCoords.x + math.sin(math.rad(-pedHeading)) * 1.5
    local forwardY = pedCoords.y + math.cos(math.rad(-pedHeading)) * 1.5

    local found, groundZ = GetGroundZFor_3dCoord(forwardX, forwardY, pedCoords.z + 100.0, 0)
    if not found then
        lib.notify({ description = Config.Notifications['invalid_location'], type = 'error' })
        return
    end

    local rackCoords = vector3(forwardX, forwardY, groundZ + 1.0)
    lib.requestAnimDict('amb@world_human_hammering@male@base')
    TaskPlayAnim(ped, 'amb@world_human_hammering@male@base', 'base', 8.0, -8.0, 2000, 1, 0, false, false, false)

    if lib.progressBar({
        duration = 2000,
        label = 'Đang đặt bàn sấy...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
    }) then
        ClearPedTasks(ped)
        TriggerServerEvent('tommy-weedplant:server:placeDryingRack', rackCoords, GetEntityHeading(cache.ped))
    else
        ClearPedTasks(ped)
    end
end)

RegisterNetEvent('tommy-weedplant:client:openDryingUI', function(data)
    local rackId = data.rackId
    if not activeDryingRacks[rackId] then return end

    lib.callback('tommy-weedplant:server:getPlayerBuds', false, function(buds)
        SendNUIMessage({ action = 'openDryingUI', rackId = rackId, buds = buds })
        SetNuiFocus(true, true)
    end)
end)

RegisterNetEvent('tommy-weedplant:client:checkDryingStatus', function(data)
    local rackId = data.rackId
    local rack = activeDryingRacks[rackId]
    if not rack or not rack.isDrying then return end

    lib.callback('tommy-weedplant:server:getDryingTimeRemaining', false, function(remaining)
        if remaining <= 0 then
            lib.notify({ description = 'Cần đã sấy xong! Hãy lấy cần ngay.', type = 'success' })
            rackReadyStatus[rackId] = true
        else
            local minutes = math.floor(remaining / 60000)
            local seconds = math.floor((remaining % 60000) / 1000)
            lib.notify({ description = string.format('Còn lại: %dphút %dgiây', minutes, seconds), type = 'inform' })
        end
    end, rackId)
end)

RegisterNetEvent('tommy-weedplant:client:collectDried', function(data)
    local rackId = data.rackId
    if not activeDryingRacks[rackId] then return end

    local ped = cache.ped
    lib.requestAnimDict('amb@world_human_gardener_plant@male@base')
    TaskPlayAnim(ped, 'amb@world_human_gardener_plant@male@base', 'base', 8.0, -8.0, 2000, 1, 0, false, false, false)

    if lib.progressBar({
        duration = 2000,
        label = 'Đang lấy cần khô...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
    }) then
        ClearPedTasks(ped)
        if GetResourceState('svc_runtime') == 'started' then
            exports['svc_runtime']:ExecuteServerEvent('tommy-weedplant:server:collectDried', rackId)
        else
            TriggerServerEvent('tommy-weedplant:server:collectDried', rackId)
        end
    else
        ClearPedTasks(ped)
    end
end)

RegisterNetEvent('tommy-weedplant:client:pickupRack', function(data)
    local rackId = data.rackId
    if not activeDryingRacks[rackId] then return end

    local ped = cache.ped
    lib.requestAnimDict('amb@world_human_hammering@male@base')
    TaskPlayAnim(ped, 'amb@world_human_hammering@male@base', 'base', 8.0, -8.0, 2000, 1, 0, false, false, false)

    if lib.progressBar({
        duration = 2000,
        label = 'Đang thu bàn sấy...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
    }) then
        ClearPedTasks(ped)
        if GetResourceState('svc_runtime') == 'started' then
            exports['svc_runtime']:ExecuteServerEvent('tommy-weedplant:server:pickupRack', rackId)
        else
            TriggerServerEvent('tommy-weedplant:server:pickupRack', rackId)
        end
    else
        ClearPedTasks(ped)
    end
end)

RegisterNetEvent('tommy-weedplant:client:spawnDryingRack', function(rackId, coords, owner, items, startedAt, isDrying, heading)
    SpawnDryingRack(rackId, coords, owner, items, startedAt, isDrying, heading)
    if isDrying and startedAt then
        lib.callback('tommy-weedplant:server:canCollectDried', false, function(canCollect)
            rackReadyStatus[rackId] = canCollect
        end, rackId)
    end
end)

RegisterNetEvent('tommy-weedplant:client:removeDryingRack', function(rackId)
    RemoveDryingRack(rackId)
end)

RegisterNetEvent('tommy-weedplant:client:updateRackStatus', function(rackId, isDrying)
    if not activeDryingRacks[rackId] then return end
    local rack = activeDryingRacks[rackId]
    local coords, owner, items, startedAt, heading = rack.coords, rack.owner, rack.items, rack.startedAt, rack.heading
    RemoveDryingRack(rackId)
    SpawnDryingRack(rackId, coords, owner, items, startedAt, isDrying, heading)
    rackReadyStatus[rackId] = false
end)

RegisterNetEvent('tommy-weedplant:client:syncDryingRacks', function(racks)
    for rackId, _ in pairs(activeDryingRacks) do RemoveDryingRack(rackId) end
    playerRackCount = 0
    rackReadyStatus = {}
    for rackId, rackData in pairs(racks) do
        SpawnDryingRack(rackId, rackData.coords, rackData.owner, rackData.items, rackData.startedAt, rackData.isDrying, rackData.heading)
        if rackData.isDrying and rackData.startedAt then
            lib.callback('tommy-weedplant:server:canCollectDried', false, function(canCollect)
                rackReadyStatus[rackId] = canCollect
            end, rackId)
        end
    end
end)

RegisterNetEvent('tommy-weedplant:client:updateRackCount', function(count)
    playerRackCount = count
end)

RegisterNUICallback('closeDryingUI', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('startDrying', function(data, cb)
    TriggerServerEvent('tommy-weedplant:server:startDrying', data.rackId, data.items)
    SetNuiFocus(false, false)
    cb('ok')
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    Wait(2000)
    TriggerServerEvent('tommy-weedplant:server:requestDryingSync')
end)

CreateThread(function()
    Wait(2000)
    if LocalPlayer.state.isLoggedIn then
        TriggerServerEvent('tommy-weedplant:server:requestDryingSync')
    end
end)