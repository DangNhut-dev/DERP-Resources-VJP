local QBX = exports.qbx_core
local currentGarage = nil
local inStoreZone = false
local isInVehicle = false
local isUIOpen = false
local spawnedVehicles = {}
local spawnedNPCs = {}

local isPreviewMode = false
local previewVehicle = nil
local previewCam = nil
local previewVehicleData = nil
local spawnedBlips = {}
local pendingMods = {}
local PlayerData = QBX:GetPlayerData()

-- Track xe đang được spawn từ garage để watchdog không bị overwrite logic
local recentGarageSpawns = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBX:GetPlayerData()
end)

local function SafeSetVehicleProperties(vehicle, props, forcePlate)
    if not vehicle or not props then return false end

    local m = type(props) == 'string' and json.decode(props) or props
    if not m or type(m) ~= 'table' then return false end

    local originalPlate = forcePlate or GetVehicleNumberPlateText(vehicle)
    if originalPlate then
        originalPlate = string.gsub(originalPlate, '^%s*(.-)%s*$', '%1')
    end

    local safeMods = {}
    for k, v in pairs(m) do
        safeMods[k] = v
    end
    safeMods.plate = originalPlate

    local ok = pcall(function()
        lib.setVehicleProperties(vehicle, safeMods)
    end)

    if originalPlate and DoesEntityExist(vehicle) then
        SetVehicleNumberPlateText(vehicle, originalPlate)
    end

    return ok
end

local function HasVehicleKeys(vehicle)
    local ok, result = pcall(function()
        return exports.qbx_vehiclekeys:HasKeys(vehicle)
    end)
    return ok and result == true
end

local function HasJobAccess(garage)
    if not garage then return false end

    if garage.type == 'public' then
        return true
    end

    if garage.type == 'job' then
        if not garage.job then return false end
        if not PlayerData or not PlayerData.job then return false end

        return PlayerData.job.name == garage.job
    end

    return false
end

local function GetVehicleStatus(vehicle)
    local status = {
        doors = {},
        windows = {},
        tyres = {},
        extras = {}
    }

    for i = 0, 7 do
        if DoesVehicleHaveDoor(vehicle, i) then
            local isBroken = IsVehicleDoorDamaged(vehicle, i)
            status.doors[tostring(i)] = {
                open = GetVehicleDoorAngleRatio(vehicle, i) > 0.0,
                broken = isBroken
            }
        end
    end

    for i = 0, 7 do
        local isIntact = IsVehicleWindowIntact(vehicle, i)
        status.windows[tostring(i)] = not isIntact
    end

    for i = 0, 7 do
        local burstState = IsVehicleTyreBurst(vehicle, i, false)
        local completelyGone = IsVehicleTyreBurst(vehicle, i, true)
        status.tyres[tostring(i)] = {
            burst = burstState,
            gone = completelyGone
        }
    end

    for i = 0, 14 do
        if DoesExtraExist(vehicle, i) then
            status.extras[tostring(i)] = IsVehicleExtraTurnedOn(vehicle, i)
        end
    end

    return status
end

local function ApplyVehicleStatus(vehicle, status)
    if not status or not vehicle or not DoesEntityExist(vehicle) then return end

    local statusData = type(status) == 'string' and json.decode(status) or status
    if not statusData then return end

    if NetworkGetEntityIsNetworked(vehicle) then
        NetworkRequestControlOfEntity(vehicle)
        local ctrlWait = 0
        while not NetworkHasControlOfEntity(vehicle) and ctrlWait < 500 do
            Wait(50)
            ctrlWait = ctrlWait + 50
            NetworkRequestControlOfEntity(vehicle)
        end
    end

    SetVehicleTyresCanBurst(vehicle, true)

    if statusData.doors then
        for doorId, doorData in pairs(statusData.doors) do
            local id = tonumber(doorId)
            if doorData.broken then
                SetVehicleDoorBroken(vehicle, id, true)
            end
            if doorData.open then
                SetVehicleDoorOpen(vehicle, id, false, false)
            end
        end
    end

    if statusData.windows then
        for windowId, isBroken in pairs(statusData.windows) do
            if isBroken then
                SmashVehicleWindow(vehicle, tonumber(windowId))
            end
        end
    end

    if statusData.tyres then
        for tyreId, tyreData in pairs(statusData.tyres) do
            local tid = tonumber(tyreId)
            if tyreData.gone then
                SetVehicleTyreBurst(vehicle, tid, true, 1000.0)
            elseif tyreData.burst then
                SetVehicleTyreBurst(vehicle, tid, false, 990.0)
            end
        end
    end

    if statusData.extras then
        for extraId, isOn in pairs(statusData.extras) do
            SetVehicleExtra(vehicle, tonumber(extraId), not isOn)
        end
    end
end

local function FindAvailableSpawnPoint(spawnPoints)
    for _, spawnPoint in ipairs(spawnPoints) do
        local coords = vector3(spawnPoint.x, spawnPoint.y, spawnPoint.z)

        local isOccupied = false
        local nearbyVehicles = GetGamePool('CVehicle')

        for _, vehicle in ipairs(nearbyVehicles) do
            local vehicleCoords = GetEntityCoords(vehicle)
            if #(vehicleCoords - coords) < 2.5 then
                isOccupied = true
                break
            end
        end

        for netId, _ in pairs(spawnedVehicles) do
            if NetworkDoesNetworkIdExist(netId) then
                local veh = NetworkGetEntityFromNetworkId(netId)
                if DoesEntityExist(veh) then
                    local vehCoords = GetEntityCoords(veh)
                    if #(vehCoords - coords) < 2.5 then
                        isOccupied = true
                        break
                    end
                end
            else
                spawnedVehicles[netId] = nil
            end
        end

        if not isOccupied then
            return spawnPoint
        end
    end

    return nil
