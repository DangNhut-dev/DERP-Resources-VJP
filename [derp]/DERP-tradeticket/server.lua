local ClothingRarity    = {}
local ValidClothingItems = {}

-- ==================== js_ranking ====================

local function getBonusTickets(itemName)
    for prefix, bonus in pairs(Config.BonusItems) do
        if itemName:sub(1, #prefix) == prefix then
            return bonus
        end
    end
    return 0
end

local function AddActionLog(anyPlayer, actionText, opts)
    if GetResourceState('js_ranking') ~= 'started' then return false end
    if not actionText or actionText == '' then return false end
    local ok = pcall(function()
        exports['js_ranking']:AddActionLog(anyPlayer, actionText, opts)
    end)
    return ok
end

local function normalizeGender(gender)
    if gender == nil then return nil end
    if type(gender) == 'number' then
        if gender == 0 then return 'nam' end
        if gender == 1 then return 'nu' end
        return tostring(gender)
    end
    local text = tostring(gender):lower()
    if text == 'male' or text == 'm' or text == '0' then return 'nam' end
    if text == 'female' or text == 'f' or text == '1' then return 'nu' end
    return tostring(gender)
end

local function getItemLabel(name, metadata)
    local label = tostring(name or '')
    local ok, itemData = pcall(function() return exports.ox_inventory:Items(name) end)
    if ok and type(itemData) == 'table' and itemData.label and itemData.label ~= '' then
        label = tostring(itemData.label)
    end
    local extras = {}
    if type(metadata) == 'table' then
        if metadata.drawableId ~= nil then
            extras[#extras + 1] = ('d%s'):format(tostring(metadata.drawableId))
        end
        if metadata.textureId ~= nil then
            extras[#extras + 1] = ('t%s'):format(tostring(metadata.textureId))
        end
        local gender = normalizeGender(metadata.gender)
        if gender then extras[#extras + 1] = gender end
    end
    if #extras > 0 then
        label = ('%s [%s]'):format(label, table.concat(extras, ' '))
    end
    return label
end

local function formatItem(name, count, metadata, mode)
    name  = tostring(name or '')
    count = tonumber(count) or 0
    local label   = getItemLabel(name, metadata)
    local display = name
    if label ~= '' and label ~= name then
        display = ('%s(%s)'):format(name, label)
    end
    local prefix = ''
    if mode == 'add'    then prefix = '+'
    elseif mode == 'remove' then prefix = '-' end
    if count > 0 then return ('%s%s x%s'):format(prefix, display, math.floor(count)) end
    return prefix .. display
end

local function buildActionText(title, details)
    local message = ('[tradeticket] | %s'):format(tostring(title or ''))
    if type(details) == 'table' and #details > 0 then
        local parts = {}
        for i = 1, #details do
            local entry = details[i]
            local key   = entry and entry[1]
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

local function logAction(src, title, details)
    return AddActionLog(src, buildActionText(title, details))
end

-- ==================== Load rarity config ====================

local function LoadRarityConfig()
    local content = LoadResourceFile('ox_inventory', 'modules/rarity/shared.lua')
    if not content then
        print('^1[DERP-tradeticket] Khong tim thay modules/rarity/shared.lua^0')
        return
    end

    local env = {
        RarityConfig = { clothing = {} },
        pairs = pairs, ipairs = ipairs, next = next,
        type = type, tostring = tostring, tonumber = tonumber,
        math = math, string = string, table = table, print = print,
    }
    env._G = env

    local fn, loadErr = load(content, '@ox_rarity_shared', 't', env)
    if not fn then
        print('^1[DERP-tradeticket] Parse loi rarity config: ' .. tostring(loadErr) .. '^0')
        return
    end

    local ok, runResult = pcall(fn)
    if not ok then
        print('^1[DERP-tradeticket] Loi khi chay rarity config: ' .. tostring(runResult) .. '^0')
        return
    end

    if type(runResult) == 'table' and runResult.clothing then
        ClothingRarity = runResult.clothing
    else
        ClothingRarity = env.RarityConfig.clothing or {}
    end

    local validItems = exports.ox_inventory:Items()
    ValidClothingItems = {}

    local function isValidClothingName(name)
        if not name or name == '' then return false end
        if name == 'balo' then return false end
        if name:match('^balo_%d+_%d+_%d+$') then
            return validItems[name] ~= nil
        end
        if name:sub(1, 5) == 'balo_' and not name:match('^balo_%d+_%d+_%d+$') then
            return false
        end
        if not validItems or not validItems[name] then return false end
        return true
    end

    for key, rarity in pairs(ClothingRarity) do
        if Config.RarityValue[rarity] then
            if key:match('^balo_%d+_%d+_%d+$') then
                if validItems[key] then
                    ValidClothingItems[key] = 'direct'
                end
            else
                local name = key:match('^(.+)_%d+_%d+_%d+$') or key:match('^(.+)_%d+_%d+$')
                if name and isValidClothingName(name) then
                    ValidClothingItems[name] = true
                end
            end
        end
    end

    print('^2[DERP-tradeticket] Loaded rarity config OK^0')
end

AddEventHandler('onResourceStart', function(res)
    if res == GetCurrentResourceName() or res == 'ox_inventory' then
        LoadRarityConfig()
    end
end)

LoadRarityConfig()

-- ==================== Helpers ====================

local function getItemRarity(name, metadata)
    if name == 'balo' then return nil end
    if name:match('^balo_%d+_%d+_%d+$') then
        return ClothingRarity[name]
    end
    local meta = metadata or {}
    local draw = tostring(meta.drawableId or '')
    local tex  = tostring(meta.textureId  or '')
    local gen  = tostring(meta.gender     or '')
    return ClothingRarity[('%s_%s_%s_%s'):format(name, draw, tex, gen)]
        or ClothingRarity[('%s_%s_%s'):format(name, draw, tex)]
end

-- ==================== Callbacks ====================

-- Tra ve danh sach clothing co rarity hop le + so ticket hien co + shop items
lib.callback.register('DERP-tradeticket:getItems', function(source)
    local src      = source
    local materials = {}

    for baseName, mode in pairs(ValidClothingItems) do
        local raw = exports.ox_inventory:Search(src, 'slots', baseName)
        if type(raw) == 'table' then
            for _, item in pairs(raw) do
                if type(item) == 'table' and item.slot then
                    local meta   = item.metadata or {}
                    local rarity = getItemRarity(item.name, meta)
                    if rarity and Config.RarityValue[rarity] then
                        materials[#materials + 1] = {
                            slot        = item.slot,
                            name        = item.name,
                            rarity      = rarity,
                            ticketValue = Config.RarityValue[rarity] + getBonusTickets(item.name),
                            metadata    = mode == 'direct' and {} or {
                                drawableId = meta.drawableId,
                                textureId  = meta.textureId,
                                gender     = meta.gender,
                            },
                        }
                    end
                end
            end
        end
    end

    -- Dem so ticket hien co
    local ticketCount = 0
    local ticketSearch = exports.ox_inventory:Search(src, 'count', Config.TicketItem)
    if type(ticketSearch) == 'number' then
        ticketCount = ticketSearch
    end

    return {
        materials    = materials,
        rarityValue  = Config.RarityValue,
        ticketItem   = Config.TicketItem,
        ticketCount  = ticketCount,
        shopItems    = Config.ShopItems,
        clothingSlots = Config.ClothingSlots,
    }
end)

local processingPlayers = {}

AddEventHandler('playerDropped', function()
    processingPlayers[source] = nil
end)

-- Doi nhieu mon clothing -> ticket
lib.callback.register('DERP-tradeticket:exchange', function(source, selectedSlots)
    local src = source

    if processingPlayers[src] then
        return { error = 'busy' }
    end

    if type(selectedSlots) ~= 'table' or #selectedSlots == 0 then
        return { error = 'invalid_data' }
    end

    if #selectedSlots > 200 then
        return { error = 'too_many' }
    end

    local slotSet = {}
    for _, slot in ipairs(selectedSlots) do
        if type(slot) ~= 'number' or slot < 1 or slot > 500 then
            return { error = 'invalid_slot' }
        end
        if slotSet[slot] then return { error = 'duplicate_slot' } end
        slotSet[slot] = true
    end

    processingPlayers[src] = true

    local ok, result = pcall(function()
        local totalTickets   = 0
        local validMaterials = {}
        local removedItems   = {}

        for _, slot in ipairs(selectedSlots) do
            local item = exports.ox_inventory:GetSlot(src, slot)
            if not item then
                return { error = 'item_missing', slot = slot }
            end

            local meta   = item.metadata or {}
            local rarity = getItemRarity(item.name, meta)
            if not rarity or not Config.RarityValue[rarity] then
                return { error = 'invalid_rarity', slot = slot }
            end

            validMaterials[#validMaterials + 1] = {
                slot        = slot,
                name        = item.name,
                metadata    = meta,
                rarity      = rarity,
                ticketValue = Config.RarityValue[rarity] + getBonusTickets(item.name),
            }
            totalTickets = totalTickets + Config.RarityValue[rarity] + getBonusTickets(item.name)
        end

        if totalTickets < 1 then
            return { error = 'no_tickets' }
        end

        for _, mat in ipairs(validMaterials) do
            local removeOk = exports.ox_inventory:RemoveItem(src, mat.name, 1, nil, mat.slot)
            if not removeOk then
                for _, r in ipairs(removedItems) do
                    exports.ox_inventory:AddItem(src, r.name, 1, r.metadata)
                end
                return { error = 'remove_failed', slot = mat.slot }
            end
            removedItems[#removedItems + 1] = mat
        end

        Wait(50)

        local addOk = exports.ox_inventory:AddItem(src, Config.TicketItem, totalTickets)
        if not addOk then
            for _, r in ipairs(removedItems) do
                exports.ox_inventory:AddItem(src, r.name, 1, r.metadata)
            end
            return { error = 'inventory_full' }
        end

        local removedText = {}
        for _, m in ipairs(validMaterials) do
            removedText[#removedText + 1] = formatItem(m.name, 1, m.metadata, 'remove')
        end

        logAction(src, 'Doi ticket', {
            { 'so_mon',  tostring(#validMaterials) },
            { 'ticket',  tostring(totalTickets) },
            { 'mon_doi', table.concat(removedText, ', ') },
        })

        return { success = true, ticketsGained = totalTickets }
    end)

    processingPlayers[src] = nil

    if not ok then
        print(('^1[DERP-tradeticket] exchange error src=%s: %s^0'):format(src, tostring(result)))
        return { error = 'internal' }
    end

    return result
end)

-- Mua item tu shop bang ticket
lib.callback.register('DERP-tradeticket:buyShopItem', function(source, itemId)
    local src = source

    if processingPlayers[src] then
        return { error = 'busy' }
    end

    if type(itemId) ~= 'number' then
        return { error = 'invalid_data' }
    end

    -- Tim item trong config
    local shopItem = nil
    for _, item in ipairs(Config.ShopItems) do
        if item.id == itemId then
            shopItem = item
            break
        end
    end

    if not shopItem then
        return { error = 'item_not_found' }
    end

    processingPlayers[src] = true

    local ok, result = pcall(function()
        -- Kiem tra du ticket
        local ticketCount = exports.ox_inventory:Search(src, 'count', Config.TicketItem)
        if type(ticketCount) ~= 'number' or ticketCount < shopItem.price then
            return { error = 'not_enough_tickets' }
        end

        -- Tru ticket
        local removeOk = exports.ox_inventory:RemoveItem(src, Config.TicketItem, shopItem.price)
        if not removeOk then
            return { error = 'remove_ticket_failed' }
        end

        -- Add item voi metadata
        local metadata = {
            drawableId = shopItem.drawableId,
            textureId  = shopItem.textureId,
            gender     = shopItem.gender,
        }

        local addOk = exports.ox_inventory:AddItem(src, shopItem.name, 1, metadata)
        if not addOk then
            -- Rollback ticket
            exports.ox_inventory:AddItem(src, Config.TicketItem, shopItem.price)
            return { error = 'inventory_full' }
        end

        logAction(src, 'Mua shop', {
            { 'item',   formatItem(shopItem.name, 1, metadata, 'add') },
            { 'ticket', '-' .. tostring(shopItem.price) },
            { 'label',  tostring(shopItem.label) },
        })

        -- Dem lai ticket sau khi mua
        local newTicketCount = exports.ox_inventory:Search(src, 'count', Config.TicketItem)

        return {
            success      = true,
            ticketCount  = type(newTicketCount) == 'number' and newTicketCount or 0,
        }
    end)

    processingPlayers[src] = nil

    if not ok then
        print(('^1[DERP-tradeticket] buyShopItem error src=%s: %s^0'):format(src, tostring(result)))
        return { error = 'internal' }
    end

    return result
end)