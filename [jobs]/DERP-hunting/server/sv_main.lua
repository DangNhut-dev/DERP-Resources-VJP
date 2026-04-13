-- ============================
--   MAIN SERVER - HUNTING
-- ============================

local TableSize            = Config.sv_maxTableSize
local garbageCollection_tm = Config.sv_dataClearnigTimer
local Animals              = Config.Animals

local animalsEnity = {}


function DERPHuntingGetMoneySnapshot(anyPlayer)
    local player = anyPlayer

    if type(anyPlayer) == 'number' then
        player = exports['qbx_core']:GetPlayer(anyPlayer)
    end

    local money = player and player.PlayerData and player.PlayerData.money or {}

    return {
        cash = tonumber(money.cash or money.money or 0) or 0,
        bank = tonumber(money.bank or 0) or 0,
        crypto = tonumber(money.crypto or 0) or 0,
        coins = tonumber(money.coins or 0) or 0,
        black_money = tonumber(money.black_money or 0) or 0,
        coins_lock = tonumber(money.coins_lock or 0) or 0,
        point = tonumber(money.point or 0) or 0,
    }
end

function DERPHuntingGetItemLabel(itemName)
    if not itemName or itemName == '' then
        return 'unknown'
    end

    local ok, itemData = pcall(function()
        return exports['ox_inventory']:Items(itemName)
    end)

    if ok and type(itemData) == 'table' and itemData.label and itemData.label ~= '' then
        return itemData.label
    end

    if Config.HideSystem and Config.HideSystem.grades then
        for _, grade in ipairs(Config.HideSystem.grades) do
            if grade.item == itemName and grade.label and grade.label ~= '' then
                return grade.label
            end
        end
    end

    for _, animalCfg in ipairs(Config.Animals or {}) do
        if animalCfg.meatItem == itemName then
            return itemName
        end
    end

    return itemName
end

function DERPHuntingBuildItemEntry(itemName, amount, label)
    local count = tonumber(amount) or 0
    if count == 0 then
        return nil
    end

    return {
        name = itemName,
        count = math.abs(count),
        label = label or DERPHuntingGetItemLabel(itemName)
    }
end

