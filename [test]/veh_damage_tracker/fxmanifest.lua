fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'debug'
description 'Track unexpected vehicle damage on streamed garage vehicles'
version '1.0.1'

shared_script 'config.lua'

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
}