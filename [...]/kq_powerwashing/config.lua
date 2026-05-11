Config = {}

-- Enabling this will add additional prints and debug visuals
Config.debug = false

--
Config.locale = 'en'

-- Name of the job
-- Can be set to false to ignore job checks. Allowing anyone to access the contracts
Config.jobName = nil

-- Quality of the network sync of the wash areas
-- Recommended to keep it at or below `medium` for large (100+ player) servers
-- To use high or ultra presets you may want to increase your statebag/network limits to improve stability.
-- If you don't know how to do that, its recommended to not do it

-- 'very_low'
-- 'low'
-- 'medium'
-- 'high'
-- 'ultra'
Config.networkQuality = 'low'

-- Sync method for wash area data (server -> client)
-- 'event' = Uses Events
-- 'statebag' = Uses StateBags
Config.syncMethod = 'statebag'

-- Delta sync method for cleaning data (client -> server)
-- 'statebag' = Uses player state bags
-- 'event' = Uses Events
Config.deltaSyncMethod = 'statebag'

-- Quality of the textures displayed for the players
-- 'very_low'
-- 'low'
-- 'medium'
-- 'high'
-- 'ultra'
Config.clientQuality = 'medium'

--

-- Whether the contract base payment should be split between all team member
-- When set to `true`. I highly recommend enabling the 'teamWorkBonuses', to balance working in teams better
Config.splitProfitsBetweenTeam = true

--

-- The XP Gain multiplier
Config.xpGainMultiplier = 1.0

-- Max reach of the power washer gun
Config.maxWashDistance = 6.5

-- Cleaning rate of the power washing
Config.cleaningRate = 400.0

Config.dirtHighlight = {
    enabled = true, -- Whether to allow the dirt highlight option
    cooldown = 8000, -- Cooldown time in milliseconds

    -- The keybind is the native weapon "Reload" keybind. It will be hinted when a first wash area reaches 75% of cleaning.
}

-- Whether to disable the powerwasher gun when not in an active contract
Config.disablePowerwasherOutsideOfJob = true

-- Whether to hide outfits which have not yet been unlocked by the player
Config.hideLockedOutfits = true

-- Work vehicles available for selection
Config.jobVehicles = {
    ['kqcaracara'] = {
        label = 'Caracara',
        model = 'kqcaracara',
        waterTankOffset = vec3(0.0, -2.8, 0.36),
        playerOffset = vec3(0.0, -3.95, 0.3),
        bedDoorIndex = 5,
        backpackRotationOffset = 205,

        unlockRequired = 'vehicle_kqcaracara', -- The upgrade key defined in Config.levelUpgrades
        defaultMods = {
            [48] = 0 -- Livery
        }
    },
    ['kqbison'] = {
        label = 'Bison',
        model = 'kqbison',
        waterTankOffset = vec3(0.0, -2.35, 0.5),
        playerOffset = vec3(0.0, -3.3, 0.5),
        bedDoorIndex = 5,
        backpackRotationOffset = 205,
    },
}

Config.defaultVehicle = 'kqbison'

-- Radius that will be checked to verify whether a vehicle can be spawned at a set spawn point.
-- If occupied, the next spawn point will be used
Config.spawnCheckRadius = 3.0

-- Water Tank Configuration
Config.waterTank = {
    drainRate = 1.12, -- Water units drained per second while spraying (by default approx 90 seconds of non-stop water per tank)
    refillTime = 5,   -- Seconds to refill tank
}

-- Whether to use metric units for "go_to" task distance display
-- true = meters/kilometers
-- false = yards/miles
Config.useMetricUnits = true

-- Contract Pool
Config.maxAvailableContracts = 15 -- Max contracts visible on the contract board at once
Config.contractReplenishDelay = 30 -- Seconds before a new random contract appears after one is taken

