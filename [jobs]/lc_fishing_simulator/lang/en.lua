-- if not Lang then Lang = {} end
-- Lang['en'] = {
-- 	['open'] = "Press ~y~E~w~ to open",
-- 	['open_main_target'] = "Open fishing dashboard",
-- 	['open_property_target'] = "Open fishing property",
-- 	['open_store_target'] = "Open fishing store",
-- 	['you_died'] = "You died and lost your vehicle",
-- 	['insufficient_money'] = "Insufficient money",
-- 	['invalid_value'] = "Invalid value",
-- 	['no_permission'] = "You dont have the required job to open this menu",
-- 	['not_enough_level'] = "You dont have enough level to use this item",
-- 	['fish_store_sold'] = "You sold %sx %s",
-- 	['fish_store_all_sold'] = "You sold all your fishes for $%s",
-- 	['fish_store_nothing_sold'] = "You dont have any fish to sell in this store",
-- 	['fish_store_not_enough'] = "You dont have %sx %s to sell",
-- 	['exp'] = "EXP",

-- 	['anchor_boat_command'] = "Anchor boat",
-- 	['anchor_too_fast'] = "Slow down to use the anchor",
-- 	['anchor_not_allowed'] = "You cannot anchor here",
-- 	['anchor_lowered'] = "Anchor lowered",
-- 	['anchor_raised'] = "Anchor raised",

-- 	['contract_invalid'] = "This contract does not exist anymore",
-- 	['contract_started'] = "You've started a contract, delivery the required products to the destination",
-- 	['contract_already_started'] = "You already have a contract, please finish it first",
-- 	['contract_someone_already_started'] = "Someone else already started this contract, please choose another",
-- 	['contract_waypoint_set'] = "The waypoint to the contract has been marked on your GPS",
-- 	['contract_finish_delivery'] = "Press ~y~E~w~ to finish delivery",
-- 	['contract_received_money'] = "Received $%s for finish the contract",
-- 	['contract_received_item'] = "Received %sx %s for finish the contract",
-- 	['contract_received_item_error'] = "You dont have enough space to receive the item %sx %s",
-- 	['contract_destination_blip'] = "Destination",
-- 	['contract_cancel'] = "You have cancelled your contract",
-- 	['contract_not_enough_items'] = "You dont have the required items: %s",

-- 	['dive_invalid'] = "This dive does not exist anymore",
-- 	['dive_started'] = "You've started a dive, go find the treasure",
-- 	['dive_already_started'] = "You already have a dive, please finish it first",
-- 	['dive_someone_already_started'] = "Someone else already started this dive, please choose another",
-- 	['dive_waypoint_set'] = "The waypoint to the dive area has been marked on your GPS",
-- 	['dive_received_money'] = "Received $%s for finish the dive",
-- 	['dive_received_item'] = "Received %sx %s for finish the dive",
-- 	['dive_received_item_error'] = "You dont have enough space to receive the item %sx %s",
-- 	['dive_cancel'] = "You have cancelled your dive",
-- 	['dive_finish'] = "Press ~y~E~w~ to finish dive",

-- 	['money_withdrawn'] = "Money withdrawn",
-- 	['money_deposited'] = "Money deposited",
-- 	['pay_loans'] = "You must pay your loans before withdrawing your money",
-- 	['loan'] = "Loan made",
-- 	['no_loan'] = "You cannot take this loan",
-- 	['loan_paid'] = "Loan paid",
-- 	['no_loan_money'] = "You don't have any money to pay off your loan from the fishing job. You've lost everything",

-- 	['upgrade_purchased'] = "Upgrade purchased",
-- 	['equipment_purchased'] = "Equipment purchased",
-- 	['insufficient_skill_points'] = "Insufficient skill points",

-- 	['occupied_places'] = "Your garage is occupied, consider removing any obstructions that are blocking the vehicle parking space",
-- 	['vehicle_blip'] = "Vehicle",
-- 	['garage_blip'] = 'Garage',
-- 	['press_e_to_store_vehicle'] = '~w~Press ~g~[E]~w~ to store the ~b~vehicle~w~.',
-- 	['vehicle_already_spawned'] = 'You already have a vehicle',
-- 	['vehicle_lost'] = 'You have lost your vehicle somewhere in the world',

-- 	['garage_full'] = 'Your garage is full',
-- 	['vehicle_purchased'] = "You have purchased the vehicle",
-- 	['vehicle_repaired'] = "Vehicle repaired",
-- 	['vehicle_refueled'] = "Vehicle refueled",
-- 	['vehicle_already_repaired'] = "This vehicle is already repaired",
-- 	['vehicle_already_refueled'] = "This vehicle is already refueled",
-- 	['vehicle_not_found'] = "Vehicle not found",
-- 	['vehicle_damaged'] = "Vehicle is too much damaged",
-- 	['vehicle_sold'] = "Vehicle sold for $%s",
-- 	['vehicle_spawned'] = "Your vehicle is in your garage",
-- 	['vehicle_capacity_full'] = "Your vehicles capacity is full",
-- 	['vehicle_owned_name'] = "Owned vehicle",
-- 	['vehicle_destroyed'] = "Your vehicle has been destroyed",

-- 	['stock_item_deposited'] = "Item deposited",
-- 	['dont_have_item'] = "You dont have %sx %s items in your inventory",
-- 	['stock_property_full'] = "The property stock cant carry that item",
-- 	['stock_item_withdrawn'] = "Item withdrawn",
-- 	['stock_cannot_withdraw'] = "This item cannot be withdrawn",
-- 	['cant_carry_item'] = "You cant carry that item",

-- 	['property_waypoint_set'] = "The waypoint to the property has been marked on your GPS",
-- 	['property_needs_repair'] = "You will lose the property '%s' really soon if you dont repair it",
-- 	['property_not_owned'] = "You dont own this property",
-- 	['property_sold'] = "You sold the property",
-- 	['property_purchased'] = "You have purchased the property",
-- 	['property_max_amount'] = 'You cant have more properties',
-- 	['property_not_found'] = "Property not found",
-- 	['property_already_repaired'] = "This property is already repaired",
-- 	['property_repaired'] = "Property repaired",

-- 	['tournament_joined'] = "You've successfully joined the tournament! The tournament location has been marked on your map. Don't forget to be there on time and good luck!",
-- 	['tournament_waypoint'] = "The tournament location has been marked on your map",
-- 	['tournament_not_in'] = "You're not in this tournament",
-- 	['tournament_not_found'] = "There are no tournaments currently happening here",
-- 	['tournament_already_in'] = "You're already in this tournament",
-- 	['tournament_not_available'] = "The tournament you're joining isn't available anymore",
-- 	['tournament_started'] = "The fishing tournament has started! Grab your fishing rod and catch as many fish as possible to win",
-- 	['tournament_fish_caught'] = "You have scored %s points with this catch!",
-- 	['tournament_ended'] = "The tournament has ended",
-- 	['tournament_cancelled'] = "The tournament was cancelled due to not reaching the minimum number of participants. The entry fee has been refunded",
-- 	['tournament_prize_received'] = "Congratulations! Your place in the tournament is: %s. Your prize is: %s",
-- 	['tournament_prize_not_received'] = "You didn't win a prize this time, but best of luck in your next attempt",

-- 	-- Logs
-- 	['logs_date'] = "Date",
-- 	['logs_hour'] = "Time",
-- 	['logs_withdraw'] = "```prolog\n[MONEY WITHDRAW]: %s \n[ID] %s \r```",
-- 	['logs_deposit'] = "```prolog\n[MONEY DEPOSITED]: %s \n[ID] %s \r```",
-- 	['logs_buy_vehicle'] = "```prolog\n[USER]: %s\n[VEHICLE PURCHASED]: %s \n[PRICE]: %s \n[ID]: %s \r```",
-- 	['logs_buy_property'] = "```prolog\n[USER]: %s\n[PROPERTY PURCHASED]: %s \n[PRICE]: %s \n[ID]: %s \r```",
-- 	['logs_fish_sold'] = "```prolog\n[FISH SOLD]: %s\n[AMOUNT]: %s \n[PRICE]: %s \n[ID]: %s \r```",
-- 	['logs_exploit'] = "```prolog\n[POTENTIAL EXPLOIT]: %s\n[PLAYER LOCATION]: %s\n[DATA]: %s\n[USER]: %s \r```",

-- 	-- Fishing Area
-- 	["cannot_fish_in_vehicle"] = "You cannot fish while in a vehicle",
-- 	["water_not_found"] = "No water found at the targeted location! Make sure there's sufficient water to fish",
-- 	["area_not_found"] = "You're not in a valid area to fish",
-- 	['new_level'] = "You just went to level: %s !",
-- 	["fishing_lost"] = "You lost the fish",

-- 	["missing_equipments"] = {
-- 		["rod"] = "You must equip a fishing rod",
-- 		["hook"] = "You must equip a fishing hook",
-- 		["reel"] = "You must equip a fishing reel",
-- 		["bait"] = "You must equip a fishing bait",
-- 		["line"] = "You must equip a fishing line",
-- 	},
-- 	["equipment_equipped"] = "You've equipped this equipment",

-- 	-- Config contracts
-- 	['contracts'] = {
-- 		['chefs_special'] = {
-- 			['name'] = "Chef's Special",
-- 			['description'] = "A local chef needs these fishes for a gourmet meal tonight. Can you deliver?"
-- 		},
-- 		['exotic_collection'] = {
-- 			['name'] = "Exotic Collection",
-- 			['description'] = "Deliver these rare fishes to earn special gear!"
-- 		},
-- 		['aquarium_exhibit'] = {
-- 			['name'] = "Aquarium Exhibit",
-- 			['description'] = "An aquarium is looking to expand its exhibit. Provide these fishes for a reward."
-- 		},
-- 		['rare_fish_trader'] = {
-- 			['name'] = "Rare Fish Trader",
-- 			['description'] = "A collector is in town looking for rare species. Deliver these and earn big!"
-- 		},
-- 		['swamp_special'] = {
-- 			['name'] = "Swamp Specialties",
-- 			['description'] = "Help a researcher gather samples from the swamp."
-- 		},
-- 		['maritime_donation'] = {
-- 			['name'] = "Maritime Museum Donation",
-- 			['description'] = "The local maritime museum needs specimens for their new ocean exhibit. Help them out!"
-- 		},
-- 		['gourmet_market'] = {
-- 			['name'] = "Gourmet Fish Market",
-- 			['description'] = "A high-end market is looking for premium fish. Fulfill their order for a generous payout."
-- 		},
-- 		['biological_research'] = {
-- 			['name'] = "Biological Research",
-- 			['description'] = "Assist researchers by providing them with specimens for their study of aquatic life."
-- 		},
-- 		['sport_fishing'] = {
-- 			['name'] = "Sport Fishing Challenge",
-- 			['description'] = "Catch these challenging species to win a prize in the local sport fishing competition."
-- 		},
-- 		['fish_fry'] = {
-- 			['name'] = "Local Fish Fry Event",
-- 			['description'] = "Contribute to the community fish fry event by delivering these popular fish."
-- 		},
-- 		['seafood_festival'] = {
-- 			['name'] = "Local Seafood Festival",
-- 			['description'] = "The annual seafood festival needs a variety of fish to showcase. Help supply their needs!"
-- 		},
-- 		['exotic_aquarium'] = {
-- 			['name'] = "Exotic Aquarium Stock",
-- 			['description'] = "An exotic aquarium is looking to add rare species to its collection. Can you provide them?"
-- 		},
-- 		['sushi_order'] = {
-- 			['name'] = "Sushi Restaurant Order",
-- 			['description'] = "A high-end sushi restaurant needs fresh, top-quality fish. Deliver their order on time!"
-- 		},
-- 		['pet_food'] = {
-- 			['name'] = "Gourmet Pet Food Maker",
-- 			['description'] = "A gourmet pet food maker needs high-quality fish for a new premium line. Help them out!"
-- 		},
-- 		['research_specimens'] = {
-- 			['name'] = "Research Specimens",
-- 			['description'] = "Marine researchers need specific fish species for important environmental studies."
-- 		},
-- 		['fish_market_supply'] = {
-- 			['name'] = "Fish Market Supply",
-- 			['description'] = "A local fish market needs a steady supply of common fish to keep their shelves stocked."
-- 		},
-- 		['bait_supply_order'] = {
-- 			['name'] = "Bait Supply Order",
-- 			['description'] = "A fishing shop needs various common fish for bait. Help them restock their inventory."
-- 		},
-- 		['cooking_class'] = {
-- 			['name'] = "Community Cooking Class",
-- 			['description'] = "A community center is holding a cooking class and needs common local fish to teach proper cleaning and cooking techniques."
-- 		},
-- 		['restaurant_daily_special'] = {
-- 			['name'] = "Local Restaurant Special",
-- 			['description'] = "A local restaurant features a daily fish special and needs fresh common fish delivered daily."
-- 		},
-- 		['science_project'] = {
-- 			['name'] = "School Science Project",
-- 			['description'] = "A local school needs various common fish for a science project on local ecosystems."
-- 		},
-- 	},
-- 	['dives'] = {
-- 		['reef_explorer'] = {
-- 			['name'] = "Reef Explorer",
-- 			['description'] = "Explore the vibrant coral reefs to find rare marine life samples for marine biologists."
-- 		},
-- 		['sunken_armada'] = {
-- 			['name'] = "Sunken Armada",
-- 			['description'] = "Dive into the remains of a legendary fleet lost during a massive storm. Recover the artifacts!"
-- 		},
-- 		['merchant_lost'] = {
-- 			['name'] = "The Merchant's Lost Goods",
-- 			['description'] = "A merchant ship sunk here in the 18th century, rumored to carry valuable silks and spices."
-- 		},
-- 		['underwater_city'] = {
-- 			['name'] = "Ancient Underwater City",
-- 			['description'] = "Ancient ruins recently discovered beneath the sea could hold clues to past civilizations."
-- 		},
-- 		['kraken_lair'] = {
-- 			['name'] = "Kraken's Lair",
-- 			['description'] = "Dare to retrieve treasures from the lair of the mythical Kraken. Beware its wrath!"
-- 		},
-- 		['meteorite_crash'] = {
-- 			['name'] = "Meteorite Crash Site",
-- 			['description'] = "A meteorite has crashed into the ocean recently, creating a rich bed of rare minerals."
-- 		},
-- 		['ghost_ship'] = {
-- 			['name'] = "Ghost Ship Expedition",
-- 			['description'] = "Dive down to investigate a ship that vanished centuries ago and has now reappeared mysteriously."
-- 		},
-- 		['volcanic_vents'] = {
-- 			['name'] = "Volcanic Vents Discovery",
-- 			['description'] = "Explore deep sea volcanic vents teeming with unique life forms and collect samples for study."
-- 		},
-- 		['wreck_titan'] = {
-- 			['name'] = "Wreck of the Titan",
-- 			['description'] = "The Titan, a luxury yacht sunk under mysterious circumstances, is believed to be filled with riches."
-- 		},
-- 		['bermuda_triangle'] = {
-- 			['name'] = "Bermuda Triangle Anomaly",
-- 			['description'] = "Investigate an anomaly in the depths of the Bermuda Triangle. Expect the unexpected."
-- 		},
-- 		['pearl_diver'] = {
-- 			['name'] = "Pearl Diver's Quest",
-- 			['description'] = "A lucrative dive to collect pearls from a dense oyster bed, known only to the oldest divers."
-- 		},
-- 		['cold_war_relic'] = {
-- 			['name'] = "Cold War Relic",
-- 			['description'] = "Recover lost espionage equipment from a sunken Cold War-era submarine."
-- 		},
-- 		['deep_sea_salvage'] = {
-- 			['name'] = "Deep Sea Salvage Operation",
-- 			['description'] = "Recover valuable cargo from a sunken freighter deep in the ocean."
-- 		},
-- 		['lost_jewel_atlantis'] = {
-- 			['name'] = "Lost Jewel of Atlantis",
-- 			['description'] = "Search for the legendary lost jewel rumored to be off the coast, guarded by the mysteries of the sea."
-- 		},
-- 		['sunken_plane'] = {
-- 			['name'] = "Sunken Plane Recovery",
-- 			['description'] = "Dive to a recently discovered WWII plane wreck to recover lost historical artifacts."
-- 		},
-- 		['sunken_yacht'] = {
-- 			['name'] = "Oil Tycoon's Sunken Yacht",
-- 			['description'] = "A billionaire's yacht has sunk under mysterious circumstances. Retrieve any valuables you find."
-- 		},
-- 		['coral_reef_photography'] = {
-- 			['name'] = "Coral Reef Photography",
-- 			['description'] = "Take stunning photographs of the coral reef for a major magazine. They pay well for quality!"
-- 		},
-- 		['arctic_shipwreck'] = {
-- 			['name'] = "Arctic Shipwreck Expedition",
-- 			['description'] = "Brave the cold waters to uncover a ship that sank while attempting to traverse the Arctic circle."
-- 		},
-- 	},
-- }


