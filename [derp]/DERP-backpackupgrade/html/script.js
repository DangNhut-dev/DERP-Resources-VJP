'use strict';

// ── Constants ─────────────────────────────────────────────────────
const TWO_PI      = Math.PI * 2;
const SPIN_MS     = 16000;  // 16s tổng: 15s quay + 1s giữ
const SPIN_ROUNDS = 8;

// ── Audio ─────────────────────────────────────────────────────────
const _spinAudio = new Audio('assets/spin.mp3');
_spinAudio.loop   = true;
_spinAudio.volume = 0;

function startSpinAudio() {
    _spinAudio.currentTime = 0;
    _spinAudio.volume      = 0;
    _spinAudio.play().catch(() => {});
}

function stopSpinAudio() {
    _spinAudio.pause();
    _spinAudio.currentTime = 0;
    _spinAudio.volume      = 0;
}

// Volume theo speedNorm: to lúc nhanh, nhỏ dần khi giảm tốc
function updateSpinVolume(speedNorm) {
    _spinAudio.volume = Math.min(Math.max(speedNorm * 0.75, 0), 1);
}

const AudioCtx = window.AudioContext || window.webkitAudioContext;
let _audioCtx  = null;

function getAudioCtx() {
    if (!_audioCtx) _audioCtx = new AudioCtx();
    return _audioCtx;
}

// Tiếng thắng/thua sau khi kim dừng
function playResult(isWin) {
    try {
        const ctx = getAudioCtx();
        if (isWin) {
            // Hợp âm C major arpeggio lên - sáng, rõ ràng
            const notes = [523, 659, 784, 1047]; // C5 E5 G5 C6
            notes.forEach((freq, i) => {
                const delay = i * 0.1;
                const osc  = ctx.createOscillator();
                const gain = ctx.createGain();
                osc.connect(gain);
                gain.connect(ctx.destination);
                osc.frequency.value = freq;
                osc.type = 'sine';
                gain.gain.setValueAtTime(0, ctx.currentTime + delay);
                gain.gain.linearRampToValueAtTime(0.2, ctx.currentTime + delay + 0.04);
                gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + delay + 0.6);
                osc.start(ctx.currentTime + delay);
                osc.stop(ctx.currentTime + delay + 0.65);
            });
            // Shimmer layer
            const shimmer = ctx.createOscillator();
            const sGain   = ctx.createGain();
            shimmer.connect(sGain);
            sGain.connect(ctx.destination);
            shimmer.frequency.value = 1568; // G6
            shimmer.type = 'sine';
            sGain.gain.setValueAtTime(0, ctx.currentTime + 0.3);
            sGain.gain.linearRampToValueAtTime(0.08, ctx.currentTime + 0.35);
            sGain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 1.2);
            shimmer.start(ctx.currentTime + 0.3);
            shimmer.stop(ctx.currentTime + 1.25);
        } else {
            // Hai nốt descending minor - nhẹ nhàng, không chói
            const notes = [392, 311]; // G4 Eb4
            notes.forEach((freq, i) => {
                const delay = i * 0.2;
                const osc  = ctx.createOscillator();
                const gain = ctx.createGain();
                osc.connect(gain);
                gain.connect(ctx.destination);
                osc.frequency.value = freq;
                osc.type = 'triangle';
                gain.gain.setValueAtTime(0, ctx.currentTime + delay);
                gain.gain.linearRampToValueAtTime(0.15, ctx.currentTime + delay + 0.05);
                gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + delay + 0.5);
                osc.start(ctx.currentTime + delay);
                osc.stop(ctx.currentTime + delay + 0.55);
            });
        }
    } catch (_) {}
}

// ── State ─────────────────────────────────────────────────────────
const state = {
    resourceName     : 'DERP-backpackupgrade',
    balos            : [],
    materials        : [],
    selectedBalo     : null,
    selectedMaterials: [],
    isSpinning       : false,
    arcLockedIn      : false,
    cfg              : { rarityPoints:{}, requirePoints:{}, maxMaterialSlots:5 },

    arcStartDeg   : 0,
    arcSizeDeg    : 0,
    needleAngle   : 0,

    dragActive    : false,
    dragStartAngle: 0,
    dragArcStart  : 0,
};

