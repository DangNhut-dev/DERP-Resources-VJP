Config = Config or {} -- Tạo bảng Config nếu chưa có (để có thể override cấu hình khi resource load nhiều file)

Config.Command = { -- Nhóm cấu hình cho lệnh mở bảng xếp hạng
    Name = 'ranking', -- Tên command dùng trong chat/console (vd: /ranking)
    Restricted = 'group.mod', -- Giới hạn quyền theo group của QBCore (ai có group.mod mới dùng được)
    SecurityAce = 'mod', -- Tên ACE permission cần có trong server.cfg để dùng command (vd: add_ace ... mod allow)
    AllowConsole = true, -- Cho phép chạy command từ console server
} 

Config.Database = { -- Nhóm cấu hình database (tên bảng/cột để query dữ liệu)
    PlayersTable = 'players', -- Tên bảng lưu player của QBCore (thường là bảng players)
    OxInventoryTable = 'ox_inventory', -- Tên bảng ox_inventory (lưu dữ liệu túi đồ offline)
    PlaytimeTable = 'js_ranking_playtime', -- Tên bảng lưu playtime của resource (tự tạo/auto tạo)
    MoneyHistoryTable = 'js_ranking_money_history', -- Tên bảng lưu lịch sử tiền theo thời gian (tự tạo/auto tạo)

    Columns = { -- Map tên cột trong bảng PlayersTable để resource đọc đúng dữ liệu
        citizenid = 'citizenid', -- Tên cột citizenid trong bảng players
        charinfo  = 'charinfo', -- Tên cột charinfo (thường là JSON thông tin nhân vật)
        name      = 'name', -- Tên cột name (nếu server dùng cột name riêng)
        money     = 'money', -- Tên cột money (thường là JSON money của QBCore)

        job       = 'job', -- Tên cột job (thường là JSON job của QBCore)

        inventory = 'inventory', -- Tên cột inventory trong bảng players (nếu có lưu inventory ở đây)
    }, 

    OfflineInventory = { -- Cấu hình đọc túi đồ của người chơi khi OFFLINE từ ox_inventory database
        Enabled = true, -- Bật/tắt tính năng đọc inventory offline
        OwnerKeyType = 'citizenid', -- Loại key định danh owner (citizenid/steam/license...) dùng để khớp với ox_inventory
        PlayerInventoryName = 'player', -- Tên inventory mặc định của player trong ox_inventory (thường là 'player')
        OwnerColumn = 'owner', -- Tên cột 'owner' trong bảng ox_inventory
        NameColumn  = 'name', -- Tên cột 'name' (tên inventory) trong bảng ox_inventory
        DataColumn  = 'data', -- Tên cột 'data' (JSON items) trong bảng ox_inventory
    } 
} 

Config.Leaderboard = { -- Cấu hình bảng xếp hạng (lọc, sort, cache, các loại tiền hiển thị)
    MaxEntries = 300, -- Số dòng tối đa trả về/hiển thị trên leaderboard
    IncludeOffline = false, -- Có tính cả người chơi offline trong leaderboard hay không
    CacheTtlSeconds = 15, -- Thời gian cache (giây) để giảm query database liên tục
    ExcludeNoCitizenId = true, -- Bỏ qua record không có citizenid (tránh lỗi dữ liệu rác)

    Sort = { -- Cấu hình sort mặc định
        Primary = 'cash_bank_crypto_desc', -- Kiểu sort chính (cash_bank_crypto_desc = tổng cash+bank+crypto giảm dần)
    }, -- Kết thúc Sort

    MoneyKeys = { -- Map key money để đọc đúng field trong JSON money
        cash   = 'cash', -- Key 'cash' trong JSON money
        bank   = 'bank', -- Key 'bank' trong JSON money
        crypto = 'crypto', -- Key 'crypto' trong JSON money
    }, 

    DefaultMoneyValue = 0, -- Giá trị mặc định khi thiếu key money (tránh nil -> 0)

    UseLiveMoneyForOnline = true, -- Online sẽ lấy tiền trực tiếp từ PlayerData (live) thay vì đọc DB (đỡ lệch)
}

