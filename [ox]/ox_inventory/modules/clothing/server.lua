local ClothingConfig = require 'modules.clothing.shared'
local Inventory = require 'modules.inventory.server'
local Items = require 'modules.items.server'
local BackpackServer = require 'modules.clothing.backpack_server'
local GloveAdmin = require 'modules.clothing.glove_admin'

local ClothingServer = {}

-- ── Helper: trích field hiển thị từ cloth slot ─────────────────
-- Client/NUI cần flat data (drawableId, textureId, gender...)
-- Hàm này build payload gửi xuống client từ cloth slot mới
---@param slot table { name, metadata }
---@return table
local function BuildClientData(slot)
    if not slot then return nil end
    local meta = slot.metadata or {}
    return {
        name = slot.name,
        drawableId = meta.drawableId,
        textureId = meta.textureId,
        gender = meta.gender,
        level = meta.level,
        idbalo = meta.idbalo,
    }
end

-- ── Helper: build client-friendly cloth slots table ────────────
---@param clothSlots table<number, table>
---@return table<number, table>
local function BuildClientClothSlots(clothSlots)
    local result = {}
    for slot, data in pairs(clothSlots) do
        result[slot] = BuildClientData(data)
    end
    return result
end

-- ── Sync skin data with illenium-appearance (playerskins table) ─
---@param identifier string citizenid
---@param def table ClothingConfig definition
---@param drawableId number
---@param textureId number
function ClothingServer.SyncSkinData(identifier, def, drawableId, textureId)
    local skinJson = MySQL.scalar.await('SELECT skin FROM playerskins WHERE citizenid = ?', { identifier })
    if not skinJson then return end

    local skin = json.decode(skinJson)
    if not skin then return end

    if def.componentType == 'component' then
        if skin.components then
            for _, comp in ipairs(skin.components) do
                if comp.component_id == def.componentId then
                    comp.drawable = drawableId
                    comp.texture = textureId
                    break
                end
            end
        end
    elseif def.componentType == 'props' then
        if skin.props then
            for _, prop in ipairs(skin.props) do
                if prop.prop_id == def.componentId then
                    prop.drawable = drawableId
                    prop.texture = textureId
                    break
                end
            end
        end
    end

    MySQL.update.await('UPDATE playerskins SET skin = ? WHERE citizenid = ?', { json.encode(skin), identifier })
end

-- ── Sync skin data on unequip (reset to default) ──────────────
---@param identifier string citizenid
---@param def table ClothingConfig definition
---@param gender number 0=male, 1=female
function ClothingServer.SyncSkinDataDefault(identifier, def, gender)
    local genderKey = gender == 0 and 'male' or 'female'

    if def.componentType == 'props' then
        local defaultDrawable = ClothingConfig.defaults.props[def.componentId] or -1
        ClothingServer.SyncSkinData(identifier, def, defaultDrawable, -1)
    else
        local defaults = ClothingConfig.defaults[genderKey]
        local default = defaults and defaults[def.componentId]
        if default then
            ClothingServer.SyncSkinData(identifier, def, default.drawable, default.texture)
        end
    end
end

-- ── Database ───────────────────────────────────────────────────
---@param identifier string Player identifier
---@return table<number, table> clothData
function ClothingServer.LoadClothSlots(identifier)
    local result = MySQL.scalar.await('SELECT cloth_slots FROM players WHERE citizenid = ?', { identifier })

    if result then
        local decoded = json.decode(result)
        if decoded then
            local data = {}
            for k, v in pairs(decoded) do
                data[tonumber(k)] = v
            end
            return data
        end
    end

    return {}
end

---@param identifier string
---@param clothData table<number, table>
function ClothingServer.SaveClothSlots(identifier, clothData)
    local encoded = json.encode(clothData)
    MySQL.update.await('UPDATE players SET cloth_slots = ? WHERE citizenid = ?', { encoded, identifier })
end

-- ── Player cloth slots cache ───────────────────────────────────
local playerClothSlots = {}

