local ox_inventory = exports.ox_inventory

local PurityLevels = Config.PurityLevels
local Veins        = Config.Veins
local ColorMods    = Config.ColorModifiers
local VeinMods     = Config.VeinModifiers
local CutTable     = Config.CutTable
local StoneRaw     = Config.StoneRaw
local StoneItems   = Config.StoneItems
local ColorPool    = Config.ColorPool

local StoneItemList = {}
for itemName, _ in pairs(StoneItems) do
    StoneItemList[#StoneItemList + 1] = itemName
end

local function isStoneItem(name)
    return name == StoneRaw or StoneItems[name] ~= nil
end

local function isPolishedStone(name)
    return StoneItems[name] ~= nil
end

local function getPurityIndex(purity)
    for i, v in ipairs(PurityLevels) do
        if v == purity then return i end
    end
    return nil
end

local function weightedRandom(pool)
    local total = 0
    for _, entry in ipairs(pool) do
        if entry.weight > 0 then
            total = total + entry.weight
        end
    end
    if total == 0 then return pool[1].item end
    local roll = math.random(1, total)
    local cumulative = 0
    for _, entry in ipairs(pool) do
        if entry.weight > 0 then
            cumulative = cumulative + entry.weight
            if roll <= cumulative then return entry.item end
        end
    end
    return pool[#pool].item
end

local function applyModifiers(basePool, color, vein)
    local cMod = ColorMods[color] or { waste = 1.0, rare = 1.0 }
    local vMod = VeinMods[vein]   or { waste = 1.0, rare = 1.0 }
    local pool = {}
    local lastIdx = #basePool
    for i, entry in ipairs(basePool) do
        local w = entry.weight
        if w <= 0 then
            pool[#pool + 1] = { item = entry.item, weight = 0 }
        elseif entry.item == 'jade_waste' then
            w = math.floor(w * cMod.waste * vMod.waste)
            if w < 1 then w = 1 end
            pool[#pool + 1] = { item = entry.item, weight = w }
        elseif i == lastIdx then
            w = math.floor(w * cMod.rare * vMod.rare)
            if w < 1 then w = 1 end
            pool[#pool + 1] = { item = entry.item, weight = w }
        else
            pool[#pool + 1] = { item = entry.item, weight = w }
        end
    end
    return pool
end

local function validateStoneSlot(source, slot)
    local item = ox_inventory:GetSlot(source, slot)
    if not item then return false, nil end
    if not isStoneItem(item.name) then return false, nil end
    return true, item
end

lib.callback.register('tommy-dothach:getPlayerStones', function(source)
    local result = {}
    for itemName, _ in pairs(StoneItems) do
        local slots = ox_inventory:GetSlotsWithItem(source, itemName)
        if slots then
            for _, item in ipairs(slots) do
                local meta = item.metadata or {}
                result[#result + 1] = {
                    slot       = item.slot,
                    itemName   = itemName,
                    polished   = true,
                    color      = StoneItems[itemName],
                    vein       = meta.vein       or nil,
                    purity     = meta.purity     or nil,
                    grindCount = meta.grindCount or 0,
                }
            end
        end
    end
    local rawSlots = ox_inventory:GetSlotsWithItem(source, StoneRaw)
    if rawSlots then
        for _, item in ipairs(rawSlots) do
            result[#result + 1] = {
                slot       = item.slot,
                itemName   = StoneRaw,
                polished   = false,
                color      = nil,
                vein       = nil,
                purity     = nil,
                grindCount = 0,
            }
        end
    end
    return result
end)

lib.callback.register('tommy-dothach:getSlotMeta', function(source, slot)
    local valid, item = validateStoneSlot(source, slot)
    if not valid then return false, 0 end
    local meta = item.metadata or {}
    local polished = isPolishedStone(item.name)
    return polished, (meta.grindCount or 0)
end)

RegisterNetEvent('tommy-dothach:grindStone', function(slot)
    local source = source
    slot = tonumber(slot)
    if not slot then return end

    local valid, item = validateStoneSlot(source, slot)
    if not valid then
        TriggerClientEvent('tommy-dothach:notify', source, {
            title = 'Đổ Thạch', description = 'Không tìm thấy viên đá.', type = 'error'
        })
        return
    end

    local meta       = item.metadata or {}
    local grindCount = meta.grindCount or 0
    local isPolished = isPolishedStone(item.name)

    if isPolished and grindCount >= 2 then
        TriggerClientEvent('tommy-dothach:notify', source, {
            title = 'Đổ Thạch', description = 'Viên đá này đã được kiểm định tối đa 2 lần.', type = 'error'
        })
        return
    end

    local newMeta    = {}
    local newItem

    if not isPolished then
        -- Kiểm định lần đầu: stone thô → stone màu
        newItem            = weightedRandom(ColorPool)
        newMeta.vein       = Veins[math.random(#Veins)]
        newMeta.purity     = PurityLevels[math.random(#PurityLevels)]
        newMeta.grindCount = 1
    else
        -- Kiểm định lần 2: giữ nguyên item, reroll purity
        newItem            = item.name
        newMeta.vein       = meta.vein
        newMeta.grindCount = grindCount + 1
        local idx = getPurityIndex(meta.purity) or 1
        if math.random(2) == 1 then
            idx = math.min(idx + 1, #PurityLevels)
        else
            idx = math.max(idx - 1, 1)
        end
        newMeta.purity = PurityLevels[idx]
    end

    local color = StoneItems[newItem]
    newMeta.description = ('Màu sắc: %s | \nVân đá: %s | \nTinh khiết: %s | \nĐã kiểm định: %d lần'):format(
        color, newMeta.vein, newMeta.purity, newMeta.grindCount
    )

    local removed = ox_inventory:RemoveItem(source, item.name, 1, nil, slot)
    if not removed then
        TriggerClientEvent('tommy-dothach:notify', source, {
            title = 'Đổ Thạch', description = 'Lỗi khi xử lý đá.', type = 'error'
        })
        return
    end

    local added = ox_inventory:AddItem(source, newItem, 1, newMeta)
    if not added then
        ox_inventory:AddItem(source, item.name, 1, meta)
        TriggerClientEvent('tommy-dothach:notify', source, {
            title = 'Đổ Thạch', description = 'Túi đồ quá đầy.', type = 'error'
        })
        return
    end

    TriggerClientEvent('tommy-dothach:notify', source, {
        title = 'Đổ Thạch',
        description = ('Kiểm định xong! Màu: %s | Vân: %s | Tinh khiết: %s'):format(
            color, newMeta.vein, newMeta.purity
        ),
        type = 'success'
    })
end)

RegisterNetEvent('tommy-dothach:cutStone', function(slot)
    local source = source
    slot = tonumber(slot)
    if not slot then return end

    local valid, item = validateStoneSlot(source, slot)
    if not valid then
        TriggerClientEvent('tommy-dothach:notify', source, {
            title = 'Đổ Thạch', description = 'Không tìm thấy viên đá.', type = 'error'
        })
        return
    end

    if not isPolishedStone(item.name) then
        TriggerClientEvent('tommy-dothach:notify', source, {
            title = 'Đổ Thạch', description = 'Viên đá này chưa được kiểm định.', type = 'error'
        })
        return
    end

    local meta     = item.metadata or {}
    local basePool = CutTable[meta.purity]
    if not basePool then
        TriggerClientEvent('tommy-dothach:notify', source, {
            title = 'Đổ Thạch', description = 'Dữ liệu tinh khiết không hợp lệ.', type = 'error'
        })
        return
    end

    local color = StoneItems[item.name]
    local reward
    if math.random(1, 100) <= Config.LuckyChance then
        reward = weightedRandom(Config.LuckyTable)
    else
        local modPool = applyModifiers(basePool, color, meta.vein)
        reward = weightedRandom(modPool)
    end

    local removed = ox_inventory:RemoveItem(source, item.name, 1, nil, slot)
    if not removed then
        TriggerClientEvent('tommy-dothach:notify', source, {
            title = 'Đổ Thạch', description = 'Lỗi khi xóa đá.', type = 'error'
        })
        return
    end

    local added = ox_inventory:AddItem(source, reward, 1)
    if not added then
        ox_inventory:AddItem(source, item.name, 1, meta)
        TriggerClientEvent('tommy-dothach:notify', source, {
            title = 'Đổ Thạch', description = 'Túi đồ quá đầy, không thể nhận đá quý.', type = 'error'
        })
        return
    end

    TriggerClientEvent('tommy-dothach:notify', source, {
        title = 'Đổ Thạch',
        description = ('Cắt thành công!'),
        type = 'success'
    })
end)

lib.addCommand('giveda', {
    help = 'Cho stone thô để test',
    restricted = 'group.admin',
    params = {
        { name = 'id',     type = 'number', help = 'Server ID người chơi' },
        { name = 'amount', type = 'number', help = 'Số lượng stone'       },
    },
}, function(source, args)
    local target = args.id
    local amount = args.amount
    if amount < 1 or amount > 100 then
        TriggerClientEvent('tommy-dothach:notify', source, {
            title = 'Đổ Thạch', description = 'Số lượng không hợp lệ (1-100).', type = 'error'
        })
        return
    end
    local added = ox_inventory:AddItem(target, StoneRaw, amount)
    if added then
        TriggerClientEvent('tommy-dothach:notify', source, {
            title = 'Đổ Thạch',
            description = ('Đã cho %d %s cho ID %d'):format(amount, StoneRaw, target),
            type = 'success'
        })
    else
        TriggerClientEvent('tommy-dothach:notify', source, {
            title = 'Đổ Thạch', description = 'Lỗi khi cho item.', type = 'error'
        })
    end
end)