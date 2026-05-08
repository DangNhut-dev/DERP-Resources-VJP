cfg = {}

cfg.framework = {
    name = 'auto',                       -- Only esx, qb, standalone or auto. If auto, it will detect the framework automatically.
    targetScript = 'ox_target',          -- Target script name (default or qb-target or ox_target)
    useOxNotify = true,                  -- Use ox_lib instead of ESX.ShowNotification or QBCore.Functions.Notify
    debug = false,                        -- Bật log debug (kiểm tra identifier được resolve OK rồi thì set false)
}

cfg.options = {
    youtubeApiKey = "AIzaSyAKOQzVTeBVxqjO7rClrqkvD0Kmb_wc8RE", -- Youtube API key
    serverBoomboxLimit = 4, -- How many boomboxes can be placed at the same time (for all server)
    individualBoomboxLimit = 2, -- How many boomboxes can be placed by one player at the same time
    createBoomboxCommand = "createboombox", -- Command to create a boombox (for standalone framework)
    streamerModeCommand = "streamermode", -- Command for streamers
    removeBoomboxCommand = "removeboombox", -- Command to remove a boombox (for standalone framework)
    interactAllPlayers = false, -- Allow all players to interact with the boomboxes (If false, owner can grant interact at will)
    enableMultipleBoomboxes = false, -- If set to true, multiple boomboxes can be placed in the same zone. If set to false, a second boombox cannot be placed within the radius of an existing one.
    staffList = { -- to remove the boombox by staffs
        ["steam:110000"] = true
    },
    userList = { -- If the table is not empty, only the people you specify can use the boombox.
        --["steam:110000"] = true
    },
    blacklistZones = { --> vector4(x, y, z, radius)
        --vector4(325.0, -212.74, 54.09, 60.0)
    }
}

cfg.webConfig = {
    colors = {
        player = {
            background = "#202128",
            backgroundLight = "#41464c",
            buttonBackground = "#202128",
            text = "#ffffff",
            volume = "#f15d38",
            pause = "#ffba8f7f",
            pauseText = "#ffba8f",
            loop = "#459fff7f",
            loopText = "#93c7ff",
        },
        input = {
            background = "#202128",
            buttonBackground = "#41464c",
            text = "#ffffff",
        },
        queue = {
            background = "#202128",
            backgroundLight = "#41464c",
            text = "#ffffff",
        }
    },
    locales = {
        ["title"] = "Nhập URL YouTube",
        ["description"] = "Vui lòng cung cấp một liên kết YouTube hợp lệ để bắt đầu phát.",
        ["input_placeholder"] = "ví dụ, https://youtu.be/H58vbez_m4E",
        ["play"] = "Bắt đầu Phát",
        ["invalid_url"] = "URL không hợp lệ",
    }
}

