local CurrentJob      = nil
local PickupBlip      = nil
local DropoffBlip     = nil
local CarryingBox     = false
local BoxProp         = nil
local IsLoadingPhase  = true
local isBusy          = false

local InParty      = false
local IsLeader     = false
local PartyData    = nil
local PendingInvite = nil

-- ─── HELPERS ─────────────────────────────────────────────────────────────────

local function GetPlate(vehicle)
    return string.upper(string.gsub(GetVehicleNumberPlateText(vehicle), '^%s*(.-)%s*$', '%1'))
end

local function Notify(msg, ntype, duration)
    lib.notify({ description = msg, type = ntype or 'inform', duration = duration or 3000 })
end

local function DrawText3D(x, y, z, text)
    local onScreen, sx, sy = World3dToScreen2d(x, y, z)
    if not onScreen then return end
    local camCoords = GetGameplayCamCoords()
    local dist      = #(camCoords - vector3(x, y, z))
    local scale     = math.max(0.3, 0.6 * (1 / dist) * 5.0)
    SetTextScale(scale, scale)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextOutline()
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    DrawText(sx, sy)
end

-- ─── UI ──────────────────────────────────────────────────────────────────────

function OpenTruckerUI()
    lib.callback('tommy-trucker:server:getDriverData', false, function(driverData)
        lib.callback('tommy-trucker:server:getOrders', false, function(orders)
            lib.callback('tommy-trucker:server:getPartyData', false, function(partyData)
                lib.callback('tommy-trucker:server:getRentalData', false, function(rentalData)
                    rentalData = rentalData or { fleet = {}, activeRental = nil }

                    if partyData.inParty then
                        InParty   = true
                        IsLeader  = partyData.isLeader
                        PartyData = partyData
                    else
                        InParty   = false
                        IsLeader  = false
                        PartyData = nil
                    end

                    SetNuiFocus(true, true)
                    SendNUIMessage({
                        action        = 'openUI',
                        driverData    = driverData,
                        orders        = orders,
                        hasActiveJob  = CurrentJob ~= nil,
                        partyData     = partyData,
                        pendingInvite = PendingInvite,
                        rentalFleet   = rentalData.fleet,
                        activeRental  = rentalData.activeRental,
                    })

                end)
            end)
        end)
    end)
end

-- ─── NUI CALLBACKS ───────────────────────────────────────────────────────────

