lib.locale()
local ver = '1.0.2'
local onTimer = {}

CreateThread(function()
    if GetResourceState(GetCurrentResourceName()) == 'started' then
        print('DRC_HOUSEROBBERY STARTED ON VERSION: ' .. ver)
    end
end)

local MoneyTable = {"cash", "money"}

local QBX = exports.qbx_core

local function RegisterUsableItem(item, cb)
    QBX:CreateUseableItem(item, cb)
end

function BanPlayer(source, message)
    if Config.AnticheatBan then
        exports['youranticheat']:BanPlayer(source, message)
    end
end

RegisterUsableItem("loot_bag", function(source)
    local src = source
    local weight = exports.ox_inventory:GetInventoryWeight(src)
    local maxWeight = exports.ox_inventory:GetInventoryMaxWeight(src)
    if weight >= maxWeight then
        TriggerClientEvent('drc_houserobbery:notify', src, 'error', locale('houserobbery'), 'Túi đồ của bạn đã đầy.')
        return
    end
    RemoveItem("loot_bag", 1, src)
    TriggerClientEvent('drc_houserobbery:lootbag', src)
end)

RegisterUsableItem('house_locator', function(source)
    local src = source
    if onTimer[src] and onTimer[src] > GetGameTimer() then
        TriggerClientEvent('drc_houserobbery:notify', src, 'error', locale('houserobbery'), locale('ItemCooldown', math.floor((onTimer[src] - GetGameTimer()) / 1000 + 0.5)))
        return
    end
    TriggerClientEvent('drc_houserobbery:gethelp', src)
    onTimer[src] = GetGameTimer() + (10 * 1000)
end)

RegisterUsableItem("powder", function(source)
    local src = source
    RemoveItem("powder", 1, src)
    TriggerClientEvent("drc_houserobbery:powder", src)
end)

function Logs(source, message)
    if message ~= nil then
        if Config.Logs.enabled then
            local license = nil
            for k, v in pairs(GetPlayerIdentifiers(source)) do
                if string.sub(v, 1, string.len("license:")) == "license:" then
                    license = v
                end
            end
            if Config.Logs.type == "ox_lib" then
                lib.logger(source, "HouseRobbery", message)
            else
                local webhook = Config.Logs.type
                local embed = {
                    {
                        ["color"] = 2600155,
                        ["title"] = "Player: **" .. GetPlayerName(source) .. " | " .. (license or 'unknown') .. " **",
                        ["description"] = message,
                        ["footer"] = {
                            ["text"] = "Logs by DRC SCRIPTS for DRC HOUSE ROBBERY!",
                        },
                    }
                }
                PerformHttpRequest(webhook, function(err, text, headers) end, 'POST',
                    json.encode({ username = "DRC HOUSE ROBBERY", embeds = embed,
                        avatar_url = "https://i.imgur.com/RclET8O.png" })
                    , { ['Content-Type'] = 'application/json' })
            end
        end
    end
end

function GetJob(source)
    local xPlayer = QBX:GetPlayer(source)
    if xPlayer then
        return xPlayer.PlayerData.job.name
    end
    return nil
end

function GetItem(name, count, source)
    local xPlayer = QBX:GetPlayer(source)
    if not xPlayer then return false end
    local item = xPlayer.Functions.GetItemByName(name)
    if item and item.amount >= count then
        return true
    end
    return false
end

function AddMoney(count, source)
    local xPlayer = QBX:GetPlayer(source)
    if not xPlayer then return end
    if Config.DirtyMoney then
        local info = {worth = count}
        xPlayer.Functions.AddItem('markedbills', 1, false, info)
    else
        xPlayer.Functions.AddMoney('cash', count)
    end
end

function RemoveMoney(count, source)
    local xPlayer = QBX:GetPlayer(source)
    if not xPlayer then return end
    xPlayer.Functions.RemoveMoney('cash', count)
end

function GetItemCount(name, source)
    local xPlayer = QBX:GetPlayer(source)
    if not xPlayer then return 0 end
    local item = xPlayer.Functions.GetItemByName(name)
    if item then
        return item.amount
    end
    return 0
end

function GetMoney(count, source)
    local xPlayer = QBX:GetPlayer(source)
    if not xPlayer then return false end
    return xPlayer.Functions.GetMoney('cash') >= count
