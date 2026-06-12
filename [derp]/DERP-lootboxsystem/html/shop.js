'use strict';

const RARITY_ORDER = ['mythic', 'legendary', 'epic', 'rare', 'common'];
const RARITY_COLORS = {
    mythic:    '#ffd700',
    legendary: '#ff4d4d',
    epic:      '#a64dff',
    rare:      '#4d9eff',
    common:    '#ffffff'
};

let shopNpcId      = null;
let shopItems      = null;
let clothesPath    = '';
let boxImagePath   = '';
let playerName     = '';
let playerCoin     = 0;
let playerCash     = 0;
let activeFilter   = 'all';
let activeGender   = 'all';
let activePayment  = 'cash';
let cartCash       = {};
let cartCoin       = {};

// DOM refs
const shopOverlay     = document.getElementById('shop-overlay');
const shopGrid        = document.getElementById('shop-grid');
const shopCloseBtn    = document.getElementById('shop-close-btn');
const detailModal     = document.getElementById('shop-detail-modal');
const detailBoxName   = document.getElementById('detail-box-name');
const detailItemsGrid = document.getElementById('detail-items-grid');
const detailCloseBtn  = document.getElementById('detail-close-btn');
const playerNameEl    = document.getElementById('player-name-display');
const playerCoinEl    = document.getElementById('player-coin-display');
const cartItemsList   = document.getElementById('cart-items-list');
const cartCountEl     = document.getElementById('cart-count');
const cartSummaryEl   = document.getElementById('cart-summary');
const cartCoinBtn     = document.getElementById('cart-coin-btn');
const cartCashBtn     = document.getElementById('cart-cash-btn');
const cartClearBtn    = document.getElementById('cart-clear-btn');
const filterTabs      = document.querySelectorAll('.filter-tab');
const paymentTabs     = document.querySelectorAll('.payment-tab');
const genderTabs      = document.querySelectorAll('.gender-tab');

// ---- Active Cart Helpers ----
function getActiveCart() {
    return activePayment === 'cash' ? cartCash : cartCoin;
}

function setActiveCart(c) {
    if (activePayment === 'cash') cartCash = c;
    else cartCoin = c;
}

// ---- Filter & Sort ----
function getFilteredItems() {
    if (!shopItems) return [];

    let items = shopItems.filter(item => {
        if (activePayment === 'cash') return item.price.cash && item.price.cash > 0;
        return item.price.coin && item.price.coin > 0;
    });

    // Gender filter
    if (activeGender === 'male') {
        items = items.filter(item => item.tags && item.tags.includes('male'));
    } else if (activeGender === 'female') {
        items = items.filter(item => item.tags && item.tags.includes('female'));
    }

    if (activeFilter === 'bestseller') {
        items.sort((a, b) => {
            const aHot = a.tags && a.tags.includes('bestseller') ? 1 : 0;
            const bHot = b.tags && b.tags.includes('bestseller') ? 1 : 0;
            return bHot - aHot;
        });
    } else if (activeFilter === 'new') {
        items.sort((a, b) => (b.id || 0) - (a.id || 0));
    } else if (activeFilter === 'price-asc') {
        const key = activePayment === 'cash' ? 'cash' : 'coin';
        items.sort((a, b) => (a.price[key] || 0) - (b.price[key] || 0));
    } else if (activeFilter === 'price-desc') {
        const key = activePayment === 'cash' ? 'cash' : 'coin';
        items.sort((a, b) => (b.price[key] || 0) - (a.price[key] || 0));
    }

    return items;
}

// ---- Filter Tabs ----
filterTabs.forEach(tab => {
    tab.onclick = () => {
        filterTabs.forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        activeFilter = tab.dataset.filter;
        renderShopGrid(getFilteredItems());
    };
});

// ---- Payment Tabs ----
paymentTabs.forEach(tab => {
    tab.onclick = () => {
        paymentTabs.forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        activePayment = tab.dataset.payment;
        renderShopGrid(getFilteredItems());
        renderCart();
    };
});

// ---- Gender Tabs ----
genderTabs.forEach(tab => {
    tab.onclick = () => {
        genderTabs.forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        activeGender = tab.dataset.gender;
        renderShopGrid(getFilteredItems());
    };
});

// ---- Player Info ----
function renderPlayerInfo() {
    if (playerNameEl) playerNameEl.textContent = playerName;
    if (playerCoinEl) playerCoinEl.innerHTML =
        '<span style="color:#4dff91">$' + playerCash.toLocaleString() + '</span>' +
        ' &nbsp;|&nbsp; ' +
        '<span style="color:#05F2F2">' + playerCoin.toLocaleString() + ' ◈</span>';
}

