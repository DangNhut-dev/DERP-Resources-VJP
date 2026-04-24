fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'TM'
description 'Check vehicle engine/body health'
version '1.0.0'

shared_script '@ox_lib/init.lua'

client_script 'client.lua'

dependencies {
    'qbx_core',
    'ox_lib',
    'ox_target',
}