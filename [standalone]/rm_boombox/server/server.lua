local totalBoomboxCount, playerBoomboxCounts, boomboxes, isStandalone, toNumber, setEntityOrphanMode

local function spawnPersistedBoombox(record)
    local boomboxCfg = cfg.boomboxes[record.bType]
    if not boomboxCfg then return end
    local model = joaat(boomboxCfg.propModel)
    local entity = CreateObjectNoOffset(model, record.coords.x, record.coords.y, record.coords.z, true, true, false)
    if not DoesEntityExist(entity) then
        madCore.debug(("[persistence] failed to spawn boombox %s"):format(record.id))
        return
    end
    SetEntityHeading(entity, record.heading)
    FreezeEntityPosition(entity, true)
    setEntityOrphanMode(entity, 2)
    local netId = NetworkGetNetworkIdFromEntity(entity)
    boomboxes[record.id] = {
        data = {
            netId = netId,
            owner = record.owner,
            disableOwner = cfg.options.interactAllPlayers,
            bType = record.bType
        },
        player = {
            fullscreen = false,
            loop = false,
            playing = true,
            volume = boomboxCfg.maxVolume
        },
        queue = record.queue or {}
    }
    totalBoomboxCount = totalBoomboxCount + 1
    SetTimeout(500, function()
        if not boomboxes[record.id] then return end
        if not DoesEntityExist(entity) then return end
        Entity(entity).state:set("updateBoombox", {
            data = boomboxes[record.id],
            boomboxId = record.id
        }, true)
    end)
end

