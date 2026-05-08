Config = {}

Config.Framework = 'qbx'

Config.OpenMethod = 'npc'

Config.Command = 'jobcenter'

Config.Target = 'ox_target'

Config.PedModel = 'a_m_y_business_03'
Config.PedCoords = vector4(564.56, -1770.79, 28.36, 329.63)
Config.PedScenario = 'WORLD_HUMAN_CLIPBOARD'

Config.Title = 'Giới Thiệu Việc Làm'

Config.Jobs = {
    ['fisherman'] = {
        setJob = false,
        title = 'Câu Cá',
        image = 'images/fisherman.png',
        description = 'Rèn luyện tay nghề để câu được những loài cá quý hiếm và giá trị cao.',
        color = '05f2f2b3',
        coords = vector3(-1809.71, -1208.17, 14.30),
        guide = 'https://www.youtube.com/watch?v=Z5bbJe2EOQY',

    },
    ['recycle'] = {
        setJob = false,
        title = 'Tái Chế',
        image = 'images/recycle.png',
        description = 'Thu gom và tái chế phế liệu để kiếm thêm thu nhập và nguyên liệu.',
        color = '05f2f2b3',
        coords = vector3(-321.85, -1545.75, 31.02),
        guide = 'https://www.youtube.com/watch?v=YCtwz1uxprQ',
    },
    ['hunting'] = {
        setJob = false,
        title = 'Săn Bắn',
        image = 'images/hunting.png',
        description = 'Săn thú rừng để lấy thịt và da đem bán kiếm tiền.',
        color = '05f2f2b3',
        coords = vector3(-679.10, 5834.43, 17.33),
        guide = 'https://www.youtube.com/watch?v=fb24Se_gVS8',
    },
    ['trucking'] = {
        setJob = false,
        title = 'Giao Hàng',
        image = 'images/delivery.png',
        description = 'Nhận đơn và giao hàng khắp thành phố để nhận tiền thưởng.',
        color = '05f2f2b3',
        coords = vector3(-1146.02, -2180.02, 13.38),
        guide = 'https://www.youtube.com/watch?v=IzUUGHHYbss',
    },
    ['cotton'] = {
        setJob = false,
        title = 'Hái Bông',
        image = 'images/cotton.png',
        description = 'Thu hoạch cotton để bán hoặc dùng cho chế tạo.',
        color = '05f2f2b3',
        coords = vector3(2489.61, 4367.26, 36.48),
        guide = 'https://www.youtube.com/watch?v=X8AtZMige_4',
    },
    ['lumberjack'] = {
        setJob = false,
        title = 'Làm Gỗ',
        image = 'images/lumber.png',
        description = 'Chặt cây và chế biến gỗ để bán kiếm thu nhập.',
        color = '05f2f2b3',
        coords = vector3(-580.10, 5369.02, 70.34),
        guide = 'https://www.youtube.com/watch?v=X8AtZMige_4',
    },
    -- ['newspaper'] = {
    --     setJob = false,
    --     title = 'Giao Báo',
    --     image = 'images/newsdelivery.png',
    --     description = 'Công việc đơn giản với mức lương ổn định cho người mới.',
    --     color = '05f2f2b3',
    --     coords = vector3(-607.01, -926.74, 23.86),
    --     guide = 'https://www.youtube.com/watch?v=X8AtZMige_4',
    -- },
    ['cutpaper'] = {
        setJob = false,
        title = 'Công Nhân Nhà Máy Giấy',
        image = 'images/cutpaper.png',
        description = 'Công việc có mức lương thấp nhưng cực kỳ nhàn hạ, không cần làm gì cả.',
        color = '05f2f2b3',
        coords = vector3(757.32, -918.83, 25.27),
        guide = 'https://www.youtube.com/watch?v=THzoWf-mZBo',
    },
}

Config.JobCenterBlip = {
    enable = true,
    sprite = 351,
    color = 5,
    scale = 0.8,
}

Config.UpdateChecker = false