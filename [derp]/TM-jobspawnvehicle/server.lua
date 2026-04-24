local QBX = exports.qbx_core

local playerVehicles = {}

local function generatePlate()
    return 'DUTY' .. tostring(math.random(1000, 9999))
end

local function cleanupVehicleEntity(netId)
    if not netId then return end
    local entity = NetworkGetEntityFromNetworkId(netId)
    if entity and entity ~= 0 and DoesEntityExist(entity) then
        DeleteEntity(entity)
    end
end

local function findVehicleConfig(job, model)
    local jobData = Config.NPCs[job]
    if not jobData then return nil end
    for _, v in ipairs(jobData.vehicles) do
        if v.model == model then return v end
    end
    return nil
end

local function playerHasGrade(player, vehicleCfg)
    if not vehicleCfg then return false end
    local gradeLevel = player.PlayerData.job.grade and player.PlayerData.job.grade.level or 0

    if type(vehicleCfg.grade) == 'table' then
        for _, g in ipairs(vehicleCfg.grade) do
            if gradeLevel == g then return true end
        end
        return false
    end

    return gradeLevel >= (tonumber(vehicleCfg.grade) or 0)
end

lib.callback.register('TM-jobspawnvehicle:server:requestSpawn', function(source, model)
    local player = QBX:GetPlayer(source)
    if not player then return { success = false, reason = 'noplayer' } end

    local citizenid = player.PlayerData.citizenid
    local job = player.PlayerData.job.name
    local onduty = player.PlayerData.job.onduty

    if not onduty then
        return { success = false, reason = 'notonduty' }
    end

    local jobData = Config.NPCs[job]
    if not jobData then
        return { success = false, reason = 'nojob' }
    end

    if playerVehicles[citizenid] then
        cleanupVehicleEntity(playerVehicles[citizenid].netId)
        playerVehicles[citizenid] = nil
    end

    local vehicleCfg = findVehicleConfig(job, model)
    if not vehicleCfg then
        return { success = false, reason = 'invalidmodel' }
    end

    if not playerHasGrade(player, vehicleCfg) then
        return { success = false, reason = 'nograde' }
    end

    local spawn = jobData.vehicleSpawn
    if not spawn then
        return { success = false, reason = 'nospawn' }
    end

    local hash = joaat(model)
    local veh = CreateVehicleServerSetter(hash, 'automobile', spawn.x, spawn.y, spawn.z, spawn.w)

    if not veh or veh == 0 then
        return { success = false, reason = 'spawnfail' }
    end

    local timeout = 0
    while not DoesEntityExist(veh) and timeout < 50 do
        Wait(20)
        timeout = timeout + 1
    end

    if not DoesEntityExist(veh) then
        return { success = false, reason = 'notexist' }
    end

    local plate = generatePlate()
    local netId = NetworkGetNetworkIdFromEntity(veh)

    playerVehicles[citizenid] = {
        netId = netId,
        job = job,
        plate = plate,
        source = source,
    }

    return {
        success = true,
        netId = netId,
        plate = plate,
    }
end)

RegisterNetEvent('TM-jobspawnvehicle:server:returnVehicle', function()
    local src = source
    local player = QBX:GetPlayer(src)
    if not player then return end

    local citizenid = player.PlayerData.citizenid
    local data = playerVehicles[citizenid]

    if not data then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = 'Bạn không có xe nào được spawn!',
        })
        return
    end

    cleanupVehicleEntity(data.netId)
    playerVehicles[citizenid] = nil

    TriggerClientEvent('ox_lib:notify', src, {
        type = 'success',
        description = 'Xe đã được trả thành công!',
    })
end)

RegisterNetEvent('QBCore:Server:OnJobUpdate', function(src, job)
    local player = QBX:GetPlayer(src)
    if not player then return end

    local citizenid = player.PlayerData.citizenid
    local data = playerVehicles[citizenid]

    if data and data.job ~= (job and job.name) then
        cleanupVehicleEntity(data.netId)
        playerVehicles[citizenid] = nil
    end
end)

RegisterNetEvent('QBCore:Server:SetDuty', function(src, duty)
    local player = QBX:GetPlayer(src)
    if not player then return end

    if duty then return end

    local citizenid = player.PlayerData.citizenid
    local data = playerVehicles[citizenid]

    if data then
        cleanupVehicleEntity(data.netId)
        playerVehicles[citizenid] = nil
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    local player = QBX:GetPlayer(src)
    if not player then return end

    local citizenid = player.PlayerData.citizenid
    local data = playerVehicles[citizenid]

    if data then
        cleanupVehicleEntity(data.netId)
        playerVehicles[citizenid] = nil
    end
end)

lib.addCommand('checkjobvehicles', {
    help = 'Check all spawned job vehicles',
    restricted = 'group.admin',
}, function(source)
    print('========== JOB VEHICLES ==========')
    for cid, data in pairs(playerVehicles) do
        print(('CID: %s | Job: %s | NetID: %s | Plate: %s'):format(cid, data.job, data.netId, data.plate))
    end
    print('==================================')
end)