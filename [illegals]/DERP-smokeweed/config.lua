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
        effectType = 'regen',
        progressTime = 1500,
        duration = 5000,
        healthTick = 5,
        healthInterval = 1000,
    },
    ['sour_diesel_medium_weed'] = {
        effectType = 'regen',
        progressTime = 3000,
        duration = 5000,
        healthTick = 5,
        healthInterval = 1000,
        screenEffect = 'DrugsTrevorClownsFight',
    },
    ['sour_diesel_low_weed'] = {
        effectType = 'regen',
        progressTime = 5000,
        duration = 5000,
        healthTick = 5,
        healthInterval = 1000,
        screenEffect = 'DrugsTrevorClownsFight',
        shake = { name = 'DRUNK_SHAKE', intensity = 0.1 },
    },

    -- Purple Haze (SPRINT boost)
    ['purple_haze_high_weed'] = {
        effectType = 'sprint',
        progressTime = 1500,
        duration = 15000,
        sprintMult = 1.1,
    },
    ['purple_haze_medium_weed'] = {
        effectType = 'sprint',
        progressTime = 3000,
        duration = 15000,
        sprintMult = 1.1,
        screenEffect = 'DrugsTrevorClownsFight',
    },
    ['purple_haze_low_weed'] = {
        effectType = 'sprint',
        progressTime = 5000,
        duration = 15000,
        sprintMult = 1.1,
        screenEffect = 'DrugsTrevorClownsFight',
        shake = { name = 'DRUNK_SHAKE', intensity = 0.1 },
    },

    -- Northern Lights
    ['northern_lights_high_weed'] = {
        effectType = 'stamina',
        progressTime = 1500,
        duration = 15000,
    },
    ['northern_lights_medium_weed'] = {
        effectType = 'light',
        progressTime = 3000,
        duration = 15000,
        screenEffect = 'DrugsTrevorClownsFight',
    },
    ['northern_lights_low_weed'] = {
        effectType = 'light',
        progressTime = 5000,
        duration = 15000,
        screenEffect = 'DrugsTrevorClownsFight',
        shake = { name = 'DRUNK_SHAKE', intensity = 0.1 },
    },

    
    -- Jack Herer
    ['jack_herer_high_weed'] = {
        effectType = 'regen',
        progressTime = 1500,
        duration = 5000,
        healthTick = 10,
        healthInterval = 1000,
    },
    ['jack_herer_medium_weed'] = {
        effectType = 'regen',
        progressTime = 3000,
        duration = 5000,
        healthTick = 10,
        healthInterval = 1000,
        screenEffect = 'DrugsTrevorClownsFight',
    },
    ['jack_herer_low_weed'] = {
        effectType = 'regen',
        progressTime = 5000,
        duration = 5000,
        healthTick = 10,
        healthInterval = 1000,
        screenEffect = 'DrugsTrevorClownsFight',
        shake = { name = 'DRUNK_SHAKE', intensity = 0.1 },
    },

    -- Super Lemon Haze
    ['super_lemon_haze_high_weed'] = {
        effectType = 'sprint',
        progressTime = 1500,
        duration = 30000,
        sprintMult = 1.2,
    },
    ['super_lemon_haze_medium_weed'] = {
        effectType = 'sprint',
        progressTime = 3000,
        duration = 30000,
        sprintMult = 1.2,
        screenEffect = 'DrugsTrevorClownsFight',
    },
    ['super_lemon_haze_low_weed'] = {
        effectType = 'sprint',
        progressTime = 5000,
        duration = 30000,
        sprintMult = 1.2,
        screenEffect = 'DrugsTrevorClownsFight',
        shake = { name = 'DRUNK_SHAKE', intensity = 0.1 },
    },

    ['blue_dream_high_weed'] = {
        effectType = 'light',
        progressTime = 1500,
        duration = 30000,
    },
    ['blue_dream_medium_weed'] = {
        effectType = 'light',
        progressTime = 3000,
        duration = 30000,
        screenEffect = 'DrugsTrevorClownsFight',
    },
    ['blue_dream_low_weed'] = {
        effectType = 'light',
        progressTime = 5000,
        duration = 30000,
        screenEffect = 'DrugsTrevorClownsFight',
        shake = { name = 'DRUNK_SHAKE', intensity = 0.1 },
    },

    -- Wedding Cake
    ['wedding_cake_high_weed'] = {
        effectType = 'regen',
        progressTime = 1500,
        duration = 5000,
        healthTick = 15,
        healthInterval = 1000,
    },
    ['wedding_cake_medium_weed'] = {
        effectType = 'regen',
        progressTime = 3000,
        duration = 5000,
        healthTick = 15,
        healthInterval = 1000,
        screenEffect = 'DrugsTrevorClownsFight',
    },
    ['wedding_cake_low_weed'] = {
        effectType = 'regen',
        progressTime = 5000,
        duration = 5000,
        healthTick = 15,
        healthInterval = 1000,
        screenEffect = 'DrugsTrevorClownsFight',
        shake = { name = 'DRUNK_SHAKE', intensity = 0.1 },
    },

    -- OG Kush (REGEN HP từ từ)
    ['og_kush_high_weed'] = {
        effectType = 'sprint',
        progressTime = 1500,
        duration = 45000,
        sprintMult = 1.4,
    },
    ['og_kush_medium_weed'] = {
        effectType = 'sprint',
        progressTime = 3000,
        duration = 45000,
        sprintMult = 1.4,
        screenEffect = 'DrugsTrevorClownsFight',
    },
    ['og_kush_low_weed'] = {
        effectType = 'sprint',
        progressTime = 5000,
        duration = 45000,
        sprintMult = 1.4,
        screenEffect = 'DrugsTrevorClownsFight',
        shake = { name = 'DRUNK_SHAKE', intensity = 0.1 },
    },

    -- Girl Scout Cookies
    ['gsc_high_weed'] = {
        effectType = 'light',
        progressTime = 1500,
        duration = 45000,
    },
    ['gsc_medium_weed'] = {
        effectType = 'light',
        progressTime = 3000,
        duration = 45000,
        screenEffect = 'DrugsTrevorClownsFight',
    },
    ['gsc_low_weed'] = {
        effectType = 'light',
        progressTime = 5000,
        duration = 45000,
        screenEffect = 'DrugsTrevorClownsFight',
        shake = { name = 'DRUNK_SHAKE', intensity = 0.1 },
    },
    
    ['indica_bud_dried_weed'] = {
        effectType = 'light',
        progressTime = 5000,
        duration = 30000,
        screenEffect = 'DrugsTrevorClownsFight',
        shake = { name = 'DRUNK_SHAKE', intensity = 0.15 },
        walkstyle = 'move_m@drunk@slightlydrunk',
    },
    ['sativa_bud_dried_weed'] = {
        effectType = 'light',
        progressTime = 5000,
        duration = 30000,
        screenEffect = 'DrugsTrevorClownsFight',
        shake = { name = 'DRUNK_SHAKE', intensity = 0.15 },
        walkstyle = 'move_m@drunk@slightlydrunk',
    },
    ['hybrid_bud_dried_weed'] = {
        effectType = 'light',
        progressTime = 5000,
        duration = 30000,
        screenEffect = 'DrugsTrevorClownsFight',
        shake = { name = 'DRUNK_SHAKE', intensity = 0.15 },
        walkstyle = 'move_m@drunk@slightlydrunk',
    },

}