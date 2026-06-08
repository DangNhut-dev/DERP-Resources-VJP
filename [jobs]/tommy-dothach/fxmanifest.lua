fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'tommy-dothach'
description 'Do Thach - Stone Grinding & Cutting System'
version '1.0.0'

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
}

dependencies {
    'ox_lib',
    'ox_inventory',
    'ox_target',
}
