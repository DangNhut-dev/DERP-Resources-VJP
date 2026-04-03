fx_version 'cerulean'
game 'gta5'

name 'AntiBackdoor Advanced'
description 'Advanced backdoor detection with behavior analysis'
author 'DE-Team'
version '1.0.0'

server_scripts {
    'config.lua',
    'utils/entropy.lua',
    'utils/pattern_matcher.lua',
    'core/behavior_analyzer.lua',
    'core/network_analyzer.lua',
    'core/code_analyzer.lua',
    'server.lua',
}

-- client_script 'client.lua'