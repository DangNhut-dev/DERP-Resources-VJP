fx_version 'cerulean'
game 'gta5'

author 'DE-Team'
description 'NPC Auto Fix Vehicle'
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
