fx_version 'cerulean'
game 'gta5'

description 'DERP-crimecamera - Crime Scene Camera for Police'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
}

lua54 'yes'