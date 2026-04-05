-- ============================
--   MAIN SERVER - HUNTING
-- ============================

local TableSize            = Config.sv_maxTableSize
local garbageCollection_tm = Config.sv_dataClearnigTimer
local Animals              = Config.Animals

local animalsEnity = {}

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
    local lootText = {}

    if animalCfg.meatItem and animalCfg.meatAmount then
        local amount = math.random(animalCfg.meatAmount.min, animalCfg.meatAmount.max)
        exports['ox_inventory']:AddItem(src, animalCfg.meatItem, amount)
        table.insert(lootText, '+' .. amount .. 'x ' .. animalCfg.meatItem)
    end

    if Config.HideSystem.enabled then
        local grade  = rollHideGrade()
        local amount = math.random(Config.HideSystem.amountMin, Config.HideSystem.amountMax)
        exports['ox_inventory']:AddItem(src, grade.item, amount)
        table.insert(lootText, '+' .. amount .. 'x ' .. grade.label)
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
                end
            end
        end
    end

    if price == 0 then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Không có đồ bán được!' })
    else
        exports['qbx_core']:AddMoney(src, 'cash', price, 'sold-items-hunting')
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
    exports['ox_inventory']:RemoveItem(src, itemName, count)
    exports['qbx_core']:AddMoney(src, 'cash', total, 'hunting-sell-item')
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
    exports['ox_inventory']:RemoveItem(source, 'huntingbait', 1)
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