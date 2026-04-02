fx_version 'cerulean'
games { 'gta5' }

author 'DERP'
description 'Police Vehicle Shop - Mua xe cho cảnh sát'

client_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'client/*.lua'
}

server_scripts {
    '@ox_lib/init.lua',
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'server/*.lua'
}

-- Dependencies
dependency 'oxmysql'
dependency 'qbx_core'
dependency 'ox_target'
dependency 'ox_lib'
