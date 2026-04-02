fx_version 'cerulean'
game 'gta5'

name 'DERP-applyskinbackpack'
description 'Apply skin/texture to backpack item'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
}

client_scripts {
    'config.lua',
    'client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'server.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
}

lua54 'yes'
