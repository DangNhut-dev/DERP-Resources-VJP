-- modules/weaponskin/server.lua
local WeaponSkin = require 'modules.weaponskin.shared'
local Inventory = require 'modules.inventory.server'

local weaponSkinCache = {}

local function loadWeaponSkinSlots(source)
    if weaponSkinCache[source] then
        return weaponSkinCache[source]
    end

    local inv = Inventory(source)
    if not inv or not inv.owner then return {} end

    local result = MySQL.scalar.await('SELECT weapon_skin_slots FROM players WHERE citizenid = ?', { inv.owner })

    local slots = {}
    if result then
        local decoded = json.decode(result)
        if type(decoded) == 'table' then
            for k, v in pairs(decoded) do
                if type(v) == 'table' and v.item and v.weapon then
                    slots[tonumber(k) or k] = v
                end
            end
        end
    end

    weaponSkinCache[source] = slots
    return slots
end

local function saveWeaponSkinSlots(source, slots)
    local inv = Inventory(source)
    if not inv or not inv.owner then return end
    local identifier = inv.owner

    weaponSkinCache[source] = slots
    MySQL.update('UPDATE players SET weapon_skin_slots = ? WHERE citizenid = ?', { json.encode(slots), identifier })
end

local function syncWeaponSkinSlots(source)
    local slots = loadWeaponSkinSlots(source)
    local Items = require 'modules.items.server'

    local nuiSlots = {}
    for slotIdx, data in pairs(slots) do
        local itemData = Items(data.item)
        if itemData then
            nuiSlots[tostring(slotIdx)] = {
                item    = data.item,
                weapon  = data.weapon,
                label   = itemData.label,
                image   = itemData.client and itemData.client.image or nil,
            }
        end
    end

    TriggerClientEvent('ox_inventory:syncWeaponSkinSlots', source, nuiSlots)
end

--- Kiểm tra toàn bộ slot 1-25, chống dupe và mapping lỗi
---@param source number
local function validateWeaponSkinSlots(source)
    local slots = loadWeaponSkinSlots(source)
    local playerInv = Inventory(source)
    if not playerInv then return end

    local dirty = false

    for slotIdx = 1, WeaponSkin.TOTAL_SLOTS do
        local slotData = slots[slotIdx]
        if slotData then
            for _, invItem in pairs(playerInv.items) do
                if invItem and invItem.name == slotData.item then
                    Inventory.RemoveItem(source, slotData.item, invItem.count or 1, nil, invItem.slot)
                    dirty = true
                    break
                end
            end
        end
    end

    if dirty then
        saveWeaponSkinSlots(source, slots)
        syncWeaponSkinSlots(source)
    end
end

local function equipWeaponSkin(source, fromSlot, toSlot)
    if type(fromSlot) ~= 'number' or type(toSlot) ~= 'number' then return false end
    if toSlot < 1 or toSlot > WeaponSkin.TOTAL_SLOTS then return false end

    local playerInv = Inventory(source)
    if not playerInv then return false end

    local item = playerInv.items[fromSlot]
    if not item or not item.name then return false end

    local weaponName = WeaponSkin.GetWeaponForSkin(item.name)
    if not weaponName then return false end

    local slots = loadWeaponSkinSlots(source)

    if slots[toSlot] then return false end

    local success = Inventory.RemoveItem(source, item.name, 1, nil, fromSlot)
    if not success then return false end

    slots[toSlot] = {
        item = item.name,
        weapon = weaponName,
    }

    saveWeaponSkinSlots(source, slots)
    syncWeaponSkinSlots(source)

    return true
end

local function unequipWeaponSkin(source, skinSlot, toInvSlot)
    if type(skinSlot) ~= 'number' then return false end
    if skinSlot < 1 or skinSlot > WeaponSkin.TOTAL_SLOTS then return false end

    local slots = loadWeaponSkinSlots(source)
    local slotData = slots[skinSlot]
    if not slotData then return false end

    local success = Inventory.AddItem(source, slotData.item, 1, nil, toInvSlot)
    if not success then return false end

    slots[skinSlot] = nil
    saveWeaponSkinSlots(source, slots)
    syncWeaponSkinSlots(source)
    return true
end

local function getActiveSkinModel(source, weaponName)
    local slots = loadWeaponSkinSlots(source)
    for i = 1, WeaponSkin.TOTAL_SLOTS do
        local slotData = slots[i]
        if slotData and slotData.weapon and slotData.weapon:lower() == weaponName then
            local replaceWeapon = WeaponSkin.GetReplaceWeapon(slotData.weapon:lower(), slotData.item)
            if replaceWeapon then return replaceWeapon end
        end
    end
    return nil
end

