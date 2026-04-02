if CFG.Framework ~= 'esx' and CFG.DetectedFramework ~= 'esx' then return end

ESX = exports['es_extended']:getSharedObject()  

local data = {}
local playerTimes = {}  
local onlineIds = {} 
local lastSaved = {} 

local function GetPrimaryIdentifier(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id and id:find('^license:') then return id end
    end

    local ids = GetPlayerIdentifiers(src)
    return ids and ids[1] or nil
end

RegisterServerCallback = function(name, cb)
    ESX.RegisterServerCallback(name, cb)
end

RegisterServerCallback('esx:getplayerData', function(source, cb)
    DebugPrint("ESX getplayerData called for source: " .. source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb({})
    end
    
    local identifier = xPlayer.getIdentifier() or GetPrimaryIdentifier(source)
    local accounts = xPlayer.getAccount('bank')

    data.source = source
    data.name = xPlayer.getName()
    data.job = xPlayer.getJob().name
    data.cash = tonumber(xPlayer.getMoney())
    data.bank = accounts.money

    data.gang = CfgGetGang(source)
    data.playTime = FormatPlayTime(playerTimes[identifier] or 0)
    data.lang = Locales[CFG.Locale] or Locales['en']
    
    DebugPrint("ESX data prepared for " .. identifier .. " - PlayTime: " .. (playerTimes[identifier] or 0))

    local s = tostring(source)
    if identifier and not onlineIds[s] then onlineIds[s] = identifier end
    cb(data)
end)

MySQL.ready(function()
    MySQL.Async.fetchAll('SELECT identifier, playtime FROM users', {}, function(result)
        if result and #result > 0 then
            DebugPrint("ESX database results: " .. #result)
            for i = 1, #result, 1 do
                local identifier = result[i].identifier
                local playtime = result[i].playtime or 0  
                
                playerTimes[identifier] = playtime
                lastSaved[identifier] = playtime
                DebugPrint("ESX loaded " .. identifier .. ": " .. playtime .. " seconds")
            end
        end
    end)
end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    local identifier = (xPlayer and xPlayer.getIdentifier and xPlayer.getIdentifier()) or GetPrimaryIdentifier(playerId)

    if not playerTimes[identifier] then
        playerTimes[identifier] = 0 
    end
    if identifier then
        onlineIds[tostring(playerId)] = identifier
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    local identifier = onlineIds[tostring(src)]
    if not identifier then
    identifier = GetPrimaryIdentifier(src)
    end

    if identifier then
        local playtime = playerTimes[identifier] or 0
        MySQL.Async.execute('UPDATE users SET playtime = @playtime WHERE identifier = @identifier', {
            ['@playtime'] = playtime,
            ['@identifier'] = identifier
        }, function(rowsChanged)
            if rowsChanged and rowsChanged > 0 then
                DebugPrint("ESX playtime saved for " .. identifier .. ": " .. playtime)
            end
        end)

        lastSaved[identifier] = playtime
    else
        print(('[WARNING] identifier not found %s in playerDropped'):format(src))
    end
    onlineIds[tostring(src)] = nil
end)

AddEventHandler('esx:playerLogout', function(playerId)
    local identifier = onlineIds[tostring(playerId)]
    if not identifier then
    identifier = GetPrimaryIdentifier(playerId)
    end

    if identifier then
        local playtime = playerTimes[identifier] or 0 
        MySQL.Async.execute('UPDATE users SET playtime = @playtime WHERE identifier = @identifier', {
            ['@playtime'] = playtime,
            ['@identifier'] = identifier
        })

    lastSaved[identifier] = playtime
    else
        print(('[WARNING] identifier not found %s in esx:playerLogout'):format(playerId))
    end
    onlineIds[tostring(playerId)] = nil
end)

CreateThread(function()
    while true do
        Wait(60000)
        local players = GetPlayers()
        for i = 1, #players do
            local pid = tostring(players[i])
            local identifier = onlineIds[pid]
            if identifier then
                local oldTime = playerTimes[identifier] or 0
                playerTimes[identifier] = oldTime + 60
            else
                local found = GetPrimaryIdentifier(tonumber(pid))
                if found then
                    onlineIds[pid] = found
                    local oldTime = playerTimes[found] or 0
                    playerTimes[found] = oldTime + 60
                end
            end
            if (i % 64) == 0 then Wait(0) end 
        end
    end
end)

CreateThread(function()
    local ROTATE_WINDOW_MIN = 5       
    local CHUNK_YIELD = 16         
    local SQL_UPDATE = 'UPDATE users SET playtime = @playtime WHERE identifier = @identifier'
    local rotateIndex = 1
    while true do
        Wait(60000)
        local idList = {}
        for _, identifier in pairs(onlineIds) do
            idList[#idList + 1] = identifier
        end
        local total = #idList
        if total == 0 then
            if CFG.Debug then DebugPrint('ESX auto-save skipped (no online users)') end
            goto continue
        end

        if rotateIndex > total then rotateIndex = 1 end
        local chunkSize = math.max(1, math.ceil(total / ROTATE_WINDOW_MIN))
        local endIndex = math.min(total, rotateIndex + chunkSize - 1)

        local wrote = 0
        local yielded = 0
        for idx = rotateIndex, endIndex do
            local identifier = idList[idx]
            local playtime = playerTimes[identifier] or 0
            if lastSaved[identifier] ~= playtime then
                MySQL.Async.execute(SQL_UPDATE, { ['@playtime'] = playtime, ['@identifier'] = identifier })
                lastSaved[identifier] = playtime
                wrote = wrote + 1
                yielded = yielded + 1
                if (yielded % CHUNK_YIELD) == 0 then Wait(0) end
            end
        end
        if CFG.Debug then
            DebugPrint(('ESX auto-save chunk %d-%d/%d, wrote %d'):format(rotateIndex, endIndex, total, wrote))
        end
        rotateIndex = endIndex + 1
        ::continue::
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        DebugPrint('ESX script stopping, saving all playtime...')
        local count = 0
        for identifier, playtime in pairs(playerTimes) do
            MySQL.Sync.execute('UPDATE users SET playtime = @playtime WHERE identifier = @identifier', {
                ['@playtime'] = playtime,
                ['@identifier'] = identifier
            })
            count = count + 1
            DebugPrint("ESX saved " .. identifier .. ": " .. playtime .. " seconds")
        end
        DebugPrint('ESX saved ' .. count .. ' playtime records before stop')
    end
end)

function FormatPlayTime(seconds)
    local d = math.floor(seconds / 86400)
    local h = math.floor((seconds % 86400) / 3600)
    local m = math.floor((seconds % 3600) / 60)

    local str = ""
    if d > 0 then str = str .. d .. "d " end
    if h > 0 or d > 0 then str = str .. h .. "h " end
    str = str .. m .. "m"
    return str
end

RegisterCommand('checkplaytime', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local identifier = xPlayer.getIdentifier()
        local currentTime = playerTimes[identifier] or 0
        
        MySQL.Async.fetchScalar('SELECT playtime FROM users WHERE identifier = @identifier', {
            ['@identifier'] = identifier
        }, function(dbTime)
            DebugPrint("Player " .. identifier .. ":")
            DebugPrint("  Memory: " .. currentTime .. " seconds (" .. FormatPlayTime(currentTime) .. ")")
            DebugPrint("  Database: " .. (dbTime or 0) .. " seconds (" .. FormatPlayTime(dbTime or 0) .. ")")
        end)
    end
end, true)

