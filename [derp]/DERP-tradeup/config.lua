Config = {}

Config.NPC = {
    model    = 'a_m_m_hasjew_01',
    coords   = vector4(141.02, -1038.36, 29.40, 58.67),
    scenario = 'WORLD_HUMAN_CLIPBOARD',
}

-- So luong nguyen lieu bat buoc moi lan trade-up
Config.RequiredCount = 9

-- Map rarity input -> rarity output
-- Rarity khong co trong bang nay = khong the trade-up (max tier)
Config.RarityUpgrade = {
    common    = 'rare',
    rare      = 'epic',
    epic      = 'legendary',
}

-- Cac rarity hop le (de validate input)
Config.ValidRarities = {
    common    = true,
    rare      = true,
    epic      = true,
    legendary = true,
    mythic    = true,
}