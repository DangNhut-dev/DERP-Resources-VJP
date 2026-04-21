Config = {}

Config.Debug = false

Config.MaxPlantsPerPlayer = 7 -- Số cây tối đa mỗi người có thể trồng

-- ===========================================
-- CÁC LOẠI HẠT GIỐNG (SEED TYPES)
-- ===========================================
Config.SeedTypes = {
    ['cannabis_seed_indica'] = {
        name = 'Indica',
        label = 'Hạt Cần Sa Indica',
        
        -- Thời gian phát triển (ms)
        growthTime = 14400000, -- 2 phút
        -- growthTime = 1000,
        
        -- Thời gian héo sau khi sẵn sàng thu hoạch (ms)
        witherTime = 120000, -- 30 giây
        
        -- Props cho từng giai đoạn (custom props)
        props = {
            stage1 = 'nui_props_weed_stage1', -- 0-33%
            stage2 = 'nui_props_weed_stage2', -- 33-66%
            stage3 = 'nui_props_weed_stage3', -- 66-100% (sẵn sàng)
            withered = 'nui_props_weed_stage1', -- Cây héo
        },
        
        -- Sản phẩm thu hoạch
        harvestItem = 'indica_bud',
        harvestAmount = {
            base = 5, -- Số lượng cơ bản
            withUVLight = 10, -- Số lượng khi có đèn UV
        },
        
        -- Yêu cầu nước
        waterRequirement = {
            enabled = true, -- Bật yêu cầu nước
            maxWater = 100, -- Thanh nước tối đa (%)
            drainRate = 0.02, -- Mất bao nhiêu % nước mỗi giây phát triển
        },
        
        -- Phân bón
        fertilizerBonus = 0.2, -- Giảm 30% thời gian phát triển khi bón phân
    },
    
    ['cannabis_seed_sativa'] = {
        name = 'Sativa',
        label = 'Hạt Cần Sa Sativa',
        growthTime = 14400000, 
        witherTime = 120000,
        props = {
            stage1 = 'nui_props_weed_stage1b',
            stage2 = 'nui_props_weed_stage2b',
            stage3 = 'nui_props_weed_stage3b',
            withered = 'nui_props_weed_stage1b',
        },
        harvestItem = 'sativa_bud',
        harvestAmount = {
            base = 5,
            withUVLight = 10,
        },
        waterRequirement = {
            enabled = true,
            maxWater = 100,
            drainRate = 0.02, 
        },
        fertilizerBonus = 0.2,
    },
    
    ['cannabis_seed_hybrid'] = {
        name = 'Hybrid',
        label = 'Hạt Cần Sa Hybrid',
        growthTime = 14400000, 
        witherTime = 120000,
        props = {
            stage1 = 'nui_props_weed_stage1c',
            stage2 = 'nui_props_weed_stage2c',
            stage3 = 'nui_props_weed_stage3c',
            withered = 'nui_props_weed_stage1c',
        },
        harvestItem = 'hybrid_bud',
        harvestAmount = {
            base = 5,
            withUVLight = 10,
        },
        waterRequirement = {
            enabled = true,
            maxWater = 100,
            drainRate = 0.02, 
        },
        fertilizerBonus = 0.2,
    },
}

-- ===========================================
-- PHẦN THƯỞNG HẠT GIỐNG KHI THU HOẠCH
-- ===========================================
Config.SeedReward = {
    enabled = true, 
    chances = {
        { chance = 10, amount = 2 },  
        { chance = 90, amount = 1 },
    }
}

-- ===========================================
-- VẬT PHẨM HỖ TRỢ
-- ===========================================
Config.WaterItemName = 'nutrient_solution'
Config.FertilizerItemName = 'fertilizer' 
Config.UVLightItemName = 'uv_lamp'

-- Props đèn UV
Config.UVLightProp = 'bzzz_world_of_lamps_purple'
Config.UVLightOffset = vector3(0.25, 0.17, -1.0)

-- ===========================================
-- THỜI GIAN COOLDOWN
-- ===========================================
Config.WaterCooldown = 5000 
Config.FertilizerCooldown = 10000

-- ===========================================
-- KIỂM TRA ĐẤT HỢP LỆ
-- ===========================================
Config.ValidGroundMaterials = {
    [0] = true,  -- Đất
    [1] = true,  -- Cỏ
    [2] = true,  -- Đất ẩm
    [3] = true,  -- Cỏ khô
}

