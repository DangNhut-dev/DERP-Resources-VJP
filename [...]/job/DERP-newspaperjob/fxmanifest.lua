fx_version 'cerulean'
game 'gta5'

name 'DERP-newpaperjob'
author 'OtisLeo'
description 'Newspaper Delivery Job'
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

dependencies {
    'ox_lib',
    'ox_target',
    'qbx_core',
}
