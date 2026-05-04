local spawnedPeds   = {}
local npcHandles    = {}   -- [id] = ped handle
local npcBusyLocal  = {}   -- [id] = bool, mirror GlobalState per npc
local mechOnDuty    = false

-- Util: load model
local function loadModel(model)
    local m = (type(model) == 'string') and joaat(model) or model
    if not IsModelInCdimage(m) then return nil end
    RequestModel(m)
    while not HasModelLoaded(m) do Wait(0) end
    return m
end

-- Spawn NPC tại coords, freeze
local function spawnNpc(cfg)
    local c = cfg.coords
    local m = loadModel(cfg.model)
    if not m then return nil end
    local ped = CreatePed(4, m, c.x, c.y, c.z - 1.0, c.w or 0.0, false, false)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    table.insert(spawnedPeds, ped)
    return ped
end

-- Xây target cho 1 NPC
local function addNpcTarget(ped, cfg)
    exports.ox_target:addLocalEntity(ped, {{
        name     = ('DERO_npcautofix_%s'):format(cfg.id),
        icon     = 'fa-solid fa-wrench',
        label    = cfg.targetLabel or 'Sửa xe',
        distance = cfg.targetDistance or 2.0,
        groups   = cfg.allowedJobs or nil,
        canInteract = function(entity)
            if GlobalState['DERO_npcautofix_busy_' .. cfg.id] then return false end
            if mechOnDuty then return false end
            -- Kiểm tra có xe trong zone không (client-side, nhanh)
            local zone   = cfg.zone
            local center = zone.coords
            local radius = zone.radius
            local pool   = GetGamePool('CVehicle')
            for _, v in ipairs(pool) do
                if DoesEntityExist(v) and #(GetEntityCoords(v) - center) <= radius then
                    return true
                end
            end
            return false
        end,
        onSelect = function()
            if GlobalState['DERO_npcautofix_busy_' .. cfg.id] then return end
            TriggerServerEvent('DERO_npcautofix:requestRepair', cfg.id)
        end,
    }})
end

-- Spawn tất cả NPC
local function spawnAllNpcs()
    for _, cfg in ipairs(Config.NPCs) do
        if not (npcHandles[cfg.id] and DoesEntityExist(npcHandles[cfg.id])) then
            local ped = spawnNpc(cfg)
            if ped then
                npcHandles[cfg.id] = ped
                addNpcTarget(ped, cfg)
            end
        end
    end
end

-- Xóa tất cả NPC
local function deleteAllNpcs()
    for id, ped in pairs(npcHandles) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
        npcHandles[id] = nil
    end
end

-- Phản ứng thay đổi duty state
local function onDutyChanged(has)
    mechOnDuty = has or false
    if mechOnDuty then
        deleteAllNpcs()
    else
        spawnAllNpcs()
    end
end

-- Khởi tạo
CreateThread(function()
    Wait(1500)
    mechOnDuty = GlobalState[Config.MechanicOnDutyStateKey] or false
    if not mechOnDuty then
        spawnAllNpcs()
    end
end)

AddStateBagChangeHandler(Config.MechanicOnDutyStateKey, nil, function(_, _, value)
    onDutyChanged(value)
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    for _, ped in pairs(npcHandles) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
    for _, e in ipairs(spawnedPeds) do
        if DoesEntityExist(e) then DeleteEntity(e) end
    end
end)

local repairRunning = {}

local function loadAnimDict(dict)
    RequestAnimDict(dict)
    local t0 = GetGameTimer()
    while not HasAnimDictLoaded(dict) do
        if GetGameTimer() - t0 > 3000 then return false end
        Wait(0)
    end
    return true
end

