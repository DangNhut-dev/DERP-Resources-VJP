local activeJobs   = {}
local cooldowns    = {}
local ox_inventory = exports.ox_inventory

local function isSlotOccupied(slotCoords)
    for _, veh in ipairs(GetAllVehicles()) do
        local pos = GetEntityCoords(veh)
        if #(pos - vector3(slotCoords.x, slotCoords.y, slotCoords.z)) < 2.0 then
            return true
        end
    end
    return false
end

local function getFreeSlot()
    local count = #Config.VehicleSlots
    local indices = {}
    for i = 1, count do indices[i] = i end
    for i = count, 2, -1 do
        local j = math.random(i)
        indices[i], indices[j] = indices[j], indices[i]
    end
    for _, i in ipairs(indices) do
        if not isSlotOccupied(Config.VehicleSlots[i]) then return i end
    end
    return nil
end

local function getRandomPoint(lastIndex)
    local count = #Config.Locations
    if count == 0 then return nil, nil end
    if count == 1 then return 1, Config.Locations[1] end
    local idx
    repeat
        idx = math.random(count)
    until idx ~= lastIndex
    local pt = Config.Locations[idx]
    return idx, { x = pt.x, y = pt.y, z = pt.z }
end

local function cleanupJob(src)
    if not activeJobs[src] then return end
    activeJobs[src] = nil
end

local function removeMoney(src, amount)
    return ox_inventory:RemoveItem(src, 'money', amount)
end

local function addMoney(src, amount)
    return ox_inventory:AddItem(src, 'money', amount)
end

RegisterNetEvent('giaopizza:server:requestJob', function()
    local src = source
    local now = os.time()

    if cooldowns[src] and (now - cooldowns[src]) < math.ceil(Config.Job.cooldown / 1000) then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Giao Pizza', description = 'Chờ một chút.', type = 'error' })
        return
    end
    cooldowns[src] = now

    if activeJobs[src] then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Giao Pizza', description = 'Bạn đang có job.', type = 'error' })
        return
    end

    if #Config.Locations == 0 then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Giao Pizza', description = 'Server chưa cấu hình điểm giao.', type = 'error' })
        return
    end

    local slotIndex = getFreeSlot()
    if not slotIndex then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Giao Pizza', description = 'Không còn chỗ trống, thử lại sau.', type = 'error' })
        return
    end

    if ox_inventory:GetItemCount(src, 'money') < Config.Job.vehicleRent then
        TriggerClientEvent('ox_lib:notify', src, {
            title       = 'Giao Pizza',
            description = ('Cần $%d tiền thuê xe để nhận job.'):format(Config.Job.vehicleRent),
            type        = 'error',
        })
        return
    end

    if not removeMoney(src, Config.Job.vehicleRent) then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Giao Pizza', description = 'Lỗi trừ tiền thuê xe, thử lại.', type = 'error' })
        return
    end

    local plate       = ('PIZ%05d'):format(src % 99999)
    local ptIndex, pt = getRandomPoint(0)

    activeJobs[src] = {
        plate          = plate,
        netId          = nil,
        totalDelivered = 0,
        accumulatedPay = 0,
        lastPtIndex    = ptIndex,
        currentPt      = pt,
        vehicleReady   = false,
        hasPizza       = false,
    }

    local slot = Config.VehicleSlots[slotIndex]
    TriggerClientEvent('giaopizza:client:startJob', src,
        { x = slot.x, y = slot.y, z = slot.z, w = slot.w },
        pt,
        plate
    )
end)

RegisterNetEvent('giaopizza:server:vehicleSpawned', function(netId, plate)
    local src = source
    local job = activeJobs[src]
    if not job then return end
    if job.plate ~= plate then return end
    if job.vehicleReady then return end
    if type(netId) ~= 'number' or netId <= 0 then return end

    job.vehicleReady = true
    job.netId = netId

    -- Set owner statebag để qbx_vehiclekeys HasKeys() nhận ra
    local Player = exports.qbx_core:GetPlayer(src)
    if Player then
        SetTimeout(500, function()
            local vehEnt = NetworkGetEntityFromNetworkId(netId)
            if DoesEntityExist(vehEnt) then
                Entity(vehEnt).state:set('owner', Player.PlayerData.citizenid, true)
            end
        end)
    end
end)

-- Lấy pizza: chỉ set flag, không động inventory
RegisterNetEvent('giaopizza:server:takePizza', function()
    local src = source
    local job = activeJobs[src]
    if not job or not job.vehicleReady then return end


    if job.hasPizza then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Giao Pizza', description = 'Đang cầm pizza, đi giao trước!', type = 'inform',
        })
        return
    end

    job.hasPizza = true
    TriggerClientEvent('giaopizza:client:pizzaTaken', src)
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Giao Pizza', description = 'Đã lấy pizza!', type = 'success',
    })
end)

-- Giao pizza: kiểm tra flag
RegisterNetEvent('giaopizza:server:arrivedPoint', function()
    local src = source
    local job = activeJobs[src]
    if not job then return end

    local pt      = job.currentPt
    local pCoords = GetEntityCoords(GetPlayerPed(src))

    if #(pCoords - vector3(pt.x, pt.y, pt.z)) > Config.Job.validRadius then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Giao Pizza', description = 'Bạn không ở điểm giao.', type = 'error' })
        return
    end

    if not job.hasPizza then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Giao Pizza', description = 'Chưa lấy pizza!', type = 'error',
        })
        return
    end

    job.hasPizza       = false
    job.totalDelivered = job.totalDelivered + 1
    local earn = math.random(Config.Job.rewardMin, Config.Job.rewardMax)
    job.accumulatedPay = job.accumulatedPay + earn

    local nextIndex, nextPt = getRandomPoint(job.lastPtIndex)
    job.lastPtIndex = nextIndex
    job.currentPt   = nextPt

    TriggerClientEvent('giaopizza:client:nextPoint', src, job.totalDelivered, job.accumulatedPay, nextPt)
end)

RegisterNetEvent('giaopizza:server:returnJob', function()
    local src = source
    local job = activeJobs[src]

    if not job then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Giao Pizza', description = 'Không có job đang hoạt động.', type = 'error' })
        return
    end

    local pCoords = GetEntityCoords(GetPlayerPed(src))
    local npc     = vector3(Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z)

    if #(pCoords - npc) > 5.0 then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Giao Pizza', description = 'Về gặp NPC để nhận tiền.', type = 'error' })
        return
    end

    local delivered = job.totalDelivered
    local reward    = job.accumulatedPay

    cleanupJob(src)

    if reward > 0 then addMoney(src, reward) end

    TriggerClientEvent('giaopizza:client:deleteVehicle', src)
    TriggerClientEvent('giaopizza:client:finishJob', src, reward, delivered)
end)

RegisterNetEvent('giaopizza:server:cancelJob', function()
    local src = source
    if not activeJobs[src] then return end
    cleanupJob(src)
    TriggerClientEvent('giaopizza:client:deleteVehicle', src)
    TriggerClientEvent('giaopizza:client:cancelJob', src)
end)

AddEventHandler('playerDropped', function()
    local src = source
    if activeJobs[src] then cleanupJob(src) end
    cooldowns[src] = nil
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for src in pairs(activeJobs) do cleanupJob(src) end
end)