madCore = {}
madCore.scriptName = GetCurrentResourceName()
madCore.inventory = nil

if GetResourceState('ox_inventory'):find('start') then
    madCore.inventory = "ox_inventory"
end

if GetResourceState('qs-inventory'):find('start') then
    madCore.inventory = "qs-inventory"
end

if GetResourceState('qb-inventory'):find('start') then
    madCore.inventory = "qb-inventory"
end

madCore.getItemLabel = function(itemName)
    if madCore.inventory == 'ox_inventory' then
        local items = exports.ox_inventory:Items()
        return items[itemName] and items[itemName].label or itemName
    elseif madCore.inventory == 'qs-inventory' then
        return exports[inventory]:GetItemLabel(itemName) or itemName
    elseif madCore.inventory == 'qb-inventory' then
        return Framework.Shared.Items[itemName] and Framework.Shared.Items[itemName].label or itemName
    end

    return itemName 
end

madCore.debug = function(msg)
    if cfg.framework.debug then
        print(("^1[%s]^0 --> %s"):format(madCore.scriptName, msg))
    end
end

madCore.getPoliceCount = function()
    local allPlayers = GetPlayers()
    local policeCount = 0

    for i = 1, #allPlayers do
        local Player = madCore.getPlayer(allPlayers[i])
        if Player then
            local playerJob = Player.getJob()
            for _, jobName in pairs(cfg.police.dispatchJobs) do
                if playerJob == jobName then
                    policeCount = policeCount + 1
                end
            end
        end
    end

    return policeCount
end

madCore.policeAlert = function(coords)
    local allPlayers = GetPlayers()

    for i = 1, #allPlayers do
        local Player = madCore.getPlayer(allPlayers[i])
        if Player then
            local playerJob = Player.getJob()
            for _, jobName in pairs(cfg.police.dispatchJobs) do
                if playerJob == jobName then
                    TriggerClientEvent('exchangeheist:client:policeAlert', allPlayers[i], coords)
                end
            end
        end
    end
end

RegisterServerEvent("exchangeheist:server:policeAlert", madCore.policeAlert)

local function pushIdentifier(playerId)
    if not madCore.getPlayer then return end
    local Player = madCore.getPlayer(playerId)
    if not Player or not Player.identifier then return end
    TriggerClientEvent(('%s:client:setIdentifier'):format(madCore.scriptName), playerId, Player.identifier)
end

RegisterNetEvent(('%s:server:requestIdentifier'):format(madCore.scriptName), function()
    pushIdentifier(source)
end)

CreateThread(function()
    while not madCore.getPlayer do
        Wait(100)
    end
    for _, playerId in ipairs(GetPlayers()) do
        pushIdentifier(tonumber(playerId))
    end
end)