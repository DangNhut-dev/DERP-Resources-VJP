local dryingRacks = {}
local rackIdCounter = 0

local function GenerateRackId()
    rackIdCounter = rackIdCounter + 1
    return 'rack_' .. os.time() .. '_' .. rackIdCounter
end

local function GetPlayerRackCount(citizenid)
    local count = 0
    for _, rack in pairs(dryingRacks) do
        if rack.owner == citizenid then count = count + 1 end
    end
    return count
end

local function LoadDryingRacksFromDatabase()
    local success, result = pcall(function()
        return exports.oxmysql:executeSync('SELECT * FROM cannabis_drying_racks', {})
    end)
    if not success then
        print('^1[tommy-weedplant]^7 Database error:', result)
        return false
    end
    if result and #result > 0 then
        for _, row in ipairs(result) do
            local coords = json.decode(row.coords)
            local items = row.items and json.decode(row.items) or {}
            local isDrying = (row.is_drying == 1 or row.is_drying == true)
            dryingRacks[row.rack_id] = {
                id = row.rack_id, coords = vector3(coords.x, coords.y, coords.z),
                owner = row.citizenid, items = items,
                startedAt = row.started_at, isDrying = isDrying,
                heading = row.heading or 0.0,
            }
        end
        print('^2[tommy-weedplant]^7 Loaded ' .. #result .. ' drying racks from database')
        return true
    end
    return true
end

local function SaveRackToDatabase(rack)
    local coords = json.encode({x = rack.coords.x, y = rack.coords.y, z = rack.coords.z})
    local items = json.encode(rack.items or {})
    exports.oxmysql:execute([[
        INSERT INTO cannabis_drying_racks (rack_id, citizenid, coords, items, started_at, is_drying, heading)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ]], { rack.id, rack.owner, coords, items, rack.startedAt, rack.isDrying and 1 or 0, rack.heading or 0.0 })
end

local function UpdateRackInDatabase(rack)
    local items = json.encode(rack.items or {})
    exports.oxmysql:execute([[
        UPDATE cannabis_drying_racks SET items=?, started_at=?, is_drying=? WHERE rack_id=?
    ]], { items, rack.startedAt, rack.isDrying and 1 or 0, rack.id })
end

local function DeleteRackFromDatabase(rackId)
    exports.oxmysql:execute('DELETE FROM cannabis_drying_racks WHERE rack_id = ?', {rackId})
end

RegisterNetEvent('tommy-weedplant:server:placeDryingRack', function(coords, heading)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    local citizenid = player.PlayerData.citizenid

    if exports.ox_inventory:Search(src, 'count', Config.DryingRack.item) < 1 then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['no_drying_rack_item'], type = 'error' })
        return
    end

    exports.ox_inventory:RemoveItem(src, Config.DryingRack.item, 1)

    local rackId = GenerateRackId()
    dryingRacks[rackId] = {
        id = rackId, coords = coords, owner = citizenid,
        items = {}, startedAt = nil, isDrying = false,
        heading = heading or 0.0,
    }

    SaveRackToDatabase(dryingRacks[rackId])
    TriggerClientEvent('tommy-weedplant:client:spawnDryingRack', -1, rackId, coords, citizenid, {}, nil, false, heading)
    TriggerClientEvent('tommy-weedplant:client:updateRackCount', src, GetPlayerRackCount(citizenid) + 1)
    TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['rack_placed'], type = 'success' })
end)

lib.callback.register('tommy-weedplant:server:getPlayerBuds', function(source)
    local buds = {}
    for itemName, _ in pairs(Config.DryingRack.inputItems) do
        local count = exports.ox_inventory:Search(source, 'count', itemName)
        if count > 0 then
            local itemData = exports.ox_inventory:GetItem(source, itemName, nil, false)
            table.insert(buds, {
                name = itemName,
                label = itemData and itemData.label or itemName,
                amount = count,
                image = itemName .. '.png'
            })
        end
    end
    return buds
end)

RegisterNetEvent('tommy-weedplant:server:startDrying', function(rackId, items)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player or not dryingRacks[rackId] then return end

    local rack = dryingRacks[rackId]
    if rack.isDrying then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['rack_still_drying'], type = 'error' })
        return
    end
    if not items or #items == 0 then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['no_valid_buds'], type = 'error' })
        return
    end

    local validItems = {}
    for _, itemData in ipairs(items) do
        if Config.DryingRack.inputItems[itemData.name] then
            local count = exports.ox_inventory:Search(src, 'count', itemData.name)
            if count >= itemData.amount then
                exports.ox_inventory:RemoveItem(src, itemData.name, itemData.amount)
                table.insert(validItems, { name = itemData.name, amount = itemData.amount })
            end
        end
    end

    if #validItems == 0 then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['no_valid_buds'], type = 'error' })
        return
    end

    rack.items = validItems
    rack.startedAt = os.time() * 1000
    rack.isDrying = true
    UpdateRackInDatabase(rack)

    TriggerClientEvent('tommy-weedplant:client:updateRackStatus', -1, rackId, true)

    local totalAmount = 0
    for _, item in ipairs(validItems) do totalAmount = totalAmount + item.amount end
    TriggerClientEvent('ox_lib:notify', src, {
        description = string.format(Config.Notifications['drying_started'], totalAmount), type = 'success'
    })
