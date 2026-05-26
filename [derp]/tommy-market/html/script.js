let market = null
let currentTab = 'buy'
let currentNpcId = null
let playerInventory = {}
let filterOwned = false
let isBlackmarket = false
let cart = {}
let searchQuery = ''
let playerMoney = { cash: 0, bank: 0, dirty: 0 }
let playerName = ''
let priceFilter = 'none'
let _buyItem = null
let _sellItem = null

const CLOTH_IMAGE_BASE = 'https://gta5root.top/fivem/items101/'

// ==================== HELPERS ====================

function sanitizeQty(val, min, max) {
    let n = parseInt(val)
    if (isNaN(n) || n < min) n = min
    if (max && n > max) n = max
    return n
}

function isValidQty(val) {
    const n = Number(val)
    return Number.isInteger(n) && n > 0
}

function getOwnedCount(itemName) {
    return parseInt(playerInventory[itemName]) || 0
}

function getItemImageUrl(item) {
    if (item && item.type === 'clothing') {
        return `${CLOTH_IMAGE_BASE}${item.name}.png`
    }
    return `nui://ox_inventory/web/images/${item.name}.png`
}

// ==================== MESSAGE ==================

window.addEventListener('message', (ev) => {
    const d = ev.data

    if (d.type === 'open') {
        market = d.market
        currentNpcId = market.id
        playerInventory = market.playerInventory || {}
        isBlackmarket = market.blackmarket || false
        playerName = market.playerName || 'Người chơi'
        playerMoney = {
            cash: market.playerCash || 0,
            bank: market.playerBank || 0,
            dirty: market.playerDirty || 0
        }
        cart = {}
        searchQuery = ''

        document.getElementById('shop-title').innerText = market.label || 'MARKET'
        document.getElementById('filterOwned').checked = false
        document.getElementById('searchInput').value = ''
        filterOwned = false

        document.getElementById('shop-overlay').classList.remove('hidden')
        updateTabs()
        renderPlayerInfo()
        renderCart()
        renderGrid()
    }

    if (d.type === 'close') {
        document.getElementById('shop-overlay').classList.add('hidden')
        cart = {}
    }

    if (d.type === 'updateItemAmount') {
        const { itemName, amount: newAmount } = d
        if (newAmount <= 0) delete playerInventory[itemName]
        else playerInventory[itemName] = newAmount
        renderGrid()
        renderCart()
    }

    if (d.type === 'updateMoney') {
        if (d.cash !== undefined) playerMoney.cash = d.cash
        if (d.bank !== undefined) playerMoney.bank = d.bank
        if (d.dirty !== undefined) playerMoney.dirty = d.dirty
        renderPlayerInfo()
    }
})

// ==================== PLAYER INFO ====================

function renderPlayerInfo() {
    document.getElementById('player-info-name').innerText = playerName.toUpperCase()

    const moneyEl = document.getElementById('player-info-money')
    moneyEl.innerHTML = ''

    if (isBlackmarket) {
        moneyEl.appendChild(makeMoneyRow('Tiền bẩn', playerMoney.dirty, 'dirty'))
    } else {
        moneyEl.appendChild(makeMoneyRow('Tiền mặt', playerMoney.cash, 'cash'))
        moneyEl.appendChild(makeMoneyRow('Ngân hàng', playerMoney.bank, 'bank'))
    }
}

function makeMoneyRow(label, amount, cls) {
    const row = document.createElement('div')
    row.className = 'money-row'
    row.innerHTML = `
        <span class="money-label">${label}</span>
        <span class="money-value ${cls}">$${Number(amount).toLocaleString()}</span>
    `
    return row
}

// ==================== TABS ====================

function updateTabs() {
    const type = market?.type || 'both'
    const tabBuy = document.getElementById('tabBuy')
    const tabSell = document.getElementById('tabSell')

    if (type === 'buy' || type === 'sell') {
        tabBuy.classList.add('hidden')
        tabSell.classList.add('hidden')
        currentTab = type
    } else {
        tabBuy.classList.remove('hidden')
        tabSell.classList.remove('hidden')
        currentTab = 'buy'
    }

    tabBuy.classList.toggle('active', currentTab === 'buy')
    tabSell.classList.toggle('active', currentTab === 'sell')
    syncFilterVisibility()
    syncCartVisibility()
}