// ---- Cart Logic ----
function addToCart(item) {
    const c = getActiveCart();
    if (c[item.name]) {
        if (c[item.name].qty < 99) c[item.name].qty++;
    } else {
        c[item.name] = { item, qty: 1 };
    }
    renderCart();
}

function removeFromCart(itemName) {
    const c = getActiveCart();
    delete c[itemName];
    renderCart();
}

function updateCartQty(itemName, delta) {
    const c = getActiveCart();
    if (!c[itemName]) return;
    const next = c[itemName].qty + delta;
    if (next < 1) { removeFromCart(itemName); return; }
    c[itemName].qty = Math.min(99, next);
    renderCart();
}

function clearCart() {
    setActiveCart({});
    renderCart();
}

function getCartTotals() {
    const c = getActiveCart();
    let total = 0;
    for (const key in c) {
        const { item, qty } = c[key];
        const unit = activePayment === 'cash' ? (item.price.cash || 0) : (item.price.coin || 0);
        total += unit * qty;
    }
    return total;
}

function getCartTotalQty() {
    const c = getActiveCart();
    let n = 0;
    for (const k in c) n += c[k].qty;
    return n;
}

function renderCartSummary() {
    const c = getActiveCart();
    if (Object.keys(c).length === 0) return;
    cartCountEl.textContent = getCartTotalQty();
    const total = getCartTotals();

    if (activePayment === 'cash') {
        cartSummaryEl.textContent = 'Tổng: $' + total.toLocaleString();
        cartCashBtn.textContent = 'THANH TOÁN  $' + total.toLocaleString();
    } else {
        cartSummaryEl.textContent = 'Tổng: ' + total.toLocaleString() + ' ◈';
        cartCoinBtn.textContent = 'THANH TOÁN  ' + total.toLocaleString() + ' ◈';
    }
}

function renderCart() {
    cartItemsList.innerHTML = '';
    const c = getActiveCart();
    const entries = Object.values(c);

    if (entries.length === 0) {
        const empty = document.createElement('div');
        empty.id = 'cart-empty';
        empty.textContent = 'Giỏ hàng trống';
        cartItemsList.appendChild(empty);
        cartCountEl.classList.add('hidden');
        cartSummaryEl.textContent = '';
        cartCoinBtn.classList.add('hidden');
        cartCashBtn.classList.add('hidden');
        cartClearBtn.classList.add('hidden');
        return;
    }

    entries.forEach(({ item, qty }) => {
        const row = document.createElement('div');
        row.className = 'cart-item-row';

        const img = document.createElement('img');
        img.className = 'cart-item-img';
        img.src = item.type === 'cloth' ? clothesPath + item.name + '.png' : `nui://ox_inventory/web/images/${item.name}.png`;
        img.alt = item.label;
        img.onerror = () => { img.style.opacity = '0.2'; };

        const info = document.createElement('div');
        info.className = 'cart-item-info';

        const nameEl = document.createElement('div');
        nameEl.className = 'cart-item-name';
        nameEl.textContent = item.label;

        const priceEl = document.createElement('div');
        priceEl.className = 'cart-item-price';
        const unit = activePayment === 'cash' ? (item.price.cash || 0) : (item.price.coin || 0);
        priceEl.textContent = activePayment === 'cash'
            ? '$' + (unit * qty).toLocaleString()
            : (unit * qty).toLocaleString() + ' ◈';

        info.appendChild(nameEl);
        info.appendChild(priceEl);

        const controls = document.createElement('div');
        controls.className = 'cart-item-controls';

        const btnMinus = document.createElement('button');
        btnMinus.className = 'cart-qty-btn';
        btnMinus.textContent = '−';
        btnMinus.onclick = () => updateCartQty(item.name, -1);

        const qtyInput = document.createElement('input');
        qtyInput.className = 'cart-qty-input';
        qtyInput.type = 'number';
        qtyInput.value = qty;
        qtyInput.min = 1;
        qtyInput.max = 99;
        qtyInput.oninput = () => {
            let v = parseInt(qtyInput.value) || 1;
            if (v < 1) v = 1;
            if (v > 99) v = 99;
            c[item.name].qty = v;
            renderCartSummary();
        };
        qtyInput.onblur = () => {
            let v = parseInt(qtyInput.value) || 1;
            if (v < 1) v = 1;
            if (v > 99) v = 99;
            qtyInput.value = v;
            c[item.name].qty = v;
            renderCart();
        };

        const btnPlus = document.createElement('button');
        btnPlus.className = 'cart-qty-btn';
        btnPlus.textContent = '+';
        btnPlus.onclick = () => updateCartQty(item.name, 1);

        const btnRemove = document.createElement('button');
        btnRemove.className = 'cart-remove-btn';
        btnRemove.textContent = '✕';
        btnRemove.onclick = () => removeFromCart(item.name);

        controls.appendChild(btnMinus);
        controls.appendChild(qtyInput);
        controls.appendChild(btnPlus);
        controls.appendChild(btnRemove);

        row.appendChild(img);
        row.appendChild(info);
        row.appendChild(controls);
        cartItemsList.appendChild(row);
    });

    cartCountEl.textContent = getCartTotalQty();
    cartCountEl.classList.remove('hidden');
    cartClearBtn.classList.remove('hidden');

    const total = getCartTotals();

    if (activePayment === 'cash') {
        cartSummaryEl.textContent = 'Tổng: $' + total.toLocaleString();
        cartCashBtn.textContent = 'THANH TOÁN  $' + total.toLocaleString();
        cartCashBtn.classList.remove('hidden');
        cartCoinBtn.classList.add('hidden');
    } else {
        cartSummaryEl.textContent = 'Tổng: ' + total.toLocaleString() + ' ◈';
        cartCoinBtn.textContent = 'THANH TOÁN  ' + total.toLocaleString() + ' ◈';
        cartCoinBtn.classList.remove('hidden');
        cartCashBtn.classList.add('hidden');
    }
}

