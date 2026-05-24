Config = {}
Config.UseTarget = true
Config.UseBuiltInNotifications = false

Config.RequiredItem = "none"                            -- Đặt tên item bất kỳ nếu muốn yêu cầu người chơi phải có item này trong túi đồ trước khi bắt đầu job
Config.RequireItemFromWholeTeam = true                  -- Nếu false thì chỉ host cần item, nếu true thì toàn bộ thành viên trong team đều phải có

Config.RequiredJob = "none"                             -- Đặt "none" nếu không muốn kiểm tra job. Nếu dùng target thì phải set tham số "job" trong mỗi export ở target.lua
Config.RequireJobAlsoForFriends = true                  -- Nếu false thì chỉ host cần đúng job, nếu true thì tất cả thành viên trong nhóm phải có Config.RequiredJob

Config.RequireOneFriendMinimum = false                  -- Đặt true nếu muốn bắt buộc người chơi phải tạo team (không cho chơi solo)

Config.letBossSplitReward = true                        -- Nếu true thì boss có thể chia % phần thưởng cho từng thành viên trong menu. Nếu false thì mọi người nhận bằng nhau. Chỉ khả dụng trong modern UI

Config.multiplyRewardWhileWorkingInGroup = true         -- Nếu false thì thưởng giữ nguyên (vd $1000/job). Nếu true thì thưởng nhân theo số thành viên. Ví dụ 4 người => $4000 (baseReward * partyCount)

Config.JobCooldown = 0 * 60 -- 10 * 60                  -- Thời gian chờ giữa các lần làm job (giây). 0 = không cooldown, ví dụ 10 * 60 = 10 phút

Config.ProgressBarOffset = "25px"                       -- Khoảng lệch (px) của thanh tiến trình trên màn hình
Config.ProgressBarAlign = "bottom-center"               -- Vị trí căn chỉnh của thanh tiến trình

Config.MainBucket = 0                                   -- ID bucket/dimension chính mà server đang sử dụng
Config.RequireGear = true                              -- Đặt false để cho phép vào job mà không cần trang bị gear
Config.LightToggleButton = 304                          -- Phím bật/tắt đèn trên đồ bảo hộ thợ mỏ (mặc định là phím H)

Config.SoundVolumeMultipler = 0.5                       -- Hệ số điều chỉnh âm lượng âm thanh
Config.MiningSpeed = {
    ["onBonus"] = 0.05,                                 -- Tốc độ đào khi đang có bonus
    ["normal"] = 0.025,                                 -- Tốc độ đào bình thường
}

Config.PenaltyAmount = 1000                             -- Tiền phạt khi team không xây dựng/hoàn thành đủ tất cả object yêu cầu
Config.OnePercentWorth = 100                            -- Số tiền thưởng cho mỗi 1% tiến độ. Hầm đào đầy đủ là 45m (tag: price, reward, money, cash)

Config.GiveOnlyOneItemFromTable = false                 -- Đặt true nếu mỗi lần đập tường chỉ nhận 1 item từ Config.ItemsWhileMining. Nếu true thì nên sắp xếp item từ hiếm → dễ

Config.ItemsWhileMining = {                             -- Danh sách item có thể nhận mỗi lần đập tường
    -- {
    --     chance = 1,                                   -- Tỉ lệ nhận item (0-100). 1 = 1%, 100 = 100%
    --     itemName = "steel",                           -- Tên item
    --     quantity = function(isOnBonus, src)            -- Bắt buộc là function
    --         return math.random(1, 5)                   -- Phải trả về số lượng. Ví dụ random từ 1 đến 5
    --     end,
    -- },
}

Config.RewardItemsToGive = {                            -- Danh sách item thưởng khi hoàn thành job
    -- {
    --     itemName = "water",                            -- Tên item
    --     chance = 100,                                  -- Tỉ lệ nhận (0-100)
    --     amountPerPercent = 1,                          -- Số lượng item nhận được cho mỗi 1% tiến độ
    --     minimumProgressPercent = 0,                    -- Tiến độ tối thiểu để bắt đầu có cơ hội nhận item
    -- },
}


