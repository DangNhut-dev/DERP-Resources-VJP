'use strict';

// ---- State ----
let spinActive    = false;
let resultPending = false;
let imagePath     = '';
let clothPath     = '';
let rarityColors  = {};

// ---- DOM ----
const overlay        = document.getElementById('overlay');
const reelTrack      = document.getElementById('reel-track');
const centerGlow     = document.getElementById('center-glow');
const resultPanel    = document.getElementById('result-panel');
const resultImg      = document.getElementById('result-img');
const resultName     = document.getElementById('result-name');
const resultRarity   = document.getElementById('result-rarity');
const resultCard     = document.getElementById('result-card');
const btnClaim       = document.getElementById('btn-claim');
const previewScreen  = document.getElementById('preview-screen');
const spinScreen     = document.getElementById('spin-screen');
const previewBoxImg  = document.getElementById('preview-box-img');
const previewBoxLabel = document.getElementById('preview-box-label');

// ---- State bổ sung ----
let currentBoxType = null;

// ---- Audio ----
const spinAudio = new Audio('assets/spin.mp3');
spinAudio.loop   = true;
spinAudio.volume = 0;

let spinFadeTimer = null;

function startSpinAudio() {
    clearInterval(spinFadeTimer);
    spinAudio.currentTime = 0;
    spinAudio.volume = 0.15;
    spinAudio.play().catch(() => {});
}

function stopSpinAudio(ms = 1200) {
    clearInterval(spinFadeTimer);
    const steps    = 30;
    const interval = ms / steps;
    const delta    = spinAudio.volume / steps;
    let   count    = 0;
    spinFadeTimer = setInterval(() => {
        count++;
        spinAudio.volume = Math.max(0, spinAudio.volume - delta);
        if (count >= steps) {
            clearInterval(spinFadeTimer);
            spinAudio.pause();
            spinAudio.volume = 0.15;
        }
    }, interval);
}

function playWin(rarity) {}

// ---- Helpers ----
function getRarityColor(rarity) {
    return rarityColors[rarity] || '#ffffff';
}

function getItemImagePath(item) {
    return (item.type === 'cloth' ? clothPath : imagePath) + item.name + '.png';
}

function buildItemEl(item) {
    const el = document.createElement('div');
    el.className = 'reel-item';
    const color = getRarityColor(item.rarity);
    el.style.setProperty('--rarity-color', color);

    const img = document.createElement('img');
    img.src = getItemImagePath(item);
    img.alt = item.label;
    img.loading = 'lazy';
    img.onerror = () => { img.style.opacity = '0.3'; };

    const bar = document.createElement('div');
    bar.className = 'item-rarity-bar';

    el.appendChild(img);
    el.appendChild(bar);
    return el;
}

function buildReelPool(items, totalSlots) {
    const rarityWeight = {
        common: 60, rare: 25, epic: 10, legendary: 4, mythic: 1
    };
    const pool = [];
    items.forEach(item => {
        const w = rarityWeight[item.rarity] || 1;
        for (let i = 0; i < w; i++) pool.push(item);
    });

    const reel = [];
    for (let i = 0; i < totalSlots; i++) {
        reel.push(pool[Math.floor(Math.random() * pool.length)]);
    }
    return reel;
}

function easeSpinNew(t) {
    return 1 - Math.pow(1 - t, 3);
}

// ---- Preview ----
function showPreview(boxType, boxLabel, imgPath) {
    currentBoxType = boxType;
    spinActive     = false;
    resultPending  = false;

    previewBoxImg.src           = imgPath + boxType + '.png';
    previewBoxLabel.textContent = boxLabel;

    const multiContainer = document.getElementById('multi-reel-container');
    multiContainer.innerHTML = '';
    multiContainer.classList.add('hidden');
    document.getElementById('multi-side-left').innerHTML  = '';
    document.getElementById('multi-side-right').innerHTML = '';

    document.getElementById('reel-container').style.display = '';
    reelTrack.innerHTML = '';

    spinScreen.classList.add('hidden');
    previewScreen.style.display = 'flex';
    resultPanel.classList.remove('visible');
    resultPanel.classList.add('hidden');
    overlay.classList.remove('hidden');
}

