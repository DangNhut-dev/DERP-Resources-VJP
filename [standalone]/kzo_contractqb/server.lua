local ox_inventory = exports.ox_inventory

lib.callback.register('kzo_contract:getclosestplayername', function(source, closestid)
    local xPlayer = exports.qbx_core:GetPlayer(source)
    local closestPlayer = exports.qbx_core:GetPlayer(closestid)
    if not xPlayer or not closestPlayer then return nil, nil end
    local xName = xPlayer.PlayerData.charinfo.firstname .. ' ' .. xPlayer.PlayerData.charinfo.lastname
    local closestName = closestPlayer.PlayerData.charinfo.firstname .. ' ' .. closestPlayer.PlayerData.charinfo.lastname
    return xName, closestName
end)

RegisterNetEvent('kzo_contract:writecontact', function(closestplayer, plate)
    local src = source
    local xPlayer = exports.qbx_core:GetPlayer(src)
    local closestPlayer = exports.qbx_core:GetPlayer(closestplayer)

    if not xPlayer or not closestPlayer then
        exports.qbx_core:Notify(src, 'Không tìm thấy người chơi.', 'error')
        return
    end

    local xCitizen = xPlayer.PlayerData.citizenid
    local tCitizen = closestPlayer.PlayerData.citizenid
    local tidentifier = closestPlayer.PlayerData.license
    local xName = xPlayer.PlayerData.charinfo.firstname .. ' ' .. xPlayer.PlayerData.charinfo.lastname
    local closestName = closestPlayer.PlayerData.charinfo.firstname .. ' ' .. closestPlayer.PlayerData.charinfo.lastname

    MySQL.query('SELECT * FROM player_vehicles WHERE plate = ? AND citizenid = ?', { plate, xCitizen }, function(result)
        if not result or not result[1] then
            exports.qbx_core:Notify(src, 'Xe biển số ' .. plate .. ' không phải của bạn!', 'error')
            return
        end

        if not xPlayer.Functions.RemoveItem('contract', 1) then
            exports.qbx_core:Notify(src, 'Không có contract trong túi.', 'error')
            return
        end

        MySQL.update('UPDATE player_vehicles SET license = ?, citizenid = ? WHERE plate = ?', { tidentifier, tCitizen, plate })

        TriggerClientEvent('kzo_contract:showAnim', src)
        TriggerClientEvent('kzo_contract:showAnim', closestplayer)
        exports.qbx_core:Notify(src, 'Xe ' .. plate .. ' đã chuyển cho ' .. closestName .. '!', 'success')
        exports.qbx_core:Notify(closestplayer, 'Bạn nhận xe ' .. plate .. ' từ ' .. xName .. '!', 'success')
        TriggerClientEvent('vehiclekeys:client:SetOwner', closestplayer, plate)
    end)
end)