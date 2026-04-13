local playerCooldowns = {}
local Framework = nil

local function IsAdmin(source)
    if IsPlayerAceAllowed(source, 'command') then return true end
    if IsPlayerAceAllowed(source, 'derp.admin') then return true end

    local ok, result = pcall(function()
        if Config.Framework == 'esx' then
            local ESX = GetESX()
            if not ESX then return false end
            local xPlayer = ESX.GetPlayerFromId(source)
            if not xPlayer then return false end
            local group = xPlayer.getGroup()
            for _, g in ipairs(Config.AdminGroups) do
                if group == g then return true end
            end
            return false
        elseif Config.Framework == 'qbcore' then
            for _, g in ipairs(Config.AdminGroups) do
                if IsPlayerAceAllowed(source, 'group.' .. g) then return true end
            end
            local ok2, perm = pcall(function()
                return exports['qbx_core']:HasPermission(source, 'admin')
            end)
            if ok2 and perm then return true end
            return false
        end
        return false
    end)
    if not ok then return false end
    return result or false
end

local function NotifyAllAdmins(eventName)
    for _, playerId in ipairs(GetPlayers()) do
        local pid = tonumber(playerId)
        if IsAdmin(pid) then
            TriggerClientEvent(eventName, pid)
        end
    end
end

local function BroadcastPendingState()
    local count = MySQL.scalar.await('SELECT COUNT(*) FROM donate_tickets WHERE status = "pending"', {})
    if count and count > 0 then
        NotifyAllAdmins('DERP-donatesystem:showPendingOverlay')
    else
        NotifyAllAdmins('DERP-donatesystem:hidePendingOverlay')
    end
end

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `donate_tickets` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `ticket_id` varchar(20) NOT NULL UNIQUE,
            `identifier` varchar(60) NOT NULL,
            `player_name` varchar(100) DEFAULT NULL,
            `amount` bigint(20) NOT NULL,
            `note` varchar(255) DEFAULT NULL,
            `status` enum('pending','paid','rejected') DEFAULT 'pending',
            `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `donate_logs` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `ticket_id` varchar(20) NOT NULL,
            `identifier` varchar(60) NOT NULL,
            `player_name` varchar(100) DEFAULT NULL,
            `amount` bigint(20) NOT NULL,
            `reward` varchar(255) DEFAULT NULL,
            `confirmed_by` varchar(100) DEFAULT NULL,
            `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    CreateThread(function()
        Wait(1000) 
        BroadcastPendingState()
    end)
end)

local function GetESX()
    if Config.Framework == 'esx' then
        if not Framework then
            Framework = exports['es_extended']:getSharedObject()
        end
        return Framework
    end
    return nil
end

local function GetIdentifier(source)
    local ok, result = pcall(function()
        if Config.Framework == 'esx' then
            local ESX = GetESX()
            if not ESX then return nil end
            local xPlayer = ESX.GetPlayerFromId(source)
            if not xPlayer then return nil end
            return xPlayer.identifier
        elseif Config.Framework == 'qbcore' then
            local player = exports['qbx_core']:GetPlayer(source)
            if not player then return nil end
            return player.PlayerData.citizenid
        end
        return nil
    end)
    if not ok then
        print('[DERP-donate] GetIdentifier error:', result)
        return nil
    end
    return result
end

local function GetPlayerDisplayName(source)
    local ok, result = pcall(function()
        if Config.Framework == 'esx' then
            local ESX = GetESX()
            if not ESX then return GetPlayerName(source) or 'Unknown' end
            local xPlayer = ESX.GetPlayerFromId(source)
            if not xPlayer then return GetPlayerName(source) or 'Unknown' end
            return xPlayer.getName()
        elseif Config.Framework == 'qbcore' then
            local player = exports['qbx_core']:GetPlayer(source)
            if not player then return GetPlayerName(source) or 'Unknown' end
            local charinfo = player.PlayerData.charinfo
            if charinfo and charinfo.firstname then
                return charinfo.firstname .. ' ' .. (charinfo.lastname or '')
            end
            return GetPlayerName(source) or 'Unknown'
        end
        return GetPlayerName(source) or 'Unknown'
    end)
    if not ok then return GetPlayerName(source) or 'Unknown' end
    return result or 'Unknown'
