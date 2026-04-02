fx_version 'cerulean'
game 'gta5'
author 'atiysu'
lua54 'yes'

shared_scripts {
    'config.lua',
    'locales.lua',
    'locales/*.lua',
    '@ox_lib/init.lua',
}

client_scripts {
    'client/utils.lua',
    'client/nui.lua',
    'client/events.lua',
    'client/headshot.lua',
    'client/main.lua',
}

server_scripts {
    'server/utils.lua',
    'server/open.lua',
    'server/nationalities.lua',
    'server/events.lua',
    'server/callbacks.lua',
}

ui_page 'ui/index.html'

files {
    'ui/*.*',
    'ui/**/*.*',
}

escrow_ignore{
    'config.lua',
    'locales.lua',
    'locales/*.lua',
    'client/utils.lua',
    'client/nui.lua',
    'client/events.lua',
    'client/headshot.lua',
    'client/main.lua',
    'server/open.lua',
    'server/nationalities.lua',
    'server/utils.lua',
    'server/events.lua',
    'server/callbacks.lua',
}
dependency '/assetpacks'
dependency '/assetpacks'