Config.bonuses = {
    -- Bonus percentage when mission is finished in perfect time (5 stars)
    perfectTime = 15,

    -- Bonus percentage when mission is finished at a good time (4 stars)
    goodTime = 5,

    -- Bonus percentage received when the vehicle is at perfect health
    vehicleCare = 5,

    -- Bonus given to the player who has washed the most (Only given when there's more than 1 person in the contract)
    topWasher = 5,

    -- Maximum vehicle damage penalty amount ($)
    maxVehicleDamagePenalty = 1250,

    -- Penalty amount applied when the vehicle is missing ($)
    missingVehiclePenalty = 1500,

    -- Bonuses applied when completing contracts in teams
    teamWorkBonuses = {
        enabled = true,
        memberCounts = {
            [1] = 0, -- 0% extra bonus
            [2] = 35, -- 35% extra bonus
            [3] = 75, -- 75% extra bonus
            [4] = 100 -- 100% extra bonus
        }
    }
}


Config.levelUpgrades = {
    ['outfit_worker'] = {
        level = 4,
        label = 'Werkoutfit'
    },
    ['vehicle_brakes'] = {
        level = 6,
        label = 'Werkvoertuig remupgrade'
    },
    ['vehicle_engine'] = {
        level = 8,
        label = 'Werkvoertuig motorupgrade'
    },
    ['salary_bonus_5'] = {
        level = 10,
        label = 'Salarisverhoging 5%',
        bonusPercentage = 5,
    },
    ['vehicle_tint'] = {
        level = 13,
        label = 'Werkvoertuig raamtint'
    },
    ['salary_bonus_10'] = {
        level = 15,
        label = 'Salarisverhoging 10%',
        bonusPercentage = 10, -- This does not stack with the lower salary increase. Only the highest gets paid out as bonus
    },
    ['efficient_washing_20'] = {
        level = 15,
        label = 'Water efficiënt (+20%)',
        waterUsageMulti = 0.8, -- Consume 20% less water. Water tank will last 20% longer
    },
    ['vehicle_kqcaracara'] = {
        level = 20,
        label = 'Nieuw werkvoertuig (Caracara)'
    },
    ['outfit_experienced'] = {
        level = 20,
        label = 'Ervaren werkoutfit'
    },
    ['salary_bonus_15'] = {
        level = 20,
        label = 'Salarisverhoging 15%',
        bonusPercentage = 15, -- This does not stack with the lower salary increase. Only the highest gets paid out as bonus
    },
    ['vehicle_turbo'] = {
        level = 25,
        label = 'Werkvoertuig turboupgrade'
    },
    ['efficient_washing_30'] = {
        level = 30,
        label = 'Water efficiënt (+30%)',
        waterUsageMulti = 0.7, -- Consume 30% less water. Water tank will last 30% longer
    },
    ['salary_bonus_25'] = {
        level = 40,
        label = 'Salarisverhoging 25%',
        bonusPercentage = 25, -- This does not stack with the lower salary increase. Only the highest gets paid out as bonus
    },
}

-- Headquarters Configuration
Config.headquarters = {
    -- Coords of the headquarter
    coords = vec3(1010.37, -2287.85, 29.51),

    -- Blip configuration
    blip = {
        sprite = 498,
        color = 12,
        scale = 1.1,
        name = 'ORP Schoonmaakbedrijf',
    },

    -- Supervisor NPC
    npc = {
        model = 'ig_drfriedlander',
        coords = vec4(1002.49, -2286.07, 30.00, 285.0),
        scenario = 'PROP_HUMAN_SEAT_CHAIR_FOOD',
    },

    -- Interaction to open the contract board
    jobBoard = {
        coords = vec3(1006.41, -2282.35, 31.14),
        scale = vec3(0.5, 4.0, 2.5),
        interactDist = 4.0,
    },

    -- Interaction for changing the outfits
    outfitZone = {
        coords = vec3(1015.5, -2281.42, 30.5),
        scale = vec3(3.5, 2.7, 2.5),
        interactDist = 3.5,
    },

    -- Available work outfits
    outfits = {
        -- When using custom peds, that are not defined as an outfit.
        -- The players will be able to access the job board without an outfit.

        ['mp_m_freemode_01'] = {  -- Default Male
            ['trainee'] = {
                label = 'Werkoutfit opleiding',
                components = {
                    [3] = {drawable = 4, texture = 0},    -- hands/torso
                    [4] = {drawable = 39, texture = 3},  -- legs
                    [5] = {drawable = 0, texture = 0},    -- bags
                    [6] = {drawable = 27, texture = 0},   -- shoes
                    [8] = {drawable = 15, texture = 0},   -- shirt
                    [9] = {drawable = 0, texture = 0},    -- body armor
                    [11] = {drawable = 66, texture = 3}, -- jacket
                },
                props = {
                    [1] = {drawable = -1, texture = 0},     -- glasses
                },
            },
            ['worker'] = {
                label = 'Werkoutfit',
                unlockRequired = 'outfit_worker', -- The upgrade key defined in Config.levelUpgrades
                components = {
                    [3] = {drawable = 4, texture = 0},    -- hands/torso
                    [4] = {drawable = 191, texture = 0},  -- legs
                    [5] = {drawable = 0, texture = 0},    -- bags
                    [6] = {drawable = 27, texture = 0},  -- shoes
                    [8] = {drawable = 15, texture = 0},   -- shirt
                    [9] = {drawable = 0, texture = 0},    -- body armor
                    [11] = {drawable = 519, texture = 0}, -- jacket
                },
                props = {
                    [1] = {drawable = -1, texture = 0},     -- glasses
                },
            },
            ['experienced'] = {
                label = 'Werkoutfit ervaren',
                unlockRequired = 'outfit_experienced', -- The upgrade key defined in Config.levelUpgrades
                components = {
                    [3] = {drawable = 4, texture = 0},    -- hands/torso
                    [4] = {drawable = 191, texture = 0},  -- legs
                    [5] = {drawable = 0, texture = 0},    -- bags
                    [6] = {drawable = 111, texture = 0},  -- shoes
                    [8] = {drawable = 155, texture = 0},   -- shirt
                    [9] = {drawable = 0, texture = 0},    -- body armor
                    [11] = {drawable = 519, texture = 0}, -- jacket
                },
                props = {
                    [1] = {drawable = 15, texture = 4},    -- glasses
                },
            },
        },
        ['mp_f_freemode_01'] = {  -- Default Female
            ['trainee'] = {
                label = 'Werkoutfit opleiding',
                components = {
                    [3] = {drawable = 9, texture = 0},    -- hands/torso
                    [4] = {drawable = 39, texture = 1},  -- legs
                    [5] = {drawable = 0, texture = 0},    -- bags
                    [6] = {drawable = 26, texture = 0},  -- shoes
                    [8] = {drawable = 14, texture = 0},   -- shirt
                    [9] = {drawable = 0, texture = 0},    -- body armor
                    [11] = {drawable = 60, texture = 1}, -- jacket
                },
                props = {
                    [1] = {drawable = -1, texture = 0},     -- glasses
                },
            },
            ['worker'] = {
                label = 'Werkoutfit',
                unlockRequired = 'outfit_worker', -- The upgrade key defined in Config.levelUpgrades
                components = {
                    [3] = {drawable = 9, texture = 0},    -- hands/torso
                    [4] = {drawable = 205, texture = 0},  -- legs
                    [5] = {drawable = 0, texture = 0},    -- bags
                    [6] = {drawable = 26, texture = 0},  -- shoes
                    [8] = {drawable = 14, texture = 0},   -- shirt
                    [9] = {drawable = 0, texture = 0},    -- body armor
                    [11] = {drawable = 558, texture = 0}, -- jacket
                },
                props = {
                    [1] = {drawable = -1, texture = 0},     -- glasses
                },
            },
            ['experienced'] = {
                label = 'Werkoutfit ervaren',
                unlockRequired = 'outfit_experienced', -- The upgrade key defined in Config.levelUpgrades
                components = {
                    [3] = {drawable = 9, texture = 0},    -- hands/torso
                    [4] = {drawable = 205, texture = 0},  -- legs
                    [5] = {drawable = 0, texture = 0},    -- bags
                    [6] = {drawable = 115, texture = 0},  -- shoes
                    [8] = {drawable = 191, texture = 0},   -- shirt
                    [9] = {drawable = 0, texture = 0},    -- body armor
                    [11] = {drawable = 558, texture = 0}, -- jacket
                },
                props = {
                    [1] = {drawable = 9, texture = 2},     -- glasses
                },
            },
        },
    },
}

-- Global spawn locations for work vehicles
Config.vehicleSpawnLocations = {
    vec4(1004.80, -2299.3, 30.50, 266.0),
    vec4(1004.80, -2302.7, 30.50, 266.0),
    vec4(1004.80, -2306.4, 30.50, 266.0),
    vec4(1004.80, -2310.5, 30.50, 266.0),
    vec4(1004.80, -2314.1, 30.50, 266.0),
    vec4(1004.80, -2317.4, 30.50, 266.0),
    vec4(1004.80, -2320.9, 30.50, 266.0),
    vec4(1004.80, -2324.3, 30.50, 266.0),

    vec4(1027.22, -2308.14, 30.51, 80.0),
    vec4(1027.22, -2312.14, 30.51, 80.0),
    vec4(1027.22, -2316.14, 30.51, 80.0),
    vec4(1027.22, -2320.14, 30.51, 80.0),
    vec4(1027.22, -2324.14, 30.51, 80.0),
    vec4(1027.22, -2328.14, 30.51, 80.0),
    vec4(1027.22, -2332.14, 30.51, 80.0),
    vec4(1027.22, -2336.14, 30.51, 80.0),
    vec4(1027.22, -2340.14, 30.51, 80.0),

    vec4(1051.06, -2318.67, 30.59, 352.0),
    vec4(1052.36, -2305.46, 30.59, 352.0),
}

-- Temporary suspension from starting new contracts after leaving an active contract
Config.cancellationBan = {
    enabled = true,
    duration = 10,  -- Minutes banned from starting a new contract, after leaving an active contract
}


Config.misc = {
    -- Whether the powerwashing gun should push objects
    allowObjectPushing = true,

    -- Whether the powerwashing gun should push npc's
    allowNpcPushing = true,

    -- Whether the powerwashing gun should clean cars
    allowCarCleaning = true,
}

-- Power washer weapon
Config.powerWasherWeapon = 'WEAPON_KQPOWERWASHER'
