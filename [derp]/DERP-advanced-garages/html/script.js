let currentVehicles = [];
let currentGarage = null;
let currentPreviewIndex = 0;
let isImpoundGarage = false;

function formatVehicleName(vehicleName) {
    if (!vehicleName) return 'Unknown';
    return vehicleName.toUpperCase().replace(/_/g, ' ');
}

function calculateHealthPercent(current, max = 1000) {
    if (!current) return 0;
    return Math.max(0, Math.min(100, (current / max) * 100));
}

function formatMoney(amount) {
    return '$' + amount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
}

function formatTime(minutes) {
    if (minutes <= 0) return 'Hết hạn';
    
    if (minutes < 60) {
        return minutes + ' phút';
    }
    
    const hours = Math.floor(minutes / 60);
    const mins = minutes % 60;
    
    if (mins === 0) {
        return hours + ' giờ';
    }
    
    return hours + ' giờ ' + mins + ' phút';
}

function showPreviewVehicle(index) {
    if (index < 0 || index >= currentVehicles.length) return;
    
    currentPreviewIndex = index;
    const vehicle = currentVehicles[index];
    
    const fuelPercent = vehicle.fuel || 0;
    const enginePercent = calculateHealthPercent(vehicle.engine);
    const bodyPercent = calculateHealthPercent(vehicle.body);
    
    const displayName = vehicle.label && vehicle.label.trim() !== ''
        ? vehicle.label
        : formatVehicleName(vehicle.vehicle);
    
    $('#previewVehicleName').text(displayName);
    $('#previewVehiclePlate').text(vehicle.plate);
    
    $('#previewFuel').text(Math.round(fuelPercent) + '%');
    $('#previewEngine').text(Math.round(enginePercent) + '%');
    $('#previewBody').text(Math.round(bodyPercent) + '%');
    
    $('#previewFuelBar').css('width', fuelPercent + '%');
    $('#previewEngineBar').css('width', enginePercent + '%');
    $('#previewBodyBar').css('width', bodyPercent + '%');
    
    if (isImpoundGarage && (vehicle.impound_price !== null && vehicle.impound_price !== undefined)) {
        $('#impoundInfo').show();
        
        const price = vehicle.impound_price || 0;
        const timeLeft = vehicle.impound_time_left || 0;
        const totalDuration = vehicle.impound_duration || 0;
        const reason = vehicle.impound_reason || '-';
        const impoundedBy = vehicle.impound_by || '-';
        
        $('#impoundPrice').text(formatMoney(price));
        $('#impoundTime').text(formatTime(timeLeft));
        $('#impoundReason').text(reason);
        $('#impoundBy').text(impoundedBy);
        
        const progressPercent = totalDuration > 0 
            ? ((totalDuration - timeLeft) / totalDuration) * 100 
            : 100;
        $('#impoundProgressBar').css('width', progressPercent + '%');
        
        const $btn = $('#spawnActionBtn');
        
        if (timeLeft > 0) {
            $('#spawnBtnText').text('Còn ' + formatTime(timeLeft));
            $btn.prop('disabled', true);
            $btn.addClass('disabled');
        } else if (price > 0) {
            $('#spawnBtnText').text('Trả ' + formatMoney(price));
            $btn.prop('disabled', false);
            $btn.removeClass('disabled');
        } else {
            $('#spawnBtnText').text('Lấy xe');
            $btn.prop('disabled', false);
            $btn.removeClass('disabled');
        }
    } else {
        $('#impoundInfo').hide();
        $('#spawnBtnText').text('Lấy xe');
        $('#spawnActionBtn').prop('disabled', false).removeClass('disabled');
    }
    
    $('#prevVehicleBtn').prop('disabled', index === 0);
    $('#nextVehicleBtn').prop('disabled', index === currentVehicles.length - 1);
    
    $('#vehicleCounter').text(`${index + 1} / ${currentVehicles.length}`);
    
    $.post('https://DERP-advanced-garages/updatePreview', JSON.stringify({
        vehicle: vehicle
    }));
}

function openEditMode() {
    const vehicle = currentVehicles[currentPreviewIndex];
    if (!vehicle) return;
    
    const currentLabel = vehicle.label || formatVehicleName(vehicle.vehicle);
    
    $('#editNameInput').val(currentLabel);
    $('#previewVehicleName').hide();
    $('#editNameBtn').hide();
    $('#editNameContainer').show();
    $('#editNameInput').focus();
}

function closeEditMode() {
    $('#editNameContainer').hide();
    $('#previewVehicleName').show();
    $('#editNameBtn').show();
}

