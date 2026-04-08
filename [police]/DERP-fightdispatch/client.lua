local cooldownActive = false
local meleeGroups = {}

for i = 1, #Config.MeleeWeaponGroups do
    meleeGroups[Config.MeleeWeaponGroups[i]] = true
end

local function IsMeleeWeapon(weaponHash)
    return meleeGroups[GetWeapontypeGroup(weaponHash)] == true
end

local function GetStreetName(coords)
    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    return GetStreetNameFromHashKey(streetHash) or 'Không xác định'
end

local function FindWitness(coords)
    local handle, ped = FindFirstPed()
    local found = false

    repeat
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped, false) then
            local dist = #(coords - GetEntityCoords(ped))
            if dist <= Config.WitnessMaxDistance then
                if not Config.RequireLos or HasEntityClearLosToEntity(ped, cache.ped, 17) then
                    found = true
                    break
                end
            end
        end
    until not FindNextPed(handle, ped)

    EndFindPed(handle)
    return found
end

AddEventHandler('gameEventTriggered', function(event, data)
    if event ~= 'CEventNetworkEntityDamage' then return end

    local victim = data[1]
    local attacker = data[2]

    if not IsPedAPlayer(victim) or not IsPedAPlayer(attacker) then return end
    if victim == cache.ped then return end
    if attacker ~= cache.ped then return end
    if cooldownActive then return end
    if not IsMeleeWeapon(data[7]) then return end

    local coords = GetEntityCoords(cache.ped)

    if Config.RequireWitness and not FindWitness(coords) then return end

    cooldownActive = true

    TriggerServerEvent('derp-fightdispatch:request', coords, GetStreetName(coords))

    SetTimeout(Config.Cooldown, function()
        cooldownActive = false
    end)
end)