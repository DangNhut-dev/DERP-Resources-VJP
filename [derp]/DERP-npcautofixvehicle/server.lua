local QBCore = exports['qb-core']:GetCoreObject()

local npcBusy = {}
local cachedMechOnDuty = false

local function hasMechanicOnDuty()
    local players = QBCore.Functions.GetPlayers()
    for _, src in ipairs(players) do
        local Player = QBCore.Functions.GetPlayer(src)
        if Player and Player.PlayerData and Player.PlayerData.job then
            local job = Player.PlayerData.job
            if job.name == Config.MechanicJob then
                local onduty = job.onduty or job.duty
                if onduty then
                    return true
                end
            end
        end
    end
    return false
end

local function recalcDuty()
    local ok, res = pcall(hasMechanicOnDuty)
    cachedMechOnDuty = (ok and res) or false
    GlobalState[Config.MechanicOnDutyStateKey] = cachedMechOnDuty
end

CreateThread(function()
    GlobalState[Config.MechanicOnDutyStateKey] = false
    for _, cfg in ipairs(Config.NPCs) do
        GlobalState['DERO_npcautofix_busy_' .. cfg.id] = false
        npcBusy[cfg.id] = false
    end

    Wait(5000)
    recalcDuty()
    while true do
        Wait(15000)
        recalcDuty()
    end
end)

AddEventHandler('QBCore:Server:PlayerLoaded',   function() recalcDuty() end)
AddEventHandler('QBCore:Server:OnPlayerUnload', function() recalcDuty() end)
RegisterNetEvent('QBCore:Server:OnJobUpdate',   function() recalcDuty() end)
RegisterNetEvent('QBCore:Server:SetDuty',       function() recalcDuty() end)

-- Validate allowedJobs
local function hasAllowedJob(Player, allowedJobs)
    if not allowedJobs then return true end
    local job = Player.PlayerData and Player.PlayerData.job
    if not job or not job.name then return false end
    local minGrade = allowedJobs[job.name]
    if minGrade == nil then return false end
    local grade = 0
    local g = job.grade
    if type(g) == 'table' then
        grade = g.level or g.grade or 0
    elseif type(g) == 'number' then
        grade = g
    end
    return grade >= (tonumber(minGrade) or 0)
end

-- Tìm NPC config theo id
local function getNpcCfg(id)
    for _, c in ipairs(Config.NPCs) do
        if c.id == id then return c end
    end
    return nil
end

-- Tìm xe gần trung tâm zone nhất, trong radius
local function getVehicleInZone(zone)
    local center = zone.coords
    local radius = zone.radius
    local best, bestDist = nil, radius
    local pool = GetGamePool('CVehicle')
    for _, v in ipairs(pool) do
        if DoesEntityExist(v) then
            local d = #(GetEntityCoords(v) - center)
            if d < bestDist then
                bestDist = d
                best = v
            end
        end
    end
    return best
end

RegisterNetEvent('DERO_npcautofix:requestRepair', function(npcId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if cachedMechOnDuty then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Thợ lưu động',
            description = 'Hiện đang có thợ máy trực, vui lòng gọi họ.',
            type = 'error'
        })
        return
    end

    local cfg = getNpcCfg(npcId)
    if not cfg then return end

    if not hasAllowedJob(Player, cfg.allowedJobs) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Thợ lưu động',
            description = 'Bạn không có quyền gọi thợ này.',
            type = 'error'
        })
        return
    end

    if npcBusy[npcId] then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Thợ lưu động',
            description = 'Thợ đang bận, vui lòng đợi.',
            type = 'error'
        })
        return
    end

    -- Tìm xe trong zone
    local veh = getVehicleInZone(cfg.zone)
    if not veh or veh == 0 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Thợ lưu động',
            description = 'Không có xe trong khu vực sửa chữa.',
            type = 'error'
        })
        return
    end

    local price = cfg.price or 100
    local cash = Player.Functions.GetMoney('cash') or 0
    if cash < price then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Thợ lưu động',
            description = ('Bạn không đủ tiền ($%d).'):format(price),
            type = 'error'
        })
        return
    end

    Player.Functions.RemoveMoney('cash', price, ('npc-repair-%s'):format(npcId))

    npcBusy[npcId] = true
    GlobalState['DERO_npcautofix_busy_' .. npcId] = true

    local vehNet = NetworkGetNetworkIdFromEntity(veh)
    TriggerClientEvent('DERO_npcautofix:doRepair', src, npcId, vehNet, price, cfg.repairType)
end)

-- Client báo sửa xong -> release busy
RegisterNetEvent('DERO_npcautofix:repairDone', function(npcId)
    local src = source
    npcBusy[npcId] = false
    GlobalState['DERO_npcautofix_busy_' .. npcId] = false
end)

RegisterNetEvent('DERO_npcautofix:resetServicing', function(vehNet, resetData)
    local src = source
    if not vehNet or not resetData then return end
    local veh = NetworkGetEntityFromNetworkId(vehNet)
    if not DoesEntityExist(veh) then return end
    Entity(veh).state:set('servicingData', resetData, true)
end)