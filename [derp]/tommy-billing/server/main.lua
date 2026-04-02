-- server.lua (Qbox + Renewed-Banking)

local function SendLog(title, message, color)
    if Config.Webhook == '' then return end
    PerformHttpRequest(Config.Webhook, function() end, 'POST',
        json.encode({
            username = 'Tommy Billing System',
            embeds = {{
                title       = title,
                description = message,
                color       = color or 3447003,
                footer      = { text = os.date('%Y-%m-%d %H:%M:%S') }
            }}
        }),
        { ['Content-Type'] = 'application/json' }
    )
end

local function IsJobAllowed(jobName)
    return Config.AllowedJobs[jobName] ~= nil
end

local function IsBoss(player)
    if not player then return false end
    return player.PlayerData.job.isboss or false
end

local function GenerateBillId()
    local result = MySQL.scalar.await('SELECT MAX(id) as max_id FROM billing_history')
    return string.format('%s-%06d', Config.BillPrefix, (result or 0) + 1)
end

local function GetPlayerInfo(player)
    if not player then return nil, nil end
    local ci = player.PlayerData.charinfo
    return ci.firstname .. ' ' .. ci.lastname, player.PlayerData.citizenid
end

local function GetNearbyPlayers(source)
    local coords = GetEntityCoords(GetPlayerPed(source))
    local players = {}
    for _, id in ipairs(GetPlayers()) do
        if id ~= source then
            local dist = #(coords - GetEntityCoords(GetPlayerPed(id)))
            if dist <= Config.Distance then
                local p = exports.qbx_core:GetPlayer(id)
                if p then
                    local name, cid = GetPlayerInfo(p)
                    players[#players + 1] = { id = id, name = name, citizenid = cid }
                end
            end
        end
    end
    return players
end

local function AddSocietyMoney(jobName, amount)
    exports['Renewed-Banking']:addAccountMoney(jobName, amount)
end

local function Notify(src, msg, ntype, duration)
    TriggerClientEvent('ox_lib:notify', src, {
        description = msg,
        type        = ntype or 'inform',
        duration    = duration or 4000
    })
end

local function ProcessAutoPayForPlayer(player, bill)
    local money    = player.PlayerData.money[bill.payment_method]
    local jcfg     = Config.AllowedJobs[bill.biller_job]
    local canPay   = false

    if bill.payment_method == 'cash' then
        canPay = money >= bill.amount
    else
        if jcfg and jcfg.allowNegativeBalance then
            canPay = (money - bill.amount) >= Config.MaxNegativeBalance
        else
            canPay = money >= bill.amount
        end
    end

    if not canPay then return end

    player.Functions.RemoveMoney(bill.payment_method, bill.amount, 'auto-billing-' .. bill.bill_id)
    AddSocietyMoney(bill.biller_job, bill.society_amount)

    if bill.commission > 0 then
        local biller = exports.qbx_core:GetPlayerByCitizenId(bill.biller_citizenid)
        if biller then
            biller.Functions.AddMoney('bank', bill.commission, 'billing-commission-' .. bill.bill_id)
        end
    end

    MySQL.update.await('UPDATE billing_history SET status = \'auto_paid\', updated_at = NOW() WHERE bill_id = ?', { bill.bill_id })
    Notify(player.PlayerData.source, string.format(Config.Locales['bill_auto_paid'], bill.amount), 'inform')
end

-- ==================== CALLBACKS ====================

lib.callback.register('tommy-billing:server:getNearbyPlayers', function(source)
    return GetNearbyPlayers(source)
end)

lib.callback.register('tommy-billing:server:getUIData', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return nil end

    local job     = player.PlayerData.job
    local jcfg    = Config.AllowedJobs[job.name]
    return {
        canCreateBill = IsJobAllowed(job.name) and job.onduty,
        isBoss        = IsBoss(player),
        jobName       = job.name,
        jobLabel      = jcfg and jcfg.label or job.label,
        onDuty        = job.onduty
    }
end)

lib.callback.register('tommy-billing:server:getPendingBills', function(source, page)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return {}, 0 end

    local cid    = player.PlayerData.citizenid
    local offset = ((page or 1) - 1) * Config.HistoryPageSize

    local bills = MySQL.query.await('SELECT * FROM billing_history WHERE target_citizenid = ? AND status = \'pending\' ORDER BY created_at DESC LIMIT ? OFFSET ?', { cid, Config.HistoryPageSize, offset })
    local total = MySQL.scalar.await('SELECT COUNT(*) FROM billing_history WHERE target_citizenid = ? AND status = \'pending\'', { cid })

    return bills or {}, total or 0
end)

lib.callback.register('tommy-billing:server:getMyHistory', function(source, page)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return {}, 0 end

    local cid    = player.PlayerData.citizenid
    local offset = ((page or 1) - 1) * Config.HistoryPageSize

    local bills = MySQL.query.await('SELECT * FROM billing_history WHERE target_citizenid = ? AND status IN (\'paid\', \'rejected\', \'auto_paid\') ORDER BY updated_at DESC LIMIT ? OFFSET ?', { cid, Config.HistoryPageSize, offset })
    local total = MySQL.scalar.await('SELECT COUNT(*) FROM billing_history WHERE target_citizenid = ? AND status IN (\'paid\', \'rejected\', \'auto_paid\')', { cid })

    return bills or {}, total or 0
end)

lib.callback.register('tommy-billing:server:getMyCreatedBills', function(source, page)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return {}, 0 end

    local cid    = player.PlayerData.citizenid
    local offset = ((page or 1) - 1) * Config.HistoryPageSize

    local bills = MySQL.query.await('SELECT * FROM billing_history WHERE biller_citizenid = ? ORDER BY created_at DESC LIMIT ? OFFSET ?', { cid, Config.HistoryPageSize, offset })
    local total = MySQL.scalar.await('SELECT COUNT(*) FROM billing_history WHERE biller_citizenid = ?', { cid })

    return bills or {}, total or 0
end)

lib.callback.register('tommy-billing:server:getCompanyBills', function(source, page)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return {}, 0, {} end
    if not IsBoss(player) then return {}, 0, {} end

    local jobName = player.PlayerData.job.name
    local offset  = ((page or 1) - 1) * Config.HistoryPageSize

    local bills = MySQL.query.await('SELECT * FROM billing_history WHERE biller_job = ? ORDER BY created_at DESC LIMIT ? OFFSET ?', { jobName, Config.HistoryPageSize, offset })
    local total = MySQL.scalar.await('SELECT COUNT(*) FROM billing_history WHERE biller_job = ?', { jobName })
    local stats = MySQL.query.await([[
        SELECT
            COUNT(*) as total_bills,
            SUM(CASE WHEN status IN ('paid','auto_paid') THEN amount       ELSE 0 END) as total_revenue,
            SUM(CASE WHEN status IN ('paid','auto_paid') THEN society_amount ELSE 0 END) as total_society,
            SUM(CASE WHEN status IN ('paid','auto_paid') THEN commission   ELSE 0 END) as total_commission,
            SUM(CASE WHEN status = 'pending'             THEN 1            ELSE 0 END) as pending_count,
            SUM(CASE WHEN status IN ('paid','auto_paid') THEN 1            ELSE 0 END) as paid_count,
            SUM(CASE WHEN status = 'rejected'            THEN 1            ELSE 0 END) as rejected_count,
            SUM(CASE WHEN status = 'cancelled'           THEN 1            ELSE 0 END) as cancelled_count
        FROM billing_history WHERE biller_job = ?
    ]], { jobName })

    return bills or {}, total or 0, stats and stats[1] or {}
end)

-- ==================== EVENTS ====================

RegisterNetEvent('tommy-billing:server:createBill', function(data)
    local src    = source
    local biller = exports.qbx_core:GetPlayer(src)
    local target = exports.qbx_core:GetPlayer(data.targetId)

    if not biller or not target then
        Notify(src, Config.Locales['player_not_found'], 'error')
        return
    end

    local job  = biller.PlayerData.job
    local jcfg = Config.AllowedJobs[job.name]

    if not IsJobAllowed(job.name) or not job.onduty then
        Notify(src, Config.Locales['no_permission'], 'error')
        return
    end

    local amount = math.floor(tonumber(data.amount) or 0)
    if amount <= 0 then
        Notify(src, Config.Locales['invalid_amount'], 'error')
        return
    end

    local dist = #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(data.targetId)))
    if dist > Config.Distance then
        Notify(src, 'Khách hàng quá xa!', 'error')
        return
    end

    local billerName, billerCid = GetPlayerInfo(biller)
    local targetName, targetCid = GetPlayerInfo(target)

    local commission   = Config.EnableCommission and math.ceil(amount * jcfg.commission) or 0
    local societyAmt   = amount - commission
    local billId       = GenerateBillId()
    local reason       = (data.reason and data.reason ~= '') and data.reason or ('Dịch vụ ' .. jcfg.label)
    local dueDate      = os.date('%Y-%m-%d %H:%M:%S', os.time() + Config.AutoPayDays * 86400)

    MySQL.insert.await([[
        INSERT INTO billing_history
            (bill_id, biller_citizenid, biller_name, biller_job, biller_job_label,
             target_citizenid, target_name, reason, amount, commission, society_amount,
             payment_method, status, due_date)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,'pending',?)
    ]], { billId, billerCid, billerName, job.name, jcfg.label, targetCid, targetName, reason, amount, commission, societyAmt, data.accountType, dueDate })

    Notify(src, string.format('Đã tạo hóa đơn %s - $%s cho %s', billId, amount, targetName), 'success')
    Notify(data.targetId, string.format(Config.Locales['new_bill_received'], jcfg.label, amount), 'inform', 5000)
    TriggerClientEvent('tommy-billing:client:newBillReceived', data.targetId, { billId = billId, amount = amount, jobLabel = jcfg.label, reason = reason })

    SendLog('📝 Hóa Đơn Mới', string.format('**Mã HĐ:** %s\n**Nhân viên:** %s\n**Khách hàng:** %s\n**Số tiền:** $%s\n**Lý do:** %s\n**Hạn thanh toán:** %s', billId, billerName, targetName, amount, reason, dueDate), 3447003)
end)