Config.Clothes = {
    male = {
        ["mask"] = {clotheId = 0, variation = 0},
        ["arms"] = {clotheId = 44, variation = 0},
        ["pants"] = {clotheId = 38, variation = 1},
        ["bag"] = {clotheId = 0, variation = 0},
        ["shoes"] = {clotheId = 51, variation = 0},
        ["t-shirt"] = {clotheId = 15, variation = 1},
        ["torso"] = {clotheId = 65, variation = 1},
        ["decals"] = {clotheId = 0, variation = 0},
        ["kevlar"] = {clotheId = 0, variation = 0},
    },

    female = {
        ["mask"] = {clotheId = 0, variation = 0},
        ["arms"] = {clotheId = 49, variation = 0},
        ["pants"] = {clotheId = 38, variation = 1},
        ["bag"] = {clotheId = 0, variation = 0},
        ["shoes"] = {clotheId = 25, variation = 0},
        ["t-shirt"] = {clotheId = 15, variation = 1},
        ["torso"] = {clotheId = 59, variation = 1},
        ["decals"] = {clotheId = 0, variation = 0},
        ["kevlar"] = {clotheId = 0, variation = 0},
    },
}

Config.RestrictBlipToRequiredJob = false -- Set to true, to hide job blip for players, who dont have RequiredJob. If requried job is "none", then this option will not have any effect.
Config.Blips = { -- Here you can configure Company blip.
    [1] = {
        Sprite = 124,
        Color = 26,
        Scale = 0.8,
        Pos = vector3(2445.14, 1532.14, 39.89),
        Label = 'Khu Đào Mỏ'
    },
}

Config.Locations = { -- Here u can change all of the base job locations.
    DutyToggle = {
        Coords = {
            vector3(2443.58, 1541.47, 39.89)
        },
        CurrentAction = 'open_dutyToggle',
        CurrentActionMsg = 'Nhấn ~g~[E]~s~ để ~y~bắt đầu/kết thúc~s~ công việc.',
        type = 'duty',
        scale = {x = 1.0, y = 1.0, z = 1.0},
    },
}

Config.ChangeClothesCoordinates = vector3(2424.52, 1544.29, 39.89)
Config.GrabGearCoordinates = vector3(2434.06, 1521.99, 39.89)
Config.DeadCoords = vector3(2428.15, 1531.82, -32.75)

