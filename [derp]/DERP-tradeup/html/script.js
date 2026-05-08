'use strict';

const RARITY_COLOR = {
    common   : '#ffffff',
    rare     : '#4d9eff',
    epic     : '#a64dff',
    legendary: '#ff4d4d',
    mythic   : '#ffd700',
};

const RARITY_LABEL = {
    common   : 'COMMON',
    rare     : 'RARE',
    epic     : 'EPIC',
    legendary: 'LEGENDARY',
    mythic   : 'MYTHIC',
};

const state = {
    resourceName     : 'DERP-tradeup',
    materials        : [],
    selectedSlots    : new Set(),
    lockedRarity     : null,
    gender           : 0,
    isProcessing     : false,
    cfg              : { requiredCount: 9, rarityUpgrade: {} },
    lastError        : null,
};

const E = {
    app          : document.getElementById('app'),
    matGrid      : document.getElementById('mat-grid'),
    matCount     : document.getElementById('mat-count'),
    rarityInfo   : document.getElementById('rarity-info'),
    rarityFlow   : document.getElementById('rarity-flow'),
    resultCard   : document.getElementById('result-card'),
    resultImg    : document.getElementById('result-img'),
    resultLabel  : document.getElementById('result-label'),
    hintText     : document.getElementById('hint-text'),
    btnTradeup   : document.getElementById('btn-tradeup'),
    btnClose     : document.getElementById('btn-close'),
    genderBtns   : document.querySelectorAll('.gender-btn'),
};

function imgUrl(item) {
    if (typeof item === 'string') return `https://gta5root.top/fivem/items101/${item}.png`;
    const meta = item.metadata || {};
    const draw = meta.drawableId != null ? meta.drawableId : '';
    const tex  = meta.textureId  != null ? meta.textureId  : '';
    const gen  = meta.gender     != null ? meta.gender     : '';
    if (draw !== '' && tex !== '' && gen !== '') {
        return `https://gta5root.top/fivem/items101/${item.name}_${draw}_${tex}_${gen}.png`;
    }
    if (draw !== '' && tex !== '') {
        return `https://gta5root.top/fivem/items101/${item.name}_${draw}_${tex}.png`;
    }
    return `https://gta5root.top/fivem/items101/${item.name}.png`;
}

function setRarityColor(el, rarity) {
    el.style.setProperty('--rarity-color', RARITY_COLOR[rarity] || 'rgba(255,255,255,0.08)');
}

function renderMaterials() {
    E.matGrid.innerHTML = '';

    if (!state.materials.length) {
        const s = document.createElement('span');
        s.className   = 'empty-label';
        s.textContent = 'Không có nguyên liệu';
        E.matGrid.appendChild(s);
        E.matCount.textContent = `0 / ${state.cfg.requiredCount}`;
        return;
    }

    for (const m of state.materials) {
        const isSelected = state.selectedSlots.has(m.slot);
        const isLockedOut = state.lockedRarity && state.lockedRarity !== m.rarity;

        const card = document.createElement('div');
        let cls = 'item-card';
        if (isSelected)    cls += ' selected';
        if (isLockedOut)   cls += ' dimmed';
        card.className = cls;
        setRarityColor(card, m.rarity);

        const img = document.createElement('img');
        img.src = imgUrl(m);
        img.onerror = () => { img.style.opacity = '0.2'; };
        card.appendChild(img);

        card.addEventListener('click', () => {
            if (state.isProcessing) return;
            if (isLockedOut) return;
            onToggleMaterial(m);
        });

        E.matGrid.appendChild(card);
    }

    E.matCount.textContent = `${state.selectedSlots.size} / ${state.cfg.requiredCount}`;
}