RegisterNetEvent('tommy-billing:server:payBill', function(billId)
    local src    = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    local cid  = player.PlayerData.citizenid
    local bill = MySQL.single.await('SELECT * FROM billing_history WHERE bill_id = ? AND target_citizenid = ? AND status = \'pending\'', { billId, cid })

    if not bill then
        Notify(src, 'Không tìm thấy hóa đơn!', 'error')
        return
    end

    local money = player.PlayerData.money[bill.payment_method]
    local jcfg  = Config.AllowedJobs[bill.biller_job]

    if bill.payment_method == 'cash' then
        if money < bill.amount then
            Notify(src, Config.Locales['not_enough_money'], 'error')
            return
        end
    else
        local limit = jcfg and jcfg.allowNegativeBalance and Config.MaxNegativeBalance or 0
        if (money - bill.amount) < limit then
            Notify(src, jcfg and jcfg.allowNegativeBalance
                and string.format('Không thể thanh toán! Vượt quá hạn mức nợ $%s', math.abs(Config.MaxNegativeBalance))
                or Config.Locales['not_enough_money'], 'error')
            return
        end
    end

    player.Functions.RemoveMoney(bill.payment_method, bill.amount, 'billing-payment-' .. billId)
    AddSocietyMoney(bill.biller_job, bill.society_amount)

    if bill.commission > 0 then
        local biller = exports.qbx_core:GetPlayerByCitizenId(bill.biller_citizenid)
        if biller then
            biller.Functions.AddMoney('bank', bill.commission, 'billing-commission-' .. billId)
            Notify(biller.PlayerData.source, string.format('Nhận hoa hồng $%s từ hóa đơn %s', bill.commission, billId), 'success')
        end
    end

    MySQL.update.await('UPDATE billing_history SET status = \'paid\', updated_at = NOW() WHERE bill_id = ?', { billId })

    Notify(src, string.format(Config.Locales['bill_paid_success'], bill.amount, bill.biller_job_label), 'success')
    TriggerClientEvent('tommy-billing:client:refreshBills', src)

    local biller = exports.qbx_core:GetPlayerByCitizenId(bill.biller_citizenid)
    if biller then
        Notify(biller.PlayerData.source, string.format('Khách hàng %s đã thanh toán hóa đơn %s - $%s', bill.target_name, billId, bill.amount), 'success')
    end

    SendLog('✅ Thanh Toán Thành Công', string.format('**Mã HĐ:** %s\n**Khách hàng:** %s\n**Số tiền:** $%s\n**Phương thức:** %s', billId, bill.target_name, bill.amount, bill.payment_method == 'cash' and 'Tiền mặt' or 'Ngân hàng'), 65280)
end)

