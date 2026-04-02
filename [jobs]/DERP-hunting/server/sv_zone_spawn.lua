-- ============================
--   ZONE ANIMAL SPAWN - SERVER
--   Nhận netId từ leader, validate, broadcast cho toàn nhóm
-- ============================

-- zoneAnimals[netId] = { gid, model, zone }
local zoneAnimals = {}

-- Cooldown chống spam registerZoneAnimal per source
local registerCooldown = {}

-- ============================
--   HELPERS (dùng playerGroup từ sv_group.lua không accessible trực tiếp)
--   Dùng exports hoặc shared event để lấy group info
-- ============================

local function getGroupBySource(src)
    -- Dùng event internal để lấy group data từ sv_group.lua
    -- sv_group expose qua TriggerEvent internal
    local g, gid
    TriggerEvent('DERP-hunting:server:internal:getGroup', src, function(group, groupId)
        g   = group
        gid = groupId
    end)
    return g, gid
end

-- ============================
--   LEADER GỬI NETID SAU KHI SPAWN
-- ============================

RegisterNetEvent('DERP-hunting:server:registerZoneAnimal')
AddEventHandler('DERP-hunting:server:registerZoneAnimal', function(netId, animalModel, zone)
    local src = source

    -- Cooldown chống spam
    local now = GetGameTimer()
    if registerCooldown[src] and (now - registerCooldown[src]) < 500 then return end
    registerCooldown[src] = now

    -- Validate netId
    netId = tonumber(netId)
    if not netId then return end

    -- Validate animalModel có trong Config
    local validModel = false
    for _, a in ipairs(Config.Animals) do
        if a.model == animalModel then validModel = true; break end
    end
    if not validModel then return end

    -- Validate source là leader của nhóm đang active
    local g, gid = getGroupBySource(src)
    if not g or not g.active or g.leader ~= src then return end

    -- Validate mission animals
    local mission = g.mission
    if mission and mission.animals and #mission.animals > 0 then
        local found = false
        for _, ma in ipairs(mission.animals) do
            if ma == animalModel then found = true; break end
        end
        if not found then return end
    end

    zoneAnimals[netId] = { gid = gid, model = animalModel, zone = zone }

    -- Broadcast netId cho tất cả members (bao gồm leader)
    for _, member in ipairs(g.members) do
        TriggerClientEvent('DERP-hunting:client:zoneAnimalRegistered', member, netId)
    end
end)

-- ============================
--   VALIDATE KILL TRONG ZONE (gọi từ sv_main khi AddItem)
--   Thay thế logic inJobZone gửi từ client
-- ============================

function isAnimalNetIdInActiveZone(netId, src)
    netId = tonumber(netId)
    if not netId then return false end
    local data = zoneAnimals[netId]
    if not data then return false end

    local g, gid = getGroupBySource(src)
    if not g or not g.active then return false end
    if data.gid ~= gid then return false end

    return data.model, gid
end

-- ============================
--   CLEANUP KHI JOB KẾT THÚC
-- ============================

AddEventHandler('DERP-hunting:server:internal:jobEnded', function(gid)
    for netId, data in pairs(zoneAnimals) do
        if data.gid == gid then
            zoneAnimals[netId] = nil
        end
    end
end)

-- ============================
--   CLEANUP THEO THỜI GIAN (garbage collection)
-- ============================

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000 * 60 * 5)
        local count = 0
        for _ in pairs(zoneAnimals) do count = count + 1 end
        if count > 500 then
            zoneAnimals = {}
        end
        local now = GetGameTimer()
        for src, t in pairs(registerCooldown) do
            if (now - t) > 5000 then
                registerCooldown[src] = nil
            end
        end
    end
end)