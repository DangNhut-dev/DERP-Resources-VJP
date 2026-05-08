fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

author 'KuzQuality | Kuzkay'
description 'Power Washing Job by KuzQuality'
version '1.0.0'

data_file 'DLC_ITYP_REQUEST' 'stream/kq_powerwashing.ytyp'

data_file 'WEAPON_METADATA_FILE' 'data/weaponarchetypes.meta'
data_file 'WEAPON_ANIMATIONS_FILE' 'data/weaponanimations.meta'
data_file 'WEAPONINFO_FILE' 'data/weapon.meta'

data_file 'CARCOLS_FILE' 'data/carcols.meta'
data_file 'DLCTEXT_FILE' 'data/dlctext.meta'
data_file 'HANDLING_FILE' 'data/handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/carvariations.meta'

dependencies {
    'kq_jobcontracts',
    'kq_link'
}

shared_scripts {
    'config.lua',
    'shared/settings.lua',
    'contracts.lua',
    'shared/utils.lua',
    'shared/cache.lua',
    'shared/locale.lua',
    'shared/shared.lua',
}

client_scripts {
    'client/utils.lua',
    'client/functions.lua',
    'client/utils/perlin.lua',
    'client/wash/backpackManager.lua',
    'client/wash/washProximity.lua',
    'client/wash/washRenderer.lua',
    'client/wash/waterTank.lua',
    'client/wash/washCleaner.lua',
    'client/headquartersNpc.lua',
    'client/outfitManager.lua',
    'client/taskTypes.lua',
    'client/editable/editable.lua',
    'client/editable/debug.lua',
    'client/client.lua',
}

server_scripts {
    'server/editable/editable.lua',
    'server/editable/debug.lua',
    'server/classes/washArea.lua',
    'server/washManager.lua',
    'server/taskTypes.lua',
    'server/functions.lua',
    'server/server.lua',
}

files {
    'data/weaponarchetypes.meta',
    'data/weaponanimations.meta',
    'data/weapon.meta',
    'locales/*.json',

    'data/carcols.meta',
    'data/dlctext.meta',
    'data/vehicles.meta',
    'data/handling.meta',
    'data/carvariations.meta',

    '.fxap',
}


-- DECRYPTED & FIXED BY DISCORD.GG/DEMONDEV