function syncFilterVisibility() {
    const bar = document.getElementById('shop-sell-filters')
    if (currentTab === 'sell') {
        bar.classList.remove('hidden')
    } else {
        bar.classList.add('hidden')
        filterOwned = false
        priceFilter = 'none'
        const cbx = document.getElementById('filterOwned')
        if (cbx) cbx.checked = false
        document.querySelectorAll('.price-filter-btn').forEach(b => {
            b.classList.toggle('active', b.dataset.filter === 'none')
        })
    }
}

function syncCartVisibility() {
    const panel = document.getElementById('cart-panel')
    if (currentTab === 'buy') {
        panel.classList.remove('hidden')
    } else {
        panel.classList.add('hidden')
    }
}

document.getElementById('tabBuy').addEventListener('click', () => {
    currentTab = 'buy'
    document.getElementById('tabBuy').classList.add('active')
    document.getElementById('tabSell').classList.remove('active')
    syncFilterVisibility()
    syncCartVisibility()
    renderGrid()
})

document.getElementById('tabSell').addEventListener('click', () => {
    currentTab = 'sell'
    document.getElementById('tabSell').classList.add('active')
    document.getElementById('tabBuy').classList.remove('active')
    syncFilterVisibility()
    syncCartVisibility()
    renderGrid()
})

document.getElementById('filterOwned').addEventListener('click', function () {
    filterOwned = !filterOwned
    this.checked = filterOwned
    renderGrid()
})

document.querySelectorAll('.price-filter-btn').forEach(btn => {
    btn.addEventListener('click', function () {
        priceFilter = this.dataset.filter
        document.querySelectorAll('.price-filter-btn').forEach(b => b.classList.remove('active'))
        this.classList.add('active')
        renderGrid()
    })
})

document.getElementById('searchInput').addEventListener('input', function () {
    searchQuery = this.value.trim().toLowerCase()
    renderGrid()
})

// ==================== CART ====================

function addToCart(item) {
    if (cart[item.name]) cart[item.name].amount = Math.min(cart[item.name].amount + 1, 999)
    else cart[item.name] = { item, amount: 1 }
    renderCart()
    renderGrid()
}

function clearCart() {
    cart = {}
    renderCart()
    renderGrid()
}

function getCartTotal() {
    return Object.values(cart).reduce((s, e) => s + e.item.buyPrice * e.amount, 0)
}

function renderCart() {
    const container = document.getElementById('cart-items')
    const totalEl = document.getElementById('cart-total')
    const checkoutBtn = document.getElementById('checkout-btn')
    const emptyEl = document.getElementById('cart-empty')
    const paymentSection = document.getElementById('payment-section')
    const keys = Object.keys(cart)

    if (paymentSection) paymentSection.style.display = isBlackmarket ? 'none' : ''

    container.querySelectorAll('.cart-item').forEach(el => el.remove())

    if (keys.length === 0) {
        if (emptyEl) emptyEl.style.display = 'flex'
        totalEl.innerText = isBlackmarket ? '$0 Tiền bẩn' : '$0'
        checkoutBtn.disabled = true
        return
    }

    if (emptyEl) emptyEl.style.display = 'none'
    checkoutBtn.disabled = false

    for (const itemName of keys) {
        const { item, amount } = cart[itemName]
        const sub = item.buyPrice * amount
        const imgUrl = getItemImageUrl(item)

        const el = document.createElement('div')
        el.className = 'cart-item'
        el.innerHTML = `
            <img class="cart-item-img" src="${imgUrl}" onerror="this.style.display='none'">
            <div class="cart-item-info">
                <div class="cart-item-name">${item.label}</div>
                <div class="cart-item-sub">${isBlackmarket ? sub.toLocaleString() + ' Tiền bẩn' : '$' + sub.toLocaleString()}</div>
            </div>
            <div class="cart-item-ctrl">
                <button class="cart-qty-btn" data-name="${itemName}" data-action="dec">−</button>
                <input class="cart-qty-input" type="number" min="1" max="999" value="${amount}" data-name="${itemName}">
                <button class="cart-qty-btn" data-name="${itemName}" data-action="inc">+</button>
                <button class="cart-remove-btn" data-name="${itemName}">✕</button>
            </div>
        `
        container.appendChild(el)
    }

    const total = getCartTotal()
    totalEl.innerText = isBlackmarket ? `${total.toLocaleString()} Tiền bẩn` : `$${total.toLocaleString()}`
}