local function movePedTo(ped, target, timeout, arriveThreshold)
    timeout         = timeout or 10000
    arriveThreshold = arriveThreshold or 1.6

    FreezeEntityPosition(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanRagdoll(ped, false)
    ClearPedTasksImmediately(ped)
    Wait(0)

    TaskGoStraightToCoord(ped, target.x, target.y, target.z, 2.0, timeout, -1.0, arriveThreshold)

    local t0 = GetGameTimer()
    while #(GetEntityCoords(ped) - target) > arriveThreshold do
        if GetGameTimer() - t0 > timeout then break end
        Wait(100)
    end
end

-- Server gọi client thực hiện animation + repair
RegisterNetEvent('DERO_npcautofix:doRepair', function(npcId, vehNet, price, repairType)
    -- Guard: không cho chạy 2 thread repair cùng lúc trên 1 NPC
    if repairRunning[npcId] then
        TriggerServerEvent('DERO_npcautofix:repairDone', npcId)
        return
    end
    repairRunning[npcId] = true

    local ped = npcHandles[npcId]
    if not ped or not DoesEntityExist(ped) then
        for _, cfg in ipairs(Config.NPCs) do
            if cfg.id == npcId then
                ped = spawnNpc(cfg)
                if ped then
                    npcHandles[npcId] = ped
                    addNpcTarget(ped, cfg)
                end
                break
            end
        end
        if not ped or not DoesEntityExist(ped) then
            repairRunning[npcId] = false
            TriggerServerEvent('DERO_npcautofix:repairDone', npcId)
            return
        end
    end

    local veh = NetToVeh(vehNet)
    if not DoesEntityExist(veh) then
        repairRunning[npcId] = false
        TriggerServerEvent('DERO_npcautofix:repairDone', npcId)
        return
    end

    local homeCfg
    for _, cfg in ipairs(Config.NPCs) do
        if cfg.id == npcId then homeCfg = cfg; break end
    end
    local homePos     = vec3(homeCfg.coords.x, homeCfg.coords.y, homeCfg.coords.z)
    local homeHeading = homeCfg.coords.w or 0.0

    CreateThread(function()
        -- Tính target đứng cạnh capo xe
        local bone   = GetEntityBoneIndexByName(veh, 'engine')
        local target = (bone ~= -1) and GetWorldPositionOfEntityBone(veh, bone) or
                       GetOffsetFromEntityInWorldCoords(veh, 0.0, 1.8, 0.0)

        -- Di chuyển NPC đến xe, có fallback teleport
        movePedTo(ped, target, 12000, 1.6)

        TaskTurnPedToFaceEntity(ped, veh, 800)
        Wait(900)

        -- Mở capo
        SetVehicleDoorOpen(veh, 4, false, false)

        ClearPedTasksImmediately(ped)
        Wait(0)
        if loadAnimDict('missmechanic') then
            TaskPlayAnim(ped, 'missmechanic', 'work2_base', 8.0, -8.0, -1, 1, 0.0, false, false, false)
        end

        local label = (repairType == 'full') and 'Thợ lưu động đang sửa xe...' or 'Thợ lưu động đang sửa động cơ...'
        lib.progressBar({
            duration  = 6000,
            label     = label,
            position  = 'bottom',
            canCancel = false,
            disable   = { move = true, car = true, combat = true },
        })

        ClearPedTasksImmediately(ped)
        Wait(0)

        -- Thực hiện repair
        if repairType == 'full' then
            local dirt = GetVehicleDirtLevel(veh)

            SetVehicleFixed(veh)
            SetVehicleDeformationFixed(veh)
            WashDecalsFromVehicle(veh, 1.0)
            RemoveDecalsFromVehicle(veh)

            SetVehicleEngineHealth(veh, 1000.0)
            SetVehicleBodyHealth(veh, 1000.0)
            SetVehiclePetrolTankHealth(veh, 1000.0)

            for i = 0, 7 do
                if IsVehicleTyreBurst(veh, i, false) then SetVehicleTyreFixed(veh, i) end
            end
            for i = 0, 7 do
                if not IsVehicleWindowIntact(veh, i) then FixVehicleWindow(veh, i) end
            end
            for i = 0, 5 do
                if IsVehicleDoorDamaged(veh, i) then SetVehicleDoorFixed(veh, i) end
            end

            SetVehicleUndriveable(veh, false)
            SetVehicleDirtLevel(veh, dirt)
        else
            SetVehicleEngineHealth(veh, 1000.0)
            SetVehicleDeformationFixed(veh)
        end

        SetVehicleDoorShut(veh, 4, false)

        -- Reset toàn bộ servicingData về 100
        local vehicleState = Entity(veh).state
        local currentServicing = vehicleState.servicingData
        if currentServicing and type(currentServicing) == 'table' then
            local resetData = {}
            for part, _ in pairs(currentServicing) do
                resetData[part] = 100
            end
            -- Gọi server set statebag (client không được set shared statebag trực tiếp)
            TriggerServerEvent('DERO_npcautofix:resetServicing', vehNet, resetData)
        end

        -- NPC về nhà
        movePedTo(ped, homePos, 12000, 1.2)

        SetEntityHeading(ped, homeHeading)
        ClearPedTasksImmediately(ped)
        FreezeEntityPosition(ped, true)

        local doneText = (repairType == 'full') and 'Đã sửa xe.' or 'Đã sửa động cơ.'
        lib.notify({
            title       = 'Thợ lưu động',
            description = ('%s Đã trừ $%d.'):format(doneText, price or 0),
            type        = 'success',
        })

        repairRunning[npcId] = false
        TriggerServerEvent('DERO_npcautofix:repairDone', npcId)
    end)
end)