-- ===========================================
-- HỆ THỐNG SẤY CẦN
-- ===========================================
Config.DryingRack = {
    item = 'drying_rack', -- Item để đặt bàn sấy
    emptyProp = 'nui_weed_rack_2', -- Prop khi trống
    fullProp = 'nui_weed_rack_1', -- Prop khi đang sấy
    
    -- Thời gian sấy
    dryingTime = 3600000, -- 5 phút (300000ms)
    
    -- Thời gian có thể thu hoạch sau khi sấy xong
    gracePeriod = 300000, -- 1 phút (60000ms)
    
    inputItems = { -- Các loại cần có thể sấy
        ['indica_bud'] = 'indica_bud_dried',
        ['sativa_bud'] = 'sativa_bud_dried',
        ['hybrid_bud'] = 'hybrid_bud_dried',
    },
    
    ruinedItem = 'ruined_bud', -- Item khi để quá lâu
    
    maxRacksPerPlayer = 1, -- Tối đa bàn sấy mỗi người
    
    gridSize = 3, 
}

-- ===========================================
-- TẨM CẦN SA
-- ===========================================
-- Config.InfusionLocations = {
--     vector3(607.42, -3092.61, 6.07),
-- }
-- Config.InfusionZoneSize = 2.0

-- Config.InfusionRecipes = {
--     ['sour_diesel'] = {
--         quality = 'high',
--         label = 'Sour Diesel',
--         ingredients = {
--             ['indica_bud_dried'] = 1,
--             ['weapon_petrolcan'] = 1,
--         },
--         time = {
--             min = 3,
--             max = 5
--         },
--         output = {
--             high = { item = 'sour_diesel_bud_high', amount = 1 },
--             medium = { item = 'sour_diesel_bud_medium', amount = 1 },
--             low = { item = 'sour_diesel_bud_low', amount = 1 }
--         }
--     },
-- }

-- ===========================================
-- ANTI-EXPLOIT
-- ===========================================
Config.AntiExploit = {
    MinTimeBetweenPlants = 2000,
    MinTimeBetweenWatering = 3000,
    MinTimeBetweenHarvest = 2000,
    MinTimeBetweenProcessing = 5000,
    MinTimeBetweenFertilizer = 3000,
    MinTimeBetweenUVLight = 5000,
    MaxDistanceFromPlant = 5.0,
    MaxDistanceFromRack = 5.0,
}

Config.MinPlantDistance = 1.0 -- Khoảng cách tối thiểu giữa các cây (mét)

Config.PlantDistance = 0.8 -- Khoảng cách trồng cây trước mặt (mét)

