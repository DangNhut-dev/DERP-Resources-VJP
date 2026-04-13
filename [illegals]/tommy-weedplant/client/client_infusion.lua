local activeInfusionTables = {}
local isInfusing = false
local currentTableId = nil
local infusionStartTime = nil
local isUIOpen = false

local function SpawnInfusionTable(tableId, coords, owner, heading)
    local modelHash = GetHashKey(Config.InfusionTableProp)
    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 100 do
        Wait(100)
        timeout = timeout + 1
    end
    if not HasModelLoaded(modelHash) then return end

    local tableObj = CreateObject(modelHash, coords.x, coords.y, coords.z - 1.0, false, true, false)
    SetEntityHeading(tableObj, heading or 0.0)
    FreezeEntityPosition(tableObj, true)

    activeInfusionTables[tableId] = {
        object = tableObj, coords = coords,
        owner = owner, heading = heading or 0.0,
    }
    CreateInfusionTableTarget(tableId, tableObj)
    return tableObj
end

local function RemoveInfusionTable(tableId)
    if not activeInfusionTables[tableId] then return end
    if DoesEntityExist(activeInfusionTables[tableId].object) then
        exports.ox_target:removeLocalEntity(activeInfusionTables[tableId].object, {
            'infusion_use_' .. tableId,
            'infusion_pickup_' .. tableId,
        })
        DeleteEntity(activeInfusionTables[tableId].object)
    end
    activeInfusionTables[tableId] = nil
end

function CreateInfusionTableTarget(tableId, tableObject)
    local tbl = activeInfusionTables[tableId]
    if not tbl then return end

    exports.ox_target:addLocalEntity(tableObject, {
        {
            name = 'infusion_use_' .. tableId,
            icon = 'fas fa-flask',
            label = 'Tẩm Cần',
            distance = Config.InfusionInteractionDistance,
            canInteract = function() return not isInfusing and not isUIOpen end,
            onSelect = function()
                TriggerEvent('tommy-weedplant:client:openInfusionUI', { tableId = tableId })
            end,
        },
        {
            name = 'infusion_pickup_' .. tableId,
            icon = 'fas fa-hand-paper',
            label = 'Thu Bàn Tẩm',
            distance = Config.InfusionInteractionDistance,
            canInteract = function() return not isInfusing and not isUIOpen end,
            onSelect = function()
                TriggerEvent('tommy-weedplant:client:pickupInfusionTable', { tableId = tableId })
            end,
        },
    })
end

local function OpenInfusionUI(tableId)
    if isUIOpen then return end
    currentTableId = tableId
    isUIOpen = true

    lib.callback('tommy-weedplant:server:getInfusionInventory', false, function(data)
        SendNUIMessage({
            action = 'openInfusionUI',
            tableId = tableId,
            buds = data.buds,
            ingredients = data.ingredients,
        })
        SetNuiFocus(true, true)
    end)
end

local function CloseInfusionUI()
    if not isUIOpen then return end
    isUIOpen = false
    SendNUIMessage({ action = 'closeInfusionUI' })
    SetNuiFocus(false, false)
    if isInfusing then
        local currentTime = GetGameTimer()
        local elapsed = (currentTime - (infusionStartTime or currentTime)) / 1000
        if GetResourceState('svc_runtime') == 'started' then
            exports['svc_runtime']:ExecuteServerEvent('tommy-weedplant:server:finishInfusion', elapsed)
        else
            TriggerServerEvent('tommy-weedplant:server:finishInfusion', elapsed)
        end
        isInfusing = false
    end
    currentTableId = nil
end

local function StartInfusion(budType, budAmount, ingredients)
    if isInfusing then return end
    isInfusing = true
    infusionStartTime = GetGameTimer()
    TriggerServerEvent('tommy-weedplant:server:startInfusion', currentTableId, budType, budAmount, ingredients)

    CreateThread(function()
        while isInfusing do
            local elapsed = (GetGameTimer() - infusionStartTime) / 1000
            SendNUIMessage({ action = 'updateInfusionTime', time = elapsed })
            Wait(100)
        end
    end)
end