RegisterNetEvent('tommy-billing:server:rejectBill', function(billId)
    local src    = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    local cid  = player.PlayerData.citizenid
    local bill = MySQL.single.await('SELECT * FROM billing_history WHERE bill_id = ? AND target_citizenid = ? AND status = \'pending\'', { billId, cid })

    if not bill then
        Notify(src, 'Không tìm thấy hóa đơn!', 'error')
        return
    end

    MySQL.update.await('UPDATE billing_history SET status = \'rejected\', updated_at = NOW() WHERE bill_id = ?', { billId })
    Notify(src, Config.Locales['bill_rejected'], 'inform')
    TriggerClientEvent('tommy-billing:client:refreshBills', src)

    local biller = exports.qbx_core:GetPlayerByCitizenId(bill.biller_citizenid)
    if biller then
        Notify(biller.PlayerData.source, string.format('Khách hàng %s đã từ chối hóa đơn %s', bill.target_name, billId), 'error')
    end

    SendLog('❌ Từ Chối Thanh Toán', string.format('**Mã HĐ:** %s\n**Khách hàng:** %s\n**Số tiền:** $%s', billId, bill.target_name, bill.amount), 16711680)
end)

RegisterNetEvent('tommy-billing:server:cancelBill', function(billId, reason)
    local src    = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    if type(reason) ~= 'string' or reason == '' then
        Notify(src, 'Vui lòng nhập lý do hủy!', 'error')
        return
    end

    local cid  = player.PlayerData.citizenid
    local bill = MySQL.single.await('SELECT * FROM billing_history WHERE bill_id = ? AND biller_citizenid = ? AND status = \'pending\'', { billId, cid })

    if not bill then
        Notify(src, 'Không tìm thấy hóa đơn hoặc không có quyền hủy!', 'error')
        return
    end

    MySQL.update.await('UPDATE billing_history SET status = \'cancelled\', cancel_reason = ?, updated_at = NOW() WHERE bill_id = ?', { reason, billId })
    Notify(src, Config.Locales['bill_cancelled'], 'success')
    TriggerClientEvent('tommy-billing:client:refreshBills', src)

    local target = exports.qbx_core:GetPlayerByCitizenId(bill.target_citizenid)
    if target then
        Notify(target.PlayerData.source, string.format('Hóa đơn %s đã được hủy bởi nhân viên. Lý do: %s', billId, reason), 'inform')
        TriggerClientEvent('tommy-billing:client:refreshBills', target.PlayerData.source)
    end

    SendLog('🚫 Hủy Hóa Đơn', string.format('**Mã HĐ:** %s\n**Nhân viên:** %s\n**Lý do:** %s', billId, bill.biller_name, reason), 16776960)
end)

