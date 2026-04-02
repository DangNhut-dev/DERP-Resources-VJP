fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'
name 'ox_inventory'
author 'Rebuild by TommyNguyenx'
version '2.44.1'
repository 'https://github.com/overextended/ox_inventory'
description 'Inventory tích hợp clothing_item và nhiều thứ'

dependencies {
    '/server:6116',
    '/onesync',
    'oxmysql',
    'ox_lib',
}

shared_script '@ox_lib/init.lua'

ox_libs {
    'locale',
    'table',
    'math',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'init.lua'
}

client_script 'init.lua'

ui_page 'web/build/index.html'

files {
    'client.lua',
    'server.lua',
    'locales/*.json',
    'web/build/index.html',
    'web/build/assets/*.js',
    'web/build/assets/*.css',
    'web/build/assets/icons/svg/*.svg',
    'web/images/*.png',
    'web/clothes/*.png',
    'web/public/*.*',
    'modules/**/shared.lua',
    'modules/**/client.lua',
    'modules/**/server.lua',
    'modules/**/backpack_shared.lua',
    'modules/**/backpack_client.lua',
    'modules/**/backpack_server.lua',
    'modules/**/glove_admin_client.lua',
    'modules/**/glove_admin.lua',
    'modules/bridge/**/client.lua',
    'data/*.lua',
}