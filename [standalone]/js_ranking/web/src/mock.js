const createHistory = (seed = 0) => {
    const points = [];
    let cash = 5000 + seed * 2000;
    let bank = 200000 + seed * 150000;
    let crypto = 5 + seed;
    const start = Date.now() - (24 * 3600 * 1000);

    for (let i = 0; i < 36; i += 1) {
        const ts = start + i * 40 * 60 * 1000;
        if (i % 4 === 0) cash += 500 + (seed * 20);
        if (i % 3 === 0) bank += 1200 - seed * 10;
        if (i % 8 === 0) crypto += 1;
        if (i === 11 || i === 22) bank += 3500;
        if (i >= 27 && i <= 35) cash += 200;

        points.push({
            ts,
            total: cash + bank + crypto,
            money: { cash, bank, crypto }
        });
    }

    const logs = [];
    for (let i = 1; i < points.length; i += 1) {
        const prev = points[i - 1];
        const cur = points[i];
        const diff = cur.total - prev.total;
        if (diff !== 0) {
            logs.push({
                ts: cur.ts,
                action: diff > 0 ? 'money:add' : 'money:remove',
                before: prev.total,
                after: cur.total,
                diff,
                diffs: {
                    cash: {
                        before: prev.money.cash,
                        after: cur.money.cash,
                        diff: cur.money.cash - prev.money.cash,
                    },
                    bank: {
                        before: prev.money.bank,
                        after: cur.money.bank,
                        diff: cur.money.bank - prev.money.bank,
                    },
                    crypto: {
                        before: prev.money.crypto,
                        after: cur.money.crypto,
                        diff: cur.money.crypto - prev.money.crypto,
                    }
                }
            });
        }
    }

    return { points, logs: logs.reverse() };
};

