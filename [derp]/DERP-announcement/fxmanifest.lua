fx_version 'cerulean'
game 'gta5'

name 'DERP-announcement'
description 'Custom Announcement System'
version '1.0.0'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/sounds/*.mp3',
    'html/assets/*.png'
}

dependencies {
    'ox_lib',
    'qbx_core'
}