Config.Playtime = { -- Cấu hình thống kê thời gian online (playtime)
    UseQBCoreEvents = true, -- Dùng event của QBCore (QBCore:Server:OnPlayerLoaded/Unload) để tính playtime
    AlsoHandlePlayerDropped = true, -- Bắt thêm event playerDropped để chốt playtime khi player rớt mạng/quit đột ngột

    DisplayFormat = 'd_hms', -- Format hiển thị playtime: d_hms = ngày-giờ-phút-giây
    DaySuffix = 'd', -- Hậu tố cho 'day' khi hiển thị (vd: 2d 05:10:03)
} 

Config.MoneyHistory = { -- Cấu hình lưu lịch sử tiền (để vẽ biểu đồ/soi biến động)
    Enabled = true, -- Bật/tắt tính năng ghi money history

    Bucket = 'minute', -- Đơn vị bucket để gom dữ liệu (minute = theo phút)
    BucketMinutes = 1, -- Kích thước bucket theo phút (1 = mỗi phút 1 điểm)

    IntervalMinutes = 2, -- Chu kỳ ghi snapshot (phút) - bao lâu ghi 1 lần

    CaptureOffline = false, -- Có ghi lịch sử cho player offline hay không (thường tắt để nhẹ DB)

    CaptureOnLeaderboard = true, -- Tự ghi snapshot khi có request leaderboard
    CaptureOnRequest = true, -- Tự ghi snapshot khi có request xem chi tiết (on-demand)
    CaptureOfflineOnRequest = true, -- Cho phép ghi snapshot cho player offline khi có request

    IncludeLivePoint = true, -- Khi player online, lấy money live trực tiếp để snapshot chính xác
    CaptureOnPlayerLoaded = true, -- Ghi snapshot ngay lúc player vừa load vào server

    RetentionDays = 30, -- Số ngày giữ lịch sử rồi xoá (cleanup)

    StoreKeys = { 'cash', 'bank', 'crypto' }, -- Danh sách money keys sẽ lưu vào history (phải khớp moneyTypes server đang dùng)
    TotalKeys = { 'cash', 'bank', 'crypto' }, -- Danh sách keys dùng để tính 'total' (tổng) cho chart/leaderboard
} 

Config.Suspicious = { -- Ngưỡng nghi vấn kiểu 1 (đếm biến động tiền lớn trong X ngày)
    Threshold = 300000, -- Ngưỡng chênh lệch tiền để bị tính là 'nghi vấn' (đơn vị: tiền)
    Days = 3, -- Số ngày lookback để đếm/hiển thị cột nghi vấn
} 

Config.Suspicious2 = { -- Ngưỡng nghi vấn kiểu 2 (đếm chuỗi biến động nhỏ liên tiếp trong cửa sổ thời gian)
    Threshold = 3000,      -- mỗi lần chênh lệch <= Threshold sẽ được tính vào chuỗi | đơn vị chênh lệch tiền
    WindowMinutes = 5,     -- cửa sổ thời gian để tính chuỗi (phút) | tính theo phút
    MinConsecutive = 11,   -- "trên 10 lần" => 11 lần liên tiếp | giá trị này càng cao càng ít bắt nhầm
    Days = 3,             -- số ngày dùng để đếm ở cột Nghi vấn 2 | lookback để hiển thị
} 

