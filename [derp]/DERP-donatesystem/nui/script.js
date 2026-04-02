'use strict';
console.log('[DERP] resource name:', window.location.hostname);

const RESOURCE_NAME = window.location.hostname.replace('cfx-nui-', '');

let appConfig = {};
let currentTicket = null;
let isAdmin = false;

// ──────────────────────────────────────────
// Utility
// ──────────────────────────────────────────

function getSelectedBank() {
    const id = document.getElementById('selectMethod')?.value;
    const banks = appConfig.payment?.banks || [];
    return banks.find(b => b.id === id && b.enabled) || null;
}

function formatMoney(amount) {
    if (!amount && amount !== 0) return '0';
    return Math.floor(amount).toLocaleString('vi-VN');
}

function formatDate(dateStr) {
    if (!dateStr) return '—';
    const d = new Date(dateStr);
    return d.toLocaleDateString('vi-VN') + ' ' + d.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });
}

function statusBadge(status) {
    const map = { pending: 'Pending', paid: 'Đã nhận', rejected: 'Từ chối' };
    return `<span class="badge badge-${status}">${map[status] || status}</span>`;
}

async function nuiFetch(endpoint, data = {}) {
    try {
        const res = await fetch(`https://${RESOURCE_NAME}/${endpoint}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        const text = await res.text();
        if (!text || !text.trim()) return {};
        return JSON.parse(text);
    } catch (e) {
        console.error('[DERP-donate] nuiFetch error:', endpoint, e);
        return {};
    }
}

function notify(msg, type = 'info') {
    // Simple in-UI toast
    let toast = document.getElementById('uiToast');
    if (!toast) {
        toast = document.createElement('div');
        toast.id = 'uiToast';
        toast.style.cssText = `position:fixed;top:16px;right:16px;background:var(--bg-card);border:1px solid var(--cyan-border);color:var(--text-main);padding:10px 16px;border-radius:4px;font-size:13px;z-index:9999;transition:opacity 0.3s;`;
        document.body.appendChild(toast);
    }
    if (type === 'error') toast.style.borderColor = '#ff4d4d';
    else if (type === 'success') toast.style.borderColor = '#00e676';
    else toast.style.borderColor = 'var(--cyan-border)';
    toast.textContent = msg;
    toast.style.opacity = '1';
    clearTimeout(toast._timer);
    toast._timer = setTimeout(() => { toast.style.opacity = '0'; }, 3000);
}

// ──────────────────────────────────────────
// Page navigation
// ──────────────────────────────────────────

function showPage(pageId) {
    document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
    document.querySelectorAll('.nav-tab').forEach(t => t.classList.remove('active'));
    const page = document.getElementById('page-' + pageId);
    if (page) page.classList.add('active');
    const tab = document.querySelector(`.nav-tab[data-page="${pageId}"]`);
    if (tab) tab.classList.add('active');

    if (pageId === 'history') loadHistory();
    if (pageId === 'admin') loadAdminTickets();
    if (pageId === 'revenue') loadRevenue();
}

// ──────────────────────────────────────────
// Render payment preview on donate page
// ──────────────────────────────────────────

function renderPaymentPreview() {
    const container = document.getElementById('paymentPreview');
    if (!container) return;
    const bank = getSelectedBank();
    if (!bank) { container.innerHTML = ''; return; }
    container.innerHTML = `
        <div class="payment-card">
            <div class="method-title">🏦 ${bank.bankName}</div>
            <div class="method-detail">Số tài khoản</div>
            <div class="method-value">${bank.accountNumber}</div>
            <div class="method-detail" style="margin-top:6px">Chủ tài khoản</div>
            <div class="method-value">${bank.accountName}</div>
        </div>`;
}

// ──────────────────────────────────────────
// QR Page
// ──────────────────────────────────────────

function renderQRPage(ticket) {
    currentTicket = ticket;
    const bank = getSelectedBank();
    const cfg = appConfig;
    const ticketId = ticket.ticketId;
    const amount = ticket.amount;
    const transferContent = `DONATE ${ticketId}`;

    let qrHtml = '';
    let infoHtml = '';

    if (bank && cfg.qr?.enabled) {
        const qrUrl = `${cfg.qr.baseUrl}${bank.bankId}-${bank.accountNumber}-compact.png?amount=${amount}&addInfo=${encodeURIComponent(transferContent)}&accountName=${encodeURIComponent(bank.accountName)}`;
        qrHtml = `
        <div class="qr-image-wrap">
            <img src="${qrUrl}" alt="QR Code" onerror="this.parentElement.innerHTML='<div style=\'color:#aaa;font-size:12px;text-align:center;padding:10px\'>QR không khả dụng</div>'">
        </div>`;
        infoHtml = `
        <div class="qr-info">
            <div class="form-label" style="margin-bottom:6px">Nội Dung Chuyển Khoản</div>
            <div class="transfer-content">${transferContent}</div>
            <div class="info-row"><span class="label">Ngân hàng</span><span class="value">${bank.bankName}</span></div>
            <div class="info-row"><span class="label">STK</span><span class="value">${bank.accountNumber}</span></div>
            <div class="info-row"><span class="label">Chủ TK</span><span class="value">${bank.accountName}</span></div>
            <div class="info-row"><span class="label">Số tiền</span><span class="value" style="color:var(--cyan)">${formatMoney(amount)} VND</span></div>
            <div class="info-row"><span class="label">Ticket ID</span><span class="value" style="color:var(--cyan)">${ticketId}</span></div>
        </div>`;
    } else {
        infoHtml = `<div class="ui-notice" style="color:#ff4d4d">Không tìm thấy thông tin ngân hàng.</div>`;
    }

    document.getElementById('qrSection').innerHTML = qrHtml + infoHtml;
    showPage('qr');
}

// ──────────────────────────────────────────
// History
// ──────────────────────────────────────────

async function loadHistory() {
    const container = document.getElementById('ticketList');
    container.innerHTML = '<div class="empty-state"><div class="spinner"></div></div>';
    const res = await nuiFetch('getMyTickets');
    const tickets = res.tickets || [];
    if (!tickets.length) {
        container.innerHTML = '<div class="empty-state">Chưa có ticket nào</div>';
        return;
    }
    container.innerHTML = tickets.map(t => `
        <div class="ticket-item">
            <span class="ticket-id">${t.ticket_id}</span>
            <span class="ticket-amount">${formatMoney(t.amount)} <small style="font-size:11px;color:var(--text-muted)">VND</small></span>
            <span class="ticket-note">${t.note || '—'}</span>
            <span class="ticket-date">${formatDate(t.created_at)}</span>
            ${statusBadge(t.status)}
        </div>
    `).join('');
}

// ──────────────────────────────────────────
// Admin Panel
// ──────────────────────────────────────────

async function loadAdminTickets(filter = '', search = '') {
    const container = document.getElementById('adminTicketList');
    container.innerHTML = '<div class="empty-state"><div class="spinner"></div></div>';
    const res = await nuiFetch('adminGetTickets', { filter, search });
    const tickets = (res.tickets || []);
    if (!tickets.length) {
        container.innerHTML = '<div class="empty-state">Không có ticket nào</div>';
        return;
    }
    container.innerHTML = tickets.map(t => `
        <div class="ticket-item" id="admin-ticket-${t.ticket_id}">
            <span class="ticket-id">${t.ticket_id}</span>
            <span style="font-size:12px;color:var(--text-muted);min-width:120px;flex-shrink:0">${t.player_name || t.identifier}</span>
            <span class="ticket-amount">${formatMoney(t.amount)} <small style="font-size:11px;color:var(--text-muted)">VND</small></span>
            <span class="ticket-note">${t.note || '—'}</span>
            <span class="ticket-date">${formatDate(t.created_at)}</span>
            ${statusBadge(t.status)}
            ${t.status === 'pending' ? `
            <div class="admin-actions">
                <button class="btn btn-success" onclick="adminConfirm('${t.ticket_id}')">✓</button>
                <button class="btn btn-danger" onclick="adminReject('${t.ticket_id}')">✗</button>
            </div>` : ''}
        </div>
    `).join('');
}

async function adminConfirm(ticketId) {
    const btn = document.querySelector(`#admin-ticket-${ticketId} .btn-success`);
    if (btn) btn.disabled = true;
    const res = await nuiFetch('adminConfirmTicket', { ticketId });
    if (res.success) {
        // notify(res.message, 'success');
        loadAdminTickets(
            document.getElementById('adminFilter').value,
            document.getElementById('adminSearch').value
        );
    } else {
        // notify(res.message || 'Lỗi xác nhận', 'error');
        if (btn) btn.disabled = false;
    }
}

async function adminReject(ticketId) {
    const btn = document.querySelector(`#admin-ticket-${ticketId} .btn-danger`);
    if (btn) btn.disabled = true;
    const res = await nuiFetch('adminRejectTicket', { ticketId });
    if (res.success) {
        // notify(res.message, 'success');
        loadAdminTickets(
            document.getElementById('adminFilter').value,
            document.getElementById('adminSearch').value
        );
    } else {
        // notify(res.message || 'Lỗi từ chối', 'error');
        if (btn) btn.disabled = false;
    }
}

// ──────────────────────────────────────────
// Revenue
// ──────────────────────────────────────────

async function loadRevenue() {
    const res = await nuiFetch('getRevenue');
    if (!res.success) return;
    document.getElementById('statTotal').textContent = formatMoney(res.total) + ' VND';
    document.getElementById('statToday').textContent = formatMoney(res.today) + ' VND';
    document.getElementById('statMonth').textContent = formatMoney(res.thisMonth) + ' VND';

    const logs = res.logs || [];
    const container = document.getElementById('revenueList');
    if (!logs.length) {
        container.innerHTML = '<div class="empty-state">Chưa có giao dịch nào</div>';
        return;
    }
    container.innerHTML = logs.map(l => `
        <div class="ticket-item">
            <span class="ticket-id">${l.ticket_id}</span>
            <span style="font-size:12px;color:var(--text-muted);min-width:130px;flex-shrink:0">${l.player_name || l.identifier}</span>
            <span class="ticket-amount">${formatMoney(l.amount)} <small style="font-size:11px;color:var(--text-muted)">VND</small></span>
            <span class="ticket-note">${l.reward || '—'}</span>
            <span class="ticket-date">${formatDate(l.created_at)}</span>
            <span class="badge badge-paid">Xác nhận</span>
        </div>
    `).join('');
}

// ──────────────────────────────────────────
// Event listeners
// ──────────────────────────────────────────

function closeUI() {
    document.getElementById('app').classList.remove('visible');
    nuiFetch('closeUI');
}

document.getElementById('btnClose').addEventListener('click', closeUI);

document.addEventListener('keydown', e => {
    if (e.key === 'Escape') closeUI();
});

document.querySelectorAll('.nav-tab').forEach(tab => {
    tab.addEventListener('click', () => showPage(tab.dataset.page));
});

document.querySelectorAll('.hint-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        document.getElementById('inputAmount').value = btn.dataset.amount;
    });
});