end

local function CalculateCameraPosition(vehicleSpawn)
    local vehCoords = vector3(vehicleSpawn.x, vehicleSpawn.y, vehicleSpawn.z)
    local heading = vehicleSpawn.w

    local rad = math.rad(heading)

    local settings = Config.CameraSettings or {
        forwardOffset = 4.5,
        rightOffset = 3.0,
        heightOffset = 2.5,
        lookAtHeight = 1.0
    }

    local camX = vehCoords.x + (-math.sin(rad) * settings.forwardOffset) + (math.cos(rad) * settings.rightOffset)
    local camY = vehCoords.y + (math.cos(rad) * settings.forwardOffset) + (math.sin(rad) * settings.rightOffset)
    local camZ = vehCoords.z + settings.heightOffset

    local pointAtX = vehCoords.x
    local pointAtY = vehCoords.y
    local pointAtZ = vehCoords.z + settings.lookAtHeight

    return {
        coords = vector3(camX, camY, camZ),
        pointAt = vector3(pointAtX, pointAtY, pointAtZ)
    }
end

local function CreatePreviewCamera(garagePreview)
    if previewCam then
        RenderScriptCams(false, true, 500, true, true)
        DestroyCam(previewCam, false)
    end

    local cameraConfig = garagePreview.camera
    if not cameraConfig then
        cameraConfig = CalculateCameraPosition(garagePreview.vehicle)
    end

    local camCoords = cameraConfig.coords
    local pointAt = cameraConfig.pointAt

    previewCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(previewCam, camCoords.x, camCoords.y, camCoords.z)
    PointCamAtCoord(previewCam, pointAt.x, pointAt.y, pointAt.z)
    SetCamActive(previewCam, true)
    RenderScriptCams(true, true, 500, true, true)
end

local function DestroyPreviewCamera()
    if previewCam then
        RenderScriptCams(false, true, 500, true, true)
        DestroyCam(previewCam, false)
        previewCam = nil
    end
end

local function SpawnPreviewVehicle(vehicleData, garagePreview)
    if previewVehicle and DoesEntityExist(previewVehicle) then
        DeleteEntity(previewVehicle)
    end

    local model = vehicleData.vehicle
    local hash = GetHashKey(model)

    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(10)
    end

    local spawnPos = garagePreview.vehicle
    previewVehicle = CreateVehicle(hash, spawnPos.x, spawnPos.y, spawnPos.z, spawnPos.w, false, false)

    local timeout = 0
    while not DoesEntityExist(previewVehicle) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end

    if not DoesEntityExist(previewVehicle) then
        return
    end

    SetEntityAlpha(previewVehicle, 0, false)
    ResetEntityAlpha(previewVehicle)
    SetEntityCollision(previewVehicle, false, false)
    SetEntityInvincible(previewVehicle, true)
    FreezeEntityPosition(previewVehicle, true)
    SetVehicleDoorsLocked(previewVehicle, 2)
    SetVehicleNumberPlateText(previewVehicle, vehicleData.plate)

    if vehicleData.mods then
        local mods = type(vehicleData.mods) == 'string' and json.decode(vehicleData.mods) or vehicleData.mods
        if mods then
            SafeSetVehicleProperties(previewVehicle, mods)
        end
    end

    Wait(100)
    ApplyVehicleStatus(previewVehicle, vehicleData.status)

    if vehicleData.engine then
        SetVehicleEngineHealth(previewVehicle, vehicleData.engine + 0.0)
    end

    if vehicleData.body then
        SetVehicleBodyHealth(previewVehicle, vehicleData.body + 0.0)
    end

    SetModelAsNoLongerNeeded(hash)
    CreatePreviewCamera(garagePreview)
    previewVehicleData = vehicleData
end

local function DestroyPreview()
    isPreviewMode = false

    if previewVehicle and DoesEntityExist(previewVehicle) then
        DeleteEntity(previewVehicle)
        previewVehicle = nil
    end

    DestroyPreviewCamera()
    previewVehicleData = nil
end

local function ApplyAllVehicleProperties(vehicle, vehicleData)
    if not DoesEntityExist(vehicle) then return end

    if NetworkGetEntityIsNetworked(vehicle) then
        NetworkRequestControlOfEntity(vehicle)
        local ctrlWait = 0
        while not NetworkHasControlOfEntity(vehicle) and ctrlWait < 1000 do
            Wait(50)
            ctrlWait = ctrlWait + 50
            NetworkRequestControlOfEntity(vehicle)
        end
    end

    if vehicleData.mods then
        local mods = type(vehicleData.mods) == 'string' and json.decode(vehicleData.mods) or vehicleData.mods
        if mods and type(mods) == 'table' then
            mods.engineHealth = vehicleData.engine or mods.engineHealth
            mods.bodyHealth   = vehicleData.body   or mods.bodyHealth
            mods.fuelLevel    = vehicleData.fuel   or mods.fuelLevel
            SafeSetVehicleProperties(vehicle, mods, vehicleData.plate)
        end
    end

    Wait(150)

    if vehicleData.engine then
        SetVehicleEngineHealth(vehicle, vehicleData.engine + 0.0)
    end

    if vehicleData.body then
        SetVehicleBodyHealth(vehicle, vehicleData.body + 0.0)
    end

    if vehicleData.fuel then
        Entity(vehicle).state:set('fuel', vehicleData.fuel + 0.0, true)
    end

    Wait(100)

    if vehicleData.status then
        ApplyVehicleStatus(vehicle, vehicleData.status)
    end

    if vehicleData.lockState then
        SetVehicleDoorsLocked(vehicle, vehicleData.lockState)
    end