Config.UI = { -- Cấu hình giao diện NUI (theme, bảng, modal, chart...)
    Theme = { -- Bộ màu theme (áp CSS cho nền/panel/text/glow)
        Main = '#2ca9e8', -- Màu chủ đạo (main accent)

        Background = 'rgba(10, 10, 18, 0.88)', -- Màu nền tổng (rgba) của UI
        Panel      = 'rgba(44, 169, 232, 0.10)', -- Màu panel/khung nội dung
        Border     = 'rgba(44, 169, 232, 0.35)', -- Màu viền (border) panel

        Text       = '#e8f7ff', -- Màu chữ chính
        MutedText  = 'rgba(232, 247, 255, 0.72)', -- Màu chữ phụ (mờ) cho text thứ cấp

        NeonGlow   = '0 0 10px rgba(44,169,232,0.75), 0 0 20px rgba(44,169,232,0.45)', -- Hiệu ứng glow (box-shadow) mức thường
        NeonGlowStrong = '0 0 14px rgba(44,169,232,0.90), 0 0 28px rgba(44,169,232,0.60)', -- Hiệu ứng glow (box-shadow) mức mạnh
    }, 

    Search = { -- Cấu hình ô tìm kiếm trên UI
        Enabled = true, -- Bật/tắt tính năng search
        DebounceMs = 120, -- Debounce (ms) - delay trước khi chạy search để tránh spam
        ClearOnEsc = true, -- Nhấn ESC để xoá nội dung search
    }, 

    Table = { -- Cấu hình bảng hiển thị leaderboard
        VisibleRows = 10, -- Số dòng hiển thị mỗi trang/khung (UI)
        RowHeightPx = 46, -- Chiều cao mỗi row (px) để UI canh layout
        ShowScrollBar = true, -- Hiện thanh scroll khi danh sách dài

        Columns = { -- Danh sách cột hiển thị (key phải trùng dữ liệu backend gửi lên)
            { key = 'status',     width = '150px' }, -- Cột trạng thái (online/offline...)
            { key = 'name',       width = '240px' }, -- Cột tên người chơi
            { key = 'job',        width = '190px' }, -- Cột job (nghề)
            { key = 'id',         width = '90px'  }, -- Cột ID động (source/server id)
            { key = 'citizenid',  width = '220px' }, -- Cột citizenid
            { key = 'cash',       width = '140px' }, -- Cột tiền mặt
            { key = 'bank',       width = '140px' }, -- Cột tiền bank
            { key = 'suspicious', width = '160px' }, -- Cột nghi vấn (tổng hợp Suspicious/Suspicious2)
            { key = 'online',     width = '170px' }, -- Cột thời gian online/playtime
            { key = 'actions',    width = '210px' }, -- Cột thao tác (xem túi đồ, xem chart, xem log...)
        } 
    }, 

    RankStyles = { -- Style riêng cho top rank (1/2/3) và mặc định
        [1] = { bg = 'rgba(44, 169, 232, 0.25)', border = 'rgba(44, 169, 232, 0.75)', fontSize = 16 }, -- Style cho hạng #1 (bg/border/fontSize)
        [2] = { bg = 'rgba(44, 169, 232, 0.20)', border = 'rgba(44, 169, 232, 0.65)', fontSize = 15 }, -- Style cho hạng #2
        [3] = { bg = 'rgba(160, 223, 250, 0.18)', border = 'rgba(160, 223, 250, 0.55)', fontSize = 14 }, -- Style cho hạng #3
        default = { bg = 'rgba(44, 169, 232, 0.10)', border = 'rgba(44, 169, 232, 0.28)', fontSize = 13 }, -- Style mặc định cho các hạng còn lại
    }, 

    Modal = { -- Cấu hình modal túi đồ (inventory modal)
        MaxItemsShow = 200, -- Giới hạn số item render trong modal (tránh lag UI)
    }, 

    Chart = { -- Cấu hình modal biểu đồ tiền
        DefaultKey = 'total', -- Key mặc định khi mở chart (total = tổng các key trong TotalKeys)
    }, 
} 

