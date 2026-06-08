Config = {}

Config.account = {								-- Account configs
	['fisher'] = 'cash',						-- Change here the account that should be used with fisher expenses
}

Config.vehicle_blips = {						-- Configure here the vehicle blips created in the script
	['vehicle'] = {								-- Config for ground vehicles
		['sprite'] = 477,						-- Vehicle blip sprite when the vehicle is spawned
		['color'] = 26							-- Vehicle blip color
	},
	['boat'] = {
		['sprite'] = 410,
		['color'] = 26
	}
}

Config.time_degradate_property = 100			-- Time in minutes that will take for the property to degradate 1% and the user will lose it when it reach 0%.
Config.max_garage_slots = 3						-- Max vehicles that can be purchased (this number can be increased when upgrading garages)
Config.job = { "fisher", "unemployed" }			-- Required job name to open the menu (set as false to disable the permission)
Config.disable_loans = true					-- Set this to true if you want to disable the loans
Config.disable_fishing_line = false				-- Set this to true if you're having the following error when starting fishing: SCRIPT ERROR: Execution of native 710311adf0e20730 > ActivatePhysics (ActivatePhysics.lua:4)

Config.anchor_boat = {							-- Feature to anchor the boat in the current location
	['enable'] = false,							-- Enable or disable this feature
	['command'] = "anchor",						-- Chat command
	['shortcut'] = "o",							-- Keyboard shortcut
}

Config.chest_model = "xm_prop_x17_chest_closed"	-- The chest object used on the dive missions
Config.rod_model = "prop_fishing_rod_01"		-- The fishing rod object spawn name
Config.fish_model = "a_c_fish"					-- The fish entity spawn name

-- Here are the places where the person can open the business menu
-- You can add as many locations as you like, just use the location already created as an example
Config.fishing_locations = {
	["fishing_1"] = {
		['menu_location'] = {226.99, -903.98, 29.69},	-- Coordinate to open the menu (vector3)
		['menu_heading'] = 67.61,	
		['garage_locations'] = {						-- Land vehicles garage coordinates, where the business vehicles will spawn (vector4)
			{1313.92, 4325.31, 38.18, 1.19},
			{1327.8, 4331.81, 37.89, 268.23},
			{1298.44, 4329.95, 38.46, 269.74}
		},
		['boat_garage_locations'] = {					-- Boats garage coordinates, where the business vehicles will spawn (vector4)
			{1333.47, 4266.97, 30.01, 266.25}
		},
		['boat_teleport_location'] = {1333.17, 4269.25, 31.5},	-- Location the player will be teleported after storing a boat in garage
		['blips'] = {							-- Create the blips on map
			['id'] = 0,						-- Blip ID [Set this value 0 to dont have blip]
			['name'] = "Fishing job",			-- Blip Name
			['color'] = 3,						-- Blip Color
			['scale'] = 0.6,					-- Blip Scale
		}
	},
}

-- Here are the stores available to sell the fishes
-- You can add as many locations as you like, just use the location already created as an example
Config.fish_stores = {
	-- ['store_1'] = {
	-- 	['menu_location'] = {464.24, 3564.12, 33.67},	-- Coordinate to open the store (vector3)
	-- 	['account'] = "cash",							-- Account where the user will receive the money from the sold fishes
	-- 	['fishes_to_sell'] = {							-- Fishes that are available to sell
	-- 		"alligator_gar", "amur_pike", "atlantic_cod", "atlantic_salmon", "barbel", "beluga_sturgeon", "black_grayling", "blacktip_reef_shark", "blue_marlin", "bluefin_tuna", "bluegill", "brook_trout", "brown_trout", "bull_trout",
	-- 		"chub", "chum_salmon", "coho_salmon", "common_bleak", "common_bream", "common_carp", "crucian_carp", "european_bass", "european_eel", "european_flounder", "european_perch", "european_sea_sturgeon", "electric_eel", "garfish",
	-- 		"giant_freshwater_stingray", "giant_grouper", "giant_squid", "giant_trevally", "golden_trout", "grass_carp", "grass_pickerel", "grayling", "great_barracuda", "grey_snapper", "huchen", "ide", "indian_threadfish", "lake_sturgeon",
	-- 		"largemouth_bass", "mahi_mahi", "malabar_grouper", "mirror_carp", "northern_pike", "pink_river_dolphin", "pink_salmon", "prussian_carp", "pufferfish", "pumpkinseed", "rainbow_trout", "red_lionfish", "redeye_piranha", "redfin_pickerel",
	-- 		"roach", "sea_trout", "silver_carp", "skeleton", "smallmouth_bass", "sockeye_salmon", "south_sea_pearl_oyster", "tench", "tiger_shark", "wels_catfish", "white_sturgeon", "yellow_perch", "yellowfin_tuna", "yellowtail_barracuda", "zander"
	-- 	},
	-- 	-- Other items that can be sold in the fish store
	-- 	['items_to_sell'] = {
	-- 		['antique_compass'] = {
	-- 			['image'] = 'images/dives/items/antique_compass.png',
	-- 			['name'] = 'Antique Compass',
	-- 			['sale_value'] = 30
	-- 		},
	-- 		['rare_spices'] = {
	-- 			['image'] = 'images/dives/items/rare_spices.png',
	-- 			['name'] = 'Rare Spices',
	-- 			['sale_value'] = 15
	-- 		},
	-- 		['ancient_artifact'] = {
	-- 			['image'] = 'images/dives/items/ancient_artifact.png',
	-- 			['name'] = 'Ancient Artifact',
	-- 			['sale_value'] = 32
	-- 		},
	-- 		['enchanted_jewel'] = {
	-- 			['image'] = 'images/dives/items/enchanted_jewel.png',
	-- 			['name'] = 'Enchanted Jewel',
	-- 			['sale_value'] = 40
	-- 		},
	-- 		['meteorite_ore'] = {
	-- 			['image'] = 'images/dives/items/meteorite_ore.png',
	-- 			['name'] = 'Meteorite Ore',
	-- 			['sale_value'] = 40
	-- 		},
	-- 		['phantom_amulet'] = {
	-- 			['image'] = 'images/dives/items/phantom_amulet.png',
	-- 			['name'] = 'Phantom Amulet',
	-- 			['sale_value'] = 52
	-- 		},
	-- 		['luxury_watch'] = {
	-- 			['image'] = 'images/dives/items/luxury_watch.png',
	-- 			['name'] = 'Luxury Watch',
	-- 			['sale_value'] = 50
	-- 		},
	-- 		['mystic_crystal'] = {
	-- 			['image'] = 'images/dives/items/mystic_crystal.png',
	-- 			['name'] = 'Mystic Crystal',
	-- 			['sale_value'] = 62
	-- 		},
	-- 		['precious_pearls'] = {
	-- 			['image'] = 'images/dives/items/precious_pearls.png',
	-- 			['name'] = 'Precious Pearls',
	-- 			['sale_value'] = 60
	-- 		},
	-- 		['spy_gadget'] = {
	-- 			['image'] = 'images/dives/items/spy_gadget.png',
	-- 			['name'] = 'Spy Gadget',
	-- 			['sale_value'] = 25
	-- 		},
	-- 		['fishing_gear'] = {
	-- 			['image'] = 'images/deliveries/items/fishing_gear.png',
	-- 			['name'] = 'Fishing Gear',
	-- 			['sale_value'] = 50
	-- 		},
	-- 		['research_kit'] = {
	-- 			['image'] = 'images/deliveries/items/research_kit.png',
	-- 			['name'] = 'Research Kit',
	-- 			['sale_value'] = 50
	-- 		}
	-- 	},

	-- 	['blips'] = {							
	-- 		['id'] = 371,						
	-- 		['name'] = "Fish store",			
	-- 		['color'] = 3,						
	-- 		['scale'] = 0.6,					
	-- 	}
	-- },
	-- ['illegal_store'] = {
	-- 	['menu_location'] = {1443.28, 6332.56, 23.98},
	-- 	['account'] = "cash",
	-- 	['fishes_to_sell'] = {
	-- 		"paddlefish", "sawfish", "eel", "hammerheadshark", "seaturtle", "leopardshark", "blueshark", "greatwhiteshark"
	-- 	},
	-- 	['items_to_sell'] = {

	-- 	},
	-- 	['blips'] = {
	-- 		['id'] = 0,
	-- 		['name'] = "Illegal fish store",
	-- 		['color'] = 1,
	-- 		['scale'] = 0.6,
	-- 	}
	-- }
}


-- Contracts that are generated to deliver items and receive rewards
-- ATTENTION: When editing a contract here, changes will only take effect for NEWLY generated contracts, not for those that already exist. If you want to remove existing contracts, empty your `fishing_simulator_available_contracts` table in your database.
Config.available_contracts = {
	['definitions'] = {
		['time_to_new_contracts'] = 60, 						-- Time (in mins) to generate new contracts to the contracts page
		['max_contracts'] = 8,								-- Max available contracts
	},
	['contracts'] = {										-- Contracts that will be generated
		{
			-- The contract name and description are provided using translations. If you wish to create new contracts, just duplicate the corresponding entries in the language files to include your newly created contract.
			['name'] = 'contracts.chefs_special.name',
			['description'] = 'contracts.chefs_special.description',
			['image'] = 'images/deliveries/chefs_special.png',	-- Suggested size 666x375
			['reward'] = {									-- Rewards the player will receive when finishing this contract
				['money_min'] = 175,						-- Money min amount
				['money_max'] = 250						-- Money max amount
			},
			['required_items'] = {							-- Items required to delivery in this contract (can be any item, not just fishes)
				{
					['name'] = 'atlantic_cod',				-- Item ID
					-- ['display_name'] = 'Atlantic Cod',	-- (OPTIONAL) Item display name. If the item ID is an existing fish from 'Config.fishes_available', it'll get the name from that table. If it doesn't exist there, you must set a 'display_name' here.
					['amount'] = 3							-- Amount
				},
				{
					['name'] = 'blue_marlin',
					['display_name'] = 'Blue Marlin',
					['amount'] = 1
				}
			}
		},
		{
			['name'] = 'contracts.exotic_collection.name',
			['description'] = 'contracts.exotic_collection.description',
			['image'] = 'images/deliveries/exotic_collection.png',
			['reward'] = {									-- The rewards can be items too, just set the item and the amount
				['item'] = 'fishing_gear',
				['display_name'] = 'High-end Fishing Gear',
				['amount'] = 1
			},
			['required_items'] = {
				{
					['name'] = 'electric_eel',
					['display_name'] = nil,
					['amount'] = 2
				},
				{
					['name'] = 'giant_squid',
					['display_name'] = nil,
					['amount'] = 1
				}
			}
		},
		{
			['name'] = 'contracts.aquarium_exhibit.name',
			['description'] = 'contracts.aquarium_exhibit.description',
			['image'] = 'images/deliveries/aquarium_exhibit.png',
			['reward'] = {
				['money_min'] = 175,
				['money_max'] = 250
			},
			['required_items'] = {
				{
					['name'] = 'tiger_shark',
					['display_name'] = nil,
					['amount'] = 1
				},
				{
					['name'] = 'mahi_mahi',
					['display_name'] = nil,
					['amount'] = 2
				}
			}
		},
		{
			['name'] = 'contracts.rare_fish_trader.name',
			['description'] = 'contracts.rare_fish_trader.description',
			['image'] = 'images/deliveries/rare_fish_trader.png',
			['reward'] = {
				['money_min'] = 150,
				['money_max'] = 300
			},
			['required_items'] = {
				{
					['name'] = 'pufferfish',
					['display_name'] = nil,
					['amount'] = 1
				},
				{
					['name'] = 'beluga_sturgeon',
					['display_name'] = nil,
					['amount'] = 1
				}
			}
		},
		{
			['name'] = 'contracts.swamp_special.name',
			['description'] = 'contracts.swamp_special.description',
			['image'] = 'images/deliveries/swamp_special.png',
			['reward'] = {
				['money_min'] = 235,
				['money_max'] = 270
			},
			['required_items'] = {
				{
					['name'] = 'alligator_gar',
					['display_name'] = nil,
					['amount'] = 2
				},
				{
					['name'] = 'largemouth_bass',
					['display_name'] = nil,
					['amount'] = 3
				}
			}
		},
		{
			['name'] = 'contracts.maritime_donation.name',
			['description'] = 'contracts.maritime_donation.description',
			['image'] = 'images/deliveries/maritime_donation.png',
			['reward'] = {
				['money_min'] = 285,
				['money_max'] = 310
			},
			['required_items'] = {
				{
					['name'] = 'bluefin_tuna',
					['display_name'] = nil,
					['amount'] = 1
				},
				{
					['name'] = 'white_sturgeon',
					['display_name'] = nil,
					['amount'] = 1
				}
			}
		},
		{
			['name'] = 'contracts.gourmet_market.name',
			['description'] = 'contracts.gourmet_market.description',
			['image'] = 'images/deliveries/gourmet_market.png',
			['reward'] = {
				['money_min'] = 225,
				['money_max'] = 285
			},
			['required_items'] = {
				{
					['name'] = 'sockeye_salmon',
					['display_name'] = nil,
					['amount'] = 2
				},
				{
					['name'] = 'european_sea_sturgeon',
					['display_name'] = nil,
					['amount'] = 1
				}
			}
		},
		{
			['name'] = 'contracts.biological_research.name',
			['description'] = 'contracts.biological_research.description',
			['image'] = 'images/deliveries/biological_research.png',
			['reward'] = {
				['item'] = 'research_kit',
				['display_name'] = 'Advanced Research Kit',
				['amount'] = 1
			},
			['required_items'] = {
				{
					['name'] = 'giant_freshwater_stingray',
					['display_name'] = nil,
					['amount'] = 1
				},
				{
					['name'] = 'pink_river_dolphin',
					['display_name'] = nil,
					['amount'] = 1
				}
			}
		},
		{
			['name'] = 'contracts.sport_fishing.name',
			['description'] = 'contracts.sport_fishing.description',
			['image'] = 'images/deliveries/sport_fishing.png',
			['reward'] = {
				['money_min'] = 235,
				['money_max'] = 270
			},
			['required_items'] = {
				{
					['name'] = 'tiger_shark',
					['display_name'] = nil,
					['amount'] = 1
				},
				{
					['name'] = 'giant_grouper',
					['display_name'] = nil,
					['amount'] = 1
				}
			}
		},
		{
			['name'] = 'contracts.fish_fry.name',
			['description'] = 'contracts.fish_fry.description',
			['image'] = 'images/deliveries/fish_fry.png',
			['reward'] = {
				['money_min'] = 75,
				['money_max'] = 95
			},
			['required_items'] = {
				{
					['name'] = 'atlantic_salmon',
					['display_name'] = nil,
					['amount'] = 2
				},
				{
					['name'] = 'european_bass',
					['display_name'] = nil,
					['amount'] = 3
				}
			}
		},
		{
			['name'] = 'contracts.seafood_festival.name',
			['description'] = 'contracts.seafood_festival.description',
			['image'] = 'images/deliveries/seafood_festival.png',
			['reward'] = {
				['money_min'] = 60,
				['money_max'] = 80
			},
			['required_items'] = {
				{
					['name'] = 'yellowfin_tuna',
					['display_name'] = nil,
					['amount'] = 2
				},
				{
					['name'] = 'redfin_pickerel',
					['display_name'] = nil,
					['amount'] = 5
				},
				{
					['name'] = 'bluegill',
					['display_name'] = nil,
					['amount'] = 3
				}
			}
		},
		{
			['name'] = 'contracts.exotic_aquarium.name',
			['description'] = 'contracts.exotic_aquarium.description',
			['image'] = 'images/deliveries/exotic_aquarium.png',
			['reward'] = {
				['money_min'] = 360,
				['money_max'] = 420
			},
			['required_items'] = {
				{
					['name'] = 'pufferfish',
					['display_name'] = nil,
					['amount'] = 2
				},
				{
					['name'] = 'electric_eel',
					['display_name'] = nil,
					['amount'] = 1
				}
			}
		},
		{
			['name'] = 'contracts.sushi_order.name',
			['description'] = 'contracts.sushi_order.description',
			['image'] = 'images/deliveries/sushi_order.png',
			['reward'] = {
				['money_min'] = 185,
				['money_max'] = 210
			},
			['required_items'] = {
				{
					['name'] = 'bluefin_tuna',
					['display_name'] = nil,
					['amount'] = 1
				},
				{
					['name'] = 'sockeye_salmon',
					['display_name'] = nil,
					['amount'] = 2
				}
			}
		},
		{
			['name'] = 'contracts.pet_food.name',
			['description'] = 'contracts.pet_food.description',
			['image'] = 'images/deliveries/pet_food.png',
			['reward'] = {
				['money_min'] = 50,
				['money_max'] = 60
			},
			['required_items'] = {
				{
					['name'] = 'rainbow_trout',
					['display_name'] = nil,
					['amount'] = 4
				},
				{
					['name'] = 'northern_pike',
					['display_name'] = nil,
					['amount'] = 2
				},
				{
					['name'] = 'brown_trout',
					['display_name'] = nil,
					['amount'] = 3
				}
			}
		},
		{
			['name'] = 'contracts.research_specimens.name',
			['description'] = 'contracts.research_specimens.description',
			['image'] = 'images/deliveries/research_specimens.png',
			['reward'] = {
				['money_min'] = 70,
				['money_max'] = 150
			},
			['required_items'] = {
				{
					['name'] = 'coho_salmon',
					['display_name'] = nil,
					['amount'] = 3
				},
				{
					['name'] = 'european_eel',
					['display_name'] = nil,
					['amount'] = 2
				},
				{
					['name'] = 'giant_freshwater_stingray',
					['display_name'] = nil,
					['amount'] = 1
				}
			}
		},
		{
			['name'] = 'contracts.fish_market_supply.name',
			['description'] = 'contracts.fish_market_supply.description',
			['image'] = 'images/deliveries/fish_market_supply.png',
			['reward'] = {
				['money_min'] = 20,
				['money_max'] = 40
			},
			['required_items'] = {
				{
					['name'] = 'roach',
					['display_name'] = nil,
					['amount'] = 5
				},
				{
					['name'] = 'common_bream',
					['display_name'] = nil,
					['amount'] = 5
				},
				{
					['name'] = 'chub',
					['display_name'] = nil,
					['amount'] = 3
				}
			}
		},
		{
			['name'] = 'contracts.bait_supply_order.name',
			['description'] = 'contracts.bait_supply_order.description',
			['image'] = 'images/deliveries/bait_supply_order.png',
			['reward'] = {
				['money_min'] = 90,
				['money_max'] = 105
			},
			['required_items'] = {
				{
					['name'] = 'common_bleak',
					['display_name'] = nil,
					['amount'] = 10
				},
				{
					['name'] = 'smallmouth_bass',
					['display_name'] = nil,
					['amount'] = 2
				}
			}
		},
		{
			['name'] = 'contracts.cooking_class.name',
			['description'] = 'contracts.cooking_class.description',
			['image'] = 'images/deliveries/cooking_class.png',
			['reward'] = {
				['money_min'] = 45,
				['money_max'] = 60
			},
			['required_items'] = {
				{
					['name'] = 'yellow_perch',
					['display_name'] = nil,
					['amount'] = 4
				},
				{
					['name'] = 'prussian_carp',
					['display_name'] = nil,
					['amount'] = 3
				},
				{
					['name'] = 'tench',
					['display_name'] = nil,
					['amount'] = 2
				}
			}
		},
		{
			['name'] = 'contracts.restaurant_daily_special.name',
			['description'] = 'contracts.restaurant_daily_special.description',
			['image'] = 'images/deliveries/restaurant_daily_special.png',
			['reward'] = {
				['money_min'] = 13,
				['money_max'] = 20
			},
			['required_items'] = {
				{
					['name'] = 'common_carp',
					['display_name'] = nil,
					['amount'] = 2
				},
				{
					['name'] = 'european_perch',
					['display_name'] = nil,
					['amount'] = 2
				},
				{
					['name'] = 'roach',
					['display_name'] = nil,
					['amount'] = 3
				}
			}
		},
		{
			['name'] = 'contracts.science_project.name',
			['description'] = 'contracts.science_project.description',
			['image'] = 'images/deliveries/science_project.png',
			['reward'] = {
				['money_min'] = 55,
				['money_max'] = 65
			},
			['required_items'] = {
				{
					['name'] = 'bluegill',
					['display_name'] = nil,
					['amount'] = 5
				},
				{
					['name'] = 'pumpkinseed',
					['display_name'] = nil,
					['amount'] = 5
				}
			}
		}
	}
}

