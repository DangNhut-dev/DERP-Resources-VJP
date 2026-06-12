return {

	['ticket'] = {
		label = 'Vé Đổi Thưởng',
		description = '',
		weight = 0,
		stack = true,
	},

	['hat_item'] = {
		label   = 'Keo Vuốt Tóc',
		weight  = 0,
		stack   = false,
		close   = true,
		client  = {
			export = 'chowhathair.useHatItem' 
		},
		description = "Làm gọn tóc để dễ mang mũ.",
	},

	['skinar15fullpurple'] = {
		label = 'AR15 Full Purple',
		description = '',
		weight = 0,
		stack = false,
		client = {
			image = "WEAPON_AR15FULL.png",
		}
	},

	['skinar15fullwhite'] = {
		label = 'AR15 Full White',
		description = '',
		weight = 0,
		stack = false,
		client = {
			image = "WEAPON_AR15FULL.png",
		}
	},

	['skinbayonetknife'] = {
		label   = 'Bayonet Knife',
		description = '',
		weight  = 0,
		stack = false,
		client = {
			image = "WEAPON_BAYONETKNIFE.png",
		}
	},

	['skinvanillabfknife'] = {
		label   = 'Vanilla Butterfly Knife',
		description = '',
		weight  = 0,
		stack = false,
		client = {
			image = "WEAPON_BFKNIFE.png",
		}
	},

	['skinchbfnife'] = {
		label   = 'Case Hardened Butterfly Knife',
		description = '',
		weight  = 0,
		stack = false,
		client = {
			image = "WEAPON_CHBFKNIFE.png",
		}
	},

	['skincrimsonbfknife'] = {
		label   = 'Crimson Butterfly Knife',
		description = '',
		weight  = 0,
		stack = false,
		client = {
			image = "WEAPON_CRIMSONBFKNIFE.png",
		}
	},

	['skinflipknife'] = {
		label   = 'Flip Knife',
		description = '',
		weight  = 0,
		stack = false,
		client = {
			image = "WEAPON_FLIPKNIFE.png",
		}
	},

	['skinforestbfknife'] = {
		label   = 'Forest Butterfly Knife',
		description = '',
		weight  = 0,
		stack = false,
		client = {
			image = "WEAPON_FORESTBFKNIFE.png",
		}
	},

	['skingutknife'] = {
		label   = 'Gut Knife',
		description = '',
		weight  = 0,
		stack = false,
		client = {
			image = "WEAPON_GUTKNIFE.png",
		}
	},

	['skinhuntsmanknife'] = {
		label   = 'Huntsman Knife',
		description = '',
		weight  = 0,
		stack = false,
		client = {
			image = "WEAPON_HUNTSMANKNIFE.png",
		}
	},

	['skinsafaribfknife'] = {
		label   = 'Safari Mesh Butterfly Knife',
		description = '',
		weight  = 0,
		stack = false,
		client = {
			image = "WEAPON_SAFARIBFKNIFE.png",
		}
	},

	['skinscorchedbfknife'] = {
		label   = 'Scorched Butterfly Knife',
		description = '',
		weight  = 0,
		stack = false,
		client = {
			image = "WEAPON_SCORCHEDBFKNIFE.png",
		}
	},

	['skinslaughterbfknife'] = {
		label   = 'Slaughter Butterfly Knife',
		description = '',
		weight  = 0,
		stack = false,
		client = {
			image = "WEAPON_SLAUGHTERBFKNIFE.png",
		}
	},

	['skinstainedrbfknife'] = {
		label   = 'Stained Butterfly Knife',
		description = '',
		weight  = 0,
		stack = false,
		client = {
			image = "WEAPON_STAINEDRBFKNIFE.png",
		}
	},

	['skinurbanrbfknife'] = {
		label   = 'Urban Masked Butterfly Knife',
		description = '',
		weight  = 0,
		stack = false,
		client = {
			image = "WEAPON_URBANRBFKNIFE.png",
		}
	},

	['skinfadebutterfly'] = {
		label   = 'Fade Butter Fly',
		description = '',
		weight  = 0,
		stack = false,
		client = {
			image = "WEAPON_FADEBFKNIFE.png",
		}
	},

	['skinblueknife'] = {
		label   = 'Blue Knife',
		description = '',
		weight  = 0,
		stack = false,
		client = {
			image = "WEAPON_BLUEBFKNIFE.png",
		}
	},

	

	-- ['testburger'] = {
	-- 	label = 'Test Burger',
	-- 	weight = 220,
	-- 	degrade = 60,
	-- 	client = {
	-- 		image = 'burger_chicken.png',
	-- 		status = { hunger = 200000 },
	-- 		anim = 'eating',
	-- 		prop = 'burger',
	-- 		usetime = 2500,
	-- 		export = 'ox_inventory_examples.testburger'
	-- 	},
	-- 	server = {
	-- 		export = 'ox_inventory_examples.testburger',
	-- 		test = 'what an amazingly delicious burger, amirite?'
	-- 	},
	-- 	buttons = {
	-- 		{
	-- 			label = 'Lick it',
	-- 			action = function(slot)
	-- 				print('You licked the burger')
	-- 			end
	-- 		},
	-- 		{
	-- 			label = 'Squeeze it',
	-- 			action = function(slot)
	-- 				print('You squeezed the burger :(')
	-- 			end
	-- 		},
	-- 		{
	-- 			label = 'What do you call a vegan burger?',
	-- 			group = 'Hamburger Puns',
	-- 			action = function(slot)
	-- 				print('A misteak.')
	-- 			end
	-- 		},
	-- 		{
	-- 			label = 'What do frogs like to eat with their hamburgers?',
	-- 			group = 'Hamburger Puns',
	-- 			action = function(slot)
	-- 				print('French flies.')
	-- 			end
	-- 		},
	-- 		{
	-- 			label = 'Why were the burger and fries running?',
	-- 			group = 'Hamburger Puns',
	-- 			action = function(slot)
	-- 				print('Because they\'re fast food.')
	-- 			end
	-- 		}
	-- 	},
	-- 	consume = 0.3
	-- },

	['mu']        = { label = 'Mũ',         weight = 0, stack = false, close = true },
	['matna']     = { label = 'Mặt nạ',     weight = 0, stack = false, close = true },
	['aokhoac']   = { label = 'Áo khoác',   weight = 0, stack = false, close = true },
	['aotrong']   = { label = 'Áo trong',    weight = 0, stack = false, close = true },
	['tay']       = { label = 'Găng tay',    weight = 0, stack = false, close = true },
	['quan']      = { label = 'Quần',        weight = 0, stack = false, close = true },
	['giay']      = { label = 'Giày',        weight = 0, stack = false, close = true },
	['kinh']      = { label = 'Kính',        weight = 0, stack = false, close = true },
	['khuyentai'] = { label = 'Khuyên tai',  weight = 0, stack = false, close = true },
	['daychuyen'] = { label = 'Dây chuyền',  weight = 0, stack = false, close = true },
	['balo']      = { label = 'Ba lô',       weight = 0, stack = false, close = true },
	['giap']      = { label = 'Giáp',        weight = 0, stack = false, close = true },
	['dongho']    = { label = 'Đồng hồ',     weight = 0, stack = false, close = true },
	['vongtay']   = { label = 'Vòng tay',    weight = 0, stack = false, close = true },
	['huyhieu']   = { label = 'Huy Hiệu',    weight = 0, stack = false, close = true },

	['balo_111_0_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_111_1_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_112_0_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_112_1_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_112_2_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_112_3_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_112_4_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_112_5_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_112_6_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_112_7_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_113_0_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_113_1_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_114_0_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_115_0_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_116_0_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_117_0_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_118_0_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_118_1_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_118_2_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_119_0_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_119_1_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_119_2_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_119_3_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_120_0_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_120_1_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_120_2_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_120_3_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_120_4_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_120_5_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_120_6_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_121_0_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_122_0_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_122_1_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_122_2_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_122_3_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_123_0_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_124_0_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_125_0_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_126_0_0']   = { label = 'Mẫu balo',    weight = 0, stack = false, close = true },
	['balo_111_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_111_10_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_111_11_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_111_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_111_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_111_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_111_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_111_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_111_6_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_111_7_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_111_8_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_111_9_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_112_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_112_10_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_112_11_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_112_12_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_112_13_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_112_14_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_112_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_112_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_112_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_112_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_112_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_112_6_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_112_7_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_112_8_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_112_9_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_113_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_113_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_113_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_113_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_114_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_114_10_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_114_11_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_114_12_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_114_13_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_114_14_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_114_15_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_114_16_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_114_17_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_114_18_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_114_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_114_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_114_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_114_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_114_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_114_6_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_114_7_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_114_8_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_114_9_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_115_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_115_10_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_115_11_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_115_12_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_115_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_115_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_115_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_115_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_115_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_115_6_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_115_7_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_115_8_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_115_9_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_116_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_116_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_116_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_117_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_117_10_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_117_11_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_117_12_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_117_13_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_117_14_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_117_15_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_117_16_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_117_17_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_117_18_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_117_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_117_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_117_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_117_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_117_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_117_6_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_117_7_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_117_8_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_117_9_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_118_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_118_10_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_118_11_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_118_12_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_118_13_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_118_14_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_118_15_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_118_16_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_118_17_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_118_18_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_118_19_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_118_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_118_20_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_118_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_118_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_118_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_118_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_118_6_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_118_7_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_118_8_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_118_9_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_119_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_119_10_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_119_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_119_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_119_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_119_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_119_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_119_6_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_119_7_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_119_8_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_119_9_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_120_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_121_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_121_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_121_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_121_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_121_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_121_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_121_6_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_121_7_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_121_8_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_122_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_122_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_122_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_122_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_122_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_122_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_123_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_124_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_124_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_124_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_124_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_124_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_124_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_124_6_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_124_7_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_124_8_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_125_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_125_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_125_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_125_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_125_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_125_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_126_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_126_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_126_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_126_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_126_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_126_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_126_6_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_126_7_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_127_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_127_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_127_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_127_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_127_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_127_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_127_6_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_128_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_128_10_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_128_11_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_128_12_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_128_13_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_128_14_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_128_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_128_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_128_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_128_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_128_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_128_6_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_128_7_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_128_8_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_128_9_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_130_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_130_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_131_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_131_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_131_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_132_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_132_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_132_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_132_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_132_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_132_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_132_6_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_132_7_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_132_8_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_132_9_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_133_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_133_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_133_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_134_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_135_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_136_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_136_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_136_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_137_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_138_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_138_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_138_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_139_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_139_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_139_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_139_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_139_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_139_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_139_6_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_140_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_142_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_142_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_142_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_142_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_142_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_142_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_142_6_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_142_7_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_142_8_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },


	['balo_127_0_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_128_0_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_129_0_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_129_1_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_129_2_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_130_0_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_130_1_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_131_0_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_131_1_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_132_0_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_132_1_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_133_0_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_133_1_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_133_2_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_134_0_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_134_1_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_135_0_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_135_1_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_135_2_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_136_0_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_136_1_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_136_2_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_137_0_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_137_1_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_137_2_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_137_3_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_137_4_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_137_5_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_137_6_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_137_7_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_137_8_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_137_9_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_138_0_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_138_1_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_138_2_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_138_3_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_138_4_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_138_5_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_138_6_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_138_7_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_139_0_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_140_0_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_140_1_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_140_2_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_140_3_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_140_4_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_140_5_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_141_0_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_141_1_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_141_2_0'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_143_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_143_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_143_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_145_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_145_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_150_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_150_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_150_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_150_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_150_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_152_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_152_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_152_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_152_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_152_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_152_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_152_6_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_152_7_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_152_8_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_152_9_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_154_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_154_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_155_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_155_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_155_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_155_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_155_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_155_6_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_156_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_158_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_158_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_158_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_158_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_158_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_158_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_160_10_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_160_13_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_160_6_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_160_7_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_160_8_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_161_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_163_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_166_6_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_167_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_169_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_169_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_169_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_169_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_171_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_171_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_173_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_173_10_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_173_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_173_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_173_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_173_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_173_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_173_6_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_173_7_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_173_8_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_173_9_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_177_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_182_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_182_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_192_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_195_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_195_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_195_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_198_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_198_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_198_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_198_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_198_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_198_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_205_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_206_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_207_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_207_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_207_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_207_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_207_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_208_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_208_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_208_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_208_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_208_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_208_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_208_6_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_209_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_209_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_209_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_209_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_209_4_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_209_5_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_210_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_221_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_221_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_221_3_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_222_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_223_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_264_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_264_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_264_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_270_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_270_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_275_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_275_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_293_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_293_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_294_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_318_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_320_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_320_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_321_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_326_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_326_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_327_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_327_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_327_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_328_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_328_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_328_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_330_0_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_330_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_330_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_336_2_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_340_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	['balo_341_1_1'] = { label = 'Mẫu balo', weight = 0, stack = false, close = true },
	

	['lootbox_nam_thuong_aokhoac'] = {
		label   = 'Hòm Áo Thường',
		description = 'Áo khoác mã thường, giành cho giới tính nam',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nam_thuong_quan'] = {
		label   = 'Hòm Quần Thường',
		description = 'Quần mã thường, giành cho giới tính nam',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nam_thuong_giay'] = {
		label   = 'Hòm Giày Thường',
		description = 'Giày mã thường, giành cho giới tính nam',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nu_thuong_aokhoac'] = {
		label   = 'Hòm Áo Thường',
		description = 'Áo khoác mã thường, giành cho giới tính nữ',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nu_thuong_quan'] = {
		label   = 'Hòm Quần Thường',
		description = 'Quần mã thường, giành cho giới tính nữ',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nu_thuong_giay'] = {
		label   = 'Hòm Giày Thường',
		description = 'Giày mã thường, giành cho giới tính nữ',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nam_thuong_matna'] = {
		label   = 'Hòm Mặt Nạ Thường',
		description = 'Mặt nạ mã thường, giành cho giới tính nam',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nu_thuong_matna'] = {
		label   = 'Hòm Mặt Nạ Thường',
		description = 'Mặt nạ mã thường, giành cho giới tính nữ',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nam_matna_s1'] = {
		label   = 'Hòm Mặt Nạ Đợt 1',
		description = 'Hòm mặt nạ hàng hiệu, giành cho nam',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nam_aokhoac_s1'] = {
		label   = 'Hòm Áo Đợt 1',
		description = 'Hòm áo khoác hàng hiệu, giành cho nam',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nam_quan_s1'] = {
		label   = 'Hòm Quần Đợt 1',
		description = 'Hòm quần hàng hiệu, giành cho nam',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nam_giay_s1'] = {
		label   = 'Hòm Giày Đợt 1',
		description = 'Hòm giày hàng hiệu, giành cho nam',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nam_balo_s1'] = {
		label   = 'Hòm Mẫu Balo Đợt 1',
		description = 'Hòm balo hàng hiệu, giành cho nam',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nu_aokhoac_s1'] = {
		label   = 'Hòm Áo Khoác Đợt 1',
		description = 'Hòm Áo Khoác hàng hiệu, giành cho nữ',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nu_aotrong_s1'] = {
		label   = 'Hòm Áo Trong Đợt 1',
		description = 'Hòm Áo Trong hàng hiệu, giành cho nữ',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nu_quan_s1'] = {
		label   = 'Hòm Quần Đợt 1',
		description = 'Hòm quần hàng hiệu, giành cho nữ',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nu_giay_s1'] = {
		label   = 'Hòm Giày Đợt 1',
		description = 'Hòm giày hàng hiệu, giành cho nữ',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nu_matna_s1'] = {
		label   = 'Hòm Mặt Nạ Đợt 1',
		description = 'Hòm mặt nạ hàng hiệu, giành cho nữ',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nu_balo_s1'] = {
		label   = 'Hòm Mẫu Balo Đợt 1',
		description = 'Hòm balo hàng hiệu, giành cho nữ',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nam_aokhoac_s2'] = {
		label   = 'Hòm Áo Khoác Đợt 2',
		description = 'Hòm áo khoác hàng hiệu, dành cho nam',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nu_aokhoac_s2'] = {
		label   = 'Hòm Áo Khoác Đợt 2',
		description = 'Hòm áo khoác hàng hiệu, dành cho nữ',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nu_aotrong_s2'] = {
		label   = 'Hòm Áo Trong Đợt 2',
		description = 'Hòm áo trong hàng hiệu, dành cho nữ',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nam_balo_s2'] = {
		label   = 'Hòm Ba Lô Đợt 2',
		description = 'Hòm ba lô hàng hiệu, dành cho nam',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nu_balo_s2'] = {
		label   = 'Hòm Ba Lô Đợt 2',
		description = 'Hòm ba lô hàng hiệu, dành cho nữ',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nu_daychuyen_s2'] = {
		label   = 'Hòm Dây Chuyền Đợt 2',
		description = 'Hòm dây chuyền hàng hiệu',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nam_giay_s2'] = {
		label   = 'Hòm Giày Đợt 2',
		description = 'Hòm giày hàng hiệu, dành cho nam',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nu_giay_s2'] = {
		label   = 'Hòm Giày Đợt 2',
		description = 'Hòm giày hàng hiệu, dành cho nữ',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nam_matna_s2'] = {
		label   = 'Hòm Mặt Nạ Đợt 2',
		description = 'Hòm mặt nạ hàng hiệu, dành cho nam',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nu_matna_s2'] = {
		label   = 'Hòm Mặt Nạ Đợt 2',
		description = 'Hòm mặt nạ hàng hiệu, dành cho nữ',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nam_mu_s2'] = {
		label   = 'Hòm Mũ Đợt 2',
		description = 'Hòm mũ hàng hiệu, dành cho nam',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nam_nonfullface_s2'] = {
		label   = 'Hòm Nón Fullface Đợt 2',
		description = 'Hòm nón fullface hàng hiệu, dành cho nam',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nu_mu_s2'] = {
		label   = 'Hòm Mũ Đợt 2',
		description = 'Hòm mũ hàng hiệu, dành cho nữ',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},

	['lootbox_nam_quan_s2'] = {
		label   = 'Hòm Quần Đợt 2',
		description = 'Hòm quần hàng hiệu, dành cho nam',
		weight  = 0,
		consume = 0,
		client  = {
			event = 'derp-lootbox:useItem'
		}
	},







	['id_card'] = {
        label = 'CCID',
        weight = 500,
        stack = false,
        close = true,
    },

	['job_card'] = {
        label = 'Thẻ Ngành',
        weight = 500,
        stack = false,
        close = true,
    },

	['fake_id_card'] = {
        label = 'CCID',
        weight = 500,
        stack = false,
        close = true,
    },

	['fake_job_card'] = {
        label = 'Thẻ Ngành',
        weight = 500,
        stack = false,
        close = true,
    },

	['diving_fill'] = {
        label = 'Ống Lặn',
        weight = 3000,
        stack = false,
        close = true,
        description = "Dùng để nạp lại nguồn cung cấp oxy cho thiết bị lặn của bạn.."
    },

    ['diving_gear'] = {
        label = 'Bộ Đồ Lặn',
        weight = 30000,
        stack = false,
        close = true,
        description = "Bộ đồ lặn cho phép bơi dưới nước. Blub blub!"
    },

	-- ['bandage'] = {
	-- 	label = 'Bandage',
	-- 	weight = 115,
	-- 	client = {
	-- 		anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a', flag = 49 },
	-- 		prop = { model = `prop_rolled_sock_02`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
	-- 		disable = { move = true, car = true, combat = true },
	-- 		usetime = 2500,
	-- 	}
	-- },

	['black_money'] = {
		label = 'Tiền Bẩn',
	},

	['burger'] = {
		label = 'Burger',
		weight = 220,
		degrade = 720,
		client = {
			status = { hunger = 400000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 5500,
			notification = 'Bạn đã ăn một chiếc bánh burger.'
		},
	},

	-- ['sprunk'] = {
	-- 	label = 'Sprunk',
	-- 	weight = 350,
	-- 	client = {
	-- 		status = { thirst = 200000 },
	-- 		anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
	-- 		prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
	-- 		usetime = 2500,
	-- 		notification = 'You quenched your thirst with a sprunk'
	-- 	}
	-- },

	['parachute'] = {
		label = 'Dù Nhảy',
		weight = 8000,
		stack = false,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 1500
		}
	},

	-- ['garbage'] = {
	-- 	label = 'Garbage',
	-- },

	['paperbag'] = {
		label = 'Túi Giấy',
		weight = 1,
		stack = false,
		close = false,
		consume = 0
	},

	-- ['identification'] = {
	-- 	label = 'Identification',
	-- 	client = {
	-- 		image = 'card_id.png'
	-- 	}
	-- },

	['panties'] = {
		label = 'Chíp Chíp',
		weight = 10,
		consume = 0,
		client = {
			status = { thirst = -100000, stress = -25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_cs_panties_02`, pos = vec3(0.03, 0.0, 0.02), rot = vec3(0.0, -13.5, -1.5) },
			usetime = 2500,
		}
	},

	['lockpick'] = {
		label = 'Bộ Bẻ Khóa',
		weight = 160,
	},

	
	["advancedlockpick"] = {
		label = "Bộ Bẻ Khóa Nâng Cao",
		weight = 500,
		stack = false,
		close = true
	},


	['phone'] = {
		label = 'Điện Thoại',
		weight = 200,
		stack = false,
		consume = 0,
		export = 'lb-phone.UsePhoneItem',
	},

	['blackphone'] = {
		label = 'Điện Thoại Vệ Tinh',
		weight = 200,
		stack = false,
		close = true,
		description = 'Có tính bảo mật cao',
		client = {
			event = 'derp-blackphone:client:useItem'
		}
	},

	['money'] = {
		label = 'Tiền Mặt',
	},

	['mustard'] = {
		label = 'Mù Tạt',
		weight = 500,
		client = {
			status = { hunger = 25000, thirst = 25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_food_mustard`, pos = vec3(0.01, 0.0, -0.07), rot = vec3(1.0, 1.0, -1.5) },
			usetime = 2500,
			notification = 'Bạn... đã uống mù tạt'
		}
	},

	['water'] = {
		label = 'Nước Suối',
		weight = 500,
		degrade = 720,
		client = {
			status = { thirst = 300000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
			usetime = 3500,
			cancel = true,
			notification = 'Bạn đã uống một ít nước suối.'
		}
	},

	['radio'] = {
		label = 'Bộ Đàm',
		weight = 1000,
		-- degrade = 10000,
		stack = false,
		allowArmed = true,
		consume = 0,
		client = {
			export = 'mm_radio.useRadio'
		}
	},

	['bodycam'] = {
		label = 'Máy Quay',
		description = 'Máy quay gọn nhẹ, thông dụng ở các ban ngành.',
		weight = 1000,
		stack = false,
		close = true,
	},

	['armor_plate1'] = {
		label = 'Giáp Nhẹ',
		weight = 1000,
		stack = true,
		description = 'Tấm giáp cơ bản có thể che chắn nhẹ.',
		client = {
			image = "armorplate.png",
		}
	},

	['armor_plate2'] = {
		label = 'Giáp Nặng',
		weight = 1000,
		stack = true,
		description = 'Tấm giáp chất lượng cao.',
		client = {
			image = "armorplate.png",
		}
	},

	-- ['armor_vest'] = {
	-- 	label = 'Armor Vest',
	-- 	weight = 1000,
	-- 	stack = true,
	-- 	description = 'A Vest To Apply Plates',
	-- 	client = {
	-- 		image = "armor_vest.png",
	-- 	}
	-- },

	-- ['armor'] = {
	-- 	label = 'Bulletproof Vest',
	-- 	weight = 3000,
	-- 	stack = false,
	-- 	client = {
	-- 		anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
	-- 		usetime = 3500
	-- 	}
	-- },

	-- ['clothing'] = {
	-- 	label = 'Clothing',
	-- 	consume = 0,
	-- },

	-- ['mastercard'] = {
	-- 	label = 'Thẻ ngân hàng Fleeca',
	-- 	description = 'Thẻ ngân hàng cá nhân. Mất cái này thì khóc không ra nước mắt đâu nhé.',
	-- 	stack = false,
	-- 	weight = 10,
	-- 	client = {
	-- 		image = 'card_bank.png'
	-- 	}
	-- },

	['scrapmetal'] = {
		label = 'Phế liệu kim loại',
		description = 'Đống sắt vụn trông vô dụng nhưng bán cân ký cũng ra tiền đấy.',
		weight = 80,
	},

	['crutch'] = {
		label = 'Nạng chống',
		description = 'Khi chân không còn muốn hợp tác nữa, cái này sẽ thay thế. Tạm thời thôi nhé.',
		weight = 100,
		stack = false,
		close = true,
	},

	['wheelchair'] = {
		label = 'Xe lăn',
		description = 'Không phải xe đua, nhưng vẫn có bánh. Chở bệnh nhân chứ đừng có drift.',
		weight = 100,
		stack = false,
		close = true,
	},

	['stretcher'] = {
		label = 'Cáng cứu thương',
		description = 'Nằm lên đây là biết mình đang trong tình huống không mấy vui. Cố lên!',
		weight = 100,
		stack = false,
		close = true,
	},

	['medical_kit'] = {
		label = 'Túi y tế cơ bản',
		weight = 200,
		stack = false,
		close = false,
		description = 'Bộ sơ cứu cơ bản cho những vết thương nhỏ. Không chữa được ngu nhưng chữa được trầy xước.',
	},

	['advanced_medical_kit'] = {
		label = 'Túi y tế nâng cao',
		weight = 200,
		stack = false,
		close = false,
		description = 'Phiên bản pro hơn. Vẫn không chữa được ngu, nhưng xử lý được vết thương nặng hơn nhiều.',
	},

	['blood_bag_250'] = {
		label = 'Túi máu 250ml',
		weight = 250,
		stack = true,
		close = false,
		description = 'Túi máu 250ml dùng để truyền máu. Không phải sinh tố, đừng uống thử.',
	},

	['blood_bag_500'] = {
		label = 'Túi máu 500ml',
		weight = 500,
		stack = true,
		close = false,
		description = 'Túi máu 500ml - dành cho ca nặng hơn. Quý như vàng trong phòng cấp cứu.',
	},

	['painkillers'] = {
		label = 'Thuốc giảm đau',
		weight = 50,
		stack = true,
		close = false,
		description = 'Đau đâu uống đó. Không giải quyết được vấn đề nhưng giúp bạn không quan tâm đến nó nữa.',
	},

	['adrenaline'] = {
		label = 'Adrenaline',
		weight = 50,
		stack = true,
		close = false,
		description = 'Tim đang đứng yên? Chích cái này vào là nó chạy lại ngay. Bảo hiểm nhân thọ chưa ký thì ký đi.',
	},

	['morphine'] = {
		label = 'Morphine',
		weight = 50,
		stack = true,
		close = false,
		description = 'Giảm đau mạnh cấp độ bệnh viện. Dùng đúng liều thì tốt, dùng sai liều thì... gặp bác sĩ ngay.',
	},

	['suture_kit'] = {
		label = 'Bộ khâu vết thương',
		weight = 100,
		stack = true,
		close = false,
		description = 'Kim chỉ chuyên dụng để vá lại những gì không nên bị mở ra. Bền hơn cả băng keo.',
	},

	['icepack'] = {
		label = 'Túi chườm đá',
		weight = 100,
		stack = true,
		close = false,
		description = 'Sưng đâu chườm đó. Lạnh buốt nhưng hiệu quả, như sự thật vậy.',
	},

	['splint'] = {
		label = 'Nẹp cố định',
		weight = 100,
		stack = true,
		close = false,
		description = 'Cố định xương gãy tạm thời. Không phải để làm kiếm, dù trông có vẻ vậy.',
	},

	['defibrilator'] = {
		label = 'Máy khử rung tim',
		description = 'Sạc đầy pin chưa? Vì bạn có thể cần giật tim ai đó trở về với cuộc đời hôm nay.',
		weight = 500,
		stack = false,
		close = true,
	},

	['bodybag'] = {
		label = 'Túi đựng thi thể',
		description = 'Hy vọng bạn không bao giờ cần dùng đến cái này. Nhưng cứ mang theo cho chắc.',
		weight = 500,
		stack = true,
		close = false,
	},

	['gauze'] = {
		label = 'Gạc y tế',
		weight = 20,
		stack = true,
		close = true,
		description = 'Vải gạc mỏng dùng băng bó vết thương. Nhỏ nhưng không thể thiếu trong túi cứu thương.',
	},

	['bandage'] = {
		label = 'Băng gạc',
		description = 'Cầm máu, băng bó vết thương nhỏ. Đơn giản mà hiệu quả, như người bạn đời lý tưởng.',
		weight = 115,
		stack = true,
		close = true,
	},

	['ifak'] = {
		label = 'ifak',
		description = 'Cầm máu, băng bó vết thương.',
		weight = 100,
		stack = true,
		close = true,
	},

	['ointment'] = {
		label = 'Thuốc mỡ bôi vết thương',
		weight = 50,
		stack = true,
		close = true,
		description = 'Thoa lên vết trầy, vết bỏng nhẹ để mau lành. Mùi y tế đặc trưng, mùi của sự hồi phục.',
	},

	['disinfectant'] = {
		label = 'Dung dịch sát khuẩn',
		weight = 50,
		stack = true,
		close = true,
		description = 'Diệt khuẩn sạch sẽ trước khi băng bó. Xót một chút nhưng đỡ mưng mủ sau này.',
	},

	['cyclonamine'] = {
		label = 'Cyclonamine',
		weight = 50,
		stack = true,
		close = true,
		description = 'Thuốc cầm máu chuyên dụng. Khi băng gạc chưa đủ thì đây là bạn đồng hành.',
	},

	['tourniquet'] = {
		label = 'Dây garô',
		weight = 100,
		stack = true,
		close = true,
		description = 'Buộc chặt để cầm máu vết thương ở tay chân. Đau thật nhưng cứu mạng thật.',
	},

	['medicbag'] = {
		label = 'Túi y tế paramedic',
		weight = 500,
		stack = false,
		close = true,
		description = 'Túi đầy đồ nghề của người hùng áo trắng. Mang theo là tự tin xử lý mọi ca cấp cứu.',
	},

	['antipyretics'] = {
		label = 'Thuốc hạ sốt',
		weight = 50,
		stack = true,
		close = true,
		description = 'Sốt cao thì uống vào. Không phải kẹo, nhưng hiệu quả hơn kẹo nhiều.',
	},

	['ambulance_gps'] = {
		label = 'GPS xe cứu thương',
		description = 'Dẫn đường đến bệnh nhân nhanh nhất có thể. Vì mỗi giây đều quan trọng.',
		weight = 100,
		stack = false,
		close = true,
	},

	['dealership_tablet'] = {
		label = 'Bảng Điều Khiển',
		weight = 1000,
		stack = false,
		close = true,
		client = { event = 'tommy-dealership:client:OpenTablet' },
	},

	["tablet"] = {
        label = "Máy Tính Bảng",
        weight = 2000,
        stack = false,
        close = true,
        description = "Một chiếc tablet thật đẹp",
        client = {
            event = "tablet:toggleOpen"
        }
    },

	['metalscrap'] = {
		label = 'Kim Loại Vụn',
		weight = 100,
		stack = true,
		close = true,
		description = 'Mảnh kim loại phế liệu',
	},
	['plastic'] = {
		label = 'Nhựa',
		weight = 40,
		stack = true,
		close = true,
		description = 'Vật liệu nhựa tổng hợp',
	},
	['copper'] = {
		label = 'Đồng',
		weight = 120,
		stack = true,
		close = true,
		description = 'Thanh đồng nguyên chất',
	},
	['iron'] = {
		label = 'Sắt',
		weight = 160,
		stack = true,
		close = true,
		description = 'Thanh sắt thô',
	},
	['aluminum'] = {
		label = 'Nhôm',
		weight = 120,
		stack = true,
		close = true,
		description = 'Thanh nhôm nguyên chất',
	},
	['circuit'] = {
		label = 'Mạch Điện Tử',
		weight = 500,
		stack = true,
		close = true,
		description = 'Mạch Điện Tử',
	},
	['steel'] = {
		label = 'Thép',
		weight = 100,
		stack = true,
		close = true,
		description = 'Thanh thép cứng',
	},
	['glass'] = {
		label = 'Kính',
		weight = 100,
		stack = true,
		close = true,
		description = 'Tấm kính mỏng',
	},
	['rubber'] = {
		label = 'Cao Su',
		weight = 70,
		stack = true,
		close = true,
		description = 'Miếng cao su tự nhiên',
	},

	['basic_rod'] = {
		label = 'Cần câu cơ bản',
		description = 'Cần câu dành cho những tay mơ, cá không cắn thì... đổ tại cần!',
		stack = false,
		weight = 250
	},

	['graphite_rod'] = {
		label = 'Cần câu graphite',
		description = 'Nhẹ, bền, xịn hơn hàng xóm một bậc. Cá to cũng đừng hòng chạy thoát.',
		stack = false,
		weight = 350
	},

	['titanium_rod'] = {
		label = 'Cần câu titanium',
		description = 'Đỉnh cao công nghệ câu cá. Nếu vẫn không câu được thì tại... số thôi.',
		stack = false,
		weight = 450
	},

	['worms'] = {
		label = 'Mồi giun',
		description = 'Giun tươi ngon, cá thích mê. Bạn có thể không thích nhưng cá thì có.',
		weight = 10
	},

	['artificial_bait'] = {
		label = 'Mồi giả',
		description = 'Trông như thật, cá cũng bị lừa. Đừng lo, bạn không phải người duy nhất bị lừa hôm nay.',
		weight = 30
	},

	['anchovy'] = {
		label = 'Cá cơm',
		description = 'Nhỏ con nhưng đầy dinh dưỡng. Kho tộ hay làm mắm đều ngon bá cháy.',
		weight = 80
	},

	['grouper'] = {
		label = 'Cá mú',
		description = 'Cá mú hấp gừng hành - đặc sản nhà hàng hải sản. Câu được con này, tự thưởng một bữa đi!',
		weight = 1500
	},

	['haddock'] = {
		label = 'Cá tuyết vân đen',
		description = 'Dân Âu Mỹ mê cái này lắm. Fish & Chips chính hiệu đây rồi!',
		weight = 650
	},

	['mahi_mahi'] = {
		label = 'Cá dorado',
		description = 'Màu sặc sỡ như cầu vồng, thịt thì ngon như mơ. Câu được là flex cả tuần luôn.',
		weight = 2600
	},

	['piranha'] = {
		label = 'Cá piranha',
		description = 'Răng sắc như dao cạo. Câu lên rồi thì... xử cẩn thận kẻo nó xử lại bạn.',
		weight = 1700
	},

	['red_snapper'] = {
		label = 'Cá hồng',
		description = 'Đỏ tươi, thịt trắng, chiên giòn ăn với cơm trắng là hết sảy. Cá nhà giàu đây!',
		weight = 2200
	},

	['salmon'] = {
		label = 'Cá hồi',
		description = 'Sashimi, sushi, nướng, áp chảo... Làm gì cũng ngon. Loài cá đa zi năng nhất vịnh Bắc Bộ.',
		weight = 900
	},

	['shark'] = {
		label = 'Cá mập',
		description = 'Bình thường nó ăn người, hôm nay người ăn lại. Karma là đây!',
		weight = 5500
	},

	['trout'] = {
		label = 'Cá hồi suối',
		description = 'Sống ở suối trong lành nên thịt ngọt tự nhiên. Dân câu cá biết tiếng lắm.',
		weight = 500
	},

	['tuna'] = {
		label = 'Cá ngừ đại dương',
		description = 'Vua của đại dương, giá trị của bữa tối hảo hạng. Câu được con này thì nghỉ hưu sớm đi được rồi.',
		weight = 4200
	},

	['meatdeer'] = {
		label       = 'Thịt hươu',
		description = 'Thịt tươi từ hươu rừng. Không bán được nhưng nướng lên thì thơm lắm.',
		weight      = 500,
		stack       = true,
	},

	['hide_1star'] = {
		label       = 'Da thú 1 sao',
		description = 'Da chất lượng thấp, còn nhiều vết thương. Vẫn bán được giá kha khá.',
		weight      = 300,
		stack       = true,
	},

	['hide_2star'] = {
		label       = 'Da thú 2 sao',
		description = 'Da chất lượng khá, ít vết thương. Thợ thuộc da thích cái này lắm.',
		weight      = 300,
		stack       = true,
	},

	['hide_3star'] = {
		label       = 'Da thú 3 sao',
		description = 'Da hoàn hảo, không tì vết. Hiếm lắm mới có được đấy.',
		weight      = 300,
		stack       = true,
	},

	["scissors"] = {
		label = "Cây Kéo",
		weight = 1000,
		degrade = 1440,
		stack = true,
		close = true,
		description = "Kéo cắt giấy hoặc thu hoạch bông, quả.",
	},


	["cotton"] = {
		label = "Bông Cotton",
		weight = 100,
		stack = true,
		close = true,
		description = "Dùng chế tác ra vải.",
	},

	['axe'] = {
		label       = 'Cây Rìu',
		weight      = 2000,
		stack       = false,
		close       = true,
		description = 'Một chiếc rìu sắc bén.',
	},

	['log'] = {
		label       = 'Khúc gỗ',
		weight      = 500,
		stack       = true,
		close       = true,
		description = 'Khúc gỗ vừa được chặt.',
	},

	['cleanlog'] = {
		label       = 'Khúc gỗ sạch',
		weight      = 500,
		stack       = true,
		close       = true,
		description = 'Khúc gỗ đã được làm sạch.',
	},

	['rawplank'] = {
		label       = 'Ván gỗ thô',
		weight      = 500,
		stack       = true,
		close       = true,
		description = 'Ván gỗ thô chưa qua xử lý.',
	},

	['sandedplank'] = {
		label       = 'Ván gỗ đã chà nhám',
		weight      = 500,
		stack       = true,
		close       = true,
		description = 'Ván gỗ đã được chà nhám mịn.',
	},

	['finishwood'] = {
		label       = 'Gỗ thành phẩm',
		weight      = 500,
		stack       = true,
		close       = true,
		description = 'Gỗ đã hoàn thiện, sẵn sàng để bán.',
	},

	['handcuffs'] = {
		label       = 'Còng Tay',
		weight      = 500,
		stack       = true,
		close       = true,
		description = 'Còng số 8 siết tay anh.',
	},

	['car_wheel'] = { label = 'Bánh Xe', weight = 5000 },
	['car_door'] = { label = 'Cửa Xe', weight = 8000 },
	['radiator'] = { label = 'Két Nước', weight = 6000 },
	['trunk'] = { label = 'Cốp Xe', weight = 7000 },
	['carbon'] = { label = 'Carbon', weight = 500 },

	['hack_laptop'] = {
		label = 'Laptop Hack',
		description = "Dùng để hack hệ thống báo động",
		weight = 20,
		stack = true
	},

	['loot_bag'] = {
		label = 'Túi Đựng Đồ',
		description = "Túi để chứa đồ trộm",
		weight = 50,
		stack = true
	},

	['laptop'] = {
		label = 'Máy Tính Xách Tay',
		description = "",
		weight = 100,
		stack = true
	},

	['printer'] = {
		label = 'Máy In',
		description = "",
		weight = 190,
		stack = true
	},

	['npc_phone'] = {
		label = 'Điện Thoại',
		description = "",
		weight = 10,
		stack = true
	},

	['monitor'] = {
		label = 'Màn Hình',
		description = "",
		weight = 50,
		stack = true
	},

	['television'] = {
		label = 'Tivi Vuông',
		description = "",
		weight = 155,
		stack = true
	},

	['flat_television'] = {
		label = 'Tivi Màn Phẳng',
		description = "",
		weight = 155,
		stack = true
	},

	['radio_alarm'] = {
		label = 'Đài Radio',
		description = "",
		weight = 30,
		stack = true
	},

	['fan'] = {
		label = 'Quạt Đứng',
		description = "",
		weight = 20,
		stack = true
	},

	['shoebox'] = {
		label = 'Hộp Giày',
		description = "",
		weight = 45,
		stack = true
	},

	['dj_deck'] = {
		label = 'Bàn DJ',
		description = "",
		weight = 95,
		stack = true
	},

	['console'] = {
		label = 'Máy Chơi Game',
		description = "",
		weight = 55,
		stack = true
	},

	['boombox'] = {
		label = 'Loa Di Động',
		description = "",
		weight = 85,
		stack = true
	},

	['bong'] = {
		label = 'Bình Hút',
		description = "",
		weight = 25,
		stack = true
	},

	['coffemachine'] = {
		label = 'Máy Pha Cà Phê',
		description = "",
		weight = 55,
		stack = true
	},

	['tapeplayer'] = {
		label = 'Máy Phát Băng',
		description = "",
		weight = 55,
		stack = true
	},

	['hairdryer'] = {
		label = 'Máy Sấy Tóc',
		description = "",
		weight = 55,
		stack = true
	},

	['j_phone'] = {
		label = 'Điện Thoại Bàn',
		description = "",
		weight = 55,
		stack = true
	},

	['sculpture'] = {
		label = 'Tượng Điêu Khắc',
		description = "",
		weight = 55,
		stack = true
	},

	['toiletry'] = {
		label = 'Đồ Vệ Sinh',
		description = "",
		weight = 10,
		stack = true
	},

	['pogo'] = {
		label = 'Tượng Nghệ Thuật',
		description = "Tượng Pogo quý hiếm",
		weight = 155,
		stack = true
	},

	['powder'] = {
		label = 'Túi Bột',
		description = "Dùng để phát hiện tia laser ẩn",
		weight = 50,
		stack = true
	},

	['bracelet'] = {
		label = 'Vòng Tay',
		description = "",
		weight = 25,
		stack = true
	},

	['book'] = {
		label = 'Sách',
		description = "",
		weight = 25,
		stack = true
	},

	['earings'] = {
		label = 'Bông Tai',
		description = "",
		weight = 25,
		stack = true
	},

	['gold_bracelet'] = {
		label = 'Vòng Tay Vàng',
		description = "",
		weight = 45,
		stack = true
	},

	['gold_watch'] = {
		label = 'Đồng Hồ Vàng',
		weight = 55,
		stack = true
	},

	['house_locator'] = {
		label = 'Máy Định Vị Nhà',
		weight = 55,
		stack = true
	},

	['necklace'] = {
		label = 'Dây Chuyền',
		weight = 55,
		stack = true
	},

	['notepad'] = {
		label = 'Sổ Tay',
		weight = 5,
		stack = true
	},

	['pencil'] = {
		label = 'Bút Chì',
		weight = 25,
		stack = true
	},

	['romantic_book'] = {
		label = 'Tiểu Thuyết',
		weight = 25,
		stack = true
	},

	['shampoo'] = {
		label = 'Dầu Gội',
		weight = 25,
		stack = true
	},

	['soap'] = {
		label = 'Xà Phòng',
		weight = 25,
		stack = true
	},

	['toothpaste'] = {
		label = 'Kem Đánh Răng',
		weight = 15,
		stack = true
	},

	['watch'] = {
		label = 'Đồng Hồ',
		weight = 35,
		stack = true
	},

	['skull'] = {
		label = 'Đầu Lâu',
		weight = 95,
		stack = true
	},

	-- Vật phẩm hỗ trợ
	['nutrient_solution'] = {
		label = 'Nước Dinh Dưỡng',
		weight = 500,
		description = 'Nước dinh dưỡng để tưới cây',
	},

	['fertilizer'] = {
		label = 'Phân Bón',
		weight = 300,
		description = 'Phân bón giúp cây phát triển nhanh hơn',
	},

	['uv_lamp']             = { label = 'Đèn UV', weight = 1000, description = 'Đèn UV tăng năng suất', consume = 0 },

	-- Hạt giống
	['cannabis_seed_indica'] = { label = 'Hạt Cần Sa Indica', weight = 50, description = 'Hạt giống Indica', consume = 0 },
	['cannabis_seed_sativa'] = { label = 'Hạt Cần Sa Sativa', weight = 50, description = 'Hạt giống Sativa', consume = 0 },
	['cannabis_seed_hybrid'] = { label = 'Hạt Cần Sa Hybrid', weight = 50, description = 'Hạt giống Hybrid', consume = 0 },

	-- Sản phẩm thu hoạch tươi
	['indica_bud'] = {
		label = 'Nụ Indica',
		weight = 100,
		description = 'Nụ cần sa Indica tươi',
	},
	['sativa_bud'] = {
		label = 'Nụ Sativa',
		weight = 100,
		description = 'Nụ cần sa Sativa tươi',
	},
	['hybrid_bud'] = {
		label = 'Nụ Hybrid',
		weight = 100,
		description = 'Nụ cần sa Hybrid tươi',
	},

	-- Bàn sấy
	['drying_rack']         = { label = 'Kệ Phơi Cần', weight = 2000, description = 'Kệ phơi cần sa', consume = 0 },

	-- Cần khô
	['indica_bud_dried'] = {
		label = 'Nụ Indica Khô',
		weight = 50,
		description = 'Nụ cần sa Indica khô',
	},
	['sativa_bud_dried'] = {
		label = 'Nụ Sativa Khô',
		weight = 50,
		description = 'Nụ cần sa Sativa khô',
	},
	['hybrid_bud_dried'] = {
		label = 'Nụ Hybrid Khô',
		weight = 50,
		description = 'Nụ cần sa Hybrid khô',
	},

	-- Cần hư
	['ruined_bud'] = {
		label = 'Cần Hư',
		weight = 50,
		description = 'Nụ cần sa đã bị hư do phơi quá lâu',
	},

	-- Bàn tẩm
	['infusion_table']      = { label = 'Bàn Tẩm Cần Sa', weight = 2000, description = 'Bàn tẩm cần sa', consume = 0 },

	-- Cần tẩm hỏng
	['ruined_infusion'] = {
		label = 'Cần Tẩm Hỏng',
		weight = 50,
		description = 'Cần sa bị hỏng do tẩm sai công thức',
	},

	-- Indica
	['sour_diesel_high'] = {
		label = 'Sour Diesel Chất Lượng Cao',
		weight = 100,
		description = 'Cần Sour Diesel được xử lý hoàn hảo, chất lượng cao.',
	},
	['sour_diesel_medium'] = {
		label = 'Sour Diesel Trung Bình',
		weight = 100,
		description = 'Cần Sour Diesel được xử lý mức trung bình.',
	},
	['sour_diesel_low'] = {
		label = 'Sour Diesel Kém Chất Lượng',
		weight = 100,
		description = 'Cần Sour Diesel bị xử lý lỗi, chất lượng kém.',
	},
	['purple_haze_high'] = {
		label = 'Purple Haze Chất Lượng Cao',
		weight = 100,
		description = 'Nụ Purple Haze thơm ngát, đã tẩm hoàn hảo.',
	},
	['purple_haze_medium'] = {
		label = 'Purple Haze Trung Bình',
		weight = 100,
		description = 'Purple Haze được xử lý ở mức trung bình.',
	},
	['purple_haze_low'] = {
		label = 'Purple Haze Kém Chất Lượng',
		weight = 100,
		description = 'Nụ Purple Haze bị lỗi trong quá trình xử lý.',
	},
	['northern_lights_high'] = {
		label = 'Northern Lights Cao Cấp',
		weight = 100,
		description = 'Nụ Northern Lights đã tẩm đạt chuẩn cao nhất.',
	},
	['northern_lights_medium'] = {
		label = 'Northern Lights Trung Bình',
		weight = 100,
		description = 'Northern Lights tẩm ở mức trung bình.',
	},
	['northern_lights_low'] = {
		label = 'Northern Lights Kém Chất Lượng',
		weight = 100,
		description = 'Northern Lights bị tẩm lỗi, chất lượng thấp.',
	},

	-- Sativa
	['blue_dream_high'] = {
		label = 'Blue Dream Cao Cấp',
		weight = 100,
		description = 'Blue Dream được tẩm kỹ, đạt chất lượng cao.',
	},
	['blue_dream_medium'] = {
		label = 'Blue Dream Trung Bình',
		weight = 100,
		description = 'Blue Dream tẩm ở mức trung bình.',
	},
	['blue_dream_low'] = {
		label = 'Blue Dream Kém Chất Lượng',
		weight = 100,
		description = 'Blue Dream bị tẩm lỗi, chất lượng thấp.',
	},
	['jack_herer_high'] = {
		label = 'Jack Herer Cao Cấp',
		weight = 100,
		description = 'Jack Herer nổi tiếng với hương cam chanh, tẩm đạt chuẩn.',
	},
	['jack_herer_medium'] = {
		label = 'Jack Herer Trung Bình',
		weight = 100,
		description = 'Jack Herer tẩm ở mức trung bình.',
	},
	['jack_herer_low'] = {
		label = 'Jack Herer Kém Chất Lượng',
		weight = 100,
		description = 'Jack Herer bị tẩm lỗi, chất lượng thấp.',
	},
	['super_lemon_haze_high'] = {
		label = 'Super Lemon Haze Cao Cấp',
		weight = 100,
		description = 'Super Lemon Haze tươi sáng, mùi chanh đặc trưng.',
	},
	['super_lemon_haze_medium'] = {
		label = 'Super Lemon Haze Trung Bình',
		weight = 100,
		description = 'Super Lemon Haze tẩm ở mức trung bình.',
	},
	['super_lemon_haze_low'] = {
		label = 'Super Lemon Haze Kém Chất Lượng',
		weight = 100,
		description = 'Super Lemon Haze bị tẩm lỗi, chất lượng thấp.',
	},

	-- Hybrid
	['og_kush_high'] = {
		label = 'OG Kush Cao Cấp',
		weight = 100,
		description = 'OG Kush pha trộn hoàn hảo giữa indica và sativa.',
	},
	['og_kush_medium'] = {
		label = 'OG Kush Trung Bình',
		weight = 100,
		description = 'OG Kush tẩm ở mức trung bình.',
	},
	['og_kush_low'] = {
		label = 'OG Kush Kém Chất Lượng',
		weight = 100,
		description = 'OG Kush bị tẩm lỗi, chất lượng thấp.',
	},
	['gsc_high'] = {
		label = 'Girl Scout Cookies Cao Cấp',
		weight = 100,
		description = 'Girl Scout Cookies – hương ngọt nhẹ, xử lý chuẩn xác.',
	},
	['gsc_medium'] = {
		label = 'Girl Scout Cookies Trung Bình',
		weight = 100,
		description = 'Girl Scout Cookies tẩm ở mức trung bình.',
	},
	['gsc_low'] = {
		label = 'Girl Scout Cookies Kém Chất Lượng',
		weight = 100,
		description = 'Girl Scout Cookies bị tẩm lỗi, chất lượng thấp.',
	},
	['wedding_cake_high'] = {
		label = 'Wedding Cake Cao Cấp',
		weight = 100,
		description = 'Wedding Cake – dòng hybrid cân bằng, hương vani dễ chịu.',
	},
	['wedding_cake_medium'] = {
		label = 'Wedding Cake Trung Bình',
		weight = 100,
		description = 'Wedding Cake tẩm ở mức trung bình.',
	},
	['wedding_cake_low'] = {
		label = 'Wedding Cake Kém Chất Lượng',
		weight = 100,
		description = 'Wedding Cake bị tẩm lỗi, chất lượng thấp.',
	},

	--base
	['indica_bud_dried_weed'] = {
		label = 'Điếu Indica',
		weight = 50,
		description = 'Điếu cần Indica.',
	},
	
	['sativa_bud_dried_weed'] = {
		label = 'Điếu Sativa',
		weight = 50,
		description = 'Điếu cần Sativa.',
	},
	
	['hybrid_bud_dried_weed'] = {
		label = 'Điếu Hybrid',
		weight = 50,
		description = 'Điếu cần Hybrid.',
	},

	-- Indica Weed
	['sour_diesel_high_weed'] = {
		label = 'Điếu Sour Diesel Cao Cấp',
		weight = 50,
		description = 'Điếu cần sa Sour Diesel chất lượng cao, đã cuốn sẵn.',
	},
	['sour_diesel_medium_weed'] = {
		label = 'Điếu Sour Diesel Trung Bình',
		weight = 50,
		description = 'Điếu cần sa Sour Diesel chất lượng trung bình.',
	},
	['sour_diesel_low_weed'] = {
		label = 'Điếu Sour Diesel Kém',
		weight = 50,
		description = 'Điếu cần sa Sour Diesel chất lượng kém.',
	},
	['purple_haze_high_weed'] = {
		label = 'Điếu Purple Haze Cao Cấp',
		weight = 50,
		description = 'Điếu cần sa Purple Haze chất lượng cao, đã cuốn sẵn.',
	},
	['purple_haze_medium_weed'] = {
		label = 'Điếu Purple Haze Trung Bình',
		weight = 50,
		description = 'Điếu cần sa Purple Haze chất lượng trung bình.',
	},
	['purple_haze_low_weed'] = {
		label = 'Điếu Purple Haze Kém',
		weight = 50,
		description = 'Điếu cần sa Purple Haze chất lượng kém.',
	},
	['northern_lights_high_weed'] = {
		label = 'Điếu Northern Lights Cao Cấp',
		weight = 50,
		description = 'Điếu cần sa Northern Lights chất lượng cao, đã cuốn sẵn.',
	},
	['northern_lights_medium_weed'] = {
		label = 'Điếu Northern Lights Trung Bình',
		weight = 50,
		description = 'Điếu cần sa Northern Lights chất lượng trung bình.',
	},
	['northern_lights_low_weed'] = {
		label = 'Điếu Northern Lights Kém',
		weight = 50,
		description = 'Điếu cần sa Northern Lights chất lượng kém.',
	},

	-- Sativa Weed
	['blue_dream_high_weed'] = {
		label = 'Điếu Blue Dream Cao Cấp',
		weight = 50,
		description = 'Điếu cần sa Blue Dream chất lượng cao, đã cuốn sẵn.',
	},
	['blue_dream_medium_weed'] = {
		label = 'Điếu Blue Dream Trung Bình',
		weight = 50,
		description = 'Điếu cần sa Blue Dream chất lượng trung bình.',
	},
	['blue_dream_low_weed'] = {
		label = 'Điếu Blue Dream Kém',
		weight = 50,
		description = 'Điếu cần sa Blue Dream chất lượng kém.',
	},
	['jack_herer_high_weed'] = {
		label = 'Điếu Jack Herer Cao Cấp',
		weight = 50,
		description = 'Điếu cần sa Jack Herer chất lượng cao, đã cuốn sẵn.',
	},
	['jack_herer_medium_weed'] = {
		label = 'Điếu Jack Herer Trung Bình',
		weight = 50,
		description = 'Điếu cần sa Jack Herer chất lượng trung bình.',
	},
	['jack_herer_low_weed'] = {
		label = 'Điếu Jack Herer Kém',
		weight = 50,
		description = 'Điếu cần sa Jack Herer chất lượng kém.',
	},
	['super_lemon_haze_high_weed'] = {
		label = 'Điếu Super Lemon Haze Cao Cấp',
		weight = 50,
		description = 'Điếu cần sa Super Lemon Haze chất lượng cao, đã cuốn sẵn.',
	},
	['super_lemon_haze_medium_weed'] = {
		label = 'Điếu Super Lemon Haze Trung Bình',
		weight = 50,
		description = 'Điếu cần sa Super Lemon Haze chất lượng trung bình.',
	},
	['super_lemon_haze_low_weed'] = {
		label = 'Điếu Super Lemon Haze Kém',
		weight = 50,
		description = 'Điếu cần sa Super Lemon Haze chất lượng kém.',
	},

	-- Hybrid Weed
	['og_kush_high_weed'] = {
		label = 'Điếu OG Kush Cao Cấp',
		weight = 50,
		description = 'Điếu cần sa OG Kush chất lượng cao, đã cuốn sẵn.',
	},
	['og_kush_medium_weed'] = {
		label = 'Điếu OG Kush Trung Bình',
		weight = 50,
		description = 'Điếu cần sa OG Kush chất lượng trung bình.',
	},
	['og_kush_low_weed'] = {
		label = 'Điếu OG Kush Kém',
		weight = 50,
		description = 'Điếu cần sa OG Kush chất lượng kém.',
	},
	['gsc_high_weed'] = {
		label = 'Điếu Girl Scout Cookies Cao Cấp',
		weight = 50,
		description = 'Điếu cần sa Girl Scout Cookies chất lượng cao, đã cuốn sẵn.',
	},
	['gsc_medium_weed'] = {
		label = 'Điếu Girl Scout Cookies Trung Bình',
		weight = 50,
		description = 'Điếu cần sa Girl Scout Cookies chất lượng trung bình.',
	},
	['gsc_low_weed'] = {
		label = 'Điếu Girl Scout Cookies Kém',
		weight = 50,
		description = 'Điếu cần sa Girl Scout Cookies chất lượng kém.',
	},
	['wedding_cake_high_weed'] = {
		label = 'Điếu Wedding Cake Cao Cấp',
		weight = 50,
		description = 'Điếu cần sa Wedding Cake chất lượng cao, đã cuốn sẵn.',
	},
	['wedding_cake_medium_weed'] = {
		label = 'Điếu Wedding Cake Trung Bình',
		weight = 50,
		description = 'Điếu cần sa Wedding Cake chất lượng trung bình.',
	},
	['wedding_cake_low_weed'] = {
		label = 'Điếu Wedding Cake Kém',
		weight = 50,
		description = 'Điếu cần sa Wedding Cake chất lượng kém.',
	},

	-- Nguyên liệu tẩm
	['herbal_oil'] = {
		label = 'Dầu Thảo Mộc',
		weight = 200,
		description = 'Dầu chiết xuất từ thảo mộc, dùng để xử lý nụ cần.',
	},
	['glycerin'] = {
		label = 'Glycerin',
		weight = 150,
		description = 'Chất bảo quản tự nhiên, hỗ trợ quá trình tẩm cần.',
	},
	['lavender_essence'] = {
		label = 'Hoa Oải Hương',
		weight = 100,
		description = 'Tinh dầu oải hương thơm nhẹ, dùng trong pha chế.',
	},
	['curing_agent'] = {
		label = 'Chất Curing',
		weight = 200,
		description = 'Chất giúp quá trình tẩm khô đều và ổn định hơn.',
	},
	['flavor_oil'] = {
		label = 'Dầu Hương Liệu',
		weight = 150,
		description = 'Dầu hương tổng hợp, tạo mùi dễ chịu khi tẩm.',
	},
	['herbal_mix'] = {
		label = 'Hỗn Hợp Thảo Mộc',
		weight = 100,
		description = 'Hỗn hợp thảo mộc khô, dùng trong tẩm cần loại hybrid.',
	},
	['citrus_extract'] = {
		label = 'Tinh Chất Cam',
		weight = 100,
		description = 'Chiết xuất từ vỏ cam chanh, tạo mùi tươi mát.',
	},
	['peppermint'] = {
		label = 'Lá Bạc Hà',
		weight = 50,
		description = 'Lá bạc hà khô, thêm hương mát lạnh khi xử lý nụ.',
	},
	['ethanol'] = {
		label = 'Ethanol',
		weight = 200,
		description = 'Dung môi ethanol tinh khiết, dùng cho pha chế an toàn.',
	},
	['lemon_essence'] = {
		label = 'Tinh Chất Chanh',
		weight = 100,
		description = 'Tinh chất chanh tạo mùi tươi sáng cho cần Sativa.',
	},
	['stabilizer'] = {
		label = 'Chất Ổn Định',
		weight = 150,
		description = 'Giúp ổn định quá trình tẩm và tăng độ bền sản phẩm.',
	},
	['vanilla_extract'] = {
		label = 'Tinh Chất Vani',
		weight = 100,
		description = 'Chiết xuất từ vani, tạo hương ngọt cho cần hybrid.',
	},

	['cut_paper'] = {
		label = 'Giấy',
		weight = 50,
		stack = true,
		close = true,
		description = 'Giấy đã được cắt thành phẩm',
	},

	["engine_oil"] = {
		label = "Dầu Động Cơ",
		weight = 1000,
	},
	["tyre_replacement"] = {
		label = "Lốp Thay Thế",
		weight = 1000,
	},
	["clutch_replacement"] = {
		label = "Bộ Ly Hợp Thay Thế",
		weight = 1000,
	},
	["air_filter"] = {
		label = "Lọc Gió",
		weight = 100,
	},
	["spark_plug"] = {
		label = "Bugi",
		weight = 1000,
	},
	["brakepad_replacement"] = {
		label = "Má Phanh Thay Thế",
		weight = 1000,
	},
	["suspension_parts"] = {
		label = "Phụ Tùng Giảm Xóc",
		weight = 1000,
	},
	-- Engine Items
	["i4_engine"] = {
		label = "Động Cơ I4",
		weight = 1000,
	},
	["v6_engine"] = {
		label = "Động Cơ V6",
		weight = 1000,
	},
	["v8_engine"] = {
		label = "Động Cơ V8",
		weight = 1000,
	},
	["v12_engine"] = {
		label = "Động Cơ V12",
		weight = 1000,
	},
	["turbocharger"] = {
		label = "Tăng Áp Turbo",
		weight = 1000,
	},
	-- Electric Engines
	["ev_motor"] = {
		label = "Mô-tơ Điện",
		weight = 1000,
	},
	["ev_battery"] = {
		label = "Pin Xe Điện",
		weight = 1000,
	},
	["ev_coolant"] = {
		label = "Dung Dịch Làm Mát EV",
		weight = 1000,
	},
	-- Drivetrain Items
	["awd_drivetrain"] = {
		label = "Hệ Dẫn Động AWD",
		weight = 1000,
	},
	["rwd_drivetrain"] = {
		label = "Hệ Dẫn Động RWD",
		weight = 1000,
	},
	["fwd_drivetrain"] = {
		label = "Hệ Dẫn Động FWD",
		weight = 1000,
	},
	-- Tuning Items
	["slick_tyres"] = {
		label = "Lốp Slick",
		weight = 1000,
	},
	["semi_slick_tyres"] = {
		label = "Lốp Semi-Slick",
		weight = 1000,
	},
	["offroad_tyres"] = {
		label = "Lốp Off-Road",
		weight = 1000,
	},
	["drift_tuning_kit"] = {
		label = "Bộ Độ Drift",
		weight = 1000,
	},
	["ceramic_brakes"] = {
		label = "Phanh Gốm",
		weight = 1000,
	},
	-- Cosmetic Items
	["lighting_controller"] = {
		label = "Bộ Điều Khiển Đèn",
		weight = 100,
		client = {
		event = "DERP-mechanic:client:show-lighting-controller",
		}
	},
	["stancing_kit"] = {
		label = "Bộ Hạ Gầm",
		weight = 100,
		client = {
		event = "DERP-mechanic:client:show-stancer-kit",
		}
	},
	["cosmetic_part"] = {
		label = "Phụ Kiện Trang Trí",
		weight = 100,
	},
	["respray_kit"] = {
		label = "Bộ Sơn Lại",
		weight = 1000,
	},
	["vehicle_wheels"] = {
		label = "Bộ Mâm Xe",
		weight = 1000,
	},
	["tyre_smoke_kit"] = {
		label = "Bộ Khói Lốp",
		weight = 1000,
	},
	["bulletproof_tyres"] = {
		label = "Lốp Chống Đạn",
		weight = 1000,
	},
	["extras_kit"] = {
		label = "Bộ Phụ Kiện",
		weight = 1000,
	},
	-- Nitrous & Cleaning Items
	["nitrous_bottle"] = {
		label = "Bình Nitrous",
		weight = 1000,
		client = {
		event = "DERP-mechanic:client:use-nitrous-bottle",
		}
	},
	["empty_nitrous_bottle"] = {
		label = "Bình Nitrous Rỗng",
		weight = 1000,
	},
	["nitrous_install_kit"] = {
		label = "Bộ Lắp Nitrous",
		weight = 1000,
	},
	["cleaning_kit"] = {
		label = "Bộ Vệ Sinh Xe",
		weight = 1000,
		client = {
		event = "DERP-mechanic:client:clean-vehicle",
		}
	},
	["repair_kit"] = {
		label = "Bộ Sửa Chữa",
		weight = 1000,
		client = {
		event = "DERP-mechanic:client:repair-vehicle",
		}
	},
	["duct_tape"] = {
		label = "Băng Keo",
		weight = 1000,
		client = {
		event = "DERP-mechanic:client:use-duct-tape",
		}
	},
	-- Performance Item
	["performance_part"] = {
		label = "Phụ Tùng Hiệu Năng",
		weight = 1000,
	},
	-- Mechanic Tablet Item
	["mechanic_tablet"] = {
		label = "Máy Tính Bảng Thợ Máy",
		weight = 1000,
		client = {
		event = "DERP-mechanic:client:use-tablet",
		}
	},
	-- Gearbox
	["manual_gearbox"] = {
		label = "Hộp Số Sàn",
		weight = 1000,
	},

	["megaphone"] = {
		label = "Loa",
		weight = 500,
		stack = false,
		close = true,
		description = "Phát đại âm thanh"
	},

	['empty_evidence_bag'] = {
        label = 'Túi Vật Chứng',
        weight = 200,
    },

    ['filled_evidence_bag'] = {
        label = 'Túi Vật Chứng',
        weight = 200,
    },

	['low_speaker'] = {
		label = 'Loa Nhỏ',
		weight = 500,
		stack = false,
		close = true,
		description = 'Loa công suất nhỏ',
		client = {
			export = 'mt_speakers.useSpeaker'
		}
	},
	['medium_speaker'] = {
		label = 'Loa Vừa',
		weight = 1000,
		stack = false,
		close = true,
		description = 'Loa công suất vừa',
		client = {
			export = 'mt_speakers.useSpeaker'
		}
	},
	['high_speaker'] = {
		label = 'Loa Lớn',
		weight = 2000,
		stack = false,
		close = true,
		description = 'Loa công suất lớn',
		client = {
			export = 'mt_speakers.useSpeaker'
		}
	},
	['cloth'] = {
		label = 'Vải Bông',
		weight = 200,
		stack = true,
		close = true,
		description = 'Vải cao cấp.',
	},
	['drone'] = {
		label = 'Drone',
		weight = 800,
		stack = false,   
		close = true,
		client = {
			event = 'nzkfc_drone:useItem',
		},
	},

	['drone_battery'] = {
		label = 'Pin Drone',
		weight = 200,
		stack = false, 
		close = true,
	},

	['drone_battery_empty'] = {
		label = 'Pin Drone (Cạn)',
		weight = 200,
		stack = true,
		close = true,
	},

	  ["bodycam"] = {
        label = "bodycam", 
		weight = 0, 
		stack = false, 
		close = true, 
		description = "Bodycam",
        client = { image = "bodycam.png",
		event = "spy-bodycam:bodycamstatus" }
    },

	 ["dashcam"] = {
        label = "dashcam", 
		weight = 0, 
		stack = false, 
		close = true, 
		description = "dashcam",
        client = { image = "dashcam.png", 
		event = "spy-bodycam:toggleCarCam" }
    },

	-- ['syphoningkit'] = {
	-- 	label = 'Bộ Hút Xăng',
	-- 	weight = 5000,
	-- 	stack = false,
	-- 	close = false,
	-- 	description = 'Bộ dụng cụ dùng để hút xăng từ xe.',
	-- },

	['jerrycan'] = {
		label = 'Bình Xăng Dự Phòng',
		weight = 5000,
		stack = false,
		close = false,
		description = 'Bình chứa xăng dự phòng.',
	},

	['crimecamera'] = {
		label = 'Máy Ảnh',
		weight = 1000,
		stack = false,
		close = true,
		description = 'Máy ảnh hiện trường.',
	},

	['crimeimage'] = {
		label = 'Ảnh Hiện Trường',
		weight = 0,
		stack = false,
		consume = 0,
	},

	['contract'] = {
		label = 'Giấy Mua Bán Xe',
		weight = 0,
		stack = false,
		consume = 0,
		client = {
			event = 'kzo_contract:useitem'
		}
	},

	['boombox_white_large'] = {
		label = 'Large Boombox (White)',
		weight = 160,
	},
	['boombox_red_large'] = {
		label = 'Large Boombox (Red)',
		weight = 160,
	},
	['boombox_purple_large'] = {
		label = 'Large Boombox (Purple)',
		weight = 160,
	},
	['boombox_pink_large'] = {
		label = 'Large Boombox (Pink)',
		weight = 160,
	},
	['boombox_orange_large'] = {
		label = 'Large Boombox (Orange)',
		weight = 160,
	},
	['boombox_green_large'] = {
		label = 'Large Boombox (Green)',
		weight = 160,
	},
	['boombox_blue_large'] = {
		label = 'Large Boombox (Blue)',
		weight = 160,
	},

	['boombox_white_medium'] = {
		label = 'Medium Boombox (White)',
		weight = 160,
	},
	['boombox_red_medium'] = {
		label = 'Medium Boombox (Red)',
		weight = 160,
	},
	['boombox_purple_medium'] = {
		label = 'Medium Boombox (Purple)',
		weight = 160,
	},
	['boombox_pink_medium'] = {
		label = 'Medium Boombox (Pink)',
		weight = 160,
	},
	['boombox_orange_medium'] = {
		label = 'Medium Boombox (Orange)',
		weight = 160,
	},
	['boombox_green_medium'] = {
		label = 'Medium Boombox (Green)',
		weight = 160,
	},
	['boombox_blue_medium'] = {
		label = 'Medium Boombox (Blue)',
		weight = 160,
	},

	['boombox_white_small'] = {
		label = 'Small Boombox (White)',
		weight = 160,
	},
	['boombox_red_small'] = {
		label = 'Small Boombox (Red)',
		weight = 160,
	},
	['boombox_purple_small'] = {
		label = 'Small Boombox (Purple)',
		weight = 160,
	},
	['boombox_pink_small'] = {
		label = 'Small Boombox (Pink)',
		weight = 160,
	},
	['boombox_orange_small'] = {
		label = 'Small Boombox (Orange)',
		weight = 160,
	},
	['boombox_green_small'] = {
		label = 'Small Boombox (Green)',
		weight = 160,
	},
	['boombox_blue_small'] = {
		label = 'Small Boombox (Blue)',
		weight = 160,
	},

	['heistpack_drone'] = {
		label = 'Drone',
		weight = 3000,
		stack = false,
		close = true,
		description = 'Drone chiến thuật dùng cho các phi vụ cướp chuyên nghiệp.'
	},

	['gasmask'] = {
		label = 'Mặt Nạ Phòng Độc',
		weight = 1000,
		stack = false,
		close = true,
		description = 'Bảo vệ khỏi khí độc và khói nguy hiểm.'
	},

	['heistpack_drill'] = {
		label = 'Máy Khoan Công Nghiệp',
		weight = 5000,
		stack = false,
		close = true,
		description = 'Máy khoan chuyên dụng để phá két và cửa kho bạc.'
	},

	['weapon_hackingdevice'] = {
		label = 'Thiết Bị Hack',
		weight = 1500,
		stack = false,
		close = true,
		description = 'Thiết bị điện tử dùng để xâm nhập hệ thống bảo mật.'
	},

	['heavy_rope'] = {
		label = 'Dây Thừng Cỡ Lớn',
		weight = 2500,
		stack = true,
		close = true,
		description = 'Loại dây chắc chắn có thể kéo vật nặng.'
	},

	['weapon_stickybomb'] = {
		label = 'Bom Dính',
		weight = 2000,
		stack = false,
		close = true,
		description = 'Chất nổ có khả năng bám dính lên bề mặt.'
	},

	['heistpack_anchor'] = {
		label = 'Mỏ Neo',
		weight = 4000,
		stack = false,
		close = true,
		description = 'Mỏ neo hạng nặng dùng trong các phi vụ tàu hàng.'
	},

	['heistpack_grinder'] = {
		label = 'Máy Cắt Cầm Tay',
		weight = 3500,
		stack = false,
		close = true,
		description = 'Máy cắt dùng để phá khóa và cắt kim loại.'
	},

	['heistpack_tablet'] = {
		label = 'Máy Tính Bảng Nhiệm Vụ',
		weight = 1800,
		stack = false,
		close = true,
		description = 'Máy tính bảng chuyên dụng.'
	},

	    ['pitchfork'] = {
        label = 'Pitch Fork',
        weight = 1000,
        client = {
            export = 'Renewed-Farming.harvestPlants'
        },
	},
	
	['wateringcan'] = {
		label = 'Watering Can',
		weight = 0,
	},
	
	['beetroot'] = {
		label = 'Beetroot',
		description = 'Freshly harvested beetroot, perfect for cooking or adding to salads.',
		weight = 100
	},
	['beetrootseed'] = {
		label = 'Beetroot Seed',
		description = 'Small seeds used to grow beetroot plants.',
		weight = 10,
		client = {
			export = 'Renewed-Farming.placeSeed'
		},
	},
	
	['carrot'] = {
		label = 'Carrot',
		description = 'Crisp and nutritious carrots, a staple ingredient in many recipes. Can be enjoyed raw or cooked.',
		weight = 100
	},
	['carrotseed'] = {
		label = 'Carrot Seed',
		description = 'Tiny seeds used to grow carrot plants.',
		weight = 10,
		client = {
			export = 'Renewed-Farming.placeSeed'
		}
	},
	
	['corn'] = {
		label = 'Corn',
		description = 'Freshly harvested corn, sweet and juicy. Great for grilling or boiling.',
		weight = 100
	},
	['cornseed'] = {
		label = 'Corn Seed',
		description = 'Small seeds used to grow corn plants.',
		weight = 10,
		client = {
			export = 'Renewed-Farming.placeSeed'
		}
	},
	
	['cucumber'] = {
		label = 'Cucumber',
		description = 'Crisp and refreshing cucumbers, perfect for salads or pickling.',
		weight = 100
	},
	['cucumberseed'] = {
		label = 'Cucumber Seed',
		description = 'Tiny seeds used to grow cucumber plants.',
		weight = 10,
		client = {
			export = 'Renewed-Farming.placeSeed'
		}
	},
	
	['garlic'] = {
		label = 'Garlic',
		description = 'Aromatic garlic bulbs, known for their strong flavor and various culinary uses.',
		weight = 100
	},
	['garlicseed'] = {
		label = 'Garlic Seed',
		description = 'Small cloves used to grow garlic plants.',
		weight = 10,
		client = {
			export = 'Renewed-Farming.placeSeed'
		}
	},
	
	['potato'] = {
		label = 'Potato',
		description = 'Versatile and starchy potatoes, ideal for mashing, baking, or frying.',
		weight = 100,
		client = {
			export = 'Renewed-Farming.placeSeed'
		}
	},
	
	['pumpkin'] = {
		label = 'Pumpkin',
		description = 'Large and festive pumpkins, perfect for carving or using in autumn recipes.',
		weight = 100,
	},
	['pumpkinseed'] = {
		label = 'Pumpkin Seed',
		description = 'Seeds used to grow pumpkin plants.',
		weight = 10,
		client = {
			export = 'Renewed-Farming.placeSeed'
		}
	},
	
	['radish'] = {
		label = 'Radish',
		description = 'Crunchy and peppery radishes, great for adding a kick to salads or pickling.',
		weight = 100
	},
	['radishseed'] = {
		label = 'Radish Seed',
		description = 'Small seeds used to grow radish plants.',
		weight = 10,
		client = {
			export = 'Renewed-Farming.placeSeed'
		}
	},
	
	['sunflower'] = {
		label = 'Sunflower',
		description = 'Bright and cheerful sunflowers, known for their tall stalks and vibrant yellow petals.',
		weight = 100
	},
	['sunflowerseed'] = {
		label = 'Sunflower Seed',
		description = 'Seeds used to grow sunflower plants.',
		weight = 10,
		client = {
			export = 'Renewed-Farming.placeSeed'
		}
	},
	
	['tomato'] = {
		label = 'Tomato',
		description = 'Juicy and flavorful tomatoes, perfect for salads, sauces, or sandwiches.',
		weight = 100
	},
	['tomatoseed'] = {
		label = 'Tomato Seed',
		description = 'Small seeds used to grow tomato plants.',
		weight = 10,
		client = {
			export = 'Renewed-Farming.placeSeed'
		}
	},
	
	['watermelon'] = {
		label = 'Watermelon',
		description = 'Large and refreshing watermelons, perfect for summertime enjoyment.',
		weight = 100
	},
	['watermelonseed'] = {
		label = 'Watermelon Seed',
		description = 'Seeds used to grow watermelon plants.',
		weight = 10,
		client = {
			export = 'Renewed-Farming.placeSeed'
		}
	},
	
	['cabbage'] = {
		label = 'Cabbage',
		description = 'Fresh and crisp cabbage, perfect for salads and cooking.',
		weight = 100
	},
	['cabbageseed'] = {
		label = 'Cabbage Seed',
		description = 'Seeds used to grow cabbage plants.',
		weight = 10,
		client = {
			export = 'Renewed-Farming.placeSeed'
		}
	},
	
	['onion'] = {
		label = 'Onion',
		description = 'Pungent and flavorful onions, a kitchen essential.',
		weight = 100
	},
	['onionseed'] = {
		label = 'Onion Seed',
		description = 'Seeds used to grow onion plants.',
		weight = 10,
		client = {
			export = 'Renewed-Farming.placeSeed'
		}
	},
	
	['wheat'] = {
		label = 'Wheat',
		description = 'Golden wheat grains, a staple crop used for making flour and various food products.',
		weight = 100
	},
	['wheatseed'] = {
		label = 'Wheat Seed',
		description = 'Small seeds used to grow wheat plants.',
		weight = 10,
		client = {
			export = 'Renewed-Farming.placeSeed'
		}
	},
	
	['barley'] = {
		label = 'Barley',
		description = 'Barley grains, a staple crop used for making various food products.',
		weight = 50
	},
	['barleyseed'] = {
		label = 'Barley Seed',
		description = 'Small seeds used to grow barley plants.',
		weight = 10,
		client = {
			export = 'Renewed-Farming.placeSeed'
		}
	},
	
	['sugarbeet'] = {
		label = 'Sugarbeet',
		description = 'Freshly harvested sugar beets, perfect for cooking.',
		weight = 50
	},
	['sugarbeetseed'] = {
		label = 'Sugarbeet Seed',
		description = 'Small seeds used to grow sugarbeet plants.',
		weight = 10,
		client = {
			export = 'Renewed-Farming.placeSeed'
		}
	},
	
	['rice'] = {
		label = 'Rice',
		description = 'Freshly harvested rice, perfect for cooking.',
		weight = 100
	},
	['riceseed'] = {
		label = 'Rice Seed',
		description = 'Small seeds used to grow rice plants.',
		weight = 10,
		client = {
			export = 'Renewed-Farming.placeSeed'
		}
	},
	
	['pepper'] = {
		label = 'Rice',
		description = 'Freshly harvested peppers, perfect for cooking with some heat.',
		weight = 100
	},
	['pepperseed'] = {
		label = 'Pepper Seed',
		description = 'Small seeds used to grow pepper plants.',
		weight = 10,
		client = {
			export = 'Renewed-Farming.placeSeed'
		}
	},
	['news_camera'] = {
		label = 'Camera tin tức',
		weight = 1000,
		stack = false,
		close = true,
		consume = 0,
		description = 'Camera chuyên dụng của Weazel News',
		client = {
			event = 'qbx_newsjob:client:toggleCam'
		}
	},
	['news_mic'] = {
		label = 'Micro tin tức',
		weight = 500,
		stack = false,
		close = true,
		consume = 0,
		description = 'Micro cầm tay của Weazel News',
		client = {
			event = 'qbx_newsjob:client:toggleMic'
		}
	},
	['news_bmicrophone'] = {
		label = 'Micro cần câu',
		weight = 500,
		stack = false,
		close = true,
		consume = 0,
		description = 'Boom microphone của Weazel News',
		client = {
			event = 'qbx_newsjob:client:toggleBMic'
		}
	},
	['dirty_metal'] = {
		label = 'Kim Loại Bẩn',
		weight = 2000,
		stack = true,
		close = true,
		description = 'Mảnh kim loại quân dụng phế thải, cần tinh chế lại.',
		client = {
			image = 'dirty_metal.png'
		}
	},

	['dirty_gunpowder'] = {
		label = 'Lưu Huỳnh',
		weight = 1000,
		stack = true,
		close = true,
		description = 'Lưu huỳnh chưa qua xử lý, lẫn nhiều tạp chất.',
		client = {
			image = 'dirty_gunpowder.png'
		}
	},

	['refined_metal'] = {
		label = 'Kim Loại Tinh Luyện',
		weight = 250,
		stack = true,
		close = true,
		description = 'Kim loại đã được tinh chế, sẵn sàng để chế tạo.',
		client = {
			image = 'refined_metal.png'
		}
	},

	['gunpowder'] = {
		label = 'Thuốc Súng',
		weight = 100,
		stack = true,
		close = true,
		description = 'Thuốc súng đã tinh chế, dùng cho chế tạo đạn dược.',
		client = {
			image = 'gunpowder.png'
		}
	},

	['taurus_frame'] = {
		label = 'Khung Súng Taurus G2C',
		weight = 500,
		stack = false,
		close = true,
		description = 'Khung thân súng Taurus G2C, phần cốt lõi để chế tạo.',
		client = {
			image = 'taurus_frame.png'
		}
	},

	['taurus_slide'] = {
		label = 'Khối Trượt Taurus G2C',
		weight = 500,
		stack = false,
		close = true,
		description = 'Khối trượt phía trên nòng súng Taurus G2C.',
		client = {
			image = 'taurus_slide.png'
		}
	},

	['taurus_barrel'] = {
		label = 'Nòng Súng Taurus G2C',
		weight = 500,
		stack = false,
		close = true,
		description = 'Nòng ngắn dành riêng cho Taurus G2C.',
		client = {
			image = 'taurus_barrel.png'
		}
	},

-- Bait
			["bread"] = {
				label = "Bánh Mì",
				weight = 10,
				stack = true,
				close = true,
				description = "Bánh Mì",
				client = {
					image = "bread.png",
				}
			},
			
			["earthworm"] = {
				label = "Giun Đất",
				weight = 10,
				stack = true,
				close = true,
				description = "Giun Đất",
				client = {
					image = "earthworm.png",
				}
			},
			
			["dough"] = {
				label = "Bột Mì",
				weight = 10,
				stack = true,
				close = true,
				description = "Bột Mì",
				client = {
					image = "dough.png",
				}
			},
			
			["grub"] = {
				label = "Ấu Trùng",
				weight = 10,
				stack = true,
				close = true,
				description = "Ấu Trùng",
				client = {
					image = "grub.png",
				}
			},
			
			["caddis_fly"] = {
				label = "Ruồi Caddis",
				weight = 10,
				stack = true,
				close = true,
				description = "Ruồi Caddis",
				client = {
					image = "caddis_fly.png",
				}
			},
			
			["cheese"] = {
				label = "Phô Mai",
				weight = 10,
				stack = true,
				close = true,
				description = "Phô Mai",
				client = {
					image = "cheese.png",
				}
			},
			
			["fly"] = {
				label = "Ruồi",
				weight = 10,
				stack = true,
				close = true,
				description = "Ruồi",
				client = {
					image = "fly.png",
				}
			},
			
			["dragonfly"] = {
				label = "Chuồn Chuồn",
				weight = 10,
				stack = true,
				close = true,
				description = "Chuồn Chuồn",
				client = {
					image = "dragonfly.png",
				}
			},
			
			["grasshoper"] = {
				label = "Châu Chấu",
				weight = 10,
				stack = true,
				close = true,
				description = "Châu Chấu",
				client = {
					image = "grasshoper.png",
				}
			},
			
			["shrimp"] = {
				label = "Tôm",
				weight = 10,
				stack = true,
				close = true,
				description = "Tôm",
				client = {
					image = "shrimp.png",
				}
			},
			
			["leech"] = {
				label = "Con Đỉa",
				weight = 10,
				stack = true,
				close = true,
				description = "Con Đỉa",
				client = {
					image = "leech.png",
				}
			},
			
			["snail"] = {
				label = "Ốc Sên",
				weight = 10,
				stack = true,
				close = true,
				description = "Ốc Sên",
				client = {
					image = "snail.png",
				}
			},
			
			["liver"] = {
				label = "Gan",
				weight = 10,
				stack = true,
				close = true,
				description = "Gan",
				client = {
					image = "liver.png",
				}
			},
			-- Lines
			["express_fishing_super_line"] = {
				label = "Dây Express Super 0.1mm",
				weight = 70,
				stack = true,
				close = true,
				description = "Dây Express Super 0.1mm",
				client = {
					image = "express_fishing_super_line.png",
				}
			},
			
			["syberia_indiana_green"] = {
				label = "Dây Indiana Xanh 0.14mm",
				weight = 70,
				stack = true,
				close = true,
				description = "Dây Indiana Xanh 0.14mm",
				client = {
					image = "syberia_indiana_green.png",
				}
			},
			
			["syberia_indiana_white"] = {
				label = "Dây Indiana Trắng 0.18mm",
				weight = 70,
				stack = true,
				close = true,
				description = "Dây Indiana Trắng 0.18mm",
				client = {
					image = "syberia_indiana_white.png",
				}
			},
			
			["simmons_mono_original"] = {
				label = "Dây Simmons Original 0.25mm",
				weight = 70,
				stack = true,
				close = true,
				description = "Dây Simmons Original 0.25mm",
				client = {
					image = "simmons_mono_original.png",
				}
			},
			
			["simmons_mono_ss"] = {
				label = "Dây Simmons SS 0.28mm",
				weight = 70,
				stack = true,
				close = true,
				description = "Dây Simmons SS 0.28mm",
				client = {
					image = "simmons_mono_ss.png",
				}
			},
			
			["syberia_indiana_green_2"] = {
				label = "Dây Indiana Xanh 0.32mm",
				weight = 70,
				stack = true,
				close = true,
				description = "Dây Indiana Xanh 0.32mm",
				client = {
					image = "syberia_indiana_green_2.png",
				}
			},
			
			["syberia_indiana_white_2"] = {
				label = "Dây Indiana Trắng 0.36mm",
				weight = 70,
				stack = true,
				close = true,
				description = "Dây Indiana Trắng 0.36mm",
				client = {
					image = "syberia_indiana_white_2.png",
				}
			},
			
			["snake_power_line_clr"] = {
				label = "Dây Snake Power 0.41mm",
				weight = 70,
				stack = true,
				close = true,
				description = "Dây Snake Power 0.41mm",
				client = {
					image = "snake_power_line_clr.png",
				}
			},
			
			["simmons_mono_original_2"] = {
				label = "Dây Simmons Original 0.48mm",
				weight = 70,
				stack = true,
				close = true,
				description = "Dây Simmons Original 0.48mm",
				client = {
					image = "simmons_mono_original_2.png",
				}
			},
			
			["simmons_mono_ss_2"] = {
				label = "Dây Simmons SS 0.52mm",
				weight = 70,
				stack = true,
				close = true,
				description = "Dây Simmons SS 0.52mm",
				client = {
					image = "simmons_mono_ss_2.png",
				}
			},
			
			["snake_power_line_clr_2"] = {
				label = "Dây Snake Power 0.65mm",
				weight = 70,
				stack = true,
				close = true,
				description = "Dây Snake Power 0.65mm",
				client = {
					image = "snake_power_line_clr_2.png",
				}
			},
			
			["solid_hipower_nylon"] = {
				label = "Dây HiPower Nylon 0.8mm",
				weight = 70,
				stack = true,
				close = true,
				description = "Dây HiPower Nylon 0.8mm",
				client = {
					image = "solid_hipower_nylon.png",
				}
			},
			
			["solid_hipower_nylon_lime"] = {
				label = "Dây HiPower Nylon Vàng Chanh 0.85mm",
				weight = 70,
				stack = true,
				close = true,
				description = "Dây HiPower Nylon Vàng Chanh 0.85mm",
				client = {
					image = "solid_hipower_nylon_lime.png",
				}
			},
			
			["solid_hipower_nylon_orange"] = {
				label = "Dây HiPower Nylon Cam 0.9mm",
				weight = 70,
				stack = true,
				close = true,
				description = "Dây HiPower Nylon Cam 0.9mm",
				client = {
					image = "solid_hipower_nylon_orange.png",
				}
			},
			
			["solid_hipower_nylon_2"] = {
				label = "Dây HiPower Nylon 1.05mm",
				weight = 70,
				stack = true,
				close = true,
				description = "Dây HiPower Nylon 1.05mm",
				client = {
					image = "solid_hipower_nylon_2.png",
				}
			},
			
			["solid_hipower_nylon_lime_2"] = {
				label = "Dây HiPower Nylon Vàng Chanh 1.15mm",
				weight = 70,
				stack = true,
				close = true,
				description = "Dây HiPower Nylon Vàng Chanh 1.15mm",
				client = {
					image = "solid_hipower_nylon_lime_2.png",
				}
			},
			
			["solid_hipower_nylon_orange_2"] = {
				label = "Dây HiPower Nylon Cam 1.25mm",
				weight = 70,
				stack = true,
				close = true,
				description = "Dây HiPower Nylon Cam 1.25mm",
				client = {
					image = "solid_hipower_nylon_orange_2.png",
				}
			},
			-- Rods
			["ufe_telerod_370"] = {
				label = "Cần UFE Telerod 370",
				weight = 150,
				stack = false,
				close = true,
				description = "Cần UFE Telerod 370",
				client = {
					image = "ufe_telerod_370.png",
				}
			},
			
			["carptack_feeder_master_250"] = {
				label = "Cần Carptack Feeder Master 250",
				weight = 150,
				stack = false,
				close = true,
				description = "Cần Carptack Feeder Master 250",
				client = {
					image = "carptack_feeder_master_250.png",
				}
			},
			
			["sakura_tsubarea_tsa_552_xul"] = {
				label = "Cần Sakura Tsubarea TSA 552 XUL",
				weight = 150,
				stack = false,
				close = true,
				description = "Cần Sakura Tsubarea TSA 552 XUL",
				client = {
					image = "sakura_tsubarea_tsa_552_xul.png",
				}
			},
			
			["carpex_hybid_carp_270"] = {
				label = "Cần Carpex Hybid Carp 270",
				weight = 150,
				stack = false,
				close = true,
				description = "Cần Carpex Hybid Carp 270",
				client = {
					image = "carpex_hybid_carp_270.png",
				}
			},
			
			["ufe_float_x5_300"] = {
				label = "Cần UFE Float X5 300",
				weight = 150,
				stack = false,
				close = true,
				description = "Cần UFE Float X5 300",
				client = {
					image = "ufe_float_x5_300.png",
				}
			},
			
			["predatek_fast_perch_210"] = {
				label = "Cần Predatek Fast Perch 210",
				weight = 150,
				stack = false,
				close = true,
				description = "Cần Predatek Fast Perch 210",
				client = {
					image = "predatek_fast_perch_210.png",
				}
			},
			
			["sakura_ionizer_bass_insb_701_ml"] = {
				label = "Cần Sakura Ionizer Bass INSB 701",
				weight = 150,
				stack = false,
				close = true,
				description = "Cần Sakura Ionizer Bass INSB 701",
				client = {
					image = "sakura_ionizer_bass_insb_701_ml.png",
				}
			},
			
			["sakura_redbird_rds_602_l"] = {
				label = "Cần Sakura Redbird RDS 602 L",
				weight = 150,
				stack = false,
				close = true,
				description = "Cần Sakura Redbird RDS 602 L",
				client = {
					image = "sakura_redbird_rds_602_l.png",
				}
			},
			
			["carpex_cobalt_carp_360"] = {
				label = "Cần Carpex Cobalt Carp 360",
				weight = 150,
				stack = false,
				close = true,
				description = "Cần Carpex Cobalt Carp 360",
				client = {
					image = "carpex_cobalt_carp_360.png",
				}
			},
			
			["sakura_salt_sniper_salss_611_mj1"] = {
				label = "Cần Sakura Salt Sniper SALSS 611",
				weight = 150,
				stack = false,
				close = true,
				description = "Cần Sakura Salt Sniper SALSS 611",
				client = {
					image = "sakura_salt_sniper_salss_611_mj1.png",
				}
			},
			
			["sakura_speciz_spes_light_602_zander"] = {
				label = "Cần Sakura Speciz Spes Light 602",
				weight = 150,
				stack = false,
				close = true,
				description = "Cần Sakura Speciz Spes Light 602",
				client = {
					image = "sakura_speciz_spes_light_602_zander.png",
				}
			},
			
			["sakura_redbird_rds_662"] = {
				label = "Cần Sakura Redbird RDS 662",
				weight = 150,
				stack = false,
				close = true,
				description = "Cần Sakura Redbird RDS 662",
				client = {
					image = "sakura_redbird_rds_662.png",
				}
			},
			
			["sakura_salt_sniper_salss_902_h"] = {
				label = "Cần Sakura Salt Sniper SALSS 902",
				weight = 150,
				stack = false,
				close = true,
				description = "Cần Sakura Salt Sniper SALSS 902",
				client = {
					image = "sakura_salt_sniper_salss_902_h.png",
				}
			},
			
			["predatek_seahunter_230"] = {
				label = "Cần Predatek Seahunter 230",
				weight = 150,
				stack = false,
				close = true,
				description = "Cần Predatek Seahunter 230",
				client = {
					image = "predatek_seahunter_230.png",
				}
			},
			
			["sakura_shukan_shuc_661_lj"] = {
				label = "Cần Sakura Shukan Shuc 661 LJ",
				weight = 150,
				stack = false,
				close = true,
				description = "Cần Sakura Shukan Shuc 661 LJ",
				client = {
					image = "sakura_shukan_shuc_661_lj.png",
				}
			},
			
			["ufe_powercatch_270"] = {
				label = "Cần UFE Powercatch 270",
				weight = 150,
				stack = false,
				close = true,
				description = "Cần UFE Powercatch 270",
				client = {
					image = "ufe_powercatch_270.png",
				}
			},
			
			["predatek_pilk_200"] = {
				label = "Cần Predatek Pilk 200",
				weight = 150,
				stack = false,
				close = true,
				description = "Cần Predatek Pilk 200",
				client = {
					image = "predatek_pilk_200.png",
				}
			},
			
			["robinson_carbonic_nordic_pilk_300"] = {
				label = "Cần Robinson Carbonic Nordic Pilk",
				weight = 150,
				stack = false,
				close = true,
				description = "Cần Robinson Carbonic Nordic Pilk",
				client = {
					image = "robinson_carbonic_nordic_pilk_300.png",
				}
			},
			
			["carptack_bottom_cast_360"] = {
				label = "Cần Carptack Bottom Cast 360",
				weight = 150,
				stack = false,
				close = true,
				description = "Cần Carptack Bottom Cast 360",
				client = {
					image = "carptack_bottom_cast_360.png",
				}
			},
			
			["seax_salfighter_170"] = {
				label = "Cần Seax Salfighter 170",
				weight = 150,
				stack = false,
				close = true,
				description = "Cần Seax Salfighter 170",
				client = {
					image = "seax_salfighter_170.png",
				}
			},
			-- Reels
			["ufe_canta_1000"] = {
				label = "Máy Câu UFE Canta 1000",
				weight = 100,
				stack = false,
				close = true,
				description = "Máy Câu UFE Canta 1000",
				client = {
					image = "ufe_canta_1000.png",
				}
			},
			
			["ufe_barracuda_2000bt"] = {
				label = "Máy Câu UFE Barracuda 2000BT",
				weight = 100,
				stack = false,
				close = true,
				description = "Máy Câu UFE Barracuda 2000BT",
				client = {
					image = "ufe_barracuda_2000bt.png",
				}
			},
			
			["sakura_alpax_4508"] = {
				label = "Máy Câu Sakura Alpax 4508",
				weight = 100,
				stack = false,
				close = true,
				description = "Máy Câu Sakura Alpax 4508",
				client = {
					image = "sakura_alpax_4508.png",
				}
			},
			
			["sakura_alpax_8508"] = {
				label = "Máy Câu Sakura Alpax 8508",
				weight = 100,
				stack = false,
				close = true,
				description = "Máy Câu Sakura Alpax 8508",
				client = {
					image = "sakura_alpax_8508.png",
				}
			},
			
			["ufe_belona_4000"] = {
				label = "Máy Câu UFE Belona 4000",
				weight = 100,
				stack = false,
				close = true,
				description = "Máy Câu UFE Belona 4000",
				client = {
					image = "ufe_belona_4000.png",
				}
			},
			
			["ufe_bigspin_8000b"] = {
				label = "Máy Câu UFE Bigspin 8000B",
				weight = 100,
				stack = false,
				close = true,
				description = "Máy Câu UFE Bigspin 8000B",
				client = {
					image = "ufe_bigspin_8000b.png",
				}
			},
			
			["ufe_batara_8000g"] = {
				label = "Máy Câu UFE Batara 8000G",
				weight = 100,
				stack = false,
				close = true,
				description = "Máy Câu UFE Batara 8000G",
				client = {
					image = "ufe_batara_8000g.png",
				}
			},
			
			["ufe_batara_1000r"] = {
				label = "Máy Câu UFE Batara 1000R",
				weight = 100,
				stack = false,
				close = true,
				description = "Máy Câu UFE Batara 1000R",
				client = {
					image = "ufe_batara_1000r.png",
				}
			},
			
			["robinson_big_runner_807qd"] = {
				label = "Máy Câu Robinson Big Runner 807QD",
				weight = 100,
				stack = false,
				close = true,
				description = "Máy Câu Robinson Big Runner 807QD",
				client = {
					image = "robinson_big_runner_807qd.png",
				}
			},
			
			["spooler_catchpro_4000fd"] = {
				label = "Máy Câu Spooler Catchpro 4000FD",
				weight = 100,
				stack = false,
				close = true,
				description = "Máy Câu Spooler Catchpro 4000FD",
				client = {
					image = "spooler_catchpro_4000fd.png",
				}
			},
			
			["ufe_opensea_8000_x"] = {
				label = "Máy Câu UFE Opensea 8000-X",
				weight = 100,
				stack = false,
				close = true,
				description = "Máy Câu UFE Opensea 8000-X",
				client = {
					image = "ufe_opensea_8000-x.png",
				}
			},
			
			["spooler_catchpro_8000fd"] = {
				label = "Máy Câu Spooler Catchpro 8000FD",
				weight = 100,
				stack = false,
				close = true,
				description = "Máy Câu Spooler Catchpro 8000FD",
				client = {
					image = "spooler_catchpro_8000fd.png",
				}
			},
			
			["spooler_catchpro_14000fd"] = {
				label = "Máy Câu Spooler Catchpro 14000FD",
				weight = 100,
				stack = false,
				close = true,
				description = "Máy Câu Spooler Catchpro 14000FD",
				client = {
					image = "spooler_catchpro_14000fd.png",
				}
			},
			-- Hooks
			["ufa_bait_hook"] = {
				label = "Lưỡi Câu UFA Bait",
				weight = 40,
				stack = true,
				close = true,
				description = "Lưỡi Câu UFA Bait",
				client = {
					image = "ufa_bait_hook.png",
				}
			},
			
			["ufa_sproat_hook"] = {
				label = "Lưỡi Câu UFA Sproat",
				weight = 40,
				stack = true,
				close = true,
				description = "Lưỡi Câu UFA Sproat",
				client = {
					image = "ufa_sproat_hook.png",
				}
			},
			
			["captack_claw_xl_hook"] = {
				label = "Lưỡi Câu Captack Claw XL",
				weight = 40,
				stack = true,
				close = true,
				description = "Lưỡi Câu Captack Claw XL",
				client = {
					image = "captack_claw_xl_hook.png",
				}
			},
			
			["ufa_sproat_g_hook"] = {
				label = "Lưỡi Câu UFA Sproat-G",
				weight = 40,
				stack = true,
				close = true,
				description = "Lưỡi Câu UFA Sproat-G",
				client = {
					image = "ufa_sproat_g_hook.png",
				}
			},
			
			["carptack_carp_ss_hook"] = {
				label = "Lưỡi Câu Carptack Carp S&S",
				weight = 40,
				stack = true,
				close = true,
				description = "Lưỡi Câu Carptack Carp S&S",
				client = {
					image = "carptack_carp_ss_hook.png",
				}
			},
			
			["ufa_wide_gap_bl_hook"] = {
				label = "Lưỡi Câu UFA Wide Gap BL",
				weight = 40,
				stack = true,
				close = true,
				description = "Lưỡi Câu UFA Wide Gap BL",
				client = {
					image = "ufa_wide_gap_bl_hook.png",
				}
			},
			
			["ufa_aberdeen_hook"] = {
				label = "Lưỡi Câu UFA Aberdeen",
				weight = 40,
				stack = true,
				close = true,
				description = "Lưỡi Câu UFA Aberdeen",
				client = {
					image = "ufa_aberdeen_hook.png",
				}
			},
			
			["ufa_octopus_bl_hook"] = {
				label = "Lưỡi Câu UFA Octopus BL",
				weight = 40,
				stack = true,
				close = true,
				description = "Lưỡi Câu UFA Octopus BL",
				client = {
					image = "ufa_octopus_bl_hook.png",
				}
			},
			
			["ufa_livebait_hook"] = {
				label = "Lưỡi Câu UFA Livebait",
				weight = 40,
				stack = true,
				close = true,
				description = "Lưỡi Câu UFA Livebait",
				client = {
					image = "ufa_livebait_hook.png",
				}
			},
			
			["carptack_micro_barb_hook"] = {
				label = "Lưỡi Câu Carptack Micro Barb",
				weight = 40,
				stack = true,
				close = true,
				description = "Lưỡi Câu Carptack Micro Barb",
				client = {
					image = "carptack_micro_barb_hook.png",
				}
			},
			
			["carptack_carp_hook"] = {
				label = "Lưỡi Câu Carptack Carp",
				weight = 40,
				stack = true,
				close = true,
				description = "Lưỡi Câu Carptack Carp",
				client = {
					image = "carptack_carp_hook.png",
				}
			},
			
			["ufa_fusion_bl_hook"] = {
				label = "Lưỡi Câu UFA Fusion BL",
				weight = 40,
				stack = true,
				close = true,
				description = "Lưỡi Câu UFA Fusion BL",
				client = {
					image = "ufa_fusion_bl_hook.png",
				}
			},
			
			["predatek_octopus_hook"] = {
				label = "Lưỡi Câu Predatek Octopus",
				weight = 40,
				stack = true,
				close = true,
				description = "Lưỡi Câu Predatek Octopus",
				client = {
					image = "predatek_octopus_hook.png",
				}
			},
			
			["predatek_fusion_hook"] = {
				label = "Lưỡi Câu Predatek Fusion",
				weight = 40,
				stack = true,
				close = true,
				description = "Lưỡi Câu Predatek Fusion",
				client = {
					image = "predatek_fusion_hook.png",
				}
			},
			-- Scuba Shit
			["scuba"] = {
				label = "Đồ Lặn Scuba",
				weight = 300,
				stack = false,
				close = true,
				description = "Đồ Lặn Scuba",
				client = {
					image = "scuba.png",
				}
			},
			-- Fish
			["alligator_gar"] = {
				label = "Cá Sấu Mỹ",
				weight = 550,
				stack = true,
				close = true,
				description = "Cá Sấu Mỹ.",
				client = {
					image = "alligator_gar.png",
				}
			},
			
			["amur_pike"] = {
				label = "Cá Chó Amur",
				weight = 750,
				stack = true,
				close = true,
				description = "Cá Chó Amur.",
				client = {
					image = "amur_pike.png",
				}
			},
			
			["atlantic_cod"] = {
				label = "Cá Tuyết Đại Tây Dương",
				weight = 300,
				stack = true,
				close = true,
				description = "Cá Tuyết Đại Tây Dương.",
				client = {
					image = "atlantic_cod.png",
				}
			},
			
			["fishing_gear"] = {
				label = "Đồ Nghề Câu Cá",
				weight = 30,
				stack = false,
				close = true,
				description = "Đồ nghề thiết yếu để câu cá.",
				client = {
					image = "fishing_gear.png",
				}
			},
			
			["aquarium_pass"] = {
				label = "Vé Vào Thủy Cung",
				weight = 30,
				stack = false,
				close = true,
				description = "Vé vào cửa thủy cung.",
				client = {
					image = "aquarium_pass.png",
				}
			},
			
			["research_kit"] = {
				label = "Bộ Dụng Cụ Nghiên Cứu",
				weight = 30,
				stack = false,
				close = true,
				description = "Bộ dụng cụ dùng để nghiên cứu thực địa.",
				client = {
					image = "research_kit.png",
				}
			},

			["special_boots"] = {
				label = "Giày Đặc Biệt",
				weight = 30,
				stack = false,
				close = true,
				description = "Giày được thiết kế đặc biệt cho địa hình hiểm trở.",
				client = {
					image = "special_boots.png",
				}
			},
			
			["museum_ticket"] = {
				label = "Vé Vào Bảo Tàng",
				weight = 30,
				stack = false,
				close = true,
				description = "Vé vào cửa bảo tàng.",
				client = {
					image = "museum_ticket.png",
				}
			},
			
			["atlantic_salmon"] = {
				label = "Cá Hồi Đại Tây Dương",
				weight = 500,
				stack = true,
				close = true,
				description = "Cá Hồi Đại Tây Dương.",
				client = {
					image = "atlantic_salmon.png",
				}
			},
			
			["barbel"] = {
				label = "Cá Râu",
				weight = 600,
				stack = true,
				close = true,
				description = "Cá Râu.",
				client = {
					image = "barbel.png",
				}
			},
			
			["beluga_sturgeon"] = {
				label = "Cá Tầm Beluga",
				weight = 264,
				stack = true,
				close = true,
				description = "Cá Tầm Beluga.",
				client = {
					image = "beluga_sturgeon.png",
				}
			},
			
			["black_grayling"] = {
				label = "Cá Hồi Đen",
				weight = 120,
				stack = true,
				close = true,
				description = "Cá Hồi Đen.",
				client = {
					image = "black_grayling.png",
				}
			},
			
			["blacktip_reef_shark"] = {
				label = "Cá Mập Vây Đen",
				weight = 1500,
				stack = true,
				close = true,
				description = "Cá Mập Vây Đen.",
				client = {
					image = "blacktip_reef_shark.png",
				}
			},
			
			["blue_marlin"] = {
				label = "Cá Cờ Xanh",
				weight = 200,
				stack = true,
				close = true,
				description = "Cá Cờ Xanh.",
				client = {
					image = "blue_marlin.png",
				}
			},
			
			["bluefin_tuna"] = {
				label = "Cá Ngừ Vây Xanh",
				weight = 270,
				stack = true,
				close = true,
				description = "Cá Ngừ Vây Xanh.",
				client = {
					image = "bluefin_tuna.png",
				}
			},
			
			["bluegill"] = {
				label = "Cá Mang Xanh",
				weight = 120,
				stack = true,
				close = true,
				description = "Cá Mang Xanh.",
				client = {
					image = "bluegill.png",
				}
			},
			
			["brook_trout"] = {
				label = "Cá Hồi Suối",
				weight = 700,
				stack = true,
				close = true,
				description = "Cá Hồi Suối.",
				client = {
					image = "brook_trout.png",
				}
			},
			
			["brown_trout"] = {
				label = "Cá Hồi Nâu",
				weight = 230,
				stack = true,
				close = true,
				description = "Cá Hồi Nâu.",
				client = {
					image = "brown_trout.png",
				}
			},
			
			["bull_trout"] = {
				label = "Cá Hồi Bò",
				weight = 200,
				stack = true,
				close = true,
				description = "Cá Hồi Bò.",
				client = {
					image = "bull_trout.png",
				}
			},
			
			["chub"] = {
				label = "Cá Chép Trắng",
				weight = 150,
				stack = true,
				close = true,
				description = "Cá Chép Trắng.",
				client = {
					image = "chub.png",
				}
			},
			
			["chum_salmon"] = {
				label = "Cá Hồi Chum",
				weight = 600,
				stack = true,
				close = true,
				description = "Cá Hồi Chum.",
				client = {
					image = "chum_salmon.png",
				}
			},
			
			["coho_salmon"] = {
				label = "Cá Hồi Coho",
				weight = 500,
				stack = true,
				close = true,
				description = "Cá Hồi Coho.",
				client = {
					image = "coho_salmon.png",
				}
			},
			
			["common_bleak"] = {
				label = "Cá Liếp",
				weight = 10,
				stack = true,
				close = true,
				description = "Cá Liếp.",
				client = {
					image = "common_bleak.png",
				}
			},
			
			["common_bream"] = {
				label = "Cá Chép Bạc",
				weight = 400,
				stack = true,
				close = true,
				description = "Cá Chép Bạc.",
				client = {
					image = "common_bream.png",
				}
			},
			
			["common_carp"] = {
				label = "Cá Chép Thường",
				weight = 700,
				stack = true,
				close = true,
				description = "Cá Chép Thường.",
				client = {
					image = "common_carp.png",
				}
			},

			["crucian_carp"] = {
				label = "Cá Diếc",
				weight = 140,
				stack = true,
				close = true,
				description = "Cá Diếc.",
				client = {
					image = "crucian_carp.png",
				}
			},
			
			["european_bass"] = {
				label = "Cá Vược Châu Âu",
				weight = 250,
				stack = true,
				close = true,
				description = "Cá Vược Châu Âu.",
				client = {
					image = "european_bass.png",
				}
			},
			
			["european_eel"] = {
				label = "Cá Chình Châu Âu",
				weight = 300,
				stack = true,
				close = true,
				description = "Cá Chình Châu Âu.",
				client = {
					image = "european_eel.png",
				}
			},
			
			["european_flounder"] = {
				label = "Cá Bơn Châu Âu",
				weight = 170,
				stack = true,
				close = true,
				description = "Cá Bơn Châu Âu.",
				client = {
					image = "european_flounder.png",
				}
			},
			
			["european_perch"] = {
				label = "Cá Rô Châu Âu",
				weight = 500,
				stack = true,
				close = true,
				description = "Cá Rô Châu Âu.",
				client = {
					image = "european_perch.png",
				}
			},
			
			["european_sea_sturgeon"] = {
				label = "Cá Tầm Biển Châu Âu",
				weight = 2000,
				stack = true,
				close = true,
				description = "Cá Tầm Biển Châu Âu.",
				client = {
					image = "european_sea_sturgeon.png",
				}
			},
			
			["electric_eel"] = {
				label = "Cá Chình Điện",
				weight = 1500,
				stack = true,
				close = true,
				description = "Cá Chình Điện.",
				client = {
					image = "electric_eel.png",
				}
			},
			
			["garfish"] = {
				label = "Cá Nhím",
				weight = 50,
				stack = true,
				close = true,
				description = "Cá Nhím.",
				client = {
					image = "garfish.png",
				}
			},
			
			["giant_freshwater_stingray"] = {
				label = "Cá Đuối Nước Ngọt Khổng Lồ",
				weight = 350,
				stack = true,
				close = true,
				description = "Cá Đuối Nước Ngọt Khổng Lồ.",
				client = {
					image = "giant_freshwater_stingray.png",
				}
			},
			
			["giant_grouper"] = {
				label = "Cá Mú Khổng Lồ",
				weight = 260,
				stack = true,
				close = true,
				description = "Cá Mú Khổng Lồ.",
				client = {
					image = "giant_grouper.png",
				}
			},
			
			["giant_squid"] = {
				label = "Mực Khổng Lồ",
				weight = 2000,
				stack = true,
				close = true,
				description = "Mực Khổng Lồ.",
				client = {
					image = "giant_squid.png",
				}
			},
			
			["giant_trevally"] = {
				label = "Cá Khế Khổng Lồ",
				weight = 200,
				stack = true,
				close = true,
				description = "Cá Khế Khổng Lồ.",
				client = {
					image = "giant_trevally.png",
				}
			},
			
			["golden_trout"] = {
				label = "Cá Hồi Vàng",
				weight = 40,
				stack = true,
				close = true,
				description = "Cá Hồi Vàng.",
				client = {
					image = "golden_trout.png",
				}
			},
			
			["grass_carp"] = {
				label = "Cá Trắm Cỏ",
				weight = 120,
				stack = true,
				close = true,
				description = "Cá Trắm Cỏ.",
				client = {
					image = "grass_carp.png",
				}
			},
			
			["grass_pickerel"] = {
				label = "Cá Chó Cỏ",
				weight = 90,
				stack = true,
				close = true,
				description = "Cá Chó Cỏ.",
				client = {
					image = "grass_pickerel.png",
				}
			},
			
			["grayling"] = {
				label = "Cá Hồi Xám",
				weight = 80,
				stack = true,
				close = true,
				description = "Cá Hồi Xám.",
				client = {
					image = "grayling.png",
				}
			},
			
			["great_barracuda"] = {
				label = "Cá Nhồng Lớn",
				weight = 900,
				stack = true,
				close = true,
				description = "Cá Nhồng Lớn.",
				client = {
					image = "great_barracuda.png",
				}
			},
			
			["grey_snapper"] = {
				label = "Cá Hồng Xám",
				weight = 400,
				stack = true,
				close = true,
				description = "Cá Hồng Xám.",
				client = {
					image = "grey_snapper.png",
				}
			},
			
			["huchen"] = {
				label = "Cá Hồi Sông Danube",
				weight = 1500,
				stack = true,
				close = true,
				description = "Cá Hồi Sông Danube.",
				client = {
					image = "huchen.png",
				}
			},
			
			["ide"] = {
				label = "Cá Chép Vàng",
				weight = 100,
				stack = true,
				close = true,
				description = "Cá Chép Vàng.",
				client = {
					image = "ide.png",
				}
			},
			
			["indian_threadfish"] = {
				label = "Cá Chỉ Vàng Ấn Độ",
				weight = 250,
				stack = true,
				close = true,
				description = "Cá Chỉ Vàng Ấn Độ.",
				client = {
					image = "indian_threadfish.png",
				}
			},
			
			["lake_sturgeon"] = {
				label = "Cá Tầm Hồ",
				weight = 1600,
				stack = true,
				close = true,
				description = "Cá Tầm Hồ.",
				client = {
					image = "lake_sturgeon.png",
				}
			},
			
			["largemouth_bass"] = {
				label = "Cá Vược Miệng Lớn",
				weight = 100,
				stack = true,
				close = true,
				description = "Cá Vược Miệng Lớn.",
				client = {
					image = "largemouth_bass.png",
				}
			},
			
			["mahi_mahi"] = {
				label = "Cá Nục Vây Vàng",
				weight = 1000,
				stack = true,
				close = true,
				description = "Cá Nục Vây Vàng.",
				client = {
					image = "mahi_mahi.png",
				}
			},
			
			["malabar_grouper"] = {
				label = "Cá Mú Malabar",
				weight = 1500,
				stack = true,
				close = true,
				description = "Cá Mú Malabar.",
				client = {
					image = "malabar_grouper.png",
				}
			},
			
			["mirror_carp"] = {
				label = "Cá Chép Gương",
				weight = 700,
				stack = true,
				close = true,
				description = "Cá Chép Gương.",
				client = {
					image = "mirror_carp.png",
				}
			},
			
			["northern_pike"] = {
				label = "Cá Chó Phương Bắc",
				weight = 500,
				stack = true,
				close = true,
				description = "Cá Chó Phương Bắc.",
				client = {
					image = "northern_pike.png",
				}
			},
			
			["pink_river_dolphin"] = {
				label = "Cá Heo Sông Hồng",
				weight = 1550,
				stack = true,
				close = true,
				description = "Cá Heo Sông Hồng.",
				client = {
					image = "pink_river_dolphin.png",
				}
			},
			
			["pink_salmon"] = {
				label = "Cá Hồi Hồng",
				weight = 200,
				stack = true,
				close = true,
				description = "Cá Hồi Hồng.",
				client = {
					image = "pink_salmon.png",
				}
			},
			
			["prussian_carp"] = {
				label = "Cá Chép Phổ",
				weight = 90,
				stack = true,
				close = true,
				description = "Cá Chép Phổ.",
				client = {
					image = "prussian_carp.png",
				}
			},
			
			["pufferfish"] = {
				label = "Cá Nóc",
				weight = 150,
				stack = true,
				close = true,
				description = "Cá Nóc.",
				client = {
					image = "pufferfish.png",
				}
			},
			
			["pumpkinseed"] = {
				label = "Cá Bí Ngô",
				weight = 40,
				stack = true,
				close = true,
				description = "Cá Bí Ngô.",
				client = {
					image = "pumpkinseed.png",
				}
			},
			
			["rainbow_trout"] = {
				label = "Cá Hồi Cầu Vồng",
				weight = 100,
				stack = true,
				close = true,
				description = "Cá Hồi Cầu Vồng.",
				client = {
					image = "rainbow_trout.png",
				}
			},
			
			["red_lionfish"] = {
				label = "Cá Mao Tiên Đỏ",
				weight = 100,
				stack = true,
				close = true,
				description = "Cá Mao Tiên Đỏ.",
				client = {
					image = "red_lionfish.png",
				}
			},
			
			["redeye_piranha"] = {
				label = "Cá Piranha Mắt Đỏ",
				weight = 120,
				stack = true,
				close = true,
				description = "Cá Piranha Mắt Đỏ.",
				client = {
					image = "redeye_piranha.png",
				}
			},
			
			["redfin_pickerel"] = {
				label = "Cá Chó Vây Đỏ",
				weight = 40,
				stack = true,
				close = true,
				description = "Cá Chó Vây Đỏ.",
				client = {
					image = "redfin_pickerel.png",
				}
			},
			
			["roach"] = {
				label = "Cá Roach",
				weight = 50,
				stack = true,
				close = true,
				description = "Cá Roach.",
				client = {
					image = "roach.png",
				}
			},
			
			["sea_trout"] = {
				label = "Cá Hồi Biển",
				weight = 200,
				stack = true,
				close = true,
				description = "Cá Hồi Biển.",
				client = {
					image = "sea_trout.png",
				}
			},
			
			["silver_carp"] = {
				label = "Cá Trắm Bạc",
				weight = 1000,
				stack = true,
				close = true,
				description = "Cá Trắm Bạc.",
				client = {
					image = "silver_carp.png",
				}
			},
			
			["skeleton"] = {
				label = "Bộ Xương",
				weight = 10,
				stack = true,
				close = true,
				description = "Bộ Xương.",
				client = {
					image = "skeleton.png",
				}
			},
			
			["smallmouth_bass"] = {
				label = "Cá Vược Miệng Nhỏ",
				weight = 150,
				stack = true,
				close = true,
				description = "Cá Vược Miệng Nhỏ.",
				client = {
					image = "smallmouth_bass.png",
				}
			},
			
			["sockeye_salmon"] = {
				label = "Cá Hồi Đỏ",
				weight = 300,
				stack = true,
				close = true,
				description = "Cá Hồi Đỏ.",
				client = {
					image = "sockeye_salmon.png",
				}
			},
			
			["south_sea_pearl_oyster"] = {
				label = "Hàu Ngọc Trai Nam Hải",
				weight = 10,
				stack = true,
				close = true,
				description = "Hàu Ngọc Trai Nam Hải.",
				client = {
					image = "south_sea_pearl_oyster.png",
				}
			},
			
			["tench"] = {
				label = "Cá Chép Xanh",
				weight = 250,
				stack = true,
				close = true,
				description = "Cá Chép Xanh.",
				client = {
					image = "tench.png",
				}
			},
			
			["tiger_shark"] = {
				label = "Cá Mập Hổ",
				weight = 5500,
				stack = true,
				close = true,
				description = "Cá Mập Hổ.",
				client = {
					image = "tiger_shark.png",
				}
			},
			
			["wels_catfish"] = {
				label = "Cá Trê Khổng Lồ",
				weight = 400,
				stack = true,
				close = true,
				description = "Cá Trê Khổng Lồ.",
				client = {
					image = "wels_catfish.png",
				}
			},
			
			["white_sturgeon"] = {
				label = "Cá Tầm Trắng",
				weight = 800,
				stack = true,
				close = true,
				description = "Cá Tầm Trắng.",
				client = {
					image = "white_sturgeon.png",
				}
			},
			
			["yellow_perch"] = {
				label = "Cá Rô Vàng",
				weight = 40,
				stack = true,
				close = true,
				description = "Cá Rô Vàng.",
				client = {
					image = "yellow_perch.png",
				}
			},
			
			["yellowfin_tuna"] = {
				label = "Cá Ngừ Vây Vàng",
				weight = 900,
				stack = true,
				close = true,
				description = "Cá Ngừ Vây Vàng.",
				client = {
					image = "yellowfin_tuna.png",
				}
			},
			
			["yellowtail_barracuda"] = {
				label = "Cá Nhồng Đuôi Vàng",
				weight = 110,
				stack = true,
				close = true,
				description = "Cá Nhồng Đuôi Vàng.",
				client = {
					image = "yellowtail_barracuda.png",
				}
			},
			
			["zander"] = {
				label = "Cá Măng",
				weight = 200,
				stack = true,
				close = true,
				description = "Cá Măng.",
				client = {
					image = "zander.png",
				}
			},
			
			["paddlefish"] = {
				label = "Cá Mái Chèo",
				weight = 1000,
				stack = true,
				close = true,
				description = "Cá Mái Chèo hiếm và bị cấm.",
				client = {
					image = "paddlefish.png",
				}
			},
			
			["sawfish"] = {
				label = "Cá Cưa",
				weight = 1000,
				stack = true,
				close = true,
				description = "Cá Cưa hiếm và bị cấm.",
				client = {
					image = "sawfish.png",
				}
			},
			
			["eel"] = {
				label = "Cá Chình",
				weight = 1000,
				stack = true,
				close = true,
				description = "Cá Chình hiếm và bị cấm.",
				client = {
					image = "eel.png",
				}
			},
			
			["hammerheadshark"] = {
				label = "Cá Mập Đầu Búa",
				weight = 2500,
				stack = true,
				close = true,
				description = "Cá Mập Đầu Búa hiếm và bị cấm.",
				client = {
					image = "hammerheadshark.png",
				}
			},
			
			["seaturtle"] = {
				label = "Rùa Biển",
				weight = 2500,
				stack = true,
				close = true,
				description = "Rùa Biển hiếm và bị cấm.",
				client = {
					image = "seaturtle.png",
				}
			},
			
			["leopardshark"] = {
				label = "Cá Mập Báo",
				weight = 2500,
				stack = true,
				close = true,
				description = "Cá Mập Báo hiếm và bị cấm.",
				client = {
					image = "leopardshark.png",
				}
			},
			
			["blueshark"] = {
				label = "Cá Mập Xanh",
				weight = 4000,
				stack = true,
				close = true,
				description = "Cá Mập Xanh huyền thoại và bị cấm.",
				client = {
					image = "blueshark.png",
				}
			},
			
			["greatwhiteshark"] = {
				label = "Cá Mập Trắng Lớn",
				weight = 10000,
				stack = true,
				close = true,
				description = "Cá Mập Trắng Lớn thần thoại và bị cấm.",
				client = {
					image = "greatwhiteshark.png",
				}
			},
			
			-- Diving Items
			["ancient_artifact"] = {
				label = "Cổ Vật Cổ Đại",
				weight = 1000,
				stack = true,
				close = true,
				description = "Một cổ vật cổ đại!",
				client = {
					image = "ancient_artifact.png",
				}
			},

			["antique_compass"] = {
				label = "La Bàn Cổ",
				weight = 1000,
				stack = true,
				close = true,
				description = "Một chiếc la bàn cổ.",
				client = {
					image = "antique_compass.png",
				}
			},

			["enchanted_jewel"] = {
				label = "Đá Quý Phong Ấn",
				weight = 1000,
				stack = true,
				close = true,
				description = "Một viên đá quý được phong ấn.",
				client = {
					image = "enchanted_jewel.png",
				}
			},

			["luxury_watch"] = {
				label = "Đồng Hồ Xa Xỉ",
				weight = 1000,
				stack = true,
				close = true,
				description = "Một chiếc đồng hồ đắt tiền.",
				client = {
					image = "luxury_watch.png",
				}
			},

			["meteorite_ore"] = {
				label = "Quặng Thiên Thạch",
				weight = 1000,
				stack = true,
				close = true,
				description = "Quặng thiên thạch.",
				client = {
					image = "meteorite_ore.png",
				}
			},

			["mystic_crystal"] = {
				label = "Pha Lê Huyền Bí",
				weight = 1000,
				stack = true,
				close = true,
				description = "Một viên pha lê huyền bí.",
				client = {
					image = "mystic_crystal.png",
				}
			},

			["phantom_amulet"] = {
				label = "Bùa Hộ Mệnh Bóng Ma",
				weight = 1000,
				stack = true,
				close = true,
				description = "Một chiếc bùa hộ mệnh bóng ma.",
				client = {
					image = "phantom_amulet.png",
				}
			},

			["precious_pearls"] = {
				label = "Ngọc Trai Quý",
				weight = 1000,
				stack = true,
				close = true,
				description = "Một nắm ngọc trai quý giá.",
				client = {
					image = "precious_pearls.png",
				}
			},

			["rare_spices"] = {
				label = "Gia Vị Quý Hiếm",
				weight = 1000,
				stack = true,
				close = true,
				description = "Bộ sưu tập gia vị quý hiếm.",
				client = {
					image = "rare_spices.png",
				}
			},

			["spy_gadget"] = {
				label = "Thiết Bị Điệp Viên",
				weight = 1000,
				stack = true,
				close = true,
				description = "Một thiết bị điệp viên bí ẩn.",
				client = {
					image = "spy_gadget.png",
				}
			},
	
	['stone'] = {
		label       = 'Đá Thô',
		weight      = 500,
		stack       = true,
		close       = false,
		description = 'Đá thô chưa được xử lý.',
	},
	
	['stone_white'] = {
        label = 'Đá Trắng Đục',
        weight = 500,
        stack = false,
        close = false,
		description = 'Đá thô có vân trắng đục.',
    },
    ['stone_lightblue'] = {
        label = 'Đá Xanh Nhạt',
        weight = 500,
        stack = false,
        close = false,
		description = 'Đá thô có vân xanh nhạt.',
    },
    ['stone_green'] = {
        label = 'Đá Xanh Lục',
        weight = 500,
        stack = false,
        close = false,
		description = 'Đá thô có vân xanh lục.',
    },
    ['stone_darkgreen'] = {
        label = 'Đá Lục Đậm',
        weight = 500,
        stack = false,
        close = false,
		description = 'Đá thô có vân xanh đậm.',
    },


	['jade_waste'] = {
		label       = 'Đá Cuội',
		weight      = 200,
		stack       = true,
		close       = false,
		description = 'Khối đá không chứa phỉ thúy có giá trị.',
	},

	['jade_dau_chung'] = {
		label       = 'Phỉ Thúy Đậu Chủng',
		weight      = 200,
		stack       = true,
		close       = false,
		description = 'Loại phỉ thúy phổ biến, kết cấu hạt rõ và giá trị thấp.',
	},

	['jade_nhu_chung'] = {
		label       = 'Phỉ Thúy Nhu Chủng',
		weight      = 200,
		stack       = true,
		close       = false,
		description = 'Phỉ thúy có độ mịn tốt, màu sắc hài hòa và giá trị khá.',
	},

	['jade_bang_chung'] = {
		label       = 'Phỉ Thúy Băng Chủng',
		weight      = 200,
		stack       = true,
		close       = false,
		description = 'Phỉ thúy trong trẻo như băng, được giới sưu tầm ưa chuộng.',
	},

	['jade_cao_bang'] = {
		label       = 'Phỉ Thúy Cao Băng',
		weight      = 200,
		stack       = true,
		close       = false,
		description = 'Biến thể cao cấp của Băng Chủng với độ trong và độ sáng vượt trội.',
	},

	['jade_thuy_tinh'] = {
		label       = 'Phỉ Thúy Thủy Tinh Chủng',
		weight      = 200,
		stack       = true,
		close       = false,
		description = 'Loại phỉ thúy cực hiếm với độ trong suốt gần như pha lê.',
	},

	['jade_de_vuong_luc'] = {
		label       = 'Phỉ Thúy Đế Vương Lục',
		weight      = 200,
		stack       = true,
		close       = false,
		description = 'Tuyệt phẩm phỉ thúy mang sắc lục đậm đặc trưng và giá trị rất cao.',
	},

	['jade_de_vuong_luc_legend'] = {
		label       = 'Đế Vương Lục Thần Phẩm',
		weight      = 200,
		stack       = true,
		close       = false,
		description = 'Báu vật hiếm có trong giới đổ thạch, gần như không thể tìm thấy.',
	},
}

