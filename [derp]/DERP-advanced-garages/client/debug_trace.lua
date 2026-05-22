local _SetVehicleTyreBurst = SetVehicleTyreBurst
function SetVehicleTyreBurst(veh, index, onRim, p3)
    if veh and DoesEntityExist(veh) then
        local plate = GetVehicleNumberPlateText(veh) or '?'
        print(('[NATIVE-TRACE] SetVehicleTyreBurst plate=%s index=%s onRim=%s p3=%s'):format(
            plate, tostring(index), tostring(onRim), tostring(p3)))
        print(debug.traceback('', 2))
    end
    return _SetVehicleTyreBurst(veh, index, onRim, p3)
end

local _SetVehicleDoorBroken = SetVehicleDoorBroken
function SetVehicleDoorBroken(veh, doorIdx, deleteDoor)
    if veh and DoesEntityExist(veh) then
        local plate = GetVehicleNumberPlateText(veh) or '?'
        print(('[NATIVE-TRACE] SetVehicleDoorBroken plate=%s doorIdx=%s delete=%s'):format(
            plate, tostring(doorIdx), tostring(deleteDoor)))
        print(debug.traceback('', 2))
    end
    return _SetVehicleDoorBroken(veh, doorIdx, deleteDoor)
end

local _SmashVehicleWindow = SmashVehicleWindow
function SmashVehicleWindow(veh, idx)
    if veh and DoesEntityExist(veh) then
        local plate = GetVehicleNumberPlateText(veh) or '?'
        print(('[NATIVE-TRACE] SmashVehicleWindow plate=%s idx=%s'):format(plate, tostring(idx)))
        print(debug.traceback('', 2))
    end
    return _SmashVehicleWindow(veh, idx)
end

local _RemoveVehicleWindow = RemoveVehicleWindow
function RemoveVehicleWindow(veh, idx)
    if veh and DoesEntityExist(veh) then
        local plate = GetVehicleNumberPlateText(veh) or '?'
        print(('[NATIVE-TRACE] RemoveVehicleWindow plate=%s idx=%s'):format(plate, tostring(idx)))
        print(debug.traceback('', 2))
    end
    return _RemoveVehicleWindow(veh, idx)
end

local _BreakOffVehicleWheel = BreakOffVehicleWheel
function BreakOffVehicleWheel(veh, wheelIdx, a, b, c, d)
    if veh and DoesEntityExist(veh) then
        local plate = GetVehicleNumberPlateText(veh) or '?'
        print(('[NATIVE-TRACE] BreakOffVehicleWheel plate=%s wheelIdx=%s'):format(plate, tostring(wheelIdx)))
        print(debug.traceback('', 2))
    end
    return _BreakOffVehicleWheel(veh, wheelIdx, a, b, c, d)
end

local _SetVehicleWheelXOffset = SetVehicleWheelXOffset
function SetVehicleWheelXOffset(veh, wheelIdx, offset)
    if veh and DoesEntityExist(veh) and offset and math.abs(offset) > 5.0 then
        local plate = GetVehicleNumberPlateText(veh) or '?'
        print(('[NATIVE-TRACE] SetVehicleWheelXOffset plate=%s wheelIdx=%s offset=%s'):format(
            plate, tostring(wheelIdx), tostring(offset)))
        print(debug.traceback('', 2))
    end
    return _SetVehicleWheelXOffset(veh, wheelIdx, offset)
end

local _SetVehicleTyresCanBurst = SetVehicleTyresCanBurst
function SetVehicleTyresCanBurst(veh, canBurst)
    if veh and DoesEntityExist(veh) then
        local plate = GetVehicleNumberPlateText(veh) or '?'
        print(('[NATIVE-TRACE] SetVehicleTyresCanBurst plate=%s canBurst=%s'):format(
            plate, tostring(canBurst)))
        print(debug.traceback('', 2))
    end
    return _SetVehicleTyresCanBurst(veh, canBurst)
end

-- Trace event apply status từ server
RegisterNetEvent('derp:applyVehicleStatus', function(netId, statusData)
    print(('[EVENT-TRACE] derp:applyVehicleStatus netId=%s data=%s'):format(
        tostring(netId), json.encode(statusData or {})))
end)

print('[NATIVE-TRACE] Debug trace loaded (client)')

-- Trace tất cả event apply status / props từ server
local function dumpEvent(eventName, ...)
    local args = {...}
    local netId = args[1]
    local payload = args[2]
    print(('[EVENT-TRACE] %s netId=%s payload=%s'):format(
        eventName, tostring(netId), json.encode(payload or {})))
