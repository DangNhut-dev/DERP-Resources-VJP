'use strict';

const app          = document.getElementById('app');
const btnClose     = document.getElementById('btn-close');
const ticketBadge  = document.getElementById('ticket-badge-count');

const itemGrid     = document.getElementById('item-grid');
const selCount     = document.getElementById('sel-count');
const btnExchange  = document.getElementById('btn-exchange');
const hintText     = document.getElementById('hint-text');
const ticketCard   = document.getElementById('ticket-card');
const ticketImg    = document.getElementById('ticket-img');
const ticketPH     = document.getElementById('ticket-placeholder');
const ticketAmount = document.getElementById('ticket-amount');
const ticketBreak  = document.getElementById('ticket-breakdown');
const arrowIcon    = document.querySelector('.arrow-icon');

const shopList  = document.getElementById('shop-list');
const tabBtns   = document.querySelectorAll('.tab-btn');
const tabExchange = document.getElementById('tab-exchange');
const tabShop     = document.getElementById('tab-shop');

let state = {
    materials:     [],
    rarityValue:   {},
    ticketItem:    'ticket',
    ticketCount:   0,
    shopItems:     [],
    clothingSlots: {},
    selected:      new Set(),
    busy:          false,
    resourceName:  '',
    pedGender:     0,
    previewActive: false,
    previewingId:  null,
    sortMode:      'none',
    genderFilter:  'all',
};

function imgUrl(item) {
    if (typeof item === 'string') {
        return `https://gta5root.top/fivem/items101/${item}.png`;
    }
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

function shopImgUrl(shopItem) {
    const draw = shopItem.drawableId != null ? shopItem.drawableId : '';
    const tex  = shopItem.textureId  != null ? shopItem.textureId  : '';
    const gen  = shopItem.gender     != null ? shopItem.gender     : '';
    if (draw !== '' && tex !== '' && gen !== '') {
        return `https://gta5root.top/fivem/items101/${shopItem.name}_${draw}_${tex}_${gen}.png`;
    }
    if (draw !== '' && tex !== '') {
        return `https://gta5root.top/fivem/items101/${shopItem.name}_${draw}_${tex}.png`;
    }
    return `https://gta5root.top/fivem/items101/${shopItem.name}.png`;
}

function ticketImgUrl(itemName) {
    return `nui://ox_inventory/web/images/${itemName}.png`;
}

const RARITY_COLORS = {
    common:    'var(--common)',
    rare:      'var(--rare)',
    epic:      'var(--epic)',
    legendary: 'var(--legendary)',
    mythic:    'var(--mythic)',
};

function rarityColor(rarity) {
    return RARITY_COLORS[rarity] || 'rgba(255,255,255,0.12)';
}

function nuiFetch(endpoint, body) {
    return fetch(`https://${state.resourceName}/${endpoint}`, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify(body || {}),
    }).then(r => r.json());
}

function updateBadge(count) {
    state.ticketCount = count;
    if (ticketBadge) ticketBadge.textContent = count;
}

// ==================== TAB ====================

function switchTab(tab) {
    tabBtns.forEach(b => b.classList.toggle('active', b.dataset.tab === tab));
    tabExchange.classList.toggle('active', tab === 'exchange');
    tabShop.classList.toggle('active', tab === 'shop');
}

tabBtns.forEach(btn => {
    btn.addEventListener('click', () => switchTab(btn.dataset.tab));
});

// ==================== EXCHANGE ====================

function computeTotal() {
    let total = 0;
    const breakdown = {};
    for (const slot of state.selected) {
        const mat = state.materials.find(m => m.slot === slot);
        if (!mat) continue;
        total += mat.ticketValue || 0;
        if (!breakdown[mat.rarity]) breakdown[mat.rarity] = 0;
        breakdown[mat.rarity] += mat.ticketValue || 0;
    }
    return { total, breakdown };
}

