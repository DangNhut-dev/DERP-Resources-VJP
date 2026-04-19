(function (global) {
    'use strict';

    const RESOURCE = (function () {
        try {
            return (typeof GetParentResourceName === 'function') ? GetParentResourceName() : 'derp-blackphone';
        } catch (_) {
            return 'derp-blackphone';
        }
    })();

    // GetClockDayOfWeek: 0 = Sunday ... 6 = Saturday (giong Date.getDay)
    const DAYS = ['Chủ nhật', 'Thứ hai', 'Thứ ba', 'Thứ tư', 'Thứ năm', 'Thứ sáu', 'Thứ bảy'];

    function pad(n) { return n < 10 ? '0' + n : '' + n; }

    function formatTime(clock) {
        if (!clock) return '00:00';
        return pad(clock.hour || 0) + ':' + pad(clock.minute || 0);
    }

    function formatDateLong(clock) {
        if (!clock) return '—';
        const dow = typeof clock.dayOfWeek === 'number' ? clock.dayOfWeek : 0;
        return DAYS[dow] + ', ' + pad(clock.day || 1) + '/' + pad(clock.month || 1) + '/' + (clock.year || 2025);
    }

    function formatDateShort(clock) {
        if (!clock) return '—';
        return pad(clock.day || 1) + '.' + pad(clock.month || 1) + '.' + (clock.year || 2025);
    }

    function getGreeting(clock) {
        const h = clock ? (clock.hour || 0) : 0;
        if (h >= 5 && h < 11) return 'Buổi sáng';
        if (h >= 11 && h < 14) return 'Buổi trưa';
        if (h >= 14 && h < 18) return 'Buổi chiều';
        return 'Buổi tối';
    }

    function post(endpoint, payload, cb) {
        return fetch('https://' + RESOURCE + '/' + endpoint, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json;charset=UTF-8' },
            body: JSON.stringify(payload || {})
        }).then(function (r) { return r.json().catch(function () { return null; }); })
          .then(function (data) { if (typeof cb === 'function') cb(data); return data; })
          .catch(function () { if (typeof cb === 'function') cb(null); });
    }

    function $(sel, root) { return (root || document).querySelector(sel); }
    function $$(sel, root) { return Array.prototype.slice.call((root || document).querySelectorAll(sel)); }

    function el(tag, opts) {
        const n = document.createElement(tag);
        if (!opts) return n;
        if (opts.cls) n.className = opts.cls;
        if (opts.html != null) n.innerHTML = opts.html;
        if (opts.text != null) n.textContent = opts.text;
        if (opts.attrs) Object.keys(opts.attrs).forEach(function (k) { n.setAttribute(k, opts.attrs[k]); });
        if (opts.style) Object.keys(opts.style).forEach(function (k) { n.style[k] = opts.style[k]; });
        return n;
    }

    global.BP = {
        RESOURCE: RESOURCE,
        pad: pad,
        formatTime: formatTime,
        formatDateLong: formatDateLong,
        formatDateShort: formatDateShort,
        getGreeting: getGreeting,
        post: post,
        $: $,
        $$: $$,
        el: el
    };
})(window);