Config = {}

-- Khoảng cách để hiển thị DrawText3D
Config.DrawDistance = 10.0

-- Khoảng cách tối đa để tương tác
Config.InteractDistance = 3.0

-- Thời gian cooldown giữa các lần spawn (milliseconds)
Config.SpawnCooldown = 2000

-- ✅ Impound System Settings
Config.Impound = {
    DefaultPrice = 1,          -- Giá mặc định nếu không nhập
    DefaultDuration = 1,          -- Thời gian mặc định (phút) nếu không nhập
    DefaultEngineHealth = 1000.0,  -- Engine health khi reset
    DefaultBodyHealth = 1000.0,    -- Body health khi reset
    ResetHealthOnRelease = true,   -- true = reset engine/body về default, false = giữ nguyên
    AllowedJobType = 'leo',        -- Chỉ job có type này mới dùng /giamxe
}

-- ✅ Camera Auto-Calculation Settings
Config.CameraSettings = {
    forwardOffset = 4.5,   -- Khoảng cách phía trước xe (tăng = xa hơn)
    rightOffset = 3.0,     -- Khoảng cách bên phải xe (tăng = sang phải hơn)
    heightOffset = 2.5,    -- Độ cao camera (tăng = cao hơn)
    lookAtHeight = 1.0     -- Độ cao điểm nhìn trên xe (tăng = nhìn cao hơn)
}

Config.WaterImpound = {
    Enabled = true,
    SubmergedThreshold = 0.7,      -- Mức ngập nước (0.9 = chìm gần hoàn toàn)
    SubmergedTime = 120,            -- Giây chìm liên tục trước khi auto impound
    ImpoundDuration = 5,          -- Phút giam trong impound (miễn phí)
    CheckInterval = 1000,          -- ms giữa mỗi lần check
    CheckRadius = 300.0,           -- Bán kính check xe xung quanh player
    ImpoundGarage = 'impound',     -- Tên garage impound trong Config.Garages
    Debug = true,                  -- true = hiện DrawText3D + /watercheck command
}

