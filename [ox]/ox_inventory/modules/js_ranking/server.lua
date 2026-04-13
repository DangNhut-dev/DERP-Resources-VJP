if rawget(_G, '__OX_JS_RANKING_LOGGER') then
    return rawget(_G, '__OX_JS_RANKING_LOGGER')
end

local Items = require 'modules.items.server'
local Inventory = require 'modules.inventory.server'

local Logger = {}
local idCustomCache = {}
local hooksRegistered = false
local qbCore = nil

local function getQBCore()
    if qbCore ~= nil then
        return qbCore or nil
    end

    local ok, obj = pcall(function()
        return exports['qb-core']:GetCoreObject()
    end)

    qbCore = ok and obj or false
    return qbCore or nil
end

function Logger.IsJsRankingStarted()
    return GetResourceState('js_ranking') == 'started'
end

function Logger.TryAddActionLog(anyPlayer, actionText, opts)
    if not Logger.IsJsRankingStarted() then return false end
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

function Logger.GetCitizenId(src)
    if type(src) ~= 'number' or src <= 0 then return nil end

    local ok, player = pcall(function()
        return exports.qbx_core and exports.qbx_core:GetPlayer(src)
    end)

    if ok and player and player.PlayerData and player.PlayerData.citizenid then
        return player.PlayerData.citizenid
    end

    local core = getQBCore()

    if core and core.Functions then
        local qbPlayer = core.Functions.GetPlayer(src)

        if qbPlayer and qbPlayer.PlayerData and qbPlayer.PlayerData.citizenid then
            return qbPlayer.PlayerData.citizenid
        end
    end

    return nil
end

function Logger.GetIdCustomFromCitizenId(citizenid)
    if not citizenid or citizenid == '' then return nil end

    if idCustomCache[citizenid] ~= nil then
        return idCustomCache[citizenid]
    end

    local idCustom

    pcall(function()
        idCustom = MySQL.scalar.await('SELECT id_custom FROM players WHERE citizenid = ? LIMIT 1', { citizenid })
    end)

    if idCustom ~= nil then
        idCustom = tostring(idCustom)
        if idCustom == '' then
            idCustom = nil
        end
    end

    idCustomCache[citizenid] = idCustom
    return idCustom
end

function Logger.FormatPlayer(anyPlayer)
    if type(anyPlayer) == 'number' then
        if anyPlayer <= 0 then
            return 'console'
        end

        local citizenid = Logger.GetCitizenId(anyPlayer)
        local idCustom = Logger.GetIdCustomFromCitizenId(citizenid)

        return idCustom or citizenid or tostring(anyPlayer)
    end

    if type(anyPlayer) == 'string' then
        local idCustom = Logger.GetIdCustomFromCitizenId(anyPlayer)
        return idCustom or anyPlayer
    end

    return 'unknown'
end

function Logger.GetPlayerCoords(src)
    if type(src) ~= 'number' or src <= 0 then return nil end

    local ped = GetPlayerPed(src)

    if not ped or ped <= 0 then return nil end

    local ok, coords = pcall(GetEntityCoords, ped)
    if ok then
        return coords
    end

    return nil
end

local function unpackCoords(coords)
    if not coords then return nil end

    local x = coords.x or coords[1]
    local y = coords.y or coords[2]
    local z = coords.z or coords[3]

    if x == nil or y == nil or z == nil then
        return nil
    end

    return tonumber(x), tonumber(y), tonumber(z)
end

function Logger.FormatCoords(coords)
    local x, y, z = unpackCoords(coords)
    if not x then return nil end

    return ('(%.2f, %.2f, %.2f)'):format(x, y, z)
end

function Logger.SafeDist(a, b)
    local ax, ay, az = unpackCoords(a)
    local bx, by, bz = unpackCoords(b)

    if not ax or not bx then return nil end

    local dx = ax - bx
    local dy = ay - by
    local dz = az - bz

    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function Logger.FormatMeters(distance)
    distance = tonumber(distance)

    if not distance then return nil end

    if distance >= 1000 then
        return ('%.2fkm'):format(distance / 1000)
    end

    return ('%.2fm'):format(distance)
end

