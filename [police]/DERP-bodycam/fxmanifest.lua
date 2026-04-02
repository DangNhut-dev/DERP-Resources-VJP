fx_version "cerulean"
game "gta5"
lua54 "yes"

escrow_ignore {
    "config.lua",
    "server_hook.lua",
}

-- Shared script để cả client và server đều load config
shared_script "config.lua"

client_scripts {
    "client.lua",
}

server_scripts {
    "server_hook.lua",
    "server_main.lua",
}

-- Nếu bạn cần load JSON file
server_script "videopatch.json"

ui_page "ui/index.html"

files {
    "ui/index.html",
    "ui/cas.js",
    "ui/style.css",
    "ui/key.png",
    "ui/lspdlogo.png",
    "ui/recordcalendar.png",
    "ui/chevron-left.png",
    "ui/chevron-right.png",
    "ui/Satoshi-Bold.otf",
    "ui/Satoshi-Regular.otf",
    "ui/calendar.png",
    "ui/yes.png",
    "ui/*.png",
    "ui/*.js",
    "ui/*.css"
}