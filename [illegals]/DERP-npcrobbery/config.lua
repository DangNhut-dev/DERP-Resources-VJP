Config = {}

Config.PlayerCooldown = 45 * 60 * 1000

Config.WhitelistedWeapons = {
    [`weapon_knife`]  = true,
    [`weapon_pistol`] = true,
}

Config.NpcResistChance    = 30  -- % NPC rút súng khi bắt đầu bị cướp
Config.NpcResistOnFail    = 0  -- % NPC rút súng khi fail progressbar
Config.ProgressDuration   = 45000

Config.Zones = {
    { id = 1, label = 'Túi áo',  color = '#e74c3c', bone = 11816, offset = vec3(-0.2, 0.2,  0.0) },  -- xuống, qua phải
    { id = 2, label = 'Ví tiền', color = '#c0392b', bone = 24816, offset = vec3(-0.1, 0.0,  0.0)  },
    { id = 3, label = 'Ba lô',   color = '#922b21', bone = 31086, offset = vec3(-0.2, 0.0, 0.0) },  -- lên
}

Config.ZoneReward = {
    cashMin  = 30,
    cashMax  = 150,
    itemChance = 25,
    items = {
        { item = 'phone',      chance = 50 },
        { item = 'watch',      chance = 40 },
        { item = 'lockpick', chance = 10 },
    },
}
