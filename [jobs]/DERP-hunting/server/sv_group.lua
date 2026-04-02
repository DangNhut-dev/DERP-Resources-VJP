-- ============================
--   GROUP + JOB SYSTEM - SERVER
-- ============================

local groups      = {}
local playerGroup = {}
local cooldowns   = {}
local groupCount  = 0

local MAX_SIZE = Config.Job.maxGroupSize

-- ============================
--   HELPERS
-- ============================

local function newGroupId()
    groupCount = groupCount + 1
    return groupCount
end

local function getGroup(src)
    local gid = playerGroup[src]
    if not gid then return nil, nil end
    return groups[gid], gid
end

local function notifyGroup(gid, notifyData)
    if not groups[gid] then return end
    for _, member in ipairs(groups[gid].members) do
        TriggerClientEvent('ox_lib:notify', member, notifyData)
    end
end

local function removeMemberFromGroup(src)
    local g, gid = getGroup(src)
    if not g then return end

    playerGroup[src] = nil
    TriggerClientEvent('DERP-hunting:client:groupDisbanded', src)

    for i = #g.members, 1, -1 do
        if g.members[i] == src then
            table.remove(g.members, i)
            break
        end
    end

    if #g.members == 0 then
        groups[gid] = nil
        return
    end

    if g.leader == src then
        g.leader = g.members[1]
        TriggerClientEvent('ox_lib:notify', g.leader, { type = 'info', description = 'Bạn trở thành leader nhóm.' })
    end

    for _, member in ipairs(g.members) do
        TriggerClientEvent('DERP-hunting:client:groupUpdated', member, gid, groups[gid])
    end
end

local function randomMission()
    local missions = Config.Job.missions
    if not missions or #missions == 0 then return nil end
    return missions[math.random(#missions)]
end

local function isAnimalCountedForMission(mission, model)
    if not mission.animals or #mission.animals == 0 then return true end
    for _, a in ipairs(mission.animals) do
        if a == model then return true end
    end
    return false
end

-- ============================
--   TẠO NHÓM
-- ============================

RegisterNetEvent('DERP-hunting:server:createGroup')
AddEventHandler('DERP-hunting:server:createGroup', function()
    local src = source
    if playerGroup[src] then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Bạn đã trong nhóm rồi!' })
        return
    end

    local gid = newGroupId()
    groups[gid] = {
        leader  = src,
        members = { src },
        kills   = 0,
        active  = false,
        done    = false,
        mission = nil,
    }
    playerGroup[src] = gid

    TriggerClientEvent('ox_lib:notify', src, { type = 'success', description = 'Đã tạo nhóm. ID nhóm: ' .. gid })
    TriggerClientEvent('DERP-hunting:client:groupUpdated', src, gid, groups[gid])
end)

-- ============================
--   THAM GIA NHÓM
-- ============================

RegisterNetEvent('DERP-hunting:server:joinGroup')
AddEventHandler('DERP-hunting:server:joinGroup', function(gid)
    local src = source
    gid = tonumber(gid)

    if not gid then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'ID nhóm không hợp lệ!' })
        return
    end
    if playerGroup[src] then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Bạn đã trong nhóm rồi!' })
        return
    end

    local g = groups[gid]
    if not g then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Nhóm không tồn tại!' })
        return
    end
    if g.active then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Nhóm đang trong nhiệm vụ!' })
        return
    end
    if #g.members >= MAX_SIZE then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Nhóm đã đầy!' })
        return
    end

    table.insert(g.members, src)
    playerGroup[src] = gid

    local Player = exports['qbx_core']:GetPlayer(src)
    local name   = Player and Player.PlayerData.charinfo.firstname or ('Player ' .. src)
    notifyGroup(gid, { type = 'info', description = name .. ' đã tham gia nhóm.' })

    for _, member in ipairs(g.members) do
        TriggerClientEvent('DERP-hunting:client:groupUpdated', member, gid, groups[gid])
    end
end)

-- ============================
--   RỜI NHÓM
-- ============================

RegisterNetEvent('DERP-hunting:server:leaveGroup')
AddEventHandler('DERP-hunting:server:leaveGroup', function()
    local src = source
    if not playerGroup[src] then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Bạn không trong nhóm nào!' })
        return
    end
    removeMemberFromGroup(src)
    TriggerClientEvent('ox_lib:notify', src, { type = 'info', description = 'Đã rời nhóm.' })
end)

AddEventHandler('playerDropped', function()
    local src = source
    if playerGroup[src] then removeMemberFromGroup(src) end
    cooldowns[src] = nil
end)

-- ============================
--   NHẬN JOB (random mission)
-- ============================