cfg.boomboxes = {
    ["boombox_white_large"] = {
        propModel = "dtsm_speaker_1_white",
        shouldRemoveItem = true, -- Remove the item from the inventory when placing the boombox
        radius = 60.0, -- Size of the area where the sound is audible.
        maxVolume = 1.0, -- Maximum volume the boombox can output
        canPutHand = false, -- can put your hand
        canPutVehicle = false, -- can put on vehicle
        handOffset = vector3(0.6, 0.0, 0.2), -- offset in the boombox your hand
        handRotation = vector3(0.0, 250.0, 140.0) -- rotation in the boombox your hand
    },
    ["boombox_red_large"] = {
        propModel = "dtsm_speaker_1_red",
        shouldRemoveItem = true,
        radius = 60.0,
        maxVolume = 1.0,
        canPutHand = false,
        canPutVehicle = false,
        handOffset = vector3(0.6, 0.0, 0.2),
        handRotation = vector3(0.0, 250.0, 140.0)
    },
    ["boombox_purple_large"] = {
        propModel = "dtsm_speaker_1_purple",
        shouldRemoveItem = true,
        radius = 60.0,
        maxVolume = 1.0,
        canPutHand = false,
        canPutVehicle = false,
        handOffset = vector3(0.6, 0.0, 0.2),
        handRotation = vector3(0.0, 250.0, 140.0)
    },
    ["boombox_pink_large"] = {
        propModel = "dtsm_speaker_1_pink",
        shouldRemoveItem = true,
        radius = 60.0,
        maxVolume = 1.0,
        canPutHand = false,
        canPutVehicle = false,
        handOffset = vector3(0.6, 0.0, 0.2),
        handRotation = vector3(0.0, 250.0, 140.0)
    },
    ["boombox_orange_large"] = {
        propModel = "dtsm_speaker_1_orange",
        shouldRemoveItem = true,
        radius = 60.0,
        maxVolume = 1.0,
        canPutHand = false,
        canPutVehicle = false,
        handOffset = vector3(0.6, 0.0, 0.2),
        handRotation = vector3(0.0, 250.0, 140.0)
    },
    ["boombox_green_large"] = {
        propModel = "dtsm_speaker_1_green",
        shouldRemoveItem = true,
        radius = 60.0,
        maxVolume = 1.0,
        canPutHand = false,
        canPutVehicle = false,
        handOffset = vector3(0.6, 0.0, 0.2),
        handRotation = vector3(0.0, 250.0, 140.0)
    },
    ["boombox_blue_large"] = {
        propModel = "dtsm_speaker_1_blue",
        shouldRemoveItem = true,
        radius = 60.0,
        maxVolume = 1.0,
        canPutHand = false,
        canPutVehicle = false,
        handOffset = vector3(0.6, 0.0, 0.2),
        handRotation = vector3(0.0, 250.0, 140.0)
    },

    ["boombox_white_medium"] = {
        propModel = "dtsm_speaker_2_white",
        shouldRemoveItem = true,
        radius = 50.0,
        maxVolume = 1.0,
        canPutHand = true,
        canPutVehicle = true,
        handOffset = vector3(0.6, 0.0, 0.2),
        handRotation = vector3(0.0, 250.0, 140.0)
    },
    ["boombox_red_medium"] = {
        propModel = "dtsm_speaker_2_red",
        shouldRemoveItem = true,
        radius = 50.0,
        maxVolume = 1.0,
        canPutHand = true,
        canPutVehicle = true,
        handOffset = vector3(0.6, 0.0, 0.2),
        handRotation = vector3(0.0, 250.0, 140.0)
    },
    ["boombox_purple_medium"] = {
        propModel = "dtsm_speaker_2_purple",
        shouldRemoveItem = true,
        radius = 50.0,
        maxVolume = 1.0,
        canPutHand = true,
        canPutVehicle = true,
        handOffset = vector3(0.6, 0.0, 0.2),
        handRotation = vector3(0.0, 250.0, 140.0)
    },
    ["boombox_pink_medium"] = {
        propModel = "dtsm_speaker_2_pink",
        shouldRemoveItem = true,
        radius = 50.0,
        maxVolume = 1.0,
        canPutHand = true,
        canPutVehicle = true,
        handOffset = vector3(0.6, 0.0, 0.2),
        handRotation = vector3(0.0, 250.0, 140.0)
    },
    ["boombox_orange_medium"] = {
        propModel = "dtsm_speaker_2_orange",
        shouldRemoveItem = true,
        radius = 50.0,
        maxVolume = 1.0,
        canPutHand = true,
        canPutVehicle = true,
        handOffset = vector3(0.6, 0.0, 0.2),
        handRotation = vector3(0.0, 250.0, 140.0)
    },
    ["boombox_green_medium"] = {
        propModel = "dtsm_speaker_2_green",
        shouldRemoveItem = true,
        radius = 50.0,
        maxVolume = 1.0,
        canPutHand = true,
        canPutVehicle = true,
        handOffset = vector3(0.6, 0.0, 0.2),
        handRotation = vector3(0.0, 250.0, 140.0)
    },
    ["boombox_blue_medium"] = {
        propModel = "dtsm_speaker_2_blue",
        shouldRemoveItem = true,
        radius = 50.0,
        maxVolume = 1.0,
        canPutHand = true,
        canPutVehicle = true,
        handOffset = vector3(0.6, 0.0, 0.2),
        handRotation = vector3(0.0, 250.0, 140.0)
    },
    
    ["boombox_white_small"] = {
        propModel = "dtsm_speaker_3_white",
        shouldRemoveItem = true,
        radius = 20.0,
        maxVolume = 0.5,
        canPutHand = true,
        canPutVehicle = true,
        handOffset = vector3(0.5, 0.0, 0.2),
        handRotation = vector3(-40.0, 250.0, 140.0)
    },
    ["boombox_red_small"] = {
        propModel = "dtsm_speaker_3_red",
        shouldRemoveItem = true,
        radius = 20.0,
        maxVolume = 0.5,
        canPutHand = true,
        canPutVehicle = true,
        handOffset = vector3(0.5, 0.0, 0.2),
        handRotation = vector3(-40.0, 250.0, 140.0)
    },
    ["boombox_purple_small"] = {
        propModel = "dtsm_speaker_3_purple",
        shouldRemoveItem = true,
        radius = 20.0,
        maxVolume = 0.5,
        canPutHand = true,
        canPutVehicle = true,
        handOffset = vector3(0.5, 0.0, 0.2),
        handRotation = vector3(-40.0, 250.0, 140.0)
    },
    ["boombox_pink_small"] = {
        propModel = "dtsm_speaker_3_pink",
        shouldRemoveItem = true,
        radius = 20.0,
        maxVolume = 0.5,
        canPutHand = true,
        canPutVehicle = true,
        handOffset = vector3(0.5, 0.0, 0.2),
        handRotation = vector3(-40.0, 250.0, 140.0)
    },
    ["boombox_orange_small"] = {
        propModel = "dtsm_speaker_3_orange",
        shouldRemoveItem = true,
        radius = 20.0,
        maxVolume = 0.5,
        canPutHand = true,
        canPutVehicle = true,
        handOffset = vector3(0.5, 0.0, 0.2),
        handRotation = vector3(-40.0, 250.0, 140.0)
    },
    ["boombox_green_small"] = {
        propModel = "dtsm_speaker_3_green",
        shouldRemoveItem = true,
        radius = 20.0,
        maxVolume = 0.5,
        canPutHand = true,
        canPutVehicle = true,
        handOffset = vector3(0.5, 0.0, 0.2),
        handRotation = vector3(-40.0, 250.0, 140.0)
    },
    ["boombox_blue_small"] = {
        propModel = "dtsm_speaker_3_blue",
        shouldRemoveItem = true,
        radius = 20.0,
        maxVolume = 0.5,
        canPutHand = true,
        canPutVehicle = true,
        handOffset = vector3(0.5, 0.0, 0.2),
        handRotation = vector3(-40.0, 250.0, 140.0)
    },
}

