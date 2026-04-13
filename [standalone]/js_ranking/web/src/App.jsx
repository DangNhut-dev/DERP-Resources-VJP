
import React, { useEffect, useMemo, useState } from 'react';
import { mockConfig, createMockLeaderboard } from './mock';
import { isNuiRuntime, nuiFetch } from './nui';

const DEFAULT_CLOTH_CATEGORIES = {
    component: {
        1: 'Mặt nạ',
        3: 'Tay áo',
        4: 'Quần',
        5: 'Ba lô',
        6: 'Giày',
        7: 'Phụ kiện',
        8: 'Áo trong',
        9: 'Giáp',
        10: 'Decal',
        11: 'Áo khoác',
    },
    props: {
        0: 'Nón',
        1: 'Kính',
        2: 'Khuyên tai',
        6: 'Đồng hồ',
        7: 'Vòng tay',
    }
};

const RANGE_OPTIONS = ['24h', '7d', '30d'];

function lang(config, path, fallback = '', vars = null) {
    const parts = String(path || '').split('.');
    let cur = config?.Lang;
    for (const part of parts) {
        if (cur == null || typeof cur !== 'object') {
            cur = null;
            break;
        }
        cur = cur[part];
    }

    let text = cur == null ? fallback : cur;
    if (typeof text !== 'string') text = fallback;
    if (!vars) return text;
    return text.replace(/\{(\w+)\}/g, (_, key) => {
        const val = vars[key];
        return val == null ? '' : String(val);
    });
}

function getLangValue(config, path, fallback = null) {
    const parts = String(path || '').split('.');
    let cur = config?.Lang;
    for (const part of parts) {
        if (cur == null || typeof cur !== 'object') return fallback;
        cur = cur[part];
    }
    return cur == null ? fallback : cur;
}

function applyThemeVars(config) {
    const root = document.documentElement;
    const theme = config?.UI?.Theme || {};
    const table = config?.UI?.Table || {};
    root.style.setProperty('--main', theme.Main || '#2ca9e8');
    root.style.setProperty('--bg', theme.Background || 'rgba(10, 10, 18, 0.88)');
    root.style.setProperty('--panel', theme.Panel || 'rgba(44, 169, 232, 0.10)');
    root.style.setProperty('--border', theme.Border || 'rgba(44, 169, 232, 0.35)');
    root.style.setProperty('--text', theme.Text || '#e8f7ff');
    root.style.setProperty('--muted', theme.MutedText || 'rgba(232, 247, 255, 0.72)');
    root.style.setProperty('--neon', theme.NeonGlow || '0 0 10px rgba(44,169,232,0.75)');
    root.style.setProperty('--neon-strong', theme.NeonGlowStrong || '0 0 14px rgba(44,169,232,0.90)');
    root.style.setProperty('--rows-visible', String(table.VisibleRows ?? 10));
    root.style.setProperty('--row-h', `${table.RowHeightPx ?? 46}px`);
}

function moneyFmt(n) {
    const value = Number(n || 0);
    if (!Number.isFinite(value)) return '0';
    return String(Math.trunc(value));
}

function parseWidthToWeight(w) {
    if (!w || typeof w !== 'string') return 100;
    const s = w.trim().toLowerCase();
    if (s.endsWith('px') || s.endsWith('%')) {
        const value = Number(s.replace(/[^\d.]/g, ''));
        return Number.isFinite(value) && value > 0 ? value : 100;
    }
    if (s.endsWith('fr')) {
        const value = Number(s.replace('fr', ''));
        return Number.isFinite(value) && value > 0 ? value * 100 : 100;
    }
    const value = Number(s);
    return Number.isFinite(value) && value > 0 ? value : 100;
}

function buildGridTemplate(columns) {
    const weights = (columns || []).map((column) => parseWidthToWeight(column.width));
    return weights.map((weight) => `minmax(0, ${weight}fr)`).join(' ');
}

function getColumnAlignClass(index, total) {
    if (index <= 0) return 'align-left';
    if (index >= total - 1) return 'align-right';
    return 'align-center';
}

function normalizeStr(value) {
    return String(value ?? '')
        .normalize('NFD')
        .replace(/\p{Diacritic}/gu, '')
        .toLowerCase()
        .trim();
}

function isNumberLike(value) {
    if (typeof value === 'number') return Number.isFinite(value);
    if (typeof value === 'string') {
        const s = value.trim();
        return !!s && Number.isFinite(Number(s));
    }
    return false;
}

function rankStyle(config, rank) {
    const styles = config?.UI?.RankStyles || {};
    return styles[String(rank)] || styles[rank] || styles.default || {
        bg: 'rgba(44,169,232,0.10)',
        border: 'rgba(44,169,232,0.28)',
        fontSize: 13,
    };
}

function isStaffPlayer(player) {
    if (!player) return false;
    if (player.isStaff) return true;
    return !!String(player.staffRole || '').trim() || !!String(player.staffLabel || '').trim();
}

function uiPlayerName(config, player) {
    const name = String(player?.name || lang(config, 'Common.Unknown', 'Unknown'));
    const role = String(player?.staffRole || '').toLowerCase();
    const label = String(player?.staffLabel || '').toUpperCase();
    if (role === 'admin' || role === 'mod' || label === 'ADMIN' || label === 'MOD') {
        return `👑 ${name}`;
    }
    return name;
}

function getPlayerSubText(config, player) {
    if (!player) return '';
    return lang(config, 'Common.PlayerSub', '{name} • citizenID: {citizenid} • ID: {id}', {
        name: player.name || lang(config, 'Common.Unknown', 'Unknown'),
        citizenid: player.citizenid || lang(config, 'Common.NotAvailable', 'N/A'),
        id: player.id || lang(config, 'Common.NotAvailable', 'N/A'),
    });
}

function formatAgoFromUnix(config, tsSeconds) {
    const ts = Number(tsSeconds || 0);
    if (!Number.isFinite(ts) || ts <= 0) return '';
    const now = Math.floor(Date.now() / 1000);
    const diff = Math.max(0, now - ts);
    if (diff < 60) return lang(config, 'Status.SecondsAgo', '{value} giây trc', { value: diff });
    if (diff < 3600) return lang(config, 'Status.MinutesAgo', '{value} phút trc', { value: Math.floor(diff / 60) });
    if (diff < 86400) return lang(config, 'Status.HoursAgo', '{value} giờ trc', { value: Math.floor(diff / 3600) });
    return lang(config, 'Status.DaysAgo', '{value} ngày trc', { value: Math.floor(diff / 86400) });
}

function formatDateTimeUnified(ms) {
    const value = Number(ms || 0);
    if (!Number.isFinite(value) || value <= 0) return '';
    return new Date(value).toLocaleString('vi-VN');
}


function inferTsUnit(ts) {
    const value = Number(ts || 0);
    if (!Number.isFinite(value) || value <= 0) return 'ms';
    return value > 200000000000 ? 'ms' : 's';
}

function tsToMs(ts, unitHint = null) {
    const value = Number(ts || 0);
    if (!Number.isFinite(value)) return 0;
    const unit = (unitHint || '').toLowerCase();
    if (unit === 'ms') return value;
    if (unit === 's') return value * 1000;
    return inferTsUnit(value) === 'ms' ? value : value * 1000;
}

function getPointValue(point, key) {
    if (!point) return 0;
    if (key === 'total') return Number(point.total || 0) || 0;
    return Number(point.money?.[key] || 0) || 0;
}

function pointsMoneyEqual(a, b, keys) {
    if (!a || !b) return false;
    if (Number(a.total || 0) !== Number(b.total || 0)) return false;
    for (const key of keys) {
        if (Number(a.money?.[key] || 0) !== Number(b.money?.[key] || 0)) return false;
    }
    return true;
}

function filterChartPointsOnlyOnMoneyChange(points, keys) {
    if (!Array.isArray(points) || points.length === 0) return [];
    const output = [];
    let prev = null;
    for (const point of points) {
        if (!prev) {
            output.push(point);
            prev = point;
            continue;
        }
        if (!pointsMoneyEqual(prev, point, keys || [])) {
            output.push(point);
            prev = point;
        }
    }
    return output;
}

function moneySnapshotText(config, money) {
    const keys = config?.MoneyHistory?.StoreKeys || [];
    return keys.map((key) => `${key}:${moneyFmt(money?.[key] || 0)}`).join(' | ');
}

function calcMoneyDiffsText(config, beforeMoney, afterMoney) {
    const keys = config?.MoneyHistory?.StoreKeys || [];
    const parts = [];
    for (const key of keys) {
        const before = Number(beforeMoney?.[key] || 0) || 0;
        const after = Number(afterMoney?.[key] || 0) || 0;
        const diff = after - before;
        if (diff !== 0) {
            const sign = diff > 0 ? '+' : '';
            parts.push(`${key}: ${moneyFmt(before)} → ${moneyFmt(after)} | ${sign}${moneyFmt(diff)}`);
        }
    }
    if (!parts.length) return lang(config, 'Log.NoStoreKeysChange', 'Không có thay đổi theo StoreKeys.');
    return parts.join('; ');
}