function saveVehicleName() {
    const vehicle = currentVehicles[currentPreviewIndex];
    if (!vehicle) return;
    
    const newLabel = $('#editNameInput').val().trim();
    
    $.post('https://DERP-advanced-garages/updateLabel', JSON.stringify({
        plate: vehicle.plate,
        label: newLabel
    }), function(response) {
        if (response.success) {
            currentVehicles[currentPreviewIndex].label = newLabel;
            showPreviewVehicle(currentPreviewIndex);
            closeEditMode();
        }
    });
}

function openGarage(data) {
    currentGarage = data.garage;
    currentVehicles = data.vehicles;
    currentPreviewIndex = 0;
    isImpoundGarage = data.garage.isImpound || false;
    
    $('#spawnActionBtn').removeClass('loading');
    
    if (currentVehicles.length > 0) {
        $('#preview-overlay').fadeIn(300);
        showPreviewVehicle(0);
    } else {
        $('#previewVehicleName').text('Không có xe');
        $('#previewVehiclePlate').text('---');
        $('#impoundInfo').hide();
        $('#preview-overlay').fadeIn(300);
    }
}

function closeGarage() {
    $.post('https://DERP-advanced-garages/stopPreview', JSON.stringify({}));
    
    $('#spawnActionBtn').removeClass('loading');
    $('#preview-overlay').fadeOut(200);
    $('#impoundInfo').hide();
    closeEditMode();
    
    currentVehicles = [];
    currentGarage = null;
    currentPreviewIndex = 0;
    isImpoundGarage = false;
    
    $.post('https://DERP-advanced-garages/closeUI', JSON.stringify({}));
}

window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.action) {
        case 'openGarage':
            openGarage(data);
            break;
        case 'closeGarage':
            closeGarage();
            break;
    }
});

$(document).ready(function() {
    $('#prevVehicleBtn').click(function() {
        if (currentPreviewIndex > 0) {
            closeEditMode();
            showPreviewVehicle(currentPreviewIndex - 1);
        }
    });
    
    $('#nextVehicleBtn').click(function() {
        if (currentPreviewIndex < currentVehicles.length - 1) {
            closeEditMode();
            showPreviewVehicle(currentPreviewIndex + 1);
        }
    });
    
    $('#editNameBtn').click(function() {
        openEditMode();
    });
    
    $('#saveNameBtn').click(function() {
        saveVehicleName();
    });
    
    $('#cancelNameBtn').click(function() {
        closeEditMode();
    });
    
    $('#editNameInput').keyup(function(e) {
        if (e.key === "Enter") {
            saveVehicleName();
        } else if (e.key === "Escape") {
            closeEditMode();
        }
    });
    
    $('#spawnActionBtn').click(function() {
        if (currentVehicles.length === 0) return;
        
        const vehicle = currentVehicles[currentPreviewIndex];
        if (!vehicle) return;
        
        const $btn = $(this);
        $btn.addClass('loading');
        
        $.post('https://DERP-advanced-garages/spawnVehicleFromPreview', JSON.stringify({
            plate: vehicle.plate
        }), function(response) {
            $btn.removeClass('loading');
            
            if (response.success) {
                closeGarage();
            } else {
                console.error('Failed to spawn vehicle:', response.message);
            }
        }).fail(function() {
            $btn.removeClass('loading');
        });
    });
    
    $(document).keyup(function(e) {
        if (e.key === "Escape") {
            if ($('#editNameContainer').is(':visible')) {
                closeEditMode();
            } else {
                closeGarage();
            }
        }
    });
    
    $(document).keydown(function(e) {
        if ($('#preview-overlay').is(':visible') && !$('#editNameContainer').is(':visible')) {
            if (e.key === "ArrowLeft" && currentPreviewIndex > 0) {
                e.preventDefault();
                showPreviewVehicle(currentPreviewIndex - 1);
            } else if (e.key === "ArrowRight" && currentPreviewIndex < currentVehicles.length - 1) {
                e.preventDefault();
                showPreviewVehicle(currentPreviewIndex + 1);
            }
        }
    });
});

document.onkeydown = function(e) {
    if(e.keyCode == 123) return false;
    if(e.ctrlKey && e.shiftKey && e.keyCode == 'I'.charCodeAt(0)) return false;
    if(e.ctrlKey && e.shiftKey && e.keyCode == 'C'.charCodeAt(0)) return false;
    if(e.ctrlKey && e.shiftKey && e.keyCode == 'J'.charCodeAt(0)) return false;
    if(e.ctrlKey && e.keyCode == 'U'.charCodeAt(0)) return false;
};