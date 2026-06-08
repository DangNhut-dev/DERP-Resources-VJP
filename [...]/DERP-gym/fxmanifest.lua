fx_version 'cerulean'
games {'gta5'}
lua54 'yes'
                                              
author 'Keres & Dév'
description 'Brutal GYM & SKILLS [V2] - store.derpscripts.com'
version '2.6.0'

client_scripts { 
    "@ox_lib/init.lua",
    "config.lua",
    "core/client-core.lua",
    "client/*.lua",
    "gym-cl_utils.lua",
    "skills-cl_utils.lua"
}

server_scripts { 
	"@mysql-async/lib/MySQL.lua",
	"config.lua",
	"core/server-core.lua",
	"server/*.lua"
}

export 'gymDoExercises'

ui_page "html/index.html"

files {
	"html/index.html",
	"html/style.css",
	"html/script.js",
}

escrow_ignore {
	'config.lua',
	'core/client-core.lua', 
	'core/server-core.lua', 
	'gym-cl_utils.lua',
	'skills-cl_utils.lua'
}