document.getElementById('cart-items').addEventListener('click', (e) => {
    const qBtn = e.target.closest('.cart-qty-btn')
    const rBtn = e.target.closest('.cart-remove-btn')

    if (qBtn) {
        const name = qBtn.dataset.name
        if (!cart[name]) return
        if (qBtn.dataset.action === 'inc') cart[name].amount = Math.min(cart[name].amount + 1, 999)
        else { cart[name].amount--; if (cart[name].amount <= 0) delete cart[name] }
        renderCart()
        renderGrid()
    }

    if (rBtn) {
        delete cart[rBtn.dataset.name]
        renderCart()
        renderGrid()
    }
})

document.getElementById('cart-items').addEventListener('input', (e) => {
    const input = e.target.closest('.cart-qty-input')
    if (!input) return
    const name = input.dataset.name
    if (!cart[name]) return

    if (input.value === '' || input.value === '-') return
    if (!isValidQty(input.value)) return

    cart[name].amount = sanitizeQty(input.value, 1, 999)
    const sub = cart[name].item.buyPrice * cart[name].amount
    const subEl = input.closest('.cart-item')?.querySelector('.cart-item-sub')
    if (subEl) subEl.innerText = isBlackmarket ? sub.toLocaleString() + ' Tiền bẩn' : '$' + sub.toLocaleString()

    const total = getCartTotal()
    document.getElementById('cart-total').innerText = isBlackmarket ? `${total.toLocaleString()} Tiền bẩn` : `$${total.toLocaleString()}`
})

document.getElementById('cart-items').addEventListener('keydown', (e) => {
    if (e.target.classList.contains('cart-qty-input')) {
        if (e.key === '.' || e.key === ',' || e.key === '-' || e.key === 'e') {
            e.preventDefault()
        }
    }
})

document.getElementById('clear-cart-btn').addEventListener('click', clearCart)

document.getElementById('checkout-btn').addEventListener('click', () => {
    const keys = Object.keys(cart)
    if (!keys.length) return

    const paymentType = isBlackmarket
        ? 'dirty'
        : (document.querySelector('input[name="payment"]:checked')?.value || 'cash')

    const items = keys.map(name => ({ name, amount: cart[name].amount }))

    fetch(`https://${GetParentResourceName()}/checkout`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ npcId: currentNpcId, items, paymentType })
    })

    cart = {}
    renderCart()
    renderGrid()
})

// ==================== GRID ====================

