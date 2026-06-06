fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'CodeNest'
description 'Orbit Dev Chopshop / Scrapyard Script - Converted to QBX'
version '1.1.1'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    'config.lua',
}

client_scripts {
    'client/cl_main.lua',
    'client/cl_animations.lua',
    'client/cl_parts.lua',
    'client/target.lua',
}

server_scripts {
    'server/sv_main.lua',
}