-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================



return {
    Hospital = {
        ['kiiya_hospital'] = {
            jobs = {'ambulance'}, -- which jobs are allowed to use this hospital
            blip = {
                enabled = true,
                name = locale('hospital'),
                sprite = 61, 
                scale = 0.9,
                color = 25, 
                coords = vec3(298.20, -584.56, 42.26)
            },
            duty = {
                enabled = true,
                coords = vec4(317.65, -582.11, 43.06, 0.0),
            -- ped = 's_m_m_paramedic_01',
            -- anim = {dict = 'missfam4', clip = 'base', flag = 1},
            -- prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)}
            },
            wardrobe = vec3(318.69, -600.69, 43.31),
            management = {
                coords = vec3(312.07, -562.62, 43.06), -- coords of boss menu [script will open your boss menu!]
                allowedGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10} -- which job grades are allowed to use management menu
            }, 
        },
    },

    TV = {
        ['kiiya_hospital'] = {
            ['Entrance TV'] = {
                coords = vec3(301.283, -582.483, 44.518),
                rot = vec3(8.231, 0.000, 47.436),
            },
        },
    },

    CheckIn = {
        ['kiiya_hospital'] = {
            label = 'Pillbox Hospital',
            coords = vec4(311.22, -582.14, 43.27, 74.00),
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
        ['kiiya_hospital'] = {
            vec4(338.35, -595.38, 42.94, 344.00),
            vec4(341.93, -596.69, 42.94, 346.00),
            vec4(335.01, -594.16, 42.94, 0.00),
            vec4(331.22, -592.89, 42.94, 0.00),
            vec4(332.52, -589.49, 42.94, 256.00),
            vec4(343.16, -593.55, 42.95, 81.00),
            vec4(344.28, -590.33, 42.94, 77.00),
        },
    },

    Insurances = {
        ['kiiya_hospital'] = {
            coords = vec4(314.5467, -586.1916, 43.2710, 161.7225),
            ped = 's_m_m_doctor_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
        },
    },

    Shops = {
        ['kiiya_hospital'] = {
            label = 'Hospital Cabinet',
            blip = {name = locale('cabinet'), sprite = 59, scale = 0.85, color = 25},
            coords = vec4(316.85, -597.72, 43.26, 254.00),
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
        ['kiiya_hospital_pharmacy'] = {
            label = 'Hospital Pharmacy',
            blip = {name = locale('pharmacy'), sprite = 403, scale = 0.85, color = 69},
            coords = vec4(298.30, -598.00, 43.26, 337.00),
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
        ['kiiya_hospital'] = {
            blip = {sprite = 225, color = 1, scale = 0.8, label = locale('garage')},
            coords = vec4(333.8549, -580.6429, 28.7892, 341.3111),
            ped = 's_m_m_paramedic_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
            spawnInVehicle = true,
            platePrefix = 'EMS',
            parkDistance = 10.0,
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
                vec4(342.3798, -579.6738, 28.7422, 68.7208),
                vec4(343.5714, -576.2437, 28.7422, 68.9288),
                vec4(344.5694, -573.1098, 28.7422, 70.2456),
                vec4(345.5736, -569.7852, 28.7421, 67.3322)
            }
        },
        ['kiiya_hospital_heli'] = {
            blip = {sprite = 759, color = 1, scale = 0.8, label = locale('helipad')},
            coords = vec4(337.58, -586.89, 74.16, 251.00),
            ped = 's_m_m_paramedic_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
            spawnInVehicle = true,
            platePrefix = 'EMS',
            parkDistance = 15.0,
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
        ['kiiya_hospital'] = {
            {
                coords = vec3(327.93, -569.52, 43.60),
                jobRestricted = true,
                floors = {
                    {label = locale('roof'), coords = vec4(327.92, -574.99, 73.16, 159.00)},
                    {label = locale('garage'), coords = vec4(314.4622, -562.1915, 28.7803, 162.5392)},
                }
            },
            {
                coords = vec3(326.38, -576.09, 74.54),
                floors = {
                    {label = locale('hospital'), coords = vec4(329.4640, -568.4213, 43.2612, 158.0979)},
                    {label = locale('garage'), coords = vec4(314.4622, -562.1915, 28.7803, 162.5392)},
                }
            },
            {
                coords = vec3(313.07, -563.18, 29.13),
                floors = {
                    {label = locale('hospital'), coords = vec4(329.4640, -568.4213, 43.2612, 158.0979)},
                    {label = locale('roof'), coords = vec4(327.92, -574.99, 73.16, 159.00)},
                }
            }
        },
    }
}