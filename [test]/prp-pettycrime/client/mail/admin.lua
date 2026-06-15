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

function OpenAdminMailMenu()
    local data = lib.callback.await("prp-pettycrime:server:adminMailGetData")
    if not data then return end

    local options = {
        {
            title = locale("menu.mail.tp_to_blackhat"),
            description = locale("menu.mail.show_current_location", data.name),
            icon = "map-location-dot",
            onSelect = function()
                local coords = data.coords
                SetEntityCoords(cache.ped, coords.x, coords.y + 0.2, coords.z + 1.0, false, false, false, false)
            end
        },
        {
            title = locale("menu.mail.send_to_next_location"),
            description = locale("menu.mail.send_to_next_location_desc"),
            icon = "refresh",
            serverEvent = "prp-pettycrime:server:adminMailNextLocation"
        }
    }

    bridge.fw.contextMenu({
        id = "pc-admin-mail",
        title = locale("menu.mail.blackhat"),
        menu = "pc-admin",
        options = options
    })

    bridge.fw.showContext("pc-admin-mail")
end

RegisterNetEvent("prp-pettycrime:client:adminMailMenu", function()
    OpenAdminMailMenu()
end)

