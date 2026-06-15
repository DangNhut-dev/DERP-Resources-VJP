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

function SetupMailNPC(model, position)
    exports["prp-bridge"]:AddPedInteraction("prp-pettycrime-mailnpc", {
        model = model,
        coords = vector3(position.x, position.y, position.z),
        heading = position.w,
        radius = 50.0,
        options = {
            {
                name = "sell_letters",
                icon = "fa-solid fa-envelope",
                label = locale("target.mail.sell"),
                serverEvent = "prp-pettycrime:server:mailSellLetters",
                distance = 1.5
            }
        }
    })

    if Config.Debug then
        TriggerEvent("prp-pettycrime:client:registerDebugCoords", "mailnpc", vector3(position.x, position.y, position.z), "Mail NPC (Blackhat)")
    end
end

RegisterNetEvent("prp-pettycrime:client:setMailPedPos", function(model, position)
    if Config.Debug then
        TriggerEvent("prp-pettycrime:client:removeDebugCoords", "mailnpc")
    end
    exports["prp-bridge"]:RemovePedInteraction("prp-pettycrime-mailnpc")
    SetTimeout(100, function()
        SetupMailNPC(model, position)
    end)
end)

RegisterNetEvent("prp-pettycrime:client:startup", function(activityType, data)
    if activityType ~= "mail_npc" then return end
    SetupMailNPC(data.model, data.position)
end)
