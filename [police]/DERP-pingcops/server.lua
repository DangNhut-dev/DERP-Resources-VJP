local cooldowns = {}

local function IsOnCooldown(source)
    local now = os.time()
    if cooldowns[source] and (now - cooldowns[source]) < Config.Cooldown then
        return true
    end
    cooldowns[source] = now
    return false
end

local function ValidateCoords(data)
    if type(data) ~= 'table' then return false end
    if type(data.x) ~= 'number' then return false end
    if type(data.y) ~= 'number' then return false end
    if type(data.z) ~= 'number' then return false end
    if type(data.street) ~= 'string' then return false end
    if #data.street > 128 then return false end
    return true
end

RegisterNetEvent('DERP-pingcops:server:ping', function(dispatchType, locationData)
    local src = source

    if dispatchType ~= '13a' and dispatchType ~= '13b' then return end
    if not ValidateCoords(locationData) then return end

    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    local job = player.PlayerData.job
    if job.name ~= Config.Dispatch.job then return end
    if not job.onduty then
        lib.notify(src, { type = 'error', description = 'Bạn phải đang trực ban.' })
        return
    end

    if IsOnCooldown(src) then
        lib.notify(src, { type = 'error', description = ('Đợi: %ds.'):format(Config.Cooldown) })
        return
    end

    local charinfo  = player.PlayerData.charinfo
    local metadata  = player.PlayerData.metadata
    local fullName  = charinfo.firstname .. ' ' .. charinfo.lastname
    local callsign  = metadata.callsign or 'N/A'

    local cfg = Config.Dispatch[dispatchType]

    exports['lb-tablet']:AddDispatch({
        job         = Config.Dispatch.job,
        priority    = cfg.priority,
        code        = cfg.code,
        title       = cfg.title,
        description = cfg.description .. ' | ' .. fullName .. ' | Callsign: ' .. callsign,
        time        = Config.Dispatch.time,
        location    = {
            label  = locationData.street,
            coords = { x = locationData.x, y = locationData.y },
        },
        blip = {
            sprite     = 526,
            color      = 1,
            label      = cfg.title,
            size       = 1.0,
            shortRange = false,
        },
    })
    TriggerClientEvent('DERP-pingcops:client:playSound', -1, locationData)

end)

AddEventHandler('playerDropped', function()
    cooldowns[source] = nil
end)