end


local function IsJsRankingStarted()
    return GetResourceState('js_ranking') == 'started'
end

local function TryAddJsRankingLog(anyPlayer, actionText, opts)
    if not IsJsRankingStarted() then return false end
    if not actionText or actionText == '' then return false end

    local ok = pcall(function()
        exports['js_ranking']:AddActionLog(anyPlayer, actionText, opts or {})
    end)

    return ok
end

local function AddActionLog(anyPlayer, actionText, opts)
    return TryAddJsRankingLog(anyPlayer, actionText, opts)
end

local function BuildActionText(title, details)
    local message = ('[donate] | %s'):format(tostring(title or ''))

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

local function CopyMoneyTable(data)
    local snapshot = {}

    if type(data) ~= 'table' then
        return snapshot
    end

    for key, value in pairs(data) do
        local num = tonumber(value)
        if num ~= nil then
            snapshot[key] = num
        end
    end

    return snapshot
end

local function GetCoinBalance(identifier)
    if not identifier or identifier == '' then
        return 0
    end

    local row = MySQL.single.await('SELECT coin FROM derp_coin WHERE citizenid = ?', { identifier })
    return tonumber(row and row.coin) or 0
end

local function AttachCoinSnapshot(snapshot, identifier)
    if not identifier or identifier == '' then
        return snapshot or {}
    end

    snapshot = snapshot or {}

    local balance = GetCoinBalance(identifier)

    if snapshot.coin == nil then
        snapshot.coin = balance
    end

    if snapshot.coins == nil then
        snapshot.coins = balance
    end

    return snapshot
end

local function GetPlayerMoneySnapshot(source, identifier)
    local snapshot = {}

    if Config.Framework == 'qbcore' then
        local ok, player = pcall(function()
            return exports['qbx_core']:GetPlayer(source)
        end)

        if ok and player and player.PlayerData and type(player.PlayerData.money) == 'table' then
            snapshot = CopyMoneyTable(player.PlayerData.money)
        end
    end

    if identifier and identifier ~= '' then
        snapshot = AttachCoinSnapshot(snapshot, identifier)
    end

    return snapshot
end

local function FormatItemLog(name, count, mode)
    local itemName = tostring(name or '')
    local itemCount = tonumber(count) or 0
    local prefix = ''

    if mode == 'add' then
        prefix = '+'
    elseif mode == 'remove' then
        prefix = '-'
    end

    if itemCount > 0 then
        return ('%s%s x%s'):format(prefix, itemName, math.floor(itemCount))
    end

    return prefix .. itemName
end

local function FormatMoneyRewardLog(moneyType, amount)
    return ('+%s'):format(tonumber(amount) or 0), tostring(moneyType or 'money')
end

