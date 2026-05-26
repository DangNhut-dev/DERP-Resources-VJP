QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('duty:toggle')
AddEventHandler('duty:toggle', function()
    local src    = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    local onDuty = Player.PlayerData.job.onduty

    Player.Functions.SetJobDuty(not onDuty)

    if not onDuty then
        TriggerClientEvent('QBCore:Notify', src, 'Bạn đã bắt đầu ca làm việc!', 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'Bạn đã kết thúc ca làm việc!', 'error')
    end
end)