// ── Elements ───────────────────────────────────────────────────────
const E = {
    app        : document.getElementById('app'),
    baloGrid   : document.getElementById('balo-grid'),
    matGrid    : document.getElementById('mat-grid'),
    matCount   : document.getElementById('mat-count'),
    lvDisplay  : document.getElementById('lv-display'),
    hintText   : document.getElementById('hint-text'),
    canvas     : document.getElementById('wheel-canvas'),
    btnUpgrade : document.getElementById('btn-upgrade'),
    btnClose   : document.getElementById('btn-close'),
};

const ctx     = E.canvas.getContext('2d');
const CX      = 150;
const CY      = 150;
const R       = 120;
const R_INNER = 60;

// ── Helpers ────────────────────────────────────────────────────────
function imgUrl(item) {
    if (typeof item === 'string') return `https://newscity.top/fivem/items101/${item}.png`;
    const meta = item.metadata || {};
    const draw = meta.drawableId != null ? meta.drawableId : '';
    const tex  = meta.textureId  != null ? meta.textureId  : '';
    const gen  = meta.gender     != null ? meta.gender     : '';
    if (draw !== '' && tex !== '' && gen !== '') {
        return `https://newscity.top/fivem/items101/${item.name}_${draw}_${tex}_${gen}.png`;
    }
    return `https://newscity.top/fivem/items101/${item.name}.png`;
}
function degToRad(d)  { return d * Math.PI / 180; }
function radToDeg(r)  { return r * 180 / Math.PI; }

function calcChance() {
    if (!state.selectedBalo) return 0;
    const lv  = (state.selectedBalo.metadata && state.selectedBalo.metadata.level) || 0;
    const req = state.cfg.requirePoints[lv];
    if (!req) return 0;
    let pts = 0;
    for (const m of state.selectedMaterials) pts += (state.cfg.rarityPoints[m.rarity] || 0);
    return Math.min(pts / req, 1.0);
}

function getMouseAngle(e) {
    const rect = E.canvas.getBoundingClientRect();
    const mx = e.clientX - rect.left - CX;
    const my = e.clientY - rect.top  - CY;
    return radToDeg(Math.atan2(my, mx)) + 90;
}