end

-- ============================================================
-- SPAWN VEHICLE (server-spawned, client apply + aggressive watchdog)
-- ============================================================
local function SpawnVehicle(vehicleData, spawnPoint, garageName)
    if not vehicleData.serverSpawned or not vehicleData.netId then
        exports.qbx_core:Notify('Lỗi: server không spawn được xe!', 'error')
        return
    end

    local netId = vehicleData.netId
    local plate = vehicleData.plate

    -- Đánh dấu xe đang được spawn từ garage (để skip DERP-mechanic logic nếu được)
    recentGarageSpawns[plate] = GetGameTimer()

    local timeout = 0
    local vehicle = nil
    while timeout < 100 do
        if NetworkDoesNetworkIdExist(netId) then
            vehicle = NetworkGetEntityFromNetworkId(netId)
            if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
                break
            end
        end
        Wait(50)
        timeout = timeout + 1
    end

    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
        exports.qbx_core:Notify('Xe không stream về kịp, thử lại!', 'error')
        recentGarageSpawns[plate] = nil
        return
    end

    spawnedVehicles[netId] = true

    -- Set statebag flag freshGarageSpawn TRƯỚC khi DERP-mechanic chạy onEnterVehicle
    Entity(vehicle).state:set('freshGarageSpawn', GetGameTimer(), true)

    Wait(150)

    -- Apply lần 1 ngay khi entity vừa stream
    ApplyAllVehicleProperties(vehicle, vehicleData)

    Wait(100)

    if DoesEntityExist(vehicle) then
        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        SetVehicleNeedsToBeHotwired(vehicle, false)
        SetVehicleNumberPlateText(vehicle, plate)
    end

    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)

    Wait(150)

    TriggerEvent('qb-vehiclekeys:client:AddKeys', plate)

    exports.qbx_core:Notify(Config.Lang['vehicle_spawned'], 'success')
    TriggerServerEvent('qbx_core:server:vehicleSpawned', plate, netId)

    -- ====================================================================
    -- AGGRESSIVE WATCHDOG: chống mọi resource khác reset health/status
    -- Chạy 8 giây để bao trùm cả DERP-mechanic 2s delay + retry buffer
    -- ====================================================================
    local targetEngine = vehicleData.engine and (vehicleData.engine + 0.0) or nil
    local targetBody   = vehicleData.body   and (vehicleData.body + 0.0)   or nil
    local targetFuel   = vehicleData.fuel   and (vehicleData.fuel + 0.0)   or nil
    local targetStatus = vehicleData.status

    CreateThread(function()
        local startTime = GetGameTimer()
        local duration  = 8000
        local interval  = 50
        local loggedSlot = {}
        local reapplyCount = 0
        local statusReapplyCount = 0

        print(string.format('^2[WATCHDOG] START %s | target Engine=%.2f Body=%.2f Fuel=%.2f^7',
            plate, targetEngine or -1, targetBody or -1, targetFuel or -1))

        while GetGameTimer() - startTime < duration do
            if not DoesEntityExist(vehicle) then
                print('^1[WATCHDOG] ' .. plate .. ' entity gone, stopping^7')
                return
            end

            local elapsed = GetGameTimer() - startTime
            local needReapplyHealth = false
            local needReapplyStatus = false

            if targetEngine then
                local cur = GetVehicleEngineHealth(vehicle)
                if math.abs(cur - targetEngine) > 1.0 then
                    local slot = math.floor(elapsed / 200)
                    if not loggedSlot[slot] then
                        print(string.format('^3[WATCHDOG] @%dms %s ENGINE drift %.2f vs target %.2f^7',
                            elapsed, plate, cur, targetEngine))
                        loggedSlot[slot] = true
                    end
                    needReapplyHealth = true
                end
            end

            if targetBody then
                local cur = GetVehicleBodyHealth(vehicle)
                if math.abs(cur - targetBody) > 1.0 then
                    needReapplyHealth = true
                end
            end

            -- Check status (lốp, kính, cửa) bị restore không
            if targetStatus and type(targetStatus) == 'table' then
                if targetStatus.windows then
                    for windowId, shouldBeBroken in pairs(targetStatus.windows) do
                        local wid = tonumber(windowId)
                        if shouldBeBroken and IsVehicleWindowIntact(vehicle, wid) then
                            needReapplyStatus = true
                            break
                        end
                    end
                end
                if not needReapplyStatus and targetStatus.tyres then
                    for tyreId, tyreData in pairs(targetStatus.tyres) do
                        local tid = tonumber(tyreId)
                        if (tyreData.burst or tyreData.gone) and not IsVehicleTyreBurst(vehicle, tid, false) then
                            needReapplyStatus = true
                            break
                        end
                    end
                end
            end

            if needReapplyHealth then
                if NetworkGetEntityIsNetworked(vehicle) then
                    NetworkRequestControlOfEntity(vehicle)
                end
                if targetEngine then SetVehicleEngineHealth(vehicle, targetEngine) end
                if targetBody   then SetVehicleBodyHealth(vehicle,   targetBody)   end
                if targetFuel   then Entity(vehicle).state:set('fuel', targetFuel, true) end
                reapplyCount = reapplyCount + 1
            end

            if needReapplyStatus then
                ApplyVehicleStatus(vehicle, targetStatus)
                statusReapplyCount = statusReapplyCount + 1
            end

            Wait(interval)
        end

        -- Final state check
        if DoesEntityExist(vehicle) then
            print(string.format('^2[WATCHDOG] DONE %s | reapplies: health=%d status=%d | Final Engine=%.2f Body=%.2f^7',
                plate, reapplyCount, statusReapplyCount,
                GetVehicleEngineHealth(vehicle), GetVehicleBodyHealth(vehicle)))
        end

        -- Cleanup
        SetTimeout(2000, function()
            recentGarageSpawns[plate] = nil
        end)
    end)