function updatePreview() {
    const count = state.selected.size;
    const { total, breakdown } = computeTotal();

    selCount.textContent = `${count} đã chọn`;

    if (count > 0) arrowIcon.classList.add('active');
    else           arrowIcon.classList.remove('active');

    if (count > 0 && !state.busy) {
        btnExchange.disabled = false;
        hintText.textContent = `Tổng: ${total} vé`;
    } else if (state.busy) {
        btnExchange.disabled = true;
        hintText.textContent = 'Đang xử lý...';
    } else {
        btnExchange.disabled = true;
        hintText.textContent = 'Chọn ít nhất 1 món';
    }

    if (total > 0) {
        ticketAmount.textContent = `${total} VÉ`;
        ticketAmount.classList.add('has-value');
        ticketCard.classList.add('has-value');
        ticketPH.style.display  = 'none';
        ticketImg.style.display = 'block';
    } else {
        ticketAmount.textContent = '— VÉ';
        ticketAmount.classList.remove('has-value');
        ticketCard.classList.remove('has-value');
        ticketPH.style.display  = '';
        ticketImg.style.display = 'none';
    }

    ticketBreak.innerHTML = '';
    const rarityOrder = ['legendary', 'mythic', 'epic', 'rare', 'common'];
    for (const r of rarityOrder) {
        if (!breakdown[r]) continue;
        const row = document.createElement('div');
        row.className = 'breakdown-row';
        row.innerHTML = `
            <span class="breakdown-rarity" style="color:${rarityColor(r)}">${r.toUpperCase()}</span>
            <span class="breakdown-val">+${breakdown[r]} vé</span>
        `;
        ticketBreak.appendChild(row);
    }
}

function renderGrid() {
    itemGrid.innerHTML = '';
    if (!state.materials || state.materials.length === 0) {
        const empty = document.createElement('div');
        empty.className   = 'empty-label';
        empty.textContent = 'Không có quần áo hợp lệ.';
        itemGrid.appendChild(empty);
        return;
    }

    const frag = document.createDocumentFragment();
    for (const mat of state.materials) {
        const card = document.createElement('div');
        card.className = 'item-card';
        card.dataset.slot = mat.slot;
        card.style.setProperty('--rarity-color', rarityColor(mat.rarity));

        const img = document.createElement('img');
        img.src     = imgUrl(mat);
        img.alt     = mat.name;
        img.loading = 'lazy';
        img.onerror = function() { this.src = imgUrl(mat.name); this.onerror = null; };

        const dot = document.createElement('div');
        dot.className = 'check-dot';

        card.appendChild(img);
        card.appendChild(dot);
        card.addEventListener('click', () => toggleSelect(mat.slot, card));
        frag.appendChild(card);
    }
    itemGrid.appendChild(frag);
}

function toggleSelect(slot, card) {
    if (state.busy) return;
    if (state.selected.has(slot)) {
        state.selected.delete(slot);
        card.classList.remove('selected');
    } else {
        state.selected.add(slot);
        card.classList.add('selected');
    }
    updatePreview();
}

btnExchange.addEventListener('click', () => {
    if (state.busy || state.selected.size === 0) return;
    const selectedSlots = Array.from(state.selected);
    state.busy = true;
    updatePreview();

    nuiFetch('exchange', { selectedSlots })
        .then(result => {
            if (result && result.success) {
                refreshItems();
            } else {
                state.busy = false;
                updatePreview();
            }
        })
        .catch(() => { state.busy = false; updatePreview(); });
});

// ==================== SHOP ====================

function getSlotInfo(slotType) {
    for (const key of Object.keys(state.clothingSlots)) {
        const s = state.clothingSlots[key];
        if (s.slotType === slotType) return s;
    }
    return null;
}

