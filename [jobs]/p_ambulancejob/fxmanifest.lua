fx_version 'cerulean'
game 'gta5'
author 'pScripts [tebex.pscripts.store]'
description 'Advanced Ambulance Job v2'
lua54 'yes'
version '2.2.2'

ui_page 'web/build/index.html'

client_script "client/**/*"
server_scripts {
	'@oxmysql/lib/MySQL.lua',
	"server/**/*",
	'shared/server.lua'
}

shared_scripts {
	'@ox_lib/init.lua',
	'shared/config.lua'
}

files {
	'web/build/index.html',
	'web/build/**/*',
	'web/sounds/*.wav',
	'web/sounds/*.mp3',
	'web/sounds/*.ogg',
	'web/tv.html',
	'web/ecg.html',
  	'locales/*.json',
	'web/assets/*.png',
	'stream/**',
	'hospitals/*.lua',
}

dependencies {
	'ox_lib',
	'p_bridge'
}

escrow_ignore {
	'hospitals/*.lua',
	'shared/config.lua',
	'shared/server.lua',
	'server/editable_functions.lua',
	'client/editable_functions.lua',
	'server/check-in.lua',
	'stream/*.ycd',
	'stream/*.ytyp',
	'stream/*.ydr',
	'stream/*.ytd',
}

-- Author of Prop [https://mads.tebex.io/]
data_file 'DLC_ITYP_REQUEST' 'stream/mads.ytyp'

-- Author of Prop [https://www.gta5-mods.com/tools/medical-prop-pack]
data_file 'DLC_ITYP_REQUEST' 'stream/ems_props.ytyp'

-- CREDITS https://www.gta5-mods.com/vehicles/wheelchair-add-on-sp-fivem
data_file 'HANDLING_FILE' 'stream/data/handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'stream/data/vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE' 'stream/data/carvariations.meta'
dependency '/assetpacks'