-- ===========================================
-- THÔNG BÁO
-- ===========================================
Config.Notifications = {
    -- Trồng cây
    ['invalid_location'] = 'Bạn không thể trồng cây ở đây! Cần trồng trên đất hoặc cỏ.',
    ['plant_placed'] = 'Bạn đã gieo hạt %s!',
    ['already_planting'] = 'Bạn đang gieo hạt...',
    ['max_plants_reached'] = 'Bạn đã đạt giới hạn trồng cây! (Tối đa: %s cây)',
    ['too_fast_planting'] = 'Bạn đang trồng quá nhanh!',
    ['no_seed'] = 'Bạn không có hạt giống!',
    
    -- Thêm Nước Dinh Dưỡng
    ['no_water'] = 'Bạn cần nước dinh dưỡng để tưới cây!',
    ['plant_watered'] = 'Tưới nước thành công!',
    ['watering'] = 'Đang tưới nước dinh dưỡng...',
    ['too_fast_watering'] = 'Bạn đang làm quá nhanh!',
    ['too_far_from_plant'] = 'Bạn đứng quá xa cây!',
    ['water_full'] = 'Cây đã đầy nước rồi!',
    ['water_cooldown'] = 'Cây này vừa được thêm! Hãy đợi %s giây nữa.',
    ['water_depleted'] = 'Cây đã hết nước dinh dưỡng! Cây tạm ngừng phát triển.',
    
    -- Phân bón
    ['no_fertilizer'] = 'Bạn cần phân bón!',
    ['fertilizer_applied'] = 'Bón phân thành công!',
    ['fertilizing'] = 'Đang bón phân...',
    ['already_fertilized'] = 'Cây này đã được bón phân rồi!',
    ['too_fast_fertilizing'] = 'Bạn đang bón phân quá nhanh!',
    
    -- Đèn UV
    ['no_uv_light'] = 'Bạn cần đèn UV!',
    ['uv_light_placed'] = 'Đặt đèn thành công!',
    ['placing_uv_light'] = 'Đang đặt đèn UV...',
    ['already_has_uv'] = 'Cây này đã có đèn UV rồi!',
    ['too_fast_uv'] = 'Bạn đang đặt đèn quá nhanh!',
    ['uv_light_removed'] = 'Đã gỡ đèn UV.',
    
    -- Thu hoạch
    ['not_ready'] = 'Cây chưa lớn đủ để thu hoạch!',
    ['harvesting'] = 'Đang thu hoạch...',
    ['harvest_success'] = 'Thu hoạch thành công!',
    ['too_fast_harvesting'] = 'Bạn đang thu hoạch quá nhanh!',
    ['not_your_plant'] = 'Đây không phải cây của bạn!',
    ['plant_withered'] = 'Cây đã héo! Bạn không thể thu hoạch nữa.',
    ['plant_ready_harvest'] = 'Cây %s đã sẵn sàng thu hoạch! Hãy thu hoạch trước khi cây héo!',
    ['no_scissors']     = 'Bạn cần kéo để thu hoạch.',
    ['scissors_broken'] = 'Kéo của bạn đã hỏng.',
    
    -- Phá cây
    ['burning_plant'] = 'Đang phá cây...',
    ['plant_burned'] = 'Phá cây thành công!',
    ['cannot_burn_ready'] = 'Không thể phá cây đang sẵn sàng thu hoạch!',
    
    -- Sấy cần
    ['rack_placed'] = 'Đã đặt kệ phơi!',
    ['rack_removed'] = 'Đã thu kệ phơi!',
    ['max_racks_reached'] = 'Bạn đã đạt giới hạn kệ phơi! (Tối đa: %s bàn)',
    ['no_drying_rack_item'] = 'Bạn không có kệ phơi!',
    ['rack_not_empty'] = 'Kệ phơi đang có cần! Hãy lấy cần trước.',
    ['drying_started'] = 'Đã bắt đầu phơi %s nụ!',
    ['drying_collected'] = 'Đã thu hoạch %s nụ khô!',
    ['drying_ruined'] = 'Nụ đã bị hư!',
    ['no_valid_buds'] = 'Không có nụ hợp lệ để phơi!',
    ['rack_still_drying'] = 'Bàn phơi đang phơi! Hãy đợi thêm.',
    ['too_far_from_rack'] = 'Bạn đứng quá xa kệ phơi!',
}

-- ===========================================
-- HỆ THỐNG TẨM CẦN SA (INFUSION SYSTEM)
-- ===========================================
Config.InfusionTableItem = 'infusion_table' -- Item để đặt bàn tẩm
Config.InfusionTableProp = 'nui_weed_table_1' -- Prop bàn tẩm
Config.MaxInfusionTablesPerPlayer = 1 -- Tối đa bàn tẩm mỗi người
Config.InfusionInteractionDistance = 2.5