-- Dives that are generated to the user collect different rewards when completing it
-- ATTENTION: When editing a contract here, changes will only take effect for NEWLY generated dives, not for those that already exist. If you want to remove existing dives, empty your `fishing_simulator_available_dives` table in your database.
Config.available_dives = {
	['definitions'] = {
		['time_to_new_dives'] = 15, 							-- Time (in mins) to generate new dive in the dives page
		['max_dives'] = 8,									-- Max available dives
	},
	['dives'] = {											-- Dives that will be generated
		{
			-- The dive name and description are provided using translations. If you wish to create new dives, just duplicate the corresponding entries in the language files to include your newly created dive.
			['name'] = 'dives.reef_explorer.name',
			['description'] = 'dives.reef_explorer.description',
			['image'] = 'images/dives/reef_explorer.png',	-- Suggested size 666x375
			['reward'] = {									-- Rewards the player will receive when finishing this dive
				['money_min'] = 10,						-- Money min amount
				['money_max'] = 18						-- Money max amount
			},
		},
		{
			['name'] = 'dives.sunken_armada.name',
			['description'] = 'dives.sunken_armada.description',
			['image'] = 'images/dives/sunken_armada.png',
			['reward'] = {									-- The rewards can be items too, just set the item and the amount
				['item'] = 'antique_compass',
				['display_name'] = 'Antique Compass',
				['amount'] = 1
			},
		},
		{
			['name'] = 'dives.merchant_lost.name',
			['description'] = 'dives.merchant_lost.description',
			['image'] = 'images/dives/merchant_lost_goods.png',
			['reward'] = {
				['item'] = 'rare_spices',
				['display_name'] = 'Rare Spices',
				['amount'] = 10
			},
		},
		{
			['name'] = 'dives.underwater_city.name',
			['description'] = 'dives.underwater_city.description',
			['image'] = 'images/dives/underwater_city.png',
			['reward'] = {
				['item'] = 'ancient_artifact',
				['display_name'] = 'Ancient Artifact',
				['amount'] = 2
			},
		},
		{
			['name'] = 'dives.kraken_lair.name',
			['description'] = 'dives.kraken_lair.description',
			['image'] = 'images/dives/kraken_lair.png',
			['reward'] = {
				['item'] = 'enchanted_jewel',
				['display_name'] = 'Enchanted Jewel',
				['amount'] = 3
			},
		},
		{
			['name'] = 'dives.meteorite_crash.name',
			['description'] = 'dives.meteorite_crash.description',
			['image'] = 'images/dives/meteorite_crash.png',
			['reward'] = {
				['item'] = 'meteorite_ore',
				['display_name'] = 'Meteorite Ore',
				['amount'] = 4
			},
		},
		{
			['name'] = 'dives.ghost_ship.name',
			['description'] = 'dives.ghost_ship.description',
			['image'] = 'images/dives/ghost_ship.png',
			['reward'] = {
				['item'] = 'phantom_amulet',
				['display_name'] = 'Phantom Amulet',
				['amount'] = 1
			},
		},
		{
			['name'] = 'dives.volcanic_vents.name',
			['description'] = 'dives.volcanic_vents.description',
			['image'] = 'images/dives/volcanic_vents.png',
			['reward'] = {
				['money_min'] = 14,
				['money_max'] = 22
			},
		},
		{
			['name'] = 'dives.wreck_titan.name',
			['description'] = 'dives.wreck_titan.description',
			['image'] = 'images/dives/wreck_titan.png',
			['reward'] = {
				['item'] = 'luxury_watch',
				['display_name'] = 'Luxury Watch',
				['amount'] = 2
			},
		},
		{
			['name'] = 'dives.bermuda_triangle.name',
			['description'] = 'dives.bermuda_triangle.description',
			['image'] = 'images/dives/bermuda_triangle.png',
			['reward'] = {
				['item'] = 'mystic_crystal',
				['display_name'] = 'Mystic Crystal',
				['amount'] = 3
			},
		},
		{
			['name'] = 'dives.pearl_diver.name',
			['description'] = 'dives.pearl_diver.description',
			['image'] = 'images/dives/pearl_diver.png',
			['reward'] = {
				['item'] = 'precious_pearls',
				['display_name'] = 'Precious Pearls',
				['amount'] = 4
			},
		},
		{
			['name'] = 'dives.cold_war_relic.name',
			['description'] = 'dives.cold_war_relic.description',
			['image'] = 'images/dives/cold_war_relic.png',
			['reward'] = {
				['item'] = 'spy_gadget',
				['display_name'] = 'Spy Gadget',
				['amount'] = 1
			},
		},
		{
			['name'] = 'dives.deep_sea_salvage.name',
			['description'] = 'dives.deep_sea_salvage.description',
			['image'] = 'images/dives/deep_sea_salvage.png',
			['reward'] = {
				['money_min'] = 18,
				['money_max'] = 30
			},
		},
		{
			['name'] = 'dives.lost_jewel_atlantis.name',
			['description'] = 'dives.lost_jewel_atlantis.description',
			['image'] = 'images/dives/lost_jewel_atlantis.png',
			['reward'] = {
				['money_min'] = 20,
				['money_max'] = 32
			},
		},
		{
			['name'] = 'dives.sunken_plane.name',
			['description'] = 'dives.sunken_plane.description',
			['image'] = 'images/dives/sunken_plane.png',
			['reward'] = {
				['money_min'] = 15,
				['money_max'] = 29
			},
		},
		{
			['name'] = 'dives.sunken_yacht.name',
			['description'] = 'dives.sunken_yacht.description',
			['image'] = 'images/dives/sunken_yacht.png',
			['reward'] = {
				['money_min'] = 16,
				['money_max'] = 30
			},
		},
		{
			['name'] = 'dives.coral_reef_photography.name',
			['description'] = 'dives.coral_reef_photography.description',
			['image'] = 'images/dives/coral_reef_photography.png',
			['reward'] = {
				['money_min'] = 12,
				['money_max'] = 20
			},
		},
		{
			['name'] = 'dives.arctic_shipwreck.name',
			['description'] = 'dives.arctic_shipwreck.description',
			['image'] = 'images/dives/arctic_shipwreck.png',
			['reward'] = {
				['money_min'] = 20,
				['money_max'] = 32
			},
		}
	}
}

-- Configuration for dynamic pricing of fish based on rarity.
-- When enabled, this will ignore the 'sale_value' defined in Config.fishes_available for each fish, and instead, use a random value between specified min and max ranges.
-- If disabled, the prices for each fish will remain as set in the individual 'sale_vale' for each fish.
Config.fish_prices = {
	['enable'] = false,							-- Enable or disable this feature
	['prices'] = {								-- The price ranges that will be set for each fish rarity
		['common'] = { min = 1, max = 15 },
		['uncommon'] = { min = 20, max = 40 },
		['rare'] = { min = 50, max = 100 },
		['legendary'] = { min = 100, max = 200 },
		['mythic'] = { min = 200, max = 500 },
	}
}

