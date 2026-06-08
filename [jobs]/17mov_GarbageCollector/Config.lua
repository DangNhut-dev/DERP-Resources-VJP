Config = {}

Config.Lang = "en"                                  -- Đặt ngôn ngữ sử dụng từ thư mục locale
Config.UseModernUI = true                           -- Tháng 3/2023 công việc đã được tái cấu trúc lớn và giao diện cũng được thay đổi. Đặt false để dùng giao diện CŨ (không còn hỗ trợ)
Config.SplitReward = false                          -- Tuỳ chọn này chỉ hoạt động khi UseModernUI = false. Nếu true, tiền công = (Config.OnePercentWorth * Progress) / SốThànhViên; nếu false thì = (Config.OnePercentWorth * Progress)

Config.AutoSearchForConflicts = true
Config.VersionCheck = {
    Enabled = false,                                 -- Bật/tắt kiểm tra phiên bản
    DisplayAsciiArt = false,                         -- Đặt false nếu không muốn hiển thị ASCII art trong console
    DisplayChangelog = false,                        -- Có hiển thị changelog trong console không?
    DisplayFiles = false,                            -- Có hiển thị các file cần cập nhật trong console không?
}

Config.UseBuiltInNotifications = false               -- Đặt false nếu muốn dùng thông báo theo framework của bạn. Nếu không, hệ thống thông báo hiện đại tích hợp sẵn sẽ được sử dụng
Config.LetBossSplitReward = true                    -- Nếu true, sếp có thể quản lý tỉ lệ phần thưởng của cả nhóm trong menu. Nếu false, tất cả sẽ nhận số tiền bằng nhau
Config.MultiplyRewardWhileWorkingInGroup = true     -- Nếu false, phần thưởng giữ nguyên mặc định. Ví dụ $1000 cho hoàn thành công việc. Nếu true, phần thưởng sẽ phụ thuộc vào số người trong nhóm. Ví dụ công việc đầy đủ là $1000, nếu người chơi làm trong nhóm 4 người thì phần thưởng sẽ là $4000 (baseReward * số thành viên)
Config.Price = 200                                    -- Giá trên mỗi túi rác trong xe. Tối đa 100 nên xe đầy = $200 / số thành viên
Config.UseTarget = true                            -- Đổi thành true nếu muốn dùng hệ thống target. Tất cả cấu hình target nằm trong file target.lua
Config.RequiredJob = "none"                         -- Đặt "none" nếu bạn không muốn dùng hệ thống nghề. Nếu đang dùng target, bạn phải đặt tham số "job" cho từng export trong target.lua
Config.RequireJobAlsoForFriends = false              -- Nếu false, chỉ cần host có nghề; nếu true thì cả nhóm phải có Config.RequiredJob
Config.RequireOneFriendMinimum = false              -- Đặt true nếu muốn bắt buộc người chơi phải lập nhóm
Config.EnableGamePoolDeleting = true                -- Chỉ đặt false khi dùng các phiên bản FXServer cũ. Có thể gây lỗi xoá túi rác
Config.EnableExploitFix = true                     -- Đặt true để bật kiểm tra có người chơi nào trong bán kính x mét khi đang nhặt túi
Config.ExploitFixDistance = 3.0                     -- Khoảng cách kiểm tra exploit (mét)

Config.BlockBagsRespawning = true
Config.BagRespawnTime = 10 * 60 * 1000

Config.JobVehicleModel = "trash"                    -- Model xe của công ty
Config.JobVehicleBackOffset = vec3(0.0, -5.0, 0.5)  -- Offset so với toạ độ xe để hiển thị text 3D ném túi rác

Config.PenaltyAmount = 500                          -- Tiền phạt khi người chơi kết thúc công việc mà không có xe công ty
Config.DontPayRewardWithoutVehicle = false          -- Đặt true nếu không muốn trả lương cho người chơi kết thúc khi không có xe công ty (chấp nhận bị phạt)
Config.EnableVehicleTeleporting = true              -- Nếu true, script sẽ dịch chuyển host tới xe công ty. Nếu false, xe công ty xuất hiện nhưng cả nhóm phải tự đi vào xe
Config.EnableVehicleCrewMembersTeleporting = false   -- Nếu true, script sẽ dịch chuyển tất cả thành viên nhóm tới xe công ty
Config.JobCooldown = 0 * 60 -- 10 * 60              -- Thời gian chờ giữa các lần làm việc (ví dụ trong ngoặc là 10 phút)
Config.GiveKeysToAllLobby = true                    -- Đặt false nếu chỉ muốn cấp chìa khoá xe cho trưởng nhóm khi bắt đầu công việc
Config.ProgressBarOffset = "25px"                   -- Giá trị px offset của counter trên màn hình
Config.ProgressBarAlign = "bottom-center"           -- Vị trí progressbar. Các tuỳ chọn: top-left, top-center, top-right, bottom-left, bottom-center, bottom-right

