(function (global) {
    'use strict';

    const $ = BP.$, el = BP.el;

    // Registry cho custom app views (cac app sau nay se register o day)
    const viewRegistry = {};

    function registerView(appId, handlers) {
        // handlers: { onOpen(container, app), onClose(container, app) }
        if (!appId || !handlers) return;
        viewRegistry[appId] = handlers;
    }

    function getView(appId) {
        return viewRegistry[appId] || null;
    }

    function iconAccent(color) {
        if (!color) return {};
        return {
            '--app-color': color,
            '--app-glow': hexToGlow(color)
        };
    }

    function hexToGlow(hex) {
        if (!hex || hex[0] !== '#') return 'rgba(5, 242, 242, 0.3)';
        const h = hex.replace('#', '');
        const r = parseInt(h.substring(0, 2), 16);
        const g = parseInt(h.substring(2, 4), 16);
        const b = parseInt(h.substring(4, 6), 16);
        return 'rgba(' + r + ',' + g + ',' + b + ',0.3)';
    }

    function buildIcon(app, onOpen) {
        const node = el('div', { cls: 'app-icon' });
        node.setAttribute('data-app-id', app.id);

        const shape = el('div', { cls: 'app-icon-shape' });
        const accent = iconAccent(app.color);
        Object.keys(accent).forEach(function (k) { shape.style.setProperty(k, accent[k]); });

        const icon = el('i', { attrs: { class: app.icon || 'fa-solid fa-square' } });
        icon.style.color = app.color || 'var(--gold)';
        shape.appendChild(icon);

        const label = el('div', { cls: 'app-icon-label', text: app.name || app.id });

        node.appendChild(shape);
        node.appendChild(label);

        node.addEventListener('click', function () {
            if (typeof onOpen === 'function') onOpen(app);
        });

        return node;
    }

    function buildEmptySlot() {
        const node = el('div', { cls: 'app-icon app-icon-empty' });
        const shape = el('div', { cls: 'app-icon-shape' });
        shape.appendChild(el('i', { attrs: { class: 'fa-solid fa-plus' } }));
        node.appendChild(shape);
        node.appendChild(el('div', { cls: 'app-icon-label', text: '' }));
        return node;
    }

    function renderGrid(apps, onOpen) {
        const grid = $('#app-grid');
        if (!grid) return;
        grid.innerHTML = '';

        const list = Array.isArray(apps) ? apps : [];
        list.forEach(function (app, i) {
            const icon = buildIcon(app, onOpen);
            icon.style.animationDelay = (i * 40) + 'ms';
            grid.appendChild(icon);
        });

        // Fill empty slots cho dep (8 slots toi thieu)
        const minSlots = 8;
        const remaining = Math.max(0, minSlots - list.length);
        for (let i = 0; i < remaining; i++) {
            const empty = buildEmptySlot();
            empty.style.animationDelay = ((list.length + i) * 40) + 'ms';
            grid.appendChild(empty);
        }
    }

    global.BPApps = {
        registerView: registerView,
        getView: getView,
        renderGrid: renderGrid
    };
})(window);