cfg.vehicleOffsets = { -- If you want to enter offset for vehicles (optional)
    [`jester`] = {
        vehicleOffset = vector3(0.0, 0.0, 0.9),
        vehicleRotation = vector3(0.0, 0.0, 0.0),
        trunkOffset = vector3(0.0, 0.0, 0.0),
        trunkRotation = vector3(0.0, 0.0, 0.0),
    },
}

cfg.keybinds = {
    uiKeybinds = {
        ["fullscreen"] = {
            keyText = "F",
            text = "Fullscreen",
            key = 23,
            order = 1,
        },
        ["pause"] = {
            keyText = "E",
            text = "Pause",
            key = 38,
            order = 2,
        },
        ["loop"] = {
            keyText = "L",
            text = "Loop",
            key = 182,
            order = 3,
        },
        ["b_seek"] = {
            keyText = "<",
            text = "-15s",
            duration = -15,
            key = 174,
            order = 5,
        },
        ["f_seek"] = {
            keyText = ">",
            text = "+15s",
            duration = 15,
            key = 175,
            order = 4,
        },
        ["skip"] = {
            keyText = "G",
            text = "Skip",
            key = 47,
            order = 6,
        },
        ["volume_up"] = {
            keyText = "↑",
            text = "Volume Up",
            key = 172,
            order = 7,
        },
        ["volume_down"] = {
            keyText = "↓",
            text = "Volume Down",
            key = 173,
            order = 8,
        },
        ["hide_ui"] = {
            keyText = "H",
            text = "Hide UI",
            key = 74,
            order = 9,
        }
    },
    actionKeys = {
        takeInHand = 38, -- for take the boombox in hand
        putDown = 38, -- for put down the boombox
        placeInVehicle = 47, -- for place the boombox in the vehicle
        placeInTrunk = 74, -- for place the boombox in the trunk
        placeBoombox = 191, -- for place the boombox
        cancelAction = 194, -- for cancel the action
        boomboxMenu = 288, -- for open the boombox menu (for STANDALONE FRAMEWORK)
    },

}

