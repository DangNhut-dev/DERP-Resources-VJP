fx_version 'cerulean'
game 'gta5'

author 'Tommy Trucker Development'
description 'QBX Trucking Job - Box Truck Version'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'locales/vi.lua',
    'config/config.lua'
}

client_scripts {
    'client/main.lua',
    'client/target.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

dependencies {
    'qbx_core',
    'ox_lib',
    'ox_target',
    'ox_inventory',
    'oxmysql'
}

lua54 'yes'