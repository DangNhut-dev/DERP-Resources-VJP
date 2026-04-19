(function () {
    'use strict';

    const RESOURCE = 'derp-weedshop';
    const NOOP = function () {};

    // ---------- State ----------
    const state = {
        activeTab: 'listings',
        config: null,
        stats: null,
        listings: [],
        orders: [],
        contacts: [],
        conversations: [],
        myItems: [],
        currentChat: null,
        pendingDeal: null,
        clockTimers: []
    };

    // ---------- Helpers ----------
    function $(sel, root) { return (root || document).querySelector(sel); }
    function $$(sel, root) { return Array.prototype.slice.call((root || document).querySelectorAll(sel)); }

    function el(tag, opts) {
        const n = document.createElement(tag);
        if (!opts) return n;
        if (opts.cls) n.className = opts.cls;
        if (opts.html != null) n.innerHTML = opts.html;
        if (opts.text != null) n.textContent = opts.text;
        if (opts.attrs) Object.keys(opts.attrs).forEach(function (k) { n.setAttribute(k, opts.attrs[k]); });
        return n;
    }

    function post(endpoint, payload) {
        return fetch('https://' + RESOURCE + '/' + endpoint, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json;charset=UTF-8' },
            body: JSON.stringify(payload || {})
        }).then(function (r) { return r.json().catch(function () { return null; }); })
          .catch(function () { return null; });
    }

    function pad(n) { return n < 10 ? '0' + n : '' + n; }

    function formatMoney(n) {
        if (n == null) return '0';
        return String(Math.floor(n)).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    }

    function formatDateShort(ts) {
        if (!ts) return '';
        const d = (typeof ts === 'string') ? new Date(ts.replace(' ', 'T')) : new Date(ts);
        if (isNaN(d.getTime())) return '';
        return pad(d.getHours()) + ':' + pad(d.getMinutes());
    }

    function timeAgo(ts) {
        if (!ts) return '';
        const d = (typeof ts === 'string') ? new Date(ts.replace(' ', 'T')) : new Date(ts);
        if (isNaN(d.getTime())) return '';
        const diff = (Date.now() - d.getTime()) / 1000;
        if (diff < 60) return 'vừa xong';
        if (diff < 3600) return Math.floor(diff / 60) + 'p';
        if (diff < 86400) return Math.floor(diff / 3600) + 'h';
        return Math.floor(diff / 86400) + 'd';
    }

    function toast(msg, type) {
        const t = $('#toast');
        if (!t) return;
        t.textContent = msg;
        t.className = 'toast' + (type ? ' ' + type : '');
        t.hidden = false;
        clearTimeout(t._timer);
        t._timer = setTimeout(function () { t.hidden = true; }, 2200);
    }

    function avatarInitials(name) {
        if (!name) return '?';
        const parts = name.split(/\s+/);
        if (parts.length === 1) return parts[0].charAt(0).toUpperCase();
        return (parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase();
    }

    // ---------- Boot ----------
    function boot() {
        bindTabs();
        bindModals();
        refreshAll();
    }

    function refreshAll() {
        post('getInitialData').then(function (data) {
            if (!data) return;
            state.config = data.config || {};
            state.stats = data.stats || {};
            state.listings = data.listings || [];
            state.orders = data.orders || [];
            state.contacts = data.contacts || [];
            state.conversations = data.conversations || [];
            state.myItems = data.myItems || [];
            updateBadges(data.unreadCount || 0);
            renderActiveTab();
        });
    }

    function updateBadges(unread) {
        const badge = $('#badge-messages');
        if (badge) {
            if (unread > 0) {
                badge.textContent = unread > 9 ? '9+' : String(unread);
                badge.hidden = false;
            } else {
                badge.hidden = true;
            }
        }
        const ordersBadge = $('#badge-orders');
        if (ordersBadge) {
            if (state.orders.length > 0) {
                ordersBadge.textContent = String(state.orders.length);
                ordersBadge.hidden = false;
            } else {
                ordersBadge.hidden = true;
            }
        }
    }

    // ---------- Tabs ----------
    function bindTabs() {
        $$('.tab-btn').forEach(function (btn) {
            btn.addEventListener('click', function () {
                const tab = btn.getAttribute('data-tab');
                if (!tab) return;
                switchTab(tab);
            });
        });
    }

    function switchTab(tab) {
        state.activeTab = tab;
        $$('.tab-btn').forEach(function (b) {
            b.classList.toggle('active', b.getAttribute('data-tab') === tab);
        });
        $$('.tab-panel').forEach(function (p) {
            p.classList.toggle('active', p.id === 'panel-' + tab);
        });
        renderActiveTab();
    }

    function renderActiveTab() {
        if (state.activeTab === 'listings') renderListings();
        else if (state.activeTab === 'messages') renderConversations();
        else if (state.activeTab === 'orders') renderOrders();
        else if (state.activeTab === 'contacts') renderContacts();
    }

    // ---------- LISTINGS ----------
    function renderListings() {
        const body = $('#listings-body');
        if (!body) return;
        if (!state.listings.length) {
            body.innerHTML =
                '<div class="empty-state">' +
                '<i class="fa-solid fa-cannabis"></i>' +
                '<div class="empty-title">Chưa có đăng bán</div>' +
                '<div class="empty-sub">Ấn + để đăng món đầu tiên</div></div>';
            return;
        }
        body.innerHTML = '';
        state.listings.forEach(function (l) {
            body.appendChild(buildListingCard(l));
        });
    }

    function buildListingCard(l) {
        const card = el('div', { cls: 'card' });
        const title = el('div', { cls: 'card-title' });
        title.innerHTML = '<i class="fa-solid fa-cannabis"></i>' + escapeHtml(l.item_label || l.item);
        card.appendChild(title);

        const row1 = el('div', { cls: 'card-row' });
        row1.innerHTML = '<span class="card-label">Số lượng</span><span class="card-value">' + l.amount + 'g</span>';
        card.appendChild(row1);

        const row2 = el('div', { cls: 'card-row' });
        row2.innerHTML = '<span class="card-label">Giá/g</span><span class="card-value card-price">$' + formatMoney(l.price_per_unit) + '</span>';
        card.appendChild(row2);

        const row3 = el('div', { cls: 'card-row' });
        row3.innerHTML = '<span class="card-label">Tổng</span><span class="card-value card-price">$' + formatMoney(l.amount * l.price_per_unit) + '</span>';
        card.appendChild(row3);

        const meta = el('div', { cls: 'card-meta', html: '<i class="fa-solid fa-clock"></i> Hết hạn ' + formatDateShort(l.expires_at) });
        meta.style.marginTop = '8px';
        card.appendChild(meta);

        const actions = el('div', { cls: 'card-actions' });
        const cancelBtn = el('button', { cls: 'btn-danger', text: 'Hủy' });
        cancelBtn.addEventListener('click', function () { cancelListing(l.id); });
        actions.appendChild(cancelBtn);
        card.appendChild(actions);

        return card;
    }

    function cancelListing(id) {
        post('cancelListing', { listingId: id }).then(function (res) {
            if (res && res.ok) {
                toast('Đã hủy', 'success');
                refreshAll();
            } else {
                toast((res && res.msg) || 'Lỗi', 'error');
            }
        });
    }

    // ---------- NEW LISTING MODAL ----------
    function bindModals() {
        $('#btn-new-listing').addEventListener('click', openNewListingModal);
        $('#modal-close').addEventListener('click', closeNewListingModal);
        $('#modal-cancel').addEventListener('click', closeNewListingModal);
        $('#modal-submit').addEventListener('click', submitNewListing);
        $('#input-item').addEventListener('change', updateItemHint);
        $('#input-amount').addEventListener('input', updatePricePreview);
        $('#input-price').addEventListener('input', updatePricePreview);
        $('#counter-close').addEventListener('click', closeCounterModal);
        $('#counter-cancel').addEventListener('click', closeCounterModal);
        $('#counter-submit').addEventListener('click', submitCounter);
        $('#chat-back').addEventListener('click', closeChat);
    }

    function openNewListingModal() {
        post('getMyItems').then(function (items) {
            state.myItems = items || [];
            const select = $('#input-item');
            select.innerHTML = '';
            if (!state.myItems.length) {
                const opt = el('option', { text: 'Không có hàng trong túi', attrs: { disabled: 'disabled' } });
                select.appendChild(opt);
                $('#modal-submit').disabled = true;
            } else {
                state.myItems.forEach(function (it) {
                    const opt = el('option', {
                        text: it.label + ' (x' + it.count + ')',
                        attrs: { value: it.name }
                    });
                    select.appendChild(opt);
                });
                $('#modal-submit').disabled = false;
            }
            updateItemHint();
            updatePricePreview();
            $('#modal-new-listing').hidden = false;
        });
    }

    function closeNewListingModal() {
        $('#modal-new-listing').hidden = true;
    }

    function updateItemHint() {
        const name = $('#input-item').value;
        const item = state.myItems.find(function (i) { return i.name === name; });
        const hint = $('#item-hint');
        if (!item) {
            hint.textContent = '';
            return;
        }
        const marketPrice = Math.floor((item.priceMin + item.priceMax) / 2);
        hint.innerHTML = 'Giá thị trường: <strong>$' + formatMoney(marketPrice) + '/g</strong> &middot; Có: ' + item.count + 'g';
        const amount = $('#input-amount');
        amount.max = item.count;
        if (parseInt(amount.value, 10) > item.count) amount.value = item.count;
        const price = $('#input-price');
        if (!price.value || parseInt(price.value, 10) < 1) {
            price.value = marketPrice;
        }
        updatePricePreview();
    }

    function updatePricePreview() {
        const a = parseInt($('#input-amount').value, 10) || 0;
        const p = parseInt($('#input-price').value, 10) || 0;
        $('#price-preview').textContent = 'Tổng: $' + formatMoney(a * p);
    }

    function submitNewListing() {
        const item = $('#input-item').value;
        const amount = parseInt($('#input-amount').value, 10);
        const price = parseInt($('#input-price').value, 10);
        if (!item || !amount || !price) {
            toast('Nhập đầy đủ', 'error');
            return;
        }
        post('createListing', { item: item, amount: amount, pricePerUnit: price }).then(function (res) {
            if (res && res.ok) {
                toast('Đã đăng bán', 'success');
                closeNewListingModal();
                refreshAll();
            } else {
                toast((res && res.msg) || 'Lỗi', 'error');
            }
        });
    }

    // ---------- ORDERS ----------
    function renderOrders() {
        const body = $('#orders-body');
        if (!body) return;
        stopClockTimers();
        if (!state.orders.length) {
            body.innerHTML =
                '<div class="empty-state">' +
                '<i class="fa-solid fa-box-open"></i>' +
                '<div class="empty-title">Không có đơn</div>' +
                '<div class="empty-sub">Nhận deal để bắt đầu giao</div></div>';
            return;
        }
        body.innerHTML = '';
        state.orders.forEach(function (o) {
            body.appendChild(buildOrderCard(o));
        });
    }

    function buildOrderCard(o) {
        const card = el('div', { cls: 'card' });

        const title = el('div', { cls: 'card-title' });
        title.innerHTML = '<i class="fa-solid fa-truck-fast"></i>' + escapeHtml(o.npc_name || 'NPC');
        card.appendChild(title);

        const row1 = el('div', { cls: 'card-row' });
        row1.innerHTML = '<span class="card-label">Hàng</span><span class="card-value">' + escapeHtml(o.item_label || o.item) + ' x' + o.amount + 'g</span>';
        card.appendChild(row1);

        const row2 = el('div', { cls: 'card-row' });
        row2.innerHTML = '<span class="card-label">Giá</span><span class="card-value card-price">$' + formatMoney(o.total_price) + '</span>';
        card.appendChild(row2);

        const row3 = el('div', { cls: 'card-row' });
        const locLabel = (o.location && o.location.label) || 'Không rõ';
        row3.innerHTML = '<span class="card-label">Điểm hẹn</span><span class="card-value">' + escapeHtml(locLabel) + '</span>';
        card.appendChild(row3);

        const row4 = el('div', { cls: 'card-row' });
        const countdownEl = el('span', { cls: 'countdown' });
        countdownEl.textContent = '—';
        row4.innerHTML = '<span class="card-label">Gặp nhau sau</span>';
        row4.appendChild(countdownEl);
        card.appendChild(row4);
        registerCountdown(countdownEl, o.deadline_unix || o.deadline_at);

        const actions = el('div', { cls: 'card-actions' });
        const waypointBtn = el('button', { cls: 'btn-primary', html: '<i class="fa-solid fa-location-dot"></i> Chỉ đường' });
        waypointBtn.addEventListener('click', function () {
            if (o.location && o.location.coords) {
                post('setWaypoint', o.location.coords);
                toast('Đã mở chỉ đường', 'success');
            }
        });
        const cancelBtn = el('button', { cls: 'btn-danger', text: 'Hủy' });
        cancelBtn.addEventListener('click', function () {
            confirmCancelOrder(o.id);
        });
        actions.appendChild(waypointBtn);
        actions.appendChild(cancelBtn);
        card.appendChild(actions);

        return card;
    }

    function confirmCancelOrder(id) {
        post('cancelOrder', { orderId: id }).then(function (res) {
            if (res && res.ok) {
                toast('Đã hủy đơn', 'success');
                refreshAll();
            } else {
                toast((res && res.msg) || 'Lỗi', 'error');
            }
        });
    }

    function registerCountdown(node, deadlineStr) {
        const deadline = parseServerTime(deadlineStr);
        if (!deadline) {
            node.textContent = '—';
            return;
        }
        const tick = function () {
            const remain = Math.floor((deadline - Date.now()) / 1000);
            if (remain <= 0) {
                node.textContent = 'ĐẾN GIỜ';
                node.classList.remove('warn');
                node.classList.add('danger');
                return;
            }
            const h = Math.floor(remain / 3600);
            const m = Math.floor((remain % 3600) / 60);
            const s = remain % 60;
            if (h > 0) {
                node.textContent = pad(h) + ':' + pad(m) + ':' + pad(s);
            } else {
                node.textContent = pad(m) + ':' + pad(s);
            }
            if (remain < 60) {
                node.classList.remove('warn');
                node.classList.add('danger');
            } else if (remain < 180) {
                node.classList.add('warn');
                node.classList.remove('danger');
            } else {
                node.classList.remove('warn');
                node.classList.remove('danger');
            }
        };
        tick();
        const id = setInterval(tick, 1000);
        state.clockTimers.push(id);
    }

    function stopClockTimers() {
        state.clockTimers.forEach(function (id) { clearInterval(id); });
        state.clockTimers = [];
    }

    function parseServerTime(s) {
        if (s == null) return null;
        // Number: co the la giay hoac millis
        if (typeof s === 'number') {
            // > 10^12 = millis, nho hon = giay
            return s > 1e12 ? s : s * 1000;
        }
        // Co the la string so (oxmysql tra ve string dep)
        if (/^\d+$/.test(s)) {
            const n = parseInt(s, 10);
            return n > 1e12 ? n : n * 1000;
        }
        // String format 'YYYY-MM-DD HH:MM:SS' - MySQL tra theo UTC
        const iso = s.replace(' ', 'T');
        let d = new Date(iso + 'Z');
        if (!isNaN(d.getTime())) return d.getTime();
        d = new Date(iso);
        return isNaN(d.getTime()) ? null : d.getTime();
    }

    // ---------- CONTACTS ----------
    function renderContacts() {
        const body = $('#contacts-body');
        if (!body) return;

        if (!state.contacts.length) {
            body.innerHTML =
                '<div class="empty-state">' +
                '<i class="fa-solid fa-users-slash"></i>' +
                '<div class="empty-title">Chưa mở khóa khách</div>' +
                '<div class="empty-sub">Giao dịch để tăng quan hệ</div></div>';
            return;
        }
        body.innerHTML = '';
        state.contacts.forEach(function (c) {
            body.appendChild(buildContactCard(c));
        });
    }

    function buildContactCard(c) {
        const row = el('div', { cls: 'contact-card' });
        const av = el('div', { cls: 'contact-avatar', text: avatarInitials(c.name) });
        const info = el('div', { cls: 'contact-info' });
        const name = el('div', { cls: 'contact-name', text: c.name || ('NPC #' + c.id) });
        const sub = el('div', { cls: 'contact-sub' });
        const trustBar = el('div', { cls: 'trust-bar' });
        const trustFill = el('div', { cls: 'trust-fill' });
        const tv = Math.max(0, Math.min(100, c.trust || 0));
        // Neu trust > 0 nhung < 8, hien thi 8% de thay duoc visually
        trustFill.style.width = (tv > 0 && tv < 8 ? 8 : tv) + '%';
        trustBar.appendChild(trustFill);
        const trustLabel = el('span', { text: 'Trust ' + (c.trust || 0) });
        const dealsLabel = el('span', { text: '• ' + (c.successful_deals || 0) + '/' + (c.total_deals || 0) });
        sub.appendChild(trustLabel);
        sub.appendChild(trustBar);
        sub.appendChild(dealsLabel);
        info.appendChild(name);
        info.appendChild(sub);
        row.appendChild(av);
        row.appendChild(info);
        row.addEventListener('click', function () { openChat(c.id, c); });
        return row;
    }

    // ---------- CONVERSATIONS ----------
    function renderConversations() {
        const body = $('#messages-body');
        if (!body) return;
        if (!state.conversations.length) {
            body.innerHTML =
                '<div class="empty-state">' +
                '<i class="fa-solid fa-comment-slash"></i>' +
                '<div class="empty-title">Chưa có tin nhắn</div>' +
                '<div class="empty-sub">Đăng bán để khách liên hệ</div></div>';
            return;
        }
        body.innerHTML = '';
        state.conversations.forEach(function (c) {
            body.appendChild(buildConvRow(c));
        });
    }

    function buildConvRow(c) {
        const row = el('div', { cls: 'conv-row' + (c.unread_count > 0 ? ' unread' : '') });
        const av = el('div', { cls: 'contact-avatar', text: avatarInitials(c.npc_name) });
        const main = el('div', { cls: 'conv-main' });
        const name = el('div', { cls: 'conv-name', text: c.npc_name || ('NPC #' + c.npc_id) });
        const preview = el('div', { cls: 'conv-preview' });
        const prefix = c.last_sender === 'player' ? 'Bạn: ' : '';
        preview.textContent = prefix + (c.last_message || '');
        main.appendChild(name);
        main.appendChild(preview);

        const right = el('div');
        right.style.cssText = 'display:flex;flex-direction:column;align-items:flex-end;gap:4px;';
        const time = el('div', { cls: 'conv-time', text: timeAgo(c.last_at) });
        right.appendChild(time);
        if (c.unread_count > 0) right.appendChild(el('div', { cls: 'conv-unread-dot' }));

        row.appendChild(av);
        row.appendChild(main);
        row.appendChild(right);

        row.addEventListener('click', function () { openChat(c.npc_id, { name: c.npc_name }); });
        return row;
    }

    // ---------- CHAT ----------
    function openChat(npcId, npcData) {
        state.currentChat = { npcId: npcId, npcData: npcData || {} };
        loadChatMessages();
    }

    function loadChatMessages() {
        if (!state.currentChat) return;
        const npcId = state.currentChat.npcId;
        post('getMessages', { npcId: npcId }).then(function (res) {
            if (!state.currentChat || state.currentChat.npcId !== npcId) return;
            if (!res) return;
            state.currentChat.npc = res.npc || state.currentChat.npcData || {};
            state.currentChat.activeDeal = res.activeDeal || null;
            state.currentChat.trust = res.trust || 0;
            renderChat(res.messages || []);
            const overlay = $('#overlay-chat');
            overlay.hidden = false;
            const cb = $('#chat-body');
            if (cb) cb.scrollTop = cb.scrollHeight;
        });
    }

    function closeChat() {
        $('#overlay-chat').hidden = true;
        state.currentChat = null;
        refreshAll();
    }

    function renderChat(messages) {
        const npc = (state.currentChat && state.currentChat.npc) || {};
        $('#chat-name').textContent = npc.name || 'NPC';
        $('#chat-avatar').textContent = avatarInitials(npc.name);

        const trust = state.currentChat.trust || 0;
        $('#chat-trust-value').textContent = trust;
        const tvc = Math.max(0, Math.min(100, trust));
        $('#chat-trust-fill').style.width = (tvc > 0 && tvc < 8 ? 8 : tvc) + '%';

        const body = $('#chat-body');
        body.innerHTML = '';

        let lastSender = null;
        messages.forEach(function (m) {
            const bubble = buildBubble(m, lastSender !== m.sender);
            body.appendChild(bubble);
            lastSender = m.sender;
        });

        body.scrollTop = body.scrollHeight;

        renderChatActions();
    }

    function buildBubble(m, differentSender) {
        const wrap = el('div', { cls: 'bubble-wrap ' + (m.sender === 'npc' ? 'npc' : 'player') + (differentSender ? ' different-sender' : '') });

        let bubble;
        const isSystem = (m.message_type === 'system');
        const isOffer = (m.message_type === 'offer' || m.message_type === 'counter');
        const isAccept = (m.message_type === 'accept');

        if (isSystem) {
            bubble = el('div', { cls: 'bubble system-msg', text: m.message });
            wrap.classList.remove('npc');
            wrap.classList.remove('player');
            wrap.style.justifyContent = 'center';
            wrap.appendChild(bubble);
            return wrap;
        }

        if (isOffer && m.metadata) {
            bubble = el('div', { cls: 'bubble offer-card' });
            const title = el('div', { cls: 'offer-title', text: m.sender === 'npc' ? (m.message_type === 'counter' ? 'Giá mới' : 'Đề nghị mua') : 'Bạn ra giá' });
            bubble.appendChild(title);
            const itemText = m.metadata.item_label || m.metadata.item || '-';
            bubble.appendChild(buildOfferRow('Mặt hàng', itemText));
            if (m.metadata.amount) bubble.appendChild(buildOfferRow('Số lượng', m.metadata.amount + 'g'));
            bubble.appendChild(buildOfferRow('Giá/g', '$' + formatMoney(m.metadata.price_per_unit), true));
            if (m.metadata.total) bubble.appendChild(buildOfferRow('Tổng', '$' + formatMoney(m.metadata.total), true));
            const time = el('div', { cls: 'bubble-time', text: formatDateShort(m.created_at) });
            wrap.appendChild(bubble);
            wrap.appendChild(time);
            return wrap;
        }

        if (isAccept && m.metadata) {
            bubble = el('div', { cls: 'bubble accept-card' });
            const title = el('div', { cls: 'offer-title', text: 'Đã chốt' });
            bubble.appendChild(title);
            bubble.appendChild(buildOfferRow('Điểm hẹn', m.metadata.location_label || '-'));
            if (m.metadata.deadline_minutes) bubble.appendChild(buildOfferRow('Thời gian', m.metadata.deadline_minutes + ' phút'));
            if (m.metadata.total_price) bubble.appendChild(buildOfferRow('Tổng', '$' + formatMoney(m.metadata.total_price), true));
            const textLine = el('div');
            textLine.style.cssText = 'margin-top:8px;font-size:11px;color:var(--text-secondary);font-style:italic;';
            textLine.textContent = m.message;
            bubble.appendChild(textLine);
            const time = el('div', { cls: 'bubble-time', text: formatDateShort(m.created_at) });
            wrap.appendChild(bubble);
            wrap.appendChild(time);
            return wrap;
        }

        bubble = el('div', { cls: 'bubble', text: m.message });
        wrap.appendChild(bubble);
        const time = el('div', { cls: 'bubble-time', text: formatDateShort(m.created_at) });
        wrap.appendChild(time);
        return wrap;
    }

    function buildOfferRow(label, value, isPrice) {
        const row = el('div', { cls: 'offer-row' });
        const l = el('span', { cls: 'label', text: label });
        const v = el('span', { cls: 'value' + (isPrice ? ' price' : ''), text: value });
        row.appendChild(l);
        row.appendChild(v);
        return row;
    }

    function renderChatActions() {
        const container = $('#chat-actions');
        container.innerHTML = '';

        const deal = state.currentChat && state.currentChat.activeDeal;
        if (!deal) {
            const hint = el('div', { cls: 'hint', text: 'Không có deal đang chờ' });
            container.appendChild(hint);
            return;
        }

        // Player vua counter xong -> cho NPC
        if (deal.lastActor === 'player') {
            const hint = el('div', { cls: 'hint', text: 'Đang chờ khách phản hồi...' });
            container.appendChild(hint);
            return;
        }

        // Deal da accept va dang cho chon delivery time
        if (deal.accepted && !deal.hasLocation === false && state.pendingDeal) {
            // handled by delivery modal
        }

        // NPC vua gui offer/counter
        const accept = el('button', { cls: 'btn-primary', text: 'Accept' });
        accept.addEventListener('click', function () { dealAccept(deal); });

        const counter = el('button', { cls: 'btn-secondary', text: 'Ra giá' });
        const canCounter = (deal.round || 0) < (deal.maxRounds || 2);
        if (!canCounter) counter.disabled = true;
        counter.addEventListener('click', function () { openCounterModal(deal); });

        const decline = el('button', { cls: 'btn-danger', text: 'Từ chối' });
        decline.addEventListener('click', function () { dealDecline(); });

        container.appendChild(accept);
        container.appendChild(counter);
        container.appendChild(decline);

        const info = el('div', { cls: 'hint', text: 'Lượt ra giá: ' + (deal.round || 0) + '/' + (deal.maxRounds || 2) });
        container.appendChild(info);
    }

    function dealAccept(deal) {
        if (!state.currentChat) return;
        post('dealAccept', { npcId: state.currentChat.npcId }).then(function (res) {
            if (!res || !res.ok) {
                toast((res && res.msg) || 'Lỗi', 'error');
                return;
            }
            if (res.needsDeliveryTime) {
                openDeliveryTimeModal(res.location, res.deliveryPresets || [15, 20, 25, 30, 35, 40], deal);
            } else {
                reopenCurrentChat();
            }
        });
    }

    function dealDecline() {
        if (!state.currentChat) return;
        post('dealDecline', { npcId: state.currentChat.npcId }).then(function (res) {
            if (res && res.ok) {
                toast('Đã từ chối', 'success');
                setTimeout(function () { reopenCurrentChat(); }, 250);
            }
        });
    }

    function openCounterModal(deal) {
        state.pendingDeal = deal;
        const info = $('#counter-info');
        const marketPrice = deal.marketPrice || null;

        let html =
            '<div>NPC hỏi: <strong>$' + formatMoney(deal.currentOffer) + '/g</strong></div>' +
            '<div>Số lượng: <strong>' + deal.amount + 'g</strong></div>';
        if (marketPrice) {
            html += '<div>Giá thị trường: <strong>$' + formatMoney(marketPrice) + '/g</strong></div>';
        }
        html += '<div>Lượt: ' + (deal.round || 0) + '/' + (deal.maxRounds || 2) + '</div>';
        info.innerHTML = html;

        const input = $('#counter-input');
        input.value = deal.currentOffer;
        $('#modal-counter').hidden = false;
    }

    function closeCounterModal() {
        $('#modal-counter').hidden = true;
        state.pendingDeal = null;
    }

    function submitCounter() {
        const price = parseInt($('#counter-input').value, 10);
        if (!price || price <= 0) { toast('Giá không hợp lệ', 'error'); return; }
        if (!state.currentChat) return;
        post('dealCounter', { npcId: state.currentChat.npcId, price: price }).then(function (res) {
            if (!res || !res.ok) {
                toast((res && res.msg) || 'Lỗi', 'error');
                return;
            }
            closeCounterModal();
            // Delay nho cho DB flush roi reload
            setTimeout(function () {
                reopenCurrentChat();
                if (res.result === 'accepted') {
                    setTimeout(function () {
                        triggerDeliveryTimeAfterAccept();
                    }, 400);
                }
            }, 250);
        });
    }

    function triggerDeliveryTimeAfterAccept() {
        // After player counter -> NPC accept, we still need player to confirm delivery time
        // Re-call dealAccept se lay location moi + presets
        if (!state.currentChat) return;
        post('dealAccept', { npcId: state.currentChat.npcId }).then(function (res) {
            if (res && res.ok && res.needsDeliveryTime) {
                openDeliveryTimeModal(res.location, res.deliveryPresets || [15, 20, 25, 30, 35, 40]);
            } else {
                reopenCurrentChat();
            }
        });
    }

    function openDeliveryTimeModal(location, presets) {
        const info = $('#delivery-info');
        info.innerHTML =
            '<div>Điểm hẹn: <strong>' + escapeHtml(location.label) + '</strong></div>' +
            '<div>Chọn thời gian giao:</div>';
        const grid = $('#preset-grid');
        grid.innerHTML = '';
        presets.forEach(function (mins) {
            const btn = el('button', { cls: 'preset-btn' });
            btn.innerHTML = '<span class="num">' + mins + '</span><span>phút</span>';
            btn.addEventListener('click', function () {
                confirmDeliveryTime(mins);
            });
            grid.appendChild(btn);
        });
        $('#modal-delivery-time').hidden = false;
    }

    function confirmDeliveryTime(minutes) {
        if (!state.currentChat) return;
        post('dealConfirmDelivery', {
            npcId: state.currentChat.npcId,
            deliveryMinutes: minutes
        }).then(function (res) {
            if (!res || !res.ok) {
                toast((res && res.msg) || 'Lỗi', 'error');
                return;
            }
            $('#modal-delivery-time').hidden = true;
            toast('Đã chốt đơn', 'success');
            closeChat();
            switchTab('orders');
            refreshAll();
        });
    }

    function reopenCurrentChat() {
        if (!state.currentChat) return;
        loadChatMessages();
    }

    // ---------- Escape HTML ----------
    function escapeHtml(s) {
        if (s == null) return '';
        return String(s)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    // ---------- Listen for push updates ----------
    window.addEventListener('message', function (ev) {
        const data = ev.data || {};
        if (data.action === 'weedshop:refresh') {
            refreshAll();
            if (state.currentChat) reopenCurrentChat();
        }
    });

    // Boot
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', boot);
    } else {
        boot();
    }
})();