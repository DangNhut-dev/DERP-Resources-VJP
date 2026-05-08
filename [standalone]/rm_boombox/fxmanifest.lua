fx_version 'cerulean'
game "gta5"

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua'
}

server_scripts {
    'bridge/frameworks/server/*.lua',
    'server/*.lua',
}

client_scripts {
    '@rm_stream/client.lua',
    'bridge/frameworks/client/*.lua',
    'bridge/targets/*.lua',
    'client/*.lua',
}

dependency 'oxmysql'

dependencies {
    'rm_stream',
    'oxmysql',
    'ox_lib',
}

ui_page "web/dist/index.html"

files {
    "web/dist/*.html",
    'web/dist/*.*',
    'web/dist/assets/*.*',
}

escrow_ignore {
    'assets/[items]/*.*',
    'shared/*.*',
    'bridge/frameworks/client/*.lua',
    'bridge/frameworks/server/*.lua',
    'bridge/targets/*.lua',
    'server/editable_functions.lua',
}