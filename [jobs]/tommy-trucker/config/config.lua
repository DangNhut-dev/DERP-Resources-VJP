Config = {}

Config.Debug = false
Config.KgPerTrip = 10

Config.NPCLocation = {
    coords = vector4(-1146.02, -2180.02, 13.38, 132.48),
    model = 's_m_m_trucker_01',
    scenario = 'WORLD_HUMAN_CLIPBOARD'
}

Config.NPCBlip = {
    sprite = 477,
    scale  = 0.8,
    color  = 3,
    label  = 'Nhận Đơn Giao Hàng',
}

Config.TruckWhitelist = {
    ['youga'] = 80,
    ['speedo4'] = 120,
    ['rumpo'] = 170,
    ['mule5'] = 250,
    ['pounder2'] = 500,
}

Config.LevelThresholds = {
    [1]  = 0,
    [2]  = 400,
    [3]  = 900,
    [4]  = 1500,
    [5]  = 2250,
    [6]  = 3150,
    [7]  = 4250,
    [8]  = 5600,
    [9]  = 7200,
    [10] = 9100,
}

Config.MaxLevel = 10

Config.RentalFleet = {
    { model = 'youga', pricePerDay = 500, capacity = 80 },
    { model = 'speedo4', pricePerDay = 750, capacity = 120 },
    { model = 'rumpo', pricePerDay = 1260, capacity = 170 },
    { model = 'mule5', pricePerDay = 2377, capacity = 250 },
    { model = 'pounder2', pricePerDay = 4125, capacity = 500 },
}

Config.RentalSpawnPoints = {
    { coords = vector4(-1096.91, -2183.18, 13.53, 225.00), label = 'Bãi đỗ xe #1' },
    { coords = vector4(-1092.16, -2178.30, 13.52, 225.31), label = 'Bãi đỗ xe #2' },
    { coords = vector4(-1087.10, -2173.28, 13.52, 225.23), label = 'Bãi đỗ xe #3' },
    { coords = vector4(-1077.32, -2163.33, 13.51, 225.03), label = 'Bãi đỗ xe #4' },
    { coords = vector4(-1072.84, -2158.66, 13.51, 224.88), label = 'Bãi đỗ xe #5' },
}

Config.RentalSpawnCheckRadius = 6.0

