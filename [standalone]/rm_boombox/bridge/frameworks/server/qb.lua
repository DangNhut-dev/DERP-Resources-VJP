if string.upper(cfg.framework.name) == "AUTO" then
    if GetResourceState("qb-core") == "missing" and GetResourceState("qbx_core") == "missing" then
        return
    end
elseif string.upper(cfg.framework.name) ~= "QB" then
    return
end

local QBCore = nil

CreateThread(function()
    pcall(function() 
        QBCore = exports["qb-core"]:GetCoreObject() 
    end)

    if not QBCore then
        pcall(function() 
            QBCore = exports["qb-core"]:GetSharedObject() 
        end)
    end

    if not QBCore then
        TriggerEvent("QBCore:GetObject", function(obj) 
            QBCore = obj 
        end)
    end

    madCore.usableItem = QBCore.Functions.CreateUseableItem
    madCore.registerCallback = lib.callback.register

    madCore.getPlayerFromIdentifier = function(identifier)
        return QBCore.Functions.GetPlayerByCitizenId(identifier)
    end

    madCore.getPhrase = function(str)
        return Strings[str] or ('locale not found: %s'):format(str)
    end

    madCore.getPlayer = function(playerId)
        local Player = QBCore.Functions.GetPlayer(playerId)

        if not Player then
            madCore.debug("Player not found.")
            return 
        end

        local self = {}

        self.identifier = Player.PlayerData.citizenid
        self.name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)

        self.notification = function(message)
            TriggerClientEvent(("%s:client:showNotification"):format(madCore.scriptName), playerId, message)
        end

        self.getJob = function()
            return Player.PlayerData.job.name
        end

        self.getItem = function(itemName)
            if madCore.inventory == "ox_inventory" then
                return exports.ox_inventory:GetItem(playerId, itemName, nil, false)
            elseif madCore.inventory == "qs-inventory" then
                return exports["qs-inventory"]:GetItem(playerId, itemName)
            else
                return Player.Functions.GetItemByName(itemName)
            end
        end

        self.getItemAmount = function(itemName)
            if madCore.inventory == "ox_inventory" then
                return exports.ox_inventory:GetItemCount(playerId, itemName)
            elseif madCore.inventory == "qs-inventory" then
                return exports["qs-inventory"]:GetItemTotalAmount(playerId, itemName)
            else
                return Player.Functions.GetItemByName(itemName).amount or 0
            end
        end

        self.hasItem = function(itemName, amount)
            local item = Player.Functions.GetItemByName(itemName) or nil

            if item then
                return item.amount >= (amount or 1)
            end

            return false
        end

        self.addItem = function(itemName, amount)
            return Player.Functions.AddItem(itemName, amount)
        end

        self.removeItem = function(itemName, amount)
            return Player.Functions.RemoveItem(itemName, amount)
        end

        self.getMoney = function(moneyType)
            return Player.PlayerData.money[moneyType or 'cash']
        end

        self.addMoney = function(moneyType, amount)
            if moneyType == "black_money" then
                return Player.Functions.AddItem('markedbills', 1, false, {
                    worth = amount
                })
            end
            return Player.Functions.AddMoney((moneyType or 'cash'), amount)
        end

        self.removeMoney = function(moneyType, amount)
            return Player.Functions.RemoveMoney((moneyType or 'cash'), amount)
        end

        return self
    end
end)
