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


ENTITY_TYPE = {
    Ped = 1,
    Vehicle = 2,
    Object = 3
}

InventoryHooks = {}

RegisterNetEvent("prp-pettycrime:server:startup", function()
    local src = source
    TriggerClientEvent("prp-pettycrime:client:startup", src, "parking_meters", GetParkingMeterData())
    TriggerClientEvent("prp-pettycrime:client:startup", src, "pp_locations", GetActiveLocations())
    TriggerClientEvent("prp-pettycrime:client:startup", src, "pp_gbombs", GetGlitterBombs())
    TriggerClientEvent("prp-pettycrime:client:startup", src, "letter_boxes", GetLetterboxData())
    TriggerClientEvent("prp-pettycrime:client:startup", src, "post_boxes", GetPostboxData())
    TriggerClientEvent("prp-pettycrime:client:startup", src, "mail_npc", GetMailNpcData())
end)

CreateThread(function()
    InventoryHooks[#InventoryHooks+1] = bridge.inv.registerCreateItemHook(function(payload)
        if not payload.metadata then
            payload.metadata = {}
        end

        if not payload.metadata.durability then
            payload.metadata.durability = 100.0
        end

        return payload.metadata
    end, {
        itemFilter = {
            [SvConfig.LockpickItem] = true
        }
    })

    if SvConfig.Logging and (not SvConfig.LogWebhook or SvConfig.LogWebhook:len() == 0) then
        lib.print.warn("Your webhook for petty crime is empty with logging enabled")
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if cache.resource ~= resource then return end
    for i = 1, #InventoryHooks do
        bridge.inv.removeHooks(InventoryHooks[i])
    end
end)
