OX INSTALL QUIDE

1. Download all dependencies!
    Dependencies:
    ox_lib | https://github.com/overextended/ox_lib
    es_extended / qb-core
    qtarget / qb-target / ox_target
    lockpick | https://github.com/baguscodestudio/lockpick
	howdy-hackminigame | https://github.com/HiHowdy/howdy-hackminigame
	pd-safe |	https://github.com/VHall1/pd-safe
	mka-lasers | https://github.com/mkafrin/mka-lasers
	xsound (with emulator for interact sound) or interactsound

2. Add Images to your inventory
	ox_inventory > web > build > images
	Paste images from folder images to ox_inventory > web > build > img

3. Add Items to your inventory
	ox_inventory > data> items.lua

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

	['lockpick'] = {
		label = 'Bộ Mở Khóa',
		description = "Có thể mở bất kỳ ổ khóa nào nếu đủ kỹ năng!",
		weight = 165,
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
		label = 'Tiểu Thuyết Tình Cảm',
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
		label = 'Đầu Lâu Nạm Kim Cương',
		weight = 95,
		stack = true
	},

4. add ensure drc_houserobbery into your server.cfg (make sure to start it after ox_lib and your target system!)

5. Enjoy your new houserobbery script from DRC SCRIPTS!