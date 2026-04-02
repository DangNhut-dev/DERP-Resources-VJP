if (Config.Dispatch == 'auto' and not checkResource('lb-tablet')) or (Config.Dispatch ~= 'auto' and Config.Dispatch ~= 'lb-tablet') then
    return
end

while not Bridge do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Dispatch] Loaded: lb-tablet')
end

Bridge.Dispatch = {}

--@param data: table
--@param data.title: string
--@param data.code: string
--@param data.icon?: string
--@param data.blip?: [scale: number, sprite: number, category: number, color: number, hidden: boolean, priority: number, short: boolean, alpha: number, name: string]
--@param data.priority?: 'low' | 'medium' | 'high'
--@param data.maxOfficers?: number [maximum number of officers that can answer the alert]
--@param data.time?: number [time in minutes how long the alert should be active]
--@param data.notify?: number [notify time]

Bridge.Dispatch.SendAlert = function(playerId, data)
    local plyPed = GetPlayerPed(playerId)
    local plyCoords = GetEntityCoords(plyPed)

    -- print(('[Dispatch Debug] priority type: %s, value: %s'):format(type(data.priority), tostring(data.priority)))
    -- print(('[Dispatch Debug] time type: %s, value: %s'):format(type(data.time), tostring(data.time)))
    
    local priority = tostring(data.priority or 'low')
    if priority == 'normal' then priority = 'low' end
    if priority == 'risk' then priority = 'high' end
    if priority ~= 'low' and priority ~= 'medium' and priority ~= 'high' then
        priority = 'low'
    end
    data.priority = priority
    -- print(('[Dispatch Debug] AFTER convert priority: %s'):format(tostring(data.priority)))

    data.time = tonumber(data.time) or 5

    if data.job and type(data.job) == 'table' then
        for i = 1, #data.job do
            local payload = {
                priority = data.priority or 'low',
                code = data.code,
                title = data.title,
                description = ('%s - %s'):format(data.code, data.title),
                location = {label = data.street or '', coords = vec2(plyCoords.x, plyCoords.y)},
                time = data.time * 60,
                job = data.job[i],
                blip = {
                    sprite = (data.blip and data.blip.sprite) or 1,
                    size = (data.blip and data.blip.scale) or 1.2,
                    color = (data.blip and data.blip.color) or 3,
                    shortRange = true,
                    label = data.title or 'No Title',
                    flashes = (data.blip and data.blip.flashes) or false,
                }
            }
            -- print('[Dispatch Debug] Full payload (loop): ' .. json.encode(payload))
            exports["lb-tablet"]:AddDispatch(payload)
        end
    else
        local payload = {
            priority = data.priority or 'low',
            code = data.code,
            title = data.title,
            description = ('%s - %s'):format(data.code, data.title),
            location = {label = data.street or '', coords = vec2(plyCoords.x, plyCoords.y)},
            time = data.time * 60,
            job = data.job or 'police',
            blip = {
                sprite = (data.blip and data.blip.sprite) or 1,
                size = (data.blip and data.blip.scale) or 1.2,
                color = (data.blip and data.blip.color) or 3,
                shortRange = true,
                label = data.title or 'No Title',
                flashes = (data.blip and data.blip.flashes) or false,
            }
        }
        -- print('[Dispatch Debug] Full payload: ' .. json.encode(payload))
        exports["lb-tablet"]:AddDispatch(payload)
    end
end

RegisterNetEvent('p_bridge/server/dispatch/sendAlert', function(data)
    Bridge.Dispatch.SendAlert(source, data)
end)