local WeaponSkin = {}

WeaponSkin.Config = {
    ['weapon_knife'] = {
        ['skinfadebutterfly'] = { replaceWeapon = 'WEAPON_FADEBFKNIFE' },
        ['skinbayonetknife'] = {replaceWeapon ='WEAPON_BAYONETKNIFE'},
        ['skinvanillabfknife'] = {replaceWeapon ='WEAPON_BFKNIFE'},
        ['skinchbfnife'] = {replaceWeapon ='WEAPON_CHBFKNIFE'},
        ['skincrimsonbfknife'] = {replaceWeapon ='WEAPON_CRIMSONBFKNIFE'},
        ['skinflipknife'] = {replaceWeapon ='WEAPON_FLIPKNIFE'},
        ['skinforestbfknife'] = {replaceWeapon ='WEAPON_FORESTBFKNIFE'},
        ['skingutknife'] = {replaceWeapon ='WEAPON_GUTKNIFE'},
        ['skinhuntsmanknife'] = {replaceWeapon ='WEAPON_HUNTSMANKNIFE'},
        ['skinsafaribfknife'] = {replaceWeapon ='WEAPON_SAFARIBFKNIFE'},
        ['skinscorchedbfknife'] = {replaceWeapon ='WEAPON_SCORCHEDBFKNIFE'},
        ['skinslaughterbfknife'] = {replaceWeapon ='WEAPON_SLAUGHTERBFKNIFE'},
        ['skinstainedrbfknife'] = {replaceWeapon ='WEAPON_STAINEDRBFKNIFE'},
        ['skinurbanrbfknife'] = {replaceWeapon ='WEAPON_URBANRBFKNIFE'},
        ['skinblueknife'] = {replaceWeapon ='WEAPON_BLUEBFKNIFE'},
    },
    ['weapon_ar15full'] = {
        ['skinar15fullpurple'] = { replaceWeapon = 'WEAPON_AR15FULLPURPLE' },
        ['skinar15fullwhite'] = { replaceWeapon = 'WEAPON_AR15FULLWHITE' },
    },
}

local TOTAL_SLOTS = 25

function WeaponSkin.GetWeaponForSkin(itemName)
    for weaponName, skins in pairs(WeaponSkin.Config) do
        if skins[itemName] then
            return weaponName
        end
    end
    return nil
end

function WeaponSkin.GetReplaceWeapon(weaponName, skinName)
    local weapon = WeaponSkin.Config[weaponName:lower()]
    if not weapon then return nil end
    local skin = weapon[skinName]
    return skin and skin.replaceWeapon or nil
end

function WeaponSkin.FindMatchingSkin(slots, weaponName)
    local lowerWeapon = weaponName:lower()
    for i = 1, TOTAL_SLOTS do
        local slot = slots[i]
        if slot and slot.weapon == lowerWeapon then
            local replaceWeapon = WeaponSkin.GetReplaceWeapon(lowerWeapon, slot.item)
            if replaceWeapon then
                return slot.item, replaceWeapon
            end
        end
    end
    return nil, nil
end

WeaponSkin.TOTAL_SLOTS = TOTAL_SLOTS

return WeaponSkin