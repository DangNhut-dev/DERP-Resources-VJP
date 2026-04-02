Config = {}

Config.NPC = {
    model  = 's_m_y_factory_01',
    coord  = vector4(757.60, -917.36, 24.29, 91.50),
    frozen = true,
    invincible = true,
    blockevents = true,
}

Config.Zone = {
    coord  = vector3(741.90, -924.36, 24.98),
    radius = 20.0,
}

Config.Work = {
    interval     = 60000,
    item         = 'cut_paper',
    itemLabel    = 'Giấy Cắt',
    requiredItem = 'scissors',
    itemAmount   = 1,
    doubleAmount = 2,
    doubleRewardDuration = 60000,

    minigame = {
        minDelay = 180000,
        maxDelay = 300000,
        export   = 'boii_minigames',
        game     = 'key_drop',
        params   = {
            style            = 'default',
            score_limit      = 5,
            miss_limit       = 5,
            fall_delay       = 1000,
            new_letter_delay = 2000,
        },
    },
}

Config.Anim = {
    base = {
        dict = 'anim@scripted@island@special_peds@dave@yoga@',
        anim = 'idle_f',
        flag = 1,
    },
    upper = {
        dict = 'mini@repair',
        anim = 'fixing_a_ped',
        flag = 49,
    },
}

Config.TextUI = {
    start = '[G] - Bắt đầu cắt giấy',
    stop  = '[G] - Dừng cắt giấy',
}

Config.Blip = {
    sprite = 478,
    color  = 2,
    scale  = 0.7,
    label  = 'Xưởng Cắt Giấy',
}

Config.Target = {
    icon     = 'fas fa-briefcase',
    onDuty   = 'Đăng Ký Làm',
    offDuty  = 'Xin Nghỉ',
    distance = 2.5,
}

Config.OxInventoryItem = {
    cut_paper = {
        label  = 'Giấy Cắt',
        weight = 50,
    },
}