-- Garages Configuration
Config.Garages = {
    ['garagepaleto'] = {
        label = 'Bãi Đỗ Xe Paleto',
        type = 'public', -- ✅ Everyone can access
        
        -- Vùng cất xe (hình tròn)
        storeZone = {
            coords = vec3(150.61, 6605.49, 31.88),
            radius = 15.0,
            showText = '[E] Cất Xe'
        },
        
        -- NPC để lấy xe
        npc = { 
            coords = vec3(159.11, 6593.66, 30.85),
            heading = 359.54,
            model = 's_m_y_dealer_01'
        },
        
        blip = {
            enabled = true,
            sprite = 50,
            color = 3,
            scale = 0.7
        },
        
        spawnPoints = {
            vec4(150.89, 6608.85, 31.27, 2.62),
            vec4(145.40, 6613.10, 31.21, 1.31),
            vec4(140.58, 6606.77, 31.24, 180.32),
            vec4(150.94, 6597.23, 31.24, 179.83),
        },
        
        preview = {
            vehicle = vec4(1120.01, 2665.66, 37.42, 355.86),
        },
    },

    ['garagemotelsandy'] = {
        label = 'Bãi Đỗ Xe Sa Mạc',
        type = 'public', -- ✅ Everyone can access
        
        -- Vùng cất xe (hình tròn)
        storeZone = {
            coords = vec3(1124.88, 2660.49, 38.00),
            radius = 15.0,
            showText = '[E] Cất Xe'
        },
        
        -- NPC để lấy xe
        npc = {
            coords = vec3(1134.59, 2661.65, 37.14),
            heading = 90.97,
            model = 's_m_y_dealer_01'
        },
        
        blip = {
            enabled = true,
            sprite = 50,
            color = 3,
            scale = 0.7
        },
        
        spawnPoints = {
            vec4(1131.60, 2647.33, 37.39, 1.01),
            vec4(1124.17, 2647.41, 37.39, 1.37),
            vec4(1116.64, 2647.60, 37.39, 0.99),
            vec4(1111.54, 2657.90, 37.39, 271.79),
        },
        
        preview = {
            vehicle = vec4(1120.01, 2665.66, 37.42, 355.86),
        },
    },

    ['gararedowntown'] = {
        label = 'Bãi Đỗ Xe Downtown',
        type = 'public', -- ✅ Everyone can access
        
        -- Vùng cất xe (hình tròn)
        storeZone = {
            coords = vec3(282.49, -333.16, 44.92),
            radius = 15.0,
            showText = '[E] Cất Xe'
        },
        
        -- NPC để lấy xe
        npc = {
            coords = vec3(275.74, -343.24, 43.92),
            heading = 340.71,
            model = 's_m_y_dealer_01'
        },
        
        blip = {
            enabled = true,
            sprite = 50,
            color = 3,
            scale = 0.7
        },
        
        spawnPoints = {
            vec4(300.72, -330.29, 44.32, 71.01),
            vec4(297.65, -336.47, 44.32, 70.57),
            vec4(295.50, -342.99, 44.32, 70.35),
            vec4(283.84, -338.94, 44.32, 250.16),
            vec4(281.20, -330.52, 44.32, 68.80),
            vec4(267.42, -329.04, 44.32, 249.02),
        },
        
        preview = {
            vehicle = vec4(276.25, -323.89, 44.32, 162.05),
        },
    },

    ['garanhatro'] = {
        label = 'Bãi Đỗ Xe Nhà Trọ',
        type = 'public', -- ✅ Everyone can access
        
        -- Vùng cất xe (hình tròn)
        storeZone = {
            coords = vec3(555.77, -1792.61, 29.20),
            radius = 15.0,
            showText = '[E] Cất Xe'
        },
        
        -- NPC để lấy xe
        npc = {
            coords = vec3(555.75, -1781.49, 28.36),
            heading = 65.74,
            model = 's_m_y_dealer_01'
        },
        
        blip = {
            enabled = false,
            sprite = 50,
            color = 3,
            scale = 0.7
        },
        
        spawnPoints = {
            vec4(561.03, -1788.87, 28.59, 155.25),
            vec4(558.55, -1787.63, 28.59, 154.16),
            vec4(555.56, -1786.45, 28.59, 154.97),
            vec4(545.05, -1794.90, 28.59, 323.79),
            vec4(552.39, -1797.45, 28.59, 348.37),
            vec4(558.60, -1798.24, 28.59, 350.95),
            vec4(564.53, -1799.14, 28.59, 351.79),
        },
        
        preview = {
            vehicle = vec4(554.53, -1776.91, 28.57, 155.19),
        },
    },

    ['garabenhvien'] = {
        label = 'Bãi Đỗ Xe Bệnh Viện',
        type = 'public',
        
        -- Vùng cất xe (hình tròn)
        storeZone = {
            coords = vec3(-461.23, -1000.70, 24.29),
            radius = 20.0,
            showText = '[E] Cất Xe'
        },
        
        -- NPC để lấy xe
        npc = {
            coords = vec3(-479.47, -992.83, 23.29),
            heading = 269.07,
            model = 's_m_y_dealer_01'
        },
        
        blip = {
            enabled = false,
            sprite = 50,
            color = 3,
            scale = 0.7
        },
        
        spawnPoints = {
            vec4(-468.94, -988.04, 23.68, 182.60),
            vec4(-464.85, -988.49, 23.69, 181.69),
            vec4(-460.45, -988.54, 23.69, 181.44),
            vec4(-455.98, -988.22, 23.68, 181.78),
        },
        
        preview = {
            vehicle = vec4(-459.55, -1005.17, 23.69, 92.49),
        },
    },

    ['garatrungtam'] = {
        label = 'Bãi Đỗ Xe Trung Tâm',
        type = 'public', -- ✅ Everyone can access
        
        -- Vùng cất xe (hình tròn)
        storeZone = {
            coords = vec3(232.0, -783.85, 29.07),
            radius = 20.0,
            showText = '[E] Cất Xe'
        },
        
        -- NPC để lấy xe
        npc = {
            coords = vec3(215.73, -808.89, 29.75),
            heading = 248.32,
            model = 's_m_y_dealer_01'
        },
        
        blip = {
            enabled = true,
            sprite = 50,
            color = 3,
            scale = 0.7
        },
        
        spawnPoints = {
            vec4(215.42, -775.91, 29.25, 249.18),
            vec4(227.5, -771.81, 29.18, 70.08),
            vec4(244.65, -775.16, 29.08, 68.3),
            vec4(239.06, -790.18, 28.92, 67.39),
            vec4(224.75, -796.47, 29.06, 248.71),
            vec4(233.92, -771.26, 29.15, 248.95),
        },
        
        preview = {
            vehicle = vec4(234.83, -784.19, 29.04, 159.18),
        },
    },
    
    ['garavespucci'] = {
        label = 'Bãi Đỗ Xe Vespucci',
        type = 'public', -- ✅ Everyone can access
        
        storeZone = {
            coords = vec3(-1174.41, -735.39, 19.21),
            radius = 20.0,
            showText = '[E] Cất Xe'
        },
        
        npc = {
            coords = vec3(-1161.04, -740.05, 18.75),
            heading = 127.85,
            model = 's_m_y_dealer_01'
        },
        
        blip = {
            enabled = true,
            sprite = 50,
            color = 3,
            scale = 0.7
        },
        
        spawnPoints = {
            vec4(-1191.71, -736.27, 18.98, 308.61),
            vec4(-1189.6, -738.92, 18.78, 309.58),
            vec4(-1186.28, -742.85, 18.5, 307.05),
            vec4(-1184.49, -745.72, 18.35, 307.53),
        },
        
        preview = {
            vehicle = vec4(-1187.58, -724.49, 19.38, 218.77),
        },
    },
    
    ['garacardealer'] = {
        label = 'Bãi Đỗ Xe Baby Blue',
        type = 'public',
        
        storeZone = {
            coords = vec3(-2145.12, -391.77, 13.27),
            radius = 15.0,
            showText = '[E] Cất Xe'
        },
        
        npc = {
            coords = vec3(-2133.74, -388.20, 12.14),
            heading = 113.45,
            model = 's_m_y_dealer_01'
        },
        
        blip = {
            enabled = false,
            sprite = 50,
            color = 3,
            scale = 0.7
        },
        
        spawnPoints = {
            vec4(-2154.73, -375.80, 12.51, 167.92),
            vec4(-2151.28, -376.76, 12.52, 168.17),
            vec4(-2148.33, -377.57, 12.54, 166.83),
            vec4(-2145.34, -378.21, 12.56, 166.56),
            vec4(-2142.46, -378.97, 12.59, 168.63),
            vec4(-2139.51, -379.83, 12.59, 171.85),
            vec4(-2136.48, -380.41, 12.59, 172.36),
        },
        
        preview = {
            vehicle = vec4(-2146.43, -390.65, 12.67, 73.44),
        },
    },
    
    ['garage_police'] = {
        label = 'Garage Cảnh Sát',
        type = 'job',  
        job = 'police',
        
        storeZone = {
            coords = vec3(452.33, -989.56, 25.31),
            radius = 15.0,
            showText = '[E] Cất Xe Công Vụ'
        },
        
        npc = {
            coords = vec3(458.07, -972.96, 24.70),
            heading = 181.40,
            model = 's_m_y_cop_01'
        },
        
        blip = {
            enabled = true,
            sprite = 56,
            color = 29, -- Police blue
            scale = 0.8
        },
        
        spawnPoints = {
            vec4(436.71, -997.01, 25.31, 90.42),
            vec4(436.66, -991.56, 25.31, 90.28),
            vec4(436.81, -986.11, 25.31, 90.18),
            vec4(426.25, -976.28, 25.31, 271.41),
            vec4(425.98, -981.57, 25.31, 270.57),
            vec4(426.21, -989.07, 25.31, 271.07),
            vec4(426.20, -994.48, 25.31, 270.18),
        },
        
        preview = {
            vehicle = vec4(452.33, -989.56, 25.31, 359.00),
        },
    },
    
    ['garage_mechanic'] = {
        label = 'Garage Mechanic',
        type = 'public',  
        
        storeZone = {
            coords = vec3(-385.16, -127.37, 38.68),
            radius = 10.0,
            showText = '[E] Cất Xe'
        },
        
        npc = {
            coords = vec3(-377.98, -124.68, 37.61),
            heading = 118.61,
            model = 's_m_y_dealer_01'
        },
        
        blip = {
            enabled = false,
            sprite = 56,
            color = 29,
            scale = 0.8
        },
        
        spawnPoints = {
            vec4(-381.22, -140.96, 38.08, 298.77),
            vec4(-384.61, -134.65, 38.08, 299.09),
            vec4(-388.32, -128.64, 38.08, 300.30),
            vec4(-391.62, -122.44, 38.08, 298.93),
        },
        
        preview = {
            vehicle = vec4(-371.81, -137.35, 38.03, 32.10),
        },
    },
    
    ['impound'] = {
        label = 'Bãi Xe Vi Phạm',
        type = 'public', -- Ai cũng có thể lấy xe (nếu hết hạn + trả tiền, hoặc là LEO)
        isImpound = true, -- Đánh dấu đây là impound garage
                
        npc = {
            coords = vec3(409.09, -1623.19, 28.29),
            heading = 230.0,
            model = 's_m_m_security_01'
        },
        
        blip = {
            enabled = true,
            sprite = 67, -- Impound icon
            color = 1,   -- Red
            scale = 0.8
        },
        
        spawnPoints = {
            vec4(403.67, -1631.02, 28.29, 320.84),
            vec4(407.01, -1634.56, 28.29, 320.35),
            vec4(410.65, -1638.22, 28.29, 320.09),
        },
        
        preview = {
            vehicle = vec4(391.23, -1619.09, 28.29, 320.0),
        },
    },
}