end

local function OpenGarageUI(garageName)
    if isUIOpen then return end

    local vehicles = lib.callback.await('DERP-advanced-garages:server:getVehicles', false, garageName)

    if not vehicles or #vehicles == 0 then
        exports.qbx_core:Notify(Config.Lang['no_vehicles'], 'error')
        return
    end

    isUIOpen = true
    SetNuiFocus(true, true)

    SendNUIMessage({
        action = 'openGarage',
        garage = Config.Garages[garageName],
        vehicles = vehicles,
        autoPreview = true
    })
end

local function CloseGarageUI()
    if not isUIOpen then return end

    isUIOpen = false
    SetNuiFocus(false, false)

    SendNUIMessage({
        action = 'closeGarage'
    })

    if isPreviewMode then
        DestroyPreview()
    end
end

local function SpawnGarageEntities()
    for garageName, garage in pairs(Config.Garages) do
        if HasJobAccess(garage) and garage.npc then
            local npcData = garage.npc
            local hash = GetHashKey(npcData.model)

            RequestModel(hash)
            while not HasModelLoaded(hash) do
                Wait(10)
            end

            local npc = CreatePed(
                4,
                hash,
                npcData.coords.x,
                npcData.coords.y,
                npcData.coords.z,
                npcData.heading,
                false,
                true
            )

            FreezeEntityPosition(npc, true)
            SetEntityInvincible(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)

            spawnedNPCs[garageName] = npc

            exports.ox_target:addLocalEntity(npc, {
                {
                    name     = 'garage_' .. garageName,
                    icon     = 'fa-solid fa-car',
                    label    = Config.Lang['open_garage'],
                    distance = 2.0,
                    onSelect = function()
                        currentGarage = garageName
                        OpenGarageUI(garageName)
                    end
                }
            })

            SetModelAsNoLongerNeeded(hash)
        end

        if HasJobAccess(garage) and garage.blip and garage.blip.enabled then
            local blip = AddBlipForCoord(
                garage.npc.coords.x,
                garage.npc.coords.y,
                garage.npc.coords.z
            )

            SetBlipSprite(blip, garage.blip.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, garage.blip.scale)
            SetBlipColour(blip, garage.blip.color)
            SetBlipAsShortRange(blip, true)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(garage.label)
            EndTextCommandSetBlipName(blip)

            spawnedBlips[garageName] = blip
        end
    end
end

local function DeleteGarageEntities()
    for _, npc in pairs(spawnedNPCs) do
        if DoesEntityExist(npc) then
            DeleteEntity(npc)
        end
    end
    spawnedNPCs = {}

    for _, blip in pairs(spawnedBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    spawnedBlips = {}
end

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
    DeleteGarageEntities()
    SpawnGarageEntities()
end)

RegisterNetEvent('derp:applyVehicleProps', function(netId, props)
    if not netId or not props then return end

    if NetworkDoesNetworkIdExist(netId) then
        local vehicle = NetworkGetEntityFromNetworkId(netId)
        if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
            Wait(100)
            local plate = GetVehicleNumberPlateText(vehicle)
            SafeSetVehicleProperties(vehicle, props, plate)
            return
        end
    end

    pendingMods[netId] = {
        props     = props,
        timestamp = GetGameTimer()
    }
end)

RegisterNetEvent('derp:lockStreamedVehicle', function(netId)
    if not netId or not NetworkDoesNetworkIdExist(netId) then return end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end

    SetVehicleDoorsLocked(vehicle, 2)
end)

CreateThread(function()
    while true do
        Wait(500)

        if not next(pendingMods) then goto continue end

        local currentTime = GetGameTimer()

        for netId, data in pairs(pendingMods) do
            if (currentTime - data.timestamp) > 300000 then
                pendingMods[netId] = nil

            elseif NetworkDoesNetworkIdExist(netId) then
                local vehicle = NetworkGetEntityFromNetworkId(netId)

                if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
                    local plate = GetVehicleNumberPlateText(vehicle)
                    SafeSetVehicleProperties(vehicle, data.props, plate)
                    pendingMods[netId] = nil
                end
            end
        end

        ::continue::
    end
end)

AddStateBagChangeHandler('pendingMods', '', function(bagName, key, value)
    if not value or type(value) ~= 'table' then return end

    CreateThread(function()
        local entity = nil
        local waited = 0
        while waited < 5000 do
            entity = GetEntityFromStateBagName(bagName)
            if entity and entity ~= 0 and DoesEntityExist(entity) then break end
            Wait(200)
            waited = waited + 200
        end

        if not entity or entity == 0 or not DoesEntityExist(entity) then return end
        if GetEntityType(entity) ~= 2 then return end

        Wait(500)
        if not DoesEntityExist(entity) then return end

        local plate = GetVehicleNumberPlateText(entity)
        SafeSetVehicleProperties(entity, value, plate)

        local netId = NetworkGetNetworkIdFromEntity(entity)
        if netId and pendingMods[netId] then
            pendingMods[netId] = nil
        end
    end)
end)

RegisterNetEvent('derp:applyVehicleState', function(netId, data)
    if not netId or not data or not NetworkDoesNetworkIdExist(netId) then return end

    local timeout = 0
    local vehicle = NetworkGetEntityFromNetworkId(netId)

    while (not vehicle or vehicle == 0 or not DoesEntityExist(vehicle)) and timeout < 50 do
        Wait(50)
        if NetworkDoesNetworkIdExist(netId) then
            vehicle = NetworkGetEntityFromNetworkId(netId)
        else
            return
        end
        timeout = timeout + 1
    end

    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end

    if data.engine then
        SetVehicleEngineHealth(vehicle, data.engine + 0.0)
    end

    if data.body then
        SetVehicleBodyHealth(vehicle, data.body + 0.0)
    end

    if data.fuel then
        Entity(vehicle).state:set('fuel', data.fuel + 0.0, true)
    end

    if data.status then
        Wait(100)
        ApplyVehicleStatus(vehicle, data.status)
    end
end)

