RESCB("derp_skills:server:getPlayerData",function(source,cb)
    local src = source

    MySQL.Async.fetchAll('SELECT * FROM derp_skills WHERE player = @player', { ['@player'] = GetIdentifier(src)}, function(result)
        result = result[1]
        if result then
            local data = json.decode(result.skills)
            cb(data)
        else
            MySQL.Async.execute("INSERT INTO derp_skills(player,skills) VALUES (@player,@skills)", {
                ["@player"] = GetIdentifier(src),
                ["@skills"] = json.encode({['Stamina'] = 0, ['Running'] = 0, ['Driving'] = 0, ['Strength'] = 0, ['Swimming'] = 0, ['Shooting'] = 0})
            }, function(rowsChanged)
            end)
            cb({['Stamina'] = 0, ['Running'] = 0, ['Driving'] = 0, ['Strength'] = 0, ['Swimming'] = 0, ['Shooting'] = 0})
        end
    end)
end)

RegisterServerEvent('derp_skills:server:UpdateSkill')
AddEventHandler('derp_skills:server:UpdateSkill', function(Skills)
    local src     = source
    local xPlayer = GETPFI(src)
    if not xPlayer then return end

    local job = xPlayer.PlayerData.job.name
    local mod = Config.JobModifiers[job]
    local cap = mod and mod.MaxCap or 100

    local validated = {}
    for k, v in pairs(Skills) do
        if Config.Skills.SkillTypes[k] ~= nil then
            validated[k] = math.max(0, math.min(math.floor(tonumber(v) or 0), cap))
        end
    end

    MySQL.Async.execute(
        'UPDATE derp_skills SET skills = @skills WHERE player = @player',
        {['@player'] = GetIdentifier(src), ['@skills'] = json.encode(validated)},
        nil
    )
end)