end

RegisterNetEvent('derp:applyVehicleStatus', function(...) dumpEvent('derp:applyVehicleStatus', ...) end)
RegisterNetEvent('derp:applyVehicleProps', function(...) dumpEvent('derp:applyVehicleProps', ...) end)
RegisterNetEvent('derp:applyVehicleState', function(...) dumpEvent('derp:applyVehicleState', ...) end)
RegisterNetEvent('derp:lockStreamedVehicle', function(...) dumpEvent('derp:lockStreamedVehicle', ...) end)
RegisterNetEvent('DERP-advanced-garages:client:requestVehicleStatus', function(...)
    dumpEvent('DERP-advanced-garages:client:requestVehicleStatus', ...)
end)

-- Trace tất cả statebag change liên quan đến xe
AddStateBagChangeHandler('persistentStatus', '', function(bagName, key, value, _, replicated)
    print(('[STATEBAG-TRACE] persistentStatus bag=%s value=%s replicated=%s'):format(
        bagName, json.encode(value or {}), tostring(replicated)))
    print(debug.traceback('', 2))
end)

AddStateBagChangeHandler('freshGarageSpawn', '', function(bagName, key, value)
    print(('[STATEBAG-TRACE] freshGarageSpawn bag=%s value=%s'):format(bagName, tostring(value)))
end)

AddStateBagChangeHandler('pendingMods', '', function(bagName, key, value)
    print(('[STATEBAG-TRACE] pendingMods bag=%s value=%s'):format(
        bagName, json.encode(value or {})))
end)

-- Trace khi entity được stream in
AddEventHandler('entityStreamIn', function(entity)
    if GetEntityType(entity) == 2 then
        local plate = GetVehicleNumberPlateText(entity) or '?'
        local netId = NetworkGetNetworkIdFromEntity(entity)
        print(('[STREAM-TRACE] entityStreamIn vehicle plate=%s netId=%s entity=%s'):format(
            plate, tostring(netId), tostring(entity)))
    end
end)

-- Watchdog: theo dõi state lốp/cửa/kính của tất cả xe quanh player trong 30s
CreateThread(function()
    local trackedVehicles = {}
    local startTime = GetGameTimer()

    while GetGameTimer() - startTime < 30000 do
        local pool = GetGamePool('CVehicle')
        for _, veh in ipairs(pool) do
            if DoesEntityExist(veh) then
                local plate = GetVehicleNumberPlateText(veh)
                if plate then plate = plate:gsub('%s+', '') end

                if not trackedVehicles[veh] then
                    trackedVehicles[veh] = {
                        plate = plate,
                        tyres = {},
                        doors = {},
                        windows = {},
                    }
                    for i = 0, 5 do trackedVehicles[veh].tyres[i] = false end
                    for i = 0, 5 do trackedVehicles[veh].doors[i] = false end
                    for i = 0, 7 do trackedVehicles[veh].windows[i] = true end
                end

                local data = trackedVehicles[veh]

                for i = 0, 5 do
                    local gone = IsVehicleTyreBurst(veh, i, true)
                    local burst = IsVehicleTyreBurst(veh, i, false)
                    local state = gone and 'GONE' or (burst and 'BURST' or false)
                    if state ~= data.tyres[i] then
                        print(('[WATCHDOG] T+%dms plate=%s TYRE[%d] %s -> %s'):format(
                            GetGameTimer() - startTime, data.plate or '?', i,
                            tostring(data.tyres[i]), tostring(state)))
                        data.tyres[i] = state
                    end
                end

                for i = 0, 5 do
                    local broken = IsVehicleDoorDamaged(veh, i)
                    if broken ~= data.doors[i] then
                        print(('[WATCHDOG] T+%dms plate=%s DOOR[%d] -> broken=%s'):format(
                            GetGameTimer() - startTime, data.plate or '?', i, tostring(broken)))
                        data.doors[i] = broken
                    end
                end

                for i = 0, 7 do
                    local intact = IsVehicleWindowIntact(veh, i)
                    if intact ~= data.windows[i] then
                        print(('[WATCHDOG] T+%dms plate=%s WINDOW[%d] intact=%s'):format(
                            GetGameTimer() - startTime, data.plate or '?', i, tostring(intact)))
                        data.windows[i] = intact
                    end
                end
            end
        end
        Wait(50)
    end

    print('[WATCHDOG] === 30s trace ended ===')
end)

print('[NATIVE-TRACE] Extended debug trace loaded')