-- Validate player job
local function isAllowed(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false end
    return Config.AllowedJobs[player.PlayerData.job.name] == true
end

-- Lấy danh sách player trong bán kính
local function getPlayersInRange(source, radius)
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then
        -- print('[DEBUG][crimecamera] getPlayersInRange: ped invalid for source ' .. tostring(source))
        return {}
    end
    local coords = GetEntityCoords(ped)
    local players = {}

    for _, playerId in ipairs(GetPlayers()) do
        local pid = tonumber(playerId)
        local targetPed = GetPlayerPed(pid)
        if targetPed and targetPed ~= 0 then
            local targetCoords = GetEntityCoords(targetPed)
            if #(coords - targetCoords) <= radius then
                players[#players + 1] = pid
            end
        end
    end

    -- print(('[DEBUG][crimecamera] getPlayersInRange: found %d players near source %d'):format(#players, source))
    return players
end

-- Lưu ảnh + gửi webhook + tạo item crimeimage
RegisterNetEvent('DERP-crimecamera:server:savePhoto', function(data)
    local src = source
    if not isAllowed(src) then return end

    if type(data) ~= 'table' then return end
    if type(data.label) ~= 'string' or #data.label > 100 or #data.label == 0 then return end
    if type(data.url) ~= 'string' or not data.url:find('^https://') then return end
    if type(data.street) ~= 'string' or #data.street > 200 then return end
    if type(data.time) ~= 'string' or #data.time > 50 then return end
    if type(data.officer) ~= 'string' or #data.officer > 100 then return end
    if type(data.coords) ~= 'table' then return end

    local player = exports.qbx_core:GetPlayer(src)
    local charinfo = player.PlayerData.charinfo
    data.officer = charinfo.firstname .. ' ' .. charinfo.lastname

    local metadata = {
        label       = data.label,
        description = ('Chụp bởi: %s\nVị trí: %s\nThời gian: %s'):format(data.officer, data.street, data.time),
        url         = data.url,
        street      = data.street,
        time        = data.time,
        officer     = data.officer,
    }

    local added = exports.ox_inventory:AddItem(src, 'crimeimage', 1, metadata)
    -- print(('[DEBUG][crimecamera] AddItem crimeimage -> added=%s'):format(tostring(added)))
    if not added then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Túi đầy, không thể lưu ảnh!' })
    end

    local webhook = Config.Webhook
    if webhook and webhook ~= '' and webhook ~= 'WEBHOOK_HERE' then
        local embed = {
            {
                title  = data.label,
                color  = 3447003,
                image  = { url = data.url },
                fields = {
                    { name = 'Sĩ quan',   value = data.officer, inline = true },
                    { name = 'Vị trí',    value = data.street,  inline = true },
                    { name = 'Thời gian', value = data.time,    inline = false },
                },
                footer    = { text = 'DERP Crime Scene Camera' },
                timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            },
        }

        PerformHttpRequest(webhook, function(code)
            if code ~= 200 and code ~= 204 then
                print(('[DERP-crimecamera] Webhook thất bại: HTTP %d'):format(code))
            end
        end, 'POST', json.encode({ embeds = embed }), { ['Content-Type'] = 'application/json' })
    end
end)

-- Đăng ký item máy ảnh (mở chế độ chụp)
exports.qbx_core:CreateUseableItem(Config.Item, function(source)
    if not isAllowed(source) then
        return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Bạn không có quyền sử dụng' })
    end
    TriggerClientEvent('DERP-crimecamera:client:use', source)
end)

exports.ox_inventory:registerHook('usingItem', function(payload)
    if payload.item.name ~= 'crimeimage' then return true end

    local src = payload.source
    local metadata = payload.item.metadata
    if not metadata or type(metadata.url) ~= 'string' or not metadata.url:find('^https://') then return false end

    local photoData = {
        url     = metadata.url,
        label   = metadata.label or '',
        time    = metadata.time or '',
        street  = metadata.street or '',
        officer = metadata.officer or '',
    }

    local nearbyPlayers = getPlayersInRange(src, 5.0)
    for _, pid in ipairs(nearbyPlayers) do
        TriggerClientEvent('DERP-crimecamera:client:showPhoto', pid, photoData)
    end

    return false
end, { itemName = 'crimeimage' })