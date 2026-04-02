// html/admin.js
let allVehicles = [];
let filteredVehicles = [];
let availableGarages = [];
let selectedVehicle = null;

function formatVehicleName(vehicleName) {
    if (!vehicleName) return 'Unknown';
    return vehicleName.toUpperCase().replace(/_/g, ' ');
}

function calculateHealthPercent(current, max = 1000) {
    if (!current) return 0;
    return Math.max(0, Math.min(100, (current / max) * 100));
}

function updateStats() {
    const total = filteredVehicles.length;
    const spawned = filteredVehicles.filter(v => v.state === 0).length;
    const stored = filteredVehicles.filter(v => v.state === 1).length;
    
    $('#totalVehicles').text(total);
    $('#spawnedVehicles').text(spawned);
    $('#storedVehicles').text(stored);
}

function renderVehicleList() {
    const $list = $('#vehicleList');
    $list.empty();
    
    if (filteredVehicles.length === 0) {
        $list.html(`
            <div class="empty-state">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="12" cy="12" r="10"></circle>
                    <line x1="12" y1="8" x2="12" y2="12"></line>
                    <line x1="12" y1="16" x2="12.01" y2="16"></line>
                </svg>
                <p>Không tìm thấy xe nào</p>
            </div>
        `);
        return;
    }
    
    filteredVehicles.forEach(vehicle => {
        const displayName = vehicle.label && vehicle.label.trim() !== ''
            ? vehicle.label
            : formatVehicleName(vehicle.vehicle);
        
        const fuelPercent = vehicle.fuel || 0;
        const enginePercent = calculateHealthPercent(vehicle.engine);
        const bodyPercent = calculateHealthPercent(vehicle.body);
        
        const statusBadge = vehicle.state === 0
            ? '<span class="status-badge spawned">Đang spawn</span>'
            : '<span class="status-badge stored">Trong garage</span>';
        
        const hasCoords = vehicle.state === 0 && vehicle.coords;
        
        const $item = $(`
            <div class="vehicle-item" data-plate="${vehicle.plate}">
                <div class="vehicle-info">
                    <h3>${displayName}</h3>
                    <p>${vehicle.vehicle}</p>
                    <span class="plate">${vehicle.plate}</span>
                </div>
                
                <div class="vehicle-owner">
                    <p>Chủ sở hữu</p>
                    <strong>${vehicle.owner_name || 'Unknown'}</strong>
                </div>
                
                <div class="vehicle-location">
                    <p>Garage</p>
                    <strong>${vehicle.garage || 'N/A'}</strong>
                    ${statusBadge}
                </div>
                
                <div class="vehicle-stats-mini">
                    <div class="stat-mini">
                        <span class="stat-mini-label">Xăng</span>
                        <div class="stat-mini-bar">
                            <div class="stat-mini-fill fuel" style="width: ${fuelPercent}%"></div>
                        </div>
                        <span class="stat-mini-value">${Math.round(fuelPercent)}%</span>
                    </div>
                    <div class="stat-mini">
                        <span class="stat-mini-label">Động cơ</span>
                        <div class="stat-mini-bar">
                            <div class="stat-mini-fill engine" style="width: ${enginePercent}%"></div>
                        </div>
                        <span class="stat-mini-value">${Math.round(enginePercent)}%</span>
                    </div>
                    <div class="stat-mini">
                        <span class="stat-mini-label">Thân vỏ</span>
                        <div class="stat-mini-bar">
                            <div class="stat-mini-fill body" style="width: ${bodyPercent}%"></div>
                        </div>
                        <span class="stat-mini-value">${Math.round(bodyPercent)}%</span>
                    </div>
                </div>
                
                <div class="vehicle-actions">
                    <button class="action-btn move-btn">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path>
                            <polyline points="9 22 9 12 15 12 15 22"></polyline>
                        </svg>
                        Chuyển
                    </button>
                    <button class="action-btn state-btn">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <polyline points="1 4 1 10 7 10"></polyline>
                            <polyline points="23 20 23 14 17 14"></polyline>
                            <path d="M20.49 9A9 9 0 0 0 5.64 5.64L1 10m22 4l-4.64 4.36A9 9 0 0 1 3.51 15"></path>
                        </svg>
                        State
                    </button>
                    ${hasCoords ? `
                    <button class="action-btn tp-btn">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <line x1="5" y1="12" x2="19" y2="12"></line>
                            <polyline points="12 5 19 12 12 19"></polyline>
                        </svg>
                        TP
                    </button>
                    ` : ''}
                </div>
            </div>
        `);
        
        $item.find('.move-btn').click(function(e) {
            e.stopPropagation();
            openMoveModal(vehicle);
        });
        
        $item.find('.state-btn').click(function(e) {
            e.stopPropagation();
            toggleVehicleState(vehicle.plate);
        });
        
        if (hasCoords) {
            $item.find('.tp-btn').click(function(e) {
                e.stopPropagation();
                teleportToVehicle(vehicle.plate);
            });
        }
        
        $list.append($item);
    });
    
    updateStats();
}

