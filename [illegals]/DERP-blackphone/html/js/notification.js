/* DERP BlackPhone - Notification system
   Queue + 5s display + click to open phone */
(function () {
    const SHOW_DURATION_MS = 5000;
    const ANIMATE_OUT_MS = 450;
    const SOUND_URL = 'sounds/notify.ogg';
    const SOUND_VOLUME = 0.6;
    const queue = [];
    let isShowing = false;
    let audioEl = null;
    let audioUnlocked = false;

    function $(sel) { return document.querySelector(sel); }

    function nuiPost(endpoint, payload) {
        try {
            const resName = window.GetParentResourceName ? GetParentResourceName() : 'derp-blackphone';
            return fetch('https://' + resName + '/' + endpoint, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload || {})
            });
        } catch (e) { return null; }
    }

    // Preload audio va unlock khi co user gesture
    function initAudio() {
        try {
            audioEl = new Audio(SOUND_URL);
            audioEl.volume = SOUND_VOLUME;
            audioEl.preload = 'auto';
            audioEl.load();

            // Try silent play to unlock
            audioEl.muted = true;
            const p = audioEl.play();
            if (p && typeof p.then === 'function') {
                p.then(function () {
                    audioEl.pause();
                    audioEl.muted = false;
                    audioEl.currentTime = 0;
                    audioUnlocked = true;
                    console.log('[BlackPhone Notif] audio unlocked');
                }).catch(function (err) {
                    audioEl.muted = false;
                    console.warn('[BlackPhone Notif] audio unlock failed, will retry on gesture:', err.message);
                });
            }
        } catch (e) {
            console.warn('[BlackPhone Notif] initAudio error:', e);
        }
    }

    function playSound() {
        // Request native GTA sound tu Lua (fallback khong can HTML5 audio)
        nuiPost('playNotifSound', {});

        // Va cung play HTML5 audio
        if (!audioEl) {
            initAudio();
        }
        try {
            audioEl.currentTime = 0;
            audioEl.muted = false;
            audioEl.volume = SOUND_VOLUME;
            const p = audioEl.play();
            if (p && typeof p.catch === 'function') {
                p.catch(function (e) {
                    console.warn('[BlackPhone Notif] sound play blocked:', e.message);
                });
            }
        } catch (e) {
            console.warn('[BlackPhone Notif] sound error:', e);
        }
    }

    function escapeHtml(s) {
        if (s == null) return '';
        return String(s)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function showNext() {
        if (isShowing) return;
        const notif = queue.shift();
        if (!notif) return;
        isShowing = true;

        const container = $('#notif-container');
        if (!container) { isShowing = false; return; }

        const card = document.createElement('div');
        card.className = 'notif-card';

        const iconBg = notif.color || '#05F2F2';
        card.innerHTML =
            '<div class="notif-icon-wrap" style="background:' + iconBg + '20;color:' + iconBg + ';">' +
                '<i class="' + escapeHtml(notif.icon || 'fa-solid fa-bell') + '"></i>' +
            '</div>' +
            '<div class="notif-content">' +
                '<div class="notif-meta">' +
                    '<span class="notif-app-name">' + escapeHtml(notif.appName || 'App') + '</span>' +
                    '<span class="notif-time">vừa xong</span>' +
                '</div>' +
                '<div class="notif-title">' + escapeHtml(notif.title || '') + '</div>' +
                '<div class="notif-body">' + escapeHtml(notif.body || '') + '</div>' +
            '</div>';

        card.addEventListener('click', function () {
            // Click -> tat banner, mo phone va navigate vao app
            hideCard(card);
            nuiPost('notificationClicked', {
                appId: notif.appId,
                onClick: notif.onClick || null
            });
        });

        container.appendChild(card);
        // Force reflow de animation play
        void card.offsetHeight;
        card.classList.add('notif-card--show');

        // Play sound
        playSound();

        // Auto hide sau 5s
        setTimeout(function () { hideCard(card); }, SHOW_DURATION_MS);
    }

    function hideCard(card) {
        if (!card || card.dataset.hiding === '1') return;
        card.dataset.hiding = '1';
        card.classList.remove('notif-card--show');
        card.classList.add('notif-card--hide');
        setTimeout(function () {
            if (card.parentNode) card.parentNode.removeChild(card);
            isShowing = false;
            // Process next trong queue
            if (queue.length > 0) showNext();
        }, ANIMATE_OUT_MS);
    }

    // Public API: enqueue notification
    window.PhoneNotify = function (notif) {
        if (!notif || !notif.title || !notif.body) return;
        queue.push(notif);
        showNext();
    };

    // Listen NUI message tu Lua
    window.addEventListener('message', function (ev) {
        const data = ev.data || {};
        if (data.action === 'notify' && data.notification) {
            console.log('[BlackPhone Notif] received:', JSON.stringify(data.notification));
            window.PhoneNotify(data.notification);
        }
    });

    console.log('[BlackPhone Notif] module loaded');

    // Init audio som (chua the autoplay nhung preload)
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initAudio);
    } else {
        initAudio();
    }
})();