Config.Lang = {
    -- Client
    ["no_permission"] = "Chỉ trưởng nhóm mới có thể thực hiện thao tác này!",
    ["keybind"] = 'Tương Tác Công Việc Thợ Mỏ',
    ["too_far"] = "Nhóm của bạn đã bắt đầu công việc, nhưng bạn đang ở quá xa trụ sở",
    ["kicked"] = "Bạn đã đá %s ra khỏi nhóm",
    ["alreadyWorking"] = "Trước tiên, hãy hoàn thành công việc trước đó",
    ["quit"] = "Bạn đã rời khỏi Nhóm",
    ["nobodyNearby"] = "Không có ai xung quanh",
    ["cantInvite"] = "Để mời thêm người, bạn cần hoàn thành công việc trước",
    ["inviteSent"] = "Đã gửi lời mời!",
    ["partyIsFull"] = "Không thể gửi lời mời, nhóm của bạn đã đầy",
    ["wrongReward1"] = "Phần trăm thưởng phải nằm trong khoảng từ 0 đến 100",
    ["wrongReward2"] = "Tổng phần trăm thưởng vượt quá 100%",
    ["cantLeaveLobby"] = "Bạn không thể rời lobby khi đang làm việc. Hãy kết thúc công việc trước.",
    ["endJobHint"] = "Nhấn ~INPUT_CONTEXT~ để ~y~kết thúc~s~ công việc.",
    ["openDoors"] = "Nhấn ~INPUT_CONTEXT~ để mở cửa",
    ["goDown"] = "Nhấn ~INPUT_CONTEXT~ để xuống hầm mỏ",
    ["goBack"] = "Nhấn ~INPUT_CONTEXT~ để quay lại và kết thúc công việc",
    ["startMining"] = "~b~[E] |~s~ Bắt Đầu Đào",
    ["mouseForMine"] = "Giữ ~INPUT_SKIP_CUTSCENE~ để đào",
    ["maximum"] = "Bạn đã đào hết đường hầm. Hãy lên thang máy để nhận thưởng",
    ["firstFinishBuilding"] = "Trước tiên hãy xây dựng đường ray, giá đỡ và đèn trước khi tiếp tục đào",
    ["pickUp"] = "Nhấn ~INPUT_CONTEXT~ để nhặt",
    ["takeRails"] = "Đến kho lấy đường ray",
    ["placeProp"] = "Nhấn ~INPUT_CONTEXT~ để đặt",
    ["placePropBack"] = "Nhấn ~INPUT_CONTEXT~ để cất vật phẩm",
    ["minecartBusy"] = "Xe goòng đang bận, đợi dỡ hàng và tiếp tục đào.",
    ["startingTutorial"] = "Chào mừng đến với công việc thợ mỏ. Nhiệm vụ của bạn là đào đường hầm ở tầng -1. Trước khi bắt đầu làm việc, hãy mặc đồng phục công ty và lấy trang bị. Bạn có thể làm điều này ở Phòng Kho và Phòng Thay Đồ. Khi đang trực ca, bạn cũng có thể sử dụng khu vực ăn uống dành cho thợ mỏ trên gác lửng. Hãy mặc đồ, bước vào thang máy, và thông tin chi tiết sẽ chờ đợi bạn trong hầm mỏ",
    ["downTutorial"] = "Chào mừng đến với hầm mỏ. Bên phải thang máy có một kho chứa, nơi bạn sẽ thu thập vật liệu xây dựng - nhưng sẽ nói thêm sau. Bạn được giao đường hầm %s, hãy đến đó để bắt đầu đào",
    ["buildingTutorial"] = "Khi tiến độ đào ngày càng tăng, bạn sẽ cần xây dựng đường ray và giá đỡ. Các vật phẩm cần xây dựng được đánh dấu. Mang vật phẩm được chỉ định từ kho để lắp đặt.",
    ["takeFood"] = "~b~[E] |~s~ Lấy Thức Ăn",
    ["sitChair"] = "~b~[E] |~s~ Ngồi",
    ["firstBuildPrevious"] = "Trước tiên bạn cần xây dựng đường ray trước đó",
    ["wait"] = "Vui lòng chờ vài giây và thử lại sau",
    ["forceExit"] = "Nhấn ~INPUT_CONTEXT~ để thoát hầm mỏ",
    ["grabGear"] = "~b~[E] |~s~ Lấy Trang Bị",
    ["putGear"] = "~b~[E] |~s~ Cất Trang Bị",
    ["civClothes"] = "~b~[E] |~s~ Đồ Thường",
    ["workClothes"] = "~b~[E] |~s~ Đồ Làm Việc",
    ["noClothes"] = "Bạn hoặc ai đó trong nhóm không mặc đồ hoặc trang bị. Bạn không thể vào hầm mỏ mà không có đồ bảo hộ",
    ["gasLeak"] = "Ai đó đã gây rò rỉ khí gas! Chạy ngay!",
    ["teammateDown"] = "Đồng đội của bạn bị thương, bạn cần hoàn thành công việc",
    ["somebodyNotInElevator"] = "Toàn bộ thành viên trong đội phải ở trong thang máy",
    ["lightToggle"] = "Nhấn ~INPUT_REPLAY_HIDEHUD~ để bật/tắt đèn",

    -- Server
    ["isAlreadyHost"] = "Người chơi này đã là trưởng nhóm.",
    ["isBusy"] = "Người chơi này đã thuộc một nhóm khác.",
    ["hasActiveInvite"] = "Người chơi này đã có lời mời từ người khác.",
    ["HaveActiveInvite"] = "Bạn đã có lời mời tham gia nhóm.",
    ["InviteDeclined"] = "Lời mời của bạn đã bị từ chối.",
    ["InviteAccepted"] = "Lời mời của bạn đã được chấp nhận!",
    ["error"] = "Đã xảy ra lỗi khi tham gia nhóm. Vui lòng thử lại sau.",
    ["kickedOut"] = "Bạn đã bị đá ra khỏi nhóm!",
    ["reward"] = "Bạn đã nhận được tiền thưởng: $",
    ["RequireOneFriend"] = "Công việc này yêu cầu ít nhất một thành viên trong nhóm",
    ["dontHaveReqItem"] = "Bạn hoặc ai đó trong nhóm không có vật phẩm yêu cầu để bắt đầu công việc",
    ["notEverybodyHasRequiredJob"] = "Không phải ai trong nhóm đều có công việc yêu cầu",
    ["someoneIsOnCooldown"] = "%s không thể bắt đầu công việc (thời gian chờ: %s)",
    ["hours"] = "giờ",
    ["minutes"] = "phút",
    ["seconds"] = "giây",
    ["newBoss"] = "Trưởng nhóm trước đó đã rời server. Bạn bây giờ là trưởng nhóm",
    ["penalty"] = "Bạn đã nộp phạt số tiền ",
    ["clientsPenalty"] = "Trưởng nhóm đã chấp nhận hình phạt",
    ["alreadyStarted"] = "Bạn đã bắt đầu công việc!",
    ["jobDone"] = "Bạn đã đào hết đường hầm, không thể đào thêm!",

    -- NUI
    ["NUI_progress"] = "Tiến Độ: %s%",
    ["NUI_signatureTitle"] = "CÔNG VIỆC THỢ MỎ",
    ["NUI_signatureTitlePlaceholder"] = "CÔNG VIỆC THỢ MỎ",
    ["NUI_tutorial"] = "Hướng Dẫn",
    ["NUI_notification"] = "Thông Báo",
    ["NUI_invitation"] = "Lời Mời",
    ["NUI_warning"] = "Cảnh Báo",
    ["NUI_bossName"] = "Tên Trưởng Nhóm",
    ["NUI_memberName"] = "Tên Thành Viên",
    ["NUI_kickPlayerNotify"] = "Trưởng nhóm không thể rời nhóm!",
    ["NUI_startJobNotify"] = "Chỉ trưởng nhóm mới có thể bắt đầu công việc!",
    ["NUI_minerLobby"] = "LOBBY THỢ MỎ",
}

