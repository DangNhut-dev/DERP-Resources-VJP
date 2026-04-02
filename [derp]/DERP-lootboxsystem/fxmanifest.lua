fx_version 'cerulean'
game 'gta5'

author 'DE-Team'
description 'DERP Lootbox System'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'config_shop.lua'
}

client_scripts {
    'client/client.lua',
    'client/client_shop.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
    'server/server_shop.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/shop.css',
    'html/shop.js',
    'html/assets/*.mp3'
}