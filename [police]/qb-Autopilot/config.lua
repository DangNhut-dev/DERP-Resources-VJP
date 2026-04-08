Config = {}

Config.rpmlimiter = 45 -- Giới hạn RPM động cơ (35-55, thấp hơn thì động cơ gầm mạnh hơn)
Config.speedlimiter = true -- Bật/tắt giới hạn tốc độ theo đường
Config.speedunits = 'mph' -- Đơn vị tốc độ (mph hoặc km/h)
Config.defaultspeedlimit = 35 -- Tốc độ mặc định nếu đường không trong danh sách (mph)
Config.topspeed = 200 -- Tốc độ tối đa của xe khi không giới hạn (mph)
Config.notify = true -- Bật/tắt thông báo
Config.notifyengaged = 'Tuân thủ tốc độ cho phép' -- Thông báo khi bật tự động lái
Config.notifydisengaged = 'Bỏ qua việc tuân thủ tốc độ' -- Thông báo khi tắt tự động lái
Config.notifyspeedlimit = 'Tốc độ cho phép: %s'..Config.speedunits -- Thông báo khi tốc độ đường thay đổi
Config.cruisehudenabled = true -- Hiển thị icon tự động lái trên HUD (qb-hud, qbx_hud, fd_hud)

Config.streets = {  -- Danh sách đường và giới hạn tốc độ (mph)
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
    { name = 'Olympic Fwy', speed = 90 },
    { name = 'Del Perro Fwy', speed = 90 },
    { name = 'La Puerta Fwy', speed = 90 },
    { name = 'Los Santos Freeway', speed = 90 },
    { name = 'Palomino Fwy', speed = 90 },
    { name = 'Route 68', speed = 50 },
    --{ name = 'Baytree Canyon Rd', speed = 50 },
}