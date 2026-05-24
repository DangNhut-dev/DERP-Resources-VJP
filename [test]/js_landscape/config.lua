Config = {}

Config.Language = 'en' --// Supported languages ['en' - English/US | 'fr' - French | 'pl' - Polish | 'de' - Deutsch | 'es' - Spanish]

Config.Frameworks = {
    ESX = {
        enabled = false, --// if you are using esx, set it to true
        frameworkScript = 'es_extended',
        frameworkExport = 'getSharedObject'
    },
    QB = {
        enabled = false, --// if you are using qb-core, set it to true
        frameworkScript = 'qb-core',
        frameworkExport = 'GetCoreObject'
    },
	QBOX = {
        enabled = true, --// if you are using qbx-core, set it to true
		frameworkScript = 'qb-core',
        frameworkExport = 'GetCoreObject'
    }
}

Config.JobData = {
    Lobby = {
        maxPlayers = 4,
    },
    Job = {
        requiredJob = false,
        name = 'unemployed',
    },
    Blip = {
        name = "Chăm sóc cảnh quan", -- tên hiển thị blip
        label = "Chăm sóc cảnh quan",
        coords = vec3(-1484.32, -391.79, 39.09), -- toạ độ blip hiển thị trên map
        sprite = 280,  -- icon
        colour = 2,    -- màu
        scale = 0.8,    -- kích cỡ
        display = 4,
        shortRange = false
    }
}

--Config.JobBlips = {
    --{x = -312.3726, y = 6312.4697, z = 32.0, sprite = 280, colour = 2, scale = 1.0, name = "Chăm sóc cảnh quan"}
--}

Config.Salary = {
    amount = 210,
    moneyType = Config.Frameworks.ESX.enabled and 'cash' or ((Config.Frameworks.QB.enabled and 'cash') or (Config.Frameworks.QBOX.enabled and 'cash' or 'yourcustomtypeofmoney')),
    levelMultiplier = 1.5, -- salary multiplier for each level f.e. for each level +0.5% from salary
    jobFinishedXP = 75,
}

Config.Keys = {
    qb_vehiclekeys = false,
    qs_vehiclekeys = false,
    qbox_vehiclekeys = true,
    wasabi_carlock = false,
    renewed_vehiclekeys = false,
    custom = false, --// if you are using other system, implement it in client/editable.lua
}

Config.Fuel = {
    LCfuel = false,
    CDNFuel = false,
    LegacyFuel = false,
    ox_fuel = true,

    FuelLevel = 50
}

Config.UseE = false --// if true then script will work at [Press E to interact] if false you must use one of Config.Target targets

Config.Target = { --// select your target system (if you aren't using any target, set everything to false)
    ox_target = true,
    qtarget = false,
    qb_target = false,
    own = false, --// if you are using other target system, implement it in client/editable.lua
}

Config.JobObjectCleanup = {
    -- Bật/tắt toàn bộ hệ thống cleanup object của job.
    -- true = dùng các option bên dưới, false = không xoá object job bằng cleanup.
    enabled = true,

    -- true = trồng hoa xong hoa sẽ giữ lại, không bị cleanup xoá.
    -- false = hoa đã trồng vẫn bị cleanup như object job bình thường.
    keepPlantedFlowers = true,

    -- true = trồng hoa xong sẽ xoá hố đào cũ.
    -- false = trồng hoa xong vẫn giữ lại hố đào.
    deleteDirtAfterPlanting = true,

    -- true = nhổ cỏ/cây xong sẽ xoá object cỏ/cây đó.
    -- false = nhổ xong vẫn giữ lại object cỏ/cây.
    deletePullingAfterFinish = true,

    -- true = đi xa khu vực làm việc thì dọn object job tạm.
    -- false = đi xa vẫn giữ object job tạm.
    deleteObjectsWhenFar = true,

    -- true = rời khu vực nhiệm vụ thì dọn object job tạm.
    -- false = rời khu vực vẫn giữ object job tạm.
    deleteObjectsWhenLeaveArea = true,

    -- true = hoàn thành nhiệm vụ thì dọn object job tạm.
    -- false = hoàn thành nhiệm vụ vẫn giữ object job tạm.
    deleteObjectsWhenMissionEnd = true,

    -- true = nghỉ việc/hủy job thì dọn object job tạm.
    -- false = nghỉ việc/hủy job vẫn giữ object job tạm.
    deleteObjectsWhenJobStop = true,

    -- true = nhận job mới thì dọn object job cũ.
    -- false = nhận job mới vẫn giữ object job cũ.
    deleteObjectsBeforeNewJob = true,
}

Config.CustomNotification = true

