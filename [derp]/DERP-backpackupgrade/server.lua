local ClothingRarity   = {}
local ClothingItemNames = {}

local function LoadRarityConfig()
    local content = LoadResourceFile('ox_inventory', 'modules/rarity/shared.lua')
    if not content then
        print('^1[DERP-backpackupgrade] Không tìm thấy modules/rarity/shared.lua trong ox_inventory^0')
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
        print('^1[DERP-backpackupgrade] Parse lỗi rarity config: ' .. tostring(loadErr) .. '^0')
        return
    end

    local ok, runResult = pcall(fn)
    if not ok then
        print('^1[DERP-backpackupgrade] Lỗi khi chạy rarity config: ' .. tostring(runResult) .. '^0')
        return
    end

    if type(runResult) == 'table' and runResult.clothing then
        ClothingRarity = runResult.clothing
    else
        ClothingRarity = env.RarityConfig.clothing or {}
    end

    ClothingItemNames = {}
    for name in pairs(ClothingRarity) do
        ClothingItemNames[#ClothingItemNames + 1] = name
    end
end

AddEventHandler('onResourceStart', function(res)
    if res == GetCurrentResourceName() or res == 'ox_inventory' then
        LoadRarityConfig()
    end
end)

LoadRarityConfig()

lib.callback.register('DERP-backpackupgrade:getItems', function(source)
    local balos     = {}
    local materials = {}

    local baloRaw = exports.ox_inventory:Search(source, 'slots', 'balo')

    if type(baloRaw) == 'table' then
        for k, v in pairs(baloRaw) do
            local slot, meta
            if type(v) == 'table' then
                slot = v.slot
                meta = v.metadata or {}
            elseif type(v) == 'number' then
                slot = v
                local slotData = exports.ox_inventory:GetSlot(source, slot)
                meta = slotData and slotData.metadata or {}
            end
            if slot then
                local level = (meta and meta.level) or 0
                balos[#balos + 1] = {
                    slot     = slot,
                    name     = 'balo',
                    metadata = meta,
                    canUp    = Config.RequirePoints[level] ~= nil,
                }
            end
        end
    end

    local baseNames = {}
    for key in pairs(ClothingRarity) do
        local base = key:match('^(.+)_%d+_%d+_%d+$')
        if not base then
            base = key:match('^(.+)_%d+_%d+$')
        end
        if base and not baseNames[base] then
            baseNames[base] = true
        end
    end

    for baseName in pairs(baseNames) do
        local raw = exports.ox_inventory:Search(source, 'slots', baseName)
        if type(raw) == 'table' then
            for _, item in pairs(raw) do
                if type(item) == 'table' and item.slot then
                    local meta   = item.metadata or {}
                    local draw   = tostring(meta.drawableId or '')
                    local tex    = tostring(meta.textureId  or '')
                    local gen    = tostring(meta.gender     or '')
                    local rarity = ClothingRarity[('%s_%s_%s_%s'):format(baseName, draw, tex, gen)]
                                or ClothingRarity[('%s_%s_%s'):format(baseName, draw, tex)]
                    if rarity then
                        materials[#materials + 1] = {
                            slot     = item.slot,
                            name     = item.name,
                            rarity   = rarity,
                            points   = Config.RarityPoints[rarity] or 0,
                            -- metadata để client build đúng tên file ảnh
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
        balos     = balos,
        materials = materials,
        config    = {
            rarityPoints     = Config.RarityPoints,
            requirePoints    = Config.RequirePoints,
            maxMaterialSlots = Config.MaxMaterialSlots,
        },
    }
end)

local pendingUpgrades = {}

lib.callback.register('DERP-backpackupgrade:upgrade', function(source, baloSlot, materialSlots, arcStartDeg)
    if type(baloSlot) ~= 'number' or baloSlot < 1 or baloSlot > 500 then
        return { error = 'invalid_slot' }
    end
    if type(materialSlots) ~= 'table'
        or #materialSlots < 1
        or #materialSlots > Config.MaxMaterialSlots then
        return { error = 'invalid_materials' }
    end

    local slotSet = {}
    for _, slot in ipairs(materialSlots) do
        if type(slot) ~= 'number' or slot < 1 or slot > 500 then
            return { error = 'invalid_mat_slot' }
        end
        if slot == baloSlot   then return { error = 'slot_conflict' } end
        if slotSet[slot]      then return { error = 'duplicate_slot' } end
        slotSet[slot] = true
    end

    local baloItem = exports.ox_inventory:GetSlot(source, baloSlot)
    if not baloItem or baloItem.name ~= 'balo' then
        return { error = 'no_balo' }
    end

    local level    = (baloItem.metadata and baloItem.metadata.level) or 0
    local required = Config.RequirePoints[level]
    if not required then return { error = 'max_level' } end

    local totalPoints    = 0
    local validMaterials = {}

    for _, slot in ipairs(materialSlots) do
        local item = exports.ox_inventory:GetSlot(source, slot)
        if not item then return { error = 'mat_missing' } end

        local meta   = item.metadata or {}
        local draw   = tostring(meta.drawableId or '')
        local tex    = tostring(meta.textureId  or '')
        local gen    = tostring(meta.gender     or '')
        local rarity = ClothingRarity[('%s_%s_%s_%s'):format(item.name, draw, tex, gen)]
                    or ClothingRarity[('%s_%s_%s'):format(item.name, draw, tex)]
        if not rarity then return { error = 'not_clothing' } end

        local pts = Config.RarityPoints[rarity]
        if not pts then return { error = 'no_points' } end

        totalPoints = totalPoints + pts
        validMaterials[#validMaterials + 1] = { slot = slot, name = item.name, rarity = rarity }
    end

    if type(arcStartDeg) ~= 'number' then arcStartDeg = 0 end
    arcStartDeg = math.max(0, math.min(359, math.floor(arcStartDeg)))

    local chance     = math.min(totalPoints / required, 1.0)
    local arcSizeDeg = chance * 360
    local rollDeg    = math.random(0, 35999) / 100

    local halfArc   = arcSizeDeg / 2
    local arc2Start = (arcStartDeg + 180) % 360

    local function inArc(roll, start, size)
        local endDeg = start + size
        if endDeg <= 360 then
            return roll >= start and roll < endDeg
        else
            return roll >= start or roll < (endDeg - 360)
        end
    end

    local isWin = inArc(rollDeg, arcStartDeg, halfArc) or inArc(rollDeg, arc2Start, halfArc)

    for _, mat in ipairs(validMaterials) do
        exports.ox_inventory:RemoveItem(source, mat.name, 1, nil, mat.slot)
    end

    local newLevel
    if isWin then
        newLevel = level + 1
    else
        newLevel = (level <= 0) and -1 or (level - 1)
    end

    local token = ('%s_%s_%s'):format(source, os.time(), math.random(100000, 999999))

    pendingUpgrades[token] = {
        source   = source,
        baloSlot = baloSlot,
        baloMeta = baloItem.metadata,
        level    = level,
        newLevel = newLevel,
        isWin    = isWin,
        expires  = os.time() + 30,
    }

    local matInfo = {}
    for _, m in ipairs(validMaterials) do
        matInfo[#matInfo + 1] = { name = m.name, rarity = m.rarity }
    end

    return {
        isWin        = isWin,
        rollDeg      = rollDeg,
        arcStartDeg  = arcStartDeg,
        arcSizeDeg   = arcSizeDeg,
        currentLevel = level,
        newLevel     = newLevel,
        materials    = matInfo,
        token        = token,
    }
end)

RegisterNetEvent('DERP-backpackupgrade:confirmUpgrade', function(token)
    local source  = source
    local pending = token and pendingUpgrades[token]

    if not pending then return end
    if pending.source ~= source then return end
    if os.time() > pending.expires then
        pendingUpgrades[token] = nil
        return
    end

    pendingUpgrades[token] = nil

    local newLevel = pending.newLevel
    local baloSlot = pending.baloSlot

    local baloItem = exports.ox_inventory:GetSlot(source, baloSlot)
    if not baloItem or baloItem.name ~= 'balo' then return end

    if newLevel == -1 then
        exports.ox_inventory:RemoveItem(source, 'balo', 1, nil, baloSlot)
    else
        local newMeta = {}
        if pending.baloMeta then
            for k, v in pairs(pending.baloMeta) do newMeta[k] = v end
        end
        newMeta.level = newLevel
        exports.ox_inventory:RemoveItem(source, 'balo', 1, nil, baloSlot)
        exports.ox_inventory:AddItem(source, 'balo', 1, newMeta, baloSlot)
    end
end)

lib.cron.new('* * * * *', function()
    local now = os.time()
    for token, data in pairs(pendingUpgrades) do
        if now > data.expires then
            pendingUpgrades[token] = nil
        end
    end
end)

RegisterCommand('bpdbg', function(src, args)
    if src ~= 0 then return end
    local target = tonumber(args[1])
    if not target then print('Usage: bpdbg <serverid>') return end

    local items = exports.ox_inventory:GetInventoryItems(target)

    local testItems = {'aokhoac_1_0_0','aokhoac_2_0_0','aokhoac_3_0_0','aokhoac_4_0_0','aokhoac_5_0_0','balo'}
    for _, name in ipairs(testItems) do
        local r = exports.ox_inventory:Search(target, 'slots', name)
    end

    local n = 0
    for _ in pairs(ClothingRarity) do n = n + 1 end
    print('[BPD] ClothingRarity dump = ' .. json.encode(ClothingRarity))
end, true)