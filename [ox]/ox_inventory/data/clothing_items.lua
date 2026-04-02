-- data/clothing_items.lua
-- Add these to your ox_inventory items configuration
-- Each clothing item: no weight, no stack, image from /clothes/ folder

return {
    -- Metadata format:
    -- drawableId (number) - GTA drawable index
    -- textureId (number)  - GTA texture index
    -- gender (number)     - 0 = male, 1 = female
    -- label auto-generated: "Áo khoác" (from config)
    -- image auto-generated: clothes/aokhoac_3_1_0.png (name_drawable_texture_gender)

    ['mu'] = {
        label = 'Mũ',
        weight = 0,
        stack = false,
        close = true,
        description = 'Mũ đội đầu',
        client = {
            image = 'clothes/%s.png', -- formatted with metadata
        }
    },
    ['matna'] = {
        label = 'Mặt nạ',
        weight = 0,
        stack = false,
        close = true,
        description = 'Mặt nạ che mặt',
    },
    ['aokhoac'] = {
        label = 'Áo khoác',
        weight = 0,
        stack = false,
        close = true,
        description = 'Áo khoác ngoài',
    },
    ['aotrong'] = {
        label = 'Áo trong',
        weight = 0,
        stack = false,
        close = true,
        description = 'Áo lót bên trong',
    },
    ['tay'] = {
        label = 'Găng tay',
        weight = 0,
        stack = false,
        close = true,
        description = 'Găng tay',
    },
    ['quan'] = {
        label = 'Quần',
        weight = 0,
        stack = false,
        close = true,
        description = 'Quần dài',
    },
    ['giay'] = {
        label = 'Giày',
        weight = 0,
        stack = false,
        close = true,
        description = 'Giày dép',
    },
    ['kinh'] = {
        label = 'Kính',
        weight = 0,
        stack = false,
        close = true,
        description = 'Kính mắt',
    },
    ['khuyentai'] = {
        label = 'Khuyên tai',
        weight = 0,
        stack = false,
        close = true,
        description = 'Khuyên tai trang sức',
    },
    ['daychuyen'] = {
        label = 'Dây chuyền',
        weight = 0,
        stack = false,
        close = true,
        description = 'Dây chuyền cổ',
    },
    ['balo'] = {
        label = 'Ba lô',
        weight = 0,
        stack = false,
        close = true,
        description = 'Ba lô đeo lưng',
    },
    ['giap'] = {
        label = 'Giáp',
        weight = 0,
        stack = false,
        close = true,
        description = 'Áo giáp bảo vệ',
    },
    ['dongho'] = {
        label = 'Đồng hồ',
        weight = 0,
        stack = false,
        close = true,
        description = 'Đồng hồ đeo tay',
    },
    ['vongtay'] = {
        label = 'Vòng tay',
        weight = 0,
        stack = false,
        close = true,
        description = 'Vòng tay trang sức',
    },
}