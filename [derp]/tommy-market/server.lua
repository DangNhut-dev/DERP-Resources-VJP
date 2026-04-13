local prices = {}
local previousPrices = {}
local buyCooldowns = {}
local sellCooldowns = {}
local COOLDOWN_MS = 500

local allEvents = {
    ["qb-npc-market:sellItem"] = false,
    ["qb-npc-market:checkout"] = false,
    ["qb-npc-market:buyItem"] = false
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

local function IsJsRankingStarted()
    return GetResourceState('js_ranking') == 'started'
end

local function CopyMoneyTable(money)
    local copy = {}

    if type(money) ~= 'table' then
        return copy
    end

    for key, value in pairs(money) do
        local amount = tonumber(value)

        if amount ~= nil then
            copy[key] = amount
        end
    end

    return copy
end

local function GetOxItemLabel(itemName, fallbackLabel)
    if fallbackLabel and fallbackLabel ~= '' then
        return tostring(fallbackLabel)
    end

    if not itemName or itemName == '' then
        return 'unknown'
    end

    local itemData
    local ok = pcall(function()
        itemData = exports.ox_inventory:Items(itemName)
    end)

    if ok and type(itemData) == 'table' and itemData.label and itemData.label ~= '' then
        return tostring(itemData.label)
    end

    ok = pcall(function()
        local items = exports.ox_inventory:Items()
        itemData = items and items[itemName] or nil
    end)

    if ok and type(itemData) == 'table' and itemData.label and itemData.label ~= '' then
        return tostring(itemData.label)
    end

    return tostring(itemName)
end

local function FormatMarketItem(itemName, count, fallbackLabel, mode)
    local amount = math.floor(tonumber(count) or 0)
    local label = GetOxItemLabel(itemName, fallbackLabel)
    local display = tostring(itemName or '')

    if label ~= '' and label ~= display then
        display = ('%s(%s)'):format(display, label)
    end

    local prefix = ''

    if mode == 'add' then
        prefix = '+'
    elseif mode == 'remove' then
        prefix = '-'
    end

    if amount > 0 then
        return ('%s%s x%s'):format(prefix, display, amount)
    end

    return prefix .. display
end

local function FormatMoneyAction(moneyType, amount, mode)
    local value = math.floor(tonumber(amount) or 0)
    local prefix = mode == 'remove' and '-' or '+'
    local moneyKey = tostring(moneyType or 'cash')

    if moneyKey == 'cash' or moneyKey == 'bank' or moneyKey == 'crypto' or moneyKey == 'coins' or moneyKey == 'coins_lock' or moneyKey == 'point' then
        return ('%s%s $%s'):format(prefix, moneyKey, value)
    end

    if moneyKey == 'dirty' then
        moneyKey = 'black_money'
    end

    return FormatMarketItem(moneyKey, value, nil, mode)
end

local function BuildItemList(items)
    if type(items) ~= 'table' or #items == 0 then
        return nil
    end

    return table.concat(items, ', ')
end

local function BuildMarketActionText(title, details)
    local message = ('[tommy-market] | %s'):format(tostring(title or ''))

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

local function AddActionLog(anyPlayer, actionText, opts)
    if not IsJsRankingStarted() then
        return false
    end

    if not actionText or actionText == '' then
        return false
    end

    local ok = pcall(function()
        exports['js_ranking']:AddActionLog(anyPlayer, actionText, opts)
    end)

    return ok
end

local function LogMarketAction(anyPlayer, title, details, opts)
    return AddActionLog(anyPlayer, BuildMarketActionText(title, details), opts)
end

local function checkCooldown(cooldownTable, src)
    local now = GetGameTimer()
    if cooldownTable[src] and (now - cooldownTable[src]) < COOLDOWN_MS then
        return false
    end
    cooldownTable[src] = now
    return true
end

local function GetCurrentHourVN()
    local utcHour = tonumber(os.date('!%H', os.time()))
    return (utcHour + Config.Timezone) % 24
end

local function ShouldSpawnNPC(npc)
    if not npc.time then return true end
    local currentHour = GetCurrentHourVN()
    local startHour = npc.time.starttime
    local endHour = npc.time.endtime
    if startHour > endHour then
        return currentHour >= startHour or currentHour < endHour
    else
        return currentHour >= startHour and currentHour < endHour
    end
end

local function notify(src, msg, ntype)
    TriggerClientEvent('ox_lib:notify', src, { title = 'Cửa Hàng', description = msg, type = ntype })
end

local function initPrices()
    for _, npc in ipairs(Config.MarketNPCs) do
        prices[npc.id] = {}
        previousPrices[npc.id] = {}
        for _, it in ipairs(npc.items) do
            if it.sellMin ~= nil and it.sellMax ~= nil then
                local p = math.random(it.sellMin, it.sellMax)
                prices[npc.id][it.name] = p
                previousPrices[npc.id][it.name] = p
            end
        end
    end
end

local function randomizePricesFor(npc)
    if not npc then return end
    for _, it in ipairs(npc.items) do
        if it.sellMin ~= nil and it.sellMax ~= nil then
            local old = prices[npc.id][it.name] or it.sellMin
            prices[npc.id][it.name] = math.random(it.sellMin, it.sellMax)
            previousPrices[npc.id][it.name] = old
        end
    end
end

CreateThread(function()
    initPrices()
    while true do
        Wait(Config.TimerResetHours * 60 * 60 * 1000)
        for _, npc in ipairs(Config.MarketNPCs) do
            if npc.enabled then
                randomizePricesFor(npc)
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(60000)
        TriggerClientEvent('qb-npc-market:updateCurrentHour', -1, GetCurrentHourVN())
    end
end)

lib.callback.register('qb-npc-market:getCurrentHour', function(source)
    return GetCurrentHourVN()
end)

lib.callback.register('qb-npc-market:getMarketData', function(source, npcId)
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return nil end

    local npcData = nil
    for _, npc in ipairs(Config.MarketNPCs) do
        if npc.id == npcId then
            npcData = npc
            break
        end
    end
    if not npcData then return nil end

    local playerInventory = {}
    for _, it in ipairs(npcData.items) do
        playerInventory[it.name] = exports.ox_inventory:Search(source, 'count', it.name) or 0
    end

    local oxItems = exports.ox_inventory:Items()
    local playerCash = Player.PlayerData.money['cash'] or 0
    local playerBank = Player.PlayerData.money['bank'] or 0
    local playerDirty = exports.ox_inventory:Search(source, 'count', 'black_money') or 0
    local playerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname

    local data = {
        id = npcData.id,
        label = npcData.label,
        type = npcData.type,
        blackmarket = npcData.blackmarket or false,
        items = {},
        playerJob = Player.PlayerData.job.name,
        playerGrade = Player.PlayerData.job.grade.level,
        playerInventory = playerInventory,
        playerName = playerName,
        playerCash = playerCash,
        playerBank = playerBank,
        playerDirty = playerDirty
    }

    for _, it in ipairs(npcData.items) do
        local cur, avg, prev = nil, nil, nil
        if it.sellMin ~= nil and it.sellMax ~= nil then
            cur = prices[npcData.id][it.name] or math.random(it.sellMin, it.sellMax)
            prev = previousPrices[npcData.id][it.name] or cur
            avg = math.floor((it.sellMin + it.sellMax) / 2)
        end
        local itemData = oxItems[it.name]
        local isUnique = itemData and itemData.stack == false or false
        table.insert(data.items, {
            name = it.name,
            label = it.label,
            buyPrice = it.buyPrice,
            sellPrice = cur,
            avgPrice = avg,
            prevPrice = prev,
            grade = it.grade,
            unique = isUnique
        })
    end

    return data
end)

local function getNpcAndItem(npcId, itemName)
    for _, npc in ipairs(Config.MarketNPCs) do
        if npc.id == npcId then
            for _, it in ipairs(npc.items) do
                if it.name == itemName then
                    return npc, it
                end
            end
            return npc, nil
        end
    end
    return nil, nil
end

local function validateDistance(src, npcCfg)
    local coords = GetEntityCoords(GetPlayerPed(src))
    local npcCoords = vector3(npcCfg.coords.x, npcCfg.coords.y, npcCfg.coords.z)
    return #(coords - npcCoords) <= 5.0
end

local function validateJob(Player, npcCfg)
    if not npcCfg.requiredJob then return true end
    local playerJob = Player.PlayerData.job.name
    local playerGrade = Player.PlayerData.job.grade.level
    for job, reqGrade in pairs(npcCfg.requiredJob) do
        if playerJob == job and playerGrade >= reqGrade then
            return true
        end
    end
    return false
end

RegisterNetEvent('qb-npc-market:buyItem', function(npcId, itemName, amount)
    local src = source
    if not checkCooldown(buyCooldowns, src) then return end
    if fiveguard_resource ~= "" and GetResourceState(fiveguard_resource) == 'started' then
        if not exports[fiveguard_resource]:VerifyToken(src) then return end
    end
    if type(npcId) ~= 'string' and type(npcId) ~= 'number' then return end
    if type(itemName) ~= 'string' then return end

    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end

    local beforeMoney = CopyMoneyTable(Player.PlayerData.money)

    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 or amount > 999 then
        notify(src, 'Số lượng không hợp lệ', 'error')
        return
    end

    local npcCfg, itemConf = getNpcAndItem(npcId, itemName)
    if not npcCfg then notify(src, 'Không tìm thấy cửa hàng', 'error') return end
    if not npcCfg.enabled then return end
    if not ShouldSpawnNPC(npcCfg) then return end
    if not itemConf then notify(src, 'Item không tồn tại', 'error') return end
    if not itemConf.buyPrice or itemConf.buyPrice <= 0 then
        notify(src, 'Item không thể mua ở đây', 'error')
        return
    end

    if not validateDistance(src, npcCfg) then
        notify(src, 'Bạn quá xa cửa hàng!', 'error')
        return
    end

    if not validateJob(Player, npcCfg) then
        notify(src, 'Bạn không có quyền mua ở đây', 'error')
        return
    end

    if itemConf.grade and Player.PlayerData.job.grade.level < itemConf.grade then
        notify(src, 'Cấp bậc của bạn chưa đủ', 'error')
        return
    end

    local oxItems = exports.ox_inventory:Items()
    local itemData = oxItems[itemConf.name]
    if itemData and itemData.stack == false and amount > 1 then
        notify(src, 'Item này chỉ có thể mua từng cái một', 'error')
        return
    end

    if not exports.ox_inventory:CanCarryItem(src, itemConf.name, amount) then
        notify(src, 'Túi đã đầy, không thể mua', 'error')
        return
    end

    local total = itemConf.buyPrice * amount

    if npcCfg.blackmarket then
        local dirtyCount = exports.ox_inventory:Search(src, 'count', 'black_money') or 0
        if dirtyCount < total then
            notify(src, 'Không đủ tiền bẩn', 'error')
            return
        end
        if not exports.ox_inventory:RemoveItem(src, 'black_money', total) then
            notify(src, 'Không đủ tiền bẩn', 'error')
            return
        end
    else
        if not Player.Functions.RemoveMoney('cash', total, 'Chợ') then
            notify(src, 'Không đủ tiền mặt', 'error')
            return
        end
    end

    local currentAmount = exports.ox_inventory:Search(src, 'count', itemConf.name) or 0

    if exports.ox_inventory:AddItem(src, itemConf.name, amount) then
        local currency = npcCfg.blackmarket and 'tiền bẩn' or '$'
        notify(src, ('Bạn đã mua %sx %s với giá %d %s'):format(amount, itemConf.label, total, currency), 'success')
        TriggerClientEvent('qb-npc-market:updateItemAmount', src, itemConf.name, currentAmount + amount)
        local updatedPlayer = exports.qbx_core:GetPlayer(src)
        local dirty = exports.ox_inventory:Search(src, 'count', 'black_money') or 0
        TriggerClientEvent('qb-npc-market:updateMoney', src, updatedPlayer.PlayerData.money['cash'], updatedPlayer.PlayerData.money['bank'], dirty)

        local paymentText = npcCfg.blackmarket and FormatMoneyAction('black_money', total, 'remove') or FormatMoneyAction('cash', total, 'remove')
        local itemText = FormatMarketItem(itemConf.name, amount, itemConf.label, 'add')
        local logOpts = not npcCfg.blackmarket and { beforeMoney = beforeMoney } or nil

        LogMarketAction(src, 'mua vật phẩm', {
            { 'cửa hàng', npcCfg.label or npcCfg.id },
            { 'thanh toán', paymentText },
            { 'item', itemText }
        }, logOpts)
    else
        if npcCfg.blackmarket then
            exports.ox_inventory:AddItem(src, 'black_money', total)
        else
            Player.Functions.AddMoney('cash', total, 'Chợ')
        end
        notify(src, 'Túi đã đầy, không thể mua', 'error')
    end
end)

RegisterNetEvent('qb-npc-market:checkout', function(npcId, items, paymentType)
    local src = source
    if not checkCooldown(buyCooldowns, src) then return end
    if fiveguard_resource ~= "" and GetResourceState(fiveguard_resource) == 'started' then
        if not exports[fiveguard_resource]:VerifyToken(src) then return end
    end
    if type(npcId) ~= 'string' and type(npcId) ~= 'number' then return end
    if type(items) ~= 'table' or #items == 0 or #items > 20 then return end
    if paymentType ~= 'cash' and paymentType ~= 'bank' and paymentType ~= 'dirty' then
        paymentType = 'cash'
    end

    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end

    local beforeMoney = CopyMoneyTable(Player.PlayerData.money)

    local npcCfg = nil
    for _, npc in ipairs(Config.MarketNPCs) do
        if npc.id == npcId then npcCfg = npc break end
    end
    if not npcCfg or not npcCfg.enabled then return end
    if not ShouldSpawnNPC(npcCfg) then return end

    if not validateDistance(src, npcCfg) then
        notify(src, 'Bạn quá xa cửa hàng!', 'error')
        return
    end

    if not validateJob(Player, npcCfg) then
        notify(src, 'Bạn không có quyền mua ở đây', 'error')
        return
    end

    local oxItems = exports.ox_inventory:Items()
    local validatedItems = {}
    local total = 0

    for _, entry in ipairs(items) do
        if type(entry.name) ~= 'string' then return end

        local amount = math.floor(tonumber(entry.amount) or 0)
        if amount <= 0 or amount > 999 then
            notify(src, 'Số lượng không hợp lệ', 'error')
            return
        end

        local itemConf = nil
        for _, it in ipairs(npcCfg.items) do
            if it.name == entry.name then itemConf = it break end
        end

        if not itemConf then notify(src, 'Item không tồn tại', 'error') return end
        if not itemConf.buyPrice or itemConf.buyPrice <= 0 then
            notify(src, 'Item không thể mua: ' .. itemConf.label, 'error')
            return
        end
        if itemConf.grade and Player.PlayerData.job.grade.level < itemConf.grade then
            notify(src, 'Cấp bậc chưa đủ: ' .. itemConf.label, 'error')
            return
        end

        local itemData = oxItems[itemConf.name]
        if itemData and itemData.stack == false and amount > 1 then
            notify(src, 'Item ' .. itemConf.label .. ' chỉ mua được từng cái', 'error')
            return
        end

        if not exports.ox_inventory:CanCarryItem(src, itemConf.name, amount) then
            notify(src, 'Túi đã đầy: ' .. itemConf.label, 'error')
            return
        end

        total = total + (itemConf.buyPrice * amount)
        validatedItems[#validatedItems + 1] = { conf = itemConf, amount = amount }
    end

    if npcCfg.blackmarket then
        local dirtyCount = exports.ox_inventory:Search(src, 'count', 'black_money') or 0
        if dirtyCount < total then
            notify(src, 'Không đủ tiền bẩn', 'error')
            return
        end
        if not exports.ox_inventory:RemoveItem(src, 'black_money', total) then
            notify(src, 'Không đủ tiền bẩn', 'error')
            return
        end
    elseif not Player.Functions.RemoveMoney(paymentType, total, 'Chợ') then
        local label = paymentType == 'bank' and 'ngân hàng' or 'tiền mặt'
        notify(src, 'Không đủ ' .. label, 'error')
        return
    end

    local added = {}
    for _, entry in ipairs(validatedItems) do
        if exports.ox_inventory:AddItem(src, entry.conf.name, entry.amount) then
            added[#added + 1] = entry
            local currentAmount = exports.ox_inventory:Search(src, 'count', entry.conf.name) or 0
            TriggerClientEvent('qb-npc-market:updateItemAmount', src, entry.conf.name, currentAmount)
        else
            for _, addedEntry in ipairs(added) do
                exports.ox_inventory:RemoveItem(src, addedEntry.conf.name, addedEntry.amount)
            end
            if paymentType == 'dirty' then
                exports.ox_inventory:AddItem(src, 'black_money', total)
            else
                Player.Functions.AddMoney(paymentType, total, 'Chợ')
            end
            notify(src, 'Lỗi thêm item, đã hoàn tiền', 'error')
            return
        end
    end

    local payLabel = npcCfg.blackmarket and 'tiền bẩn' or (paymentType == 'bank' and 'ngân hàng' or 'tiền mặt')
    notify(src, ('Thanh toán $%d qua %s thành công'):format(total, payLabel), 'success')
    local updatedPlayer = exports.qbx_core:GetPlayer(src)
    local dirty = exports.ox_inventory:Search(src, 'count', 'black_money') or 0
    TriggerClientEvent('qb-npc-market:updateMoney', src, updatedPlayer.PlayerData.money['cash'], updatedPlayer.PlayerData.money['bank'], dirty)

    local itemLogs = {}

    for _, entry in ipairs(validatedItems) do
        itemLogs[#itemLogs + 1] = FormatMarketItem(entry.conf.name, entry.amount, entry.conf.label, 'add')
    end

    local paidBy = npcCfg.blackmarket and 'black_money' or paymentType
    local paymentText = FormatMoneyAction(paidBy, total, 'remove')
    local logOpts = (not npcCfg.blackmarket and paymentType ~= 'dirty') and { beforeMoney = beforeMoney } or nil

    LogMarketAction(src, 'mua nhiều vật phẩm', {
        { 'cửa hàng', npcCfg.label or npcCfg.id },
        { 'thanh toán', paymentText },
        { 'items', BuildItemList(itemLogs) }
    }, logOpts)
end)

RegisterNetEvent('qb-npc-market:sellItem', function(npcId, itemName, amount)
    local src = source
    if not checkCooldown(sellCooldowns, src) then return end
    if fiveguard_resource ~= "" and GetResourceState(fiveguard_resource) == 'started' then
        if not exports[fiveguard_resource]:VerifyToken(src) then return end
    end
    if type(npcId) ~= 'string' and type(npcId) ~= 'number' then return end
    if type(itemName) ~= 'string' then return end

    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end

    local beforeMoney = CopyMoneyTable(Player.PlayerData.money)

    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 or amount > 999999 then
        notify(src, 'Số lượng không hợp lệ', 'error')
        return
    end

    local npcCfg, itemConf = getNpcAndItem(npcId, itemName)
    if not npcCfg then notify(src, 'Không tìm thấy cửa hàng', 'error') return end
    if not npcCfg.enabled then return end
    if not ShouldSpawnNPC(npcCfg) then return end
    if not itemConf then notify(src, 'Item không tồn tại', 'error') return end

    if not itemConf.sellMin or not itemConf.sellMax then
        notify(src, 'Item này không thể bán ở đây', 'error')
        return
    end

    if not validateDistance(src, npcCfg) then
        notify(src, 'Bạn quá xa cửa hàng!', 'error')
        return
    end

    if not validateJob(Player, npcCfg) then
        notify(src, 'Bạn không có quyền bán ở đây', 'error')
        return
    end

    local have = exports.ox_inventory:Search(src, 'count', itemConf.name) or 0
    if have <= 0 then
        notify(src, 'Bạn không có ' .. itemConf.label, 'error')
        return
    end

    if amount > have then amount = have end

    local curPrice = prices[npcCfg.id] and prices[npcCfg.id][itemConf.name]
    if not curPrice then
        notify(src, 'Lỗi giá, vui lòng thử lại', 'error')
        return
    end

    if exports.ox_inventory:RemoveItem(src, itemConf.name, amount) then
        local total = math.floor(curPrice * amount)
        if npcCfg.blackmarket then
            exports.ox_inventory:AddItem(src, 'black_money', total)
            notify(src, ('Bạn đã bán %sx %s nhận %d tiền bẩn'):format(amount, itemConf.label, total), 'success')
        else
            Player.Functions.AddMoney('cash', total, 'Chợ')
            notify(src, ('Bạn đã bán %sx %s nhận $%d'):format(amount, itemConf.label, total), 'success')
        end
        TriggerClientEvent('qb-npc-market:updateItemAmount', src, itemConf.name, have - amount)
        local updatedPlayer = exports.qbx_core:GetPlayer(src)
        local dirty = exports.ox_inventory:Search(src, 'count', 'black_money') or 0
        TriggerClientEvent('qb-npc-market:updateMoney', src, updatedPlayer.PlayerData.money['cash'], updatedPlayer.PlayerData.money['bank'], dirty)

        local receiveType = npcCfg.blackmarket and 'black_money' or 'cash'
        local receiveText = FormatMoneyAction(receiveType, total, 'add')
        local itemText = FormatMarketItem(itemConf.name, amount, itemConf.label, 'remove')
        local logOpts = not npcCfg.blackmarket and { beforeMoney = beforeMoney } or nil

        LogMarketAction(src, 'bán vật phẩm', {
            { 'cửa hàng', npcCfg.label or npcCfg.id },
            { 'nhận', receiveText },
            { 'item', itemText }
        }, logOpts)
    else
        notify(src, 'Lỗi khi bán', 'error')
    end
end)

exports('AddActionLog', function(anyPlayer, actionText, opts)
    return AddActionLog(anyPlayer, actionText, opts)
end)

exports('OpenMarketUI', function(npcId)
end)