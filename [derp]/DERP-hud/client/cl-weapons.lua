-- Weapon hash to name mapping table
local weaponHashes = {}

-- Populate weapon hash table from config
for weaponName in pairs(Config.WeaponNames or {}) do
    local hash = joaat(weaponName)
    weaponHashes[hash] = weaponName
end

-- Get weapon data for display
function GetWeaponData(weaponHash)
    if not Config.ShowComponents or not Config.ShowComponents.weapon then
        return false
    end

    if weaponHash == nil then
        weaponHash = cache.weapon
    end

    if not weaponHash then
        return false
    end

    local weaponRawKey = weaponHashes[weaponHash] or ''   -- giữ chữ hoa để lookup config
    local weaponKey    = string.lower(weaponRawKey)        -- lowercase chỉ để làm path ảnh
    local weaponName   = weaponKey

    if Config.BlacklistWeaponUI[weaponKey] then
        return false
    end

    if Config.WeaponNames and Config.WeaponNames[weaponRawKey] then
        weaponName = Config.WeaponNames[weaponRawKey]
    end

    local isVehicleWeapon, vehicleWeaponIndex = GetCurrentPedVehicleWeapon(cache.ped)
    if isVehicleWeapon then
        weaponName = "Vehicle Weapon"
    end

    local totalAmmo
    if isVehicleWeapon then
        totalAmmo = GetVehicleWeaponRestrictedAmmo(cache.vehicle, vehicleWeaponIndex) or
                    GetAmmoInPedWeapon(cache.ped, weaponHash)
    else
        totalAmmo = GetAmmoInPedWeapon(cache.ped, weaponHash)
    end

    totalAmmo = tonumber(totalAmmo) or 0

    return {
        weaponHash  = weaponKey,   -- "weapon_pistol" → path ảnh ox_inventory
        weaponName  = weaponName,  -- display label từ Config.WeaponNames
        reserveAmmo = totalAmmo,
        clipAmmo    = 0,
    }
end

-- Send weapon data to NUI
local function SendWeaponDataToNUI(weaponHash)
    SendNUIMessage({
        type = "weaponData",
        weaponData = GetWeaponData(weaponHash)
    })
end

-- Flag to track if weapon monitoring thread is running
local isMonitoringWeapon = false

-- Create thread to monitor weapon ammo updates
local function StartWeaponMonitoring()
    CreateThread(function()
        Wait(10)
        
        -- Check if weapon display is enabled
        if not Config.ShowComponents or not Config.ShowComponents.weapon then
            return
        end
        
        -- Check if player has a weapon
        if not cache.ped or not cache.weapon then
            return
        end
        
        -- Prevent multiple monitoring threads
        if isMonitoringWeapon then
            return
        end
        
        isMonitoringWeapon = true
        
        -- Monitor weapon while player has it equipped
        while cache.ped and cache.weapon and IsHudRunning do
            Wait(1000)
            SendWeaponDataToNUI(cache.weapon)
        end
        
        isMonitoringWeapon = false
    end)
end

-- Check and display weapon data on player load
function CheckWeaponOnLoad()
    if Config.ShowComponents and Config.ShowComponents.weapon then
        if cache.weapon then
            SendWeaponDataToNUI(cache.weapon)
            StartWeaponMonitoring()
        end
    end
end

-- Register weapon change listener
if Config.ShowComponents and Config.ShowComponents.weapon then
    -- Listen for weapon cache changes
    lib.onCache("weapon", function(newWeapon)
        SendWeaponDataToNUI(newWeapon)
        StartWeaponMonitoring()
    end)
    
    -- Listen for gunshot events to update ammo display
    AddEventHandler("CEventGunShot", function(entities, shooter)
        -- Only update if the shooter is the player
        if shooter ~= cache.ped then
            return
        end
        
        SendWeaponDataToNUI(cache.weapon)
        StartWeaponMonitoring()
    end)
end