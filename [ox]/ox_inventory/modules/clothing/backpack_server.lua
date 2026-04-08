-- modules/clothing/backpack_server.lua
local BackpackConfig = require 'modules.clothing.backpack_shared'
local ClothingConfig = require 'modules.clothing.shared'
local Inventory = require 'modules.inventory.server'
local Items = require 'modules.items.server'

local BackpackServer = {}

local playerBackpacks = {}

-- ── Helper: lấy metadata từ cloth slot (tương thích cả format cũ và mới)
---@param clothSlot table
---@return table metadata
local function GetMeta(clothSlot)
    if clothSlot.metadata then return clothSlot.metadata end
    -- Fallback format cũ (drawableId nằm trực tiếp)
    return clothSlot
end

-- ── Helper: lấy name từ cloth slot
---@param clothSlot table
---@return string|nil
local function GetName(clothSlot)
    return clothSlot.name
end

-- ── Generate / Ensure idbalo ───────────────────────────────────

---@param source number
---@param clothSlot table { name, metadata: { drawableId, textureId, gender, level, idbalo? } }
---@return table|nil updatedMetadata with idbalo
function BackpackServer.EnsureBackpackId(source, clothSlot)
    local name = GetName(clothSlot)
    if not clothSlot or name ~= 'balo' then return nil end

    local meta = GetMeta(clothSlot)
    if meta.idbalo then
        return meta
    end

    meta.idbalo = BackpackConfig.GenerateId()
    return meta
end

-- ── Open backpack ──────────────────────────────────────────────

---@param source number
---@param meta table metadata { level, idbalo, ... }
---@return table|nil backpackInfo
function BackpackServer.OpenBackpack(source, meta)
    if not meta or not meta.idbalo then return nil end

    local level = meta.level or 1
    local levelData = BackpackConfig.GetLevel(level)
    if not levelData then return nil end

    local stashName = BackpackConfig.GetStashName(meta.idbalo)

    exports.ox_inventory:RegisterStash(stashName, levelData.label, levelData.slots, levelData.maxWeight, false)

    local stashInv = Inventory({ id = stashName }, nil, true)

    local info = {
        idbalo = meta.idbalo,
        level = level,
        stashName = stashName,
        slots = levelData.slots,
        maxWeight = levelData.maxWeight,
        label = levelData.label,
        items = stashInv and stashInv.items or {},
        weight = stashInv and stashInv.weight or 0,
    }

    playerBackpacks[source] = info
    return info
end

-- ── Close backpack ─────────────────────────────────────────────

---@param source number
function BackpackServer.CloseBackpack(source)
    local bp = playerBackpacks[source]
    if not bp then return end

    local playerInv = Inventory(source)
    if playerInv and playerInv.open then
        local openedInv = Inventory(playerInv.open)
        if openedInv and openedInv.dbId == bp.stashName then
            playerInv:closeInventory()
        end
    end

    playerBackpacks[source] = nil
end

-- ── Get active backpack ────────────────────────────────────────

---@param source number
---@return table|nil
function BackpackServer.GetPlayerBackpack(source)
    return playerBackpacks[source]
end

-- ── Cleanup on disconnect ──────────────────────────────────────

---@param source number
function BackpackServer.OnPlayerDropped(source)
    playerBackpacks[source] = nil
end

-- ── Events ─────────────────────────────────────────────────────

RegisterNetEvent('ox_inventory:requestBackpackData', function()
    local source = source
    local ClothingServer = require 'modules.clothing.server'
    local clothSlots = ClothingServer.GetPlayerClothSlots(source)
    local baloSlot = clothSlots[11]

    if not baloSlot or GetName(baloSlot) ~= 'balo' then
        TriggerClientEvent('ox_inventory:backpackData', source, nil)
        return
    end

    local meta = GetMeta(baloSlot)

    local updated = BackpackServer.EnsureBackpackId(source, baloSlot)
    if updated and updated.idbalo and not meta.idbalo then
        -- idbalo vừa được generate, cập nhật lại metadata
        if baloSlot.metadata then
            baloSlot.metadata = updated
        else
            clothSlots[11] = updated
        end
        local inv = Inventory(source)
        if inv and inv.owner then
            ClothingServer.SaveClothSlots(inv.owner, clothSlots)
        end
    end

    local info = BackpackServer.OpenBackpack(source, updated or meta)
    TriggerClientEvent('ox_inventory:backpackData', source, info)
end)