local function BuildDonateRewardActionText(context, rewardType, rewardValue)
    local details = {
        { 'ticket', context and context.ticketId or nil },
        { 'donate', context and context.amountText or nil },
        { 'duyệt bởi', context and context.adminName or nil },
    }

    if rewardType == 'item' and type(rewardValue) == 'table' then
        details[#details + 1] = { 'item', FormatItemLog(rewardValue.name, rewardValue.count, 'add') }
    elseif rewardType == 'reward' then
        details[#details + 1] = { 'reward', rewardValue }
    else
        local value, key = FormatMoneyRewardLog(rewardType, rewardValue)
        details[#details + 1] = { key, value }
    end

    return BuildActionText('Nhận donate', details)
end

local function BuildDonatePendingActionText(context, rewardType, rewardValue)
    local details = {
        { 'ticket', context and context.ticketId or nil },
        { 'donate', context and context.amountText or nil },
        { 'duyệt bởi', context and context.adminName or nil },
        { 'trạng thái', 'pending_offline' },
    }

    if rewardType == 'item' and type(rewardValue) == 'table' then
        details[#details + 1] = { 'item', FormatItemLog(rewardValue.name, rewardValue.count, 'add') }
    else
        local value, key = FormatMoneyRewardLog(rewardType, rewardValue)
        details[#details + 1] = { key, value }
    end

    return BuildActionText('Donate chờ xử lý offline', details)
end

exports('AddActionLog', AddActionLog)

local function GiveReward(source, identifier, amount, context)
    if not Config.Rewards.enabled then return 'none' end

    local ok, result = pcall(function()
        if Config.Rewards.type == 'coin' then
            local reward = math.floor(amount * Config.Rewards.ratio)
            local beforeMoney = GetPlayerMoneySnapshot(source, identifier)

            if reward <= 0 then
                AddActionLog(source, BuildDonateRewardActionText(context, 'coins', reward))
                return 'coin: 0 (skipped)'
            end

            MySQL.query.await([[
                INSERT INTO derp_coin (citizenid, coin)
                VALUES (?, ?)
                ON DUPLICATE KEY UPDATE coin = coin + VALUES(coin)
            ]], { identifier, reward })

            local afterMoney = GetPlayerMoneySnapshot(source, identifier)

            AddActionLog(source, BuildDonateRewardActionText(context, 'coins', reward), {
                beforeMoney = beforeMoney,
                afterMoney = afterMoney,
            })

            return 'Coin: ' .. reward

        elseif Config.Rewards.type == 'money_cash' then
            local reward = math.floor(amount * Config.Rewards.ratio)
            local beforeMoney = GetPlayerMoneySnapshot(source, identifier)
            local player = exports['qbx_core']:GetPlayer(source)

            if player then
                player.Functions.AddMoney('cash', reward)
            end

            local afterMoney = GetPlayerMoneySnapshot(source, identifier)

            AddActionLog(source, BuildDonateRewardActionText(context, 'cash', reward), {
                beforeMoney = beforeMoney,
                afterMoney = afterMoney,
            })

            return 'Cash: ' .. reward

        elseif Config.Rewards.type == 'money_bank' then
            local reward = math.floor(amount * Config.Rewards.ratio)
            local beforeMoney = GetPlayerMoneySnapshot(source, identifier)
            local player = exports['qbx_core']:GetPlayer(source)

            if player then
                player.Functions.AddMoney('bank', reward)
            end

            local afterMoney = GetPlayerMoneySnapshot(source, identifier)

            AddActionLog(source, BuildDonateRewardActionText(context, 'bank', reward), {
                beforeMoney = beforeMoney,
                afterMoney = afterMoney,
            })

            return 'Bank: ' .. reward

        elseif Config.Rewards.type == 'item' then
            local itemAmount = Config.Rewards.itemAmountPerDonate or 1
            exports.ox_inventory:AddItem(source, Config.Rewards.item, itemAmount)

            AddActionLog(source, BuildDonateRewardActionText(context, 'item', {
                name = Config.Rewards.item,
                count = itemAmount,
            }))

            return 'Item: ' .. Config.Rewards.item .. ' x' .. itemAmount
        end

        return 'none'
    end)

    if not ok then
        print('[DERP-donate] GiveReward error:', result)
        if source and source > 0 then
            AddActionLog(source, BuildActionText('Lỗi phát thưởng donate', {
                { 'ticket', context and context.ticketId or nil },
                { 'reward', tostring(result) },
            }))
        end
        return 'reward_error'
    end
    return result or 'none'
end

local function GiveRewardOffline(identifier, amount, context)
    if not Config.Rewards.enabled then return 'none' end

    if Config.Rewards.type == 'coin' then
        local reward = math.floor(amount * Config.Rewards.ratio)
        if reward <= 0 then
            AddActionLog(identifier, BuildDonateRewardActionText(context, 'coins', reward))
            return 'coin: 0 (skipped)'
        end
        MySQL.query.await([[
            INSERT INTO derp_coin (citizenid, coin)
            VALUES (?, ?)
            ON DUPLICATE KEY UPDATE coin = coin + VALUES(coin)
        ]], { identifier, reward })
        AddActionLog(identifier, BuildDonateRewardActionText(context, 'coins', reward))
        return 'Coin: ' .. reward

    elseif Config.Rewards.type == 'money_cash' or Config.Rewards.type == 'money_bank' then
        local reward = math.floor(amount * Config.Rewards.ratio)
        local rewardType = Config.Rewards.type == 'money_cash' and 'cash' or 'bank'
        print(('[DERP-donate] Offline reward pending: %s | amount=%s | type=%s'):format(identifier, amount, Config.Rewards.type))
        AddActionLog(identifier, BuildDonatePendingActionText(context, rewardType, reward))
        return 'pending_offline'

    elseif Config.Rewards.type == 'item' then
        local itemAmount = Config.Rewards.itemAmountPerDonate or 1
        print(('[DERP-donate] Offline item reward pending: %s | item=%s'):format(identifier, Config.Rewards.item))
        AddActionLog(identifier, BuildDonatePendingActionText(context, 'item', {
            name = Config.Rewards.item,
            count = itemAmount,
        }))
        return 'pending_offline'
    end

    return 'none'
end

RegisterNetEvent('DERP-donatesystem:requestPendingState', function()
    local source = source
    if not IsAdmin(source) then return end
    local count = MySQL.scalar.await('SELECT COUNT(*) FROM donate_tickets WHERE status = "pending"', {})
    if count and count > 0 then
        TriggerClientEvent('DERP-donatesystem:showPendingOverlay', source)
    else
        TriggerClientEvent('DERP-donatesystem:hidePendingOverlay', source)
    end
end)

lib.callback.register('DERP-donatesystem:getCoinBalance', function(source)
    local identifier = GetIdentifier(source)
    if not identifier then return 0 end
    return GetCoinBalance(identifier)
end)

lib.callback.register('DERP-donatesystem:checkAdmin', function(source)
    local ok, admin = pcall(IsAdmin, source)
    local ok2, identifier = pcall(GetIdentifier, source)
    return (ok and admin) or false, (ok2 and identifier) or nil
end)

lib.callback.register('DERP-donatesystem:createTicket', function(source, amount, note)
    local ok, result = pcall(function()
        local identifier = GetIdentifier(source)
        if not identifier then
            return { success = false, message = 'Không thể xác minh người chơi. Thử lại sau.' }
        end

        amount = tonumber(amount)
        if not amount or amount < Config.Donate.minAmount or amount > Config.Donate.maxAmount then
            return { success = false, message = ('Số tiền phải từ %d đến %d VND'):format(Config.Donate.minAmount, Config.Donate.maxAmount) }
        end

        note = SanitizeString(tostring(note or ''), 200)

        local now = os.time()
        if playerCooldowns[identifier] and (now - playerCooldowns[identifier]) < Config.Cooldown then
            local remaining = Config.Cooldown - (now - playerCooldowns[identifier])
            return { success = false, message = ('Vui lòng chờ %d giây'):format(remaining) }
        end

        local pendingCount = MySQL.scalar.await('SELECT COUNT(*) FROM donate_tickets WHERE identifier = ? AND status = "pending"', { identifier })
        if pendingCount and pendingCount >= 3 then
            return { success = false, message = 'Bạn có quá nhiều ticket đang chờ (tối đa 3)' }
        end

        local playerName = GetPlayerDisplayName(source)

        local ticketId
        for _ = 1, 10 do
            local candidate = 'DERP-' .. math.random(1000, 9999)
            local exists = MySQL.scalar.await('SELECT ticket_id FROM donate_tickets WHERE ticket_id = ?', { candidate })
            if not exists then
                ticketId = candidate
                break
            end
        end

        if not ticketId then
            return { success = false, message = 'Không thể tạo Ticket ID. Thử lại.' }
        end

        MySQL.insert.await('INSERT INTO donate_tickets (ticket_id, identifier, player_name, amount, note, status) VALUES (?, ?, ?, ?, ?, "pending")', {
            ticketId, identifier, playerName, amount, note
        })

        playerCooldowns[identifier] = now

        CreateThread(function()
            NotifyAllAdmins('DERP-donatesystem:showPendingOverlay')
        end)

        AddActionLog(source, BuildActionText('Tạo ticket donate', {
            { 'ticket', ticketId },
            { 'donate', ('%s %s'):format(amount, Config.Donate.currency or 'VND') },
            { 'note', note ~= '' and note or nil },
        }))

        return {
            success = true,
            ticketId = ticketId,
            amount = amount,
            note = note,
            message = 'Ticket đã được tạo thành công'
        }
    end)

    if not ok then
        print('[DERP-donate] createTicket error:', result)
        return { success = false, message = 'Lỗi hệ thống. Vui lòng báo admin: ' .. tostring(result):sub(1, 80) }
    end
    return result
end)

lib.callback.register('DERP-donatesystem:getMyTickets', function(source)
    local identifier = GetIdentifier(source)
    if not identifier then return {} end
    local tickets = MySQL.query.await('SELECT * FROM donate_tickets WHERE identifier = ? ORDER BY created_at DESC LIMIT 20', { identifier })
    return tickets or {}
end)

lib.callback.register('DERP-donatesystem:adminGetTickets', function(source, filter, search)
    if not IsAdmin(source) then return { success = false, tickets = {} } end

    local query = 'SELECT * FROM donate_tickets'
    local params = {}
    local conditions = {}

    filter = SanitizeString(tostring(filter or ''), 20)
    search = SanitizeString(tostring(search or ''), 50)

    if filter == 'pending' or filter == 'paid' or filter == 'rejected' then
        conditions[#conditions + 1] = 'status = ?'
        params[#params + 1] = filter
    end

    if search ~= '' then
        conditions[#conditions + 1] = 'ticket_id LIKE ?'
        params[#params + 1] = '%' .. search .. '%'
    end

    if #conditions > 0 then
        query = query .. ' WHERE ' .. table.concat(conditions, ' AND ')
    end

    query = query .. ' ORDER BY created_at DESC LIMIT 50'

    local tickets = MySQL.query.await(query, params)
    return { success = true, tickets = tickets or {} }
end)

lib.callback.register('DERP-donatesystem:adminConfirmTicket', function(source, ticketId)
    if not IsAdmin(source) then return { success = false, message = 'Không có quyền' } end

    ticketId = SanitizeString(tostring(ticketId or ''), 20)
    if ticketId == '' then return { success = false, message = 'Ticket ID không hợp lệ' } end

    local ticket = MySQL.single.await('SELECT * FROM donate_tickets WHERE ticket_id = ? AND status = "pending"', { ticketId })
    if not ticket then
        return { success = false, message = 'Ticket không tồn tại hoặc đã được xử lý' }
    end

    MySQL.update.await('UPDATE donate_tickets SET status = "paid" WHERE ticket_id = ?', { ticketId })

    CreateThread(function()
        BroadcastPendingState()
    end)

    local adminName = GetPlayerDisplayName(source)
    local rewardDesc = 'none'
    local targetSrc = nil
    local rewardContext = {
        ticketId = ticketId,
        amountText = ('%s %s'):format(ticket.amount, Config.Donate.currency or 'VND'),
        adminName = adminName,
    }

    for _, playerId in ipairs(GetPlayers()) do
        local pid = tonumber(playerId)
        local pIdentifier = GetIdentifier(pid)
        if pIdentifier == ticket.identifier then
            targetSrc = pid
            break
        end
    end

    if targetSrc then
        rewardDesc = GiveReward(targetSrc, ticket.identifier, ticket.amount, rewardContext)
        TriggerClientEvent('DERP-donatesystem:notify', targetSrc, 'success', ('Donate #%s đã được xác nhận! Cảm ơn bạn.'):format(ticketId))
    else
        rewardDesc = GiveRewardOffline(ticket.identifier, ticket.amount, rewardContext)
    end

    MySQL.insert.await('INSERT INTO donate_logs (ticket_id, identifier, player_name, amount, reward, confirmed_by) VALUES (?, ?, ?, ?, ?, ?)', {
        ticketId, ticket.identifier, ticket.player_name, ticket.amount, rewardDesc, adminName
    })

    TriggerClientEvent('DERP-donatesystem:notify', source, 'success', ('Đã xác nhận ticket %s'):format(ticketId))
    return { success = true, message = 'Xác nhận thành công' }
end)

lib.callback.register('DERP-donatesystem:adminRejectTicket', function(source, ticketId)
    if not IsAdmin(source) then return { success = false, message = 'Không có quyền' } end

    ticketId = SanitizeString(tostring(ticketId or ''), 20)
    if ticketId == '' then return { success = false, message = 'Ticket ID không hợp lệ' } end

    local ticket = MySQL.single.await('SELECT * FROM donate_tickets WHERE ticket_id = ? AND status = "pending"', { ticketId })
    if not ticket then
        return { success = false, message = 'Ticket không tồn tại hoặc đã được xử lý' }
    end

    MySQL.update.await('UPDATE donate_tickets SET status = "rejected" WHERE ticket_id = ?', { ticketId })

    CreateThread(function()
        BroadcastPendingState()
    end)

    for _, playerId in ipairs(GetPlayers()) do
        local pid = tonumber(playerId)
        if GetIdentifier(pid) == ticket.identifier then
            TriggerClientEvent('DERP-donatesystem:notify', pid, 'error', ('Donate #%s đã bị từ chối.'):format(ticketId))
            break
        end
    end

    TriggerClientEvent('DERP-donatesystem:notify', source, 'info', ('Đã từ chối ticket %s'):format(ticketId))
    return { success = true, message = 'Đã từ chối ticket' }
end)

lib.callback.register('DERP-donatesystem:cancelTicket', function(source, ticketId)
    ticketId = SanitizeString(tostring(ticketId or ''), 20)
    if ticketId == '' then return { success = false, message = 'Ticket ID không hợp lệ' } end

    local identifier = GetIdentifier(source)
    if not identifier then return { success = false, message = 'Không xác minh được người chơi' } end

    local ticket = MySQL.single.await('SELECT * FROM donate_tickets WHERE ticket_id = ? AND identifier = ? AND status = "pending"', { ticketId, identifier })
    if not ticket then
        return { success = false, message = 'Ticket không tồn tại hoặc đã được xử lý' }
    end

    MySQL.update.await('UPDATE donate_tickets SET status = "rejected" WHERE ticket_id = ?', { ticketId })

    CreateThread(function()
        BroadcastPendingState()
    end)

    TriggerClientEvent('DERP-donatesystem:notify', source, 'info', ('Đã hủy ticket %s'):format(ticketId))
    return { success = true, message = 'Đã hủy ticket' }
end)

lib.callback.register('DERP-donatesystem:getRevenue', function(source)
    if not IsAdmin(source) then return { success = false } end

    local total     = MySQL.scalar.await('SELECT COALESCE(SUM(amount), 0) FROM donate_logs', {})
    local today     = MySQL.scalar.await('SELECT COALESCE(SUM(amount), 0) FROM donate_logs WHERE DATE(created_at) = CURDATE()', {})
    local thisMonth = MySQL.scalar.await('SELECT COALESCE(SUM(amount), 0) FROM donate_logs WHERE MONTH(created_at) = MONTH(CURDATE()) AND YEAR(created_at) = YEAR(CURDATE())', {})
    local logs      = MySQL.query.await('SELECT * FROM donate_logs ORDER BY created_at DESC LIMIT 50', {})

    return {
        success   = true,
        total     = total or 0,
        today     = today or 0,
        thisMonth = thisMonth or 0,
        logs      = logs or {}
    }
end)