function renderGrid() {
    const grid = document.getElementById('shop-grid')
    grid.innerHTML = ''
    if (!market?.items?.length) return

    const type = market.type || 'both'

    let list = []
    for (const it of market.items) {
        if (currentTab === 'buy' && it.buyPrice == null) continue
        if (currentTab === 'sell' && it.sellPrice == null) continue
        if (currentTab === 'buy' && it.grade && market.playerGrade < it.grade) continue

        if (searchQuery) {
            const haystack = (it.label || '').toLowerCase() + (it.name || '').toLowerCase()
            if (!haystack.includes(searchQuery)) continue
        }

        const owned = getOwnedCount(it.name)

        // filterOwned tick → chỉ ẩn item không có khi được tick
        if (currentTab === 'sell' && filterOwned && owned <= 0) continue

        list.push(it)
    }

    if (currentTab === 'sell') {
        if (priceFilter === 'low') {
            list.sort((a, b) => (a.sellPrice || 0) - (b.sellPrice || 0))
        } else if (priceFilter === 'high') {
            list.sort((a, b) => (b.sellPrice || 0) - (a.sellPrice || 0))
        } else if (priceFilter === 'good') {
            list = list.filter(it => it.sellPrice != null && it.avgPrice != null && it.sellPrice > it.avgPrice)
            list.sort((a, b) => (b.sellPrice - b.avgPrice) - (a.sellPrice - a.avgPrice))
        }
    }

    for (const it of list) {
        const owned = getOwnedCount(it.name)
        const isOwned = owned > 0

        const card = document.createElement('div')
        card.className = 'shop-card'
        if (currentTab === 'sell' && !isOwned) card.classList.add('dimmed')

        const imgWrap = document.createElement('div')
        imgWrap.className = 'shop-card-img-wrap'

        const img = document.createElement('img')
        img.className = 'shop-card-img'
        img.src = getItemImageUrl(it)
        img.onerror = () => { img.style.display = 'none' }
        imgWrap.appendChild(img)

        if (currentTab === 'sell' && isOwned) {
            const badge = document.createElement('div')
            badge.className = 'owned-badge'
            badge.innerText = `x${owned}`
            imgWrap.appendChild(badge)
        }

        card.appendChild(imgWrap)

        const name = document.createElement('div')
        name.className = 'shop-card-name'
        name.innerText = it.label
        card.appendChild(name)

        const priceRow = document.createElement('div')
        priceRow.className = 'shop-card-price'

        const pLabel = document.createElement('span')
        pLabel.className = 'price-label'
        pLabel.innerText = currentTab === 'buy' ? 'Giá mua' : 'Giá bán'

        const pVal = document.createElement('span')
        pVal.className = 'price-value'

        if (currentTab === 'sell') {
            let arrow = ''
            if (it.sellPrice != null && it.avgPrice != null) {
                if (it.sellPrice > it.avgPrice) arrow = '<span class="price-arrow up">▲</span>'
                else if (it.sellPrice < it.avgPrice) arrow = '<span class="price-arrow down">▼</span>'
            }
            pVal.innerHTML = `${arrow}${it.sellPrice}$`
        } else {
            pVal.innerText = `${it.buyPrice}$`
        }

        priceRow.appendChild(pLabel)
        priceRow.appendChild(pVal)
        card.appendChild(priceRow)

        const actions = document.createElement('div')
        actions.className = 'shop-card-actions'

        if (currentTab === 'buy' && (type === 'buy' || type === 'both')) {
            const inCart = cart[it.name]?.amount || 0
            const addBtn = document.createElement('button')
            addBtn.className = 'shop-btn shop-btn-primary' + (inCart > 0 ? ' in-cart' : '')
            addBtn.innerText = inCart > 0 ? `GIỎ (${inCart})` : 'THÊM VÀO GIỎ'
            addBtn.onclick = () => addToCart(it)
            actions.appendChild(addBtn)
        }

        if (currentTab === 'sell' && (type === 'sell' || type === 'both') && it.sellPrice != null) {
            const sellBtn = document.createElement('button')
            sellBtn.className = 'shop-btn shop-btn-primary'
            sellBtn.innerText = 'BÁN'
            sellBtn.onclick = () => openSellModal(it)

            const sellAllBtn = document.createElement('button')
            sellAllBtn.className = 'shop-btn shop-btn-ghost'
            sellAllBtn.innerText = 'TẤT CẢ'
            sellAllBtn.onclick = () => sellAll(it)

            actions.appendChild(sellBtn)
            actions.appendChild(sellAllBtn)
        }

        card.appendChild(actions)
        grid.appendChild(card)
    }
}

// ==================== BUY MODAL ====================

function openBuyModal(item) {
    _buyItem = item
    document.getElementById('buy-item-name').innerText = item.label
    document.getElementById('buy-item-price-info').innerText = `Giá: ${item.buyPrice}$ / đơn vị`
    const input = document.getElementById('qty-input')
    input.value = 1
    updateBuyTotal()
    document.getElementById('shop-buy-modal').classList.remove('hidden')
}

function updateBuyTotal() {
    const qty = sanitizeQty(document.getElementById('qty-input').value, 1, 999)
    document.getElementById('buy-total-display').innerText = `TỔNG: $${((_buyItem?.buyPrice || 0) * qty).toLocaleString()}`
}

