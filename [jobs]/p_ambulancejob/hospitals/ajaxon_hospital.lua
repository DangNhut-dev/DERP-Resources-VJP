-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================




return {
    Hospital = {
        ['ajaxon_hospital'] = {
            jobs = {'ambulance'}, -- which jobs are allowed to use this hospital
            blip = {
                enabled = true,
                name = locale('hospital'),
                sprite = 61, 
                scale = 0.9,
                color = 25, 
                coords = vec3(-492.5157, -977.8770, 23.7272),
            },
            duty = {
                enabled = true,
                coords = vec3(-488.40, -989.31, 24.38),
            -- ped = 's_m_m_paramedic_01',
            -- anim = {dict = 'missfam4', clip = 'base', flag = 1},
            -- prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)}
            },
            wardrobe = vec3(-483.62, -992.04, 24.17),
            management = {
                coords = vec3(-485.00, -1003.49, 100.49), -- coords of boss menu [script will open your boss menu!]
                allowedGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10} -- which job grades are allowed to use management menu
            }, 
        },
    },

    TV = {
        ['ajaxon_hospital'] = {
            ['Entrance TV'] = {
                coords = vec3(-497.52, -983.62, 24.75),
                rot = vec3(-1.00, 0.00, 1.00)
            },
        },
    },

    CheckIn = {
        ['ajaxon_hospital'] = {
            label = 'Little Seul Hospital',
            coords = vec4(-487.55, -987.59, 24.29, 88.31),
            driveCoords = vec4(-493.5232, -977.8796, 23.7192, 8.5150), -- optional, if you want ai medic to drive to specific coords before going to bed
            ped = 's_m_m_doctor_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
            duration = 15000,
            maxDutyMedics = 2,
            price = {
                money = 500, -- price in cash
                bank = 500, -- price in bank
                -- black_money = 500, -- price in black money [if you want to disable some payment method, just remove it from table]
                insurance = true, -- can be used insurance for check-in? [only will work if player own insurance]
            }
        },
    },

    CheckInBeds = {
        ['ajaxon_hospital'] = {
            vec4(-458.83, -1024.06, 34.60, 179.92),
            vec4(-455.00, -1024.04, 34.60, 179.35),
            vec4(-451.17, -1024.14, 34.60, 179.17),
            vec4(-447.41, -1023.91, 34.60, 179.94),
            vec4(-447.21, -1030.15, 34.60, 358.47),
            vec4(-451.14, -1030.25, 34.60, 359.01),
            vec4(-454.90, -1030.30, 34.60, 359.01),
            vec4(-458.64, -1030.19, 34.60, 356.05),
        },
    },

    Insurances = {
        ['ajaxon_hospital'] = {
            coords = vec4(-487.57, -990.30, 24.29, 89.92),
            ped = 's_m_m_doctor_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
        },
    },

    Shops = {
        -- ['ajaxon_hospital'] = {
        --     label = 'Hospital Cabinet',
        --     blip = {name = locale('cabinet'), sprite = 59, scale = 0.85, color = 25},
        --     coords = vec4(-487.41, -1010.70, 24.29, 178.61),
        --     ped = 's_m_m_paramedic_01',
        --     anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
        --     prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
        --     jobRestricted = true, -- only for jobs from Config.Hospitals?
        --     items = {
        --         {name = 'medicbag', price = 0},
        --         {name = 'ambulance_gps', price = 0},
        --         {name = 'wheelchair', price = 0},
        --         {name = 'crutch', price = 0},
        --         {name = 'stretcher', price = 0},
        --         {name = 'bodybag', price = 0},
        --         {name = 'bandage', price = 0},
        --         {name = 'icepack', price = 0},
        --         {name = 'ointment', price = 0},
        --         {name = 'defibrilator', price = 0},
        --         {name = 'splint', price = 0},
        --         {name = 'suture_kit', price = 0},
        --         {name = 'morphine', price = 0},
        --         {name = 'medical_kit', price = 0},
        --         {name = 'disinfectant', price = 0},
        --         {name = 'advanced_medical_kit', price = 0},
        --         {name = 'blood_bag_250', price = 0},
        --         {name = 'blood_bag_500', price = 0},
        --         {name = 'antipyretics', price = 0},
        --         {name = 'painkillers', price = 0},
        --         {name = 'gauze', price = 5},
        --         {name = 'adrenaline', price = 10},
        --         {name = 'cyclonamine', price = 15},
        --         {name = 'tourniquet', price = 20},
        --     }
        -- },
        -- ['ajaxon_hospital_pharmacy'] = {
        --     label = 'Hospital Pharmacy',
        --     blip = {name = locale('pharmacy'), sprite = 403, scale = 0.85, color = 69},
        --     coords = vec4(-487.84, -1005.00, 24.29, 0.00),
        --     ped = 's_m_m_paramedic_01',
        --     items = {
        --         {name = 'gauze', price = 50},
        --         {name = 'adrenaline', price = 100},
        --         {name = 'bandage', price = 200},
        --         {name = 'cyclonamine', price = 300},
        --         {name = 'tourniquet', price = 500},
        --     }
        -- },
    },

    Garages = {
        ['ajaxon_hospital'] = {
            blip = {sprite = 225, color = 1, scale = 0.8, label = locale('garage')},
            coords = vec4(-479.47, -1005.22, 24.29, 267.71),
            ped = 's_m_m_paramedic_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
            spawnInVehicle = true,
            platePrefix = 'EMS',
            parkDistance = 10.0,
            vehicles = {
                ['25fpiu1'] = {
                    label = '25fpiu1',
                    image = 'https://docs.fivem.net/vehicles/ambulance.webp',
                    mods = {
                        [0] = 1,
                    },
                    allowedGrades = {0, 1, 2, 3, 4, 5},
                }
            },
            spawnPoints = {
                vec4(-456.04, -989.32, 24.06, 180.56),
                vec4(-460.37, -989.50, 24.06, 179.21),
                vec4(-464.70, -989.40, 24.06, 178.87),
                vec4(-468.75, -989.32, 24.06, 180.22),
                -- vec4(-488.49, -1007.07, 19.69, 105.00),
            }
        },
        ['ajaxon_hospital_heli'] = {
            blip = {sprite = 759, color = 1, scale = 0.8, label = locale('helipad')},
            coords = vec4(-463.29, -1029.22, 38.28, 279.00),
            ped = 's_m_m_paramedic_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
            spawnInVehicle = true,
            platePrefix = 'EMS',
            parkDistance = 15.0,
            vehicles = {
                ['polmav'] = {
                    label = 'polmav',
                    image = 'https://docs.fivem.net/vehicles/maverick.webp',
                    mods = {
                        [0] = -1,
                    },
                    allowedGrades = {0, 1, 2, 3, 4, 5},
                }
            },
            spawnPoints = {
                vec4(-454.0706, -1029.7781, 38.3966, 269.4753)
            }
        },
    },

    Elevators = {
        ['ajaxon_hospital'] = {},
    }
}