if not Lang then Lang = {} end
Lang['en'] = {
	['open'] = "Nhấn ~y~E~w~ để mở",
	['open_main_target'] = "Mở bảng điều khiển câu cá",
	['open_property_target'] = "Mở bất động sản câu cá",
	['open_store_target'] = "Mở cửa hàng câu cá",
	['you_died'] = "Bạn đã chết và mất phương tiện",
	['insufficient_money'] = "Không đủ tiền",
	['invalid_value'] = "Giá trị không hợp lệ",
	['no_permission'] = "Bạn không có công việc phù hợp để mở menu này",
	['not_enough_level'] = "Bạn chưa đủ cấp độ để sử dụng vật phẩm này",
	['fish_store_sold'] = "Bạn đã bán %sx %s",
	['fish_store_all_sold'] = "Bạn đã bán tất cả cá với giá $%s",
	['fish_store_nothing_sold'] = "Bạn không có cá nào để bán ở cửa hàng này",
	['fish_store_not_enough'] = "Bạn không có %sx %s để bán",
	['exp'] = "KINH NGHIỆM",

	['anchor_boat_command'] = "Neo thuyền",
	['anchor_too_fast'] = "Hãy giảm tốc độ để thả neo",
	['anchor_not_allowed'] = "Bạn không thể thả neo ở đây",
	['anchor_lowered'] = "Đã thả neo",
	['anchor_raised'] = "Đã thu neo",

	['contract_invalid'] = "Hợp đồng này không còn tồn tại",
	['contract_started'] = "Bạn đã bắt đầu hợp đồng, giao hàng yêu cầu đến đích",
	['contract_already_started'] = "Bạn đã có hợp đồng rồi, vui lòng hoàn thành trước",
	['contract_someone_already_started'] = "Ai đó đã nhận hợp đồng này, vui lòng chọn hợp đồng khác",
	['contract_waypoint_set'] = "Điểm đến hợp đồng đã được đánh dấu trên GPS",
	['contract_finish_delivery'] = "Nhấn ~y~E~w~ để hoàn thành giao hàng",
	['contract_received_money'] = "Nhận $%s sau khi hoàn thành hợp đồng",
	['contract_received_item'] = "Nhận %sx %s sau khi hoàn thành hợp đồng",
	['contract_received_item_error'] = "Bạn không đủ chỗ để nhận %sx %s",
	['contract_destination_blip'] = "Điểm đến",
	['contract_cancel'] = "Bạn đã hủy hợp đồng",
	['contract_not_enough_items'] = "Bạn không có đủ vật phẩm yêu cầu: %s",

	['dive_invalid'] = "Điểm lặn này không còn tồn tại",
	['dive_started'] = "Bạn đã bắt đầu lặn, hãy tìm kho báu",
	['dive_already_started'] = "Bạn đã có điểm lặn rồi, vui lòng hoàn thành trước",
	['dive_someone_already_started'] = "Ai đó đã lặn ở đây, vui lòng chọn điểm khác",
	['dive_waypoint_set'] = "Khu vực lặn đã được đánh dấu trên GPS",
	['dive_received_money'] = "Nhận $%s sau khi hoàn thành lặn",
	['dive_received_item'] = "Nhận %sx %s sau khi hoàn thành lặn",
	['dive_received_item_error'] = "Bạn không đủ chỗ để nhận %sx %s",
	['dive_cancel'] = "Bạn đã hủy điểm lặn",
	['dive_finish'] = "Nhấn ~y~E~w~ để hoàn thành lặn",

	['money_withdrawn'] = "Đã rút tiền",
	['money_deposited'] = "Đã gửi tiền",
	['pay_loans'] = "Bạn phải trả nợ trước khi rút tiền",
	['loan'] = "Đã vay tiền",
	['no_loan'] = "Bạn không thể vay khoản này",
	['loan_paid'] = "Đã trả nợ",
	['no_loan_money'] = "Bạn không có tiền để trả nợ công việc câu cá. Bạn đã mất tất cả",

	['upgrade_purchased'] = "Đã mua nâng cấp",
	['equipment_purchased'] = "Đã mua thiết bị",
	['insufficient_skill_points'] = "Không đủ điểm kỹ năng",

	['occupied_places'] = "Garage của bạn bị chặn, hãy loại bỏ vật cản đang chặn chỗ đỗ xe",
	['vehicle_blip'] = "Phương tiện",
	['garage_blip'] = 'Garage',
	['press_e_to_store_vehicle'] = '~w~Nhấn ~g~[E]~w~ để cất ~b~xe~w~.',
	['vehicle_already_spawned'] = 'Bạn đã có xe rồi',
	['vehicle_lost'] = 'Bạn đã đánh mất xe ở đâu đó',

	['garage_full'] = 'Garage đầy',
	['vehicle_purchased'] = "Bạn đã mua xe",
	['vehicle_repaired'] = "Đã sửa xe",
	['vehicle_refueled'] = "Đã đổ xăng",
	['vehicle_already_repaired'] = "Xe này đã được sửa rồi",
	['vehicle_already_refueled'] = "Xe này đã đổ xăng rồi",
	['vehicle_not_found'] = "Không tìm thấy xe",
	['vehicle_damaged'] = "Xe hư hỏng quá nặng",
	['vehicle_sold'] = "Đã bán xe với giá $%s",
	['vehicle_spawned'] = "Xe của bạn đã ở trong garage",
	['vehicle_capacity_full'] = "Sức chứa xe đã đầy",
	['vehicle_owned_name'] = "Xe sở hữu",
	['vehicle_destroyed'] = "Xe của bạn đã bị phá hủy",

	['stock_item_deposited'] = "Đã gửi vật phẩm",
	['dont_have_item'] = "Bạn không có %sx %s trong túi đồ",
	['stock_property_full'] = "Kho bất động sản không thể chứa vật phẩm này",
	['stock_item_withdrawn'] = "Đã rút vật phẩm",
	['stock_cannot_withdraw'] = "Không thể rút vật phẩm này",
	['cant_carry_item'] = "Bạn không thể mang vật phẩm này",

	['property_waypoint_set'] = "Vị trí bất động sản đã được đánh dấu trên GPS",
	['property_needs_repair'] = "Bạn sẽ mất bất động sản '%s' nếu không sửa chữa",
	['property_not_owned'] = "Bạn không sở hữu bất động sản này",
	['property_sold'] = "Bạn đã bán bất động sản",
	['property_purchased'] = "Bạn đã mua bất động sản",
	['property_max_amount'] = 'Bạn không thể có thêm bất động sản',
	['property_not_found'] = "Không tìm thấy bất động sản",
	['property_already_repaired'] = "Bất động sản này đã được sửa rồi",
	['property_repaired'] = "Đã sửa bất động sản",

	['tournament_joined'] = "Bạn đã tham gia giải đấu thành công! Địa điểm giải đấu đã được đánh dấu trên bản đồ. Đừng quên có mặt đúng giờ và chúc may mắn!",
	['tournament_waypoint'] = "Địa điểm giải đấu đã được đánh dấu trên bản đồ",
	['tournament_not_in'] = "Bạn không tham gia giải đấu này",
	['tournament_not_found'] = "Không có giải đấu nào đang diễn ra ở đây",
	['tournament_already_in'] = "Bạn đã tham gia giải đấu này rồi",
	['tournament_not_available'] = "Giải đấu bạn tham gia không còn khả dụng",
	['tournament_started'] = "Giải đấu câu cá đã bắt đầu! Cầm cần câu và bắt càng nhiều cá càng tốt để chiến thắng",
	['tournament_fish_caught'] = "Bạn đã ghi được %s điểm với mẻ câu này!",
	['tournament_ended'] = "Giải đấu đã kết thúc",
	['tournament_cancelled'] = "Giải đấu đã bị hủy do không đủ số lượng người tham gia. Phí đăng ký đã được hoàn lại",
	['tournament_prize_received'] = "Chúc mừng! Hạng của bạn trong giải đấu: %s. Phần thưởng: %s",
	['tournament_prize_not_received'] = "Bạn chưa giành được giải lần này, chúc may mắn lần sau",

	-- Logs
	['logs_date'] = "Ngày",
	['logs_hour'] = "Giờ",
	['logs_withdraw'] = "```prolog\n[RÚT TIỀN]: %s \n[ID] %s \r```",
	['logs_deposit'] = "```prolog\n[GỬI TIỀN]: %s \n[ID] %s \r```",
	['logs_buy_vehicle'] = "```prolog\n[NGƯỜI DÙNG]: %s\n[ĐÃ MUA XE]: %s \n[GIÁ]: %s \n[ID]: %s \r```",
	['logs_buy_property'] = "```prolog\n[NGƯỜI DÙNG]: %s\n[ĐÃ MUA BẤT ĐỘNG SẢN]: %s \n[GIÁ]: %s \n[ID]: %s \r```",
	['logs_fish_sold'] = "```prolog\n[ĐÃ BÁN CÁ]: %s\n[SỐ LƯỢNG]: %s \n[GIÁ]: %s \n[ID]: %s \r```",
	['logs_exploit'] = "```prolog\n[NGHI NGỜ EXPLOIT]: %s\n[VỊ TRÍ NGƯỜI CHƠI]: %s\n[DỮ LIỆU]: %s\n[NGƯỜI DÙNG]: %s \r```",

	-- Fishing Area
	["cannot_fish_in_vehicle"] = "Bạn không thể câu cá trong xe",
	["water_not_found"] = "Không tìm thấy nước ở vị trí này! Đảm bảo có đủ nước để câu",
	["area_not_found"] = "Bạn không ở khu vực hợp lệ để câu cá",
	['new_level'] = "Bạn vừa lên cấp: %s !",
	["fishing_lost"] = "Bạn đã đánh mất con cá",

	["missing_equipments"] = {
		["rod"] = "Bạn phải trang bị cần câu",
		["hook"] = "Bạn phải trang bị lưỡi câu",
		["reel"] = "Bạn phải trang bị ròng rọc câu",
		["bait"] = "Bạn phải trang bị mồi câu",
		["line"] = "Bạn phải trang bị dây câu",
	},
	["equipment_equipped"] = "Bạn đã trang bị thiết bị này",
	["equipment_unequipped"] = "Đã tháo phụ kiện.",
	["item_not_found"] = "Không tìm thấy vật phẩm.",

	-- Config contracts
	['contracts'] = {
		['chefs_special'] = {
			['name'] = "Đặc Biệt Của Đầu Bếp",
			['description'] = "Một đầu bếp địa phương cần những con cá này cho bữa ăn sang trọng tối nay. Bạn có thể giao không?"
		},
		['exotic_collection'] = {
			['name'] = "Bộ Sưu Tập Kỳ Lạ",
			['description'] = "Giao những con cá hiếm này để nhận trang bị đặc biệt!"
		},
		['aquarium_exhibit'] = {
			['name'] = "Triển Lãm Thủy Cung",
			['description'] = "Một thủy cung muốn mở rộng triển lãm. Cung cấp những con cá này để nhận thưởng."
		},
		['rare_fish_trader'] = {
			['name'] = "Thương Nhân Cá Hiếm",
			['description'] = "Một nhà sưu tập đang tìm loài cá hiếm. Giao hàng và kiếm lớn!"
		},
		['swamp_special'] = {
			['name'] = "Đặc Sản Đầm Lầy",
			['description'] = "Giúp nhà nghiên cứu thu thập mẫu từ đầm lầy."
		},
		['maritime_donation'] = {
			['name'] = "Quyên Góp Bảo Tàng Hàng Hải",
			['description'] = "Bảo tàng hàng hải địa phương cần mẫu vật cho triển lãm đại dương mới. Hãy giúp họ!"
		},
		['gourmet_market'] = {
			['name'] = "Chợ Cá Cao Cấp",
			['description'] = "Một chợ cao cấp đang tìm cá hảo hạng. Hoàn thành đơn hàng để nhận thưởng hậu hĩnh."
		},
		['biological_research'] = {
			['name'] = "Nghiên Cứu Sinh Học",
			['description'] = "Hỗ trợ các nhà nghiên cứu bằng cách cung cấp mẫu vật cho nghiên cứu sinh vật thủy sinh."
		},
		['sport_fishing'] = {
			['name'] = "Thử Thách Câu Cá Thể Thao",
			['description'] = "Bắt những loài thách thức này để giành giải trong cuộc thi câu cá thể thao địa phương."
		},
		['fish_fry'] = {
			['name'] = "Sự Kiện Chiên Cá Địa Phương",
			['description'] = "Đóng góp cho sự kiện chiên cá cộng đồng bằng cách giao những con cá phổ biến này."
		},
		['seafood_festival'] = {
			['name'] = "Lễ Hội Hải Sản Địa Phương",
			['description'] = "Lễ hội hải sản hàng năm cần nhiều loại cá để trưng bày. Hãy giúp cung cấp!"
		},
		['exotic_aquarium'] = {
			['name'] = "Kho Thủy Cung Kỳ Lạ",
			['description'] = "Một thủy cung kỳ lạ muốn thêm loài hiếm vào bộ sưu tập. Bạn có thể cung cấp không?"
		},
		['sushi_order'] = {
			['name'] = "Đơn Hàng Nhà Hàng Sushi",
			['description'] = "Một nhà hàng sushi cao cấp cần cá tươi chất lượng hàng đầu. Giao hàng đúng giờ!"
		},
		['pet_food'] = {
			['name'] = "Nhà Sản Xuất Thức Ăn Thú Cưng Cao Cấp",
			['description'] = "Nhà sản xuất thức ăn thú cưng cao cấp cần cá chất lượng cao cho dòng sản phẩm mới. Giúp họ nhé!"
		},
		['research_specimens'] = {
			['name'] = "Mẫu Vật Nghiên Cứu",
			['description'] = "Các nhà nghiên cứu biển cần các loài cá cụ thể cho nghiên cứu môi trường quan trọng."
		},
		['fish_market_supply'] = {
			['name'] = "Cung Cấp Chợ Cá",
			['description'] = "Một chợ cá địa phương cần nguồn cung cấp cá thường xuyên để duy trì quầy hàng."
		},
		['bait_supply_order'] = {
			['name'] = "Đơn Hàng Cung Cấp Mồi",
			['description'] = "Một cửa hàng câu cá cần nhiều loại cá thường làm mồi. Giúp họ nhập hàng."
		},
		['cooking_class'] = {
			['name'] = "Lớp Nấu Ăn Cộng Đồng",
			['description'] = "Một trung tâm cộng đồng đang tổ chức lớp nấu ăn và cần cá địa phương để dạy kỹ thuật làm sạch và nấu đúng cách."
		},
		['restaurant_daily_special'] = {
			['name'] = "Món Đặc Biệt Nhà Hàng Địa Phương",
			['description'] = "Một nhà hàng địa phương có món cá đặc biệt hàng ngày và cần giao cá tươi thường xuyên."
		},
		['science_project'] = {
			['name'] = "Dự Án Khoa Học Trường Học",
			['description'] = "Một trường học địa phương cần nhiều loại cá thường cho dự án khoa học về hệ sinh thái địa phương."
		},
	},
	['dives'] = {
		['reef_explorer'] = {
			['name'] = "Khám Phá Rạn San Hô",
			['description'] = "Khám phá rạn san hô rực rỡ để tìm mẫu sinh vật biển hiếm cho các nhà sinh vật học biển."
		},
		['sunken_armada'] = {
			['name'] = "Hạm Đội Chìm",
			['description'] = "Lặn xuống tàn tích hạm đội huyền thoại bị mất trong cơn bão lớn. Thu hồi hiện vật!"
		},
		['merchant_lost'] = {
			['name'] = "Hàng Hóa Thất Lạc Của Thương Nhân",
			['description'] = "Một tàu thương mại chìm ở đây từ thế kỷ 18, được đồn là chở lụa và gia vị quý giá."
		},
		['underwater_city'] = {
			['name'] = "Thành Phố Dưới Nước Cổ Đại",
			['description'] = "Tàn tích cổ đại mới được phát hiện dưới biển có thể chứa manh mối về các nền văn minh xưa."
		},
		['kraken_lair'] = {
			['name'] = "Hang Ổ Kraken",
			['description'] = "Dám lấy kho báu từ hang ổ Kraken huyền thoại. Cẩn thận cơn thịnh nộ của nó!"
		},
		['meteorite_crash'] = {
			['name'] = "Hiện Trường Thiên Thạch Rơi",
			['description'] = "Một thiên thạch vừa rơi xuống đại dương, tạo ra lớp khoáng chất hiếm phong phú."
		},
		['ghost_ship'] = {
			['name'] = "Thám Hiểm Con Tàu Ma",
			['description'] = "Lặn xuống điều tra con tàu biến mất từ nhiều thế kỷ trước và giờ xuất hiện trở lại một cách bí ẩn."
		},
		['volcanic_vents'] = {
			['name'] = "Khám Phá Miệng Núi Lửa",
			['description'] = "Khám phá miệng núi lửa biển sâu đầy sinh vật độc đáo và thu thập mẫu để nghiên cứu."
		},
		['wreck_titan'] = {
			['name'] = "Xác Tàu Titan",
			['description'] = "Titan, du thuyền sang trọng chìm trong hoàn cảnh bí ẩn, được cho là chứa đầy của cải."
		},
		['bermuda_triangle'] = {
			['name'] = "Dị Thường Tam Giác Bermuda",
			['description'] = "Điều tra dị thường trong lòng sâu Tam Giác Bermuda. Hãy chuẩn bị cho những điều bất ngờ."
		},
		['pearl_diver'] = {
			['name'] = "Nhiệm Vụ Thợ Lặn Ngọc Trai",
			['description'] = "Một chuyến lặn sinh lợi để thu thập ngọc trai từ đáy hàu dày đặc, chỉ những thợ lặn lâu năm mới biết."
		},
		['cold_war_relic'] = {
			['name'] = "Di Vật Chiến Tranh Lạnh",
			['description'] = "Thu hồi thiết bị gián điệp thất lạc từ tàu ngầm thời Chiến Tranh Lạnh đã chìm."
		},
		['deep_sea_salvage'] = {
			['name'] = "Hoạt Động Trục Vớt Biển Sâu",
			['description'] = "Thu hồi hàng hóa quý giá từ tàu chở hàng chìm sâu trong đại dương."
		},
		['lost_jewel_atlantis'] = {
			['name'] = "Viên Ngọc Thất Lạc Của Atlantis",
			['description'] = "Tìm kiếm viên ngọc huyền thoại được đồn là ngoài khơi, được bảo vệ bởi những bí ẩn của biển cả."
		},
		['sunken_plane'] = {
			['name'] = "Trục Vớt Máy Bay Chìm",
			['description'] = "Lặn xuống xác máy bay Thế Chiến II mới phát hiện để thu hồi hiện vật lịch sử."
		},
		['sunken_yacht'] = {
			['name'] = "Du Thuyền Chìm Của Ông Trùm Dầu Mỏ",
			['description'] = "Du thuyền của một tỷ phú đã chìm trong hoàn cảnh bí ẩn. Hãy thu hồi bất cứ thứ gì có giá trị."
		},
		['coral_reef_photography'] = {
			['name'] = "Chụp Ảnh Rạn San Hô",
			['description'] = "Chụp những bức ảnh tuyệt đẹp về rạn san hô cho tạp chí lớn. Họ trả lương cao cho chất lượng!"
		},
		['arctic_shipwreck'] = {
			['name'] = "Thám Hiểm Tàu Đắm Bắc Cực",
			['description'] = "Dũng cảm lặn vào vùng nước lạnh để khám phá con tàu chìm khi cố gắng băng qua vòng Bắc Cực."
		},
	},
}