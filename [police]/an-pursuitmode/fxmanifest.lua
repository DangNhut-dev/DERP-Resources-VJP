fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Lenix <https://github.com/LenixDev>'
description 'Patrol System: Garage, Mic, Modes'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua',
    'option/*.lua',
}

client_scripts {
    'client/**/*.lua',
}

dependencies {
    'ox_lib',
    'qbx_core',
}