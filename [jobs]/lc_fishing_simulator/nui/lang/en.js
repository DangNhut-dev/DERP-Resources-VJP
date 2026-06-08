// if (Lang == undefined) {
// 	var Lang = [];
// }
// Lang["en"] = {
// 	common: {
// 		confirm: "Confirm",
// 		weight_unit: "kg",
// 		level_abbreviate: "Lvl.",
// 		skill_point: "Skill point",
// 		areas: {
// 			sea: "Sea",
// 			lake: "Lake",
// 			river: "River",
// 			swamp: "Swamp",
// 			all: "All",
// 		},
// 	},
// 	sidebar: {
// 		profile: "Your Profile",
// 		bank: "Bank",
// 		deliveries: "Special deliveries",
// 		dives: "Dives",
// 		upgrades: "Upgrades",
// 		equipments: "Equipments",
// 		store: "Store",
// 		owned_vehicles: "Owned vehicles",
// 		owned_property: "Owned properties",
// 		guide: "Guide",
// 		close: "Close",
// 		property: "Property",
// 		fish_store: "Fish store",
// 	},
// 	modals: {
// 		confirmation: {
// 			sell_vehicle: "Are you sure you want to sell this vehicle?",
// 			sell_propertty: "Are you sure you want to sell this property? All the items in storage will be lost",
// 			loan_payoff: "Are you sure you want to pay the entire balance of {0}?",
// 			sell_all_fishes: "This action will sell all the fish in your inventory. Are you sure you want to proceed?",
// 		},
// 	},
// 	statistics_page: {
// 		title: "Statistics",
// 		desc: "Statistics to track your fishing life progression",
// 		money_earned: "Total money earned",
// 		money_spent: "Total money spent",
// 		total_mythic_fish: "Total mythic fish caught",
// 		total_legendary_fish: "Total legendary fish caught",
// 		total_all_fish: "Total fishes caught",
// 		total_dives: "Total dives finished",
// 		total_deliveries: "Total deliveries finished",
// 		total_exp: "Total EXP earned",
// 		total_upgrades: "Total upgrades purchased",
// 		top_users: {
// 			title: "Top fishermans",
// 			desc: "Top 10 fishermans in the city",
// 			fishes_caught: "Fishes caught: {0}",
// 			exp: "EXP: {0}",
// 		},
// 	},
// 	deliveries_page: {
// 		title: "Deliveries",
// 		desc: "Complete orders to receive special pricing for fish. Select a contract to start and deliver the requested fishes to the client",
// 		contracts_time: "New contracts each {0} min",
// 		reward: "Reward",
// 		required_items: "Required items",
// 		start_button: "Start contract",
// 		cancel_button: "Cancel contract",
// 		see_location: "See location",
// 		missing_item: "You don't have this",
// 	},
// 	dives_page: {
// 		start_button: "Start dive",
// 		cancel_button: "Cancel dive",
// 		title: "Dives",
// 		desc: "Complete underwater expeditions to find treasures and rare items. Select a dive mission to start and earn unique rewards, but note that the locations of treasure chests aren't accurate on your GPS, making it challenging even for the most experienced",
// 		time: "New dives each {0} min",
// 	},
// 	bank_page: {
// 		title: "Bank",
// 		desc: "View your company's bank account information here",
// 		withdraw: "Withdraw money",
// 		deposit: "Deposit Money",
// 		balance: "Your balance is:",
// 		active_loans: "Active loans",

// 		loan_title: "Loans",
// 		loan_desc: "Take out loans to invest in your business!<BR>(Maximum loan: {0})",
// 		loan_button: "Take loan",
// 		loan_value_title: "Loan amount",
// 		loan_daily_title: "Daily cost",
// 		loan_remaining_title: "Remaining amount",
// 		loan_date_title: "Next payment (Auto-Debit)",
// 		loan_pay: "Payoff Loan",

