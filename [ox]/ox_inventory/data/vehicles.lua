return {
	-- 0	vehicle has no storage
	-- 1	vehicle has no trunk storage
	-- 2	vehicle has no glovebox storage
	-- 3	vehicle has trunk in the hood
	Storage = {
		[`jester`] = 3,
		[`adder`] = 3,
		[`osiris`] = 1,
		[`pfister811`] = 1,
		[`penetrator`] = 1,
		[`autarch`] = 1,
		[`bullet`] = 1,
		[`cheetah`] = 1,
		[`cyclone`] = 1,
		[`voltic`] = 1,
		[`reaper`] = 3,
		[`entityxf`] = 1,
		[`t20`] = 1,
		[`taipan`] = 1,
		[`tezeract`] = 1,
		[`torero`] = 3,
		[`turismor`] = 1,
		[`fmj`] = 1,
		[`infernus`] = 1,
		[`italigtb`] = 3,
		[`italigtb2`] = 3,
		[`nero2`] = 1,
		[`vacca`] = 3,
		[`vagner`] = 1,
		[`visione`] = 1,
		[`prototipo`] = 1,
		[`zentorno`] = 1,
		[`trophytruck`] = 0,
		[`trophytruck2`] = 0,
	},

	-- slots, maxWeight; default weight is 8000 per slot
	glovebox = {
		[0] = {5, 10000},		-- Compact
		[1] = {5, 10000},		-- Sedan
		[2] = {5, 10000},		-- SUV
		[3] = {5, 10000},		-- Coupe
		[4] = {5, 10000},		-- Muscle
		[5] = {5, 10000},		-- Sports Classic
		[6] = {5, 10000},		-- Sports
		[7] = {5, 10000},		-- Super
		[8] = {5, 10000},		-- Motorcycle
		[9] = {5, 10000},		-- Offroad
		[10] = {5, 10000},		-- Industrial
		[11] = {5, 10000},		-- Utility
		[12] = {5, 10000},		-- Van
		[14] = {5, 10000},		-- Boat
		[15] = {5, 10000},		-- Helicopter
		[16] = {5, 10000},		-- Plane
		[17] = {5, 10000},		-- Service
		[18] = {5, 10000},		-- Emergency
		[19] = {5, 10000},		-- Military
		[20] = {5, 10000},		-- Commercial (trucks)
		models = {
			[`xa21`] = {5, 10000}
		}
	},

	trunk = {
		[0] = {15, 50000},			-- Compact
		[1] = {15, 50000},			-- Sedan
		[2] = {15, 50000},			-- SUV
		[3] = {15, 50000},			-- Coupe
		[4] = {15, 50000},			-- Muscle
		[5] = {15, 50000},			-- Sports Classic
		[6] = {15, 50000},			-- Sports
		[7] = {15, 50000},			-- Super
		[8] = {15, 50000},			-- Motorcycle
		[9] = {15, 50000},			-- Offroad
		[10] = {15, 50000},		-- Industrial
		[11] = {15, 50000},		-- Utility
		[12] = {15, 50000},		-- Van
		-- [14] -- Boat
		-- [15] -- Helicopter
		-- [16] -- Plane
		[17] = {15, 50000},		-- Service
		[18] = {15, 50000},		-- Emergency
		[19] = {15, 50000},		-- Military
		[20] = {15, 50000},		-- Commercial
		models = {
			[`npolciv`] = {20, 200000},
			[`clrgtaurus`] = {20, 200000},
			[`npolmm`] = {20, 200000},
			[`npolchal`] = {20, 200000},
			[`npolstang`] = {20, 200000},
			[`npolexp`] = {20, 200000},
			[`npolvette`] = {20, 200000},
			[`npolchar`] = {20, 200000},
			[`bison`] = {50, 150000},
			[`riata`] = {50, 120000},
			[`sandking`] = {50, 300000},
		},
	}
}
