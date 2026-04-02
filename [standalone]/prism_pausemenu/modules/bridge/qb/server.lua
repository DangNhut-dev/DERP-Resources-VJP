if CFG.Framework ~= 'qb' and CFG.DetectedFramework ~= 'qb' then return end

local QBCore = exports['qb-core']:GetCoreObject()

local data = {}
local playerTimes = {}
local lastSaved = {} 

local function GetCitizenId(src)
    local player = QBCore.Functions.GetPlayer(src)
    if player and player.PlayerData and player.PlayerData.citizenid then
        return player.PlayerData.citizenid
    end
    return nil
end

RegisterServerCallback = function(name, cb)
    QBCore.Functions.CreateCallback(name, cb)
end

RegisterServerCallback('qb:getPlayerData', function(source, cb)
    DebugPrint("QB getPlayerData called for source: " .. source)
    local player = QBCore.Functions.GetPlayer(source)
    if not player then
        print("[ERROR] Player not found for source: " .. source)
        return cb({})
    end
    local playerData = player.PlayerData
    local money = playerData.money
    local citizenid = playerData.citizenid
    data.source = source
    data.name = playerData.charinfo.firstname.. " " ..playerData.charinfo.lastname
    data.job = playerData.job.label 
    data.gang = CfgGetGang(source)
    data.cash = money.cash
    data.bank = money.bank
    data.playTime = FormatPlayTime(playerTimes[citizenid] or 0)
    data.lang = Locales[CFG.Locale] or Locales['en']
    DebugPrint("QB data prepared for " .. citizenid .. " - PlayTime: " .. (playerTimes[citizenid] or 0))
    cb(data)
end)

