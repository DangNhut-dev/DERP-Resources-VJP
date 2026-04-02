fx_version 'cerulean'
game 'gta5'

author      'Doogie'
description 'DoogieLoadingScreen — Custom FiveM loading screen'
version     '1.0.0'

loadscreen                'html/index.html'
loadscreen_manual_shutdown 'yes'
loadscreen_cursor          'yes'

files {
    -- Core
    'html/index.html',
    'html/assets/css/style.css',
    'html/assets/js/config.js',
    'html/assets/js/playlist.js',
    'html/assets/js/script.js',

    -- Videos
    'html/assets/videos/video.mp4',
    'html/assets/videos/video1.mp4',
    -- 'html/assets/videos/my-next-video.mp4',

    -- Music
    'html/assets/music/audio.mp3',
    'html/assets/music/audio1.mp3',
    -- 'html/assets/music/my-next-song.mp3',

    -- Cover Art
    'html/assets/covers/cover.jpg',
    'html/assets/covers/cover1.jpg',
    -- 'html/assets/covers/my-next-cover.jpg',

    -- Images (Logos, etc.)
    'html/assets/images/*.png',
    'html/assets/images/*.jpg',
    'html/assets/images/*.jpeg',
    'html/assets/images/*.svg',
    'html/assets/images/*.webp',
    'html/assets/images/*.gif',
}
