local SHARED_CONFIG <const> = lib.load("config.scenarios._shared")

return {

    blips = {
        employer = { hidden = true, sprite = 429, scale = 0.8, color = 5, name = locale("blips.employer") },
        vehicle  = { sprite = 853, scale = 0.8, color = 5, name = locale("blips.vehicle") },
    },

    employers = {
        {
            coords = vector4(-79.36, 6220.69, 46.30, 31.07),
            pedModel = "s_m_m_movprem_01",
            vehicleSpawnPoints = {
                vector4(-94.73, 6181.13, 30.57, 130.39),
            },
        },
    },

    heistScenarios = {
        ["vangelico_robbery"] = {
            isActive = false,    -- Set to false to deactivate this scenario.
            level = 1,          -- Minimum player level required to start the scenario.
            requiredCops = 1,   -- Minimum number of police officers required online to start a heist.
            maxMemberCount = 6, -- Maximum number of players allowed in the scenario.
            -- Required items: Items that players must have to start the scenario.
            requiredItems = {
                { itemName = "heistpack_drone", count = 1, label = "Heistpack Drone", },
            },

            scenarioCooldown = SHARED_CONFIG.gameplay.cooldowns.medium, -- Duration (in minutes) of the entire scenario.
            playerCooldown = SHARED_CONFIG.gameplay.cooldowns.short,    -- Duration (in minutes) a player must wait before starting another scenario.

            rewards = { exp = 300 },                                    -- Rewards given to players upon successful completion of the scenario.

            label = locale("vangelico_robbery.label"),                  -- Localized label for the scenario.
            description = locale("vangelico_robbery.description"),      -- Localized description for the scenario.
            information = locale("vangelico_robbery.information"),      -- Localized additional information for the scenario.

            image = "images/scenarios/vangelico_robbery.png",           -- Image path representing the scenario.

            -- Detailed step-by-step instructions for players participating in the scenario.
            infoTexts = {
                "Nếu thiếu vật phẩm, hãy đến chợ để mua.",
                "Đến khu vực được đánh dấu trên bản đồ, lên mái nhà và sử dụng máy bay không người lái.",
                "Dùng máy bay để thả bom khí vào các khu vực mục tiêu.",
                "Đừng quên đeo mặt nạ khi ở trong đám mây khí, nếu không sức khỏe của bạn sẽ bị tổn thương.",
                "Khi khí làm bất động những người trong cửa hàng, hệ thống bảo mật sẽ kích hoạt và cửa ngoài sẽ bị khóa.",
                "Dùng thuốc nổ C4 phá cửa và tiến vào cửa hàng.",
                "Bạn có thể đập tủ kính, cướp người dân và thu thập trang sức bên trong cửa hàng.",
                "Hãy cố gắng hoàn thành tất cả các hoạt động còn lại.",
                "Di chuyển đủ xa để kết thúc vụ cướp.",
            },
        },
        ["house_robbery"] = {
            isActive = false, 
            level = 1,
            requiredCops = 1,
            maxMemberCount = 4,
            simultaneous = 1,

            scenarioCooldown = 0,
            playerCooldown = SHARED_CONFIG.gameplay.cooldowns.short,

            rewards = { exp = 500 },

            label = locale("house_robbery.label"),
            description = locale("house_robbery.description"),
            information = locale("house_robbery.information"),

            image = "images/scenarios/house_robbery.png",

            infoTexts = {
                "Nếu thiếu vật phẩm, hãy đến chợ để mua.",
                "Đến khu vực được đánh dấu trên bản đồ và dùng hacking_device để đột nhập vào nhà.",
                "Lục soát các phòng để tìm đồ có giá trị như tiền mặt, trang sức và đồ điện tử.",
                "Thu thập càng nhiều đồ có giá trị càng tốt.",
                "Di chuyển đủ xa để kết thúc vụ cướp và quay lại gặp chủ thuê.",
            },
        },
        ["atm_robbery"] = {
            level = 1,
            requiredCops = 0,
            maxMemberCount = 5,
            simultaneous = 2,

            scenarioCooldown = 0,
            playerCooldown = SHARED_CONFIG.gameplay.cooldowns.short,

            rewards = { exp = 200 },

            label = locale("atm_robbery.label"),
            description = locale("atm_robbery.description"),
            information = locale("atm_robbery.information"),

            image = "images/scenarios/atm_robbery.png",

            infoTexts = {
                "Đến một máy ATM và tương tác với mục tiêu.",
                "Hoàn thành các hành động yêu cầu để cướp ATM thành công.",
                "Thu thập tiền vương vãi trên mặt đất.",
                "Di chuyển đủ xa để kết thúc vụ cướp.",
            },
        },
        ["store_robbery"] = {
            isActive = false, 
            level = 1,
            requiredCops = 1,
            maxMemberCount = 3,
            simultaneous = 2,

            scenarioDuration = SHARED_CONFIG.gameplay.maxDuration.short,
            scenarioCooldown = 0,
            playerCooldown = SHARED_CONFIG.gameplay.cooldowns.short,

            rewards = { exp = 150 },

            label = locale("store_robbery.label"),
            description = locale("store_robbery.description"),
            information = locale("store_robbery.information"),

            image = "images/scenarios/store_robbery.png",

            infoTexts = {
                "Đến bất kỳ cửa hàng nào được đánh dấu trên bản đồ.",
                "Dùng vũ khí để uy hiếp thu ngân bên trong cửa hàng.",
                "Lấy tiền từ thu ngân và tiếp tục vụ cướp.",
                "Bạn cũng có thể cướp các vật phẩm và kệ hàng trong cửa hàng.",
                "Di chuyển đủ xa để kết thúc vụ cướp và quay lại gặp chủ thuê.",
            },
        },
        ["pacific_bank_robbery"] = {
            isActive = false, 
            level = 1,
            requiredCops = 1,
            maxMemberCount = 8,

            scenarioCooldown = SHARED_CONFIG.gameplay.cooldowns.long,
            playerCooldown = SHARED_CONFIG.gameplay.cooldowns.short,

            rewards = { exp = 150 },

            label = locale("pacific_bank_robbery.label"),
            description = locale("pacific_bank_robbery.description"),
            information = locale("pacific_bank_robbery.information"),

            image = "images/scenarios/pacific_bank_robbery.png",

            infoTexts = {
                "Đến khu vực được đánh dấu và phá hoại bằng máy bay không người lái.",
                "Dùng máy bay và thuốc nổ để vô hiệu hóa hệ thống bảo mật.",
                "Ngân hàng mục tiêu đã được đánh dấu, dùng thuốc nổ để phá cửa.",
                "Phá cửa bảo mật để tiếp cận các tầng dưới.",
                "Mở cửa bảo mật bằng bàn phím điện tử (truy cập điện tử).",
                "Vô hiệu hóa và mở cửa két bằng SafePad.",
                "Thu thập toàn bộ tiền trong két lớn.",
                "Di chuyển đủ xa để kết thúc vụ cướp.",
            },
        },
        ["paleto_bank_robbery"] = {
            isActive = false, 
            level = 1,
            requiredCops = 1,
            maxMemberCount = 6,

            scenarioCooldown = SHARED_CONFIG.gameplay.cooldowns.medium,
            playerCooldown = SHARED_CONFIG.gameplay.cooldowns.short,

            rewards = { exp = 150 },

            label = locale("paleto_bank_robbery.label"),
            description = locale("paleto_bank_robbery.description"),
            information = locale("paleto_bank_robbery.information"),

            image = "images/scenarios/paleto_bank_robbery.png",

            infoTexts = {
                "Đến ngân hàng được đánh dấu và phá hoại hệ thống điện ở phía sau.",
                "Ngân hàng mục tiêu đã được đánh dấu, dùng thuốc nổ để phá cửa.",
                "Mở cửa két bằng bàn phím điện tử (truy cập điện tử).",
                "Thu thập toàn bộ tiền trong két lớn.",
                "Di chuyển đủ xa để kết thúc vụ cướp.",
            },
        },
        ["fleeca_bank_robbery"] = {
            isActive = false, 
            level = 1,
            requiredCops = 1,
            maxMemberCount = 4,

            scenarioCooldown = SHARED_CONFIG.gameplay.cooldowns.medium,
            playerCooldown = SHARED_CONFIG.gameplay.cooldowns.short,

            rewards = { exp = 150 },

            label = locale("fleeca_bank_robbery.label"),
            description = locale("fleeca_bank_robbery.description"),
            information = locale("fleeca_bank_robbery.information"),

            image = "images/scenarios/fleeca_bank_robbery.png",

            infoTexts = {
                "Đến bất kỳ ngân hàng nào được đánh dấu và vào bên trong.",
                "Mở cửa két bằng SafePad (truy cập điện tử).",
                "Thu thập toàn bộ tiền trong két lớn.",
                "Di chuyển đủ xa để kết thúc vụ cướp.",
            },
        },
        ["money_truck_robbery"] = {
            isActive = false, 
            level = 1,
            requiredCops = 1,
            maxMemberCount = 4,

            scenarioCooldown = SHARED_CONFIG.gameplay.cooldowns.short,
            playerCooldown = SHARED_CONFIG.gameplay.cooldowns.short,

            rewards = { exp = 150 },

            label = locale("money_truck_robbery.label"),
            description = locale("money_truck_robbery.description"),
            information = locale("money_truck_robbery.information"),

            image = "images/scenarios/money_truck_robbery.png",

            infoTexts = {
                "Đến vị trí xe tải tiền được đánh dấu.",
                "Vô hiệu hóa bảo mật và tiếp cận tiền.",
                "Di chuyển đủ xa để kết thúc vụ cướp và quay lại gặp chủ thuê.",
            },
        },
        ["ammunation_robbery"] = {
            level = 1,
            requiredCops = 0,
            maxMemberCount = 10,

            scenarioCooldown = SHARED_CONFIG.gameplay.cooldowns.long,
            playerCooldown = SHARED_CONFIG.gameplay.cooldowns.short,

            rewards = { exp = 200 },

            label = locale("ammunation_robbery.label"),
            description = locale("ammunation_robbery.description"),
            information = locale("ammunation_robbery.information"),

            image = "images/scenarios/ammunation_robbery.png",

            infoTexts = {
                "Chỉ có một trong các điểm đánh dấu là đúng. Hãy đến đúng địa điểm!",
                "Đánh cắp vũ khí và đạn dược từ cửa hàng.",
                "Di chuyển đủ xa để kết thúc vụ cướp và quay lại gặp chủ thuê.",
            },
        },
        ["cargo_ship_robbery"] = {
            isActive = false, 
            level = 1,
            requiredCops = 1,
            maxMemberCount = 8,

            scenarioCooldown = SHARED_CONFIG.gameplay.cooldowns.long,
            playerCooldown = SHARED_CONFIG.gameplay.cooldowns.short,

            rewards = { exp = 300 },

            label = locale("cargo_ship_robbery.label"),
            description = locale("cargo_ship_robbery.description"),
            information = locale("cargo_ship_robbery.information"),

            image = "images/scenarios/cargo_ship_robbery.png",

            infoTexts = {
                "Trưởng nhóm cần đến gần điểm xuất hiện thuyền để lấy thuyền.",
                "Đến vị trí tàu chở hàng được đánh dấu trên bản đồ.",
                "Tìm chìa khóa của thuyền trưởng trong cabin trên boong trên.",
                "Chìa khóa sẽ mở khóa trực thăng trên sân đỗ của tàu.",
                "Lục soát các chiến lợi phẩm rải rác khắp tàu để tìm vật phẩm có giá trị.",
                "Dùng trực thăng để nâng các container hàng lớn.",
                "Đến khu vực được đánh dấu để thả container.",
                "Thoát khỏi trực thăng để kết thúc vụ cướp.",
            },
        },
        ["bobcat_robbery"] = {
            isActive = false, 
            level = 1,
            requiredCops = 1,
            maxMemberCount = 8,

            scenarioCooldown = SHARED_CONFIG.gameplay.cooldowns.long,
            playerCooldown = SHARED_CONFIG.gameplay.cooldowns.short,

            rewards = { exp = 400 },

            label = locale("bobcat_robbery.label"),
            description = locale("bobcat_robbery.description"),
            information = locale("bobcat_robbery.information"),

            image = "images/scenarios/bobcat_robbery.png",

            infoTexts = {
                "Đến vị trí Bobcat được đánh dấu.",
                "Đột nhập vào két.",
                "Thu thập tiền mặt từ két và xe đẩy.",
                "Di chuyển đủ xa để kết thúc vụ cướp.",
            },
        },
        ["truck_robbery"] = {
            level = 1,
            requiredCops = 0,
            maxMemberCount = 8,

            scenarioCooldown = SHARED_CONFIG.gameplay.cooldowns.medium,
            playerCooldown = SHARED_CONFIG.gameplay.cooldowns.short,

            rewards = { exp = 250, money = 5000 },

            label = locale("truck_robbery.label"),
            description = locale("truck_robbery.description"),
            information = locale("truck_robbery.information"),

            image = "images/scenarios/truck_robbery.png",

            infoTexts = {
                "Đến vị trí container được đánh dấu.",
                "Dùng xe nâng để xếp container lên xe tải.",
                "Gắn chặt container vào xe tải.",
                "Lái xe tải đến điểm giao hàng được đánh dấu.",
            },
        },
        ["train_robbery"] = {
            isActive = false, 
            level = 1,
            requiredCops = 1,
            maxMemberCount = 8,

            scenarioCooldown = SHARED_CONFIG.gameplay.cooldowns.medium,
            playerCooldown = SHARED_CONFIG.gameplay.cooldowns.short,

            rewards = { exp = 250, money = 5000 },

            label = locale("train_robbery.label"),
            description = locale("train_robbery.description"),
            information = locale("train_robbery.information"),

            image = "images/scenarios/train_robbery.png",

            infoTexts = {
                "Đến vị trí tàu hỏa được đánh dấu.",
                "Chiến đấu với cảnh vệ và chiếm quyền kiểm soát toa chứa tiền.",
                "Mở container và thu thập tiền bên trong.",
                "Di chuyển đủ xa để kết thúc vụ cướp.",
            },
        },
        ["vehicle_theft_robbery"] = {
            isActive = false, 
            level = 1,
            requiredCops = 1,
            maxMemberCount = 4,

            scenarioCooldown = SHARED_CONFIG.gameplay.cooldowns.short,
            playerCooldown = SHARED_CONFIG.gameplay.cooldowns.short,

            rewards = { exp = 200, money = 3000 },

            label = locale("vehicle_theft_robbery.label"),
            description = locale("vehicle_theft_robbery.description"),
            information = locale("vehicle_theft_robbery.information"),

            image = "images/scenarios/vehicle_theft_robbery.png",

            infoTexts = {
                "Đến vị trí được đánh dấu để lấy xe tải.",
                "Đến các xe được đánh dấu và tiêu diệt cảnh vệ.",
                "Đánh cắp xe và lái đến điểm giao hàng.",
            },
        },
        ["yacht_robbery"] = {
            isActive = false, 
            level = 1,
            requiredCops = 1,
            maxMemberCount = 6,

            scenarioCooldown = SHARED_CONFIG.gameplay.cooldowns.medium,
            playerCooldown = SHARED_CONFIG.gameplay.cooldowns.short,

            rewards = { exp = 300, money = 1000 },

            label = locale("yacht_robbery.label"),
            description = locale("yacht_robbery.description"),
            information = locale("yacht_robbery.information"),

            image = "images/scenarios/yacht_robbery.png",

            infoTexts = {
                "Đến vị trí du thuyền được đánh dấu.",
                "Lên du thuyền và tìm kiếm các vật phẩm có giá trị.",
                "Thu thập tiền mặt, trang sức và các đồ có giá trị khác trên du thuyền.",
                "Di chuyển đủ xa để kết thúc vụ cướp.",
            },
        },
    }
}
