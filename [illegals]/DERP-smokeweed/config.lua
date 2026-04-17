Config = {}

-- Animation dùng chung khi hút
Config.Anim = {
    dict = 'amb@world_human_smoking_pot@male@base',
    clip = 'base',
    prop = 'prop_sh_joint_01',
    bone = 60309,
    propPos = vector3(-0.006, 0.018, 0.001),
    propRot = vector3(-70.0, 0.0, 0.0),
    flag = 49
}

-- Progressbar
Config.ProgressLabel = 'Đang hút...'

--[[
    EffectType:
      - sprint     : boost tốc độ chạy + screen effect nhẹ
      - stamina    : không mệt (stamina vô hạn) + screen effect nhẹ
      - regen      : hồi HP từ từ + screen effect nhẹ
      - high       : phê mạnh (screen effect mạnh + shake cam + walkstyle drunk)
      - light      : chỉ screen effect say nhẹ, không bonus stat

    Tham số chung:
      duration     : thời gian hiệu ứng (ms)
      progressTime : thời gian hút (ms) - 4 strain đặc biệt = 5000, còn lại = 30000
      screenEffect : tên screen effect GTA

    Tham số riêng:
      sprintMult     : boost sprint (effectType=sprint)
      healthTick     : HP hồi mỗi tick (effectType=regen)
      healthInterval : chu kỳ tick HP (effectType=regen)
      shake          : shake camera (effectType=high)
      walkstyle      : dáng đi (effectType=high) - 'move_m@drunk@verydrunk', 'move_m@drunk@moderatedrunk'
]]