// ---- Core Spin ----
function startSpin(winningItem, items) {
    if (spinActive) return;
    spinActive    = true;
    resultPending = false;

    resultPanel.classList.remove('visible');
    resultPanel.classList.add('hidden');
    reelTrack.innerHTML = '';

    const ITEM_W      = 160;
    const GAP         = 10;
    const SLOT_W      = ITEM_W + GAP;
    const TOTAL_SLOTS = 60;
    const WIN_IDX     = 52;
    const SPIN_MS     = 15500;

    const reelItems = buildReelPool(items, TOTAL_SLOTS);
    reelItems[WIN_IDX] = winningItem;

    reelItems.forEach(item => {
        reelTrack.appendChild(buildItemEl(item));
    });

    const trackWrap    = document.getElementById('reel-track-wrap');
    const viewCenter   = trackWrap.offsetWidth / 2;
    const targetCenter = WIN_IDX * SLOT_W + ITEM_W / 2;
    const targetOffset = targetCenter - viewCenter;
    const jitter       = (Math.random() - 0.5) * (ITEM_W * 0.35);
    const finalOffset  = targetOffset + jitter;

    let startTime = null;

    function animate(ts) {
        if (!startTime) startTime = ts;
        const elapsed  = ts - startTime;
        const progress = Math.min(elapsed / SPIN_MS, 1);
        const eased    = easeSpinNew(progress);
        reelTrack.style.transform = `translateX(${-(eased * finalOffset)}px)`;

        if (progress < 1) {
            requestAnimationFrame(animate);
        } else {
            onSpinEnd(winningItem, WIN_IDX);
        }
    }

    startSpinAudio();
    setTimeout(() => {
        requestAnimationFrame(animate);
    }, 500);
}

function onSpinEnd(winningItem, winIdx) {
    stopSpinAudio(1200);

    const flash = document.createElement('div');
    flash.className = 'flash-overlay';
    document.body.appendChild(flash);
    setTimeout(() => flash.remove(), 700);

    playWin(winningItem.rarity);
    setTimeout(() => showResult(winningItem), 900);
}

function showResult(item) {
    const color = getRarityColor(item.rarity);
    resultCard.style.setProperty('--result-rarity-color', color);

    resultImg.src = getItemImagePath(item);
    resultImg.alt = item.label;

    resultName.textContent   = '';
    resultRarity.textContent = '';

    const leftEl  = document.getElementById('multi-side-left');
    const rightEl = document.getElementById('multi-side-right');
    if (leftEl)  { leftEl.innerHTML  = ''; leftEl.className  = ''; }
    if (rightEl) { rightEl.innerHTML = ''; rightEl.className = ''; }

    resultPanel.classList.remove('hidden');
    requestAnimationFrame(() => {
        requestAnimationFrame(() => {
            resultPanel.classList.add('visible');
            resultPending = true;
        });
    });
}

// ---- NUI Message Listener ----
window.addEventListener('message', (e) => {
    const data = e.data;
    if (!data || !data.action) return;

    if (data.action === 'showPreview') {
        imagePath = data.imagePath || '';
        showPreview(data.boxType, data.boxLabel, imagePath);
        return;
    }

    if (data.action === 'closeUI') {
        spinActive    = false;
        resultPending = false;

        const multiContainer = document.getElementById('multi-reel-container');
        multiContainer.innerHTML = '';
        multiContainer.classList.add('hidden');
        document.getElementById('multi-side-left').innerHTML  = '';
        document.getElementById('multi-side-right').innerHTML = '';
        document.getElementById('reel-container').style.display = '';
        reelTrack.innerHTML = '';

        overlay.classList.add('hidden');
        return;
    }

    if (data.action === 'startSpin') {
        imagePath    = data.imagePath    || '';
        clothPath    = data.clothPath    || '';
        rarityColors = data.rarityColors || {};
        previewScreen.style.display = 'none';
        spinScreen.classList.remove('hidden');
        overlay.classList.remove('hidden');
        requestAnimationFrame(() => {
            setTimeout(() => startSpin(data.winningItem, data.items), 100);
        });
        return;
    }

    if (data.action === 'startMultiSpin') {
        imagePath    = data.imagePath    || '';
        clothPath    = data.clothPath    || '';
        rarityColors = data.rarityColors || {};
        previewScreen.style.display = 'none';
        spinScreen.classList.remove('hidden');
        overlay.classList.remove('hidden');
        requestAnimationFrame(() => {
            setTimeout(() => startMultiSpin(data.winners, data.items), 100);
        });
        return;
    }
});