Config.EnableBins = true                            -- Nếu false, người chơi sẽ không thể nhặt rác từ thùng rác
Config.FixBinsPosition = true                       -- Thử nghiệm, sửa hướng xoay của thùng rác. Có ảnh hưởng đến hiệu năng - nếu bị lag hãy đặt false
Config.HighlightOnTutorial = true                   -- Nếu true, tất cả vật thể có thể nhặt sẽ được highlight trong tutorial
Config.EnableUnloadStage = true                     -- Nếu true, sau khi kết thúc công việc, người chơi sẽ phải dỡ hàng khỏi xe
Config.BagsCountToFullUnload = 25                   -- Số túi rác sẽ được tạo ra khi đạt 100% để dỡ hàng
Config.BinsRestartingDelay = {                      -- Số giây để thùng rác làm mới lại túi rác đã bị nhặt
    min = 10 * 60,
    max = 15 * 60
}

Config.UnloadZone = {
    coords = vec3(-351.819092, -1541.140869, 27.428465),
    rotation = vec3(0.339711, -0.048754, -0.072852)
}

Config.Animation = {
    start_coords = vec3(-351.824158, -1547.076904, 27.609995),
    end_coords_offset = vec3(0.0, 0.0, 14.0),
    rotation = vec3(0.0, 90.0, 0.0),
    duration = 3800,
    max_bags_on_line = 6,
    model = 'hei_prop_heist_binbag',
}

Config.KeybindSettings = {
    bagsInteractionKey = 38,
    bagsInteractionkeyString = "~r~[E] | ~s~"
}

Config.RewardItemsToGive = {
    -- {
    --     item_name = "water",
    --     chance = 100,
    --     amountPerBag = 1,
    -- },
}

Config.RequiredItem = "none"                        -- Đặt thành bất kỳ vật phẩm nào bạn muốn, để yêu cầu người chơi phải có vật phẩm đó trong túi trước khi bắt đầu công việc
Config.RequireItemFromWholeTeam = false             -- Nếu false, chỉ host cần có vật phẩm yêu cầu; ngược lại cả đội phải có

Config.RequireFullJob = false                       -- Đặt true nếu muốn người chơi phải đạt 100% tiến độ, nếu không họ sẽ không thể kết thúc công việc
Config.RequireWorkClothes = false                   -- Đặt true để thay đồ người chơi mỗi khi họ bắt đầu công việc

Config.RestrictBlipToRequiredJob = false            -- Đặt true để ẩn blip công việc với người chơi không có RequiredJob. Nếu RequiredJob là "none" thì tuỳ chọn này sẽ không có tác dụng
Config.Blips = { -- Tại đây bạn có thể cấu hình blip của công ty
    [1] = {
        Sprite = 318,
        Color = 52,
        Scale = 0.8,
        Pos = vector3(-329.47, -1538.23, 31.43),
        Label = 'Công Việc Dọn Rác'
    },
}

Config.MarkerSettings = {   -- Chỉ dùng khi Config.UseTarget = true. Màu của marker. Active = khi người chơi đang đứng trong marker
    Active = {
        r = 89,
        g = 198,
        b = 100,
        a = 200,
    },
    UnActive = {
        r = 34,
        g = 117,
        b = 42,
        a = 200,
    }
}


Config.TargetPedOptions = {
    model = 's_m_m_gardener_01',
    coords = vector3(-339.28, -1534.15, 27.72),
    heading = 357.96,
}

Config.Locations = {       -- Tại đây bạn có thể đổi tất cả vị trí cơ bản của công việc
    DutyToggle = {
        Coords = {
            vector3(-329.47, -1538.23, 31.43),
        },
        CurrentAction = 'open_dutyToggle',
        CurrentActionMsg = _L("Job.Markers.DutyToggle"),
        type = 'duty',
        scale = { x = 1.0, y = 1.0, z = 1.0 }
    },
    FinishJob = {
        Coords = {
            vector3(-329.48, -1522.98, 27.53),
        },
        CurrentAction = 'finish_job',
        CurrentActionMsg = _L("Job.Markers.FinishJob"),
        scale = { x = 3.0, y = 3.0, z = 3.0 }
    },

}

