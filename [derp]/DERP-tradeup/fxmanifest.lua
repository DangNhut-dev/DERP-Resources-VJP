fx_version 'cerulean'
game 'gta5'

name        'DERP-tradeup'
author      'DE-Team'
description 'Trade-Up Contract System (9 same-rarity -> 1 next-tier)'
version     '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
}

lua54 'yes'
