-- server.lua

local dutyCache = {} -- [source] = citizenid

RegisterNetEvent('DERP-business:toggleDuty', function(businessKey)
    local source = source

    if type(businessKey) ~= 'string' then return end

    local config = Config.Businesses[businessKey]
    if not config then return end

    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    if player.PlayerData.job.name ~= config.job then return end

    local newDuty = not player.PlayerData.job.onduty
    player.Functions.SetJobDuty(newDuty)

    if newDuty then
        dutyCache[source] = player.PlayerData.citizenid
    else
        dutyCache[source] = nil
    end

    TriggerClientEvent('DERP-business:dutyToggled', source, newDuty, config.label)
end)

AddEventHandler('playerDropped', function()
    local source = source
    local citizenid = dutyCache[source]
    if not citizenid then return end

    MySQL.update(
        'UPDATE players SET job = JSON_SET(job, "$.onduty", false) WHERE citizenid = ?',
        { citizenid }
    )

    dutyCache[source] = nil
end)