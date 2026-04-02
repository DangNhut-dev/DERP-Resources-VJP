fx_version 'cerulean'
game 'gta5'

name 'DERP-policegunrack'
author 'DE-Team'
description 'Police Vehicle Gun Rack System'
version '2.3.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

client_scripts {
    'client.lua'
}

dependencies {
    'ox_lib',
    'ox_inventory',
    'qbx_core',
    'qbx_radialmenu',
}

lua54 'yes'