---@param source number
---@return table<number, table>
function ClothingServer.GetPlayerClothSlots(source)
    return playerClothSlots[source] or {}
end

---@param source number
---@param slot number
---@return table|nil
function ClothingServer.GetClothSlot(source, slot)
    local slots = playerClothSlots[source]
    return slots and slots[slot]
end

-- ── Init / Cleanup ─────────────────────────────────────────────
---@param source number
---@param identifier string
function ClothingServer.InitPlayer(source, identifier)
    playerClothSlots[source] = ClothingServer.LoadClothSlots(identifier)
end

---@param source number
---@param identifier string
function ClothingServer.SaveAndCleanup(source, identifier)
    BackpackServer.OnPlayerDropped(source)
    if playerClothSlots[source] then
        ClothingServer.SaveClothSlots(identifier, playerClothSlots[source])
        playerClothSlots[source] = nil
    end
end

-- ── Equip ──────────────────────────────────────────────────────
---@param source number
---@param fromSlot number Inventory slot
---@param toClothSlot number Cloth slot (1-14)
---@return boolean success
---@return string|nil error
function ClothingServer.Equip(source, fromSlot, toClothSlot)
    local inv = Inventory(source)
    if not inv then return false, 'no_inventory' end

    local targetItemName = ClothingConfig.GetItemBySlot(toClothSlot)
    if not targetItemName then return false, 'invalid_cloth_slot' end

    local def = ClothingConfig.GetDef(targetItemName)
    if not def then return false, 'invalid_cloth_def' end

    local item = inv.items[fromSlot]
    if not item then return false, 'no_item' end

    if item.name ~= targetItemName then
        return false, 'wrong_item_type'
    end

    local meta = item.metadata
    if not meta or meta.drawableId == nil or meta.textureId == nil or meta.gender == nil then
        return false, 'invalid_metadata'
    end

    local ped = GetPlayerPed(source)
    local model = GetEntityModel(ped)

    if model == `mp_m_freemode_01` or model == `mp_f_freemode_01` then
        local playerGender = model == `mp_m_freemode_01` and 0 or 1
        if meta.gender ~= playerGender then
            return false, 'Không thể mặc (Sai giới tính)'
        end
    end

    local clothSlots = playerClothSlots[source] or {}
    local currentEquipped = clothSlots[toClothSlot]

    if currentEquipped then
        local oldMeta = currentEquipped.metadata and table.clone(currentEquipped.metadata) or {}

        local removed = Inventory.RemoveItem(source, item.name, 1, nil, fromSlot)
        if not removed then return false, 'remove_failed' end

        local added = Inventory.AddItem(source, currentEquipped.name, 1, oldMeta, fromSlot)
        if not added then
            Inventory.AddItem(source, item.name, 1, meta)
            return false, 'add_failed'
        end

        clothSlots[toClothSlot] = {
            name = item.name,
            metadata = table.clone(meta),
        }
    else
        local removed = Inventory.RemoveItem(source, item.name, 1, nil, fromSlot)
        if not removed then return false, 'remove_failed' end

        clothSlots[toClothSlot] = {
            name = item.name,
            metadata = table.clone(meta),
        }
    end

    playerClothSlots[source] = clothSlots

    local identifier = inv.owner
    if identifier then
        ClothingServer.SaveClothSlots(identifier, clothSlots)
        ClothingServer.SyncSkinData(identifier, def, meta.drawableId, meta.textureId)

        if toClothSlot == 11 and clothSlots[11] then
            local updated = BackpackServer.EnsureBackpackId(source, clothSlots[11])
            if updated and updated.idbalo then
                clothSlots[11].metadata = updated
                playerClothSlots[source] = clothSlots
                if identifier then
                    ClothingServer.SaveClothSlots(identifier, clothSlots)
                end
            end
        end
    end

    return true
end

