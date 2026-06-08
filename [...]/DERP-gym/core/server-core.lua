if Config.Core:upper() == 'ESX' then
                                                    
    Core = exports['es_extended']:getSharedObject()
    RESCB = Core.RegisterServerCallback
    GETPFI = Core.GetPlayerFromId
    RUI = Core.RegisterUsableItem
    Accounts = {'money', 'bank'}

    function GetIdentifier(source)
        local xPlayer = GETPFI(source)
        return xPlayer.identifier
    end

    function GetAccountMoney(xPlayer,account)
        return xPlayer.getAccount(account).money
    end

    function GetItemCount(xPlayer, item)
        return xPlayer.getInventoryItem(item).count
    end

    function RemoveAccountMoney(xPlayer, account, amount)
        xPlayer.removeAccountMoney(account, amount)
    end

    function AddAccountMoney(xPlayer, account, amount)
        xPlayer.addAccountMoney(account, amount)
    end

    function RemoveItem(xPlayer, item)
        xPlayer.removeInventoryItem(item, 1)
    end

elseif Config.Core:upper() == 'QBCORE' then
--------------------------------------------------------------------------
--------------------------------| QBCore |--------------------------------
--------------------------------------------------------------------------

    Core = exports['qb-core']:GetCoreObject()
    RESCB = Core.Functions.CreateCallback
    GETPFI = Core.Functions.GetPlayer
    RUI = Core.Functions.CreateUseableItem
    Accounts = {'cash', 'bank'}

    function GetIdentifier(source)
        local xPlayer = GETPFI(source)
        return xPlayer.PlayerData.citizenid
    end

    function GetAccountMoney(xPlayer, account)
        if account == Accounts[1] then
            return xPlayer.PlayerData.money['cash']
        elseif account == Accounts[2] then
            return xPlayer.PlayerData.money['bank']
        end
    end

    function GetItemCount(xPlayer, item)
        local items = xPlayer.Functions.GetItemByName(item)
        local item_count = 0
        if items ~= nil then
            item_count = items.amount
        else
            item_count = 0
        end
        return item_count
    end

    function RemoveAccountMoney(xPlayer, account, amount)
        xPlayer.Functions.RemoveMoney(account, amount)
    end

    function AddAccountMoney(xPlayer, account, amount)
        xPlayer.Functions.AddMoney(account, amount)
    end

    function RemoveItem(xPlayer, item)
        xPlayer.Functions.RemoveItem(item, 1)
    end
    
end