Config.Zones = {
    startJob = {
        targetLabel = TRANSLATIONS.LOCALE('LABEL_STARTJOB_TARGET'),
        icon = 'fa-solid fa-play',
        model = 's_m_m_gardener_01',
        coords = vec3(-1484.32, -391.79, 38.09),
        heading = 149.4,
        distance = 2.5,
        groups = Config.JobData.Job.requiredJob and Config.JobData.Job.name or false,
        scenario = 'WORLD_HUMAN_CLIPBOARD',
    },
}

Config.Markers = {
    PedMarkers = {
        id = 2,
        color = {255, 182, 193},
    },
    DeleteCar = {
        id = 25,
        color = {255, 182, 193},
    },
}

Config.RemoveVehicleTimeout = {
    enabled = true,
    time = 600, --// in seconds
}

Config.Garage = {
    SpawnPoints = {
        vec4(-1476.08, -399.4, 37.79, 124.42)
    },
    DeleteCar = {
        vec4(-1506.03, -384.2, 40.71, 43.55)
    },
    vehicleModel = 'pony2'
}

Config.Uniforms = {
    male = {
        tshirt_1 = 15,     tshirt_2 = 0,
        torso_1 = 97,       torso_2 = 1,
        arms = 63,
        pants_1 = 90,       pants_2 = 2,
        shoes_1 = 25,       shoes_2 = 0,
        helmet_1 = 20,     helmet_2 = 0
    },
    female = {
        tshirt_1 = 219,     tshirt_2 = 0,
        torso_1 = 286,       torso_2 = 1,
        arms = 0,
        pants_1 = 35,       pants_2 = 0,
        shoes_1 = 68,       shoes_2 = 0,
        helmet_1 = -1,     helmet_2 = 0
    }
}