RegisterNetEvent('ox_inventory:openBackpackStash', function()
    local source = source
    local bp = playerBackpacks[source]
    if not bp then return end

    local left, right = lib.callback.await('ox_inventory:openInventory', source, 'stash', bp.stashName)
end)

RegisterNetEvent('ox_inventory:backpackSwap', function(data)
    local source = source
    if not data then return end

    local bp = playerBackpacks[source]
    if not bp then return end

    local playerInv = Inventory(source)
    if not playerInv then return end

    local backpackInv = Inventory(bp.stashName)
    if not backpackInv then return end

    local rightInv
    if data.fromType == 'right' or data.toType == 'right' then
        if not playerInv.open then
            return TriggerClientEvent('ox_lib:notify', source, {
                type = 'error', description = 'Không có inventory đang mở'
            })
        end
        rightInv = Inventory(playerInv.open)
        if not rightInv then
            return TriggerClientEvent('ox_lib:notify', source, {
                type = 'error', description = 'Inventory không hợp lệ'
            })
        end
    end

    local fromInv, toInv
    local fromSlot = data.fromSlot
    local toSlot = data.toSlot
    local count = data.count or 1

    if data.fromType == 'player' then
        fromInv = playerInv
    elseif data.fromType == 'backpack' then
        fromInv = backpackInv
    elseif data.fromType == 'right' then
        fromInv = rightInv
    else
        return
    end

    if data.toType == 'player' then
        toInv = playerInv
    elseif data.toType == 'backpack' then
        toInv = backpackInv
    elseif data.toType == 'right' then
        toInv = rightInv
    else
        return
    end

    if not fromInv or not toInv then return end

    local fromItem = fromInv.items[fromSlot]
    if not fromItem then return end

    if count > fromItem.count then count = fromItem.count end
    if count < 1 then return end

    local toItem = toInv.items[toSlot]
    local item = Items(fromItem.name)
    if not item then return end

    if toInv == backpackInv and fromItem.name == 'balo' then
        return TriggerClientEvent('ox_lib:notify', source, {
            type = 'error', description = 'Không thể bỏ balo vào balo'
        })
    end

    if fromInv ~= toInv then
        if toItem then
            local toItemDef = Items(toItem.name)
            if not toItemDef then return end

            local newToWeight = toInv.weight - toItem.weight + Inventory.SlotWeight(item, fromItem)
            local newFromWeight = fromInv.weight + Inventory.SlotWeight(toItemDef, toItem) - fromItem.weight

            if newToWeight > toInv.maxWeight or newFromWeight > fromInv.maxWeight then
                return TriggerClientEvent('ox_lib:notify', source, {
                    type = 'error', description = 'Quá tải trọng'
                })
            end
        else
            local moveWeight = Inventory.SlotWeight(item, { count = count, metadata = fromItem.metadata })
            if toInv.weight + moveWeight > toInv.maxWeight then
                return TriggerClientEvent('ox_lib:notify', source, {
                    type = 'error', description = 'Quá tải trọng'
                })
            end
        end
    end

    if toItem and (toItem.name ~= fromItem.name or not toItem.stack or not table.matches(toItem.metadata, fromItem.metadata)) then
        if fromInv == toInv then
            Inventory.SwapSlots(fromInv, toInv, fromSlot, toSlot)
        else
            local newToWeight = toInv.weight - toItem.weight + fromItem.weight
            local newFromWeight = fromInv.weight + toItem.weight - fromItem.weight

            if newToWeight <= toInv.maxWeight and newFromWeight <= fromInv.maxWeight then
                fromInv.weight = newFromWeight
                toInv.weight = newToWeight
                Inventory.SwapSlots(fromInv, toInv, fromSlot, toSlot)
            else
                return TriggerClientEvent('ox_lib:notify', source, {
                    type = 'error', description = 'Quá tải trọng'
                })
            end
        end
    elseif toItem and toItem.name == fromItem.name and toItem.stack and table.matches(toItem.metadata, fromItem.metadata) then
        local toSlotWeight = Inventory.SlotWeight(item, { count = toItem.count + count, metadata = toItem.metadata })
        local totalWeight = toInv.weight - toItem.weight + toSlotWeight

        if fromInv == toInv or totalWeight <= toInv.maxWeight then
            toItem.count = toItem.count + count
            toItem.weight = toSlotWeight
            fromItem.count = fromItem.count - count

            if fromItem.count < 1 then
                fromInv.items[fromSlot] = nil
            else
                fromItem.weight = Inventory.SlotWeight(item, fromItem)
            end

            toInv.items[toSlot] = toItem

            if fromInv ~= toInv then
                fromInv.weight = fromInv.weight - (fromItem.count < 1 and Inventory.SlotWeight(item, { count = count, metadata = fromItem.metadata }) or (Inventory.SlotWeight(item, { count = fromItem.count + count, metadata = fromItem.metadata }) - fromItem.weight))
                toInv.weight = totalWeight
            end
        else
            return TriggerClientEvent('ox_lib:notify', source, {
                type = 'error', description = 'Quá tải trọng'
            })
        end
    else
        local moveData = table.clone(fromItem)
        moveData.count = count
        moveData.slot = toSlot
        moveData.weight = Inventory.SlotWeight(item, { count = count, metadata = moveData.metadata })

        if fromInv == toInv or toInv.weight + moveData.weight <= toInv.maxWeight then
            fromItem.count = fromItem.count - count

            if fromItem.count < 1 then
                fromInv.items[fromSlot] = nil
                if fromInv ~= toInv then
                    fromInv.weight = fromInv.weight - moveData.weight
                end
            else
                local oldWeight = fromItem.weight
                fromItem.weight = Inventory.SlotWeight(item, fromItem)
                if fromInv ~= toInv then
                    fromInv.weight = fromInv.weight - (oldWeight - fromItem.weight)
                end
                moveData.metadata = table.clone(moveData.metadata)
            end

            toInv.items[toSlot] = moveData
            if fromInv ~= toInv then
                toInv.weight = toInv.weight + moveData.weight
            end
        else
            return TriggerClientEvent('ox_lib:notify', source, {
                type = 'error', description = 'Quá tải trọng'
            })
        end
    end

    fromInv.changed = true
    toInv.changed = true

    TriggerClientEvent('ox_inventory:backpackUpdate', source, {
        items = backpackInv.items,
        weight = backpackInv.weight,
    })

    if fromInv == playerInv or toInv == playerInv then
        local updates = {}
        if fromInv == playerInv then
            updates[#updates + 1] = { item = fromInv.items[fromSlot] or { slot = fromSlot }, inventory = fromInv.id }
        end
        if toInv == playerInv and toInv ~= fromInv then
            updates[#updates + 1] = { item = toInv.items[toSlot] or { slot = toSlot }, inventory = toInv.id }
        elseif toInv == playerInv and fromInv == playerInv then
            updates[#updates + 1] = { item = toInv.items[toSlot] or { slot = toSlot }, inventory = toInv.id }
        end
        if #updates > 0 then
            TriggerClientEvent('ox_inventory:updateSlots', source, updates, playerInv.weight)
        end
    end

    if rightInv and (fromInv == rightInv or toInv == rightInv) then
        local updates = {}
        if fromInv == rightInv then
            updates[#updates + 1] = { item = fromInv.items[fromSlot] or { slot = fromSlot }, inventory = fromInv.id }
        end
        if toInv == rightInv and toInv ~= fromInv then
            updates[#updates + 1] = { item = toInv.items[toSlot] or { slot = toSlot }, inventory = toInv.id }
        elseif toInv == rightInv and fromInv == rightInv then
            updates[#updates + 1] = { item = toInv.items[toSlot] or { slot = toSlot }, inventory = toInv.id }
        end
        if #updates > 0 then
            rightInv:syncSlotsWithClients(updates, true)
        end
    end

    -- Sync account items (cash) với framework
    if server.syncInventory then
        if fromInv == playerInv or toInv == playerInv then
            server.syncInventory(playerInv)
        end
    end
end)

RegisterNetEvent('ox_inventory:backpackDrop', function(data)
    local source = source
    if not data then return end

    local bp = playerBackpacks[source]
    if not bp then return end

    local backpackInv = Inventory(bp.stashName)
    if not backpackInv then return end

    local fromSlot = data.fromSlot
    local fromItem = backpackInv.items[fromSlot]
    if not fromItem then return end

    local count = data.count or fromItem.count
    if count > fromItem.count then count = fromItem.count end
    if count < 1 then return end

    local item = Items(fromItem.name)
    if not item then return end

    local dropData = table.clone(fromItem)
    dropData.count = count
    dropData.weight = Inventory.SlotWeight(item, { count = count, metadata = dropData.metadata })

    if dropData.weight > shared.playerweight then return end

    local dropId
    while true do
        dropId = ('drop-%s'):format(math.random(100000, 999999))
        if not Inventory.Drops[dropId] then break end
        Wait(0)
    end

    local coords = data.coords
    if type(coords) == 'table' then
        coords = vec3(coords.x or coords[1], coords.y or coords[2], coords.z or coords[3])
    end

    local playerPed = GetPlayerPed(source)
    if playerPed and playerPed ~= 0 then
        local playerCoords = GetEntityCoords(playerPed)
        if #(playerCoords - coords) > 10.0 then
            coords = playerCoords
        end
    end

    fromItem.count = fromItem.count - count
    local removedWeight = dropData.weight

    if fromItem.count < 1 then
        backpackInv.items[fromSlot] = nil
    else
        fromItem.weight = Inventory.SlotWeight(item, fromItem)
        dropData.metadata = table.clone(dropData.metadata)
    end

    backpackInv.weight = backpackInv.weight - removedWeight
    backpackInv.changed = true

    dropData.slot = data.toSlot or 1

    local dropInv = Inventory.Create(dropId, ('Drop %s'):format(dropId:gsub('%D', '')), 'drop', shared.dropslots, dropData.weight, shared.dropweight, false, { [dropData.slot] = dropData })

    if not dropInv then
        if backpackInv.items[fromSlot] then
            backpackInv.items[fromSlot].count = backpackInv.items[fromSlot].count + count
            backpackInv.items[fromSlot].weight = Inventory.SlotWeight(item, backpackInv.items[fromSlot])
        else
            local restored = table.clone(dropData)
            restored.slot = fromSlot
            backpackInv.items[fromSlot] = restored
        end
        backpackInv.weight = backpackInv.weight + removedWeight
        return
    end

    dropInv.coords = coords
    Inventory.Drops[dropId] = { coords = coords, instance = data.instance }

    TriggerClientEvent('ox_inventory:createDrop', -1, dropId, Inventory.Drops[dropId], source)

    TriggerClientEvent('ox_inventory:backpackUpdate', source, {
        items = backpackInv.items,
        weight = backpackInv.weight,
    })
end)

lib.addCommand('givebalo', {
    help = 'Cho balo với drawable/texture/gender/level',
    params = {
        { name = 'target',   type = 'playerId', help = 'ID người nhận' },
        { name = 'drawable', type = 'number',   help = 'Drawable ID' },
        { name = 'texture',  type = 'number',   help = 'Texture ID' },
        { name = 'gender',   type = 'number',   help = '0=male, 1=female' },
        { name = 'level',    type = 'number',   help = 'Cấp balo (1-5)' },
    },
    restricted = 'group.admin',
}, function(source, args)
    local level = args.level
    local levelData = BackpackConfig.GetLevel(level)

    if not levelData then
        return lib.notify(source, { type = 'error', description = ('Level %s không tồn tại'):format(level) })
    end

    local metadata = {
        drawableId = args.drawable,
        textureId  = args.texture,
        gender     = args.gender,
        level      = level,
    }

    local success, response = Inventory.AddItem(args.target, 'balo', 1, metadata)

    if success then
        lib.notify(source, {
            type = 'success',
            description = ('Đã cho Ba lô Cấp %s (D:%s T:%s G:%s) cho ID %s'):format(
                level, args.drawable, args.texture, args.gender, args.target
            )
        })
    else
        lib.notify(source, { type = 'error', description = response or 'Không thể cho balo' })
    end
end)

-- ── Exports cho resource bên ngoài (DERP-unequipmaskandbaloPD) ─

-- Trả về dữ liệu của 1 cloth slot cụ thể của player
exports('getPlayerClothSlot', function(targetSrc, slot)
    local ClothingServer = require 'modules.clothing.server'
    local clothSlots = ClothingServer.GetPlayerClothSlots(targetSrc)
    if not clothSlots then return nil end
    return clothSlots[slot]
end)

-- Force unequip 1 cloth slot của player: xóa DB, sync client ped
exports('forceUnequipPlayerClothSlot', function(targetSrc, slot)
    local ClothingServer = require 'modules.clothing.server'
    local clothSlots = ClothingServer.GetPlayerClothSlots(targetSrc)
    if not clothSlots then return false end

    local slotData = clothSlots[slot]
    if not slotData then return false end

    clothSlots[slot] = nil

    local inv = Inventory(targetSrc)
    if inv and inv.owner then
        ClothingServer.SaveClothSlots(inv.owner, clothSlots)
    end

    -- Nếu là balo: đóng stash đang mở (nếu có)
    if slot == 11 then
        BackpackServer.CloseBackpack(targetSrc)
    end

    -- Thông báo client của target cập nhật ped appearance
    TriggerClientEvent('ox_inventory:clothSlotUpdate', targetSrc, {
        action    = 'unequip',
        clothSlot = slot,
    })

    return true
end)

return BackpackServer