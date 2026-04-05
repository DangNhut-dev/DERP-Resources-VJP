---@type table<string, number>
local levels = {}

MySQL.ready(function()
    local data = MySQL.query.await('SELECT * FROM `derp-fishing`')

    for _, entry in ipairs(data) do
        levels[entry.user_identifier] = entry.xp
    end
end)

local function save()
    local query = 'UPDATE `derp-fishing` SET xp = ? WHERE user_identifier = ?'
    local parameters = {}
    local size = 0

    for identifier, level in pairs(levels) do
        size += 1
        parameters[size] = {
            level,
            identifier
        }
    end

    if size > 0 then
        print('Saving player progress.')
        MySQL.prepare.await(query, parameters)
    end
end

lib.cron.new('*/10 * * * *', save)
AddEventHandler('txAdmin:events:serverShuttingDown', save)

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    if eventData.secondsRemaining ~= 60 then return end

	save()
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == cache.resource then
		save()
	end
end)

local function createPlayer(identifier)
    levels[identifier] = 0
    MySQL.insert.await('INSERT INTO `derp-fishing` (user_identifier, xp) VALUES(?, ?)', { identifier, 0 })
end

RegisterNetEvent('derp-fishing:requestLevel', function()
    local source = source
    local player = Framework.getPlayerFromId(source)

    if not player then return end

    local identifier = player:getIdentifier()

    if not levels[identifier] then
        createPlayer(identifier)
    end

    TriggerClientEvent('derp-fishing:updateLevel', source, levels[identifier])
end)

function AddPlayerLevel(player, amount)
    local identifier = player:getIdentifier()
    local oldLevel = math.floor(levels[identifier] / Config.xpPerLevel) + 1

    levels[identifier] = levels[identifier] + amount

    local newLevel = math.floor(levels[identifier] / Config.xpPerLevel) + 1

    if newLevel > oldLevel then
        TriggerClientEvent('derp-fishing:showNotification', player.source, locale('unlocked_level'), 'success')
    end

    TriggerClientEvent('derp-fishing:updateLevel', player.source, levels[identifier])
end

function GetPlayerLevel(player)
    return math.floor(levels[player:getIdentifier()] / Config.xpPerLevel) + 1
end