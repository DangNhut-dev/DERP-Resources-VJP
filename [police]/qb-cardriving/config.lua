Config = {}

Config.keybind = 'LCTRL' -- Keybind to engage/disengage the script

Config.rpmlimiter = 45 -- Recommended values: 35-55
-- The lower the number, the more the engine will rev
-- Increase this number to make the engine rev less

Config.speedlimiter = true -- Enable/Disable speed limiter
Config.speedunits = 'mph' -- Speed units (mph or km/h)
Config.defaultspeedlimit = 35 -- Default speed limit if street is not found in the list
Config.topspeed = 300 -- Default top speed limit of all vehicles 
-- In order for the speed limiter to reset its limit it has to assign a new top speed limit to the vehicle
-- Leave this at 300 for mph or 480 for km/h unless you have a global top speed limit script then change this to your server's top speed limit

Config.notify = true -- Enable/Disable notifications
Config.notifyengaged = 'Tuân thủ tốc độ cho phép' -- Notification description when script is engaged
Config.notifydisengaged = 'Bỏ qua việc tuân thủ tốc độ' -- Notification description when script is disengaged
Config.notifyspeedlimit = 'Tốc độ cho phép: %s'..Config.speedunits -- Notification description when speed limit changes

Config.cruisehudenabled = true -- Toggle cruise control icon on qb/qbx based HUD's 
-- Only set true if you plan to replace cruise control built into QB/QBX smallresources with this script
-- Tested on qb-hud, qbx_hud and fd_hud


Config.streets = {  -- Add extra streets here that you want toapply a speed limit to. Otherwise unlisted streets will use default speed limit

    { name = 'Great Ocean Hwy', speed = 90 },
    { name = 'Senora Freeway', speed = 90 },
    { name = 'Senora Fwy', speed = 90 },
    { name = 'Senora Rd', speed = 60 },
    { name = 'Union Rd', speed = 35 },
    { name = 'Seaview Rd', speed = 50 },
    { name = 'Joshua Rd', speed = 50 },
    { name = 'Panorama Dr', speed = 50 },
    { name = 'Grapeseed Main St', speed = 35 },
    { name = 'O\'Neil Way', speed = 25 },
    { name = 'Joad Ln', speed = 25 },
    --{ name = 'Baytree Canyon Rd', speed = 50 },
    { name = 'Olympic Fwy', speed = 90 },
    { name = 'Del Perro Fwy', speed = 90 },
    { name = 'La Puerta Fwy', speed = 90 },
    { name = 'Los Santos Freeway', speed = 90 },
    { name = 'Palomino Fwy', speed = 90 },
    { name = 'Route 68', speed = 68 },
}