function getFilteredShopItems() {
    let items = [...state.shopItems];
    if (state.genderFilter !== 'all') {
        items = items.filter(i => i.gender === state.genderFilter);
    }
    if (state.sortMode === 'asc') {
        items.sort((a, b) => a.price - b.price);
    } else if (state.sortMode === 'desc') {
        items.sort((a, b) => b.price - a.price);
    }
    return items;
}

const BATCH_SIZE  = 20;
let renderedCount = 0;
let allShopItems  = [];

function renderShopBatch() {
    const end  = Math.min(renderedCount + BATCH_SIZE, allShopItems.length);
    const frag = document.createDocumentFragment();
    for (let i = renderedCount; i < end; i++) {
        frag.appendChild(buildShopRow(allShopItems[i]));
    }
    shopList.appendChild(frag);
    renderedCount = end;
}

function buildShopRow(shopItem) {
    const canAfford   = state.ticketCount >= shopItem.price;
    const slotInfo    = getSlotInfo(shopItem.slotType);
    const slotLabel   = slotInfo ? slotInfo.label : shopItem.slotType;
    const genderLabel = shopItem.gender === 0 ? 'Nam' : 'Nữ';
    const wrongGender = typeof shopItem.gender === 'number' && shopItem.gender !== state.pedGender;

    const row = document.createElement('div');
    row.className  = 'shop-row';
    row.dataset.id = shopItem.id;

    row.innerHTML = `
        <img class="shop-item-img" src="${shopImgUrl(shopItem)}" alt="${shopItem.label}" loading="lazy">
        <div class="shop-item-info">
            <div class="shop-item-label">${shopItem.label}</div>
            <div class="shop-item-meta">${slotLabel} · ${genderLabel}</div>
        </div>
        <div class="shop-item-price">
            <span class="price-num">${shopItem.price}</span>
            <span class="price-label">VÉ</span>
        </div>
        <div class="shop-item-actions">
            <button class="btn-try" data-id="${shopItem.id}" ${wrongGender ? 'disabled title="Sai giới tính"' : ''}>THỬ</button>
            <button class="btn-buy" data-id="${shopItem.id}" ${!canAfford ? 'disabled' : ''}>MUA</button>
        </div>
    `;

    const img = row.querySelector('.shop-item-img');
    img.onerror = function() { this.src = imgUrl(shopItem.name); this.onerror = null; };

    if (!wrongGender) {
        row.querySelector('.btn-try').addEventListener('click', (e) => {
            e.stopPropagation();
            handlePreview(shopItem);
        });
    }

    row.querySelector('.btn-buy').addEventListener('click', (e) => {
        e.stopPropagation();
        handleBuy(shopItem);
    });

    return row;
}

function renderShopList() {
    shopList.innerHTML = '';
    renderedCount = 0;
    allShopItems  = getFilteredShopItems();

    if (allShopItems.length === 0) {
        const empty = document.createElement('div');
        empty.className   = 'empty-label';
        empty.textContent = 'Không có item nào.';
        shopList.appendChild(empty);
        return;
    }

    renderShopBatch();
}

shopList.addEventListener('scroll', () => {
    if (renderedCount >= allShopItems.length) return;
    const { scrollTop, scrollHeight, clientHeight } = shopList;
    if (scrollTop + clientHeight >= scrollHeight - 60) {
        renderShopBatch();
    }
});

document.querySelectorAll('.filter-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        const type = btn.dataset.filter;
        const val  = btn.dataset.val;

        if (type === 'sort') {
            document.querySelectorAll('[data-filter="sort"]').forEach(b => b.classList.remove('active'));
            if (state.sortMode === val) {
                state.sortMode = 'none';
            } else {
                state.sortMode = val;
                btn.classList.add('active');
            }
        } else if (type === 'gender') {
            document.querySelectorAll('[data-filter="gender"]').forEach(b => b.classList.remove('active'));
            const parsed = val === 'all' ? 'all' : parseInt(val);
            if (state.genderFilter === parsed) {
                state.genderFilter = 'all';
            } else {
                state.genderFilter = parsed;
                btn.classList.add('active');
            }
        }

        renderShopList();
    });
});