Config.MiningHintColor = {r = 57, g = 151, b = 201, a = 0.8}
Config.MarkerSettings = { -- used only when Config.UseTarget = false. Colors of the marker. Active = when player stands inside the marker.
    Active = {
        r = 91,
        g = 168,
        b = 255,
        a = 201,
    },
    UnActive = {
        r = 57,
        g = 151,
        b = 201,
        a = 150,
    }
}

Config.Restaurant = {
    enable = true,
    coordinates = vector3(2436.07, 1545.88, 44.02),
    tray = {
        model =  `prop_cs_silver_tray`,
        burgerModel = `prop_cs_burger_01`,
        burgerOffset = vec3(0.08, 0.0, 0.04),
        waterModel = `prop_ld_flow_bottle`,
        waterOffset = vec3(-0.08, 0.0, 0.12),
        wearingAnim = {
            dict = "anim@heists@box_carry@",
            name = "idle",
            trayOffset = vec3(0.0, -0.20, -0.16),
            trayRotation = vec3(0.0, 0.0, 0.0),
        }
    },
    restoreStatus = function()
        TriggerEvent("esx_status:add", "thirst", 100000)
        TriggerEvent("esx_status:add", "hunger", 200000)

        TriggerServerEvent("consumables:server:addHunger", 100)
        TriggerServerEvent("consumables:server:addThirst", 100)
        -- Your status restore export goes here
    end,
    objects = {
        {
            coordinates = vector3(2439.63525, 1545.90576, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, 55.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2440.98535, 1544.95154, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, -120.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2438.169, 1541.80579, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, 80.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2439.69385, 1541.83984, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, -80.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2442.12866, 1543.06384, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, 90.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2443.65356, 1543.18054, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, -95.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2443.87866, 1545.678, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, 120.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2445.24585, 1546.45117, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, -55.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2446.25757, 1542.6947, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, 160.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2446.9895, 1544.03223, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, -20.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2447.293, 1545.19116, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, 130.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2448.63013, 1546.332, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, -40.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2451.05347, 1545.14282, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, 130.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2452.199, 1546.14929, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, -40.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2449.27637, 1542.77747, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, 65.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2450.802, 1542.222, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, -110.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2453.70044, 1542.035, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, 175.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2453.79858, 1543.69836, 43.0813828),
            trayOffset = vec3(0.0, -0.35, 0.74),
            rotation = vec3(0.0, 0.0, 5.0),
            type = "chair",
            model = `restaurant_chair`,
        },

        {
            coordinates = vector3(2453.77173, 1542.84778, 43.01016),
            rotation = vec3(0.0, 0.0, 0.0),
            type = "table",
            model = `restarutant_table`,
        },

        {
            coordinates = vector3(2451.57837, 1545.54578, 43.01016),
            rotation = vec3(0.0, 0.0, 0.0),
            type = "table",
            model = `restarutant_table`,
        },

        {
            coordinates = vector3(2448.06934, 1545.79382, 43.01016),
            rotation = vec3(0.0, 0.0, 0.0),
            type = "table",
            model = `restarutant_table`,
        },

        {
            coordinates = vector3(2450.08325, 1542.439, 43.01016),
            rotation = vec3(0.0, 0.0, 0.0),
            type = "table",
            model = `restarutant_table`,
        },

        {
            coordinates = vector3(2446.606, 1543.36792, 43.01016),
            rotation = vec3(0.0, 0.0, 0.0),
            type = "table",
            model = `restarutant_table`,
        },

        {
            coordinates = vector3(2444.4126, 1546.06592, 43.01016),
            rotation = vec3(0.0, 0.0, 0.0),
            type = "table",
            model = `restarutant_table`,
        },


        {
            coordinates = vector3(2442.787, 1543.07214, 43.01016),
            rotation = vec3(0.0, 0.0, 0.0),
            type = "table",
            model = `restarutant_table`,
        },


        {
            coordinates = vector3(2440.252, 1545.38684, 43.01016),
            rotation = vec3(0.0, 0.0, 0.0),
            type = "table",
            model = `restarutant_table`,
        },

        {
            coordinates = vector3(2438.85034, 1541.82532, 43.01016),
            rotation = vec3(0.0, 0.0, 0.0),
            type = "table",
            model = `restarutant_table`,
        },
    }
}

