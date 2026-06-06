Config = {}

Config.Debug = false

Config.AppId = 'weedshop'
Config.AppName = 'Green Market'
Config.AppIcon = 'fa-solid fa-cannabis'
Config.AppColor = '#4ade80'

Config.BlackMoneyItem = 'money'

-- Gioi han
Config.MaxActiveOrders = 3
Config.MaxDealsPerDay = 10
Config.ListingDurationMinutes = 30

-- Preset deadline theo phut REAL (khong con lien quan game time)
Config.DeliveryPresets = { 15, 20, 25, 30, 35, 40 }

-- Timing windows (phut real), co dinh cho moi deadline
-- Flow: [deadline - earlyWindow] -> spawn NPC va bat dau giai doan early
--       [deadline]                 -> het early, bat dau ontime
--       [deadline + ontimeWindow]  -> het ontime, bat dau late
--       [deadline + lateWindow]    -> het late, auto FAIL
Config.DeliveryWindows = {
    earlyWindowMinutes = 5,  -- 5p truoc deadline = giao som (bonus)
    ontimeWindowMinutes = 5, -- 5p sau deadline = giao dung gio
    lateWindowMinutes = 5    -- 5p sau ontime = giao tre, het thi fail
}

-- Interaction radius
Config.DeliveryRadius = 100.0
Config.DispatchRadius = 100.0
Config.NPCSpawnRadius = 150.0
Config.NPCDespawnRadius = 200.0

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
    messageTickSeconds = 60,       -- Scheduler tick moi 60s real
    messageChanceBase = 0.15,      -- 15% chance/tick -> TB ~6-7 phut/listing
    messageChancePerTrust = 0.002, -- +0.2%/trust (trust 100 = +20% -> ~4-5 phut)
    maxCounterRounds = 3,
    offerAmountMin = 1,
    offerAmountMax = 20,
    acceptThreshold = 0.85,
    counterReduction = 0.5,
    -- Sau khi don ket thuc (delivered/failed/cancelled), NPC do khong nhan tin trong X phut REAL
    npcCooldownMinutes = 15,
    -- Moi NPC chi mua toi da N don / ngay REAL (reset 00:00 real)
    maxDealsPerNpcPerDay = 5,
    -- Proactive call: trust toi thieu de player chu dong goi NPC
    proactiveCallMinTrust = 80,
    -- Payout khi player chu dong goi (NPC tra thap hon 5%)
    proactiveCallPayoutMultiplier = 0.95
}

-- Anti-abuse
Config.AntiAbuse = {
    findBuyerCooldownSeconds = 60,
    deliverCooldownSeconds = 5
}