RegisterNetEvent('qb-vehiclekeys:client:AddKeysSilent', function(plate)
    if not plate then return end

    if exports['qb-vehiclekeys'] then
        local success, err = pcall(function()
            exports['qb-vehiclekeys']:AddKey(plate, true)
        end)

        if not success then
            TriggerEvent('qb-vehiclekeys:client:AddKeys', plate)
        end
    else
        TriggerEvent('qb-vehiclekeys:client:AddKeys', plate)
    end
end)

RegisterNetEvent('DERP-advanced-garages:client:requestVehicleStatus', function(netId, plate)
    if not netId or not plate or not NetworkDoesNetworkIdExist(netId) then return end

    Wait(150)

    local vehicle = NetworkGetEntityFromNetworkId(netId)

    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end

    local status = GetVehicleStatus(vehicle)
    local mods = lib.getVehicleProperties(vehicle)

    local coords = GetEntityCoords(vehicle)
    local heading = GetEntityHeading(vehicle)

    local engineHealth = GetVehicleEngineHealth(vehicle)
    local bodyHealth = GetVehicleBodyHealth(vehicle)
    local fuelLevel = Entity(vehicle).state.fuel or 100
    local lockState = GetVehicleDoorLockStatus(vehicle)

    TriggerServerEvent('DERP-advanced-garages:server:receiveVehicleStatus', plate, netId, {
        status = status,
        mods = mods,
        fuel = fuelLevel,
        engine = engineHealth,
        body = bodyHealth,
        coords = {x = coords.x, y = coords.y, z = coords.z, w = heading},
        lockState = lockState
    })
end)

RegisterNetEvent('derp:applyVehicleStatus', function(netId, statusData)
    if not netId or not statusData or not NetworkDoesNetworkIdExist(netId) then return end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end

    Wait(100)

    ApplyVehicleStatus(vehicle, statusData)
end)

local function GetClosestVehicle(coords, maxDistance)
    local vehicles = GetGamePool('CVehicle')
    local closestVehicle = nil
    local closestDistance = maxDistance or 5.0

    for _, vehicle in ipairs(vehicles) do
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(coords - vehicleCoords)

        if distance < closestDistance then
            closestVehicle = vehicle
            closestDistance = distance
        end
    end

    return closestVehicle, closestDistance
end

local function IsVehicleOccupied(vehicle)
    if not vehicle or vehicle == 0 then return false end

    for seat = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
        local ped = GetPedInVehicleSeat(vehicle, seat)
        if ped ~= 0 then
            return true
        end
    end

    return false
end

RegisterNetEvent('DERP-advanced-garages:client:startImpoundProcess', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    if IsPedInAnyVehicle(ped, false) then
        exports.qbx_core:Notify('Bạn phải đứng ngoài xe để giam xe!', 'error')
        return
    end

    local vehicle, distance = GetClosestVehicle(coords, 5.0)

    if not vehicle then
        exports.qbx_core:Notify('Không tìm thấy xe gần đây!', 'error')
        return
    end

    if IsVehicleOccupied(vehicle) then
        exports.qbx_core:Notify('Không thể giam xe khi có người trong xe!', 'error')
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')

    local netId = NetworkGetNetworkIdFromEntity(vehicle)

    local vehicleState = {
        fuel = Entity(vehicle).state.fuel or 100,
        engine = GetVehicleEngineHealth(vehicle),
        body = GetVehicleBodyHealth(vehicle),
        status = GetVehicleStatus(vehicle)
    }

    local input = lib.inputDialog('Giam Xe Vi Phạm - ' .. plate, {
        {
            type = 'number',
            label = 'Thời gian giam (phút)',
            description = 'Để trống = ' .. Config.Impound.DefaultDuration .. ' phút',
            icon = 'clock',
            min = 1,
            max = 999999
        },
        {
            type = 'number',
            label = 'Giá tiền ($)',
            description = 'Để trống = $' .. Config.Impound.DefaultPrice,
            icon = 'dollar-sign',
            min = 1,
            max = 999999999
        },
        {
            type = 'input',
            label = 'Lý do',
            description = 'Lý do giam xe',
            icon = 'file-text',
            required = false,
            default = 'Vi phạm luật giao thông'
        }
    })

    if not input then return end

    local impoundData = {
        duration = input[1] and tonumber(input[1]) or nil,
        price = input[2] and tonumber(input[2]) or nil,
        reason = input[3] or 'Vi phạm luật giao thông'
    }

    TriggerServerEvent('DERP-advanced-garages:server:impoundVehicle', netId, plate, impoundData, vehicleState)
end)

RegisterNetEvent('DERP-advanced-garages:client:deleteVehicle', function(netId)
    if not netId or not NetworkDoesNetworkIdExist(netId) then return end

    local vehicle = NetworkGetEntityFromNetworkId(netId)

    if vehicle and DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
    end
end)

RegisterNUICallback('closeUI', function(data, cb)
    CloseGarageUI()
    cb('ok')
end)

RegisterNUICallback('startPreview', function(data, cb)
    local vehicleData = data.vehicle
    local garagePreview = Config.Garages[currentGarage].preview

    if not garagePreview then
        cb('ok')
        return
    end

    SetNuiFocus(false, false)
    isPreviewMode = true
    SpawnPreviewVehicle(vehicleData, garagePreview)

    cb('ok')
end)

