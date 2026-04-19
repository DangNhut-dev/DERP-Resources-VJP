fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'derp-blackphone'
author 'DERP'
description 'Black Phone - Modular App System'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/apps.lua'
}

client_scripts {
    'client/main.lua',
    'client/nui.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/*.css',
    'html/js/*.js',
    'html/img/*.png',
    'html/img/*.jpg',
    'html/img/*.svg'
}

dependencies {
    'qbx_core',
    'ox_lib',
    'ox_inventory'
}