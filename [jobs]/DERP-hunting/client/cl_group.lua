-- ============================
--   GROUP + JOB SYSTEM - CLIENT
-- ============================

local currentGroupId  = nil
local currentGroup    = nil
local currentMission  = nil
local jobActive       = false
local jobKills        = 0
local jobTarget       = 0
local textUIShowing   = false
local isGroupLeader   = false

local jobBlip         = nil

-- ============================
--   ZONE SPAWN STATE
-- ============================

local zoneSpawnActive = false
local spawnedNetIds   = {}
local spawnLock       = false
local totalSpawned    = 0
local enteredZone     = false

-- ============================
--   ZONE SPAWN HELPERS
-- ============================

local function getRandomPosInZone(zone)
    local origin = zone.coord
    local radius = zone.radius
    local maxR   = radius * 0.9
    local minR = math.min(radius * 0.1, maxR * 0.5)

    local playerCoord = GetEntityCoords(cache.ped)
    local attempts    = 0

    while attempts < 80 do
        local angle = math.rad(math.random(0, 359))
        local dist  = math.random(math.floor(minR), math.floor(maxR))
        local px    = origin.x + dist * math.cos(angle)
        local py    = origin.y + dist * math.sin(angle)

        if #(vector2(px, py) - vector2(playerCoord.x, playerCoord.y)) > 30.0 then
            local found, gz = GetGroundZFor_3dCoord(px, py, origin.z + 200.0, false)
            local pz        = found and gz or origin.z
            local safe, _   = GetSafeCoordForPed(px, py, pz, false, 16)
            if safe then
                return vector4(px, py, pz, math.random(0, 359) + 0.0)
            end
        end

        attempts = attempts + 1
        Citizen.Wait(0)
    end

    local angle = math.rad(math.random(0, 359))
    local dist  = math.floor(maxR * 0.5)
    return vector4(
        origin.x + dist * math.cos(angle),
        origin.y + dist * math.sin(angle),
        origin.z,
        math.random(0, 359) + 0.0
    )
end