export const mockConfig = {
    UI: {
        Theme: {
            Main: '#2ca9e8',
            Background: 'rgba(10, 10, 18, 0.88)',
            Panel: 'rgba(44, 169, 232, 0.10)',
            Border: 'rgba(44, 169, 232, 0.35)',
            Text: '#e8f7ff',
            MutedText: 'rgba(232, 247, 255, 0.72)',
            NeonGlow: '0 0 10px rgba(44,169,232,0.75), 0 0 20px rgba(44,169,232,0.45)',
            NeonGlowStrong: '0 0 14px rgba(44,169,232,0.90), 0 0 28px rgba(44,169,232,0.60)',
        },
        Search: {
            Enabled: true,
            DebounceMs: 120,
            ClearOnEsc: true,
        },
        Table: {
            VisibleRows: 10,
            RowHeightPx: 46,
            Columns: [
                { key: 'status', width: '150px' },
                { key: 'name', width: '240px' },
                { key: 'job', width: '190px' },
                { key: 'id', width: '90px' },
                { key: 'citizenid', width: '220px' },
                { key: 'cash', width: '140px' },
                { key: 'bank', width: '140px' },
                { key: 'crypto', width: '140px' },
                { key: 'suspicious', width: '160px' },
                { key: 'online', width: '170px' },
                { key: 'actions', width: '320px' },
            ]
        },
        RankStyles: {
            1: { bg: 'rgba(44, 169, 232, 0.25)', border: 'rgba(44, 169, 232, 0.75)', fontSize: 16 },
            2: { bg: 'rgba(44, 169, 232, 0.20)', border: 'rgba(44, 169, 232, 0.65)', fontSize: 15 },
            3: { bg: 'rgba(160, 223, 250, 0.18)', border: 'rgba(160, 223, 250, 0.55)', fontSize: 14 },
            default: { bg: 'rgba(44, 169, 232, 0.10)', border: 'rgba(44, 169, 232, 0.28)', fontSize: 13 },
        },
        Modal: {
            MaxItemsShow: 200,
        },
        Chart: {
            DefaultKey: 'total',
        }
    },
    Inventory: {
        ImageBaseUrl: 'nui://ox_inventory/web/images',
        VehicleImageBaseUrl: 'https://gta5root.top/fivem/cars/',
        ImageExt: '.png',
        UseItemLabelFallback: true,
        ClothesImageBaseUrl: 'https://gta5root.top/fivem/items101',
        ClickNameToOpenModal: true,
    },
    NUI: {
        AutoRefresh: false,
        RefreshSeconds: 15,
    },
    MoneyHistory: {
        Enabled: true,
        StoreKeys: ['cash', 'bank', 'crypto'],
        TotalKeys: ['cash', 'bank', 'crypto'],
    },
    Suspicious: {
        Threshold: 1000,
        Days: 3,
    },
    Suspicious2: {
        Threshold: 1000,
        WindowMinutes: 5,
        MinConsecutive: 11,
        Days: 3,
    },
    Lang: {
        Main: {
            Title: 'BẢNG XẾP HẠNG',
            Subtitle: 'Bảng xếp hạng người chơi',
            MetaUpdated: 'Cập nhật: {time}',
            HintClickName: 'Click tên để xem inventory',
            NoData: 'Không có dữ liệu.',
        },
        Common: {
            Error: 'error',
            LoadingDots: '...',
            Unknown: 'Unknown',
            UnknownTime: 'Unknown time',
            NotAvailable: 'N/A',
            PlayerSub: '{name} • citizenID: {citizenid} • ID: {id}',
        },
        Buttons: {
            Refresh: 'Refresh',
            Close: 'Đóng',
            ShowNames: 'Hiện tên',
            HideNames: 'Ẩn tên',
            BanList: 'List ban',
            Admin: 'ADMIN',
            Chart: 'Biểu đồ',
            Log: 'Log',
            ViewOnChart: 'Xem trên biểu đồ',
            OpenLog: 'Mở log',
        },
        Admin: {
            Loading: 'Đang tải dữ liệu admin...',
            ErrorFetch: 'Không lấy được dữ liệu admin: {message}',
            ActionError: 'Không thể thực hiện thao tác: {message}',
            ActionsTitle: 'Hành động',
            AccountsTitle: 'Tài khoản',
            InformationTitle: 'Thông tin',
            NoTargetId: 'Người chơi này không online để dùng thao tác nhanh.',
            Fields: {
                CharacterName: 'Tên nhân vật',
                Gender: 'Giới tính',
            },
            Actions: {
                Kick: 'Kick người đó',
                Ban: 'Ban người đó',
                Goto: 'Dịch chuyển đến người đó',
                Bring: 'Kéo người đó về phía mình',
                Revive: 'Hồi sinh người đó',
                Spectate: 'Theo dõi người đó',
            },
            Tooltips: {
                Kick: 'Kick',
                Ban: 'Ban',
                Goto: 'Goto',
                Bring: 'Bring',
                Revive: 'Revive',
                Spectate: 'Spectate',
            }
        },
        Bans: {
            Title: 'DANH SÁCH BAN',
            Loading: 'Đang tải danh sách ban...',
            Empty: 'Không có người chơi nào đang bị ban.',
            ErrorFetch: 'Không lấy được danh sách ban: {message}',
            ErrorUnban: 'Không thể unban: {message}',
            Unban: 'Unban',
            Reason: 'Lý do',
            Expires: 'Hết hạn',
            BannedBy: 'Ban bởi',
        },
        Toggles: {
            ShowStaff: 'Hiện Admin/Mod',
            ShowStaffTitle: 'Hiện/ẩn Admin & Mod khỏi bảng xếp hạng',
            HideOffline: 'Ẩn Offline',
            HideOfflineTitle: 'Ẩn/hiện người chơi Offline',
        },
        Search: {
            Placeholder: 'Tìm theo Tên/citizenID/ID',
            GlobalLabel: 'Find log',
            GlobalPlaceholder: 'Find (vd: bank / 1000)',
            ChartPlaceholder: 'Find time / #điểm',
            LogPlaceholder: 'Find',
            ResultBadge: '{count} kq',
        },
        Ranges: {
            '24h': '24h',
            '7d': '7 ngày',
            '30d': '30 ngày',
        },
        Alerts: {
            Title: 'CẢNH BÁO',
            Empty: 'Không có cảnh báo.',
            Count: '{count} thông báo',
        },
        Status: {
            Online: 'Online',
            Offline: 'Offline',
            SecondsAgo: '{value} giây trc',
            MinutesAgo: '{value} phút trc',
            HoursAgo: '{value} giờ trc',
            DaysAgo: '{value} ngày trc',
        },
        Jobs: {
            police: 'Police',
            ambulance: 'Ambulance',
            mechanic: 'Mechanic',
            taxi: 'Taxi',
            BadgeTitle: '{title}: OnDuty {onDuty} • OffDuty {offDuty} • Total {total}',
        },
        Table: {
            Columns: {
                status: 'Trạng thái',
                name: 'Tên',
                job: 'Job',
                id: 'ID',
                citizenid: 'CitizenID',
                cash: 'Tiền mặt',
                bank: 'Tiền bank',
                crypto: 'Tiền crypto',
                suspicious: 'Nghi vấn',
                online: 'Online',
                actions: 'Thao tác',
            }
        },
        Inventory: {
            Title: 'TÚI ĐỒ NGƯỜI CHƠI',
            Empty: 'Không có item.',
            Loading: 'Đang tải inventory...',
            ErrorFetch: 'Không lấy được inventory: {message}',
            Count: 'Số lượng: {count}',
            TabItems: 'Túi đồ',
            TabVehicles: 'Xe sở hữu',
            ClothingDefault: 'Trang phục',
            ClothingCategories: {
                component: {
                    '1': 'Mặt nạ',
                    '3': 'Tay áo',
                    '4': 'Quần',
                    '5': 'Ba lô',
                    '6': 'Giày',
                    '7': 'Phụ kiện',
                    '8': 'Áo trong',
                    '9': 'Giáp',
                    '10': 'Decal',
                    '11': 'Áo khoác',
                },
                props: {
                    '0': 'Nón',
                    '1': 'Kính',
                    '2': 'Khuyên tai',
                    '6': 'Đồng hồ',
                    '7': 'Vòng tay',
                },
            },
        },
        Vehicles: {
            Loading: 'Đang tải danh sách xe...',
            ErrorFetch: 'Không lấy được danh sách xe: {message}',
            Empty: 'Không có xe.',
            Plate: 'Biển số: {plate}',
            UnknownPlate: 'UNKNOWN',
            DefaultLabel: 'Vehicle',
            ImageAlt: 'vehicle',
        },
        Chart: {
            Title: 'BIỂU ĐỒ DÒNG TIỀN',
            Loading: 'Đang tải biểu đồ...',
            ErrorFetch: 'Không lấy được dữ liệu biểu đồ: {message}',
            TotalLabel: 'Tổng',
            NoData: 'Không có dữ liệu.',
            Start: 'Đầu: {value}',
            End: 'Cuối: {value}',
            Min: 'Min: {value}',
            Max: 'Max: {value}',
            Diff: 'Chênh (Cuối-Đầu): {value}',
            SelectedPoint: 'Điểm chọn: #{index}',
            Time: 'Thời gian: {value}',
            Value: 'Giá trị: {value}',
            DiffPrev: 'Chênh vs điểm trước: {value}',
            DiffNext: 'Chênh tới điểm sau: {value}',
        },
        Log: {
            Title: 'NHẬT KÝ HÀNH ĐỘNG',
            Empty: 'Không có log.',
            Loading: 'Đang tải log...',
            ErrorFetch: 'Không lấy được log: {message}',
            Headers: {
                Time: 'Thời gian',
                Action: 'Hành động',
                MoneyDiff: 'Chênh lệch tiền',
            },
            NoStoreKeysChange: 'Không có thay đổi theo StoreKeys.',
            TotalKey: 'total',
        },
        Suspicious: {
            Title: 'NGHI VẤN DÒNG TIỀN',
            Title2: 'NGHI VẤN 2',
            Count: '({count} nghi vấn)',
            Loading: 'Đang tải nghi vấn...',
            Error: 'Lỗi khi tải nghi vấn.',
            ErrorMoney: 'Không lấy được dữ liệu tiền: {message}',
            Empty: 'Không có nghi vấn trong khoảng thời gian này.',
            Headers: {
                Time: 'Thời gian',
                Point: 'Điểm chọn',
                Diff: 'Chênh lệch',
                Detail: 'Chi tiết + Log',
            },
            BeforeAfter: 'Trước: {before} → Sau: {after} | Chênh: {sign}{diff}',
            DetailText: 'Chi tiết: {value}',
            Snapshot: 'Snapshot: {value}',
            LogText: 'Log: {action} • {value}',
            LogEmpty: 'Log: (không có log gần mốc này)',
            StreakSummary: 'Chuỗi: {count} lần / ~{minutes} phút | {details}',
        },
    }
};

