-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================



return {
    Hospital = {
        ['gabz_hospital'] = {
            jobs = {'ambulance'}, -- which jobs are allowed to use this hospital
            blip = {
                enabled = true,
                name = locale('hospital'),
                sprite = 61, 
                scale = 0.9,
                color = 25, 
                coords = vec3(297.9502, -584.3785, 43.2609)
            },
            duty = {
                enabled = true,
                coords = vec4(310.19, -593.06, 43.09, 0.0),
            -- ped = 's_m_m_paramedic_01',
            -- anim = {dict = 'missfam4', clip = 'base', flag = 1},
            -- prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)}
            },
            wardrobe = vec3(302.47, -598.98, 43.50),
            management = {
                coords = vec3(339.65, -590.56, 43.09), -- coords of boss menu [script will open your boss menu!]
                allowedGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10} -- which job grades are allowed to use management menu
            }, 
        },
    },

    TV = {
        ['gabz_hospital'] = {
            ['Entrance TV'] = {
                coords = vec3(301.283, -582.483, 44.318),
                rot = vec3(8.231, 0.000, 47.436),
            },
        },
    },

    CheckIn = {
        ['gabz_hospital'] = {
            label = 'Pillbox Hospital',
            coords = vec4(307.0528, -595.0332, 43.2841, 67.0701),
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
        ['gabz_hospital'] = {
            vec4(322.69, -587.27, 44.20, 341.00),
            vec4(324.19, -582.87, 44.20, 174.00),
            vec4(317.81, -585.33, 44.20, 354.00),
            vec4(319.35, -581.05, 44.20, 166.00),
            vec4(314.51, -584.30, 44.20, 0.00),
            vec4(313.85, -579.02, 44.20, 172.00),
            vec4(311.19, -582.88, 44.20, 0.00),
            vec4(309.32, -577.37, 44.20, 165.00),
            vec4(307.81, -581.64, 44.20, 0.00),
        },
    },

    Insurances = {
        ['gabz_hospital'] = {
            coords = vec4(312.4630, -592.8284, 43.2841, 344.9943),
            ped = 's_m_m_doctor_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
        },
    },

    Shops = {
        ['gabz_hospital'] = {
            label = 'Hospital Cabinet',
            blip = {name = locale('cabinet'), sprite = 59, scale = 0.85, color = 25},
            coords = vec4(306.33, -601.66, 43.28, 338.00),
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
        ['gabz_hospital'] = {
            blip = {sprite = 225, color = 1, scale = 0.8, label = locale('garage')},
            coords = vec4(335.0324, -590.1027, 28.7968, 69.5732),
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
                vec4(332.8722, -590.2881, 28.7968, 158.3711),
                vec4(329.5510, -588.9984, 28.7968, 160.5542),
                vec4(326.3069, -587.9284, 28.7968, 158.1964),
                vec4(323.0535, -586.5775, 28.7968, 159.6957),
                vec4(319.5735, -585.2662, 28.7968, 159.9599),
                vec4(316.6394, -577.9641, 28.7968, 69.7879),
                vec4(318.5216, -573.6894, 28.7968, 68.9035)
            }
        },
        ['gabz_hospital_heli'] = {
            blip = {sprite = 759, color = 1, scale = 0.8, label = locale('helipad')},
            coords = vec4(337.58, -586.89, 74.16, 251.00),
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
                vec4(351.9953, -588.1979, 74.1644, 95.6272),
            }
        },
    },

    Elevators = {
        ['gabz_hospital'] = {
            {
                coords = vec3(332.66, -595.78, 43.49),
                floors = {
                    {label = locale('roof'), coords = vec4(338.9885, -584.0726, 74.1617, 250.3736)},
                    {label = locale('garage'), coords = vec4(339.9623, -584.7045, 28.7968, 70.3155)},
                }
            },
            {
                coords = vec3(340.42, -584.83, 28.92),
                floors = {
                    {label = locale('roof'), coords = vec4(338.9885, -584.0726, 74.1617, 250.3736)},
                    {label = locale('hospital'), coords = vec4(331.7536, -595.5214, 43.2840, 69.4922)},
                }
            },
            {
                coords = vec3(338.27, -583.74, 74.30),
                floors = {
                    {label = locale('hospital'), coords = vec4(331.7536, -595.5214, 43.2840, 69.4922)},
                    {label = locale('garage'), coords = vec4(339.9623, -584.7045, 28.7968, 70.3155)},
                }
            }
        },
    }
}