-- ── Unequip ────────────────────────────────────────────────────
---@param source number
---@param clothSlot number Cloth slot (1-14)
---@param toSlot? number Target inventory slot (optional)
---@return boolean success
---@return string|nil error
function ClothingServer.Unequip(source, clothSlot, toSlot)
    local inv = Inventory(source)
    if not inv then return false, 'no_inventory' end

    local clothSlots = playerClothSlots[source] or {}
    local equipped = clothSlots[clothSlot]

    if not equipped then return false, 'slot_empty' end

    if toSlot then
        local targetItem = inv.items[toSlot]
        if targetItem and targetItem.name then
            return false, 'slot_occupied'
        end
    end

    local itemName = ClothingConfig.GetItemBySlot(clothSlot)
    local def = itemName and ClothingConfig.GetDef(itemName)

    local meta = equipped.metadata and table.clone(equipped.metadata) or {}

    local added = Inventory.AddItem(source, equipped.name, 1, meta, toSlot)
    if not added then return false, 'inventory_full' end

    local gender = meta.gender or 0

    clothSlots[clothSlot] = nil
    playerClothSlots[source] = clothSlots

    local identifier = inv.owner
    if identifier then
        ClothingServer.SaveClothSlots(identifier, clothSlots)
        if def then
            ClothingServer.SyncSkinDataDefault(identifier, def, gender)
        end
    end

    return true
end

-- ── NUI Callbacks (server events) ──────────────────────────────

RegisterNetEvent('ox_inventory:clothSlotEquip', function(data)
    local source = source
    if not data or not data.fromSlot or not data.toClothSlot then return end

    local success, err = ClothingServer.Equip(source, data.fromSlot, data.toClothSlot)

    if success then
        local clothSlots = ClothingServer.GetPlayerClothSlots(source)
        local equipped = clothSlots[data.toClothSlot]

        if data.toClothSlot == 11 and equipped then
            local updated = BackpackServer.EnsureBackpackId(source, equipped)
            if updated and updated.idbalo and not (equipped.metadata or {}).idbalo then
                equipped.metadata = updated
                local inv = Inventory(source)
                if inv and inv.owner then
                    ClothingServer.SaveClothSlots(inv.owner, clothSlots)
                end
            end
        end

        TriggerClientEvent('ox_inventory:clothSlotUpdate', source, {
            action = (clothSlots[data.toClothSlot] and 'swap' or 'equip'),
            clothSlot = data.toClothSlot,
            data = BuildClientData(equipped),
        })

        if data.toClothSlot == 11 and equipped then
            local info = BackpackServer.OpenBackpack(source, equipped.metadata or {})
            TriggerClientEvent('ox_inventory:backpackData', source, info)
        end
    else
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = err or 'Không thể mặc đồ'
        })
    end
end)

RegisterNetEvent('ox_inventory:clothSlotUnequip', function(data)
    local source = source
    if not data or not data.clothSlot then return end

    if data.clothSlot == 11 then
        BackpackServer.CloseBackpack(source)
        TriggerClientEvent('ox_inventory:backpackData', source, nil)
    end

    local success, err = ClothingServer.Unequip(source, data.clothSlot, data.toSlot)

    if success then
        TriggerClientEvent('ox_inventory:clothSlotUpdate', source, {
            action = 'unequip',
            clothSlot = data.clothSlot,
        })
    else
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = err or 'Không thể cởi đồ'
        })
    end
end)

