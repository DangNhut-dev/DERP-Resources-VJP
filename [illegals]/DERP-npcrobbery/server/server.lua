local QBX         = exports.qbx_core
local playerCooldowns = {}

lib.callback.register('derp_npcrobbery:server:checkCooldown', function(source)
    local src = source
    local now = GetGameTimer()
    if playerCooldowns[src] and playerCooldowns[src] > now then
        return false
    end
    playerCooldowns[src] = now + Config.PlayerCooldown
    return true
end)

RegisterNetEvent('derp_npcrobbery:server:robZone', function(zoneId)
    local src  = source
    local zone = Config.Zones[zoneId]
    if not zone then return end

    local xPlayer = QBX:GetPlayer(src)
    if not xPlayer then return end

    local reward = Config.ZoneReward
    local cash   = math.random(reward.cashMin, reward.cashMax)
    exports.ox_inventory:AddItem(src, 'cash', cash)

    TriggerClientEvent('ox_lib:notify', src, {
        title       = zone.label,
        description = 'Tìm được $' .. cash,
        type        = 'success',
    })

    if math.random(100) <= reward.itemChance then
        local roll  = math.random(100)
        local accum = 0
        for _, v in ipairs(reward.items) do
            accum = accum + v.chance
            if roll <= accum then
                exports.ox_inventory:AddItem(src, v.item, 1)
                TriggerClientEvent('ox_lib:notify', src, {
                    title       = 'Tìm được đồ',
                    description = v.item,
                    type        = 'success',
                })
                break
            end
        end
    end

    local allZones = #Config.Zones
    local done     = 0
end)

RegisterNetEvent('derp_npcrobbery:server:dispatch', function(coords, streetLabel)
    local src = source
    if GetResourceState('lb-tablet') ~= 'started' then return end
    if not coords then return end
    streetLabel = streetLabel or 'Không xác định'

    exports['lb-tablet']:AddDispatch({
        priority    = 'medium',
        code        = '10-30',
        title       = 'Cướp Người',
        description = 'Phát hiện hành vi cướp giật tại ' .. streetLabel,
        location    = {
            label  = streetLabel,
            coords = vec2(coords.x, coords.y),
        },
        time   = 120,
        job    = 'police',
        fields = {
            { icon = 'fas fa-person', label = 'Loại', value = 'Cướp người đi đường' },
            { icon = 'fas fa-map-marker-alt', label = 'Vị trí', value = streetLabel },
        },
        blip = {
            sprite = 153,
            color  = 1,
            size   = 1.5,
            label  = '10-30 Cướp Người',
        },
    })
end)

AddEventHandler('playerDropped', function()
    playerCooldowns[source] = nil
end)