end)

RegisterNetEvent('tommy-weedplant:server:collectDried', function(rackId)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player or not dryingRacks[rackId] then return end

    local rack = dryingRacks[rackId]
    if not rack.isDrying or not rack.startedAt then
        TriggerClientEvent('ox_lib:notify', src, { description = 'Bàn sấy không có cần!', type = 'error' })
        return
    end

    local currentTime = os.time() * 1000
    local elapsed = currentTime - rack.startedAt

    if elapsed < Config.DryingRack.dryingTime then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['rack_still_drying'], type = 'error' })
        return
    end

    local isRuined = elapsed > (Config.DryingRack.dryingTime + Config.DryingRack.gracePeriod)
    local totalCollected = 0

    for _, itemData in ipairs(rack.items) do
        if isRuined then
            exports.ox_inventory:AddItem(src, Config.DryingRack.ruinedItem, itemData.amount)
        else
            local outputItem = Config.DryingRack.inputItems[itemData.name]
            if outputItem then
                exports.ox_inventory:AddItem(src, outputItem, itemData.amount)
                totalCollected = totalCollected + itemData.amount
            end
        end
    end

    rack.items = {}
    rack.startedAt = nil
    rack.isDrying = false
    UpdateRackInDatabase(rack)
    TriggerClientEvent('tommy-weedplant:client:updateRackStatus', -1, rackId, false)

    if isRuined then
        TriggerClientEvent('ox_lib:notify', src, { description = string.format(Config.Notifications['drying_ruined'], totalCollected), type = 'error' })
    else
        TriggerClientEvent('ox_lib:notify', src, { description = string.format(Config.Notifications['drying_collected'], totalCollected), type = 'success' })
    end
end)

RegisterNetEvent('tommy-weedplant:server:pickupRack', function(rackId)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player or not dryingRacks[rackId] then return end

    local rack = dryingRacks[rackId]
    if rack.isDrying then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['rack_not_empty'], type = 'error' })
        return
    end

    exports.ox_inventory:AddItem(src, Config.DryingRack.item, 1)
    local citizenid = player.PlayerData.citizenid
    TriggerClientEvent('tommy-weedplant:client:updateRackCount', src, GetPlayerRackCount(citizenid) - 1)
    TriggerClientEvent('tommy-weedplant:client:removeDryingRack', -1, rackId)
    DeleteRackFromDatabase(rackId)
    dryingRacks[rackId] = nil
    TriggerClientEvent('ox_lib:notify', src, { description = Config.Notifications['rack_removed'], type = 'success' })
end)

RegisterNetEvent('tommy-weedplant:server:requestDryingSync', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end
    TriggerClientEvent('tommy-weedplant:client:syncDryingRacks', src, dryingRacks)
    local citizenid = player.PlayerData.citizenid
    TriggerClientEvent('tommy-weedplant:client:updateRackCount', src, GetPlayerRackCount(citizenid))
end)

lib.callback.register('tommy-weedplant:server:canCollectDried', function(source, rackId)
    if not dryingRacks[rackId] then return false end
    local rack = dryingRacks[rackId]
    if not rack.isDrying or not rack.startedAt then return false end
    return (os.time() * 1000) - rack.startedAt >= Config.DryingRack.dryingTime
end)

lib.callback.register('tommy-weedplant:server:getDryingTimeRemaining', function(source, rackId)
    if not dryingRacks[rackId] then return 0 end
    local rack = dryingRacks[rackId]
    if not rack.isDrying or not rack.startedAt then return 0 end
    local remaining = Config.DryingRack.dryingTime - ((os.time() * 1000) - rack.startedAt)
    return math.max(0, remaining)
end)

exports.qbx_core:CreateUseableItem(Config.DryingRack.item, function(source, item)
    TriggerClientEvent('tommy-weedplant:client:useDryingRack', source)
end)

CreateThread(function()
    local attempts = 0
    while attempts < 10 do
        Wait(2000)
        attempts = attempts + 1
        local success = LoadDryingRacksFromDatabase()
        if success then
            print('^2[tommy-weedplant]^7 Drying racks loaded successfully!')
            break
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for rackId, rack in pairs(dryingRacks) do UpdateRackInDatabase(rack) end
        Wait(500)
        TriggerClientEvent('tommy-weedplant:client:syncDryingRacks', -1, {})
    end
end)