local function equipWeaponSkinFromBackpack(source, fromSlot, toSlot)
    if type(fromSlot) ~= 'number' or type(toSlot) ~= 'number' then return false end
    if toSlot < 1 or toSlot > WeaponSkin.TOTAL_SLOTS then return false end

    local BackpackServer = require 'modules.clothing.backpack_server'
    local bp = BackpackServer.GetPlayerBackpack(source)
    if not bp then return false end

    local backpackInv = Inventory(bp.stashName)
    if not backpackInv then return false end

    local item = backpackInv.items[fromSlot]
    if not item or not item.name then return false end

    local weaponName = WeaponSkin.GetWeaponForSkin(item.name)
    if not weaponName then return false end

    local slots = loadWeaponSkinSlots(source)
    if slots[toSlot] then return false end

    local Items = require 'modules.items.server'
    local itemDef = Items(item.name)
    if not itemDef then return false end

    local itemName = item.name
    local removeWeight = Inventory.SlotWeight(itemDef, { count = 1, metadata = item.metadata })

    item.count = item.count - 1
    if item.count < 1 then
        backpackInv.items[fromSlot] = nil
    else
        item.weight = Inventory.SlotWeight(itemDef, item)
    end

    backpackInv.weight = backpackInv.weight - removeWeight
    backpackInv.changed = true

    TriggerClientEvent('ox_inventory:backpackUpdate', source, {
        items = backpackInv.items,
        weight = backpackInv.weight,
    })

    slots[toSlot] = {
        item   = itemName,
        weapon = weaponName,
    }

    saveWeaponSkinSlots(source, slots)
    syncWeaponSkinSlots(source)
    return true
end

local function unequipWeaponSkinToBackpack(source, skinSlot, toSlot)
    if type(skinSlot) ~= 'number' or type(toSlot) ~= 'number' then return false end
    if skinSlot < 1 or skinSlot > WeaponSkin.TOTAL_SLOTS then return false end

    local BackpackServer = require 'modules.clothing.backpack_server'
    local bp = BackpackServer.GetPlayerBackpack(source)
    if not bp then return false end

    local backpackInv = Inventory(bp.stashName)
    if not backpackInv then return false end

    if toSlot < 1 or toSlot > (backpackInv.slots or 0) then return false end
    if backpackInv.items[toSlot] then return false end

    local slots = loadWeaponSkinSlots(source)
    local slotData = slots[skinSlot]
    if not slotData then return false end

    local Items = require 'modules.items.server'
    local itemDef = Items(slotData.item)
    if not itemDef then return false end

    local addWeight = Inventory.SlotWeight(itemDef, { count = 1, metadata = {} })
    if backpackInv.weight + addWeight > backpackInv.maxWeight then return false end

    backpackInv.items[toSlot] = {
        name     = slotData.item,
        count    = 1,
        slot     = toSlot,
        metadata = {},
        weight   = addWeight,
        label    = itemDef.label,
        description = itemDef.description,
        stack    = itemDef.stack,
        close    = itemDef.close,
    }
    backpackInv.weight  = backpackInv.weight + addWeight
    backpackInv.changed = true

    TriggerClientEvent('ox_inventory:backpackUpdate', source, {
        items  = backpackInv.items,
        weight = backpackInv.weight,
    })

    slots[skinSlot] = nil
    saveWeaponSkinSlots(source, slots)
    syncWeaponSkinSlots(source)
    return true
end

-- ── Callbacks ────────────────────────────────────────────────

lib.callback.register('ox_inventory:equipWeaponSkin', function(source, fromSlot, toSlot)
    return equipWeaponSkin(source, fromSlot, toSlot)
end)

lib.callback.register('ox_inventory:unequipWeaponSkin', function(source, skinSlot, toInvSlot)
    return unequipWeaponSkin(source, skinSlot, tonumber(toInvSlot))
end)

lib.callback.register('ox_inventory:getWeaponSkinModel', function(source, weaponName)
    if type(weaponName) ~= 'string' then return nil end
    return getActiveSkinModel(source, weaponName:lower())
end)

lib.callback.register('ox_inventory:moveSkinSlot', function(source, fromSlot, toSlot)
    if type(fromSlot) ~= 'number' or type(toSlot) ~= 'number' then return false end
    if fromSlot < 1 or fromSlot > WeaponSkin.TOTAL_SLOTS then return false end
    if toSlot < 1 or toSlot > WeaponSkin.TOTAL_SLOTS then return false end
    if fromSlot == toSlot then return false end

    local slots = loadWeaponSkinSlots(source)
    if not slots[fromSlot] then return false end

    local temp = slots[toSlot]
    slots[toSlot] = slots[fromSlot]
    slots[fromSlot] = temp  

    saveWeaponSkinSlots(source, slots)
    syncWeaponSkinSlots(source)
    return true
end)

lib.callback.register('ox_inventory:equipWeaponSkinFromBackpack', function(source, fromSlot, toSlot)
    return equipWeaponSkinFromBackpack(source, fromSlot, toSlot)
end)

lib.callback.register('ox_inventory:unequipWeaponSkinToBackpack', function(source, skinSlot, toSlot)
    return unequipWeaponSkinToBackpack(source, skinSlot, toSlot)
end)

-- ── Events ───────────────────────────────────────────────────

RegisterNetEvent('ox_inventory:requestWeaponSkinSync', function()
    local source = source
    validateWeaponSkinSlots(source)
    syncWeaponSkinSlots(source)
end)

AddEventHandler('playerDropped', function()
    weaponSkinCache[source] = nil
end)

RegisterNetEvent('ox_inventory:clearPlayerInventory', function()
    weaponSkinCache[source] = nil
end)

return {
    loadWeaponSkinSlots = loadWeaponSkinSlots,
    saveWeaponSkinSlots = saveWeaponSkinSlots,
    syncWeaponSkinSlots = syncWeaponSkinSlots,
    validateWeaponSkinSlots = validateWeaponSkinSlots,
    getActiveSkinModel = getActiveSkinModel,
}