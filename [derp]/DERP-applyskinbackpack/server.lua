local ox_inventory = exports.ox_inventory

-- Load RarityConfig từ ox_inventory resource
local raritySource = LoadResourceFile('ox_inventory', 'modules/rarity/shared.lua')
local RarityConfig
if raritySource then
    local fn = load(raritySource)
    if fn then RarityConfig = fn() end
end
if not RarityConfig then
    RarityConfig = { tiers = {}, items = {}, clothing = {} }
end

local function IsJsRankingStarted()
    return GetResourceState('js_ranking') == 'started'
end

local function normalizeGender(gender)
    if gender == nil then return nil end

    if type(gender) == 'number' then
        if gender == 0 then return 'nam' end
        if gender == 1 then return 'nữ' end
        return tostring(gender)
    end

    local text = tostring(gender):lower()

    if text == 'male' or text == 'm' or text == '0' then
        return 'nam'
    end

    if text == 'female' or text == 'f' or text == '1' then
        return 'nữ'
    end

    return tostring(gender)
end

local function getItemLabel(name, metadata, fallbackLabel)
    if type(metadata) == 'table' and metadata.label and metadata.label ~= '' then
        return tostring(metadata.label)
    end

    local ok, itemData = pcall(function()
        return ox_inventory:Items(name)
    end)

    if ok and itemData and itemData.label and itemData.label ~= '' then
        return tostring(itemData.label)
    end

    if fallbackLabel and fallbackLabel ~= '' then
        return tostring(fallbackLabel)
    end

    return tostring(name or '')
end