// 		loan_modal_desc: "Select one of the loan types:",
// 		loan_modal_item: "({0}% interest rate, repayable in {1} days)",
// 		loan_modal_submit: "Take loan",

// 		deposit_modal_title: "Deposit money",
// 		deposit_modal_desc: "How much do you want to deposit?",
// 		deposit_modal_submit: "Deposit money",

// 		withdraw_modal_title: "Withdraw money",
// 		withdraw_modal_desc: "How much do you want to withdraw?",
// 		withdraw_modal_submit: "Withdraw money",

// 		modal_placeholder: "Amount",
// 		modal_money_available: "Available money: {0}",
// 		modal_cancel: "Cancel",
// 	},
// 	upgrades_page: {
// 		title: "Skills",
// 		desc: "Use your accumulated skill points to unlock new abilities that will improve your fishing experience. There is a diverse range of skills that can make you a better fisherman",
// 		vehicles: {
// 			title: "Vehicles",
// 			desc: "Upgrade your garage capacity to accommodate more vehicles for transporting your fish.",
// 			level: "+{0} vehicle slots in your garage<BR>+ Unlocks new vehicles to purchase",
// 		},
// 		boats: {
// 			title: "Boats",
// 			desc: "Upgrade your dock capacity to accommodate more boats for transporting your fish.",
// 			level: "+{0} vehicle slots in your garage<BR>+ Unlocks new boats to purchase",
// 		},
// 		properties: {
// 			title: "Properties",
// 			desc: "Unlock new properties to make them purchasable.",
// 			level: "Unlocks new properties to purchase",
// 		},
// 		lake: {
// 			title: "Lake",
// 			desc: "Upgrade your lake skills to catch more types of fish.",
// 			level: "Unlocks new fish species in the lake",
// 		},
// 		river: {
// 			title: "River",
// 			desc: "Upgrade your river skills to catch more types of fish.",
// 			level: "Unlocks new fish species in the river",
// 		},
// 		swamp: {
// 			title: "Swamp",
// 			desc: "Upgrade your swamp skills to catch more types of fish.",
// 			level: "Unlocks new fish species in the swamp",
// 		},
// 		sea: {
// 			title: "Sea",
// 			desc: "Upgrade your sea skills to catch more types of fish.",
// 			level: "Unlocks new fish species in the sea",
// 		},
// 	},
// 	equipments_page: {
// 		title: "Equipments",
// 		desc: "Purchase new fishing equipments to improve your fishing techniques. Improve your reaction time, increase the chances of catching rare fish, and reduce the wait time for bites. Invest on your equipment to increase your fishing effectiveness and success",
// 		name: "Name",
// 		price: "Price",
// 		bonus: "Bonus",
// 		amount: "Amount",
// 		buy_button: "Buy",
// 		unlock_text: "Reach <b>level {0}</b> to unlock this equipment",
// 		rod: {
// 			title: "Rod",
// 			desc: "Upgrade your fishing rod to increase the chances of catching rarer fishes",
// 		},
// 		reel: {
// 			title: "Reel",
// 			desc: "Upgrade your reel to increase the reeling performance, making the reeling progress be faster",
// 		},
// 		hook: {
// 			title: "Hook",
// 			desc: "Upgrade your hook to increase the time you have to react when hooking a fish, making it easier to catch",
// 		},
// 		line: {
// 			title: "Line",
// 			desc: "This upgrade will make your line stronger, this means that will be easier to control the tension and faster to catch the fish",
// 		},
// 		bait: {
// 			title: "Bait",
// 			desc: "Upgrade your bait to reduce the wait time for a fish to bite, starting your fishing sooner",
// 		},
// 		other : {
// 			title: "Other",
// 			desc: "Other equiments to improve your fishing experience",
// 		},
// 	},
// 	store_page: {
// 		title: "Fleet & Property Store",
// 		desc: "Purchase vehicles, boats, and properties to improve your delivery capabilities. Select from a variety of options to improve your efficiency and expand your operations",
// 		buy_button: "Buy",
// 		tabs: {
// 			vehicle: "Vehicles",
// 			boat: "Boats",
// 			property: "Properties",
// 		},
// 		vehicle: {
// 			name: "Vehicle",
// 			price: "Price",
// 			trunk: "Weight",
// 		},
// 		property: {
// 			name: "Property",
// 			capacity: "Capacity",
// 			owned: "You already own this property",
// 		},
// 	},
// 	owned_vehicles_page: {
// 		title: "Owned vehicles",
// 		desc: "View and manage your garage, where you can monitor the condition and fuel levels of your boats and vehicles",
// 		vehicle_plate: "Plate:",
// 		unregistered: "Empty",
// 		distance: "Odometer: {0} km",
// 		vehicle_condition: "Vehicle condition",
// 		vehicle_fuel: "Fuel",
// 		repair: "Repair {0}",
// 		refuel: "Refuel {0}",
// 		spawn: "Spawn Vehicle",
// 		sell: "Sell",
// 		unlock_text: {
// 			vehicle: "Upgrade the vehicle garage to <b>level {0}</b> to unlock this vehicle",
// 			boat: "Upgrade the boat garage to <b>level {0}</b> to unlock this boat",
// 			property: "Upgrade the property skill to <b>level {0}</b> to unlock this property",
// 		},
// 		tabs: {
// 			vehicle: "Vehicles",
// 			boat: "Boats",
// 		},
// 	},
// 	owned_properties_page: {
// 		title: "Owned properties",
// 		desc: "Manage your properties here. View stock capacity, condition, set waypoints, sell properties and repair them once they degrade to keep functioning properly",
// 		see: "See property stock",
// 		repair: "Repair {0}",
// 		sell: "Sell property",
// 		stock_percentage: "Stock capacity",
// 		stock_condition: "Stock condition",
// 		address: "Address: {0}",
// 		set_waypoint: "Set waypoint",
// 	},
// 	guide_page: {
// 		title: "Guide",
// 		desc: "A guide designed to assist fishermen to learn about the fish species found in each location",
// 		fish_weight: "Weight",
// 		fish_value: "Value",
// 		filter_label: "Filter by name",
// 		filter_placeholder: "Fish name",
// 	},
// 	stock_page: {
// 		title: "Property stock ({0})",
// 		desc: "Here you can see and interact with all the items your property has stored",
// 		property_stock_title: "Property stock",
// 		player_inventory_title: "Your inventory",
// 		table_empty:"Stock empty",
// 		bar_title: "Stock capacity",
// 		inventory_table: {
// 			header_name: "Item name",
// 			header_amount: "Amount",
// 			header_weight: "Weight",
// 			header_value: "Value",
// 		},
// 		deposit_modal_title: "Deposit item",
// 		deposit_modal_item_available: "In inventory: {0}",
// 		withdraw_modal_title: "Withdraw item",
// 		withdraw_modal_item_available: "In stock: {0}",
// 		withdraw_modal_amount: "Amount",
// 		withdraw_modal_cancel: "Cancel",
// 	},
// 	tournaments: {
// 		join_tournament_alert: {
// 			title: "Fishing Tournament",
// 			body: "Join our fishing tournaments for a chance to win big prizes! The next tournament begins <b>{0}</b> at <b>{1}</b>. To participate, click the \"Join Tournament\" button before the event starts.",
// 			footer: "Prepare your gear and aim for the top prize by catching the biggest and rarest fish. Don't miss out on your chance to win up to <b>{0}</b>!",
// 			button: "Join Tournament",
// 		},
// 		joined_tournament_alert: {
// 			title: "Tournament Entry Confirmed",
// 			body: "You've successfully joined the upcoming fishing tournament! It begins <b>{0}</b> at <b>{1}</b>. Don't forget to be there in time.",
// 			footer: "You're all set! Gear up to compete for the top prize and the chance to catch the biggest and rarest fish. Up to <b>{0}</b> in prizes awaits!",
// 			button: "Mark Location on GPS",
// 		},
// 		scoreboard_dialog: {
// 			title: "Tournament Scoreboard",
// 			table_name: "Name",
// 			table_points: "Points",
// 		},
// 		join_tournament_dialog: {
// 			title: "Join Fishing Tournament",
// 			body: `
// 				<p>You are about to enter the fishing tournament. Below are the details of the tournament:</p>