// ── Draw helpers ───────────────────────────────────────────────────
function drawWheelBase() {
    ctx.beginPath();
    ctx.arc(CX, CY, R, 0, TWO_PI);
    ctx.arc(CX, CY, R_INNER, 0, TWO_PI, true);
    ctx.fillStyle = '#0f0f18';
    ctx.fill();

    ctx.beginPath();
    ctx.arc(CX, CY, R, 0, TWO_PI);
    ctx.strokeStyle = '#1a1a28';
    ctx.lineWidth = 2;
    ctx.stroke();

    ctx.beginPath();
    ctx.arc(CX, CY, R_INNER, 0, TWO_PI);
    ctx.strokeStyle = '#1a1a28';
    ctx.lineWidth = 1;
    ctx.stroke();

    for (let i = 0; i < 60; i++) {
        const a   = degToRad(i * 6 - 90);
        const big = i % 5 === 0;
        const r1  = R - (big ? 10 : 5);
        ctx.beginPath();
        ctx.moveTo(CX + Math.cos(a) * R,  CY + Math.sin(a) * R);
        ctx.lineTo(CX + Math.cos(a) * r1, CY + Math.sin(a) * r1);
        ctx.strokeStyle = big ? '#2a2a40' : '#1e1e2c';
        ctx.lineWidth   = big ? 1.5 : 0.8;
        ctx.stroke();
    }

    if (state.arcSizeDeg > 0) {
        const halfDeg = state.arcSizeDeg / 2;
        const chance  = state.arcSizeDeg / 360;
        let arcColor;
        if (chance >= 0.7)      arcColor = '#00cc66';
        else if (chance >= 0.4) arcColor = '#05F2F2';
        else if (chance >= 0.2) arcColor = '#ffaa22';
        else                    arcColor = '#ff4422';

        const arcOffsets = [state.arcStartDeg, (state.arcStartDeg + 180) % 360];
        for (const offset of arcOffsets) {
            const startRad = degToRad(offset - 90);
            const endRad   = degToRad(offset + halfDeg - 90);

            ctx.beginPath();
            ctx.arc(CX, CY, R - 1,       startRad, endRad, false);
            ctx.arc(CX, CY, R_INNER + 1, endRad, startRad, true);
            ctx.closePath();
            ctx.fillStyle = arcColor + '30';
            ctx.fill();

            ctx.beginPath();
            ctx.arc(CX, CY, R - 1, startRad, endRad, false);
            ctx.strokeStyle = arcColor;
            ctx.lineWidth = 3;
            ctx.stroke();

            ctx.beginPath();
            ctx.arc(CX, CY, R_INNER + 1, startRad, endRad, false);
            ctx.strokeStyle = arcColor + '80';
            ctx.lineWidth = 1.5;
            ctx.stroke();

            for (const a of [startRad, endRad]) {
                ctx.beginPath();
                ctx.moveTo(CX + Math.cos(a) * R_INNER, CY + Math.sin(a) * R_INNER);
                ctx.lineTo(CX + Math.cos(a) * R,       CY + Math.sin(a) * R);
                ctx.strokeStyle = arcColor;
                ctx.lineWidth = 2;
                ctx.stroke();
            }
        }
    }
}

function drawCenterCap() {
    ctx.beginPath();
    ctx.arc(CX, CY, 8, 0, TWO_PI);
    ctx.fillStyle = '#05F2F2';
    ctx.fill();
    ctx.beginPath();
    ctx.arc(CX, CY, 5, 0, TWO_PI);
    ctx.fillStyle = '#0b0b10';
    ctx.fill();
}

function drawNeedle(angleDeg, speedNorm) {
    const rad  = degToRad(angleDeg - 90);
    const tipX = CX + Math.cos(rad) * (R - 6);
    const tipY = CY + Math.sin(rad) * (R - 6);

    if (speedNorm > 0.06) {
        const steps = 5;
        for (let i = steps; i >= 1; i--) {
            const off   = i * speedNorm * 13;
            const tr    = degToRad(angleDeg - off - 90);
            const tx    = CX + Math.cos(tr) * (R - 6);
            const ty    = CY + Math.sin(tr) * (R - 6);
            const alpha = (1 - i / (steps + 1)) * speedNorm * 0.28;
            ctx.save();
            ctx.globalAlpha = alpha;
            ctx.beginPath();
            ctx.moveTo(CX, CY);
            ctx.lineTo(tx, ty);
            ctx.strokeStyle = '#ff5522';
            ctx.lineWidth   = 2.5;
            ctx.lineCap     = 'round';
            ctx.stroke();
            ctx.restore();
        }
    }

    ctx.beginPath();
    ctx.moveTo(CX, CY);
    ctx.lineTo(tipX, tipY);
    ctx.strokeStyle = 'rgba(0,0,0,0.5)';
    ctx.lineWidth   = 5;
    ctx.lineCap     = 'round';
    ctx.stroke();

    const grad = ctx.createLinearGradient(CX, CY, tipX, tipY);
    grad.addColorStop(0,   '#ffffff');
    grad.addColorStop(0.7, '#ff8844');
    grad.addColorStop(1,   '#ff2233');
    ctx.beginPath();
    ctx.moveTo(CX, CY);
    ctx.lineTo(tipX, tipY);
    ctx.strokeStyle = grad;
    ctx.lineWidth   = 3;
    ctx.lineCap     = 'round';
    ctx.stroke();

    const arrowLen = 10;
    const arrowW   = degToRad(25);
    const backRad  = rad + Math.PI;
    ctx.beginPath();
    ctx.moveTo(tipX, tipY);
    ctx.lineTo(tipX + Math.cos(backRad - arrowW) * arrowLen, tipY + Math.sin(backRad - arrowW) * arrowLen);
    ctx.lineTo(tipX + Math.cos(backRad + arrowW) * arrowLen, tipY + Math.sin(backRad + arrowW) * arrowLen);
    ctx.closePath();
    ctx.fillStyle = '#ff2233';
    ctx.fill();
}

