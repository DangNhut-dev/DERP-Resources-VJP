fx_version 'cerulean'
game 'gta5'

author 'TommyNguyenx'
description 'Mua Bán Items với ped có UI'
version '1.0.0'

shared_script 
{
    'config.lua',
    '@ox_lib/init.lua'
}

server_scripts {
    '@qb-core/shared/locale.lua',
    'server.lua'
}

client_scripts {
    'client.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/assets/myLogo.png',
}