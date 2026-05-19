// ═══════════════════════════════════════════════════════════
// 🎮 TOMMY TRUCKER - JAVASCRIPT LOGIC
// ═══════════════════════════════════════════════════════════

$(document).ready(function() {
    let currentDriverData = null;
    let currentOrders = [];
    let selectedVehicle = null;
    let hasActiveJob = false;
    let currentPartyData = null;
    let pendingInvite = null;

    let rentalFleet = [];
    let activeRental = null;
    let selectedRentalVehicle = null;
    let selectedRentalDays = 1;
    let rentalTimerInterval = null;

    // ═══════════════════════════════════════════════════════════
    // 🎧 NUI LISTENER
    // ═══════════════════════════════════════════════════════════

    window.addEventListener('message', function(event) {
        const data = event.data;

        if (data.action === 'openUI') {
            currentDriverData = data.driverData;
            currentOrders = data.orders;
            hasActiveJob = data.hasActiveJob || false;
            currentPartyData = data.partyData || null;
            pendingInvite = data.pendingInvite || null;
            rentalFleet = data.rentalFleet || [];
            activeRental = data.activeRental || null;

            $('#main-container').removeClass('hidden');
            updateDriverTab();
            updateOrdersTab();
            updatePartyTab();
            updateRentalTab();
            updateRegisterButton();
            updateCancelButton();
            updatePendingInvite();
        }

        if (data.action === 'partyDisbanded') {
            currentPartyData = { inParty: false };
            updatePartyTab();
        }

        if (data.action === 'showPartyInvite') {
            pendingInvite = data.data;
            updatePendingInvite();
        }

        if (data.action === 'refreshPartyData') {
            currentPartyData = data.partyData;
            updatePartyTab();
        }

        if (data.action === 'rentalSuccess') {
            activeRental = data.rentalData;
            updateRentalTab();
            $('#rentalModal').addClass('hidden');
        }
    });

    // ═══════════════════════════════════════════════════════════
    // 🎯 TAB SWITCHING
    // ═══════════════════════════════════════════════════════════

    $('.tab-btn').click(function() {
        const tabName = $(this).data('tab');

        $('.tab-btn').removeClass('active');
        $(this).addClass('active');

        $('.tab-content').removeClass('active');
        $(`#${tabName}-tab`).addClass('active');

        if (tabName === 'party') {
            refreshPartyData();
        }
    });

    // ═══════════════════════════════════════════════════════════
    // ❌ CLOSE UI
    // ═══════════════════════════════════════════════════════════

    $('#closeBtn').click(function() {
        closeUI();
    });

    $(document).keyup(function(e) {
        if (e.key === 'Escape') {
            if (!$('#cancelConfirmModal').hasClass('hidden')) {
                $('#cancelConfirmModal').addClass('hidden');
            } else if (!$('#vehicleModal').hasClass('hidden')) {
                $('#vehicleModal').addClass('hidden');
            } else if (!$('#inviteModal').hasClass('hidden')) {
                $('#inviteModal').addClass('hidden');
            } else if (!$('#rentalModal').hasClass('hidden')) {
                $('#rentalModal').addClass('hidden');
            } else {
                closeUI();
            }
        }
    });

    function closeUI() {
        $('#main-container').addClass('hidden');
        if (rentalTimerInterval) clearInterval(rentalTimerInterval);
        $.post('https://tommy-trucker/closeUI', JSON.stringify({}));
    }

    // ═══════════════════════════════════════════════════════════
    // 📦 UPDATE ORDERS TAB
    // ═══════════════════════════════════════════════════════════

    function updateOrdersTab() {
        const $ordersGrid = $('#ordersGrid');
        const $noOrders = $('#noOrders');

        $ordersGrid.empty();

        if (currentOrders.length === 0) {
            $ordersGrid.addClass('hidden');
            $noOrders.removeClass('hidden');
            return;
        }

        $ordersGrid.removeClass('hidden');
        $noOrders.addClass('hidden');

        currentOrders.forEach(order => {
            const illegalClass = order.isIllegal ? 'illegal' : '';
            const illegalBadge = order.isIllegal ? '<span class="order-badge badge-illegal"><i class="fas fa-exclamation-triangle"></i> HÀNG CẤM</span>' : '';

            const orderCard = `
                <div class="order-card ${illegalClass}" data-order-id="${order.id}">
                    <div class="order-header">
                        <div>
                            <div class="order-title">${order.label}</div>
                            ${illegalBadge}
                        </div>
                        <span class="order-badge badge-level">Level ${order.requiredLevel}</span>
                    </div>
                    <div class="order-details">
                        <div class="order-detail">
                            <i class="fas fa-weight-hanging"></i>
                            <span>Yêu cầu tải trọng: ${order.requiredKg}kg</span>
                        </div>
                        <div class="order-detail">
                            <i class="fas fa-star"></i>
                            <span>Kinh nghiệm: +${order.exp} EXP</span>
                        </div>
                    </div>
                    <div class="order-footer">
                        <div class="order-reward">
                            <i class="fas fa-dollar-sign"></i>
                            <span>${formatNumber(order.reward)}</span>
                        </div>
                        <button class="btn btn-accept" onclick="acceptOrder(${order.id})">
                            <i class="fas fa-check-circle"></i>
                            Nhận Đơn
                        </button>
                    </div>
                </div>
            `;

            $ordersGrid.append(orderCard);
        });
    }

    window.acceptOrder = function(orderId) {
        $('#main-container').addClass('hidden');
        $.post('https://tommy-trucker/acceptOrder', JSON.stringify({ orderId: orderId }));
    };

    // ═══════════════════════════════════════════════════════════
    // 👤 UPDATE DRIVER TAB
    // ═══════════════════════════════════════════════════════════

    function updateDriverTab() {
        if (!currentDriverData) return;

        $('#driverLevel').text(currentDriverData.current_level);
        $('#tripsCompleted').text(formatNumber(currentDriverData.trips_completed));
        $('#totalExp').text(formatNumber(currentDriverData.total_exp) + ' EXP');

        const currentLevel = currentDriverData.current_level;
        const totalExp = currentDriverData.total_exp;

        const levelThresholds = [0, 400, 900, 1500, 2250, 3150, 4250, 5600, 7200, 9100];
        const currentThreshold = levelThresholds[currentLevel - 1] || 0;
        const nextThreshold = levelThresholds[currentLevel] || levelThresholds[levelThresholds.length - 1];

        const expInLevel = totalExp - currentThreshold;
        const expNeeded = nextThreshold - currentThreshold;
        const percentage = Math.min((expInLevel / expNeeded) * 100, 100);

        $('#expFill').css('width', percentage + '%');
        $('#expText').text(`${expInLevel} / ${expNeeded}`);

        if (currentDriverData.registered_plate && currentDriverData.registered_vehicle) {
            const vehicleName = formatVehicleName(currentDriverData.registered_vehicle);
            const capacity = getVehicleCapacity(currentDriverData.registered_vehicle);

            $('#vehicleDisplay').html(`
                <div class="vehicle-info">
                    <div class="vehicle-name">${vehicleName}</div>
                    <div class="vehicle-plate">Biển số: ${currentDriverData.registered_plate}</div>
                    <div class="vehicle-capacity"><i class="fas fa-weight-hanging"></i> Tải trọng: ${capacity}kg</div>
                </div>
            `);
        } else {
            $('#vehicleDisplay').html('<span class="no-vehicle">Chưa đăng ký xe</span>');
        }
    }

    // ═══════════════════════════════════════════════════════════
    // 🔑 RENTAL TAB
    // ═══════════════════════════════════════════════════════════

    function updateRentalTab() {
        const $grid = $('#rentalGrid');
        const $noRental = $('#noRentalAvailable');
        const $banner = $('#activeRentalBanner');

        if (activeRental) {
            $('#activeRentalPlate').text(activeRental.plate);
            $('#activeRentalModel').text(formatVehicleName(activeRental.vehicle_model));
            $banner.removeClass('hidden');
            const expireSec = activeRental.expire_unix
                ?? (activeRental.expire_time > 9999999999
                    ? Math.floor(activeRental.expire_time / 1000)
                    : activeRental.expire_time);
            startRentalCountdown(expireSec);
        } else {
            $banner.addClass('hidden');
            if (rentalTimerInterval) clearInterval(rentalTimerInterval);
        }

        $grid.empty();

        if (!rentalFleet || rentalFleet.length === 0) {
            $noRental.removeClass('hidden');
            return;
        }

        $noRental.addClass('hidden');

        rentalFleet.forEach((truck, index) => {
            const isRented = activeRental !== null;
            const disabledClass = isRented ? 'rental-card-disabled' : '';
            const disabledAttr = isRented ? 'disabled' : '';

            const card = `
                <div class="rental-card ${disabledClass}" data-index="${index}" style="animation-delay: ${index * 0.07}s">
                    <div class="rental-card-top">
                        <div class="rental-card-icon">
                            <i class="fas fa-truck-moving"></i>
                        </div>
                        <div class="rental-card-badge">
                            <i class="fas fa-weight-hanging"></i>
                            ${truck.capacity}kg
                        </div>
                    </div>
                    <div class="rental-card-body">
                        <div class="rental-card-name">${formatVehicleName(truck.model)}</div>
                        <div class="rental-card-model">${truck.model}</div>
                        <div class="rental-card-price">
                            <span class="price-amount">$${formatNumber(truck.pricePerDay)}</span>
                            <span class="price-per">/ngày</span>
                        </div>
                    </div>
                    <button class="btn btn-rent-truck" data-index="${index}" ${disabledAttr}>
                        ${isRented
                            ? '<i class="fas fa-lock"></i> Đang thuê xe khác'
                            : '<i class="fas fa-key"></i> Thuê Ngay'}
                    </button>
                </div>
            `;

            $grid.append(card);
        });
    }

    $(document).on('click', '.btn-rent-truck', function() {
        if ($(this).prop('disabled')) return;
        const index = $(this).data('index');
        selectedRentalVehicle = rentalFleet[index];
        selectedRentalDays = 1;
        openRentalModal();
    });

    function openRentalModal() {
        if (!selectedRentalVehicle) return;

        $('#rentalPreviewName').text(formatVehicleName(selectedRentalVehicle.model));
        $('#rentalPreviewCapacity').html(`<i class="fas fa-weight-hanging"></i> ${selectedRentalVehicle.capacity}kg`);
        $('#rentalPreviewPricePerDay').html(`<i class="fas fa-dollar-sign"></i> ${formatNumber(selectedRentalVehicle.pricePerDay)}/ngày`);

        selectedRentalDays = 1;
        updateRentalModalPricing();

        $('.day-pick-btn').removeClass('active');
        $('.day-pick-btn[data-days="1"]').addClass('active');

        $('#rentalModal').removeClass('hidden');
    }

    function updateRentalModalPricing() {
        const days = selectedRentalDays;
        const pricePerDay = selectedRentalVehicle.pricePerDay;
        const total = days * pricePerDay;

        $('#rentalDays').text(days);
        $('#rentalPricePerDay').text('$' + formatNumber(pricePerDay) + ' / ngày');
        $('#rentalDaysDisplay').text(days + ' ngày');
        $('#rentalTotalPrice').text('$' + formatNumber(total));
    }

    $('#dayDecreaseBtn').click(function() {
        if (selectedRentalDays > 1) {
            selectedRentalDays--;
            updateRentalModalPricing();
            syncQuickPicks();
        }
    });

    $('#dayIncreaseBtn').click(function() {
        if (selectedRentalDays < 7) {
            selectedRentalDays++;
            updateRentalModalPricing();
            syncQuickPicks();
        }
    });

    $(document).on('click', '.day-pick-btn', function() {
        selectedRentalDays = parseInt($(this).data('days'));
        updateRentalModalPricing();
        syncQuickPicks();
    });

    function syncQuickPicks() {
        $('.day-pick-btn').removeClass('active');
        $(`.day-pick-btn[data-days="${selectedRentalDays}"]`).addClass('active');
    }

    $('#confirmRentalBtn').click(function() {
        if (!selectedRentalVehicle) return;

        const $btn = $(this);
        $btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Đang xử lý...');

        $.post('https://tommy-trucker/rentVehicle', JSON.stringify({
            model: selectedRentalVehicle.model,
            pricePerDay: selectedRentalVehicle.pricePerDay,
            rentalDays: selectedRentalDays,
            totalPrice: selectedRentalDays * selectedRentalVehicle.pricePerDay
        }), function() {
            $btn.prop('disabled', false).html('<i class="fas fa-handshake"></i> Xác Nhận Thuê Xe');
        }).fail(function() {
            $btn.prop('disabled', false).html('<i class="fas fa-handshake"></i> Xác Nhận Thuê Xe');
        });
    });

    $('#closeRentalModalBtn').click(function() {
        $('#rentalModal').addClass('hidden');
        selectedRentalVehicle = null;
    });

    function startRentalCountdown(expireTime) {
        if (rentalTimerInterval) clearInterval(rentalTimerInterval);

        const expireSec = expireTime > 9999999999
            ? Math.floor(expireTime / 1000)
            : parseInt(expireTime);

        function tick() {
            const now  = Math.floor(Date.now() / 1000);
            const diff = expireSec - now;

            if (diff <= 0) {
                $('#activeRentalExpire').text('Hết hạn');
                clearInterval(rentalTimerInterval);
                activeRental = null;
                updateRentalTab();
                return;
            }

            const days    = Math.floor(diff / 86400);
            const hours   = Math.floor((diff % 86400) / 3600);
            const minutes = Math.floor((diff % 3600) / 60);
            const seconds = diff % 60;

            const timeStr = days > 0
                ? `${days}n ${pad(hours)}:${pad(minutes)}:${pad(seconds)}`
                : `${pad(hours)}:${pad(minutes)}:${pad(seconds)}`;

            $('#activeRentalExpire').text(timeStr);
        }

        tick();
        rentalTimerInterval = setInterval(tick, 1000);
    }

    function pad(n) { return n.toString().padStart(2, '0'); }

    // ═══════════════════════════════════════════════════════════
    // 👥 UPDATE PARTY TAB
    // ═══════════════════════════════════════════════════════════

    function updatePartyTab() {
        const $noParty = $('#noPartySection');
        const $partyCard = $('#partySection');

        if (!currentPartyData || !currentPartyData.inParty) {
            $noParty.removeClass('hidden');
            $partyCard.addClass('hidden');
            return;
        }

        $noParty.addClass('hidden');
        $partyCard.removeClass('hidden');

        $('#partyIdDisplay').text('#' + currentPartyData.visibleId);
        $('#leaderName').text(currentPartyData.leader.name);

        const $memberSlot = $('#memberSlot');

        if (currentPartyData.member) {
            $memberSlot.removeClass('empty');
            $memberSlot.html(`
                <div class="member-left">
                    <div class="member-avatar">
                        <i class="fas fa-user"></i>
                    </div>
                    <div class="member-info">
                        <span class="member-name">${currentPartyData.member.name}</span>
                        <span class="member-role">Thành viên</span>
                    </div>
                </div>
                <div class="member-status online">
                    <i class="fas fa-circle"></i>
                </div>
            `);
            $('#inviteMemberBtn').addClass('hidden');
        } else {
            $memberSlot.addClass('empty');
            $memberSlot.html(`
                <div class="member-left">
                    <div class="member-avatar empty-avatar">
                        <i class="fas fa-user-plus"></i>
                    </div>
                    <div class="member-info">
                        <span class="member-name">Chưa có thành viên</span>
                        <span class="member-role">Ấn nút bên dưới để mời</span>
                    </div>
                </div>
            `);

            if (currentPartyData.isLeader) {
                $('#inviteMemberBtn').removeClass('hidden');
            } else {
                $('#inviteMemberBtn').addClass('hidden');
            }
        }

        if (currentPartyData.isLeader) {
            $('#leavePartyBtn').html('<i class="fas fa-times-circle"></i> Giải Tán Nhóm');
        } else {
            $('#leavePartyBtn').html('<i class="fas fa-sign-out-alt"></i> Rời Nhóm');
        }
    }

    function refreshPartyData() {
        $.post('https://tommy-trucker/getPartyData', JSON.stringify({}), function(response) {
            currentPartyData = response;
            updatePartyTab();
        });
    }

    // ═══════════════════════════════════════════════════════════
    // 👥 PENDING INVITE
    // ═══════════════════════════════════════════════════════════

    function updatePendingInvite() {
        const $banner = $('#partyInviteBanner');

        if (pendingInvite && !currentPartyData?.inParty) {
            $('#inviteFromName').text(pendingInvite.name);
            $banner.removeClass('hidden');
        } else {
            $banner.addClass('hidden');
        }
    }

    $('#acceptInviteBtn').click(function() {
        $.post('https://tommy-trucker/acceptPartyInvite', JSON.stringify({}), function() {
            pendingInvite = null;
            updatePendingInvite();
            setTimeout(refreshPartyData, 500);
        });
    });

    $('#declineInviteBtn').click(function() {
        $.post('https://tommy-trucker/declinePartyInvite', JSON.stringify({}), function() {
            pendingInvite = null;
            updatePendingInvite();
        });
    });

    // ═══════════════════════════════════════════════════════════
    // 👥 PARTY ACTIONS
    // ═══════════════════════════════════════════════════════════

    $('#createPartyBtn').click(function() {
        $.post('https://tommy-trucker/createParty', JSON.stringify({}), function() {
            setTimeout(refreshPartyData, 500);
        });
    });

    $('#leavePartyBtn').click(function() {
        $.post('https://tommy-trucker/leaveParty', JSON.stringify({}), function() {
            currentPartyData = { inParty: false };
            updatePartyTab();
        });
    });

    $('#inviteMemberBtn').click(function() {
        openInviteModal();
    });

    $('#closeInviteModalBtn').click(function() {
        $('#inviteModal').addClass('hidden');
    });

    function openInviteModal() {
        const $modal = $('#inviteModal');
        const $list = $('#nearbyPlayersList');
        const $noPlayers = $('#noNearbyPlayers');
        const $loading = $('#loadingPlayers');

        $modal.removeClass('hidden');
        $list.addClass('hidden');
        $noPlayers.addClass('hidden');
        $loading.removeClass('hidden');

        $.post('https://tommy-trucker/getNearbyPlayers', JSON.stringify({}), function(response) {
            $loading.addClass('hidden');

            if (!response.players || response.players.length === 0) {
                $noPlayers.removeClass('hidden');
                return;
            }

            $list.empty();
            $list.removeClass('hidden');

            response.players.forEach(player => {
                const playerItem = `
                    <div class="nearby-player-item" data-src="${player.src}">
                        <div class="player-left">
                            <div class="player-avatar">
                                <i class="fas fa-user"></i>
                            </div>
                            <div class="player-info">
                                <span class="player-name">ID: ${player.id}</span>
                                <span class="player-distance">${player.distance}m</span>
                            </div>
                        </div>
                        <button class="btn btn-invite-player">
                            <i class="fas fa-paper-plane"></i>
                            Mời
                        </button>
                    </div>
                `;
                $list.append(playerItem);
            });
        });
    }

    $(document).on('click', '.btn-invite-player', function() {
        const targetSrc = $(this).closest('.nearby-player-item').data('src');
        $.post('https://tommy-trucker/invitePlayer', JSON.stringify({ targetSrc: targetSrc }), function() {
            $('#inviteModal').addClass('hidden');
        });
    });

    // ═══════════════════════════════════════════════════════════
    // 🔘 UPDATE REGISTER BUTTON
    // ═══════════════════════════════════════════════════════════

    function updateRegisterButton() {
        const $registerBtn = $('#registerVehicleBtn');
        if (!$registerBtn.length) return;

        if (hasActiveJob) {
            $registerBtn.hide().prop('disabled', true);
        } else {
            $registerBtn.show().prop('disabled', false);
        }
    }

    // ═══════════════════════════════════════════════════════════
    // 🚛 REGISTER VEHICLE
    // ═══════════════════════════════════════════════════════════

    $('#registerVehicleBtn').click(function() {
        if (hasActiveJob) return;

        $.post('https://tommy-trucker/registerVehicle', JSON.stringify({}), function(response) {
            if (response.vehicles && response.vehicles.length > 0) {
                showVehicleModal(response.vehicles);
            } else {
                $('#vehicleModal').removeClass('hidden');
                $('#vehicleList').addClass('hidden');
                $('#noVehicles').removeClass('hidden');
            }
        });
    });

    function showVehicleModal(vehicles) {
        const $vehicleList = $('#vehicleList');
        $vehicleList.empty();

        vehicles.forEach(vehicle => {
            const vehicleName = formatVehicleName(vehicle.vehicle);
            const vehicleItem = `
                <div class="vehicle-item" data-vehicle="${vehicle.vehicle}" data-plate="${vehicle.plate}">
                    <div class="vehicle-item-left">
                        <div class="vehicle-item-icon">
                            <i class="fas fa-truck"></i>
                        </div>
                        <div class="vehicle-item-info">
                            <div class="vehicle-item-name">${vehicleName}</div>
                            <div class="vehicle-item-plate">${vehicle.plate}</div>
                        </div>
                    </div>
                    <div class="vehicle-item-capacity">
                        <i class="fas fa-weight-hanging"></i>
                        ${vehicle.capacity}kg
                    </div>
                </div>
            `;
            $vehicleList.append(vehicleItem);
        });

        $('#vehicleModal').removeClass('hidden');
        $('#vehicleList').removeClass('hidden');
        $('#noVehicles').addClass('hidden');
    }

    $(document).on('click', '.vehicle-item', function() {
        $('.vehicle-item').removeClass('selected');
        $(this).addClass('selected');

        selectedVehicle = {
            vehicle: $(this).data('vehicle'),
            plate: $(this).data('plate')
        };

        setTimeout(() => { confirmRegister(); }, 300);
    });

    function confirmRegister() {
        if (!selectedVehicle) return;

        $.post('https://tommy-trucker/confirmRegister', JSON.stringify({
            vehicle: selectedVehicle.vehicle,
            plate: selectedVehicle.plate
        }));

        currentDriverData.registered_vehicle = selectedVehicle.vehicle;
        currentDriverData.registered_plate = selectedVehicle.plate;
        updateDriverTab();
        closeModal();
    }

    $('#closeModalBtn').click(function() { closeModal(); });

    function closeModal() {
        $('#vehicleModal').addClass('hidden');
        selectedVehicle = null;
    }

    // ═══════════════════════════════════════════════════════════
    // 🛠️ UTILITY FUNCTIONS
    // ═══════════════════════════════════════════════════════════

    function formatNumber(num) {
        return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    }

    function formatVehicleName(vehicle) {
        return vehicle
            .split('_')
            .map(word => word.charAt(0).toUpperCase() + word.slice(1))
            .join(' ');
    }

    function getVehicleCapacity(vehicle) {
        const whitelist = {
            'youga': 80,
            'speedo4': 120,
            'rumpo': 170,
            'mule5': 250,
            'pounder2': 500
        };
        return whitelist[vehicle.toLowerCase()] || 0;
    }

    // ═══════════════════════════════════════════════════════════
    // 🛠️ CANCEL JOB
    // ═══════════════════════════════════════════════════════════

    function updateCancelButton() {
        const $cancelBtn = $('#cancelJobBtn');
        if (hasActiveJob) {
            $cancelBtn.removeClass('hidden');
        } else {
            $cancelBtn.addClass('hidden');
        }
    }

    $('#cancelJobBtn').click(function() {
        $('#cancelConfirmModal').removeClass('hidden');
    });

    $('#cancelJobConfirm').click(function() {
        $('#cancelConfirmModal').addClass('hidden');
        closeUI();
        $.post('https://tommy-trucker/cancelJob', JSON.stringify({}));
    });

    $('#cancelJobCancel').click(function() {
        $('#cancelConfirmModal').addClass('hidden');
    });
});