function StopInfusion(isCancel)
    if not isInfusing then return end
    local elapsed = (GetGameTimer() - (infusionStartTime or GetGameTimer())) / 1000
    isInfusing = false
    if GetResourceState('svc_runtime') == 'started' then
        exports['svc_runtime']:ExecuteServerEvent('tommy-weedplant:server:finishInfusion', elapsed)
    else
        TriggerServerEvent('tommy-weedplant:server:finishInfusion', elapsed)
    end
    CloseInfusionUI()
end

RegisterNetEvent('tommy-weedplant:client:useInfusionTable', function()
    local ped = cache.ped
    local pedCoords = GetEntityCoords(ped)
    local pedHeading = GetEntityHeading(ped)
    local forwardX = pedCoords.x + math.sin(math.rad(-pedHeading)) * 1.5
    local forwardY = pedCoords.y + math.cos(math.rad(-pedHeading)) * 1.5

    local found, groundZ = GetGroundZFor_3dCoord(forwardX, forwardY, pedCoords.z + 100.0, 0)
    if not found then
        lib.notify({ description = 'Vị trí không hợp lệ!', type = 'error' })
        return
    end

    local tableCoords = vector3(forwardX, forwardY, groundZ + 1.0)
    lib.requestAnimDict('amb@world_human_hammering@male@base')
    TaskPlayAnim(ped, 'amb@world_human_hammering@male@base', 'base', 8.0, -8.0, 2000, 1, 0, false, false, false)

    if lib.progressBar({
        duration = 2000,
        label = 'Đang đặt bàn tẩm...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
    }) then
        ClearPedTasks(ped)
        TriggerServerEvent('tommy-weedplant:server:placeInfusionTable', tableCoords, GetEntityHeading(cache.ped))
    else
        ClearPedTasks(ped)
    end
end)

RegisterNetEvent('tommy-weedplant:client:openInfusionUI', function(data)
    OpenInfusionUI(data.tableId)
end)

RegisterNetEvent('tommy-weedplant:client:pickupInfusionTable', function(data)
    local tableId = data.tableId
    if not activeInfusionTables[tableId] then return end

    local ped = cache.ped
    lib.requestAnimDict('amb@world_human_hammering@male@base')
    TaskPlayAnim(ped, 'amb@world_human_hammering@male@base', 'base', 8.0, -8.0, 2000, 1, 0, false, false, false)

    if lib.progressBar({
        duration = 2000,
        label = 'Đang thu bàn tẩm...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
    }) then
        ClearPedTasks(ped)
        if GetResourceState('svc_runtime') == 'started' then
            exports['svc_runtime']:ExecuteServerEvent('tommy-weedplant:server:pickupInfusionTable', tableId)
        else
            TriggerServerEvent('tommy-weedplant:server:pickupInfusionTable', tableId)
        end
    else
        ClearPedTasks(ped)
    end
end)

RegisterNetEvent('tommy-weedplant:client:spawnInfusionTable', function(tableId, coords, owner, heading)
    SpawnInfusionTable(tableId, coords, owner, heading)
end)

RegisterNetEvent('tommy-weedplant:client:removeInfusionTable', function(tableId)
    RemoveInfusionTable(tableId)
end)

RegisterNetEvent('tommy-weedplant:client:syncInfusionTables', function(tables)
    for tableId, _ in pairs(activeInfusionTables) do RemoveInfusionTable(tableId) end
    for tableId, tableData in pairs(tables) do
        SpawnInfusionTable(tableId, tableData.coords, tableData.owner, tableData.heading)
    end
end)

RegisterNUICallback('closeInfusionUI', function(data, cb)
    CloseInfusionUI()
    cb('ok')
end)

RegisterNUICallback('startInfusion', function(data, cb)
    StartInfusion(data.budType, data.budAmount, data.ingredients)
    cb('ok')
end)

RegisterNUICallback('stopInfusion', function(data, cb)
    StopInfusion(false)
    cb('ok')
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    Wait(2000)
    TriggerServerEvent('tommy-weedplant:server:requestInfusionSync')
end)

CreateThread(function()
    Wait(2000)
    if LocalPlayer.state.isLoggedIn then
        TriggerServerEvent('tommy-weedplant:server:requestInfusionSync')
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for tableId, _ in pairs(activeInfusionTables) do RemoveInfusionTable(tableId) end
        if isInfusing then StopInfusion(true) end
    end
end)