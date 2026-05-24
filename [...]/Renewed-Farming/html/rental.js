(function () {
    'use strict';

    const app = document.getElementById('rental-app');
    const plotsList = document.getElementById('plots-list');
    const detailEmpty = document.getElementById('detail-empty');
    const detailContent = document.getElementById('detail-content');
    const detailName = document.getElementById('detail-name');
    const detailBadge = document.getElementById('detail-badge');
    const detailRenterInfo = document.getElementById('detail-renter-info');
    const rentForm = document.getElementById('rent-form');
    const ownerInfo = document.getElementById('owner-info');
    const durationGrid = document.getElementById('duration-grid');
    const priceValue = document.getElementById('price-value');
    const submitBtn = document.getElementById('rent-submit-btn');
    const closeBtn = document.getElementById('close-btn');
    const myRentalBar = document.getElementById('my-rental-bar');
    const myRentalText = document.getElementById('my-rental-text');
    const notification = document.getElementById('notification');
    const notificationText = document.getElementById('notification-text');
    const routeBtn = document.getElementById('route-btn');
    const routeBtnText = document.getElementById('route-btn-text');
    let routeActive = false;

    let currentData = null;
    let selectedPlot = null;
    let selectedDays = null;
    let selectedPay = 'cash';
    let countdownInterval = null;

    function formatMoney(amount) {
        return '$' + amount.toLocaleString('vi-VN');
    }

    function formatDate(dateVal) {
        if (!dateVal) return '--';
        const d = typeof dateVal === 'number' ? new Date(dateVal * 1000) : new Date(dateVal);
        return d.toLocaleDateString('vi-VN', {
            day: '2-digit', month: '2-digit', year: 'numeric',
            hour: '2-digit', minute: '2-digit'
        });
    }

    function getTimeRemaining(dateVal) {
        if (!dateVal) return '';
        const now = new Date();
        const end = typeof dateVal === 'number' ? new Date(dateVal * 1000) : new Date(dateVal);
        const diff = end - now;
        if (diff <= 0) return 'Đã hết hạn';
        const days = Math.floor(diff / 86400000);
        const hours = Math.floor((diff % 86400000) / 3600000);
        const mins = Math.floor((diff % 3600000) / 60000);
        let parts = [];
        if (days > 0) parts.push(days + ' ngày');
        if (hours > 0) parts.push(hours + ' giờ');
        parts.push(mins + ' phút');
        return 'Còn lại: ' + parts.join(' ');
    }

    function showNotification(msg, type) {
        notificationText.textContent = msg;
        notification.className = 'notification show ' + (type || '');
        setTimeout(function () {
            notification.className = 'notification hidden';
        }, 3000);
    }

    function renderPlots() {
        plotsList.innerHTML = '';
        if (!currentData || !currentData.plots) return;

        currentData.plots.forEach(function (plot) {
            const card = document.createElement('div');
            card.className = 'plot-card' + (selectedPlot && selectedPlot.id === plot.id ? ' active' : '');

            let statusClass, statusText;
            if (plot.isOwner) {
                statusClass = 'owner';
                statusText = 'Của bạn';
            } else if (plot.status === 'rented') {
                statusClass = 'rented';
                statusText = 'Đã thuê';
            } else {
                statusClass = 'available';
                statusText = 'Trống';
            }

            card.innerHTML =
                '<div class="plot-card-name">' + plot.name + '</div>' +
                '<div class="plot-card-status">' +
                '<span class="status-dot ' + statusClass + '"></span>' +
                '<span>' + statusText + '</span>' +
                '</div>' +
                (plot.isOwner ? '<span class="owner-tag">Của bạn</span>' : '');

            card.addEventListener('click', function () {
                selectPlot(plot);
            });

            plotsList.appendChild(card);
        });

        if (currentData.myRental) {
            myRentalBar.classList.remove('hidden');
            const rPlot = currentData.plots.find(function (p) { return p.id === currentData.myRental.plot_id; });
            myRentalText.textContent = 'Bạn đã thuê: ' + (rPlot ? rPlot.name : 'Mảnh #' + currentData.myRental.plot_id);
        } else {
            myRentalBar.classList.add('hidden');
        }
    }

    function selectPlot(plot) {
        selectedPlot = plot;
        selectedDays = null;

        document.querySelectorAll('.plot-card').forEach(function (el) { el.classList.remove('active'); });
        const cards = plotsList.children;
        for (let i = 0; i < cards.length; i++) {
            if (currentData.plots[i].id === plot.id) {
                cards[i].classList.add('active');
            }
        }

        detailEmpty.classList.add('hidden');
        detailContent.classList.remove('hidden');
        detailContent.style.animation = 'none';
        detailContent.offsetHeight;
        detailContent.style.animation = 'slideIn 0.3s ease';

        detailName.textContent = plot.name;

        if (plot.isOwner) {
            const endDate = typeof plot.expires_at === 'number' ? new Date(plot.expires_at * 1000) : new Date(plot.expires_at);
            const isExpired = plot.expires_at && (endDate - new Date() <= 0);
            if (isExpired) {
                detailBadge.textContent = 'Đã hết hạn';
                detailBadge.className = 'detail-badge rented';
                detailRenterInfo.classList.add('hidden');
                rentForm.classList.remove('hidden');
                ownerInfo.classList.add('hidden');
                renderDurations();
                updateSubmit();
                stopCountdown();
            } else {
                detailBadge.textContent = 'Của bạn';
                detailBadge.className = 'detail-badge owner';
                detailRenterInfo.classList.add('hidden');
                rentForm.classList.add('hidden');
                ownerInfo.classList.remove('hidden');
                document.getElementById('owner-expires').textContent = formatDate(plot.expires_at);
                startCountdown(plot.expires_at);
            }
        } else if (plot.status === 'rented') {
            detailBadge.textContent = 'Đã thuê';
            detailBadge.className = 'detail-badge rented';
            detailRenterInfo.classList.remove('hidden');
            document.getElementById('info-renter').textContent = plot.renter || '--';
            document.getElementById('info-expires').textContent = formatDate(plot.expires_at);
            rentForm.classList.add('hidden');
            ownerInfo.classList.add('hidden');
            stopCountdown();
        } else {
            detailBadge.textContent = 'Trống';
            detailBadge.className = 'detail-badge available';
            detailRenterInfo.classList.add('hidden');
            ownerInfo.classList.add('hidden');
            stopCountdown();

            if (currentData.myRental) {
                rentForm.classList.add('hidden');
            } else {
                rentForm.classList.remove('hidden');
                renderDurations();
                updateSubmit();
            }
        }
    }

    function renderDurations() {
        durationGrid.innerHTML = '';
        if (!currentData || !currentData.prices) return;

        const sorted = Object.keys(currentData.prices)
            .map(Number)
            .sort(function (a, b) { return a - b; });

        sorted.forEach(function (days) {
            const btn = document.createElement('button');
            btn.className = 'dur-btn' + (selectedDays === days ? ' active' : '');
            btn.innerHTML =
                '<span class="dur-days">' + days + '</span>' +
                '<span class="dur-label">ngày</span>' +
                '<span class="dur-price">' + formatMoney(currentData.prices[days]) + '</span>';

            btn.addEventListener('click', function () {
                selectedDays = days;
                document.querySelectorAll('.dur-btn').forEach(function (el) { el.classList.remove('active'); });
                btn.classList.add('active');
                priceValue.textContent = formatMoney(currentData.prices[days]);
                updateSubmit();
            });

            durationGrid.appendChild(btn);
        });

        priceValue.textContent = '$0';
    }

    function updateSubmit() {
        submitBtn.disabled = !selectedDays || !selectedPlot;
    }

    function startCountdown(dateStr) {
        stopCountdown();
        const el = document.getElementById('owner-countdown');
        function update() {
            el.textContent = getTimeRemaining(dateStr);
        }
        update();
        countdownInterval = setInterval(update, 60000);
    }

    function stopCountdown() {
        if (countdownInterval) {
            clearInterval(countdownInterval);
            countdownInterval = null;
        }
    }

    function openUI(data) {
        currentData = data;
        selectedPlot = null;
        selectedDays = null;
        selectedPay = 'cash';

        detailEmpty.classList.remove('hidden');
        detailContent.classList.add('hidden');

        renderPlots();
        app.classList.remove('hidden');
    }

    function openUI(data) {
        currentData = data;
        selectedPlot = null;
        selectedDays = null;
        selectedPay = 'cash';
        routeActive = data.routeActive || false;
        updateRouteBtn();

        detailEmpty.classList.remove('hidden');
        detailContent.classList.add('hidden');

        renderPlots();
        app.classList.remove('hidden');
    }

    function closeUI() {
        app.classList.add('hidden');
        stopCountdown();
        fetch('https://Renewed-Farming/closeRental', {
            method: 'POST',
            body: JSON.stringify({})
        });
    }

    function updateRouteBtn() {
        if (!routeBtn) return;
        if (routeActive) {
            routeBtn.classList.add('active');
            routeBtnText.textContent = 'Tắt chỉ vị trí';
        } else {
            routeBtn.classList.remove('active');
            routeBtnText.textContent = 'Chỉ vị trí';
        }
    }

    if (routeBtn) {
        routeBtn.addEventListener('click', function () {
            fetch('https://Renewed-Farming/toggleRoute', {
                method: 'POST',
                body: JSON.stringify({})
            })
            .then(function (r) { return r.json(); })
            .then(function (result) {
                if (result && result.success) {
                    routeActive = result.active;
                    updateRouteBtn();
                }
            });
        });
    }

    // Payment toggle
    document.querySelectorAll('.pay-btn').forEach(function (btn) {
        btn.addEventListener('click', function () {
            document.querySelectorAll('.pay-btn').forEach(function (el) { el.classList.remove('active'); });
            btn.classList.add('active');
            selectedPay = btn.getAttribute('data-pay');
        });
    });

    // Submit
    submitBtn.addEventListener('click', function () {
        if (!selectedPlot || !selectedDays || submitBtn.disabled) return;

        submitBtn.classList.add('loading');
        submitBtn.textContent = 'Đang xử lý...';
        submitBtn.disabled = true;

        fetch('https://Renewed-Farming/rentPlot', {
            method: 'POST',
            body: JSON.stringify({
                plotId: selectedPlot.id,
                days: selectedDays,
                payType: selectedPay
            })
        })
        .then(function (r) { return r.json(); })
        .then(function (result) {
            submitBtn.classList.remove('loading');
            submitBtn.textContent = 'Thuê đất';

            if (result.success) {
                showNotification(result.msg || 'Thuê đất thành công!', 'success');
                setTimeout(closeUI, 1500);
            } else {
                showNotification(result.msg || 'Có lỗi xảy ra', 'error');
                submitBtn.disabled = false;
            }
        })
        .catch(function () {
            submitBtn.classList.remove('loading');
            submitBtn.textContent = 'Thuê đất';
            submitBtn.disabled = false;
            showNotification('Có lỗi xảy ra', 'error');
        });
    });

    // Close
    closeBtn.addEventListener('click', closeUI);
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') closeUI();
    });

    // NUI Message Listener
    window.addEventListener('message', function (event) {
        var data = event.data;
        if (data.action === 'openRental') {
            openUI(data.data || data);
            if (typeof data.routeActive !== 'undefined') {
                routeActive = data.routeActive;
                updateRouteBtn();
            }
        } else if (data.action === 'closeRental') {
            app.classList.add('hidden');
            stopCountdown();
        } else if (data.action === 'updateRouteState') {
            routeActive = data.active;
            updateRouteBtn();
        }
    });
})();