Config.Items = {
    -- ========== 4 STRAIN ĐẶC BIỆT ==========

    -- Sour Diesel (HIGH TIER - phê pha nhất, shake cam + walkstyle drunk)
    ['sour_diesel_high_weed'] = {
        effectType = 'high',
        progressTime = 30000,
        duration = 120000,
        screenEffect = 'DrugsMichaelAliensFightIn',
        shake = { name = 'DRUNK_SHAKE', intensity = 0.5 },
        walkstyle = 'move_m@drunk@verydrunk',
    },
    ['sour_diesel_medium_weed'] = {
        effectType = 'high',
        progressTime = 30000,
        duration = 90000,
        screenEffect = 'DrugsTrevorClownsFight',
        shake = { name = 'DRUNK_SHAKE', intensity = 0.4 },
        walkstyle = 'move_m@drunk@moderatedrunk',
    },
    ['sour_diesel_low_weed'] = {
        effectType = 'high',
        progressTime = 30000,
        duration = 60000,
        screenEffect = 'DrugsTrevorClownsFight',
        shake = { name = 'DRUNK_SHAKE', intensity = 0.3 },
        walkstyle = 'move_m@drunk@slightlydrunk',
    },

    -- Purple Haze (SPRINT boost)
    ['purple_haze_high_weed'] = {
        effectType = 'sprint',
        progressTime = 5000,
        duration = 90000,
        sprintMult = 1.3,
        screenEffect = 'DrugsTrevorClownsFight',
    },
    ['purple_haze_medium_weed'] = {
        effectType = 'sprint',
        progressTime = 5000,
        duration = 60000,
        sprintMult = 1.2,
        screenEffect = 'DrugsTrevorClownsFight',
    },
    ['purple_haze_low_weed'] = {
        effectType = 'sprint',
        progressTime = 5000,
        duration = 30000,
        sprintMult = 1.1,
        screenEffect = 'DrugsTrevorClownsFight',
    },

    -- Blue Dream (STAMINA không mệt)
    ['blue_dream_high_weed'] = {
        effectType = 'stamina',
        progressTime = 5000,
        duration = 90000,
        screenEffect = 'DrugsTrevorClownsFight',
    },
    ['blue_dream_medium_weed'] = {
        effectType = 'stamina',
        progressTime = 5000,
        duration = 60000,
        screenEffect = 'DrugsTrevorClownsFight',
    },
    ['blue_dream_low_weed'] = {
        effectType = 'stamina',
        progressTime = 5000,
        duration = 30000,
        screenEffect = 'DrugsTrevorClownsFight',
    },

    -- OG Kush (REGEN HP từ từ)
    ['og_kush_high_weed'] = {
        effectType = 'regen',
        progressTime = 5000,
        duration = 90000,
        healthTick = 5,
        healthInterval = 2000,
    },
    ['og_kush_medium_weed'] = {
        effectType = 'regen',
        progressTime = 5000,
        duration = 60000,
        healthTick = 3,
        healthInterval = 2500,
    },
    ['og_kush_low_weed'] = {
        effectType = 'regen',
        progressTime = 5000,
        duration = 30000,
        healthTick = 2,
        healthInterval = 3000,
    },

    -- ========== CÁC LOẠI CÒN LẠI - CHỈ EFFECT NHẸ ==========

    -- Northern Lights
    ['northern_lights_high_weed'] = {
        effectType = 'light',
        progressTime = 30000,
        duration = 60000,
        screenEffect = 'DrugsTrevorClownsFight',
        shake = { name = 'DRUNK_SHAKE', intensity = 0.15 },
        walkstyle = 'move_m@drunk@slightlydrunk',
    },
    ['northern_lights_medium_weed'] = {
        effectType = 'light',
        progressTime = 30000,
        duration = 45000,
        screenEffect = 'DrugsTrevorClownsFight',
        shake = { name = 'DRUNK_SHAKE', intensity = 0.1 },
    },
    ['northern_lights_low_weed'] = {
        effectType = 'light',
        progressTime = 30000,
        duration = 30000,
        screenEffect = 'DrugsTrevorClownsFight',
        screenEffect = 'DrunkBlurred01',
    },

    -- Jack Herer
    ['jack_herer_high_weed'] = {
        effectType = 'light',
        progressTime = 30000,
        duration = 60000,
        screenEffect = 'DrugsTrevorClownsFight',
        shake = { name = 'DRUNK_SHAKE', intensity = 0.15 },
        walkstyle = 'move_m@drunk@slightlydrunk',
    },
    ['jack_herer_medium_weed'] = {
        effectType = 'light',
        progressTime = 30000,
        duration = 45000,
        screenEffect = 'DrugsTrevorClownsFight',
        shake = { name = 'DRUNK_SHAKE', intensity = 0.1 },
    },
    ['jack_herer_low_weed'] = {
        effectType = 'light',
        progressTime = 30000,
        duration = 30000,
        screenEffect = 'DrugsTrevorClownsFight',
        screenEffect = 'DrunkBlurred01',
    },

    -- Super Lemon Haze
    ['super_lemon_haze_high_weed'] = {
        effectType = 'light',
        progressTime = 30000,
        duration = 60000,
        screenEffect = 'DrugsTrevorClownsFight',
        shake = { name = 'DRUNK_SHAKE', intensity = 0.15 },
        walkstyle = 'move_m@drunk@slightlydrunk',
    },
    ['super_lemon_haze_medium_weed'] = {
        effectType = 'light',
        progressTime = 30000,
        duration = 45000,
        screenEffect = 'DrugsTrevorClownsFight',
        shake = { name = 'DRUNK_SHAKE', intensity = 0.1 },
    },
    ['super_lemon_haze_low_weed'] = {
        effectType = 'light',
        progressTime = 30000,
        duration = 30000,
        screenEffect = 'DrugsTrevorClownsFight',
        screenEffect = 'DrunkBlurred01',
    },

    -- Girl Scout Cookies
    ['gsc_high_weed'] = {
        effectType = 'light',
        progressTime = 30000,
        duration = 60000,
        screenEffect = 'DrugsTrevorClownsFight',
        shake = { name = 'DRUNK_SHAKE', intensity = 0.15 },
        walkstyle = 'move_m@drunk@slightlydrunk',
    },
    ['gsc_medium_weed'] = {
        effectType = 'light',
        progressTime = 30000,
        duration = 45000,
        screenEffect = 'DrugsTrevorClownsFight',
        shake = { name = 'DRUNK_SHAKE', intensity = 0.1 },
    },
    ['gsc_low_weed'] = {
        effectType = 'light',
        progressTime = 30000,
        duration = 30000,
        screenEffect = 'DrugsTrevorClownsFight',
        screenEffect = 'DrunkBlurred01',
    },

    -- Wedding Cake
    ['wedding_cake_high_weed'] = {
        effectType = 'light',
        progressTime = 30000,
        duration = 60000,
        screenEffect = 'DrugsTrevorClownsFight',
        shake = { name = 'DRUNK_SHAKE', intensity = 0.15 },
        walkstyle = 'move_m@drunk@slightlydrunk',
    },
    ['wedding_cake_medium_weed'] = {
        effectType = 'light',
        progressTime = 30000,
        duration = 45000,
        screenEffect = 'DrugsTrevorClownsFight',
        shake = { name = 'DRUNK_SHAKE', intensity = 0.1 },
    },
    ['wedding_cake_low_weed'] = {
        effectType = 'light',
        progressTime = 30000,
        duration = 30000,
        screenEffect = 'DrugsTrevorClownsFight',
    },
}