Config = {}

-- Model và vị trí ped nâng cấp (đặt đúng tọa độ server của bạn)
Config.PedModel  = 'a_m_y_business_02'
Config.PedCoords = vector4(192.95, -876.25, 30.71, 256.94)

-- Điểm cộng theo rarity của item nguyên liệu
Config.RarityPoints = {
    common    = 10,
    rare      = 50,
    epic      = 250,
    legendary = 1250,
    mythic    = 6250,
}

-- key = level hiện tại của balo, value = điểm cần để đạt 100% tỉ lệ
-- Balo ở level không có trong bảng này sẽ không thể nâng cấp (đã max)
Config.RequirePoints = {
    [0] = 100,
    [1] = 500,
    [2] = 2500,
    [3] = 4000,
    [4] = 12500,
    [5] = 15000,
    [6] = 15500,
    [7] = 16000,
    [8] = 16500,
    [9] = 17000,
}

-- Số slot nguyên liệu tối đa mỗi lần nâng cấp
Config.MaxMaterialSlots = 5