Config = {}

-- EXP cần để đạt level tương ứng
Config.Levels = {
    [1] = 0,
    [2] = 5,
    [3] = 100,
    [4] = 500,
    [5] = 1000,
    [6] = 2000,
    [7] = 4000,
    [8] = 8000,
    [9] = 16000,
    [10] = 32000,
}

Config.Benches = {
    ["balocrafting"] = {
        label = "Bàn Chế Tạo",
        object = `prop_tool_bench02`,
        coords = vector3(713.77, -963.09, 29.40),
        heading = 270.10,

        recipes = {
            ["cloth"] = {
                id = 1,
                time = 2000,
                amount = 1,
                allowQuantity = true,
                requiredLevel = 1,
                expReward = 0,
                ingredients = {
                    ["cotton"] = 5,
                }
            },
            ["balo_male"] = {
                id = 2,
                time = 10000,
                amount = 1,
                allowQuantity = false,
                requiredLevel = 1,
                expReward = 0,
                ingredients = {
                    ["hide_3star"] = 15,
                    ["cloth"] = 30,
                },
                craftItem = "balo",
                craftMeta = {
                    drawableId = 1,
                    textureId = 0,
                    gender = 0,
                    level = 0,
                },
                customLabel = "Ba lô (Nam)",
                customImage = "https://gta5root.top/fivem/items101/balo_1_0_0.png",
            },
            ["balo_female"] = {
                id = 3,
                time = 10000,
                amount = 1,
                allowQuantity = false,
                requiredLevel = 1,
                expReward = 0,
                ingredients = {
                    ["hide_3star"] = 15,
                    ["cloth"] = 30,
                },
                craftItem = "balo",
                craftMeta = {
                    drawableId = 1,
                    textureId = 0,
                    gender = 1,
                    level = 0,
                },
                customLabel = "Ba lô (Nữ)",
                customImage = "https://gta5root.top/fivem/items101/balo_1_0_1.png",
            },
        }
    },
    
    ["craftingdevice"] = {
        label = "Bàn Chế Tạo",
        object = `prop_toolchest_04`,
        coords = vector3(1507.91, -2120.41, 75.56 ),
        heading = 90.83,

        recipes = {
            ["WEAPON_SLEDGEHAMMER"] = {
                id = 1,
                time = 3000,
                amount = 1,
                allowQuantity = false,
                requiredLevel = 1,
                expReward = 1,
                ingredients = {
                    ["iron"] = 1,
                    -- ["rubber"] = 25,
                    -- ["aluminum"] = 10,
                }
            },
            ["WEAPON_KATANA"] = {
                id = 2,
                time = 3000,
                amount = 1,
                allowQuantity = false,
                requiredLevel = 2,
                expReward = 0,
                ingredients = {
                    ["iron"] = 1,
                    -- ["aluminum"] = 15,
                }
            },
            ["WEAPON_CHAIR"] = {
                id = 3,
                time = 3000,
                amount = 1,
                allowQuantity = false,
                requiredLevel = 2,
                expReward = 0,
                ingredients = {
                    ["iron"] = 1,
                    -- ["aluminum"] = 50,
                }
            },
            ["WEAPON_P30L"] = {
                id = 4,
                time = 3000,
                amount = 1,
                allowQuantity = false,
                requiredLevel = 2,
                expReward = 5,
                limit = true,
                ingredients = {
                    ["iron"] = 1,
                    -- ["banvesung"] = 1,
                    -- ["banhrang"] = 1,
                    -- ["refined_metal"] = 1,
                }
            },
            ["WEAPON_P210"] = {
                id = 5,
                time = 3000,
                amount = 1,
                allowQuantity = false,
                requiredLevel = 3,
                expReward = 10,
                limit = true,
                ingredients = {
                    ["iron"] = 1,
                    -- ["banvesung"] = 1,
                    -- ["banhrang"] = 1,
                    -- ["refined_metal"] = 1,
                }
            },
            ["WEAPON_SR40"] = {
                id = 6,
                time = 3000,
                amount = 1,
                allowQuantity = false,
                requiredLevel = 4,
                expReward = 20,
                limit = true,
                ingredients = {
                    ["iron"] = 1,
                    -- ["banvesung"] = 1,
                    -- ["banhrang"] = 1,
                    -- ["refined_metal"] = 1,
                }
            },
            ["WEAPON_MGGLOCK"] = {
                id = 7,
                time = 3000,
                amount = 1,
                allowQuantity = false,
                requiredLevel = 4,
                expReward = 20,
                limit = true,
                ingredients = {
                    ["iron"] = 1,
                    -- ["banvesung"] = 1,
                    -- ["banhrang"] = 1,
                    -- ["refined_metal"] = 1,
                }
            },
            
        }
    },
    ["craftingarmor"] = {
        label = "Bàn Chế Tạo",
        object = `prop_toolchest_05`,
        coords = vector3(871.97, -1347.18, 25.31),
        heading = 0.931,

        recipes = {
            ["armor_plate1"] = {
                id = 1,
                time = 3000,
                amount = 1,
                allowQuantity = false,
                requiredLevel = 1,
                expReward = 0,
                ingredients = {
                    ["cloth"] = 25,
                    ["carbon"] = 15,
                }
            },
            ["ammo-9"] = {
                id = 2,
                time = 500,
                amount = 5,
                allowQuantity = true,
                requiredLevel = 1,
                expReward = 0,
                ingredients = {
                    ["refined_metal"] = 1,
                    ["gunpowder"] = 3,
                }
            },
        }
    },
    ["craftingweed"] = {
        label = "Bàn Chế Tạo",
        object = `prop_tool_bench02`,
        coords = vector3(1443.55, 6334.64, 22.78),
        heading = 267.88,

        recipes = {
            ["drying_rack"] = {
                id = 1,
                time = 3000,
                amount = 1,
                allowQuantity = false,
                requiredLevel = 1,
                expReward = 0,
                ingredients = {
                    ["finishwood"] = 50,
                    ["iron"] = 30,
                    ["metalscrap"] = 30,
                }
            },
            ["infusion_table"] = {
                id = 2,
                time = 3000,
                amount = 1,
                allowQuantity = false,
                requiredLevel = 1,
                expReward = 0,
                ingredients = {
                    ["finishwood"] = 50,
                    ["iron"] = 30,
                    ["metalscrap"] = 30,
                }
            },
            ["uv_lamp"] = {
                id = 1,
                time = 3000,
                amount = 1,
                allowQuantity = false,
                requiredLevel = 1,
                expReward = 0,
                ingredients = {
                    ["glass"] = 5,
                    ["metalscrap"] = 5,
                }
            },
        }
    },
    ["craftinglockpick"] = {
        label = "Bàn Chế Tạo",
        object = `prop_tool_bench02`,
        coords = vector3(372.24, -317.92, 45.76),
        heading = 161.27,

        recipes = {
            ["advancedlockpick"] = {
                id = 1,
                time = 2000,
                amount = 1,
                allowQuantity = true,
                requiredLevel = 1,
                expReward = 0,
                ingredients = {
                    ["banhrang"] = 3,
                }
            },
        }
    },
    ["mechanic_1"] = {
        label = "Bàn Chế Tạo",
        object = `prop_tool_bench02`,
        coords = vector3(-348.26, -162.68, 37.99),
        heading = 122.75,

        recipes = {
            ["repair_kit"] = {
                id = 1,
                time = 4000,
                amount = 1,
                quality = nil,
                allowQuantity = false,
                requiredLevel = 1,
                expReward = 0,
                ingredients = {
                    ["steel"] = 6,
                    ["aluminum"] = 6,
                    ["plastic"] = 3,
                }
            },
            ["duct_tape"] = {
                id = 2,
                time = 1500,
                amount = 1,
                quality = nil,
                allowQuantity = false,
                requiredLevel = 1,
                expReward = 0,
                ingredients = {
                    ["rubber"] = 4,
                    ["plastic"] = 3,
                }
            },
            ["engine_oil"] = {
                id = 4,
                time = 2500,
                amount = 1,
                quality = nil,
                allowQuantity = false,
                requiredLevel = 1,
                expReward = 0,
                ingredients = {
                    ["plastic"] = 4,
                    ["rubber"] = 2,
                }
            },
            ["tyre_replacement"] = {
                id = 5,
                time = 3500,
                amount = 1,
                quality = nil,
                allowQuantity = false,
                requiredLevel = 1,
                expReward = 0,
                ingredients = {
                    ["rubber"] = 2,
                    ["steel"] = 1,
                }
            },
            ["clutch_replacement"] = {
                id = 6,
                time = 3500,
                amount = 1,
                quality = nil,
                allowQuantity = false,
                requiredLevel = 1,
                expReward = 0,
                ingredients = {
                    ["steel"] = 5,
                    ["copper"] = 2,
                    ["plastic"] = 3,
                }
            },
            ["air_filter"] = {
                id = 7,
                time = 2500,
                amount = 1,
                quality = nil,
                allowQuantity = false,
                requiredLevel = 1,
                expReward = 0,
                ingredients = {
                    ["plastic"] = 3,
                    ["cloth"] = 1,
                }
            },
            ["spark_plug"] = {
                id = 8,
                time = 2000,
                amount = 1,
                quality = nil,
                allowQuantity = false,
                requiredLevel = 1,
                expReward = 0,
                ingredients = {
                    ["copper"] = 4,
                    ["iron"] = 2,
                }
            },
            ["suspension_parts"] = {
                id = 9,
                time = 4000,
                amount = 1,
                quality = nil,
                allowQuantity = false,
                requiredLevel = 1,
                expReward = 0,
                ingredients = {
                    ["steel"] = 6,
                    ["rubber"] = 4,
                }
            },
            ["brakepad_replacement"] = {
                id = 10,
                time = 3000,
                amount = 1,
                quality = nil,
                allowQuantity = false,
                requiredLevel = 1,
                expReward = 0,
                ingredients = {
                    ["steel"] = 4,
                    ["rubber"] = 4,
                }
            },
            ["ev_motor"] = {
                id = 11,
                time = 6000,
                amount = 1,
                quality = nil,
                allowQuantity = false,
                requiredLevel = 1,
                expReward = 0,
                ingredients = {
                    ["copper"] = 12,
                    ["steel"] = 6,
                    ["aluminum"] = 8,
                }
            },
            ["ev_battery"] = {
                id = 12,
                time = 6500,
                amount = 1,
                quality = nil,
                allowQuantity = false,
                requiredLevel = 1,
                expReward = 0,
                ingredients = {
                    ["copper"] = 10,
                    ["aluminum"] = 10,
                    ["plastic"] = 5,
                }
            },
            ["ev_coolant"] = {
                id = 13,
                time = 4000,
                amount = 1,
                quality = nil,
                allowQuantity = false,
                requiredLevel = 1,
                expReward = 0,
                ingredients = {
                    ["plastic"] = 6,
                    ["aluminum"] = 4,
                }
            },
        },
        jobs = {
            ["mechanic"] = 2,
        },
    },

    -- ["redlinecustom_1"] = {
    --     label = "Bàn Chế Tạo",
    --     object = `v_ind_cs_hammer`,
    --     coords = vector3(-584.07, -939.55, 23.7),
    --     heading = 80.4,

    --     recipes = {
    --         ["i4_engine"] = {
    --             id = 1, time = 2000, amount = 1, allowQuantity = false,
    --             ingredients = {
    --                 iron = 6, aluminum = 8, steel = 7, copper = 4
    --             }
    --         },

    --         ["v6_engine"] = {
    --             id = 2, time = 2000,
    --             ingredients = {
    --                 iron = 8, aluminum = 10, steel = 8, copper = 5
    --             }
    --         },

    --         ["turbocharger"] = {
    --             id = 3, time = 2000,
    --             ingredients = {
    --                 steel = 6, aluminum = 5, copper = 4, plastic = 2
    --             }
    --         },

    --         ["awd_drivetrain"] = {
    --             id = 4, time = 2000,
    --             ingredients = {
    --                 iron = 6, steel = 6, aluminum = 5, copper = 3
    --             }
    --         },

    --         ["rwd_drivetrain"] = {
    --             id = 5, time = 2000,
    --             ingredients = {
    --                 iron = 5, steel = 5, aluminum = 4, copper = 3
    --             }
    --         },

    --         ["fwd_drivetrain"] = {
    --             id = 6, time = 2000,
    --             ingredients = {
    --                 iron = 4, steel = 5, aluminum = 4
    --             }
    --         },

    --         -- Cosmetic Parts
    --         ["cosmetic_part"] = {
    --             id = 7, time = 2000,
    --             ingredients = {
    --                 plastic = 8, cloth = 4, glass = 3
    --             }
    --         },

    --         ["performance_part"] = {
    --             id = 8, time = 2000,
    --             ingredients = {
    --                 steel = 5, aluminum = 5, plastic = 3, copper = 2
    --             }
    --         },

    --         ["respray_kit"] = {
    --             id = 9, time = 2000,
    --             ingredients = {
    --                 plastic = 5, glass = 4, cloth = 2
    --             }
    --         },

    --         ["vehicle_wheels"] = {
    --             id = 10, time = 2000,
    --             ingredients = {
    --                 steel = 5, rubber = 6, plastic = 3
    --             }
    --         },

    --         ["tyre_smoke_kit"] = {
    --             id = 11, time = 2000,
    --             ingredients = {
    --                 plastic = 3, rubber = 4, glass = 1
    --             }
    --         },

    --         ["extras_kit"] = {
    --             id = 12, time = 2000,
    --             ingredients = {
    --                 plastic = 4, cloth = 3, steel = 2
    --             }
    --         },

    --         ["manual_gearbox"] = {
    --             id = 13, time = 2000,
    --             ingredients = {
    --                 steel = 6, iron = 5, aluminum = 4, copper = 3
    --             }
    --         },

    --         ["cleaning_kit"] = {
    --             id = 14, time = 2000,
    --             ingredients = {
    --                 cloth = 6, plastic = 3, glass = 2
    --             }
    --         },

    --         ["stancing_kit"] = {
    --             id = 15, time = 2000,
    --             ingredients = {
    --                 steel = 5, aluminum = 4, rubber = 4
    --             }
    --         },

    --         ["slick_tyres"] = {
    --             id = 16, time = 2000,
    --             ingredients = {
    --                 rubber = 10, plastic = 4, steel = 3
    --             }
    --         },

    --         ["semi_slick_tyres"] = {
    --             id = 17, time = 2000,
    --             ingredients = {
    --                 rubber = 8, plastic = 3, steel = 3
    --             }
    --         },

    --         ["offroad_tyres"] = {
    --             id = 18, time = 2000,
    --             ingredients = {
    --                 rubber = 12, steel = 4, plastic = 4
    --             }
    --         },

    --         ["ceramic_brakes"] = {
    --             id = 19, time = 2000,
    --             ingredients = {
    --                 steel = 6, aluminum = 4, copper = 3
    --             }
    --         },

    --         ["drift_tuning_kit"] = {
    --             id = 20, time = 2000,
    --             ingredients = {
    --                 steel = 5, rubber = 5, aluminum = 4, plastic = 2
    --             }
    --         }
    --     },
    --     jobs = {
    --          ["redlinecustom"] = 2,
                
    --     },
    -- },
}