Config = {}

Config.MinimumCops = 0
Config.RequireItem  = true  
Config.RequiredItem = 'hack_laptop'

Config.Cooldown = 60 * 60 * 1000

Config.Safes = {
    [1]  = { coords = vec3(-709.74,  -904.15,  19.21),   type = 'keypad'  },
    [2]  = { coords = vec3(28.15,   -1339.23,  29.5),    type = 'keypad'  },
    [3]  = { coords = vec3(1159.46,  -314.05,  69.2),    type = 'keypad'  },
    [4]  = { coords = vec3(378.11,    333.36,  103.57),  type = 'keypad'  },
    [5]  = { coords = vec3(-1829.27,  798.76,  138.19),  type = 'keypad'  },
    [6]  = { coords = vec3(2549.33,   384.88,  108.62),  type = 'keypad'  },
    [7]  = { coords = vec3(2672.69,  3286.63,  55.24),   type = 'keypad'  },
    [8]  = { coords = vec3(1959.21,  3748.83,  32.34),   type = 'keypad'  },
    [9] = { coords = vec3(546.56,   2662.8,   42.16),   type = 'keypad'  },
    [10] = { coords = vec3(1734.74,  6420.83,  35.04),   type = 'keypad'  },
    [11] = { coords = vec3(1707.9,   4920.49,  42.06),   type = 'keypad'  },
    [12] = { coords = vec3(-3250.09, 1004.46,  12.83),   type = 'keypad'  },
    [13] = { coords = vec3(-3047.88,  585.64,   7.91),   type = 'keypad'  },
    [14] = { coords = vec3(-1220.85,  -916.05, 11.329),  type = 'padlock' },
    [15] = { coords = vec3(-1478.94,  -375.5,  39.16),   type = 'padlock' },
    [16] = { coords = vec3(1126.77,   -980.1,  45.41),   type = 'padlock' },
    [17] = { coords = vec3(1169.31,  2717.79,  37.15),   type = 'padlock' },
    [18] = { coords = vec3(-2959.64,  387.08,  14.04),   type = 'padlock' },
}

Config.Pincode = {
    difficulty = 1,
    guesses    = 5,
}

Config.SafeCrack = {
    difficulty = 3,
}

Config.MoneyGame = {
    duration    = 160,
    coinValue   = 1,
    bombPenalty = 3,
    maxReward   = 120,
    spawnRate   = 1100,
    rewardType  = 'black_money',
}