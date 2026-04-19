(function () {
    'use strict';

    const $ = BP.$, post = BP.post;

    const state = {
        open: false,
        currentScreen: 'lock',
        currentApp: null,
        apps: [],
        clock: null
    };

    // ---------- Clock ----------
    function renderClock() {
        const c = state.clock;
        const t = BP.formatTime(c);
        const lockTime = $('#lock-time');
        const statusTime = $('#status-time');
        const lockDate = $('#lock-date');
        const homeDate = $('#home-date');
        const homeGreet = $('#home-greeting-time');

        if (lockTime) lockTime.textContent = t;
        if (statusTime) statusTime.textContent = t;
        if (lockDate) lockDate.textContent = BP.formatDateLong(c).toUpperCase();
        if (homeDate) homeDate.textContent = BP.formatDateShort(c);
        if (homeGreet) homeGreet.textContent = BP.getGreeting(c);
    }

    function setClock(clock) {
        if (!clock) return;
        state.clock = clock;
        renderClock();
    }

    // ---------- Screens ----------
    function showScreen(name) {
        const screens = ['lock', 'home', 'app'];
        screens.forEach(function (s) {
            const node = $('#screen-' + s);
            if (!node) return;
            if (s === name) node.classList.add('active');
            else node.classList.remove('active');
        });
        state.currentScreen = name;
    }

    function openHome() {
        showScreen('home');
    }

    function openLock() {
        showScreen('lock');
    }

    function openAppView(app) {
        if (!app) return;
        state.currentApp = app;

        const title = $('#app-title');
        const body = $('#app-body');
        if (title) title.textContent = (app.name || app.id).toUpperCase();
        if (body) {
            body.innerHTML = '';

            // External app -> iframe
            if (app.external && app.resource) {
                mountExternalApp(body, app);
            } else {
                const view = BPApps.getView(app.id);
                if (view && typeof view.onOpen === 'function') {
                    try { view.onOpen(body, app); }
                    catch (e) { showPlaceholder(body); }
                } else {
                    showPlaceholder(body);
                }
            }
        }

        showScreen('app');

        post('openApp', { appId: app.id });
    }

    function mountExternalApp(body, app) {
        const iframe = document.createElement('iframe');
        iframe.className = 'app-iframe';
        iframe.src = 'https://cfx-nui-' + app.resource + '/html/app.html';
        iframe.setAttribute('allow', 'fullscreen');
        iframe.style.cssText = 'width:100%;height:100%;border:0;background:transparent;';
        iframe.dataset.appId = app.id;
        iframe.dataset.resource = app.resource;
        body.appendChild(iframe);
    }

    function closeAppView() {
        if (state.currentApp) {
            if (state.currentApp.external) {
                const body = $('#app-body');
                if (body) body.innerHTML = '';
            } else {
                const view = BPApps.getView(state.currentApp.id);
                if (view && typeof view.onClose === 'function') {
                    try { view.onClose($('#app-body'), state.currentApp); } catch (_) {}
                }
            }
        }
        state.currentApp = null;
        openHome();
    }

    function showPlaceholder(body) {
        body.innerHTML =
            '<div class="app-placeholder">' +
                '<div class="placeholder-icon"><i class="fa-regular fa-circle-dot"></i></div>' +
                '<div class="placeholder-title">App chưa được cài đặt</div>' +
                '<div class="placeholder-sub">Nội dung sẽ được nạp khi app sẵn sàng.</div>' +
            '</div>';
    }

    // ---------- Phone open/close ----------
    function openPhone(apps, clock) {
        state.apps = Array.isArray(apps) ? apps : [];
        if (clock) state.clock = clock;
        state.open = true;

        const wrap = $('#phone-wrapper');
        console.log('[BlackPhone] openPhone called, wrapper found:', !!wrap, 'apps:', state.apps.length);
        if (wrap) {
            wrap.classList.remove('hidden');
            wrap.classList.add('visible');
        }

        BPApps.renderGrid(state.apps, openAppView);
        openLock();
        renderClock();
    }

    function closePhone() {
        state.open = false;

        const wrap = $('#phone-wrapper');
        if (wrap) {
            wrap.classList.remove('visible');
            wrap.classList.add('hidden');
        }

        state.currentApp = null;
        post('close', {});
    }

    // ---------- Input handlers ----------
    function bindUI() {
        // Lock -> Home
        const lock = $('#screen-lock');
        if (lock) {
            lock.addEventListener('click', function () {
                if (state.currentScreen === 'lock') openHome();
            });
        }

        // App back
        const back = $('#app-back');
        if (back) {
            back.addEventListener('click', function (e) {
                e.stopPropagation();
                closeAppView();
            });
        }

        // ESC / Backspace de dong phone
        document.addEventListener('keydown', function (e) {
            if (!state.open) return;
            if (e.key === 'Escape') {
                e.preventDefault();
                if (state.currentScreen === 'app') closeAppView();
                else closePhone();
            } else if (e.key === 'Backspace' && state.currentScreen === 'app') {
                e.preventDefault();
                closeAppView();
            }
        });
    }

    // ---------- NUI messages ----------
    let domReady = false;
    const pendingMessages = [];

    function handleMessage(data) {
        try {
            if (data.action === 'open') {
                openPhone(data.apps, data.clock);
            } else if (data.action === 'close') {
                closePhone();
            } else if (data.action === 'clock') {
                setClock({
                    hour: data.hour, minute: data.minute,
                    day: data.day, month: data.month, year: data.year,
                    dayOfWeek: data.dayOfWeek
                });
            } else if (data.action === 'updateApps') {
                state.apps = Array.isArray(data.apps) ? data.apps : [];
                BPApps.renderGrid(state.apps, openAppView);
            } else if (data.action === 'pushToApp') {
                // Forward message vao iframe con cua app tuong ung
                const iframe = document.querySelector('iframe.app-iframe[data-app-id="' + data.appId + '"]');
                if (iframe && iframe.contentWindow) {
                    iframe.contentWindow.postMessage(data.payload || {}, '*');
                }
            }
        } catch (err) {
            console.error('[BlackPhone] handleMessage error:', err);
        }
    }

    window.addEventListener('message', function (ev) {
        const data = ev.data || {};
        if (!domReady) {
            pendingMessages.push(data);
            return;
        }
        handleMessage(data);
    });

    // ---------- Boot ----------
    function boot() {
        try {
            bindUI();
            domReady = true;
            while (pendingMessages.length) {
                handleMessage(pendingMessages.shift());
            }
        } catch (err) {
            console.error('[BlackPhone] boot error:', err);
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', boot);
    } else {
        boot();
    }

    // Expose minimal API cho app khac (neu can)
    window.BPPhone = {
        close: closePhone,
        openApp: openAppView,
        backToHome: closeAppView
    };
})();