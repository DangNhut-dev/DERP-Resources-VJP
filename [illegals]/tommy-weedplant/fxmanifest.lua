fx_version 'cerulean'
game 'gta5'

author 'TommyNguyenx'
description 'Cannabis Growing & Drying System'
version '2.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/main.lua',
    'client/client_drying.lua',
    'client/client_infusion.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/server_drying.lua',
    'server/server_infusion.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/nui-wrapper.js',
}

dependencies {
    'qbx_core',
    'ox_target',
    'ox_inventory',
    'ox_lib',
    'oxmysql',
}

lua54 'yes'