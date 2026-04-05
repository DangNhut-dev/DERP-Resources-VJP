Config = {}

-- Model và vị trí prop nâng cấp (đặt đúng tọa độ server của bạn)
Config.PropModel  = 'prop_sewing_machine'
Config.PropCoords = vector4(194.81, -876.99, 31.27, 66.88)

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
}

-- Số slot nguyên liệu tối đa mỗi lần nâng cấp
Config.MaxMaterialSlots = 5