Config.WallModel = `17mov_mining_wall`

Config.MinecartModel = `17mov_cart`
Config.MinecartOffset = vector3(0.0, 0.0, 0.7)
Config.MinecartForwardOffset = -1.5

Config.RockModel = `17mov_stones_txt`
Config.RockInMinecaftMinOffset = vector3(0.0, 0.0, -0.03)
Config.RockInMinecaftMaxOffset = vector3(0.0, 0.0, 0.24)
Config.RockInMinecaftRotation = vector3(0.0, 0.0, 0.0)

Config.Props = {
    ["Rails"] = {
        model = `17mov_rail`,
        stackCoords = vector3(2416.326, 1551.32751, -33.52552),
        stackRotation = vector3(0.0, 0.0, 0.0),
        stackOffest = vector3(0.0, 0.0, 0.3),
        interactionDistance = 2.5,
        attachToPed = {
            offset = vector3(0.2, -0.26, 0.03),
            rotation = vector3(-17.0, -27.0, 96.0),
        }
    },
    ["Lights"] = {
        model = `17mov_minelight_25_off`,
        stackCoordinates = {
            vec3(2417.17822, 1546.30322, -33.50039),
            vec3(2417.17822, 1545.75916, -33.50039),
            vec3(2416.61353, 1546.30322, -33.50039),
            vec3(2416.61353, 1545.75916, -33.50039),
            vec3(2415.824, 1546.30322, -33.50039),
            vec3(2415.824, 1545.75916, -33.50039),
            vec3(2415.824, 1545.25732, -33.50039),
            vec3(2416.61353, 1545.25732, -33.50039),
            vec3(2417.17822, 1545.25732, -33.50039),
        },
        stackRotation = vector3(0.0, -180.0, 13.5),
        interactionDistance = 2.5,
        attachToPed = {
            offset = vector3(0.0, -0.08, -0.2),
            rotation = vector3(0.0, 180.0, 0.0),
        }
    },
    ["SupportPillarLeft"] = {
        model = `17mov_miner_wbar1`,
        offset = vector3(0.0, -2.5, 0.0),
        rotation = vector3(0.0, 0.0, 0.0),
        stackCoordinates = {
            vec3(2430.61, 1546.913, -33.346508),
            vec3(2430.22559, 1546.913, -33.346508),
            vec3(2429.84863, 1546.913, -33.346508),
            vec3(2429.464, 1546.913, -33.346508),
            vec3(2430.4126, 1546.913, -32.9867134),
            vec3(2430.028, 1546.913, -32.9867134),
            vec3(2429.65112, 1546.913, -32.9867134),
        },
        stackRotation = vector3(90.0, 0.0, 0.0),
        interactionDistance = 2.5,
        attachToPed = {
            offset = vector3(0.0, -0.1, 0.1),
            rotation = vector3(0.0, 90.0, 0.0),
        }
    },
    ["SupportPillarRight"] = {
        model = `17mov_miner_wbar1`,
        offset = vector3(0.0, 2.5, 0.0),
        rotation = vector3(0.0, 0.0, 0.0),
        stackCoordinates = {
            vec3(2430.61, 1550.97986, -33.346508),
            vec3(2430.22559, 1550.97986, -33.346508),
            vec3(2429.84863, 1550.97986, -33.346508),
            vec3(2429.464, 1550.97986, -33.346508),
            vec3(2430.4126, 1550.97986, -32.9867134),
            vec3(2430.028, 1550.97986, -32.9867134),
            vec3(2429.65112, 1550.97986, -32.9867134),
        },
        stackRotation = vector3(90.0, 0.0, 0.0),
        interactionDistance = 2.5,
        attachToPed = {
            offset = vector3(0.0, -0.1, 0.1),
            rotation = vector3(0.0, 90.0, 0.0),
        }
    },
    ["SupportConnectorLeft"] = {
        model = `17mov_miner_wbar2`,
        offset = vector3(0.0, -1.675, 1.9),
        rotation = vector3(0.0, 0.0, 0.0),
        stackCoordinates = {
            vec3(2430.01782, 1555.77649, -33.3409729),
            vec3(2430.01782, 1555.41284, -33.3409729),
            vec3(2430.01782, 1555.77649, -32.96839),
            vec3(2430.01782, 1555.41284, -32.96839),
            vec3(2430.01782, 1555.77649, -32.5947571),
            vec3(2430.01782, 1555.41284, -32.5947571),
            vec3(2430.01782, 1555.61084, -32.2259521),
        },
        stackRotation = vector3(-45.0, 0.0, 90.0),
        interactionDistance = 2.5,
        attachToPed = {
            offset = vector3(0.0, -0.1, 0.1),
            rotation = vector3(0.0, 90.0, -50.0),
        }
    },
    ["SupportConnectorRight"] = {
        model = `17mov_miner_wbar2`,
        offset = vector3(0.0, -1.675, 1.9),
        rotation = vector3(0.0, 0.0, 180.0),
        stackCoordinates = {
            vec3(2430.01782, 1554.95837, -33.3409729),
            vec3(2430.01782, 1554.59473, -33.3409729),
            vec3(2430.01782, 1554.95837, -32.96839),
            vec3(2430.01782, 1554.59473, -32.96839),
            vec3(2430.01782, 1554.95837, -32.5947571),
            vec3(2430.01782, 1554.59473, -32.5947571),
            vec3(2430.01782, 1554.79272, -32.2259521),
        },
        stackRotation = vector3(-45.0, 0.0, 90.0),
        interactionDistance = 3.0,
        attachToPed = {
            offset = vector3(0.0, -0.1, 0.1),
            rotation = vector3(0.0, 90.0, -50.0),
        }
    },
    ["SupportLintel"] = {
        model = `17mov_miner_wbar3`,
        offset = vector3(0.0, 0.0, 2.7),
        rotation = vector3(0.0, 0.0, 0.0),
        stackCoordinates = {
            vec3(2425.8335, 1557.04675, -33.3713531),
            vec3(2425.8335, 1556.68274, -33.3713531),
            vec3(2425.8335, 1556.319, -33.3713531),
            vec3(2425.8335, 1555.955, -33.3713531),
            vec3(2425.8335, 1556.86951, -33.0083427),
            vec3(2425.8335, 1556.50574, -33.0083427),
            vec3(2425.8335, 1556.14172, -33.0083427),
        },
        stackRotation = vector3(0.0, 0.0, -90.0),
        interactionDistance = 2.5,
        attachToPed = {
            offset = vector3(0.0, -0.1, 0.1),
            rotation = vector3(0.0, 0.0, 90.0),
        }
    },
}