function DERPHuntingFormatItemList(entries)
    if type(entries) ~= 'table' or #entries == 0 then
        return 'không có'
    end

    local merged = {}
    local order = {}

    for _, entry in ipairs(entries) do
        if entry and entry.name and entry.count and entry.count > 0 then
            if not merged[entry.name] then
                merged[entry.name] = {
                    name = entry.name,
                    label = entry.label or DERPHuntingGetItemLabel(entry.name),
                    count = 0
                }
                order[#order + 1] = entry.name
            end

            merged[entry.name].count = merged[entry.name].count + entry.count
        end
    end

    local parts = {}
    for _, itemName in ipairs(order) do
        local entry = merged[itemName]
        parts[#parts + 1] = ('%sx %s(%s)'):format(entry.count, entry.name, entry.label or entry.name)
    end

    if #parts == 0 then
        return 'không có'
    end

    return table.concat(parts, ', ')
end

function DERPHuntingActionLog(src, actionText, opts)
    if not src or not actionText or actionText == '' then
        return false
    end

    local state = GetResourceState('js_ranking')
    if state ~= 'started' and state ~= 'starting' then
        return false
    end

    local ok, result = pcall(function()
        return exports['js_ranking']:AddActionLog(src, actionText, opts or {})
    end)

    return ok and result or false
end

-- ============================
--   SLAUGHTER TABLE
--   slaughteredNetIds[netId] = src  → đang bị claim bởi src
--   slaughteredNetIds[netId] = true → đã lột xong vĩnh viễn
-- ============================

local slaughteredNetIds = {}
local CLAIM_TIMEOUT     = 30000

local function claimNetId(netId, src)
    if slaughteredNetIds[netId] ~= nil then
        return false
    end

    slaughteredNetIds[netId] = src

    SetTimeout(CLAIM_TIMEOUT, function()
        if slaughteredNetIds[netId] == src then
            slaughteredNetIds[netId] = nil
        end
    end)

    return true
end

function isAleadySlaughtered(netId)
    return slaughteredNetIds[netId] ~= nil
end

function setHash(netId)
    slaughteredNetIds[netId] = true
end

function garbageCollection()
    local count = 0
    for _ in pairs(slaughteredNetIds) do count = count + 1 end
    if count > TableSize then
        slaughteredNetIds = {}
    end
end

-- ============================
--   SLAUGHTER + LOOT
-- ============================

local KNIFE_ITEMS = { 'knife', 'weapon_knife' }

local function hasKnifeInInventory(src)
    for _, itemName in ipairs(KNIFE_ITEMS) do
        local count = exports['ox_inventory']:GetItem(src, itemName, nil, false)
        if count and count.count and count.count > 0 then
            return true
        end
    end
    return false
end

RegisterServerEvent('DERP-hunting:server:checkKnife')
AddEventHandler('DERP-hunting:server:checkKnife', function(animal, entity, netId)
    local src = source

    if not exports['qbx_core']:GetPlayer(src) then
        return
    end

    if not hasKnifeInInventory(src) then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Bạn không có dao!' })
        return
    end

    netId = tonumber(netId)

    if not netId then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Không thể xác định con thú!' })
        return
    end

    local existing = slaughteredNetIds[netId]

    if not claimNetId(netId, src) then
        return
    end

    TriggerClientEvent('DERP-hunting:client:startSkinning', src, entity, animal, netId)
end)

RegisterServerEvent('DERP-hunting:server:AddItem')
AddEventHandler('DERP-hunting:server:AddItem', function(data, entity, _unused, netId)
    local src = source

    local Player = exports['qbx_core']:GetPlayer(src)
    if not Player then return end

    netId = tonumber(netId)

    if not netId then return end

    local claimedBy = slaughteredNetIds[netId]

    if claimedBy ~= src then
        TriggerClientEvent('DERP-hunting:client:ForceRemoveAnimalEntity', src, entity)
        return
    end

    slaughteredNetIds[netId] = true

    -- NetId được game tái sử dụng sau khi entity xóa → clear sau 10s
    SetTimeout(10000, function()
        if slaughteredNetIds[netId] == true then
            slaughteredNetIds[netId] = nil
        end
    end)

    local animalCfg = nil
    for _, v in pairs(Config.Animals) do
        if v.model == data.model then
            animalCfg = v
            break
        end
    end

    if not animalCfg then
        return
    end

    choiceRewardsForPlayer(animalCfg, src, Player)
    TriggerClientEvent('DERP-hunting:client:ForceRemoveAnimalEntity', -1, entity)

    local model, gid = isAnimalNetIdInActiveZone(netId, src)
    if model and gid then
        TriggerEvent('DERP-hunting:server:jobKillCount', src, model, gid)
    end
end)

-- Random da theo tỉ lệ trong Config.HideSystem.grades
local function rollHideGrade()
    local grades     = Config.HideSystem.grades
    local roll       = math.random(1, 100)
    local cumulative = 0
    for _, grade in ipairs(grades) do
        cumulative = cumulative + grade.chance
        if roll <= cumulative then
            return grade
        end
    end
    return grades[1]
end

-- Loot thịt + da sau khi lột
function choiceRewardsForPlayer(animalCfg, src, Player)
    -- Tính trước loot để check slot
    local meatAmount, meatItem
    local hideAmount, hideGrade
    local rewardEntries = {}

    if animalCfg.meatItem and animalCfg.meatAmount then
        meatAmount = math.random(animalCfg.meatAmount.min, animalCfg.meatAmount.max)
        meatItem   = animalCfg.meatItem
    end

    if Config.HideSystem.enabled then
        hideGrade  = rollHideGrade()
        hideAmount = math.random(Config.HideSystem.amountMin, Config.HideSystem.amountMax)
    end

    -- Check slot/weight trước khi add
    if meatItem then
        local canCarry = exports['ox_inventory']:CanCarryItem(src, meatItem, meatAmount)
        if not canCarry then
            TriggerClientEvent('ox_lib:notify', src, {
                type        = 'error',
                description = 'Túi không đủ chỗ cho thịt! Hãy bỏ bớt đồ.',
                duration    = 5000,
            })
            print(('[DERP-hunting] [DEBUG] choiceRewards | src=%s cant carry meat %sx %s'):format(src, meatAmount, meatItem))
            return
        end
    end

    if hideGrade then
        local canCarry = exports['ox_inventory']:CanCarryItem(src, hideGrade.item, hideAmount)
        if not canCarry then
            TriggerClientEvent('ox_lib:notify', src, {
                type        = 'error',
                description = 'Túi không đủ chỗ cho da! Hãy bỏ bớt đồ.',
                duration    = 5000,
            })
            print(('[DERP-hunting] [DEBUG] choiceRewards | src=%s cant carry hide %sx %s'):format(src, hideAmount, hideGrade.item))
            return
        end
    end

    -- Add item
    if meatItem then
        exports['ox_inventory']:AddItem(src, meatItem, meatAmount)
        rewardEntries[#rewardEntries + 1] = DERPHuntingBuildItemEntry(meatItem, meatAmount)
        print(('[DERP-hunting] [DEBUG] loot | src=%s +%sx %s (meat)'):format(src, meatAmount, meatItem))
    end

    if hideGrade then
        exports['ox_inventory']:AddItem(src, hideGrade.item, hideAmount)
        rewardEntries[#rewardEntries + 1] = DERPHuntingBuildItemEntry(hideGrade.item, hideAmount, hideGrade.label)
        print(('[DERP-hunting] [DEBUG] loot | src=%s +%sx %s (hide grade=%s)'):format(src, hideAmount, hideGrade.item, hideGrade.label))
    end

    if #rewardEntries > 0 then
        DERPHuntingActionLog(src,
            ('DERP-hunting | Nhận item | Danh sách: %s | Nguồn: lột thú | Loại: %s'):format(
                DERPHuntingFormatItemList(rewardEntries),
                animalCfg.model or 'unknown'
            )
        )
    end
end

-- ============================
--   SELLING (bulk)
-- ============================

RegisterServerEvent('DERP-hunting:server:sellmeat')
AddEventHandler('DERP-hunting:server:sellmeat', function()
    local src    = source
    local Player = exports['qbx_core']:GetPlayer(src)
    if not Player then return end

    local price = 0
    local items = exports['ox_inventory']:GetInventoryItems(src)
    local soldEntries = {}

    if not items or not next(items) then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Bạn không có đồ!' })
        return
    end

    for _, v in pairs(items) do
        if v and v.count and v.count > 0 then
            for _, grade in ipairs(Config.HideSystem.grades) do
                if grade.item == v.name then
                    price = price + (grade.sellPrice * v.count)
                    exports['ox_inventory']:RemoveItem(src, v.name, v.count)
                    soldEntries[#soldEntries + 1] = DERPHuntingBuildItemEntry(v.name, v.count, grade.label)
                end
            end
        end
    end

    if price == 0 then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Không có đồ bán được!' })
    else
        local beforeMoney = DERPHuntingGetMoneySnapshot(src)
        exports['qbx_core']:AddMoney(src, 'cash', price, 'sold-items-hunting')
        local afterMoney = DERPHuntingGetMoneySnapshot(src)

        DERPHuntingActionLog(src,
            ('DERP-hunting | Bán đồ săn | Danh sách: %s | Nhận: $%s cash'):format(
                DERPHuntingFormatItemList(soldEntries),
                price
            ),
            {
                beforeMoney = beforeMoney,
                afterMoney = afterMoney
            }
        )

        TriggerClientEvent('ox_lib:notify', src, { type = 'success', description = 'Đã bán đồ, nhận $' .. price })
    end
end)

-- ============================
--   SELLING (per item)
-- ============================

RegisterServerEvent('DERP-hunting:server:sellItem')
AddEventHandler('DERP-hunting:server:sellItem', function(itemName, pricePerUnit)
    local src    = source
    local Player = exports['qbx_core']:GetPlayer(src)
    if not Player then return end

    local validItem = false
    for _, spot in ipairs(Config.SellSpots) do
        for _, sellItem in ipairs(spot.sellItems) do
            if sellItem.item == itemName and sellItem.price == pricePerUnit then
                validItem = true
                break
            end
        end
        if validItem then break end
    end

    if not validItem then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Item không hợp lệ!' })
        return
    end

    local count = exports['ox_inventory']:GetItemCount(src, itemName)
    if not count or count <= 0 then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Bạn không có ' .. itemName .. '!' })
        return
    end

    local total = pricePerUnit * count
    local soldEntries = {
        DERPHuntingBuildItemEntry(itemName, count)
    }
    local beforeMoney = DERPHuntingGetMoneySnapshot(src)

    exports['ox_inventory']:RemoveItem(src, itemName, count)
    exports['qbx_core']:AddMoney(src, 'cash', total, 'hunting-sell-item')

    local afterMoney = DERPHuntingGetMoneySnapshot(src)

    DERPHuntingActionLog(src,
        ('DERP-hunting | Bán item | Danh sách: %s | Đơn giá: $%s | Nhận: $%s cash'):format(
            DERPHuntingFormatItemList(soldEntries),
            pricePerUnit,
            total
        ),
        {
            beforeMoney = beforeMoney,
            afterMoney = afterMoney
        }
    )

    TriggerClientEvent('ox_lib:notify', src, {
        type        = 'success',
        description = 'Đã bán ' .. count .. 'x ' .. itemName .. ' được $' .. total,
    })
end)

-- ============================
--   BAIT / SPAWN
-- ============================

exports['ox_inventory']:registerHook('usingItem', function(payload)
    if payload.item.name ~= 'huntingbait' then return end
    TriggerClientEvent('DERP-hunting:client:useBait', payload.source)
    return false
end, { itemFilter = { huntingbait = true } })

RegisterServerEvent('DERP-hunting:server:removeBaitFromPlayerInventory')
AddEventHandler('DERP-hunting:server:removeBaitFromPlayerInventory', function()
    local src = source
    local removed = exports['ox_inventory']:RemoveItem(src, 'huntingbait', 1)

    if removed then
        DERPHuntingActionLog(src,
            ('DERP-hunting | Tiêu hao item | Danh sách: %s | Nguồn: đặt mồi săn'):format(
                DERPHuntingFormatItemList({
                    DERPHuntingBuildItemEntry('huntingbait', 1)
                })
            )
        )
    end
end)

RegisterServerEvent('DERP-hunting:server:choiceWhichAnimalToSpawn')
AddEventHandler('DERP-hunting:server:choiceWhichAnimalToSpawn', function(coord, outPosition, was_llegal, missionAnimals)
    local src  = source
    local pool = Animals

    if missionAnimals and #missionAnimals > 0 then
        pool = {}
        for _, v in ipairs(Animals) do
            for _, ma in ipairs(missionAnimals) do
                if v.model == ma then
                    table.insert(pool, v)
                    break
                end
            end
        end
        if #pool == 0 then pool = Animals end
    end

    local C_animal = choiceAnimal(pool, was_llegal)
    if C_animal then
        TriggerClientEvent('DERP-hunting:client:spawnAnimal', src, coord, outPosition, C_animal, was_llegal)
    end
end)

function choiceAnimal(Rarities, was_llegal)
    local temp = {}
    for _, value in pairs(Rarities) do
        table.insert(temp, was_llegal and value.spwanRarity[1] or value.spwanRarity[2])
    end
    if next(temp) then
        return Rarities[Alias_table_wrapper(temp)]
    end
end

-- ============================
--   COMMANDS
-- ============================

lib.addCommand('spawnanimal', {
    help       = 'Spawn Animals (Admin Only)',
    restricted = 'group.admin',
    params = {
        { name = 'model',      help = 'Animal Model' },
        { name = 'was_llegal', help = 'Area of hunt true/false' },
    },
}, function(src, args)
    TriggerClientEvent('DERP-hunting:client:spawnanim', src, args.model, args.was_llegal)
end)

lib.addCommand('clearTask', { help = 'Clear Animations' }, function(src)
    TriggerClientEvent('DERP-hunting:client:clearTask', src)
end)

lib.addCommand('addBait', {
    help       = 'Add bait (Admin Only)',
    restricted = 'group.admin',
}, function(src)
    exports['ox_inventory']:AddItem(src, 'huntingbait', 10)

    DERPHuntingActionLog(src,
        ('DERP-hunting | Nhận item | Danh sách: %s | Nguồn: lệnh admin addBait'):format(
            DERPHuntingFormatItemList({
                DERPHuntingBuildItemEntry('huntingbait', 10)
            })
        )
    )

    TriggerClientEvent('ox_lib:notify', src, { type = 'success', description = 'Added 10x Hunting Bait' })
end)

-- ============================
--   GARBAGE COLLECTION
-- ============================

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(garbageCollection_tm)
        garbageCollection()
    end
end)