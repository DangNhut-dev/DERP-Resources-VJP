
import React, { useEffect, useMemo, useRef, useState } from 'react';
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

function adminFieldValue(config, value) {
    if (value == null || value === '') return lang(config, 'Common.NotAvailable', 'N/A');
    return String(value);
}

function getAdminHeaderText(config, data, fallbackPlayer = null) {
    const idText = adminFieldValue(config, data?.id || fallbackPlayer?.id);
    const steamName = adminFieldValue(config, data?.steamName || fallbackPlayer?.steamName || fallbackPlayer?.name || lang(config, 'Common.Unknown', 'Unknown'));
    const characterName = adminFieldValue(config, data?.characterName || data?.name || fallbackPlayer?.characterName || fallbackPlayer?.name || lang(config, 'Common.Unknown', 'Unknown'));
    return `ID: ${idText} | ${steamName} | ${characterName}`;
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

function formatBanExpireText(config, tsSeconds) {
    const value = Number(tsSeconds || 0);
    if (!Number.isFinite(value) || value <= 0) return lang(config, 'Common.NotAvailable', 'N/A');
    return new Date(value * 1000).toLocaleString('vi-VN');
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


const SCREEN_WATCH_RTC_CONFIG = {
    iceServers: [
        { urls: ['stun:stun.l.google.com:19302', 'stun:stun1.l.google.com:19302', 'stun:stun2.l.google.com:19302', 'stun:stun3.l.google.com:19302', 'stun:stun4.l.google.com:19302'] },
        { urls: ['stun:global.stun.twilio.com:3478', 'stun:stun.voip.blackberry.com:3478'] },
        { urls: ['turn:turn.bistri.com:80'], username: 'homeo', credential: 'homeo' },
        { urls: ['turn:numb.viagenie.ca'], username: 'webrtc@live.com', credential: 'muazkh' },
        { urls: ['turn:us-0.turn.peerjs.com:3478'], username: 'peerjs', credential: 'peerjsp' }
    ],
    iceCandidatePoolSize: 10,
    bundlePolicy: 'max-bundle',
    rtcpMuxPolicy: 'require',
    sdpSemantics: 'unified-plan'
};

const SCREEN_WATCH_DISCONNECT_DELAY = 8000;

const SCREEN_WATCH_VERTEX_SHADER = `
  attribute vec2 a_position;
  attribute vec2 a_texcoord;
  uniform mat3 u_matrix;
  varying vec2 textureCoordinate;
  void main() {
    gl_Position = vec4(a_position, 0.0, 1.0);
    textureCoordinate = a_texcoord;
  }
`;

const SCREEN_WATCH_FRAGMENT_SHADER = `
varying highp vec2 textureCoordinate;
uniform sampler2D external_texture;
void main() {
    gl_FragColor = texture2D(external_texture, textureCoordinate);
}
`;

function sleep(ms) {
    return new Promise((resolve) => window.setTimeout(resolve, ms));
}

function clamp(value, min, max) {
    if (!Number.isFinite(value)) return min;
    if (max < min) return min;
    return Math.min(Math.max(value, min), max);
}

const SCREEN_WATCH_DEFAULT_WIDTH = 1180;
const SCREEN_WATCH_DEFAULT_HEIGHT = 720;
const SCREEN_WATCH_MIN_WIDTH = 560;
const SCREEN_WATCH_MIN_HEIGHT = 360;
const SCREEN_WATCH_VIEWPORT_GAP = 0;

function getScreenWatchBounds(widthHint = null, heightHint = null, leftHint = null, topHint = null) {
    const viewportWidth = Math.max(Number(window.innerWidth || 0), 320);
    const viewportHeight = Math.max(Number(window.innerHeight || 0), 240);
    const maxWidth = Math.max(320, viewportWidth - (SCREEN_WATCH_VIEWPORT_GAP * 2));
    const maxHeight = Math.max(220, viewportHeight - (SCREEN_WATCH_VIEWPORT_GAP * 2));
    const minWidth = Math.min(SCREEN_WATCH_MIN_WIDTH, maxWidth);
    const minHeight = Math.min(SCREEN_WATCH_MIN_HEIGHT, maxHeight);
    const width = clamp(widthHint == null ? Math.min(SCREEN_WATCH_DEFAULT_WIDTH, maxWidth) : widthHint, minWidth, maxWidth);
    const height = clamp(heightHint == null ? Math.min(SCREEN_WATCH_DEFAULT_HEIGHT, maxHeight) : heightHint, minHeight, maxHeight);
    const maxLeft = Math.max(SCREEN_WATCH_VIEWPORT_GAP, viewportWidth - width - SCREEN_WATCH_VIEWPORT_GAP);
    const maxTop = Math.max(SCREEN_WATCH_VIEWPORT_GAP, viewportHeight - height - SCREEN_WATCH_VIEWPORT_GAP);
    const left = clamp(leftHint == null ? (viewportWidth - width) / 2 : leftHint, SCREEN_WATCH_VIEWPORT_GAP, maxLeft);
    const top = clamp(topHint == null ? (viewportHeight - height) / 2 : topHint, SCREEN_WATCH_VIEWPORT_GAP, maxTop);
    return { width, height, left, top, minWidth, minHeight, maxWidth, maxHeight };
}

function createWatchShader(gl, type, source) {
    const shader = gl.createShader(type);
    if (!shader) return null;
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    const info = gl.getShaderInfoLog(shader);
    if (info) console.error(info);
    return shader;
}

function createWatchTexture(gl) {
    const texture = gl.createTexture();
    if (!texture) return null;

    const pixel = new Uint8Array([0, 0, 255, 255]);
    gl.bindTexture(gl.TEXTURE_2D, texture);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 1, 1, 0, gl.RGBA, gl.UNSIGNED_BYTE, pixel);
    gl.texParameterf(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
    gl.texParameterf(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
    gl.texParameterf(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameterf(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    gl.texParameterf(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.MIRRORED_REPEAT);
    gl.texParameterf(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
    gl.texParameterf(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    return texture;
}

function createWatchBuffers(gl) {
    const vertexBuff = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuff);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 1, -1, -1, 1, 1, 1]), gl.STATIC_DRAW);

    const texBuff = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, texBuff);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([0, 0, 1, 0, 0, 1, 1, 1]), gl.STATIC_DRAW);

    return { vertexBuff, texBuff };
}

function createWatchProgram(gl) {
    const vertexShader = createWatchShader(gl, gl.VERTEX_SHADER, SCREEN_WATCH_VERTEX_SHADER);
    const fragmentShader = createWatchShader(gl, gl.FRAGMENT_SHADER, SCREEN_WATCH_FRAGMENT_SHADER);
    if (!vertexShader || !fragmentShader) return null;

    const program = gl.createProgram();
    if (!program) return null;

    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program);
    gl.useProgram(program);

    return {
        program,
        vloc: gl.getAttribLocation(program, 'a_position'),
        tloc: gl.getAttribLocation(program, 'a_texcoord')
    };
}