RegisterNUICallback('updatePreview', function(data, cb)
    local vehicleData = data.vehicle
    local garagePreview = Config.Garages[currentGarage].preview

    if not garagePreview then
        cb('ok')
        return
    end

    if previewVehicle and DoesEntityExist(previewVehicle) then
        DeleteEntity(previewVehicle)
    end

    local model = vehicleData.vehicle
    local hash = GetHashKey(model)

    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(10)
    end

    local spawnPos = garagePreview.vehicle
    previewVehicle = CreateVehicle(hash, spawnPos.x, spawnPos.y, spawnPos.z, spawnPos.w, false, false)

    local timeout = 0
    while not DoesEntityExist(previewVehicle) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end

    if not DoesEntityExist(previewVehicle) then
        cb('ok')
        return
    end

    SetEntityAlpha(previewVehicle, 0, false)
    ResetEntityAlpha(previewVehicle)
    SetEntityCollision(previewVehicle, false, false)
    SetEntityInvincible(previewVehicle, true)
    FreezeEntityPosition(previewVehicle, true)
    SetVehicleDoorsLocked(previewVehicle, 2)
    SetVehicleNumberPlateText(previewVehicle, vehicleData.plate)

    if vehicleData.mods then
        local mods = type(vehicleData.mods) == 'string' and json.decode(vehicleData.mods) or vehicleData.mods
        if mods then
            SafeSetVehicleProperties(previewVehicle, mods)
        end
    end

    Wait(100)
    ApplyVehicleStatus(previewVehicle, vehicleData.status)

    if vehicleData.engine then
        SetVehicleEngineHealth(previewVehicle, vehicleData.engine + 0.0)
    end

    if vehicleData.body then
        SetVehicleBodyHealth(previewVehicle, vehicleData.body + 0.0)
    end

    SetModelAsNoLongerNeeded(hash)

    if previewCam then
        local cameraConfig = garagePreview.camera
        if not cameraConfig then
            cameraConfig = CalculateCameraPosition(garagePreview.vehicle)
        end

        local camCoords = cameraConfig.coords
        local pointAt = cameraConfig.pointAt

        SetCamCoord(previewCam, camCoords.x, camCoords.y, camCoords.z)
        PointCamAtCoord(previewCam, pointAt.x, pointAt.y, pointAt.z)
    else
        CreatePreviewCamera(garagePreview)
    end

    previewVehicleData = vehicleData

    cb('ok')
end)

RegisterNUICallback('stopPreview', function(data, cb)
    DestroyPreview()

    if isUIOpen then
        SetNuiFocus(true, true)
    end

    cb('ok')
end)

RegisterNUICallback('spawnVehicleFromPreview', function(data, cb)
    local plate = data.plate
    local garageName = currentGarage

    if not garageName or not Config.Garages[garageName] then
        cb({success = false, message = 'Invalid garage'})
        return
    end

    local spawnPoint = FindAvailableSpawnPoint(Config.Garages[garageName].spawnPoints)

    if not spawnPoint then
        exports.qbx_core:Notify(Config.Lang['all_spawns_blocked'], 'error')
        cb({success = false, message = 'All spawn points blocked'})
        return
    end

    local result = lib.callback.await('DERP-advanced-garages:server:spawnVehicle', false, plate, spawnPoint, garageName)

    if result and result.success then
        DestroyPreview()
        CloseGarageUI()
        SpawnVehicle(result, spawnPoint, garageName)
        cb({success = true})
    else
        cb({success = false, message = 'Failed to spawn vehicle'})
    end
end)

RegisterNUICallback('updateLabel', function(data, cb)
    local plate = data.plate
    local label = data.label

    local result = lib.callback.await('DERP-advanced-garages:server:updateLabel', false, plate, label)

    cb({success = result})
end)

CreateThread(function()
    while true do
        local sleep = 500

        if isPreviewMode and DoesEntityExist(previewVehicle) then
            sleep = 0

            SetTextFont(0)
            SetTextScale(0.4, 0.4)
            SetTextColour(255, 255, 255, 200)
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextOutline()
            SetTextCentre(true)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentString("Xem trước xe")
            EndTextCommandDisplayText(0.5, 0.95)
        end

        Wait(sleep)
    end
end)

local function StoreVehicle(garageName)
    local ped     = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if not vehicle or vehicle == 0 then
        exports.qbx_core:Notify(Config.Lang['not_in_vehicle'], 'error')
        return
    end

    if GetPedInVehicleSeat(vehicle, -1) ~= ped then
        exports.qbx_core:Notify('Bạn phải là tài xế!', 'error')
        return
    end

    local plate = string.gsub(GetVehicleNumberPlateText(vehicle), '^%s*(.-)%s*$', '%1')
    local netId = NetworkGetNetworkIdFromEntity(vehicle)

    local currentMods = lib.getVehicleProperties(vehicle)

    local clientEngine = GetVehicleEngineHealth(vehicle)
    local clientBody   = GetVehicleBodyHealth(vehicle)
    local clientFuel   = GetVehicleFuelLevel(vehicle)

    if type(currentMods) == 'table' then
        currentMods.engineHealth = clientEngine
        currentMods.bodyHealth   = clientBody
        currentMods.fuelLevel    = clientFuel
    end

    local vehicleData = {
        fuel      = clientFuel,
        engine    = clientEngine,
        body      = clientBody,
        status    = GetVehicleStatus(vehicle),
        mods      = currentMods,
        lockState = GetVehicleDoorLockStatus(vehicle)
    }

    TriggerServerEvent('DERP-advanced-garages:server:storeVehicle', plate, garageName, vehicleData, netId)

    TaskLeaveVehicle(ped, vehicle, 0)

    local timeout = 0
    while IsPedInVehicle(ped, vehicle, false) and timeout < 50 do
        Wait(100)
        timeout = timeout + 1
    end

    DeleteEntity(vehicle)

    if spawnedVehicles[netId] then
        spawnedVehicles[netId] = nil
    end
