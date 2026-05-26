fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'TommyNguyenx'
description 'tommy-militaryscrap - Military Scrap Farming System'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/server.lua'
}

dependencies {
    'qbx_core',
    'ox_lib',
    'ox_target',
    'ox_inventory'
}