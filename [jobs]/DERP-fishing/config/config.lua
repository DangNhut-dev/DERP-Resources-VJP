Config = {}

Config.progressPerCatch = 1
Config.xpPerLevel = 10000

---@class Fish
---@field minLevel integer
---@field price integer | { min: integer, max: integer }
---@field chance integer Percentage chance
---@field skillcheck SkillCheckDifficulity

---@type table<string, Fish>
Config.fish = {
    ['anchovy']     = { minLevel = 1, price = { min = 25,   max = 50   }, chance = 35, skillcheck = { 'easy', 'medium' } },
    ['trout']       = { minLevel = 2, price = { min = 50,   max = 100  }, chance = 35, skillcheck = { 'easy', 'medium' } },
    ['haddock']     = { minLevel = 3, price = { min = 150,  max = 200  }, chance = 20, skillcheck = { 'easy', 'medium' } },
    ['salmon']      = { minLevel = 4, price = { min = 200,  max = 250  }, chance = 10, skillcheck = { 'easy', 'medium', 'medium' } },
    ['grouper']     = { minLevel = 5, price = { min = 300,  max = 350  }, chance = 25, skillcheck = { 'easy', 'medium', 'medium', 'medium' } },
    ['piranha']     = { minLevel = 6, price = { min = 350,  max = 450  }, chance = 25, skillcheck = { 'easy', 'medium', 'hard' } },
    ['red_snapper'] = { minLevel = 7, price = { min = 400,  max = 450  }, chance = 20, skillcheck = { 'easy', 'medium', 'medium', 'medium' } },
    ['mahi_mahi']   = { minLevel = 8, price = { min = 450,  max = 500  }, chance = 20, skillcheck = { 'easy', 'medium', 'medium', 'medium' } },
    ['tuna']        = { minLevel = 9, price = { min = 1250, max = 1500 }, chance = 5,  skillcheck = { 'easy', 'medium', 'hard' } },
    ['shark']       = { minLevel = 10, price = { min = 2250, max = 2750 }, chance = 1,  skillcheck = { 'easy', 'medium', 'hard' } },
}

---@class FishingRod
---@field name string
---@field price integer
---@field minLevel integer The minimal level
---@field breakChance integer Percentage chance

---@type FishingRod[]
Config.fishingRods = {
    { name = 'basic_rod', price = 500, minLevel = 1, breakChance = 20 },
    { name = 'graphite_rod', price = 5000, minLevel = 2, breakChance = 10 },
    { name = 'titanium_rod', price = 10000, minLevel = 3, breakChance = 1 },
}

---@class FishingBait
---@field name string
---@field price integer
---@field minLevel integer The minimal level
---@field waitDivisor number The total wait time gets divided by this value

---@type FishingBait[]
Config.baits = {
    { name = 'worms', price = 1, minLevel = 1, waitDivisor = 1.0 },
    { name = 'artificial_bait', price = 3, minLevel = 2, waitDivisor = 3.0 },
}

---@class FishingZone
---@field locations vector3[] One of these gets picked at random
---@field radius number
---@field minLevel integer
---@field waitTime { min: integer, max: integer }
---@field includeOutside boolean Whether you can also catch fish from Config.outside
---@field blip BlipData?
---@field message { enter: string, exit: string }?
---@field fishList string[]

---@type FishingZone[]
Config.fishingZones = {
    {
        blip = {
            name = 'Bãi Câu Cá',
            sprite = 317,
            color = 24,
            scale = 0.75
        },
        locations = {
            vector3(-1911.83, -1295.70, 10.57)
        },
        radius = 250.0,
        minLevel = 1,
        waitTime = { min = 25, max = 35 },
        includeOutside = true,
        message = { enter = '', exit = '' },
        fishList = { 'anchovy', 'trout', 'haddock', 'salmon', 'mahi_mahi', 'red_snapper', 'grouper', 'tuna', 'shark', 'piranha' }
    },
}

-- Outside of all zones
Config.outside = {
    waitTime = { min = 10, max = 25 },

    ---@type string[]
    fishList = {
        -- 'trout', 'anchovy', 'haddock', 'salmon'
    }
}

Config.ped = {
    model = `s_m_m_cntrybar_01`,
    buyAccount = 'money',
    sellAccount = 'money',
    blip = {
        name = 'Cửa Hàng Câu',
        sprite = 356,
        color = 74,
        scale = 0.75
    },

    ---@type vector4[]
    locations = {
        -- vector4(-1810.04, -1207.75, 14.30, 122.41)
        vector4(-1857.90, -1244.02, 8.62, 133.78)
    }
}

-- Config.renting = {
--     model = `s_m_m_dockwork_01`, -- The ped model
--     account = 'money',
--     boats = {
--         { model = `speeder`, price = 500, image = 'https://i.postimg.cc/mDSqWj4P/164px-Speeder.webp' },
--         { model = `dinghy`, price = 750, image = 'https://i.postimg.cc/ZKzjZgj0/164px-Dinghy2.webp'  },
--         { model = `tug`, price = 1250, image = 'https://i.postimg.cc/jq7vpKHG/164px-Tug.webp' }
--     },
--     blip = {
--         name = 'Boat Rental',
--         sprite = 410,
--         color = 74,
--         scale = 0.75
--     },
--     returnDivider = 5, -- Players can return it and get some cash back
--     returnRadius = 30.0, -- The save radius

--     ---@type { coords: vector4, spawn: vector4 }[]
--     locations = {
--         { coords = vector4(-1434.4818, -1512.2745, 2.1486, 25.8666), spawn = vector4(-1494.4496, -1537.6943, 2.3942, 115.6015) }
--     }
-- }