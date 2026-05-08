local ClothingRarity = {}
local ValidClothingItems = {}
-- Pool item theo rarity de random output
-- structure: { [rarity] = { { name, drawableId, textureId, gender }, ... } }
local OutputPool = {
    common    = { all = {}, byGender = { [0] = {}, [1] = {} } },
    rare      = { all = {}, byGender = { [0] = {}, [1] = {} } },
    epic      = { all = {}, byGender = { [0] = {}, [1] = {} } },
    legendary = { all = {}, byGender = { [0] = {}, [1] = {} } },
    mythic    = { all = {}, byGender = { [0] = {}, [1] = {} } },
}

-- ==================== js_ranking action log ====================

local function AddActionLog(anyPlayer, actionText, opts)
    if GetResourceState('js_ranking') ~= 'started' then return false end
    if not actionText or actionText == '' then return false end

    local ok = pcall(function()
        exports['js_ranking']:AddActionLog(anyPlayer, actionText, opts)
    end)

    return ok
end

exports('AddActionLog', AddActionLog)

local function normalizeGender(gender)
    if gender == nil then return nil end

    if type(gender) == 'number' then
        if gender == 0 then return 'nam' end
        if gender == 1 then return 'nu' end
        return tostring(gender)
    end

    local text = tostring(gender):lower()

    if text == 'male' or text == 'm' or text == '0' then
        return 'nam'
    end

    if text == 'female' or text == 'f' or text == '1' then
        return 'nu'
    end

    return tostring(gender)
end

