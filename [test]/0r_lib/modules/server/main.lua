Resmon = Resmon or {}
Resmon.ServerCallbacks = {}
Resmon.Framework = nil

if GetResourceState(Config.CoreName["ESX"]) ~= 'missing' then
    Config.Framework = 'ESX'
    Resmon.Framework = exports[Config.CoreName["ESX"]]:getSharedObject()
    print("[0Resmon] ESX Framework detected and loaded")
elseif GetResourceState(Config.CoreName["QBCore"]) ~= 'missing' then
    Config.Framework = 'QBCore'
    Resmon.Framework = exports[Config.CoreName["QBCore"]]:GetCoreObject()
    print("[0Resmon] QBCore Framework detected and loaded")
else
    print("[0Resmon] No supported framework detected (ESX or QBCore)")
end

MySQL.ready(function()
    print("[0Resmon] MySQL Connection established.")
end)

function Resmon.Framework.GetPlayer(source)
    if not Resmon.Framework then
        print("[0Resmon] Error: No framework loaded")
        return nil
    end
    
    if Config.Framework == 'QBCore' then
        return Resmon.Framework.Functions.GetPlayer(source)
    elseif Config.Framework == 'ESX' then
        return Resmon.Framework.GetPlayerFromId(source)
    end
    return nil
end

RegisterServerEvent('0R:Core:NewPlayerJoined')
AddEventHandler('0R:Core:NewPlayerJoined', function()
    local src = source
    local xPlayer = Resmon.Framework.GetPlayer(src)
    if not xPlayer then return end
    
    -- print("[0Resmon] Player joined: " .. xPlayer.identifier)
    TriggerClientEvent("0R:Core:SetPlayerData", src, xPlayer)
end)

RegisterServerEvent('0R:Core:SetPlayerJob')
AddEventHandler('0R:Core:SetPlayerJob', function(job)
    local src = source
    local xPlayer = Resmon.Framework.GetPlayer(src)
    if not xPlayer then return end
    
    xPlayer.setJob(job, xPlayer.job.grade)
    print("[0Resmon] Job updated: " .. xPlayer.identifier .. " -> " .. job.name)
end)

RegisterServerEvent('0R:Core:TriggerCallback')
AddEventHandler('0R:Core:TriggerCallback', function(name, requestId, ...)
    local src = source
    if Resmon.ServerCallbacks[name] then
        Resmon.ServerCallbacks[name](function(...)
            TriggerClientEvent('0R:Core:ServerCallback', src, requestId, ...)
        end, src, ...)
    end
end)

function Resmon.RegisterServerCallback(name, cb)
    Resmon.ServerCallbacks[name] = cb
end

function Resmon.Framework.GetMoney(source, account)
    local xPlayer = Resmon.Framework.GetPlayer(source)
    if not xPlayer then return 0 end
    if Config.Framework == 'QBCore' then
        return xPlayer.Functions.GetMoney(account)
    else
        return xPlayer.getAccount(account).money
    end
end

function Resmon.Framework.SetMoney(source, account, amount)
    local xPlayer = Resmon.Framework.GetPlayer(source)
    if not xPlayer then return end
    if Config.Framework == 'QBCore' then
        xPlayer.Functions.SetMoney(account, amount)
    else
        xPlayer.setAccountMoney(account, amount)
    end
end

RegisterNetEvent(Resmon.Framework == "QBCore" and "QBCore:PlayerLoaded" or "esx:playerLoaded")
AddEventHandler(Resmon.Framework == "QBCore" and "QBCore:PlayerLoaded" or "esx:playerLoaded", function(playerId)
    local xPlayer = Resmon.Framework.GetPlayer(playerId)
    if not xPlayer then return end
    print("[0Resmon] Player fully loaded: " .. xPlayer.identifier)
end)

RegisterServerEvent('0R:Lib:Notify')
AddEventHandler('0R:Lib:Notify', function(target, data)
    TriggerClientEvent('0R:Lib:Notify', target, data)
end)

RegisterServerEvent('0R:Core:GetVehicleProperties')
AddEventHandler('0R:Core:GetVehicleProperties', function(plate, cb)
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE plate = @plate', {['@plate'] = plate}, function(result)
        if result[1] then
            cb(json.decode(result[1].vehicle))
        else
            cb(nil)
        end
    end)
end)

RegisterServerEvent('0R:Core:SetVehicleProperties')
AddEventHandler('0R:Core:SetVehicleProperties', function(plate, props)
    MySQL.Async.execute('UPDATE owned_vehicles SET vehicle = @vehicle WHERE plate = @plate', {
        ['@vehicle'] = json.encode(props),
        ['@plate'] = plate
    })
end)

RegisterServerEvent('0R:Core:ShowTextUI')
AddEventHandler('0R:Core:ShowTextUI', function(target, text, icon)
    TriggerClientEvent('0R:Core:ShowTextUI', target, text, icon)
end)

RegisterServerEvent('0R:Core:HideTextUI')
AddEventHandler('0R:Core:HideTextUI', function(target)
    TriggerClientEvent('0R:Core:HideTextUI', target)
end)

-- Open Source License Bypass - Server-side exports
exports('hasLicense', function(productName)
    return true
end)

exports('checkLicense', function(productName)
    return true
end)

exports('validateLicense', function(productName)
    return true
end)
