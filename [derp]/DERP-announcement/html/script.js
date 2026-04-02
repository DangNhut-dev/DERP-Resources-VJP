'use strict';

// ===================== STATE =====================

const state = {
    announce: { hideTimer: null, closeTimer: null },
    restart:  { interval: null, beepPlayed: {} }
};

// ===================== SOUND =====================

const audioCache = {};

function playSound(file, volume) {
    if (!file) return;
    if (!audioCache[file]) audioCache[file] = new Audio('sounds/' + file);
    const a = audioCache[file];
    a.volume = Math.min(1, Math.max(0, volume || 0.3));
    a.currentTime = 0;
    a.play().catch(() => {});
}

// ===================== PROGRESS BAR =====================

function startProgress(el, durationMs) {
    el.style.transition = 'none';
    el.style.width = '100%';
    requestAnimationFrame(() => requestAnimationFrame(() => {
        el.style.transition = 'width ' + durationMs + 'ms linear';
        el.style.width = '0%';
    }));
}

// ===================== ANNOUNCE (split logo) =====================

function showAnnounce(data) {
    clearActiveAnnounce();

    const wrap = document.getElementById('announce-wrap');
    const text = document.getElementById('announce-text');

    text.textContent = data.message || '';

    // Reset
    wrap.classList.remove('hidden', 'show', 'hide', 'open');
    void wrap.offsetWidth; // force reflow

    // Step 1: drop in the bar
    wrap.classList.add('show');
    wrap.classList.remove('hidden');

    if (data.sound) playSound(data.sound, data.volume);

    // Step 2: split logos outward + fade in text
    setTimeout(() => wrap.classList.add('open'), 80);

    // Step 3: hide after duration
    const duration = (data.time || 10) * 1000;
    state.announce.hideTimer = setTimeout(() => hideAnnounce(), duration);
}

function hideAnnounce() {
    const wrap = document.getElementById('announce-wrap');

    // Close logos back to center first
    wrap.classList.remove('open');

    // Then slide bar up
    state.announce.closeTimer = setTimeout(() => {
        wrap.classList.remove('show');
        wrap.classList.add('hide');
        setTimeout(() => {
            wrap.classList.add('hidden');
            wrap.classList.remove('hide');
        }, 280);
    }, 420);
}

function clearActiveAnnounce() {
    clearTimeout(state.announce.hideTimer);
    clearTimeout(state.announce.closeTimer);
    const wrap = document.getElementById('announce-wrap');
    wrap.classList.add('hidden');
    wrap.classList.remove('show', 'hide', 'open');
}

// ===================== RESTART =====================

function showRestart(data) {
    clearActiveRestart();

    const wrap    = document.getElementById('restart-wrap');
    const box     = document.getElementById('restart-box');
    const secEl   = document.getElementById('restart-seconds');
    const timerEl = document.getElementById('restart-timer');
    const bar     = document.getElementById('restart-progress');

    let remaining = parseInt(data.time) || 30;
    state.restart.beepPlayed = {};

    box.classList.remove('closing');
    wrap.classList.remove('hidden');

    if (data.sound) playSound(data.sound, data.volume);

    secEl.textContent = remaining;
    timerEl.classList.toggle('urgent', remaining <= 10);
    startProgress(bar, remaining * 1000);

    state.restart.interval = setInterval(() => {
        remaining--;
        secEl.textContent = remaining;
        timerEl.classList.toggle('urgent', remaining <= 10);

        if (remaining <= 10 && remaining > 0 && !state.restart.beepPlayed[remaining]) {
            state.restart.beepPlayed[remaining] = true;
            if (data.countdown) playSound(data.countdown, data.volume);
        }

        if (remaining <= 0) {
            clearInterval(state.restart.interval);
            hideRestart();
        }
    }, 1000);
}

function hideRestart() {
    const wrap = document.getElementById('restart-wrap');
    const box  = document.getElementById('restart-box');
    box.classList.add('closing');
    clearInterval(state.restart.interval);
    setTimeout(() => {
        wrap.classList.add('hidden');
        box.classList.remove('closing');
    }, 300);
}

function clearActiveRestart() {
    clearInterval(state.restart.interval);
    document.getElementById('restart-wrap').classList.add('hidden');
}

// ===================== ADMIN UI =====================

function openAdmin() {
    document.getElementById('admin-wrap').classList.remove('hidden');
    document.getElementById('admin-message').value = '';
    document.getElementById('admin-time').value = '10';
    setTimeout(() => document.getElementById('admin-message').focus(), 50);
}

function closeAdmin() {
    document.getElementById('admin-wrap').classList.add('hidden');
    fetch('https://DERP-announcement/closeAdmin', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

function submitAnnounce() {
    const message = document.getElementById('admin-message').value.trim();
    const time    = parseInt(document.getElementById('admin-time').value) || 10;
    if (!message) { document.getElementById('admin-message').focus(); return; }
    fetch('https://DERP-announcement/sendAnnounce', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message, time })
    });
    document.getElementById('admin-wrap').classList.add('hidden');
}

// ===================== NUI MESSAGE =====================

window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data || !data.action) return;
    switch (data.action) {
        case 'announce':
        case 'show':
            showAnnounce(data);
            break;
        case 'restart':
            showRestart(data);
            break;
        case 'openAdmin':
            openAdmin();
            break;
    }
});

// ===================== KEYBOARD =====================

document.addEventListener('keydown', (e) => {
    const adminWrap = document.getElementById('admin-wrap');
    if (!adminWrap.classList.contains('hidden')) {
        if (e.key === 'Escape') closeAdmin();
        if (e.key === 'Enter' && e.ctrlKey) submitAnnounce();
    }
});