Strings = {
    ["cant_use_boombox"] = "Bạn không thể sử dụng hộp nhạc.",
    ["boombox_only_use_vip_members"] = "Bạn không được phép sử dụng hộp nhạc.",
    ["dont_have_boombox"] = "Bạn không có hộp nhạc!",
    ["boombox_cant_place_zone"] = "Không thể đặt hộp nhạc ở khu vực này.",
    ["boombox_vehicle_trunk_open"] = "Để đặt hộp nhạc vào cốp xe, bạn phải mở cốp.",
    ["streamer_mod_enabled"] = "Chế độ dành cho streamer đã được bật.",
    ["streamer_mod_disabled"] = "Chế độ dành cho streamer đã được tắt.",
    ["dont_have_permission"] = "Bạn không có quyền sử dụng lệnh này.",
    ["api_key_not_found"] = "Không tìm thấy khóa API của Youtube.",
    ["boombox_server_limit"] = "Bạn không thể thêm hộp nhạc nữa vì máy chủ đã đạt giới hạn hộp nhạc.",
    ["boombox_individual_limit"] = "Bạn không thể thêm hộp nhạc nữa vì bạn đã đạt giới hạn hộp nhạc cá nhân.",
    ["no_nearby_vehicle"] = "Không tìm thấy xe ở gần.",
    ["boombox_target_label"] = "Sử dụng Hộp nhạc",
    ["enter_url"] = "Nhập URL",
    ["enter_url_desc"] = "Phát nhạc mới hoặc thêm vào hàng đợi!",
    ["remove_boombox"] = "Gỡ Hộp nhạc",
    ["remove_boombox_desc"] = "Chán nghe nhạc rồi à?",
    ["boombox_take_in_hand"] = "Cầm trên tay",
    ["boombox_hand_action"] = "[E] - Đặt hộp nhạc xuống \n[G] - Đặt hộp nhạc vào xe \n[H] - Đặt hộp nhạc vào cốp xe",
    ["boombox_vehicle_action"] = "Nhấn phím [E] để lấy hộp nhạc ra tay.",
    ["boombox_place_action"] = "[Enter] - Đặt Hộp nhạc \n[Backspace] - Hủy",
    ["invalid_boombox"] = "Bạn đã nhập tên không hợp lệ cho hộp nhạc!",
    ["boombox_menu_action"] = "[F1] - Sử dụng Hộp nhạc", -- dành cho framework độc lập
    ["take_in_hand"] = "Cầm trên tay",
    ["take_in_hand_desc"] = "Nhặt hộp nhạc lên!",
}
