fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'derp-weedshop'
author 'DERP'
description 'Green Market - Weed Dealer App'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/npcs.lua',
    'shared/locations.lua',
    'shared/utils.lua'
}

client_scripts {
    'client/main.lua',
    'client/npc.lua',
    'client/app.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/relationship.lua',
    'server/customers.lua',
    'server/orders.lua',
    'server/scheduler.lua'
}

files {
    'html/app.html',
    'html/css/*.css',
    'html/js/*.js'
}

dependencies {
    'qbx_core',
    'ox_lib',
    'ox_inventory',
    'oxmysql',
    'DERP-blackphone'
}