document.getElementById('selectMethod').addEventListener('change', renderPaymentPreview);

document.getElementById('btnCreateTicket').addEventListener('click', async () => {
    const btn = document.getElementById('btnCreateTicket');
    const amount = document.getElementById('inputAmount').value;
    const note = document.getElementById('inputNote').value;

    if (!amount || isNaN(Number(amount)) || Number(amount) <= 0) {
        notify('Nhập số tiền hợp lệ', 'error');
        return;
    }

    btn.disabled = true;
    btn.textContent = 'Đang xử lý...';

    const pingRes = await nuiFetch('ping', {});
    console.log('[DERP] ping result:', JSON.stringify(pingRes));

    const res = await nuiFetch('createTicket', { amount: Number(amount), note });

    btn.disabled = false;
    btn.textContent = 'Tạo Ticket';

    if (res.success) {
        // notify(res.message, 'success');
        renderQRPage(res);
    } else {
        // notify(res.message || 'Có lỗi xảy ra', 'error');
    }
});

document.getElementById('btnBackFromQR').addEventListener('click', () => showPage('donate'));
document.getElementById('btnViewHistory').addEventListener('click', () => showPage('history'));

document.getElementById('btnAdminSearch').addEventListener('click', () => {
    const search = document.getElementById('adminSearch').value;
    const filter = document.getElementById('adminFilter').value;
    loadAdminTickets(filter, search);
});

