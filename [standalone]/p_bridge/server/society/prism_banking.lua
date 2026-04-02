-- if (Config.Society == 'auto' and not checkResource('Renewed-Banking')) or (Config.Society ~= 'auto' and Config.Society ~= 'Renewed-Banking') then
--     return
-- end

-- while not Bridge do
--     Citizen.Wait(0)
-- end

-- if Config.Debug then
--     lib.print.info('[Society] Loaded: Renewed-Banking')
-- end

-- Bridge.Society = {}

-- Bridge.Society.addMoney = function(playerId, jobName, amount)
--     exports['Renewed-Banking']:AddSocietyMoney(jobName, amount)
--     return true
-- end

-- Bridge.Society.removeMoney = function(playerId, jobName, amount)
--     exports['Renewed-Banking']:RemoveSocietyMoney(jobName, amount)
--     return true
-- end

-- Bridge.Society.getMoney = function(playerId, jobName)
--     local societyBalance = exports['Renewed-Banking']:GetSocietyBalance(jobName)
--     if societyBalance then
--         return societyBalance
--     end
--     return 0
-- end

if (Config.Society == 'auto' and not checkResource('Renewed-Banking')) or (Config.Society ~= 'auto' and Config.Society ~= 'Renewed-Banking') then
    return
end

while not Bridge do
    Citizen.Wait(0)
end

if Config.Debug then
    lib.print.info('[Society] Loaded: Renewed-Banking')
end

Bridge.Society = {}

Bridge.Society.addMoney = function(playerId, jobName, amount)
    local result = exports['Renewed-Banking']:addAccountMoney(jobName, amount)
    return result
end

Bridge.Society.removeMoney = function(playerId, jobName, amount)
    local result = exports['Renewed-Banking']:removeAccountMoney(jobName, amount)
    return result
end

Bridge.Society.getMoney = function(playerId, jobName)
    local money = exports['Renewed-Banking']:getAccountMoney(jobName)
    if money then
        return money
    end
    return 0
end