fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'MrMRVLS'
description 'Simple crosshair.'
version '1.1.0'

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'client/*.lua'
}

ui_page 'ui/index.html'

files {
    'ui/crosshair.png',
    'ui/index.html',
    'ui/script.js',
    'ui/style.css'
}