fx_version 'cerulean'
game 'gta5'

name        'DERP-business'
author      'LeOtis'
description 'Food & Beverage Business System'
version     '1.0.0'
lua54       'yes'

ui_page 'html/index.html'

files {
    'html/index.html'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'modules/zones.lua',
    'modules/duty.lua',
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'modules/crafting.lua',
    'server.lua'
}

dependencies {
    'ox_lib',
    'ox_inventory',
    'ox_target',
    'oxmysql',
    'qbx_core'
}