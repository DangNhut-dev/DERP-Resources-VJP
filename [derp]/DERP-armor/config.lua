Config = {}

Config.ArmorPlates = {
    criminal = {
        item = "armor_plate1",
        armorIncrease = 35,
        maxArmor = 70,
        useTime = 5000,
        jobs = nil
    },
    police = {
        item = "armor_plate2",
        armorIncrease = 35,
        maxArmor = 100,
        useTime = 3000,
        jobs = {
            ["police"] = true
        }
    }
}

Config.RequiredVest = "armor_vest"