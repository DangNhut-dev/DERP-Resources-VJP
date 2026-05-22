fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'DE-Team'
description 'Gagares Nâng Cao Tích Hợp DB-backed'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    'shared/config.lua',
    'shared/streaming_config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/streaming.lua',
    -- 'server/debug_trace_sv.lua'
}

client_scripts {
    'client/main.lua',
    -- 'client/debug_trace.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/admin.css',
    'html/admin.js'
}

lua54 'yes'