document.getElementById('btn-open-x1').addEventListener('click', (e) => {
    e.stopPropagation();
    if (spinActive) return;
    previewScreen.style.display = 'none';
    fetch(`https://${window.location.hostname.replace('cfx-nui-', '')}/confirmOpen`, {
        method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({})
    });
});

document.getElementById('btn-open-x5').addEventListener('click', (e) => {
    e.stopPropagation();
    if (spinActive) return;
    previewScreen.style.display = 'none';
    fetch(`https://${window.location.hostname.replace('cfx-nui-', '')}/confirmOpenMulti`, {
        method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({})
    });
});

// ---- Multi spin ----
const MULTI_ITEM_W  = 88;
const MULTI_GAP     = 6;
const MULTI_SLOT_W  = MULTI_ITEM_W + MULTI_GAP;
const MULTI_SLOTS   = 55;
const MULTI_WIN_IDX = 47;
const MULTI_BASE_MS = 10000;
const MULTI_STEP_MS = 900;

function buildMultiItemEl(item) {
    const el = document.createElement('div');
    el.className = 'multi-reel-item';
    const color = getRarityColor(item.rarity);
    el.style.setProperty('--rarity-color', color);

    const img = document.createElement('img');
    img.src = getItemImagePath(item);
    img.alt = item.label;
    img.onerror = () => { img.style.opacity = '0.3'; };

    const bar = document.createElement('div');
    bar.className = 'item-rarity-bar';

    el.appendChild(img);
    el.appendChild(bar);
    return el;
}

let multiSpinCount = 0;
let multiWinners   = [];

function startMultiSpin(winners, items) {
    if (spinActive) return;
    spinActive     = true;
    resultPending  = false;
    multiSpinCount = 0;
    multiWinners   = winners;

    document.getElementById('reel-container').style.display   = 'none';
    const multiContainer = document.getElementById('multi-reel-container');
    multiContainer.innerHTML = '';
    multiContainer.classList.remove('hidden');

    resultPanel.classList.add('hidden');
    resultPanel.classList.remove('visible');
    document.getElementById('multi-side-left').innerHTML  = '';
    document.getElementById('multi-side-right').innerHTML = '';

    const tracks = [];
    winners.forEach(() => {
        const row = document.createElement('div');
        row.className = 'multi-reel-row';

        const track = document.createElement('div');
        track.className = 'multi-reel-track';

        const centerLine = document.createElement('div');
        centerLine.className = 'multi-center-line';

        row.appendChild(track);
        row.appendChild(centerLine);
        multiContainer.appendChild(row);
        tracks.push(track);
    });

    requestAnimationFrame(() => {
        startSpinAudio();
        setTimeout(() => {
            winners.forEach((winner, idx) => {
                const spinMs = MULTI_BASE_MS + idx * MULTI_STEP_MS;
                animateMultiTrack(tracks[idx], winner, items, idx, spinMs, winners.length, multiContainer);
            });
        }, 500);
    });
}

function animateMultiTrack(track, winner, items, rowIdx, spinMs, totalRows, container) {
    const pool = [];
    items.forEach(item => {
        const w = { common:60, rare:25, epic:10, legendary:4, mythic:1 }[item.rarity] || 1;
        for (let i = 0; i < w; i++) pool.push(item);
    });

    const reelItems = [];
    for (let i = 0; i < MULTI_SLOTS; i++) {
        reelItems.push(pool[Math.floor(Math.random() * pool.length)]);
    }
    reelItems[MULTI_WIN_IDX] = winner;
    reelItems.forEach(item => track.appendChild(buildMultiItemEl(item)));

    const viewCenter   = container.offsetWidth / 2;
    const targetCenter = MULTI_WIN_IDX * MULTI_SLOT_W + MULTI_ITEM_W / 2;
    const jitter       = (Math.random() - 0.5) * (MULTI_ITEM_W * 0.3);
    const finalOffset  = (targetCenter - viewCenter) + jitter;

    let startTime = null;

    function animate(ts) {
        if (!startTime) startTime = ts;
        const elapsed  = ts - startTime;
        const progress = Math.min(elapsed / spinMs, 1);
        const eased    = easeSpinNew(progress);
        track.style.transform = `translateX(${-(eased * finalOffset)}px)`;

        if (progress < 1) {
            requestAnimationFrame(animate);
        } else {
            onMultiReelStop(winner, rowIdx, totalRows);
        }
    }

    requestAnimationFrame(animate);
}