Config.Orders = {
    -- LEVEL 1
    {
        id = 1,
        label = 'Tạp Hóa Đường Grove',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(-40.9, -1751.44, 30.42),
        requiredLevel = 1,
        requiredKg = 40,
        isIllegal = false,
        reward = 380,
        exp = 3,
        cooldown = 180,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 2,
        label = 'Tạp Hóa Đường Innocence',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(25.64, -1339.01, 30.5),
        requiredLevel = 1,
        requiredKg = 50,
        isIllegal = false,
        reward = 400,
        exp = 4,
        cooldown = 200,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 3,
        label = 'Tạp Hóa Đường Palomino',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(-705.68, -904.56, 20.22),
        requiredLevel = 1,
        requiredKg = 60,
        isIllegal = false,
        reward = 420,
        exp = 4,
        cooldown = 220,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 4,
        label = 'Tạp Hóa Đường Vespucci',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(-1147.64, -1525.51, 5.22),
        requiredLevel = 1,
        requiredKg = 70,
        isIllegal = false,
        reward = 440,
        exp = 5,
        cooldown = 240,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 5,
        label = 'Tạp Hóa Đường Rockford',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(-1158.71, -522.71, 33.58),
        requiredLevel = 1,
        requiredKg = 80,
        isIllegal = false,
        reward = 460,
        exp = 5,
        cooldown = 260,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    
    -- LEVEL 2
    {
        id = 6,
        label = 'Tạp Hóa Đường S.Andreas',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(-1219.52, -910.75, 13.33),
        requiredLevel = 2,
        requiredKg = 90,
        isIllegal = false,
        reward = 570,
        exp = 5,
        cooldown = 280,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 7,
        label = 'Tạp Hóa Đường Clinton',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(376.39, 334.08, 104.57),
        requiredLevel = 2,
        requiredKg = 100,
        isIllegal = false,
        reward = 640,
        exp = 6,
        cooldown = 300,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 8,
        label = 'Tạp Hóa Đường Mirror Park',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(1143.43, -301.25, 68.84),
        requiredLevel = 2,
        requiredKg = 110,
        isIllegal = false,
        reward = 610,
        exp = 5,
        cooldown = 290,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 9,
        label = 'Tạp Hóa Đường La Mesa',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(803.33, -1020.26, 26.12),
        requiredLevel = 2,
        requiredKg = 120,
        isIllegal = false,
        reward = 580,
        exp = 4,
        cooldown = 260,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    
    -- LEVEL 3
    {
        id = 10,
        label = 'Tạp Hóa Đường Senora',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(2671.57, 3284.48, 56.24),
        requiredLevel = 3,
        requiredKg = 130,
        isIllegal = false,
        reward = 590,
        exp = 7,
        cooldown = 360,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 11,
        label = 'Tạp Hóa Đường Alhambra',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(1957.85, 3748.31, 33.34),
        requiredLevel = 3,
        requiredKg = 140,
        isIllegal = false,
        reward = 610,
        exp = 7,
        cooldown = 370,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 12,
        label = 'Tạp Hóa Đường Sandy Shores',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(1961.93, 3817.24, 32.4),
        requiredLevel = 3,
        requiredKg = 150,
        isIllegal = false,
        reward = 630,
        exp = 8,
        cooldown = 380,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 13,
        label = 'Tạp Hóa Đường Harmony',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(547.55, 2662.66, 42.16),
        requiredLevel = 3,
        requiredKg = 160,
        isIllegal = false,
        reward = 570,
        exp = 5,
        cooldown = 320,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 14,
        label = 'Tạp Hóa Đường Grand Senora',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(1476.91, 2721.52, 37.64),
        requiredLevel = 3,
        requiredKg = 170,
        isIllegal = false,
        reward = 650,
        exp = 6,
        cooldown = 340,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 15,
        label = 'Tạp Hóa Đường Route 68',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(619.81, 2803.02, 41.93),
        requiredLevel = 3,
        requiredKg = 180,
        isIllegal = false,
        reward = 670,
        exp = 6,
        cooldown = 350,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    
    -- LEVEL 4
    {
        id = 16,
        label = 'Tạp Hóa Đường Ineseno',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(-3046.79, 583.94, 8.91),
        requiredLevel = 4,
        requiredKg = 190,
        isIllegal = false,
        reward = 760,
        exp = 6,
        cooldown = 400,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 17,
        label = 'Tạp Hóa Đường Grapeseed',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(1705.04, 4917.84, 43.06),
        requiredLevel = 4,
        requiredKg = 200,
        isIllegal = false,
        reward = 800,
        exp = 7,
        cooldown = 420,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 18,
        label = 'Tạp Hóa Đường Paleto Bay',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(-417.64, 6134.66, 31.47),
        requiredLevel = 4,
        requiredKg = 210,
        isIllegal = false,
        reward = 890,
        exp = 9,
        cooldown = 460,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 19,
        label = 'Tạp Hóa Đường Chumash',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(-3179.44, 1052.35, 20.97),
        requiredLevel = 4,
        requiredKg = 220,
        isIllegal = false,
        reward = 850,
        exp = 8,
        cooldown = 440,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 20,
        label = 'Tạp Hóa Đường Great Ocean',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(-2948.87, 456.78, 15.32),
        requiredLevel = 4,
        requiredKg = 230,
        isIllegal = false,
        reward = 830,
        exp = 7,
        cooldown = 430,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 21,
        label = 'Tạp Hóa Đường Raton Canyon',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(-575.42, 5352.85, 70.21),
        requiredLevel = 4,
        requiredKg = 240,
        isIllegal = false,
        reward = 870,
        exp = 8,
        cooldown = 450,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    
    -- LEVEL 5
    {
        id = 22,
        label = 'Tạp Hóa Đường Senora 2',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(1732.92, 6421.93, 36.04),
        requiredLevel = 5,
        requiredKg = 250,
        isIllegal = false,
        reward = 1040,
        exp = 9,
        cooldown = 500,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 23,
        label = 'Tạp Hóa Đường Paleto 2',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(-248.63, 6069.81, 32.34),
        requiredLevel = 5,
        requiredKg = 260,
        isIllegal = false,
        reward = 1020,
        exp = 8,
        cooldown = 480,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 24,
        label = 'Tạp Hóa Đường Mount Chiliad',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(178.42, 6397.75, 31.34),
        requiredLevel = 5,
        requiredKg = 270,
        isIllegal = false,
        reward = 1080,
        exp = 9,
        cooldown = 520,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 25,
        label = 'Tạp Hóa Đường Tataviam',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(596.4, 2784.24, 43.48),
        requiredLevel = 5,
        requiredKg = 280,
        isIllegal = false,
        reward = 970,
        exp = 6,
        cooldown = 440,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 26,
        label = 'Tạp Hóa Đường Tongva Hills',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(-503.76, 278.32, 83.32),
        requiredLevel = 5,
        requiredKg = 290,
        isIllegal = false,
        reward = 950,
        exp = 6,
        cooldown = 420,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 27,
        label = 'Tạp Hóa Đường Vinewood',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(325.82, 268.73, 104.37),
        requiredLevel = 5,
        requiredKg = 300,
        isIllegal = false,
        reward = 930,
        exp = 5,
        cooldown = 400,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    
    -- LEVEL 6
    {
        id = 28,
        label = 'Kho Hàng Ngoại Ô',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(-3195.46, 1220.1, 10.05),
        requiredLevel = 6,
        requiredKg = 320,
        isIllegal = false,
        reward = 1320,
        exp = 10,
        cooldown = 560,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 29,
        label = 'Kho Hàng Xa Xôi',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(2386.12, 5030.8, 46.0),
        requiredLevel = 6,
        requiredKg = 340,
        isIllegal = false,
        reward = 1360,
        exp = 9,
        cooldown = 540,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 30,
        label = 'Kho Hàng Miền Núi',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(791.6, 4186.19, 40.56),
        requiredLevel = 6,
        requiredKg = 360,
        isIllegal = false,
        reward = 1280,
        exp = 9,
        cooldown = 520,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    
    -- LEVEL 7
    {
        id = 31,
        label = 'Kho Hàng Cảng',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(3488.59, 3695.39, 33.89),
        requiredLevel = 7,
        requiredKg = 380,
        isIllegal = false,
        reward = 1350,
        exp = 9,
        cooldown = 380,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 32,
        label = 'Kho Hàng Sân Bay',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(-1858.98, -2990.24, 13.94),
        requiredLevel = 7,
        requiredKg = 400,
        isIllegal = false,
        reward = 1300,
        exp = 8,
        cooldown = 360,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 33,
        label = 'Kho Hàng Công Nghiệp',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(734.18, -1388.02, 26.52),
        requiredLevel = 7,
        requiredKg = 420,
        isIllegal = false,
        reward = 1250,
        exp = 8,
        cooldown = 340,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    
    -- LEVEL 8
    {
        id = 34,
        label = 'Siêu Thị Đồ Số',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(263.53, -1794.56, 27.11),
        requiredLevel = 8,
        requiredKg = 440,
        isIllegal = false,
        reward = 1600,
        exp = 10,
        cooldown = 400,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 35,
        label = 'Kho Hàng Trung Tâm',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(-9.27, -655.47, 33.45),
        requiredLevel = 8,
        requiredKg = 460,
        isIllegal = false,
        reward = 1550,
        exp = 9,
        cooldown = 380,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 36,
        label = 'Kho Hàng Đặc Biệt',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(-176.08, -1276.79, 32.6),
        requiredLevel = 8,
        requiredKg = 480,
        isIllegal = false,
        reward = 1500,
        exp = 9,
        cooldown = 360,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    
    -- LEVEL 9
    {
        id = 37,
        label = 'Kho Hàng Cao Cấp',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(-805.73, 352.64, 87.89),
        requiredLevel = 9,
        requiredKg = 500,
        isIllegal = false,
        reward = 1950,
        exp = 10,
        cooldown = 420,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 38,
        label = 'Kho Hàng Xa Xỉ',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(-1189.76, -774.03, 17.33),
        requiredLevel = 9,
        requiredKg = 500,
        isIllegal = false,
        reward = 1900,
        exp = 10,
        cooldown = 400,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    
    -- LEVEL 10
    {
        id = 39,
        label = 'Kho Hàng Đặc Quyền',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(-1366.07, 56.61, 54.1),
        requiredLevel = 10,
        requiredKg = 500,
        isIllegal = false,
        reward = 2350,
        exp = 11,
        cooldown = 440,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    {
        id = 40,
        label = 'Kho Hàng VIP',
        pickup = vector3(1243.38, -3241.96, 6.03),
        dropoff = vector3(-1858.08, -347.45, 49.84),
        requiredLevel = 10,
        requiredKg = 500,
        isIllegal = false,
        reward = 2400,
        exp = 11,
        cooldown = 460,
        items = { {item = 'lockpick', chance = 15}, {item = 'circuit', chance = 25} }
    },
    
    -- ILLEGAL JOBS
    {
        id = 100,
        label = 'Đồ Chơi Giới Trẻ',
        pickup = vector3(-147.92, 6146.84, 32.34),
        dropoff = vector3(-171.18, -1449.05, 31.62),
        requiredLevel = 2,
        requiredKg = 80,
        isIllegal = true,
        reward = 600,
        exp = 25,
        cooldown = 3600,
        items = { {item = 'cannabis_seed_indica', chance = 10} }
    },
    -- {
    --     id = 101,
    --     label = 'Kho Hàng Cấm',
    --     pickup = vector3(2452.11, 4974.79, 47.81),
    --     dropoff = vector3(-1512.36, -495.26, 34.52),
    --     requiredLevel = 5,
    --     requiredKg = 250,
    --     isIllegal = true,
    --     reward = 1350,
    --     exp = 10,
    --     cooldown = 360,
    --     items = { {item = 'vango', chance = 80} }
    -- },
    -- {
    --     id = 102,
    --     label = 'Hàng Lậu Biên Giới',
    --     pickup = vector3(-2130.26, 2602.32, 4.09),
    --     dropoff = vector3(-1745.56, -296.15, 50.98),
    --     requiredLevel = 7,
    --     requiredKg = 350,
    --     isIllegal = true,
    --     reward = 1700,
    --     exp = 12,
    --     cooldown = 420,
    --     items = { {item = 'vango', chance = 90} }
    -- },
    -- {
    --     id = 103,
    --     label = 'Đường Dây Ma Túy',
    --     pickup = vector3(191.28, 2785.09, 46.68),
    --     dropoff = vector3(100.53, -1952.74, 22.38),
    --     requiredLevel = 8,
    --     requiredKg = 400,
    --     isIllegal = true,
    --     reward = 2000,
    --     exp = 13,
    --     cooldown = 460,
    --     items = { {item = 'vango', chance = 95} }
    -- },
    -- {
    --     id = 104,
    --     label = 'Vũ Khí Lậu',
    --     pickup = vector3(-254.88, 6324.89, 32.47),
    --     dropoff = vector3(-1766.88, -881.79, 10.44),
    --     requiredLevel = 9,
    --     requiredKg = 450,
    --     isIllegal = true,
    --     reward = 2500,
    --     exp = 14,
    --     cooldown = 500,
    --     items = { {item = 'vango', chance = 100} }
    -- },
    -- {
    --     id = 105,
    --     label = 'Kho Vàng Bất Hợp Pháp',
    --     pickup = vector3(2918.05, 4377.42, 52.07),
    --     dropoff = vector3(-722.45, -1020.46, 15.28),
    --     requiredLevel = 10,
    --     requiredKg = 500,
    --     isIllegal = true,
    --     reward = 3200,
    --     exp = 15,
    --     cooldown = 540,
    --     items = { {item = 'vango', chance = 100} }
    -- },
}

Config.BlipColors = {
    pickup = 26,
    dropoff = 46,
    illegal = 1,
    npc = 51
}

Config.PickupDistance = 50.0
Config.DropoffDistance = 50.0
Config.LoadTime = 2000
Config.UnloadTime = 2000

Config.BoxProp = 'prop_cs_cardbox_01'
Config.BoxBone = 60309
Config.BoxOffset = {
    x = 0.07, y = 0.15, z = 0.24,
    xRot = 120.0, yRot = 110.0, zRot = 180.0
}

Config.LoadAnimation = {
    dict = 'anim@heists@box_carry@',
    anim = 'idle',
    flags = 49
}

Config.PickupAnimation = {
    dict = 'amb@world_human_bum_wash@male@low@idle_a',
    anim = 'idle_a',
    flags = 1
}