Config = {}

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
                ingredients = {
                    ["cotton"] = 5,
                }
            },
            ["balo_male"] = {
                id = 2,
                time = 10000,
                amount = 1,
                allowQuantity = false,
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
        object = `prop_tool_bench02`,
        coords = vector3(1493.39, -2118.47, 74.89),
        heading = 266.74,

        recipes = {
            ["radio"] = {
                id = 1,
                time = 3000,
                amount = 1,
                allowQuantity = false,
                ingredients = {
                    ["aluminum"] = 10,
                    ["copper"] = 5,
                    ["circuit"] = 1,
                }
            },
            ["hack_laptop"] = {
                id = 1,
                time = 3000,
                amount = 1,
                allowQuantity = false,
                ingredients = {
                    ["iron"] = 15,
                    ["copper"] = 10,
                    ["circuit"] = 5,
                }
            },
        }
    },
    ["craftingarmor"] = {
        label = "Bàn Chế Tạo",
        object = `prop_tool_bench02`,
        coords = vector3(579.69, -3110.16, 5.07),
        heading = 270.18,

        recipes = {
            ["armor_plate1"] = {
                id = 1,
                time = 3000,
                amount = 1,
                allowQuantity = false,
                ingredients = {
                    ["cloth"] = 10,
                    ["carbon"] = 25,
                }
            },
        }
    },
    ["craftingweed"] = {
        label = "Bàn Chế Tạo",
        object = `prop_tool_bench02`,
        coords = vector3(-508.95, -1631.24, 16.80),
        heading = 148.16,

        recipes = {
            ["drying_rack"] = {
                id = 1,
                time = 3000,
                amount = 1,
                allowQuantity = false,
                ingredients = {
                    ["finishwood"] = 25,
                    ["iron"] = 25,
                    ["metalscrap"] = 10,
                }
            },
            ["infusion_table"] = {
                id = 2,
                time = 3000,
                amount = 1,
                allowQuantity = false,
                ingredients = {
                    ["finishwood"] = 25,
                    ["iron"] = 25,
                    ["metalscrap"] = 10,
                }
            },
        }
    },
    ["craftingweed2"] = {
        label = "Bàn Chế Tạo",
        object = `prop_tool_bench02`,
        coords = vector3(1216.37, 1892.68, 76.97),
        heading = 124.45,

        recipes = {
            ["uv_lamp"] = {
                id = 1,
                time = 3000,
                amount = 1,
                allowQuantity = false,
                ingredients = {
                    ["glass"] = 1,
                    ["metalscrap"] = 2,
                }
            },
        }
    },
    ["craftinglockpick"] = {
        label = "Bàn Chế Tạo",
        object = `prop_tool_bench02`,
        coords = vector3(493.06, -583.07, 23.71),
        heading = 349.33,

        recipes = {
            ["lockpick"] = {
                id = 1,
                time = 2000,
                amount = 1,
                allowQuantity = true,
                ingredients = {
                    ["iron"] = 5,
                }
            },
        }
    },
    ["washingmoney"] = {
        label = "Rửa Tiền",
        object = `v_ind_cs_hammer`,
        coords = vector3(1400.00, 1155.06, 108.28),
        heading = 218.87,

        recipes = {
            ["cash"] = {
                id = 1,
                time = 1000,
                amount = 150,
                allowQuantity = true,
                ingredients = {
                    ["black_money"] = 1,
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
                ingredients = {
                    ["rubber"] = 8,
                    ["steel"] = 3,
                }
            },

            ["clutch_replacement"] = {
                id = 6,
                time = 3500,
                amount = 1,
                quality = nil,
                allowQuantity = false,
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
                ingredients = {
                    ["plastic"] = 5,
                    ["cloth"] = 3, -- nếu có
                }
            },

            ["spark_plug"] = {
                id = 8,
                time = 2000,
                amount = 1,
                quality = nil,
                allowQuantity = false,
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
                ingredients = {
                    ["steel"] = 4,
                    ["rubber"] = 4,
                }
            },

            -- ================= EV PARTS (HI-END) =================

            ["ev_motor"] = {
                id = 11,
                time = 6000,
                amount = 1,
                quality = nil,
                allowQuantity = false,
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