CreateThread(function()
    while not RmBoomboxPersistence do Wait(50) end
    Wait(1000)
    local records = RmBoomboxPersistence.loadAll()
    for i = 1, #records do
        spawnPersistedBoombox(records[i])
    end
    madCore.debug(("[persistence] restored %d boombox(es)"):format(#records))
end)

totalBoomboxCount = 0
playerBoomboxCounts = {}
boomboxes = {}
isStandalone = string.upper(cfg.framework.name) == "STANDALONE"
toNumber = tonumber
setEntityOrphanMode = SetEntityOrphanMode
if not setEntityOrphanMode then
    function setEntityOrphanMode(A0_2, A1_2)
    end
end

CreateThread(function()
    while true do
        if madCore then
            break
        end
        Wait(100)
    end
    if not isStandalone then
        for itemName, boomboxCfg in pairs(cfg.boomboxes) do
            madCore.usableItem(itemName, function(playerId)
                local Player = madCore.getPlayer(playerId)
                if playerBoomboxCounts[playerId] and playerBoomboxCounts[playerId] >= cfg.options.individualBoomboxLimit then
                    return Player.notification(madCore.getPhrase("boombox_individual_limit"))
                end
                if totalBoomboxCount >= cfg.options.serverBoomboxLimit then
                    return Player.notification(madCore.getPhrase("boombox_server_limit"))
                end
                if cfg.options.userList and next(cfg.options.userList) then
                    local hasAccess = false
                    for _, identifier in ipairs(GetPlayerIdentifiers(playerId)) do
                        if cfg.options.userList[identifier] then
                            hasAccess = true
                            break
                        end
                    end
                    if not hasAccess then
                        return Player.notification(madCore.getPhrase("boombox_only_use_vip_members"))
                    end
                end
                if not canPlayerUseBoombox(playerId) then
                    return Player.notification(madCore.getPhrase("cant_use_boombox"))
                end
                TriggerClientEvent("boombox:client:placeBoombox", playerId, itemName)
            end)
        end
    end
end)

function uuid()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return string.gsub(template, "[xy]", function(c)
        local v
        if "x" == c then
            v = math.random(0, 15)
        else
            v = math.random(8, 11)
        end
        return string.format("%x", v)
    end)
end

function extractVideoId(url)
    local id = url:match("v=([^&]+)")
    if not id then
        id = url:match("youtu%.be/([^?&]+)")
    end
    return id
end

function parseISO8601Duration(duration)
    local hours = duration:match("(%d+)H")
    if not hours then
        hours = "0"
    end
    local minutes = duration:match("(%d+)M")
    if not minutes then
        minutes = "0"
    end
    local seconds = duration:match("(%d+)S")
    if not seconds then
        seconds = "0"
    end
    local total = toNumber(hours) * 3600
    total = total + toNumber(minutes) * 60
    total = total + toNumber(seconds)
    return total
end

function getUrlDetails(url, callback)
    local videoId = extractVideoId(url)
    if not videoId then
        return callback(false)
    end
    local apiKey = cfg.options.youtubeApiKey
    if "" == apiKey or not apiKey then
        return callback(false)
    end
    local requestUrl = ("https://www.googleapis.com/youtube/v3/videos?part=snippet,contentDetails,statistics&id=%s&key=%s"):format(videoId, apiKey)
    PerformHttpRequest(requestUrl, function(statusCode, responseText, responseHeaders)
        if 200 ~= statusCode or not responseText then
            return callback(false)
        end
        local decoded = json.decode(responseText)
        if decoded then
            if decoded.items then
                if #decoded.items > 0 then
                    local item = decoded.items[1]
                    local thumbnails = item.snippet.thumbnails
                    if not thumbnails then
                        thumbnails = {}
                    end
                    local thumbnailUrl
                    if thumbnails.high and thumbnails.high.url then
                        thumbnailUrl = thumbnails.high.url
                    elseif thumbnails.default and thumbnails.default.url then
                        thumbnailUrl = thumbnails.default.url
                    else
                        thumbnailUrl = ""
                    end
                    local result = {}
                    result.url = url
                    result.title = item.snippet.title
                    result.author = item.snippet.channelTitle
                    result.thumbnail = thumbnailUrl
                    result.timestamp = os.time()
                    result.duration = parseISO8601Duration(item.contentDetails.duration)
                    local viewCount
                    if item.statistics and item.statistics.viewCount then
                        viewCount = item.statistics.viewCount
                    else
                        viewCount = 0
                    end
                    result.viewCount = viewCount
                    local likeCount
                    if item.statistics and item.statistics.likeCount then
                        likeCount = item.statistics.likeCount
                    else
                        likeCount = 0
                    end
                    result.likeCount = likeCount
                    callback(result)
                end
            end
        else
            callback(false)
        end
    end, "GET", "", {})
end

RegisterServerEvent("boombox:server:updatePosition", function(data)
    if not data then return end
    if not boomboxes[data.boomboxId] then
        return madCore.debug("[updatePosition] -> boombox does not exist")
    end
    local Player = madCore.getPlayer(source)
    if not Player then return end
    if not boomboxes[data.boomboxId].data.disableOwner then
        if boomboxes[data.boomboxId].data.owner ~= Player.identifier then
            return madCore.debug("[updatePosition] -> boombox does not belong to player")
        end
    end
    if type(data.coords) ~= "vector3" then
        if type(data.coords) == "table" and data.coords.x and data.coords.y and data.coords.z then
            data.coords = vector3(data.coords.x + 0.0, data.coords.y + 0.0, data.coords.z + 0.0)
        else
            return madCore.debug("[updatePosition] -> invalid coords")
        end
    end
    local heading = tonumber(data.heading) or 0.0
    local entity = NetworkGetEntityFromNetworkId(boomboxes[data.boomboxId].data.netId)
    if not DoesEntityExist(entity) then
        return madCore.debug("[updatePosition] -> entity does not exist")
    end
    RmBoomboxPersistence.save(
        data.boomboxId,
        boomboxes[data.boomboxId].data.owner,
        boomboxes[data.boomboxId].data.bType,
        data.coords,
        heading,
        boomboxes[data.boomboxId].queue or {}
    )
end)

RegisterServerEvent("boombox:server:placeBoombox", function(data)
    local playerId = source
    if not data then return end
    local entity = NetworkGetEntityFromNetworkId(data.netId)
    if not DoesEntityExist(entity) then
        return madCore.debug("entity does not exist")
    end
    local boomboxId = uuid()
    if boomboxes[boomboxId] then
        return madCore.debug("boombox id already exists")
    end
    local Player = madCore.getPlayer(playerId)
    local boomboxCfg = cfg.boomboxes[data.bType]
    if boomboxCfg.shouldRemoveItem then
        if not isStandalone then
            if not Player.hasItem(data.bType, 1) then
                if DoesEntityExist(entity) then DeleteEntity(entity) end
                return Player.notification(madCore.getPhrase("dont_have_boombox"))
            end
            Player.removeItem(data.bType, 1)
        end
    end
    totalBoomboxCount = totalBoomboxCount + 1
    boomboxes[boomboxId] = {
        data = {
            netId = data.netId,
            owner = Player.identifier,
            disableOwner = cfg.options.interactAllPlayers,
            bType = data.bType
        },
        player = {
            fullscreen = false,
            loop = false,
            playing = true,
            volume = cfg.boomboxes[data.bType].maxVolume
        },
        queue = {}
    }
    setEntityOrphanMode(entity, 2)
    if not playerBoomboxCounts[playerId] then
        playerBoomboxCounts[playerId] = 0
    end
    playerBoomboxCounts[playerId] = playerBoomboxCounts[playerId] + 1
    local entityCoords = (data.coords and vector3(data.coords.x + 0.0, data.coords.y + 0.0, data.coords.z + 0.0)) or GetEntityCoords(entity)
    local entityHeading = data.heading or GetEntityHeading(entity)
    RmBoomboxPersistence.save(boomboxId, Player.identifier, data.bType, entityCoords, entityHeading, {})
    Entity(entity).state:set("updateBoombox", {
        data = boomboxes[boomboxId],
        boomboxId = boomboxId
    }, true)
end)

RegisterServerEvent("boombox:server:enterUrl", function(data)
    if not data then
        return
    end
    if not boomboxes[data.boomboxId] then
        return madCore.debug("boombox does not exist")
    end
    local Player = madCore.getPlayer(source)
    local identifier = Player.identifier
    if not boomboxes[data.boomboxId].data.disableOwner then
        if boomboxes[data.boomboxId].data.owner ~= identifier then
            return madCore.debug("boombox does not belong to player")
        end
    end
    local entity = NetworkGetEntityFromNetworkId(boomboxes[data.boomboxId].data.netId)
    if not DoesEntityExist(entity) then
        return madCore.debug("entity does not exist")
    end
    getUrlDetails(data.url, function(details)
        if not details then
            return Player.notification("Invalid URL")
        end
        boomboxes[data.boomboxId].queue[#boomboxes[data.boomboxId].queue + 1] = details
        RmBoomboxPersistence.updateQueue(data.boomboxId, boomboxes[data.boomboxId].queue)
        Entity(entity).state:set("updateBoombox", {
            data = boomboxes[data.boomboxId],
            boomboxId = data.boomboxId
        }, true)
    end)
end)

RegisterServerEvent("boombox:server:removeBoombox", function(boomboxId)
    if not boomboxes[boomboxId] then
        return madCore.debug("[removeBoombox] -> boombox data does not exist")
    end
    local Player = madCore.getPlayer(source)
    local identifier = Player.identifier
    if not boomboxes[boomboxId].data.disableOwner then
        if boomboxes[boomboxId].data.owner ~= identifier then
            return madCore.debug("[removeBoombox] -> boombox does not belong to player")
        end
    end
    local boomboxCfg = cfg.boomboxes[boomboxes[boomboxId].data.bType]
    if boomboxCfg.shouldRemoveItem then
        if not isStandalone then
            Player.addItem(boomboxes[boomboxId].data.bType, 1)
        end
    end
    -- if boomboxCfg.shouldRemoveItem then
    --     if not isStandalone then
    --         Player.addItem(boomboxes[boomboxId].data.bType, 1)
    --     end
    -- end
    RmBoomboxPersistence.delete(boomboxId)
    boomboxes[boomboxId] = nil
    totalBoomboxCount = totalBoomboxCount - 1
    if playerBoomboxCounts[source] and playerBoomboxCounts[source] > 0 then
        playerBoomboxCounts[source] = playerBoomboxCounts[source] - 1
    end
    TriggerClientEvent("boombox:client:removeBoombox", -1, boomboxId)
end)

RegisterServerEvent("boombox:server:sync", function(data)
    if not data then
        return
    end
    if not boomboxes[data.boomboxId] then
        return madCore.debug("[sync] -> boombox does not exist")
    end
    local Player = madCore.getPlayer(source)
    local identifier = Player.identifier
    if not boomboxes[data.boomboxId].data.disableOwner then
        if boomboxes[data.boomboxId].data.owner ~= identifier then
            return madCore.debug("[sync] -> boombox does not belong to player")
        end
    end
    local entity = NetworkGetEntityFromNetworkId(boomboxes[data.boomboxId].data.netId)
    if not DoesEntityExist(entity) then
        return madCore.debug("[sync] -> entity does not exist")
    end
    if "fullscreen" == data.type then
        boomboxes[data.boomboxId].data.monitor = data.monitor or nil
        boomboxes[data.boomboxId].player.fullscreen = data.state
        if not data.state then
            local monitorEntity = NetworkGetEntityFromNetworkId(boomboxes[data.boomboxId].data.monitor)
            if DoesEntityExist(monitorEntity) then
                DeleteEntity(monitorEntity)
            end
        end
    elseif "pause" == data.type then
        data.state = not boomboxes[data.boomboxId].player.playing
        boomboxes[data.boomboxId].player.playing = data.state
    elseif "loop" == data.type then
        data.state = not boomboxes[data.boomboxId].player.loop
        boomboxes[data.boomboxId].player.loop = data.state
    elseif "skip" == data.type then
        table.remove(boomboxes[data.boomboxId].queue, 1)
        RmBoomboxPersistence.updateQueue(data.boomboxId, boomboxes[data.boomboxId].queue)
    elseif "seek" == data.type then
        local boombox = boomboxes[data.boomboxId]
        if boombox and boombox.data and boombox.queue[1] then
            local track = boombox.queue[1]
            if "forward" == data.state then
                track.elapsed = (track.elapsed or 0) + 15
            elseif "backward" == data.state then
                track.elapsed = math.max((track.elapsed or 0) - 15, 0)
            end
            track.timestamp = os.time()
            Entity(entity).state:set("syncDuration", {
                boomboxId = data.boomboxId,
                elapsed = track.elapsed,
                timestamp = GetGameTimer()
            }, true)
        end
    elseif "volume" == data.type then
        local newVolume
        if data.state then
            newVolume = boomboxes[data.boomboxId].player.volume + 0.25
        else
            newVolume = boomboxes[data.boomboxId].player.volume - 0.25
        end
        boomboxes[data.boomboxId].player.volume = newVolume
        local maxVolume = cfg.boomboxes[boomboxes[data.boomboxId].data.bType].maxVolume
        if boomboxes[data.boomboxId].player.volume > maxVolume then
            boomboxes[data.boomboxId].player.volume = maxVolume
        elseif boomboxes[data.boomboxId].player.volume < 0 then
            boomboxes[data.boomboxId].player.volume = 0
        end
    end
    Entity(entity).state:set("updateBoombox", {
        boomboxId = data.boomboxId,
        data = boomboxes[data.boomboxId],
        timestamp = GetGameTimer()
    }, true)
end)

RegisterServerEvent("boombox:server:duration", function(boomboxId)
    if not boomboxId then
        return
    end
    local boombox = boomboxes[boomboxId]
    if not boombox then
        return
    end
    if not boombox.queue[1] then
        return
    end
    local entity = NetworkGetEntityFromNetworkId(boombox.data.netId)
    if not DoesEntityExist(entity) then
        return madCore.debug("[sync] -> entity does not exist")
    end
    local track = boombox.queue[1]
    TriggerClientEvent("boombox:client:duration", source, {
        boomboxId = boomboxId,
        elapsed = track.elapsed or 0
    })
end)

CreateThread(function()
    while true do
        for boomboxId, boombox in pairs(boomboxes) do
            local entity = NetworkGetEntityFromNetworkId(boombox.data.netId)
            if not DoesEntityExist(entity) then
                RmBoomboxPersistence.delete(boomboxId)
                boomboxes[boomboxId] = nil
                totalBoomboxCount = totalBoomboxCount - 1
            end
            if boomboxes[boomboxId] then
                local track = boombox.queue[1]
                if track then
                    local duration = track.duration
                    if boombox.player.playing then
                        if not track.timestamp then
                            track.timestamp = os.time()
                        end
                        local delta = os.time() - track.timestamp
                        track.elapsed = (track.elapsed or 0) + delta
                        track.timestamp = os.time()
                        if duration <= track.elapsed then
                            if boombox.player.loop then
                                track.elapsed = 0
                                track.timestamp = os.time()
                            else
                                table.remove(boombox.queue, 1)
                                RmBoomboxPersistence.updateQueue(boomboxId, boombox.queue)
                                Entity(entity).state:set("updateBoombox", {
                                    boomboxId = boomboxId,
                                    data = boomboxes[boomboxId],
                                    timestamp = GetGameTimer()
                                }, true)
                            end
                        end
                    else
                        if track.timestamp then
                            local delta = os.time() - track.timestamp
                            track.elapsed = (track.elapsed or 0) + delta
                            track.timestamp = nil
                        end
                    end
                end
            end
        end
        Wait(1000)
    end
end)

RegisterCommand(cfg.options.removeBoomboxCommand, function(source, args, rawCommand)
    local playerId = source
    local identifiers = GetPlayerIdentifiers(playerId)
    local Player = madCore.getPlayer(playerId)
    if not Player then
        return
    end
    if not identifiers then
        return Player.notification("dont_have_permission")
    end
    for i = 1, #identifiers, 1 do
        if cfg.options.staffList[identifiers[i]] then
            for boomboxId, boombox in pairs(boomboxes) do
                if boombox and boombox.data then
                    local entity = NetworkGetEntityFromNetworkId(boombox.data.netId)
                    if DoesEntityExist(entity) then
                        local entityCoords = GetEntityCoords(entity)
                        local playerCoords = GetEntityCoords(GetPlayerPed(playerId))
                        local distance = #(entityCoords - playerCoords)
                        if distance < 3.0 then
                            RmBoomboxPersistence.delete(boomboxId)
                            boomboxes[boomboxId] = nil
                            totalBoomboxCount = totalBoomboxCount - 1
                            return TriggerClientEvent("boombox:client:removeBoombox", -1, boomboxId)
                        end
                    end
                end
            end
        end
    end
end)

if isStandalone then
    RegisterCommand(cfg.options.createBoomboxCommand, function(source, args, rawCommand)
        local Player = madCore.getPlayer(source)
        if not Player then
            return
        end
        local itemName = args[1]
        if not itemName then
            return Player.notification("invalid_boombox")
        end
        if not cfg.boomboxes[itemName] then
            return Player.notification("invalid_boombox")
        end
        if playerBoomboxCounts[source] and playerBoomboxCounts[source] >= cfg.options.individualBoomboxLimit then
            return Player.notification(madCore.getPhrase("boombox_individual_limit"))
        end
        if totalBoomboxCount >= cfg.options.serverBoomboxLimit then
            return Player.notification(madCore.getPhrase("boombox_server_limit"))
        end
        TriggerClientEvent("boombox:client:placeBoombox", source, itemName)
    end)

    RegisterServerEvent("boombox:server:playerLoaded", function()
        local identifiers = GetPlayerIdentifiers(source)
        local steamIdentifier = false
        for _, identifier in ipairs(identifiers) do
            if "steam:" == string.sub(identifier, 1, 6) then
                steamIdentifier = identifier
                break
            end
        end
        if not steamIdentifier then
            return
        end
        TriggerClientEvent("boombox:client:playerLoaded", source, steamIdentifier)
    end)
end

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    for boomboxId, boombox in pairs(boomboxes) do
        if boombox and boombox.data then
            local entity = NetworkGetEntityFromNetworkId(boombox.data.netId)
            local monitorEntity = NetworkGetEntityFromNetworkId(boombox.data.monitor)
            if DoesEntityExist(monitorEntity) then
                DeleteEntity(monitorEntity)
            end
            if DoesEntityExist(entity) then
                DeleteEntity(entity)
            end
        end
    end
end)