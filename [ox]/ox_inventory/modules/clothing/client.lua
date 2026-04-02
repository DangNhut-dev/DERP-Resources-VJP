local ClothingConfig = require 'modules.clothing.shared'
local BackpackClient = require 'modules.clothing.backpack_client'
local GloveAdminClient = require 'modules.clothing.glove_admin_client'
local ClothingClient = {}

-- Cache of current cloth slots from server
local currentClothSlots = {}
local lastAppliedHash = nil

-- Thêm helper check freemode
---@param ped number
---@return boolean
function ClothingClient.IsFreemodeModel(ped)
    local model = GetEntityModel(ped)
    return model == `mp_m_freemode_01` or model == `mp_f_freemode_01`
end

-- ── Ped Appearance ─────────────────────────────────────────────

---@param ped number
---@param def table ClothingConfig definition
---@param drawableId number
---@param textureId number
function ClothingClient.ApplyClothing(ped, def, drawableId, textureId)
    if not ClothingClient.IsFreemodeModel(ped) then return end
    if def.componentType == 'component' then
        SetPedComponentVariation(ped, def.componentId, drawableId, textureId, 0)
    elseif def.componentType == 'props' then
        if drawableId >= 0 then
            SetPedPropIndex(ped, def.componentId, drawableId, textureId, true)
        else
            ClearPedProp(ped, def.componentId)
        end
    end
end

---@param ped number
---@param def table ClothingConfig definition
---@param gender number 0=male, 1=female
function ClothingClient.RemoveClothing(ped, def, gender)
    if not ClothingClient.IsFreemodeModel(ped) then return end
    local genderKey = gender == 0 and 'male' or 'female'

    if def.componentType == 'props' then
        ClearPedProp(ped, def.componentId)
    else
        local defaults = ClothingConfig.defaults[genderKey]
        local default = defaults and defaults[def.componentId]

        if default then
            SetPedComponentVariation(ped, def.componentId, default.drawable, default.texture, 0)
        end
    end
end

-- ── Animation ──────────────────────────────────────────────────

---@param ped number
---@param action 'equip'|'unequip'|'swap'
---@param callback function Called after animation
function ClothingClient.PlayAnimation(ped, action, callback)
    local dict, anim, duration

    if action == 'equip' or action == 'swap' then
        dict = 'clothingtie'
        anim = 'try_tie_negative_a'
        duration = 1500
    else -- unequip
        dict = 'clothingtie'
        anim = 'try_tie_negative_a'
        duration = 1200
    end

    lib.requestAnimDict(dict)

    TaskPlayAnim(ped, dict, anim, 3.0, 3.0, duration, 49, 0, false, false, false)

    SetTimeout(duration - 200, function()
        if callback then callback() end
    end)

    SetTimeout(duration, function()
        ClearPedTasks(ped)
        RemoveAnimDict(dict)
    end)
end

-- ── Apply all cloth slots on ped (on spawn/load) ───────────────

---@param ped number
---@param clothSlots table<number, table>
---@param gender number 0=male, 1=female
function ClothingClient.ApplyAllClothSlots(ped, clothSlots, gender)
    for slot = 1, 15 do
        local itemName = ClothingConfig.GetItemBySlot(slot)
        if not itemName then goto continue end

        local def = ClothingConfig.GetDef(itemName)
        if not def then goto continue end

        local equipped = clothSlots[slot]
        if equipped then
            ClothingClient.ApplyClothing(ped, def, equipped.drawableId, equipped.textureId)
        else
            ClothingClient.RemoveClothing(ped, def, gender)
        end

        ::continue::
    end
end

-- ── Get player gender ──────────────────────────────────────────

---@return number 0=male, 1=female
function ClothingClient.GetPlayerGender()
    local ped = cache.ped
    local model = GetEntityModel(ped)

    if model == `mp_m_freemode_01` then
        return 0 -- male
    elseif model == `mp_f_freemode_01` then
        return 1 -- female
    end

    return 0 -- default male
end

-- ── NUI Events ─────────────────────────────────────────────────

RegisterNetEvent('ox_inventory:syncClothSlots', function(data)
    local clothSlots, gloveOptions

    if data and data.clothSlots then
        clothSlots = data.clothSlots
        gloveOptions = data.gloveOptions
    else
        clothSlots = data or {}
        gloveOptions = {}
    end

    currentClothSlots = clothSlots

    SendNUIMessage({
        action = 'syncClothSlots',
        data = {
            clothSlots = currentClothSlots,
            gloveOptions = gloveOptions or {},
            isFreemode = ClothingClient.IsFreemodeModel(cache.ped),
            hasDecalAccess = data.hasDecalAccess or false,
        },
    })

    local newHash = json.encode(clothSlots)
    if newHash ~= lastAppliedHash then
        lastAppliedHash = newHash
        local ped = cache.ped
        local gender = ClothingClient.GetPlayerGender()
        ClothingClient.ApplyAllClothSlots(ped, currentClothSlots, gender)
    end
end)

