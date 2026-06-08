fx_version 'cerulean'
game 'gta5'
author 'LixeiroCharmoso'

ui_page "nui/ui.html"

lua54 'yes'

escrow_ignore {
	'config.lua',
	'client.lua',
	'client-fishing.lua',
	'server_utils.lua',
	'lang/*.lua',
}

client_scripts {
	"client.lua",
	"client-fishing.lua",
}

server_scripts {
	"@mysql-async/lib/MySQL.lua",
	"server_utils.lua",
	"server.lua",
}

shared_scripts {
	'@ox_lib/init.lua',
	'@PolyZone/client.lua',
	"lang/*.lua",
	"config.lua",
	"@lc_utils/functions/loader.lua",
}

files {
	"nui/lang/*",
	"nui/ui.html",
	"nui/panel.js",
	"nui/css/*",
	"nui/images/*",
	"nui/images/**",
}

dependency "lc_utils"
dependency '/assetpacks'