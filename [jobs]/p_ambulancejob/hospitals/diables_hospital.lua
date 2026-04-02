-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--      Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================



return {
    Hospital = {
        ['diables_hospital'] = {
            jobs = {'ambulance'}, -- which jobs are allowed to use this hospital
            blip = {
                enabled = true,
                name = locale('hospital'),
                sprite = 61, 
                scale = 0.9,
                color = 25, 
                coords = vec3(306.08, -585.09, 43.27),
            },
            duty = {
                enabled = true,
                coords = vec4(300.41, -597.82, 43.27, 341.3),
                ped = 's_m_m_paramedic_01',
                anim = {dict = 'missfam4', clip = 'base', flag = 1},
                prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)}
            },
            wardrobe = vec3(312.05, -589.55, 38.7),
            management = {
                coords = vec3(310.83, -569.48, 43.2), -- coords of boss menu [script will open your boss menu!]
                allowedGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10} -- which job grades are allowed to use management menu
            }, 
        },
    },

    TV = {
        ['diables_hospital'] = {
            ['Entrance TV'] = {
                coords = vec3(301.4, -592.05, 44.3),
                rot = vec3(7.00, 0.00, 160.00)
            },
        },
    },

    CheckIn = {
        ['diables_hospital'] = {
            label = 'Pillbox Hospital',
            coords = vec4(302.04, -591.16, 43.27, 344.27),
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
        ['diables_hospital'] = {
            vec4(311.88, -586.66, 44.18, 65.67),
        },
    },

    Insurances = {
        ['diables_hospital'] = {
            coords = vec4(307.88, -592.16, 43.27, 74.32),
            ped = 's_m_m_doctor_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
        },
    },

    Shops = {
        ['diables_hospital'] = {
            label = 'Hospital Cabinet',
            blip = {name = locale('cabinet'), sprite = 59, scale = 0.85, color = 25},
            coords = vec4(306.36, -572.05, 43.27, 341.53),
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
        ['diables_hospital_pharmacy'] = {
            label = 'Hospital Pharmacy',
            blip = {name = locale('pharmacy'), sprite = 403, scale = 0.85, color = 69},
            coords = vec4(324.33, -583.77, 43.27, 161.95),
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
        ['diables_hospital'] = {
            blip = {sprite = 225, color = 1, scale = 0.8, label = locale('garage')},
            coords = vec4(341.49, -571.87, 28.72, 69.62),
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
                vec4(336.86, -573.92, 28.05, 69.16),
                vec4(335.25, -577.47, 28.05, 71.33),
                vec4(322.70, -572.94, 28.05, 250.66),
                vec4(324.26, -569.63, 28.05, 249.94)
            }
        },
        ['diables_hospital_heli'] = {
            blip = {sprite = 759, color = 1, scale = 0.8, label = locale('helipad')},
            coords = vec4(337.43, -586.70, 74.16, 252.75),
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
                vec4(351.76, -588.10, 74.16, 281.28),
            }
        },
    },

    Elevators = {
        ['diables_hospital'] = {
            {
                coords = vec3(327.62, -578.56, 74.15), --roof
                jobRestricted = true,
                floors = {
                    {label = locale('3rd Floor'), coords = vec4(327.47, -569.99, 48.21, 157.73)},
                    {label = locale('First Floor'), coords = vec4(316.90, -596.08, 38.33, 334.72)},
                    {label = locale('garage'), coords = vec4(323.96, -581.82, 28.72, 341.98)},
                }
            },
            {
                coords = vec3(326.55, -570.01, 48.21), --3rd floor 
                floors = {
                    {label = locale('First Floor'), coords = vec4(316.90, -596.08, 38.33, 334.72)},
                    {label = locale('roof'), coords = vec4(326.97, -579.80, 74.15, 250.28)},
                    {label = locale('garage'), coords = vec4(323.96, -581.82, 28.72, 341.98)},
                }
            },
            {
                coords = vec3(318.10, -595.85, 38.33), --first floor
                floors = {
                    {label = locale('3rd Floor'), coords = vec4(327.47, -569.99, 48.21, 157.73)},
                    {label = locale('roof'), coords = vec4(326.97, -579.80, 74.15, 250.28)},
                    {label = locale('garage'), coords = vec4(323.96, -581.82, 28.72, 341.98)},
                }
            },
            {
                coords = vec3(322.75, -581.44, 28.72), --garage
                floors = {
                    {label = locale('3rd Floor'), coords = vec4(327.47, -569.99, 48.21, 157.73)},
                    {label = locale('First Floor'), coords = vec4(316.90, -596.08, 38.33, 334.72)},
                    {label = locale('roof'), coords = vec4(326.97, -579.80, 74.15, 250.28)},
                }
            },
            {
                coords = vec3(341.89, -594.31, 28.81), --ground reception
                floors = {
                    {label = locale('3rd Floor'), coords = vec4(327.47, -569.99, 48.21, 157.73)},
                    {label = locale('First Floor'), coords = vec4(316.90, -596.08, 38.33, 334.72)},
                    {label = locale('roof'), coords = vec4(326.97, -579.80, 74.15, 250.28)},
                }
            }
        }
    }
}
