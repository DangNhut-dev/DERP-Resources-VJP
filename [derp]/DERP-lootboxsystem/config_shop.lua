Config.Shop = {}

Config.Shop.BuyCooldown = 3

Config.Shop.NPCs = {
    ['npc_shop_1'] = {
        model  = 's_m_m_highsec_01',
        coords = vec4(199.50, -870.66, 30.71, 158.85),
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
    }
}