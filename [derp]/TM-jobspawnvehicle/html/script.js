let resourceName = GetParentResourceName();

function GetParentResourceName() {
    let resourceName = 'npc-spawn'; // Fallback
    
    // Lấy từ URL params
    const urlParams = new URLSearchParams(window.location.search);
    const paramResource = urlParams.get('resource');
    if (paramResource) {
        return paramResource;
    }
    
    // Lấy từ window.location (method 2)
    if (window.location.hostname === 'cfx-nui-npc_spawnxe' || window.location.hostname.includes('npc_spawnxe')) {
        return 'npc_spawnxe';
    }
    
    // Lấy từ hostname
    const hostname = window.location.hostname;
    if (hostname.startsWith('cfx-nui-')) {
        return hostname.replace('cfx-nui-', '');
    }
    
    return resourceName;
}

$(function() {
    // console.log('Resource name:', resourceName);

    window.addEventListener('message', function(event) {
        const data = event.data;
        
        if (data.action === 'openMenu') {
            openMenu(data.vehicles);
        }
    });
    
    $('#closeBtn').click(function() {
        closeMenu();
    });
    
    $(document).keyup(function(e) {
        if (e.key === "Escape") {
            closeMenu();
        }
    });
});

function openMenu(vehicles) {
    const container = $('#container');
    const vehicleList = $('#vehicleList');
    
    vehicleList.empty();
    
    vehicles.forEach(vehicle => {
        const vehicleItem = $(`
            <div class="vehicle-item" data-model="${vehicle.model}">
                <div class="vehicle-icon">
                    <i class="fas fa-car"></i>
                </div>
                <div class="vehicle-info">
                    <div class="vehicle-name">${vehicle.label}</div>
                    <div class="vehicle-model">${vehicle.model}</div>
                </div>
                <div class="vehicle-arrow">
                    <i class="fas fa-chevron-right"></i>
                </div>
            </div>
        `);
        
        vehicleItem.click(function() {
            // console.log('Clicked vehicle:', vehicle.model);
            spawnVehicle(vehicle.model);
        });
        
        vehicleList.append(vehicleItem);
    });
    
    container.removeClass('hidden');
}

function closeMenu() {
    $('#container').addClass('hidden');
    $.post(`https://${resourceName}/closeMenu`, JSON.stringify({}));
}

function spawnVehicle(model) {
    // console.log('Spawning vehicle:', model);
    // console.log('Using resource name:', resourceName);
    
    // Đóng menu trước
    $('#container').addClass('hidden');
    
    // Gửi request spawn xe
    $.post(`https://${resourceName}/spawnVehicle`, JSON.stringify({
        model: model
    }));
}