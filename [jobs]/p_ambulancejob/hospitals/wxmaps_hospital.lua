-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================



return {
    Hospital = {
        ['wxmaps_hospital'] = {
            jobs = {'ambulance'}, -- which jobs are allowed to use this hospital
            blip = {
                enabled = true,
                name = locale('hospital'),
                sprite = 61, 
                scale = 0.9,
                color = 25, 
                coords = vec3(-316.13, -603.79, 31.85),
            },
            duty = {
                enabled = true,
                coords = vec4(-324.22, -586.46, 32.68, 0.0),
            -- ped = 's_m_m_paramedic_01',
            -- anim = {dict = 'missfam4', clip = 'base', flag = 1},
            -- prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)}
            },
            wardrobe = vec3(-344.65, -588.72, 32.96),
            management = {
                coords = vec3(-327.90, -576.27, 32.61), -- coords of boss menu [script will open your boss menu!]
                allowedGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10} -- which job grades are allowed to use management menu
            }, 
        },
    },

    TV = {
        ['wxmaps_hospital'] = {
            ['Entrance TV'] = {
                coords = vec3(-317.10, -594.68, 33.86),
                rot = vec3(1.00, -0.00, -125.00),
            },
        },
    },

    CheckIn = {
        ['wxmaps_hospital'] = {
            label = 'San Andreas Hospital',
            coords = vec4(-327.9289, -590.4722, 32.7755, 244.6265),
            driveCoords = vec4(-300.9110, -616.3211, 33.5446, 22.8251), -- optional, if you want ai medic to drive to specific coords before going to bed
            ped = 's_m_m_doctor_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
            duration = 5000,
            maxDutyMedics = 2,
            price = {
                money = 500, -- price in cash
                bank = 500, -- price in bank
                black_money = 500, -- price in black money [if you want to disable some payment method, just remove it from table]
                insurance = true, -- can be used insurance for check-in? [only will work if player own insurance]
            }
        },
    },

    CheckInBeds = {
        ['wxmaps_hospital'] = {
            vec4(-347.96, -604.04, 37.19, 217.00),
            vec4(-347.01, -607.95, 37.19, 314.00),
            vec4(-344.81, -611.29, 37.19, 314.00),
            vec4(-341.28, -612.91, 37.19, 34.00),
        },
    },

    Insurances = {
        ['wxmaps_hospital'] = {
            coords = vec4(-323.1106, -586.9794, 32.7755, 191.7357),
            ped = 's_m_m_doctor_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
        },
    },

    Shops = {
        ['wxmaps_hospital'] = {
            label = 'Hospital Cabinet',
            blip = {name = locale('cabinet'), sprite = 59, scale = 0.85, color = 25},
            coords = vec4(-344.9016, -587.7113, 32.7745, 303.0427),
            ped = 's_m_m_paramedic_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
            jobRestricted = true, -- only for jobs from Config.Hospitals?
            items = {
                {name = 'medicbag', price = 0},
                {name = 'ambulance_gps', price = 0},
                {name = 'wheelchair', price = 0},
                {name = 'crutch', price = 0},
                {name = 'stretcher', price = 0},
                {name = 'bodybag', price = 0},
                {name = 'bandage', price = 0},
                {name = 'icepack', price = 0},
                {name = 'ointment', price = 0},
                {name = 'defibrilator', price = 0},
                {name = 'splint', price = 0},
                {name = 'suture_kit', price = 0},
                {name = 'morphine', price = 0},
                {name = 'medical_kit', price = 0},
                {name = 'disinfectant', price = 0},
                {name = 'advanced_medical_kit', price = 0},
                {name = 'blood_bag_250', price = 0},
                {name = 'blood_bag_500', price = 0},
                {name = 'antipyretics', price = 0},
                {name = 'painkillers', price = 0},
                {name = 'gauze', price = 5},
                {name = 'adrenaline', price = 10},
                {name = 'cyclonamine', price = 15},
                {name = 'tourniquet', price = 20},
            }
        },
    },

    Garages = {
        ['wxmaps_hospital'] = {
            blip = {sprite = 225, color = 1, scale = 0.8, label = locale('garage')},
            coords = vec4(-293.0264, -588.3840, 27.7824, 0.9708),
            ped = 's_m_m_paramedic_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
            spawnInVehicle = true,
            platePrefix = 'EMS',
            parkDistance = 30.0,
            vehicles = {
                ['ambulance'] = {
                    label = 'Ambulance',
                    image = 'https://docs.fivem.net/vehicles/ambulance.webp',
                    mods = {
                        [0] = 1,
                    },
                    allowedGrades = {0, 1, 2, 3, 4, 5},
                }
            },
            spawnPoints = {
                vec4(-285.2777, -585.4836, 27.6325, 273.0562),
                vec4(-285.8666, -580.5070, 27.6325, 268.1144),
                vec4(-285.8909, -576.0419, 27.6325, 268.6015),
                vec4(-285.8459, -571.7371, 27.6325, 267.1442),
            }
        },
        ['wxmaps_hospital_heli'] = {
            blip = {sprite = 759, color = 1, scale = 0.8, label = locale('helipad')},
            coords = vec4(-347.1185, -623.5330, 51.2549, 3.8405),
            ped = 's_m_m_paramedic_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
            spawnInVehicle = true,
            platePrefix = 'EMS',
            parkDistance = 20.0,
            vehicles = {
                ['maverick'] = {
                    label = 'Maverick',
                    image = 'https://docs.fivem.net/vehicles/maverick.webp',
                    mods = {
                        [0] = -1,
                    },
                    allowedGrades = {0, 1, 2, 3, 4, 5},
                }
            },
            spawnPoints = {
                vec4(-344.8115, -613.6418, 51.2549, 358.7374),
            }
        },
    },

    Elevators = {
        ['wxmaps_hospital'] = {
            {
                coords = vec3(-304.69, -588.31, 32.98),
                floors = {
                    {label = locale('roof'), coords = vec4(-302.2470, -593.6422, 47.9819, 0.9272)},
                    {label = locale('garage'), coords = vec4(-294.8038, -591.3406, 27.7824, 357.6197)}
                }
            },
            {
                coords = vec3(-293.73, -589.56, 27.99),
                floors = {
                    {label = locale('roof'), coords = vec4(-302.2470, -593.6422, 47.9819, 0.9272)},
                    {label = locale('hospital'), coords = vec4(-304.5966, -590.5762, 32.7755, 37.3349)}
                }
            },
            {
                coords = vec3(-301.14, -591.84, 48.42),
                floors = {
                    {label = locale('hospital'), coords = vec4(-304.5966, -590.5762, 32.7755, 37.3349)},
                    {label = locale('garage'), coords = vec4(-294.8038, -591.3406, 27.7824, 357.6197)}
                }
            },

            {
                coords = vec3(-331.84, -606.63, 33.26),
                floors = {
                    {label = locale('roof'), coords = vec4(-329.8257, -611.5190, 47.9820, 87.5609)},
                }
            },
            {
                coords = vec3(-331.80, -610.39, 48.43),
                floors = {
                    {label = locale('hospital'), coords = vec4(-331.6162, -609.1214, 32.7755, 33.9749)},
                }
            },
        },
    }
}