// ---- Checkout ----
function sendCartCheckout() {
    if (!shopNpcId) return;
    const c = getActiveCart();
    const cartItems = Object.values(c).map(({ item, qty }) => ({ name: item.name, amount: qty }));
    if (cartItems.length === 0) return;
    fetch(`https://${GetParentResourceName()}/shopBuyCart`, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({ npcId: shopNpcId, cartItems, paymentType: 'coin' })
    });
    clearCart();
}

function sendCartCheckoutCash() {
    if (!shopNpcId) return;
    const c = getActiveCart();
    const cartItems = Object.values(c).map(({ item, qty }) => ({ name: item.name, amount: qty }));
    if (cartItems.length === 0) return;
    fetch(`https://${GetParentResourceName()}/shopBuyCart`, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({ npcId: shopNpcId, cartItems, paymentType: 'cash' })
    });
    clearCart();
}

cartCoinBtn.onclick  = () => sendCartCheckout();
cartCashBtn.onclick  = () => sendCartCheckoutCash();
cartClearBtn.onclick = () => clearCart();

// ---- Shop Grid ----
function renderShopGrid(items) {
    shopGrid.innerHTML = '';
    items.forEach(item => {
        const card = document.createElement('div');
        card.className = 'shop-card';

        if (item.tags && item.tags.length > 0) {
            const badges = document.createElement('div');
            badges.className = 'shop-card-badges';
            if (item.tags.includes('bestseller')) {
                const b = document.createElement('span');
                b.className = 'badge badge-hot';
                b.textContent = 'BÁN CHẠY';
                badges.appendChild(b);
            }
            if (item.tags.includes('new')) {
                const b = document.createElement('span');
                b.className = 'badge badge-new';
                b.textContent = 'MỚI';
                badges.appendChild(b);
            }
            if (item.tags.includes('male')) {
                const b = document.createElement('span');
                b.className = 'badge badge-male';
                b.textContent = 'NAM';
                badges.appendChild(b);
            }
            if (item.tags.includes('female')) {
                const b = document.createElement('span');
                b.className = 'badge badge-female';
                b.textContent = 'NỮ';
                badges.appendChild(b);
            }
            if (badges.children.length > 0) card.appendChild(badges);
        }

        const imgWrap = document.createElement('div');
        imgWrap.className = 'shop-card-img-wrap';
        const img = document.createElement('img');
        img.className = 'shop-card-img';
        img.src = item.type === 'cloth' ? clothesPath + item.name + '.png' : `nui://ox_inventory/web/images/${item.name}.png`;
        img.alt = item.label;
        img.onerror = () => { img.style.opacity = '0.25'; };
        imgWrap.appendChild(img);

        const nameEl = document.createElement('div');
        nameEl.className = 'shop-card-name';
        nameEl.textContent = item.label;

        const prices = document.createElement('div');
        prices.className = 'shop-card-prices';

        if (activePayment === 'cash' && item.price.cash && item.price.cash > 0) {
            const row = document.createElement('div');
            row.className = 'shop-price-row';
            row.innerHTML = '<span class="price-label">GIÁ</span><span class="price-cash">$' + item.price.cash.toLocaleString() + '</span>';
            prices.appendChild(row);
        } else if (activePayment === 'coin' && item.price.coin && item.price.coin > 0) {
            const row = document.createElement('div');
            row.className = 'shop-price-row';
            row.innerHTML = '<span class="price-label">GIÁ</span><span class="price-coin">' + item.price.coin.toLocaleString() + ' ◈</span>';
            prices.appendChild(row);
        }

        const actions = document.createElement('div');
        actions.className = 'shop-card-actions';

        const btnBuy = document.createElement('button');
        btnBuy.className = 'shop-btn shop-btn-buy';
        btnBuy.textContent = 'THÊM VÀO GIỎ';
        btnBuy.onclick = () => addToCart(item);

        const btnDetail = document.createElement('button');
        btnDetail.className = 'shop-btn shop-btn-detail';
        btnDetail.textContent = 'CHI TIẾT';
        btnDetail.onclick = () => openDetailModal(item);

        actions.appendChild(btnBuy);
        if (item.contents && item.contents.length > 0) actions.appendChild(btnDetail);

        card.appendChild(imgWrap);
        card.appendChild(nameEl);
        card.appendChild(prices);
        card.appendChild(actions);
        shopGrid.appendChild(card);
    });
}