export function createMockLeaderboard() {
    return {
        generatedAt: Math.floor(Date.now() / 1000),
        list: [
            {
                citizenid: 'CIT001',
                id: '31',
                name: 'Nguyen A',
                job: 'Police',
                jobDuty: true,
                isStaff: false,
                staffRole: '',
                staffLabel: '',
                cash: 28500,
                bank: 865000,
                crypto: 14,
                total: 893514,
                onlineSeconds: 125000,
                onlineText: '1d 10:43:20',
                isOnline: true,
                lastSeen: 0,
                suspicious: 2,
                suspicious2: 1,
            },
            {
                citizenid: 'CIT002',
                id: '48',
                name: 'Tran B',
                job: 'Mechanic',
                jobDuty: false,
                isStaff: false,
                staffRole: '',
                staffLabel: '',
                cash: 19500,
                bank: 742000,
                crypto: 3,
                total: 761503,
                onlineSeconds: 88210,
                onlineText: '1d 00:30:10',
                isOnline: true,
                lastSeen: 0,
                suspicious: 0,
                suspicious2: 0,
            },
            {
                citizenid: 'CIT003',
                id: '',
                name: 'Le C',
                job: 'Ambulance',
                jobDuty: false,
                isStaff: true,
                staffRole: 'admin',
                staffLabel: 'ADMIN',
                cash: 15000,
                bank: 620000,
                crypto: 50,
                total: 635050,
                onlineSeconds: 145020,
                onlineText: '1d 16:17:00',
                isOnline: false,
                lastSeen: Math.floor((Date.now() - 3 * 3600 * 1000) / 1000),
                suspicious: 1,
                suspicious2: 0,
            },
            {
                citizenid: 'CIT004',
                id: '52',
                name: 'Pham D',
                job: 'Taxi',
                jobDuty: true,
                isStaff: false,
                staffRole: '',
                staffLabel: '',
                cash: 6000,
                bank: 420000,
                crypto: 0,
                total: 426000,
                onlineSeconds: 35400,
                onlineText: '9:50:00',
                isOnline: true,
                lastSeen: 0,
                suspicious: 0,
                suspicious2: 0,
            }
        ],
        alerts: [
            {
                category: 1,
                title: 'Cảnh báo',
                description: 'Nguyen A có biến động tiền lớn trong 24h gần nhất.',
                ts: Math.floor(Date.now() / 1000),
                type: 'warning',
            },
            {
                category: 2,
                title: 'Cảnh báo nghi vấn 2',
                description: 'Le C có chuỗi biến động nhỏ liên tiếp.',
                ts: Math.floor((Date.now() - 3600 * 1000) / 1000),
                type: 'warning',
            },
        ],
        jobCounts: {
            police: { total: 8, onDuty: 5, offDuty: 3 },
            ambulance: { total: 3, onDuty: 1, offDuty: 2 },
            mechanic: { total: 6, onDuty: 2, offDuty: 4 },
            taxi: { total: 4, onDuty: 2, offDuty: 2 },
        }
    };
}

