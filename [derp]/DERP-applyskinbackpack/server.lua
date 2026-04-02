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

    return { success = true }
end)