function createWatchGameRender(canvas) {
    const gl = canvas.getContext('webgl', {
        antialias: false,
        depth: false,
        stencil: false,
        alpha: false,
        desynchronized: true,
        failIfMajorPerformanceCaveat: false
    });

    if (!gl) return null;

    let animationFrame = 0;

    const programData = createWatchProgram(gl);
    if (!programData) return null;

    const texture = createWatchTexture(gl);
    const { program, vloc, tloc } = programData;
    const { vertexBuff, texBuff } = createWatchBuffers(gl);

    gl.useProgram(program);
    gl.bindTexture(gl.TEXTURE_2D, texture);
    gl.uniform1i(gl.getUniformLocation(program, 'external_texture'), 0);
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuff);
    gl.vertexAttribPointer(vloc, 2, gl.FLOAT, false, 0, 0);
    gl.enableVertexAttribArray(vloc);
    gl.bindBuffer(gl.ARRAY_BUFFER, texBuff);
    gl.vertexAttribPointer(tloc, 2, gl.FLOAT, false, 0, 0);
    gl.enableVertexAttribArray(tloc);
    gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);

    const draw = () => {
        gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
        gl.finish();
        animationFrame = window.requestAnimationFrame(draw);
    };

    draw();

    return {
        canvas,
        gl,
        animationFrame,
        resize(width, height) {
            gl.viewport(0, 0, width, height);
            gl.canvas.width = width;
            gl.canvas.height = height;
        },
        remove() {
            if (animationFrame) {
                window.cancelAnimationFrame(animationFrame);
                animationFrame = 0;
            }
            const loseContext = gl.getExtension('WEBGL_lose_context');
            if (loseContext) {
                loseContext.loseContext();
            }
        }
    };
}

async function waitForCanvasRef(canvasRef, tries = 60, delayMs = 50) {
    for (let i = 0; i < tries; i += 1) {
        if (canvasRef.current) return canvasRef.current;
        await sleep(delayMs);
    }
    return null;
}

function GameRenderCanvas({ canvasRef }) {
    useEffect(() => {
        if (!canvasRef.current) return undefined;
        const renderer = createWatchGameRender(canvasRef.current);
        return () => {
            if (renderer) {
                renderer.remove();
            }
        };
    }, [canvasRef]);

    return <canvas id="gameRender" ref={canvasRef} className="hidden" width={window.innerWidth} height={window.innerHeight} />;
}

