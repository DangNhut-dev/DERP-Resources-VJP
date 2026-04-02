/**
 * ┌──────────────────────────────────────────────────┐
 * │  DoogieLoadingScreen — Playlist Configuration    │
 * └──────────────────────────────────────────────────┘
 *
 * HOW TO ADD A TRACK:
 *   1. Place your audio  → html/assets/music/
 *   2. Place your cover  → html/assets/covers/
 *   3. Place your video  → html/assets/videos/
 *   4. Add an entry below (copy the template)
 *   5. Register the files in fxmanifest.lua
 *
 * SUPPORTED FORMATS:
 *   Audio : .mp3, .ogg, .wav
 *   Cover : .jpg, .jpeg, .png, .webp
 *   Video : .mp4, .webm
 */

const PLAYLIST = [
    {
        title:  'Face of a War',
        artist: 'Zy Benji',
        src:    'assets/music/audio.mp3',
        cover:  'assets/covers/cover.jpg',
        video:  'assets/videos/video.mp4',
    },
    {
        title:  'AHHH HA',
        artist: 'Lil Durk',
        src:    'assets/music/audio1.mp3',
        cover:  'assets/covers/cover1.jpg',
        video:  'assets/videos/video1.mp4',
    },

    // ── Add your tracks below ──────────────────────
    //
    // {
    //     title:  'My Song Title',
    //     artist: 'Artist Name',
    //     src:    'assets/music/my-song.mp3',
    //     cover:  'assets/covers/my-cover.jpg',
    //     video:  'assets/videos/my-video.mp4',
    // },
];