Config.Places = {
    { -- Los Santos
        waypoint_coords = {x = -943.3661, y = 308.2832, z = 71.1959},
        jobs = {
            ['pulling'] = {
                amount = math.random(1, 6), -- how much on one job bcs of randomness, if you dont want randomness, just put how much data is inside.
                data = {
                    {x = -973.3199, y = 336.2529, z = 71.3786, h = 151.4801, r = 6.0},
                    {x = -967.6786, y = 313.9684, z = 70.3108, h = 174.2324, r = 6.0},
                    {x = -981.9857, y = 295.0443, z = 68.7477, h = 50.9205, r = 6.0},
                    {x = -994.7645, y = 310.5606, z = 68.9562, h = 37.7718, r = 6.0},
                    {x = -1014.7027, y = 330.6223, z = 69.4209, h = 280.7517, r = 6.0},
                    {x = -989.2468, y = 325.1008, z = 70.0718, h = 242.5265, r = 6.0},
                }
            },
            ['digging'] = { -- digging & planting
                amount = math.random(1, 6),
                data = {
                    {x = -949.6821, y = 290.0047, z = 70.1091, h = 165.9141},
                    {x = -975.9343, y = 314.1049, z = 70.0069, h = 107.1102},
                    {x = -975.5019, y = 308.6168, z = 69.8059, h = 175.3125},
                    {x = -963.3129, y = 338.4132, z = 71.6848, h = 9.4779},
                    {x = -966.4136, y = 344.4422, z = 72.1107, h = 260.4245},
                    {x = -961.0827, y = 347.1177, z = 72.2029, h = 333.9651},
                }
            },
            ['cleaning'] = {
                amount = math.random(1, 6),
                data = {
                    {x = -948.6981, y = 322.0216, z = 71.3520, h = 151.8865},
                    {x = -952.6587, y = 335.3077, z = 71.3158, h = 274.2999},
                    {x = -978.4860, y = 339.8868, z = 71.4304, h = 131.4352},
                    {x = -942.8970, y = 298.9110, z = 70.7044, h = 211.3058},
                    {x = -944.5516, y = 294.0666, z = 70.4536, h = 188.7516},
                    {x = -960.7797, y = 285.2545, z = 69.3629, h = 65.0002},
                }
            },
        }
    },
    { -- Los Santos
        waypoint_coords = {x = 1279.9955, y = -654.9881, z = 67.4639},
        jobs = {
            ['pulling'] = {
                amount = math.random(1, 4), -- how much on one job bcs of randomness, if you dont want randomness, just put how much data is inside.
                data = { 
                    {x = 1271.7400, y = -665.9597, z = 67.5408, h = 148.7996},
                    {x = 1272.1442, y = -652.8821, z = 67.8715, h = 2.4639},
                    {x = 1268.6213, y = -642.3850, z = 68.1239, h = 295.3592},
                    {x = 1246.4178, y = -663.0811, z = 67.3571, h = 28.2605},
                }
            },
            ['digging'] = { -- digging & planting
                amount = math.random(1, 5),
                data = {
                    {x = 1276.2828, y = -648.0709, z = 67.9689, h = 150.0324},
                    {x = 1276.7383, y = -662.8130, z = 67.5304, h = 118.7440},
                    {x = 1242.0973, y = -651.3757, z = 67.5697, h = 277.5362},
                    {x = 1244.6125, y = -661.1976, z = 67.2651, h = 139.7015},
                    {x = 1247.0864, y = -666.7706, z = 67.2313, h = 221.2041},
                }
            },
            ['cleaning'] = {
                amount = math.random(1, 9),
                data = {
                    {x = 1254.2402, y = -665.9458, z = 67.6875, h = 344.4643},
                    {x = 1251.0150, y = -660.7859, z = 67.7352, h = 249.5204},
                    {x = 1247.7446, y = -653.2509, z = 67.7130, h = 351.1519},
                    {x = 1256.3206, y = -644.8163, z = 67.7940, h = 259.8242},
                    {x = 1262.9313, y = -641.9681, z = 67.9279, h = 270.7243},
                    {x = 1265.5103, y = -645.5395, z = 67.9211, h = 151.0417},
                    {x = 1269.4259, y = -638.1042, z = 68.2854, h = 310.3879},
                    {x = 1278.1758, y = -654.2683, z = 67.6171, h = 160.4106},
                    {x = 1269.7970, y = -660.7571, z = 67.7323, h = 75.3014},
                }
            },
        }
    },
    { -- Los Santos
        waypoint_coords = {x = 444.4128, y = -1521.5916, z = 29.2710},
        jobs = {
            ['pulling'] = {
                amount = math.random(1, 7), -- how much on one job bcs of randomness, if you dont want randomness, just put how much data is inside.
                data = { 
                    {x = 406.6427, y = -1532.1005, z = 29.3255, h = 17.6603},
                    {x = 405.2527, y = -1537.9037, z = 29.3830, h = 171.1844},
                    {x = 395.5456, y = -1536.0338, z = 29.3387, h = 47.9146},
                    {x = 387.9408, y = -1530.7598, z = 29.2841, h = 345.8569},
                    {x = 377.0982, y = -1521.0409, z = 29.2913, h = 51.8547},
                    {x = 384.9893, y = -1523.2495, z = 29.2847, h = 231.3362},
                    {x = 396.6860, y = -1519.4807, z = 29.2730, h = 276.7755},
                }
            },
            ['digging'] = { -- digging & planting
                amount = math.random(1, 8),
                data = {
                    {x = 394.7755, y = -1511.4062, z = 29.2693, h = 26.7291},
                    {x = 396.3082, y = -1519.2212, z = 29.2728, h = 222.0930},
                    {x = 384.9041, y = -1522.8588, z = 29.2854, h = 86.0999},
                    {x = 387.7081, y = -1528.0129, z = 29.2812, h = 349.9290},
                    {x = 379.0436, y = -1523.3911, z = 29.2909, h = 118.9554},
                    {x = 372.5774, y = -1512.8682, z = 29.3322, h = 290.8137},
                    {x = 368.2445, y = -1509.3629, z = 29.3294, h = 72.8151},
                    {x = 388.0171, y = -1503.6780, z = 29.2916, h = 206.8303},
                }
            },
            ['cleaning'] = {
                amount = math.random(1, 8),
                data = {
                    {x = 382.1344, y = -1514.0975, z = 29.2914, h = 145.3436},
                    {x = 377.9138, y = -1511.0404, z = 29.2916, h = 50.2114},
                    {x = 368.4637, y = -1519.7067, z = 29.2570, h = 167.0717},
                    {x = 387.4618, y = -1517.2280, z = 29.2878, h = 82.2836},
                    {x = 400.3174, y = -1523.7302, z = 29.2746, h = 247.2863},
                    {x = 391.1714, y = -1534.8848, z = 29.3063, h = 108.8320},
                    {x = 402.1914, y = -1550.9700, z = 29.2916, h = 284.7950},
                    {x = 416.5603, y = -1539.4346, z = 29.2916, h = 319.3549},
                }
            },
        }
    },
    { -- Los Santos
        waypoint_coords = {x = 1054.4940, y = -482.5856, z = 63.8767},
        jobs = {
            ['pulling'] = {
                amount = math.random(1, 3), -- how much on one job bcs of randomness, if you dont want randomness, just put how much data is inside.
                data = { 
                    {x = 1056.4072, y = -475.1720, z = 64.0440, h = 25.2838},
                    {x = 1061.1304, y = -466.5329, z = 64.4445, h = 323.9720},
                    {x = 1057.3264, y = -467.7544, z = 64.0920, h = 138.4047},
                }
            },
            ['digging'] = { -- digging & planting
                amount = math.random(1, 4),
                data = {
                    {x = 1057.6483, y = -477.2516, z = 64.1055, h = 47.3369},
                    {x = 1059.7124, y = -467.5712, z = 64.3005, h = 348.2695},
                    {x = 1059.1785, y = -477.7497, z = 64.0762, h = 257.0834},
                }
            },
            ['cleaning'] = {
                amount = math.random(1, 4),
                data = {
                    {x = 1060.5356, y = -472.4675, z = 64.2846, h = 60.5300},
                    {x = 1054.1886, y = -471.0752, z = 63.8989, h = 79.2586},
                    {x = 1056.1047, y = -484.0166, z = 63.8128, h = 250.1622},
                    {x = 1051.5483, y = -480.7562, z = 63.9218, h = 90.2190},
                }
            },
        }
    }, 
    { -- Paleto Bay 
        waypoint_coords = {x = -428.9478, y = 6264.1333, z = 30.4366},
        jobs = {
            ['pulling'] = {
                amount = math.random(1, 2), -- how much on one job bcs of randomness, if you dont want randomness, just put how much data is inside.
                data = { 
                    {x = -431.1210, y = 6238.7388, z = 30.1276, h = 249.3069, r = 5.0},
                    {x = -439.3843, y = 6247.9717, z = 29.5875, h = 72.7727},
                }
            },
            ['digging'] = { -- digging & planting
                amount = math.random(1, 3),
                data = {
                    {x = -443.2108, y = 6237.4204, z = 29.3056, h = 135.5177},
                    {x = -427.9627, y = 6244.1519, z = 30.1589, h = 302.4203},
                    {x = -435.2570, y = 6245.7642, z = 29.8343, h = 248.9734},
                }
            },
            ['cleaning'] = {
                amount = math.random(1, 7),
                data = {
                    {x = -432.2157, y = 6268.4771, z = 30.2078, h = 27.1093},
                    {x = -435.1367, y = 6264.3965, z = 30.1450, h = 147.6782},
                    {x = -451.3035, y = 6263.3926, z = 30.0432, h = 18.2438},
                    {x = -451.1263, y = 6270.9985, z = 30.0394, h = 333.6066},
                    {x = -451.3654, y = 6264.0493, z = 33.3301, h = 18.3752},
                    {x = -450.9644, y = 6269.7305, z = 33.3301, h = 292.1263},
                    {x = -448.2786, y = 6274.9873, z = 33.3301, h = 21.6978},
                }
            },
        }
    },
    { -- GRAPESEED
    waypoint_coords = {x = 2261.6628, y = 5157.2988, z = 58.0676},
    jobs = {
        ['pulling'] = {
            amount = math.random(1, 2), -- how much on one job bcs of randomness, if you dont want randomness, just put how much data is inside.
            data = { 
                {x = 2261.6738, y = 5145.5342, z = 55.6387, h = 36.0318, r = 5.0},
                {x = 2280.0513, y = 5167.7925, z = 59.1655, h = 95.6082, r = 3.0},   
            }
        },
        ['digging'] = { -- digging & planting
            amount = math.random(1, 4),
            data = {
                {x = 2264.4546, y = 5147.8896, z = 56.0321, h = 139.7140},
                {x = 2253.4048, y = 5145.3887, z = 55.6340, h = 85.7959},
                {x = 2257.7756, y = 5160.8496, z = 58.1945, h = 48.3229},
                {x = 2257.3650, y = 5174.2446, z = 59.9109, h = 250.3303},
            }
        },
        ['cleaning'] = {
            amount = math.random(1, 3),
            data = {
                {x = 2258.6382, y = 5166.4248, z = 59.1117, h = 149.8786},
                {x = 2251.0608, y = 5154.7944, z = 57.8871, h = 316.2199},
                {x = 2242.4412, y = 5154.7100, z = 57.8871, h = 228.1965},
            }
        },
    }
    },
}

Config.JobsOptions = {
    ['digging'] = {
        holes = math.random(3, 8),
    },
    ['planting'] = {
        time = 10,
        props = {
            'prop_plant_paradise',
            'prop_plant_paradise',
            'prop_plant_paradise',
            'prop_plant_paradise',
            'prop_plant_paradise',
            'prop_plant_paradise'
        }
    },
    ['cleaning'] = {
        time = 10,
    },
    ['pulling'] = {
        props = {
            'h4_prop_bush_cocaplant_01',
            'v_med_p_ext_plant'
        }
    }
}