Config = {}

-- 'always' = luôn bật khi cầm súng
-- 'key'    = bấm phím để bật/tắt
-- false    = tắt hoàn toàn
Config.Mode = 'always'

Config.ToggleKey = 'L'

-- Job được miễn animation (cầm súng bình thường)
Config.ExemptJobs = {
    ['police']    = true,
    ['ambulance'] = true,
}

-- Weapon không apply animation (dùng tên native GTA)
Config.BlacklistWeapons = {
    'weapon_musket',
}