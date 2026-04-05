Config = {}

Config.Framework = 'qbcore'

Config.AdminGroups = { 'admin', 'superadmin' }

Config.Cooldown = 30

Config.Donate = {
    minAmount = 10000,
    maxAmount = 50000000,
    currency = 'VND'
}

Config.Payment = {
    banks = {
        -- {
        --     id          = 'tcb',
        --     label       = 'Luis - Giờ Sáng',
        --     bankId      = 'TCB',
        --     bankName    = 'Techcombank',
        --     accountNumber = '19034801880013',
        --     accountName = 'DIEP THIEN TUAN',
        --     enabled     = true
        -- },
        {
            id          = 'momo',
            label       = 'MOMO',
            bankId      = 'momo',
            bankName    = 'MOMO',
            accountNumber = 'PSG2609510400000007',
            accountName = 'Nguyen Dang Dang Nhut',
            enabled     = true
        },
        -- {
        --     id          = 'tcb2',
        --     label       = 'TommyNguyenx - Giờ Khuya',
        --     bankId      = 'TCB',
        --     bankName    = 'Techcombank',
        --     accountNumber = '234567290804',
        --     accountName = 'NGUYEN DANG DANG NHUT',
        --     enabled     = true
        -- },
    }
}

Config.QR = {
    enabled = true,
    baseUrl = 'https://img.vietqr.io/image/'
}

Config.Rewards = {
    enabled = true,
    type    = 'coin',
    ratio   = 0.001
}

Config.RadialMenu = {
    enabled = true
}