fx_version 'cerulean'
game 'gta5'
version '1.0.1'
lua54 'yes'
author '36giqz|https://github.com/36fg'
escrow_ignore {
  'shared/cfg.lua',
  'shared/locales.lua',
  'Locales/*.lua',
  'modules/bridge/esx/client.lua',
  'modules/bridge/esx/server.lua',
  'modules/bridge/qb/client.lua',
  'modules/bridge/qb/server.lua',
  'modules/bridge/qbox/client.lua',
  'modules/bridge/qbox/server.lua'
}
shared_scripts {
  'shared/locales.lua',
  'Locales/*.lua',
  'shared/cfg.lua',
  '@ox_lib/init.lua',
}
client_scripts {
  'modules/bridge/esx/client.lua',
  'modules/bridge/qbox/client.lua',
  'modules/bridge/qb/client.lua',
  'modules/client/main.lua',
  'modules/client/functions.lua',
  'modules/client/cam.lua',
  'modules/client/nui.lua',
}
server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'modules/bridge/esx/server.lua',
  'modules/bridge/qbox/server.lua',
  'modules/bridge/qb/server.lua',
  'modules/server/main.lua'
}
files { 'web/dist/index.html', 'web/dist/**/*', }
ui_page 'web/dist/index.html'
dependency '/assetpacks'

