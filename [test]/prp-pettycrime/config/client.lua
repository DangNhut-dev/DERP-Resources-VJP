
Config = {}
Config.Debug = false

Config.PickPocket = {
    targetDistance = 10.0
}

Config.ParkingMeters = {
    targetDistance = 3.0,
    zones = {
        {
            coords = vector3(269.71, -963.33, 28.27),
            radius = 150.0,
        }
    }
}

Config.LetterBoxes = {
    targetDistance = 3.0,
    zones = {
        {
            coords = vec3(1053.63, -555.17, 58.94),
            radius = 280.0,
        }
    }
}

Config.PostBoxes = {
    targetDistance = 3.0,
    zones = {
        {
            coords = vector3(-20.47, -881.44, 32.07),
            radius = 450.0,
        }
    }
}

Config.GlitterBomb = {
    disarming = {
        jobRequired = true,
        jobs = {
            {
                id = "police",
                duty = true,
                minGrade = 0
            }
        }
    },
}