function formatMoneyDiffText(config, log) {
    if (!log) return '';
    if (log.diffs && typeof log.diffs === 'object') {
        const parts = Object.entries(log.diffs).map(([key, diff]) => {
            const before = Number(diff?.before || 0) || 0;
            const after = Number(diff?.after || 0) || 0;
            const delta = Number(diff?.diff || 0) || 0;
            const sign = delta > 0 ? '+' : '';
            return `${key}: ${moneyFmt(before)} → ${moneyFmt(after)} | ${sign}${moneyFmt(delta)}`;
        });
        if (parts.length) return parts.join('; ');
    }
    const before = Number(log.before || 0) || 0;
    const after = Number(log.after || 0) || 0;
    const diff = Number(log.diff || 0) || 0;
    const sign = diff > 0 ? '+' : '';
    return `${lang(config, 'Log.TotalKey', 'total')}: ${moneyFmt(before)} → ${moneyFmt(after)} | ${sign}${moneyFmt(diff)}`;
}

function findNearestLog(ts, logs, maxDeltaMs = 120000, unitHint = null) {
    if (!Array.isArray(logs) || logs.length === 0) return null;
    const target = Number(ts || 0);
    let best = null;
    let bestDelta = Number.MAX_SAFE_INTEGER;
    for (const log of logs) {
        const logTs = tsToMs(log?.ts, unitHint);
        const delta = Math.abs(logTs - target);
        if (delta < bestDelta) {
            best = log;
            bestDelta = delta;
        }
    }
    return bestDelta <= maxDeltaMs ? best : null;
}

function getSuspiciousThreshold(config) {
    const value = Number(config?.Suspicious?.Threshold);
    return Number.isFinite(value) && value > 0 ? value : 1000;
}

function getSuspicious2Config(config) {
    const threshold = Number(config?.Suspicious2?.Threshold);
    const winMinutes = Number(config?.Suspicious2?.WindowMinutes);
    const minConsecutive = Number(config?.Suspicious2?.MinConsecutive);
    return {
        threshold: Number.isFinite(threshold) && threshold > 0 ? threshold : getSuspiciousThreshold(config),
        windowMs: Number.isFinite(winMinutes) && winMinutes > 0 ? winMinutes * 60 * 1000 : 5 * 60 * 1000,
        minConsecutive: Number.isFinite(minConsecutive) && minConsecutive > 0 ? Math.floor(minConsecutive) : 11,
    };
}

function buildSuspiciousFromHistory(config, moneyResp, logResp) {
    const threshold = getSuspiciousThreshold(config);
    const unitMoney = moneyResp?.tsUnit || 'ms';
    const unitLog = logResp?.tsUnit || 'ms';
    const storeKeys = moneyResp?.storeKeys || config?.MoneyHistory?.StoreKeys || [];
    const points = filterChartPointsOnlyOnMoneyChange(moneyResp?.points || [], storeKeys);
    const logs = Array.isArray(logResp?.logs) ? logResp.logs : [];
    const output = [];

    for (let index = 1; index < points.length; index += 1) {
        const prev = points[index - 1];
        const cur = points[index];
        const beforeTotal = Number(prev?.total || 0) || 0;
        const afterTotal = Number(cur?.total || 0) || 0;
        const diffTotal = afterTotal - beforeTotal;
        if (Math.abs(diffTotal) > threshold) {
            const ts = tsToMs(cur?.ts, unitMoney);
            output.push({
                ts,
                pointIndex: index,
                beforeTotal,
                afterTotal,
                diffTotal,
                moneyDiffText: calcMoneyDiffsText(config, prev?.money || {}, cur?.money || {}),
                moneySnapText: moneySnapshotText(config, cur?.money || {}),
                log: findNearestLog(ts, logs, 120000, unitLog),
            });
        }
    }

    return output.sort((a, b) => b.ts - a.ts);
}

function buildSuspicious2FromHistory(config, moneyResp, logResp) {
    const cfg = getSuspicious2Config(config);
    const unitMoney = moneyResp?.tsUnit || 'ms';
    const unitLog = logResp?.tsUnit || 'ms';
    const storeKeys = moneyResp?.storeKeys || config?.MoneyHistory?.StoreKeys || [];
    const points = filterChartPointsOnlyOnMoneyChange(moneyResp?.points || [], storeKeys);
    const logs = Array.isArray(logResp?.logs) ? logResp.logs : [];
    const output = [];
    let streak = [];

    for (let index = 1; index < points.length; index += 1) {
        const prev = points[index - 1];
        const cur = points[index];
        const diff = (Number(cur?.total || 0) || 0) - (Number(prev?.total || 0) || 0);
        const ts = tsToMs(cur?.ts, unitMoney);
        const isSmall = diff !== 0 && Math.abs(diff) <= cfg.threshold;

        if (!isSmall) {
            streak = [];
            continue;
        }

        streak.push(index);
        while (streak.length > 0) {
            const firstTs = tsToMs(points[streak[0]]?.ts, unitMoney);
            if (ts - firstTs <= cfg.windowMs) break;
            streak.shift();
        }

        if (streak.length >= cfg.minConsecutive) {
            const startIdx = streak[0];
            const baseIdx = Math.max(0, startIdx - 1);
            const base = points[baseIdx];
            const end = points[index];
            const baseTotal = Number(base?.total || 0) || 0;
            const endTotal = Number(end?.total || 0) || 0;

            output.push({
                ts,
                pointIndex: index,
                beforeTotal: baseTotal,
                afterTotal: endTotal,
                diffTotal: endTotal - baseTotal,
                moneyDiffText: lang(config, 'Suspicious.StreakSummary', 'Chuỗi: {count} lần / ~{minutes} phút | {details}', {
                    count: streak.length,
                    minutes: Math.round((ts - tsToMs(points[startIdx]?.ts, unitMoney)) / 60000),
                    details: calcMoneyDiffsText(config, base?.money || {}, end?.money || {}),
                }),
                moneySnapText: moneySnapshotText(config, end?.money || {}),
                log: findNearestLog(ts, logs, 120000, unitLog),
            });

            streak = [];
        }
    }

    return output.sort((a, b) => b.ts - a.ts);
}

function isClothingItem(item) {
    if (!item) return false;
    const meta = item.metadata;
    if (!meta || typeof meta !== 'object') return false;
    return meta.drawableId !== undefined && meta.textureId !== undefined;
}

function isLegacyClothingItem(item) {
    return item?.name === 'clothing';
}

function clothImageFromMeta(config, item) {
    const meta = item?.metadata || {};
    const drawableId = Number(meta?.drawableId || 0);
    const textureId = Number(meta?.textureId || 0);

    if (isLegacyClothingItem(item)) {
        const base = String(config?.Inventory?.LegacyClothesImageBaseUrl || 'https://gta5root.top/fivem/items101').replace(/\/+$/g, '');
        const gender = meta?.gender === 'female' ? 'female' : 'male';
        const type = meta?.componentType === 'props' ? 'props' : 'component';
        const componentId = Number(meta?.componentId || 0);
        return `${base}/${gender}_${type}_${componentId}_${drawableId}_${textureId}.png`;
    }

    const base = String(config?.Inventory?.ClothesImageBaseUrl || 'https://gta5root.top/fivem/items101').replace(/\/+$/g, '');
    const gender = Number(meta?.gender || 0);
    return `${base}/${encodeURIComponent(item?.name || 'clothing')}_${drawableId}_${textureId}_${gender}.png`;
}

function clothCategoryLabel(config, meta) {
    const defs = getLangValue(config, 'Inventory.ClothingCategories', DEFAULT_CLOTH_CATEGORIES) || DEFAULT_CLOTH_CATEGORIES;
    const fallback = lang(config, 'Inventory.ClothingDefault', 'Trang phục');
    if (!meta) return fallback;
    const type = meta.componentType === 'props' ? 'props' : 'component';
    const key = String(Number(meta.componentId || 0));
    return defs?.[type]?.[key] || fallback;
}

function clothDisplayLabel(config, item) {
    const meta = item?.metadata || {};
    const drawableId = Number(meta?.drawableId || 0);
    const textureId = Number(meta?.textureId || 0);
    const baseLabel = isLegacyClothingItem(item)
        ? clothCategoryLabel(config, meta)
        : (item?.label || clothCategoryLabel(config, meta) || item?.name || lang(config, 'Inventory.ClothingDefault', 'Trang phục'));
    return `${baseLabel} (D:${drawableId} T:${textureId})`;
}