end

function AddItem(name, count, source)
    local src = source
    local ismoney = false
    for _, v in pairs(MoneyTable) do
        if v == name then
            ismoney = true
            AddMoney(count, src)
        end
    end
    if not ismoney then
        local xPlayer = QBX:GetPlayer(src)
        if xPlayer then
            if not exports.ox_inventory:CanCarryItem(src, name, count) then
                TriggerClientEvent('drc_houserobbery:notify', src, 'error', locale('houserobbery'), 'Túi đồ của bạn đã đầy.')
                return false
            end
            xPlayer.Functions.AddItem(name, count)
        end
    end
    return true
end

function RemoveItem(name, count, source)
    local xPlayer = QBX:GetPlayer(source)
    if xPlayer then
        xPlayer.Functions.RemoveItem(name, count)
    end
end

function CheckJob()
    local PoliceCount = 0
    for _, playerId in ipairs(GetPlayers()) do
        local xPlayer = QBX:GetPlayer(tonumber(playerId))
        if xPlayer then
            for _, job in pairs(Config.PoliceJobs) do
                if xPlayer.PlayerData.job.name == job then
                    PoliceCount = PoliceCount + 1
                end
            end
        end
    end
    return PoliceCount
end

function GetIdent(source)
    local xPlayer = QBX:GetPlayer(source)
    if xPlayer then
        return xPlayer.PlayerData.citizenid
    end
    return nil
end

lib.callback.register('drc_houserobbery:getident', function(source)
    return GetIdent(source)
end)

-- lb-tablet dispatch handler
RegisterNetEvent('drc_houserobbery:server:dispatch', function(coords, streetLabel)
    if GetResourceState('lb-tablet') ~= 'started' then return end
    if not coords then 
        return 
    end

    -- Thêm vào danh sách dispatch trên tablet (không phát sound vì đã notify)
    exports['lb-tablet']:AddDispatch({
        priority = 'high',
        code = '10-90',
        title = 'Trộm Nhà',
        description = 'Phát hiện hành vi đột nhập nhà dân tại ' .. (streetLabel or 'không xác định'),
        location = {
            label = streetLabel or 'Không xác định',
            coords = coords and vec2(coords.x, coords.y) or nil,
        },
        time = 120,
        job = 'police',
        sound = false,
        fields = {
            { icon = 'fas fa-house-crack', label = 'Loại', value = 'Đột nhập nhà dân' },
            { icon = 'fas fa-map-marker-alt', label = 'Vị trí', value = streetLabel or 'Không rõ' },
        },
        blip = {
            sprite = 40,
            color = 1,
            size = 1.5,
            label = '10-90 Trộm Nhà',
        },
    })
end)

-- Test command: /testdispatch
lib.addCommand('testdispatch', {
    help = 'Test houserobbery dispatch',
    restricted = 'group.admin',
}, function(source)
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local street = 'Test Location'

    for _, playerId in ipairs(GetPlayers()) do
        local target = QBX:GetPlayer(tonumber(playerId))
        if target and target.PlayerData.job.type == 'leo' and target.PlayerData.job.onduty then
            exports['lb-tablet']:SendNotification({
                source = tonumber(playerId),
                app = '10-90 Trộm Nhà',
                title = 'Trộm Nhà | ' .. street,
                content = 'Phát hiện đột nhập nhà dân',
            })
        end
    end

    exports['lb-tablet']:AddDispatch({
        priority = 'high',
        code = '10-90',
        title = 'Trộm Nhà',
        description = 'Phát hiện hành vi đột nhập nhà dân tại ' .. street,
        location = {
            label = street,
            coords = vec2(coords.x, coords.y),
        },
        time = 120,
        job = 'police',
        sound = false,
        fields = {
            { icon = 'fas fa-house-crack', label = 'Loại', value = 'Đột nhập nhà dân' },
            { icon = 'fas fa-map-marker-alt', label = 'Vị trí', value = street },
        },
        blip = {
            sprite = 40,
            color = 1,
            size = 1.5,
            label = '10-90 Trộm Nhà',
        },
    })

    TriggerClientEvent('ox_lib:notify', source, { type = 'success', description = 'Dispatch test sent' })
end)