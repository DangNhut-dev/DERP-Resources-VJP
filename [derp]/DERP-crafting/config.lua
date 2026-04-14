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
                    ["iron"] = 50,
                    ["metalscrap"] = 15,
                }
            },
        }
    },
}