// ---- Detail Modal ----
function openDetailModal(item) {
    if (!item.contents || item.contents.length === 0) return;
    detailBoxName.textContent = item.label + ' — NỘI DUNG';
    detailItemsGrid.innerHTML = '';

    const sorted = [...item.contents].sort((a, b) =>
        RARITY_ORDER.indexOf(a.rarity) - RARITY_ORDER.indexOf(b.rarity)
    );

    sorted.forEach(entry => {
        const color = RARITY_COLORS[entry.rarity] || '#fff';
        const card  = document.createElement('div');
        card.className = 'detail-item-card';
        card.style.setProperty('--rc', color);

        const img = document.createElement('img');
        img.src = entry.type === 'cloth' ? clothesPath + entry.name + '.png' : `nui://ox_inventory/web/images/${entry.name}.png`;
        img.alt = entry.name;
        img.onerror = () => { img.style.opacity = '0.25'; };

        card.appendChild(img);
        detailItemsGrid.appendChild(card);
    });

    detailModal.classList.remove('hidden');
}

detailCloseBtn.onclick = () => detailModal.classList.add('hidden');

// ---- Close Shop ----
function closeShop() {
    shopOverlay.classList.add('hidden');
    detailModal.classList.add('hidden');
    shopNpcId     = null;
    shopItems     = null;
    cartCash      = {};
    cartCoin      = {};
    activeFilter  = 'all';
    activeGender  = 'all';
    activePayment = 'cash';
    fetch('https://' + GetParentResourceName() + '/shopClose', {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({})
    });
}

shopCloseBtn.onclick = closeShop;

document.addEventListener('keydown', (e) => {
    if (e.key !== 'Escape') return;
    if (shopOverlay.classList.contains('hidden')) return;
    e.stopImmediatePropagation();
    if (!detailModal.classList.contains('hidden')) {
        detailModal.classList.add('hidden');
        return;
    }
    closeShop();
}, true);

// ---- NUI Entry Point ----
window.addEventListener('message', (e) => {
    const data = e.data;
    if (!data || !data.action) return;

    if (data.action === 'openShop') {
        shopNpcId     = data.npcId;
        shopItems     = data.items;
        clothesPath   = data.clothesPath || '';
        boxImagePath  = data.imagePath   || '';
        playerName    = data.playerName  || '';
        playerCoin    = data.coinBalance || 0;
        playerCash    = data.cashBalance || 0;

        cartCash      = {};
        cartCoin      = {};
        activeFilter  = 'all';
        activeGender  = 'all';
        activePayment = data.defaultPayment || 'cash';

        filterTabs.forEach(t => t.classList.toggle('active', t.dataset.filter === 'all'));
        paymentTabs.forEach(t => t.classList.toggle('active', t.dataset.payment === activePayment));
        genderTabs.forEach(t => t.classList.toggle('active', t.dataset.gender === 'all'));

        renderPlayerInfo();
        renderCart();
        renderShopGrid(getFilteredItems());
        shopOverlay.classList.remove('hidden');
        return;
    }

    if (data.action === 'closeShop') {
        shopOverlay.classList.add('hidden');
        detailModal.classList.add('hidden');
        return;
    }

    if (data.action === 'updateCoin') {
        playerCoin = data.coinBalance || 0;
        renderPlayerInfo();
    }

    if (data.action === 'updateCash') {
        playerCash = data.cashBalance || 0;
        renderPlayerInfo();
    }
});