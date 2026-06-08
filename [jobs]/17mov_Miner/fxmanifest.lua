fx_version "cerulean"
version "1.0.31"
game "gta5"
lua54 'yes'
this_is_a_map 'yes'

shared_script "Config.lua"

server_scripts {
    "server/functions.lua",
    "server/core.lua",
    "server/server.lua",
}

client_scripts {
    "client/functions.lua",
    "client/core.lua",
    "client/client.lua",
    "client/target.lua",
}

ui_page "web/index.html"

files {
    "web/index.html",
    "web/assets/**/*.*",
}

escrow_ignore {
    "Config.lua",
    "client/target.lua",
    "client/functions.lua",
    "server/functions.lua",
}