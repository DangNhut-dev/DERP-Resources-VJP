-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================




return {
    Hospital = {
        ['kiiya_emt_hospital'] = {
            jobs = {'ambulance'}, -- which jobs are allowed to use this hospital
            blip = {
                enabled = true,
                name = locale('hospital'),
                sprite = 61, 
                scale = 0.9,
                color = 25, 
                coords = vec3(-677.03, 308.14, 82.08),
            },
            duty = {
                enabled = true,
                coords = vec4(-674.47, 330.18, 83.02, 0.0),
            -- ped = 's_m_m_paramedic_01',
            -- anim = {dict = 'missfam4', clip = 'base', flag = 1},
            -- prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)}
            },
            wardrobe = vec3(-666.11, 344.08, 83.14),
            management = {
                coords = vec3(-666.32, 348.12, 82.97), -- coords of boss menu [script will open your boss menu!]
                allowedGrades = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10} -- which job grades are allowed to use management menu
            }, 
        },
    },

    TV = {
        ['kiiya_emt_hospital'] = {
            ['Entrance TV'] = {
                coords = vec3(-670.42, 316.27, 83.48),
                rot = vec3(9.00, 0.00, -127.00),
            },
        },
    },

    CheckIn = {
        ['kiiya_emt_hospital'] = {
            label = 'Eclipse Hospital',
            coords = vec4(-676.80, 329.08, 83.08, 172.00),
            driveCoords = vec4(-677.64, 293.92, 81.08, 0.0), -- optional, if you want ai medic to drive to specific coords before going to bed
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
        ['kiiya_emt_hospital'] = {
            vec4(-662.27, 360.03, 83.77, 178.00),
            vec4(-659.22, 359.78, 83.77, 176.00),
            vec4(-656.14, 359.46, 83.77, 186.00),
            vec4(-653.12, 359.18, 83.76, 179.00),
        },
    },

    Insurances = {
        ['kiiya_emt_hospital'] = {
            coords = vec4(-673.75, 328.95, 83.08, 170.00),
            ped = 's_m_m_doctor_01',
            anim = {dict = 'amb@world_human_clipboard@male@idle_a', clip = 'idle_a', flag = 1},
            prop = {model = 'p_amb_clipboard_01', bone = 36029, coords = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0)},
        },
    },

    Shops = {
        ['kiiya_emt_hospital'] = {
            label = 'Hospital Cabinet',
            blip = {name = locale('cabinet'), sprite = 59, scale = 0.85, color = 25},
            coords = vec4(-674.82, 335.02, 83.08, 187.00),
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
        ['kiiya_emt_hospital_pharmacy'] = {
            label = 'Hospital Pharmacy',
            blip = {name = locale('pharmacy'), sprite = 403, scale = 0.85, color = 69},
            coords = vec4(-663.96, 321.77, 83.08, 184.00),
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
        ['kiiya_emt_hospital'] = {
            blip = {sprite = 225, color = 1, scale = 0.8, label = locale('garage')},
            coords = vec4(-690.32, 342.95, 77.71, 268.00),
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
                vec4(-688.16, 336.61, 77.71, 0.00),
                vec4(-683.91, 336.19, 77.71, 0.00),
                vec4(-679.67, 335.68, 77.71, 0.00),
                vec4(-675.53, 335.49, 77.71, 0.00),
                vec4(-671.33, 335.00, 77.71, 0.00),
                vec4(-667.20, 334.60, 77.71, 0.00),
            }
        },
        ['kiiya_emt_hospital_heli'] = {
            blip = {sprite = 759, color = 1, scale = 0.8, label = locale('helipad')},
            coords = vec4(-654.37, 317.60, 141.96, 277.00),
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
                vec4(-646.99, 318.95, 141.96, 0.00),
            }
        },
    },

    Elevators = {
        ['kiiya_emt_hospital'] = {
            {
                coords = vec3(-670.74, 360.13, 83.23),
                jobRestricted = true,
                floors = {
                    {label = locale('roof'), coords = vec4(-670.86, 323.27, 140.12, 188.00)},
                    {label = locale('garage'), coords = vec4(-670.42, 362.30, 77.77, 189.00)},
                }
            },
            {
                coords = vec3(-670.83, 323.88, 140.24),
                floors = {
                    {label = locale('hospital'), coords = vec4(-670.54, 362.08, 83.08, 184.00)},
                    {label = locale('garage'), coords = vec4(-670.46, 362.24, 77.77, 187.00)},
                }
            },
            {
                coords = vec3(-669.58, 360.49, 78.14),
                floors = {
                    {label = locale('hospital'), coords = vec4(-670.54, 362.08, 83.08, 184.00)},
                    {label = locale('roof'), coords = vec4(-670.42, 362.30, 77.77, 189.00)},
                }
            }
        },
    }
}