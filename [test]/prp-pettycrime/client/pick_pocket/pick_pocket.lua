--[[
░▒▓████████▓▒░▒▓██████▓▒░       ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░  
   ░▒▓█▓▒░  ░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
   ░▒▓█▓▒░  ░▒▓█▓▒░             ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
   ░▒▓█▓▒░  ░▒▓█▓▒░             ░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░  
   ░▒▓█▓▒░  ░▒▓█▓▒░             ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
   ░▒▓█▓▒░  ░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
   ░▒▓█▓▒░   ░▒▓██████▓▒░       ░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░░▒▓███████▓▒░  
                                                                         
 This File Leaked By TC HUB Team, Join Our Server For More
 DISCORD: - https://discord.gg/k3S8RjkPWc - https://t.me/+RgDxwPX3L7w2ODBk - https://tchub.shop/
--]]

local pickpocketedPeds = {}

CreateThread(function()
    bridge.target.addGlobalPed({
        {
            name = "pickpocket-npc",
            icon = "fas fa-mask",
            label = locale("target.pickpocket"),
            distance = Config.PickPocket.targetDistance,
            canInteract = function(entity)
                if pickpocketedPeds[entity] then return false end
                if IsPedFleeing(entity) or IsPedRunning(entity) then return false end
                if IsPedFacingPed(entity, cache.ped, 90.0) then return false end
                if not NetworkGetEntityIsNetworked(entity) then return false end

                if not IsPedUsingAnyScenario(entity) and not GetPedConfigFlag(entity, 236, true) then
                    return false
                end

                local pedType = GetPedType(entity)
                if pedType == 28 or pedType == 29 then
                    return false
                end

                return true
            end,
            onSelect = function(data)
                local entity = data.entity
                pickpocketedPeds[entity] = true

                TaskTurnPedToFaceEntity(cache.ped, entity, 1000)

                local playerCoords = GetEntityCoords(cache.ped)
                local zone = GetZoneAtCoords(playerCoords.x, playerCoords.y, playerCoords.z)
                local scumminess = GetZoneScumminess(zone)

                TriggerServerEvent("prp-pettycrime:server:pickpocketPed", PedToNet(entity), scumminess)
            end
        }
    })
end)

AddEventHandler("onResourceStop", function(resourceName)
    if cache.resource ~= resourceName then return end

    bridge.target.removeGlobalPed({ "pickpocket-npc" })
end)

