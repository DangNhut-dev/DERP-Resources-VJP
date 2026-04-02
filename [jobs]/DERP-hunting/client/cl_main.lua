local inzone  = false
local Zones   = {}

local baitCooldown         = Config.BaitCooldown
local deployedBaitCooldown = 0

local spawningTime       = Config.SpawningTimer
local startSpawningTimer = 0

local spawnedAnimalsBlips       = Config.spawnedAnimalsBlips
local spawnedAnimalsBlipsConfig = Config.AnimalBlip

-- Global sync với cl_group.lua
currentMission = nil

-- ============================
--   ZONE HELPERS
-- ============================

function AddCircleZone(name, llegal, center, radius, options)
    Zones[name] = CircleZone:Create(center, radius, options)
    table.insert(Zones[name], { llegal = llegal })
end

function isPedInHuntingZone()
    local coord = GetEntityCoords(PlayerPedId())
    local legl
    for _, zone in pairs(Zones) do
        if zone:isPointInside(coord) then
            return { inzone = true, llegal = zone[1].llegal }
        else
            legl = zone[1].llegal
        end
    end
    return { inzone = false, llegal = legl }
end

local huntingAreaBlips = {}

function showHuntingAreaBlips()
    for _, mission in ipairs(Config.Job.missions) do
        if mission.zone then
            local blip = AddBlipForCoord(mission.zone.coord.x, mission.zone.coord.y, mission.zone.coord.z)
            SetBlipSprite(blip, 141)
            SetBlipColour(blip, 4)
            SetBlipScale(blip, 0.8)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(mission.zone.name or mission.label)
            EndTextCommandSetBlipName(blip)

            table.insert(huntingAreaBlips, blip)
        end
    end
end

function hideHuntingAreaBlips()
    for _, blip in ipairs(huntingAreaBlips) do
        RemoveBlip(blip)
    end
    huntingAreaBlips = {}
end

-- ============================
--   INIT
-- ============================

function initBlips()
    -- initSellspotsQbTargets(Config.SellSpots)
    createCustomBlips(Config.SellSpots)
    -- createCustomBlips(Config.HuntingArea)
end

Citizen.CreateThread(function()
    while not LocalPlayer.state.isLoggedIn do
        Citizen.Wait(500)
    end
    Citizen.Wait(1000)
    initBlips()
    if Config.SlughterEveryAnimal then
        putQbTargetAllOnAnimals()
    end
end)

-- ============================
--   SLAUGHTER
--   Gửi netId thay vì inJobZone bool để server validate phía server
-- ============================

-- Slaughter lock chống spam
local slaughterLock = false

AddEventHandler('DERP-hunting:client:slaughterAnimal', function(entity)
    if slaughterLock then return end

    local model  = GetEntityModel(entity)
    local animal = getAnimalMatch(model)
    if not model or not animal then return end

    -- Kiểm tra thú có bị xe cán không (không cho lột da)
    if killedByVehicle and killedByVehicle[entity] == true then
        lib.notify({
            type        = 'error',
            description = 'Bạn phải dùng súng săn để hạ thú! Không thể lột da thú bị xe cán.',
            duration    = 5000,
        })
        return
    end

    local netId = nil
    if NetworkGetEntityIsNetworked(entity) then
        netId = NetworkGetNetworkIdFromEntity(entity)
    end

    -- Gửi lên server check dao trước
    TriggerServerEvent('DERP-hunting:server:checkKnife', animal, entity, netId)
end)

-- Server xác nhận có dao → client bắt đầu animation + progress
RegisterNetEvent('DERP-hunting:client:startSkinning')
AddEventHandler('DERP-hunting:client:startSkinning', function(entity, animalData, netId)
    if slaughterLock then return end
    slaughterLock = true

    local animal = animalData

    ClearPedTasks(PlayerPedId())
    ToggleSlaughterAnimation(true, entity)

    lib.progressBar({
        duration     = Config.SlaughteringSpeed,
        label        = 'Đang Lột Da...',
        useWhileDead = false,
        canCancel    = false,
        disable      = { move = true, car = true, mouse = true, combat = true },
    })

    ToggleSlaughterAnimation(false, 0)

    local multiplier = AnimalLootMultiplier:read(entity) or 'default'
    TriggerServerEvent('DERP-hunting:server:AddItem', animal, entity, multiplier, netId)

    slaughterLock = false
    Citizen.Wait(100)
end)

AddEventHandler('DERP-hunting:client:sellREQ', function()
    TriggerServerEvent('DERP-hunting:server:sellmeat')
end)

RegisterNetEvent('DERP-hunting:client:ForceRemoveAnimalEntity')
AddEventHandler('DERP-hunting:client:ForceRemoveAnimalEntity', function(entity)
    DeleteEntity(entity)
    AnimalLootMultiplier[entity] = nil
end)

-- ============================
--   BAIT (giữ nguyên cho non-job hunting)
-- ============================

RegisterNetEvent('DERP-hunting:client:useBait')
AddEventHandler('DERP-hunting:client:useBait', function()
    local plyPed        = PlayerPedId()
    local coord         = GetEntityCoords(plyPed)
    local inHuntingZone = isPedInHuntingZone()

    if not inHuntingZone.inzone then
        lib.notify({ type = 'error', description = 'Phải ở trong khu vực săn bắn!' })
        return
    end

    if deployedBaitCooldown > 0 then
        lib.notify({ type = 'error', description = 'Cooldown! Còn ' .. (deployedBaitCooldown / 1000) .. 's' })
        return
    end

    ClearPedTasks(plyPed)
    TaskStartScenarioInPlace(plyPed, 'WORLD_HUMAN_GARDENER_PLANT', 0, true)

    lib.progressBar({
        duration     = Config.BaitPlacementSpeed,
        label        = 'Đặt mồi nhử...',
        useWhileDead = false,
        canCancel    = false,
        disable      = { move = true, car = false, mouse = false, combat = true },
    })

    ClearPedTasks(plyPed)
    createThreadAnimalSpawningTimer(coord, inHuntingZone.llegal)
end)