RegisterNetEvent('DERP-hunting:server:acceptJob')
AddEventHandler('DERP-hunting:server:acceptJob', function()
    local src = source
    local g, gid = getGroup(src)

    if not g then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Bạn chưa có nhóm!' })
        return
    end
    if g.leader ~= src then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Chỉ trưởng nhóm mới nhận được!' })
        return
    end
    if g.active then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Nhóm đang trong nhiệm vụ!' })
        return
    end

    -- local now = os.time()
    -- if cooldowns[src] and now < cooldowns[src] then
    --     TriggerClientEvent('ox_lib:notify', src, {
    --         type        = 'error',
    --         description = 'Cooldown còn ' .. (cooldowns[src] - now) .. 's trước khi nhận job tiếp!',
    --     })
    --     return
    -- end

    local mission = randomMission()
    if not mission then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Không có nhiệm vụ nào!' })
        return
    end

    g.active  = true
    g.done    = false
    g.kills   = 0
    g.mission = mission

    local delay = math.random(Config.Job.notifyDelay.min, Config.Job.notifyDelay.max)
    notifyGroup(gid, { type = 'success', description = 'Đang đợi thông tin từ quản lý, hãy đợi...' })

    SetTimeout(delay, function()
        if not groups[gid] or not groups[gid].active then return end
        local m = groups[gid].mission
        notifyGroup(gid, {
            type        = 'inform',
            -- title       = m.label,
            -- description = m.description .. ' | Mục tiêu: ' .. m.targetKills .. ' con | Thưởng: $' .. m.reward .. '/người',
            title       = 'Đã có nhiệm vụ',
            description = 'Hãy di chuyển đến khu vực săn.',
        })
        for _, member in ipairs(groups[gid].members) do
            local isLeader = (member == groups[gid].leader)
            TriggerClientEvent('DERP-hunting:client:jobStarted', member, groups[gid].kills, m.targetKills, m, isLeader)
        end
    end)
end)

-- ============================
--   KILL COUNT
-- ============================

AddEventHandler('DERP-hunting:server:jobKillCount', function(src, animalModel, gid)
    local g = groups[gid]
    if not g or not g.active or g.done or not g.mission then return end
    if not isAnimalCountedForMission(g.mission, animalModel) then return end

    g.kills = g.kills + 1

    for _, member in ipairs(g.members) do
        TriggerClientEvent('DERP-hunting:client:jobKillUpdated', member, g.kills, g.mission.targetKills)
    end

    if g.kills >= g.mission.targetKills then
        g.done = true
        notifyGroup(gid, {
            type        = 'success',
            title       = 'Nhiệm vụ hoàn thành!',
            description = 'Đã săn đủ ' .. g.mission.targetKills .. ' con. Về gặp quản lý để nhận thưởng $' .. g.mission.reward .. '!',
        })
        for _, member in ipairs(g.members) do
            TriggerClientEvent('DERP-hunting:client:groupUpdated', member, gid, groups[gid])
        end
    end
end)

-- ============================
--   NỘP NHIỆM VỤ
-- ============================

RegisterNetEvent('DERP-hunting:server:submitJob')
AddEventHandler('DERP-hunting:server:submitJob', function()
    local src = source
    local g, gid = getGroup(src)

    if not g then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Bạn không trong nhóm nào!' })
        return
    end
    if g.leader ~= src then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Chỉ leader mới nộp nhiệm vụ!' })
        return
    end
    if not g.active then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Không có nhiệm vụ đang chạy!' })
        return
    end
    if not g.done then
        TriggerClientEvent('ox_lib:notify', src, {
            type        = 'error',
            description = 'Chưa đủ thú! ' .. g.kills .. '/' .. g.mission.targetKills,
        })
        return
    end

    local reward = g.mission.reward
    for _, member in ipairs(g.members) do
        local Player = exports['qbx_core']:GetPlayer(member)
        if Player then
            exports['qbx_core']:AddMoney(member, 'cash', reward, 'hunting-job-reward')
            TriggerClientEvent('ox_lib:notify', member, {
                type        = 'success',
                title       = 'Nhận thưởng',
                description = 'Hoàn thành nhiệm vụ! +$' .. reward,
            })
            TriggerClientEvent('DERP-hunting:client:jobEnded', member)
        end
    end

    -- Notify sv_zone_spawn cleanup
    TriggerEvent('DERP-hunting:server:internal:jobEnded', gid)

    -- Notify tất cả members dừng zone spawn
    for _, member in ipairs(g.members) do
        TriggerClientEvent('DERP-hunting:client:stopZoneSpawn', member)
    end

    -- local cooldownSec = math.floor(math.random(Config.Job.cooldownMin, Config.Job.cooldownMax) / 1000)
    -- cooldowns[src] = os.time() + cooldownSec

    g.active  = false
    g.done    = false
    g.kills   = 0
    g.mission = nil

    for _, member in ipairs(g.members) do
        TriggerClientEvent('DERP-hunting:client:groupUpdated', member, gid, groups[gid])
    end
end)

-- ============================
--   SYNC GROUP INFO
-- ============================

RegisterNetEvent('DERP-hunting:server:requestGroupInfo')
AddEventHandler('DERP-hunting:server:requestGroupInfo', function()
    local src = source
    local g, gid = getGroup(src)
    if g then
        TriggerClientEvent('DERP-hunting:client:groupUpdated', src, gid, g)
        if g.active and g.mission then
            local isLeader = (g.leader == src)
            TriggerClientEvent('DERP-hunting:client:jobStarted', src, g.kills, g.mission.targetKills, g.mission, isLeader)
        end
    else
        TriggerClientEvent('DERP-hunting:client:groupUpdated', src, nil, nil)
    end
end)

-- ============================
--   INTERNAL GETTER (dùng bởi sv_zone_spawn.lua)
-- ============================

AddEventHandler('DERP-hunting:server:internal:getGroup', function(src, cb)
    local gid = playerGroup[src]
    if not gid then cb(nil, nil); return end
    cb(groups[gid], gid)
end)