function updateRarityInfo() {
    if (!state.lockedRarity) {
        E.rarityInfo.classList.remove('locked');
        E.rarityInfo.style.removeProperty('--locked-color');
        E.rarityInfo.textContent = 'Chọn 1 món để khoá rarity';
        E.rarityFlow.innerHTML = '-- <span class="arrow">→</span> --';
        return;
    }

    const from = state.lockedRarity;
    const to   = state.cfg.rarityUpgrade[from];
    const fromColor = RARITY_COLOR[from] || '#ffffff';
    const toColor   = to ? (RARITY_COLOR[to] || '#ffffff') : 'rgba(255,255,255,0.3)';

    E.rarityInfo.classList.add('locked');
    E.rarityInfo.style.setProperty('--locked-color', fromColor);
    E.rarityInfo.textContent = `Đã khoá: ${RARITY_LABEL[from] || from.toUpperCase()}`;

    E.rarityFlow.style.setProperty('--from-color', fromColor);
    E.rarityFlow.style.setProperty('--to-color', toColor);
    E.rarityFlow.innerHTML = `
        <span class="from">${RARITY_LABEL[from] || from}</span>
        <span class="arrow">→</span>
        <span class="to">${to ? (RARITY_LABEL[to] || to) : '???'}</span>
    `;
}

function updateButton() {
    const enough = state.selectedSlots.size === state.cfg.requiredCount;
    const upgradable = state.lockedRarity && state.cfg.rarityUpgrade[state.lockedRarity];
    E.btnTradeup.disabled = !(enough && upgradable) || state.isProcessing;

    if (state.isProcessing) {
        E.hintText.textContent = 'Đang xử lý...';
        E.hintText.style.color = '';
    } else if (state.lastError) {
        E.hintText.textContent = 'Lỗi: ' + state.lastError;
        E.hintText.style.color = '#ff4444';
    } else if (!state.lockedRarity) {
        E.hintText.textContent = 'Chọn 9 món cùng rarity';
        E.hintText.style.color = '';
    } else if (!upgradable) {
        E.hintText.textContent = 'Rarity này đã ở mức cao nhất';
        E.hintText.style.color = '';
    } else if (!enough) {
        E.hintText.textContent = `Cần thêm ${state.cfg.requiredCount - state.selectedSlots.size} món`;
        E.hintText.style.color = '';
    } else {
        E.hintText.textContent = 'Sẵn sàng trade-up';
        E.hintText.style.color = '';
    }
}

function refreshAll() {
    renderMaterials();
    updateRarityInfo();
    updateButton();
}

function onToggleMaterial(m) {
    if (state.selectedSlots.has(m.slot)) {
        state.selectedSlots.delete(m.slot);
        if (state.selectedSlots.size === 0) {
            state.lockedRarity = null;
        }
    } else {
        if (state.selectedSlots.size >= state.cfg.requiredCount) return;
        if (!state.lockedRarity) {
            state.lockedRarity = m.rarity;
        } else if (state.lockedRarity !== m.rarity) {
            return;
        }
        state.selectedSlots.add(m.slot);
    }
    refreshAll();
}

function resetResultCard() {
    E.resultCard.classList.remove('has-result');
    E.resultCard.style.removeProperty('--result-color');
    E.resultImg.src = '';
    E.resultLabel.classList.remove('success');
    E.resultLabel.textContent = 'CHƯA CÓ KẾT QUẢ';
}

function showResult(result) {
    const color = RARITY_COLOR[result.newRarity] || '#ffffff';
    E.resultCard.style.setProperty('--result-color', color);
    E.resultImg.src = imgUrl(result.result);
    E.resultImg.onerror = () => { E.resultImg.style.opacity = '0.3'; };
    E.resultImg.onload  = () => { E.resultImg.style.opacity = '1'; };

    void E.resultCard.offsetWidth;
    E.resultCard.classList.add('has-result');

    E.resultLabel.style.color = color;
    E.resultLabel.classList.add('success');
    E.resultLabel.textContent = `+1 ${RARITY_LABEL[result.newRarity] || result.newRarity.toUpperCase()}`;
}

const ERROR_LABEL = {
    busy             : 'Đang bận, thử lại',
    invalid_count    : 'Cần đúng 9 món',
    invalid_gender   : 'Giới tính không hợp lệ',
    invalid_data     : 'Dữ liệu không hợp lệ',
    invalid_slot     : 'Slot không hợp lệ',
    duplicate_slot   : 'Trùng slot',
    mat_missing      : 'Vật phẩm đã thay đổi, đã làm mới',
    balo_not_allowed : 'Không được dùng balo',
    not_clothing     : 'Không phải clothing',
    rarity_mismatch  : 'Phải cùng rarity',
    max_tier         : 'Đã max tier',
    no_output_pool   : 'Pool output trống',
    remove_failed    : 'Không xoá được nguyên liệu',
    inventory_full   : 'Hết slot inventory',
    internal         : 'Lỗi server',
    timeout          : 'Hết thời gian chờ',
    unknown          : 'Lỗi không xác định',
};

