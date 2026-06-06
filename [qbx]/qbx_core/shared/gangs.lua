---Gang names must be lower case (top level table key)
---@type table<string, Gang>
return {
    ['none'] = {
        label = 'No Gang',
        grades = {
            [0] = {
                name = 'Unaffiliated'
            },
        },
    },
    ['dealer'] = {
        label = 'White Dealer', 
        grades = {
            [0] = {
                name = 'Prospect' -- Người mới
            },
            [1] = {
                name = 'Associate' -- Thành viên chính thức
            },
            [2] = {
                name = 'Dealer' -- Người đi giao dịch
            },
            [3] = {
                name = 'Alchemist' -- Nhà Khoa Học
            },
            [4] = {
                name = 'Broker' -- Trung gian, cấp cao hơn dealer
            },
            [5] = {
                name = 'Consigliere' -- Cố vấn
            },
            [6] = {
                name = 'High Table', -- Đầu não
                isboss = true,
                bankAuth = true
            },
        },
    },
    ['yamaguchi'] = {
        label = 'Yamaguchi Gumi', 
        grades = {
            [0] = {
                name = 'Phàm Nhân Vượt Ải' 
            },
            [1] = {
                name = 'Luyện Khí Ngư Đồ'
            },
            [2] = {
                name = 'Luyện Khí Đạo Tổ' 
            },
            [3] = {
                name = 'Nguyên Anh Ngư Tôn' 
            },
            [4] = {
                name = 'Thái Thượng Tông Chủ' ,
                isboss = true,
                bankAuth = true
            },
        },
    },
    -- ['ballas'] = {
    --     label = 'Ballas',
    --     grades = {
    --         [0] = {
    --             name = 'Recruit'
    --         },
    --         [1] = {
    --             name = 'Enforcer'
    --         },
    --         [2] = {
    --             name = 'Shot Caller'
    --         },
    --         [3] = {
    --             name = 'Boss',
    --             isboss = true,
    --             bankAuth = true
    --         },
    --     },
    -- },
    -- ['vagos'] = {
    --     label = 'Vagos',
    --     grades = {
    --         [0] = {
    --             name = 'Recruit'
    --         },
    --         [1] = {
    --             name = 'Enforcer'
    --         },
    --         [2] = {
    --             name = 'Shot Caller'
    --         },
    --         [3] = {
    --             name = 'Boss',
    --             isboss = true,
    --             bankAuth = true
    --         },
    --     },
    -- },
    -- ['cartel'] = {
    --     label = 'Cartel',
    --     grades = {
    --         [0] = {
    --             name = 'Recruit'
    --         },
    --         [1] = {
    --             name = 'Enforcer'
    --         },
    --         [2] = {
    --             name = 'Shot Caller'
    --         },
    --         [3] = {
    --             name = 'Boss',
    --             isboss = true,
    --             bankAuth = true
    --         },
    --     },
    -- },
    -- ['families'] = {
    --     label = 'Families',
    --     grades = {
    --         [0] = {
    --             name = 'Recruit'
    --         },
    --         [1] = {
    --             name = 'Enforcer'
    --         },
    --         [2] = {
    --             name = 'Shot Caller'
    --         },
    --         [3] = {
    --             name = 'Boss',
    --             isboss = true,
    --             bankAuth = true
    --         },
    --     },
    -- },
    -- ['triads'] = {
    --     label = 'Triads',
    --     grades = {
    --         [0] = {
    --             name = 'Recruit'
    --         },
    --         [1] = {
    --             name = 'Enforcer'
    --         },
    --         [2] = {
    --             name = 'Shot Caller'
    --         },
    --         [3] = {
    --             name = 'Boss',
    --             isboss = true,
    --             bankAuth = true
    --         },
    --     },
    -- }
}
