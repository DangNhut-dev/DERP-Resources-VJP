Config = {}

Config.Benches = {
    ["balocrafting"] = {
        label = "Bàn Chế Tạo Balo",
        object = `prop_tool_bench02`,
        coords = vector3(713.77, -963.09, 29.40),
        heading = 270.10,

        recipes = {
            ["cloth"] = {
                id = 1,
                time = 2000,
                amount = 2,
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
                customImage = "https://newscity.top/fivem/items101/balo_1_0_0.png",
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
                customImage = "https://newscity.top/fivem/items101/balo_1_0_1.png",
            },
        }
    },
}