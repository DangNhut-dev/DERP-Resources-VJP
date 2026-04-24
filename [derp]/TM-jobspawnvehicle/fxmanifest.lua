fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'TommyNguyenx'
description 'Job Spawn Vehicle - NPC spawn vehicle by job (Qbox + ox)'
version '1.0.0'

shared_script {
    '@ox_lib/init.lua',
    'config.lua',
}

client_script 'client.lua'

server_script 'server.lua'

dependencies {
    'qbx_core',
    'ox_lib',
    'ox_target',
    'qbx_vehiclekeys',
}