-- ===========================================
-- CÔNG THỨC TẨM (INFUSION RECIPES)
-- ===========================================
Config.InfusionRecipes = {

    -- INDICA
    ['sour_diesel'] = { 
        bud_type = 'indica_bud_dried',
        bud_amount = 1,
        ingredients = {
            -- ['herbal_oil'] = 3,
            ['glycerin'] = 2,
            ['flavor_oil'] = 1,
            ['curing_agent'] = 1,
            ['herbal_mix'] = 1,
        },
        time = { min = 23.0, max = 28.0 },
        output = { high = 'sour_diesel_high', medium = 'sour_diesel_medium', low = 'sour_diesel_low' }
    },

    ['purple_haze'] = {
        bud_type = 'indica_bud_dried',
        bud_amount = 1,
        ingredients = {
            ['lavender_essence'] = 2,
            ['curing_agent'] = 1,
            ['glycerin'] = 1,
        },
        time = { min = 19.0, max = 24.0 },
        output = { high = 'purple_haze_high', medium = 'purple_haze_medium', low = 'purple_haze_low' }
    },

    ['northern_lights'] = { 
        bud_type = 'indica_bud_dried',
        bud_amount = 1,
        ingredients = {
            ['flavor_oil'] = 1,
            ['herbal_mix'] = 1,
            ['curing_agent'] = 1,
            ['herbal_oil'] = 1,
        },
        time = { min = 27.0, max = 32.0 },
        output = { high = 'northern_lights_high', medium = 'northern_lights_medium', low = 'northern_lights_low' }
    },

    -- SATIVA
    ['blue_dream'] = {
        bud_type = 'sativa_bud_dried',
        bud_amount = 1,
        ingredients = {
            ['citrus_extract'] = 2,
            ['peppermint'] = 1,
        },
        time = { min = 15.0, max = 20.0 },
        output = { high = 'blue_dream_high', medium = 'blue_dream_medium', low = 'blue_dream_low' }
    },

    ['jack_herer'] = { 
        bud_type = 'sativa_bud_dried',
        bud_amount = 1,
        ingredients = {
            ['ethanol'] = 2,
            ['citrus_extract'] = 1,
            ['stabilizer'] = 1,
            ['herbal_mix'] = 1,
            ['glycerin'] = 1,
        },
        time = { min = 31.0, max = 36.0 },
        output = { high = 'jack_herer_high', medium = 'jack_herer_medium', low = 'jack_herer_low' }
    },

    ['super_lemon_haze'] = { 
        bud_type = 'sativa_bud_dried',
        bud_amount = 1,
        ingredients = {
            ['lemon_essence'] = 2,
            ['stabilizer'] = 1,
            ['citrus_extract'] = 1,
            ['peppermint'] = 1,
        },
        time = { min = 21.0, max = 26.0 },
        output = { high = 'super_lemon_haze_high', medium = 'super_lemon_haze_medium', low = 'super_lemon_haze_low' }
    },

    -- HYBRID
    ['og_kush'] = { 
        bud_type = 'hybrid_bud_dried',
        bud_amount = 1,
        ingredients = {
            ['flavor_oil'] = 2,
            ['curing_agent'] = 1,
            ['herbal_oil'] = 1,
        },
        time = { min = 14.0, max = 28.0 },
        output = { high = 'og_kush_high', medium = 'og_kush_medium', low = 'og_kush_low' }
    },

    ['gsc'] = {
        bud_type = 'hybrid_bud_dried',
        bud_amount = 1,
        ingredients = {
            ['herbal_mix'] = 2,
            ['glycerin'] = 1,
            ['vanilla_extract'] = 1,
            ['curing_agent'] = 1,
        },
        time = { min = 18.0, max = 30.0 },
        output = { high = 'gsc_high', medium = 'gsc_medium', low = 'gsc_low' }
    },

    ['wedding_cake'] = {
        bud_type = 'hybrid_bud_dried',
        bud_amount = 1,
        ingredients = {
            ['vanilla_extract'] = 2,
            ['flavor_oil'] = 1,
            ['herbal_oil'] = 1,
            ['glycerin'] = 1,
            ['curing_agent'] = 1,
        },
        time = { min = 29.0, max = 34.0 },
        output = { high = 'wedding_cake_high', medium = 'wedding_cake_medium', low = 'wedding_cake_low' }
    },
}


Config.InfusionRuinedItem = 'ruined_infusion'

-- ===========================================
-- THÔNG BÁO TẨM
-- ===========================================
Config.InfusionNotifications = {
    ['table_placed'] = 'Đã đặt bàn tẩm!',
    ['table_removed'] = 'Đã thu bàn tẩm!',
    ['max_tables_reached'] = 'Bạn đã đạt giới hạn bàn tẩm! (Tối đa: %s bàn)',
    ['no_table_item'] = 'Bạn không có bàn tẩm!',
    ['table_in_use'] = 'Bàn tẩm đang được sử dụng!',
    ['too_far_from_table'] = 'Bạn đứng quá xa bàn tẩm!',
    
    ['no_bud_selected'] = 'Chưa chọn loại cần!',
    ['no_ingredients'] = 'Chưa có nguyên liệu!',
    ['missing_bud'] = 'Bạn không có %s!',
    ['missing_ingredient'] = 'Bạn thiếu nguyên liệu: %s',
    ['infusion_started'] = 'Bắt đầu tẩm! Bấm "Dừng" khi muốn lấy kết quả.',
    
    ['infusion_ruined'] = 'Công thức sai! Nhận được %s.',
    ['infusion_low'] = 'Thiếu nguyên liệu! Chất lượng thấp: %s.',
    ['infusion_medium'] = 'Thời gian không chuẩn! Chất lượng trung bình: %s.',
    ['infusion_high'] = 'Hoàn hảo! Chất lượng cao: %s.',
}

-- ===========================================
-- ANTI-EXPLOIT CHO TẨM
-- ===========================================
Config.InfusionAntiExploit = {
    MinTimeBetweenInfusion = 3000, -- 3 giây giữa mỗi lần tẩm
    MinInfusionTime = 0.5, -- Thời gian tối thiểu để tính kết quả (0.5 giây)
    MaxDistanceFromTable = 3.0, -- Khoảng cách tối đa từ bàn tẩm
}