-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================




return {
    Hospital = {
        ['hane_hospital'] = {
            jobs = {'ambulance'}, -- which jobs are allowed to use this hospital
            blip = {
                enabled = true,
                name = locale('hospital'),
                sprite = 61, 
                scale = 0.9,
                color = 25, 
                coords = vec3(295.78, -583.25, 42.10),
            },
            duty = {
                enabled = true,
                coords = vec4(307.85, -588.01, 43.34, 0.0),
            -- ped = 's_m_m_paramedic_01',
            -- anim = {dict = 'missfam4', clip = 'base', flag = 1},
            -- prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)}
            },
            wardrobe = vec3(324.39, -565.20, 43.78),
            management = {
                coords = vec3(315.49, -604.74, 43.20), -- coords of boss menu [script will open your boss menu!]
                allowedGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10} -- which job grades are allowed to use management menu
            }, 
        },
    },

    TV = {
        ['hane_hospital'] = {
            ['Entrance TV'] = {
                coords = vec3(298.65, -587.31, 44.57),
                rot = vec3(7.00, 0.00, 76.00)
            },
        },
    },

    CheckIn = {
        ['hane_hospital'] = {
            label = 'Pillbox Hospital',
            coords = vec4(307.42, -584.63, 43.27, 106.00),
            driveCoords = vec4(329.8796, -555.0304, 28.7451, 129.7094), -- optional, if you want ai medic to drive to specific coords before going to bed
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
        ['hane_hospital'] = {
            vec4(324.40, -597.01, 43.97, 255.00),
            vec4(330.62, -599.18, 43.97, 75.00),
            vec4(325.10, -595.06, 43.97, 261.00),
            vec4(331.32, -597.25, 43.97, 69.00),
            vec4(325.81, -593.15, 43.97, 256.00),
            vec4(331.97, -595.27, 43.97, 70.00),
            vec4(328.93, -584.44, 43.97, 250.00),
            vec4(335.02, -587.14, 43.97, 76.00),
            vec4(329.82, -582.54, 43.97, 259.00),
            vec4(335.76, -585.03, 43.97, 67.00),
            vec4(330.41, -580.61, 43.97, 264.00),
            vec4(336.60, -582.88, 43.97, 65.00),
        },
    },

    Insurances = {
        ['hane_hospital'] = {
            coords = vec4(305.19, -590.13, 43.27, 31.00),
            ped = 's_m_m_doctor_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
        },
    },

    Shops = {
        ['hane_hospital'] = {
            label = 'Hospital Cabinet',
            blip = {name = locale('cabinet'), sprite = 59, scale = 0.85, color = 25},
            coords = vec4(311.2262, -604.3000, 43.2684, 340.2412),
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
        ['hane_hospital_pharmacy'] = {
            label = 'Hospital Pharmacy',
            blip = {name = locale('pharmacy'), sprite = 403, scale = 0.85, color = 69},
            coords = vec4(301.2602, -598.2853, 43.2684, 66.8515),
            ped = 's_m_m_paramedic_01',
            items = {
                {name = 'gauze', price = 50},
                {name = 'adrenaline', price = 100},
                {name = 'bandage', price = 200},
                {name = 'cyclonamine', price = 300},
                {name = 'tourniquet', price = 500},
            }
        },
    },

    Garages = {
        ['hane_hospital'] = {
            blip = {sprite = 225, color = 1, scale = 0.8, label = locale('garage')},
            coords = vec4(301.53, -584.26, 28.80, 256.00),
            ped = 's_m_m_paramedic_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
            spawnInVehicle = true,
            platePrefix = 'EMS',
            parkDistance = 20.0,
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
                vec4(300.2314, -580.3588, 28.8031, 338.2588),
                vec4(302.5553, -573.9823, 28.8031, 339.7199),
                vec4(296.9142, -578.7649, 28.8031, 160.6713),
                vec4(299.1299, -572.9935, 28.8036, 339.3024),
                vec4(296.0599, -571.7712, 28.8031, 337.4802),
                vec4(293.7421, -577.2399, 28.8031, 159.8416),
            }
        },
        ['hane_hospital_heli'] = {
            blip = {sprite = 759, color = 1, scale = 0.8, label = locale('helipad')},
            coords = vec4(327.79, -593.37, 94.89, 77.00),
            ped = 's_m_m_paramedic_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
            spawnInVehicle = true,
            platePrefix = 'EMS',
            parkDistance = 25.0,
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
                vec4(320.5074, -592.8791, 94.8939, 69.5829),
            }
        },
    },

    Elevators = {
        ['hane_hospital'] = {
            {
                coords = vec3(337.04, -603.87, 69.46),
                floors = {
                    {label = locale('roof'), coords = vec4(335.39, -598.41, 92.99, 78.00)},
                    {label = locale('garage'), coords = vec4(338.6567, -602.7155, 28.8039, 156.9842)},
                }
            },
            {
                coords = vec3(336.92, -604.07, 29.00),
                floors = {
                    {label = locale('roof'), coords = vec4(335.39, -598.41, 92.99, 78.00)},
                    {label = locale('hospital'), coords = vec4(338.4647, -603.0683, 43.2684, 159.3193)},
                }
            },
            {
                coords = vec3(333.45, -596.70, 93.35),
                floors = {
                    {label = locale('hospital'), coords = vec4(338.4647, -603.0683, 43.2684, 159.3193)},
                    {label = locale('garage'), coords = vec4(338.6567, -602.7155, 28.8039, 156.9842)},
                }
            }
        },
    }
}
