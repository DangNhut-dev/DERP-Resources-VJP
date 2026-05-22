Config = {}

Config.MinPolice = 1
Config.PoliceJobs = { 'police', 'sheriff', 'bcso' }

Config.LockpickItem = 'lockpick'
Config.AdvancedLockpickItem = 'advancedlockpick'
Config.LockpickBreakChance = 30
Config.AdvancedLockpickDurabilityLoss = 5

Config.CrateInteractDistance = 2.0
Config.RefineryInteractDistance = 2.5

Config.LockpickDuration = 10000
Config.RespawnTime = 30

Config.RedZones = {
    {
        label = 'Bãi Quân Dụng',
        coords = vec3(-1640.89, 3016.64, 31.83),
        radius = 180.0,
        blip = {
            sprite = 568,
            color = 1,
            scale = 0.6,
            alpha = 128
        }
    }
}

Config.Crates = {
    {
        id = 1,
        model = 'prop_mil_crate_01',
        coords = vec4(-1638.88, 3001.56, 31.33, 113.63),
        respawn = 30
    },
    {
        id = 2,
        model = 'prop_box_wood05a',
        coords = vec4(-1644.98, 3003.22, 30.83, 210.37),
        respawn = 30
    },
    {
        id = 3,
        model = 'prop_box_wood05a',
        coords = vec4(-1649.77, 3006.31, 30.83, 113.92),
        respawn = 30
    },
    {
        id = 4,
        model = 'prop_mil_crate_01',
        coords = vec4(-1651.21, 3009.62, 31.33, 119.43),
        respawn = 30
    },
    {
        id = 5,
        model = 'prop_mil_crate_01',
        coords = vec4(-1646.91, 3002.74, 31.33, 207.65),
        respawn = 30
    },
    {
        id = 6,
        model = 'prop_box_wood05a',
        coords = vec4(-1652.09, 3011.31, 30.83, 116.50),
        respawn = 30
    },
    {
        id = 7,
        model = 'prop_box_wood05a',
        coords = vec4(-1639.53, 3003.27, 30.83, 113.16),
        respawn = 30
    },
    {
        id = 8,
        model = 'prop_mil_crate_01',
        coords = vec4(-1654.04, 3015.58, 31.33, 115.86),
        respawn = 30
    },
    {
        id = 9,
        model = 'prop_box_wood05a',
        coords = vec4(-1653.09, 3013.54, 30.83, 113.11),
        respawn = 30
    },
    {
        id = 10,
        model = 'prop_mil_crate_01',
        coords = vec4(-1642.75, 3004.54, 31.33, 207.61),
        respawn = 30
    },
    {
        id = 11,
        model = 'prop_box_wood05a',
        coords = vec4(-1648.83, 3003.91, 30.83, 121.32),
        respawn = 30
    },
    {
        id = 12,
        model = 'prop_mil_crate_01',
        coords = vec4(-1646.75, 3022.05, 31.33, 26.50),
        respawn = 30
    },
    {
        id = 13,
        model = 'prop_box_wood05a',
        coords = vec4(-1650.48, 3016.68, 30.83, 358.54),
        respawn = 30
    },
    {
        id = 14,
        model = 'prop_box_wood05a',
        coords = vec4(-1648.35, 3016.68, 30.83, 356.30),
        respawn = 30
    },
    {
        id = 15,
        model = 'prop_mil_crate_01',
        coords = vec4(-1643.63, 3020.74, 31.33, 294.21),
        respawn = 30
    },
}

Config.Rewards = {
    { item = 'dirty_metal',             min = 2, max = 5, chance = 75 },
    { item = 'dirty_gunpowder',         min = 1, max = 3, chance = 100 },
    { item = 'carbon',                  min = 1, max = 3, chance = 50 },
    { item = 'taurus_slide',            min = 1, max = 1, chance = 10 },
    { item = 'taurus_frame',            min = 1, max = 1, chance = 8 },
    { item = 'taurus_barrel',           min = 1, max = 1, chance = 6 },
    { item = 'at_clip_extended_pistol2',min = 1, max = 1, chance = 2 },
}

Config.RefineryLocations = {
    vec3(1047.22, -2056.56, 31.02),
}

Config.RefineryRecipes = {
    {
        label = 'Tinh chế kim loại',
        input  = { item = 'dirty_metal',       amount = 5 },
        output = { item = 'refined_metal',     amount = 5 },
        duration = 10000
    },
    {
        label = 'Tinh chế thuốc súng',
        input  = { item = 'dirty_gunpowder',   amount = 5 },
        output = { item = 'gunpowder',         amount = 10 },
        duration = 10000
    }
}