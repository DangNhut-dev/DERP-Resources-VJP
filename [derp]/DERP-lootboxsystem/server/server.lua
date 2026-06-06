local cooldowns      = {}
local pendingRewards = {}

local allEvents = {
    ["derp-lootbox:openBox"] = false,
    ["derp-lootbox:claimReward"] = false,
    ["derp-lootbox:openBoxMulti"] = false,
    ["derp-lootbox:claimRewardMulti"] = false,
}

local fiveguard_resource = "svc_runtime"

AddEventHandler("fg:ExportsLoaded", function(fiveguard_res, res)
    if res == "*" or res == GetCurrentResourceName() then
        fiveguard_resource = fiveguard_res
        for event,cross_scripts in pairs(allEvents) do
            local retval, errorText = exports[fiveguard_res]:RegisterSafeEvent(event, {
                ban = true,
                log = true
            }, cross_scripts)
            if not retval then
                print("[fiveguard safe-events] "..errorText)
            end
        end
    end
end)

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


local function derpNormalizeGender(gender)
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

local function derpGetItemLabel(name, metadata)
    if type(metadata) == 'table' and metadata.label and metadata.label ~= '' then
        return tostring(metadata.label)
    end

    local label = tostring(name or '')
    local ok, item = pcall(function()
        return exports.ox_inventory:Items(name)
    end)

    if ok and type(item) == 'table' and item.label and item.label ~= '' then
        label = tostring(item.label)
    end

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

        local gender = derpNormalizeGender(metadata.gender)
        if gender then
            extras[#extras + 1] = gender
        end

        if metadata.type ~= nil then
            extras[#extras + 1] = ('type:%s'):format(tostring(metadata.type))
        end
    end

    if #extras > 0 then
        label = ('%s [%s]'):format(label, table.concat(extras, ' '))
    end

    return label
end

function DERP_FormatItemText(name, count, metadata, mode)
    name = tostring(name or '')
    count = tonumber(count) or 0

    local label = derpGetItemLabel(name, metadata)
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

function DERP_FormatItemList(items, mode)
    if type(items) ~= 'table' or #items == 0 then
        return nil
    end

    local grouped = {}
    local order = {}

    for i = 1, #items do
        local entry = items[i]
        local name = entry and entry.name

        if name and name ~= '' then
            local metadata = entry.metadata
            local count = tonumber(entry.count) or 1
            local ok, metaKey = pcall(json.encode, metadata or {})

            if not ok then
                metaKey = ''
            end

            local key = tostring(name) .. '|' .. tostring(metaKey)
            local group = grouped[key]

            if not group then
                group = {
                    name = name,
                    count = 0,
                    metadata = metadata,
                }
                grouped[key] = group
                order[#order + 1] = key
            end

            group.count = group.count + count
        end
    end

    local out = {}

    for i = 1, #order do
        local entry = grouped[order[i]]
        out[#out + 1] = DERP_FormatItemText(entry.name, entry.count, entry.metadata, mode)
    end

    table.sort(out)
    return table.concat(out, ', ')
end

local function derpBuildActionText(title, details)
    local message = ('[DERP-lootboxsystem] | %s'):format(tostring(title or ''))

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

function DERP_IsJsRankingStarted()
    return GetResourceState('js_ranking') == 'started'
end

function DERP_TryAddActionLog(anyPlayer, actionText, opts)
    if not DERP_IsJsRankingStarted() then return false end
    if not actionText or actionText == '' then return false end

    local ok = pcall(function()
        exports['js_ranking']:AddActionLog(anyPlayer, actionText, opts)
    end)

    return ok
end

function DERP_LogAction(anyPlayer, title, details, opts)
    return DERP_TryAddActionLog(anyPlayer, derpBuildActionText(title, details), opts)
end

function DERP_GetPlayerMoneySnapshot(source, overrides)
    local snapshot = {}

    if source and source > 0 then
        local player = exports.qbx_core:GetPlayer(source)
        if player and player.PlayerData and type(player.PlayerData.money) == 'table' then
            for key, value in pairs(player.PlayerData.money) do
                if type(key) == 'string' and key ~= '' then
                    snapshot[key] = tonumber(value) or 0
                end
            end
        end
    end

    if type(overrides) == 'table' then
        for key, value in pairs(overrides) do
            if type(key) == 'string' and key ~= '' then
                snapshot[key] = tonumber(value) or 0
            end
        end
    end

    return snapshot
end

local function buildRewardEntry(wonItemName, boxType)
    local lbType = Config.Lootboxes[boxType] and Config.Lootboxes[boxType].type or 'clothing'

    if lbType == 'clothing' then
        local itemName, drawableId, textureId, gender = parseClothItem(wonItemName)
        if not itemName then return nil end

        return {
            name = itemName,
            count = 1,
            metadata = {
                drawableId = drawableId,
                textureId = textureId,
                gender = gender,
            }
        }
    end

    return {
        name = wonItemName,
        count = 1,
    }
end

local function giveReward(source, wonItemName, boxType)
    local rewardItem = buildRewardEntry(wonItemName, boxType)
    if not rewardItem then return false end

    local added = exports.ox_inventory:AddItem(source, rewardItem.name, rewardItem.count or 1, rewardItem.metadata)
    if not added then
        return false
    end

    return true, rewardItem
end

RegisterNetEvent('derp-lootbox:openBox', function(boxType)
    local source = source
    if fiveguard_resource ~= "" and GetResourceState(fiveguard_resource) == 'started' then
        if not exports[fiveguard_resource]:VerifyToken(source) then return end
    end
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

    DERP_LogAction(source, 'Mở lootbox', {
        { 'box', DERP_FormatItemText(boxType, 1, nil, 'remove') },
    })

    cooldowns[source] = now

    local winner = pickWeightedItem(boxConfig.items)

    pendingRewards[source] = {
        name      = winner.name,
        boxType   = boxType,
        expiresAt = now + 120000 
    }

    TriggerClientEvent('derp-lootbox:startUI', source, {
        winningItem  = { name = winner.name, type = boxConfig.type == 'clothing' and 'cloth' or 'normal', rarity = getItemRarity(winner.name) },
        items        = enrichItems(boxConfig.items, boxType),
        rarityColors = buildRarityColors()
    })
end)

-- Thay TOÀN BỘ event derp-lootbox:claimReward bằng đoạn này:

RegisterNetEvent('derp-lootbox:claimReward', function()
    local source = source
    -- print('[DERP-DEBUG-SERVER] [1] claimReward received from src=' .. tostring(source))

    if fiveguard_resource ~= "" and GetResourceState(fiveguard_resource) == 'started' then
        if not exports[fiveguard_resource]:VerifyToken(source) then
            -- print('[DERP-DEBUG-SERVER] [BLOCKED] fiveguard VerifyToken')
            return
        end
    end

    local reward = pendingRewards[source]
    -- print('[DERP-DEBUG-SERVER] [2] pendingRewards = ' .. tostring(reward ~= nil))
    if not reward then return end

    -- print('[DERP-DEBUG-SERVER] [3] reward.name = ' .. tostring(reward.name))
    -- print('[DERP-DEBUG-SERVER] [3] reward.boxType = ' .. tostring(reward.boxType))
    -- print('[DERP-DEBUG-SERVER] [3] reward.expiresAt = ' .. tostring(reward.expiresAt))
    -- print('[DERP-DEBUG-SERVER] [3] os.time() = ' .. tostring(os.time()))

    if os.time() > reward.expiresAt then
        -- print('[DERP-DEBUG-SERVER] [BLOCKED] expired')
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

    -- print('[DERP-DEBUG-SERVER] [4] valid = ' .. tostring(valid))
    if not valid then
        pendingRewards[source] = nil
        return
    end

    local rewarded, rewardItem = giveReward(source, wonItemName, reward.boxType)
    -- print('[DERP-DEBUG-SERVER] [5] giveReward rewarded = ' .. tostring(rewarded))

    if rewarded and rewardItem then
        DERP_LogAction(source, 'Nhận thưởng lootbox', {
            { 'box', DERP_FormatItemText(boxType, 1) },
            { 'item', DERP_FormatItemList({ rewardItem }, 'add') },
        })
    end

    pendingRewards[source] = nil
    cooldowns[source]      = nil

    local remaining = exports.ox_inventory:GetItem(source, boxType, nil, false)
    local hasMore   = remaining ~= nil and (remaining.count or 0) > 0
    -- print('[DERP-DEBUG-SERVER] [6] hasMore = ' .. tostring(hasMore) .. ', sending afterClaim')
    TriggerClientEvent('derp-lootbox:afterClaim', source, hasMore)
    -- print('[DERP-DEBUG-SERVER] [7] DONE')
end)

local pendingMultiRewards = {}

RegisterNetEvent('derp-lootbox:openBoxMulti', function(boxType)
    local source = source
    if fiveguard_resource ~= "" and GetResourceState(fiveguard_resource) == 'started' then
        if not exports[fiveguard_resource]:VerifyToken(source) then return end
    end
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

    DERP_LogAction(source, 'Mở lootbox x5', {
        { 'box', DERP_FormatItemText(boxType, 5, nil, 'remove') },
    })

    cooldowns[source] = now

    local winners = {}
    for i = 1, 5 do
        winners[i] = pickWeightedItem(boxConfig.items)
    end

    pendingMultiRewards[source] = {
        rewards   = winners,
        boxType   = boxType,
        expiresAt = now + 120000 
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
    -- print('[DERP-DEBUG-SERVER] claimRewardMulti received from src=' .. tostring(source))
    -- print('[DERP-DEBUG-SERVER] pendingMultiRewards[src] = ' .. tostring(pendingMultiRewards[source] ~= nil))
 
    if fiveguard_resource ~= "" and GetResourceState(fiveguard_resource) == 'started' then
        if not exports[fiveguard_resource]:VerifyToken(source) then
            -- print('[DERP-DEBUG-SERVER] BLOCKED by fiveguard VerifyToken')
            return
        end
    end
    local data = pendingMultiRewards[source]
    if not data then return end

    if os.time() > data.expiresAt then
        pendingMultiRewards[source] = nil
        return
    end

    local rewardItems = {}

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
            local rewarded, rewardItem = giveReward(source, wonItemName, data.boxType)
            if rewarded and rewardItem then
                rewardItems[#rewardItems + 1] = rewardItem
            end
        end
    end

    local boxType = data.boxType
    if #rewardItems > 0 then
        DERP_LogAction(source, 'Nhận thưởng lootbox x5', {
            { 'box', DERP_FormatItemText(boxType, 5) },
            { 'items', DERP_FormatItemList(rewardItems, 'add') },
        })
    end

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