function Logger.GetItemLabel(name, metadata)
    if type(metadata) == 'table' and metadata.label and metadata.label ~= '' then
        return tostring(metadata.label)
    end

    local item = Items(name)
    local label = item and item.label or tostring(name or '')
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

        if metadata.type ~= nil then
            extras[#extras + 1] = ('type:%s'):format(tostring(metadata.type))
        end
    end

    if #extras > 0 then
        label = ('%s [%s]'):format(label, table.concat(extras, ' '))
    end

    return label
end

function Logger.FormatItem(name, count, metadata, mode)
    name = tostring(name or '')
    count = tonumber(count) or 0

    local label = Logger.GetItemLabel(name, metadata)
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

function Logger.BuildActionText(title, details)
    local message = ('[inventory] | %s'):format(tostring(title or ''))

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

function Logger.Log(anyPlayer, title, details, opts)
    return Logger.TryAddActionLog(anyPlayer, Logger.BuildActionText(title, details), opts)
end

function Logger.GetDropCoords(dropId)
    if dropId == nil then return nil end

    local drops = Inventory.Drops or {}
    local key = tostring(dropId)
    local drop = drops[key] or drops[dropId]

    return drop and drop.coords or nil
end

function Logger.GetInventoryInfo(invId)
    if invId == nil then return nil end

    local inv = Inventory(invId)

    if not inv then
        return {
            id = tostring(invId),
            label = tostring(invId),
            type = nil,
            coords = nil,
        }
    end

    return {
        id = tostring(inv.id or invId),
        label = inv.label or tostring(inv.id or invId),
        type = inv.type,
        coords = inv.coords,
    }
end

function Logger.GetVehiclePlate(invId, invType)
    local id = tostring(invId or '')

    if invType == 'trunk' then
        local plate = id:match('^trunk(.+)$')
        return plate or id
    end

    if invType == 'glovebox' then
        local plate = id:match('^glove(.+)$')
        return plate or id
    end

    return id ~= '' and id or nil
end

local function registerSwapHook()
    exports.ox_inventory:registerHook('swapItems', function(payload)
        if not payload or not payload.source then return end

        local src = tonumber(payload.source)
        if not src or src <= 0 then return end

        local fromType = tostring(payload.fromType or '')
        local toType = tostring(payload.toType or '')
        local fromInv = payload.fromInventory
        local toInv = payload.toInventory
        local fromSlot = payload.fromSlot
        local count = tonumber(payload.count) or (type(fromSlot) == 'table' and tonumber(fromSlot.count)) or 0

        if type(fromSlot) ~= 'table' or not fromSlot.name then
            return
        end

        local itemName = fromSlot.name
        local metadata = fromSlot.metadata

        if fromType == 'player' and toType == 'drop' then
            local pcoords = Logger.GetPlayerCoords(src)
            local dcoords = payload.coords or payload.dropCoords or payload.dropPos or Logger.GetDropCoords(payload.dropId or toInv)
            local dist = Logger.SafeDist(pcoords, dcoords)

            Logger.Log(src, 'Vứt đồ', {
                { 'item', Logger.FormatItem(itemName, count, metadata, 'remove') },
                { 'drop', tostring(payload.dropId or toInv or '') },
                { 'p', Logger.FormatCoords(pcoords) },
                { 'drop_pos', Logger.FormatCoords(dcoords) },
                { 'p→drop', Logger.FormatMeters(dist) },
            })

            return
        end

        if fromType == 'drop' and toType == 'player' then
            local pcoords = Logger.GetPlayerCoords(src)
            local dcoords = Logger.GetDropCoords(fromInv)
            local dist = Logger.SafeDist(pcoords, dcoords)

            Logger.Log(src, 'Nhặt đồ', {
                { 'item', Logger.FormatItem(itemName, count, metadata, 'add') },
                { 'drop', tostring(fromInv or '') },
                { 'p', Logger.FormatCoords(pcoords) },
                { 'drop_pos', Logger.FormatCoords(dcoords) },
                { 'p→drop', Logger.FormatMeters(dist) },
            })

            return
        end

        if fromType == 'player' and toType == 'player' and fromInv ~= toInv then
            local toSrc = tonumber(toInv)
            local fromLabel = Logger.FormatPlayer(src)
            local toLabel = Logger.FormatPlayer(toSrc or tostring(toInv or 'unknown'))
            local pcoords = Logger.GetPlayerCoords(src)
            local tcoords = toSrc and Logger.GetPlayerCoords(toSrc) or nil
            local dist = Logger.SafeDist(pcoords, tcoords)

            Logger.Log(src, 'Đưa đồ', {
                { 'item', Logger.FormatItem(itemName, count, metadata, 'remove') },
                { 'đến', toLabel },
                { 'p', Logger.FormatCoords(pcoords) },
                { 't', Logger.FormatCoords(tcoords) },
                { 'p→t', Logger.FormatMeters(dist) },
            })

            if toSrc and toSrc > 0 then
                Logger.Log(toSrc, 'Nhận đồ', {
                    { 'item', Logger.FormatItem(itemName, count, metadata, 'add') },
                    { 'từ', fromLabel },
                    { 'p', Logger.FormatCoords(tcoords) },
                    { 'from', Logger.FormatCoords(pcoords) },
                    { 'p→from', Logger.FormatMeters(dist) },
                })
            end

            return
        end

        if fromType == 'player' and (toType == 'trunk' or toType == 'glovebox') then
            local pcoords = Logger.GetPlayerCoords(src)
            local plate = Logger.GetVehiclePlate(toInv, toType)

            Logger.Log(src, 'Bỏ vào cốp xe', {
                { 'item', Logger.FormatItem(itemName, count, metadata, 'remove') },
                { 'kho', toType },
                { 'xe', plate or tostring(toInv or '') },
                { 'p', Logger.FormatCoords(pcoords) },
            })

            return
        end

        if (fromType == 'trunk' or fromType == 'glovebox') and toType == 'player' then
            local pcoords = Logger.GetPlayerCoords(src)
            local plate = Logger.GetVehiclePlate(fromInv, fromType)

            Logger.Log(src, 'Lấy từ cốp xe', {
                { 'item', Logger.FormatItem(itemName, count, metadata, 'add') },
                { 'kho', fromType },
                { 'xe', plate or tostring(fromInv or '') },
                { 'p', Logger.FormatCoords(pcoords) },
            })

            return
        end

        if fromType == 'player' and (toType == 'stash' or toType == 'container' or toType == 'dumpster' or toType == 'temp' or toType == 'policeevidence') then
            local pcoords = Logger.GetPlayerCoords(src)
            local invInfo = Logger.GetInventoryInfo(toInv)
            local dist = Logger.SafeDist(pcoords, invInfo and invInfo.coords or nil)
            local title = 'Bỏ vào kho đồ'

            if toType == 'container' then
                title = 'Cất vào túi đồ'
            elseif toType == 'dumpster' then
                title = 'Bỏ vào thùng rác'
            elseif toType == 'temp' then
                title = 'Bỏ vào kho tạm'
            elseif toType == 'policeevidence' then
                title = 'Bỏ vào kho tang vật'
            end

            Logger.Log(src, title, {
                { 'item', Logger.FormatItem(itemName, count, metadata, 'remove') },
                { 'kho', invInfo and (invInfo.label or invInfo.id) or tostring(toInv or '') },
                { 'type', toType },
                { 'p', Logger.FormatCoords(pcoords) },
                { 'kho_pos', Logger.FormatCoords(invInfo and invInfo.coords or nil) },
                { 'p→kho', Logger.FormatMeters(dist) },
            })

            return
        end

        if (fromType == 'stash' or fromType == 'container' or fromType == 'dumpster' or fromType == 'temp' or fromType == 'policeevidence') and toType == 'player' then
            local pcoords = Logger.GetPlayerCoords(src)
            local invInfo = Logger.GetInventoryInfo(fromInv)
            local dist = Logger.SafeDist(pcoords, invInfo and invInfo.coords or nil)
            local title = 'Lấy ra khỏi kho đồ'

            if fromType == 'container' then
                title = 'Lấy ra khỏi túi đồ'
            elseif fromType == 'dumpster' then
                title = 'Lấy từ thùng rác'
            elseif fromType == 'temp' then
                title = 'Lấy từ kho tạm'
            elseif fromType == 'policeevidence' then
                title = 'Lấy từ kho tang vật'
            end

            Logger.Log(src, title, {
                { 'item', Logger.FormatItem(itemName, count, metadata, 'add') },
                { 'kho', invInfo and (invInfo.label or invInfo.id) or tostring(fromInv or '') },
                { 'type', fromType },
                { 'p', Logger.FormatCoords(pcoords) },
                { 'kho_pos', Logger.FormatCoords(invInfo and invInfo.coords or nil) },
                { 'p→kho', Logger.FormatMeters(dist) },
            })
        end
    end)
end

local function registerBuyHook()
    exports.ox_inventory:registerHook('buyItem', function(payload)
        if not payload or not payload.source then return end

        local src = tonumber(payload.source)
        if not src or src <= 0 then return end

        local price = tonumber(payload.price) or 0
        local total = tonumber(payload.totalPrice) or price * (tonumber(payload.count) or 0)
        local shopCoords = payload.shopCoords or payload.coords
        local pcoords = Logger.GetPlayerCoords(src)
        local dist = Logger.SafeDist(pcoords, shopCoords)

        Logger.Log(src, 'Mua đồ trong shop', {
            { 'shop', tostring(payload.shopLabel or payload.shopType or payload.shopId or 'shop') },
            { 'item', Logger.FormatItem(payload.itemName, payload.count, payload.metadata, 'add') },
            { 'giá', tostring(price) },
            { 'tổng', tostring(total) },
            { 'tiền', tostring(payload.currency or 'money') },
            { 'p', Logger.FormatCoords(pcoords) },
            { 'shop_pos', Logger.FormatCoords(shopCoords) },
            { 'p→shop', Logger.FormatMeters(dist) },
        })
    end)
end

local function registerUsingHook()
    exports.ox_inventory:registerHook('usingItem', function(payload)
        if not payload or not payload.source then return end

        local src = tonumber(payload.source)
        if not src or src <= 0 then return end

        local item = payload.item
        if type(item) ~= 'table' or not item.name then return end

        local consume = payload.consume
        local consumeText = ''

        if consume == nil then
            consumeText = 'không'
        elseif type(consume) == 'number' then
            if consume > 0 and consume < 1 then
                consumeText = string.format('%.2f', consume)
            else
                consumeText = tostring(math.floor(consume + 0.5))
            end
        else
            consumeText = tostring(consume)
        end

        Logger.Log(src, 'Dùng vật phẩm', {
            { 'item', Logger.FormatItem(item.name, 1, item.metadata, 'remove') },
            { 'tiêu hao', consumeText },
            { 'p', Logger.FormatCoords(Logger.GetPlayerCoords(src)) },
        })
    end)
end

local function registerCraftHook()
    exports.ox_inventory:registerHook('craftItem', function(payload)
        if not payload or not payload.source then return end

        local src = tonumber(payload.source)
        if not src or src <= 0 then return end

        local recipe = payload.recipe
        if type(recipe) ~= 'table' or not recipe.name then return end

        local count = recipe.count
        local countText = '1'

        if type(count) == 'number' then
            countText = tostring(math.floor(count))
        elseif type(count) == 'table' then
            local a = tonumber(count[1] or count.min)
            local b = tonumber(count[2] or count.max)

            if a and b then
                countText = ('%d-%d'):format(math.floor(a), math.floor(b))
            end
        end

        local ingredients = {}

        if type(recipe.ingredients) == 'table' then
            for ingredient, needs in pairs(recipe.ingredients) do
                local needed = tonumber(needs) or 0
                if needed > 0 then
                    ingredients[#ingredients + 1] = Logger.FormatItem(ingredient, needed, nil, 'remove')
                end
            end
        end

        table.sort(ingredients)

        Logger.Log(src, 'Chế tạo', {
            { 'bàn', tostring(payload.benchName or payload.benchId or 'craft') },
            { 'kết quả', Logger.FormatItem(recipe.name, 0, recipe.metadata, 'add') .. (' x%s'):format(countText) },
            { 'nguyên liệu', table.concat(ingredients, ', ') },
            { 'p', Logger.FormatCoords(Logger.GetPlayerCoords(src)) },
            { 'bench_pos', Logger.FormatCoords(payload.benchCoords) },
        })
    end)
end

function Logger.RegisterHooks()
    if hooksRegistered then return end
    if GetResourceState(GetCurrentResourceName()) ~= 'started' then return end
    if GetResourceState('ox_inventory') ~= 'started' then return end

    hooksRegistered = true

    pcall(registerSwapHook)
    pcall(registerBuyHook)
    pcall(registerUsingHook)
    pcall(registerCraftHook)
end

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CreateThread(function()
            Wait(0)
            Logger.RegisterHooks()
        end)
    end
end)

CreateThread(function()
    Wait(0)
    Logger.RegisterHooks()
end)

exports('AddActionLog', function(anyPlayer, actionText, opts)
    return Logger.TryAddActionLog(anyPlayer, actionText, opts)
end)

_G.__OX_JS_RANKING_LOGGER = Logger
return Logger
