Config = {}

-- ==================== CÀI ĐẶT CƠ BẢN ====================

Config.Distance = 10.0
Config.EnableCommission = true
Config.MaxNegativeBalance = -10000

-- ==================== BILL SETTINGS ====================

Config.BillPrefix = 'DERP'                -- Prefix cho mã bill: BILL-000001
Config.AutoPayDays = 3                    -- Tự động trừ tiền sau 7 ngày
Config.HistoryPageSize = 10               -- Số bill mỗi trang

-- ==================== DEBUG MODE ====================

Config.DebugMode = false

-- ==================== DISCORD WEBHOOK ====================

Config.Webhook = 'https://discord.com/api/webhooks/1429345321044934709/ExbDEFyS31dQ-paPiG4b9Zg7q9iEKqENYdfP-ruCycJ5x3FaCyAwhGd3g1oBb5ihARff'

-- ==================== BANKING SYSTEM ====================

Config.BankingSystem = 'qb-banking'

-- ==================== CÔNG VIỆC ĐƯỢC PHÉP ====================

Config.AllowedJobs = {    
    ['police'] = {
        label = 'LSPD',
        commission = 0.0,
        allowNegativeBalance = true, 
    },
    ['ambulance'] = {
        label = 'Bệnh Viện',
        commission = 0.1,
        allowNegativeBalance = true, 
    },
    ['mechanic'] = {
        label = 'Sửa Xe',
        commission = 0.0,
        allowNegativeBalance = false,
    },
    ['redlinecustom'] = {
        label = 'Độ Xe',
        commission = 0.0,
        allowNegativeBalance = false,
    },
}

-- ==================== LOCALES ====================

Config.Locales = {
    -- Status
    ['status_pending'] = 'Chờ thanh toán',
    ['status_paid'] = 'Đã thanh toán',
    ['status_rejected'] = 'Đã từ chối',
    ['status_cancelled'] = 'Đã hủy',
    ['status_auto_paid'] = 'Tự động trừ',
    
    -- Tabs
    ['tab_create'] = 'Viết Hóa Đơn',
    ['tab_pending'] = 'Cần Thanh Toán',
    ['tab_history'] = 'Lịch Sử',
    ['tab_my_bills'] = 'Bill Đã Viết',
    ['tab_company'] = 'Công Ty',
    
    -- Notifications
    ['new_bill_received'] = 'Bạn có hóa đơn mới từ %s - $%s',
    ['bill_paid_success'] = 'Đã thanh toán $%s cho %s',
    ['bill_rejected'] = 'Bạn đã từ chối hóa đơn',
    ['bill_cancelled'] = 'Hóa đơn đã được hủy',
    ['not_enough_money'] = 'Bạn không đủ tiền!',
    ['bill_auto_paid'] = 'Hóa đơn $%s đã được tự động trừ',
    
    -- Errors
    ['player_not_found'] = 'Không tìm thấy người chơi!',
    ['invalid_amount'] = 'Số tiền không hợp lệ!',
    ['no_permission'] = 'Bạn không có quyền!',
}