-- Server confirms equip/unequip/swap
RegisterNetEvent('ox_inventory:clothSlotUpdate', function(data)
    local ped = cache.ped
    local gender = ClothingClient.GetPlayerGender()

    if data.action == 'equip' or data.action == 'swap' then
        local itemName = ClothingConfig.GetItemBySlot(data.clothSlot)
        local def = ClothingConfig.GetDef(itemName)

        if def and data.data then
            currentClothSlots[data.clothSlot] = data.data

            ClothingClient.PlayAnimation(ped, data.action, function()
                ClothingClient.ApplyClothing(ped, def, data.data.drawableId, data.data.textureId)
            end)
        end
    elseif data.action == 'gloveSelect' then
        -- Glove modal selection: apply component 3 directly
        local def = ClothingConfig.GetDef('tay')
        if def and data.data then
            currentClothSlots[5] = data.data
            ClothingClient.ApplyClothing(ped, def, data.data.drawableId, data.data.textureId)
        end
    elseif data.action == 'unequip' then
        local itemName = ClothingConfig.GetItemBySlot(data.clothSlot)
        local def = ClothingConfig.GetDef(itemName)

        if def then
            ClothingClient.PlayAnimation(ped, 'unequip', function()
                ClothingClient.RemoveClothing(ped, def, gender)
            end)

            currentClothSlots[data.clothSlot] = nil
            -- Nếu unequip balo
            if data.clothSlot == 11 then
                BackpackClient.OnUnequip()
            end
        end
    end

    -- Sync to NUI
    lastAppliedHash = nil
    SendNUIMessage({
        action = 'syncClothSlots',
        data = {
            clothSlots = currentClothSlots,
            gloveOptions = {},
            isFreemode = ClothingClient.IsFreemodeModel(cache.ped),
        },
    })
end)

-- Request cloth slots when inventory opens
-- Add this call in client.openInventory after setupInventory
function ClothingClient.RequestSync()
    TriggerServerEvent('ox_inventory:requestClothSlots')
    TriggerServerEvent('ox_inventory:requestBackpackData')
end

-- NUI callback: equip item to cloth slot (drag from inventory)
RegisterNUICallback('clothSlotEquip', function(data, cb)
    TriggerServerEvent('ox_inventory:clothSlotEquip', {
        fromSlot = data.fromSlot,
        toClothSlot = data.toClothSlot,
    })
    cb('ok')
end)

-- NUI callback: unequip from cloth slot (drag out / right click)
RegisterNUICallback('clothSlotUnequip', function(data, cb)
    TriggerServerEvent('ox_inventory:clothSlotUnequip', {
        clothSlot = data.clothSlot,
        toSlot = data.toSlot,
    })
    cb('ok')
end)

-- NUI callback: glove modal selection
RegisterNUICallback('gloveSelect', function(data, cb)
    TriggerServerEvent('ox_inventory:gloveSelect', {
        drawable = data.drawable,
        texture = data.texture or 0,
        gender = ClothingClient.GetPlayerGender(),
    })
    cb('ok')
end)

-- NUI callback: equip cloth item FROM backpack TO cloth slot
RegisterNUICallback('clothSlotEquipFromBackpack', function(data, cb)
    TriggerServerEvent('ox_inventory:clothSlotEquipFromBackpack', {
        fromSlot = data.fromSlot,
        toClothSlot = data.toClothSlot,
    })
    cb('ok')
end)
 
-- NUI callback: unequip cloth item FROM cloth slot TO backpack
RegisterNUICallback('clothSlotUnequipToBackpack', function(data, cb)
    TriggerServerEvent('ox_inventory:clothSlotUnequipToBackpack', {
        clothSlot = data.clothSlot,
        toSlot = data.toSlot,
    })
    cb('ok')
end)
 

-- Getter for other resources
function ClothingClient.GetCurrentClothSlots()
    return currentClothSlots
end

-- ── Re-apply cloth slots after skin/appearance reload ──────────
-- illenium-appearance / fivem-appearance triggers this after saving
AddEventHandler('qb-clothing:client:loadPlayerClothing', function()
    lastAppliedHash = nil
    SetTimeout(500, function()
        local ped = cache.ped
        local gender = ClothingClient.GetPlayerGender()
        ClothingClient.ApplyAllClothSlots(ped, currentClothSlots, gender)
    end)
end)

-- illenium-appearance specific event
AddEventHandler('illenium-appearance:client:reloadSkin', function()
    lastAppliedHash = nil
    SetTimeout(500, function()
        local ped = cache.ped
        local gender = ClothingClient.GetPlayerGender()
        ClothingClient.ApplyAllClothSlots(ped, currentClothSlots, gender)
    end)
end)

-- Generic: after any ped model change, re-apply
lib.onCache('ped', function(ped)
    if not ped or not next(currentClothSlots) then return end
    lastAppliedHash = nil
    SetTimeout(1000, function()
        local gender = ClothingClient.GetPlayerGender()
        ClothingClient.ApplyAllClothSlots(cache.ped, currentClothSlots, gender)
    end)
end)

-- Export for other resources to trigger re-apply
exports('reapplyClothSlots', function()
    local ped = cache.ped
    local gender = ClothingClient.GetPlayerGender()
    ClothingClient.ApplyAllClothSlots(ped, currentClothSlots, gender)
end)

return ClothingClient