local function getItemLabel(name, metadata)
    if type(metadata) == 'table' and metadata.label and metadata.label ~= '' then
        return tostring(metadata.label)
    end

    local label = tostring(name or '')
    local ok, itemData = pcall(function()
        return exports.ox_inventory:Items(name)
    end)

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
        if gender then
            extras[#extras + 1] = gender
        end
    end

    if #extras > 0 then
        label = ('%s [%s]'):format(label, table.concat(extras, ' '))
    end

    return label
end

local function formatItem(name, count, metadata, mode)
    name = tostring(name or '')
    count = tonumber(count) or 0

    local label = getItemLabel(name, metadata)
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
    local message = ('[tradeup] | %s'):format(tostring(title or ''))

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

local function logTradeUp(src, title, details, opts)
    return AddActionLog(src, buildActionText(title, details), opts)
end

-- ==================== Load rarity config tu ox_inventory ====================

local function LoadRarityConfig()
    local content = LoadResourceFile('ox_inventory', 'modules/rarity/shared.lua')
    if not content then
        print('^1[DERP-tradeup] Khong tim thay modules/rarity/shared.lua trong ox_inventory^0')
        return
    end

    local env = {
        RarityConfig = { clothing = {} },
        pairs = pairs, ipairs = ipairs, next = next,
        type = type, tostring = tostring, tonumber = tonumber,
        math = math, string = string, table = table,
        print = print,
    }
    env._G = env

    local fn, loadErr = load(content, '@ox_rarity_shared', 't', env)
    if not fn then
        print('^1[DERP-tradeup] Parse loi rarity config: ' .. tostring(loadErr) .. '^0')
        return
    end

    local ok, runResult = pcall(fn)
    if not ok then
        print('^1[DERP-tradeup] Loi khi chay rarity config: ' .. tostring(runResult) .. '^0')
        return
    end

    if type(runResult) == 'table' and runResult.clothing then
        ClothingRarity = runResult.clothing
    else
        ClothingRarity = env.RarityConfig.clothing or {}
    end

    -- Build output pool theo rarity, chia theo gender + unisex
    for r in pairs(OutputPool) do
        OutputPool[r] = { all = {}, byGender = { [0] = {}, [1] = {} } }
    end

    -- Cache item list tu ox_inventory de validate name la item that
    local validItems = exports.ox_inventory:Items()
    ValidClothingItems = {}

    local function isValidClothingName(name)
        if not name or name == '' then return false end
        if name == 'balo' then return false end
        if name:sub(1, 5) == 'balo_' then return false end
        if not validItems or not validItems[name] then return false end
        return true
    end

    for key, rarity in pairs(ClothingRarity) do
        if Config.ValidRarities[rarity] then
            -- Match key: name_draw_tex_gen
            local name, draw, tex, gen = key:match('^(.+)_(%d+)_(%d+)_(%d+)$')

            if name and isValidClothingName(name) then
                local entry = {
                    name       = name,
                    drawableId = tonumber(draw),
                    textureId  = tonumber(tex),
                    gender     = tonumber(gen),
                }
                local pool = OutputPool[rarity]
                pool.all[#pool.all + 1] = entry
                if pool.byGender[entry.gender] then
                    pool.byGender[entry.gender][#pool.byGender[entry.gender] + 1] = entry
                end
                ValidClothingItems[name] = true
            else
                -- Match key: name_draw_tex (unisex)
                name, draw, tex = key:match('^(.+)_(%d+)_(%d+)$')
                if name and isValidClothingName(name) then
                    local entry = {
                        name       = name,
                        drawableId = tonumber(draw),
                        textureId  = tonumber(tex),
                        gender     = nil,
                    }
                    local pool = OutputPool[rarity]
                    pool.all[#pool.all + 1] = entry
                    pool.byGender[0][#pool.byGender[0] + 1] = entry
                    pool.byGender[1][#pool.byGender[1] + 1] = entry
                    ValidClothingItems[name] = true
                end
            end
        end
    end

    print(('^2[DERP-tradeup] Loaded pool: common=%d rare=%d epic=%d legendary=%d^0'):format(
        #OutputPool.common.all, #OutputPool.rare.all, #OutputPool.epic.all, #OutputPool.legendary.all
    ))
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

    local meta = metadata or {}
    local draw = tostring(meta.drawableId or '')
    local tex  = tostring(meta.textureId  or '')
    local gen  = tostring(meta.gender     or '')

    return ClothingRarity[('%s_%s_%s_%s'):format(name, draw, tex, gen)]
        or ClothingRarity[('%s_%s_%s'):format(name, draw, tex)]
end

-- ==================== Callbacks ====================

lib.callback.register('DERP-tradeup:getItems', function(source)
    local materials = {}

    for baseName in pairs(ValidClothingItems) do
        local raw = exports.ox_inventory:Search(source, 'slots', baseName)
        if type(raw) == 'table' then
            for _, item in pairs(raw) do
                if type(item) == 'table' and item.slot then
                    local meta   = item.metadata or {}
                    local rarity = getItemRarity(item.name, meta)
                    if rarity and Config.RarityUpgrade[rarity] then
                        materials[#materials + 1] = {
                            slot     = item.slot,
                            name     = item.name,
                            rarity   = rarity,
                            metadata = {
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

    return {
        materials = materials,
        config    = {
            requiredCount = Config.RequiredCount,
            rarityUpgrade = Config.RarityUpgrade,
        },
    }
end)

local processingPlayers = {}

AddEventHandler('playerDropped', function()
    processingPlayers[source] = nil
end)

local function doTradeUp(source, materialSlots, gender)
    -- Validate slot list: khong trung, trong range hop le
    local slotSet = {}
    for _, slot in ipairs(materialSlots) do
        if type(slot) ~= 'number' or slot < 1 or slot > 500 then
            return { error = 'invalid_slot' }
        end
        if slotSet[slot] then return { error = 'duplicate_slot' } end
        slotSet[slot] = true
    end

    -- Validate tung item: phai ton tai, la clothing co rarity, cung 1 rarity
    local validMaterials = {}
    local sharedRarity   = nil

    for _, slot in ipairs(materialSlots) do
        local item = exports.ox_inventory:GetSlot(source, slot)
        if not item then return { error = 'mat_missing' } end
        if item.name == 'balo' then return { error = 'balo_not_allowed' } end

        local meta   = item.metadata or {}
        local rarity = getItemRarity(item.name, meta)
        if not rarity then return { error = 'not_clothing' } end

        if not sharedRarity then
            sharedRarity = rarity
        elseif sharedRarity ~= rarity then
            return { error = 'rarity_mismatch' }
        end

        validMaterials[#validMaterials + 1] = {
            slot     = slot,
            name     = item.name,
            metadata = meta,
            rarity   = rarity,
        }
    end

    local nextRarity = Config.RarityUpgrade[sharedRarity]
    if not nextRarity then return { error = 'max_tier' } end

    local pool = OutputPool[nextRarity] and OutputPool[nextRarity].byGender[gender]
    if not pool or #pool == 0 then return { error = 'no_output_pool' } end

    -- Random output
    local pick = pool[math.random(1, #pool)]
    if not pick then return { error = 'no_output_pool' } end

    -- Build metadata cho item moi
    local newMeta = {
        drawableId = pick.drawableId,
        textureId  = pick.textureId,
    }
    if pick.gender ~= nil then
        newMeta.gender = pick.gender
    else
        newMeta.gender = gender
    end

    -- Remove 9 nguyen lieu
    local removed = {}
    for _, mat in ipairs(validMaterials) do
        local ok = exports.ox_inventory:RemoveItem(source, mat.name, 1, nil, mat.slot)
        if not ok then
            print(('^1[DERP-tradeup] RemoveItem failed src=%s item=%s slot=%s^0'):format(source, mat.name, mat.slot))
            -- Rollback nhung mat da remove truoc do
            for _, r in ipairs(removed) do
                exports.ox_inventory:AddItem(source, r.name, 1, r.metadata)
            end
            return { error = 'remove_failed' }
        end
        removed[#removed + 1] = mat
    end

    -- Cho ox_inventory commit cac thay doi truoc khi add item moi
    Wait(50)

    local addOk = exports.ox_inventory:AddItem(source, pick.name, 1, newMeta)
    if not addOk then
        print(('^1[DERP-tradeup] AddItem failed src=%s item=%s draw=%s tex=%s gen=%s^0'):format(
            source, pick.name, tostring(newMeta.drawableId), tostring(newMeta.textureId), tostring(newMeta.gender)
        ))
        -- Het slot/weight inventory: tra lai 9 nguyen lieu
        for _, mat in ipairs(validMaterials) do
            exports.ox_inventory:AddItem(source, mat.name, 1, mat.metadata)
        end
        return { error = 'inventory_full' }
    end

    -- Log
    local materialText = {}
    for _, m in ipairs(validMaterials) do
        materialText[#materialText + 1] = formatItem(m.name, 1, m.metadata, 'remove')
    end

    logTradeUp(source, 'Trade-up clothing', {
        { 'rarity', ('%s -> %s'):format(sharedRarity, nextRarity) },
        { 'nguyen_lieu', table.concat(materialText, ', ') },
        { 'ket_qua', formatItem(pick.name, 1, newMeta, 'add') },
        { 'gender_chon', normalizeGender(gender) },
    })

    return {
        success    = true,
        oldRarity  = sharedRarity,
        newRarity  = nextRarity,
        result     = {
            name     = pick.name,
            metadata = newMeta,
            rarity   = nextRarity,
        },
    }
end

lib.callback.register('DERP-tradeup:tradeUp', function(source, materialSlots, gender)
    if processingPlayers[source] then
        return { error = 'busy' }
    end

    if type(materialSlots) ~= 'table' or #materialSlots ~= Config.RequiredCount then
        return { error = 'invalid_count' }
    end

    if gender ~= 0 and gender ~= 1 then
        return { error = 'invalid_gender' }
    end

    processingPlayers[source] = true

    local ok, result = pcall(doTradeUp, source, materialSlots, gender)

    processingPlayers[source] = nil

    if not ok then
        print(('^1[DERP-tradeup] tradeUp error src=%s: %s^0'):format(source, tostring(result)))
        return { error = 'internal' }
    end

    return result
end)