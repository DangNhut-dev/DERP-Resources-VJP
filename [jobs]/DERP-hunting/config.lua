Config = Config or {}

Config.DEBUG = false

Config.sv_dataClearnigTimer = 1000 * 60 * 60
Config.sv_maxTableSize      = 5000

Config.SlughterEveryAnimal  = true

Config.ShootingProtection = false
Config.ProtectedWeapons   = { 'weapon_musket' }

Config.BaitCooldown   = 1000 * 30
Config.SpawningTimer  = 1000 * 10

Config.AnimalsEatingSpeed = 1000 * 15
Config.AnimalsFleeView    = 15.0

Config.BaitPlacementSpeed = math.random(1000 * 5, 1000 * 7)
Config.SlaughteringSpeed  = math.random(1000 * 5, 1000 * 7)

Config.animalDespawnRange   = 150.0
Config.zoneOutRespawnDelay  = 15000  -- ms: thú ra ngoài zone bao lâu thì despawn + respawn lại

Config.spawnedAnimalsBlips = true
Config.AnimalBlip = {
    sprite = 463,
    color  = 5,
}

Config.callPoliceChance = { 25, 75 }

Config.llegalHuntingNotification = function(animalCoord)
    exports['ps-dispatch']:Hunting()
end

Config.activateLootMultiplier = true
Config.maxMultiplier          = 10

-- Chỉ các vũ khí trong danh sách này mới được tính sát thương hợp lệ
-- Thú bị xe cán hoặc vũ khí không có trong đây → không thể lột da
Config.weaponQualityMultiplier = {
    ['weapon_sniperrifle2'] = 5,
    ['weapon_rifle']        = 3,
    ['weapon_carbinerifle'] = 3,
    ['weapon_huntingrifle'] = 4,
    ['weapon_musket']       = 2,
    ['weapon_pistol']       = 1,
    ['default']             = 1,  -- súng khác không có trong list vẫn cho lột da
}

Config.boneHitMultiplier = {
    ['head'] = {
        bondeId    = 31086,
        multiplier = 5,
        lastHit    = true,
    },
    ['SKEL_ROOT'] = {
        bondeId    = 0,
        multiplier = -1,
    },
    ['default'] = {
        multiplier = -1,
    },
}

-- ============================
--   HỆ THỐNG DA (HIDE) THEO SAO
--   Mỗi con thú khi lột da sẽ random ra da theo tỉ lệ
--   chance: tổng các giá trị = 100 (%)
--   sellPrice: giá bán mỗi unit
-- ============================
Config.HideSystem = {
    enabled = true,

    -- Item da theo sao (tên item trong ox_inventory)
    grades = {
        { star = 1, item = 'hide_1star', label = 'Da 1 sao',  sellPrice = 100, chance = 70 },
        { star = 2, item = 'hide_2star', label = 'Da 2 sao',  sellPrice = 250, chance = 25 },
        { star = 3, item = 'hide_3star', label = 'Da 3 sao',  sellPrice = 500, chance = 5 },
    },

    -- Số lượng da nhận được (random trong khoảng min-max)
    amountMin = 1,
    amountMax = 3,
}

-- ============================
--   ANIMALS MASTER LIST
--   Loots: chỉ còn thịt (thịt không bán được, chỉ dùng nội bộ)
--   Da được tính riêng qua HideSystem
-- ============================
Config.Animals = {
    {
        model       = 'a_c_deer',
        spwanRarity = { 100, 100 },
        hash        = -664053099,
        meatItem    = 'meatdeer',   -- thịt nhận được sau lột da (không bán được)
        meatAmount  = { min = 1, max = 3 },
    },
    -- {
    --     model       = 'a_c_pig',
    --     spwanRarity = { 20, 0 },
    --     hash        = -1323586730,
    --     meatItem    = 'meatpig',
    --     meatAmount  = { min = 1, max = 3 },
    -- },
    -- {
    --     model       = 'a_c_boar',
    --     spwanRarity = { 30, 25 },
    --     hash        = -832573324,
    --     meatItem    = 'meatpig',
    --     meatAmount  = { min = 1, max = 3 },
    -- },
    -- {
    --     model       = 'a_c_mtlion',
    --     spwanRarity = { 25, 50 },
    --     hash        = 307287994,
    --     meatItem    = 'meatlion',
    --     meatAmount  = { min = 1, max = 3 },
    -- },
}

-- ============================
--   HUNTING AREA
-- ============================
-- Config.HuntingArea = {
--     {
--         name     = 'Khu Vực Săn Bắn',
--         coord    = vector3(-840.6, 4183.3, 215.29),
--         radius   = 800.0,
--         llegal   = false,
--         showBlip = false,
--     },
-- }

-- ============================
--   SELL SPOTS
--   Chỉ bán da, thịt không bán được
-- ============================
Config.SellSpots = {
    {
        -- BlipsCoords = vector3(570.34, 2796.46, 42.01),
        -- name        = 'Ban da thu san',
        -- showBlip    = false,
        -- SellerNpc = {
        --     model  = 'csb_chef',
        --     coords = vector4(568.96, 2796.51, 42.02, 275.62),
        -- },
        -- targetLabel = 'Ban da thu san',
        -- targetIcon  = 'fas fa-dollar-sign',
        -- targetDist  = 2.5,
        -- sellItems tự động generate từ Config.HideSystem.grades
        -- không cần khai báo thủ công ở đây
    },
}