function drawWheel() {
    ctx.clearRect(0, 0, 300, 300);
    drawWheelBase();
    drawNeedle(state.needleAngle, 0);
    drawCenterCap();
}

// ── Needle animation ───────────────────────────────────────────────
// Bắt đầu nhanh ngay từ t=0, ease-out sextic giảm dần suốt 15s
// Overshoot nhẹ ở cuối rồi kéo về. Giây 15→16: giữ nguyên vị trí.
function spinEasing(t) {
    const STOP_AT = 15 / 16; // dừng tại 15s trong tổng 16s
    if (t >= STOP_AT) return 1.0;
    const u  = t / STOP_AT;
    const c1 = 0.14;
    const c3 = c1 + 1;
    return 1 + c3 * Math.pow(u - 1, 3) + c1 * Math.pow(u - 1, 2);
}

function spinDerivative(t) {
    const h = 0.0008;
    return (spinEasing(Math.min(t + h, 1)) - spinEasing(Math.max(t - h, 0))) / (h * 2);
}

function animateNeedle(targetDeg, onDone) {
    const startAngle = state.needleAngle;
    const fullSpin   = SPIN_ROUNDS * 360;
    const rawDelta   = ((targetDeg - startAngle) % 360 + 360) % 360;
    const totalDelta = fullSpin + rawDelta;
    const startTime  = performance.now();
    const peakDeriv  = spinDerivative(0.001); // peak gần t=0

    function frame(now) {
        const t         = Math.min((now - startTime) / SPIN_MS, 1);
        const eased     = spinEasing(t);
        const speedNorm = Math.min(spinDerivative(t) / peakDeriv, 1);

        state.needleAngle = startAngle + totalDelta * eased;

        updateSpinVolume(speedNorm);

        ctx.clearRect(0, 0, 300, 300);
        drawWheelBase();
        drawNeedle(state.needleAngle, speedNorm);
        drawCenterCap();

        if (t < 1) {
            requestAnimationFrame(frame);
        } else {
            state.needleAngle = targetDeg;
            stopSpinAudio();
            drawWheel();
            if (onDone) onDone();
        }
    }

    requestAnimationFrame(frame);
}

// ── Update UI state ────────────────────────────────────────────────
function updateInfo() {
    const chance = calcChance();
    state.arcSizeDeg = chance * 360;

    if (!state.selectedBalo) {
        E.lvDisplay.textContent = 'LV -- → --';
        E.btnUpgrade.disabled   = true;
        E.hintText.textContent  = 'Chọn balo và nguyên liệu';
    } else {
        const lv = (state.selectedBalo.metadata && state.selectedBalo.metadata.level) || 0;
        E.lvDisplay.textContent = `LV ${lv}  →  LV ${lv + 1}`;
        E.btnUpgrade.disabled   = state.selectedMaterials.length === 0 || state.isSpinning || state.arcLockedIn;

        if (!state.arcLockedIn) {
            E.hintText.textContent = chance > 0 ? 'Kéo vòng tròn để chọn vị trí' : 'Thêm nguyên liệu để có tỉ lệ';
        } else {
            E.hintText.textContent = 'Đang quay...';
        }
    }

    drawWheel();
}

const RARITY_COLOR = {
    common   : '#ffffff',
    rare     : '#4d9eff',
    epic     : '#a64dff',
    legendary: '#ff4d4d',
    mythic   : '#ffd700',
};