// 				<ul>
// 					<li><strong>Tournament Start Time:</strong> {0} at {1}</li>
// 					<li><strong>Entry Fee:</strong> {2}</li>
// 					<li><strong>Duration:</strong> {3} minutes</li>
// 				</ul>

// 				<p><strong>Prizes:</strong></p>
// 				<ul>
// 					<li><strong>1st Place:</strong> {4}</li>
// 					<li><strong>2nd Place:</strong> {5}</li>
// 					<li><strong>3rd Place:</strong> {6}</li>
// 				</ul>

// 				<p><strong>Objective:</strong> Catch as many fish as you can to increase your total score, with rarer fish boosting your score more than common ones! 🏆</p>

// 				<p>Are you ready?</p>`, // Caution when translating, this code must keep its formatting
// 		},
// 		today_text: "Today",
// 		week_days: new Array("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"),
// 	},
// 	fish_store_page: {
// 		desc: "Here you can sell your catch for designated prices. Use the filter options to quickly find specific fish by name or adjust price ranges. Get the best value for your efforts and keep your inventory fresh",
// 		amount: "Amount",
// 		sell_button: "Sell fish",
// 		sell_all_button: "Sell all fishes",
// 		filters: {
// 			title: "Filters",
// 			name_placeholder: "Filter by name",
// 			name: "Name:",
// 			price: "Price:",
// 			min: "Min:",
// 			max: "Max:",
// 			only_owned: "Owned Only:",
// 			filter_btn: "Filter",
// 		},
// 		others_tab: "Others",
// 	},
// 	fishing_game: {
// 		get_ready: "Get ready to hook the fish!",
// 		hook_fish: "Press <strong>LMB</strong> to hook the fish!",
// 		instructions: {
// 			title: "INSTRUCTIONS",
// 			hook_command: "Action (hook/reel)",
// 			exit_fishing: "Exit fishing game",
// 		},
// 		progress_bar_labels: {
// 			tension: {
// 				low: "Low Tension",
// 				avg: "Optimal Tension",
// 				max: "High Tension",
// 			},
// 			progress: {
// 				low: "Just Started",
// 				avg: "Making Progress",
// 				max: "Almost Caught",
// 			},
// 		},
// 		fish_details: {
// 			rarity: {
// 				common: "Common",
// 				uncommon: "Uncommon",
// 				rare: "Rare",
// 				legendary: "Legendary",
// 				mythic: "Mythic",
// 			},
// 			weight: "Weight",
// 			exp: "EXP",
// 			price: "Price",
// 			keep: "Keep",
// 			release: "Release",
// 			illegal: "Illegal",
// 		},
// 	},
// };