-- ==================== AUTO PAY THREAD ====================

CreateThread(function()
    while true do
        Wait(60000)

        local overdue = MySQL.query.await('SELECT * FROM billing_history WHERE status = \'pending\' AND due_date <= NOW()')
        if overdue and #overdue > 0 then
            for _, bill in ipairs(overdue) do
                local player = exports.qbx_core:GetPlayerByCitizenId(bill.target_citizenid)
                if player then
                    ProcessAutoPayForPlayer(player, bill)
                    SendLog('⏰ Tự Động Trừ Tiền', string.format('**Mã HĐ:** %s\n**Khách hàng:** %s\n**Số tiền:** $%s', bill.bill_id, bill.target_name, bill.amount), 16753920)
                end
            end
        end
    end
end)

-- ==================== PLAYER LOAD ====================

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local src    = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    Wait(3000)

    local cid = player.PlayerData.citizenid

    local pendingCount = MySQL.scalar.await('SELECT COUNT(*) FROM billing_history WHERE target_citizenid = ? AND status = \'pending\'', { cid })
    if pendingCount and pendingCount > 0 then
        Notify(src, string.format('Bạn có %s hóa đơn chưa thanh toán!', pendingCount), 'inform', 7000)
    end

    local overdue = MySQL.query.await('SELECT * FROM billing_history WHERE target_citizenid = ? AND status = \'pending\' AND due_date <= NOW()', { cid })
    if overdue and #overdue > 0 then
        for _, bill in ipairs(overdue) do
            ProcessAutoPayForPlayer(player, bill)
        end
    end
end)

-- ==================== RESOURCE START ====================

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `billing_history` (
            `id`               INT AUTO_INCREMENT PRIMARY KEY,
            `bill_id`          VARCHAR(20)  NOT NULL UNIQUE,
            `biller_citizenid` VARCHAR(50)  NOT NULL,
            `biller_name`      VARCHAR(100) NOT NULL,
            `biller_job`       VARCHAR(50)  NOT NULL,
            `biller_job_label` VARCHAR(100) NOT NULL,
            `target_citizenid` VARCHAR(50)  NOT NULL,
            `target_name`      VARCHAR(100) NOT NULL,
            `reason`           VARCHAR(255) NOT NULL,
            `amount`           INT          NOT NULL,
            `commission`       INT          DEFAULT 0,
            `society_amount`   INT          NOT NULL,
            `payment_method`   ENUM('cash','bank') NOT NULL,
            `status`           ENUM('pending','paid','rejected','cancelled','auto_paid') DEFAULT 'pending',
            `cancel_reason`    VARCHAR(255) NULL,
            `created_at`       TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
            `updated_at`       TIMESTAMP    NULL,
            `due_date`         TIMESTAMP    NULL,
            INDEX `idx_biller` (`biller_citizenid`),
            INDEX `idx_target` (`target_citizenid`),
            INDEX `idx_job`    (`biller_job`),
            INDEX `idx_status` (`status`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    print('^2[Tommy Billing] ^0Database initialized!')
end)