fx_version 'cerulean'
game 'gta5'

name 'DERP-slideshow'
description 'Board projector - Image & Video'
author 'DERP'

shared_script '@ox_lib/init.lua'

shared_script 'config.lua'

client_script 'client.lua'

server_script 'server.lua'

files {
    'html/player.html',
    'assets/demo.mp4',
}

scaleform_files {
    'generic_texture_renderer.gfx',
}

lua54 'yes'