if (Lang == undefined) {
	var Lang = [];
}
Lang["en"] = {
	common: {
		confirm: "Xác nhận",
		weight_unit: "kg",
		level_abbreviate: "Cấp ",
		skill_point: "Điểm kỹ năng",
		areas: {
			sea: "Biển",
			lake: "Hồ",
			river: "Sông",
			swamp: "Đầm lầy",
			all: "Tất cả",
		},
	},
	sidebar: {
		profile: "Hồ Sơ Của Bạn",
		bank: "Ngân Hàng",
		deliveries: "Giao hàng đặc biệt",
		dives: "Lặn biển",
		upgrades: "Nâng cấp",
		equipments: "Trang bị",
		store: "Cửa hàng",
		owned_vehicles: "Xe sở hữu",
		owned_property: "Bất động sản sở hữu",
		guide: "Hướng dẫn",
		close: "Đóng",
		property: "Bất động sản",
		fish_store: "Cửa hàng cá",
	},
	modals: {
		confirmation: {
			sell_vehicle: "Bạn có chắc muốn bán xe này?",
			sell_propertty: "Bạn có chắc muốn bán bất động sản này? Tất cả vật phẩm trong kho sẽ bị mất",
			loan_payoff: "Bạn có chắc muốn trả toàn bộ số dư {0}?",
			sell_all_fishes: "Hành động này sẽ bán tất cả cá trong túi đồ. Bạn có chắc muốn tiếp tục?",
		},
	},
	statistics_page: {
		title: "Thống Kê",
		desc: "Thống kê để theo dõi quá trình câu cá của bạn",
		money_earned: "Tổng tiền kiếm được",
		money_spent: "Tổng tiền đã chi",
		total_mythic_fish: "Tổng cá huyền thoại đã bắt",
		total_legendary_fish: "Tổng cá truyền thuyết đã bắt",
		total_all_fish: "Tổng số cá đã bắt",
		total_dives: "Tổng số lần lặn hoàn thành",
		total_deliveries: "Tổng số lần giao hàng hoàn thành",
		total_exp: "Tổng EXP kiếm được",
		total_upgrades: "Tổng nâng cấp đã mua",
		top_users: {
			title: "Ngư dân hàng đầu",
			desc: "Top 10 ngư dân trong thành phố",
			fishes_caught: "Cá đã bắt: {0}",
			exp: "EXP: {0}",
		},
	},
	deliveries_page: {
		title: "Giao Hàng",
		desc: "Hoàn thành đơn hàng để nhận giá đặc biệt cho cá. Chọn hợp đồng để bắt đầu và giao cá yêu cầu cho khách hàng",
		contracts_time: "Hợp đồng mới mỗi {0} phút",
		reward: "Phần thưởng",
		required_items: "Vật phẩm yêu cầu",
		start_button: "Bắt đầu hợp đồng",
		cancel_button: "Hủy hợp đồng",
		see_location: "Xem vị trí",
		missing_item: "Bạn không có vật phẩm này",
	},
	dives_page: {
		start_button: "Bắt đầu lặn",
		cancel_button: "Hủy lặn",
		title: "Lặn Biển",
		desc: "Hoàn thành các chuyến thám hiểm dưới nước để tìm kho báu và vật phẩm hiếm. Chọn nhiệm vụ lặn để bắt đầu và kiếm phần thưởng độc đáo, nhưng lưu ý rằng vị trí rương kho báu không chính xác trên GPS, tạo thử thách ngay cả cho người giàu kinh nghiệm nhất",
		time: "Điểm lặn mới mỗi {0} phút",
	},
	bank_page: {
		title: "Ngân Hàng",
		desc: "Xem thông tin tài khoản ngân hàng công ty của bạn tại đây",
		withdraw: "Rút tiền",
		deposit: "Gửi tiền",
		balance: "Số dư của bạn:",
		active_loans: "Khoản vay đang hoạt động",

		loan_title: "Vay tiền",
		loan_desc: "Vay tiền để đầu tư vào công việc!<BR>(Khoản vay tối đa: {0})",
		loan_button: "Vay tiền",
		loan_value_title: "Số tiền vay",
		loan_daily_title: "Chi phí hàng ngày",
		loan_remaining_title: "Số tiền còn lại",
		loan_date_title: "Thanh toán tiếp theo (Tự động)",
		loan_pay: "Trả nợ",

		loan_modal_desc: "Chọn một loại khoản vay:",
		loan_modal_item: "({0}% lãi suất, trả trong {1} ngày)",
		loan_modal_submit: "Vay tiền",

		deposit_modal_title: "Gửi tiền",
		deposit_modal_desc: "Bạn muốn gửi bao nhiêu?",
		deposit_modal_submit: "Gửi tiền",

		withdraw_modal_title: "Rút tiền",
		withdraw_modal_desc: "Bạn muốn rút bao nhiêu?",
		withdraw_modal_submit: "Rút tiền",

		modal_placeholder: "Số tiền",
		modal_money_available: "Tiền khả dụng: {0}",
		modal_cancel: "Hủy",
	},
	upgrades_page: {
		title: "Kỹ Năng",
		desc: "Sử dụng điểm kỹ năng tích lũy để mở khóa khả năng mới giúp cải thiện trải nghiệm câu cá. Có nhiều loại kỹ năng giúp bạn trở thành ngư dân giỏi hơn",
		vehicles: {
			title: "Xe cộ",
			desc: "Nâng cấp sức chứa garage để chứa nhiều xe hơn phục vụ vận chuyển cá.",
			level: "+{0} chỗ xe trong garage<BR>+ Mở khóa xe mới để mua",
		},
		boats: {
			title: "Thuyền",
			desc: "Nâng cấp sức chứa bến tàu để chứa nhiều thuyền hơn phục vụ vận chuyển cá.",
			level: "+{0} chỗ thuyền trong garage<BR>+ Mở khóa thuyền mới để mua",
		},
		properties: {
			title: "Bất động sản",
			desc: "Mở khóa bất động sản mới để có thể mua.",
			level: "Mở khóa bất động sản mới để mua",
		},
		lake: {
			title: "Hồ",
			desc: "Nâng cấp kỹ năng câu ở hồ để bắt nhiều loại cá hơn.",
			level: "Mở khóa loài cá mới ở hồ",
		},
		river: {
			title: "Sông",
			desc: "Nâng cấp kỹ năng câu ở sông để bắt nhiều loại cá hơn.",
			level: "Mở khóa loài cá mới ở sông",
		},
		swamp: {
			title: "Đầm lầy",
			desc: "Nâng cấp kỹ năng câu ở đầm lầy để bắt nhiều loại cá hơn.",
			level: "Mở khóa loài cá mới ở đầm lầy",
		},
		sea: {
			title: "Biển",
			desc: "Nâng cấp kỹ năng câu ở biển để bắt nhiều loại cá hơn.",
			level: "Mở khóa loài cá mới ở biển",
		},
	},
	equipments_page: {
		title: "Trang Bị",
		desc: "Mua trang bị câu cá mới để cải thiện kỹ thuật câu. Tăng thời gian phản ứng, tăng cơ hội bắt cá hiếm và giảm thời gian chờ cá cắn câu. Đầu tư vào trang bị để tăng hiệu quả và thành công khi câu cá",
		name: "Tên",
		price: "Giá",
		bonus: "Thưởng",
		amount: "Số lượng",
		buy_button: "Mua",
		unlock_text: "Đạt <b>cấp {0}</b> để mở khóa trang bị này",
		rod: {
			title: "Cần câu",
			desc: "Nâng cấp cần câu để tăng cơ hội bắt được cá hiếm hơn",
		},
		reel: {
			title: "Ròng rọc",
			desc: "Nâng cấp ròng rọc để tăng hiệu suất kéo, giúp tiến trình kéo nhanh hơn",
		},
		hook: {
			title: "Lưỡi câu",
			desc: "Nâng cấp lưỡi câu để tăng thời gian phản ứng khi câu cá, giúp bắt dễ hơn",
		},
		line: {
			title: "Dây câu",
			desc: "Nâng cấp này làm dây câu chắc hơn, giúp dễ kiểm soát lực căng và nhanh hơn khi bắt cá",
		},
		bait: {
			title: "Mồi câu",
			desc: "Nâng cấp mồi để giảm thời gian chờ cá cắn câu, bắt đầu câu sớm hơn",
		},
		other : {
			title: "Khác",
			desc: "Trang bị khác để cải thiện trải nghiệm câu cá",
		},
	},
	store_page: {
		title: "Cửa Hàng Xe & Bất Động Sản",
		desc: "Mua xe, thuyền và bất động sản để cải thiện khả năng giao hàng. Chọn từ nhiều lựa chọn để nâng cao hiệu quả và mở rộng hoạt động",
		buy_button: "Mua",
		tabs: {
			vehicle: "Xe cộ",
			boat: "Thuyền",
			property: "Bất động sản",
		},
		vehicle: {
			name: "Xe",
			price: "Giá",
			trunk: "Trọng lượng",
		},
		property: {
			name: "Bất động sản",
			capacity: "Sức chứa",
			owned: "Bạn đã sở hữu bất động sản này",
		},
	},
	owned_vehicles_page: {
		title: "Xe Sở Hữu",
		desc: "Xem và quản lý garage, theo dõi tình trạng và mức nhiên liệu của thuyền và xe",
		vehicle_plate: "Biển số:",
		unregistered: "Trống",
		distance: "Đồng hồ: {0} km",
		vehicle_condition: "Tình trạng xe",
		vehicle_fuel: "Nhiên liệu",
		repair: "Sửa {0}",
		refuel: "Đổ xăng {0}",
		spawn: "Lấy xe",
		sell: "Bán",
		unlock_text: {
			vehicle: "Nâng garage xe lên <b>cấp {0}</b> để mở khóa xe này",
			boat: "Nâng garage thuyền lên <b>cấp {0}</b> để mở khóa thuyền này",
			property: "Nâng kỹ năng bất động sản lên <b>cấp {0}</b> để mở khóa",
		},
		tabs: {
			vehicle: "Xe cộ",
			boat: "Thuyền",
		},
	},
	owned_properties_page: {
		title: "Bất Động Sản Sở Hữu",
		desc: "Quản lý bất động sản tại đây. Xem sức chứa kho, tình trạng, đặt điểm đến, bán bất động sản và sửa chữa khi xuống cấp để duy trì hoạt động",
		see: "Xem kho bất động sản",
		repair: "Sửa {0}",
		sell: "Bán bất động sản",
		stock_percentage: "Sức chứa kho",
		stock_condition: "Tình trạng kho",
		address: "Địa chỉ: {0}",
		set_waypoint: "Đặt điểm đến",
	},
	guide_page: {
		title: "Hướng Dẫn",
		desc: "Hướng dẫn giúp ngư dân tìm hiểu về các loài cá ở từng địa điểm",
		fish_weight: "Trọng lượng",
		fish_value: "Giá trung bình",
		filter_label: "Lọc theo tên",
		filter_placeholder: "Tên cá",
	},
	stock_page: {
		title: "Kho bất động sản ({0})",
		desc: "Tại đây bạn có thể xem và tương tác với tất cả vật phẩm được lưu trong kho",
		property_stock_title: "Kho bất động sản",
		player_inventory_title: "Túi đồ của bạn",
		table_empty:"Kho trống",
		bar_title: "Sức chứa kho",
		inventory_table: {
			header_name: "Tên vật phẩm",
			header_amount: "Số lượng",
			header_weight: "Trọng lượng",
			header_value: "Giá trị",
		},
		deposit_modal_title: "Gửi vật phẩm",
		deposit_modal_item_available: "Trong túi: {0}",
		withdraw_modal_title: "Rút vật phẩm",
		withdraw_modal_item_available: "Trong kho: {0}",
		withdraw_modal_amount: "Số lượng",
		withdraw_modal_cancel: "Hủy",
	},
	tournaments: {
		join_tournament_alert: {
			title: "Giải Đấu Câu Cá",
			body: "Tham gia giải đấu câu cá để có cơ hội giành giải thưởng lớn! Giải đấu tiếp theo bắt đầu <b>{0}</b> lúc <b>{1}</b>. Để tham gia, nhấn nút \"Tham Gia Giải Đấu\" trước khi sự kiện bắt đầu.",
			footer: "Chuẩn bị trang bị và hướng đến giải thưởng hàng đầu bằng cách bắt cá lớn và hiếm nhất. Đừng bỏ lỡ cơ hội giành đến <b>{0}</b>!",
			button: "Tham Gia Giải Đấu",
		},
		joined_tournament_alert: {
			title: "Xác Nhận Tham Gia Giải Đấu",
			body: "Bạn đã tham gia giải đấu câu cá thành công! Giải bắt đầu <b>{0}</b> lúc <b>{1}</b>. Đừng quên có mặt đúng giờ.",
			footer: "Bạn đã sẵn sàng! Chuẩn bị trang bị để tranh tài giành giải thưởng hàng đầu và bắt cá lớn, hiếm nhất. Giải thưởng lên đến <b>{0}</b> đang chờ bạn!",
			button: "Đánh Dấu Vị Trí Trên GPS",
		},
		scoreboard_dialog: {
			title: "Bảng Xếp Hạng Giải Đấu",
			table_name: "Tên",
			table_points: "Điểm",
		},
		join_tournament_dialog: {
			title: "Tham Gia Giải Đấu Câu Cá",
			body: `
				<p>Bạn sắp tham gia giải đấu câu cá. Dưới đây là thông tin chi tiết:</p>

				<ul>
					<li><strong>Giờ Bắt Đầu:</strong> {0} lúc {1}</li>
					<li><strong>Phí Tham Gia:</strong> {2}</li>
					<li><strong>Thời Lượng:</strong> {3} phút</li>
				</ul>

				<p><strong>Giải Thưởng:</strong></p>
				<ul>
					<li><strong>Hạng 1:</strong> {4}</li>
					<li><strong>Hạng 2:</strong> {5}</li>
					<li><strong>Hạng 3:</strong> {6}</li>
				</ul>

				<p><strong>Mục Tiêu:</strong> Bắt càng nhiều cá càng tốt để tăng tổng điểm, cá hiếm sẽ tăng điểm nhiều hơn cá thường! 🏆</p>

				<p>Bạn đã sẵn sàng chưa?</p>`,
		},
		today_text: "Hôm nay",
		week_days: new Array("Chủ Nhật", "Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy"),
	},
	fish_store_page: {
		desc: "Tại đây bạn có thể bán cá với giá được chỉ định. Sử dụng bộ lọc để nhanh chóng tìm cá theo tên hoặc điều chỉnh khoảng giá. Nhận giá trị tốt nhất cho công sức và giữ túi đồ luôn gọn gàng",
		amount: "Số lượng",
		sell_button: "Bán cá",
		sell_all_button: "Bán tất cả cá",
		filters: {
			title: "Bộ Lọc",
			name_placeholder: "Lọc theo tên",
			name: "Tên:",
			price: "Giá:",
			min: "Tối thiểu:",
			max: "Tối đa:",
			only_owned: "Chỉ Đang Có:",
			filter_btn: "Lọc",
		},
		others_tab: "Khác",
	},
	fishing_game: {
		get_ready: "Chuẩn bị câu cá!",
		hook_fish: "Nhấn <strong>Chuột Trái</strong> để câu cá!",
		instructions: {
			title: "HƯỚNG DẪN",
			hook_command: "Hành động (câu/kéo)",
			exit_fishing: "Thoát minigame câu cá",
		},
		progress_bar_labels: {
			tension: {
				low: "Lực Căng Thấp",
				avg: "Lực Căng Tối Ưu",
				max: "Lực Căng Cao",
			},
			progress: {
				low: "Vừa Bắt Đầu",
				avg: "Đang Tiến Triển",
				max: "Sắp Bắt Được",
			},
		},
		fish_details: {
			rarity: {
				common: "Thường",
				uncommon: "Không Phổ Biến",
				rare: "Hiếm",
				legendary: "Truyền Thuyết",
				mythic: "Huyền Thoại",
			},
			weight: "Trọng lượng",
			exp: "EXP",
			price: "Giá",
			keep: "Giữ",
			release: "Thả",
			illegal: "Bất Hợp Pháp",
		},
	},
};