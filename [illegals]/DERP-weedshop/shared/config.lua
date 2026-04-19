Config = {}

Config.Debug = true

Config.AppId = 'weedshop'
Config.AppName = 'Green Market'
Config.AppIcon = 'fa-solid fa-cannabis'
Config.AppColor = '#4ade80'

Config.BlackMoneyItem = 'black_money'

-- Gioi han
Config.MaxActiveOrders = 3
Config.MaxDealsPerDay = 10
Config.ListingDurationMinutes = 30
Config.MinDeliveryMinutesGame = 60
Config.MaxDeliveryMinutesGame = 360
-- Preset gio game (de hien thi 1h-6h, luu nhu phut game de tuong thich)
Config.DeliveryPresets = { 60, 120, 180, 240, 300, 360 }

-- Game time ratio: 1 phut game = 2 giay real (GTA V default)
Config.GameToRealSecondsRatio = 2

-- Interaction radius
Config.DeliveryRadius = 100.0
Config.DispatchRadius = 100.0
Config.NPCSpawnRadius = 150.0
Config.NPCDespawnRadius = 200.0

-- Timing thresholds (fraction of total allowed delivery time)
-- 0.0 = order created, 1.0 = deadline
Config.TimeThresholds = {
    earlyBonus = 0.75,
    onTime = 1.0,
    lateSmall = 1.5
}

Config.Payout = {
    earlyMultiplier = 1.1,
    onTimeMultiplier = 1.0,
    lateMultiplier = 0.8
}

Config.TrustChanges = {
    delivered_early = 3,
    delivered_ontime = 2,
    delivered_late = -1,
    failed = -5,
    cancelled = -3,
    counter_refused = -2,
    deal_completed = 1
}

-- Customer AI
Config.Customer = {
    messageTickMinutes = 1,
    messageChanceBase = 0.5,
    messageChancePerTrust = 0.005,
    maxCounterRounds = 3,
    offerAmountMin = 1,
    offerAmountMax = 20,
    acceptThreshold = 0.85,
    counterReduction = 0.5,
    -- Sau khi 1 don ket thuc (delivered/failed/cancelled), NPC do khong nhan tin trong X phut game
    npcCooldownGameMinutes = 360, -- 6 gio game
    -- Moi NPC chi mua toi da N don / ngay game (reset 00:00 game time)
    maxDealsPerNpcPerDay = 5
}

-- Anti-abuse
Config.AntiAbuse = {
    findBuyerCooldownSeconds = 60,
    deliverCooldownSeconds = 5
}