function itemImageSrc(config, item) {
    if (isClothingItem(item)) return clothImageFromMeta(config, item);
    const base = String(config?.Inventory?.ImageBaseUrl || 'nui://ox_inventory/web/images').replace(/\/+$/g, '');
    const ext = config?.Inventory?.ImageExt || '.png';
    return `${base}/${encodeURIComponent(item.name)}${ext}`;
}

function vehicleImageSrc(config, vehicle) {
    const base = String(config?.Inventory?.VehicleImageBaseUrl || 'https://gta5root.top/fivem/cars/').replace(/\/?$/g, '/');
    const ext = config?.Inventory?.ImageExt || '.png';
    const model = String(vehicle?.model || vehicle?.modelName || '').toLowerCase();
    return `${base}${encodeURIComponent(model)}${ext}`;
}

function cycleSort(currentKey, currentDir, nextKey, numeric = false) {
    if (currentKey !== nextKey) return [nextKey, numeric ? -1 : 1];
    if (currentDir === 0) return [nextKey, numeric ? -1 : 1];
    if (currentDir === -1) return [nextKey, 1];
    return [null, 0];
}

function sortArrow(dir) {
    if (dir === -1) return ' ↓';
    if (dir === 1) return ' ↑';
    return '';
}

function useDebouncedValue(value, delayMs) {
    const [debounced, setDebounced] = useState(value);
    useEffect(() => {
        const timer = window.setTimeout(() => setDebounced(value), delayMs);
        return () => window.clearTimeout(timer);
    }, [value, delayMs]);
    return debounced;
}

function Modal({ open, children, onBackdropClick, extraClass = '' }) {
    if (!open) return null;
    return (
        <div className={`modal ${extraClass}`.trim()}>
            <div className="modal-backdrop" onClick={onBackdropClick} />
            {children}
        </div>
    );
}

function ChartSvg({ points, chartKey, selectedIndex, onSelect, activeFindIndices = [] }) {
    const width = 1200;
    const height = 320;
    const padding = { left: 56, right: 24, top: 20, bottom: 42 };
    const values = points.map((point) => getPointValue(point, chartKey));
    if (values.length === 0) {
        return <div className="chart-empty">Không có dữ liệu.</div>;
    }

    let min = Math.min(...values);
    let max = Math.max(...values);
    if (min === max) {
        min -= 1;
        max += 1;
    }

    const plotW = width - padding.left - padding.right;
    const plotH = height - padding.top - padding.bottom;
    const getX = (index) => values.length === 1 ? padding.left + (plotW / 2) : padding.left + (index / (values.length - 1)) * plotW;
    const getY = (value) => {
        const k = (value - min) / (max - min);
        return padding.top + (1 - k) * plotH;
    };

    const linePoints = values.map((value, index) => `${getX(index)},${getY(value)}`).join(' ');
    const gridY = Array.from({ length: 6 }, (_, index) => padding.top + (index / 5) * plotH);
    const gridX = Array.from({ length: 7 }, (_, index) => padding.left + (index / 6) * plotW);
    const findSet = new Set(activeFindIndices);

    return (
        <svg className="chart-svg" viewBox={`0 0 ${width} ${height}`} preserveAspectRatio="none">
            {gridY.map((y) => <line key={`gy-${y}`} x1={padding.left} y1={y} x2={padding.left + plotW} y2={y} className="chart-grid" />)}
            {gridX.map((x) => <line key={`gx-${x}`} x1={x} y1={padding.top} x2={x} y2={padding.top + plotH} className="chart-grid" />)}
            <polyline points={linePoints} fill="none" className="chart-line" />
            {values.map((value, index) => {
                const cx = getX(index);
                const cy = getY(value);
                const isSelected = selectedIndex === index;
                const isFound = findSet.has(index);
                return (
                    <g key={`pt-${index}`} onClick={() => onSelect(index)} className="chart-point-wrap">
                        <circle cx={cx} cy={cy} r={isSelected ? 6 : (isFound ? 5 : 4)} className={isSelected ? 'chart-point chart-point-selected' : (isFound ? 'chart-point chart-point-found' : 'chart-point')} />
                    </g>
                );
            })}
        </svg>
    );
}

