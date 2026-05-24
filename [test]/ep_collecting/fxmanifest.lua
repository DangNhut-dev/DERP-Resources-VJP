fx_version   'cerulean'
lua54        'yes'
game         'gta5'

author 'EP'
description 'Collector Zones'

shared_scripts {
	'@ox_lib/init.lua',
	'shared/*.lua',
}

client_scripts {
	"client/*.lua",
}

dependencies {
	'ox_lib',
	'ox_target',
	'/server:6116',
    '/assetpacks',
}

escrow_ignore {
	"client/*.lua",
	"shared/*.lua",
	'stream/*.ydr',
    'stream/*.ytd',
}

files {
    'stream/ep_plants.ytyp',
    'stream/ytyp/np_farming_arch.ytyp'
}

data_file 'DLC_ITYP_REQUEST' 'stream/ep_plants.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/ytyp/np_farming_arch.ytyp'
dependency '/assetpacks'