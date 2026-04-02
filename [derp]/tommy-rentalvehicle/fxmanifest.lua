fx_version 'cerulean'
game 'gta5'

description 'Thuê Xe Cơ Bản'
author 'TommyNguyenx'
version '1.0.0'

client_script 'client/main.lua'
shared_scripts {
    '@ox_lib/init.lua',
    '@qb-core/shared/locale.lua',
    'locales/*.lua',
    'config.lua',
}
files {
    'images/*.png',
}
server_script 'server/main.lua'