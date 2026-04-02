fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'DE-Team'
description 'Được build bởi team DERP'
version '1.0.0'

shared_scripts {
    'shared/config.lua',
    'shared/translations.lua',
}

client_script {
    'client/functions.lua',
    'client/main.lua',
}

server_script {
    'server/main.lua',
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/styles/styles.css',
    'ui/script.js',
    'ui/images/*.png',
}