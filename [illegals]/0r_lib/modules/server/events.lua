RegisterServerEvent('playerConnecting')
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local src = source
    print("[0Resmon] Player connecting: " .. name .. " (ID: " .. src .. ")")
end)

RegisterServerEvent('playerDropped')
AddEventHandler('playerDropped', function(reason)
    local src = source
    print("[0Resmon] Player disconnected: " .. src .. " (Reason: " .. reason .. ")")
end)

RegisterServerEvent('0R:Core:SavePlayerData')
AddEventHandler('0R:Core:SavePlayerData', function()
    local src = source
    local xPlayer = Resmon.Framework.GetPlayer(src)
    if not xPlayer then return end
    
    MySQL.Async.execute("UPDATE users SET job = @job WHERE identifier = @identifier", {
        ['@job'] = xPlayer.job.name,
        ['@identifier'] = xPlayer.identifier
    }, function(rowsChanged)
        print("[0Resmon] Player data saved for: " .. xPlayer.identifier)
    end)
end)