end

CreateThread(function()
    local lastVehicle = 0
    local keyCheckCooldown = {}

    while true do
        Wait(1000)

        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle ~= 0 and vehicle ~= lastVehicle then
            if GetPedInVehicleSeat(vehicle, -1) == ped then
                local plate = GetVehicleNumberPlateText(vehicle)
                plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')

                local netId = NetworkGetNetworkIdFromEntity(vehicle)
                local currentTime = GetGameTimer()

                if not keyCheckCooldown[plate] or (currentTime - keyCheckCooldown[plate]) > 5000 then
                    TriggerServerEvent('DERP-advanced-garages:server:checkVehicleOwnership', plate, netId, true)
                    keyCheckCooldown[plate] = currentTime
                end
            end

            lastVehicle = vehicle
        elseif vehicle == 0 then
            lastVehicle = 0
        end
    end
end)

CreateThread(function()
    while not PlayerData or not PlayerData.job do
        Wait(100)
    end

    SpawnGarageEntities()
end)

CreateThread(function()
    local wasShowingStoreUI = false

    while true do
        local sleep = 1000
        local ped     = PlayerPedId()
        local coords  = GetEntityCoords(ped)
        local vehicle = GetVehiclePedIsIn(ped, false)

        isInVehicle = vehicle ~= 0
        inStoreZone = false

        if isInVehicle then
            for garageName, garage in pairs(Config.Garages) do
                if HasJobAccess(garage) and garage.storeZone then
                    local distance = #(coords - garage.storeZone.coords)

                    if distance <= garage.storeZone.radius then
                        sleep = 0
                        inStoreZone   = true
                        currentGarage = garageName

                        if HasVehicleKeys(vehicle) then
                            if not wasShowingStoreUI then
                                lib.showTextUI(garage.storeZone.showText, {
                                    position = 'left-center',
                                    icon     = 'warehouse'
                                })
                                wasShowingStoreUI = true
                            end

                            if IsControlJustReleased(0, 38) then
                                lib.hideTextUI()
                                wasShowingStoreUI = false
                                StoreVehicle(garageName)
                            end
                        else
                            if wasShowingStoreUI then
                                lib.hideTextUI()
                                wasShowingStoreUI = false
                            end
                        end

                        break
                    end
                end
            end

            if not inStoreZone then
                if wasShowingStoreUI then
                    lib.hideTextUI()
                    wasShowingStoreUI = false
                end
                currentGarage = nil
            end
        else
            if wasShowingStoreUI then
                lib.hideTextUI()
                wasShowingStoreUI = false
            end
        end

        Wait(sleep)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    CloseGarageUI()
    DestroyPreview()
    lib.hideTextUI()

    for _, npc in pairs(spawnedNPCs) do
        if DoesEntityExist(npc) then
            DeleteEntity(npc)
        end
    end

    for netId, _ in pairs(spawnedVehicles) do
        spawnedVehicles[netId] = nil
    end
end)

local isAdminUIOpen = false

RegisterNetEvent('DERP-advanced-garages:client:teleportTo', function(coords)
    local ped = PlayerPedId()

    DoScreenFadeOut(500)
    Wait(500)

    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, true)

    Wait(500)
    DoScreenFadeIn(500)

    exports.qbx_core:Notify('Đã teleport đến vị trí xe!', 'success')
end)

local function OpenAdminUI()
    if isAdminUIOpen then return end

    local vehicles = lib.callback.await('DERP-advanced-garages:server:getAllVehicles', false)

    if not vehicles then
        exports.qbx_core:Notify('Không có quyền truy cập!', 'error')
        return
    end

    local garageList = {}
    for name, garage in pairs(Config.Garages) do
        table.insert(garageList, {
            name = name,
            label = garage.label
        })
    end

    isAdminUIOpen = true
    SetNuiFocus(true, true)

    SendNUIMessage({
        action = 'openAdmin',
        vehicles = vehicles,
        garages = garageList
    })
end

local function CloseAdminUI()
    if not isAdminUIOpen then return end

    isAdminUIOpen = false
    SetNuiFocus(false, false)

    SendNUIMessage({
        action = 'closeAdmin'
    })
end

RegisterNUICallback('closeAdminUI', function(data, cb)
    CloseAdminUI()
    cb('ok')
end)

RegisterNUICallback('toggleVehicleState', function(data, cb)
    local plate = data.plate

    TriggerServerEvent('DERP-advanced-garages:server:toggleVehicleState', plate)

    Wait(500)

    local vehicles = lib.callback.await('DERP-advanced-garages:server:getAllVehicles', false)
    cb({success = true, vehicles = vehicles})
end)

RegisterNUICallback('teleportToVehicle', function(data, cb)
    local plate = data.plate

    TriggerServerEvent('DERP-advanced-garages:server:teleportToVehicle', plate)

    CloseAdminUI()

    cb('ok')
end)

RegisterNUICallback('moveVehicleToGarage', function(data, cb)
    local plate = data.plate
    local garage = data.garage

    TriggerServerEvent('DERP-advanced-garages:server:moveVehicleToGarage', plate, garage)

    Wait(500)

    local vehicles = lib.callback.await('DERP-advanced-garages:server:getAllVehicles', false)
    cb({success = true, vehicles = vehicles})
end)

RegisterNetEvent('DERP-advanced-garages:client:openAdminUI', function()
    OpenAdminUI()
end)