function ScreenWatchStreamer() {
    const [active, setActive] = useState(false);
    const canvasRef = useRef(null);
    const peerRef = useRef(null);
    const streamRef = useRef(null);
    const pendingIceRef = useRef([]);
    const disconnectTimerRef = useRef(null);

    const clearDisconnectTimer = () => {
        if (disconnectTimerRef.current) {
            window.clearTimeout(disconnectTimerRef.current);
            disconnectTimerRef.current = null;
        }
    };

    const cleanupPeer = async (notifyRemote = false) => {
        clearDisconnectTimer();

        const peer = peerRef.current;
        peerRef.current = null;
        if (peer) {
            peer.onicecandidate = null;
            peer.ontrack = null;
            peer.onconnectionstatechange = null;
            peer.oniceconnectionstatechange = null;
            try {
                peer.close();
            } catch (error) {}
        }

        const stream = streamRef.current;
        streamRef.current = null;
        if (stream) {
            stream.getTracks().forEach((track) => {
                try {
                    track.stop();
                } catch (error) {}
            });
        }

        pendingIceRef.current = [];
        setActive(false);

        if (notifyRemote && isNuiRuntime) {
            try {
                await nuiFetch('screenWatchClose', {});
            } catch (error) {}
        }
    };

    const flushPendingIce = async (peer) => {
        if (!peer || !peer.remoteDescription || !peer.remoteDescription.type) return;
        const items = pendingIceRef.current.slice();
        pendingIceRef.current = [];
        for (const candidate of items) {
            try {
                await peer.addIceCandidate(new RTCIceCandidate(candidate));
            } catch (error) {}
        }
    };

    const bindDisconnectHandlers = (peer) => {
        const scheduleDisconnect = () => {
            if (disconnectTimerRef.current) return;
            disconnectTimerRef.current = window.setTimeout(() => {
                disconnectTimerRef.current = null;
                cleanupPeer(true);
            }, SCREEN_WATCH_DISCONNECT_DELAY);
        };

        const handleStateChange = () => {
            const connectionState = peer.connectionState;
            const iceState = peer.iceConnectionState;
            if (connectionState === 'connected' || iceState === 'connected' || iceState === 'completed') {
                clearDisconnectTimer();
                return;
            }
            if (connectionState === 'failed' || iceState === 'failed') {
                cleanupPeer(true);
                return;
            }
            if (connectionState === 'disconnected' || iceState === 'disconnected') {
                scheduleDisconnect();
                return;
            }
            if (connectionState === 'closed') {
                cleanupPeer(false);
            }
        };

        peer.onconnectionstatechange = handleStateChange;
        peer.oniceconnectionstatechange = handleStateChange;
    };

    const ensurePeer = async () => {
        if (peerRef.current) return peerRef.current;

        setActive(true);
        await sleep(500);

        const canvas = await waitForCanvasRef(canvasRef);
        if (!canvas || typeof canvas.captureStream !== 'function') {
            return null;
        }

        canvas.width = window.innerWidth || canvas.width;
        canvas.height = window.innerHeight || canvas.height;

        const peer = new RTCPeerConnection(SCREEN_WATCH_RTC_CONFIG);
        const stream = canvas.captureStream(30);
        streamRef.current = stream;
        stream.getTracks().forEach((track) => peer.addTrack(track, stream));

        peer.onicecandidate = (event) => {
            if (event.candidate) {
                nuiFetch('screenWatchSignal', { type: 'ice', candidate: event.candidate }).catch(() => {});
            }
        };

        bindDisconnectHandlers(peer);
        peerRef.current = peer;
        return peer;
    };

    useEffect(() => {
        const onMessage = async (event) => {
            const msg = event.data;
            if (!msg?.action) return;

            if (msg.action === 'screenWatchRequested') {
                setActive(true);
                return;
            }

            if (msg.action === 'screenWatchClosed') {
                await cleanupPeer(false);
                return;
            }

            if (msg.action !== 'screenWatchSignal') return;

            const data = msg.data || {};
            if (data.type === 'close') {
                await cleanupPeer(false);
                return;
            }

            if (data.type === 'ice') {
                const candidate = data.candidate;
                if (!candidate) return;

                const peer = peerRef.current;
                if (!peer || !peer.remoteDescription || !peer.remoteDescription.type) {
                    pendingIceRef.current.push(candidate);
                    return;
                }

                try {
                    await peer.addIceCandidate(new RTCIceCandidate(candidate));
                } catch (error) {}
                return;
            }

            if (data.type !== 'offer' || !data.description) return;

            try {
                const peer = await ensurePeer();
                if (!peer) {
                    await cleanupPeer(true);
                    return;
                }

                await peer.setRemoteDescription(new RTCSessionDescription(data.description));
                await flushPendingIce(peer);

                const answer = await peer.createAnswer();
                await peer.setLocalDescription(answer);
                await nuiFetch('screenWatchSignal', { type: 'answer', description: peer.localDescription });
            } catch (error) {
                await cleanupPeer(true);
            }
        };

        window.addEventListener('message', onMessage);
        return () => {
            window.removeEventListener('message', onMessage);
            cleanupPeer(false);
        };
    }, []);

    if (!active) return null;
    return <GameRenderCanvas canvasRef={canvasRef} />;
}