function App() {
    const initialMock = createMockLeaderboard();
    const [visible, setVisible] = useState(!isNuiRuntime);
    const [config, setConfig] = useState(mockConfig);
    const [leaderboard, setLeaderboard] = useState(isNuiRuntime ? null : initialMock);
    const [alerts, setAlerts] = useState(isNuiRuntime ? [] : (initialMock.alerts || []));
    const [search, setSearch] = useState('');
    const [showStaff, setShowStaff] = useState(() => localStorage.getItem('js_ranking_show_staff') === '1');
    const [hideOffline, setHideOffline] = useState(() => localStorage.getItem('js_ranking_hide_offline') === '1');
    const [sortKey, setSortKey] = useState(null);
    const [sortDir, setSortDir] = useState(0);
    const [globalRange, setGlobalRange] = useState('24h');
    const [globalQuery, setGlobalQuery] = useState('');
    const [globalCounts, setGlobalCounts] = useState({});
    const [globalHitIndex, setGlobalHitIndex] = useState(-1);

    const [inventoryModal, setInventoryModal] = useState({ open: false, player: null, tab: 'inv', loadingInv: false, loadingVeh: false, items: [], vehicles: [], errorInv: '', errorVeh: '' });
    const [chartModal, setChartModal] = useState({ open: false, player: null, range: '24h', loading: false, data: null, error: '', key: null, selectedIndex: null, findQuery: '', findIndex: -1 });
    const [logModal, setLogModal] = useState({ open: false, player: null, range: '24h', loading: false, logs: [], error: '', findQuery: '', findIndex: -1, tsUnit: 'ms', focusTs: 0 });
    const [imageModal, setImageModal] = useState({ open: false, title: '', sub: '', src: '' });
    const [susModal, setSusModal] = useState({ open: false, player: null, mode: 1, range: '30d', loading: false, items: [], error: '' });

    const debouncedGlobalQuery = useDebouncedValue(globalQuery, 180);
    const debouncedSearch = useDebouncedValue(search, Number(config?.UI?.Search?.DebounceMs || 120));
    const columns = useMemo(() => Array.isArray(config?.UI?.Table?.Columns) ? config.UI.Table.Columns : [], [config]);
    const gridTemplateColumns = useMemo(() => buildGridTemplate(columns), [columns]);

    useEffect(() => {
        applyThemeVars(config);
    }, [config]);

    useEffect(() => {
        localStorage.setItem('js_ranking_show_staff', showStaff ? '1' : '0');
    }, [showStaff]);

    useEffect(() => {
        localStorage.setItem('js_ranking_hide_offline', hideOffline ? '1' : '0');
    }, [hideOffline]);

    useEffect(() => {
        if (isNuiRuntime) return undefined;
        setVisible(true);
        setConfig(mockConfig);
        setLeaderboard(initialMock);
        setAlerts(initialMock.alerts || []);
        return undefined;
    }, []);

    useEffect(() => {
        if (!isNuiRuntime) return undefined;
        const onMessage = (event) => {
            const msg = event.data;
            if (!msg?.action) return;
            if (msg.action === 'open') {
                setConfig(msg.config || mockConfig);
                setVisible(true);
                setSearch('');
                setSortKey(null);
                setSortDir(0);
                setGlobalQuery('');
                setGlobalCounts({});
                setGlobalHitIndex(-1);
            } else if (msg.action === 'close') {
                setVisible(false);
                setInventoryModal({ open: false, player: null, tab: 'inv', loadingInv: false, loadingVeh: false, items: [], vehicles: [], errorInv: '', errorVeh: '' });
                setChartModal({ open: false, player: null, range: '24h', loading: false, data: null, error: '', key: null, selectedIndex: null, findQuery: '', findIndex: -1 });
                setLogModal({ open: false, player: null, range: '24h', loading: false, logs: [], error: '', findQuery: '', findIndex: -1, tsUnit: 'ms', focusTs: 0 });
                setSusModal({ open: false, player: null, mode: 1, range: '30d', loading: false, items: [], error: '' });
                setImageModal({ open: false, title: '', sub: '', src: '' });
            } else if (msg.action === 'setLeaderboard') {
                setLeaderboard(msg.data || null);
                setAlerts(Array.isArray(msg.data?.alerts) ? msg.data.alerts : []);
            } else if (msg.action === 'pushAlert') {
                setAlerts((prev) => [msg.data, ...prev].slice(0, 50));
            }
        };
        window.addEventListener('message', onMessage);
        return () => window.removeEventListener('message', onMessage);
    }, []);

    useEffect(() => {
        if (!visible || !leaderboard?.list?.length || !debouncedGlobalQuery.trim()) {
            setGlobalCounts({});
            setGlobalHitIndex(-1);
            return;
        }

        let cancelled = false;
        const citizenids = leaderboard.list.map((player) => player.citizenid).filter(Boolean);
        nuiFetch('requestActionLogMatchCounts', { citizenids, range: globalRange, query: debouncedGlobalQuery.trim() })
            .then((resp) => {
                if (cancelled) return;
                if (resp?.ok) {
                    setGlobalCounts(resp.counts || {});
                    setGlobalHitIndex(-1);
                } else {
                    setGlobalCounts({});
                    setGlobalHitIndex(-1);
                }
            })
            .catch(() => {
                if (!cancelled) {
                    setGlobalCounts({});
                    setGlobalHitIndex(-1);
                }
            });

        return () => {
            cancelled = true;
        };
    }, [visible, leaderboard, debouncedGlobalQuery, globalRange]);

    const baseList = useMemo(() => Array.isArray(leaderboard?.list) ? leaderboard.list.slice() : [], [leaderboard]);
    const filteredRows = useMemo(() => {
        const searchQuery = normalizeStr(debouncedSearch);
        const rankMap = new Map(baseList.map((player, index) => [player.citizenid, index + 1]));
        let rows = baseList.filter((player) => showStaff || !isStaffPlayer(player));
        if (hideOffline) rows = rows.filter((player) => !!player.isOnline);
        if (searchQuery) {
            rows = rows.filter((player) => normalizeStr(player.name).includes(searchQuery) || normalizeStr(player.citizenid).includes(searchQuery) || normalizeStr(player.id).includes(searchQuery));
        }
        if (sortKey && sortDir !== 0) {
            rows = rows.slice().sort((a, b) => {
                const getValue = (player) => {
                    if (sortKey === 'status') return player.isOnline ? 1 : 0;
                    if (sortKey === 'online') return Number(player.onlineSeconds || 0) || 0;
                    if (sortKey === 'suspicious') return Number(player.suspicious || 0) + Number(player.suspicious2 || 0);
                    if (sortKey === 'actions') return 0;
                    return player?.[sortKey];
                };
                const av = getValue(a);
                const bv = getValue(b);
                if (isNumberLike(av) && isNumberLike(bv)) {
                    const delta = Number(av) - Number(bv);
                    if (delta !== 0) return sortDir * delta;
                } else {
                    const result = String(av ?? '').localeCompare(String(bv ?? ''), 'vi', { numeric: true, sensitivity: 'base' });
                    if (result !== 0) return sortDir * result;
                }
                return (rankMap.get(a.citizenid) || 0) - (rankMap.get(b.citizenid) || 0);
            });
        }
        return rows;
    }, [baseList, showStaff, hideOffline, debouncedSearch, sortKey, sortDir]);

    const onlineCount = useMemo(() => filteredRows.filter((player) => player.isOnline).length, [filteredRows]);
    const serviceJobBadges = useMemo(() => {
        const jobCounts = leaderboard?.jobCounts || {};
        return [
            { key: 'police', icon: '🚓', title: lang(config, 'Jobs.police', 'Police') },
            { key: 'ambulance', icon: '🚑', title: lang(config, 'Jobs.ambulance', 'Ambulance') },
            { key: 'mechanic', icon: '🔧', title: lang(config, 'Jobs.mechanic', 'Mechanic') },
            { key: 'taxi', icon: '🚕', title: lang(config, 'Jobs.taxi', 'Taxi') },
        ].map((entry) => {
            const value = jobCounts[entry.key] || {};
            return {
                ...entry,
                total: Number(value.total || 0) || 0,
                onDuty: Number(value.onDuty || 0) || 0,
                offDuty: Number(value.offDuty || 0) || Math.max(0, Number(value.total || 0) - Number(value.onDuty || 0)),
            };
        });
    }, [leaderboard, config]);

    const visibleGlobalHits = useMemo(() => {
        if (!debouncedGlobalQuery.trim()) return [];
        return filteredRows.filter((player) => Number(globalCounts[player.citizenid] || 0) > 0).map((player) => player.citizenid);
    }, [filteredRows, globalCounts, debouncedGlobalQuery]);

    useEffect(() => {
        if (!visibleGlobalHits.length) {
            setGlobalHitIndex(-1);
            return;
        }
        if (globalHitIndex < 0 || globalHitIndex >= visibleGlobalHits.length) {
            setGlobalHitIndex(0);
        }
    }, [visibleGlobalHits, globalHitIndex]);

    const activeGlobalCitizenId = globalHitIndex >= 0 ? visibleGlobalHits[globalHitIndex] : null;
    const chartPoints = useMemo(() => {
        const points = Array.isArray(chartModal.data?.points) ? chartModal.data.points : [];
        const keys = chartModal.data?.storeKeys || config?.MoneyHistory?.StoreKeys || [];
        return filterChartPointsOnlyOnMoneyChange(points, keys);
    }, [chartModal.data, config]);
    const chartKeys = useMemo(() => ['total', ...(chartModal.data?.storeKeys || config?.MoneyHistory?.StoreKeys || [])], [chartModal.data, config]);
    const chartFindMatches = useMemo(() => {
        const query = normalizeStr(chartModal.findQuery);
        if (!query || !chartPoints.length) return [];
        return chartPoints
            .map((point, index) => {
                const text = [`#${index + 1}`, formatDateTimeUnified(tsToMs(point.ts, chartModal.data?.tsUnit || 'ms')), moneyFmt(getPointValue(point, chartModal.key || 'total'))].join(' ');
                return normalizeStr(text).includes(query) ? index : null;
            })
            .filter((index) => index != null);
    }, [chartModal.findQuery, chartPoints, chartModal.key, chartModal.data]);
    useEffect(() => {
        if (!chartFindMatches.length) {
            if (chartModal.findIndex !== -1) setChartModal((prev) => ({ ...prev, findIndex: -1 }));
            return;
        }
        if (chartModal.findIndex < 0 || chartModal.findIndex >= chartFindMatches.length) {
            setChartModal((prev) => ({ ...prev, findIndex: 0, selectedIndex: chartFindMatches[0] }));
        }
    }, [chartFindMatches, chartModal.findIndex]);
    const selectedChartPoint = chartModal.selectedIndex != null ? chartPoints[chartModal.selectedIndex] : null;
    const filteredLogs = useMemo(() => {
        const query = normalizeStr(logModal.findQuery);
        const logs = Array.isArray(logModal.logs) ? logModal.logs : [];
        if (!query) return logs;
        return logs.filter((log) => normalizeStr(`${log.action} ${formatMoneyDiffText(config, log)} ${formatDateTimeUnified(tsToMs(log.ts, logModal.tsUnit || 'ms'))}`).includes(query));
    }, [logModal.logs, logModal.findQuery, logModal.tsUnit, config]);

    const generatedAtText = leaderboard?.generatedAt ? formatDateTimeUnified(Number(leaderboard.generatedAt) * 1000) : lang(config, 'Common.UnknownTime', 'Unknown time');

    const openInventoryModal = async (player) => {
        if (!player?.citizenid) return;
        setInventoryModal({ open: true, player, tab: 'inv', loadingInv: true, loadingVeh: false, items: [], vehicles: [], errorInv: '', errorVeh: '' });
        try {
            const response = await nuiFetch('requestInventory', { citizenid: player.citizenid });
            if (response?.ok) {
                setInventoryModal((prev) => ({ ...prev, loadingInv: false, items: Array.isArray(response.items) ? response.items : [], errorInv: '' }));
            } else {
                setInventoryModal((prev) => ({ ...prev, loadingInv: false, errorInv: response?.message || lang(config, 'Common.Error', 'error') }));
            }
        } catch (error) {
            setInventoryModal((prev) => ({ ...prev, loadingInv: false, errorInv: lang(config, 'Inventory.ErrorFetch', 'Không lấy được inventory: {message}', { message: 'error' }) }));
        }
    };

    const loadVehicles = async (citizenid) => {
        setInventoryModal((prev) => ({ ...prev, loadingVeh: true, errorVeh: '' }));
        try {
            const response = await nuiFetch('requestVehicles', { citizenid });
            if (response?.ok) {
                setInventoryModal((prev) => ({ ...prev, loadingVeh: false, vehicles: Array.isArray(response.vehicles) ? response.vehicles : [], errorVeh: '' }));
            } else {
                setInventoryModal((prev) => ({ ...prev, loadingVeh: false, errorVeh: response?.message || lang(config, 'Common.Error', 'error') }));
            }
        } catch (error) {
            setInventoryModal((prev) => ({ ...prev, loadingVeh: false, errorVeh: lang(config, 'Vehicles.ErrorFetch', 'Không lấy được danh sách xe: {message}', { message: 'error' }) }));
        }
    };

    const openChartModal = async (player, focusTs = null, forceRange = null) => {
        if (!player?.citizenid) return;
        const range = forceRange || chartModal.range || '24h';
        setChartModal({ open: true, player, range, loading: true, data: null, error: '', key: config?.UI?.Chart?.DefaultKey || 'total', selectedIndex: null, findQuery: '', findIndex: -1 });
        try {
            const response = await nuiFetch('requestMoneyHistory', { citizenid: player.citizenid, range });
            if (response?.ok) {
                const filtered = filterChartPointsOnlyOnMoneyChange(response.points || [], response.storeKeys || config?.MoneyHistory?.StoreKeys || []);
                let selectedIndex = null;
                if (focusTs) {
                    let bestDelta = Number.MAX_SAFE_INTEGER;
                    filtered.forEach((point, index) => {
                        const delta = Math.abs(tsToMs(point.ts, response.tsUnit || 'ms') - Number(focusTs));
                        if (delta < bestDelta) {
                            bestDelta = delta;
                            selectedIndex = index;
                        }
                    });
                }
                setChartModal((prev) => ({ ...prev, loading: false, data: response, range, selectedIndex }));
            } else {
                setChartModal((prev) => ({ ...prev, loading: false, error: response?.message || lang(config, 'Common.Error', 'error') }));
            }
        } catch (error) {
            setChartModal((prev) => ({ ...prev, loading: false, error: lang(config, 'Chart.ErrorFetch', 'Không lấy được dữ liệu biểu đồ: {message}', { message: 'error' }) }));
        }
    };

    const openLogModal = async (player, focusTs = null, forceRange = null) => {
        if (!player?.citizenid) return;
        const range = forceRange || logModal.range || '24h';
        setLogModal({ open: true, player, range, loading: true, logs: [], error: '', findQuery: '', findIndex: -1, tsUnit: 'ms', focusTs: focusTs || 0 });
        try {
            const response = await nuiFetch('requestActionLogs', { citizenid: player.citizenid, range });
            if (response?.ok) {
                let nextIndex = -1;
                if (focusTs) {
                    let bestDelta = Number.MAX_SAFE_INTEGER;
                    (response.logs || []).forEach((log, index) => {
                        const delta = Math.abs(tsToMs(log.ts, response.tsUnit || 'ms') - Number(focusTs));
                        if (delta < bestDelta) {
                            bestDelta = delta;
                            nextIndex = index;
                        }
                    });
                }
                setLogModal({ open: true, player, range, loading: false, logs: Array.isArray(response.logs) ? response.logs : [], error: '', findQuery: '', findIndex: nextIndex, tsUnit: response.tsUnit || 'ms', focusTs: 0 });
            } else {
                setLogModal((prev) => ({ ...prev, loading: false, error: response?.message || lang(config, 'Common.Error', 'error') }));
            }
        } catch (error) {
            setLogModal((prev) => ({ ...prev, loading: false, error: lang(config, 'Log.ErrorFetch', 'Không lấy được log: {message}', { message: 'error' }) }));
        }
    };

    const openSuspiciousModal = async (player, mode, forceRange = null) => {
        if (!player?.citizenid) return;
        const range = forceRange || susModal.range || '30d';
        setSusModal({ open: true, player, mode, range, loading: true, items: [], error: '' });
        try {
            const [moneyResp, logResp] = await Promise.all([
                nuiFetch('requestMoneyHistory', { citizenid: player.citizenid, range }),
                nuiFetch('requestActionLogs', { citizenid: player.citizenid, range })
            ]);
            if (!moneyResp?.ok) {
                setSusModal((prev) => ({ ...prev, loading: false, error: lang(config, 'Suspicious.ErrorMoney', 'Không lấy được dữ liệu tiền: {message}', { message: moneyResp?.message || lang(config, 'Common.Error', 'error') }) }));
                return;
            }
            const safeLog = logResp?.ok ? logResp : { ok: false, logs: [], tsUnit: 'ms' };
            const items = mode === 2 ? buildSuspicious2FromHistory(config, moneyResp, safeLog) : buildSuspiciousFromHistory(config, moneyResp, safeLog);
            setSusModal({ open: true, player, mode, range, loading: false, items, error: '' });
        } catch (error) {
            setSusModal((prev) => ({ ...prev, loading: false, error: lang(config, 'Suspicious.Error', 'Lỗi khi tải nghi vấn.') }));
        }
    };

    const doRefresh = async () => {
        try {
            const response = await nuiFetch('refresh', {});
            if (!isNuiRuntime && response?.list) {
                setLeaderboard(response);
                setAlerts(response.alerts || []);
            }
        } catch (error) {}
    };

    const doClose = async () => {
        try { await nuiFetch('close', {}); } catch (error) {}
        if (!isNuiRuntime) setVisible(false);
    };

    if (!visible) return <div id="app" className="hidden" />;

    return (
        <div id="app">
            <div className="backdrop" />
            <div className="panel">
                <div className="header">
                    <div className="title-wrap">
                        <div className="title">{lang(config, 'Main.Title', 'BẢNG XẾP HẠNG')}</div>
                        <div className="subtitle">{lang(config, 'Main.Subtitle', 'Bảng xếp hạng người chơi')}</div>
                    </div>

                    {config?.UI?.Search?.Enabled !== false && (
                        <div className="search-wrap">
                            <input className="search" type="text" autoComplete="off" value={search} onChange={(event) => setSearch(event.target.value)} onKeyDown={(event) => { if (event.key === 'Escape' && config?.UI?.Search?.ClearOnEsc) setSearch(''); }} placeholder={lang(config, 'Search.Placeholder', 'Tìm theo Tên/citizenID/ID')} />
                        </div>
                    )}

                    <div className="actions">
                        <label className="staff-toggle" title={lang(config, 'Toggles.ShowStaffTitle', 'Hiện/ẩn Admin & Mod khỏi bảng xếp hạng')}>
                            <input type="checkbox" checked={showStaff} onChange={(event) => setShowStaff(event.target.checked)} />
                            <span>{lang(config, 'Toggles.ShowStaff', 'Hiện Admin/Mod')}</span>
                        </label>
                        <label className="staff-toggle" title={lang(config, 'Toggles.HideOfflineTitle', 'Ẩn/hiện người chơi Offline')}>
                            <input type="checkbox" checked={hideOffline} onChange={(event) => setHideOffline(event.target.checked)} />
                            <span>{lang(config, 'Toggles.HideOffline', 'Ẩn Offline')}</span>
                        </label>
                        <button className="btn" onClick={doRefresh}>{lang(config, 'Buttons.Refresh', 'Refresh')}</button>
                        <button className="btn btn-ghost" onClick={doClose}>{lang(config, 'Buttons.Close', 'Đóng')}</button>
                    </div>
                </div>

                {config?.MoneyHistory?.Enabled && (
                    <div className="global-find-bar">
                        <div className="left-meta">
                            <div className="online-meta">{onlineCount}/{filteredRows.length}</div>
                            <div className="job-meta">
                                {serviceJobBadges.map((badge) => (
                                    <div key={badge.key} className="job-badge" title={lang(config, 'Jobs.BadgeTitle', '{title}: OnDuty {onDuty} • OffDuty {offDuty} • Total {total}', { title: badge.title, onDuty: badge.onDuty, offDuty: badge.offDuty, total: badge.total })}>
                                        <span className="job-icon">{badge.icon}</span>
                                        <span className="job-count">{badge.title}: {badge.onDuty}/{badge.total}</span>
                                    </div>
                                ))}
                            </div>
                        </div>
                        <div className="global-find-label">{lang(config, 'Search.GlobalLabel', 'Find log')}</div>
                        <select className="select" value={globalRange} onChange={(event) => setGlobalRange(event.target.value)}>
                            {RANGE_OPTIONS.map((range) => <option key={range} value={range}>{lang(config, `Ranges.${range}`, range)}</option>)}
                        </select>
                        <div className="find-wrap">
                            <input className="find-input" type="text" autoComplete="off" value={globalQuery} onChange={(event) => setGlobalQuery(event.target.value)} placeholder={lang(config, 'Search.GlobalPlaceholder', 'Find (vd: bank / 1000)')} />
                            <button className="btn btn-small find-btn" onClick={() => visibleGlobalHits.length && setGlobalHitIndex((prev) => prev <= 0 ? visibleGlobalHits.length - 1 : prev - 1)}>↑</button>
                            <button className="btn btn-small find-btn" onClick={() => visibleGlobalHits.length && setGlobalHitIndex((prev) => prev >= visibleGlobalHits.length - 1 ? 0 : prev + 1)}>↓</button>
                            <div className="find-meta">{!debouncedGlobalQuery.trim() ? '' : `${visibleGlobalHits.length ? globalHitIndex + 1 : 0}/${visibleGlobalHits.length} • Σ${Object.values(globalCounts).reduce((sum, value) => sum + (Number(value || 0) || 0), 0)}`}</div>
                        </div>
                    </div>
                )}

                <div className="table-wrap">
                    <div className="table-head" style={{ gridTemplateColumns }}>
                        {columns.map((column, columnIndex) => {
                            const numeric = ['cash', 'bank', 'online', 'suspicious', 'id'].includes(column.key);
                            const title = lang(config, `Table.Columns.${column.key}`, column.key);
                            const alignClass = getColumnAlignClass(columnIndex, columns.length);
                            return (
                                <button key={column.key} className={`head-cell ${alignClass} ${sortKey === column.key ? 'active' : ''}`} onClick={() => {
                                    const [nextKey, nextDir] = cycleSort(sortKey, sortDir, column.key, numeric);
                                    setSortKey(nextKey);
                                    setSortDir(nextDir);
                                }}>
                                    <span className="head-label">{title}</span>
                                    <span className="head-arrow">{sortKey === column.key ? sortArrow(sortDir) : ''}</span>
                                </button>
                            );
                        })}
                    </div>
                    <div className="table-body">
                        {!filteredRows.length && <div className="empty-state">{lang(config, 'Main.NoData', 'Không có dữ liệu.')}</div>}
                        {filteredRows.map((player, index) => {
                            const style = rankStyle(config, index + 1);
                            const activeMatch = activeGlobalCitizenId === player.citizenid;
                            return (
                                <div key={player.citizenid || `${player.name}-${index}`} className={`row ${activeMatch ? 'find-active' : ''}`} style={{ gridTemplateColumns, background: style.bg || '', boxShadow: `inset 0 0 0 1px ${style.border || 'rgba(44,169,232,0.20)'}`, fontSize: `${style.fontSize ?? 13}px` }}>
                                    {columns.map((column, columnIndex) => {
                                        const count = Number(globalCounts[player.citizenid] || 0) || 0;
                                        const showBadge = debouncedGlobalQuery.trim() && count > 0;
                                        const alignClass = getColumnAlignClass(columnIndex, columns.length);
                                        if (column.key === 'status') {
                                            return (
                                                <div key={column.key} className={`cell ${alignClass} status ${player.isOnline ? 'status-online' : 'status-offline'}`}>
                                                    <div className="status-wrap">
                                                        <span className="status-text">{player.isOnline ? lang(config, 'Status.Online', 'Online') : lang(config, 'Status.Offline', 'Offline')}</span>
                                                        {showBadge && <span className="find-count-badge">{lang(config, 'Search.ResultBadge', '{count} kq', { count })}</span>}
                                                        {!player.isOnline && !!player.lastSeen && <span className="status-lastseen">({formatAgoFromUnix(config, player.lastSeen)})</span>}
                                                    </div>
                                                </div>
                                            );
                                        }
                                        if (column.key === 'name') {
                                            return <div key={column.key} className={`cell ${alignClass} name`} onClick={() => config?.Inventory?.ClickNameToOpenModal !== false && openInventoryModal(player)}>{uiPlayerName(config, player)}</div>;
                                        }
                                        if (column.key === 'job') {
                                            return (
                                                <div key={column.key} className={`cell ${alignClass} job`}>
                                                    {player.job ? (
                                                        <div className="job-wrap">
                                                            <span className={`job-dot ${player.jobDuty === true ? 'job-on' : 'job-off'}`} />
                                                            <span className="job-text">{player.job}</span>
                                                        </div>
                                                    ) : ''}
                                                </div>
                                            );
                                        }
                                        if (column.key === 'id') return <div key={column.key} className={`cell ${alignClass}`}>{player.id || ''}</div>;
                                        if (column.key === 'citizenid') return <div key={column.key} className={`cell ${alignClass}`}>{player.citizenid || ''}</div>;
                                        if (column.key === 'cash') return <div key={column.key} className={`cell ${alignClass}`}>{moneyFmt(player.cash)}</div>;
                                        if (column.key === 'bank') return <div key={column.key} className={`cell ${alignClass}`}>{moneyFmt(player.bank)}</div>;
                                        if (column.key === 'online') return <div key={column.key} className={`cell ${alignClass}`}>{player.onlineText || ''}</div>;
                                        if (column.key === 'suspicious') {
                                            const n1 = Number(player.suspicious || 0) || 0;
                                            const n2 = Number(player.suspicious2 || 0) || 0;
                                            return (
                                                <div key={column.key} className={`cell ${alignClass} actions`}>
                                                    <div className="cell-actions">
                                                        <button className="btn btn-mini btn-inline btn-suspicious" disabled={n1 <= 0} onClick={() => openSuspiciousModal(player, 1)}>{n1}</button>
                                                        <button className="btn btn-mini btn-inline btn-suspicious" disabled={n2 <= 0} onClick={() => openSuspiciousModal(player, 2)}>{n2}</button>
                                                    </div>
                                                </div>
                                            );
                                        }
                                        if (column.key === 'actions') {
                                            return (
                                                <div key={column.key} className={`cell ${alignClass} actions`}>
                                                    <div className="cell-actions">
                                                        <button className="btn btn-mini btn-inline" onClick={() => openChartModal(player)}>{lang(config, 'Buttons.Chart', 'Biểu đồ')}</button>
                                                        <button className="btn btn-mini btn-inline" onClick={() => openLogModal(player)}>{lang(config, 'Buttons.Log', 'Log')}</button>
                                                    </div>
                                                </div>
                                            );
                                        }
                                        return <div key={column.key} className={`cell ${alignClass}`}>{String(player[column.key] ?? '')}</div>;
                                    })}
                                </div>
                            );
                        })}
                    </div>
                </div>

                <div className="alerts-wrap">
                    <div className="alerts-head">
                        <div className="alerts-title">{lang(config, 'Alerts.Title', 'CẢNH BÁO')}</div>
                        <div className="alerts-meta">{lang(config, 'Alerts.Count', '{count} thông báo', { count: alerts.length })}</div>
                    </div>
                    <div className="alerts-body">
                        {!alerts.length && <div className="alerts-empty">{lang(config, 'Alerts.Empty', 'Không có cảnh báo.')}</div>}
                        {alerts.map((alert, index) => (
                            <div className="alert-card" key={`${alert.ts || 0}-${index}`}>
                                <div className="alert-top">
                                    <strong>{alert.title || 'Alert'}</strong>
                                    <span>{formatDateTimeUnified(tsToMs(alert.ts || 0, 's'))}</span>
                                </div>
                                <div className="alert-desc">{alert.description || ''}</div>
                            </div>
                        ))}
                    </div>
                </div>

                <div className="footer">
                    <div className="hint">{lang(config, 'Main.HintClickName', 'Click tên để xem inventory')}</div>
                    <div className="meta">{lang(config, 'Main.MetaUpdated', 'Cập nhật: {time}', { time: generatedAtText })}</div>
                </div>
            </div>

            <Modal open={inventoryModal.open} onBackdropClick={() => setInventoryModal({ open: false, player: null, tab: 'inv', loadingInv: false, loadingVeh: false, items: [], vehicles: [], errorInv: '', errorVeh: '' })}>
                <div className="modal-card">
                    <div className="modal-header">
                        <div className="modal-title">{lang(config, 'Inventory.Title', 'TÚI ĐỒ NGƯỜI CHƠI')}</div>
                        <button className="btn btn-ghost" onClick={() => setInventoryModal({ open: false, player: null, tab: 'inv', loadingInv: false, loadingVeh: false, items: [], vehicles: [], errorInv: '', errorVeh: '' })}>{lang(config, 'Buttons.Close', 'Đóng')}</button>
                    </div>
                    <div className="modal-sub">{getPlayerSubText(config, inventoryModal.player)}</div>
                    <div className="modal-tabs">
                        <button className={`tab ${inventoryModal.tab === 'inv' ? 'active' : ''}`} onClick={() => setInventoryModal((prev) => ({ ...prev, tab: 'inv' }))}>{lang(config, 'Inventory.TabItems', 'Túi đồ')}</button>
                        <button className={`tab ${inventoryModal.tab === 'veh' ? 'active' : ''}`} onClick={() => {
                            setInventoryModal((prev) => ({ ...prev, tab: 'veh' }));
                            if (!inventoryModal.vehicles.length && !inventoryModal.loadingVeh && inventoryModal.player?.citizenid) loadVehicles(inventoryModal.player.citizenid);
                        }}>{lang(config, 'Inventory.TabVehicles', 'Xe sở hữu')}</button>
                    </div>
                    <div className="modal-body">
                        {inventoryModal.tab === 'inv' && (
                            <div className="items-grid">
                                {inventoryModal.loadingInv && <div className="modal-empty">{lang(config, 'Inventory.Loading', 'Đang tải inventory...')}</div>}
                                {!inventoryModal.loadingInv && inventoryModal.errorInv && <div className="modal-empty">{lang(config, 'Inventory.ErrorFetch', 'Không lấy được inventory: {message}', { message: inventoryModal.errorInv })}</div>}
                                {!inventoryModal.loadingInv && !inventoryModal.errorInv && inventoryModal.items.length === 0 && <div className="modal-empty">{lang(config, 'Inventory.Empty', 'Không có item.')}</div>}
                                {inventoryModal.items.map((item, index) => {
                                    const isCloth = isClothingItem(item);
                                    const label = isCloth ? clothDisplayLabel(config, item) : (item.label || item.name);
                                    return (
                                        <div key={`${item.name}-${item.slot || index}`} className="item">
                                            <button className="img-btn" onClick={() => setImageModal({ open: true, title: label, sub: item.name, src: itemImageSrc(config, item) })}>
                                                <img src={itemImageSrc(config, item)} alt={item.name} className="item-img" />
                                            </button>
                                            <div className="info">
                                                <div className="label">{label}</div>
                                                <div className="count">{lang(config, 'Inventory.Count', 'Số lượng: {count}', { count: moneyFmt(item.count) })}</div>
                                            </div>
                                        </div>
                                    );
                                })}
                            </div>
                        )}

                        {inventoryModal.tab === 'veh' && (
                            <div className="veh-grid">
                                {inventoryModal.loadingVeh && <div className="modal-empty">{lang(config, 'Vehicles.Loading', 'Đang tải danh sách xe...')}</div>}
                                {!inventoryModal.loadingVeh && inventoryModal.errorVeh && <div className="modal-empty">{lang(config, 'Vehicles.ErrorFetch', 'Không lấy được danh sách xe: {message}', { message: inventoryModal.errorVeh })}</div>}
                                {!inventoryModal.loadingVeh && !inventoryModal.errorVeh && inventoryModal.vehicles.length === 0 && <div className="modal-empty">{lang(config, 'Vehicles.Empty', 'Không có xe.')}</div>}
                                {inventoryModal.vehicles.map((vehicle) => (
                                    <div className="veh-card" key={`${vehicle.id}-${vehicle.plate}`}>
                                        <button className="img-btn" onClick={() => setImageModal({ open: true, title: vehicle.label || vehicle.model || lang(config, 'Vehicles.DefaultLabel', 'Vehicle'), sub: vehicle.plate || '', src: vehicleImageSrc(config, vehicle) })}>
                                            <img src={vehicleImageSrc(config, vehicle)} alt={lang(config, 'Vehicles.ImageAlt', 'vehicle')} className="veh-img" />
                                        </button>
                                        <div className="veh-info">
                                            <div className="veh-label">{vehicle.label || vehicle.model || lang(config, 'Vehicles.DefaultLabel', 'Vehicle')}</div>
                                            <div className="veh-plate">{lang(config, 'Vehicles.Plate', 'Biển số: {plate}', { plate: vehicle.plate || lang(config, 'Vehicles.UnknownPlate', 'UNKNOWN') })}</div>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>
                </div>
            </Modal>

            <Modal open={chartModal.open} onBackdropClick={() => setChartModal({ open: false, player: null, range: '24h', loading: false, data: null, error: '', key: null, selectedIndex: null, findQuery: '', findIndex: -1 })}>
                <div className="modal-card">
                    <div className="modal-header">
                        <div className="modal-title">{lang(config, 'Chart.Title', 'BIỂU ĐỒ DÒNG TIỀN')}</div>
                        <div className="modal-tools">
                            <select className="select" value={chartModal.range} onChange={(event) => openChartModal(chartModal.player, null, event.target.value)}>
                                {RANGE_OPTIONS.map((range) => <option key={range} value={range}>{lang(config, `Ranges.${range}`, range)}</option>)}
                            </select>
                            <select className="select" value={chartModal.key || config?.UI?.Chart?.DefaultKey || 'total'} onChange={(event) => setChartModal((prev) => ({ ...prev, key: event.target.value, selectedIndex: null }))}>
                                {chartKeys.map((key) => <option key={key} value={key}>{key === 'total' ? lang(config, 'Chart.TotalLabel', 'Tổng') : key}</option>)}
                            </select>
                            <div className="find-wrap">
                                <input className="find-input" type="text" autoComplete="off" value={chartModal.findQuery} onChange={(event) => setChartModal((prev) => ({ ...prev, findQuery: event.target.value }))} placeholder={lang(config, 'Search.ChartPlaceholder', 'Find time / #điểm')} />
                                <button className="btn btn-small find-btn" onClick={() => chartFindMatches.length && setChartModal((prev) => {
                                    const next = prev.findIndex <= 0 ? chartFindMatches.length - 1 : prev.findIndex - 1;
                                    return { ...prev, findIndex: next, selectedIndex: chartFindMatches[next] };
                                })}>↑</button>
                                <button className="btn btn-small find-btn" onClick={() => chartFindMatches.length && setChartModal((prev) => {
                                    const next = prev.findIndex >= chartFindMatches.length - 1 ? 0 : prev.findIndex + 1;
                                    return { ...prev, findIndex: next, selectedIndex: chartFindMatches[next] };
                                })}>↓</button>
                                <div className="find-meta">{chartModal.findQuery.trim() ? `${chartFindMatches.length ? chartModal.findIndex + 1 : 0}/${chartFindMatches.length}` : ''}</div>
                            </div>
                            <button className="btn btn-small" onClick={() => openChartModal(chartModal.player, null, chartModal.range)}>{lang(config, 'Buttons.Refresh', 'Refresh')}</button>
                            <button className="btn btn-ghost btn-small" onClick={() => setChartModal({ open: false, player: null, range: '24h', loading: false, data: null, error: '', key: null, selectedIndex: null, findQuery: '', findIndex: -1 })}>{lang(config, 'Buttons.Close', 'Đóng')}</button>
                        </div>
                    </div>
                    <div className="modal-sub">{getPlayerSubText(config, chartModal.player)}</div>
                    <div className="modal-body">
                        {chartModal.loading && <div className="modal-empty">{lang(config, 'Chart.Loading', 'Đang tải biểu đồ...')}</div>}
                        {!chartModal.loading && chartModal.error && <div className="modal-empty">{lang(config, 'Chart.ErrorFetch', 'Không lấy được dữ liệu biểu đồ: {message}', { message: chartModal.error })}</div>}
                        {!chartModal.loading && !chartModal.error && (
                            <>
                                <div className="chart-scroll">
                                    <ChartSvg points={chartPoints} chartKey={chartModal.key || config?.UI?.Chart?.DefaultKey || 'total'} selectedIndex={chartModal.selectedIndex} activeFindIndices={chartFindMatches} onSelect={(index) => setChartModal((prev) => ({ ...prev, selectedIndex: index }))} />
                                </div>
                                <div className="chart-stats">
                                    {chartPoints.length > 0 && (
                                        <>
                                            <div>{lang(config, 'Chart.Start', 'Đầu: {value}', { value: moneyFmt(getPointValue(chartPoints[0], chartModal.key || 'total')) })}</div>
                                            <div>{lang(config, 'Chart.End', 'Cuối: {value}', { value: moneyFmt(getPointValue(chartPoints[chartPoints.length - 1], chartModal.key || 'total')) })}</div>
                                            <div>{lang(config, 'Chart.Min', 'Min: {value}', { value: moneyFmt(Math.min(...chartPoints.map((point) => getPointValue(point, chartModal.key || 'total')))) })}</div>
                                            <div>{lang(config, 'Chart.Max', 'Max: {value}', { value: moneyFmt(Math.max(...chartPoints.map((point) => getPointValue(point, chartModal.key || 'total')))) })}</div>
                                            <div>{lang(config, 'Chart.Diff', 'Chênh (Cuối-Đầu): {value}', { value: moneyFmt(getPointValue(chartPoints[chartPoints.length - 1], chartModal.key || 'total') - getPointValue(chartPoints[0], chartModal.key || 'total')) })}</div>
                                        </>
                                    )}
                                    {selectedChartPoint && (
                                        <div className="chart-selected-box">
                                            <div>{lang(config, 'Chart.SelectedPoint', 'Điểm chọn: #{index}', { index: Number(chartModal.selectedIndex) + 1 })}</div>
                                            <div>{lang(config, 'Chart.Time', 'Thời gian: {value}', { value: formatDateTimeUnified(tsToMs(selectedChartPoint.ts, chartModal.data?.tsUnit || 'ms')) })}</div>
                                            <div>{lang(config, 'Chart.Value', 'Giá trị: {value}', { value: moneyFmt(getPointValue(selectedChartPoint, chartModal.key || 'total')) })}</div>
                                            {chartModal.selectedIndex > 0 && <div>{lang(config, 'Chart.DiffPrev', 'Chênh vs điểm trước: {value}', { value: moneyFmt(getPointValue(selectedChartPoint, chartModal.key || 'total') - getPointValue(chartPoints[chartModal.selectedIndex - 1], chartModal.key || 'total')) })}</div>}
                                            {chartModal.selectedIndex < chartPoints.length - 1 && <div>{lang(config, 'Chart.DiffNext', 'Chênh tới điểm sau: {value}', { value: moneyFmt(getPointValue(chartPoints[chartModal.selectedIndex + 1], chartModal.key || 'total') - getPointValue(selectedChartPoint, chartModal.key || 'total')) })}</div>}
                                        </div>
                                    )}
                                </div>
                            </>
                        )}
                    </div>
                </div>
            </Modal>

            <Modal open={logModal.open} onBackdropClick={() => setLogModal({ open: false, player: null, range: '24h', loading: false, logs: [], error: '', findQuery: '', findIndex: -1, tsUnit: 'ms', focusTs: 0 })}>
                <div className="modal-card">
                    <div className="modal-header">
                        <div className="modal-title">{lang(config, 'Log.Title', 'NHẬT KÝ HÀNH ĐỘNG')}</div>
                        <div className="modal-tools">
                            <select className="select" value={logModal.range} onChange={(event) => openLogModal(logModal.player, null, event.target.value)}>
                                {RANGE_OPTIONS.map((range) => <option key={range} value={range}>{lang(config, `Ranges.${range}`, range)}</option>)}
                            </select>
                            <div className="find-wrap">
                                <input className="find-input" type="text" autoComplete="off" value={logModal.findQuery} onChange={(event) => setLogModal((prev) => ({ ...prev, findQuery: event.target.value, findIndex: -1 }))} placeholder={lang(config, 'Search.LogPlaceholder', 'Find')} />
                            </div>
                            <button className="btn btn-small" onClick={() => openLogModal(logModal.player, null, logModal.range)}>{lang(config, 'Buttons.Refresh', 'Refresh')}</button>
                            <button className="btn btn-ghost btn-small" onClick={() => setLogModal({ open: false, player: null, range: '24h', loading: false, logs: [], error: '', findQuery: '', findIndex: -1, tsUnit: 'ms', focusTs: 0 })}>{lang(config, 'Buttons.Close', 'Đóng')}</button>
                        </div>
                    </div>
                    <div className="modal-sub">{getPlayerSubText(config, logModal.player)}</div>
                    <div className="modal-body">
                        {logModal.loading && <div className="modal-empty">{lang(config, 'Log.Loading', 'Đang tải log...')}</div>}
                        {!logModal.loading && logModal.error && <div className="modal-empty">{lang(config, 'Log.ErrorFetch', 'Không lấy được log: {message}', { message: logModal.error })}</div>}
                        {!logModal.loading && !logModal.error && (
                            <div className="log-table">
                                <div className="log-head">
                                    <div className="log-cell">{lang(config, 'Log.Headers.Time', 'Thời gian')}</div>
                                    <div className="log-cell">{lang(config, 'Log.Headers.Action', 'Hành động')}</div>
                                    <div className="log-cell log-cell-wide">{lang(config, 'Log.Headers.MoneyDiff', 'Chênh lệch tiền')}</div>
                                </div>
                                {!filteredLogs.length && <div className="modal-empty">{lang(config, 'Log.Empty', 'Không có log.')}</div>}
                                {filteredLogs.map((log, index) => (
                                    <div className={`log-row ${logModal.findIndex === index ? 'log-row-focus' : ''}`} key={`${log.ts}-${index}`}>
                                        <div className="log-cell">{formatDateTimeUnified(tsToMs(log.ts, logModal.tsUnit || 'ms'))}</div>
                                        <div className="log-cell">{log.action || ''}</div>
                                        <div className="log-cell log-cell-wide">{formatMoneyDiffText(config, log)}</div>
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>
                </div>
            </Modal>

            <Modal open={imageModal.open} onBackdropClick={() => setImageModal({ open: false, title: '', sub: '', src: '' })} extraClass="img-modal">
                <div className="modal-card img-card">
                    <div className="modal-header">
                        <div className="modal-title">{imageModal.title || 'HÌNH ẢNH'}</div>
                        <button className="btn btn-ghost" onClick={() => setImageModal({ open: false, title: '', sub: '', src: '' })}>{lang(config, 'Buttons.Close', 'Đóng')}</button>
                    </div>
                    <div className="modal-sub">{imageModal.sub || ''}</div>
                    <div className="modal-body img-body">
                        <div className="img-wrap">
                            <img src={imageModal.src} alt="preview" className="img-preview" />
                        </div>
                    </div>
                </div>
            </Modal>

            <Modal open={susModal.open} onBackdropClick={() => setSusModal({ open: false, player: null, mode: 1, range: '30d', loading: false, items: [], error: '' })}>
                <div className="modal-card">
                    <div className="modal-header">
                        <div className="modal-title">{susModal.mode === 2 ? lang(config, 'Suspicious.Title2', 'NGHI VẤN 2') : lang(config, 'Suspicious.Title', 'NGHI VẤN DÒNG TIỀN')} <span className="sus-count">{lang(config, 'Suspicious.Count', '({count} nghi vấn)', { count: susModal.items.length })}</span></div>
                        <div className="modal-tools">
                            <select className="select" value={susModal.range} onChange={(event) => openSuspiciousModal(susModal.player, susModal.mode, event.target.value)}>
                                {RANGE_OPTIONS.map((range) => <option key={range} value={range}>{lang(config, `Ranges.${range}`, range)}</option>)}
                            </select>
                            <button className="btn btn-small" onClick={() => openSuspiciousModal(susModal.player, susModal.mode, susModal.range)}>{lang(config, 'Buttons.Refresh', 'Refresh')}</button>
                            <button className="btn btn-ghost btn-small" onClick={() => setSusModal({ open: false, player: null, mode: 1, range: '30d', loading: false, items: [], error: '' })}>{lang(config, 'Buttons.Close', 'Đóng')}</button>
                        </div>
                    </div>
                    <div className="modal-sub">{getPlayerSubText(config, susModal.player)}</div>
                    <div className="modal-body">
                        {susModal.loading && <div className="modal-empty">{lang(config, 'Suspicious.Loading', 'Đang tải nghi vấn...')}</div>}
                        {!susModal.loading && susModal.error && <div className="modal-empty">{susModal.error}</div>}
                        {!susModal.loading && !susModal.error && (
                            <div className="sus-table">
                                <div className="sus-head">
                                    <div className="sus-cell">#</div>
                                    <div className="sus-cell">{lang(config, 'Suspicious.Headers.Time', 'Thời gian')}</div>
                                    <div className="sus-cell">{lang(config, 'Suspicious.Headers.Point', 'Điểm chọn')}</div>
                                    <div className="sus-cell">{lang(config, 'Suspicious.Headers.Diff', 'Chênh lệch')}</div>
                                    <div className="sus-cell detail">{lang(config, 'Suspicious.Headers.Detail', 'Chi tiết + Log')}</div>
                                </div>
                                {!susModal.items.length && <div className="sus-empty">{lang(config, 'Suspicious.Empty', 'Không có nghi vấn trong khoảng thời gian này.')}</div>}
                                {susModal.items.map((item, index) => (
                                    <div className="sus-row" key={`${item.ts}-${index}`}>
                                        <div className="sus-cell">{index + 1}</div>
                                        <div className="sus-cell">{formatDateTimeUnified(item.ts)}</div>
                                        <div className="sus-cell">#{Number(item.pointIndex) + 1}</div>
                                        <div className="sus-cell">{item.diffTotal > 0 ? '+' : ''}{moneyFmt(item.diffTotal)}</div>
                                        <div className="sus-cell detail">
                                            <div>{lang(config, 'Suspicious.BeforeAfter', 'Trước: {before} → Sau: {after} | Chênh: {sign}{diff}', { before: moneyFmt(item.beforeTotal), after: moneyFmt(item.afterTotal), sign: item.diffTotal > 0 ? '+' : '', diff: moneyFmt(item.diffTotal) })}</div>
                                            <div className="sus-sub-line">{lang(config, 'Suspicious.DetailText', 'Chi tiết: {value}', { value: item.moneyDiffText || '' })}</div>
                                            <div className="sus-sub-line">{lang(config, 'Suspicious.Snapshot', 'Snapshot: {value}', { value: item.moneySnapText || '' })}</div>
                                            <div className="sus-sub-line">{item.log?.action ? lang(config, 'Suspicious.LogText', 'Log: {action} • {value}', { action: item.log.action, value: formatMoneyDiffText(config, item.log) }) : lang(config, 'Suspicious.LogEmpty', 'Log: (không có log gần mốc này)')}</div>
                                            <div className="sus-actions">
                                                <button className="btn btn-small" onClick={() => openChartModal(susModal.player, item.ts, '30d')}>{lang(config, 'Buttons.ViewOnChart', 'Xem trên biểu đồ')}</button>
                                                <button className="btn btn-small btn-ghost" onClick={() => openLogModal(susModal.player, item.ts, '30d')}>{lang(config, 'Buttons.OpenLog', 'Mở log')}</button>
                                            </div>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>
                </div>
            </Modal>
        </div>
    );
}

export default App;
