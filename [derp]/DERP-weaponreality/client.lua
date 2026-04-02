if not Config.Mode then return end

local CLIPSET = 'move_ped_wpn_jerrycan_generic'

local isEnabled = Config.Mode == 'always'
local isExempt = false
local clipsetApplied = false
local clipsetLoaded = false

-- Cache blacklist thành hash set một lần duy nhất
local blacklistedHashes = {}
for _, weaponName in ipairs(Config.BlacklistWeapons) do
    blacklistedHashes[GetHashKey(weaponName)] = true
end

local function checkJobExempt()
    local playerData = exports.qbx_core and exports.qbx_core:GetPlayerData()
        or exports['qb-core']:GetCoreObject().Functions.GetPlayerData()
    if playerData and playerData.job and playerData.job.onduty then
        return Config.ExemptJobs[playerData.job.name] or false
    end
    return false
end

-- Request và block đến khi clipset thực sự loaded vào memory
local function preloadClipset()
    if clipsetLoaded then return end
    RequestAnimSet(CLIPSET)
    local timeout = 0
    while not HasAnimSetLoaded(CLIPSET) and timeout < 100 do
        Wait(100)
        timeout = timeout + 1
    end
    clipsetLoaded = HasAnimSetLoaded(CLIPSET)
end

if Config.Mode == 'key' then
    RegisterCommand('tommy_weaponanim_toggle', function()
        isEnabled = not isEnabled
        if not isEnabled and clipsetApplied then
            ResetPedWeaponMovementClipset(cache.ped, 0.0)
            clipsetApplied = false
        end
        exports.ox_lib:notify({
            description = isEnabled and 'Weapon animation: BẬT' or 'Weapon animation: TẮT',
            type = 'inform',
        })
    end, false)
    RegisterKeyMapping('tommy_weaponanim_toggle', 'Bật/Tắt weapon animation', 'keyboard', Config.ToggleKey)
end

RegisterNetEvent('QBCore:Client:OnJobUpdate', function()
    isExempt = checkJobExempt()
    if isExempt and clipsetApplied then
        ResetPedWeaponMovementClipset(cache.ped, 0.0)
        clipsetApplied = false
    end
end)

CreateThread(function()
    while not LocalPlayer.state.isLoggedIn do Wait(500) end
    isExempt = checkJobExempt()
    Wait(1000)
    preloadClipset()
end)

lib.onCache('ped', function()
    clipsetApplied = false
    clipsetLoaded = false
    Wait(1000)
    preloadClipset()
end)

CreateThread(function()
    while true do
        local ped = cache.ped
        local armed = IsPedArmed(ped, 4)

        local currentWeapon = GetSelectedPedWeapon(ped)
        local isBlacklisted = blacklistedHashes[currentWeapon] or false

        if isEnabled and not isExempt and armed and not isBlacklisted then
            if not clipsetApplied then
                if clipsetLoaded then
                    SetPedWeaponMovementClipset(ped, CLIPSET, 0.50)
                    clipsetApplied = true
                end
            end
            Wait(500)
        else
            if clipsetApplied then
                ResetPedWeaponMovementClipset(ped, 0.0)
                clipsetApplied = false
            end
            Wait(1000)
        end
    end
end)