function setRarityColor(el, rarity) {
    el.style.setProperty('--rarity-color', RARITY_COLOR[rarity] || 'rgba(255,255,255,0.08)');
}

// ── Render items ───────────────────────────────────────────────────
function renderBalos() {
    E.baloGrid.innerHTML = '';
    if (!state.balos || !state.balos.length) {
        const s = document.createElement('span');
        s.className   = 'empty-label';
        s.textContent = 'Không có balo khả dụng';
        E.baloGrid.appendChild(s);
        return;
    }
    for (const b of state.balos) {
        const card = document.createElement('div');
        let cls = 'item-card';
        if (state.selectedBalo && state.selectedBalo.slot === b.slot) cls += ' selected';
        if (!b.canUp) cls += ' maxed';
        card.className = cls;
        const baloRarity = (b.metadata && b.metadata.rarity) || 'common';
        setRarityColor(card, baloRarity);

        const img = document.createElement('img');
        img.src = imgUrl(b);
        img.onerror = () => { img.style.opacity = '0.2'; };

        const lv = document.createElement('span');
        lv.className   = 'card-level';
        lv.textContent = 'Lv' + ((b.metadata && b.metadata.level != null) ? b.metadata.level : 0);

        if (!b.canUp) {
            const mx = document.createElement('span');
            mx.className   = 'card-max';
            mx.textContent = 'MAX';
            card.appendChild(mx);
        }

        card.appendChild(img);
        card.appendChild(lv);
        card.addEventListener('click', () => { if (!state.isSpinning && b.canUp) onSelectBalo(b); });
        E.baloGrid.appendChild(card);
    }
}

function renderMaterials() {
    E.matGrid.innerHTML = '';
    if (!state.materials || !state.materials.length) {
        const s = document.createElement('span');
        s.className   = 'empty-label';
        s.textContent = 'Không có nguyên liệu';
        E.matGrid.appendChild(s);
        E.matCount.textContent = `0 / ${state.cfg.maxMaterialSlots}`;
        return;
    }
    for (const m of state.materials) {
        const selected = state.selectedMaterials.some(s => s.slot === m.slot);
        const noPoints = (m.points || 0) === 0;
        const card     = document.createElement('div');
        let cls = 'item-card';
        if (selected)  cls += ' selected';
        if (noPoints)  cls += ' no-points';
        card.className = cls;
        setRarityColor(card, m.rarity);

        const img = document.createElement('img');
        img.src = imgUrl(m);
        img.onerror = () => { img.style.opacity = '0.2'; };

        // const dot = document.createElement('span');
        // dot.className = `card-rarity r-${m.rarity}`;

        const pts = document.createElement('span');
        pts.className = 'card-pts';

        card.appendChild(img);
        // card.appendChild(dot);
        card.appendChild(pts);
        card.addEventListener('click', () => {
            if (!state.isSpinning && !noPoints) onToggleMaterial(m);
        });
        E.matGrid.appendChild(card);
    }
    E.matCount.textContent = `${state.selectedMaterials.length} / ${state.cfg.maxMaterialSlots}`;
}

// ── Selection ──────────────────────────────────────────────────────
function onSelectBalo(b) {
    state.selectedBalo = (state.selectedBalo && state.selectedBalo.slot === b.slot) ? null : b;
    renderBalos();
    updateInfo();
}

function onToggleMaterial(m) {
    const idx = state.selectedMaterials.findIndex(s => s.slot === m.slot);
    if (idx !== -1) {
        state.selectedMaterials.splice(idx, 1);
    } else {
        if (state.selectedMaterials.length >= state.cfg.maxMaterialSlots) return;
        state.selectedMaterials.push(m);
    }
    renderMaterials();
    updateInfo();
}

// ── Drag to rotate arc ─────────────────────────────────────────────
E.canvas.addEventListener('mousedown', e => {
    if (state.isSpinning || state.arcSizeDeg <= 0) return;
    state.dragActive     = true;
    state.dragStartAngle = getMouseAngle(e);
    state.dragArcStart   = state.arcStartDeg;
});