const RARITY_RANK = { common: 0, rare: 1, epic: 2, legendary: 3, mythic: 4 };

function onMultiReelStop(winner, rowIdx, totalRows) {
    playWin(winner.rarity);
    multiSpinCount++;

    if (multiSpinCount === totalRows) {
        stopSpinAudio(1200);
        const flash = document.createElement('div');
        flash.className = 'flash-overlay';
        document.body.appendChild(flash);
        setTimeout(() => flash.remove(), 700);

        const best = multiWinners.reduce((prev, cur) =>
            (RARITY_RANK[cur.rarity] || 0) > (RARITY_RANK[prev.rarity] || 0) ? cur : prev
        );

        const others = [...multiWinners];
        const bestIdx = others.findIndex(i => i === best);
        others.splice(bestIdx, 1);

        setTimeout(() => {
            showResult(best);

            const leftEl  = document.getElementById('multi-side-left');
            const rightEl = document.getElementById('multi-side-right');
            leftEl.innerHTML  = '';
            rightEl.innerHTML = '';
            leftEl.className  = 'multi-side';
            rightEl.className = 'multi-side';

            others.forEach((item, i) => {
                const color = getRarityColor(item.rarity);
                const card  = document.createElement('div');
                card.className = 'multi-side-card';
                card.style.setProperty('--result-rarity-color', color);
                card.style.animationDelay = `${0.15 + i * 0.1}s`;
                card.innerHTML = `
                    <img src="${getItemImagePath(item)}" alt="${item.label}" onerror="this.style.opacity='0.3'">
                `;
                (i < 2 ? leftEl : rightEl).appendChild(card);
            });
        }, 900);
    }
}

btnClaim.addEventListener('click', (e) => {
    const RESOURCE_NAME = window.location.hostname.replace('cfx-nui-', '');
 
    fetch(`https://${RESOURCE_NAME}/debugResult`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            event: 'btnClaim_CLICKED',
            resultPending: resultPending,
            spinActive: spinActive,
            panelVisible: resultPanel.classList.contains('visible'),
            panelHidden: resultPanel.classList.contains('hidden')
        })
    });
 
    if (!resultPending) {
        fetch(`https://${RESOURCE_NAME}/debugResult`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ event: 'btnClaim_BLOCKED_resultPending_false' })
        });
        return;
    }
    resultPending = false;
    spinActive    = false;
 
    const isMulti = !document.getElementById('multi-reel-container').classList.contains('hidden');
 
    fetch(`https://${RESOURCE_NAME}/debugResult`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ event: 'btnClaim_FETCHING', isMulti: isMulti })
    });
 
    fetch(`https://${RESOURCE_NAME}/${isMulti ? 'spinDoneMulti' : 'spinDone'}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});
 
// THÊM body click listener để biết click chuột có vào DOM không:
document.body.addEventListener('click', (e) => {
    const RESOURCE_NAME = window.location.hostname.replace('cfx-nui-', '');
    fetch(`https://${RESOURCE_NAME}/debugResult`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            event: 'body_click',
            targetId: e.target.id || e.target.tagName,
            x: e.clientX,
            y: e.clientY
        })
    });
}, true);

document.addEventListener('keydown', (e) => {
    if (e.key !== 'Escape') return;
    if (spinActive || resultPending) return;

    if (previewScreen.style.display !== 'none') {
        overlay.classList.add('hidden');
        const RESOURCE_NAME = window.location.hostname.replace('cfx-nui-', '');
        fetch(`https://${RESOURCE_NAME}/closePreview`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }
});