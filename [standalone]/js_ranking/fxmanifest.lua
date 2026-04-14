fx_version 'cerulean'
game 'gta5'

name 'js_ranking'
author 'js_ranking by JamesSs'
description 'admin ranking'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'license_config.lua',
    'server/main.lua'
}

ui_page 'web/dist/index.html'

files {
    'web/dist/**/*'
}

escrow_ignore {
    'config.lua',
    'license_config.lua',
    'locales/*.lua',
    'web/**',
    'README.md'
}

dependency '/assetpacks'