Config.fishes_available = {
	['alligator_gar'] = {
		['image'] = 'images/fishing/fishes/alligator_gar.png',
		['name'] = 'Cá Sấu Mỹ',
		['weight'] = 5,
		['sale_value'] = 63,
		['rarity'] = 'legendary',
		['exp'] = 20,
		['areas'] = { 'swamp' },
	},
	['amur_pike'] = {
		['image'] = 'images/fishing/fishes/amur_pike.png',
		['name'] = 'Cá Chó Amur',
		['weight'] = 7,
		['sale_value'] = 6,
		['rarity'] = 'uncommon',
		['exp'] = 5,
		['areas'] = { 'river', 'lake', 'swamp' },
	},
	['atlantic_cod'] = {
		['image'] = 'images/fishing/fishes/atlantic_cod.png',
		['name'] = 'Cá Tuyết Đại Tây Dương',
		['weight'] = 3,
		['sale_value'] = 8,
		['rarity'] = 'rare',
		['exp'] = 15,
		['areas'] = { 'sea' },
	},
	['atlantic_salmon'] = {
		['image'] = 'images/fishing/fishes/atlantic_salmon.png',
		['name'] = 'Cá Hồi Đại Tây Dương',
		['weight'] = 5,
		['sale_value'] = 6,
		['rarity'] = 'uncommon',
		['exp'] = 5,
		['areas'] = { 'sea', 'lake' },
	},
	['barbel'] = {
		['image'] = 'images/fishing/fishes/barbel.png',
		['name'] = 'Cá Râu',
		['weight'] = 6,
		['sale_value'] = 4,
		['rarity'] = 'common',
		['exp'] = 5,
		['areas'] = { 'river', 'lake' },
	},
	['beluga_sturgeon'] = {
		['image'] = 'images/fishing/fishes/beluga_sturgeon.png',
		['name'] = 'Cá Tầm Beluga',
		['weight'] = 2.6,
		['sale_value'] = 52,
		['rarity'] = 'mythic',
		['exp'] = 20,
		['areas'] = { 'river' },
	},
	['black_grayling'] = {
		['image'] = 'images/fishing/fishes/black_grayling.png',
		['name'] = 'Cá Hồi Đen',
		['weight'] = 1.2,
		['sale_value'] = 7,
		['rarity'] = 'uncommon',
		['exp'] = 5,
		['areas'] = { 'river', 'lake' },
	},
	['blacktip_reef_shark'] = {
		['image'] = 'images/fishing/fishes/blacktip_reef_shark.png',
		['name'] = 'Cá Mập Vây Đen',
		['weight'] = 15,
		['sale_value'] = 13,
		['rarity'] = 'rare',
		['exp'] = 15,
		['areas'] = { 'sea' },
	},
	['blue_marlin'] = {
		['image'] = 'images/fishing/fishes/blue_marlin.png',
		['name'] = 'Cá Cờ Xanh',
		['weight'] = 2,
		['sale_value'] = 88,
		['rarity'] = 'legendary',
		['exp'] = 20,
		['areas'] = { 'sea' },
	},
	['bluefin_tuna'] = {
		['image'] = 'images/fishing/fishes/bluefin_tuna.png',
		['name'] = 'Cá Ngừ Vây Xanh',
		['weight'] = 2.7,
		['sale_value'] = 96,
		['rarity'] = 'legendary',
		['exp'] = 20,
		['areas'] = { 'sea' },
	},
	['bluegill'] = {
		['image'] = 'images/fishing/fishes/bluegill.png',
		['name'] = 'Cá Mang Xanh',
		['weight'] = 1.2,
		['sale_value'] = 3,
		['rarity'] = 'common',
		['exp'] = 5,
		['areas'] = { 'lake', 'river' },
	},
	['brook_trout'] = {
		['image'] = 'images/fishing/fishes/brook_trout.png',
		['name'] = 'Cá Hồi Suối',
		['weight'] = 7,
		['sale_value'] = 6,
		['rarity'] = 'uncommon',
		['exp'] = 5,
		['areas'] = { 'lake', 'river' },
	},
	['brown_trout'] = {
		['image'] = 'images/fishing/fishes/brown_trout.png',
		['name'] = 'Cá Hồi Nâu',
		['weight'] = 2.3,
		['sale_value'] = 4,
		['rarity'] = 'common',
		['exp'] = 5,
		['areas'] = { 'lake', 'river' },
	},
	['bull_trout'] = {
		['image'] = 'images/fishing/fishes/bull_trout.png',
		['name'] = 'Cá Hồi Bò',
		['weight'] = 2,
		['sale_value'] = 8,
		['rarity'] = 'rare',
		['exp'] = 15,
		['areas'] = { 'river' },
	},
	['chub'] = {
		['image'] = 'images/fishing/fishes/chub.png',
		['name'] = 'Cá Chép Trắng',
		['weight'] = 1.5,
		['sale_value'] = 3,
		['rarity'] = 'common',
		['exp'] = 5,
		['areas'] = { 'lake', 'river' },
	},
	['chum_salmon'] = {
		['image'] = 'images/fishing/fishes/chum_salmon.png',
		['name'] = 'Cá Hồi Chum',
		['weight'] = 6,
		['sale_value'] = 5,
		['rarity'] = 'uncommon',
		['exp'] = 5,
		['areas'] = { 'sea', 'lake', 'river' },
	},
	['coho_salmon'] = {
		['image'] = 'images/fishing/fishes/coho_salmon.png',
		['name'] = 'Cá Hồi Coho',
		['weight'] = 5,
		['sale_value'] = 5,
		['rarity'] = 'uncommon',
		['exp'] = 5,
		['areas'] = { 'sea', 'lake', 'river' },
	},
	['common_bleak'] = {
		['image'] = 'images/fishing/fishes/common_bleak.png',
		['name'] = 'Cá Liếp',
		['weight'] = 0.1,
		['sale_value'] = 3,
		['rarity'] = 'common',
		['exp'] = 5,
		['areas'] = { 'sea', 'lake', 'river' },
	},
	['common_bream'] = {
		['image'] = 'images/fishing/fishes/common_bream.png',
		['name'] = 'Cá Chép Bạc',
		['weight'] = 4,
		['sale_value'] = 4,
		['rarity'] = 'common',
		['exp'] = 5,
		['areas'] = { 'river' },
	},
	['common_carp'] = {
		['image'] = 'images/fishing/fishes/common_carp.png',
		['name'] = 'Cá Chép Thường',
		['weight'] = 7,
		['sale_value'] = 5,
		['rarity'] = 'uncommon',
		['exp'] = 5,
		['areas'] = { 'sea', 'lake', 'river' },
	},
	['crucian_carp'] = {
		['image'] = 'images/fishing/fishes/crucian_carp.png',
		['name'] = 'Cá Diếc',
		['weight'] = 1.4,
		['sale_value'] = 4,
		['rarity'] = 'common',
		['exp'] = 5,
		['areas'] = { 'lake', 'river' },
	},
	['european_bass'] = {
		['image'] = 'images/fishing/fishes/european_bass.png',
		['name'] = 'Cá Vược Châu Âu',
		['weight'] = 2.5,
		['sale_value'] = 4,
		['rarity'] = 'common',
		['exp'] = 5,
		['areas'] = { 'sea' },
	},
	['european_eel'] = {
		['image'] = 'images/fishing/fishes/european_eel.png',
		['name'] = 'Cá Chình Châu Âu',
		['weight'] = 3,
		['sale_value'] = 9,
		['rarity'] = 'rare',
		['exp'] = 15,
		['areas'] = { 'lake', 'river' },
	},
	['european_flounder'] = {
		['image'] = 'images/fishing/fishes/european_flounder.png',
		['name'] = 'Cá Bơn Châu Âu',
		['weight'] = 1.7,
		['sale_value'] = 4,
		['rarity'] = 'common',
		['exp'] = 5,
		['areas'] = { 'sea' },
	},
	['european_perch'] = {
		['image'] = 'images/fishing/fishes/european_perch.png',
		['name'] = 'Cá Rô Châu Âu',
		['weight'] = 5,
		['sale_value'] = 4,
		['rarity'] = 'common',
		['exp'] = 5,
		['areas'] = { 'lake', 'river', 'swamp' },
	},
	['european_sea_sturgeon'] = {
		['image'] = 'images/fishing/fishes/european_sea_sturgeon.png',
		['name'] = 'Cá Tầm Biển Châu Âu',
		['weight'] = 20,
		['sale_value'] = 29,
		['rarity'] = 'mythic',
		['exp'] = 20,
		['areas'] = { 'sea' },
	},
	['electric_eel'] = {
		['image'] = 'images/fishing/fishes/electric_eel.png',
		['name'] = 'Cá Chình Điện',
		['weight'] = 15,
		['sale_value'] = 39,
		['rarity'] = 'mythic',
		['exp'] = 20,
		['areas'] = { 'swamp' },
	},
	['garfish'] = {
		['image'] = 'images/fishing/fishes/garfish.png',
		['name'] = 'Cá Nhím',
		['weight'] = 0.5,
		['sale_value'] = 3,
		['rarity'] = 'common',
		['exp'] = 5,
		['areas'] = { 'sea' },
	},
	['giant_freshwater_stingray'] = {
		['image'] = 'images/fishing/fishes/giant_freshwater_stingray.png',
		['name'] = 'Cá Đuối Nước Ngọt Khổng Lồ',
		['weight'] = 3.5,
		['sale_value'] = 40,
		['rarity'] = 'mythic',
		['exp'] = 20,
		['areas'] = { 'lake' },
	},
	['giant_grouper'] = {
		['image'] = 'images/fishing/fishes/giant_grouper.png',
		['name'] = 'Cá Mú Khổng Lồ',
		['weight'] = 2.6,
		['sale_value'] = 9,
		['rarity'] = 'legendary',
		['exp'] = 20,
		['areas'] = { 'sea' },
	},
	['giant_squid'] = {
		['image'] = 'images/fishing/fishes/giant_squid.png',
		['name'] = 'Mực Khổng Lồ',
		['weight'] = 20,
		['sale_value'] = 9,
		['rarity'] = 'rare',
		['exp'] = 15,
		['areas'] = { 'sea' },
	},
	['giant_trevally'] = {
		['image'] = 'images/fishing/fishes/giant_trevally.png',
		['name'] = 'Cá Khế Khổng Lồ',
		['weight'] = 2,
		['sale_value'] = 7,
		['rarity'] = 'uncommon',
		['exp'] = 5,
		['areas'] = { 'sea' },
	},
	['golden_trout'] = {
		['image'] = 'images/fishing/fishes/golden_trout.png',
		['name'] = 'Cá Hồi Vàng',
		['weight'] = 0.4,
		['sale_value'] = 13,
		['rarity'] = 'legendary',
		['exp'] = 20,
		['areas'] = { 'river', 'lake' },
	},
	['grass_carp'] = {
		['image'] = 'images/fishing/fishes/grass_carp.png',
		['name'] = 'Cá Trắm Cỏ',
		['weight'] = 1.2,
		['sale_value'] = 6,
		['rarity'] = 'uncommon',
		['exp'] = 5,
		['areas'] = { 'lake', 'river' },
	},
	['grass_pickerel'] = {
		['image'] = 'images/fishing/fishes/grass_pickerel.png',
		['name'] = 'Cá Chó Cỏ',
		['weight'] = 0.9,
		['sale_value'] = 4,
		['rarity'] = 'common',
		['exp'] = 5,
		['areas'] = { 'swamp' },
	},
	['grayling'] = {
		['image'] = 'images/fishing/fishes/grayling.png',
		['name'] = 'Cá Hồi Xám',
		['weight'] = 0.8,
		['sale_value'] = 3,
		['rarity'] = 'common',
		['exp'] = 5,
		['areas'] = { 'lake' },
	},
	['great_barracuda'] = {
		['image'] = 'images/fishing/fishes/great_barracuda.png',
		['name'] = 'Cá Nhồng Lớn',
		['weight'] = 9,
		['sale_value'] = 7,
		['rarity'] = 'uncommon',
		['exp'] = 5,
		['areas'] = { 'sea' },
	},
	['grey_snapper'] = {
		['image'] = 'images/fishing/fishes/grey_snapper.png',
		['name'] = 'Cá Hồng Xám',
		['weight'] = 4,
		['sale_value'] = 5,
		['rarity'] = 'uncommon',
		['exp'] = 5,
		['areas'] = { 'sea' },
	},
	['huchen'] = {
		['image'] = 'images/fishing/fishes/huchen.png',
		['name'] = 'Cá Hồi Sông Danube',
		['weight'] = 15,
		['sale_value'] = 44,
		['rarity'] = 'legendary',
		['exp'] = 20,
		['areas'] = { 'river' },
	},
	['ide'] = {
		['image'] = 'images/fishing/fishes/ide.png',
		['name'] = 'Cá Chép Vàng',
		['weight'] = 1,
		['sale_value'] = 4,
		['rarity'] = 'common',
		['exp'] = 5,
		['areas'] = { 'river', 'lake' },
	},
	['indian_threadfish'] = {
		['image'] = 'images/fishing/fishes/indian_threadfish.png',
		['name'] = 'Cá Chỉ Vàng Ấn Độ',
		['weight'] = 2.5,
		['sale_value'] = 3,
		['rarity'] = 'common',
		['exp'] = 5,
		['areas'] = { 'sea' },
	},
	['lake_sturgeon'] = {
		['image'] = 'images/fishing/fishes/lake_sturgeon.png',
		['name'] = 'Cá Tầm Hồ',
		['weight'] = 16,
		['sale_value'] = 45,
		['rarity'] = 'legendary',
		['exp'] = 20,
		['areas'] = { 'lake' },
	},
	['largemouth_bass'] = {
		['image'] = 'images/fishing/fishes/largemouth_bass.png',
		['name'] = 'Cá Vược Miệng Lớn',
		['weight'] = 1,
		['sale_value'] = 8,
		['rarity'] = 'rare',
		['exp'] = 15,
		['areas'] = { 'swamp' },
	},
	['mahi_mahi'] = {
		['image'] = 'images/fishing/fishes/mahi_mahi.png',
		['name'] = 'Cá Nục Vây Vàng',
		['weight'] = 10,
		['sale_value'] = 9,
		['rarity'] = 'rare',
		['exp'] = 15,
		['areas'] = { 'sea' },
	},
	['malabar_grouper'] = {
		['image'] = 'images/fishing/fishes/malabar_grouper.png',
		['name'] = 'Cá Mú Malabar',
		['weight'] = 15,
		['sale_value'] = 7,
		['rarity'] = 'uncommon',
		['exp'] = 5,
		['areas'] = { 'sea' },
	},
	['mirror_carp'] = {
		['image'] = 'images/fishing/fishes/mirror_carp.png',
		['name'] = 'Cá Chép Gương',
		['weight'] = 7,
		['sale_value'] = 4,
		['rarity'] = 'common',
		['exp'] = 5,
		['areas'] = { 'lake', 'river' },
	},
	['northern_pike'] = {
		['image'] = 'images/fishing/fishes/northern_pike.png',
		['name'] = 'Cá Chó Phương Bắc',
		['weight'] = 5,
		['sale_value'] = 6,
		['rarity'] = 'uncommon',
		['exp'] = 5,
		['areas'] = { 'lake', 'river' },
	},
	['pink_river_dolphin'] = {
		['image'] = 'images/fishing/fishes/pink_river_dolphin.png',
		['name'] = 'Cá Heo Sông Hồng',
		['weight'] = 15.5,
		['sale_value'] = 48,
		['rarity'] = 'mythic',
		['exp'] = 20,
		['areas'] = { 'river' },
	},
	['pink_salmon'] = {
		['image'] = 'images/fishing/fishes/pink_salmon.png',
		['name'] = 'Cá Hồi Hồng',
		['weight'] = 2,
		['sale_value'] = 5,
		['rarity'] = 'uncommon',
		['exp'] = 5,
		['areas'] = { 'river', 'sea' },
	},
	['prussian_carp'] = {
		['image'] = 'images/fishing/fishes/prussian_carp.png',
		['name'] = 'Cá Chép Phổ',
		['weight'] = 0.9,
		['sale_value'] = 3,
		['rarity'] = 'common',
		['exp'] = 5,
		['areas'] = { 'lake', 'river' },
	},
	['pufferfish'] = {
		['image'] = 'images/fishing/fishes/pufferfish.png',
		['name'] = 'Cá Nóc',
		['weight'] = 1.5,
		['sale_value'] = 38,
		['rarity'] = 'legendary',
		['exp'] = 20,
		['areas'] = { 'sea' },
	},
	['pumpkinseed'] = {
		['image'] = 'images/fishing/fishes/pumpkinseed.png',
		['name'] = 'Cá Bí Ngô',
		['weight'] = 0.4,
		['sale_value'] = 3,
		['rarity'] = 'common',
		['exp'] = 5,
		['areas'] = { 'lake', 'swamp' },
	},
	['rainbow_trout'] = {
		['image'] = 'images/fishing/fishes/rainbow_trout.png',
		['name'] = 'Cá Hồi Cầu Vồng',
		['weight'] = 1,
		['sale_value'] = 5,
		['rarity'] = 'uncommon',
		['exp'] = 5,
		['areas'] = { 'sea', 'lake', 'river' },
	},
	['red_lionfish'] = {
		['image'] = 'images/fishing/fishes/red_lionfish.png',
		['name'] = 'Cá Mao Tiên Đỏ',
		['weight'] = 1,
		['sale_value'] = 8,
		['rarity'] = 'rare',
		['exp'] = 15,
		['areas'] = { 'sea' },
	},
	['redeye_piranha'] = {
		['image'] = 'images/fishing/fishes/redeye_piranha.png',
		['name'] = 'Cá Piranha Mắt Đỏ',
		['weight'] = 1.2,
		['sale_value'] = 6,
		['rarity'] = 'uncommon',
		['exp'] = 5,
		['areas'] = { 'swamp' },
	},
	['redfin_pickerel'] = {
		['image'] = 'images/fishing/fishes/redfin_pickerel.png',
		['name'] = 'Cá Chó Vây Đỏ',
		['weight'] = 0.4,
		['sale_value'] = 5,
		['rarity'] = 'uncommon',
		['exp'] = 5,
		['areas'] = { 'lake', 'swamp' },
	},
	['roach'] = {
		['image'] = 'images/fishing/fishes/roach.png',
		['name'] = 'Cá Roach',
		['weight'] = 0.5,
		['sale_value'] = 3,
		['rarity'] = 'common',
		['exp'] = 5,
		['areas'] = { 'lake', 'river', 'sea', 'swamp' },
	},
	['sea_trout'] = {
		['image'] = 'images/fishing/fishes/sea_trout.png',
		['name'] = 'Cá Hồi Biển',
		['weight'] = 2,
		['sale_value'] = 4,
		['rarity'] = 'common',
		['exp'] = 5,
		['areas'] = { 'river', 'sea' },
	},
	['silver_carp'] = {
		['image'] = 'images/fishing/fishes/silver_carp.png',
		['name'] = 'Cá Trắm Bạc',
		['weight'] = 10,
		['sale_value'] = 7,
		['rarity'] = 'uncommon',
		['exp'] = 5,
		['areas'] = { 'river' },
	},
	['skeleton'] = {
		['image'] = 'images/fishing/fishes/skeleton.png',
		['name'] = 'Bộ Xương',
		['weight'] = 0.1,
		['sale_value'] = 3,
		['rarity'] = 'common',
		['exp'] = 5,
		['areas'] = { 'sea', 'river', 'lake', 'swamp' },
	},
	['smallmouth_bass'] = {
		['image'] = 'images/fishing/fishes/smallmouth_bass.png',
		['name'] = 'Cá Vược Miệng Nhỏ',
		['weight'] = 1.5,
		['sale_value'] = 7,
		['rarity'] = 'uncommon',
		['exp'] = 5,
		['areas'] = { 'swamp' },
	},
	['sockeye_salmon'] = {
		['image'] = 'images/fishing/fishes/sockeye_salmon.png',
		['name'] = 'Cá Hồi Đỏ',
		['weight'] = 3,
		['sale_value'] = 13,
		['rarity'] = 'rare',
		['exp'] = 15,
		['areas'] = { 'river', 'lake' },
	},
	['south_sea_pearl_oyster'] = {
		['image'] = 'images/fishing/fishes/south_sea_pearl_oyster.png',
		['name'] = 'Hàu Ngọc Trai Nam Hải',
		['weight'] = 0.1,
		['sale_value'] = 57,
		['rarity'] = 'mythic',
		['exp'] = 20,
		['areas'] = { 'sea' },
	},
	['tench'] = {
		['image'] = 'images/fishing/fishes/tench.png',
		['name'] = 'Cá Chép Xanh',
		['weight'] = 2.5,
		['sale_value'] = 4,
		['rarity'] = 'common',
		['exp'] = 5,
		['areas'] = { 'swamp', 'river', 'lake' },
	},
	['tiger_shark'] = {
		['image'] = 'images/fishing/fishes/tiger_shark.png',
		['name'] = 'Cá Mập Hổ',
		['weight'] = 20,
		['sale_value'] = 41,
		['rarity'] = 'mythic',
		['exp'] = 20,
		['areas'] = { 'sea' },
	},
	['wels_catfish'] = {
		['image'] = 'images/fishing/fishes/wels_catfish.png',
		['name'] = 'Cá Trê Khổng Lồ',
		['weight'] = 4,
		['sale_value'] = 12,
		['rarity'] = 'rare',
		['exp'] = 15,
		['areas'] = { 'river', 'lake', 'swamp' },
	},
	['white_sturgeon'] = {
		['image'] = 'images/fishing/fishes/white_sturgeon.png',
		['name'] = 'Cá Tầm Trắng',
		['weight'] = 8,
		['sale_value'] = 74,
		['rarity'] = 'legendary',
		['exp'] = 20,
		['areas'] = { 'river' },
	},
	['yellow_perch'] = {
		['image'] = 'images/fishing/fishes/yellow_perch.png',
		['name'] = 'Cá Rô Vàng',
		['weight'] = 0.4,
		['sale_value'] = 3,
		['rarity'] = 'common',
		['exp'] = 5,
		['areas'] = { 'river', 'lake' },
	},
	['yellowfin_tuna'] = {
		['image'] = 'images/fishing/fishes/yellowfin_tuna.png',
		['name'] = 'Cá Ngừ Vây Vàng',
		['weight'] = 9,
		['sale_value'] = 12,
		['rarity'] = 'rare',
		['exp'] = 15,
		['areas'] = { 'sea' },
	},
	['yellowtail_barracuda'] = {
		['image'] = 'images/fishing/fishes/yellowtail_barracuda.png',
		['name'] = 'Cá Nhồng Đuôi Vàng',
		['weight'] = 1.1,
		['sale_value'] = 6,
		['rarity'] = 'uncommon',
		['exp'] = 5,
		['areas'] = { 'sea' },
	},
	['zander'] = {
		['image'] = 'images/fishing/fishes/zander.png',
		['name'] = 'Cá Măng',
		['weight'] = 2,
		['sale_value'] = 4,
		['rarity'] = 'common',
		['exp'] = 5,
		['areas'] = { 'sea', 'river', 'lake' },
	},
	-- Illegal fishes
	['paddlefish'] = {
		['image'] = 'images/fishing/fishes/paddlefish.png',
		['name'] = 'Cá Mái Chèo',
		['weight'] = 10,
		['sale_value'] = 69,
		['rarity'] = 'rare',
		['exp'] = 15,
		['areas'] = { 'river', 'lake' },
		-- ['illegal'] = true,
	},
	['sawfish'] = {
		['image'] = 'images/fishing/fishes/sawfish.png',
		['name'] = 'Cá Cưa',
		['weight'] = 10,
		['sale_value'] = 19,
		['rarity'] = 'rare',
		['exp'] = 15,
		['areas'] = { 'river', 'lake' },
		-- ['illegal'] = true,
	},
	['eel'] = {
		['image'] = 'images/fishing/fishes/eel.png',
		['name'] = 'Cá Chình',
		['weight'] = 10,
		['sale_value'] = 11,
		['rarity'] = 'rare',
		['exp'] = 15,
		['areas'] = { 'swamp', 'river' },
		-- ['illegal'] = true,
	},
	['hammerheadshark'] = {
		['image'] = 'images/fishing/fishes/hammerheadshark.png',
		['name'] = 'Cá Mập Đầu Búa',
		['weight'] = 20,
		['sale_value'] = 58,
		['rarity'] = 'rare',
		['exp'] = 15,
		['areas'] = { 'sea' },
		-- ['illegal'] = true,
	},
	['seaturtle'] = {
		['image'] = 'images/fishing/fishes/seaturtle.png',
		['name'] = 'Rùa Biển',
		['weight'] = 20,
		['sale_value'] = 41,
		['rarity'] = 'rare',
		['exp'] = 15,
		['areas'] = { 'sea' },
		-- ['illegal'] = true,
	},
	['leopardshark'] = {
		['image'] = 'images/fishing/fishes/leopardshark.png',
		['name'] = 'Cá Mập Báo',
		['weight'] = 20,
		['sale_value'] = 25,
		['rarity'] = 'rare',
		['exp'] = 15,
		['areas'] = { 'sea' },
		-- ['illegal'] = true,
	},
	['blueshark'] = {
		['image'] = 'images/fishing/fishes/blueshark.png',
		['name'] = 'Cá Mập Xanh',
		['weight'] = 20,
		['sale_value'] = 86,
		['rarity'] = 'legendary',
		['exp'] = 20,
		['areas'] = { 'sea' },
		-- ['illegal'] = true,
	},
	['greatwhiteshark'] = {
		['image'] = 'images/fishing/fishes/greatwhiteshark.png',
		['name'] = 'Cá Mập Trắng Lớn',
		['weight'] = 20,
		['sale_value'] = 114,
		['rarity'] = 'mythic',
		['exp'] = 20,
		['areas'] = { 'sea' },
		-- ['illegal'] = true,
	},
}

