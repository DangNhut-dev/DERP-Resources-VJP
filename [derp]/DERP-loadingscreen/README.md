# 🎮 DoogieLoadingScreen — FiveM Loading Screen

> A premium, highly customizable loading screen with an integrated music player, background video clips, and dynamic UI panels.

---

## 🚀 1. Installation

1. Drag and drop the `DoogieLoadingScreen` folder into your server `resources` directory.
2. Add `ensure DoogieLoadingScreen` into your `server.cfg`.
3. Restart your server or type `refresh` and `ensure DoogieLoadingScreen` in your server console.

---

## ⚙️ 2. Configuration (The ONLY file you need)

Everything you need to customize is located in exactly one file: 

!! 👉 **`html/assets/js/config.js`** !!

Open it up to easily change:
- **Server Branding**: Your server name, central tagline, and Discord subtext.
- **Server Logo**: Add your logo image into `html/assets/images/` and change the link in the config. *(Use a transparent .PNG of 500x500px for best results!)*
- **Changelogs (Left Panel)**: Edit the list to show your latest patch notes and updates.
- **Team Staff (Right Panel)**: List your administrators, developers, and moderators.
- **Social Links**: Your Discord, YouTube, and TikTok URLs.

---

## 🎵 3. Adding Music, Covers & Background Videos

This loading screen supports dynamic background videos! When a specific song plays in the music player, its matching video will play in the background.

### Step A: Put the files in their folders
Drop your new media files into their respective folders:
- 📀 **Music Files** (`.mp3`): Place in `html/assets/music/`
- 🖼️ **Cover Images** (`.jpg`, `.png`): Place in `html/assets/covers/`
- 🎥 **Video Clips** (`.mp4`, `.webm`): Place in `html/assets/videos/`

### Step B: Update the Playlist 
Open **`html/assets/js/playlist.js`** and add your new track to the list following this format:
```javascript
const PLAYLIST = [
    {
        title:  'Song Title',
        artist: 'Artist Name',
        src:    'assets/music/my-song.mp3',
        cover:  'assets/covers/my-cover.jpg',
        video:  'assets/videos/my-video.mp4',
    },
    // You can add as many tracks as you want!
];
```

### Step C: Register files in `fxmanifest.lua` (CRITICAL)
If you skip this step, players will NOT download the files and the screen will be black! 
Open **`fxmanifest.lua`** and add your exact file names in the `files` section at the bottom:
```lua
    -- Videos
    'html/assets/videos/my-video.mp4',

    -- Music
    'html/assets/music/my-song.mp3',

    -- Cover Art
    'html/assets/covers/my-cover.jpg',
```

*(Note: Logos placed in the `images` folder are already handled automatically by the manifest!)*

---

## 🗑️ Removing a Track

1. Delete the block from `html/assets/js/playlist.js`.
2. Delete the corresponding lines from `fxmanifest.lua`.
3. Delete the actual `.mp3`, `.jpg`, and `.mp4` files from the folders to save server space.

---

## 💡 Pro Tips for Best Performance

To ensure your players don't lag or spend 10 minutes downloading the loading screen:
- ✔️ **Total Size:** Try to keep the total resource size under ~100MB.
- ✔️ **Audio:** Compress `.mp3` files to **128 kbps**. They will still sound great.
- ✔️ **Video:** Compress `.mp4` files to **720p or 1080p, 30fps**. Under 50MB per video is strongly recommended.
- ✔️ **Covers:** Use perfectly square images (e.g. 500x500px) in `.jpg` to save space.

---
**Made by WSPDoogie**