function createThreadAnimalSpawningTimer(coord, was_llegal)
    Citizen.CreateThread(function()
        local spawnZone   = currentMission and currentMission.zone or nil
        local outPosition = getSpawnLocationInZone(coord, spawnZone)

        startSpawningTimer = spawningTime
        while startSpawningTimer > 0 do
            startSpawningTimer = startSpawningTimer - 1000
            Wait(1000)
        end

        createThreadBaitCooldown()

        local missionAnimals = currentMission and currentMission.animals or {}
        TriggerServerEvent('DERP-hunting:server:choiceWhichAnimalToSpawn', coord, outPosition, was_llegal, missionAnimals)
    end)
end

RegisterNetEvent('DERP-hunting:client:spawnAnimal')
AddEventHandler('DERP-hunting:client:spawnAnimal', function(coord, outPosition, C_animal, was_llegal)
    Citizen.CreateThread(function()
        local model = C_animal.hash
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(10)
        end

        local baitAnimal = CreatePed(3, model, outPosition.x, outPosition.y, outPosition.z, outPosition.w, true, true)

        local timeout = 0
        while not DoesEntityExist(baitAnimal) and timeout < 50 do
            Citizen.Wait(10)
            timeout = timeout + 1
        end

        if not DoesEntityExist(baitAnimal) then
            SetModelAsNoLongerNeeded(model)
            return
        end

        SetEntityAsMissionEntity(baitAnimal, true, true)
        SetModelAsNoLongerNeeded(model)

        if spawnedAnimalsBlips then
            local blip = AddBlipForEntity(baitAnimal)
            SetBlipSprite(blip, spawnedAnimalsBlipsConfig.sprite)
            SetBlipColour(blip, spawnedAnimalsBlipsConfig.color)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('Thú săn')
            EndTextCommandSetBlipName(blip)
        end

        TriggerServerEvent('DERP-hunting:server:removeBaitFromPlayerInventory')
        createThreadAnimalTraveledDistanceToBaitTracker(coord, baitAnimal)
        createDespawnThread(baitAnimal, was_llegal, coord)
        putQbTargetOnEntity(baitAnimal)
    end)
end)

RegisterNetEvent('DERP-hunting:client:spawnanim')
AddEventHandler('DERP-hunting:client:spawnanim', function(model, was_llegal)
    model = (tonumber(model) ~= nil and tonumber(model) or GetHashKey(model))
    local playerPed = PlayerPedId()
    local coords    = GetEntityCoords(playerPed)
    local forward   = GetEntityForwardVector(playerPed)
    local x, y, z  = table.unpack(coords + forward * 1.0)

    Citizen.CreateThread(function()
        RequestModel(model)
        while not HasModelLoaded(model) do Citizen.Wait(1) end
        local baitAnimal = CreatePed(5, model, x, y, z, 0.0, true, false)
        createDespawnThread(baitAnimal, was_llegal)
    end)
end)

RegisterNetEvent('DERP-hunting:client:clearTask')
AddEventHandler('DERP-hunting:client:clearTask', function()
    ClearPedTasks(PlayerPedId())
end)

function createThreadBaitCooldown()
    Citizen.CreateThread(function()
        deployedBaitCooldown = baitCooldown
        while deployedBaitCooldown > 0 do
            deployedBaitCooldown = deployedBaitCooldown - 1000
            Wait(1000)
        end
    end)
end

-- ============================
--   SHOOTING PROTECTION
-- ============================

local hasMusket = false

function disablePlayerFiring()
    DisableControlAction(0, 24)
    DisableControlAction(0, 69)
    DisableControlAction(0, 70)
    DisableControlAction(0, 92)
    DisableControlAction(0, 114)
    DisableControlAction(0, 257)
    DisableControlAction(0, 331)
    DisableControlAction(0, 282)
    DisableControlAction(0, 24, true)
    DisableControlAction(0, 47, true)
    DisableControlAction(0, 58, true)
    DisablePlayerFiring(PlayerPedId(), true)
end

local function blockShooting()
    Citizen.CreateThread(function()
        while hasMusket do
            Citizen.Wait(1)
            local aiming, targetPed = GetEntityPlayerIsFreeAimingAt(PlayerId())
            local PedType = GetPedType(targetPed)
            disablePlayerFiring()
            if aiming then
                if DoesEntityExist(targetPed) and IsEntityAPed(targetPed) and (PedType == 4 or PedType == 5) then
                    DisablePlayerFiring(PlayerId(), true)
                    disablePlayerFiring()
                end
            else
                if IsPedShooting(PlayerPedId()) then
                    SetCurrentPedWeapon(PlayerPedId(), 'weapon_unarmed', true)
                else
                    hasMusket = false
                end
            end
        end
    end)
end

if Config.ShootingProtection then
    local hashTable = {}
    for _, weapon in pairs(Config.ProtectedWeapons) do
        table.insert(hashTable, GetHashKey(weapon))
    end
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(50)
            for _, weaponHash in pairs(hashTable) do
                if not hasMusket and GetSelectedPedWeapon(PlayerPedId()) == weaponHash then
                    hasMusket = true
                    blockShooting()
                end
            end
        end
    end)
end