-- Upgrades the user can get
Config.upgrades = {
	['boats'] = { -- This upgrade increases your garage capacity and unlock new boats
		{
			points_required = 1, 		-- Skill points required to upgrade
			level_reward = 1, 			-- How many more vehicles youe will be able to buy
			icon = 'images/upgrades/Boats_001.png' 	-- Image of the upgrades
		},
		{ points_required = 1, level_reward = 2, icon = 'images/upgrades/Boats_002.png' },
		{ points_required = 1, level_reward = 3, icon = 'images/upgrades/Boats_003.png' },
		{ points_required = 1, level_reward = 4, icon = 'images/upgrades/Boats_004.png' },
		{ points_required = 1, level_reward = 5, icon = 'images/upgrades/Boats_005.png' },
	},
	['vehicles'] = { -- This upgrade increases your garage capacity and unlock new vehicles
		{ points_required = 1, level_reward = 1, icon = 'images/upgrades/Garage_001.png' },
		{ points_required = 1, level_reward = 2, icon = 'images/upgrades/Garage_002.png' },
		{ points_required = 1, level_reward = 3, icon = 'images/upgrades/Garage_003.png' },
		{ points_required = 1, level_reward = 4, icon = 'images/upgrades/Garage_004.png' },
		{ points_required = 1, level_reward = 5, icon = 'images/upgrades/Garage_005.png' },
	},
	['properties'] = { -- This upgrade unlock new properties
		{ points_required = 1, icon = 'images/upgrades/Properties_001.png' },
		{ points_required = 1, icon = 'images/upgrades/Properties_002.png' },
		{ points_required = 1, icon = 'images/upgrades/Properties_003.png' },
		{ points_required = 1, icon = 'images/upgrades/Properties_004.png' },
		{ points_required = 1, icon = 'images/upgrades/Properties_005.png' },
	},
	-- The upgrades below is to unlock higher level fishes in the respective locations. See the fish_probability_by_level config for more infos about it
	['lake'] = {
		{ points_required = 1, icon = 'images/upgrades/Lake_001.png' },
		{ points_required = 1, icon = 'images/upgrades/Lake_002.png' },
		{ points_required = 1, icon = 'images/upgrades/Lake_003.png' },
		{ points_required = 1, icon = 'images/upgrades/Lake_004.png' },
		{ points_required = 1, icon = 'images/upgrades/Lake_005.png' },
	},
	['river'] = {
		{ points_required = 1, icon = 'images/upgrades/River_001.png' },
		{ points_required = 1, icon = 'images/upgrades/River_002.png' },
		{ points_required = 1, icon = 'images/upgrades/River_003.png' },
		{ points_required = 1, icon = 'images/upgrades/River_004.png' },
		{ points_required = 1, icon = 'images/upgrades/River_005.png' },
	},
	['sea'] = {
		{ points_required = 1, icon = 'images/upgrades/Sea_001.png' },
		{ points_required = 1, icon = 'images/upgrades/Sea_002.png' },
		{ points_required = 1, icon = 'images/upgrades/Sea_003.png' },
		{ points_required = 1, icon = 'images/upgrades/Sea_004.png' },
		{ points_required = 1, icon = 'images/upgrades/Sea_005.png' },
	},
	['swamp'] = {
		{ points_required = 1, icon = 'images/upgrades/Swamp_001.png' },
		{ points_required = 1, icon = 'images/upgrades/Swamp_002.png' },
		{ points_required = 1, icon = 'images/upgrades/Swamp_003.png' },
		{ points_required = 1, icon = 'images/upgrades/Swamp_004.png' },
		{ points_required = 1, icon = 'images/upgrades/Swamp_005.png' },
	},
}

-- Upgrades to for the fishing minigame
Config.equipments_upgrades = {
	-- Here are all the upgrades you can configure for the fishing minigame
	-- These upgrades will directly affect or be affected by the settings in Config.fishing_difficulties
	['rod'] = { -- This upgrade increases the user's chance to catch rarer fish
		['ufe_telerod_370'] = {				-- Item id
			['name'] = "UFE Telerod 370",	-- Item name
			['price'] = 54,				-- Price
			['bonus'] = 0,					-- Amount this upgrade will affect in the fishing
			['required_level'] = 0,			-- Min level to purchase it
			['icon'] = 'images/equipments/rod/ufe_telerod_370.png'
		},
		['carptack_feeder_master_250'] = {
			['name'] = "Carptack Feeder Master 250",
			['price'] = 80,
			['bonus'] = 1,
			['required_level'] = 3,
			['icon'] = 'images/equipments/rod/carptack_feeder_master_250.png'
		},
		['sakura_tsubarea_tsa_552_xul'] = {
			['name'] = "Sakura Tsubarea TSA 552 XUL",
			['price'] = 130,
			['bonus'] = 1.5,
			['required_level'] = 4,
			['icon'] = 'images/equipments/rod/sakura_tsubarea_tsa_552_xul.png'
		},
		['carpex_hybid_carp_270'] = {
			['name'] = "Carpex Hybid Carp 270",
			['price'] = 170,
			['bonus'] = 2,
			['required_level'] = 5,
			['icon'] = 'images/equipments/rod/carpex_hybid_carp_270.png'
		},
		['ufe_float_x5_300'] = {
			['name'] = "UFE Float X5 300",
			['price'] = 199,
			['bonus'] = 2.5,
			['required_level'] = 5,
			['icon'] = 'images/equipments/rod/ufe_float_x5_300.png'
		},
		['predatek_fast_perch_210'] = {
			['name'] = "Predatek Fast Perch 210",
			['price'] = 88,
			['bonus'] = 1.5,
			['required_level'] = 6,
			['icon'] = 'images/equipments/rod/predatek_fast_perch_210.png'
		},
		['sakura_ionizer_bass_insb_701_ml'] = {
			['name'] = "Sakura Ionizer Bass INSB 701",
			['price'] = 240,
			['bonus'] = 3,
			['required_level'] = 7,
			['icon'] = 'images/equipments/rod/sakura_ionizer_bass_insb_701_ml.png'
		},
		['sakura_redbird_rds_602_l'] = {
			['name'] = "Sakura Redbird RDS 602 L",
			['price'] = 270,
			['bonus'] = 3.5,
			['required_level'] = 8,
			['icon'] = 'images/equipments/rod/sakura_redbird_rds_602_l.png'
		},
		['carpex_cobalt_carp_360'] = {
			['name'] = "Carpex Cobalt Carp 360",
			['price'] = 132,
			['bonus'] = 3,
			['required_level'] = 9,
			['icon'] = 'images/equipments/rod/carpex_cobalt_carp_360.png'
		},
		['sakura_salt_sniper_salss_611_mj1'] = {
			['name'] = "Sakura Salt Sniper SALSS 611",
			['price'] = 290,
			['bonus'] = 4,
			['required_level'] = 10,
			['icon'] = 'images/equipments/rod/sakura_salt_sniper_salss_611_mj1.png'
		},
		['sakura_speciz_spes_light_602_zander'] = {
			['name'] = "Sakura Speciz Spes Light 602",
			['price'] = 310,
			['bonus'] = 4.5,
			['required_level'] = 12,
			['icon'] = 'images/equipments/rod/sakura_speciz_spes_light_602_zander.png'
		},
		['sakura_redbird_rds_662'] = {
			['name'] = "Sakura Redbird RDS 662",
			['price'] = 350,
			['bonus'] = 5,
			['required_level'] = 14,
			['icon'] = 'images/equipments/rod/sakura_redbird_rds_662.png'
		},
		['sakura_salt_sniper_salss_902_h'] = {
			['name'] = "Sakura Salt Sniper SALSS 902",
			['price'] = 380,
			['bonus'] = 5.5,
			['required_level'] = 16,
			['icon'] = 'images/equipments/rod/sakura_salt_sniper_salss_902_h.png'
		},
		['predatek_seahunter_230'] = {
			['name'] = "Predatek Seahunter 230",
			['price'] = 420,
			['bonus'] = 6,
			['required_level'] = 19,
			['icon'] = 'images/equipments/rod/predatek_seahunter_230.png'
		},
		['sakura_shukan_shuc_661_lj'] = {
			['name'] = "Sakura Shukan Shuc 661 LJ",
			['price'] = 450,
			['bonus'] = 7,
			['required_level'] = 20,
			['icon'] = 'images/equipments/rod/sakura_shukan_shuc_661_lj.png'
		},
		['ufe_powercatch_270'] = {
			['name'] = "UFE Powercatch 270",
			['price'] = 485,
			['bonus'] = 8,
			['required_level'] = 21,
			['icon'] = 'images/equipments/rod/ufe_powercatch_270.png'
		},
		['predatek_pilk_200'] = {
			['name'] = "Predatek Pilk 200",
			['price'] = 505,
			['bonus'] = 9,
			['required_level'] = 23,
			['icon'] = 'images/equipments/rod/predatek_pilk_200.png'
		},
		['robinson_carbonic_nordic_pilk_300'] = {
			['name'] = "Robinson Carbonic Nordic Pilk",
			['price'] = 584,
			['bonus'] = 10,
			['required_level'] = 24,
			['icon'] = 'images/equipments/rod/robinson_carbonic_nordic_pilk_300.png'
		},
		['carptack_bottom_cast_360'] = {
			['name'] = "Carptack Bottom Cast 360",
			['price'] = 610,
			['bonus'] = 11,
			['required_level'] = 26,
			['icon'] = 'images/equipments/rod/carptack_bottom_cast_360.png'
		},
		['seax_salfighter_170'] = {
			['name'] = "Seax Salfighter 170",
			['price'] = 699,
			['bonus'] = 12,
			['required_level'] = 29,
			['icon'] = 'images/equipments/rod/seax_salfighter_170.png'
		},
	},
	['reel'] = { -- This upgrade increases the reeling performance, making the reeling progress increase faster
		['ufe_canta_1000'] = {
			['name'] = "UFE Canta 1000",
			['price'] = 72,
			['bonus'] = 0,
			['required_level'] = 0,
			['icon'] = 'images/equipments/reel/ufe_canta_1000.png'
		},
		['ufe_barracuda_2000bt'] = {
			['name'] = "UFE Barracuda 2000BT",
			['price'] = 100,
			['bonus'] = 1,
			['required_level'] = 3,
			['icon'] = 'images/equipments/reel/ufe_barracuda_2000bt.png'
		},
		['sakura_alpax_4508'] = {
			['name'] = "Sakura Alpax 4508",
			['price'] = 115,
			['bonus'] = 2,
			['required_level'] = 5,
			['icon'] = 'images/equipments/reel/sakura_alpax_4508.png'
		},
		['sakura_alpax_8508'] = {
			['name'] = "Sakura Alpax 8508",
			['price'] = 175,
			['bonus'] = 4,
			['required_level'] = 6,
			['icon'] = 'images/equipments/reel/sakura_alpax_8508.png'
		},
		['ufe_belona_4000'] = {
			['name'] = "UFE Belona 4000",
			['price'] = 240,
			['bonus'] = 6,
			['required_level'] = 7,
			['icon'] = 'images/equipments/reel/ufe_belona_4000.png'
		},
		['ufe_bigspin_8000b'] = {
			['name'] = "UFE Bigspin 8000B",
			['price'] = 275,
			['bonus'] = 9,
			['required_level'] = 9,
			['icon'] = 'images/equipments/reel/ufe_bigspin_8000b.png'
		},
		['ufe_batara_8000g'] = {
			['name'] = "UFE Batara 8000G",
			['price'] = 290,
			['bonus'] = 12,
			['required_level'] = 12,
			['icon'] = 'images/equipments/reel/ufe_batara_8000g.png'
		},
		['ufe_batara_1000r'] = {
			['name'] = "UFE Batara 1000R",
			['price'] = 330,
			['bonus'] = 15,
			['required_level'] = 14,
			['icon'] = 'images/equipments/reel/ufe_batara_1000r.png'
		},
		['robinson_big_runner_807qd'] = {
			['name'] = "Robinson Big Runner 807QD",
			['price'] = 260,
			['bonus'] = 13,
			['required_level'] = 15,
			['icon'] = 'images/equipments/reel/robinson_big_runner_807qd.png'
		},
		['spooler_catchpro_4000fd'] = {
			['name'] = "Spooler Catchpro 4000FD",
			['price'] = 345,
			['bonus'] = 18,
			['required_level'] = 17,
			['icon'] = 'images/equipments/reel/spooler_catchpro_4000fd.png'
		},
		['ufe_opensea_8000_x'] = {
			['name'] = "UFE Opensea 8000-X",
			['price'] = 420,
			['bonus'] = 22,
			['required_level'] = 19,
			['icon'] = 'images/equipments/reel/ufe_opensea_8000_x.png'
		},
		['spooler_catchpro_8000fd'] = {
			['name'] = "Spooler Catchpro 8000FD",
			['price'] = 595,
			['bonus'] = 26,
			['required_level'] = 22,
			['icon'] = 'images/equipments/reel/spooler_catchpro_8000fd.png'
		},
		['spooler_catchpro_14000fd'] = {
			['name'] = "Spooler Catchpro 14000FD",
			['price'] = 720,
			['bonus'] = 30,
			['required_level'] = 26,
			['icon'] = 'images/equipments/reel/spooler_catchpro_14000fd.png'
		},
	},
	['hook'] = { -- This upgrade increases the time the user has to react when hooking a fish
		['ufa_bait_hook'] = {
			['name'] = "UFA Bait",
			['price'] = 10,
			['bonus'] = 0,
			['required_level'] = 0,
			['icon'] = 'images/equipments/hook/ufa_bait_hook.png'
		},
		['ufa_sproat_hook'] = {
			['name'] = "UFA Sproat",
			['price'] = 25,
			['bonus'] = 3,
			['required_level'] = 2,
			['icon'] = 'images/equipments/hook/ufa_sproat_hook.png'
		},
		['captack_claw_xl_hook'] = {
			['name'] = "Captack Claw XL",
			['price'] = 32,
			['bonus'] = 6,
			['required_level'] = 3,
			['icon'] = 'images/equipments/hook/captack_claw_xl_hook.png'
		},
		['ufa_sproat_g_hook'] = {
			['name'] = "UFA Sproat-G",
			['price'] = 38,
			['bonus'] = 10,
			['required_level'] = 5,
			['icon'] = 'images/equipments/hook/ufa_sproat_g_hook.png'
		},
		['carptack_carp_ss_hook'] = {
			['name'] = "Carptack Carp S&S",
			['price'] = 46,
			['bonus'] = 14,
			['required_level'] = 7,
			['icon'] = 'images/equipments/hook/carptack_carp_ss_hook.png'
		},
		['ufa_wide_gap_bl_hook'] = {
			['name'] = "UFA Wide Gap BL",
			['price'] = 52,
			['bonus'] = 18,
			['required_level'] = 9,
			['icon'] = 'images/equipments/hook/ufa_wide_gap_bl_hook.png'
		},
		['ufa_aberdeen_hook'] = {
			['name'] = "UFA Aberdeen",
			['price'] = 60,
			['bonus'] = 22,
			['required_level'] = 10,
			['icon'] = 'images/equipments/hook/ufa_aberdeen_hook.png'
		},
		['ufa_octopus_bl_hook'] = {
			['name'] = "UFA Octopus BL",
			['price'] = 65,
			['bonus'] = 26,
			['required_level'] = 12,
			['icon'] = 'images/equipments/hook/ufa_octopus_bl_hook.png'
		},
		['ufa_livebait_hook'] = {
			['name'] = "UFA Livebait",
			['price'] = 70,
			['bonus'] = 30,
			['required_level'] = 15,
			['icon'] = 'images/equipments/hook/ufa_livebait_hook.png'
		},
		['carptack_micro_barb_hook'] = {
			['name'] = "Carptack Micro Barb",
			['price'] = 78,
			['bonus'] = 35,
			['required_level'] = 17,
			['icon'] = 'images/equipments/hook/carptack_micro_barb_hook.png'
		},
		['carptack_carp_hook'] = {
			['name'] = "Carptack Carp",
			['price'] = 96,
			['bonus'] = 40,
			['required_level'] = 20,
			['icon'] = 'images/equipments/hook/carptack_carp_hook.png'
		},
		['ufa_fusion_bl_hook'] = {
			['name'] = "UFA Fusion BL",
			['price'] = 105,
			['bonus'] = 45,
			['required_level'] = 22,
			['icon'] = 'images/equipments/hook/ufa_fusion_bl_hook.png'
		},
		['predatek_octopus_hook'] = {
			['name'] = "Predatek Octopus",
			['price'] = 120,
			['bonus'] = 50,
			['required_level'] = 24,
			['icon'] = 'images/equipments/hook/predatek_octopus_hook.png'
		},
		['predatek_fusion_hook'] = {
			['name'] = "Predatek Fusion",
			['price'] = 148,
			['bonus'] = 60,
			['required_level'] = 28,
			['icon'] = 'images/equipments/hook/predatek_fusion_hook.png'
		},
	},
	['bait'] = { -- This upgrade decreases the time the user has to wait for a fish to bite the bait
		['bread'] = {
			['name'] = "Bánh mì",
			['price'] = 1,
			['bonus'] = 0,
			['required_level'] = 0,
			['icon'] = 'images/equipments/bait/bread.png'
		},
		['earthworm'] = {
			['name'] = "Giun đất",
			['price'] = 1,
			['bonus'] = 5,
			['required_level'] = 1,
			['icon'] = 'images/equipments/bait/earthworm.png'
		},
		['dough'] = {
			['name'] = "Bột nhào",
			['price'] = 1,
			['bonus'] = 10,
			['required_level'] = 2,
			['icon'] = 'images/equipments/bait/dough.png'
		},
		['grub'] = {
			['name'] = "Ấu trùng",
			['price'] = 1,
			['bonus'] = 15,
			['required_level'] = 4,
			['icon'] = 'images/equipments/bait/grub.png'
		},
		['caddis_fly'] = {
			['name'] = "Ruồi nước",
			['price'] = 1,
			['bonus'] = 20,
			['required_level'] = 6,
			['icon'] = 'images/equipments/bait/caddis_fly.png'
		},
		['cheese'] = {
			['name'] = "Phô mai",
			['price'] = 1,
			['bonus'] = 25,
			['required_level'] = 8,
			['icon'] = 'images/equipments/bait/cheese.png'
		},
		['fly'] = {
			['name'] = "Ruồi",
			['price'] = 2,
			['bonus'] = 30,
			['required_level'] = 10,
			['icon'] = 'images/equipments/bait/fly.png'
		},
		['dragonfly'] = {
			['name'] = "Chuồn chuồn",
			['price'] = 2,
			['amount'] = 5,
			['bonus'] = 35,
			['required_level'] = 12,
			['icon'] = 'images/equipments/bait/dragonfly.png'
		},
		['grasshoper'] = {
			['name'] = "Châu chấu",
			['price'] = 2,
			['bonus'] = 40,
			['required_level'] = 14,
			['icon'] = 'images/equipments/bait/grasshoper.png'
		},
		['shrimp'] = {
			['name'] = "Tôm",
			['price'] = 3,
			['bonus'] = 45,
			['required_level'] = 16,
			['icon'] = 'images/equipments/bait/shrimp.png'
		},
		['leech'] = {
			['name'] = "Đỉa",
			['price'] = 3,
			['bonus'] = 50,
			['required_level'] = 18,
			['icon'] = 'images/equipments/bait/leech.png'
		},
		['snail'] = {
			['name'] = "Ốc sên",
			['price'] = 3,
			['bonus'] = 55,
			['required_level'] = 20,
			['icon'] = 'images/equipments/bait/snail.png'
		},
		['liver'] = {
			['name'] = "Gan",
			['price'] = 4,
			['bonus'] = 60,
			['required_level'] = 25,
			['icon'] = 'images/equipments/bait/liver.png'
		},
	},
	['line'] = { -- This upgrade makes the fishing line stronger, making it easier to control tension and catch fish faster (bonus must be at max 100)
		['express_fishing_super_line'] = {
			['name'] = "Express Super Line 0.1mm",
			['price'] = 65,
			['bonus'] = 0,
			['required_level'] = 0,
			['icon'] = 'images/equipments/line/express_fishing_super_line.png'
		},
		['syberia_indiana_green'] = {
			['name'] = "Indiana Green 0.14mm",
			['price'] = 82,
			['bonus'] = 2,
			['required_level'] = 3,
			['icon'] = 'images/equipments/line/syberia_indiana_green.png'
		},
		['syberia_indiana_white'] = {
			['name'] = "Indiana White 0.18mm",
			['price'] = 115,
			['bonus'] = 4,
			['required_level'] = 5,
			['icon'] = 'images/equipments/line/syberia_indiana_white.png'
		},
		['simmons_mono_original'] = {
			['name'] = "Simmons Original 0.25mm",
			['price'] = 130,
			['bonus'] = 7,
			['required_level'] = 6,
			['icon'] = 'images/equipments/line/simmons_mono_original.png'
		},
		['simmons_mono_ss'] = {
			['name'] = "Simmons SS 0.28mm",
			['price'] = 145,
			['bonus'] = 10,
			['required_level'] = 8,
			['icon'] = 'images/equipments/line/simmons_mono_ss.png'
		},
		['syberia_indiana_green_2'] = {
			['name'] = "Indiana Green 0.32mm",
			['price'] = 152,
			['bonus'] = 13,
			['required_level'] = 9,
			['icon'] = 'images/equipments/line/syberia_indiana_green_2.png'
		},
		['syberia_indiana_white_2'] = {
			['name'] = "Indiana White 0.36mm",
			['price'] = 169,
			['bonus'] = 16,
			['required_level'] = 11,
			['icon'] = 'images/equipments/line/syberia_indiana_white_2.png'
		},
		['snake_power_line_clr'] = {
			['name'] = "Snake Power Line 0.41mm",
			['price'] = 180,
			['bonus'] = 19,
			['required_level'] = 12,
			['icon'] = 'images/equipments/line/snake_power_line_clr.png'
		},
		['simmons_mono_original_2'] = {
			['name'] = "Simmons Original 0.48mm",
			['price'] = 210,
			['bonus'] = 22,
			['required_level'] = 14,
			['icon'] = 'images/equipments/line/simmons_mono_original_2.png'
		},
		['simmons_mono_ss_2'] = {
			['name'] = "Simmons SS 0.52mm",
			['price'] = 240,
			['bonus'] = 25,
			['required_level'] = 15,
			['icon'] = 'images/equipments/line/simmons_mono_ss_2.png'
		},
		['snake_power_line_clr_2'] = {
			['name'] = "Snake Power Line 0.65mm",
			['price'] = 285,
			['bonus'] = 28,
			['required_level'] = 16,
			['icon'] = 'images/equipments/line/snake_power_line_clr_2.png'
		},
		['solid_hipower_nylon'] = {
			['name'] = "HiPower Nylon 0.8mm",
			['price'] = 310,
			['bonus'] = 31,
			['required_level'] = 18,
			['icon'] = 'images/equipments/line/solid_hipower_nylon.png'
		},
		['solid_hipower_nylon_lime'] = {
			['name'] = "HiPower Nylon L 0.85mm",
			['price'] = 370,
			['bonus'] = 34,
			['required_level'] = 20,
			['icon'] = 'images/equipments/line/solid_hipower_nylon_lime.png'
		},
		['solid_hipower_nylon_orange'] = {
			['name'] = "HiPower Nylon O 0.9mm",
			['price'] = 410,
			['bonus'] = 38,
			['required_level'] = 21,
			['icon'] = 'images/equipments/line/solid_hipower_nylon_orange.png'
		},
		['solid_hipower_nylon_2'] = {
			['name'] = "HiPower Nylon 1.05mm",
			['price'] = 459,
			['bonus'] = 42,
			['required_level'] = 23,
			['icon'] = 'images/equipments/line/solid_hipower_nylon_2.png'
		},
		['solid_hipower_nylon_lime_2'] = {
			['name'] = "HiPower Nylon L 1.15mm",
			['price'] = 501,
			['bonus'] = 46,
			['required_level'] = 25,
			['icon'] = 'images/equipments/line/solid_hipower_nylon_lime_2.png'
		},
		['solid_hipower_nylon_orange_2'] = {
			['name'] = "HiPower Nylon O 1.25mm",
			['price'] = 552,
			['bonus'] = 50,
			['required_level'] = 27,
			['icon'] = 'images/equipments/line/solid_hipower_nylon_orange_2.png'
		},
	},
	['other'] = { -- Other purchaseable items
		-- ['scuba'] = {
		-- 	['name'] = "Scuba gear",
		-- 	['price'] = 350,
		-- 	['required_level'] = 0,
		-- 	['is_scuba'] = true, -- This is to the script know that this item is a scuba
		-- 	['icon'] = 'images/equipments/other/scuba.png'
		-- },
	}
}