async function refreshMaterialsFromServer() {
    try {
        const resp = await fetch(`https://${state.resourceName}/refreshItems`, {
            method : 'POST',
            headers: { 'Content-Type': 'application/json' },
            body   : JSON.stringify({}),
        });
        const fresh = await resp.json();
        if (fresh && fresh.materials) {
            state.materials = fresh.materials;
        }
    } catch {}
}

let _hintResetTimer = null;
function showError(code) {
    const label = ERROR_LABEL[code] || `Lỗi: ${code}`;
    E.hintText.textContent = label;
    E.hintText.style.color = '#ff5050';

    if (_hintResetTimer) clearTimeout(_hintResetTimer);
    _hintResetTimer = setTimeout(() => {
        E.hintText.style.color = '';
        updateButton();
    }, 2500);
}

async function onTradeUp() {
    if (state.isProcessing) return;
    if (state.selectedSlots.size !== state.cfg.requiredCount) return;
    if (!state.lockedRarity || !state.cfg.rarityUpgrade[state.lockedRarity]) return;

    state.isProcessing = true;
    E.btnTradeup.disabled = true;
    E.hintText.style.color = '';
    E.hintText.textContent = 'Đang xử lý...';
    if (_hintResetTimer) { clearTimeout(_hintResetTimer); _hintResetTimer = null; }
    resetResultCard();

    const materialSlots = Array.from(state.selectedSlots);
    const payload = { materialSlots, gender: state.gender };

    let result;
    try {
        const resp = await fetch(`https://${state.resourceName}/startTradeUp`, {
            method : 'POST',
            headers: { 'Content-Type': 'application/json' },
            body   : JSON.stringify(payload),
        });
        result = await resp.json();
    } catch {
        state.isProcessing = false;
        showError('timeout');
        return;
    }

    if (!result || result.error || !result.success) {
        const code = (result && result.error) || 'unknown';

        if (code === 'mat_missing' || code === 'not_clothing' || code === 'rarity_mismatch') {
            state.selectedSlots.clear();
            state.lockedRarity = null;
            await refreshMaterialsFromServer();
        }

        state.isProcessing = false;
        refreshAll();
        showError(code);
        return;
    }

    state.selectedSlots.clear();
    state.lockedRarity = null;
    showResult(result);
    await refreshMaterialsFromServer();
    state.isProcessing = false;
    refreshAll();
}

function onSelectGender(gender) {
    if (state.isProcessing) return;
    state.gender = gender;
    E.genderBtns.forEach(btn => {
        const g = parseInt(btn.dataset.gender, 10);
        btn.classList.toggle('active', g === gender);
    });
}

function openUI(data, resourceName) {
    state.resourceName  = resourceName || 'DERP-tradeup';
    state.materials     = data.materials || [];
    state.cfg           = data.config    || state.cfg;
    state.selectedSlots = new Set();
    state.lockedRarity  = null;
    state.isProcessing  = false;
    state.gender        = 0;

    E.genderBtns.forEach(btn => {
        const g = parseInt(btn.dataset.gender, 10);
        btn.classList.toggle('active', g === 0);
    });

    resetResultCard();
    refreshAll();
    E.app.classList.remove('hidden');
}

function closeUI() {
    if (state.isProcessing) return;
    E.app.classList.add('hidden');
    fetch(`https://${state.resourceName}/closeUI`, {
        method : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body   : JSON.stringify({}),
    });
}

E.btnClose.addEventListener('click', closeUI);
E.btnTradeup.addEventListener('click', onTradeUp);
E.genderBtns.forEach(btn => {
    btn.addEventListener('click', () => {
        const g = parseInt(btn.dataset.gender, 10);
        onSelectGender(g);
    });
});

window.addEventListener('keydown', e => { if (e.key === 'Escape') closeUI(); });

window.addEventListener('message', e => {
    if (e.data.action === 'open')  openUI(e.data.data, e.data.resourceName);
    if (e.data.action === 'close') E.app.classList.add('hidden');
});