RegisterNetEvent('derp:applyVehicleLockState', function(netId, lockState)
    if not netId or not lockState or not NetworkDoesNetworkIdExist(netId) then return end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end

    SetVehicleDoorsLocked(vehicle, lockState)
end)

RegisterNetEvent('DERP-advanced-garages:client:startImpoundWithAnim', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    if IsPedInAnyVehicle(ped, false) then
        exports.qbx_core:Notify('Bạn phải đứng ngoài xe để giam xe!', 'error')
        return
    end

    local vehicle, distance = GetClosestVehicle(coords, 5.0)

    if not vehicle then
        exports.qbx_core:Notify('Không tìm thấy xe gần đây!', 'error')
        return
    end

    if IsVehicleOccupied(vehicle) then
        exports.qbx_core:Notify('Không thể giam xe khi có người trong xe!', 'error')
        return
    end

    lib.requestAnimDict('missheistdockssetup1clipboard@base')
    TaskPlayAnim(ped, 'missheistdockssetup1clipboard@base', 'base', 8.0, -8.0, -1, 49, 0, false, false, false)

    local plate = GetVehicleNumberPlateText(vehicle)
    plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')

    local netId = NetworkGetNetworkIdFromEntity(vehicle)

    local vehicleState = {
        fuel = GetVehicleFuelLevel(vehicle),
        engine = GetVehicleEngineHealth(vehicle),
        body = GetVehicleBodyHealth(vehicle),
        status = GetVehicleStatus(vehicle)
    }

    local input = lib.inputDialog('Giam Xe Vi Phạm - ' .. plate, {
        {
            type = 'number',
            label = 'Thời gian giam (phút)',
            description = 'Để trống = ' .. Config.Impound.DefaultDuration .. ' phút',
            icon = 'clock',
            min = 1,
            max = 999999
        },
        {
            type = 'number',
            label = 'Giá tiền ($)',
            description = 'Để trống = $' .. Config.Impound.DefaultPrice,
            icon = 'dollar-sign',
            min = 1,
            max = 999999999
        },
        {
            type = 'input',
            label = 'Lý do',
            description = 'Lý do giam xe',
            icon = 'file-text',
            required = false,
            default = 'Vi phạm luật giao thông'
        }
    })

    ClearPedTasks(ped)

    if not input then return end

    local impoundData = {
        duration = input[1] and tonumber(input[1]) or nil,
        price = input[2] and tonumber(input[2]) or nil,
        reason = input[3] or 'Vi phạm luật giao thông'
    }

    Wait(500)

    TriggerServerEvent('DERP-advanced-garages:server:impoundVehicle', netId, plate, impoundData, vehicleState)
end)

-- ============================================================
-- WATER IMPOUND SYSTEM
-- ============================================================

local waterImpoundTimers = {}
local waterImpoundSent = {}
local waterImpoundDebug = {}

CreateThread(function()
    while true do
        local interval = Config.WaterImpound and Config.WaterImpound.CheckInterval or 1000
        Wait(interval)

        if not Config.WaterImpound or not Config.WaterImpound.Enabled then goto continueWater end

        local playerCoords = GetEntityCoords(PlayerPedId())
        local vehicles = GetGamePool('CVehicle')
        local now = GetGameTimer()

        waterImpoundDebug = {}

        for _, vehicle in ipairs(vehicles) do
            if DoesEntityExist(vehicle) then
                local plate = string.gsub(GetVehicleNumberPlateText(vehicle), '^%s*(.-)%s*$', '%1')

                if waterImpoundSent[plate] then goto nextVehicle end

                local vehCoords = GetEntityCoords(vehicle)
                if #(playerCoords - vehCoords) > Config.WaterImpound.CheckRadius then goto nextVehicle end

                local engineHealth = GetVehicleEngineHealth(vehicle)
                local submergedLevel = GetEntitySubmergedLevel(vehicle)

                if submergedLevel >= Config.WaterImpound.SubmergedThreshold then
                    if not waterImpoundTimers[plate] then
                        waterImpoundTimers[plate] = now
                    end

                    local elapsed = (now - waterImpoundTimers[plate]) / 1000
                    local remaining = Config.WaterImpound.SubmergedTime - elapsed

                    waterImpoundDebug[plate] = {
                        coords = vector3(vehCoords.x, vehCoords.y, vehCoords.z + 2.0),
                        remaining = remaining,
                        engine = engineHealth,
                        submerged = submergedLevel
                    }

                    if elapsed >= Config.WaterImpound.SubmergedTime then
                        local netId = NetworkGetNetworkIdFromEntity(vehicle)
                        if netId and netId ~= 0 then
                            waterImpoundSent[plate] = true
                            waterImpoundTimers[plate] = nil
                            waterImpoundDebug[plate] = nil
                            TriggerServerEvent('DERP-advanced-garages:server:waterImpound', plate, netId)
                        end
                    end
                else
                    waterImpoundTimers[plate] = nil
                end

                ::nextVehicle::
            end
        end

        ::continueWater::
    end
end)

CreateThread(function()
    while true do
        Wait(10000)

        local pool = GetGamePool('CVehicle')
        local activePlates = {}

        for _, vehicle in ipairs(pool) do
            if DoesEntityExist(vehicle) then
                local plate = string.gsub(GetVehicleNumberPlateText(vehicle), '^%s*(.-)%s*$', '%1')
                activePlates[plate] = true
            end
        end

        for plate, _ in pairs(waterImpoundTimers) do
            if not activePlates[plate] then
                waterImpoundTimers[plate] = nil
            end
        end

        for plate, _ in pairs(waterImpoundSent) do
            if not activePlates[plate] then
                waterImpoundSent[plate] = nil
            end
        end
    end
end)