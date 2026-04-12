fx_version 'cerulean'
game 'gta5'
description ''
author 'KzO Exclusives'

client_scripts {
    '@ox_lib/init.lua',
    'client.lua'
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@ox_lib/init.lua',
    'server.lua'
}

dependencies {
    'oxmysql',
    'ox_lib',
    'ox_inventory',
    'qbx_core',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'html/imgs/*.png',
    'html/button.wav',
    'html/fonts/*.otf'
}

lua54 'yes'