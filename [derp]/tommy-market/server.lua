local prices = {}
local previousPrices = {}
local buyCooldowns = {}
local sellCooldowns = {}
local COOLDOWN_MS = 500

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

    if type(npcId) ~= 'string' and type(npcId) ~= 'number' then return end
    if type(itemName) ~= 'string' then return end

    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end

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
        if not Player.Functions.RemoveMoney('cash', total) then
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
    else
        if npcCfg.blackmarket then
            exports.ox_inventory:AddItem(src, 'black_money', total)
        else
            Player.Functions.AddMoney('cash', total)
        end
        notify(src, 'Túi đã đầy, không thể mua', 'error')
    end
end)

RegisterNetEvent('qb-npc-market:checkout', function(npcId, items, paymentType)
    local src = source
    if not checkCooldown(buyCooldowns, src) then return end

    if type(npcId) ~= 'string' and type(npcId) ~= 'number' then return end
    if type(items) ~= 'table' or #items == 0 or #items > 20 then return end
    if paymentType ~= 'cash' and paymentType ~= 'bank' and paymentType ~= 'dirty' then
        paymentType = 'cash'
    end

    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end

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
    elseif not Player.Functions.RemoveMoney(paymentType, total) then
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
                Player.Functions.AddMoney(paymentType, total)
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
end)

RegisterNetEvent('qb-npc-market:sellItem', function(npcId, itemName, amount)
    local src = source
    if not checkCooldown(sellCooldowns, src) then return end

    if type(npcId) ~= 'string' and type(npcId) ~= 'number' then return end
    if type(itemName) ~= 'string' then return end

    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end

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
            Player.Functions.AddMoney('cash', total)
            notify(src, ('Bạn đã bán %sx %s nhận $%d'):format(amount, itemConf.label, total), 'success')
        end
        TriggerClientEvent('qb-npc-market:updateItemAmount', src, itemConf.name, have - amount)
        local updatedPlayer = exports.qbx_core:GetPlayer(src)
        local dirty = exports.ox_inventory:Search(src, 'count', 'black_money') or 0
        TriggerClientEvent('qb-npc-market:updateMoney', src, updatedPlayer.PlayerData.money['cash'], updatedPlayer.PlayerData.money['bank'], dirty)
    else
        notify(src, 'Lỗi khi bán', 'error')
    end
end)

exports('OpenMarketUI', function(npcId)
end)