-- Items config
-- Items config
-- Format: 3 nhom (Indica/Sativa/Hybrid) x 3 chat luong (low/medium/high)
-- priceMin/priceMax: gia/gram (NPC random trong khoang nay theo trust)
-- qualityBias: 1 = low quality (NPC trust thap van mua), 3 = high (can trust cao)
Config.Items = {
    -- ===== BASE (dieu cuon san) =====
    ['indica_bud_dried_weed'] = {
        label = 'Điếu Indica',
        priceMin = 50, priceMax = 100,
        qualityBias = 1
    },
    ['sativa_bud_dried_weed'] = {
        label = 'Điếu Sativa',
        priceMin = 50, priceMax = 100,
        qualityBias = 1
    },
    ['hybrid_bud_dried_weed'] = {
        label = 'Điếu Hybrid',
        priceMin = 55, priceMax = 110,
        qualityBias = 1
    },

    -- ===== INDICA =====
    ['sour_diesel_low_weed'] = {
        label = 'Sour Diesel (Kém)',
        priceMin = 40, priceMax = 90,
        qualityBias = 1
    },
    ['sour_diesel_medium_weed'] = {
        label = 'Sour Diesel (Trung Bình)',
        priceMin = 70, priceMax = 140,
        qualityBias = 2
    },
    ['sour_diesel_high_weed'] = {
        label = 'Sour Diesel (Cao Cấp)',
        priceMin = 110, priceMax = 200,
        qualityBias = 3
    },
    ['purple_haze_low_weed'] = {
        label = 'Purple Haze (Kém)',
        priceMin = 45, priceMax = 95,
        qualityBias = 1
    },
    ['purple_haze_medium_weed'] = {
        label = 'Purple Haze (Trung Bình)',
        priceMin = 75, priceMax = 150,
        qualityBias = 2
    },
    ['purple_haze_high_weed'] = {
        label = 'Purple Haze (Cao Cấp)',
        priceMin = 120, priceMax = 220,
        qualityBias = 3
    },
    ['northern_lights_low_weed'] = {
        label = 'Northern Lights (Kém)',
        priceMin = 45, priceMax = 95,
        qualityBias = 1
    },
    ['northern_lights_medium_weed'] = {
        label = 'Northern Lights (Trung Bình)',
        priceMin = 80, priceMax = 155,
        qualityBias = 2
    },
    ['northern_lights_high_weed'] = {
        label = 'Northern Lights (Cao Cấp)',
        priceMin = 125, priceMax = 230,
        qualityBias = 3
    },

    -- ===== SATIVA =====
    ['blue_dream_low_weed'] = {
        label = 'Blue Dream (Kém)',
        priceMin = 45, priceMax = 95,
        qualityBias = 1
    },
    ['blue_dream_medium_weed'] = {
        label = 'Blue Dream (Trung Bình)',
        priceMin = 80, priceMax = 155,
        qualityBias = 2
    },
    ['blue_dream_high_weed'] = {
        label = 'Blue Dream (Cao Cấp)',
        priceMin = 125, priceMax = 230,
        qualityBias = 3
    },
    ['jack_herer_low_weed'] = {
        label = 'Jack Herer (Kém)',
        priceMin = 50, priceMax = 100,
        qualityBias = 1
    },
    ['jack_herer_medium_weed'] = {
        label = 'Jack Herer (Trung Bình)',
        priceMin = 85, priceMax = 160,
        qualityBias = 2
    },
    ['jack_herer_high_weed'] = {
        label = 'Jack Herer (Cao Cấp)',
        priceMin = 130, priceMax = 240,
        qualityBias = 3
    },
    ['super_lemon_haze_low_weed'] = {
        label = 'Super Lemon Haze (Kém)',
        priceMin = 50, priceMax = 100,
        qualityBias = 1
    },
    ['super_lemon_haze_medium_weed'] = {
        label = 'Super Lemon Haze (Trung Bình)',
        priceMin = 85, priceMax = 165,
        qualityBias = 2
    },
    ['super_lemon_haze_high_weed'] = {
        label = 'Super Lemon Haze (Cao Cấp)',
        priceMin = 135, priceMax = 245,
        qualityBias = 3
    },

    -- ===== HYBRID =====
    ['og_kush_low_weed'] = {
        label = 'OG Kush (Kém)',
        priceMin = 55, priceMax = 105,
        qualityBias = 1
    },
    ['og_kush_medium_weed'] = {
        label = 'OG Kush (Trung Bình)',
        priceMin = 90, priceMax = 170,
        qualityBias = 2
    },
    ['og_kush_high_weed'] = {
        label = 'OG Kush (Cao Cấp)',
        priceMin = 140, priceMax = 260,
        qualityBias = 3
    },
    ['gsc_low_weed'] = {
        label = 'Girl Scout Cookies (Kém)',
        priceMin = 55, priceMax = 110,
        qualityBias = 1
    },
    ['gsc_medium_weed'] = {
        label = 'Girl Scout Cookies (Trung Bình)',
        priceMin = 95, priceMax = 175,
        qualityBias = 2
    },
    ['gsc_high_weed'] = {
        label = 'Girl Scout Cookies (Cao Cấp)',
        priceMin = 145, priceMax = 270,
        qualityBias = 3
    },
    ['wedding_cake_low_weed'] = {
        label = 'Wedding Cake (Kém)',
        priceMin = 60, priceMax = 115,
        qualityBias = 1
    },
    ['wedding_cake_medium_weed'] = {
        label = 'Wedding Cake (Trung Bình)',
        priceMin = 100, priceMax = 185,
        qualityBias = 2
    },
    ['wedding_cake_high_weed'] = {
        label = 'Wedding Cake (Cao Cấp)',
        priceMin = 150, priceMax = 280,
        qualityBias = 3
    }
}

-- Unlock tiers: tong trust cua player -> unlock so luong NPC
-- 5 NPC dau tien mo mac dinh (index 1-5 deu = 0 trust)
Config.UnlockTiers = {
    0, 0, 0, 0, 0,
    100, 250, 450, 700, 1000,
    1400, 1900, 2500, 3200, 4000,
    5000, 6200, 7600, 9200, 11000,
    13200, 15800, 18800, 22200, 26000,
    30200, 34800, 39800, 45200, 51000
}

-- Dispatch chance khi giao (0-1)
Config.DispatchChance = 0.35
Config.DispatchCode = '10-66'
Config.DispatchTitle = 'Giao Dich Kha Nghi'
Config.DispatchDescription = 'Phat hien hanh vi kha nghi (nghi ngo mua ban chat cam)'