-- ── Glove Selector ─────────────────────────────────────────────
RegisterNetEvent('ox_inventory:gloveSelect', function(data)
    local source = source
    if not data or data.drawable == nil then return end

    local inv = Inventory(source)
    if not inv then return end

    local player = exports.qbx_core and exports.qbx_core:GetPlayer(source)
        or exports['qb-core']:GetCoreObject().Functions.GetPlayer(source)
    local job = player and player.PlayerData.job.name or ''
    local citizenId = player and player.PlayerData.citizenid or ''

    local gender = data.gender or 0
    local allowedOptions = ClothingConfig.GetGloveOptions(job, citizenId, gender)
    local isAllowed = false
    for _, opt in ipairs(allowedOptions) do
        if opt.drawable == data.drawable and opt.texture == (data.texture or 0) then
            isAllowed = true
            break
        end
    end

    if not isAllowed then
        return TriggerClientEvent('ox_lib:notify', source, {
            type = 'error', description = 'Không có quyền chọn găng tay này'
        })
    end

    local clothSlots = playerClothSlots[source] or {}

    clothSlots[5] = {
        name = 'tay',
        metadata = {
            drawableId = data.drawable,
            textureId = data.texture or 0,
            gender = gender,
        },
    }

    playerClothSlots[source] = clothSlots

    local identifier = inv.owner
    if identifier then
        ClothingServer.SaveClothSlots(identifier, clothSlots)
        local def = ClothingConfig.GetDef('tay')
        if def then
            ClothingServer.SyncSkinData(identifier, def, data.drawable, data.texture or 0)
        end
    end

    TriggerClientEvent('ox_inventory:clothSlotUpdate', source, {
        action = 'gloveSelect',
        clothSlot = 5,
        data = BuildClientData(clothSlots[5]),
    })
end)

-- Send cloth slots + glove options to client on inventory open
RegisterNetEvent('ox_inventory:requestClothSlots', function()
    local source = source
    local clothSlots = ClothingServer.GetPlayerClothSlots(source)

    local player = exports.qbx_core and exports.qbx_core:GetPlayer(source)
        or exports['qb-core']:GetCoreObject().Functions.GetPlayer(source)
    local job = player and player.PlayerData.job.name or ''
    local citizenId = player and player.PlayerData.citizenid or ''

    local ped = GetPlayerPed(source)
    local model = GetEntityModel(ped)
    local gender = model == `mp_m_freemode_01` and 0 or 1
    local gloveOptions = ClothingConfig.GetGloveOptions(job, citizenId, gender)

    TriggerClientEvent('ox_inventory:syncClothSlots', source, {
        clothSlots = BuildClientClothSlots(clothSlots),
        gloveOptions = gloveOptions,
        hasDecalAccess = ClothingConfig.HasDecalAccess(job),
    })
end)

