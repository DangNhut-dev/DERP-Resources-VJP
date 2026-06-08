Config = {}

Config.GrindLocations = {
    { coords = vec3(2438.31, 1516.80, 39.80), heading = 0.0, label = 'Bàn Kiểm định Đá' },
}

Config.CutLocations = {
    { coords = vec3(2436.18, 1515.89, 40.53), heading = 0.0, label = 'Máy Cắt Đá' },
}

Config.TargetRadius = 2.0

Config.ProgressTime = {
    grind_first  = 5000,
    grind_reroll = 4000,
    cut          = 6000,
}

Config.StoneRaw = 'stone'

Config.StoneItems = {
    ['stone_white']     = 'Trắng Đục',
    ['stone_lightblue'] = 'Xanh Nhạt',
    ['stone_green']     = 'Xanh Lục',
    ['stone_darkgreen'] = 'Lục Đậm',
}

Config.ColorPool = {
    { item = 'stone_white',     weight = 40 },
    { item = 'stone_lightblue', weight = 30 },
    { item = 'stone_green',     weight = 20 },
    { item = 'stone_darkgreen', weight = 10 },
}

Config.PurityLevels = {
    'Kém',
    'Thấp',
    'Khá',
    'Tốt',
    'Rất tốt',
    'Tuyệt hảo',
}

Config.Veins = {
    'Thô',
    'Mịn',
    'Trong',
    'Kính',
}

Config.ColorModifiers = {
    ['Trắng Đục'] = { waste = 1.4, rare = 0.6 },
    ['Xanh Nhạt'] = { waste = 1.0, rare = 1.1 },
    ['Xanh Lục']  = { waste = 0.8, rare = 1.3 },
    ['Lục Đậm']   = { waste = 0.6, rare = 1.6 },
}

Config.VeinModifiers = {
    ['Thô']   = { waste = 1.5, rare = 0.5 },
    ['Mịn']   = { waste = 1.0, rare = 1.0 },
    ['Trong'] = { waste = 0.8, rare = 1.3 },
    ['Kính']  = { waste = 0.5, rare = 1.7 },
}

Config.LuckyChance = 3

Config.LuckyTable = {
    { item = 'jade_dau_chung',           weight = 400 },
    { item = 'jade_nhu_chung',           weight = 250 },
    { item = 'jade_bang_chung',          weight = 150 },
    { item = 'jade_cao_bang',            weight = 80  },
    { item = 'jade_thuy_tinh',           weight = 25  },
    { item = 'jade_de_vuong_luc',        weight = 8   },
    { item = 'jade_de_vuong_luc_legend', weight = 2   },
}

Config.CutTable = {
    ['Kém'] = {
        { item = 'jade_waste',               weight = 700 },
        { item = 'jade_dau_chung',           weight = 200 },
        { item = 'jade_nhu_chung',           weight = 60  },
        { item = 'jade_bang_chung',          weight = 25  },
        { item = 'jade_cao_bang',            weight = 10  },
        { item = 'jade_thuy_tinh',           weight = 4   },
        { item = 'jade_de_vuong_luc',        weight = 1   },
        { item = 'jade_de_vuong_luc_legend', weight = 0   },
    },
    ['Thấp'] = {
        { item = 'jade_waste',               weight = 500 },
        { item = 'jade_dau_chung',           weight = 280 },
        { item = 'jade_nhu_chung',           weight = 150 },
        { item = 'jade_bang_chung',          weight = 50  },
        { item = 'jade_cao_bang',            weight = 15  },
        { item = 'jade_thuy_tinh',           weight = 4   },
        { item = 'jade_de_vuong_luc',        weight = 1   },
        { item = 'jade_de_vuong_luc_legend', weight = 0   },
    },
    ['Khá'] = {
        { item = 'jade_waste',               weight = 300 },
        { item = 'jade_dau_chung',           weight = 250 },
        { item = 'jade_nhu_chung',           weight = 250 },
        { item = 'jade_bang_chung',          weight = 140 },
        { item = 'jade_cao_bang',            weight = 40  },
        { item = 'jade_thuy_tinh',           weight = 15  },
        { item = 'jade_de_vuong_luc',        weight = 4   },
        { item = 'jade_de_vuong_luc_legend', weight = 1   },
    },
    ['Tốt'] = {
        { item = 'jade_waste',               weight = 150 },
        { item = 'jade_dau_chung',           weight = 150 },
        { item = 'jade_nhu_chung',           weight = 250 },
        { item = 'jade_bang_chung',          weight = 250 },
        { item = 'jade_cao_bang',            weight = 120 },
        { item = 'jade_thuy_tinh',           weight = 60  },
        { item = 'jade_de_vuong_luc',        weight = 15  },
        { item = 'jade_de_vuong_luc_legend', weight = 5   },
    },
    ['Rất tốt'] = {
        { item = 'jade_waste',               weight = 80  },
        { item = 'jade_dau_chung',           weight = 80  },
        { item = 'jade_nhu_chung',           weight = 150 },
        { item = 'jade_bang_chung',          weight = 250 },
        { item = 'jade_cao_bang',            weight = 250 },
        { item = 'jade_thuy_tinh',           weight = 130 },
        { item = 'jade_de_vuong_luc',        weight = 50  },
        { item = 'jade_de_vuong_luc_legend', weight = 10  },
    },
    ['Tuyệt hảo'] = {
        { item = 'jade_waste',               weight = 40  },
        { item = 'jade_dau_chung',           weight = 40  },
        { item = 'jade_nhu_chung',           weight = 80  },
        { item = 'jade_bang_chung',          weight = 150 },
        { item = 'jade_cao_bang',            weight = 300 },
        { item = 'jade_thuy_tinh',           weight = 250 },
        { item = 'jade_de_vuong_luc',        weight = 110 },
        { item = 'jade_de_vuong_luc_legend', weight = 30  },
    },
}