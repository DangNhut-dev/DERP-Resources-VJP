local QBX = exports.qbx_core

local spawnedNPCs = {}
local currentVehicleNetId = nil

local function notifyError(msg)
    lib.notify({ type = 'error', description = msg })
end

local function notifySuccess(msg)
    lib.notify({ type = 'success', description = msg })
end

local function notifyInfo(msg)
    lib.notify({ type = 'inform', description = msg })
end

local function getReasonMsg(reason)
    if reason == 'notonduty' then return 'Bạn phải vào ca trực để lấy xe!' end
    if reason == 'nojob' then return 'Bạn không có quyền sử dụng dịch vụ này!' end
    if reason == 'invalidmodel' then return 'Xe không hợp lệ!' end
    if reason == 'nograde' then return 'Cấp bậc của bạn không đủ để lấy xe này!' end
    if reason == 'nospawn' then return 'Không có điểm spawn!' end
    if reason == 'spawnfail' then return 'Không thể spawn xe!' end
    if reason == 'notexist' then return 'Lỗi tạo xe!' end
    return 'Lỗi không xác định!'
end

local function openVehicleMenu(job)
    local jobData = Config.NPCs[job]
    if not jobData then
        notifyError('Bạn không có quyền sử dụng dịch vụ này!')
        return
    end

    local playerData = QBX:GetPlayerData()
    if not playerData.job.onduty then
        notifyError('Bạn phải vào ca trực để lấy xe!')
        return
    end

    if currentVehicleNetId then
        notifyError('Bạn đã có xe được spawn!')
        return
    end

    local playerGrade = playerData.job.grade and playerData.job.grade.level or 0
    local options = {}

    for _, vehicle in ipairs(jobData.vehicles) do
        local hasGrade = false
        if type(vehicle.grade) == 'table' then
            for _, g in ipairs(vehicle.grade) do
                if playerGrade == g then hasGrade = true break end
            end
        else
            if playerGrade >= (tonumber(vehicle.grade) or 0) then hasGrade = true end
        end

        if hasGrade then
            options[#options + 1] = {
                title = vehicle.label,
                description = vehicle.model,
                icon = 'car',
                onSelect = function()
                    requestSpawnVehicle(vehicle.model)
                end,
            }
        end
    end

    if #options == 0 then
        notifyError('Không có xe khả dụng cho cấp bậc của bạn!')
        return
    end

    lib.registerContext({
        id = 'tm_jobspawn_menu',
        title = 'Lấy Xe Công Vụ',
        options = options,
    })

    lib.showContext('tm_jobspawn_menu')
end

function requestSpawnVehicle(model)
    local result = lib.callback.await('TM-jobspawnvehicle:server:requestSpawn', false, model)

    if not result or not result.success then
        notifyError(getReasonMsg(result and result.reason))
        return
    end

    currentVehicleNetId = result.netId

    local timeout = 0
    local entity = NetworkGetEntityFromNetworkId(result.netId)
    while (not entity or entity == 0 or not DoesEntityExist(entity)) and timeout < 50 do
        Wait(100)
        entity = NetworkGetEntityFromNetworkId(result.netId)
        timeout = timeout + 1
    end

    if not entity or entity == 0 or not DoesEntityExist(entity) then
        notifyError('Xe không visible trong scope, thử lại!')
        currentVehicleNetId = nil
        return
    end

    local retry = 0
    while not NetworkHasControlOfEntity(entity) and retry < 20 do
        NetworkRequestControlOfEntity(entity)
        Wait(100)
        retry = retry + 1
    end

    SetVehicleNumberPlateText(entity, result.plate)
    SetVehicleHasBeenOwnedByPlayer(entity, true)
    SetVehicleNeedsToBeHotwired(entity, false)
    SetVehicleEngineOn(entity, true, true, false)

    pcall(function()
        exports[Config.FuelResource]:SetFuel(entity, 100.0)
    end)

    TaskWarpPedIntoVehicle(PlayerPedId(), entity, -1)

    TriggerEvent('qb-vehiclekeys:client:AddKeys', result.plate)

    notifySuccess('Xe đã được lấy thành công!')
end

local function returnVehicle()
    if not currentVehicleNetId then
        notifyError('Bạn không có xe nào được spawn!')
        return
    end

    local playerData = QBX:GetPlayerData()
    local job = playerData.job.name
    local jobData = Config.NPCs[job]

    if not jobData or not jobData.deletePoint then
        notifyError('Không tìm thấy zone trả xe!')
        return
    end

    local pedCoords = GetEntityCoords(PlayerPedId())
    local distZone = #(pedCoords - jobData.deletePoint)

    if distZone > Config.ReturnDistance then
        notifyError('Bạn phải vào zone trả xe!')
        return
    end

    local entity = NetworkGetEntityFromNetworkId(currentVehicleNetId)
    if entity and entity ~= 0 and DoesEntityExist(entity) then
        local vehCoords = GetEntityCoords(entity)
        if #(vehCoords - jobData.deletePoint) > Config.VehicleNearZoneDistance then
            notifyError('Xe của bạn phải ở trong bán kính ' .. Config.VehicleNearZoneDistance .. 'm từ zone trả xe!')
            return
        end
    end

    TriggerServerEvent('TM-jobspawnvehicle:server:returnVehicle')
    currentVehicleNetId = nil
end

CreateThread(function()
    for jobName, jobData in pairs(Config.NPCs) do
        local npcData = jobData.npc
        local hash = joaat(npcData.model)

        RequestModel(hash)
        while not HasModelLoaded(hash) do Wait(50) end

        local npc = CreatePed(4, hash, npcData.coords.x, npcData.coords.y, npcData.coords.z - 1.0, npcData.coords.w, false, true)

        SetEntityAsMissionEntity(npc, true, true)
        SetPedFleeAttributes(npc, 0, 0)
        SetPedDiesWhenInjured(npc, false)
        SetPedKeepTask(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        SetEntityInvincible(npc, true)
        FreezeEntityPosition(npc, true)

        spawnedNPCs[jobName] = npc

        exports.ox_target:addLocalEntity(npc, {
            {
                name = 'tm_jobspawn_' .. jobName,
                icon = 'fas fa-car',
                label = 'Lấy Xe',
                distance = 2.5,
                canInteract = function()
                    local pd = QBX:GetPlayerData()
                    return pd and pd.job and pd.job.name == jobName
                end,
                onSelect = function()
                    openVehicleMenu(jobName)
                end,
            },
        })

        SetModelAsNoLongerNeeded(hash)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        local playerData = QBX:GetPlayerData()

        if playerData and playerData.job and playerData.job.name then
            local job = playerData.job.name
            local jobData = Config.NPCs[job]

            if jobData and jobData.deletePoint and currentVehicleNetId then
                local pedCoords = GetEntityCoords(PlayerPedId())
                local dist = #(pedCoords - jobData.deletePoint)

                if dist < Config.ReturnDistance then
                    sleep = 0
                    lib.showTextUI('[E] Trả Xe', {
                        position = 'left-center',
                        icon = 'car',
                    })

                    if IsControlJustReleased(0, 38) then
                        lib.hideTextUI()
                        returnVehicle()
                    end
                else
                    lib.hideTextUI()
                end
            end
        end

        Wait(sleep)
    end
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function()
    currentVehicleNetId = nil
end)

RegisterNetEvent('QBCore:Client:SetDuty', function(duty)
    if not duty then
        currentVehicleNetId = nil
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    for _, npc in pairs(spawnedNPCs) do
        if DoesEntityExist(npc) then
            DeleteEntity(npc)
        end
    end

    lib.hideTextUI()
end)