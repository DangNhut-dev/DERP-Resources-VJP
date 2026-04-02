local cooldowns      = {}
local pendingRewards = {}

-- Load rarity data từ ox_inventory một lần duy nhất
RarityConfig = load(LoadResourceFile('ox_inventory', 'modules/rarity/shared.lua'))()

-- Danh sách prefix của clothing item
CLOTH_PREFIXES = {
    mu = true, matna = true, aokhoac = true, aotrong = true,
    tay = true, quan = true, giay = true, kinh = true,
    khuyentai = true, daychuyen = true, balo = true,
    giap = true, dongho = true, vongtay = true
}

-- Tự nhận diện cloth dựa theo prefix tên item
function isClothItem(name)
    local prefix = name:match('^([^_]+)')
    return prefix and CLOTH_PREFIXES[prefix] == true
end

-- Tra cứu rarity của item
function getItemRarity(name)
    if isClothItem(name) then
        return RarityConfig.clothing[name] or 'common'
    else
        return RarityConfig.items[name] or 'common'
    end
end

-- Build rarityColors map từ tiers để gửi client
function buildRarityColors()
    local colors = {}
    for tier, data in pairs(RarityConfig.tiers) do
        colors[tier] = data.color
    end
    return colors
end

-- Enrich item list với rarity trước khi gửi NUI
local function enrichItems(items, boxType)
    local lbType = Config.Lootboxes[boxType] and Config.Lootboxes[boxType].type or 'clothing'
    local result = {}
    for _, item in ipairs(items) do
        result[#result + 1] = {
            name   = item.name,
            type   = lbType == 'clothing' and 'cloth' or 'normal',
            rarity = getItemRarity(item.name)
        }
    end
    return result
end

