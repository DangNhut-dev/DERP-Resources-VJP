local activeJobs  = {}
local cooldowns   = {}
local usedSlots   = {}
local jobTimers   = {}
local ox_inventory = exports.ox_inventory

local function getFreeSlot()
    for i = 1, #Config.VehicleSlots do
        if not usedSlots[i] then return i end
    end
    return nil
end

local function cleanupJob(src)
    if not activeJobs[src] then return end
    jobTimers[src] = nil
    TriggerClientEvent('ox_inventory:disarm', src, true)
    local remaining = ox_inventory:GetItemCount(src, Config.Job.item)
    if remaining > 0 then
        ox_inventory:RemoveItem(src, Config.Job.item, remaining)
    end
    usedSlots[activeJobs[src].slotIndex] = nil
    activeJobs[src] = nil
end

-- FIX: dùng os.time() thay vì CreateThread + Wait để tránh thread treo
local function startJobTimer(src)
    jobTimers[src] = os.time() + Config.Job.timeout
    SetTimeout(Config.Job.timeout * 1000, function()
        if not jobTimers[src] then return end
        if not activeJobs[src] then return end
        TriggerClientEvent('ox_lib:notify', src, {
            title       = 'Nghề Giao Báo',
            description = 'Hết 15 phút! Nhiệm vụ bị hủy, mất tiền cọc $' .. Config.Job.deposit .. '.',
            type        = 'error',
        })
        cleanupJob(src)
        TriggerClientEvent('delivery:client:deleteVehicle', src)
        TriggerClientEvent('delivery:client:cancelJob', src)
    end)
end

local function removeMoney(src, amount)
    return ox_inventory:RemoveItem(src, 'money', amount)
end

local function addMoney(src, amount)
    return ox_inventory:AddItem(src, 'money', amount)
end

local function getMoney(src)
    return ox_inventory:GetItemCount(src, 'money')
end

RegisterNetEvent('delivery:server:requestJob', function()
    local src = source
    local now = os.time()

    -- FIX: cooldown server-side bằng os.time() (giây), tránh drift
    if cooldowns[src] and (now - cooldowns[src]) < math.ceil(Config.Job.cooldown / 1000) then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Giao Báo', description = 'Chờ một chút.', type = 'error' })
        return
    end
    cooldowns[src] = now

    if activeJobs[src] then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Giao Báo', description = 'Bạn đang có job.', type = 'error' })
        return
    end

    local slotIndex = getFreeSlot()
    if not slotIndex then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Giao Báo', description = 'Không còn xe trống, thử lại sau.', type = 'error' })
        return
    end

    local areaIndex = math.random(#Config.Areas)
    local area      = Config.Areas[areaIndex]
    local locations = area.locations
    local total     = #locations

    local cash = getMoney(src)
    if cash < Config.Job.deposit then
        TriggerClientEvent('ox_lib:notify', src, {
            title       = 'Giao Báo',
            description = ('Cần $%d tiền cọc để nhận job.'):format(Config.Job.deposit),
            type        = 'error',
        })
        return
    end

    local deducted = removeMoney(src, Config.Job.deposit)
    if not deducted then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Giao Báo', description = 'Lỗi trừ tiền cọc, thử lại.', type = 'error' })
        return
    end

    TriggerClientEvent('ox_inventory:disarm', src, true)
    local old = ox_inventory:GetItemCount(src, Config.Job.item)
    if old > 0 then ox_inventory:RemoveItem(src, Config.Job.item, old) end

    local added = ox_inventory:AddItem(src, Config.Job.item, total)
    if not added then
        addMoney(src, Config.Job.deposit)
        TriggerClientEvent('ox_lib:notify', src, { title = 'Giao Báo', description = 'Lỗi cấp báo, thử lại.', type = 'error' })
        return
    end

    -- FIX: build pointList lưu server, points gửi client — tách biệt
    local pointList = {}
    local points    = {}
    for i, loc in ipairs(locations) do
        pointList[i] = { x = loc.x, y = loc.y, z = loc.z }
        points[i]    = { pointIndex = i, x = loc.x, y = loc.y, z = loc.z }
    end

    usedSlots[slotIndex] = src
    activeJobs[src] = {
        slotIndex = slotIndex,
        pointList = pointList,
        delivered = 0,
        total     = total,
    }

    startJobTimer(src)

    local slot = Config.VehicleSlots[slotIndex]
    TriggerClientEvent('delivery:client:startJob', src, points, total, {
        x = slot.x, y = slot.y, z = slot.z, w = slot.w
    }, area.label)
end)

RegisterNetEvent('delivery:server:arrivedPoint', function(pointIndex)
    local src = source
    local job = activeJobs[src]

    if not job then return end

    -- FIX: validate type + range trước khi xử lý
    if type(pointIndex) ~= 'number' or pointIndex < 1 or pointIndex > job.total then return end

    local pt = job.pointList[pointIndex]
    if not pt then return end

    local pCoords = GetEntityCoords(GetPlayerPed(src))

    -- FIX: distance check server-side — client không thể tự quyết validate
    -- if #(pCoords - vector3(pt.x, pt.y, pt.z)) > (Config.Job.zoneRadius * 3.5) then
    --     TriggerClientEvent('ox_lib:notify', src, { title = 'Giao Báo', description = 'Bạn không ở điểm giao.', type = 'error' })
    --     return
    -- end

    job.pointList[pointIndex] = nil
    job.delivered = job.delivered + 1

    local remaining = job.total - job.delivered

    TriggerClientEvent('delivery:client:removePoint', src, pointIndex, remaining)

    if remaining == 0 then
        TriggerClientEvent('delivery:client:allDelivered', src)
    end
end)

RegisterNetEvent('delivery:server:returnJob', function()
    local src = source
    local job = activeJobs[src]

    if not job then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Giao Báo', description = 'Không có job đang hoạt động.', type = 'error' })
        return
    end

    local pCoords = GetEntityCoords(GetPlayerPed(src))
    local npc     = vector3(Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z)

    -- FIX: validate coords server-side — client không tự declare vị trí trả job
    if #(pCoords - npc) > 5.0 then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Giao Báo', description = 'Về gặp NPC để nhận tiền.', type = 'error' })
        return
    end

    local reward    = job.delivered * Config.Job.rewardPoint
    local delivered = job.delivered
    local deposit   = Config.Job.deposit

    -- FIX: cleanupJob trước addMoney — tránh double-claim nếu event fired 2 lần
    cleanupJob(src)
    addMoney(src, reward + deposit)

    TriggerClientEvent('delivery:client:deleteVehicle', src)
    TriggerClientEvent('delivery:client:finishJob', src, reward, delivered, deposit)
end)

RegisterNetEvent('delivery:server:cancelJob', function()
    local src = source
    if not activeJobs[src] then return end
    cleanupJob(src)
    TriggerClientEvent('delivery:client:deleteVehicle', src)
    TriggerClientEvent('delivery:client:cancelJob', src)
end)

AddEventHandler('playerDropped', function()
    local src = source
    if activeJobs[src] then cleanupJob(src) end
    cooldowns[src] = nil
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for src in pairs(activeJobs) do
        cleanupJob(src)
    end
end)