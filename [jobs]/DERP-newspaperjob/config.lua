Config = {}

Config.NPC = {
    model  = 'a_m_m_og_boss_01',
    coords = vector4(-607.01, -926.74, 23.86, 180.46),
}

Config.VehicleSlots = {
    vector4(-615.47, -924.66, 22.07, 104.59),
    vector4(-615.61, -928.95, 21.66, 111.19),
    vector4(-615.01, -932.86, 21.40, 108.48),
}

Config.Vehicle = {
    model = 'bmx',
    color   = { primary = 135, secondary = 135 },
}

Config.Job = {
    cooldown    = 2000,
    zoneRadius  = 5.0,
    item        = 'WEAPON_ACIDPACKAGE',
    weapon      = 'WEAPON_ACIDPACKAGE',
    rewardPoint = 45,
    deposit     = 100,       -- tiền cọc khi nhận job
    timeout     = 15 * 60,   -- 15 phút (giây)
    returnRadius  = 13.0,
}

-- mỗi area là 1 khu vực giao báo, server random 1 area mỗi lần nhận job
Config.Areas = {
    { -- Little Seoul
        label = 'Little Seoul',
        locations = {
            vector3(-766.38,  -917.32,  20.3),
            vector3(-697.03,  -858.86,  22.69),
            vector3(-708.51,  -886.59,  22.8),
            vector3(-604.35,  -802.27,  24.4),
            vector3(-531.18,  -1221.27, 17.46),
            vector3(-700.21,  -1401.38, 4.5),
            vector3(-753.27,  -1512.31, 4.02),
        },
    },
   { -- South LS
        label = 'South LS',
        locations = {
            vector3(-927.57,  -1182.48, 3.95),
            vector3(-1171.41, -1435.18, 3.47),
            vector3(-898.79,  -1500.19, 4.18),
            vector3(-1039.93, -1475.32, 4.58),
            vector3(-1193.96, -1341.05, 3.92),
        },
    },
    { -- Rockford Hills
        label = 'Rockford Hills',
        locations = {
            vector3(-17.04, -296.76, 45.77),
            vector3(225.68, -283.98, 47.72),
            vector3(292.43,  -222.86,  52.98),
            vector3(315.44,  -275.72,  52.92),
            vector3(418.75,  -207.14,  58.91),
            vector3(415.36,  -217.76,  58.91),
            vector3(313.35,  -174.4,   57.12),
            vector3(223.16,  -176.25,  56.92),
        },
    },
    { -- Vespucci Beach
        label = 'Vespucci Beach',
        locations = {
            vec3(-1312.37, -1178.47, 3.89),
            vec3(-1339.13, -1214.64, 4.74),
            vec3(-1336.82, -1276.83, 3.88),
            vec3(-1305.04, -1363.85, 3.52),
            vec3(-1286.22, -1386.78, 3.45),
            vec3(-1269.33, -1296.14, 3.0),
            vec3(-1284.43, -1252.78, 3.07),
            vec3(-1384.82, -976.05, 7.94),
        },
    },
    { -- Mission ROW
        label = 'Mission ROW',
        locations = {
            vec3(292.67, -1111.41, 28.41),
            vec3(325.64, -1073.71, 28.47),
            vec3(383.33, -1076.42, 28.42),
            vec3(382.71, -1024.12, 28.54),
            vec3(278.56, -1070.97, 28.44),
        },
    },
    { -- PillBox Hills
        label = 'PillBox Hills',
        locations = {
            vec3(-231.15, -851.58, 29.68),
            vec3(-296.31, -828.61, 31.42),
            vec3(143.23, -832.45, 30.17),
            vec3(285.78, -936.98, 28.41),
            vec3(346.37, -874.38, 28.29),
            vec3(242.8, -1116.12, 28.32),
            vec3(296.26, -1028.12, 28.21),
            vec3(117.48, -821.61, 30.3),
        },
    },
}