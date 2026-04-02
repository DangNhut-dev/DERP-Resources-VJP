-- server.lua
-- Requires in server.cfg:
--   set ox:txAdminNotifications 1
--   set txAdmin-hideDefaultAnnouncement 1
--   set txAdmin-hideDefaultScheduledRestartWarning 1

local cooldowns = {}
local COOLDOWN  = 5000

-- Check if source has admin permission
local function IsAdmin(source)
    for _, group in ipairs(Config.AdminGroups) do
        if IsPlayerAceAllowed(source, 'group.' .. group) then
            return true
        end
    end
    return false
end

-- Check and set cooldown
local function CheckCooldown(source)
    local now = GetGameTimer()
    if cooldowns[source] and (now - cooldowns[source]) < COOLDOWN then
        return false
    end
    cooldowns[source] = now
    return true
end

-- Intercept txAdmin announcement → forward to custom NUI
AddEventHandler('txAdmin:events:announcement', function(eventData)
    local message = tostring(eventData.message or '')
    if message == '' then return end
    TriggerClientEvent('derp-announce:send', -1, {
        message = message,
        time    = Config.DefaultTime
    })
end)

-- server.lua

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    local seconds = tonumber(eventData.secondsRemaining) or 30
    local minutes = math.floor(seconds / 60)

    local message
    if minutes >= 1 then
        message = 'Server sẽ khởi động lại sau ' .. minutes .. ' phút'
    else
        message = 'Server sẽ khởi động lại sau ' .. seconds .. ' giây'
    end

    TriggerClientEvent('derp-announce:send', -1, {
        message = message,
        time    = Config.DefaultTime
    })
end)

-- Admin requests to open UI
RegisterNetEvent('derp-announce:requestAdminUI', function()
    local src = source
    if not IsAdmin(src) then return end
    TriggerClientEvent('derp-announce:openAdmin', src)
end)

-- Admin sends announcement to all players
RegisterNetEvent('derp-announce:create', function(data)
    local src = source

    if not IsAdmin(src) then return end
    if not CheckCooldown(src) then return end
    if type(data) ~= 'table' then return end

    local message = tostring(data.message or ''):gsub('^%s+', ''):gsub('%s+$', '')
    if message == '' or #message > 500 then return end

    local time = math.min(math.max(math.floor(tonumber(data.time) or Config.DefaultTime), 3), 120)

    TriggerClientEvent('derp-announce:send', -1, { message = message, time = time })
end)

-- Cleanup on player drop
AddEventHandler('playerDropped', function()
    cooldowns[source] = nil
end)