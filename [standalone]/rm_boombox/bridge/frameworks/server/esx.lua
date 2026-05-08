if string.upper(cfg.framework.name) == "AUTO" then
    if GetResourceState("es_extended") == "missing" then
        return
    end
elseif string.upper(cfg.framework.name) ~= "ESX" then
    return
end

local ESX = nil

CreateThread(function()
    pcall(function() 
        ESX = exports["es_extended"]:getSharedObject() 
    end)

    if not ESX then
        TriggerEvent("esx:getSharedObject", function(library)
            ESX = library
        end)
    end

    madCore.usableItem = ESX.RegisterUsableItem
    madCore.registerCallback = lib.callback.register

    madCore.getPhrase = function(str)
        return Strings[str] or ('locale not found: %s'):format(str)
    end

    madCore.getPlayerFromIdentifier = function(identifier)
        return ESX.GetPlayerFromIdentifier(identifier)
    end

    madCore.getPlayer = function(playerId)
        local Player = ESX.GetPlayerFromId(playerId)

        if not Player then
            madCore.debug("Player not found.")
            return 
        end

        local self = {}

        self.identifier = Player.getIdentifier()
        self.name = Player.getName()

        self.notification = function(message)
            TriggerClientEvent(("%s:client:showNotification"):format(madCore.scriptName), playerId, message)
        end

        self.getJob = function()
            return Player.getJob().name
        end

        self.getItem = function(itemName)
            if madCore.inventory == "ox_inventory" then
                return exports.ox_inventory:GetItem(playerId, itemName, nil, false)
            elseif madCore.inventory == "qs-inventory" then
                return exports["qs-inventory"]:GetItem(playerId, itemName)
            else
                return Player.getInventoryItem(itemName)
            end
        end

        self.getItemAmount = function(itemName)
            if madCore.inventory == "ox_inventory" then
                return exports.ox_inventory:GetItemCount(playerId, itemName)
            elseif madCore.inventory == "qs-inventory" then
                return exports["qs-inventory"]:GetItemTotalAmount(playerId, itemName)
            else
                return Player.getInventoryItem(itemName).count
            end
        end

        self.hasItem = function(itemName, amount)
            local item = Player.getInventoryItem(itemName) or nil
                
            if item then
                if inventory == "qs-inventory" then
                    return item.amount >= (amount or 1)
                end
                return item.count >= (amount or 1)
            end

            return false
        end

        self.addItem = function(itemName, amount)
            return Player.addInventoryItem(itemName, amount)
        end

        self.removeItem = function(itemName, amount)
            return Player.removeInventoryItem(itemName, amount)
        end

        self.getMoney = function(moneyType)
            return Player.getAccount((moneyType or 'money')).money
        end

        self.addMoney = function(moneyType, amount)
            return Player.addAccountMoney((moneyType or 'money'), amount)
        end

        self.removeMoney = function(moneyType, amount)
            return Player.removeAccountMoney((moneyType or 'money'), amount)
        end

        return self
    end
end)