local function pickWeightedItem(items)
    local pool = {}
    for _, item in ipairs(items) do
        local rarity = getItemRarity(item.name)
        local weight = Config.RarityWeights[rarity] or 1
        for _ = 1, weight do
            pool[#pool + 1] = item
        end
    end
    return pool[math.random(#pool)]
end

local function validatePlayer(source, boxType)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false end
    local item = exports.ox_inventory:GetItem(source, boxType, nil, false)
    return item ~= nil and (item.count or 0) > 0
end

local function hasFreeSlot(source)
    local inventory = exports.ox_inventory:GetInventory(source, false)
    if not inventory then return false end
    local usedSlots = {}
    for _, item in pairs(inventory.items or {}) do
        if item and item.slot then usedSlots[item.slot] = true end
    end
    for slot = 1, (inventory.slots or 0) do
        if not usedSlots[slot] then return true end
    end
    return false
end

local function parseClothItem(wonItemName)
    local parts = {}
    for part in wonItemName:gmatch('[^_]+') do
        parts[#parts + 1] = part
    end
    if #parts < 4 then return nil end

    local gender     = tonumber(parts[#parts])
    local textureId  = tonumber(parts[#parts - 1])
    local drawableId = tonumber(parts[#parts - 2])

    if not gender or not textureId or not drawableId then return nil end
    if gender < 0 or gender > 1           then return nil end
    if drawableId < 0 or drawableId > 9999 then return nil end
    if textureId < 0  or textureId > 255   then return nil end

    local nameParts = {}
    for i = 1, #parts - 3 do nameParts[#nameParts + 1] = parts[i] end
    local itemName = table.concat(nameParts, '_')
    if not itemName or itemName == '' then return nil end

    return itemName, drawableId, textureId, gender
end

-- Tra cứu type của item từ config
local function getItemType(wonItemName)
    for _, box in pairs(Config.Lootboxes) do
        for _, item in ipairs(box.items) do
            if item.name == wonItemName then
                return item.type or 'normal'
            end
        end
    end
    return 'normal'
end

local function giveReward(source, wonItemName, boxType)
    local lbType = Config.Lootboxes[boxType] and Config.Lootboxes[boxType].type or 'clothing'

    if lbType == 'clothing' then
        local itemName, drawableId, textureId, gender = parseClothItem(wonItemName)
        if not itemName then return false end
        exports.ox_inventory:AddItem(source, itemName, 1, {
            drawableId = drawableId,
            textureId  = textureId,
            gender     = gender,
        })
    else
        exports.ox_inventory:AddItem(source, wonItemName, 1)
    end
    return true
end

RegisterNetEvent('derp-lootbox:openBox', function(boxType)
    local source = source

    if type(boxType) ~= 'string' then return end

    local boxConfig = Config.Lootboxes[boxType]
    if not boxConfig then return end

    if pendingRewards[source] then return end

    local now = os.time()
    if cooldowns[source] and (now - cooldowns[source]) < (Config.OpenCooldown / 1000) then return end

    if not validatePlayer(source, boxType) then return end

    if not hasFreeSlot(source) then
        TriggerClientEvent('derp-lootbox:notify', source, {
            type        = 'error',
            description = 'Túi đồ đầy, cần ít nhất 1 ô trống để mở hộp!'
        })
        return
    end

    local removed = exports.ox_inventory:RemoveItem(source, boxType, 1)
    if not removed then return end

    cooldowns[source] = now

    local winner = pickWeightedItem(boxConfig.items)

    pendingRewards[source] = {
        name      = winner.name,
        boxType   = boxType,
        expiresAt = now + 60
    }

    TriggerClientEvent('derp-lootbox:startUI', source, {
        winningItem  = { name = winner.name, type = boxConfig.type == 'clothing' and 'cloth' or 'normal', rarity = getItemRarity(winner.name) },
        items        = enrichItems(boxConfig.items, boxType),
        rarityColors = buildRarityColors()
    })
end)

RegisterNetEvent('derp-lootbox:claimReward', function()
    local source = source

    local reward = pendingRewards[source]
    if not reward then return end

    if os.time() > reward.expiresAt then
        pendingRewards[source] = nil
        return
    end

    local wonItemName = reward.name
    local boxType     = reward.boxType

    local valid = false
    for _, box in pairs(Config.Lootboxes) do
        for _, item in ipairs(box.items) do
            if item.name == wonItemName then valid = true; break end
        end
        if valid then break end
    end

    if not valid then
        pendingRewards[source] = nil
        return
    end

    giveReward(source, wonItemName, reward.boxType)

    pendingRewards[source] = nil
    cooldowns[source]      = nil

    local remaining = exports.ox_inventory:GetItem(source, boxType, nil, false)
    local hasMore   = remaining ~= nil and (remaining.count or 0) > 0
    TriggerClientEvent('derp-lootbox:afterClaim', source, hasMore)
end)

local pendingMultiRewards = {}

RegisterNetEvent('derp-lootbox:openBoxMulti', function(boxType)
    local source = source

    if type(boxType) ~= 'string' then return end

    local boxConfig = Config.Lootboxes[boxType]
    if not boxConfig then return end

    if pendingRewards[source] or pendingMultiRewards[source] then return end

    local now = os.time()
    if cooldowns[source] and (now - cooldowns[source]) < (Config.OpenCooldown / 1000) then return end

    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    local item = exports.ox_inventory:GetItem(source, boxType, nil, false)
    if not item or (item.count or 0) < 5 then
        TriggerClientEvent('derp-lootbox:notify', source, {
            type        = 'error',
            description = 'Bạn cần ít nhất 5 hộp để mở x5!'
        })
        return
    end

    local freeSlots = 0
    local inventory = exports.ox_inventory:GetInventory(source, false)
    if inventory then
        local usedSlots = {}
        for _, itm in pairs(inventory.items or {}) do
            if itm and itm.slot then usedSlots[itm.slot] = true end
        end
        for slot = 1, (inventory.slots or 0) do
            if not usedSlots[slot] then freeSlots = freeSlots + 1 end
        end
    end

    if freeSlots < 5 then
        TriggerClientEvent('derp-lootbox:notify', source, {
            type        = 'error',
            description = 'Cần ít nhất 5 ô trống trong túi đồ!'
        })
        return
    end

    local removed = exports.ox_inventory:RemoveItem(source, boxType, 5)
    if not removed then return end

    cooldowns[source] = now

    local winners = {}
    for i = 1, 5 do
        winners[i] = pickWeightedItem(boxConfig.items)
    end

    pendingMultiRewards[source] = {
        rewards   = winners,
        boxType   = boxType,
        expiresAt = now + 120
    }

    local enrichedWinners = {}
    for _, w in ipairs(winners) do
        enrichedWinners[#enrichedWinners + 1] = {
            name   = w.name,
            type   = boxConfig.type == 'clothing' and 'cloth' or 'normal',
            rarity = getItemRarity(w.name)
        }
    end

    TriggerClientEvent('derp-lootbox:startUIMulti', source, {
        winners      = enrichedWinners,
        items        = enrichItems(boxConfig.items, boxType),
        rarityColors = buildRarityColors()
    })
end)

RegisterNetEvent('derp-lootbox:claimRewardMulti', function()
    local source = source

    local data = pendingMultiRewards[source]
    if not data then return end

    if os.time() > data.expiresAt then
        pendingMultiRewards[source] = nil
        return
    end

    for _, winner in ipairs(data.rewards) do
        local wonItemName = winner.name
        local valid = false
        for _, box in pairs(Config.Lootboxes) do
            for _, itm in ipairs(box.items) do
                if itm.name == wonItemName then valid = true; break end
            end
            if valid then break end
        end
        if valid then
            giveReward(source, wonItemName, data.boxType)
        end
    end

    local boxType = data.boxType
    pendingMultiRewards[source] = nil
    cooldowns[source]           = nil

    local remaining = exports.ox_inventory:GetItem(source, boxType, nil, false)
    local hasMore   = remaining ~= nil and (remaining.count or 0) >= 1
    TriggerClientEvent('derp-lootbox:afterClaim', source, hasMore)
end)

AddEventHandler('playerDropped', function()
    pendingRewards[source]      = nil
    cooldowns[source]           = nil
    pendingMultiRewards[source] = nil
end)