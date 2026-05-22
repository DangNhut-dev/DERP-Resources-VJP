local _TriggerClientEvent = TriggerClientEvent
function TriggerClientEvent(eventName, target, ...)
    if eventName == 'derp:applyVehicleStatus' or eventName == 'derp:applyVehicleState'
       or eventName == 'derp:applyVehicleProps'
       or eventName == 'DERP-advanced-garages:client:requestVehicleStatus' then
        local args = {...}
        print(('[SV-EVENT-TRACE] TriggerClientEvent event=%s target=%s args=%s'):format(
            eventName, tostring(target), json.encode(args)))
        print(debug.traceback('', 2))
    end
    return _TriggerClientEvent(eventName, target, ...)
end

RegisterNetEvent('DERP-advanced-garages:server:receiveVehicleStatus', function(plate, netId, data)
    local src = source
    print(('[SV-EVENT-TRACE] receiveVehicleStatus src=%s plate=%s netId=%s data=%s'):format(
        tostring(src), tostring(plate), tostring(netId), json.encode(data or {})))
end)

RegisterNetEvent('DERP-advanced-garages:server:storeVehicle', function(plate, garageName, vehicleData, netId)
    local src = source
    print(('[SV-EVENT-TRACE] storeVehicle src=%s plate=%s garage=%s netId=%s status=%s'):format(
        tostring(src), tostring(plate), tostring(garageName), tostring(netId),
        json.encode(vehicleData and vehicleData.status or {})))
end)

print('[NATIVE-TRACE] Debug trace loaded (server)')