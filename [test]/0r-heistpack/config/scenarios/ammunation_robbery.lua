--[[
    Scenario: Ammunation Robbery
    Description: This scenario involves robbing weapon containers guarded by security.
]]
return {

    guardWeapon = "WEAPON_CARBINERIFLE",

    requiredGrinderItem = { itemName = "heistpack_grinder", label = "Máy Cắt Cầm Tay" },

    ---@type RewardItem[]
    lootableRewards = {
        { itemName = "black_money",         chance = 1.0, quantity = { min = 5000, max = 10000 } },
        { itemName = "weapon_glock17", chance = 1.0, quantity = { min = 2, max = 5 } },
        { itemName = "ammo-9", chance = 1.0, quantity = { min = 200, max = 500 } },
        -- { itemName = "weapon_smg",    chance = 0.4, quantity = { min = 1, max = 1 } },
        -- { itemName = "weapon_ammo",   chance = 0.9, quantity = { min = 100, max = 200 } },
    },

    locations = {
        [1] = {
            centerCoords = vector3(1139.2340, -3193.1665, 5.9008),

            -- 8 container coordinates
            containers = {
                { model = "tr_prop_tr_container_01a", coords = vector4(1132.873, -3181.619, 4.901, 0.0) },
                { model = "tr_prop_tr_container_01b", coords = vector4(1136.239, -3181.571, 4.901, 0.0) },
                { model = "tr_prop_tr_container_01c", coords = vector4(1140.260, -3181.627, 4.901, 0.0) },
                { model = "tr_prop_tr_container_01d", coords = vector4(1144.235, -3181.610, 4.901, 0.0) },
                { model = "tr_prop_tr_container_01e", coords = vector4(1132.154, -3190.396, 4.901, 180.0) },
                { model = "tr_prop_tr_container_01f", coords = vector4(1136.204, -3190.360, 4.901, 180.0) },
                { model = "tr_prop_tr_container_01g", coords = vector4(1140.264, -3190.552, 4.901, 180.0) },
                { model = "tr_prop_tr_container_01h", coords = vector4(1144.295, -3190.430, 4.901, 180.0) },
            },

            -- Guard spawn positions
            guards = {
                vector4(1144.1525, -3194.8657, 5.9008, 186.9639),
                vector4(1131.1377, -3193.2769, 5.9008, 190.3578),
                vector4(1131.5502, -3178.8857, 5.8978, 352.5563),
                vector4(1146.0671, -3178.7830, 5.9008, 315.3257),
                vector4(1137.59, -3197.44, 5.90, 34.53),
                vector4(1129.87, -3182.48, 8.68, 6.06),
                vector4(1138.75, -3176.18, 5.90, 336.99),
                vector4(1145.82, -3171.05, 5.80, 305.13),
                vector4(1124.25, -3193.65, 5.90, 68.41),
                vector4(1129.58, -3174.55, 5.87, 342.01),
            },
        },
        [2] = {
            centerCoords = vector3(1108.2590, -3080.9531, 5.8521),

            containers = {
                { model = "tr_prop_tr_container_01a", coords = vector4(1092.305, -3089.684, 4.890, 90.0) },
                { model = "tr_prop_tr_container_01b", coords = vector4(1092.393, -3086.037, 4.889, 90.0) },
                { model = "tr_prop_tr_container_01c", coords = vector4(1092.362, -3082.694, 4.889, 90.0) },
                { model = "tr_prop_tr_container_01d", coords = vector4(1092.435, -3079.118, 4.888, 90.0) },
                { model = "tr_prop_tr_container_01e", coords = vector4(1099.923, -3078.022, 4.877, 270.0) },
                { model = "tr_prop_tr_container_01f", coords = vector4(1099.975, -3081.758, 4.872, 270.0) },
                { model = "tr_prop_tr_container_01g", coords = vector4(1099.965, -3085.479, 4.873, 270.0) },
                { model = "tr_prop_tr_container_01h", coords = vector4(1100.096, -3089.360, 4.874, 270.0) },
            },

            guards = {
                vector4(1103.3414, -3076.2439, 5.8807, 248.4538),
                vector4(1103.0618, -3090.1233, 5.8688, 327.2201),
                vector4(1087.9653, -3091.6318, 5.8984, 87.4428),
                vector4(1088.0776, -3078.1702, 5.8994, 151.8113),
                vector4(1096.27, -3065.66, 5.90, 39.07),
                vector4(1108.85, -3065.16, 5.90, 266.65),
                vector4(1113.76, -3069.95, 8.68, 279.46),
                vector4(1086.12, -3079.70, 5.90, 90.22),
                vector4(1086.59, -3094.46, 5.90, 150.81),
                vector4(1108.50, -3094.18, 5.86, 320.15),
            },
        },
        [3] = {
            centerCoords = vector3(1280.7283, -3304.1526, 5.9016),

            containers = {
                { model = "tr_prop_tr_container_01b", coords = vector4(1283.748, -3306.488, 4.918, 270.0) },
                { model = "tr_prop_tr_container_01b", coords = vector4(1283.816, -3309.939, 4.918, 270.0) },
                { model = "tr_prop_tr_container_01b", coords = vector4(1283.905, -3313.388, 4.903, 270.0) },
                { model = "tr_prop_tr_container_01b", coords = vector4(1283.979, -3316.864, 4.903, 270.0) },
                { model = "tr_prop_tr_container_01b", coords = vector4(1275.467, -3317.947, 4.902, 90.0) },
                { model = "tr_prop_tr_container_01b", coords = vector4(1275.323, -3314.343, 4.902, 90.0) },
                { model = "tr_prop_tr_container_01b", coords = vector4(1275.298, -3310.718, 4.902, 90.0) },
                { model = "tr_prop_tr_container_01b", coords = vector4(1275.216, -3306.551, 4.902, 90.0) },
            },

            guards = {
                vector4(1284.1030, -3295.2612, 5.9028, 39.6853),
                vector4(1283.0093, -3295.5869, 5.9024, 103.6959),
                vector4(1279.4268, -3296.2083, 5.9016, 98.9039),
                vector4(1281.0098, -3293.9138, 5.9016, 295.2392),
                vector4(1288.51, -3287.69, 5.96, 342.76),
                vector4(1281.66, -3278.86, 5.90, 34.68),
                vector4(1271.44, -3283.94, 5.90, 102.38),
                vector4(1269.10, -3298.69, 5.90, 121.50),
                vector4(1277.58, -3310.74, 5.90, 196.84),
                vector4(1285.90, -3319.03, 5.90, 205.08),
            },
        },
        [4] = {
            centerCoords = vector3(847.4496, -3137.8308, 5.9007),

            containers = {
                { model = "tr_prop_tr_container_01b", coords = vector4(851.277, -3129.968, 4.901, 0.0) },
                { model = "tr_prop_tr_container_01b", coords = vector4(846.507, -3130.134, 4.901, 0.0) },
                { model = "tr_prop_tr_container_01b", coords = vector4(842.801, -3130.106, 4.901, 0.0) },
                { model = "tr_prop_tr_container_01b", coords = vector4(838.674, -3129.948, 4.901, 0.0) },
                { model = "tr_prop_tr_container_01b", coords = vector4(834.592, -3130.084, 4.901, 0.0) },
                { model = "tr_prop_tr_container_01b", coords = vector4(830.361, -3130.236, 4.901, 0.0) },
                { model = "tr_prop_tr_container_01b", coords = vector4(826.216, -3130.463, 4.901, 0.0) },
                { model = "tr_prop_tr_container_01b", coords = vector4(822.279, -3130.353, 4.901, 0.0) },
            },

            guards = {
                vector4(823.1535, -3134.1458, 5.9008, 171.5896),
                vector4(832.5996, -3133.7227, 5.9008, 197.2730),
                vector4(843.7590, -3133.9629, 5.9008, 176.9784),
                vector4(851.8945, -3134.1477, 5.9008, 202.0529),
                vector4(821.95, -3125.17, 5.90, 341.05),
                vector4(835.21, -3122.80, 6.05, 308.11),
                vector4(873.07, -3123.30, 5.90, 281.88),
                vector4(866.22, -3151.19, 6.05, 166.63),
                vector4(843.42, -3147.96, 5.91, 81.24),
                vector4(830.37, -3139.65, 6.02, 76.14),
            },
        }
    },
}