let mockShowNames = false;

let mockBans = [
    {
        id: 'ban_mock_1',
        steamName: 'Tommy Nguyenx',
        characterName: 'Tommy Nguyenx',
        citizenid: 'L2I7F2JC',
        steam: 'steam:11000010abcdef',
        discord: 'discord:595982132862779412',
        license: 'license:296c11f3ca1778f99df144d88623a1a2b1fccbcd',
        license2: 'license2:296c11f3ca1778f99df144d88623a1a2b1fccbcd',
        ip: 'ip:127.0.0.1',
        reason: 'VDM',
        expire: Math.floor(Date.now() / 1000) + 86400,
        bannedBy: 'Admin',
    },
];

const histories = {
    CIT001: createHistory(1),
    CIT002: createHistory(2),
    CIT003: createHistory(3),
    CIT004: createHistory(4),
};

const inventoryMap = {
    CIT001: {
        ok: true,
        offline: false,
        items: [
            { name: 'water', label: 'Nước', count: 5, slot: 1, metadata: {} },
            { name: 'bread', label: 'Bánh mì', count: 3, slot: 2, metadata: {} },
            { name: 'clothing', label: 'clothing', count: 1, slot: 3, metadata: { gender: 'male', componentType: 'component', componentId: 11, drawableId: 24, textureId: 0 } },
            { name: 'clothing', label: 'clothing', count: 1, slot: 4, metadata: { gender: 'male', componentType: 'props', componentId: 0, drawableId: 7, textureId: 2 } },
        ]
    },
    CIT002: {
        ok: true,
        offline: false,
        items: [
            { name: 'repairkit', label: 'Repair Kit', count: 2, slot: 1, metadata: {} },
            { name: 'radio', label: 'Radio', count: 1, slot: 2, metadata: {} },
        ]
    },
    CIT003: {
        ok: true,
        offline: true,
        items: [
            { name: 'phone', label: 'Điện thoại', count: 1, slot: 1, metadata: {} },
        ]
    },
    CIT004: {
        ok: true,
        offline: false,
        items: []
    }
};

