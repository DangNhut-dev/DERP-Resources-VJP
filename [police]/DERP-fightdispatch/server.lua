local cooldowns = {}

RegisterNetEvent('derp-fightdispatch:request', function(coords, street)
    local src = source

    if not coords or type(coords) ~= 'vector3' then return end

    if type(street) ~= 'string' or #street > 64 then
        street = 'Không xác định'
    end

    local now = GetGameTimer()
    if cooldowns[src] and (now - cooldowns[src]) < Config.Cooldown then return end
    cooldowns[src] = now

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return end

    local serverCoords = GetEntityCoords(ped)
    if #(serverCoords.xy - coords.xy) > 50.0 then return end

    exports['lb-tablet']:AddDispatch({
        priority = Config.Priority,
        code = Config.DispatchCode,
        title = Config.DispatchTitle,
        description = Config.DispatchDescription:format(street),
        job = 'police',
        time = Config.DispatchDuration,
        location = {
            label = street,
            coords = { x = serverCoords.x, y = serverCoords.y },
        },
        blip = {
            sprite = 685,
            color = 1,
            size = 1.2,
            shortRange = false,
            label = Config.DispatchTitle,
        },
    })
end)

AddEventHandler('playerDropped', function()
    cooldowns[source] = nil
end)