Config.Lang = {
    Main = {
        Title = 'BẢNG XẾP HẠNG',
        Subtitle = 'Bảng xếp hạng người chơi',
        MetaUpdated = 'Cập nhật: {time}',
        HintClickName = 'Click tên để xem inventory',
        NoData = 'Không có dữ liệu.',
    },

    Common = {
        Error = 'error',
        LoadingDots = '...',
        Index = '#',
        Unknown = 'Unknown',
        UnknownTime = 'Unknown time',
        NotAvailable = 'N/A',
        Separator = '────────',
        PlayerSub = '{name} • citizenID: {citizenid} • ID: {id}',
    },

    Buttons = {
        Refresh = 'Refresh',
        Close = 'Đóng',
        Chart = 'Biểu đồ',
        Log = 'Log',
        ViewImage = 'Xem ảnh',
        ViewImageIndex = 'Ảnh #{index}',
        ViewOnChart = 'Xem trên biểu đồ',
        OpenLog = 'Mở log',
    },

    Toggles = {
        ShowStaff = 'Hiện Admin/Mod',
        ShowStaffTitle = 'Hiện/ẩn Admin & Mod khỏi bảng xếp hạng',
        HideOffline = 'Ẩn Offline',
        HideOfflineTitle = 'Ẩn/hiện người chơi Offline',
    },

    Search = {
        Placeholder = 'Tìm theo Tên/citizenID/ID',
        GlobalLabel = 'Find log',
        GlobalPlaceholder = 'Find (vd: bank / 1000)',
        ChartPlaceholder = 'Find time / #điểm',
        LogPlaceholder = 'Find',
        ResultBadge = '{count} kq',
        ResultTitle = 'Kết quả find log: "{query}"',
    },

    Ranges = {
        ['24h'] = '24h',
        ['7d'] = '7 ngày',
        ['30d'] = '30 ngày',
    },

    Alerts = {
        Title = 'CẢNH BÁO',
        Empty = 'Không có cảnh báo.',
        Count = '{count} thông báo',
    },

    Status = {
        Online = 'Online',
        Offline = 'Offline',
        SecondsAgo = '{value} giây trc',
        MinutesAgo = '{value} phút trc',
        HoursAgo = '{value} giờ trc',
        DaysAgo = '{value} ngày trc',
    },

    Jobs = {
        police = 'Police',
        ambulance = 'Ambulance',
        mechanic = 'Mechanic',
        taxi = 'Taxi',
        BadgeTitle = '{title}: OnDuty {onDuty} • OffDuty {offDuty} • Total {total}',
    },

    Table = {
        Columns = {
            status = 'Trạng thái',
            name = 'Tên',
            job = 'Job',
            id = 'ID',
            citizenid = 'CitizenID',
            cash = 'Tiền mặt',
            bank = 'Tiền bank',
            suspicious = 'Nghi vấn',
            online = 'Online',
            actions = 'Thao tác',
        },
        Suspicious = 'Nghi vấn',
        Suspicious2 = 'Nghi vấn 2',
    },

    Inventory = {
        Title = 'TÚI ĐỒ NGƯỜI CHƠI',
        Empty = 'Không có item.',
        Offline = 'Người chơi đang offline',
        Loading = 'Đang tải inventory...',
        Error = 'Lỗi khi tải inventory.',
        ErrorFetch = 'Không lấy được inventory: {message}',
        Count = 'Số lượng: {count}',
        TabItems = 'Túi đồ',
        TabVehicles = 'Xe sở hữu',
        ClothingDefault = 'Trang phục',
        ClothingCategories = {
            component = {
                ['1'] = 'Mặt nạ',
                ['3'] = 'Tay áo',
                ['4'] = 'Quần',
                ['5'] = 'Ba lô',
                ['6'] = 'Giày',
                ['7'] = 'Phụ kiện',
                ['8'] = 'Áo trong',
                ['9'] = 'Giáp',
                ['10'] = 'Decal',
                ['11'] = 'Áo khoác',
            },
            props = {
                ['0'] = 'Nón',
                ['1'] = 'Kính',
                ['2'] = 'Khuyên tai',
                ['6'] = 'Đồng hồ',
                ['7'] = 'Vòng tay',
            },
        },
    },

    Vehicles = {
        Loading = 'Đang tải danh sách xe...',
        Error = 'Lỗi khi tải danh sách xe.',
        ErrorFetch = 'Không lấy được danh sách xe: {message}',
        Empty = 'Không có xe.',
        Plate = 'Biển số: {plate}',
        UnknownPlate = 'UNKNOWN',
        DefaultLabel = 'Vehicle',
        ImageAlt = 'vehicle',
    },

    Chart = {
        Title = 'BIỂU ĐỒ DÒNG TIỀN',
        Loading = 'Đang tải biểu đồ...',
        Error = 'Lỗi khi tải biểu đồ.',
        ErrorFetch = 'Không lấy được dữ liệu biểu đồ: {message}',
        TotalLabel = 'Tổng',
        NoData = 'Không có dữ liệu.',
        Start = 'Đầu: {value}',
        End = 'Cuối: {value}',
        Min = 'Min: {value}',
        Max = 'Max: {value}',
        Diff = 'Chênh (Cuối-Đầu): {value}',
        SelectedPoint = 'Điểm chọn: #{index}',
        Time = 'Thời gian: {value}',
        Value = 'Giá trị: {value}',
        DiffPrev = 'Chênh vs điểm trước: {value}',
        DiffNext = 'Chênh tới điểm sau: {value}',
    },

    Log = {
        Title = 'NHẬT KÝ HÀNH ĐỘNG',
        Empty = 'Không có log.',
        Loading = 'Đang tải log...',
        Error = 'Lỗi khi tải log.',
        ErrorFetch = 'Không lấy được log: {message}',
        Headers = {
            Time = 'Thời gian',
            Action = 'Hành động',
            MoneyDiff = 'Chênh lệch tiền',
        },
        NoStoreKeysChange = 'Không có thay đổi theo StoreKeys.',
        TotalKey = 'total',
    },

    Image = {
        Title = 'HÌNH ẢNH',
        Error = 'Không tải được ảnh.',
    },

    Suspicious = {
        Title = 'NGHI VẤN DÒNG TIỀN',
        Title2 = 'NGHI VẤN 2',
        Count = '({count} nghi vấn)',
        Loading = 'Đang tải nghi vấn...',
        Error = 'Lỗi khi tải nghi vấn.',
        ErrorMoney = 'Không lấy được dữ liệu tiền: {message}',
        Empty = 'Không có nghi vấn trong khoảng thời gian này.',
        Headers = {
            Time = 'Thời gian',
            Point = 'Điểm chọn',
            Diff = 'Chênh lệch',
            Detail = 'Chi tiết + Log',
        },
        BeforeAfter = 'Trước: {before} → Sau: {after} | Chênh: {sign}{diff}',
        DetailText = 'Chi tiết: {value}',
        Snapshot = 'Snapshot: {value}',
        LogText = 'Log: {action} • {value}',
        LogEmpty = 'Log: (không có log gần mốc này)',
        StreakSummary = 'Chuỗi: {count} lần / ~{minutes} phút | {details}',
    },
} 

Config.Inventory = { -- Cấu hình hiển thị ảnh item/quần áo khi xem inventory (ox_inventory items/clothes)
    ImageBaseUrl = 'nui://ox_inventory/web/images', 
    VehicleImageBaseUrl = 'https://gta5root.top/fivem/cars/', -- Base URL để ghép ra link ảnh xe 
    ImageExt = '.png', 
    UseItemLabelFallback = true, 

    ClothesImageBaseUrl = 'https://gta5root.top/fivem/items101', 
    LegacyClothesImageBaseUrl = 'https://gta5root.top/fivem/items101', 

    ClickNameToOpenModal = true, -- Click vào tên người chơi trên bảng sẽ mở modal chi tiết (inventory)
}

Config.NUI = { -- Cấu hình auto refresh UI (NUI) phía client
    AutoRefresh = false, -- Bật/tắt tự refresh leaderboard theo chu kỳ
    RefreshSeconds = 15, -- Chu kỳ refresh (giây) nếu AutoRefresh = true
} 