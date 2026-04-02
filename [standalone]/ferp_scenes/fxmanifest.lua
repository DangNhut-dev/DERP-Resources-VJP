fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Ferp.Dev'
description 'Advanced Scene System'
version '1.0.0'

files {
    'locale/*.json',
    'stream/*'
}

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    'shared/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

dependencies {
    'ox_lib',
    'ox_target',
    'qbx_core',
    'oxmysql'
}