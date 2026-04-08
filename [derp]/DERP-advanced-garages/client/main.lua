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
    if not status then return end

    local statusData = type(status) == 'string' and json.decode(status) or status
    if not statusData then return end

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
            if tyreData.gone then
                SetVehicleTyreBurst(vehicle, tonumber(tyreId), true, 1000.0)
            elseif tyreData.burst then
                SetVehicleTyreBurst(vehicle, tonumber(tyreId), false, 990.0)
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

-- FIX: Gửi netId thay vì entity handle, fix undefined success, re-assert plate
local function SpawnVehicle(vehicleData, spawnPoint, garageName)
    local model = vehicleData.vehicle
    local hash = GetHashKey(model)

    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(10)
    end

    local vehicle = CreateVehicle(hash, spawnPoint.x, spawnPoint.y, spawnPoint.z, spawnPoint.w, true, true)

    local timeout = 0
    while not DoesEntityExist(vehicle) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end

    if not DoesEntityExist(vehicle) then
        SetModelAsNoLongerNeeded(hash)
        return
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)

    timeout = 0
    while not NetworkGetEntityIsNetworked(vehicle) and timeout < 150 do
        NetworkRegisterEntityAsNetworked(vehicle)
        Wait(10)
        timeout = timeout + 1
    end

    if not NetworkGetEntityIsNetworked(vehicle) then
        DeleteEntity(vehicle)
        SetModelAsNoLongerNeeded(hash)
        exports.qbx_core:Notify('Lỗi spawn xe, thử lại!', 'error')
        return
    end

    SetNetworkIdCanMigrate(netId, true)
    SetNetworkIdExistsOnAllMachines(netId, true)

    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetVehicleNumberPlateText(vehicle, vehicleData.plate)

    spawnedVehicles[netId] = true

    Wait(800)

    if vehicleData.mods then
        local mods = type(vehicleData.mods) == 'string' and json.decode(vehicleData.mods) or vehicleData.mods
        if mods and type(mods) == 'table' then
            local applyOk = SafeSetVehicleProperties(vehicle, mods, vehicleData.plate)

            if not applyOk then
                Wait(500)
                SafeSetVehicleProperties(vehicle, mods, vehicleData.plate)
            end
        end
    end

    if vehicleData.fuel then
        Entity(vehicle).state:set('fuel', vehicleData.fuel, true)
    end

    Wait(300)

    if vehicleData.engine then
        SetVehicleEngineHealth(vehicle, vehicleData.engine + 0.0)
    end

    if vehicleData.body then
        SetVehicleBodyHealth(vehicle, vehicleData.body + 0.0)
    end

    Wait(200)

    if vehicleData.status then
        ApplyVehicleStatus(vehicle, vehicleData.status)
    end

    SetModelAsNoLongerNeeded(hash)

    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)

    Wait(100)

    TriggerEvent('qb-vehiclekeys:client:AddKeys', vehicleData.plate)

    if vehicleData.fuel then
        local fuelLevel = vehicleData.fuel + 0.0
        exports['cdn-fuel']:SetFuel(vehicle, fuelLevel)

        SetTimeout(1500, function()
            if DoesEntityExist(vehicle) then
                exports['cdn-fuel']:SetFuel(vehicle, fuelLevel)
            end
        end)
    end

    if vehicleData.lockState then
        SetVehicleDoorsLocked(vehicle, vehicleData.lockState)
    end

    exports.qbx_core:Notify(Config.Lang['vehicle_spawned'], 'success')
    TriggerServerEvent('qbx_core:server:vehicleSpawned', vehicleData.plate, netId)

    if Config.Streaming and Config.Streaming.Enabled then
        local spawnNetId = NetworkGetNetworkIdFromEntity(vehicle)
        TriggerServerEvent('DERP-advanced-garages:server:registerSpawn', vehicleData.plate, spawnNetId, spawnPoint)
    end
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

-- FIX: StateBag handler với retry khi entity chưa stream vào
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
        exports['cdn-fuel']:SetFuel(vehicle, data.fuel + 0.0)
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

    local nativeFuel = GetVehicleFuelLevel(vehicle)
    local stateBagFuel = Entity(vehicle).state.fuel

    -- print('[FUEL DEBUG STORE] Plate: ' .. plate)
    -- print('[FUEL DEBUG STORE] Native fuel: ' .. tostring(nativeFuel))
    -- print('[FUEL DEBUG STORE] StateBag fuel: ' .. tostring(stateBagFuel))

    local vehicleData = {
        fuel      = GetVehicleFuelLevel(vehicle),
        engine    = GetVehicleEngineHealth(vehicle),
        body      = GetVehicleBodyHealth(vehicle),
        status    = GetVehicleStatus(vehicle),
        mods      = currentMods,
        lockState = GetVehicleDoorLockStatus(vehicle)
    }

    -- print('[FUEL DEBUG STORE] Sending fuel: ' .. tostring(vehicleData.fuel))

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

