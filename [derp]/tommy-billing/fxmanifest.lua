fx_version 'cerulean'
game 'gta5'

author 'TommyNguyenx'
description 'Advanced Billing System for QB-Core with History & Auto-pay'
version '3.0.0'

shared_scripts {
    '@ox_lib/init.lua',  
    'config.lua',
}
client_script 'client/main.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'html/ui.html'

files {
    'html/ui.html'
}

lua54 'yes'