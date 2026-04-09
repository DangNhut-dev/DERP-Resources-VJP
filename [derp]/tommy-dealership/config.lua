Config = {}

-- General Settings
Config.UsingTarget = GetConvar('UseTarget', 'false') == 'true'
Config.TestDriveTimeLimit = 1.0 -- Time in minutes (0.5 = 30 seconds)
Config.PaymentWarning = 10
Config.PaymentInterval = 24
Config.MinimumDown = 10
Config.MaximumPayments = 24
Config.PreventFinanceSelling = false
Config.FilterByMake = false
Config.SortAlphabetically = true
Config.HideCategorySelectForOne = true

-- Showroom Rendering (Important for custom maps!)
Config.ShowroomRenderDistance = 100.0 -- Distance (in meters) at which showroom vehicles spawn for players
Config.SelfPurchaseMarkup = 0.10

-- ✨ Discord Webhook Settings
Config.DiscordWebhook = "https://discord.com/api/webhooks/1438247973233365083/Hn_hMC_-Ahhl7KGZpZATOtH2M9o3WWyV4RRjhjPJ9KGuH9yLX9AfpeeV6qh8T1SYjDSS" -- Điền URL webhook Discord của bạn vào đây
Config.WebhookImagePath = "html/images/" -- Đường dẫn đến thư mục ảnh xe
Config.WebhookDefaultImage = "default.png" -- Ảnh mặc định nếu không tìm thấy ảnh xe

-- Commission by Grade
Config.Commission = {
    [0] = 0.02,
    [1] = 0.05, 
    [2] = 0.05, 
    [3] = 0.07, 
    [4] = 0.15, 
}

-- Job Settings
Config.DealerJob = 'cardealer'
Config.ManagementGrade = 4 -- Grade required for management features

-- Self Purchase NPC Settings
Config.SelfPurchaseNPC = {
    enabled = true,
    model = 'cs_milton',
    coords = vector4(-2235.47, -390.54, 12.52, 308.08),
    scenario = 'WORLD_HUMAN_CLIPBOARD', -- Animation: standing with clipboard
    frozen = true,
    invincible = true,
    blockevents = true,
    checkDistance = 5.0, -- Max distance to interact with NPC
}

-- Shops Configuration
Config.Shops = {
    ['luxury'] = {
        ['Type'] = 'managed',
        ['Zone'] = {
            ['Shape'] = {
                vector2(-2246.59, -387.37),
                vector2(-2197.27, -429.42),
                vector2(-2174.38, -403.70),
                vector2(-2224.46, -360.98)
            },
            ['minZ'] = 5.417655944824,
            ['maxZ'] = 20.102005004883,
            ['size'] = 2.75
        },
        ['Job'] = 'cardealer',
        ['ShopLabel'] = 'Baby Blue Cars',
        ['showBlip'] = true,
        ['blipSprite'] = 530,
        ['blipColor'] = 15,
        ['Location'] = vector3(-2196.40, -379.28, 13.32),
        ['ReturnLocation'] = vector3(-2198.98, -378.36, 13.51),
        ['VehicleSpawn'] = vector4(-2178.13, -419.20, 12.60, 320.89),
        ['TestDriveSpawn'] = vector4(-2178.13, -419.20, 12.60, 320.89),
        ['FinanceZone'] = vector3(-2210.00, -394.59, 13.61),
        ['ShowroomVehicles'] = {
            [1] = {
                coords = vector4(-2223.21, -368.71, 12.08, 249.10),
                defaultVehicle = '',
            },
            [2] = {
                coords = vector4(-2218.66, -379.39, 12.06, 247.69),
                defaultVehicle = '',
            },
            [3] = {
                coords = vector4(-2208.07, -381.15, 12.08, 243.01),
                defaultVehicle = '',
            },
            [4] = {
                coords = vector4(-2197.42, -392.43, 12.08, 186.38),
                defaultVehicle = '',
            },
            [5] = {
                coords = vector4(-2183.30, -404.61, 12.08, 181.40),
                defaultVehicle = '',
            },
            [6] = {
                coords = vector4(-2200.22, -417.94, 13.40, 49.87),
                defaultVehicle = '',
            },
            [7] = {
                coords = vector4(-2217.92, -403.12, 13.40, 49.93),
                defaultVehicle = '',
            },
            -- [8] = {
            --     coords = vector4(-2159.38, -412.12, 13.49, 31.22),
            --     defaultVehicle = '',
            -- },
            -- [9] = {
            --     coords = vector4(-110.76, 46.9, 71.68, 331.32),
            --     defaultVehicle = '',
            -- },
            -- [10] = {
            --     coords = vector4(-106.54, 43.65, 71.61, 332.18),
            --     defaultVehicle = '',
            -- },
        }
    },
}

