
fx_version "cerulean"
games { "gta5" }
lua54 "yes"

author "Prodigy Studios"
version "1.0.0"

shared_scripts {
    "@ox_lib/init.lua",
    "@prp-bridge/import.lua",
    "config/client.lua",
    "shared/**/*.lua"
}

escrow_ignore {
    "server/**/*.lua",
    "config/**/*.lua",
    "shared/**/*.lua"
}

client_scripts {
    "client/**/*.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "config/server.lua",
    "server/**/*.lua"
}

files {
    "locales/*.json"
}

-- dependency '/assetpacks'