const vehicleMap = {
    CIT001: {
        ok: true,
        offline: false,
        vehicles: [
            { id: 1, plate: '30A12345', model: 'sultan', label: 'Sultan RS', state: 1, depotPrice: 0 },
            { id: 2, plate: '51H77777', model: 'police3', label: 'Police 3', state: 1, depotPrice: 0 },
        ]
    },
    CIT002: {
        ok: true,
        offline: false,
        vehicles: [
            { id: 3, plate: '59A88991', model: 'flatbed', label: 'Flatbed', state: 1, depotPrice: 0 },
        ]
    },
    CIT003: {
        ok: true,
        offline: true,
        vehicles: []
    },
    CIT004: {
        ok: true,
        offline: false,
        vehicles: [
            { id: 4, plate: '60B22222', model: 'taxi', label: 'Taxi', state: 1, depotPrice: 0 },
        ]
    }
};

function countOccurrences(haystack, needle) {
    const h = String(haystack || '').toLowerCase();
    const n = String(needle || '').toLowerCase();
    if (!h || !n) return 0;
    let count = 0;
    let start = 0;
    while (true) {
        const idx = h.indexOf(n, start);
        if (idx === -1) break;
        count += 1;
        start = idx + n.length;
    }
    return count;
}

export async function mockRequest(action, data = {}) {
    await new Promise((resolve) => setTimeout(resolve, 120));

    if (action === 'close') return true;
    if (action === 'refresh') return createMockLeaderboard();
    if (action === 'requestSelfProfile') {
        return {
            ok: true,
            player: {
                id: 1,
                citizenid: 'L2I7F2JC',
                name: 'Tommy Nguyenx',
                steamName: 'Tommy Nguyenx',
            }
        };
    }
    if (action === 'requestAdminProfile') {
        return {
            ok: true,
            player: {
                id: 1,
                steamName: 'Tommy Nguyenx',
                steam: 'steam:110000112345678',
                discord: 'discord:595982132862779412',
                license: 'license:296c11f3ca1778f99df144d88623a1a2b1fccbcd',
                license2: 'license2:296c11f3ca1778f99df144d88623a1a2b1fccbcd',
                ip: '127.0.0.1',
                citizenid: data.citizenid || 'L2I7F2JC',
                name: 'Tommy Nguyenx',
                job: 'LSPD | 3',
                cash: 5950,
                bank: 48819,
                gender: 'Nam',
                isOnline: true,
            }
        };
    }
    if (action === 'adminAction') return { ok: true };
    if (action === 'requestInventory') return inventoryMap[data.citizenid] || { ok: true, offline: true, items: [] };
    if (action === 'requestVehicles') return vehicleMap[data.citizenid] || { ok: true, offline: true, vehicles: [] };

    if (action === 'requestMoneyHistory') {
        const base = histories[data.citizenid];
        if (!base) return { ok: false, message: 'missing_citizenid' };
        return {
            ok: true,
            citizenid: data.citizenid,
            range: data.range || '24h',
            generatedAt: Math.floor(Date.now() / 1000),
            tsUnit: 'ms',
            points: base.points,
            storeKeys: ['cash', 'bank', 'crypto'],
            totalKeys: ['cash', 'bank', 'crypto'],
        };
    }

    if (action === 'requestActionLogs') {
        const base = histories[data.citizenid];
        if (!base) return { ok: false, message: 'missing_citizenid' };
        return {
            ok: true,
            citizenid: data.citizenid,
            range: data.range || '24h',
            generatedAt: Math.floor(Date.now() / 1000),
            tsUnit: 'ms',
            logs: base.logs,
        };
    }

    if (action === 'requestActionLogMatchCounts') {
        const ids = Array.isArray(data.citizenids) ? data.citizenids : [];
        const query = String(data.query || '').trim();
        const counts = {};

        ids.forEach((citizenid) => {
            const logs = histories[citizenid]?.logs || [];
            let total = 0;
            logs.forEach((log) => {
                total += countOccurrences(log.action, query);
                total += countOccurrences(`${log.before} ${log.after} ${log.diff}`, query);
                total += countOccurrences(JSON.stringify(log.diffs || {}), query);
            });
            counts[citizenid] = total;
        });

        return {
            ok: true,
            range: data.range || '24h',
            query,
            counts,
        };
    }

    return { ok: false, message: 'unsupported_action' };
}