-- RegisterNetEvent('DERP-advanced-garages:client:requestVehicleLockState', function(netId, plate)
--     if not netId or not plate or not NetworkDoesNetworkIdExist(netId) then return end

--     local vehicle = NetworkGetEntityFromNetworkId(netId)
--     if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end

--     local lockState = GetVehicleDoorLockStatus(vehicle)
--     TriggerServerEvent('DERP-advanced-garages:server:receiveLockState', plate, lockState)
-- end)

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

-- Debug: DrawText3D trên mỗi xe đang đếm ngược
-- CreateThread(function()
--     while true do
--         local sleep = 500

--         if Config.WaterImpound and Config.WaterImpound.Enabled and Config.WaterImpound.Debug and next(waterImpoundDebug) then
--             sleep = 0
--             for plate, data in pairs(waterImpoundDebug) do
--                 local remaining = math.max(0, math.floor(data.remaining))
--                 local text = string.format(
--                     '~r~IMPOUND: %ds~n~~w~Engine: %.0f | Water: %.1f~n~%s',
--                     remaining, data.engine, data.submerged, plate
--                 )
--                 SetTextScale(0.35, 0.35)
--                 SetTextFont(4)
--                 SetTextColour(255, 255, 255, 255)
--                 SetTextDropshadow(0, 0, 0, 0, 255)
--                 SetTextEdge(2, 0, 0, 0, 150)
--                 SetTextDropShadow()
--                 SetTextOutline()
--                 SetTextCentre(true)
--                 BeginTextCommandDisplayText('STRING')
--                 AddTextComponentSubstringPlayerName(text)
--                 SetDrawOrigin(data.coords.x, data.coords.y, data.coords.z, 0)
--                 EndTextCommandDisplayText(0.0, 0.0)
--                 ClearDrawOrigin()
--             end
--         end

--         Wait(sleep)
--     end
-- end)

-- Command debug: check xe gần nhất realtime
-- RegisterCommand('watercheck', function()
--     local ped = PlayerPedId()
--     local playerCoords = GetEntityCoords(ped)
--     local vehicles = GetGamePool('CVehicle')
--     local found = false

--     for _, vehicle in ipairs(vehicles) do
--         if DoesEntityExist(vehicle) then
--             local vehCoords = GetEntityCoords(vehicle)
--             if #(playerCoords - vehCoords) <= 30.0 then
--                 local plate = string.gsub(GetVehicleNumberPlateText(vehicle), '^%s*(.-)%s*$', '%1')
--                 local engine = GetVehicleEngineHealth(vehicle)
--                 local submerged = GetEntitySubmergedLevel(vehicle)
--                 local inWater = IsEntityInWater(vehicle)
--                 local netId = NetworkGetNetworkIdFromEntity(vehicle)

--                 local msg = string.format(
--                     '[%s] Engine: %.1f | Submerged: %.2f | InWater: %s | NetID: %s | Timer: %s',
--                     plate, engine, submerged,
--                     tostring(inWater), tostring(netId),
--                     waterImpoundTimers[plate] and string.format('%.1fs', (GetGameTimer() - waterImpoundTimers[plate]) / 1000) or 'NONE'
--                 )

--                 print(msg)
--                 exports.qbx_core:Notify(msg, 'primary', 8000)
--                 found = true
--             end
--         end
--     end

--     if not found then
--         exports.qbx_core:Notify('Không tìm thấy xe trong 30m', 'error')
--     end

--     -- Config check
--     local cfgMsg = string.format(
--         'Config: Enabled=%s | EngineThreshold=%s | SubmergedThreshold=%s | Time=%ss | Debug=%s',
--         tostring(Config.WaterImpound and Config.WaterImpound.Enabled),
--         tostring(Config.WaterImpound and Config.WaterImpound.EngineHealthThreshold),
--         tostring(Config.WaterImpound and Config.WaterImpound.SubmergedThreshold),
--         tostring(Config.WaterImpound and Config.WaterImpound.SubmergedTime),
--         tostring(Config.WaterImpound and Config.WaterImpound.Debug)
--     )
--     print(cfgMsg)
-- end, false)

-- Cleanup
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