-- ============================
--   SHOP + JOB NPC
-- ============================
Config.ShopNPC = {
    model  = 'cs_hunter',
    coords = vector4(-679.10, 5834.43, 17.33, 136.09),
    blip = {
        show   = true,
        sprite = 141,
        color  = 4,
        scale  = 0.8,
        label  = 'Trung Tâm Săn Bắn',
    },
    targetLabel = 'Quản Lý Trung Tâm Săn Bắn',
    targetIcon  = 'fas fa-store',
    targetDist  = 2.5,
    items = {
        { label = 'Súng Săn',  item = 'WEAPON_MUSKET', price = 3500, description = 'Súng săn bắn tiêu chuẩn.' },
        { label = 'Đạn Súng Săn',  item = 'ammo-MUSKET', price = 50, description = 'Đạn súng săn tiêu chuẩn.' },
        { label = 'Dao', item = 'weapon_knife', price = 1500,  description = 'Dao dùng cho việt xẻ thịt, lột da.' },
    },
}

-- ============================
--   JOB CONFIG
-- ============================
Config.Job = {
    maxGroupSize = 4,

    notifyDelay  = { min = 60000, max = 120000 },
    -- notifyDelay  = { min = 600, max = 700 },

    zoneMaxAnimals   = 10,       -- Số thú tối đa trong zone cùng lúc
    zoneRespawnDelay = 5000,   -- Delay (ms) sau khi thú chết → spawn con mới

    missions = {
        {
            id          = 1,
            label       = 'Săn Hươu Rừng',
            description = 'Tiêu diệt đàn hươu đang phá hoại mùa màng.',
            animals     = { 'a_c_deer' },
            targetKills = 3,
            reward      = 400,
            zone = {
                name   = 'Khu Vực Săn Bắn',
                coord  = vector3(-348.67, 4843.49, 210.78),
                radius = 100.0,
            },
        },
        {
            id          = 2,
            label       = 'Săn Hươu Rừng',
            description = 'Tiêu diệt đàn hươu đang phá hoại mùa màng.',
            animals     = { 'a_c_deer' },
            targetKills = 2,
            reward      = 400,
            zone = {
                name   = 'Khu Vực Săn Bắn',
                coord  = vector3(-898.60, 4802.35, 302.68),
                radius = 100.0,
            },
        },
        {
            id          = 3,
            label       = 'Săn Hươu Rừng',
            description = 'Tiêu diệt đàn hươu đang phá hoại mùa màng.',
            animals     = { 'a_c_deer' },
            targetKills = 3,
            reward      = 400,
            zone = {
                name   = 'Khu Vực Săn Bắn',
                coord  = vector3(-701.92, 4956.27, 186.44),
                radius = 100.0,
            },
        },
        {
            id          = 4,
            label       = 'Săn Hươu Rừng',
            description = 'Tiêu diệt đàn hươu đang phá hoại mùa màng.',
            animals     = { 'a_c_deer' },
            targetKills = 3,
            reward      = 400,
            zone = {
                name   = 'Khu Vực Săn Bắn',
                coord  = vector3(-967.93, 4996.46, 183.77),
                radius = 100.0,
            },
        },
        {
            id          = 5,
            label       = 'Săn Hươu Rừng',
            description = 'Tiêu diệt đàn hươu đang phá hoại mùa màng.',
            animals     = { 'a_c_deer' },
            targetKills = 2,
            reward      = 450,
            zone = {
                name   = 'Khu Vực Săn Bắn',
                coord  = vector3(-1201.27, 4952.35, 180.54),
                radius = 100.0,
            },
        },
        {
            id          = 6,
            label       = 'Săn Hươu Rừng',
            description = 'Tiêu diệt đàn hươu đang phá hoại mùa màng.',
            animals     = { 'a_c_deer' },
            targetKills = 3,
            reward      = 500,
            zone = {
                name   = 'Khu Vực Săn Bắn',
                coord  = vector3(-1264.86, 4684.23, 85.62),
                radius = 100.0,
            },
        },
        {
            id          = 7,
            label       = 'Săn Hươu Rừng',
            description = 'Tiêu diệt đàn hươu đang phá hoại mùa màng.',
            animals     = { 'a_c_deer' },
            targetKills = 2,
            reward      = 400,
            zone = {
                name   = 'Khu Vực Săn Bắn',
                coord  = vector3(34.50, 6870.87, 14.54),
                radius = 100.0,
            },
        },
        {
            id          = 8,
            label       = 'Săn Hươu Rừng',
            description = 'Tiêu diệt đàn hươu đang phá hoại mùa màng.',
            animals     = { 'a_c_deer' },
            targetKills = 2,
            reward      = 420,
            zone = {
                name   = 'Khu Vực Săn Bắn',
                coord  = vector3(252.69, 6813.92, 15.76),
                radius = 100.0,
            },
        },
    },
}