local function pickMissionAnimal(mission)
    local pool = {}
    if mission.animals and #mission.animals > 0 then
        for _, modelName in ipairs(mission.animals) do
            for _, a in ipairs(Config.Animals) do
                if a.model == modelName then
                    table.insert(pool, a)
                    break
                end
            end
        end
    end
    if #pool == 0 then pool = Config.Animals end
    return pool[math.random(#pool)]
end

-- ============================
--   SPAWN 1 CON THU (leader only)
-- ============================

local function spawnOneAnimal(mission)
    if spawnLock then return false end
    spawnLock = true

    local animalCfg = pickMissionAnimal(mission)
    if not animalCfg then spawnLock = false; return false end

    local pos   = getRandomPosInZone(mission.zone)
    local model = animalCfg.hash

    RequestModel(model)
    local timeout = 0
    while not HasModelLoaded(model) and timeout < 100 do
        Citizen.Wait(10)
        timeout = timeout + 1
    end

    if not HasModelLoaded(model) then
        SetModelAsNoLongerNeeded(model)
        spawnLock = false
        return false
    end

    local ped = CreatePed(3, model, pos.x, pos.y, pos.z, pos.w, true, true)
    timeout = 0
    while not DoesEntityExist(ped) and timeout < 50 do
        Citizen.Wait(10)
        timeout = timeout + 1
    end

    if not DoesEntityExist(ped) then
        SetModelAsNoLongerNeeded(model)
        spawnLock = false
        return false
    end

    SetEntityAsMissionEntity(ped, true, true)
    SetModelAsNoLongerNeeded(model)

    NetworkRegisterEntityAsNetworked(ped)
    local netId = NetworkGetNetworkIdFromEntity(ped)

    timeout = 0
    while not NetworkDoesNetworkIdExist(netId) and timeout < 50 do
        Citizen.Wait(10)
        timeout = timeout + 1
    end

    if not NetworkDoesNetworkIdExist(netId) then
        DeleteEntity(ped)
        spawnLock = false
        return false
    end

    SetNetworkIdExistsOnAllMachines(netId, true)
    SetNetworkIdCanMigrate(netId, false)

    -- Hành vi tự nhiên
    SetPedFleeAttributes(ped, 2, true)
    SetPedCombatAttributes(ped, 46, true)
    SetPedSeeingRange(ped, 40.0)
    SetPedHearingRange(ped, 30.0)
    TaskWanderStandard(ped, 10.0, 10)

    -- Blip chỉ tạo trên client của leader, members sẽ tạo qua zoneAnimalRegistered
    if Config.spawnedAnimalsBlips then
        local blip = AddBlipForEntity(ped)
        SetBlipSprite(blip, Config.AnimalBlip.sprite)
        SetBlipColour(blip, Config.AnimalBlip.color)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Thú Săn")
        EndTextCommandSetBlipName(blip)
    end

    table.insert(spawnedNetIds, netId)
    totalSpawned = totalSpawned + 1

    TriggerServerEvent('DERP-hunting:server:registerZoneAnimal', netId, animalCfg.model, mission.zone)

    spawnLock = false
    return true
end

-- Spawn đúng số lượng nhiệm vụ, chỉ khi vào zone
local function spawnAllMissionAnimals(mission)
    local target = mission.targetKills
    zoneSpawnActive = true

    Citizen.CreateThread(function()
        while totalSpawned < target and zoneSpawnActive do
            if not spawnLock then
                spawnOneAnimal(mission)
            end
            Citizen.Wait(600)
        end
    end)
end

-- Theo dõi khi leader vào zone thì bắt đầu spawn
local function startZoneEntryWatch(mission)
    Citizen.CreateThread(function()
        while jobActive and not enteredZone do
            local dist = #(GetEntityCoords(cache.ped) - mission.zone.coord)
            if dist <= mission.zone.radius then
                enteredZone = true
                if isGroupLeader then
                    spawnAllMissionAnimals(mission)
                end
            end
            Citizen.Wait(1000)
        end
    end)
end

local function doStartZoneSpawn(mission, isLeader)
    zoneSpawnActive = false
    spawnedNetIds   = {}
    spawnLock       = false
    totalSpawned    = 0
    enteredZone     = false
    startZoneEntryWatch(mission)
end

local function doStopZoneSpawn(isLeader)
    zoneSpawnActive = false
    enteredZone     = false
    if isLeader then
        for _, netId in ipairs(spawnedNetIds) do
            if NetworkDoesNetworkIdExist(netId) then
                local ped = NetToPed(netId)
                if DoesEntityExist(ped) then DeleteEntity(ped) end
            end
        end
    end
    spawnedNetIds = {}
    spawnLock     = false
    totalSpawned  = 0
end

-- ============================
--   NHAN NETID TU LEADER (members add blip + target)
-- ============================

RegisterNetEvent('DERP-hunting:client:zoneAnimalRegistered')
AddEventHandler('DERP-hunting:client:zoneAnimalRegistered', function(netId)
    Citizen.CreateThread(function()
        local timeout = 0
        while not NetworkDoesNetworkIdExist(netId) and timeout < 100 do
            Citizen.Wait(50)
            timeout = timeout + 1
        end
        if not NetworkDoesNetworkIdExist(netId) then return end

        local ped = NetToPed(netId)
        timeout   = 0
        while not DoesEntityExist(ped) and timeout < 100 do
            Citizen.Wait(50)
            ped     = NetToPed(netId)
            timeout = timeout + 1
        end
        if not DoesEntityExist(ped) then return end

        -- Members tạo blip riêng
        if not isGroupLeader and Config.spawnedAnimalsBlips then
            local blip = AddBlipForEntity(ped)
            SetBlipSprite(blip, Config.AnimalBlip.sprite)
            SetBlipColour(blip, Config.AnimalBlip.color)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Thú Săn")
            EndTextCommandSetBlipName(blip)
        end

        putQbTargetOnEntity(ped)
    end)
end)

-- ============================
--   ZONE VISUALS
--   Chỉ GPS route đến tâm nhiệm vụ, không có marker zone
-- ============================

-- local jobRadiusBlip = nil

local function createJobZoneVisuals(mission)
    if not mission or not mission.zone then return end
    local zone = mission.zone

    if jobBlip then RemoveBlip(jobBlip) end
    -- if jobRadiusBlip then RemoveBlip(jobRadiusBlip) end

    jobBlip = AddBlipForCoord(zone.coord.x, zone.coord.y, zone.coord.z)
    SetBlipSprite(jobBlip, 141)
    SetBlipColour(jobBlip, 1)
    SetBlipScale(jobBlip, 0.8)
    SetBlipAsShortRange(jobBlip, true)
    -- SetBlipRoute(jobBlip, true)
    -- SetBlipRouteColour(jobBlip, 18)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(zone.name or 'Khu vực săn bắn')
    EndTextCommandSetBlipName(jobBlip)

    -- jobRadiusBlip = AddBlipForRadius(zone.coord.x, zone.coord.y, zone.coord.z, zone.radius)
    -- SetBlipColour(jobRadiusBlip, 2)
    -- SetBlipAlpha(jobRadiusBlip, 64)

    SetNewWaypoint(zone.coord.x, zone.coord.y)
end

local function removeJobZoneVisuals()
    if jobBlip then
        -- SetBlipRoute(jobBlip, false)
        RemoveBlip(jobBlip)
        jobBlip = nil
    end
    -- if jobRadiusBlip then
    --     RemoveBlip(jobRadiusBlip)
    --     jobRadiusBlip = nil
    -- end
    -- DeleteWaypoint()
end

-- ============================
--   TEXT UI
-- ============================

local function showJobTextUI()
    local label = currentMission
        and (currentMission.label .. ': ' .. jobKills .. '/' .. jobTarget)
        or  (jobKills .. '/' .. jobTarget)
    lib.showTextUI(label, { position = 'left-center' })
    textUIShowing = true
end

-- ============================
--   GROUP STATE EVENTS
-- ============================

RegisterNetEvent('DERP-hunting:client:groupUpdated')
AddEventHandler('DERP-hunting:client:groupUpdated', function(gid, groupData)
    currentGroupId = gid
    currentGroup   = groupData
    if groupData then
        isGroupLeader = (groupData.leader == GetPlayerServerId(PlayerId()))
    end
end)

RegisterNetEvent('DERP-hunting:client:groupDisbanded')
AddEventHandler('DERP-hunting:client:groupDisbanded', function()
    if jobActive then
        doStopZoneSpawn(isGroupLeader)
        removeJobZoneVisuals()
        if textUIShowing then lib.hideTextUI(); textUIShowing = false end
    end
    currentGroupId    = nil
    currentGroup      = nil
    currentMission    = nil
    isGroupLeader     = false
    jobActive         = false
    _G.currentMission = nil
    -- hideHuntingAreaBlips()
end)

-- ============================
--   JOB STATE EVENTS
-- ============================

RegisterNetEvent('DERP-hunting:client:jobStarted')
AddEventHandler('DERP-hunting:client:jobStarted', function(kills, target, mission, isLeader)
    jobActive         = true
    jobKills          = kills
    jobTarget         = target
    currentMission    = mission
    isGroupLeader     = isLeader or false
    _G.currentMission = mission

    showJobTextUI()
    createJobZoneVisuals(mission)
    doStartZoneSpawn(mission, isGroupLeader)
    -- showHuntingAreaBlips()
end)

RegisterNetEvent('DERP-hunting:client:jobKillUpdated')
AddEventHandler('DERP-hunting:client:jobKillUpdated', function(kills, target)
    jobKills  = kills
    jobTarget = target
    if jobActive then showJobTextUI() end
end)

RegisterNetEvent('DERP-hunting:client:jobEnded')
AddEventHandler('DERP-hunting:client:jobEnded', function()
    doStopZoneSpawn(isGroupLeader)
    removeJobZoneVisuals()
    if textUIShowing then lib.hideTextUI(); textUIShowing = false end
    jobActive         = false
    jobKills          = 0
    currentMission    = nil
    _G.currentMission = nil
    isGroupLeader     = false
    -- hideHuntingAreaBlips()
end)

RegisterNetEvent('DERP-hunting:client:stopZoneSpawn')
AddEventHandler('DERP-hunting:client:stopZoneSpawn', function()
    doStopZoneSpawn(isGroupLeader)
end)

-- ============================
--   MENU CHINH TAI NPC
-- ============================

function openNpcMainMenu()
    local options = {}

    if not currentGroupId then
        table.insert(options, {
            title       = 'Tạo Nhóm Săn',
            description = 'Phải có nhóm mới bắt đầu săn (Tối đa ' .. Config.Job.maxGroupSize .. ' thành viên)',
            icon        = 'fas fa-users',
            onSelect    = function() TriggerServerEvent('DERP-hunting:server:createGroup') end,
        })
        table.insert(options, {
            title       = 'Tham gia nhóm',
            description = 'Tham gia nhóm của người khác',
            icon        = 'fas fa-user-plus',
            onSelect    = function() promptJoinGroup() end,
        })
    else
        local memberCount = currentGroup and #currentGroup.members or 0

        table.insert(options, {
            title       = 'Thông tin nhóm',
            description = 'ID: ' .. currentGroupId .. ' | Thành viên: ' .. memberCount .. '/' .. Config.Job.maxGroupSize,
            icon        = 'fas fa-info-circle',
            readOnly    = true,
        })

        if currentMission then
            table.insert(options, {
                title       = 'Nhiệm vụ hiện tại',
                description = currentMission.label .. ' | ' .. jobKills .. '/' .. jobTarget .. ' con | Thưởng: $' .. currentMission.reward,
                icon        = 'fas fa-crosshairs',
                readOnly    = true,
            })
        end

        if isGroupLeader and not jobActive then
            table.insert(options, {
                title       = 'Nhận nhiệm vụ săn bắn',
                description = 'Nhận vị trí săn bắn để bắt đầu săn.',
                icon        = 'fas fa-dice',
                onSelect    = function() TriggerServerEvent('DERP-hunting:server:acceptJob') end,
            })
        end

        if isGroupLeader and jobActive and currentGroup and currentGroup.done then
            table.insert(options, {
                title       = 'Trả nhiệm vụ',
                description = 'Đã hoàn thành! Nhận $' .. (currentMission and currentMission.reward or '?') .. '/thành viên',
                icon        = 'fas fa-flag-checkered',
                onSelect    = function() TriggerServerEvent('DERP-hunting:server:submitJob') end,
            })
        end

        table.insert(options, {
            title       = 'Rời nhóm',
            description = 'Rời khỏi nhóm hiện tại',
            icon        = 'fas fa-sign-out-alt',
            onSelect    = function() TriggerServerEvent('DERP-hunting:server:leaveGroup') end,
        })
    end

    table.insert(options, {
        title       = 'Mua dụng cụ săn bắn',
        description = 'Xem cửa hàng săn bắn',
        icon        = 'fas fa-store',
        onSelect    = function() openShopMenu() end,
    })

    lib.registerContext({
        id      = 'hunting_npc_main',
        title   = Config.ShopNPC.targetLabel,
        options = options,
    })
    lib.showContext('hunting_npc_main')
end

function promptJoinGroup()
    local input = lib.inputDialog('Tham gia nhóm', {
        { type = 'number', label = 'ID nhóm', required = true, min = 1 },
    })
    if not input or not input[1] then return end
    TriggerServerEvent('DERP-hunting:server:joinGroup', input[1])
end

-- ============================
--   SYNC KHI LOGIN
-- ============================

Citizen.CreateThread(function()
    while not LocalPlayer.state.isLoggedIn do
        Citizen.Wait(500)
    end
    Citizen.Wait(1000)
    TriggerServerEvent('DERP-hunting:server:requestGroupInfo')
end)