Config = {}

-- Model và vị trí prop nâng cấp (đặt đúng tọa độ server của bạn)
Config.PropModel  = 'prop_sewing_machine'
Config.PropCoords = vector4(194.81, -876.99, 31.27, 66.88)

-- Điểm cộng theo rarity của item nguyên liệu
Config.RarityPoints = {
    common    = 10,
    rare      = 25,
    epic      = 60,
    legendary = 150,
    mythic    = 400,
}

-- key = level hiện tại của balo, value = điểm cần để đạt 100% tỉ lệ
-- Balo ở level không có trong bảng này sẽ không thể nâng cấp (đã max)
Config.RequirePoints = {
    [0] = 500,
    [1] = 1000,
    [2] = 2000,
    [3] = 4000,
    [4] = 8000,
    [5] = 16000,
}

-- Số slot nguyên liệu tối đa mỗi lần nâng cấp
Config.MaxMaterialSlots = 5
