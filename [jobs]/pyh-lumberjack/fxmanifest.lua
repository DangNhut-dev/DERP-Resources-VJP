fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Forlax'
name 'pyh-lumberjack'
description 'Lumberjack 4.0'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
}

client_scripts {
    'client/core.lua',
    'client/main.lua',
}

server_scripts {
    'server/core.lua',
    'server/**.lua',
}

dependencies {
    'ox_lib',
    'ox_inventory',
    'ox_target',
    'qbx_core',
}

escrow_ignore {
    'shared/**',
    'server/**',
    'client/**',
}