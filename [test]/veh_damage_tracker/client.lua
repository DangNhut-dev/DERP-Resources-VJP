local snapshots = {}

local function getTrackedPlatesFromGarage()
    local ok, list = pcall(function()
        return exports[Config.GarageResource]:GetTrackedVehiclesForDebug() and
               exports[Config.GarageResource]:GetTrackedVehiclesForDebug() or nil
    end)

    if ok and type(list) == 'table' then
        return list
    end

    return nil
end

local function takeSnapshot(entity)
    if not entity or not DoesEntityExist(entity) then return nil end

    local snap = { tyres = {}, doors = {} }

    for i = 0, 7 do
        if IsVehicleTyreBurst(entity, i, true) then
            snap.tyres[i] = 'gone'
        elseif IsVehicleTyreBurst(entity, i, false) then
            snap.tyres[i] = 'burst'
        else
            snap.tyres[i] = 'ok'
        end
    end

    for i = 0, 5 do
        if DoesVehicleHaveDoor(entity, i) then
            snap.doors[i] = IsVehicleDoorDamaged(entity, i) and 'broken' or 'ok'
        else
            snap.doors[i] = 'nodoor'
        end
    end

    return snap
end

local function diffSnapshots(prev, curr)
    local changes = {}

    for i = 0, 7 do
        if prev.tyres[i] == 'ok' and (curr.tyres[i] == 'burst' or curr.tyres[i] == 'gone') then
            changes[#changes + 1] = ('tyre[%d]:ok->%s'):format(i, curr.tyres[i])
        end
    end

    for i = 0, 5 do
        if prev.doors[i] == 'ok' and curr.doors[i] == 'broken' then
            changes[#changes + 1] = ('door[%d]:ok->broken'):format(i)
        end
    end

    return changes
end

local function getNearestPlayerDistance(coords)
    local nearest = math.huge
    local players = GetActivePlayers()
    for _, pid in ipairs(players) do
        local ped = GetPlayerPed(pid)
        if DoesEntityExist(ped) then
            local d = #(GetEntityCoords(ped) - coords)
            if d < nearest then nearest = d end
        end
    end
    return nearest
end

CreateThread(function()
    Wait(15000)

    while true do
        Wait(Config.SnapshotInterval)

        local tracked = getTrackedPlatesFromGarage()
        if tracked then
            for plate, data in pairs(tracked) do
                if data.state == 'spawned' and data.netId then
                    if NetworkDoesNetworkIdExist(data.netId) then
                        local entity = NetworkGetEntityFromNetworkId(data.netId)

                        if entity and entity ~= 0 and DoesEntityExist(entity) then
                            local coords = GetEntityCoords(entity)
                            local nearestDist = getNearestPlayerDistance(coords)

                            if nearestDist > Config.PlayerNearRadius then
                                local curr = takeSnapshot(entity)

                                if curr then
                                    local prev = snapshots[plate]

                                    if prev then
                                        local changes = diffSnapshots(prev, curr)
                                        if #changes > 0 then
                                            TriggerServerEvent('veh_damage_tracker:reportDamage', plate, data.netId, changes, nearestDist)
                                        end
                                    end

                                    snapshots[plate] = curr
                                end
                            end
                        end
                    end
                end
            end

            for plate in pairs(snapshots) do
                if not tracked[plate] then
                    snapshots[plate] = nil
                end
            end
        end
    end
end)