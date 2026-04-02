-- sv_blacklistweapon.lua

local blacklistedWeaponHashes = {
    GetHashKey('WEAPON_MUSKET'),
}

local function isBlacklisted(weaponHash)
    for _, hash in ipairs(blacklistedWeaponHashes) do
        if hash == weaponHash then return true end
    end
    return false
end

AddEventHandler('entityDamaged', function(victim, attacker, weaponHash, baseDamage)
    if not victim or not attacker then return end
    if not isBlacklisted(weaponHash) then return end
    if GetEntityType(victim) ~= 1 then return end
    if not IsPedAPlayer(victim) then return end

    local victimSrc = NetworkGetEntityOwner(victim)
    if not victimSrc then return end

    local curHealth = GetEntityHealth(victim)
    local maxHealth = GetEntityMaxHealth(victim)
    SetEntityHealth(victim, math.min(math.floor(curHealth + baseDamage), maxHealth))
end)