-- Language Config
Config.Lang = {
    ['open_garage'] = 'Lấy Xe',
    ['store_vehicle'] = '[E] Cất Xe',
    ['no_vehicles'] = 'Bạn không có xe nào trong bãi này!',
    ['vehicle_stored'] = 'Xe đã được cất vào bãi',
    ['vehicle_spawned'] = 'Xe đã được lấy ra',
    ['spawn_occupied'] = 'Vị trí spawn bị chặn, đang thử vị trí khác...',
    ['all_spawns_blocked'] = 'Tất cả vị trí spawn đều bị chặn!',
    ['not_in_vehicle'] = 'Bạn không ở trong xe!',
    ['not_your_vehicle'] = 'Đây không phải xe của bạn!',
    ['too_far'] = 'Xe quá xa bãi!',
    ['cooldown_active'] = 'Vui lòng đợi trước khi spawn xe tiếp theo!',
    
    -- Impound
    ['vehicle_impounded'] = 'Xe đã bị giam với giá %s$ trong %s phút',
    ['not_authorized_impound'] = 'Bạn không có quyền giam xe!',
    ['impound_released'] = 'Xe đã được trả. Đã trừ %s$',
    ['not_enough_money'] = 'Không đủ tiền để lấy xe! Cần %s$',
    ['impound_time_remaining'] = 'Xe vẫn còn bị giam! Còn %s phút',
}