-- Tại đây bạn có thể cấu hình các sự kiện tai nạn/ngẫu nhiên xảy ra khi người chơi đang đào
Config.Events = {
    ["gas"] = {
        chance = 50,               -- Tỉ lệ kích hoạt sự kiện (có thể xảy ra mỗi lần đập). Giá trị từ 0-100
        duration = 30 * 1000,        -- Thời gian sự kiện kéo dài (milliseconds)
        minimumProgressPercent = 15, -- % tiến độ tối thiểu của job để sự kiện có thể xảy ra
        healthLossValue = 2,         -- Lượng máu bị mất mỗi lần trừ
        healthLossInterval = 1000,   -- Khoảng thời gian giữa mỗi lần trừ máu (ms, 1000 = 1 giây)
    },
    ["blackout"] = {
        chance = 50,                -- Tỉ lệ kích hoạt sự kiện (có thể xảy ra mỗi lần đập). Giá trị từ 0-100
        minimumProgressPercent = 15, -- % tiến độ tối thiểu của job để sự kiện có thể xảy ra
        minDuration = 10000,         -- Thời gian tối thiểu của sự kiện (milliseconds)
        maxDuration = 100000,        -- Thời gian tối đa của sự kiện (milliseconds)
    }
}


Config.Mineshatfs = {
    [1] = {
        wallCoordinates = vector3(2410.50122, 1516.50427, -31.17),
        wallRotation = vector3(0.0, 0.0, 180.0),

        railsStart = vector3(2409.26147, 1520.744, -33.75),
        railsRotation = vector3(0.0, 0.0, 0.0),
        railsQuantity = 10,

        supportsStart = vector3(2410.51172, 1512.74426, -32.25),
        supportsRotation = vector3(0.0, 0.0, 90.0),
        supportsQuantity = 7,

        lightsStart = vector3(2410.51172, 1512.74426, -29.7),
        lightsRotation = vector3(0.0, 0.0, 180.0),
        lightsQuantity = 7,
        forwardVector = vector3(0.0, -1.0, 0.0)
    },
    [2] = {
        wallCoordinates = vector3(2402.52832, 1516.50427, -31.17),
        wallRotation = vector3(0.0, 0.0, 180.0),

        railsStart = vector3(2401.28857, 1520.744, -33.75),
        railsRotation = vector3(0.0, 0.0, 0.0),
        railsQuantity = 10,

        supportsStart = vector3(2402.53882, 1512.74426, -32.25),
        supportsRotation = vector3(0.0, 0.0, 90.0),
        supportsQuantity = 7,

        lightsStart = vector3(2402.53882, 1512.74426, -29.7),
        lightsRotation = vector3(0.0, 0.0, 180.0),
        lightsQuantity = 7,
        forwardVector = vec3(0, -1, 0)
    },
    [3] = {
        wallCoordinates = vector3(2394.53149, 1516.50427, -31.17),
        wallRotation = vector3(0.0, 0.0, 180.0),

        railsStart = vector3(2393.29175, 1520.744, -33.75),
        railsRotation = vector3(0.0, 0.0, 0.0),
        railsQuantity = 10,

        supportsStart = vector3(2394.542, 1512.74426, -32.25),
        supportsRotation = vector3(0.0, 0.0, 90.0),
        supportsQuantity = 7,

        lightsStart = vector3(2394.542, 1512.74426, -29.7),
        lightsRotation = vector3(0.0, 0.0, 180.0),
        lightsQuantity = 7,
        forwardVector = vec3(0, -1, 0)
    },
    [4] = {
        wallCoordinates = vector3(2381.89, 1528.1, -31.17),
        wallRotation = vector3(0.0, 0.0, 90.0),

        railsStart = vector3(2386.13, 1529.34, -33.75),
        railsRotation = vector3(0.0, 0.0, -90.0),
        railsQuantity = 10,

        supportsStart = vector3(2378.13, 1528.09, -32.25),
        supportsRotation = vector3(0.0, 0.0, 0.0),
        supportsQuantity = 7,

        lightsStart = vector3(2378.13, 1528.09, -29.7),
        lightsRotation = vector3(0.0, 0.0, 90.0),
        lightsQuantity = 7,
        forwardVector = vec3(-1, 0, 0)
    },
    [5] = {
        wallCoordinates = vector3(2381.89, 1535.51709, -31.17),
        wallRotation = vector3(0.0, 0.0, 90.0),

        railsStart = vector3(2386.13, 1536.75708, -33.75),
        railsRotation = vector3(0.0, 0.0, -90.0),
        railsQuantity = 10,

        supportsStart = vector3(2378.13, 1535.50708, -32.25),
        supportsRotation = vector3(0.0, 0.0, 0.0),
        supportsQuantity = 7,

        lightsStart = vector3(2378.13, 1535.50708, -29.7),
        lightsRotation = vector3(0.0, 0.0, 90.0),
        lightsQuantity = 7,
        forwardVector = vec3(-1, 0, 0)
    },
    [6] = {
        wallCoordinates = vector3(2394.59717, 1547.2489, -31.17),
        wallRotation = vector3(0.0, 0.0, 0.0),

        railsStart = vector3(2395.83667, 1543.00854, -33.75),
        railsRotation = vector3(0.0, 0.0, 180.0),
        railsQuantity = 10,

        supportsStart = vector3(2394.5874, 1551.00854, -32.25),
        supportsRotation = vector3(0.0, 0.0, 270.0),
        supportsQuantity = 7,

        lightsStart = vector3(2394.5874, 1551.00854, -29.7),
        lightsRotation = vector3(0.0, 0.0, 0.0),
        lightsQuantity = 7,
        forwardVector = vec3(0, 1, 0)
    },
    [7] = {
        wallCoordinates = vector3(2402.58252, 1547.2489, -31.17),
        wallRotation = vector3(0.0, 0.0, 0.0),

        railsStart = vector3(2403.822, 1543.00854, -33.75),
        railsRotation = vector3(0.0, 0.0, 180.0),
        railsQuantity = 10,

        supportsStart = vector3(2402.57275, 1551.00854, -32.25),
        supportsRotation = vector3(0.0, 0.0, 270.0),
        supportsQuantity = 7,

        lightsStart = vector3(2402.57275, 1551.00854, -29.7),
        lightsRotation = vector3(0.0, 0.0, 0.0),
        lightsQuantity = 7,
        forwardVector = vec3(0, 1, 0)
    },
    [8] = {
        wallCoordinates = vector3(2410.461, 1547.2489, -31.17),
        wallRotation = vector3(0.0, 0.0, 0.0),

        railsStart = vector3(2411.70044, 1543.00854, -33.75),
        railsRotation = vector3(0.0, 0.0, 180.0),
        railsQuantity = 10,

        supportsStart = vector3(2410.45117, 1551.00854, -32.25),
        supportsRotation = vector3(0.0, 0.0, 270.0),
        supportsQuantity = 7,

        lightsStart = vector3(2410.45117, 1551.00854, -29.7),
        lightsRotation = vector3(0.0, 0.0, 0.0),
        lightsQuantity = 7,
        forwardVector = vec3(0, 1, 0)
    },
}