-- Vehicle Colors (Random)
Config.VehicleColors = {
    {name = "Black", colorindex = 0},
    {name = "Carbon Black", colorindex = 147},
    {name = "Graphite", colorindex = 1},
    {name = "Anthracite Black", colorindex = 11},
    {name = "Black Steel", colorindex = 2},
    {name = "Dark Steel", colorindex = 3},
    {name = "Silver", colorindex = 4},
    {name = "Bluish Silver", colorindex = 5},
    {name = "Rolled Steel", colorindex = 6},
    {name = "Shadow Silver", colorindex = 7},
    {name = "Stone Silver", colorindex = 8},
    {name = "Midnight Silver", colorindex = 9},
    {name = "Cast Iron Silver", colorindex = 10},
    {name = "Red", colorindex = 27},
    {name = "Torino Red", colorindex = 28},
    {name = "Formula Red", colorindex = 29},
    {name = "Lava Red", colorindex = 150},
    {name = "Blaze Red", colorindex = 30},
    {name = "Grace Red", colorindex = 31},
    {name = "Garnet Red", colorindex = 32},
    {name = "Sunset Red", colorindex = 33},
    {name = "Cabernet Red", colorindex = 34},
    {name = "Wine Red", colorindex = 143},
    {name = "Candy Red", colorindex = 35},
    {name = "Hot Pink", colorindex = 135},
    {name = "Pfsiter Pink", colorindex = 137},
    {name = "Salmon Pink", colorindex = 136},
    {name = "Sunrise Orange", colorindex = 36},
    {name = "Orange", colorindex = 38},
    {name = "Bright Orange", colorindex = 138},
    {name = "Gold", colorindex = 99},
    {name = "Bronze", colorindex = 90},
    {name = "Yellow", colorindex = 88},
    {name = "Race Yellow", colorindex = 89},
    {name = "Dew Yellow", colorindex = 91},
    {name = "Dark Green", colorindex = 49},
    {name = "Racing Green", colorindex = 50},
    {name = "Sea Green", colorindex = 51},
    {name = "Olive Green", colorindex = 52},
    {name = "Bright Green", colorindex = 53},
    {name = "Gasoline Green", colorindex = 54},
    {name = "Lime Green", colorindex = 92},
    {name = "Midnight Blue", colorindex = 141},
    {name = "Galaxy Blue", colorindex = 61},
    {name = "Dark Blue", colorindex = 62},
    {name = "Saxon Blue", colorindex = 63},
    {name = "Blue", colorindex = 64},
    {name = "Mariner Blue", colorindex = 65},
    {name = "Harbor Blue", colorindex = 66},
    {name = "Diamond Blue", colorindex = 67},
    {name = "Surf Blue", colorindex = 68},
    {name = "Nautical Blue", colorindex = 69},
    {name = "Racing Blue", colorindex = 73},
    {name = "Ultra Blue", colorindex = 70},
    {name = "Light Blue", colorindex = 74},
    {name = "Chocolate Brown", colorindex = 96},
    {name = "Bison Brown", colorindex = 101},
    {name = "Creeen Brown", colorindex = 95},
    {name = "Feltzer Brown", colorindex = 94},
    {name = "Maple Brown", colorindex = 97},
    {name = "Beechwood Brown", colorindex = 103},
    {name = "Sienna Brown", colorindex = 104},
    {name = "Saddle Brown", colorindex = 98},
    {name = "Moss Brown", colorindex = 100},
    {name = "Woodbeech Brown", colorindex = 102},
    {name = "Straw Brown", colorindex = 99},
    {name = "Sandy Brown", colorindex = 105},
    {name = "Bleached Brown", colorindex = 106},
    {name = "Schafter Purple", colorindex = 71},
    {name = "Spinnaker Purple", colorindex = 72},
    {name = "Midnight Purple", colorindex = 142},
    {name = "Bright Purple", colorindex = 145},
    {name = "Cream", colorindex = 107},
    {name = "Ice White", colorindex = 111},
    {name = "Frost White", colorindex = 112}
}