local function formatItem(name, count, metadata, mode, fallbackLabel)
    name = tostring(name or '')
    count = tonumber(count) or 0

    local label = getItemLabel(name, metadata, fallbackLabel)
    local extras = {}

    if type(metadata) == 'table' then
        if metadata.level ~= nil then
            extras[#extras + 1] = ('lv%s'):format(tostring(metadata.level))
        end

        if metadata.drawableId ~= nil then
            extras[#extras + 1] = ('d%s'):format(tostring(metadata.drawableId))
        end

        if metadata.textureId ~= nil then
            extras[#extras + 1] = ('t%s'):format(tostring(metadata.textureId))
        end

        local gender = normalizeGender(metadata.gender)
        if gender then
            extras[#extras + 1] = gender
        end
    end

    if #extras > 0 then
        label = ('%s [%s]'):format(label, table.concat(extras, ' '))
    end

    local display = name
    if label ~= '' and label ~= name then
        display = ('%s(%s)'):format(name, label)
    end

    local prefix = ''
    if mode == 'add' then
        prefix = '+'
    elseif mode == 'remove' then
        prefix = '-'
    end

    if count > 0 then
        return ('%s%s x%s'):format(prefix, display, math.floor(count))
    end

    return prefix .. display
end

local function buildActionText(title, details)
    local message = ('[applyskinbackpack] | %s'):format(tostring(title or ''))

    if type(details) == 'table' and #details > 0 then
        local parts = {}

        for i = 1, #details do
            local entry = details[i]
            local key = entry and entry[1]
            local value = entry and entry[2]

            if key and value ~= nil and value ~= '' then
                parts[#parts + 1] = ('%s: %s'):format(tostring(key), tostring(value))
            end
        end

        if #parts > 0 then
            message = message .. ' | ' .. table.concat(parts, ' | ')
        end
    end

    return message
end

local function TryAddActionLog(anyPlayer, actionText, opts)
    if not IsJsRankingStarted() then return false end
    if not actionText or actionText == '' then return false end

    local ok = pcall(function()
        exports['js_ranking']:AddActionLog(anyPlayer, actionText, opts)
    end)

    return ok
end

local function AddActionLog(anyPlayer, title, details, opts)
    return TryAddActionLog(anyPlayer, buildActionText(title, details), opts)
end

exports('AddActionLog', function(anyPlayer, actionText, opts)
    return TryAddActionLog(anyPlayer, actionText, opts)
end)

-- Parse tên item mẫu: balo_4_0_0 → { drawable=4, texture=0, gender=0 }
---@param itemName string
---@return table|nil { drawable: number, texture: number, gender: number }
local function ParseSkinItem(itemName)
    local prefix = Config.SkinPrefix
    if not itemName or itemName:sub(1, #prefix) ~= prefix then return nil end

    local rest = itemName:sub(#prefix + 1)
    local parts = {}
    for part in rest:gmatch('[^_]+') do
        parts[#parts + 1] = tonumber(part)
    end

    if #parts ~= 3 then return nil end
    if not parts[1] or not parts[2] or not parts[3] then return nil end

    return {
        drawable = parts[1],
        texture = parts[2],
        gender = parts[3],
    }
end

-- Lấy rarity cho item name
---@param itemName string
---@return string|nil tierName
---@return table|nil tierData
local function GetItemRarity(itemName)
    local tierName = RarityConfig.items[itemName] or RarityConfig.clothing[itemName]
    if not tierName then return nil, nil end
    return tierName, RarityConfig.tiers[tierName]
end

-- Lấy danh sách balo + mẫu trong inventory
lib.callback.register('DERP-applyskinbackpack:getItems', function(source)
    local items = ox_inventory:GetInventoryItems(source)
    if not items then return { backpacks = {}, skins = {}, rarityTiers = {} } end

    local backpacks = {}
    local skins = {}

    for _, item in pairs(items) do
        if item.name == 'balo' and item.metadata then
            backpacks[#backpacks + 1] = {
                slot = item.slot,
                name = item.name,
                label = item.label,
                count = item.count,
                metadata = {
                    drawableId = item.metadata.drawableId,
                    textureId = item.metadata.textureId,
                    gender = item.metadata.gender,
                    level = item.metadata.level,
                },
            }
        else
            local parsed = ParseSkinItem(item.name)
            if parsed then
                local tierName, tierData = GetItemRarity(item.name)
                skins[#skins + 1] = {
                    slot = item.slot,
                    name = item.name,
                    label = item.label or item.name,
                    count = item.count,
                    parsed = parsed,
                    rarity = tierName,
                    rarityColor = tierData and tierData.color or nil,
                    rarityLabel = tierData and tierData.label or nil,
                    rarityOrder = tierData and tierData.order or 0,
                }
            end
        end
    end

    local rarityTiers = {}
    for name, data in pairs(RarityConfig.tiers) do
        rarityTiers[name] = { color = data.color, order = data.order, label = data.label }
    end

    return { backpacks = backpacks, skins = skins, rarityTiers = rarityTiers }
end)

-- Apply skin lên balo
lib.callback.register('DERP-applyskinbackpack:apply', function(source, data)
    if not data or not data.backpackSlot or not data.skinSlot then
        return { success = false, message = 'Dữ liệu không hợp lệ' }
    end

    local backpackSlot = data.backpackSlot
    local skinSlot = data.skinSlot

    local items = ox_inventory:GetInventoryItems(source)
    if not items then
        return { success = false, message = 'Không tìm thấy inventory' }
    end

    local baloItem = nil
    for _, item in pairs(items) do
        if item.slot == backpackSlot and item.name == 'balo' then
            baloItem = item
            break
        end
    end

    if not baloItem or not baloItem.metadata then
        return { success = false, message = 'Không tìm thấy balo' }
    end

    local skinItem = nil
    for _, item in pairs(items) do
        if item.slot == skinSlot then
            skinItem = item
            break
        end
    end

    if not skinItem then
        return { success = false, message = 'Không tìm thấy mẫu' }
    end

    local parsed = ParseSkinItem(skinItem.name)
    if not parsed then
        return { success = false, message = 'Item không phải mẫu balo' }
    end

    local baloGender = baloItem.metadata.gender
    if baloGender == nil then
        return { success = false, message = 'Balo thiếu thông tin giới tính' }
    end

    if parsed.gender ~= baloGender then
        return { success = false, message = 'Mẫu không đúng giới tính với balo' }
    end

    local oldMeta = {}
    for k, v in pairs(baloItem.metadata) do
        oldMeta[k] = v
    end

    local removed = ox_inventory:RemoveItem(source, skinItem.name, 1, nil, skinSlot)
    if not removed then
        return { success = false, message = 'Không thể xóa mẫu' }
    end

    local newMeta = {}
    for k, v in pairs(baloItem.metadata) do
        newMeta[k] = v
    end
    newMeta.drawableId = parsed.drawable
    newMeta.textureId = parsed.texture

    local removedBalo = ox_inventory:RemoveItem(source, 'balo', 1, nil, backpackSlot)
    if not removedBalo then
        ox_inventory:AddItem(source, skinItem.name, 1, nil, skinSlot)
        return { success = false, message = 'Không thể cập nhật balo' }
    end

    local addedBalo = ox_inventory:AddItem(source, 'balo', 1, newMeta, backpackSlot)
    if not addedBalo then
        ox_inventory:AddItem(source, 'balo', 1, baloItem.metadata, backpackSlot)
        ox_inventory:AddItem(source, skinItem.name, 1, nil, skinSlot)
        return { success = false, message = 'Không thể thêm balo mới' }
    end

    AddActionLog(source, 'Đổi skin balo', {
        { 'tiêu hao', formatItem(skinItem.name, 1, skinItem.metadata, 'remove', skinItem.label) },
        { 'balo cũ', formatItem('balo', 1, oldMeta, nil, baloItem.label) },
        { 'balo mới', formatItem('balo', 1, newMeta, 'add', baloItem.label) },
        { 'slot_balo', tostring(backpackSlot) },
        { 'slot_mẫu', tostring(skinSlot) },
    }, {
        deferMs = 0,
    })

    return { success = true }
end)