-- Items config
-- Format: 3 nhom (Indica/Sativa/Hybrid) x 3 chat luong (low/medium/high)
-- priceMin/priceMax: gia/gram (NPC random trong khoang nay theo trust)
-- qualityBias: 1 = low quality (NPC trust thap van mua), 3 = high (can trust cao)
Config.Items = {
    -- ===== BASE =====
    ['indica_bud_dried_weed'] = {
        label = 'Điếu Indica',
        priceMin = 1500, priceMax = 1550,
        qualityBias = 1
    },
    ['sativa_bud_dried_weed'] = {
        label = 'Điếu Sativa',
        priceMin = 1500, priceMax = 1550,
        qualityBias = 1
    },
    ['hybrid_bud_dried_weed'] = {
        label = 'Điếu Hybrid',
        priceMin = 1525, priceMax = 1575,
        qualityBias = 1
    },

    -- ===== LOW =====
    -- priceMin = 1550 ~ 1625

    ['sour_diesel_low_weed']      = { label = 'Sour Diesel (Kém)',          priceMin = 1600, priceMax = 1650, qualityBias = 1 },
    ['purple_haze_low_weed']      = { label = 'Purple Haze (Kém)',          priceMin = 1550, priceMax = 1600, qualityBias = 1 },
    ['northern_lights_low_weed']  = { label = 'Northern Lights (Kém)',      priceMin = 1575, priceMax = 1625, qualityBias = 1 },
    ['blue_dream_low_weed']       = { label = 'Blue Dream (Kém)',           priceMin = 1550, priceMax = 1600, qualityBias = 1 },
    ['jack_herer_low_weed']       = { label = 'Jack Herer (Kém)',           priceMin = 1600, priceMax = 1650, qualityBias = 1 },
    ['super_lemon_haze_low_weed'] = { label = 'Super Lemon Haze (Kém)',     priceMin = 1550, priceMax = 1600, qualityBias = 1 },
    ['og_kush_low_weed']          = { label = 'OG Kush (Kém)',              priceMin = 1575, priceMax = 1625, qualityBias = 1 },
    ['gsc_low_weed']              = { label = 'Girl Scout Cookies (Kém)',   priceMin = 1600, priceMax = 1650, qualityBias = 1 },
    ['wedding_cake_low_weed']     = { label = 'Wedding Cake (Kém)',         priceMin = 1625, priceMax = 1675, qualityBias = 1 },

    -- ===== MEDIUM =====
    ['sour_diesel_medium_weed']      = { label = 'Sour Diesel (Trung Bình)',         priceMin = 1675, priceMax = 1725, qualityBias = 2 },
    ['purple_haze_medium_weed']      = { label = 'Purple Haze (Trung Bình)',         priceMin = 1650, priceMax = 1700, qualityBias = 2 },
    ['northern_lights_medium_weed']  = { label = 'Northern Lights (Trung Bình)',     priceMin = 1675, priceMax = 1725, qualityBias = 2 },
    ['blue_dream_medium_weed']       = { label = 'Blue Dream (Trung Bình)',          priceMin = 1650, priceMax = 1700, qualityBias = 2 },
    ['jack_herer_medium_weed']       = { label = 'Jack Herer (Trung Bình)',          priceMin = 1700, priceMax = 1750, qualityBias = 2 },
    ['super_lemon_haze_medium_weed'] = { label = 'Super Lemon Haze (Trung Bình)',    priceMin = 1650, priceMax = 1700, qualityBias = 2 },
    ['og_kush_medium_weed']          = { label = 'OG Kush (Trung Bình)',             priceMin = 1675, priceMax = 1725, qualityBias = 2 },
    ['gsc_medium_weed']              = { label = 'Girl Scout Cookies (Trung Bình)',  priceMin = 1700, priceMax = 1750, qualityBias = 2 },
    ['wedding_cake_medium_weed']     = { label = 'Wedding Cake (Trung Bình)',        priceMin = 1725, priceMax = 1775, qualityBias = 2 },

    -- ===== HIGH =====
    ['sour_diesel_high_weed']      = { label = 'Sour Diesel (Cao Cấp)',         priceMin = 1750, priceMax = 1800, qualityBias = 3 },
    ['purple_haze_high_weed']      = { label = 'Purple Haze (Cao Cấp)',         priceMin = 1725, priceMax = 1775, qualityBias = 3 },
    ['northern_lights_high_weed']  = { label = 'Northern Lights (Cao Cấp)',     priceMin = 1750, priceMax = 1800, qualityBias = 3 },
    ['blue_dream_high_weed']       = { label = 'Blue Dream (Cao Cấp)',          priceMin = 1725, priceMax = 1775, qualityBias = 3 },
    ['jack_herer_high_weed']       = { label = 'Jack Herer (Cao Cấp)',          priceMin = 1775, priceMax = 1800, qualityBias = 3 },
    ['super_lemon_haze_high_weed'] = { label = 'Super Lemon Haze (Cao Cấp)',    priceMin = 1725, priceMax = 1775, qualityBias = 3 },
    ['og_kush_high_weed']          = { label = 'OG Kush (Cao Cấp)',             priceMin = 1750, priceMax = 1800, qualityBias = 3 },
    ['gsc_high_weed']              = { label = 'Girl Scout Cookies (Cao Cấp)',  priceMin = 1750, priceMax = 1800, qualityBias = 3 },
    ['wedding_cake_high_weed']     = { label = 'Wedding Cake (Cao Cấp)',        priceMin = 1775, priceMax = 1800, qualityBias = 3 },
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
Config.DispatchChance = 0.30
Config.DispatchCode = '10-66'
Config.DispatchTitle = 'Giao Dịch Khả Nghi'
Config.DispatchDescription = 'Phát hiện hành vi khả nghi (nghi ngờ mua bán chất cấm)'

-- Chat templates (random pick)
-- Format: %s (item label), %d (amount), %d (price)
Config.ChatTemplates = {
    initial_offer = {
        'Ê bro, tao muốn lấy %dg %s, giá %d/g được không?',
        'Yo, tao cần %dg %s, trả %d/g nhé.',
        'Hey, lấy %dg %s giá %d/g ok hông?',
        'Sup bro, %dg %s với giá %d/g, deal không?',
        'Chào, tao hỏi %dg %s giá %d/g được không.',
        'Ê này, tao muốn mua %dg %s. Trả %d/g.',
        'Bro ơi, %dg %s giá %d/g nhé, tao cần gấp.',
        'Tao đang cần %dg %s, bán %d/g không?',
        'Lấy %dg %s giá %d/g deal hông bro?',
        'Cho tao %dg %s, trả %d/g được chứ?',
        'Ê bro, tao đang cần %dg %s, %d/g bán không?',
        'Yo, có %dg %s không? Tao trả %d/g.',
        'Tao cần %dg %s gấp, %d/g chốt được không?',
        'Bro, có hàng không? %dg %s, %d/g nhé.',
        'Ê, tao đang thiếu %dg %s, %d/g bán không?',
        'Có %dg %s không bro? Tao trả %d/g, sạch sẽ.',
        'Tao tìm %dg %s nãy giờ, %d/g ok không?',
        'Bro, %dg %s, %d/g, có thì nói nhanh.',
        'Tao cần %dg %s liền, %d/g, đừng để tao chờ.',
        'Ê mày, có %dg %s không? Tao trả %d/g.',
        'Đang cần %dg %s, %d/g, chơi không?',
        'Bro, tao cần %dg %s, %d/g, có hàng không?',
        'Có %dg %s không? %d/g tao lấy hết.',
        'Tao đang gom %dg %s, %d/g, bán không?',
        'Ê, %dg %s, %d/g, mày có không?',
        'Tao cần %dg %s, %d/g, nhanh gọn lẹ.',
        'Bro, %dg %s, %d/g, có thì chốt luôn.',
        'Có %dg %s không? Tao trả %d/g, khỏi lằng nhằng.',
        'Tao hỏi thật, %dg %s, %d/g bán không?',
        'Ê, %dg %s, %d/g, mày có thì deal liền.'
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
        'Tối đa %d/g, không hơn được.',
        'Giá này mày đùa tao à, %d/g thôi.',
        'Không có cửa đâu, %d/g là hết mức.',
        '%d/g, chốt thì chốt không tao out.',
        'Mày hét giá cao quá, %d/g đi.',
        '%d/g, đừng thử tao.',
        'Tao không ngu đâu, %d/g thôi.',
        '%d/g, không thêm 1 đồng.',
        'Bớt ảo đi, %d/g là đẹp.',
        '%d/g, không thì thôi.',
        'Mày nghĩ tao là gà à, %d/g thôi.',
        '%d/g, đừng kéo dài.',
        'Giá đó bán cho người khác đi, tao %d/g.',
        '%d/g, take it or leave it.',
        'Đừng làm quá, %d/g thôi bro.',
        '%d/g, tao không trả hơn.',
        'Tao nói thẳng, %d/g.',
        '%d/g, không thích thì biến.',
        '%d/g, tao không thích bị chém.',
        'Chơi đẹp đi, %d/g thôi.',
        '%d/g, lần cuối.'
    },
    counter_player = {
        'Tao trả %d/g, chốt không?',
        'Thế này đi, %d/g nhé.',
        '%d/g được không bro?',
        'Tao nghĩ %d/g là hợp lý.',
        'Hay là %d/g đi?',
        'Bớt cho Tao, %d/g thôi.',
        '%d/g nhé, deal không?',
        '%d/g thôi, chốt nhanh đi.',
        'Tao không lên nữa, %d/g.',
        '%d/g là hết cỡ rồi.',
        '%d/g, đừng ép giá nữa.',
        'Tao trả %d/g, không hơn.',
        '%d/g, hợp lý rồi.',
        '%d/g nhé, đừng kéo dài.',
        'Tao nói thẳng %d/g.',
        '%d/g, ok thì làm.',
        '%d/g thôi, nhanh gọn.',
        '%d/g, không thương lượng thêm.',
        '%d/g, giá cuối.',
        'Tao chỉ trả %d/g.',
        '%d/g, chốt không?',
        '%d/g, không thì thôi.',
        '%d/g, fair rồi.',
        '%d/g, đừng làm khó.',
        '%d/g, hết mức.',
        '%d/g, Tao không thêm.',
        '%d/g, quyết đi.'
    },
    accept = {
        'Deal. Gặp tao ở %s trong %d phút nữa.',
        'Chốt. %s, %d phút, đừng trễ nha.',
        'OK, đến %s trong %d phút. Tao đợi.',
        'Được, gặp ở %s sau %d phút.',
        'Done deal, %s trong %d phút. Mang đủ hàng.',
        'Xong, tới %s trong %d phút. Đừng để tao chờ lâu.',
        'OK, %s, %d phút nữa, đừng fail.',
        'Chốt, %s, %d phút, tới đúng giờ.',
        'Deal, %s sau %d phút, mang đủ hàng.',
        'Ok bro, %s %d phút, tao chờ.',
        'Được, %s, %d phút, nhanh lên.',
        '%s, %d phút nữa gặp, đừng trễ.',
        'Deal xong, %s %d phút.',
        'OK, %s, %d phút, clean deal.',
        'Chốt rồi, %s, %d phút nữa.',
        'Gặp ở %s, %d phút, nhớ đó.',
        '%s, %d phút nữa, đừng để tao đợi.',
        'Ok, %s trong %d phút, lẹ lên.',
        'Deal, %s %d phút, tới đúng giờ.',
        '%s, %d phút, không sai giờ.',
        'OK bro, %s %d phút.',
        'Chốt lẹ, %s %d phút.',
        '%s %d phút, đừng trễ.',
        'Deal, %s %d phút nữa.',
        '%s, %d phút, xong việc.',
        'OK, %s %d phút, nhanh.'
    },
    late_reminder = {
        'Ê, mày đâu rồi? Tao đợi mỏi mòn đây.',
        'Bro, quá giờ rồi đó. Đến nhanh đi.',
        'Mày làm gì mà lâu thế? Tao hết kiên nhẫn rồi.',
        'Ê đến chưa? Tao không đợi được nữa đâu.',
        'Trễ rồi đấy bro, nhanh lên không tao đi.',
        'Hối tí đi, tao đứng đây không phải trò đùa.',
        'Mày đang ở đâu? Đến không thì nói.',
        'Nhanh gọn vậy mới là pro, tao thích.',
        'Làm việc chuẩn chỉnh, giữ liên lạc.',
        'Tới sớm, điểm cộng lớn đó.',
        'Pro vcl, lần sau tao gọi mày.',
        'Nhanh thế này thì hợp tác dài.',
        'Đúng kiểu tao cần, good job.',
        'Ok, mày có tương lai đó.',
        'Làm ăn vậy mới đáng tiền.',
        'Nice, giữ phong độ nhé.',
        'Tao ưng mày rồi đó.',
        'Giao sớm, respect.',
        'Đỉnh, không có gì để chê.',
        'Chuẩn bài, sẽ call lại.',
        'Mày làm nhanh thật.',
        'Pro, lần sau nhớ ưu tiên tao.',
        'Ổn áp, tiếp tục vậy đi.',
        'Đáng tin cậy đó bro.',
        'Giao kiểu này mới chất.',
        'Respect, làm ăn ngon.',
        'OK, mày pass test rồi.'
    },
    player_accept = {
        'OK, chốt giá đó đi.',
        'Được, deal thế nhé.',
        'OK chốt, hẹn gặp.',
        'Deal, đi thôi.',
        'OK, chốt giá này luôn.',
        'Deal, không nói nhiều.',
        'Được, giá đó ổn.',
        'OK bro, làm lẹ đi.',
        'Chốt, triển luôn.',
        'Giá vậy là được rồi.',
        'OK, không mặc cả nữa.',
        'Deal nhanh gọn.',
        'Được, tiến hành đi.',
        'OK, làm việc thôi.',
        'Chốt luôn, khỏi dài dòng.',
        'Giá này hợp lý, ok.',
        'Deal, không suy nghĩ thêm.',
        'OK, tao đồng ý.',
        'Chốt, làm lẹ.',
        'Được rồi, đi tiếp.',
        'OK bro, triển.',
        'Deal, không đổi nữa.',
        'Chốt giá này, đi luôn.',
        'OK, xong kèo.'
    },
    player_decline = {
        'Thôi, không deal được.',
        'Khỏi, Tao tìm khách khác.',
        'Bye, giá thấp quá.',
        'Không ổn, tao pass.',
        'Giá này không chơi.',
        'Thôi khỏi, không hợp.',
        'Tao không deal kiểu này.',
        'Không được đâu.',
        'Bỏ đi, kiếm kèo khác.',
        'Không ổn, tao out.',
        'Giá này thì thôi.',
        'Không hợp lý, bỏ.',
        'Thôi, không làm nữa.',
        'Pass, tìm người khác.',
        'Không chơi giá này.',
        'Thôi bro, kèo fail.',
        'Không ok, tao đi.',
        'Bỏ kèo, không hợp.',
        'Giá này không nuốt nổi.',
        'Không deal được.',
        'Thôi khỏi nói nữa.',
        'Out luôn.',
        'Không có cửa.'
    },
    decline = {
        'Thôi, giá cao quá. Bye.',
        'Không nổi bro, tìm khách khác đi.',
        'Pass, khi nào giảm nhắn lại.',
        'Điên à, giá đó ai mua.',
        'Bye, mày hét giá kinh thật.',
        'Khỏi, tao tìm chỗ khác.',
        'Không deal được đâu, thôi.',
        'Giá này mày đùa tao à, thôi.',
        'Không chơi kiểu đó đâu.',
        'Thôi nghỉ, không hợp.',
        'Tao không ngu mà mua giá đó.',
        'Bỏ đi bro, không deal.',
        'Không ổn, tìm người khác.',
        'Giá này thì tao chịu.',
        'Không có cửa đâu.',
        'Thôi, kèo này bỏ.',
        'Tao không quan tâm nữa.',
        'Không đáng tiền.',
        'Thôi khỏi nói nữa.',
        'Pass luôn.',
        'Không hợp lý.',
        'Bỏ đi, đừng ép.',
        'Tao không mua kiểu này.',
        'Không ổn đâu.',
        'Thôi bro, hết chuyện.',
        'Không deal được.',
        'Kèo này fail.'
    },
    delivered_early = {
        'Nice bro, sớm hơn giờ hẹn. Có tip thêm đây.',
        'Good, tao thích mày. Lần sau gọi nữa.',
        'Đỉnh thật, pro vcl. Sẽ call lại.',
        'Nhanh vậy luôn, respect. Tip đây.',
        'Mày làm ăn được đó, sẽ nhớ mặt.',
        'Nhanh vậy là quá ok.',
        'Làm việc chuẩn chỉnh.',
        'Tới sớm, tao thích.',
        'Nhanh gọn, đẹp.',
        'Đúng kiểu tao cần.',
        'Pro đấy, giữ phong độ.',
        'Làm ăn vậy mới ổn.',
        'Tao ưng mày rồi.',
        'Đáng tin cậy.',
        'Nhanh như này thì quá ngon.',
        'Respect bro.',
        'Ổn áp, lần sau tiếp.',
        'Chuẩn bài.',
        'Good job thật sự.',
        'Mày làm việc có tâm.',
        'Được việc đó.',
        'Nice, không chê.',
        'Giữ liên lạc nhé.',
        'OK, mày ổn.',
        'Làm ăn vậy mới lâu dài.'
    },
    delivered_ontime = {
        'Good, đúng hẹn. Gặp lần sau.',
        'Thanks bro, hàng ổn. Gặp lại.',
        'Chuẩn, giữ phone mở nhé.',
        'OK, deal sạch sẽ. Bye.',
        'Được việc, sẽ liên lạc tiếp.',
        'Đúng giờ, ok.',
        'Chuẩn hẹn, tốt.',
        'Không lệch phút nào.',
        'Đúng giờ là điểm cộng.',
        'Ổn, giữ vậy nhé.',
        'Giao đúng hẹn, ok.',
        'Làm việc nghiêm túc.',
        'Đúng giờ, tao thích.',
        'Chuẩn chỉnh.',
        'Không trễ là tốt rồi.',
        'Ổn áp.',
        'Giữ phong độ.',
        'Được việc.',
        'Không có gì phàn nàn.',
        'Good.',
        'Chuẩn kèo.',
        'OK, tiếp tục vậy.',
        'Ổn bro.',
        'Không vấn đề.',
        'Làm tốt.'
    },
    delivered_late = {
        'Mày trễ vcl, lần sau đừng trễ.',
        'Tao đợi mỏi cả mồm. Giá trừ đó.',
        'Trễ thế này lần sau khỏi gọi.',
        'Chán mày thật, làm ăn kiểu gì.',
        'Lần sau trễ nữa là cắt đứt.',
        'Trễ kiểu này không ổn đâu.',
        'Mày làm ăn vậy ai chơi lại.',
        'Tao không thích chờ đợi.',
        'Lần sau mà trễ nữa thì thôi.',
        'Trễ quá rồi bro.',
        'Mày đang test kiên nhẫn tao à?',
        'Làm ăn chậm vậy là mất khách.',
        'Trễ nữa là cắt luôn.',
        'Tao không có thời gian cho mày.',
        'Trễ kiểu này khó hợp tác.',
        'Mày làm tao mất hứng.',
        'Đừng để tao nhắc lần 2.',
        'Trễ thêm lần nữa là xong.',
        'Chán thật, làm ăn gì vậy.',
        'Tao đợi không phải để chơi.',
        'Trễ quá mức rồi.',
        'Không ổn đâu bro.',
        'Mày phải cải thiện đi.',
        'Lần sau chuẩn giờ dùm.',
        'Tao không thích kiểu này.'
    },
    failed = {
        'Mày chạy mất dép à? Block!',
        'Fuck, không giao được thì đừng nhận.',
        'Tao xóa số mày rồi đó.',
        'Làm ăn gì kỳ vậy, bye forever.',
        'Mày mất uy tín với tao luôn rồi.',
        'Mất hút luôn à? Đừng liên lạc nữa.',
        'Làm ăn kiểu này nghỉ đi.',
        'Block mày luôn cho nhanh.',
        'Tao không muốn thấy số mày nữa.',
        'Thất vọng thật sự.',
        'Mày out game luôn đi.',
        'Đừng nhận job nếu không làm.',
        'Chấm hết từ đây.',
        'Mất uy tín nặng.',
        'Bye luôn, không nói nhiều.',
        'Mày fail nặng rồi.',
        'Đừng quay lại nữa.',
        'Xong rồi, tao cắt liên lạc.',
        'Không có lần 2.',
        'Mày tự hủy cơ hội.',
        'Game over cho mày.',
        'Tao không cần mày nữa.',
        'Kết thúc ở đây.',
        'Đừng xuất hiện nữa.',
        'Bye forever.'
    },
    cancelled = {
        'Mày hủy đơn? OK, mất niềm tin đó.',
        'Hủy giữa chừng? Lần sau khó liên lạc.',
        'Pro à, hủy là hủy. Trách sao được.',
        'Mất hứng thật, lần sau chắc chọn người khác.',
        'Cút.',
        'Mày làm mất uy tín rồi.',
        'Hủy ngang vậy ai chơi.',
        'Tao không thích kiểu này.',
        'Lần sau đừng nhận nữa.',
        'Mất thời gian tao.',
        'Hủy là mất điểm đó.',
        'Tao ghi nhớ rồi.',
        'Làm ăn vậy khó lâu dài.',
        'Hủy kiểu này thì thôi.',
        'Không chuyên nghiệp.',
        'Tao không vui đâu.',
        'Bỏ giữa chừng vậy à.',
        'Không ổn chút nào.',
        'Lần sau khó nói chuyện.',
        'Mày tự làm khó mình thôi.',
        'Hủy là mất cơ hội.',
        'Thôi, kết thúc ở đây.',
        'Không đáng tin nữa.',
        'Bye luôn.'
    },
    -- Player chu dong goi NPC
    proactive_player_offer = {
        'Yo bro, tao có %dg %s đây, %d/g lấy không?',
        'Ê, tao đang có %dg %s giá %d/g, mày có hứng không?',
        'Bro, %dg %s với giá %d/g, deal không?',
        'Tao đẩy %dg %s, %d/g thôi. Chơi không?',
        'Hàng ngon đây, %dg %s giá %d/g, lấy đi bro.',
        'Tao có hàng đây, %dg %s, %d/g, lấy không?',
        'Bro, %dg %s, %d/g, hàng nóng đó.',
        '%dg %s, %d/g, chốt lẹ.',
        'Tao đẩy %dg %s, %d/g, không nói nhiều.',
        '%dg %s đây, %d/g, chơi không?',
        'Có %dg %s, %d/g, hàng chuẩn.',
        '%dg %s, %d/g, không ép.',
        'Tao đang có %dg %s, %d/g.',
        '%dg %s, %d/g, nhanh đi.',
        'Deal %dg %s, %d/g.',
        '%dg %s, %d/g, giá đẹp.',
        'Tao có %dg %s, %d/g, cần không?',
        '%dg %s, %d/g, hàng xịn.',
        '%dg %s, %d/g, chốt nhanh.',
        'Bro, %dg %s, %d/g.',
        '%dg %s, %d/g, không vòng vo.',
        'Tao có hàng, %dg %s, %d/g.',
        '%dg %s, %d/g, deal không?',
        '%dg %s, %d/g, lẹ lên.',
        '%dg %s, %d/g, hàng ngon.'
    },
    proactive_accept = {
        'Ok, gặp tao ở %s trong %d phút nữa.',
        'Deal. %s, %d phút, tao đợi.',
        'Được, đến %s sau %d phút nhé.',
        'OK bro, %s trong %d phút. Cảm ơn đã gọi.',
        'Chốt, %s sau %d phút. Khỏi lo.',
        'OK, %s %d phút nữa.',
        'Deal, %s %d phút.',
        'Được, %s %d phút, tới đúng giờ.',
        'Chốt, %s %d phút.',
        '%s, %d phút, tao đợi.',
        'OK bro, %s %d phút.',
        'Gặp ở %s sau %d phút.',
        '%s %d phút, đừng trễ.',
        'Deal xong, %s %d phút.',
        '%s, %d phút nữa gặp.',
        'OK, tới %s trong %d phút.',
        'Chốt kèo, %s %d phút.',
        '%s %d phút, nhanh lên.',
        'Deal, %s %d phút nhé.',
        '%s %d phút, nhớ đó.',
        'OK, %s %d phút, đi lẹ.',
        '%s %d phút, không sai giờ.',
        'Chốt, %s %d phút.',
        '%s %d phút, tới liền.',
        'OK, gặp %s %d phút.'
    },
    proactive_busy = {
        'Xin lỗi bro, giờ tao đang bận, để lần khác.',
        'Tao đang có deal khác rồi, lần sau nhé.',
        'Tiếc ghê, giờ không tiện. Gọi lại sau đi.',
        'Bận quá bro, lúc khác tao sẽ nhận hàng.',
        'Gia đình đang có việc, chưa mua được đâu.',
        'Giờ không rảnh đâu.',
        'Đang bận, để sau.',
        'Tao có việc rồi.',
        'Không tiện lúc này.',
        'Đang chạy kèo khác.',
        'Giờ không giao dịch.',
        'Bận việc riêng.',
        'Để hôm khác.',
        'Không có thời gian.',
        'Đang lo việc khác.',
        'Không nhận lúc này.',
        'Để sau đi.',
        'Giờ không ok.',
        'Đang kín lịch.',
        'Không tiện bro.',
        'Để hôm sau.',
        'Giờ không làm được.',
        'Bận rồi.',
        'Không rảnh.',
        'Out tạm.'
    },
    proactive_too_many_today = {
        'Hôm nay tao đã mua đủ rồi, mai nhé.',
        'Đủ hàng cho hôm nay rồi bro, mai liên hệ lại.',
        'Tao full hàng rồi, ngày mai qua.',
        'Hết ngân sách hôm nay, mai mua tiếp.',
        'Hôm nay đủ hàng rồi.',
        'Tao full rồi.',
        'Không cần thêm hôm nay.',
        'Đủ quota rồi.',
        'Hôm nay nghỉ mua.',
        'Mai quay lại.',
        'Không nhận thêm.',
        'Đủ rồi bro.',
        'Hôm nay không mua nữa.',
        'Full kho rồi.',
        'Không còn nhu cầu.',
        'Đủ dùng rồi.',
        'Mai tính tiếp.',
        'Hôm nay stop.',
        'Không cần thêm.',
        'Đã đủ hàng.',
        'Không nhập nữa.',
        'Đủ ngân sách rồi.',
        'Ngày mai nhé.',
        'Hôm nay kết thúc.'
    },
    proactive_npc_interested = {
        'OK bro, deal thế đi. Chốt thời gian giao đi.',
        'Được, giá hợp lý đó. Khi nào mày giao được?',
        'Ok deal, chọn thời gian giao hẹn đi.',
        'Hợp lý, chọn giờ giao nhé bro.',
        'Tao đồng ý, cho tao biết mấy giờ nhận.',
        'Deal, báo giờ với địa điểm đi.',
        'OK, sắp xếp thời gian giao giúp tao với.',
        'Nghe ổn đó, nói giờ đi.',
        'OK, chốt giờ giao.',
        'Giá được, hẹn giờ.',
        'Ổn, khi nào giao?',
        'Deal, chọn thời gian.',
        'Được, báo giờ cụ thể.',
        'OK bro, nói giờ đi.',
        'Giá hợp lý, hẹn luôn.',
        'Chốt, mày giao lúc nào?',
        'Deal, báo thời gian.',
        'Ổn, chọn giờ.',
        'OK, lên lịch đi.',
        'Giá đẹp, hẹn giao.',
        'Được, nói giờ.',
        'Deal rồi, giờ đâu?',
        'OK, thời gian nào?',
        'Chốt, mày sắp xếp đi.',
        'Giá này ok, giờ giao?',
        'Deal, báo tao.',
        'OK, triển.'
    },
    proactive_player_confirm = {
        'OK, gặp ở %s sau %d phút nhé.',
        'Tao đến %s trong %d phút, đợi tao.',
        'Chốt, hẹn %s sau %d phút.',
        'Được, có mặt ở %s sau %d phút.',
        'OK bro, %s trong %d phút, tao đang đi đây.',
        'Deal, gặp ở %s sau %d phút.',
        'OK, tao tới %s sau %d phút.',
        '%s %d phút, tao có mặt.',
        'Chốt, %s %d phút nữa.',
        'Tao tới %s trong %d phút.',
        '%s %d phút, đợi tao.',
        'OK, đang tới %s, %d phút.',
        '%s %d phút, chuẩn bị.',
        'Chốt kèo, %s %d phút.',
        'Tao tới liền, %s %d phút.',
        '%s %d phút, không trễ.',
        'OK bro, %s %d phút.',
        '%s %d phút, tao đang chạy.',
        'Chốt, gặp %s %d phút.',
        '%s %d phút, tới ngay.',
        'OK, %s %d phút, on the way.',
        '%s %d phút, chuẩn.',
        'Đang tới %s, %d phút.',
        '%s %d phút, đợi tao.',
        'OK, %s %d phút nữa.',
        'Deal, %s %d phút.'
    }
}