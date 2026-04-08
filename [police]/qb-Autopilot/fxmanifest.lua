fx_version 'bodacious'
games { 'gta5' }
lua54 'yes'

author "John Walker"
description "Auto Pilot for all Car"
version '1.0'

shared_script {
    '@ox_lib/init.lua',
}

client_scripts {
    'config.lua',
    'client.lua'
} 

server_scripts {
    'server.lua'
}