Config.SpawnPoint = vector4(-316.98, -1537.58, 26.64, 338.0)  -- Điểm spawn xe của công ty
Config.EnableCloakroom = false                                 -- Nếu false, bạn sẽ không thấy nút Phòng Thay Đồ trong Menu Công Việc
Config.Clothes = {
    -- Tại đây bạn có thể cấu hình trang phục. Thông tin chi tiết: https://docs.fivem.net/natives/?_0xD4F7B05C. Tại link này bạn có thể xem id nào tương ứng với component nào
    male = {
        ["mask"] = {clotheId = 0, variation = 0},
        ["arms"] = {clotheId = 30, variation = 0},
        ["pants"] = {clotheId = 36, variation = 0},
        ["bag"] = {clotheId = 0, variation = 0},
        ["shoes"] = {clotheId = 56, variation = 1},
        ["t-shirt"] = {clotheId = 59, variation = 1},
        ["torso"] = {clotheId = 56, variation = 0},
        ["decals"] = {clotheId = 0, variation = 0},
        ["kevlar"] = {clotheId = 0, variation = 0},
    },
    female = {
        ["mask"] = {clotheId = 0, variation = 0},
        ["arms"] = {clotheId = 57, variation = 0},
        ["pants"] = {clotheId = 35, variation = 0},
        ["bag"] = {clotheId = 0, variation = 0},
        ["shoes"] = {clotheId = 59, variation = 1},
        ["t-shirt"] = {clotheId = 36, variation = 1},
        ["torso"] = {clotheId = 49, variation = 1},
        ["decals"] = {clotheId = 0, variation = 0},
        ["kevlar"] = {clotheId = 0, variation = 0},
    }
}

Config.BagAttachments = {
    [`bkr_prop_fakeid_binbag_01`] = {
        offset = vec3(0.5128798484802, -0.3899130821228, -0.061923664063215),
        rotation = vec3(-49.78881072998, -69.82479858398, 27.380029678345),
        counterValue = 1,
    },
    [`hei_prop_heist_binbag`] = {
        offset = vec3(0.11030727624893, -0.015525032766163, -0.046225301921368),
        rotation = vec3(-28.24030685424, -78.76949310302, 24.484218597412),
        counterValue = 1,
    },
    [`prop_cs_rub_binbag_01`] = {
        offset = vec3(0.093124, -0.014298, -0.028950),
        rotation = vec3(-30.728870, -56.827114, 20.127888),
        counterValue = 1,
    },
    [`prop_cs_street_binbag_01`] = {
        offset = vec3(0.444981, -0.132261, -0.019885),
        rotation = vec3(-98.415436, 13.830777, 71.450897),
        counterValue = 1,
    },
    [`prop_ld_rub_binbag_01`] = {
        offset = vec3(0.384783, -0.147489, -0.134954),
        rotation = vec3(-30.008329, -58.360416, 20.631702),
        counterValue = 1,
    },
    [`prop_rub_binbag_01`] = {
        offset = vec3(0.443036, -0.237512, 0.003951),
        rotation = vec3(-16.469851, -87.421234, 7.540201),
        counterValue = 1,
    },

    [`prop_rub_binbag_04`] = {
        offset = vec3(0.912093, -0.544255, -0.016079),
        rotation = vec3(-32.461769, -80.153793, 20.617262),
        counterValue = 1,
    },
    [`prop_rub_binbag_05`] = {
        offset = vec3(0.758000, -0.022000, -0.161000),
        rotation = vec3(1.350526, -77.211212, -168.416992),
        counterValue = 1,
    },
    [`prop_rub_binbag_sd_01`] = {
        offset = vec3(0.513000, -0.134000, -0.065000),
        rotation = vec3(0.000000, -83.960419, 0.000000),
        counterValue = 1,
    },
    [`prop_rub_binbag_sd_02`] = {
        offset = vec3(0.509000, -0.127000, -0.047000),
        rotation = vec3(0.000000, -83.228851, 0.000000),
        counterValue = 1,
    },
    [`p_binbag_01_s`] = {
        offset = vec3(0.408000, -0.168000, -0.029000),
        rotation = vec3(-23.795959, -82.635666, 23.621243),
        counterValue = 1,
    },
    [`p_rub_binbag_test`] = {
        offset = vec3(0.477000, -0.105000, -0.066000),
        rotation = vec3(92.451553, -10.887776, -102.771141),
        counterValue = 1,
    },
    [`prop_rub_binbag_06`] = {
        offset = vec3(0.644000, -0.228000, -0.176000),
        rotation = vec3(-20.425049, -87.962196, -3.816112),
        counterValue = 1,
    },
    [`prop_rub_binbag_08`] = {
        offset = vec3(0.437000, -0.194000, -0.119000),
        rotation = vec3(0.000000, -71.260628, 0.000000),
        counterValue = 1,
    },
    [`prop_rub_binbag_01b`] = {
        offset = vec3(0.442000, -0.118000, -0.055000),
        rotation = vec3(0.000000, -84.545776, 0.000000),
        counterValue = 1,
    },
    [`prop_rub_binbag_03`] = {
        offset = vec3(0.303000, -0.667000, 0.067000),
        rotation = vec3(-130.519180, 77.479706, 0.466558),
        counterValue = 1,
    },
    [`prop_rub_binbag_03b`] = {
        offset = vec3(0.708000, -0.470000, 0.133000),
        rotation = vec3(-85.900436, -15.666203, 55.107498),
        counterValue = 1,
    },
}
