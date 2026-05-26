fx_version 'cerulean'
game 'gta5'

name 'giaopizza'
description 'Giao Pizza Job'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
}

dependencies {
    'ox_lib',
    'ox_target',
    'ox_inventory',
    'qbx_core',
    'qbx_vehiclekeys',
}