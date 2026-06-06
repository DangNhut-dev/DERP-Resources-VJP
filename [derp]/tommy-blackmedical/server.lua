local REVIVE_COST = 5000
local cooldowns = {}

lib.callback.register('tommy-blackmedical:server:checkMoney', function(source)
    local src = source

    local isDead = Player(src).state.isDead or Player(src).state.isDown
    if not isDead then
        lib.notify({ title = 'Chữa Trị', description = 'Bạn không cần chữa trị', type = 'error', position = 'top' }, src)
        return false
    end

    if cooldowns[src] and GetGameTimer() < cooldowns[src] then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Chữa Trị',
            description = 'Vui lòng chờ trước khi dùng lại',
            type = 'error',
            position = 'top'
        })
        return false
    end

    local player = exports.qbx_core:GetPlayer(src)
    if not player then return false end

    local cash = player.PlayerData.money.cash
    if cash < REVIVE_COST then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Chữa Trị',
            description = ('Không đủ tiền mặt (cần $%s)'):format(REVIVE_COST),
            type = 'error',
            position = 'top'
        })
        return false
    end

    return true
end)

lib.callback.register('tommy-blackmedical:server:doRevive', function(source)
    local src = source

    local isDead = Player(src).state.isDead or Player(src).state.isDown
    if not isDead then return false, 'Bạn không cần chữa trị' end

    if cooldowns[src] and GetGameTimer() < cooldowns[src] then
        return false, 'Cooldown chưa hết'
    end

    local player = exports.qbx_core:GetPlayer(src)
    if not player then return false, 'Không tìm thấy người chơi' end

    local cash = player.PlayerData.money.cash
    if cash < REVIVE_COST then
        return false, ('Không đủ tiền mặt (cần $%s)'):format(REVIVE_COST)
    end

    player.Functions.RemoveMoney('cash', REVIVE_COST, 'black-medical-revive')
    cooldowns[src] = GetGameTimer() + 15000

    TriggerClientEvent('p_ambulancejob/client/death/revive', src)
    TriggerEvent('p_ambulancejob/server/death/reviveUtils', src)

    return true
end)

AddEventHandler('playerDropped', function()
    cooldowns[source] = nil
end)