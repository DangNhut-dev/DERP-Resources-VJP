local WeaponSkin = require 'modules.weaponskin.shared'

-- Map: original weapon hash -> skin weapon hash (build từ slots đã sync)
local skinHashMap = {}

local function rebuildSkinHashMap(slots)
    skinHashMap = {}
    if not slots then return end
    for i = 1, 25 do
        local data = slots[tostring(i)]
        if data and data.weapon and data.item then
            local weaponHash = joaat(data.weapon:lower())
            if not skinHashMap[weaponHash] then
                local replaceWeapon = WeaponSkin.GetReplaceWeapon(data.weapon:lower(), data.item)
                if replaceWeapon then
                    skinHashMap[weaponHash] = joaat(replaceWeapon)
                end
            end
        end
    end
end

--- Trả về skin weapon hash nếu có, không thì nil
---@param originalHash number
---@return number?
local function getEquipHash(originalHash)
    return skinHashMap[originalHash]
end

RegisterNetEvent('ox_inventory:syncWeaponSkinSlots', function(slots)
    SendNUIMessage({ action = 'syncWeaponSkinSlots', data = slots })
    rebuildSkinHashMap(slots)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == cache.resource then
        skinHashMap = {}
    end
end)

return {
    getEquipHash = getEquipHash,
}