RegisterNUICallback('closeUI', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('registerVehicle', function(_, cb)
    lib.callback('tommy-trucker:server:getVehicles', false, function(vehicles)
        cb({ vehicles = vehicles })
    end)
end)

RegisterNUICallback('confirmRegister', function(data, cb)
    TriggerServerEvent('tommy-trucker:server:registerVehicle', data.plate, data.vehicle)
    cb('ok')
end)

RegisterNUICallback('rentVehicle', function(data, cb)
    TriggerServerEvent('tommy-trucker:server:rentVehicle', {
        model       = data.model,
        pricePerDay = data.pricePerDay,
        rentalDays  = data.rentalDays,
        totalPrice  = data.totalPrice,
    })
    cb('ok')
end)

RegisterNUICallback('acceptOrder', function(data, cb)
    local ped    = PlayerPedId()
    local coords = GetEntityCoords(ped)

    lib.callback('tommy-trucker:server:getDriverData', false, function(driverData)
        if not driverData or not driverData.registered_plate then
            SetNuiFocus(false, false)
            Notify(locale('error_no_vehicle'), 'error')
            cb('ok')
            return
        end

        local registeredPlate = string.upper(string.gsub(driverData.registered_plate, '^%s*(.-)%s*$', '%1'))
        local vehicle, foundPlate = nil, nil

        if IsPedInAnyVehicle(ped, false) then
            local v = GetVehiclePedIsIn(ped, false)
            if GetPlate(v) == registeredPlate then
                vehicle    = v
                foundPlate = registeredPlate
            end
        end

        if not vehicle then
            local closestDist = 50.0
            for _, v in ipairs(GetGamePool('CVehicle')) do
                local dist = #(coords - GetEntityCoords(v))
                if dist <= 50.0 and GetPlate(v) == registeredPlate and dist < closestDist then
                    closestDist = dist
                    vehicle     = v
                    foundPlate  = registeredPlate
                end
            end
        end

        if not vehicle or vehicle == 0 then
            SetNuiFocus(false, false)
            Notify(locale('error_vehicle_not_nearby'), 'error')
            cb('ok')
            return
        end

        local npcCoords = Config.NPCLocation.coords
        local vehCoords = GetEntityCoords(vehicle)
        local dist      = #(vehCoords - vector3(npcCoords.x, npcCoords.y, npcCoords.z))

        if dist > 50.0 then
            SetNuiFocus(false, false)
            Notify(locale('error_vehicle_too_far_npc'), 'error')
            cb('ok')
            return
        end

        SetNuiFocus(false, false)
        TriggerServerEvent('tommy-trucker:server:acceptOrder', data.orderId, NetworkGetNetworkIdFromEntity(vehicle))
        cb('ok')
    end)
end)

RegisterNUICallback('cancelJob', function(_, cb)
    if CurrentJob then TriggerServerEvent('tommy-trucker:server:cancelJob') end
    cb('ok')
end)

-- ─── PARTY NUI ───────────────────────────────────────────────────────────────

RegisterNUICallback('createParty',       function(_, cb) TriggerServerEvent('tommy-trucker:server:createParty')  cb('ok') end)
RegisterNUICallback('leaveParty',        function(_, cb) TriggerServerEvent('tommy-trucker:server:leaveParty')   cb('ok') end)
RegisterNUICallback('kickMember',        function(_, cb) TriggerServerEvent('tommy-trucker:server:kickMember')   cb('ok') end)

RegisterNUICallback('getNearbyPlayers', function(_, cb)
    lib.callback('tommy-trucker:server:getNearbyPlayers', false, function(players)
        cb({ players = players })
    end)
end)

RegisterNUICallback('invitePlayer', function(data, cb)
    TriggerServerEvent('tommy-trucker:server:inviteToParty', data.targetSrc)
    cb('ok')
end)

RegisterNUICallback('acceptPartyInvite', function(_, cb)
    TriggerServerEvent('tommy-trucker:server:acceptPartyInvite')
    PendingInvite = nil
    cb('ok')
end)

RegisterNUICallback('declinePartyInvite', function(_, cb)
    TriggerServerEvent('tommy-trucker:server:declinePartyInvite')
    PendingInvite = nil
    cb('ok')
end)

RegisterNUICallback('getPartyData', function(_, cb)
    lib.callback('tommy-trucker:server:getPartyData', false, function(partyData)
        cb(partyData)
    end)
end)

-- ─── PARTY EVENTS ────────────────────────────────────────────────────────────

RegisterNetEvent('tommy-trucker:client:forceRefreshPartyUI', function()
    lib.callback('tommy-trucker:server:getPartyData', false, function(data)
        if data.inParty then
            InParty   = true
            IsLeader  = data.isLeader
            PartyData = data
        else
            InParty   = false
            IsLeader  = false
            PartyData = nil
        end
        SendNUIMessage({ action = 'refreshPartyData', partyData = data })
    end)
end)

RegisterNetEvent('tommy-trucker:client:partyUpdated', function()
    lib.callback('tommy-trucker:server:getPartyData', false, function(data)
        if data.inParty then
            InParty   = true
            IsLeader  = data.isLeader
            PartyData = data
        else
            InParty   = false
            IsLeader  = false
            PartyData = nil
        end
    end)
end)

RegisterNetEvent('tommy-trucker:client:partyDisbanded', function()
    InParty       = false
    IsLeader      = false
    PartyData     = nil
    PendingInvite = nil
    SendNUIMessage({ action = 'partyDisbanded' })
end)

RegisterNetEvent('tommy-trucker:client:receivePartyInvite', function(fromSrc, fromName)
    PendingInvite = { from = fromSrc, name = fromName }
    SendNUIMessage({ action = 'showPartyInvite', data = { from = fromSrc, name = fromName } })
    Notify('📨 ' .. fromName .. ' ' .. locale('invite_received'), 'inform', 10000)
end)

-- ─── JOB START ───────────────────────────────────────────────────────────────

RegisterNetEvent('tommy-trucker:client:startJob', function(order, registeredPlate, isPartyJob)
    CurrentJob = {
        order           = order,
        registeredPlate = registeredPlate,
        loaded          = 0,
        unloaded        = 0,
        totalKg         = order.requiredKg,
        isIllegal       = order.isIllegal,
        isPartyJob      = isPartyJob or false,
    }
    IsLoadingPhase = true

    Notify(isPartyJob and locale('info_goto_pickup_party') or locale('info_goto_pickup'), 'inform', 5000)
    if order.isIllegal then Notify(locale('info_illegal_cargo'), 'error', 7000) end

    CreatePickupBlip(order.pickup, order.isIllegal)
    SetNewWaypoint(order.pickup.x, order.pickup.y)
    CheckPickupZone()
end)

RegisterNetEvent('tommy-trucker:client:rentalSuccess', function(rentalData)
    SendNUIMessage({
        action     = 'rentalSuccess',
        rentalData = {
            plate         = rentalData.plate,
            vehicle_model = rentalData.vehicle_model,
            expire_time   = rentalData.expire_unix,
        },
    })
end)

RegisterNetEvent('tommy-trucker:client:spawnRentalVehicle', function(rentalInfo)
    local model  = rentalInfo.model
    local plate  = rentalInfo.plate
    local coords = rentalInfo.spawnCoords

    lib.requestModel(model)
    local modelHash = GetHashKey(model)

    local spawnPos  = vector3(coords.x, coords.y, coords.z)
    local isClear   = true
    local checkRadius = Config.RentalSpawnCheckRadius or 6.0

    for _, v in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(v) and #(GetEntityCoords(v) - spawnPos) < checkRadius then
            isClear = false
            break
        end
    end

    if not isClear then
        coords.x = coords.x + math.cos(math.rad(coords.heading + 90)) * 6.0
        coords.y = coords.y + math.sin(math.rad(coords.heading + 90)) * 6.0
    end

    local vehicle = CreateVehicle(
        modelHash,
        coords.x, coords.y, coords.z,
        coords.heading,
        true, false
    )

    local timeout = 0
    while not DoesEntityExist(vehicle) and timeout < 3000 do
        Wait(50)
        timeout = timeout + 50
    end

    if not DoesEntityExist(vehicle) then
        Notify('Không thể spawn xe thuê, hãy liên hệ admin!', 'error')
        return
    end

    SetVehicleNumberPlateText(vehicle, plate)
    exports['cdn-fuel']:SetFuel(vehicle, 100.0)

    local ped = PlayerPedId()
    TaskWarpPedIntoVehicle(ped, vehicle, -1)
    SetVehicleEngineOn(vehicle, true, true, false)

    CreateThread(function()
        local waitTime = 0
        while not IsPedInVehicle(ped, vehicle, false) and waitTime < 3000 do
            Wait(100)
            waitTime = waitTime + 100
        end

        TriggerServerEvent('tommy-trucker:server:rentalVehicleSpawned', plate)

        SendNUIMessage({
            action     = 'rentalSuccess',
            rentalData = {
                plate         = plate,
                vehicle_model = rentalInfo.model,
                expire_time   = rentalInfo.expireUnix,
            },
        })

        Notify(
            ('Xe %s đã sẵn sàng! Chúc lái xe vui vẻ.'):format(string.upper(model)),
            'success', 5000
        )
    end)

    SetModelAsNoLongerNeeded(modelHash)
end)

-- ─── BLIPS ───────────────────────────────────────────────────────────────────

function CreatePickupBlip(coords, isIllegal)
    PickupBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(PickupBlip, 478)
    SetBlipDisplay(PickupBlip, 4)
    SetBlipScale(PickupBlip, 0.8)
    SetBlipColour(PickupBlip, isIllegal and Config.BlipColors.illegal or Config.BlipColors.pickup)
    SetBlipAsShortRange(PickupBlip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(locale('blip_pickup'))
    EndTextCommandSetBlipName(PickupBlip)
end

function CreateDropoffBlip(coords, isIllegal)
    DropoffBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(DropoffBlip, 478)
    SetBlipDisplay(DropoffBlip, 4)
    SetBlipScale(DropoffBlip, 0.8)
    SetBlipColour(DropoffBlip, isIllegal and Config.BlipColors.illegal or Config.BlipColors.dropoff)
    SetBlipAsShortRange(DropoffBlip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(locale('blip_dropoff'))
    EndTextCommandSetBlipName(DropoffBlip)
end

function RemoveBlips()
    if PickupBlip  then RemoveBlip(PickupBlip)  PickupBlip  = nil end
    if DropoffBlip then RemoveBlip(DropoffBlip) DropoffBlip = nil end
end

-- ─── VEHICLE HELPERS ─────────────────────────────────────────────────────────

function IsPlayerBehindVehicle(vehicle)
    local pedCoords = GetEntityCoords(PlayerPedId())
    local vehCoords = GetEntityCoords(vehicle)
    local forward   = GetEntityForwardVector(vehicle)
    local toPlayer  = vector3(pedCoords.x - vehCoords.x, pedCoords.y - vehCoords.y, 0.0)
    local len       = math.sqrt(toPlayer.x ^ 2 + toPlayer.y ^ 2)
    if len == 0 then return false end
    return (forward.x * (toPlayer.x / len) + forward.y * (toPlayer.y / len)) < -0.3
end

function GetDistanceToRearDoor(vehicle)
    local pedCoords  = GetEntityCoords(PlayerPedId())
    local vehCoords  = GetEntityCoords(vehicle)
    local forward    = GetEntityForwardVector(vehicle)
    local min, max   = GetModelDimensions(GetEntityModel(vehicle))
    local halfLen    = (max.y - min.y) / 2
    local rearX      = vehCoords.x - forward.x * halfLen
    local rearY      = vehCoords.y - forward.y * halfLen
    return #(pedCoords - vector3(rearX, rearY, vehCoords.z))
end

function CheckRearDoorsOpen(vehicle)
    return GetVehicleDoorAngleRatio(vehicle, 2) >= 0.1 and GetVehicleDoorAngleRatio(vehicle, 3) >= 0.1
end

-- ─── FIND REGISTERED VEHICLE ─────────────────────────────────────────────────

local function FindRegisteredVehicle(coords, maxDist)
    local closestVehicle, closestDist = nil, maxDist
    for _, v in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(v) and GetPlate(v) == CurrentJob.registeredPlate then
            local dist = #(coords - GetEntityCoords(v))
            if dist < closestDist then
                closestVehicle = v
                closestDist    = dist
            end
        end
    end
    return closestVehicle
end

-- ─── PICKUP ZONE ─────────────────────────────────────────────────────────────

function CheckPickupZone()
    CreateThread(function()
        local pickupTextUI   = false
        local loadTextUI     = false

        while CurrentJob and IsLoadingPhase do
            local sleep     = 500
            local ped       = PlayerPedId()
            local coords    = GetEntityCoords(ped)
            local pickupCoords = CurrentJob.order.pickup
            local dist      = #(coords - pickupCoords)
            local inVehicle = IsPedInAnyVehicle(ped, false)

            if dist < Config.PickupDistance then
                sleep = 0
                DrawMarker(1, pickupCoords.x, pickupCoords.y, pickupCoords.z - 1.0,
                    0, 0, 0, 0, 0, 0, 5.0, 5.0, 1.0, 255, 255, 0, 100, false, true, 2, false, nil, nil, false)

                if not inVehicle and not isBusy then
                    if CarryingBox then
                        if pickupTextUI then lib.hideTextUI() pickupTextUI = false end

                        local vehicle = FindRegisteredVehicle(coords, 10.0)
                        if vehicle then
                            local vehCoords   = GetEntityCoords(vehicle)
                            local vehDist     = GetDistanceToRearDoor(vehicle)
                            local vehAtPickup = #(vehCoords - pickupCoords) < Config.PickupDistance

                            if vehDist < 3.0 and IsPlayerBehindVehicle(vehicle) and CheckRearDoorsOpen(vehicle) and vehAtPickup then
                                local text = string.format('[E] %s (%d/%dkg)', locale('action_load'), CurrentJob.loaded, CurrentJob.totalKg)
                                if not loadTextUI then
                                    lib.showTextUI(text, { position = 'left-center' })
                                    loadTextUI = true
                                end

                                if IsControlJustReleased(0, 38) then
                                    lib.hideTextUI()
                                    loadTextUI = false
                                    PutCargoInVehicle()
                                end
                            else
                                if loadTextUI then lib.hideTextUI() loadTextUI = false end
                            end
                        else
                            if loadTextUI then lib.hideTextUI() loadTextUI = false end
                        end

                    elseif dist < 2.0 then
                        if loadTextUI then lib.hideTextUI() loadTextUI = false end

                        if not pickupTextUI then
                            lib.showTextUI(string.format('[E] %s', locale('action_pickup')), { position = 'left-center' })
                            pickupTextUI = true
                        end

                        if IsControlJustReleased(0, 38) then
                            lib.hideTextUI()
                            pickupTextUI = false
                            PickupCargo()
                        end
                    else
                        if pickupTextUI then lib.hideTextUI() pickupTextUI = false end
                        if loadTextUI   then lib.hideTextUI() loadTextUI   = false end
                    end
                else
                    if pickupTextUI then lib.hideTextUI() pickupTextUI = false end
                    if loadTextUI   then lib.hideTextUI() loadTextUI   = false end
                end
            else
                if pickupTextUI then lib.hideTextUI() pickupTextUI = false end
                if loadTextUI   then lib.hideTextUI() loadTextUI   = false end
            end

            Wait(sleep)
        end

        if pickupTextUI then lib.hideTextUI() end
        if loadTextUI   then lib.hideTextUI() end
    end)
end

RegisterNetEvent('tommy-trucker:client:updateLoading', function(loadedKg, totalKg)
    if CurrentJob then CurrentJob.loaded = loadedKg end
end)

-- ─── PICKUP CARGO ────────────────────────────────────────────────────────────

function PickupCargo()
    if isBusy then return end

    local ped    = PlayerPedId()
    local coords = GetEntityCoords(ped)

    if IsPedInAnyVehicle(ped, false) then Notify(locale('error_in_vehicle'), 'error') return end

    local vehicle = FindRegisteredVehicle(coords, 50.0)
    if not vehicle then
        Notify(locale('error_too_far', { distance = Config.PickupDistance }), 'error')
        return
    end

    local vehCoords = GetEntityCoords(vehicle)
    if #(vehCoords - CurrentJob.order.pickup) > Config.PickupDistance then
        Notify(locale('error_too_far', { distance = Config.PickupDistance }), 'error')
        return
    end

    isBusy = true

    lib.callback('tommy-trucker:server:canLoadCargo', false, function(canLoad, errorMsg)
        if not canLoad then
            isBusy = false
            Notify(errorMsg or locale('error_cannot_load'), 'error')
            return
        end

        lib.requestAnimDict(Config.PickupAnimation.dict)
        TaskPlayAnim(ped, Config.PickupAnimation.dict, Config.PickupAnimation.anim,
            8.0, 8.0, -1, Config.PickupAnimation.flags, 0, false, false, false)

        local success = lib.progressBar({
            duration = Config.LoadTime,
            label    = locale('progress_loading'),
            useWhileDead = false,
            canCancel    = true,
            disable = { move = true, car = true, combat = true },
        })

        ClearPedTasks(ped)

        if success then
            AttachBoxProp()
            lib.requestAnimDict(Config.LoadAnimation.dict)
            TaskPlayAnim(ped, Config.LoadAnimation.dict, Config.LoadAnimation.anim,
                8.0, 8.0, -1, Config.LoadAnimation.flags, 0, false, false, false)
            CarryingBox = true
        else
            TriggerServerEvent('tommy-trucker:server:cancelLoadUnlock', true)
            Notify(locale('error_canceled'), 'error')
        end

        isBusy = false
    end)
end

-- ─── PUT CARGO IN VEHICLE ────────────────────────────────────────────────────

function PutCargoInVehicle()
    if isBusy then return end

    local ped    = PlayerPedId()
    local coords = GetEntityCoords(ped)

    if IsPedInAnyVehicle(ped, false) then Notify(locale('error_in_vehicle'), 'error') return end

    local vehicle = FindRegisteredVehicle(coords, 10.0)
    if not vehicle then
        Notify(locale('error_too_far', { distance = 5 }), 'error')
        return
    end

    if not CheckRearDoorsOpen(vehicle)    then Notify(locale('error_trunk_closed'),  'error') return end
    if not IsPlayerBehindVehicle(vehicle) then Notify(locale('error_not_behind'),    'error') return end

    isBusy = true

    local success = lib.progressBar({
        duration = Config.UnloadTime,
        label    = locale('progress_loaded'),
        useWhileDead = false,
        canCancel    = true,
        disable = { move = true, car = true, combat = true },
    })

    ClearPedTasks(ped)

    if success then
        RemoveBoxProp()
        CarryingBox = false
        TriggerServerEvent('tommy-trucker:server:loadCargo')
    end

    isBusy = false
end

-- ─── ALL LOADED ──────────────────────────────────────────────────────────────

RegisterNetEvent('tommy-trucker:client:allLoaded', function()
    IsLoadingPhase = true
    CurrentJob.loaded = CurrentJob.totalKg
    IsLoadingPhase = false

    if PickupBlip then RemoveBlip(PickupBlip) PickupBlip = nil end

    CreateDropoffBlip(CurrentJob.order.dropoff, CurrentJob.isIllegal)
    SetNewWaypoint(CurrentJob.order.dropoff.x, CurrentJob.order.dropoff.y)
    Notify(locale('info_goto_dropoff'), 'success', 5000)

    CheckDropoffZone()
end)

-- ─── DROPOFF ZONE ────────────────────────────────────────────────────────────

function CheckDropoffZone()
    CreateThread(function()
        local dropTextUI  = false
        local unloadTextUI = false

        while CurrentJob and not IsLoadingPhase do
            local sleep        = 500
            local ped          = PlayerPedId()
            local coords       = GetEntityCoords(ped)
            local dropoffCoords = CurrentJob.order.dropoff
            local dist         = #(coords - dropoffCoords)
            local inVehicle    = IsPedInAnyVehicle(ped, false)

            if dist < Config.DropoffDistance then
                sleep = 0
                DrawMarker(1, dropoffCoords.x, dropoffCoords.y, dropoffCoords.z - 2.0,
                    0, 0, 0, 0, 0, 0, 5.0, 5.0, 1.0, 0, 255, 0, 100, false, true, 2, false, nil, nil, false)

                if not inVehicle and not isBusy then
                    if CarryingBox and dist < 2.0 then
                        if unloadTextUI then lib.hideTextUI() unloadTextUI = false end

                        if not dropTextUI then
                            lib.showTextUI(string.format('[E] %s', locale('action_deliver')), { position = 'left-center' })
                            dropTextUI = true
                        end

                        if IsControlJustReleased(0, 38) then
                            lib.hideTextUI()
                            dropTextUI = false
                            DeliverCargo()
                        end

                    elseif not CarryingBox then
                        if dropTextUI then lib.hideTextUI() dropTextUI = false end

                        local vehicle = FindRegisteredVehicle(coords, 10.0)
                        if vehicle then
                            local vehCoords     = GetEntityCoords(vehicle)
                            local vehDist       = GetDistanceToRearDoor(vehicle)
                            local vehAtDropoff  = #(vehCoords - dropoffCoords) < Config.DropoffDistance

                            if vehDist < 3.0 and IsPlayerBehindVehicle(vehicle) and CheckRearDoorsOpen(vehicle) and vehAtDropoff then
                                local remaining = CurrentJob.totalKg - CurrentJob.unloaded
                                local text      = string.format('[E] %s (%d/%dkg)', locale('action_take'), remaining, CurrentJob.totalKg)

                                if not unloadTextUI then
                                    lib.showTextUI(text, { position = 'left-center' })
                                    unloadTextUI = true
                                end

                                if IsControlJustReleased(0, 38) then
                                    lib.hideTextUI()
                                    unloadTextUI = false
                                    TakeCargoFromVehicle(vehicle)
                                end
                            else
                                if unloadTextUI then lib.hideTextUI() unloadTextUI = false end
                            end
                        else
                            if unloadTextUI then lib.hideTextUI() unloadTextUI = false end
                        end
                    else
                        if dropTextUI   then lib.hideTextUI() dropTextUI   = false end
                        if unloadTextUI then lib.hideTextUI() unloadTextUI = false end
                    end
                else
                    if dropTextUI   then lib.hideTextUI() dropTextUI   = false end
                    if unloadTextUI then lib.hideTextUI() unloadTextUI = false end
                end
            else
                if dropTextUI   then lib.hideTextUI() dropTextUI   = false end
                if unloadTextUI then lib.hideTextUI() unloadTextUI = false end
            end

            Wait(sleep)
        end

        if dropTextUI   then lib.hideTextUI() end
        if unloadTextUI then lib.hideTextUI() end
    end)
end

-- ─── TAKE CARGO FROM VEHICLE ─────────────────────────────────────────────────

function TakeCargoFromVehicle(vehicle)
    if isBusy then return end

    local ped = PlayerPedId()

    if IsPedInAnyVehicle(ped, false)      then Notify(locale('error_in_vehicle'),   'error') return end
    if GetPlate(vehicle) ~= CurrentJob.registeredPlate then Notify(locale('error_wrong_vehicle'), 'error') return end
    if not CheckRearDoorsOpen(vehicle)    then Notify(locale('error_trunk_closed'),  'error') return end
    if not IsPlayerBehindVehicle(vehicle) then Notify(locale('error_not_behind'),    'error') return end

    local vehCoords = GetEntityCoords(vehicle)
    if #(vehCoords - CurrentJob.order.dropoff) > Config.DropoffDistance then
        Notify(locale('error_too_far', { distance = Config.DropoffDistance }), 'error')
        return
    end

    isBusy = true

    lib.callback('tommy-trucker:server:canDeliverCargo', false, function(canDeliver, errorMsg)
        if not canDeliver then
            isBusy = false
            Notify(errorMsg or locale('error_cannot_deliver'), 'error')
            return
        end

        lib.requestAnimDict(Config.LoadAnimation.dict)
        TaskPlayAnim(ped, Config.LoadAnimation.dict, Config.LoadAnimation.anim,
            8.0, 8.0, -1, Config.LoadAnimation.flags, 0, false, false, false)

        local success = lib.progressBar({
            duration = Config.LoadTime,
            label    = locale('progress_taking'),
            useWhileDead = false,
            canCancel    = true,
            disable = { move = true, car = true, combat = true },
        })

        ClearPedTasks(ped)

        if success then
            AttachBoxProp()
            lib.requestAnimDict(Config.LoadAnimation.dict)
            TaskPlayAnim(ped, Config.LoadAnimation.dict, Config.LoadAnimation.anim,
                8.0, 8.0, -1, Config.LoadAnimation.flags, 0, false, false, false)
            CarryingBox = true
        else
            TriggerServerEvent('tommy-trucker:server:cancelLoadUnlock', false)
            Notify(locale('error_canceled'), 'error')
        end

        isBusy = false
    end)
end

-- ─── DELIVER CARGO ───────────────────────────────────────────────────────────

function DeliverCargo()
    if isBusy then return end

    local ped = PlayerPedId()

    if IsPedInAnyVehicle(ped, false) then Notify(locale('error_in_vehicle'), 'error') return end

    isBusy = true

    lib.requestAnimDict(Config.PickupAnimation.dict)
    TaskPlayAnim(ped, Config.PickupAnimation.dict, Config.PickupAnimation.anim,
        8.0, 8.0, -1, Config.PickupAnimation.flags, 0, false, false, false)

    local success = lib.progressBar({
        duration = Config.UnloadTime,
        label    = locale('progress_unloading'),
        useWhileDead = false,
        canCancel    = true,
        disable = { move = true, car = true, combat = true },
    })

    ClearPedTasks(ped)

    if success then
        RemoveBoxProp()
        CarryingBox = false
        TriggerServerEvent('tommy-trucker:server:deliverCargo')
    else
        TriggerServerEvent('tommy-trucker:server:cancelLoadUnlock', false)
    end

    isBusy = false
end

RegisterNetEvent('tommy-trucker:client:updateDelivery', function(unloadedKg, totalKg)
    if CurrentJob then CurrentJob.unloaded = unloadedKg end
end)

-- ─── BOX PROP ────────────────────────────────────────────────────────────────

function AttachBoxProp()
    local ped = PlayerPedId()
    lib.requestModel(Config.BoxProp)
    BoxProp = CreateObject(GetHashKey(Config.BoxProp), 0, 0, 0, true, true, true)
    AttachEntityToEntity(BoxProp, ped, GetPedBoneIndex(ped, Config.BoxBone),
        Config.BoxOffset.x, Config.BoxOffset.y, Config.BoxOffset.z,
        Config.BoxOffset.xRot, Config.BoxOffset.yRot, Config.BoxOffset.zRot,
        true, true, false, true, 1, true)
end

function RemoveBoxProp()
    if BoxProp then DeleteObject(BoxProp) BoxProp = nil end
end

-- ─── DOOR CONTROL THREAD ─────────────────────────────────────────────────────

CreateThread(function()
    local holdTime        = 0
    local requiredHoldTime = 1000
    local lastVehicle     = nil
    local wasHolding      = false

    while true do
        local sleep = 500
        local ped   = PlayerPedId()

        if IsPedInAnyVehicle(ped, false) or not CurrentJob then
            holdTime    = 0
            lastVehicle = nil
            wasHolding  = false
        else
            local coords    = GetEntityCoords(ped)
            local nearZone  = false

            if CurrentJob.order.pickup and #(coords - CurrentJob.order.pickup) < Config.PickupDistance + 10 then nearZone = true end
            if CurrentJob.order.dropoff and #(coords - CurrentJob.order.dropoff) < Config.DropoffDistance + 10 then nearZone = true end

            if nearZone then
                sleep = 0

                local closestVehicle, closestDist = nil, 2.3
                for _, vehicle in ipairs(GetGamePool('CVehicle')) do
                    if DoesEntityExist(vehicle) then
                        local model       = GetEntityModel(vehicle)
                        local vehicleName = string.lower(GetDisplayNameFromVehicleModel(model))
                        if Config.TruckWhitelist[vehicleName] then
                            local d = GetDistanceToRearDoor(vehicle)
                            if d < closestDist then closestVehicle = vehicle closestDist = d end
                        end
                    end
                end

                if closestVehicle and GetPlate(closestVehicle) == CurrentJob.registeredPlate then
                    local vehCoords  = GetEntityCoords(closestVehicle)
                    local isAtPickup  = CurrentJob.order.pickup  and #(vehCoords - CurrentJob.order.pickup)  < Config.PickupDistance
                    local isAtDropoff = CurrentJob.order.dropoff and #(vehCoords - CurrentJob.order.dropoff) < Config.DropoffDistance

                    if (isAtPickup or isAtDropoff) and IsPlayerBehindVehicle(closestVehicle) then
                        local doorsOpen = GetVehicleDoorAngleRatio(closestVehicle, 2) > 0.1
                                      and GetVehicleDoorAngleRatio(closestVehicle, 3) > 0.1
                        local label  = doorsOpen and locale('door_close') or locale('door_open')
                        local fwd    = GetEntityForwardVector(closestVehicle)
                        local dMin, dMax = GetModelDimensions(GetEntityModel(closestVehicle))
                        local dHalf  = (dMax.y - dMin.y) / 2 + 0.5
                        local dPos   = GetEntityCoords(closestVehicle)
                        DrawText3D(
                            dPos.x - fwd.x * dHalf,
                            dPos.y - fwd.y * dHalf,
                            dPos.z + 1.2,
                            '[Giữ H] ' .. label
                        )

                        if IsControlPressed(0, 74) then
                            if lastVehicle ~= closestVehicle then holdTime = 0 lastVehicle = closestVehicle end
                            holdTime   = holdTime + GetFrameTime() * 1000
                            wasHolding = true

                            local progress = math.min(holdTime / requiredHoldTime, 1.0)
                            DrawRect(0.5, 0.95, 0.2 * progress, 0.01, 0, 255, 0, 200)

                            if holdTime >= requiredHoldTime then
                                TriggerServerEvent('tommy-trucker:server:toggleDoors', NetworkGetNetworkIdFromEntity(closestVehicle), doorsOpen)
                                holdTime    = 0
                                lastVehicle = nil
                                Wait(500)
                            end
                        else
                            if wasHolding then holdTime = 0 end
                            wasHolding = false
                        end
                    else
                        holdTime    = 0
                        lastVehicle = nil
                        wasHolding  = false
                    end
                else
                    holdTime    = 0
                    lastVehicle = nil
                    wasHolding  = false
                end
            else
                holdTime    = 0
                lastVehicle = nil
                wasHolding  = false
            end
        end

        Wait(sleep)
    end
end)

RegisterNetEvent('tommy-trucker:client:toggleDoors', function(vehicleNetId, shouldClose)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    if not vehicle or not DoesEntityExist(vehicle) then return end

    if shouldClose then
        SetVehicleDoorShut(vehicle, 2, false)
        SetVehicleDoorShut(vehicle, 3, false)
        Notify(locale('door_closed_notify'), 'success', 2000)
    else
        SetVehicleDoorOpen(vehicle, 2, false, false)
        SetVehicleDoorOpen(vehicle, 3, false, false)
        Notify(locale('door_opened_notify'), 'success', 2000)
    end
end)

-- ─── POLICE CONFISCATE ───────────────────────────────────────────────────────

function PoliceConfiscateCargo(vehicle)
    local ped   = PlayerPedId()
    local netId = NetworkGetNetworkIdFromEntity(vehicle)

    local success = lib.progressBar({
        duration = 8000,
        label    = locale('police_confiscating'),
        useWhileDead = false,
        canCancel    = true,
        disable = { move = true, car = true, combat = true },
        anim = {
            dict  = 'amb@world_human_clipboard@male@idle_a',
            clip  = 'idle_c',
            flag  = 49,
        },
    })

    ClearPedTasks(ped)

    if success then
        lib.callback('tommy-trucker:server:confiscateCargo', false, function(data)
            if not data.success then
                Notify(locale('error_confiscate_failed'), 'error')
                return
            end
            if data.wasIllegal then
                Notify(locale('police_confiscated_illegal'), 'success')
            else
                Notify(locale('police_no_illegal'), 'inform')
            end
        end, netId)
    end
end

-- ─── CLEAR JOB ───────────────────────────────────────────────────────────────

RegisterNetEvent('tommy-trucker:client:clearJob', function(completedPlate)
    local plateToFind = completedPlate or (CurrentJob and CurrentJob.registeredPlate)
    if plateToFind then
        local ped    = PlayerPedId()
        local coords = GetEntityCoords(ped)
        for _, vehicle in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(vehicle) and #(coords - GetEntityCoords(vehicle)) < 50.0 then
                if GetPlate(vehicle) == plateToFind then
                    SetVehicleDoorShut(vehicle, 2, false)
                    SetVehicleDoorShut(vehicle, 3, false)
                    break
                end
            end
        end
    end

    RemoveBlips()
    lib.hideTextUI()
    CurrentJob     = nil
    IsLoadingPhase = true
    isBusy         = false
    RemoveBoxProp()
    CarryingBox    = false
    ClearPedTasks(PlayerPedId())
end)

-- ─── CLEANUP ─────────────────────────────────────────────────────────────────

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    RemoveBlips()
    RemoveBoxProp()
    lib.hideTextUI()
    SetNuiFocus(false, false)
end)