MySQL.ready(function()
    DebugPrint("QB MySQL ready - starting playtime loading...")
    MySQL.Async.fetchAll('SELECT citizenid, playtime FROM players', {}, function(result)
        if result and #result > 0 then
            DebugPrint("QB results from database: " .. #result)
            for i = 1, #result, 1 do
                local citizenid = result[i].citizenid
                local playtime = tonumber(result[i].playtime) or 0 
                playerTimes[citizenid] = playtime
                lastSaved[citizenid] = playtime
                DebugPrint("QB loaded " .. citizenid .. ": " .. playtime .. " seconds")
            end
            if CFG.Debug then
                DebugPrint("QB loaded " .. #result .. " playtime from database")
            end
        else
            print("[WARNING] QB no playtime data found in database or query error")
        end
    end)
end)

AddEventHandler('QBCore:Server:PlayerLoaded', function(player)
    local playerData = player.PlayerData
    local citizenid = playerData.citizenid
    if playerTimes[citizenid] == nil then
        playerTimes[citizenid] = 0
    end
    DebugPrint("QB PlayerLoaded: " .. citizenid .. " playtime: " .. playerTimes[citizenid])
end)

AddEventHandler('QBCore:Server:OnPlayerUnload', function(source)
    local player = QBCore.Functions.GetPlayer(source)
    if player and player.PlayerData then
        local citizenid = player.PlayerData.citizenid
        local playtime = playerTimes[citizenid] or 0
        MySQL.Async.execute('UPDATE players SET playtime = @playtime WHERE citizenid = @citizenid', {
            ['@playtime'] = playtime,
            ['@citizenid'] = citizenid
        })
        lastSaved[citizenid] = playtime
        DebugPrint("QB OnPlayerUnload: Saved " .. citizenid .. " playtime: " .. playtime)
    else
        print(('[WARNING] Player not found %s in QBCore:Server:OnPlayerUnload'):format(source))
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if player and player.PlayerData then
        local citizenid = player.PlayerData.citizenid
        local playtime = playerTimes[citizenid] or 0
        MySQL.Async.execute('UPDATE players SET playtime = @playtime WHERE citizenid = @citizenid', {
            ['@playtime'] = playtime,
            ['@citizenid'] = citizenid
        }, function(rowsChanged)
            if rowsChanged > 0 then
                DebugPrint("QB playtime saved for " .. citizenid .. ": " .. playtime)
            end
        end)
        lastSaved[citizenid] = playtime
    else
        print("[WARNING] QB player not found " .. src .. " in playerDropped")
    end
end)

CreateThread(function()
    while true do
        Wait(60000)
        local players = GetPlayers()
        for i = 1, #players do
            local playerId = players[i]
            local player = QBCore.Functions.GetPlayer(playerId)
            if player and player.PlayerData then
                local citizenid = player.PlayerData.citizenid
                local oldTime = playerTimes[citizenid] or 0
                playerTimes[citizenid] = oldTime + 60
                DebugPrint("QB playtime incremented for " .. citizenid .. ": " .. playerTimes[citizenid])
            end
            if (i % 64) == 0 then Wait(0) end
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        DebugPrint('QB script stopping, saving all playtime...')
        local count = 0
        for citizenid, playtime in pairs(playerTimes) do
            MySQL.Sync.execute('UPDATE players SET playtime = @playtime WHERE citizenid = @citizenid', {
                ['@playtime'] = playtime,
                ['@citizenid'] = citizenid
            })
            count = count + 1
            DebugPrint("QB saved " .. citizenid .. ": " .. playtime .. " seconds")
        end
        DebugPrint('QB saved ' .. count .. ' playtime records before stop')
    end
end)

CreateThread(function()
    local ROTATE_WINDOW_MIN = 5
    local CHUNK_YIELD = 16
    local SQL_UPDATE = 'UPDATE players SET playtime = @playtime WHERE citizenid = @citizenid'
    local rotateIndex = 1
    while true do
        Wait(60000)
        local idList = {}
        for _, playerId in ipairs(GetPlayers()) do
            local player = QBCore.Functions.GetPlayer(playerId)
            if player and player.PlayerData then
                local citizenid = player.PlayerData.citizenid
                idList[#idList + 1] = citizenid
            end
        end
        local total = #idList
        if total == 0 then
            if CFG.Debug then DebugPrint('QB auto-save skipped (no online users)') end
            goto continue
        end
        if rotateIndex > total then rotateIndex = 1 end
        local chunkSize = math.max(1, math.ceil(total / ROTATE_WINDOW_MIN))
        local endIndex = math.min(total, rotateIndex + chunkSize - 1)
        local wrote = 0
        local yielded = 0
        for idx = rotateIndex, endIndex do
            local citizenid = idList[idx]
            local playtime = playerTimes[citizenid] or 0
            if lastSaved[citizenid] ~= playtime then
                MySQL.Async.execute(SQL_UPDATE, { ['@playtime'] = playtime, ['@citizenid'] = citizenid })
                lastSaved[citizenid] = playtime
                wrote = wrote + 1
                yielded = yielded + 1
                DebugPrint("QB auto-save: Saved " .. citizenid .. " playtime: " .. playtime)
                if (yielded % CHUNK_YIELD) == 0 then Wait(0) end
            end
        end
        if CFG.Debug then
            DebugPrint(('QB auto-save chunk %d-%d/%d, wrote %d'):format(rotateIndex, endIndex, total, wrote))
        end
        rotateIndex = endIndex + 1
        ::continue::
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
    local player = QBCore.Functions.GetPlayer(source)
    if player then
        local citizenid = player.PlayerData.citizenid
        local currentTime = playerTimes[citizenid] or 0
        DebugPrint("QB checkplaytime: citizenid=" .. citizenid .. " memory=" .. currentTime)
        MySQL.Async.fetchScalar('SELECT playtime FROM players WHERE citizenid = @citizenid', {
            ['@citizenid'] = citizenid
        }, function(dbTime)
            DebugPrint("QB Player " .. citizenid .. ":")
            DebugPrint("  Memory: " .. currentTime .. " seconds (" .. FormatPlayTime(currentTime) .. ")")
            DebugPrint("  Database: " .. (dbTime or 0) .. " seconds (" .. FormatPlayTime(dbTime or 0) .. ")")
        end)
    end
end, true)

