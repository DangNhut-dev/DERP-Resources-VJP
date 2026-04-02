fx_version 'cerulean'
games {'gta5'}

author "DE-Team"

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/shared.lua',
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/CircleZone.lua',
    'client/functions.lua',
    'client/cl_main.lua',
    'client/cl_shop.lua',
    'client/cl_group.lua',
    'client/blacklistweapon.lua',
}

server_scripts {
    'server/sv_main.lua',
    'server/sv_shop.lua',
    'server/sv_zone_spawn.lua',
    'server/sv_group.lua',
    'server/sv_blacklistweapon.lua',
}

dependencies {
    'ox_lib',
    'ox_inventory',
    'ox_target',
    'qbx_core',
    'PolyZone',
}