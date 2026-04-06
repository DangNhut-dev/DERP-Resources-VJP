Config = {
    proximityDistances = {
        vehicle  = 50.0,    -- Tầm xe
        handHeld = 30.0,    -- Tầm cầm tay
        stage    = 100.0,   -- Tầm mic sân khấu
    },

    -- Model mic sân khấu: https://forge.plebmasters.de/objects
    models = {
        `v_club_roc_micstd`,
        `prop_table_mic_01`
    },

    -- Vị trí microphone cố định (để trống nếu dùng model)
    microphoneLocations = {
        {
            coords  = vector3(64.26, -401.66, 47.50),
            heading = 159.72,
            label   = 'Microphone Sân khấu'
        },
    },

    targetOptions = {
        enabled  = true,
        distance = 2.0,
        icon     = 'fa-solid fa-microphone'
    },

    volume = -1.0,                  -- -1.0 = mặc định, 0.0 ~ 1.0 để override

    specifyVehicles = false,        -- true = dùng danh sách vehicles bên dưới
    vehicleClass    = { 18, 15 },   -- class xe được dùng (nếu specifyVehicles = false)
    vehicles        = { 'washington' }, -- tên xe (nếu specifyVehicles = true)

    keybind = 'LSHIFT',                -- Phím mặc định vehicle megaphone
    debug   = true,
}