-- Here you can configure the difficulty the player will have while fishing
Config.fishing_difficulties ={
	['fish_probability_by_level'] = {
		-- This table defines the probabilities (in percentages) of catching different levels of fish based on the player's current level in a specific area (e.g., sea, lake, swamp).
		-- Each entry in the table corresponds to the player's upgrade level in that area, with sub-entries for the chance of catching fish of each rarity.
		-- The chance to catch rarer fishes can also be increased when upgradig the fishing rod equipment.
		[1] = { 			-- When the player is at level 0 in the current area he's fishing:
			[1] = 90, 		-- There's a 90% chance to catch a level 1 fish (common species).
			[2] = 10, 		-- 10% chance to catch a level 2 fish (uncommon species).
			[3] = 0, 		-- 0% chance to catch a level 3 fish, meaning it's impossible at this stage (rare species).
			[4] = 0,		-- 0% chance to catch a level 4 fish (legendary species).
			[5] = 0			-- 0% chance to catch a level 5 fish (mythic species).
		},
		[2] = { 			-- At player level 1 in the area:
			[1] = 80, 		-- An 80% chance to catch a level 1 fish.
			[2] = 15, 		-- A 15% chance to catch a level 2 fish.
			[3] = 5,		-- A 5% chance for a level 3 fish, introducing a small chance for rarer fish.
			[4] = 0,		-- Still no chance for levels 4 and 5.
			[5] = 0
		},
		[3] = { 			-- At level 2:
			[1] = 70, 		-- Chances decrease for level 1 as rarer fishes become more common.
			[2] = 20, 		-- Increased chance for level 2 fish.
			[3] = 8, 		-- A 8% chance for level 3 fish.
			[4] = 2,		-- A small chance introduced for catching a level 4 fish.
			[5] = 0 		-- Level 5 fish remains elusive.
		},
		[4] = { 			-- At level 3:
			[1] = 50, 		-- Further decreased chance for the most common fish as player progresses.
			[2] = 30, 		-- Higher chance for level 2 fish.
			[3] = 15, 		-- Higher chance for level 3 fish.
			[4] = 4, 		-- Slightly increased chance for level 4 fish.
			[5] = 1			-- A very small chance introduced for the rarest level 5 fish.
		},
		[5] = { 			-- At level 4:
			[1] = 40, 		-- Reduced chance for level 1, focusing on diversity of catches.
			[2] = 30, 		-- Slightly reduced chance for level 2.
			[3] = 20, 		-- Balanced chance for level 3 fish.
			[4] = 8, 		-- Moderate chance for level 4 fish.
			[5] = 2			-- Maintained a rare chance for level 5, reflecting player's progression.
		},
		[6] = { 			-- At level 5, the highest player level in the area:
			[1] = 35, 		-- Reduced chance for level 1, focusing on diversity of catches.
			[2] = 29, 		-- Slightly reduced chance for level 2.
			[3] = 20, 		-- Balanced chance for level 3 fish.
			[4] = 12, 		-- Moderate chance for level 4 fish.
			[5] = 4			-- A less rare chance for level 5, rewarding the player's progression with extremely rare finds.
		}
	},
	['bait_hook_wait'] = { 	-- This represents the time (in seconds) the user will wait for a fish to bite the bait. This time can be reduced by upgrading the bait
		['min'] = 10,		-- Min wait time
		['max'] = 40,		-- Max wait time
	},
	['hook_fish_wait'] = {	-- This represents the time (in seconds) the user has to hook the fish once it bites. This can be extended by upgrading the reel
		['min'] = 1,		-- Min available time
		['max'] = 2,		-- Max available time
	},
	['tension'] = {					-- Configuration for the tension bar. This sets how much the tension changes each second (tension ranges from 0% to 100%)
		["base_value"] = 1.6,		-- Base speed of tension increase while reeling. This speed will change depending on penalties and fish difficulty
		["randomness"] = 20,		-- Random variation (in %) of the base value for higher or lower tension
		["fish_difficult"] = {		-- Reeling difficulty increases based on fish rarity. Common fish are easier, while rare fish are harder, making it almost impossible to catch legendary or mythic fish without proper upgrades
			[1] = 0,				-- Nothing changes for common fishes
			[2] = 40,				-- 40% harder when fishing uncommon fishes
			[3] = 80,				-- 80% harder when fishing rare fishes
			[4] = 120,				-- 120% harder when fishing legendary fishes
			[5] = 180,				-- 180% harder when fishing mythic fishes
		},
		["penalty"] = 90,			-- Speed penalty (in %) when tension is too low or too high (no penalties at optimal tension)
		["decrease_rate"] = 2.2		-- Speed at which tension decreases when not reeling
	},
	['reeling'] = {					-- Configuration for the progress bar
		["base_value"] = 0.7,		-- Base speed of progress increase while reeling
		["penalty"] = 80,			-- Speed penalty (in %) when tension is too low or too high (no penalties at optimal tension)
		["decrease_rate"] = 1.1		-- Speed at which progress decreases when not reeling
	}
}

-- Any player can join the fishing tournaments, which occur at specific times throughout the week. 
-- The player who catches the most fish based on their rarity during the event wins the top prize, with additional prizes awarded to other top performers based on their ranking.
Config.fishing_tournaments = {
	["enabled"] = true,				-- Enable or disable fishing tournaments
	["command"] = "fish_tournament",-- Command to open the scoreboard while in a tournament
	["schedule"] = {				-- Days of the week, hours and minutes of the day when the tournament will occur
		["Sunday"] = { {12, 0}, {21, 30} },
		["Monday"] = { {12, 0}, {21, 30} },
		["Tuesday"] = { {12, 0}, {21, 30} },
		["Wednesday"] = { {12, 0}, {21, 30} },
		["Thursday"] = { {12, 0}, {21, 30} },
		["Friday"] = { {12, 0}, {21, 30} },
		["Saturday"] = { {12, 0}, {21, 30} },
	},
	["alert_time_before_start"] = 8,-- Time in hours before the tournament starts to allow the users to join
	["min_participants"] = 0,		-- Minimum participants required to start the tournament
	["event_duration"] = 2,		-- Duration of the tournament in minutes
	["entry_fee"] = 200,			-- Fee required to enter the tournament
	["radius"] = 60,				-- Maximum distance in meters from the designated fishing location within which players can participate in the tournament
	["prizes"] = {					-- Prize money awarded to players based on their ranking
		[1] = {						-- 1st place prize
			-- ["item"] = {			-- Item to receive (can be set as nil if you dont want to give items)
			-- 	["label"] = "gold_medal",
			-- 	["display_name"] = "Gold Medal",
			-- 	["amount"] = 1,
			-- },
			["item"] = nil,
			["money"] = 100,		-- Money amount to receive
			["exp"] = 300
		},
		[2] = {						-- 2nd place prize
			["item"] = nil,
			["money"] = 70,
			["exp"] = 150
		},
		[3] = {						-- 3rd place prize
			["item"] = nil,
			["money"] = 60,
			["exp"] = 50
		},
		[4] = {					-- Additional prizes can be added as needed
			["item"] = nil,
			["money"] = 100,
			["exp"] = 25
		},
		[5] = {					-- Additional prizes can be added as needed
			["item"] = nil,
			["money"] = 100,
			["exp"] = 10
		},
	},
	["fish_values"] = {				-- Point values for fish based on their rarity. The winner is the one with the most points
		["common"] = 10,
		["uncommon"] = 12,
		["rare"] = 15,
		["legendary"] = 20,
		["mythic"] = 30
	},
	["blip"] = {
		["id"] = 68,
		["name"] = "Fishing Tournament",
		["color"] = 5,
		["scale"] = 0.6,
	},
	["locations"] = {				-- Fishing locations for each event, randomly selected
		{-2477.66, 4243.59, 1.39},
		{-1588.18, 5208.35, 4.06},
		{-260.53, 6620.3, 7.41},
		{714.21, 4146.69, 35.78},
		{-2082.54, 2614.12, 3.08},
		{-237.95, 4262.89, 30.42},
	}
}

--[[
	Amount of exp you need to reach each level
	Example:
	[1] = 100,
	[2] = 200,
	This means that to reach level 1 you need 100 EXP, to reach level 2 you need 200 EXP
	When leveling up, the player receives 1 skill point
	Level 30 is the maximum
]]
Config.required_xp_to_levelup = {
	[1] = 1000,
	[2] = 2000,
	[3] = 3000,
	[4] = 4000,
	[5] = 5000,
	[6] = 6000,
	[7] = 7000,
	[8] = 8000,
	[9] = 9000,
	[10] = 10000,
	[11] = 11000,
	[12] = 12000,
	[13] = 13000,
	[14] = 14000,
	[15] = 16000,
	[16] = 18000,
	[17] = 20000,
	[18] = 22000,
	[19] = 24000,
	[20] = 26000,
	[21] = 28000,
	[22] = 30000,
	[23] = 35000,
	[24] = 40000,
	[25] = 45000,
	[26] = 50000,
	[27] = 55000,
	[28] = 60000,
	[29] = 65000,
	[30] = 100000 -- Max
}

-- Value you receive when selling the used vehicle
Config.vehicle_sell_price_multiplier = 0.7
-- Value you receive when selling the used property
Config.property_sell_price_multiplier = 0.7

