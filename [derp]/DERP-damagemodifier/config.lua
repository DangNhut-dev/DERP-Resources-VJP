-----------------------------------------------------------------------------
-- Script made by LGD
-----------------------------------------------------------------------------
-- Weapons list: https://www.vespura.com/fivem/weapons/stats/
-----------------------------------------------------------------------------
-- weapon_name: weapon's name 
-----------------------------------------------------------------------------
-- damage_multiplier: default is 1.0
-- Example: 0.4 is 40% the original damage
-----------------------------------------------------------------------------
-- Disabling headshots will make them count as torso damage not a 1 kill shot
-----------------------------------------------------------------------------


Config = {}

Config.Weapons = {
    { weapon_name = 'WEAPON_UNARMED', damage_multiplier = 0.25 },
    { weapon_name = 'weapon_knife', damage_multiplier = 0.25 }, 
    { weapon_name = 'weapon_nightstick', damage_multiplier = 0.5 },
    { weapon_name = 'weapon_katana', damage_multiplier = 0.3 },
    { weapon_name = 'WEAPON_SLEDGEHAMMER', damage_multiplier = 0.3 }, 
    { weapon_name = 'WEAPON_colbaton', damage_multiplier = 0.5 }, 
    { weapon_name = 'WEAPON_PERFORATOR', damage_multiplier = 5.0 }, 

}

Config.Headshots = true -- true: headshots enabled / false: headshots disabled
