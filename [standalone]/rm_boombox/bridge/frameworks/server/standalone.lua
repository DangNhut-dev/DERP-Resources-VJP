if string.upper(cfg.framework.name) == "AUTO" then
    if GetResourceState("qb-core") ~= "missing" or GetResourceState("qbx_core") ~= "missing" or GetResourceState("es_extended") ~= "missing" then
        return
    end
elseif string.upper(cfg.framework.name) ~= "STANDALONE" then
    return
end


CreateThread(function()
    madCore.registerCallback = lib.callback.register

    madCore.getPlayer = function(playerId)
        local self = {}
        local identifiers = GetPlayerIdentifiers(playerId)

        for _,id in ipairs(identifiers) do
            if string.sub(id, 1, 6) == "steam:" then
                self.identifier = id
                break
            end
        end

        self.name = GetPlayerName(playerId)

        self.notification = function(message)
            TriggerClientEvent(("%s:client:showNotification"):format(madCore.scriptName), playerId, message)
        end

        self.addItem = function(itemName, amount)
            return 
        end

        self.removeItem = function(itemName, amount)
            return 
        end

        return self
    end
end)
