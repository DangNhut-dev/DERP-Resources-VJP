Config = {}

Config.Dealers = {
    {
        name = "Nhận Xe Police",
        job = "police", -- Job yêu cầu (false = ai cũng mua được)
        npc = {
            model = "a_m_y_business_01",
            coords = vec4(459.27, -1007.94, 28.26, 90.03),
        },
        spawnPoint = vec4(455.14, -1018.27, 28.00, 90.99),
        vehicles = {
            { model = "npolvic", label = "Ford Crown Victoria", price = 1000, minGrade = 1 },
            { model = "clrgtaurus", label = "Ford Taurus", price = 1000, minGrade = 2 },
            { model = "npolmm", label = "Moto", price = 1000, minGrade = 3 },
            { model = "npolexp", label = "Ford Explorer", price = 1000, minGrade = 3 },
            { model = "npolchal", label = "Dodge Challenger", price = 1000, minGrade = 4 },
            { model = "npolstang", label = "Ford Mustang", price = 1000, minGrade = 6 },
            { model = "npolvette", label = "Corvette C7", price = 1000, minGrade = 8 },
            { model = "npolchar", label = "Dodge Charger", price = 1000, minGrade = 9 },
        },
    },
}

-- Cấu hình thông báo
Config.Notifications = {
    notEligible = "Bạn không đủ grade để mua xe này!",
    alreadyPurchased = "Bạn đã mua xe này rồi!",
    noMoney = "Số dư tài khoản không đủ!",
    success = "Bạn đã mua thành công xe %s!",
    spawnBlocked = "Khu vực spawn xe đang bị chặn, vui lòng thử lại sau!",
    noVehicle = "Không tìm thấy mẫu xe này!",
    notPolice = "Bạn không phải là cảnh sát!",
}

-- Bán kính kiểm tra NPC
Config.NpcInteractionRadius = 2.5

-- Thời gian chờ giữa các lần tương tác (ms)
Config.Cooldown = 1000
