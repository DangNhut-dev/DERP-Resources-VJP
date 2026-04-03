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
                payment = 20
            },
        },
    },
    ['police'] = {
        label = 'LSPD',
        type = 'leo',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Cadet',
                payment = 50
            },
            [1] = {
                name = 'Solo Cadet',
                payment = 75
            },
            [2] = {
                name = 'Officer',
                payment = 100
            },
            [3] = {
                name = 'Senior Officer',
                payment = 125
            },
            [4] = {
                name = 'Corporal',
                payment = 150
            },
            [5] = {
                name = 'Sergeant',
                payment = 175
            },
            [6] = {
                name = 'Lieutenant',
                payment = 200
            },
            [7] = {
                name = 'Captain',
                payment = 225
            },
            [8] = {
                name = 'Commander',
                payment = 250
            },
            [9] = {
                name = 'Deputy Chief',
                payment = 275
            },
            [10] = {
                name = 'Assistant Chief',
                isboss = true,
                payment = 300
            },
            [11] = {
                name = 'Chief',
                isboss = true,
                bankAuth = true,
                payment = 300
            },
        },
    },
    ['bcso'] = {
        label = 'BCSO',
        type = 'leo',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Cadet',
                payment = 50
            },
            [1] = {
                name = 'Solo Cadet',
                payment = 75
            },
            [2] = {
                name = 'Deputy',
                payment = 100
            },
            [3] = {
                name = 'Senior Deputy',
                payment = 125
            },
            [4] = {
                name = 'Corporal',
                payment = 150
            },
            [5] = {
                name = 'Sergeant',
                payment = 175
            },
            [6] = {
                name = 'Lieutenant',
                payment = 200
            },
            [7] = {
                name = 'Captain',
                payment = 225
            },
            [8] = {
                name = 'Commander',
                payment = 250
            },
            [9] = {
                name = 'Chief Deputy',
                payment = 275
            },
            [10] = {
                name = 'Undersheriff',
                isboss = true,
                payment = 300
            },
            [11] = {
                name = 'Sheriff',
                isboss = true,
                bankAuth = true,
                payment = 300
            },
        },
    },
    ['sasp'] = {
        label = 'SASP',
        type = 'leo',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Trooper',
                payment = 100
            },
            [1] = {
                name = 'Sergeant',
                payment = 150
            },
            [2] = {
                name = 'Lieutenant',
                payment = 200
            },
            [3] = {
                name = 'Captain',
                payment = 250
            },
            [4] = {
                name = 'Assistant Chief',
                payment = 300
            },
            [5] = {
                name = 'Chief',
                payment = 350
            },
            [6] = {
                name = 'Assistant Commissioner',
                isboss = true,
                bankAuth = true,
                payment = 400
            },
            [7] = {
                name = 'Deputy Commissioner',
                isboss = true,
                bankAuth = true,
                payment = 400
            },
            [8] = {
                name = 'Commissioner',
                isboss = true,
                bankAuth = true,
                payment = 400
            },
        },
    },
    ['ambulance'] = {
        label = 'EMS',
        type = 'ems',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Thực Tập',
                payment = 50
            },
            [1] = {
                name = 'Bác Sĩ',
                payment = 75
            },
            [2] = {
                name = 'Quản Lý Khoa',
                payment = 100
            },
            [3] = {
                name = 'Phó Viện Trưởng',
                payment = 125
            },
            [4] = {
                name = 'Viện Trưởng',
                isboss = true,
                bankAuth = true,
                payment = 150
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
                payment = 50
            },
            [1] = {
                name = 'Nhân Viên Chính Thức',
                payment = 75
            },
            [2] = {
                name = 'Quản Lý',
                payment = 100
            },
            [3] = {
                name = 'Phó Giám Đốc',
                payment = 125
            },
            [4] = {
                name = 'Giám Đốc',
                isboss = true,
                bankAuth = true,
                payment = 150
            },
        },
    },
    ['mechanic'] = {
        label = 'Mechanic',
        type = 'mechanic',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Thử Việc',
                payment = 50
            },
            [1] = {
                name = 'Thợ Sửa',
                payment = 75
            },
            [2] = {
                name = 'Quản Lý',
                payment = 100
            },
            [3] = {
                name = 'Phó Giám Đốc',
                payment = 125
            },
            [4] = {
                name = 'Giám Đốc',
                isboss = true,
                bankAuth = true,
                payment = 150
            },
        },
    },
}