-- Available items to buy in the store
Config.available_items_store = {
	['vehicle'] = {		-- Vehicles available to buy
		-- ['scrap'] = {									-- Vehicle spawn name
		-- 	['name'] = 'Scrap Truck',					-- Vehicle display name
		-- 	['price'] = 14000,							-- Value
		-- 	['image'] = 'images/vehicles/scrap.png',	-- Vehicle image (Suggested size: 666x375, but it can be on any size or any format. Site to remove the background of the image: https://www.remove.bg)
		-- 	['repair_price'] = 20,						-- Value to repair 1% of vehicle condition (Example: if 40% of the part is damaged, the value to repair will be multiplied by 40)
		-- 	['refuel_price'] = 5,						-- Value to fuel 1% of vehicle gas tank
		-- 	['level'] = 0								-- Required vehicle upgrade level to be able to purchase this truck
		-- },
		-- ['seminole2'] = {
		-- 	['name'] = 'Canis Seminole Frontier',
		-- 	['price'] = 15000,
		-- 	['image'] = 'images/vehicles/seminole2.png',
		-- 	['repair_price'] = 20,
		-- 	['refuel_price'] = 5,
		-- 	['level'] = 0
		-- },
		-- ['sadler'] = {
		-- 	['name'] = 'Vapid Sadler',
		-- 	['price'] = 19000,
		-- 	['image'] = 'images/vehicles/sadler.png',
		-- 	['repair_price'] = 20,
		-- 	['refuel_price'] = 5,
		-- 	['level'] = 0
		-- },
		-- ['rumpo'] = {
		-- 	['name'] = 'Bravado Rumpo',
		-- 	['price'] = 20000,
		-- 	['image'] = 'images/vehicles/rumpo.png',
		-- 	['repair_price'] = 20,
		-- 	['refuel_price'] = 5,
		-- 	['level'] = 1
		-- },
		-- ['tiptruck'] = {
		-- 	['name'] = 'Brute Tipper',
		-- 	['price'] = 25000,
		-- 	['image'] = 'images/vehicles/tiptruck.png',
		-- 	['repair_price'] = 20,
		-- 	['refuel_price'] = 5,
		-- 	['level'] = 1
		-- },
		-- ['rubble'] = {
		-- 	['name'] = 'JoBuilt Rubble',
		-- 	['price'] = 35000,
		-- 	['image'] = 'images/vehicles/rubble.png',
		-- 	['repair_price'] = 40,
		-- 	['refuel_price'] = 10,
		-- 	['level'] = 2
		-- },
		-- ['mule'] = {
		-- 	['name'] = 'Maibatsu Mule',
		-- 	['price'] = 40000,
		-- 	['image'] = 'images/vehicles/mule.png',
		-- 	['repair_price'] = 30,
		-- 	['refuel_price'] = 10,
		-- 	['level'] = 3
		-- },
		-- ['mule3'] = {
		-- 	['name'] = 'Maibatsu Mule Custom',
		-- 	['price'] = 42000,
		-- 	['image'] = 'images/vehicles/mule3.png',
		-- 	['repair_price'] = 40,
		-- 	['refuel_price'] = 10,
		-- 	['level'] = 3
		-- },
		-- ['caracara2'] = {
		-- 	['name'] = 'Vapid Caracara 4x4',
		-- 	['price'] = 45000,
		-- 	['image'] = 'images/vehicles/caracara2.png',
		-- 	['repair_price'] = 40,
		-- 	['refuel_price'] = 10,
		-- 	['level'] = 3
		-- },
		-- ['benson'] = {
		-- 	['name'] = 'Vapid Benson',
		-- 	['price'] = 60000,
		-- 	['image'] = 'images/vehicles/benson.png',
		-- 	['repair_price'] = 40,
		-- 	['refuel_price'] = 10,
		-- 	['level'] = 4
		-- },
		-- ['pounder'] = {
		-- 	['name'] = 'MTL Pounder',
		-- 	['price'] = 80000,
		-- 	['image'] = 'images/vehicles/pounder.png',
		-- 	['repair_price'] = 40,
		-- 	['refuel_price'] = 10,
		-- 	['level'] = 4
		-- },
		-- ['terbyte'] = {
		-- 	['name'] = 'Benefactor Terrorbyte',
		-- 	['price'] = 150000,
		-- 	['image'] = 'images/vehicles/terbyte.png',
		-- 	['repair_price'] = 80,
		-- 	['refuel_price'] = 20,
		-- 	['level'] = 5
		-- },
	},
	['boat'] = {		-- Vehicles available to buy
		-- ['tug'] = {
		-- 	['name'] = 'Buckingham Tug',
		-- 	['price'] = 11000,
		-- 	['image'] = 'images/vehicles/tug.png',
		-- 	['repair_price'] = 20,
		-- 	['refuel_price'] = 5,
		-- 	['level'] = 0
		-- },
		-- ['squalo'] = {
		-- 	['name'] = 'Shitzu Squalo',
		-- 	['price'] = 60000,
		-- 	['image'] = 'images/vehicles/squalo.png',
		-- 	['repair_price'] = 20,
		-- 	['refuel_price'] = 5,
		-- 	['level'] = 2
		-- },
		-- ['marquis'] = {
		-- 	['name'] = 'Dinka Marquis',
		-- 	['price'] = 50000,
		-- 	['image'] = 'images/vehicles/marquis.png',
		-- 	['repair_price'] = 20,
		-- 	['refuel_price'] = 5,
		-- 	['level'] = 2
		-- },
		-- ['jetmax'] = {
		-- 	['name'] = 'Shitzu Jetmax',
		-- 	['price'] = 75000,
		-- 	['image'] = 'images/vehicles/jetmax.png',
		-- 	['repair_price'] = 20,
		-- 	['refuel_price'] = 5,
		-- 	['level'] = 3
		-- },
		-- ['tropic'] = {
		-- 	['name'] = 'Shitzu Tropic',
		-- 	['price'] = 55000,
		-- 	['image'] = 'images/vehicles/tropic.png',
		-- 	['repair_price'] = 20,
		-- 	['refuel_price'] = 5,
		-- 	['level'] = 2
		-- },
		-- ['tropic2'] = {
		-- 	['name'] = 'Shitzu Tropic Yacht',
		-- 	['price'] = 60000,
		-- 	['image'] = 'images/vehicles/tropic2.png',
		-- 	['repair_price'] = 20,
		-- 	['refuel_price'] = 5,
		-- 	['level'] = 3
		-- },
		-- ['dinghy'] = {
		-- 	['name'] = 'Dinghy 4-Seater',
		-- 	['price'] = 20000,
		-- 	['image'] = 'images/vehicles/dinghy.png',
		-- 	['repair_price'] = 20,
		-- 	['refuel_price'] = 5,
		-- 	['level'] = 1
		-- },
		-- ['dinghy2'] = {
		-- 	['name'] = 'Dinghy 2-Seater',
		-- 	['price'] = 15000,
		-- 	['image'] = 'images/vehicles/dinghy2.png',
		-- 	['repair_price'] = 20,
		-- 	['refuel_price'] = 5,
		-- 	['level'] = 0
		-- },
		-- ['dinghy3'] = {
		-- 	['name'] = 'Dinghy (Heist)',
		-- 	['price'] = 22000,
		-- 	['image'] = 'images/vehicles/dinghy3.png',
		-- 	['repair_price'] = 20,
		-- 	['refuel_price'] = 5,
		-- 	['level'] = 1
		-- },
		-- ['dinghy4'] = {
		-- 	['name'] = 'Dinghy Yacht',
		-- 	['price'] = 25000,
		-- 	['image'] = 'images/vehicles/dinghy4.png',
		-- 	['repair_price'] = 20,
		-- 	['refuel_price'] = 5,
		-- 	['level'] = 1
		-- },
		-- ['suntrap'] = {
		-- 	['name'] = 'Shitzu Suntrap',
		-- 	['price'] = 50000,
		-- 	['image'] = 'images/vehicles/suntrap.png',
		-- 	['repair_price'] = 20,
		-- 	['refuel_price'] = 5,
		-- 	['level'] = 2
		-- },
		-- ['speeder'] = {
		-- 	['name'] = 'Pegassi Speeder',
		-- 	['price'] = 65000,
		-- 	['image'] = 'images/vehicles/speeder.png',
		-- 	['repair_price'] = 20,
		-- 	['refuel_price'] = 5,
		-- 	['level'] = 3
		-- },
		-- ['speeder2'] = {
		-- 	['name'] = 'Pegassi Speeder Yacht',
		-- 	['price'] = 80000,
		-- 	['image'] = 'images/vehicles/speeder2.png',
		-- 	['repair_price'] = 20,
		-- 	['refuel_price'] = 5,
		-- 	['level'] = 4
		-- },
		-- ['longfin'] = {
		-- 	['name'] = 'Shitzu Longfin',
		-- 	['price'] = 70000,
		-- 	['image'] = 'images/vehicles/longfin.png',
		-- 	['repair_price'] = 20,
		-- 	['refuel_price'] = 5,
		-- 	['level'] = 4
		-- },
		-- ['toro'] = {
		-- 	['name'] = 'Lampadati Toro',
		-- 	['price'] = 70000,
		-- 	['image'] = 'images/vehicles/toro.png',
		-- 	['repair_price'] = 20,
		-- 	['refuel_price'] = 5,
		-- 	['level'] = 4
		-- },
		-- ['toro2'] = {
		-- 	['name'] = 'Lampadati Toro Yacht',
		-- 	['price'] = 80000,
		-- 	['image'] = 'images/vehicles/toro2.png',
		-- 	['repair_price'] = 20,
		-- 	['refuel_price'] = 5,
		-- 	['level'] = 4
		-- },
		-- ['submersible'] = {
		-- 	['name'] = "Submersible",
		-- 	['price'] = 200000,
		-- 	['image'] = 'images/vehicles/submersible.png',
		-- 	['repair_price'] = 20,
		-- 	['refuel_price'] = 5,
		-- 	['level'] = 5
		-- },
		-- ['submersible2'] = {
		-- 	['name'] = "Kraken",
		-- 	['price'] = 250000,
		-- 	['image'] = 'images/vehicles/submersible2.png',
		-- 	['repair_price'] = 20,
		-- 	['refuel_price'] = 5,
		-- 	['level'] = 5
		-- },
		-- ['avisa'] = {
		-- 	['name'] = "Avisa",
		-- 	['price'] = 180000,
		-- 	['image'] = 'images/vehicles/avisa.png',
		-- 	['repair_price'] = 20,
		-- 	['refuel_price'] = 5,
		-- 	['level'] = 5
		-- },
	},
	['property'] = {	-- Properties available to buy
		-- ['sandy_shores_warehouse'] = {					-- Property id
		-- 	['name'] = 'Sandy Shores',					-- Property name
		-- 	['price'] = 17000,							-- Price
		-- 	['capacity'] = 400,							-- Storage capacity
		-- 	['image'] = 'images/properties/sandy_shores_warehouse.png',
		-- 	['location'] = {1919.48, 3739.19, 32.63},	-- Property location
		-- 	['repair_price'] = 17,						-- Price to repair each 1% of it
		-- 	['level'] = 0								-- Min level required to purchase it
		-- },
		-- ['grapeseed_warehouse'] = {
		-- 	['name'] = 'Grapeseed',
		-- 	['price'] = 26000,
		-- 	['capacity'] = 800,
		-- 	['image'] = 'images/properties/grapeseed_warehouse.png',
		-- 	['location'] = {1961.28, 5184.9, 47.96},
		-- 	['repair_price'] = 26,
		-- 	['level'] = 1
		-- },
		-- ['redwood_warehouse'] = {
		-- 	['name'] = 'Redwood',
		-- 	['price'] = 32000,
		-- 	['capacity'] = 1100,
		-- 	['image'] = 'images/properties/redwood_warehouse.png',
		-- 	['location'] = {839.46, 2176.53, 52.29},
		-- 	['repair_price'] = 32,
		-- 	['level'] = 2
		-- },
		-- ['paleto_bay_warehouse'] = {
		-- 	['name'] = 'Paleto Bay',
		-- 	['price'] = 34000,
		-- 	['capacity'] = 1200,
		-- 	['image'] = 'images/properties/paleto_bay_warehouse.png',
		-- 	['location'] = {-121.55, 6204.66, 32.38},
		-- 	['repair_price'] = 34,
		-- 	['level'] = 3
		-- },
		-- ['millars_fishery_warehouse'] = {
		-- 	['name'] = 'Millar\'s Fishery',
		-- 	['price'] = 49000,
		-- 	['capacity'] = 1000,
		-- 	['image'] = 'images/properties/millars_fishery_warehouse.png',
		-- 	['location'] = {1301.07, 4319.1, 38.18},
		-- 	['repair_price'] = 49,
		-- 	['level'] = 3
		-- },
		-- ['youtool_warehouse'] = {
		-- 	['name'] = 'You Tool',
		-- 	['price'] = 55000,
		-- 	['capacity'] = 1600,
		-- 	['image'] = 'images/properties/youtool_warehouse.png',
		-- 	['location'] = {2709.89, 3454.98, 56.32},
		-- 	['repair_price'] = 55,
		-- 	['level'] = 4
		-- },
		-- ['los_santos_warehouse'] = {
		-- 	['name'] = 'Los Santos',
		-- 	['price'] = 70000,
		-- 	['capacity'] = 2000,
		-- 	['image'] = 'images/properties/los_santos_warehouse.png',
		-- 	['location'] = {1007.84, -1854.67, 31.04},
		-- 	['repair_price'] = 70,
		-- 	['level'] = 5
		-- },
	}
}

--[[
	Maximum loan amount available per level (loan size increases with higher levels)
	Example:
	[0] = 40000,
	[10] = 100000,
	[20] = 250000
	This indicates that from level 0 to level 10, players can take out a maximum loan of 40 000. From level 10 to 20, the maximum loan amount increases to 100 000...
]]
Config.max_loan_per_level = {
	[0] = 0,
	[10] = 0,
	[20] = 0,
	[30] = 0
}

-- Loan amounts and interest charges
Config.loans = {
	-- Set the interval between loan payments in hours (24 hours by default)
	['payment_interval_hours'] = 24,

	-- Define the available loan plans, you can create as many as you want
	['plans'] = {
		{
			['loan_amount'] = 0,		-- Total loan amount (20,000)
			['interest_rate'] = 20,			-- Interest rate in percentage
			['repayment_days'] = 15			-- Number of days to complete the loan payment
		},
		{
			['loan_amount'] = 0,
			['interest_rate'] = 15,
			['repayment_days'] = 20
		},
		{
			['loan_amount'] = 0,
			['interest_rate'] = 12,
			['repayment_days'] = 25
		},
		{
			['loan_amount'] = 0,
			['interest_rate'] = 10,
			['repayment_days'] = 30
		}
	}
}

-- Locations that the dives will be generated
Config.dives_locations = {
	-- Ocean locations surrounding the map
	{-2607.21,-757.81,-78.95},
	{-2774.69,-394.55,-27.22},
	{-3502.22,273.39,-59.12},
	{-3456.41,1533.42,-72.00},
	{-2224.31,5235.5,-17.56},
	{518.91,7300.83,-32.75},
	{2141.2,7065.49,-74.99},
	{4012.76,4817.33,-43.43},
	{3224.5,1208.6,-63.83},
	{2149.92,-3034.36,-63.59},
	{1343.66,-3039.94,-20.96},
	{835.44,-3788.04,-84.25},
	{-3154.5,4062.28,-56.69},
	{-2968.1,3996.91,-38.79},
	{-3000.04,3747.42,-42.5},
	{-1149.9,6440.08,-23.73},
	{-1014.61,6420.59,-22.7},
	{-992.53,6353.04,-12.82},
	{-1023.67,6533.73,-16.6},
	{73.66,7413.73,-11.73},
	{385.66,7384.88,-58.49},
	{609.00,7257.48,-13.96},
	{1087.7,7139.95,-40.34},
	{1154.07,7097.8,-56},
	{1236.67,6987.53,-55.93},
	{1386.13,6842.54,-33.2},
	{1722.76,6893.01,-55.99},
	{1894.16,6791.12,-36.89},
	{2326.84,6822.37,-71.37},
	{3672.28,5802.42,-52.19},
	{-2126.22,-1107.02,-64.95},
	{-2207.79,-914.72,-76.89},
	{-2420.75,-764.76,-50},
	{-2432.77,-642.4,-39.14},
	{-2397.81,-599.3,-21.29},
	{-2509.53,-519.83,-28.55},
	{-2677.81,-610.86,-64.33},
	{-2821.44,-687.15,-133.45},
	{-2881.96,-548,-97.15},
	{-3103.75,-321.12,-45.22},
	{-3432.79,-61.34,-47.35},
	{-3262.29,209.45,-5.7},
	{-3468.65,260.37,-49.09},
	{-3617.98,690.24,-72.14},
	{-3723.22,975.97,-112.96},
	{-3451.29,1287.26,-38.95},
	{-3486.66,1454.74,-63.45},
	{-3462.18,1863.22,-54.81},
	{-3370.12,1728.57,-48.26},
	{-3290.96,1810.08,-21.96},

	-- Alamo Sea
	{551.39,3920.4,9.49},
	{356.34,3963.88,-2.02},
	{214.58,3920.34,7.83},
	{59.9,4045.19,-5.19},
	{-142.02,4203.83,26.72},
	{715.09,4089.57,25.66},
	{1549.03,4064.72,14.7},
	{1674.33,4177.74,3.79},
	{1846.83,4199.49,-7.68},
	{2073.37,4129.49,-3.35},
	{2197.73,4334.79,3.42},
	{2198.61,4463.99,15.89},
	{1996.6,4333.75,4.38},
	{1736.46,4264.34,3.85},
	{8.26,3955.15,10.1},

	-- Others
	{1320.35, 4134.6, 16.86},
	{1144.1450, 3900.7524, 5.4106},
	{392.2330, 3855.4492, 8.3525},
	{1963.6865, 4221.6948, -0.6398},
	{1611.6561, 4238.3120, 7.6389},
	{-1181.0347, 6459.2319, -27.5255},
	{-970.1909, 6688.1299, -36.6170},
	{-770.7571, 6614.3037, -14.0786},
	{-137.1174, 7638.5142, -109.6843},
	{-1899.3710, -1301.6575, -38.6908},
	{-1632.5746, -1696.1438, -31.0379},
	{-2100.4636, -1015.8242, -39.8589},
	{-1764.9395, -1406.2587, -42.8310},
	{-2077.2036, -877.2539, -36.6060},
}

-- The contracts are generated in these locations
Config.delivery_locations = {
	{ -952.31, -1077.87, 2.48 },
	{ -978.23, -1108.09, 2.16 },
	{ -1024.49, -1139.6, 2.75 },
	{ -1063.76, -1159.88, 2.56 },
	{ -1001.68, -1218.78, 5.75 },
	{ -1171.54, -1575.61, 4.51 },
	{ -1097.94, -1673.36, 8.4 },
	{ -1286.17, -1267.12, 4.52 },
	{ -1335.75, -1146.55, 6.74 },
	{ -1750.47, -697.09, 10.18 },
	{ -1876.84, -584.39, 11.86 },
	{ -1772.23, -378.12, 46.49 },
	{ -1821.38, -404.97, 46.65 },
	{ -1965.33, -296.96, 41.1 },
	{ -3089.24, 221.49, 14.07 },
	{ -3088.62, 392.3, 11.45 },
	{ -3077.98, 658.9, 11.67 },
	{ -3243.07, 931.84, 17.23 },
	{ 1230.8, -1590.97, 53.77 },
	{ 1286.53, -1604.26, 54.83 },
	{ 1379.38, -1515.23, 58.24 },
	{ 1379.38, -1515.23, 58.24 },
	{ 1437.37, -1492.53, 63.63 },
	{ 450.04, -1863.49, 27.77 },
	{ 403.75, -1929.72, 24.75 },
	{ 430.16, -1559.31, 32.8 },
	{ 446.06, -1242.17, 30.29 },
	{ 322.39, -1284.7, 30.57 },
	{ 369.65, -1194.79, 31.34 },
	{ 474.27, -635.05, 25.65 },
	{ 158.87, -1215.65, 29.3 },
	{ 154.68, -1335.62, 29.21 },
	{ 215.54, -1461.67, 29.19 },
	{ 167.46, -1709.3, 29.3 },
	{ -444.47, 287.68, 83.3 },
	{ -179.56, 314.25, 97.88 },
	{ -16.07, 216.7, 106.75 },
	{ 164.02, 151.87, 105.18 },
	{ 840.2, -181.93, 74.19 },
	{ 952.27, -252.17, 67.77 },
	{ 1105.27, -778.84, 58.27 },
	{ 1099.59, -345.68, 67.19 },
	{ -1211.12, -401.56, 38.1 },
	{ -1302.69, -271.32, 40.0 },
	{ -1468.65, -197.3, 48.84 },
	{ -1583.18, -265.78, 48.28 },
	{ -603.96, -774.54, 25.02 },
	{ -805.14, -959.54, 18.13 },
	{ -325.07, -1356.35, 31.3 },
	{ -321.94, -1545.74, 31.02 },
	{ -428.95, -1728.13, 19.79 },
	{ -582.38, -1743.65, 22.44 },
	{ -670.43, -889.09, 24.5 },
	{ 1691.4, 3866.21, 34.91 },
	{ 1837.93, 3907.12, 33.26 },
	{ 1937.08, 3890.89, 32.47},
	{ 2439.7, 4068.45, 38.07 },
	{ 2592.26, 4668.98, 34.08 },
	{ 1961.53, 5184.91, 47.98 },
	{ 2258.59, 5165.84, 59.12 },
	{ 1652.7, 4746.1, 42.03 },
	{ -359.09, 6062.05, 31.51 },
	{ -160.13, 6432.2, 31.92 },
	{ 33.33, 6673.27, 32.19 },
	{ 175.03, 6643.14, 31.57 },
	{ 22.8, 6488.44, 31.43 },
	{ 64.39, 6309.17, 31.38 },
	{ 122.42, 6406.02, 31.37 },
	{ 1681.2, 6429.11, 32.18 },
	{ 2928.01, 4474.74, 48.04 },
	{ 2709.92, 3454.83, 56.32 },
	{ -688.75, 5788.9, 17.34 },
	{ -436.13, 6154.93, 31.48 },
	{ -291.09, 6185.0, 31.49 },
	{ 405.31, 6526.38, 27.69 },
	{ -20.38, 6567.13, 31.88 },
	{ -368.06, 6341.4, 29.85 },
	{ 1842.89, 3777.72, 33.16 },
	{ 1424.82, 3671.73, 34.18 },
	{ 996.54, 3575.55, 34.62 },
	{ 1697.52, 3596.14, 35.56 },
	{ 2415.05, 5005.35, 46.68 },
	{ 2336.21, 4859.41, 41.81},
	{ 1800.9, 4616.07, 37.23 },
	{ -453.3, 6336.9, 13.11 },
	{ -425.4, 6356.43, 13.33 },
	{ -481.9, 6276.47, 13.42 },
	{ -693.92, 5761.95, 17.52 },
	{ -682.03, 5770.96, 17.52 },
	{ -379.44, 6062.07, 31.51 },
	{ -105.68, 6528.7, 30.17 },
	{ 35.02, 6662.61, 32.2 },
	{ 126.41, 6353.64, 31.38 },
	{ 48.15, 6305.99, 31.37 },
	{ 1417.68, 6343.83, 24.01 },
	{ 1510.21, 6326.28, 24.61 },
	{ 1698.22, 6425.66, 32.77 },
	{ 2434.69, 5011.7, 46.84 },
	{ 1718.88, 4677.32, 43.66 },
	{ 1673.21, 4958.09, 42.35 },
	{ 1364.33, 4315.43, 37.67 },
	{ -1043.6, 5326.84, 44.58 },
	{ -329.63, 6150.58, 32.32 },
	{ -374.41, 6191.04, 31.73 },
	{ -356.63, 6207.34, 31.85 },
	{ -347.15, 6224.69, 31.7 },
	{ -315.61, 6194.0, 31.57 },
	{ -33.3, 6455.87, 31.48 },
	{ 405.52, 6526.59, 27.7 },
	{ 1470.41, 6513.71, 21.23 },
	{ 1593.73, 6460.56, 25.32 },
	{ 1741.31, 6420.19, 35.05 },
}

-- Here you can configure the areas available to fish, it uses polyzone
Config.areas_available_to_fish = {
	['river'] = { -- Area type
		["ness_monster"] = { -- Area name, can be anything
			vector2(-1301.52, 2928.79), --
			vector2(-768.18, 3080.30),
			vector2(-334.85, 3146.97),
			vector2(83.33, 3498.48),
			vector2(262.12, 3413.64),
			vector2(19.70, 2968.18),
			vector2(-356.06, 2846.97),
			vector2(-771.21, 2737.88),
			vector2(-1177.27, 2583.33)
		},
		["smelly_lake"] = {
			vector2(-195.45, 4216.67),
			vector2(-110.61, 4307.58),
			vector2(-328.79, 4553.03),
			vector2(-850.00, 4562.12),
			vector2(-1316.67, 4531.82),
			vector2(-1704.55, 4662.12),
			vector2(-1816.67, 4756.06),
			vector2(-2053.03, 4559.09),
			vector2(-1634.85, 4325.76),
			vector2(-1513.64, 4219.70)
		},
		["big_lake"] = {
			vector2(-1577.27, 1553.03),
			vector2(-1546.97, 1753.03),
			vector2(-1525.76, 1877.27),
			vector2(-1491.67, 2033.33),
			vector2(-1729.55, 2050.76),
			vector2(-1484.09, 2260.98),
			vector2(-1575.76, 2465.15),
			vector2(-1471.21, 2493.94),
			vector2(-1365.15, 2207.58),
			vector2(-1353.79, 1990.91),
			vector2(-1400.76, 1746.97),
			vector2(-1407.58, 1601.52)
		},
	},
	['lake'] = {
		['alamo'] = {
			vector2(126.47, 3426.16),
			vector2(170.03, 3410.63),
			vector2(332.13, 3516.68),
			vector2(321.52, 3575.01),
			vector2(381.74, 3606.82),
			vector2(637.77, 3571.22),
			vector2(892.37, 3646.98),
			vector2(1199.15, 3621.99),
			vector2(1305.58, 3665.16),
			vector2(1379.11, 3727.29),
			vector2(1439.33, 3734.10),
			vector2(1512.81, 3768.57),
			vector2(1571.52, 3814.78),
			vector2(1606.36, 3843.94),
			vector2(1628.71, 3873.86),
			vector2(1658.25, 3885.23),
			vector2(1734.75, 3940.15),
			vector2(1854.06, 3970.07),
			vector2(1971.85, 3949.24),
			vector2(2030.25, 3886.38),
			vector2(2065.48, 3845.85),
			vector2(2154.10, 3874.26),
			vector2(2239.70, 3866.30),
			vector2(2361.66, 3970.84),
			vector2(2406.73, 4050.76),
			vector2(2402.18, 4152.27),
			vector2(2401.09, 4274.64),
			vector2(2435.56, 4403.81),
			vector2(2452.60, 4475.77),
			vector2(2418.51, 4529.18),
			vector2(2423.44, 4586.38),
			vector2(2362.46, 4653.80),
			vector2(2224.95, 4677.67),
			vector2(2120.42, 4662.52),
			vector2(2051.49, 4586.76),
			vector2(1894.69, 4540.56),
			vector2(1801.14, 4541.31),
			vector2(1626.54, 4521.62),
			vector2(1547.38, 4418.60),
			vector2(1463.30, 4363.30),
			vector2(1395.12, 4325.42),
			vector2(1325.33, 4283.35),
			vector2(1260.19, 4329.94),
			vector2(1216.25, 4340.55),
			vector2(1141.64, 4314.41),
			vector2(942.04, 4301.53),
			vector2(887.88, 4283.73),
			vector2(889.02, 4208.36),
			vector2(873.07, 4165.56),
			vector2(768.92, 4160.25),
			vector2(629.53, 4199.26),
			vector2(551.08, 4175.78),
			vector2(466.24, 4262.89),
			vector2(359.42, 4316.30),
			vector2(197.32, 4337.89),
			vector2(56.81, 4432.58),
			vector2(-12.12, 4437.13),
			vector2(-60.98, 4364.40),
			vector2(-90.52, 4271.61),
			vector2(-126.51, 4236.38),
			vector2(-187.10, 4201.54),
			vector2(-226.92, 4110.62),
			vector2(-234.50, 4067.82),
			vector2(-217.08, 4003.81),
			vector2(-214.43, 3912.15),
			vector2(-203.06, 3806.46),
			vector2(-145.49, 3687.53),
			vector2(-94.36, 3658.36),
			vector2(38.58, 3751.52),
			vector2(118.88, 3748.87),
			vector2(132.51, 3654.56),
			vector2(125.69, 3545.48),
			vector2(120.77, 3482.23),
			vector2(120.39, 3438.29)
		},
	},
	['swamp'] = {
		['dirty_water'] = {
			vector2(-2046.97, 2759.09),
			vector2(-1301.52, 2928.79),
			vector2(-1177.27, 2583.33),
			vector2(-1559.09, 2465.15),
			vector2(-2025.76, 2398.48),
			vector2(-2607.58, 2371.21),
			vector2(-2777.27, 2374.24),
			vector2(-2680.30, 2868.18)
		}
	},
	['sea'] = {
		["small_pier"] = {
			vector2(-3428.3308105469, 951.81042480469),
			vector2(-3428.3774414063, 983.30786132813),
			vector2(-3408.8615722656, 983.28839111328),
			vector2(-3408.7917480469, 970.98431396484),
			vector2(-3323.1303710938, 970.91625976563),
			vector2(-3323.1264648438, 964.23559570313),
			vector2(-3408.8974609375, 963.92547607422),
			vector2(-3408.8547363281, 951.81213378906)
		},
		["nice_area"] = {
			vector2(-1786.36, -973.48),
			vector2(-1823.86, -867.42),
			vector2(-1939.77, -716.67),
			vector2(-2022.73, -617.42),
			vector2(-2104.55, -553.79),
			vector2(-2112.50, -543.94),
			vector2(-2111.74, -518.18),
			vector2(-2146.97, -487.12),
			vector2(-2171.97, -456.82),
			vector2(-2212.12, -442.42),
			vector2(-2276.89, -393.18),
			vector2(-2347.73, -353.79),
			vector2(-2371.59, -339.39),
			vector2(-2419.32, -331.82),
			vector2(-2478.03, -296.21),
			vector2(-2656.44, -182.58),
			vector2(-2727.65, -103.41),
			vector2(-2807.20, -62.88),
			vector2(-2861.74, -41.67),
			vector2(-2926.14, -40.53),
			vector2(-3066.29, 23.48),
			vector2(-3091.29, 78.41),
			vector2(-3101.52, 182.58),
			vector2(-3152.27, 246.97),
			vector2(-3155.30, 285.61),
			vector2(-3138.64, 326.89),
			vector2(-3121.97, 374.24),
			vector2(-3080.68, 471.21),
			vector2(-3074.62, 507.20),
			vector2(-3095.83, 614.39),
			vector2(-3135.23, 683.33),
			vector2(-3183.33, 773.48),
			vector2(-3229.92, 853.03),
			vector2(-3235.98, 889.77),
			vector2(-3274.62, 925.76),
			vector2(-3296.97, 956.44),
			vector2(-3399.62, 957.20),
			vector2(-3398.86, 945.08),
			vector2(-3421.21, 943.56),
			vector2(-3948.48, 942.42),
			vector2(-3907.58, -2028.79)

		},
		["giant_area"] = {
			vector2(1577.65, 6658.33),
			vector2(1584.47, 6668.56),
			vector2(1600.76, 6669.70),
			vector2(1609.09, 6678.79),
			vector2(1621.59, 6668.18),
			vector2(1645.83, 6662.88),
			vector2(1661.74, 6665.91),
			vector2(1668.18, 6675.76),
			vector2(1678.79, 6665.91),
			vector2(1691.67, 6667.42),
			vector2(1693.94, 6676.14),
			vector2(1712.50, 6676.14),
			vector2(1727.27, 6672.73),
			vector2(1735.23, 6666.67),
			vector2(1746.59, 6678.41),
			vector2(1756.44, 6679.17),
			vector2(1761.74, 6666.29),
			vector2(1776.52, 6660.98),
			vector2(1784.47, 6667.05),
			vector2(1796.21, 6668.18),
			vector2(1807.58, 6668.56),
			vector2(1814.02, 6676.14),
			vector2(1832.95, 6671.21),
			vector2(1840.91, 6667.80),
			vector2(1850.38, 6676.52),
			vector2(1865.91, 6673.48),
			vector2(1878.03, 6671.59),
			vector2(1889.02, 6659.47),
			vector2(1901.14, 6657.58),
			vector2(1908.71, 6654.17),
			vector2(1912.88, 6648.11),
			vector2(1917.80, 6650.38),
			vector2(1922.73, 6661.36),
			vector2(1923.86, 6671.97),
			vector2(1920.45, 6692.05),
			vector2(1915.53, 6697.35),
			vector2(1936.74, 6700.38),
			vector2(1955.30, 6709.47),
			vector2(1981.82, 6725.38),
			vector2(2013.26, 6740.91),
			vector2(2045.83, 6737.50),
			vector2(2078.41, 6737.88),
			vector2(2096.97, 6728.03),
			vector2(2131.44, 6692.05),
			vector2(2158.71, 6717.80),
			vector2(2184.47, 6730.68),
			vector2(2206.44, 6727.65),
			vector2(2215.53, 6719.32),
			vector2(2231.82, 6726.89),
			vector2(2254.55, 6733.33),
			vector2(2305.30, 6704.55),
			vector2(2325.76, 6674.62),
			vector2(2337.12, 6645.45),
			vector2(2354.55, 6628.41),
			vector2(2401.14, 6621.97),
			vector2(2445.45, 6602.65),
			vector2(2484.09, 6586.36),
			vector2(2504.92, 6586.36),
			vector2(2535.23, 6603.41),
			vector2(2555.68, 6609.85),
			vector2(2573.86, 6594.70),
			vector2(2583.33, 6596.59),
			vector2(2589.77, 6593.94),
			vector2(2600.76, 6586.36),
			vector2(2621.97, 6567.05),
			vector2(2616.67, 6549.62),
			vector2(2619.32, 6533.71),
			vector2(2623.48, 6519.32),
			vector2(2633.71, 6520.08),
			vector2(2649.24, 6533.71),
			vector2(2654.55, 6544.32),
			vector2(2665.15, 6540.91),
			vector2(2678.79, 6526.52),
			vector2(2705.30, 6523.11),
			vector2(2729.92, 6540.53),
			vector2(2739.39, 6532.20),
			vector2(2739.39, 6525.00),
			vector2(2748.48, 6527.65),
			vector2(2753.41, 6520.45),
			vector2(2744.70, 6513.64),
			vector2(2749.24, 6499.24),
			vector2(2760.23, 6502.27),
			vector2(2762.50, 6511.74),
			vector2(2773.11, 6510.61),
			vector2(2783.33, 6515.15),
			vector2(2799.62, 6513.26),
			vector2(2800.00, 6506.06),
			vector2(2813.26, 6495.08),
			vector2(2803.03, 6491.67),
			vector2(2809.85, 6476.52),
			vector2(2809.85, 6462.50),
			vector2(2814.77, 6447.35),
			vector2(2812.12, 6442.80),
			vector2(2827.27, 6436.36),
			vector2(2845.83, 6428.79),
			vector2(2862.88, 6433.33),
			vector2(2879.55, 6428.79),
			vector2(2887.50, 6418.56),
			vector2(2890.91, 6392.42),
			vector2(2892.80, 6379.55),
			vector2(2888.64, 6354.17),
			vector2(2921.21, 6367.05),
			vector2(2941.67, 6377.65),
			vector2(2969.70, 6381.06),
			vector2(2975.76, 6369.32),
			vector2(2980.68, 6360.98),
			vector2(2999.24, 6362.12),
			vector2(3025.76, 6345.45),
			vector2(3034.47, 6331.06),
			vector2(3047.35, 6318.56),
			vector2(3057.58, 6329.55),
			vector2(3051.89, 6339.02),
			vector2(3068.94, 6346.97),
			vector2(3081.82, 6353.79),
			vector2(3095.45, 6347.35),
			vector2(3120.08, 6349.62),
			vector2(3156.06, 6353.41),
			vector2(3168.56, 6342.42),
			vector2(3174.62, 6324.62),
			vector2(3172.73, 6317.42),
			vector2(3176.89, 6310.98),
			vector2(3199.62, 6300.00),
			vector2(3210.98, 6300.76),
			vector2(3218.18, 6304.92),
			vector2(3231.44, 6301.89),
			vector2(3239.77, 6292.05),
			vector2(3248.86, 6285.98),
			vector2(3240.53, 6282.58),
			vector2(3245.83, 6274.24),
			vector2(3250.76, 6259.09),
			vector2(3254.17, 6235.98),
			vector2(3259.09, 6225.76),
			vector2(3266.67, 6220.08),
			vector2(3254.17, 6208.71),
			vector2(3247.35, 6197.35),
			vector2(3248.86, 6184.47),
			vector2(3248.86, 6170.08),
			vector2(3247.35, 6159.09),
			vector2(3239.02, 6153.79),
			vector2(3240.91, 6138.64),
			vector2(3249.24, 6138.64),
			vector2(3275.76, 6138.26),
			vector2(3290.53, 6142.05),
			vector2(3319.70, 6122.73),
			vector2(3355.68, 6120.45),
			vector2(3361.74, 6098.86),
			vector2(3379.92, 6109.09),
			vector2(3398.86, 6122.73),
			vector2(3422.73, 6134.85),
			vector2(3425.76, 6129.92),
			vector2(3432.95, 6109.47),
			vector2(3418.94, 6101.52),
			vector2(3418.18, 6076.52),
			vector2(3419.70, 6058.71),
			vector2(3415.53, 6047.35),
			vector2(3408.33, 6041.29),
			vector2(3405.68, 6004.92),
			vector2(3401.52, 5992.80),
			vector2(3403.41, 5980.68),
			vector2(3414.39, 5965.53),
			vector2(3420.83, 5966.29),
			vector2(3430.30, 5965.91),
			vector2(3436.36, 5947.35),
			vector2(3439.77, 5928.79),
			vector2(3434.09, 5920.83),
			vector2(3424.62, 5913.26),
			vector2(3425.76, 5885.98),
			vector2(3435.23, 5871.97),
			vector2(3444.32, 5859.09),
			vector2(3430.30, 5848.11),
			vector2(3410.61, 5839.39),
			vector2(3401.14, 5837.12),
			vector2(3401.89, 5818.56),
			vector2(3398.48, 5799.24),
			vector2(3392.80, 5773.48),
			vector2(3387.88, 5752.65),
			vector2(3378.03, 5723.48),
			vector2(3370.83, 5703.03),
			vector2(3361.74, 5692.42),
			vector2(3357.58, 5684.47),
			vector2(3359.09, 5672.35),
			vector2(3367.80, 5662.50),
			vector2(3378.41, 5638.64),
			vector2(3380.30, 5621.59),
			vector2(3374.24, 5609.47),
			vector2(3372.73, 5589.77),
			vector2(3377.65, 5573.11),
			vector2(3376.52, 5564.39),
			vector2(3395.45, 5551.14),
			vector2(3399.24, 5540.91),
			vector2(3417.05, 5540.53),
			vector2(3426.14, 5526.52),
			vector2(3434.85, 5526.14),
			vector2(3436.36, 5513.64),
			vector2(3454.92, 5509.47),
			vector2(3468.56, 5509.85),
			vector2(3472.35, 5502.27),
			vector2(3465.91, 5490.91),
			vector2(3475.38, 5476.14),
			vector2(3467.42, 5467.42),
			vector2(3463.64, 5457.95),
			vector2(3455.68, 5442.05),
			vector2(3436.74, 5421.59),
			vector2(3407.20, 5424.62),
			vector2(3389.39, 5403.41),
			vector2(3364.77, 5392.80),
			vector2(3343.94, 5391.67),
			vector2(3319.70, 5373.86),
			vector2(3298.86, 5356.06),
			vector2(3273.86, 5353.79),
			vector2(3258.33, 5344.32),
			vector2(3241.67, 5326.52),
			vector2(3217.80, 5326.52),
			vector2(3202.65, 5316.29),
			vector2(3207.20, 5300.38),
			vector2(3215.91, 5279.55),
			vector2(3235.61, 5254.92),
			vector2(3247.35, 5234.47),
			vector2(3301.14, 5231.06),
			vector2(3316.29, 5220.08),
			vector2(3319.32, 5210.98),
			vector2(3337.88, 5193.94),
			vector2(3348.11, 5188.64),
			vector2(3356.82, 5172.73),
			vector2(3360.61, 5165.15),
			vector2(3348.11, 5128.79),
			vector2(3326.89, 5120.83),
			vector2(3318.18, 5111.36),
			vector2(3296.97, 5109.85),
			vector2(3265.15, 5110.98),
			vector2(3244.70, 5111.74),
			vector2(3225.76, 5107.95),
			vector2(3211.36, 5104.17),
			vector2(3204.92, 5096.97),
			vector2(3188.64, 5091.67),
			vector2(3173.48, 5088.64),
			vector2(3157.58, 5080.30),
			vector2(3154.17, 5071.59),
			vector2(3180.30, 5071.97),
			vector2(3214.39, 5077.65),
			vector2(3230.30, 5075.00),
			vector2(3241.29, 5085.98),
			vector2(3255.30, 5088.64),
			vector2(3269.32, 5078.79),
			vector2(3282.58, 5079.55),
			vector2(3294.32, 5071.59),
			vector2(3314.77, 5067.05),
			vector2(3328.79, 5064.02),
			vector2(3345.45, 5063.26),
			vector2(3354.55, 5057.58),
			vector2(3355.30, 5052.65),
			vector2(3372.73, 5049.24),
			vector2(3389.02, 5035.61),
			vector2(3395.83, 5036.36),
			vector2(3410.61, 5027.65),
			vector2(3414.02, 5019.32),
			vector2(3417.05, 5008.33),
			vector2(3431.44, 5003.41),
			vector2(3435.23, 4991.29),
			vector2(3445.45, 4981.44),
			vector2(3446.59, 4973.11),
			vector2(3443.56, 4962.88),
			vector2(3444.32, 4951.14),
			vector2(3447.73, 4943.94),
			vector2(3460.98, 4943.18),
			vector2(3471.21, 4938.64),
			vector2(3477.27, 4927.27),
			vector2(3481.44, 4917.80),
			vector2(3506.06, 4913.26),
			vector2(3512.50, 4900.76),
			vector2(3521.59, 4882.95),
			vector2(3529.55, 4876.52),
			vector2(3528.41, 4867.42),
			vector2(3526.89, 4859.85),
			vector2(3534.85, 4854.17),
			vector2(3542.80, 4851.89),
			vector2(3546.59, 4843.56),
			vector2(3544.70, 4834.85),
			vector2(3547.73, 4822.73),
			vector2(3550.00, 4811.74),
			vector2(3543.56, 4805.68),
			vector2(3535.98, 4798.48),
			vector2(3530.30, 4789.02),
			vector2(3533.33, 4778.41),
			vector2(3543.56, 4773.48),
			vector2(3536.74, 4765.91),
			vector2(3537.88, 4756.44),
			vector2(3550.38, 4743.56),
			vector2(3560.98, 4731.44),
			vector2(3571.59, 4718.56),
			vector2(3583.33, 4714.39),
			vector2(3596.97, 4701.14),
			vector2(3613.26, 4696.97),
			vector2(3625.76, 4699.24),
			vector2(3636.74, 4699.62),
			vector2(3644.32, 4692.42),
			vector2(3635.98, 4687.12),
			vector2(3633.33, 4682.20),
			vector2(3639.77, 4673.48),
			vector2(3640.15, 4665.15),
			vector2(3636.74, 4660.61),
			vector2(3640.15, 4653.41),
			vector2(3635.98, 4637.50),
			vector2(3635.98, 4625.00),
			vector2(3645.08, 4619.70),
			vector2(3654.55, 4634.85),
			vector2(3668.94, 4653.41),
			vector2(3685.98, 4666.29),
			vector2(3714.02, 4667.80),
			vector2(3735.61, 4659.09),
			vector2(3742.42, 4645.45),
			vector2(3736.36, 4637.12),
			vector2(3730.30, 4624.24),
			vector2(3738.64, 4620.08),
			vector2(3755.30, 4617.42),
			vector2(3762.88, 4596.59),
			vector2(3764.02, 4576.14),
			vector2(3770.45, 4562.12),
			vector2(3774.62, 4547.73),
			vector2(3771.21, 4535.23),
			vector2(3788.26, 4532.95),
			vector2(3796.97, 4530.68),
			vector2(3810.61, 4515.15),
			vector2(3824.24, 4489.39),
			vector2(3829.55, 4462.88),
			vector2(3833.71, 4453.79),
			vector2(3830.68, 4443.18),
			vector2(4115.15, 4429.55),
			vector2(4978.79, 4419.70),
			vector2(4977.27, 8250.00),
			vector2(1571.21, 8277.27)

		},
		['test_pier'] = {
			vector2(-3308.33, 967.80),
			vector2(-3241.67, 1327.65),
			vector2(-3184.47, 1440.15),
			vector2(-3068.56, 1514.02),
			vector2(-3034.09, 1559.09),
			vector2(-3123.86, 1634.85),
			vector2(-3181.06, 1700.38),
			vector2(-3182.58, 1781.82),
			vector2(-3142.05, 1843.56),
			vector2(-3112.50, 1854.55),
			vector2(-3091.29, 1885.23),
			vector2(-3068.56, 1887.50),
			vector2(-3106.82, 1953.79),
			vector2(-3036.74, 2236.36),
			vector2(-2958.71, 2240.91),
			vector2(-2939.02, 2276.52),
			vector2(-2875.76, 2260.23),
			vector2(-2788.64, 2393.94),
			vector2(-2783.33, 2533.71),
			vector2(-2748.86, 2782.95),
			vector2(-2737.50, 2965.53),
			vector2(-2758.33, 3016.29),
			vector2(-3023.11, 3241.29),
			vector2(-3110.23, 3236.74),
			vector2(-3159.85, 3262.50),
			vector2(-3092.05, 3360.61),
			vector2(-3110.98, 3401.14),
			vector2(-3036.36, 3433.33),
			vector2(-3062.88, 3489.39),
			vector2(-2918.94, 3557.58),
			vector2(-2833.71, 3576.14),
			vector2(-2786.36, 3565.53),
			vector2(-2659.47, 3553.79),
			vector2(-2603.79, 3592.80),
			vector2(-2541.67, 3800.38),
			vector2(-2546.21, 3900.76),
			vector2(-2487.12, 4046.97),
			vector2(-2496.97, 4146.59),
			vector2(-2405.30, 4328.79),
			vector2(-2277.65, 4454.92),
			vector2(-2213.64, 4557.58),
			vector2(-2183.33, 4604.55),
			vector2(-1949.24, 4577.27),
			vector2(-1835.98, 4690.91),
			vector2(-1868.18, 4785.23),
			vector2(-1730.30, 4923.11),
			vector2(-1770.08, 5035.98),
			vector2(-1778.03, 5051.89),
			vector2(-1757.20, 5071.59),
			vector2(-1770.08, 5095.45),
			vector2(-1696.59, 5081.44),
			vector2(-1698.11, 5107.20),
			vector2(-1617.42, 5098.11),
			vector2(-1596.97, 5174.62),
			vector2(-1569.32, 5183.33),
			vector2(-1540.53, 5163.64),
			vector2(-1533.33, 5212.88),
			vector2(-1476.89, 5214.39),
			vector2(-1428.79, 5187.88),
			vector2(-1395.08, 5239.77),
			vector2(-1395.45, 5338.26),
			vector2(-1365.15, 5366.67),
			vector2(-1151.89, 5386.36),
			vector2(-1050.76, 5505.68),
			vector2(-907.20, 5620.08),
			vector2(-915.91, 5736.36),
			vector2(-871.21, 5842.80),
			vector2(-864.39, 5877.65),
			vector2(-941.29, 6017.05),
			vector2(-990.15, 6221.21),
			vector2(-946.21, 6218.94),
			vector2(-854.17, 6065.15),
			vector2(-810.23, 6000.76),
			vector2(-764.77, 6015.91),
			vector2(-652.27, 6162.50),
			vector2(-640.15, 6307.95),
			vector2(-618.56, 6363.26),
			vector2(-470.08, 6449.62),
			vector2(-371.97, 6488.26),
			vector2(-286.36, 6564.77),
			vector2(-265.15, 6598.48),
			vector2(-263.64, 6648.48),
			vector2(-219.32, 6647.73),
			vector2(-145.45, 6701.89),
			vector2(-64.77, 6806.82),
			vector2(-31.44, 6893.94),
			vector2(-29.92, 6965.53),
			vector2(23.48, 7037.12),
			vector2(40.91, 7064.02),
			vector2(48.11, 7214.77),
			vector2(77.65, 7187.50),
			vector2(138.26, 7079.55),
			vector2(227.65, 7061.74),
			vector2(341.29, 6937.50),
			vector2(420.08, 6857.95),
			vector2(412.12, 6838.26),
			vector2(467.80, 6751.52),
			vector2(730.68, 6639.02),
			vector2(840.15, 6653.03),
			vector2(996.21, 6604.55),
			vector2(1070.83, 6614.02),
			vector2(1171.21, 6582.95),
			vector2(1337.50, 6616.67),
			vector2(1346.59, 6603.03),
			vector2(1371.59, 6614.02),
			vector2(1444.32, 6620.45),
			vector2(1462.12, 6613.64),
			vector2(1514.02, 6621.21),
			vector2(1576.52, 6659.47),
			vector2(1874.24, 8292.42),
			vector2(-3865.15, 8280.30),
			vector2(-3819.70, 959.85),
			vector2(-3421.21, 961.36),
			vector2(-3422.73, 979.17),
			vector2(-3400.00, 978.79),
			vector2(-3400.00, 967.05)
		},
		['area51'] = {
			vector2(1020.18, -2634.50),
			vector2(1247.52, -2676.91),
			vector2(1574.89, -2704.18),
			vector2(1865.88, -2628.44),
			vector2(2062.91, -2389.13),
			vector2(2250.85, -2113.46),
			vector2(2538.81, -2068.02),
			vector2(2629.75, -1871.11),
			vector2(2590.35, -1713.59),
			vector2(2514.57, -1601.50),
			vector2(2460.00, -1462.15),
			vector2(2444.85, -1340.98),
			vector2(2460.00, -1213.75),
			vector2(2563.06, -1134.99),
			vector2(2644.91, -1113.78),
			vector2(2611.56, -919.90),
			vector2(2735.65, -816.50),
			vector2(2781.12, -725.62),
			vector2(2750.81, -577.18),
			vector2(2839.75, -443.76),
			vector2(2788.22, -49.95),
			vector2(2709.41, 56.08),
			vector2(2763.97, 395.53),
			vector2(2824.59, 478.83),
			vector2(2865.51, 712.09),
			vector2(2862.48, 771.16),
			vector2(2812.47, 802.97),
			vector2(2771.55, 880.22),
			vector2(2745.78, 971.10),
			vector2(2726.08, 1054.41),
			vector2(2720.33, 1279.95),
			vector2(2777.93, 1428.39),
			vector2(2820.36, 1640.44),
			vector2(2862.80, 1840.38),
			vector2(2887.05, 2052.43),
			vector2(2971.92, 2194.81),
			vector2(3123.48, 2300.84),
			vector2(3320.51, 2721.91),
			vector2(3469.04, 2937.00),
			vector2(3602.27, 3150.24),
			vector2(3838.70, 3592.53),
			vector2(3720.40, 3714.04),
			vector2(3705.24, 3823.10),
			vector2(3811.33, 3968.51),
			vector2(3884.08, 4059.39),
			vector2(3811.33, 4247.21),
			vector2(3735.55, 4435.03),
			vector2(3690.09, 4571.35),
			vector2(3490.03, 4734.93),
			vector2(3383.94, 4965.16),
			vector2(3283.89, 5107.84),
			vector2(3232.36, 5232.04),
			vector2(3186.89, 5298.69),
			vector2(3174.76, 5383.51),
			vector2(3326.32, 5441.07),
			vector2(3344.51, 5550.12),
			vector2(3286.92, 5692.50),
			vector2(3251.16, 5959.84),
			vector2(3166.29, 6141.60),
			vector2(3135.98, 6244.60),
			vector2(4627.32, 6359.71),
			vector2(4472.99, 2795.72),
			vector2(4448.75, -1227.24),
			vector2(2872.53, -3553.76),
			vector2(1408.39, -3670.64),
			vector2(1372.02, -2901.19),
			vector2(974.42, -2801.44)
		},
		['dead_sea'] = {
			vector2(-1208.33, -1843.18),
			vector2(-1421.97, -1480.30),
			vector2(-1509.09, -1204.17),
			vector2(-1660.23, -1044.70),
			vector2(-1798.48, -867.80),
			vector2(-1942.80, -690.15),
			vector2(-3125.76, -1295.45),
			vector2(-2301.52, -2277.27)
		},
	},
}
-- Enable this to enable the polyzones debug mode
Config.debug_polyzones = false

Config.create_table = true