function toggleVehicleState(plate) {
    $.post('https://DERP-advanced-garages/toggleVehicleState', JSON.stringify({
        plate: plate
    }), function(response) {
        if (response.success && response.vehicles) {
            allVehicles = response.vehicles;
            applyFilters();
        }
    });
}

function teleportToVehicle(plate) {
    $.post('https://DERP-advanced-garages/teleportToVehicle', JSON.stringify({
        plate: plate
    }));
}

function applyFilters() {
    const searchTerm = $('#searchInput').val().toLowerCase();
    const garageFilter = $('#garageFilter').val();
    const stateFilter = $('#stateFilter').val();
    
    filteredVehicles = allVehicles.filter(vehicle => {
        const matchSearch = !searchTerm || 
            vehicle.plate.toLowerCase().includes(searchTerm) ||
            vehicle.vehicle.toLowerCase().includes(searchTerm) ||
            (vehicle.label && vehicle.label.toLowerCase().includes(searchTerm)) ||
            (vehicle.owner_name && vehicle.owner_name.toLowerCase().includes(searchTerm));
        
        const matchGarage = !garageFilter || vehicle.garage === garageFilter;
        const matchState = !stateFilter || vehicle.state.toString() === stateFilter;
        
        return matchSearch && matchGarage && matchState;
    });
    
    renderVehicleList();
}

function openMoveModal(vehicle) {
    selectedVehicle = vehicle;
    
    const displayName = vehicle.label && vehicle.label.trim() !== ''
        ? vehicle.label
        : formatVehicleName(vehicle.vehicle);
    
    $('#modalVehicleInfo').html(`
        <strong>${displayName}</strong> (${vehicle.plate})<br>
        Hiện tại: ${vehicle.garage || 'N/A'}
    `);
    
    const $select = $('#targetGarageSelect');
    $select.html('<option value="">Chọn garage...</option>');
    
    availableGarages.forEach(garage => {
        $select.append(`<option value="${garage.name}">${garage.label}</option>`);
    });
    
    $('#moveModal').fadeIn(200);
}

function closeMoveModal() {
    $('#moveModal').fadeOut(200);
    selectedVehicle = null;
}

function openAdminPanel(data) {
    allVehicles = data.vehicles;
    filteredVehicles = [...allVehicles];
    availableGarages = data.garages;
    
    const $garageFilter = $('#garageFilter');
    $garageFilter.html('<option value="">Tất cả garage</option>');
    
    availableGarages.forEach(garage => {
        $garageFilter.append(`<option value="${garage.name}">${garage.label}</option>`);
    });
    
    renderVehicleList();
    $('#admin-panel').fadeIn(300);
}

function closeAdminPanel() {
    $('#admin-panel').fadeOut(200);
    allVehicles = [];
    filteredVehicles = [];
    
    $.post('https://DERP-advanced-garages/closeAdminUI', JSON.stringify({}));
}

window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.action) {
        case 'openAdmin':
            openAdminPanel(data);
            break;
        case 'closeAdmin':
            closeAdminPanel();
            break;
    }
});

$(document).ready(function() {
    $('#closeAdminBtn').click(function() {
        closeAdminPanel();
    });
    
    $('#searchInput').on('input', function() {
        applyFilters();
    });
    
    $('#garageFilter, #stateFilter').change(function() {
        applyFilters();
    });
    
    $('#cancelMoveBtn').click(function() {
        closeMoveModal();
    });
    
    $('#confirmMoveBtn').click(function() {
        if (!selectedVehicle) return;
        
        const targetGarage = $('#targetGarageSelect').val();
        
        if (!targetGarage) {
            alert('Vui lòng chọn garage!');
            return;
        }
        
        $.post('https://DERP-advanced-garages/moveVehicleToGarage', JSON.stringify({
            plate: selectedVehicle.plate,
            garage: targetGarage
        }), function(response) {
            if (response.success && response.vehicles) {
                allVehicles = response.vehicles;
                applyFilters();
                closeMoveModal();
            }
        });
    });
    
    $(document).keyup(function(e) {
        if (e.key === "Escape") {
            if ($('#moveModal').is(':visible')) {
                closeMoveModal();
            } else if ($('#admin-panel').is(':visible')) {
                closeAdminPanel();
            }
        }
    });
});