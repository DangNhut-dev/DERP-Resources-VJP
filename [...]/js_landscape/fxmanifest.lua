fx_version 'cerulean'
game 'gta5'

use_experimental_fxv2_oal 'yes'
lua54 'yes'

author 'Caps'
description 'Landscape Multiplayer Job'
version '1.1.2'

shared_scripts {
    'shared/translations/shared.lua',

    'shared/translations/tr.lua',
    'shared/translations/pl.lua',
    'shared/translations/en.lua',
    'shared/translations/de.lua',
    'shared/translations/es.lua',
    'shared/translations/fr.lua',

    'config.lua',
}

client_scripts {
    "callbacks/client.lua",
    'client/editable.lua',
    'client/framework.lua',
    'client/functions.lua',
    'client/job.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',

    'license_config.lua',
    "callbacks/server.lua",
    'server/editable.lua',
    'server/framework.lua',
    'server/job.lua',
    --'server/version.lua',
}

ui_page {'web/build/index.html'}

files {
	'web/build/index.html',
	'web/build/**/*',

}

escrow_ignore {

    'shared/translations/shared.lua',

    'shared/translations/tr.lua',
    'shared/translations/pl.lua',
    'shared/translations/en.lua',
    'shared/translations/de.lua',
    'shared/translations/es.lua',
    'shared/translations/fr.lua',

    'config.lua',
    'license_config.lua',

}

dependency '/assetpacks'
dependency '/assetpacks'
dependency '/assetpacks'