window.addEventListener('mousemove', e => {
    if (!state.dragActive) return;
    const cur   = getMouseAngle(e);
    const delta = cur - state.dragStartAngle;
    state.arcStartDeg = ((state.dragArcStart + delta) % 360 + 360) % 360;
    drawWheel();
});

window.addEventListener('mouseup', () => { state.dragActive = false; });

function showResult(isWin, newLevel) {
    playResult(isWin);

    const existing = document.getElementById('upgrade-result-text');
    if (existing) existing.remove();
    const existingBg = document.getElementById('upgrade-result-bg');
    if (existingBg) existingBg.remove();

    // Làm mờ panel-right
    const panelRight = document.querySelector('.panel-right');
    const bg = document.createElement('div');
    bg.id = 'upgrade-result-bg';
    bg.style.cssText = `
        position: absolute;
        inset: 0;
        background: rgba(0, 0, 0, 0.7);
        backdrop-filter: blur(4px);
        z-index: 9;
        opacity: 0;
        transition: opacity 0.4s ease;
        border-radius: 0 12px 12px 0;
    `;
    panelRight.style.position = 'relative';
    panelRight.appendChild(bg);

    // Text kết quả
    const el = document.createElement('div');
    el.id = 'upgrade-result-text';
    el.style.cssText = `
        position: absolute;
        top: 50%; left: 50%;
        transform: translate(-50%, -50%) scale(0.3);
        text-align: center;
        pointer-events: none;
        z-index: 10;
        opacity: 0;
        transition: opacity 0.4s ease, transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    `;

    if (isWin) {
        el.innerHTML = `
            <div style="font-family:'Be Vietnam Pro',sans-serif; font-size:36px; font-weight:900; letter-spacing:0.1em; color:#00ff88; text-shadow:0 0 30px rgba(0,255,136,0.6), 0 0 60px rgba(0,255,136,0.2);">THÀNH CÔNG</div>
            <div style="font-family:'Be Vietnam Pro',sans-serif; font-size:52px; font-weight:900; letter-spacing:0.06em; color:#05F2F2; text-shadow:0 0 36px rgba(5,242,242,0.6), 0 0 72px rgba(5,242,242,0.2); margin-top:10px;">→ LV ${newLevel}</div>
        `;
    } else {
        const label = newLevel === -1 ? 'BA LÔ BỊ PHÁ' : 'THẤT BẠI';
        const sub   = newLevel === -1 ? '✕' : `LV ${newLevel}`;
        el.innerHTML = `
            <div style="font-family:'Be Vietnam Pro',sans-serif; font-size:36px; font-weight:900; letter-spacing:0.1em; color:#ff4444; text-shadow:0 0 30px rgba(255,68,68,0.6), 0 0 60px rgba(255,68,68,0.2);">${label}</div>
            <div style="font-family:'Be Vietnam Pro',sans-serif; font-size:52px; font-weight:900; letter-spacing:0.06em; color:rgba(255,255,255,0.5); text-shadow:0 0 20px rgba(255,255,255,0.15); margin-top:10px;">${sub}</div>
        `;
    }

    panelRight.appendChild(el);

    requestAnimationFrame(() => {
        bg.style.opacity = '1';
        el.style.opacity = '1';
        el.style.transform = 'translate(-50%, -50%) scale(1)';
    });
}