document.getElementById('qty-input').addEventListener('input', function () {
    if (this.value === '' || this.value === '-') return
    if (!isValidQty(this.value)) { this.value = sanitizeQty(this.value, 1, 999); return }
    updateBuyTotal()
})
document.getElementById('qty-input').addEventListener('keydown', (e) => {
    if (e.key === '.' || e.key === ',' || e.key === '-' || e.key === 'e') e.preventDefault()
})
document.getElementById('qty-dec').addEventListener('click', () => {
    const inp = document.getElementById('qty-input')
    inp.value = Math.max(1, sanitizeQty(inp.value, 1, 999) - 1)
    updateBuyTotal()
})
document.getElementById('qty-inc').addEventListener('click', () => {
    const inp = document.getElementById('qty-input')
    inp.value = Math.min(999, sanitizeQty(inp.value, 1, 999) + 1)
    updateBuyTotal()
})
document.getElementById('buy-cancel-btn').addEventListener('click', () => {
    document.getElementById('shop-buy-modal').classList.add('hidden')
    _buyItem = null
})
document.getElementById('buy-coin-btn').addEventListener('click', () => {
    if (!_buyItem) return
    const amount = sanitizeQty(document.getElementById('qty-input').value, 1, 999)
    fetch(`https://${GetParentResourceName()}/buy`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ npcId: currentNpcId, item: _buyItem.name, amount, paymentType: 'dirty' })
    })
    document.getElementById('shop-buy-modal').classList.add('hidden')
    _buyItem = null
})

// ==================== SELL MODAL ====================

function openSellModal(item) {
    _sellItem = item
    const max = getOwnedCount(item.name) || 1
    document.getElementById('sell-item-name').innerText = item.label
    document.getElementById('sell-item-price-info').innerText = `Giá: ${item.sellPrice}$ / đơn vị — Đang có: x${max}`
    const input = document.getElementById('sell-qty-input')
    input.value = 1
    input.max = max
    updateSellTotal()
    document.getElementById('shop-sell-modal').classList.remove('hidden')
}

function updateSellTotal() {
    const max = getOwnedCount(_sellItem?.name) || 1
    const qty = sanitizeQty(document.getElementById('sell-qty-input').value, 1, max)
    document.getElementById('sell-total-display').innerText = `NHẬN: $${((_sellItem?.sellPrice || 0) * qty).toLocaleString()}`
}

document.getElementById('sell-qty-input').addEventListener('input', function () {
    if (this.value === '' || this.value === '-') return
    const max = getOwnedCount(_sellItem?.name) || 1
    if (!isValidQty(this.value)) { this.value = sanitizeQty(this.value, 1, max); return }
    updateSellTotal()
})
document.getElementById('sell-qty-input').addEventListener('keydown', (e) => {
    if (e.key === '.' || e.key === ',' || e.key === '-' || e.key === 'e') e.preventDefault()
})
document.getElementById('sell-qty-dec').addEventListener('click', () => {
    const inp = document.getElementById('sell-qty-input')
    const max = getOwnedCount(_sellItem?.name) || 1
    inp.value = Math.max(1, sanitizeQty(inp.value, 1, max) - 1)
    updateSellTotal()
})
document.getElementById('sell-qty-inc').addEventListener('click', () => {
    const inp = document.getElementById('sell-qty-input')
    const max = getOwnedCount(_sellItem?.name) || 1
    inp.value = Math.min(max, sanitizeQty(inp.value, 1, max) + 1)
    updateSellTotal()
})
document.getElementById('sell-cancel-btn').addEventListener('click', () => {
    document.getElementById('shop-sell-modal').classList.add('hidden')
    _sellItem = null
})
document.getElementById('sell-confirm-btn').addEventListener('click', () => {
    if (!_sellItem) return
    const max = getOwnedCount(_sellItem.name) || 1
    const qty = sanitizeQty(document.getElementById('sell-qty-input').value, 1, max)
    fetch(`https://${GetParentResourceName()}/sell`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ npcId: currentNpcId, item: _sellItem.name, amount: qty })
    })
    document.getElementById('shop-sell-modal').classList.add('hidden')
    _sellItem = null
})

function sellAll(item) {
    const have = getOwnedCount(item.name)
    if (have <= 0) return
    fetch(`https://${GetParentResourceName()}/sell`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ npcId: currentNpcId, item: item.name, amount: have })
    })
}

// ==================== CLOSE ====================

function closeMarket() {
    fetch(`https://${GetParentResourceName()}/close`, { method: 'POST' })
    document.getElementById('shop-overlay').classList.add('hidden')
    cart = {}
}

document.getElementById('shop-close-btn').addEventListener('click', closeMarket)
document.addEventListener('keydown', (e) => { if (e.key === 'Escape') closeMarket() })