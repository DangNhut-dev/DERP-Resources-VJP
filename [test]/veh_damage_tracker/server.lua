local lastLogTime = {}

local function writeLogFile(line)
    local stamp = os.date('%Y-%m-%d %H:%M:%S')
    local entry = ('[%s] %s\n'):format(stamp, line)
    SaveResourceFile(GetCurrentResourceName(), Config.LogFile, entry, -1)
    print('[veh_damage_tracker] ' .. entry:gsub('\n$', ''))
end

local function getStartedResources()
    local num = GetNumResources()
    local list = {}
    for i = 0, num - 1 do
        local name = GetResourceByFindIndex(i)
        if name and GetResourceState(name) == 'started' then
            list[#list + 1] = name
        end
    end
    return list
end

local function shouldLog(plate)
    local now = os.time()
    if not lastLogTime[plate] or (now - lastLogTime[plate]) >= Config.LogThrottle then
        lastLogTime[plate] = now
        return true
    end
    return false
end

RegisterNetEvent('veh_damage_tracker:reportDamage', function(plate, netId, changes, nearestDist)
    local src = source
    if not plate or not changes or type(changes) ~= 'table' or #changes == 0 then return end

    if not shouldLog(plate) then return end

    local resources = getStartedResources()
    local line = ('plate=%s netId=%s nearestPlayer=%.1fm reporter=%s changes=[%s]'):format(
        tostring(plate),
        tostring(netId),
        tonumber(nearestDist) or -1,
        tostring(src),
        table.concat(changes, ',')
    )

    writeLogFile(line)
    writeLogFile(('  started_resources: %s'):format(table.concat(resources, ', ')))
end)

-- lib = lib or exports.ox_lib:_register()

CreateThread(function()
    while true do
        Wait(300000)
        local stale = os.time() - (Config.LogThrottle * 10)
        for plate, t in pairs(lastLogTime) do
            if t < stale then lastLogTime[plate] = nil end
        end
    end
end)

print('^2[veh_damage_tracker]^7 Started - waiting for client reports')