// ──────────────────────────────────────────
// NUI message handler
// ──────────────────────────────────────────

window.addEventListener('message', e => {
    const data = e.data;
    if (!data || !data.action) return;

    if (data.action === 'openUI') {
        appConfig = data.config || {};
        isAdmin = !!appConfig.isAdmin;

        // Show/hide admin tabs
        document.querySelectorAll('.admin-only').forEach(el => {
            el.style.display = isAdmin ? '' : 'none';
        });

        // Reset to correct starting page
        showPage(data.page === 'admin' ? 'admin' : 'donate');

        // Render payment preview
        renderPaymentPreview();

        // Show app
        document.getElementById('app').classList.add('visible');
    }

    if (data.action === 'showPendingOverlay') {
        document.getElementById('pendingOverlay').classList.add('visible');
    }

    if (data.action === 'hidePendingOverlay') {
        document.getElementById('pendingOverlay').classList.remove('visible');
    }

    // Hiển thị player info
    document.getElementById('displayPlayerName').textContent = appConfig.playerName || '—';
    document.getElementById('displayCoin').textContent = formatMoney(appConfig.coin || 0);

    // Populate bank dropdown
    const select = document.getElementById('selectMethod');
    select.innerHTML = '';
    const banks = appConfig.payment?.banks || [];
    banks.filter(b => b.enabled).forEach(b => {
        const opt = document.createElement('option');
        opt.value = b.id;
        opt.textContent = b.label;
        select.appendChild(opt);
    });

    // Auto trigger preview với bank đầu tiên
    renderPaymentPreview();
});