function handlePreview(shopItem) {
    if (state.busy || state.previewActive) return;
    if (typeof shopItem.gender === 'number' && shopItem.gender !== state.pedGender) return;

    state.previewingId = shopItem.id;

    nuiFetch('previewItem', {
        slotType:   shopItem.slotType,
        drawableId: shopItem.drawableId,
        textureId:  shopItem.textureId,
        gender:     shopItem.gender,
    }).then(result => {
        if (result && result.error) {
            state.previewActive = false;
            state.previewingId  = null;
        }
        // neu ok: client.lua da gui hideUI, app da hidden
    }).catch(() => {
        state.previewActive = false;
        state.previewingId  = null;
    });
}

function handleBuy(shopItem) {
    if (state.busy) return;
    if (state.ticketCount < shopItem.price) return;

    nuiFetch('confirmBuy', { itemId: shopItem.id, label: shopItem.label, price: shopItem.price });
}

// ==================== OPEN / CLOSE ====================

function openUI(data) {
    state.materials     = data.materials     || [];
    state.rarityValue   = data.rarityValue   || {};
    state.ticketItem    = data.ticketItem    || 'ticket';
    state.shopItems     = data.shopItems     || [];
    state.clothingSlots = data.clothingSlots || {};
    state.pedGender     = typeof data.pedGender === 'number' ? data.pedGender : 0;
    state.selected      = new Set();
    state.busy          = false;
    state.previewActive = false;
    state.previewingId  = null;
    state.sortMode      = 'none';
    state.genderFilter  = 'all';

    updateBadge(data.ticketCount || 0);
    ticketImg.src = ticketImgUrl(state.ticketItem);

    document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));

    renderGrid();
    updatePreview();
    renderShopList();
    switchTab('exchange');
    app.classList.remove('hidden');
}

function closeUI() {
    app.classList.add('hidden');
    state.selected      = new Set();
    state.busy          = false;
    state.previewActive = false;
    state.previewingId  = null;
    nuiFetch('closeUI');
}

function refreshItems() {
    nuiFetch('refreshItems')
        .then(data => {
            if (!data || data.error) return;
            state.materials     = data.materials     || [];
            state.rarityValue   = data.rarityValue   || {};
            state.ticketItem    = data.ticketItem    || state.ticketItem;
            state.shopItems     = data.shopItems     || [];
            state.clothingSlots = data.clothingSlots || {};
            if (typeof data.pedGender === 'number') state.pedGender = data.pedGender;
            state.selected = new Set();
            state.busy     = false;
            updateBadge(data.ticketCount || 0);
            renderGrid();
            updatePreview();
            renderShopList();
        })
        .catch(() => { state.busy = false; updatePreview(); });
}

btnClose.addEventListener('click', closeUI);

// Block ESC khi dang preview
document.addEventListener('keydown', e => {
    if (e.key === 'Escape') {
        if (state.previewActive) return;
        if (!app.classList.contains('hidden')) closeUI();
    }
});

window.addEventListener('message', e => {
    const msg = e.data;
    if (!msg || !msg.action) return;

    switch (msg.action) {
        case 'open':
            if (msg.resourceName) state.resourceName = msg.resourceName;
            openUI(msg.data || {});
            break;

        // Client.lua gui xuong sau khi previewItem ok -> an UI
        case 'hideUI':
            state.previewActive = true;
            app.classList.add('hidden');
            break;

        // Client.lua gui xuong sau ESC trong game -> hien lai UI
        case 'previewStopped':
            state.previewActive = false;
            state.previewingId  = null;
            app.classList.remove('hidden');
            break;

        // Clinet.lua gui xuong confirm mua
        case 'buyResult':
            state.busy = false;
            if (msg.result && msg.result.success) {
                updateBadge(msg.result.ticketCount);
                renderShopList();
            }
            break;
    }
});