---Job names must be lower case (top level table key)
---@type table<string, Job>
return {
    ['unemployed'] = {
        label = 'Thất Nghiệp',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Tự Do',
                payment = 200
            },
        },
    },
    ['police'] = {
        label = 'LSPD',
        type = 'leo',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Cadet',
                payment = 2000
            },
            [1] = {
                name = 'Solo Cadet',
                payment = 2500
            },
            [2] = {
                name = 'Officer',
                payment = 3200
            },
            [3] = {
                name = 'Senior Officer',
                payment = 3500
            },
            [4] = {
                name = 'Corporal',
                payment = 3800
            },
            [5] = {
                name = 'Sergeant',
                payment = 4000
            },
            [6] = {
                name = 'Lieutenant',
                payment = 4200
            },
            [7] = {
                name = 'Captain',
                payment = 4500
            },
            [8] = {
                name = 'Commander',
                payment = 4800
            },
            [9] = {
                name = 'Deputy Chief',
                payment = 5000
            },
            [10] = {
                name = 'Assistant Chief',
                isboss = true,
                payment = 5200
            },
            [11] = {
                name = 'Chief',
                isboss = true,
                bankAuth = true,
                payment = 5500
            },
        },
    },
    ['bcso'] = {
        label = 'BCSO',
        type = 'leo',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Cadet',
                payment = 2000
            },
            [1] = {
                name = 'Solo Cadet',
                payment = 2500
            },
            [2] = {
                name = 'Deputy',
                payment = 3200
            },
            [3] = {
                name = 'Senior Deputy',
                payment = 3500
            },
            [4] = {
                name = 'Corporal',
                payment = 3700
            },
            [5] = {
                name = 'Sergeant',
                payment = 4000
            },
            [6] = {
                name = 'Lieutenant',
                payment = 4200
            },
            [7] = {
                name = 'Captain',
                payment = 4500
            },
            [8] = {
                name = 'Commander',
                payment = 4800
            },
            [9] = {
                name = 'Chief Deputy',
                payment = 5000
            },
            [10] = {
                name = 'Undersheriff',
                isboss = true,
                payment = 5200
            },
            [11] = {
                name = 'Sheriff',
                isboss = true,
                bankAuth = true,
                payment = 5500
            },
        },
    },
    -- ['sasp'] = {
    --     label = 'SASP',
    --     type = 'leo',
    --     defaultDuty = true,
    --     offDutyPay = false,
    --     grades = {
    --         [0] = {
    --             name = 'Trooper',
    --             payment = 100
    --         },
    --         [1] = {
    --             name = 'Sergeant',
    --             payment = 150
    --         },
    --         [2] = {
    --             name = 'Lieutenant',
    --             payment = 200
    --         },
    --         [3] = {
    --             name = 'Captain',
    --             payment = 250
    --         },
    --         [4] = {
    --             name = 'Assistant Chief',
    --             payment = 300
    --         },
    --         [5] = {
    --             name = 'Chief',
    --             payment = 350
    --         },
    --         [6] = {
    --             name = 'Assistant Commissioner',
    --             isboss = true,
    --             bankAuth = true,
    --             payment = 400
    --         },
    --         [7] = {
    --             name = 'Deputy Commissioner',
    --             isboss = true,
    --             bankAuth = true,
    --             payment = 400
    --         },
    --         [8] = {
    --             name = 'Commissioner',
    --             isboss = true,
    --             bankAuth = true,
    --             payment = 400
    --         },
    --     },
    -- },
    ['ambulance'] = {
        label = 'EMS',
        type = 'ems',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Thực Tập',
                payment = 2500
            },
            [1] = {
                name = 'Bác Sĩ',
                payment = 3200
            },
            [2] = {
                name = 'Quản Lý Khoa',
                payment = 3500
            },
            [3] = {
                name = 'Phó Viện Trưởng',
                isboss = true,
                payment = 3800
            },
            [4] = {
                name = 'Viện Trưởng',
                isboss = true,
                bankAuth = true,
                payment = 4000
            },
        },
    },
    ['cardealer'] = {
        label = 'Vehicle Dealer',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Thử Việc',
                payment = 2700
            },
            [1] = {
                name = 'Nhân Viên Chính Thức',
                payment = 3200
            },
            [2] = {
                name = 'Quản Lý',
                payment = 3500
            },
            [3] = {
                name = 'Phó Giám Đốc',
                payment = 4000
            },
            [4] = {
                name = 'Giám Đốc',
                isboss = true,
                bankAuth = true,
                payment = 5000
            },
        },
    },
    ['mechanic'] = {
        label = 'Mechanic',
        type = 'mechanic',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Thử Việc',
                payment = 200
            },
            [1] = {
                name = 'Thợ Sửa',
                payment = 200
            },
            [2] = {
                name = 'Quản Lý',
                payment = 200
            },
            [3] = {
                name = 'Phó Giám Đốc',
                payment = 200
            },
            [4] = {
                name = 'Giám Đốc',
                isboss = true,
                bankAuth = true,
                payment = 200
            },
        },
    },
}