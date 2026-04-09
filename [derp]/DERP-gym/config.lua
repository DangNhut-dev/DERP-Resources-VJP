Config = {
    DeveloperMode = true, -- Developer mode (for support)

    Core = 'QBCORE',  -- ESX / QBCORE  | Other core setting on the 'core' folder
    BrutalNotify = false, -- Buy here: (4€+VAT) https://store.derpscripts.com | Or set up your own notify >> cl_utils.lua
    MINIGAME = false,  -- Download here: https://github.com/firestix77/taskbarskill   (You can edit in the [gym-cl_utils.lua])
    GYMDistance = 60,  -- This is the distance from which membership is broken
    PressKey = 38,  -- If you want to change: https://docs.fivem.net/docs/game-references/controls/

    DisableControls = {}, -- These controls will blocked during the exercises
    ShootWeponsBlackList = {'WEAPON_PETROLCAN'},

    Skills = {
        SkillMenu = {Label = 'Brutal Skill Menu', Command = 'skillmenu', Control = 'DELETE'},  -- SETTINGS > KEYBINDINGS
        SkillNotifyTime = 5000, -- in milisec | 1000 = 1 sec
        SaveFrequency = 5, -- in minutes | Save in the SQL after that time
        RemoveTime = 30,  -- in munites | Remove one skill from player after that time

        SprintSpeedIncrease = 'MEDIUM', -- ('FAST', 'MEDIUM', 'SLOWLY') At what rate should you increase the run speed?
        SwimSpeedIncrease = 'MEDIUM', -- ('FAST', 'MEDIUM', 'SLOWLY') At what rate should you increase the swimming speed?

        SkillTypes = {
            ['Stamina']  = {
                Use = true,
                Label = 'Thể lực',
                Color = 'rgb(24, 191, 238)',
                Description = 'Ảnh hưởng đến khả năng chạy nước rút, đạp xe và bơi. Thể lực tối đa giúp bạn không bị hụt sức.'
            },
            ['Running']  = {
                Use = true,
                Label = 'Chạy bộ',
                Color = 'rgb(24, 237, 148)',
                Description = 'Tăng tốc độ chạy, giúp di chuyển nhanh hơn.'
            },
            ['Driving']  = {
                Use = true,
                Label = 'Lái xe',
                Color = 'rgb(198, 237, 24)',
                Description = 'Cải thiện khả năng điều khiển xe, giữ thăng bằng tốt hơn và kiểm soát xe khi bay trên không.'
            },
            ['Strength'] = {
                Use = true,
                Label = 'Sức mạnh',
                Color = 'rgb(237, 24, 24)',
                Description = 'Tăng sức mạnh cận chiến, leo trèo nhanh hơn và giảm sát thương nhận vào.'
            },
            ['Swimming'] = {
                Use = true,
                Label = 'Bơi lội',
                Color = 'rgb(52, 24, 237)',
                Description = 'Tăng dung tích phổi, giúp ở dưới nước lâu hơn.'
            },
            ['Shooting'] = {
                Use = true,
                Label = 'Bắn súng',
                Color = 'rgb(212, 24, 237)',
                Description = 'Tăng độ chính xác, giảm giật và tăng khả năng sử dụng đạn.'
            },
        }
    },

    JobModifiers = {
        ['police'] = {
            MaxCap          = 150,
            DecayMultiplier = 10,
        },
        -- Thêm job khác tại đây nếu cần
    },

    Exersices = {
        -- Only use these [Stamina / Running / Driving / Strength / Swimming / Shooting] to the skill value.
        ['running'] = {label = "Chạy bộ", anim = "running", time = 30, skill = 'Running'},
        ['pushups'] = {label = "Hít đất", anim = "pushups", time = 30, skill = 'Strength'},
        ['situps'] = {label = "Gập bụng", anim = "situps", time = 30, skill = 'Stamina'},
        ['weightlifting'] = {label = "Nâng tạ", anim = "world_human_muscle_free_weights", time = 30, skill = 'Strength'},
        ['yoga'] = {label = "Yoga", anim = "world_human_yoga", time = 30, skill = 'Stamina'},
        ['pullup'] = {label = "Hít xà", anim = "prop_human_muscle_chin_ups", time = 30, skill = 'Strength'},
        -- You can add more...
    },
    
    Gyms = {
        ['GYM Bãi Biển'] = {
            ItemRequired = {Use = false, Item = '', Time = 30, RemoveItem = false},
            Distances = {Marker = 10, Text = 1.0},
            GYMCoords = { x = -1200.3149, y = -1568.4581, z = 4.6123},
            Marker = { Distance = 15, Sprite = 30, Rotation = true, UpAndDown = false, Brightness = 100, r = 240, g = 221, b = 12, sizes = {x = 0.25, y = 0.3, z = 0.3}},  -- More sprites: https://docs.fivem.net/docs/game-references/markers/
            Blip = { Use = true, colour = 33, size = 1.1, sprite = 311 },
            Exersices = {
                [1]  = { type = 'weightlifting', x = -1197.0083, y = -1573.0277, z = 4.6125, heading = 29.5812},
                [2]  = { type = 'weightlifting', x = -1210.0604, y = -1561.3734, z = 4.6080, heading = 76.0602},
                [3]  = { type = 'pullup', x = -1204.6512, y = -1564.4742, z = 4.6096, heading = 36.2476},
                [4]  = { type = 'pullup', x = -1200.1077, y = -1570.9010, z = 4.6097, heading = 216.9520},
                [5]  = { type = 'yoga', x = -1204.6547, y = -1560.7797, z = 4.6143, heading = 35.4453},
                [6]  = { type = 'pushups', x = -1207.3629, y = -1565.8481, z = 4.6080, heading = 125.5502},
                [7]  = { type = 'situps', x = -1202.0811, y = -1567.2975, z = 4.6106,heading =  209.7822},
                -- You can add more...
            }
        },
        
        ['Trung Tâm GYM'] = {
            ItemRequired = {Use = false, Item = 'gym_membership', Time = 15, RemoveItem = true},
            Distances = {Marker = 10, Text = 1.0},
            GYMCoords = { x = -1263.9678, y = -360.9280, z = 36.9944},
            Marker = { Distance = 15, Sprite = 30, Rotation = true, UpAndDown = false, Brightness = 100, r = 260, g = 40, b = 40, sizes = {x = 0.25, y = 0.3, z = 0.3}},  -- More sprites: https://docs.fivem.net/docs/game-references/markers/
            Blip = { Use = true, colour = 1, size = 1.1, sprite = 311 },
            Exersices = {
                [1]  = { type = 'weightlifting', x = -1269.4681, y = -362.2640, z = 36.9837, heading = 114.9331},
                [2]  = { type = 'weightlifting', x = -1267.5681, y = -365.8660, z = 36.9837, heading = 111.7152},
                [3]  = { type = 'pullup', x = -1256.8202, y = -358.4193, z = 36.9595, heading = 115.7973},
                [4]  = { type = 'pullup', x = -1258.6047, y = -355.1523, z = 36.9596, heading = 157.1221},
                [5]  = { type = 'yoga', x = -1270.4337, y = -359.4362, z = 36.9596, heading = 265.9220},
                [6]  = { type = 'pushups', x = -1262.6473, y = -359.7602, z = 36.9948, heading = 118.7721},
                [7]  = { type = 'pushups', x = -1261.6625, y = -361.5224, z = 36.9948, heading = 114.4993},
                [8]  = { type = 'situps', x = -1266.0231, y = -356.7149, z = 36.9596, heading = 208.9295},
                [9]  = { type = 'situps', x = -1263.2084, y = -355.0845, z = 36.9596, heading = 205.2904},
                [10] = { type = 'running', x = -1263.5249, y = -369.5938, z = 37.1113, heading = 213.0987},
                [11] = { type = 'running', x = -1260.6754, y = -368.0751, z = 37.1124, heading = 213.4567},
                [12] = { type = 'running', x = -1257.7607, y = -366.3998, z = 37.1116, heading = 208.1506},
                -- You can add more...
            }
        },

        ['GYM Nhà Tù'] = {
            ItemRequired = {Use = false, Item = 'gym_membership', Time = 15, RemoveItem = true},
            Distances = {Marker = 10, Text = 1.0},
            GYMCoords = { x = 1747.8870, y = 2544.0845, z = 43.5854},
            Marker = { Distance = 15, Sprite = 30, Rotation = true, UpAndDown = false, Brightness = 100, r = 260, g = 40, b = 40, sizes = {x = 0.25, y = 0.3, z = 0.3}},  -- More sprites: https://docs.fivem.net/docs/game-references/markers/
            Blip = { Use = false, colour = 1, size = 1.1, sprite = 311 },
            Exersices = {
                [1]  = { type = 'weightlifting', x = 1746.9486, y = 2543.9863, z = 43.5855, heading = 100.8497},
                [2]  = { type = 'weightlifting', x = 1748.1990, y = 2541.6675, z = 43.5855, heading = 111.0449},
                [3]  = { type = 'pushups', x = 1739.7616, y = 2541.2312, z = 43.5855, heading = 206.0246},
                [4]  = { type = 'pushups', x = 1742.0660, y = 2537.2927, z = 43.5855, heading = 32.1690},
                [5]  = { type = 'situps', x = 1751.0808, y = 2536.8789, z = 43.5855, heading = 24.3098},
                [6]  = { type = 'situps', x = 1752.6005, y = 2537.6794, z = 43.5855, heading = 24.3307},
                -- You can add more...
            }
        },

        -- You can add more GYM's...
    },
    

    -----------------------------------------------------------
    -----------------------| TRANSLATE |-----------------------
    -----------------------------------------------------------

    Text3D = {'Để', '~w~nhấn ~w~[~g~E~w~]'},

    Notify = {
        [1] = {'Brutal GYM', "Bạn không có thẻ GYM!", 5000, 'error'},
        [2] = {'Brutal GYM', "Đã hết thời gian!", 5000, 'warning'},
        [3] = {'Brutal GYM', "Bạn đã rời khỏi GYM!", 5000, 'warning'},
        [4] = {'Brutal GYM', "Bạn không thể làm điều này khi đang ở trong xe!", 5000, 'error'},
    }
}