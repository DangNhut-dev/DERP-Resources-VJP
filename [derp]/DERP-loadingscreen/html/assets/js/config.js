/**
 * ┌──────────────────────────────────────────────────┐
 * │  DoogieLoadingScreen — Configuration             │
 * │  Edit this file to customize your loading screen │
 * └──────────────────────────────────────────────────┘
 */

const CONFIG = {

    // ── Audio ────────────────────────────────────────
    defaultVolume: 0.3,       // 0.0 (muted) → 1.0 (max)
    shuffle: true,     // true = randomize track order on load

    // ── Hero Title (center of screen) ────────────────
    serverLogo: 'assets/images/logo.png', // <── Edit your server logo path here (leave '' to hide)
    heroTitle: 'DE:RP', // <── Edit your server name in the middle of the screen
    heroTagline: 'Đừng tin tưởng bất kỳ ai. Chỉ kẻ mạnh mới tồn tại.', // <── Edit message that appears below your server name in middle of the screen

    // ── Server Branding (top left) ───────────────────
    serverName: 'Dominion Entropy : Roleplay', // <── Edit your server name in the top left
    serverDiscordText: 'https://discord.gg/TWv9AWfDwY', // <── Edit your discord link in the top left

    // ── Changelogs (left panel) ──────────────────────
    changelogTitle: 'Cập Nhật Mới',
    changelogs: [
        // { version: 'v1.0.0', date: '03-04-2026', desc: '' },
        // { version: 'v1.1.5', date: '2026-03-26', desc: 'Script Performance improvements' },
        // { version: 'v1.1.0', date: '2026-03-25', desc: 'Bug fix and optimizations for WSPDoogie Loading Screen' },
        // { version: 'v1.0.2', date: '2026-03-24', desc: 'GPS Tracker UI Added' },
        // { version: 'v1.0.0', date: '2026-02-12', desc: 'Update of WSPDoogie Loading Screen' },
    ],

    // ── Staff List (right panel) ─────────────────────
    staffTitle: 'Đội Ngũ Quản Lý',
    staffList: [
        // { role: 'C.E.O', name: '<span style="color: #ff0000ff;">@WSPDoogie</span>' },
        { role: 'Admin', name: '<span style="color: #ff0000;">TommyNguyenx, Phuc, P4ttrick</span>' },
        { role: 'Dev', name: 'TommyNguyenx, P4trick, LeO' },
        { role: '3D Model', name: 'P4trick' },
        { role: 'Mods', name: 'LeO, Kuro' },
        { role: 'Supports', name: 'Jayy, Tuấn Ace' },
    ],

    // ── Social Links (leave '' to hide the icon) ─────
    discordUrl: 'https://discord.gg/TWv9AWfDwY',
    youtubeUrl: '',
    tiktokUrl: '',

    // ── Loading Steps (fallback simulation) ──────────
    loadingSteps: [
        { label: 'Đang kết nối với máy chủ...', target: 10 },
        { label: 'Đang tải nội dung...', target: 28 },
        { label: 'Đang tải tài nguyên...', target: 48 },
        { label: 'Đang tải bản đồ...', target: 65 },
        { label: 'Đang khởi tạo tập lệnh...', target: 82 },
        { label: 'Thế giới chuẩn bị...', target: 94 },
        { label: 'Gần như đã sẵn sàng...', target: 100 },
    ],
};