// ── Upgrade ────────────────────────────────────────────────────────
async function onUpgrade() {
    if (state.isSpinning || !state.selectedBalo || !state.selectedMaterials.length) return;
    if (state.arcSizeDeg <= 0) return;

    state.isSpinning       = true;
    state.arcLockedIn      = true;
    E.btnUpgrade.disabled  = true;
    E.hintText.textContent = 'Đang quay...';

    startSpinAudio();

    const baloSlot      = state.selectedBalo.slot;
    const materialSlots = state.selectedMaterials.map(m => m.slot);
    const arcStartDeg   = Math.round(state.arcStartDeg);

    let result;
    try {
        const resp = await fetch(`https://${state.resourceName}/startUpgrade`, {
            method : 'POST',
            headers: { 'Content-Type': 'application/json' },
            body   : JSON.stringify({ baloSlot, materialSlots, arcStartDeg }),
        });
        result = await resp.json();
    } catch {
        state.isSpinning  = false;
        state.arcLockedIn = false;
        stopSpinAudio();
        E.hintText.textContent = 'Lỗi kết nối';
        updateInfo();
        return;
    }

    if (!result || result.error) {
        state.isSpinning  = false;
        state.arcLockedIn = false;
        stopSpinAudio();
        E.hintText.textContent = 'Lỗi: ' + (result && result.error || 'unknown');
        updateInfo();
        return;
    }

    animateNeedle(result.rollDeg, async () => {
        showResult(result.isWin, result.newLevel);

        await new Promise(resolve => {
            fetch(`https://${state.resourceName}/confirmUpgrade`, {
                method : 'POST',
                headers: { 'Content-Type': 'application/json' },
                body   : JSON.stringify({ token: result.token }),
            }).then(() => resolve()).catch(() => resolve());
        });

        await new Promise(r => setTimeout(r, 3000));

        syncAfterUpgrade(result);
        state.isSpinning  = false;
        state.arcLockedIn = false;
        state.needleAngle = result.rollDeg % 360;

        renderBalos();
        renderMaterials();
        updateInfo();
        E.hintText.textContent = 'Kéo vòng tròn để chọn vị trí';
    });
}

function syncAfterUpgrade(result) {
    const existing = document.getElementById('upgrade-result-text');
    if (existing) existing.remove();
    const existingBg = document.getElementById('upgrade-result-bg');
    if (existingBg) existingBg.remove();
    const { newLevel } = result;
    const idx = state.balos.findIndex(b => b.slot === state.selectedBalo.slot);
    if (idx !== -1) {
        if (newLevel === -1) {
            state.balos.splice(idx, 1);
        } else if (state.cfg.requirePoints[newLevel] !== undefined) {
            state.balos[idx].metadata.level = newLevel;
            state.balos[idx].canUp = true;
        } else {
            state.balos[idx].metadata.level = newLevel;
            state.balos[idx].canUp = false;
        }
    }
    const usedSlots = new Set(state.selectedMaterials.map(m => m.slot));
    state.materials         = state.materials.filter(m => !usedSlots.has(m.slot));
    state.selectedBalo      = null;
    state.selectedMaterials = [];
    state.arcSizeDeg        = 0;
    state.arcStartDeg       = 0;
}

// ── Open / Close ───────────────────────────────────────────────────
function openUI(data, resourceName) {
    state.resourceName      = resourceName || 'DERP-backpackupgrade';
    state.balos             = data.balos     || [];
    state.materials         = data.materials || [];
    state.cfg               = data.config    || state.cfg;
    state.selectedBalo      = null;
    state.selectedMaterials = [];
    state.isSpinning        = false;
    state.arcLockedIn       = false;
    state.arcSizeDeg        = 0;
    state.arcStartDeg       = 0;
    state.needleAngle       = 0;

    renderBalos();
    renderMaterials();
    updateInfo();
    E.app.classList.remove('hidden');
}

function closeUI() {
    if (state.isSpinning) return;
    E.app.classList.add('hidden');
    fetch(`https://${state.resourceName}/closeUI`, {
        method : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body   : JSON.stringify({}),
    });
}

E.btnClose.addEventListener('click', closeUI);
E.btnUpgrade.addEventListener('click', onUpgrade);
window.addEventListener('keydown', e => { if (e.key === 'Escape') closeUI(); });

window.addEventListener('message', e => {
    if (e.data.action === 'open')  openUI(e.data.data, e.data.resourceName);
    if (e.data.action === 'close') E.app.classList.add('hidden');
});

drawWheel();