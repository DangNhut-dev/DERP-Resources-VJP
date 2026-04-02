fx_version 'cerulean'
game 'gta5'

name 'DERP-megaphone'
author 'DERP'
description 'Megaphone resource - QBX'
version '1.0.0'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

client_scripts {
    'client/functions.lua',
    'client/megaphone.lua',
    'client/microphones.lua'
}

server_scripts {
    'server/main.lua',
}

dependencies {
    'ox_lib',
    'ox_target',
    'qbx_core',
    'pma-voice'
}
