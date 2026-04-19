return {
	{
		coords = vec3(91.52, -406.70, 46.31),
		target = {
			loc = vec3(91.52, -406.70, 46.31),
			length = 1.2,
			width = 5.6,
			heading = 0,
			minZ = 29.49,
			maxZ = 32.09,
			label = 'Tủ Boss'
		},
		name = 'Tủ Boss',
		label = 'Tủ Boss',
		owner = false,
		slots = 25,
		weight = 100000,
		groups = {['police'] = 7}
	},

	{
		coords = vec3(79.59, -389.10, 40.62),
		target = {
			loc = vec3(79.59, -389.10, 40.62),
			length = 1.2,
			width = 5.6,
			heading = 0,
			minZ = 29.49,
			maxZ = 32.09,
			label = 'Tủ Cá Nhân'
		},
		name = 'Tủ Cá Nhân',
		label = 'Tủ Cá Nhân',
		owner = true,
		slots = 20,
		weight = 70000,
		groups = {['police'] = 0}
	},

	{
		coords = vec3(76.42, -410.43, 40.62),
		target = {
			loc = vec3(76.42, -410.43, 40.62),
			length = 1.2,
			width = 5.6,
			heading = 0,
			minZ = 29.49,
			maxZ = 32.09,
			label = 'Evidence'
		},
		name = 'Evidence',
		label = 'Tủ Evidence',
		owner = false,
		slots = 500,
		weight = 1000000,
		groups = {['police'] = 6}
	},

	{
		coords = vec3(-481.45, -1015.99, 33.69),
		target = {
			loc = vec3(-481.45, -1015.99, 33.69),
			length = 1.2,
			width = 5.6,
			heading = 0,
			minZ = 29.49,
			maxZ = 32.09,
			label = 'Tủ Kho'
		},
		name = 'Tủ Kho',
		label = 'Tủ Kho',
		owner = false,
		slots = 50,
		weight = 200000,
		groups = {['police'] = 2}
	},

	{
		coords = vec3(-351.17, -164.52, 38.79),
		target = {
			loc = vec3(-351.17, -164.52, 38.79),
			length = 0.6,
			width = 1.8,
			heading = 340,
			minZ = 43.34,
			maxZ = 44.74,
			label = 'Mở Tủ'
		},
		name = 'mechaniclocker1',
		label = 'Tủ Kho',
		owner = false,
		slots = 50,
		weight = 200000,
		groups = {['mechanic'] = 1}
	},

	{
		coords = vec3(-348.59, -158.04, 38.79),
		target = {
			loc = vec3(-348.59, -158.04, 38.79),
			length = 0.6,
			width = 1.8,
			heading = 340,
			minZ = 43.34,
			maxZ = 44.74,
			label = 'Mở Tủ'
		},
		name = 'mechaniclocker2',
		label = 'Tủ Kho',
		owner = false,
		slots = 50,
		weight = 100000,
		groups = {['mechanic'] = 1}
	},

	{
		coords = vec3(-2242.99, -390.21, 12.52),
		target = {
			loc = vec3(-2242.99, -390.21, 12.52),
			length = 0.6,
			width = 1.8,
			heading = 340,
			minZ = 43.34,
			maxZ = 44.74,
			label = 'Mở Tủ'
		},
		name = 'cardealerlocker',
		label = 'Tủ Kho',
		owner = false,
		slots = 50,
		weight = 100000,
		groups = {['cardealer'] = 1}
	},

	{
		coords = vec3(1385.91, 1139.01, 113.33),
		target = {
			loc = vec3(1385.91, 1139.01, 113.33),
			length = 0.6,
			width = 1.8,
			heading = 340,
			minZ = 43.34,
			maxZ = 44.74,
			label = 'Mở Tủ'
		},
		name = 'whitedealer',
		label = 'Tủ Kho',
		owner = false,
		slots = 100,
		weight = 500000,
		groups = {['dealer'] = 1}
	},
}