lib.addCommand('givecloth', {
    help = 'Cho quần áo với drawable/texture/gender',
    params = {
        { name = 'target', type = 'playerId', help = 'ID người nhận' },
        { name = 'cloth',  type = 'string',   help = 'Format: tên_drawable_texture_gender (vd: aokhoac_3_1_0)' },
        { name = 'count',  type = 'number',   help = 'Số lượng', optional = true },
    },
    restricted = 'group.admin',
}, function(source, args)
    local ClothingConfig = require 'modules.clothing.shared'
    local Inventory = require 'modules.inventory.server'

    local parts = {}
    for part in args.cloth:gmatch('[^_]+') do
        parts[#parts + 1] = part
    end

    if #parts < 4 then
        return lib.notify(source, { type = 'error', description = 'Sai format! Dùng: tên_drawable_texture_gender (vd: aokhoac_3_1_0)' })
    end

    local gender     = tonumber(parts[#parts])
    local textureId  = tonumber(parts[#parts - 1])
    local drawableId = tonumber(parts[#parts - 2])

    local nameParts = {}
    for i = 1, #parts - 3 do
        nameParts[#nameParts + 1] = parts[i]
    end
    local itemName = table.concat(nameParts, '_')

    if not itemName or not drawableId or not textureId or not gender then
        return lib.notify(source, { type = 'error', description = 'Sai format! Dùng: tên_drawable_texture_gender (vd: aokhoac_3_1_0)' })
    end

    if not ClothingConfig.IsClothing(itemName) then
        return lib.notify(source, { type = 'error', description = ('"%s" không phải quần áo'):format(itemName) })
    end

    local count = args.count or 1
    local metadata = {
        drawableId = drawableId,
        textureId  = textureId,
        gender     = gender,
    }

    local success, response = Inventory.AddItem(args.target, itemName, count, metadata)

    if success then
        local def = ClothingConfig.GetDef(itemName)
        lib.notify(source, {
            type = 'success',
            description = ('Đã cho %sx %s (%s_%s_%s) cho ID %s'):format(
                count, def.label, drawableId, textureId, gender, args.target
            )
        })
    else
        lib.notify(source, { type = 'error', description = response or 'Không thể cho item' })
    end
end)

-- ── Equip from Backpack ────────────────────────────────────────
RegisterNetEvent('ox_inventory:clothSlotEquipFromBackpack', function(data)
    local source = source
    if not data or not data.fromSlot or not data.toClothSlot then return end

    local bp = BackpackServer.GetPlayerBackpack(source)
    if not bp then
        return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Không có balo đang mở' })
    end

    local backpackInv = Inventory(bp.stashName)
    if not backpackInv then return end

    local fromItem = backpackInv.items[data.fromSlot]
    if not fromItem then return end

    local targetItemName = ClothingConfig.GetItemBySlot(data.toClothSlot)
    if not targetItemName then return end

    if fromItem.name ~= targetItemName then
        return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Vật phẩm không đúng loại' })
    end

    local def = ClothingConfig.GetDef(targetItemName)
    if not def then return end

    local meta = fromItem.metadata
    if not meta or meta.drawableId == nil or meta.textureId == nil or meta.gender == nil then
        return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Metadata không hợp lệ' })
    end

    local ped = GetPlayerPed(source)
    local model = GetEntityModel(ped)
    if model == `mp_m_freemode_01` or model == `mp_f_freemode_01` then
        local playerGender = model == `mp_m_freemode_01` and 0 or 1
        if meta.gender ~= playerGender then
            return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Không đúng giới tính' })
        end
    end

    local inv = Inventory(source)
    if not inv then return end

    local clothSlots = ClothingServer.GetPlayerClothSlots(source)
    local currentEquipped = clothSlots[data.toClothSlot]
    local item = Items(fromItem.name)
    if not item then return end

    if currentEquipped then
        local oldMeta = currentEquipped.metadata and table.clone(currentEquipped.metadata) or {}

        local removeWeight = Inventory.SlotWeight(item, { count = 1, metadata = fromItem.metadata })
        fromItem.count = fromItem.count - 1
        if fromItem.count < 1 then
            backpackInv.items[data.fromSlot] = nil
        else
            fromItem.weight = Inventory.SlotWeight(item, fromItem)
        end
        backpackInv.weight = backpackInv.weight - removeWeight

        local oldItem = Items(currentEquipped.name)
        if oldItem then
            local oldSlotData = {
                name = currentEquipped.name,
                label = oldItem.label,
                weight = Inventory.SlotWeight(oldItem, { count = 1, metadata = oldMeta }),
                slot = data.fromSlot,
                count = 1,
                description = oldItem.description,
                metadata = oldMeta,
                stack = oldItem.stack,
                close = oldItem.close,
            }

            if backpackInv.weight + oldSlotData.weight > backpackInv.maxWeight then
                if backpackInv.items[data.fromSlot] then
                    backpackInv.items[data.fromSlot].count = backpackInv.items[data.fromSlot].count + 1
                    backpackInv.items[data.fromSlot].weight = Inventory.SlotWeight(item, backpackInv.items[data.fromSlot])
                else
                    local restored = table.clone(fromItem)
                    restored.count = 1
                    restored.slot = data.fromSlot
                    restored.weight = removeWeight
                    backpackInv.items[data.fromSlot] = restored
                end
                backpackInv.weight = backpackInv.weight + removeWeight
                return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Balo quá tải' })
            end

            backpackInv.items[data.fromSlot] = oldSlotData
            backpackInv.weight = backpackInv.weight + oldSlotData.weight
        end
    else
        local removeWeight = Inventory.SlotWeight(item, { count = 1, metadata = fromItem.metadata })
        fromItem.count = fromItem.count - 1
        if fromItem.count < 1 then
            backpackInv.items[data.fromSlot] = nil
        else
            fromItem.weight = Inventory.SlotWeight(item, fromItem)
        end
        backpackInv.weight = backpackInv.weight - removeWeight
    end

    backpackInv.changed = true

    clothSlots[data.toClothSlot] = {
        name = fromItem.name or targetItemName,
        metadata = table.clone(meta),
    }

    local identifier = inv.owner
    if identifier then
        ClothingServer.SaveClothSlots(identifier, clothSlots)
        ClothingServer.SyncSkinData(identifier, def, meta.drawableId, meta.textureId)

        if data.toClothSlot == 11 and clothSlots[11] then
            local updated = BackpackServer.EnsureBackpackId(source, clothSlots[11])
            if updated and updated.idbalo then
                clothSlots[11].metadata = updated
                ClothingServer.SaveClothSlots(identifier, clothSlots)
            end
        end
    end

    TriggerClientEvent('ox_inventory:clothSlotUpdate', source, {
        action = currentEquipped and 'swap' or 'equip',
        clothSlot = data.toClothSlot,
        data = BuildClientData(clothSlots[data.toClothSlot]),
    })

    TriggerClientEvent('ox_inventory:backpackUpdate', source, {
        items = backpackInv.items,
        weight = backpackInv.weight,
    })

    if data.toClothSlot == 11 and clothSlots[11] then
        local info = BackpackServer.OpenBackpack(source, clothSlots[11].metadata or {})
        TriggerClientEvent('ox_inventory:backpackData', source, info)
    end
end)

-- ── Unequip to Backpack ────────────────────────────────────────
RegisterNetEvent('ox_inventory:clothSlotUnequipToBackpack', function(data)
    local source = source
    if not data or not data.clothSlot then return end

    local bp = BackpackServer.GetPlayerBackpack(source)
    if not bp then
        return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Không có balo đang mở' })
    end

    local backpackInv = Inventory(bp.stashName)
    if not backpackInv then return end

    local inv = Inventory(source)
    if not inv then return end

    local clothSlots = ClothingServer.GetPlayerClothSlots(source)
    local equipped = clothSlots[data.clothSlot]
    if not equipped then
        return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Slot trống' })
    end

    if equipped.name == 'balo' then
        return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Không thể bỏ balo vào balo' })
    end

    local itemName = ClothingConfig.GetItemBySlot(data.clothSlot)
    local def = itemName and ClothingConfig.GetDef(itemName)
    local item = Items(equipped.name)
    if not item then return end

    local meta = equipped.metadata and table.clone(equipped.metadata) or {}
    local gender = meta.gender or 0

    local toSlot = data.toSlot
    local slotData = {
        name = equipped.name,
        label = item.label,
        weight = Inventory.SlotWeight(item, { count = 1, metadata = meta }),
        slot = toSlot,
        count = 1,
        description = item.description,
        metadata = meta,
        stack = item.stack,
        close = item.close,
    }

    local existingItem = backpackInv.items[toSlot]
    if existingItem and existingItem.name then
        return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Ô đó đã có đồ' })
    end

    if backpackInv.weight + slotData.weight > backpackInv.maxWeight then
        return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Balo quá tải' })
    end

    backpackInv.items[toSlot] = slotData
    backpackInv.weight = backpackInv.weight + slotData.weight
    backpackInv.changed = true

    clothSlots[data.clothSlot] = nil

    local identifier = inv.owner
    if identifier then
        ClothingServer.SaveClothSlots(identifier, clothSlots)
        if def then
            ClothingServer.SyncSkinDataDefault(identifier, def, gender)
        end
    end

    if data.clothSlot == 11 then
        BackpackServer.CloseBackpack(source)
        TriggerClientEvent('ox_inventory:backpackData', source, nil)
    end

    TriggerClientEvent('ox_inventory:clothSlotUpdate', source, {
        action = 'unequip',
        clothSlot = data.clothSlot,
    })

    TriggerClientEvent('ox_inventory:backpackUpdate', source, {
        items = backpackInv.items,
        weight = backpackInv.weight,
    })
end)

return ClothingServer