-- Chat templates (random pick)
-- Format: %s (item label), %d (amount), %d (price)
Config.ChatTemplates = {
    initial_offer = {
        'Ê bro, tao muốn lấy %dg %s, giá %d/g được không?',
        'Yo, mày còn %s chứ? Tao cần %dg, trả %d/g nhé.',
        'Hey, thấy mày đăng %s. Lấy %dg giá %d/g ok hông?',
        'Sup bro, %dg %s với giá %d/g, deal không?',
        'Chào, tao hỏi %dg %s giá %d/g được không.',
        'Ê này, tao muốn mua %dg %s. Trả %d/g.',
        'Bro ơi, %dg %s giá %d/g nhé, tao cần gấp.',
        'Tao đang cần %dg %s. Mày bán %d/g không?',
        'Nghe nói mày có %s. Lấy %dg, %d/g deal hông?',
        'Hàng %s ngon không bro? Tao lấy %dg, %d/g.'
    },
    counter_npc = {
        'Giá đó chát quá bro, %d/g thôi nhé.',
        'Không được đâu, %d/g là max của tao.',
        '%d/g đi, đừng có hét giá chứ.',
        'Cao vậy ai mua, %d/g nha.',
        'Tao trả %d/g thôi, đồng ý thì chốt.',
        'Thôi bớt xíu đi, %d/g được không?',
        'Tao chỉ đưa %d/g, hợp lý rồi đó.',
        '%d/g nha, đừng ép tao.',
        'Làm ăn đàng hoàng, %d/g thôi.',
        'Tối đa %d/g, không hơn được.'
    },
    counter_player = {
        'Tôi trả %d/g, chốt không?',
        'Thế này đi, %d/g nhé.',
        '%d/g được không bro?',
        'Tôi nghĩ %d/g là hợp lý.',
        'Hay là %d/g đi?',
        'Bớt cho tôi, %d/g thôi.',
        '%d/g nhé, deal không?'
    },
    accept = {
        'Deal. Gặp tao ở %s trong %d giờ nữa.',
        'Chốt. %s, %d giờ, đừng trễ nha.',
        'OK, đến %s trong %d giờ. Tao đợi.',
        'Được, gặp ở %s sau %d giờ.',
        'Done deal, %s trong %d giờ. Mang đủ hàng.',
        'Xong, tới %s trong %d giờ. Đừng để tao chờ lâu.'
    },
    player_accept = {
        'OK, chốt giá đó đi.',
        'Được, deal thế nhé.',
        'OK chốt, hẹn gặp.',
        'Deal, đi thôi.'
    },
    player_decline = {
        'Thôi, không deal được.',
        'Khỏi, tôi tìm khách khác.',
        'Bye, giá thấp quá.'
    },
    decline = {
        'Thôi, giá cao quá. Bye.',
        'Không nổi bro, tìm khách khác đi.',
        'Pass, khi nào giảm nhắn lại.',
        'Điên à, giá đó ai mua.',
        'Bye, mày hét giá kinh thật.',
        'Khỏi, tao tìm chỗ khác.',
        'Không deal được đâu, thôi.'
    },
    delivered_early = {
        'Nice bro, sớm hơn giờ hẹn. Có tip thêm đây.',
        'Good, tao thích mày. Lần sau gọi nữa.',
        'Đỉnh thật, pro vcl. Sẽ call lại.',
        'Nhanh vậy luôn, respect. Tip đây.',
        'Mày làm ăn được đó, sẽ nhớ mặt.'
    },
    delivered_ontime = {
        'Good, đúng hẹn. Gặp lần sau.',
        'Thanks bro, hàng ổn. Gặp lại.',
        'Chuẩn, giữ phone mở nhé.',
        'OK, deal sạch sẽ. Bye.',
        'Được việc, sẽ liên lạc tiếp.'
    },
    delivered_late = {
        'Mày trễ vcl, lần sau đừng trễ.',
        'Tao đợi mỏi cả mồm. Giá trừ đó.',
        'Trễ thế này lần sau khỏi gọi.',
        'Chán mày thật, làm ăn kiểu gì.',
        'Lần sau trễ nữa là cắt đứt.'
    },
    failed = {
        'Mày chạy mất dép à? Block!',
        'Fuck, không giao được thì đừng nhận.',
        'Tao xóa số mày rồi đó.',
        'Làm ăn gì kỳ vậy, bye forever.',
        'Mày mất uy tín với tao luôn rồi.'
    },
    cancelled = {
        'Mày hủy đơn? OK, mất niềm tin đó.',
        'Hủy giữa chừng? Lần sau khó liên lạc.',
        'Pro à, hủy là hủy. Trách sao được.',
        'Mất hứng thật, lần sau chắc chọn người khác.'
    }
}