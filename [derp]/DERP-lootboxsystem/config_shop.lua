Config.Shop = {}

Config.Shop.BuyCooldown = 3

Config.Shop.NPCs = {
    ['npc_shop_1'] = {
        model  = 's_m_m_highsec_01',
        coords = vec4(135.40, -1025.61, 29.36, 160.11),
        defaultPayment = 'coin',

        blip = {
            enabled = true,
            sprite  = 73,
            color   = 15,
            scale   = 0.8,
            label   = 'Cửa Hàng Quần Áo'
        },

        items = {
            -- ['thuong_box'] = {
            --     id    = 1,
            --     label = 'thuong Lootbox',
            --     price = { coin = 1 },
            --     tags  = { 'new', 'bestseller' }
            -- },
            ['lootbox_nam_thuong_aokhoac'] = {
                id    = 1,
                label = 'Hòm Áo Thường - Nam',
                price = { cash = 200 },
                tags  = { 'male' }
            },
            ['lootbox_nam_thuong_quan'] = {
                id    = 2,
                label = 'Hòm Quần Thường - Nam',
                price = { cash = 200 },
                tags  = { 'male' }
            },
            ['lootbox_nam_thuong_giay'] = {
                id    = 3,
                label = 'Hòm Giày Thường - Nam',
                price = { cash = 200 },
                tags  = { 'male' }
            },
            ['lootbox_nam_thuong_matna'] = {
                id    = 4,
                label = 'Hòm Mặt Nạ Thường - Nam',
                price = { cash = 200 },
                tags  = { 'male' }
            },
            ['lootbox_nu_thuong_aokhoac'] = {
                id    = 5,
                label = 'Hòm Áo Thường - Nữ',
                price = { cash = 200 },
                tags  = { 'female' }
            },
            ['lootbox_nu_thuong_quan'] = {
                id    = 6,
                label = 'Hòm Quần Thường - Nữ',
                price = { cash = 200 },
                tags  = { 'female' }
            },
            ['lootbox_nu_thuong_giay'] = {
                id    = 7,
                label = 'Hòm Giày Thường - Nữ',
                price = { cash = 200 },
                tags  = { 'female' }
            },
            ['lootbox_nu_thuong_matna'] = {
                id    = 8,
                label = 'Hòm Mặt Nạ Thường - Nữ',
                price = { cash = 200 },
                tags  = { 'female' }
            },
            ['lootbox_nam_aokhoac_s1'] = {
                id    = 1,
                label = 'Hòm Áo Đợt 1 - Nam',
                price = { coin = 7},
                tags  = { 'male' }
            },
            ['lootbox_nam_quan_s1'] = {
                id    = 2,
                label = 'Hòm Quần Đợt 1 - Nam',
                price = { coin = 7},
                tags  = { 'male' }
            },
            ['lootbox_nam_giay_s1'] = {
                id    = 3,
                label = 'Hòm Giày Đợt 1 - Nam',
                price = { coin = 7},
                tags  = { 'male' }
            },
            ['lootbox_nam_matna_s1'] = {
                id    = 4,
                label = 'Hòm Mặt Nạ Đợt 1 - Nam',
                price = { coin = 7},
                tags  = { 'male' }
            },
            ['lootbox_nam_balo_s1'] = {
                id    = 5,
                label = 'Hòm Balo Đợt 1 - Nam',
                price = { coin = 20},
                tags  = { 'male' }
            },
            ['lootbox_nu_aokhoac_s1'] = {
                id    = 6,
                label = 'Hòm Áo Đợt 1 - Nữ',
                price = { coin = 7},
                tags  = { 'female' }
            },
            ['lootbox_nu_aotrong_s1'] = {
                id    = 7,
                label = 'Hòm Áo Trong Đợt 1 - Nữ',
                price = { coin = 7},
                tags  = { 'female' }
            },
            ['lootbox_nu_balo_s1'] = {
                id    = 8,
                label = 'Hòm Balo Đợt 1 - Nữ',
                price = { coin = 20},
                tags  = { 'female' }
            },
            ['lootbox_nu_quan_s1'] = {
                id    = 9,
                label = 'Hòm Quần Đợt 1 - Nữ',
                price = { coin = 7},
                tags  = { 'female' }
            },
            ['lootbox_nu_giay_s1'] = {
                id    = 10,
                label = 'Hòm Giày Đợt 1 - Nữ',
                price = { coin = 7},
                tags  = { 'female' }
            },
            ['lootbox_nu_matna_s1'] = {
                id    = 11,
                label = 'Hòm Mặt Nạ Đợt 1 - Nữ',
                price = { coin = 7},
                tags  = { 'female' }
            },
            ['lootbox_nam_aokhoac_s2'] = {
                id    = 12,
                label = 'Hòm Áo Đợt 2 - Nam',
                price = { coin = 5, cash = 2500},
                tags  = { 'male', 'new' }
            },
            ['lootbox_nu_aokhoac_s2'] = {
                id    = 13,
                label = 'Hòm Áo Đợt 2 - Nữ',
                price = { coin = 5, cash = 2500},
                tags  = { 'female', 'new' }
            },
            ['lootbox_nu_aotrong_s2'] = {
                id    = 14,
                label = 'Hòm áo trong Đợt 2 - Nữ',
                price = { coin = 5, cash = 2500},
                tags  = { 'female', 'new' }
            },
            ['lootbox_nam_balo_s2'] = {
                id    = 15,
                label = 'Hòm Balo Đợt 2 - Nam',
                price = { coin = 15, cash = 7500},
                tags  = { 'male', 'new' }
            },
            ['lootbox_nu_balo_s2'] = {
                id    = 16,
                label = 'Hòm Balo Đợt 2 - Nữ',
                price = { coin = 15, cash = 7500},
                tags  = { 'female', 'new' }
            },
            ['lootbox_nu_daychuyen_s2'] = {
                id    = 17,
                label = 'Hòm Dây Chuyền Đợt 2 - Nữ',
                price = { coin = 5, cash = 2500},
                tags  = { 'female', 'new' }
            },
            ['lootbox_nam_giay_s2'] = {
                id    = 18,
                label = 'Hòm Giày Đợt 2 - Nam',
                price = { coin = 5, cash = 2500},
                tags  = { 'male', 'new' }
            },
            ['lootbox_nu_giay_s2'] = {
                id    = 19,
                label = 'Hòm Giày Đợt 2 - Nữ',
                price = { coin = 5, cash = 2500},
                tags  = { 'female', 'new' }
            },
            ['lootbox_nam_matna_s2'] = {
                id    = 20,
                label = 'Hòm Mặt Nạ Đợt 2 - Nam',
                price = { coin = 5, cash = 2500},
                tags  = { 'male', 'new' }
            },
            ['lootbox_nu_matna_s2'] = {
                id    = 21,
                label = 'Hòm Mặt Nạ Đợt 2 - Nữ',
                price = { coin = 5, cash = 2500},
                tags  = { 'female', 'new' }
            },
            ['lootbox_nam_mu_s2'] = {
                id    = 22,
                label = 'Hòm Mũ Đợt 2 - Nam',
                price = { coin = 5, cash = 2500},
                tags  = { 'male', 'new' }
            },
            ['lootbox_nam_nonfullface_s2'] = {
                id    = 23,
                label = 'Hòm Nón Bảo Hiểm Đợt 2 - Nam',
                price = { coin = 10, cash = 5000},
                tags  = { 'male', 'new' }
            },
            ['lootbox_nu_mu_s2'] = {
                id    = 24,
                label = 'Hòm Mũ Đợt 2 - Nữ',
                price = { coin = 5, cash = 2500},
                tags  = { 'female', 'new' }
            },
            ['lootbox_nam_quan_s2'] = {
                id    = 25,
                label = 'Hòm Quần Đợt 2 - Nam',
                price = { coin = 5, cash = 2500},
                tags  = { 'male', 'new' }
            },
        }
    },
    ['npc_shop_2'] = {
        model  = 's_m_m_highsec_02',
        coords = vec4(133.45, -1024.74, 29.36, 84.47),
        defaultPayment = 'coin',

        blip = {
            enabled = false,
            sprite  = 73,
            color   = 15,
            scale   = 0.8,
            label   = 'Cửa Hàng Vật Phẩm'
        },

        items = {
            ['boombox_blue_large'] = {
                id    = 1,
                label = 'Boombox xanh (Lớn)',
                price = { coin = 200 },
                tags  = { 'new'}
            },
            ['boombox_blue_medium'] = {
                id    = 2,
                label = 'Boombox xanh (Vừa)',
                price = { coin = 100 },
                tags  = { 'new'}
            },
            ['boombox_blue_small'] = {
                id    = 3,
                label = 'Boombox xanh (Nhỏ)',
                price = { coin = 50 },
                tags  = { 'new'}
            },
            ['boombox_green_large'] = {
                id    = 4,
                label = 'Boombox lục (Lớn)',
                price = { coin = 200 },
                tags  = { 'new'}
            },
            ['boombox_green_medium'] = {
                id    = 5,
                label = 'Boombox lục (Vừa)',
                price = { coin = 100 },
                tags  = { 'new'}
            },
            ['boombox_green_small'] = {
                id    = 6,
                label = 'Boombox lục (Nhỏ)',
                price = { coin = 50 },
                tags  = { 'new'}
            },
            ['boombox_orange_large'] = {
                id    = 7,
                label = 'Boombox cam (Lớn)',
                price = { coin = 200 },
                tags  = { 'new'}
            },
            ['boombox_orange_medium'] = {
                id    = 8,
                label = 'Boombox cam (Vừa)',
                price = { coin = 100 },
                tags  = { 'new'}
            },
            ['boombox_orange_small'] = {
                id    = 9,
                label = 'Boombox cam (Nhỏ)',
                price = { coin = 50 },
                tags  = { 'new'}
            },
            ['boombox_pink_large'] = {
                id    = 10,
                label = 'Boombox hồng (Lớn)',
                price = { coin = 200 },
                tags  = { 'new'}
            },
            ['boombox_pink_medium'] = {
                id    = 11,
                label = 'Boombox hồng (Vừa)',
                price = { coin = 100 },
                tags  = { 'new'}
            },
            ['boombox_pink_small'] = {
                id    = 12,
                label = 'Boombox hồng (Nhỏ)',
                price = { coin = 50 },
                tags  = { 'new'}
            },
            ['boombox_purple_large'] = {
                id    = 13,
                label = 'Boombox tím (Lớn)',
                price = { coin = 200 },
                tags  = { 'new'}
            },
            ['boombox_purple_medium'] = {
                id    = 14,
                label = 'Boombox tím (Vừa)',
                price = { coin = 100 },
                tags  = { 'new'}
            },
            ['boombox_purple_small'] = {
                id    = 15,
                label = 'Boombox tím (Nhỏ)',
                price = { coin = 50 },
                tags  = { 'new'}
            },
            ['boombox_red_large'] = {
                id    = 16,
                label = 'Boombox đỏ (Lớn)',
                price = { coin = 200 },
                tags  = { 'new'}
            },
            ['boombox_red_medium'] = {
                id    = 17,
                label = 'Boombox đỏ (Vừa)',
                price = { coin = 100 },
                tags  = { 'new'}
            },
            ['boombox_red_small'] = {
                id    = 18,
                label = 'Boombox đỏ (Nhỏ)',
                price = { coin = 50 },
                tags  = { 'new'}
            },
            ['boombox_white_large'] = {
                id    = 19,
                label = 'Boombox trắng (Lớn)',
                price = { coin = 200 },
                tags  = { 'new'}
            },
            ['boombox_white_medium'] = {
                id    = 20,
                label = 'Boombox trắng (Vừa)',
                price = { coin = 100 },
                tags  = { 'new'}
            },
            ['boombox_white_small'] = {
                id    = 21,
                label = 'Boombox trắng (Nhỏ)',
                price = { coin = 50 },
                tags  = { 'new'}
            },
            ['lootbox_skin_knife_s1'] = {
                id    = 22,
                label = 'Hòm Dao Đợt 1',
                price = { coin = 15},
                tags  = { 'new'}
            },
            -- ['weapon_katanablackgold'] = {
            --     id    = 23,
            --     label = 'Hòm Dao Đợt 1',
            --     price = { coin = 100},
            --     tags  = { 'new'}
            -- },
        }
    }
}