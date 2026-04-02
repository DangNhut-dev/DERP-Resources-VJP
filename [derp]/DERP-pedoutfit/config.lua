Config = {}

-- Model freemode — KHÔNG hiển thị textUI
Config.FreemodeModels = {
    [`mp_m_freemode_01`] = true,
    [`mp_f_freemode_01`] = true,
}

-- Phím tương tác
Config.Key = 38 -- [E]

-- TextUI label
Config.TextUILabel = '[E] Thay quần áo'

-- Zones (ox_lib): thêm bao nhiêu tùy ý
-- type: 'sphere' | 'box' | 'poly'
Config.Zones = {
    {
        name   = 'clothing_room_1',
        type   = 'sphere',
        coords = vector3(190.70, -884.25, 30.71), -- ví dụ, thay bằng coords thật
        radius = 2.0,
    },
    -- {
    --     name   = 'clothing_room_2',
    --     type   = 'box',
    --     coords = vector3(0.0, 0.0, 0.0),
    --     size   = vector3(3.0, 3.0, 2.0),
    --     rotation = 0.0,
    -- },
}