function ScreenWatchModal({ open, player, config, onClose, sessionToken }) {
    const videoRef = useRef(null);
    const peerRef = useRef(null);
    const pendingIceRef = useRef([]);
    const disconnectTimerRef = useRef(null);
    const interactionRef = useRef(null);
    const [status, setStatus] = useState(lang(config, 'Admin.WatchStatus.Requesting', 'Đang yêu cầu xem màn hình người chơi...'));
    const [error, setError] = useState('');
    const [hasStream, setHasStream] = useState(false);
    const [bounds, setBounds] = useState(() => getScreenWatchBounds());

    const targetId = Number(player?.id || 0) || 0;

    const clearDisconnectTimer = () => {
        if (disconnectTimerRef.current) {
            window.clearTimeout(disconnectTimerRef.current);
            disconnectTimerRef.current = null;
        }
    };

    const cleanupPeer = async (notifyRemote = false) => {
        clearDisconnectTimer();

        const peer = peerRef.current;
        peerRef.current = null;
        if (peer) {
            peer.ontrack = null;
            peer.onicecandidate = null;
            peer.onconnectionstatechange = null;
            peer.oniceconnectionstatechange = null;
            try {
                peer.close();
            } catch (err) {}
        }

        pendingIceRef.current = [];
        setHasStream(false);

        if (videoRef.current && videoRef.current.srcObject) {
            videoRef.current.srcObject = null;
        }

        if (notifyRemote && isNuiRuntime) {
            try {
                await nuiFetch('screenWatchClose', {});
            } catch (err) {}
        }
    };

    const flushPendingIce = async (peer) => {
        if (!peer || !peer.remoteDescription || !peer.remoteDescription.type) return;
        const items = pendingIceRef.current.slice();
        pendingIceRef.current = [];
        for (const candidate of items) {
            try {
                await peer.addIceCandidate(new RTCIceCandidate(candidate));
            } catch (err) {}
        }
    };

    const bindDisconnectHandlers = (peer) => {
        const scheduleDisconnect = () => {
            if (disconnectTimerRef.current) return;
            disconnectTimerRef.current = window.setTimeout(() => {
                disconnectTimerRef.current = null;
                setError(lang(config, 'Admin.WatchFailed', 'Không thể kết nối xem màn hình người chơi.'));
                setStatus(lang(config, 'Admin.WatchStatus.Stopped', 'Đã ngắt kết nối xem màn hình.'));
                cleanupPeer(true);
            }, SCREEN_WATCH_DISCONNECT_DELAY);
        };

        const handleStateChange = () => {
            const connectionState = peer.connectionState;
            const iceState = peer.iceConnectionState;

            if (connectionState === 'new') {
                setStatus(lang(config, 'Admin.WatchStatus.Waiting', 'Đang chờ người chơi phản hồi...'));
                return;
            }

            if (connectionState === 'connecting' || iceState === 'checking') {
                clearDisconnectTimer();
                setStatus(lang(config, 'Admin.WatchStatus.Connecting', 'Đang kết nối luồng màn hình...'));
                return;
            }

            if (connectionState === 'connected' || iceState === 'connected' || iceState === 'completed') {
                clearDisconnectTimer();
                setError('');
                setStatus(lang(config, 'Admin.WatchStatus.Live', 'Đang xem màn hình người chơi.'));
                return;
            }

            if (connectionState === 'failed' || iceState === 'failed') {
                setError(lang(config, 'Admin.WatchFailed', 'Không thể kết nối xem màn hình người chơi.'));
                setStatus(lang(config, 'Admin.WatchStatus.Stopped', 'Đã ngắt kết nối xem màn hình.'));
                cleanupPeer(true);
                return;
            }

            if (connectionState === 'disconnected' || iceState === 'disconnected') {
                scheduleDisconnect();
                return;
            }

            if (connectionState === 'closed') {
                setStatus(lang(config, 'Admin.WatchStatus.Stopped', 'Đã ngắt kết nối xem màn hình.'));
            }
        };

        peer.onconnectionstatechange = handleStateChange;
        peer.oniceconnectionstatechange = handleStateChange;
    };

    useEffect(() => {
        if (!open) return undefined;
        setBounds((prev) => getScreenWatchBounds(prev?.width, prev?.height));

        const handleResize = () => {
            setBounds((prev) => getScreenWatchBounds(prev?.width, prev?.height, prev?.left, prev?.top));
        };

        const handleMouseMove = (event) => {
            const interaction = interactionRef.current;
            if (!interaction) return;

            if (interaction.mode === 'drag') {
                setBounds((prev) => {
                    const next = getScreenWatchBounds(prev.width, prev.height, interaction.startLeft + (event.clientX - interaction.startX), interaction.startTop + (event.clientY - interaction.startY));
                    return (next.left === prev.left && next.top === prev.top) ? prev : { ...prev, left: next.left, top: next.top, maxWidth: next.maxWidth, maxHeight: next.maxHeight, minWidth: next.minWidth, minHeight: next.minHeight };
                });
                return;
            }

            if (interaction.mode === 'resize') {
                setBounds((prev) => {
                    const next = getScreenWatchBounds(interaction.startWidth + (event.clientX - interaction.startX), interaction.startHeight + (event.clientY - interaction.startY), prev.left, prev.top);
                    return (next.width === prev.width && next.height === prev.height) ? prev : { ...prev, width: next.width, height: next.height, maxWidth: next.maxWidth, maxHeight: next.maxHeight, minWidth: next.minWidth, minHeight: next.minHeight };
                });
            }
        };

        const stopInteraction = () => {
            interactionRef.current = null;
        };

        window.addEventListener('resize', handleResize);
        window.addEventListener('mousemove', handleMouseMove);
        window.addEventListener('mouseup', stopInteraction);

        return () => {
            interactionRef.current = null;
            window.removeEventListener('resize', handleResize);
            window.removeEventListener('mousemove', handleMouseMove);
            window.removeEventListener('mouseup', stopInteraction);
        };
    }, [open, sessionToken]);

    const beginMove = (event) => {
        if (event.button !== 0) return;
        if (event.target instanceof Element && event.target.closest('button')) return;
        event.preventDefault();
        interactionRef.current = {
            mode: 'drag',
            startX: event.clientX,
            startY: event.clientY,
            startLeft: bounds.left,
            startTop: bounds.top,
        };
    };

    const beginResize = (event) => {
        if (event.button !== 0) return;
        event.preventDefault();
        interactionRef.current = {
            mode: 'resize',
            startX: event.clientX,
            startY: event.clientY,
            startWidth: bounds.width,
            startHeight: bounds.height,
        };
    };

    useEffect(() => {
        if (!open || targetId <= 0) return undefined;

        let cancelled = false;

        const handleSignal = async (data) => {
            const peer = peerRef.current;
            if (!peer) return;

            if (data.type === 'close') {
                setError(lang(config, 'Admin.WatchClosed', 'Người chơi đã dừng chia sẻ màn hình.'));
                setStatus(lang(config, 'Admin.WatchStatus.Stopped', 'Đã ngắt kết nối xem màn hình.'));
                await cleanupPeer(false);
                return;
            }

            if (data.type === 'ice') {
                if (!data.candidate) return;
                if (!peer.remoteDescription || !peer.remoteDescription.type) {
                    pendingIceRef.current.push(data.candidate);
                    return;
                }
                try {
                    await peer.addIceCandidate(new RTCIceCandidate(data.candidate));
                } catch (err) {}
                return;
            }

            if (data.type !== 'answer' || !data.description) return;

            try {
                await peer.setRemoteDescription(new RTCSessionDescription(data.description));
                await flushPendingIce(peer);
                setStatus(lang(config, 'Admin.WatchStatus.Connecting', 'Đang kết nối luồng màn hình...'));
            } catch (err) {
                setError(lang(config, 'Admin.WatchFailed', 'Không thể kết nối xem màn hình người chơi.'));
                setStatus(lang(config, 'Admin.WatchStatus.Failed', 'Yêu cầu xem màn hình thất bại.'));
            }
        };

        const onMessage = (event) => {
            const msg = event.data;
            if (!msg?.action) return;

            if (msg.action === 'screenWatchClosed') {
                setError(lang(config, 'Admin.WatchClosed', 'Người chơi đã dừng chia sẻ màn hình.'));
                setStatus(lang(config, 'Admin.WatchStatus.Stopped', 'Đã ngắt kết nối xem màn hình.'));
                cleanupPeer(false);
                return;
            }

            if (msg.action === 'screenWatchSignal') {
                handleSignal(msg.data || {});
            }
        };

        const startWatch = async () => {
            setError('');
            setHasStream(false);
            setStatus(lang(config, 'Admin.WatchStatus.Requesting', 'Đang yêu cầu xem màn hình người chơi...'));

            const response = await nuiFetch('screenWatchRequest', { id: targetId });
            if (cancelled) return;

            if (!response?.ok) {
                setError(response?.message || lang(config, 'Admin.WatchFailed', 'Không thể kết nối xem màn hình người chơi.'));
                setStatus(lang(config, 'Admin.WatchStatus.Failed', 'Yêu cầu xem màn hình thất bại.'));
                return;
            }

            try {
                const peer = new RTCPeerConnection(SCREEN_WATCH_RTC_CONFIG);
                peerRef.current = peer;

                peer.ontrack = (event) => {
                    const stream = event.streams?.[0] || new MediaStream([event.track]);
                    if (videoRef.current && videoRef.current.srcObject !== stream) {
                        videoRef.current.srcObject = stream;
                        videoRef.current.play?.().catch(() => {});
                    }
                    setHasStream(true);
                    setError('');
                    setStatus(lang(config, 'Admin.WatchStatus.Live', 'Đang xem màn hình người chơi.'));
                };

                peer.onicecandidate = (event) => {
                    if (event.candidate) {
                        nuiFetch('screenWatchSignal', { type: 'ice', candidate: event.candidate }).catch(() => {});
                    }
                };

                bindDisconnectHandlers(peer);

                peer.addTransceiver('video', { direction: 'recvonly' });
                const offer = await peer.createOffer({ offerToReceiveVideo: true, offerToReceiveAudio: false });
                await peer.setLocalDescription(offer);
                await nuiFetch('screenWatchSignal', { type: 'offer', description: peer.localDescription });
                setStatus(lang(config, 'Admin.WatchStatus.Waiting', 'Đang chờ người chơi phản hồi...'));
            } catch (err) {
                setError(lang(config, 'Admin.WatchFailed', 'Không thể kết nối xem màn hình người chơi.'));
                setStatus(lang(config, 'Admin.WatchStatus.Failed', 'Yêu cầu xem màn hình thất bại.'));
                await cleanupPeer(true);
            }
        };

        window.addEventListener('message', onMessage);
        startWatch();

        return () => {
            cancelled = true;
            window.removeEventListener('message', onMessage);
            cleanupPeer(true);
        };
    }, [open, targetId, sessionToken, config]);

    if (!open) return null;

    return (
        <Modal open={open} onBackdropClick={onClose} extraClass="screen-watch-modal">
            <div
                className="modal-card screen-watch-card"
                style={{
                    left: `${bounds.left}px`,
                    top: `${bounds.top}px`,
                    width: `${bounds.width}px`,
                    height: `${bounds.height}px`,
                    transform: 'none',
                    maxHeight: 'none',
                }}
            >
                <div className="modal-header screen-watch-header" onMouseDown={beginMove}>
                    <div className="modal-title">{lang(config, 'Admin.WatchTitle', 'THEO DÕI MÀN HÌNH')} - {getAdminHeaderText(config, player, player)}</div>
                    <div className="screen-watch-header-actions">
                        <button className="btn btn-ghost" onClick={onClose}>{lang(config, 'Buttons.Close', 'Đóng')}</button>
                    </div>
                </div>
                <div className="modal-body screen-watch-body">
                    <div className="screen-watch-frame">
                        <video ref={videoRef} className="screen-watch-video" autoPlay playsInline muted />
                        {!!error && <div className="screen-watch-placeholder"><div>{error}</div></div>}
                        {!error && !hasStream && (
                            <div className="screen-watch-placeholder">
                                <div>{lang(config, 'Admin.WatchPlaceholder', 'Đang chờ hình ảnh từ màn hình người chơi...')}</div>
                            </div>
                        )}
                    </div>
                </div>
                <div className="screen-watch-resize-handle" onMouseDown={beginResize} />
            </div>
        </Modal>
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
    const [showNames, setShowNames] = useState(false);
    const [banListModal, setBanListModal] = useState({ open: false, loading: false, items: [], error: '', busyId: '' });
    const [adminModal, setAdminModal] = useState({ open: false, loading: false, player: null, data: null, error: '', busy: false });
    const [watchModal, setWatchModal] = useState({ open: false, player: null, token: 0 });

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
                setShowNames(false);
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
                setBanListModal({ open: false, loading: false, items: [], error: '', busyId: '' });
                setAdminModal({ open: false, loading: false, player: null, data: null, error: '', busy: false });
                setWatchModal({ open: false, player: null, token: 0 });
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
        if (!visible) {
            setShowNames(false);
            return undefined;
        }

        let cancelled = false;
        nuiFetch('requestPlayerNamesState', {})
            .then((resp) => {
                if (cancelled) return;
                if (resp?.ok) {
                    setShowNames(!!resp.enabled);
                } else {
                    setShowNames(false);
                }
            })
            .catch(() => {
                if (!cancelled) {
                    setShowNames(false);
                }
            });

        return () => {
            cancelled = true;
        };
    }, [visible]);

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

    const closeAdminModal = () => {
        setAdminModal({ open: false, loading: false, player: null, data: null, error: '', busy: false });
    };

    const closeWatchModal = () => {
        setWatchModal({ open: false, player: null, token: 0 });
    };

    const openAdminModal = async (player) => {
        if (!player?.citizenid && !player?.id) return;
        setAdminModal({ open: true, loading: true, player, data: null, error: '', busy: false });
        try {
            const response = await nuiFetch('requestAdminProfile', { citizenid: player.citizenid, id: player.id });
            if (response?.ok) {
                setAdminModal({ open: true, loading: false, player, data: response.player || response.data || null, error: '', busy: false });
            } else {
                setAdminModal({ open: true, loading: false, player, data: null, error: response?.message || lang(config, 'Common.Error', 'error'), busy: false });
            }
        } catch (error) {
            setAdminModal({ open: true, loading: false, player, data: null, error: lang(config, 'Admin.ErrorFetch', 'Không lấy được dữ liệu admin: {message}', { message: 'error' }), busy: false });
        }
    };

    const openWatchModal = () => {
        const target = adminModal.data || adminModal.player || null;
        const targetId = Number(target?.id || 0) || 0;
        if (targetId <= 0) return;
        setWatchModal({ open: true, player: target, token: Date.now() });
    };

    const runAdminAction = async (action) => {
        const targetId = Number(adminModal.data?.id || adminModal.player?.id || 0) || 0;
        setAdminModal((prev) => ({ ...prev, busy: true, error: '' }));
        try {
            const response = await nuiFetch('adminAction', {
                action,
                id: targetId,
                citizenid: adminModal.data?.citizenid || adminModal.player?.citizenid || '',
            });

            if (response?.ok) {
                setAdminModal((prev) => ({ ...prev, busy: false, error: '' }));
                if (action !== 'spectate') {
                    await doRefresh();
                }
                if (action === 'kick' || action === 'ban') {
                    closeAdminModal();
                }
            } else if (response?.cancelled) {
                setAdminModal((prev) => ({ ...prev, busy: false }));
            } else {
                setAdminModal((prev) => ({ ...prev, busy: false, error: response?.message || lang(config, 'Admin.ActionError', 'Không thể thực hiện thao tác: {message}', { message: lang(config, 'Common.Error', 'error') }) }));
            }
        } catch (error) {
            setAdminModal((prev) => ({ ...prev, busy: false, error: lang(config, 'Admin.ActionError', 'Không thể thực hiện thao tác: {message}', { message: 'error' }) }));
        }
    };

    const togglePlayerNames = async () => {
        try {
            const response = await nuiFetch('togglePlayerNames', {});
            if (response?.ok) {
                setShowNames(!!response.enabled);
            }
        } catch (error) {}
    };

    const closeBanListModal = () => {
        setBanListModal({ open: false, loading: false, items: [], error: '', busyId: '' });
    };

    const openBanListModal = async () => {
        setBanListModal({ open: true, loading: true, items: [], error: '', busyId: '' });
        try {
            const response = await nuiFetch('requestBanList', {});
            if (response?.ok) {
                setBanListModal({ open: true, loading: false, items: Array.isArray(response.items) ? response.items : [], error: '', busyId: '' });
            } else {
                setBanListModal({ open: true, loading: false, items: [], error: response?.message || lang(config, 'Bans.ErrorFetch', 'Không lấy được danh sách ban: {message}', { message: lang(config, 'Common.Error', 'error') }), busyId: '' });
            }
        } catch (error) {
            setBanListModal({ open: true, loading: false, items: [], error: lang(config, 'Bans.ErrorFetch', 'Không lấy được danh sách ban: {message}', { message: 'error' }), busyId: '' });
        }
    };

    const unbanEntry = async (banId) => {
        if (!banId) return;
        setBanListModal((prev) => ({ ...prev, busyId: banId, error: '' }));
        try {
            const response = await nuiFetch('unbanBan', { banId });
            if (response?.ok) {
                setBanListModal((prev) => ({
                    ...prev,
                    busyId: '',
                    items: Array.isArray(prev.items) ? prev.items.filter((item) => item.id !== banId) : [],
                }));
            } else {
                setBanListModal((prev) => ({ ...prev, busyId: '', error: response?.message || lang(config, 'Bans.ErrorUnban', 'Không thể unban: {message}', { message: lang(config, 'Common.Error', 'error') }) }));
            }
        } catch (error) {
            setBanListModal((prev) => ({ ...prev, busyId: '', error: lang(config, 'Bans.ErrorUnban', 'Không thể unban: {message}', { message: 'error' }) }));
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

    useEffect(() => {
        if (!visible) return undefined;

        const onKeyDown = (event) => {
            if (event.key !== 'Escape') return;
            if (event.defaultPrevented) return;

            const activeTag = document.activeElement?.tagName?.toLowerCase();
            const activeValue = typeof document.activeElement?.value === 'string' ? document.activeElement.value : '';
            const isTyping = activeTag === 'input' || activeTag === 'textarea' || activeTag === 'select' || document.activeElement?.isContentEditable;
            if (isTyping && String(activeValue).trim()) return;

            event.preventDefault();
            if (watchModal.open) {
                closeWatchModal();
                return;
            }
            if (imageModal.open) {
                setImageModal({ open: false, title: '', sub: '', src: '' });
                return;
            }
            if (inventoryModal.open) {
                closeInventoryModal();
                return;
            }
            if (chartModal.open) {
                closeChartModal();
                return;
            }
            if (logModal.open) {
                closeLogModal();
                return;
            }
            if (susModal.open) {
                closeSusModal();
                return;
            }
            if (banListModal.open) {
                closeBanListModal();
                return;
            }
            if (adminModal.open) {
                closeAdminModal();
                return;
            }
            doClose();
        };

        window.addEventListener('keydown', onKeyDown);
        return () => window.removeEventListener('keydown', onKeyDown);
    }, [visible, watchModal.open, imageModal.open, inventoryModal.open, chartModal.open, logModal.open, susModal.open, banListModal.open, adminModal.open]);

    if (!visible) return <div id="app" className="hidden"><ScreenWatchStreamer /></div>;

    const adminProfile = adminModal.data || adminModal.player || {};
    const adminTargetOnline = !!(Number(adminProfile?.id || 0) > 0 && adminProfile?.isOnline !== false);
    const adminActionButtons = [
        { key: 'kick', icon: '⛔', title: lang(config, 'Admin.Actions.Kick', 'Kick người đó'), tooltip: lang(config, 'Admin.Tooltips.Kick', 'Kick') },
        { key: 'ban', icon: '🚫', title: lang(config, 'Admin.Actions.Ban', 'Ban người đó'), tooltip: lang(config, 'Admin.Tooltips.Ban', 'Ban') },
        { key: 'goto', icon: '➜', title: lang(config, 'Admin.Actions.Goto', 'Dịch chuyển đến người đó'), tooltip: lang(config, 'Admin.Tooltips.Goto', 'Goto') },
        { key: 'bring', icon: '⇠', title: lang(config, 'Admin.Actions.Bring', 'Kéo người đó về phía mình'), tooltip: lang(config, 'Admin.Tooltips.Bring', 'Bring') },
        { key: 'revive', icon: '❤', title: lang(config, 'Admin.Actions.Revive', 'Hồi sinh người đó'), tooltip: lang(config, 'Admin.Tooltips.Revive', 'Revive') },
        { key: 'spectate', icon: '👁', title: lang(config, 'Admin.Actions.Spectate', 'Theo dõi người đó'), tooltip: lang(config, 'Admin.Tooltips.Spectate', 'Spectate') },
        { key: 'watch', icon: '🖥', title: lang(config, 'Admin.Actions.Watch', 'Theo dõi màn hình người đó'), tooltip: lang(config, 'Admin.Tooltips.Watch', 'Watch') },
    ];

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
                        <button className={`btn ${showNames ? 'btn-active' : ''}`} onClick={togglePlayerNames}>{showNames ? lang(config, 'Buttons.HideNames', 'Ẩn tên') : lang(config, 'Buttons.ShowNames', 'Hiện tên')}</button>
                        <button className="btn" onClick={doRefresh}>{lang(config, 'Buttons.Refresh', 'Refresh')}</button>
                        <button className="btn" onClick={openBanListModal}>{lang(config, 'Buttons.BanList', 'List ban')}</button>
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
                                                        <button className="btn btn-mini btn-inline btn-admin" onClick={() => openAdminModal(player)}>{lang(config, 'Buttons.Admin', 'ADMIN')}</button>
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

            <Modal open={adminModal.open} onBackdropClick={closeAdminModal} extraClass="admin-modal">
                <div className="modal-card admin-modal-card">
                    <div className="modal-header">
                        <div className="modal-title admin-modal-title">{getAdminHeaderText(config, adminModal.data, adminModal.player)}</div>
                        <button className="btn btn-ghost" onClick={closeAdminModal}>{lang(config, 'Buttons.Close', 'Đóng')}</button>
                    </div>
                    <div className="modal-body admin-modal-body">
                        {adminModal.loading && <div className="modal-empty">{lang(config, 'Admin.Loading', 'Đang tải dữ liệu admin...')}</div>}
                        {!adminModal.loading && adminModal.error && <div className="modal-empty">{adminModal.error}</div>}
                        {!adminModal.loading && !adminModal.error && (
                            <>
                                <div className="admin-section">
                                    <div className="admin-section-title">{lang(config, 'Admin.ActionsTitle', 'Hành động')}</div>
                                    <div className="admin-quick-actions">
                                        {adminActionButtons.map((button) => (
                                            <button
                                                key={button.key}
                                                className={`admin-quick-btn ${button.key === 'ban' ? 'is-danger' : ''}`}
                                                title={button.tooltip}
                                                data-tooltip={button.tooltip}
                                                aria-label={button.tooltip}
                                                disabled={!adminTargetOnline || adminModal.busy}
                                                onClick={() => (button.key === 'watch' ? openWatchModal() : runAdminAction(button.key))}
                                            >
                                                <span>{button.icon}</span>
                                            </button>
                                        ))}
                                    </div>
                                    {!adminTargetOnline && <div className="admin-note">{lang(config, 'Admin.NoTargetId', 'Người chơi này không online để dùng thao tác nhanh.')}</div>}
                                </div>

                                <div className="admin-section">
                                    <div className="admin-section-title">{lang(config, 'Admin.AccountsTitle', 'Tài khoản')}</div>
                                    <div className="admin-field-list">
                                        <div className="admin-field-row"><span>ID Steam</span><strong>{adminFieldValue(config, adminProfile.steam)}</strong></div>
                                        <div className="admin-field-row"><span>ID Discord</span><strong>{adminFieldValue(config, adminProfile.discord)}</strong></div>
                                        <div className="admin-field-row"><span>License</span><strong>{adminFieldValue(config, adminProfile.license)}</strong></div>
                                        <div className="admin-field-row"><span>License 2</span><strong>{adminFieldValue(config, adminProfile.license2)}</strong></div>
                                        <div className="admin-field-row"><span>IP</span><strong>{adminFieldValue(config, adminProfile.ip)}</strong></div>
                                    </div>
                                </div>

                                <div className="admin-section">
                                    <div className="admin-section-title">{lang(config, 'Admin.InformationTitle', 'Thông tin')}</div>
                                    <div className="admin-field-list">
                                        <div className="admin-field-row"><span>CitizenID</span><strong>{adminFieldValue(config, adminProfile.citizenid)}</strong></div>
                                        <div className="admin-field-row"><span>{lang(config, 'Admin.Fields.CharacterName', 'Tên nhân vật')}</span><strong>{adminFieldValue(config, adminProfile.name)}</strong></div>
                                        <div className="admin-field-row"><span>Job</span><strong>{adminFieldValue(config, adminProfile.job)}</strong></div>
                                        <div className="admin-field-row"><span>Cash</span><strong>{adminFieldValue(config, adminProfile.cash)}</strong></div>
                                        <div className="admin-field-row"><span>Bank</span><strong>{adminFieldValue(config, adminProfile.bank)}</strong></div>
                                        <div className="admin-field-row"><span>{lang(config, 'Admin.Fields.Gender', 'Giới tính')}</span><strong>{adminFieldValue(config, adminProfile.gender)}</strong></div>
                                    </div>
                                </div>
                            </>
                        )}
                    </div>
                </div>
            </Modal>

            <ScreenWatchModal open={watchModal.open} player={watchModal.player} sessionToken={watchModal.token} config={config} onClose={closeWatchModal} />

            <Modal open={banListModal.open} onBackdropClick={closeBanListModal} extraClass="ban-list-modal">
                <div className="modal-card ban-list-modal-card">
                    <div className="modal-header">
                        <div className="modal-title">{lang(config, 'Bans.Title', 'DANH SÁCH BAN')}</div>
                        <button className="btn btn-ghost" onClick={closeBanListModal}>{lang(config, 'Buttons.Close', 'Đóng')}</button>
                    </div>
                    <div className="modal-body ban-list-body">
                        {banListModal.loading && <div className="modal-empty">{lang(config, 'Bans.Loading', 'Đang tải danh sách ban...')}</div>}
                        {!banListModal.loading && banListModal.error && <div className="modal-empty">{banListModal.error}</div>}
                        {!banListModal.loading && !banListModal.error && !banListModal.items.length && <div className="modal-empty">{lang(config, 'Bans.Empty', 'Không có người chơi nào đang bị ban.')}</div>}
                        {!banListModal.loading && !banListModal.error && banListModal.items.map((ban) => (
                            <div key={ban.id} className="ban-list-card">
                                <div className="ban-list-top">
                                    <div>
                                        <div className="ban-list-name">{ban.characterName || ban.steamName || lang(config, 'Common.Unknown', 'Unknown')}</div>
                                        <div className="ban-list-sub">ID Steam: {adminFieldValue(config, ban.steam)} • CitizenID: {adminFieldValue(config, ban.citizenid)}</div>
                                    </div>
                                    <button className="btn btn-small btn-danger" disabled={banListModal.busyId === ban.id} onClick={() => unbanEntry(ban.id)}>{lang(config, 'Bans.Unban', 'Unban')}</button>
                                </div>
                                <div className="ban-list-grid">
                                    <div className="ban-list-field"><span>{lang(config, 'Bans.Reason', 'Lý do')}</span><strong>{adminFieldValue(config, ban.reason)}</strong></div>
                                    <div className="ban-list-field"><span>{lang(config, 'Bans.Expires', 'Hết hạn')}</span><strong>{formatBanExpireText(config, ban.expire)}</strong></div>
                                    <div className="ban-list-field"><span>{lang(config, 'Bans.BannedBy', 'Ban bởi')}</span><strong>{adminFieldValue(config, ban.bannedBy)}</strong></div>
                                    <div className="ban-list-field"><span>License</span><strong>{adminFieldValue(config, ban.license)}</strong></div>
                                    <div className="ban-list-field"><span>License 2</span><strong>{adminFieldValue(config, ban.license2)}</strong></div>
                                    <div className="ban-list-field"><span>ID Discord</span><strong>{adminFieldValue(config, ban.discord)}</strong></div>
                                    <div className="ban-list-field"><span>IP</span><strong>{adminFieldValue(config, ban.ip)}</strong></div>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </Modal>

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
            <ScreenWatchStreamer />
        </div>
    );
}

export default App;
