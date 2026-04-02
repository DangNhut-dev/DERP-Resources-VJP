Config = {}

-- Banking System Selection
Config.BankingSystem = "Renewed-Banking"  -- Options: "dw-banking", "qb-banking", "renewed-banking"

-- Target Sysytem Selection
Config.TargetSystem = "ox_target"  -- Options: "qb-target", "ox_target"

-- Job Application System Settings
Config.EnableApplicationSystem = true  -- Set to false to disable job application system


-- Management access locations
Config.Locations = {
    ["police"] = {
        label = "Police Department",
        logoImage = "police.png",
        locations = {
            {
                coords = vec3(92.98, -397.77, 47.83), -- Main Police Station
                width = 1.0,
                length = 1.0,
                heading = 0,
                minZ = 30.0,
                maxZ = 31.0,
            },
            -- {
            --     coords = vector3(1853.82, 3689.82, 34.27), -- Sandy Shores Sheriff
            --     width = 1.0,
            --     length = 1.0,
            --     heading = 0,
            --     minZ = 34.0,
            --     maxZ = 35.0,
            -- }
        }
    },
    ["ambulance"] = {
        label = "EMS",
        logoImage = "ems.png",
        locations = {
            {
                coords = vector3(-485.13, -1003.51, 33.49), -- Main Hospital
                width = 1.0,
                length = 1.0,
                heading = 0,
                minZ = 43.0,
                maxZ = 44.0,
            },
            -- {
            --     coords = vector3(1839.32, 3673.26, 34.28), -- Sandy Shores Hospital
            --     width = 1.0,
            --     length = 1.0,
            --     heading = 0,
            --     minZ = 34.0,
            --     maxZ = 35.0,
            -- }
        }
    },
    ["mechanic"] = {
        label = "Sửa Xe",
        logoImage = "mechanic.png",
        locations = {
            {
                coords = vector3(-350.63, -126.93, 42.98), -- Mechanic Shop
                width = 1.0,
                length = 1.0,
                heading = 0,
                minZ = 25.0,
                maxZ = 26.0,
            }
        }
    },
    ["cardealer"] = {
        label = "Cardealer",
        logoImage = "cardealer.png",
        locations = {
            {
                coords = vector3(-53.52, 76.32, 75.41), -- Mechanic Shop
                width = 1.0,
                length = 1.0,
                heading = 0,
                minZ = 25.0,
                maxZ = 26.0,
            }
        }
    }
    -- Add more jobs as needed
}

Config.ApplicationPoints = {
    ["police"] = {
        coords = vec3(86.82, -402.27, 41.60),  -- Near the police station
        width = 1.5,
        length = 1.5,
        heading = 0,
        minZ = 30.0,
        maxZ = 31.0,
        label = "Nộp Đơn Xin Việc"
    },
    ["ambulance"] = {
        coords = vector3(-488.15, -986.33, 24.36),  -- Near the hospital
        width = 1.0,
        length = 1.0,
        heading = 0,
        minZ = 43.0,
        maxZ = 44.0,
        label = "Nộp Đơn Xin Việc"
    },
    -- ["mechanic"] = {
    --     coords = vector3(835.92, -912.54, 25.25),  -- Near the mechanic shop
    --     width = 1.0,
    --     length = 1.0,
    --     heading = 0,
    --     minZ = 25.0,
    --     maxZ = 26.0,
    --     label = "Mechanic Application"
    -- },
    -- Add more points as needed
}

-- Define application form questions (these will be shown in the application form)
Config.ApplicationQuestions = {
    ["police"] = {
        {
            question = "Why do you want to join the Police Department?",
            type = "text",
            required = true,
            min = 1,
            max = 1024
        },
        {
            question = "Bạn có bất kỳ kinh nghiệm nào trước đây trong lĩnh vực thực thi pháp luật không?",
            type = "select",
            options = {"Đã có", "Không có"},
            required = true
        },
        {
            question = "Bạn có kinh nghiệm làm Police chưa?",
            type = "number",
            required = false,
            min = 0,
            max = 50
        },
        {
            question = "Một tình huống xảy ra: Bạn đang tuần tra và thấy một người dân có hành vi đáng ngờ. Bạn sẽ làm gì?",
            type = "text",
            required = true,
            min = 1,
            max = 1024
        },
        {
            question = "Bạn có sẵn sàng làm việc theo ca và trong các điều kiện thời tiết khác nhau không?",
            type = "text",
            required = true,
            min = 1,
            max = 1024
        },
        {
            question = "Bạn có thể làm việc dưới áp lực cao và trong các tình huống khẩn cấp không?",
            type = "text",
            required = true,
            min = 1,
            max = 1024
        },
        {
            question = "Bạn có sẵn sàng tuân thủ các quy tắc và quy định của lực lượng Cảnh sát không?",
            type = "text",
            required = true,
            min = 1,
            max = 1024
        },
        {
            question = "Lực lượng bạn chọn",
            type = "select",
            options = {"LSPD", "BCSO"},
            required = true
        },
    }
}

-- Default settings
Config.DefaultSettings = {
    darkMode = true,
    showAnimations = true,
    compactView = false,
    notificationSound = "default",
    themeColor = "blue",
    refreshInterval = 60,
    showPlaytime = true,
    showLocation = true
}
