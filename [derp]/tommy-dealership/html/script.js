let currentData = null;
let currentLocale = {};
let currentColors = [];
let selectedSlot = null;
let selectedVehicle = null;
let selectedColor = null;
let selectedPlayer = null;
let currentAction = null;
let currentLanguage = 'vi';
let allLocales = {};
let selfPurchaseData = null;

let inventoryFilterState = {
    searchText: '',
    activeFilter: null,
    filteredStock: []
};

let statisticsState = {
    salesDisplayCount: 10,
    selfPurchaseDisplayCount: 10,
    allSales: [],
    allSelfPurchases: []
};

let selfPurchaseFilterState = {
    searchText: '',
    activeSort: 'available',
    allVehicles: [],
    filteredVehicles: []
};

$(document).ready(function() {
    window.addEventListener('message', function(event) {
        const data = event.data;
        switch(data.action) {
            case 'openTablet':
                openTablet(data.data, data.locale, data.colors);
                break;
            case 'refreshData':
                refreshData(data.data);
                break;
            case 'openSelfPurchase':
                openSelfPurchaseUI(data.data, data.locale, data.colors);
                break;
        }
    });

    $(document).keyup(function(e) {
        if (e.key === "Escape") {
            if ($('#selfPurchaseContainer').hasClass('active')) {
                closeSelfPurchase();
            } else if ($('#tabletContainer').hasClass('active')) {
                closeTablet();
            }
        }
    });

    $('#closeBtn').click(closeTablet);
    $('#closeSelfPurchaseBtn').click(closeSelfPurchase);
    $('.lang-btn').click(function() { const lang = $(this).data('lang'); changeLanguage(lang); });
    $('.nav-btn').click(function() { const tab = $(this).data('tab'); switchTab(tab); });
    $('.modal-close').click(function() { $(this).closest('.modal').removeClass('active'); });
    $('#sellBtn').click(showPlayerSelect);
    $('#testDriveBtn').click(showPlayerSelectForTest);
    $('#restockBtn').click(showRestockModal);
    $('#changeVehicleBtn').click(showChangeVehicleModal);
    $('#changeColorBtn').click(showColorPickerModal);
    $('#clearSlotBtn').click(clearShowroomSlot);
    $('#importBtn').click(showImportModal);
    $('#confirmRestockBtn').click(confirmRestock);
    $('#confirmImportBtn').click(confirmImport);
    $('#confirmEditPriceBtn').click(confirmEditPrice);
    $('#confirmEditGCPriceBtn').click(confirmEditGCPrice);
    $('#confirmEditDescriptionBtn').click(confirmEditDescription);

    $('#selfPurchaseSearchInput').on('input', function() {
        selfPurchaseFilterState.searchText = $(this).val().toLowerCase().trim();
        if (selfPurchaseFilterState.searchText.length > 0) { $('#clearSelfPurchaseSearch').show(); } else { $('#clearSelfPurchaseSearch').hide(); }
        applySelfPurchaseFilters();
    });

    $('#clearSelfPurchaseSearch').click(function() {
        $('#selfPurchaseSearchInput').val('');
        selfPurchaseFilterState.searchText = '';
        $(this).hide();
        applySelfPurchaseFilters();
    });

    $('#inventorySearch').on('input', function() {
        inventoryFilterState.searchText = $(this).val().toLowerCase().trim();
        if (inventoryFilterState.searchText.length > 0) { $('#clearSearch').show(); } else { $('#clearSearch').hide(); }
        applyInventoryFilters();
    });

    $('#clearSearch').click(function() {
        $('#inventorySearch').val('');
        inventoryFilterState.searchText = '';
        $(this).hide();
        applyInventoryFilters();
    });

    $('#changeVehicleSearch').on('input', function() {
        const searchText = $(this).val().toLowerCase().trim();
        if (searchText.length > 0) { $('#clearChangeVehicleSearch').show(); } else { $('#clearChangeVehicleSearch').hide(); }
        filterChangeVehicleList(searchText);
    });

    $('#clearChangeVehicleSearch').click(function() {
        $('#changeVehicleSearch').val('');
        $(this).hide();
        filterChangeVehicleList('');
    });

    $('#filterPriceLow').click(function() { toggleInventoryFilter('price-low', $(this)); });
    $('#filterPriceHigh').click(function() { toggleInventoryFilter('price-high', $(this)); });
    $('#filterAutoSell').click(function() { toggleInventoryFilter('auto-sell', $(this)); });
    $('#filterStockHigh').click(function() { toggleInventoryFilter('stock-high', $(this)); });
    $('#resetFilters').click(function() { resetInventoryFilters(); });

    $('.stats-nav-btn').click(function() { const tab = $(this).data('stats-tab'); switchStatsTab(tab); });

    $('#salesLoadMoreBtn').click(function() { statisticsState.salesDisplayCount += 10; renderSalesTable(); });
    $('#selfPurchaseLoadMoreBtn').click(function() { statisticsState.selfPurchaseDisplayCount += 10; renderSelfPurchasesTable(); });

    $('#modalClose, #playerModalClose, #paymentModalClose, #restockModalClose, #importModalClose, #changeVehicleModalClose, #colorPickerModalClose, #selfPurchaseColorModalClose, #selfPurchasePaymentModalClose, #editPriceModalClose, #editGCPriceModalClose').click(function() {
        $(this).closest('.modal').removeClass('active');
    });

    $('#sortAvailableBtn').click(function() {
        selfPurchaseFilterState.activeSort = 'available';
        $('.filter-btn').removeClass('active');
        $(this).addClass('active');
        applySelfPurchaseFilters();
    });

    $('#sortCheapBtn').click(function() {
        selfPurchaseFilterState.activeSort = 'cheap';
        $('.filter-btn').removeClass('active');
        $(this).addClass('active');
        applySelfPurchaseFilters();
    });

    $('#sortExpensiveBtn').click(function() {
        selfPurchaseFilterState.activeSort = 'expensive';
        $('.filter-btn').removeClass('active');
        $(this).addClass('active');
        applySelfPurchaseFilters();
    });
});

function toggleInventoryFilter(filterType, buttonElement) {
    if (inventoryFilterState.activeFilter === filterType) {
        inventoryFilterState.activeFilter = null;
        $('.inventory-filter-btn').removeClass('active');
    } else {
        inventoryFilterState.activeFilter = filterType;
        $('.inventory-filter-btn').removeClass('active');
        buttonElement.addClass('active');
    }
    applyInventoryFilters();
}

function resetInventoryFilters() {
    inventoryFilterState.searchText = '';
    inventoryFilterState.activeFilter = null;
    $('#inventorySearch').val('');
    $('#clearSearch').hide();
    $('.inventory-filter-btn').removeClass('active');
    applyInventoryFilters();
}

function applyInventoryFilters() {
    if (!currentData || !currentData.stock) { loadInventory(); return; }
    let filteredStock = [...currentData.stock];
    if (inventoryFilterState.searchText.length > 0) {
        filteredStock = filteredStock.filter(item => {
            const label = (item.label || '').toLowerCase();
            const vehicle = (item.vehicle || '').toLowerCase();
            return label.includes(inventoryFilterState.searchText) || vehicle.includes(inventoryFilterState.searchText);
        });
    }
    if (inventoryFilterState.activeFilter) {
        switch (inventoryFilterState.activeFilter) {
            case 'price-low': filteredStock.sort((a, b) => a.price - b.price); break;
            case 'price-high': filteredStock.sort((a, b) => b.price - a.price); break;
            case 'auto-sell': filteredStock = filteredStock.filter(item => item.allowSelfPurchase === true); break;
            case 'stock-high': filteredStock.sort((a, b) => b.stock - a.stock); break;
        }
    }
    inventoryFilterState.filteredStock = filteredStock;
    renderInventoryList(filteredStock);
}

function renderInventoryList(stockList) {
    const list = $('#inventoryList');
    list.empty();
    if (!stockList || stockList.length === 0) {
        const noResultsText = inventoryFilterState.searchText.length > 0 || inventoryFilterState.activeFilter
            ? (currentLocale['ui_no_results'] || 'Không tìm thấy kết quả')
            : (currentLocale['ui_no_sales'] || 'Không có hàng');
        list.append(`<div style="text-align: center; padding: 40px; color: rgba(255,255,255,0.5);"><p>${noResultsText}</p></div>`);
        return;
    }
    stockList.forEach(item => {
        const gcPriceDisplay = item.gcPrice > 0 ? ` / ${formatNumber(item.gcPrice)} DE-Coin` : '';
        const inventoryItem = $(`
            <div class="inventory-item ${item.stock === 0 ? 'out-of-stock' : ''}">
                <div class="item-info">
                    <h4>${item.label || formatVehicleName(item.vehicle)}</h4>
                    <p>${item.vehicle}</p>
                </div>
                <div class="item-stats">
                    <div class="stat-badge">
                        <label>${currentLocale['ui_stock'] || 'Stock'}</label>
                        <span>${item.stock}</span>
                    </div>
                    <div class="stat-badge stat-badge-price">
                        <label>${currentLocale['ui_price'] || 'Price'}</label>
                        <span class="${currentData.playerGrade >= 4 ? 'price-clickable' : ''}" data-vehicle="${item.vehicle}" data-price="${item.price}">${formatMoney(item.price)}</span>
                        ${currentData.playerGrade >= 4 ? `<span class="gc-price-clickable" data-vehicle="${item.vehicle}" data-gc-price="${item.gcPrice || 0}"> / ${item.gcPrice > 0 ? formatNumber(item.gcPrice) : '0'} DE-Coin</span>` : (item.gcPrice > 0 ? `<span> / ${formatNumber(item.gcPrice)} DE-Coin</span>` : '')}
                    </div>
                    ${currentData.playerGrade >= 4 ? `
                        <div class="auto-sell-toggle">
                            <label class="switch">
                                <input type="checkbox" class="toggle-self-purchase" data-vehicle="${item.vehicle}" ${item.allowSelfPurchase ? 'checked' : ''}>
                                <span class="slider"></span>
                            </label>
                            <span class="toggle-label">${currentLocale['ui_auto_sell'] || 'Bán Tự Động'}</span>
                        </div>
                        <button class="btn-restock-inline" data-vehicle="${item.vehicle}" data-price="${item.price}" data-gc-price="${item.gcPrice || 0}">
                            <span>📦</span>
                            <span class="restock-text">${currentLocale['ui_restock'] || 'Restock'}</span>
                        </button>
                        <button class="btn-edit-desc-inline" data-vehicle="${item.vehicle}" data-description="${escapeHtml(item.description || '')}">
                            <span>📝</span>
                            <span class="edit-desc-text">${currentLocale['ui_edit_description'] || 'Sửa Mô Tả'}</span>
                        </button>
                    ` : ''}
                </div>
            </div>
        `);
        inventoryItem.find('.toggle-self-purchase').change(function(e) {
            const vehicle = $(this).data('vehicle');
            const enabled = $(this).is(':checked');
            const $checkbox = $(this);
            $checkbox.prop('disabled', true);
            $.post('https://tommy-dealership/toggleSelfPurchase', JSON.stringify({ vehicle: vehicle, enabled: enabled }), function(success) {
                if (success) { const stockItem = currentData.stock.find(s => s.vehicle === vehicle); if (stockItem) { stockItem.allowSelfPurchase = enabled; } }
                else { $checkbox.prop('checked', !enabled); }
                $checkbox.prop('disabled', false);
            }).fail(function() { $checkbox.prop('checked', !enabled); $checkbox.prop('disabled', false); });
        });
        if (currentData.playerGrade >= 4) {
            inventoryItem.find('.price-clickable').click(function(e) { e.stopPropagation(); showEditPriceModal($(this).data('vehicle'), $(this).data('price')); });
            inventoryItem.find('.gc-price-clickable').click(function(e) { e.stopPropagation(); showEditGCPriceModal($(this).data('vehicle'), $(this).data('gc-price')); });
            inventoryItem.find('.btn-restock-inline').click(function(e) { e.stopPropagation(); showRestockModalForVehicle($(this).data('vehicle'), $(this).data('price'), $(this).data('gc-price')); });
            inventoryItem.find('.btn-edit-desc-inline').click(function(e) { e.stopPropagation(); showEditDescriptionModal($(this).data('vehicle'), $(this).data('description')); });
        }
        list.append(inventoryItem);
    });
}

function openTablet(data, locale, colors) {
    currentData = data;
    currentColors = colors || [];
    buildRuntimeConfig(data);
    if (locale && typeof locale === 'object' && (locale.en || locale.vi)) {
        allLocales = locale;
        currentLocale = locale[currentLanguage] || locale.en || locale.vi || {};
    } else {
        allLocales[currentLanguage] = locale;
        currentLocale = locale;
    }
    $('#tabletContainer').addClass('active');
    $('#shopName').text(Config.Shops[data.shop]?.ShopLabel || data.shop);
    $('.lang-btn').removeClass('active');
    $(`.lang-btn[data-lang="${currentLanguage}"]`).addClass('active');
    updateLocale();
    if (data.playerGrade >= 4) { $('.management-only').show(); } else { $('.management-only').hide(); }
    resetInventoryFilters();
    loadShowroomVehicles();
    loadInventory();
    loadStatistics();
    $.post('https://tommy-dealership/refreshData', JSON.stringify({}));
}

function closeTablet() {
    $('#tabletContainer').removeClass('active');
    $('.modal').removeClass('active');
    $.post('https://tommy-dealership/closeTablet', JSON.stringify({}));
}

function openSelfPurchaseUI(data, locale, colors) {
    selfPurchaseData = data;
    currentColors = colors || [];
    if (locale && typeof locale === 'object' && (locale.en || locale.vi)) {
        allLocales = locale;
        currentLocale = locale[currentLanguage] || locale.en || locale.vi || {};
    }
    selfPurchaseFilterState.allVehicles = selfPurchaseData.vehicles || [];
    selfPurchaseFilterState.searchText = '';
    selfPurchaseFilterState.activeSort = 'available';
    $('#selfPurchaseSearchInput').val('');
    $('#clearSelfPurchaseSearch').hide();
    $('#selfPurchaseContainer').addClass('active');
    $('.filter-btn').removeClass('active');
    $('#sortAvailableBtn').addClass('active');
    updateSelfPurchaseLocale();
    applySelfPurchaseFilters();
}

function closeSelfPurchase() {
    $('#selfPurchaseContainer').removeClass('active');
    $('.modal').removeClass('active');
    $.post('https://tommy-dealership/closeSelfPurchase', JSON.stringify({}));
}

function updateSelfPurchaseLocale() {
    $('#selfPurchaseTitle').text(currentLocale['ui_buy_vehicle'] || 'Mua Xe');
    $('#markupNoticeText').text(currentLocale['ui_markup_notice'] || 'Tự mua có giá cao hơn 10% so với mua từ nhân viên');
    $('#sortAvailableBtnText').text(currentLocale['ui_sort_available'] || 'Có Thể Mua');
    $('#sortCheapBtnText').text(currentLocale['ui_sort_cheap'] || 'Giá Thấp');
    $('#sortExpensiveBtnText').text(currentLocale['ui_sort_expensive'] || 'Giá Cao');
    $('#selfPurchaseSearchInput').attr('placeholder', currentLocale['ui_search_vehicle'] || 'Tìm kiếm xe...');
    if (selfPurchaseData && selfPurchaseData.playerGC !== undefined) {
        $('#playerGCDisplay').text(`${currentLocale['ui_your_gc'] || 'DE-Coin'}: ${formatNumber(selfPurchaseData.playerGC)}`);
    }
}

function applySelfPurchaseFilters() {
    let vehicles = [...selfPurchaseFilterState.allVehicles];
    if (selfPurchaseFilterState.searchText.length > 0) {
        vehicles = vehicles.filter(vehicle => {
            const label = (vehicle.label || '').toLowerCase();
            const model = (vehicle.vehicle || '').toLowerCase();
            return label.includes(selfPurchaseFilterState.searchText) || model.includes(selfPurchaseFilterState.searchText);
        });
    }
    switch (selfPurchaseFilterState.activeSort) {
        case 'available':
            vehicles.sort((a, b) => {
                const aCanBuy = a.allowSelfPurchase === true && a.stock > 0;
                const bCanBuy = b.allowSelfPurchase === true && b.stock > 0;
                if (aCanBuy && !bCanBuy) return -1;
                if (!aCanBuy && bCanBuy) return 1;
                return a.price - b.price;
            });
            break;
        case 'cheap': vehicles.sort((a, b) => a.price - b.price); break;
        case 'expensive': vehicles.sort((a, b) => b.price - a.price); break;
    }
    selfPurchaseFilterState.filteredVehicles = vehicles;
    renderSelfPurchaseVehicles(vehicles);
}

function renderSelfPurchaseVehicles(vehicles) {
    const grid = $('#selfPurchaseGrid');
    grid.empty();
    if (!vehicles || vehicles.length === 0) {
        const noResultsText = selfPurchaseFilterState.searchText.length > 0
            ? (currentLocale['ui_no_results'] || 'Không tìm thấy kết quả')
            : (currentLocale['ui_no_sales'] || 'Không có xe');
        grid.append(`<div style="grid-column: 1/-1; text-align: center; padding: 40px; color: rgba(255,255,255,0.5);"><p>${noResultsText}</p></div>`);
        return;
    }
    vehicles.forEach(vehicle => {
        const imagePath = `images/${vehicle.vehicle}.png`;
        const stockText = vehicle.stock > 0 ? vehicle.stock : (currentLocale['ui_out_of_stock'] || 'Hết hàng');
        const stockClass = vehicle.stock > 0 ? '' : 'out-of-stock';
        const canBuy = vehicle.allowSelfPurchase === true && vehicle.stock > 0;
        const gcPriceDisplay = vehicle.gcPrice > 0 ? ` / ${formatNumber(vehicle.gcPrice)} DE-Coin` : '';
        const card = $(`
            <div class="self-purchase-card ${stockClass}">
                <div class="vehicle-image">
                    <img src="${imagePath}" onerror="this.src='images/default.png'" alt="${vehicle.label}">
                </div>
                <div class="vehicle-details">
                    <h3>${vehicle.label}</h3>
                    <p class="vehicle-model">${vehicle.vehicle}</p>
                    ${vehicle.description ? `<p class="vehicle-description">${vehicle.description}</p>` : ''}
                    <div class="vehicle-info-row">
                        <div class="info-col">
                            <span class="info-label">${currentLocale['ui_price'] || 'Giá'}:</span>
                            <span class="info-value price">$${formatMoney(vehicle.price)}${gcPriceDisplay}</span>
                        </div>
                        <div class="info-col">
                            <span class="info-label">${currentLocale['ui_stock'] || 'Tồn kho'}:</span>
                            <span class="info-value stock ${vehicle.stock > 0 ? '' : 'no-stock'}">${stockText}</span>
                        </div>
                    </div>
                    ${canBuy ? `
                        <button class="btn-buy" data-vehicle="${vehicle.vehicle}" data-price="${vehicle.price}" data-gc-price="${vehicle.gcPrice || 0}">
                            <span>🛒</span>
                            <span>${currentLocale['ui_buy_vehicle'] || 'Mua Xe'}</span>
                        </button>
                    ` : `
                        <button class="btn-contact" disabled>
                            <span>📞</span>
                            <span>${currentLocale['ui_contact_staff'] || 'Liên Hệ Nhân Viên'}</span>
                        </button>
                    `}
                </div>
            </div>
        `);
        card.find('.btn-buy').click(function() {
            showSelfPurchaseColorPicker($(this).data('vehicle'), $(this).data('price'), $(this).data('gc-price'));
        });
        grid.append(card);
    });
}

function showSelfPurchaseColorPicker(vehicle, price, gcPrice) {
    selectedVehicle = vehicle;
    $('#selfPurchaseColorModalTitle').text(currentLocale['ui_select_color'] || 'Chọn Màu');
    const grid = $('#selfPurchaseColorGrid');
    grid.empty();
    const basicColors = [
        { colorindex: 0, name: 'Black' }, { colorindex: 3, name: 'Gray' }, { colorindex: 111, name: 'White' },
        { colorindex: 27, name: 'Red' }, { colorindex: 88, name: 'Yellow' }, { colorindex: 63, name: 'Blue' },
        { colorindex: 53, name: 'Green' }, { colorindex: 138, name: 'Orange' }, { colorindex: 135, name: 'Pink' },
        { colorindex: 145, name: 'Violet' }, { colorindex: 96, name: 'Brown' },
    ];
    basicColors.forEach(colorData => {
        const colorItem = $(`
            <div class="color-item" data-colorindex="${colorData.colorindex}" title="${colorData.name}">
                <div class="color-preview" style="background-color: ${getColorHex(colorData.colorindex)};"></div>
                <span class="color-name">${colorData.name}</span>
            </div>
        `);
        colorItem.click(function() {
            selectedColor = colorData.colorindex;
            $('.color-item').removeClass('selected');
            $(this).addClass('selected');
            showSelfPurchasePayment(vehicle, price, gcPrice, selectedColor);
        });
        grid.append(colorItem);
    });
    $('#selfPurchaseColorModal').addClass('active');
}

function showSelfPurchasePayment(vehicle, price, gcPrice, color) {
    $('#selfPurchaseColorModal').removeClass('active');
    const vehicleInfo = selfPurchaseData.vehicles.find(v => v.vehicle === vehicle);
    $('#spPaymentVehicleName').text(vehicleInfo.label);
    $('#spPaymentPrice').text('$' + formatMoney(price));
    $('#spPaymentGCPrice').text(gcPrice > 0 ? formatNumber(gcPrice) + ' DE-Coin' : 'N/A');
    $('#spPaymentColor').text(getColorName(color));
    if (gcPrice > 0) { $('#spPayGCBtn').show().prop('disabled', false); } else { $('#spPayGCBtn').hide(); }
    $('#selfPurchasePaymentModal').addClass('active');
    $('#spPayCashBtn').off('click').on('click', function() { confirmSelfPurchase(vehicle, price, color, 'cash'); });
    $('#spPayBankBtn').off('click').on('click', function() { confirmSelfPurchase(vehicle, price, color, 'bank'); });
    $('#spPayGCBtn').off('click').on('click', function() { confirmSelfPurchase(vehicle, gcPrice, color, 'gc'); });
}

function confirmSelfPurchase(vehicle, price, color, paymentType) {
    $.post('https://tommy-dealership/purchaseVehicleSelf', JSON.stringify({ vehicle: vehicle, color: color, paymentType: paymentType }), function(success) {
        if (success) { $('#selfPurchasePaymentModal').removeClass('active'); closeSelfPurchase(); }
    });
}

function changeLanguage(lang) {
    currentLanguage = lang;
    if (allLocales[lang]) {
        currentLocale = allLocales[lang];
        $('.lang-btn').removeClass('active');
        $(`.lang-btn[data-lang="${lang}"]`).addClass('active');
        updateLocale();
        if ($('#selfPurchaseContainer').hasClass('active')) { updateSelfPurchaseLocale(); applySelfPurchaseFilters(); }
        else { loadShowroomVehicles(); applyInventoryFilters(); loadStatistics(); }
    } else {
        $.post('https://tommy-dealership/changeLanguage', JSON.stringify({ language: lang }), function(locale) {
            if (locale && typeof locale === 'object') {
                allLocales[lang] = locale;
                currentLocale = locale;
                $('.lang-btn').removeClass('active');
                $(`.lang-btn[data-lang="${lang}"]`).addClass('active');
                updateLocale();
                if ($('#selfPurchaseContainer').hasClass('active')) { updateSelfPurchaseLocale(); applySelfPurchaseFilters(); }
                else { loadShowroomVehicles(); applyInventoryFilters(); loadStatistics(); }
            }
        });
    }
}

function updateLocale() {
    $('#navDashboard').text(currentLocale['ui_dashboard'] || 'Dashboard');
    $('#navInventory').text(currentLocale['ui_inventory'] || 'Inventory');
    $('#navStatistics').text(currentLocale['ui_statistics'] || 'Statistics');
    $('#importBtnText').text(currentLocale['ui_import_vehicle'] || 'Import Vehicle');
    $('#autoSellBtnText').text(currentLocale['ui_auto_sell'] || 'Bán Tự Động');
    $('#sellBtnText').text(currentLocale['ui_sell'] || 'Sell Vehicle');
    $('#testDriveBtnText').text(currentLocale['ui_test_drive'] || 'Test Drive');
    $('#restockBtnText').text(currentLocale['ui_restock'] || 'Restock');
    $('#changeVehicleBtnText').text(currentLocale['ui_change_vehicle'] || 'Change Vehicle');
    $('#changeColorBtnText').text(currentLocale['ui_change_color'] || 'Change Color');
    $('#clearSlotBtnText').text(currentLocale['ui_clear_slot'] || 'Clear Slot');
    $('#importDescriptionLabel').text((currentLocale['ui_description'] || 'Description') + ':');
    $('#editDescriptionTitle').text(currentLocale['ui_edit_description'] || 'Sửa Mô Tả Xe');
    $('#filterPriceLowText').text(currentLocale['ui_price_low'] || 'Giá Thấp');
    $('#filterPriceHighText').text(currentLocale['ui_price_high'] || 'Giá Cao');
    $('#filterAutoSellText').text(currentLocale['ui_auto_sell'] || 'Bán Tự Động');
    $('#filterStockHighText').text(currentLocale['ui_stock_high'] || 'Tồn Kho Cao');
    $('#resetFiltersText').text(currentLocale['ui_reset_filters'] || 'Xóa Bộ Lọc');
    $('#inventorySearch').attr('placeholder', currentLocale['ui_search_vehicle'] || 'Tìm kiếm xe...');
    $('#changeVehicleSearch').attr('placeholder', currentLocale['ui_search_vehicle'] || 'Tìm kiếm xe...');
    $('#labelStock').text((currentLocale['ui_stock'] || 'Stock') + ':');
    $('#labelPrice').text((currentLocale['ui_price'] || 'Price') + ':');
    $('#labelColor').text((currentLocale['ui_color'] || 'Color') + ':');
    $('#inventoryTitle').text(currentLocale['ui_inventory'] || 'Inventory');
    $('#totalSalesLabel').text(currentLocale['ui_total_sales'] || 'Total Sales');
    $('#totalCommissionLabel').text(currentLocale['ui_total_commission'] || 'Total Commission');
    $('#totalSelfPurchaseLabel').text(currentLocale['ui_total_self_purchase'] || 'Self Purchase Sales');
    $('#navEmployeeSales').text(currentLocale['ui_employee_sales'] || 'Employee Sales');
    $('#navSelfPurchases').text(currentLocale['ui_self_purchases_tab'] || 'Self Purchases');
    $('#thSeller').text(currentLocale['ui_seller'] || 'Seller');
    $('#thBuyer').text(currentLocale['ui_buyer'] || 'Buyer');
    $('#thVehicle').text(currentLocale['ui_vehicle'] || 'Vehicle');
    $('#thPrice').text(currentLocale['ui_price'] || 'Price');
    $('#thCommission').text(currentLocale['ui_commission'] || 'Commission');
    $('#thDate').text(currentLocale['ui_date'] || 'Date');
    $('#thSpBuyer').text(currentLocale['ui_buyer'] || 'Buyer');
    $('#thSpVehicle').text(currentLocale['ui_vehicle'] || 'Vehicle');
    $('#thSpPrice').text(currentLocale['ui_price'] || 'Price');
    $('#thSpPayment').text(currentLocale['ui_payment'] || 'Payment');
    $('#thSpDate').text(currentLocale['ui_date'] || 'Date');
    $('#thPlate').text(currentLocale['ui_plate'] || 'Plate');
    $('#thSpPlate').text(currentLocale['ui_plate'] || 'Plate');
    $('#selectCustomerTitle').text(currentLocale['ui_select_customer'] || 'Select Customer');
    $('#paymentMethodTitle').text(currentLocale['ui_payment_method'] || 'Payment Method');
    $('#restockTitle').text(currentLocale['ui_restock'] || 'Restock');
    $('#importTitle').text(currentLocale['ui_import_vehicle'] || 'Import Vehicle');
    $('#changeVehicleTitle').text(currentLocale['ui_change_vehicle'] || 'Change Vehicle');
    $('#colorPickerTitle').text(currentLocale['ui_color_picker'] || 'Select Vehicle Color');
    $('#paymentCustomer').text((currentLocale['ui_customer'] || 'Customer') + ':');
    $('#paymentVehicle').text((currentLocale['ui_vehicle'] || 'Vehicle') + ':');
    $('#paymentPrice').text((currentLocale['ui_price'] || 'Price') + ':');
    $('#payCashText').text(currentLocale['ui_cash'] || 'Cash');
    $('#payBankText').text(currentLocale['ui_bank'] || 'Bank');
    $('#payGCText').text(currentLocale['ui_gold_coin'] || 'DE-Coin');
    $('#spPaymentVehicleLabel').text((currentLocale['ui_vehicle'] || 'Xe') + ':');
    $('#spPaymentPriceLabel').text((currentLocale['ui_price'] || 'Giá') + ':');
    $('#spPaymentGCPriceLabel').text((currentLocale['ui_gc_price'] || 'Giá DE-Coin') + ':');
    $('#spPaymentColorLabel').text((currentLocale['ui_color'] || 'Màu') + ':');
    $('#spPayCashText').text(currentLocale['ui_cash'] || 'Tiền Mặt');
    $('#spPayBankText').text(currentLocale['ui_bank'] || 'Ngân Hàng');
    $('#spPayGCText').text(currentLocale['ui_gold_coin'] || 'DE-Coin');
    $('#restockAmountLabel').text((currentLocale['ui_amount'] || 'Amount') + ':');
    $('#restockPriceLabel').text((currentLocale['ui_new_price'] || 'New Price') + ':');
    $('#restockGCPriceLabel').text((currentLocale['ui_gc_price'] || 'Giá DE-Coin') + ':');
    $('#importVehicleLabel').text((currentLocale['ui_vehicle_name'] || 'Vehicle Name') + ':');
    $('#importQuantityLabel').text((currentLocale['ui_quantity'] || 'Quantity') + ':');
    $('#importPriceLabel').text((currentLocale['ui_price'] || 'Price') + ':');
    $('#importGCPriceLabel').text((currentLocale['ui_gc_price'] || 'Giá DE-Coin') + ':');
    $('#confirmRestockText').text(currentLocale['ui_confirm'] || 'Confirm');
    $('#confirmImportText').text(currentLocale['ui_import'] || 'Import');
    $('#editPriceTitle').text(currentLocale['ui_edit_price'] || 'Thay Đổi Giá Xe');
    $('#editGCPriceTitle').text(currentLocale['ui_edit_gc_price'] || 'Thay Đổi Giá DE-Coin');
}

function refreshData(data) {
    currentData = data;
    buildRuntimeConfig(data);
    loadShowroomVehicles();
    applyInventoryFilters();
    loadStatistics();
}

function switchTab(tab) {
    $('.nav-btn').removeClass('active');
    $(`.nav-btn[data-tab="${tab}"]`).addClass('active');
    $('.tab-content').removeClass('active');
    $(`#${tab}Tab`).addClass('active');
}

function loadShowroomVehicles() {
    const grid = $('#showroomGrid');
    grid.empty();
    const shopConfig = Config.Shops[currentData.shop];
    if (!shopConfig) return;
    const slots = Object.keys(shopConfig.ShowroomVehicles).map(slot => parseInt(slot)).sort((a, b) => a - b);
    slots.forEach(slotNum => {
        const slotData = currentData.showroomVehicles['slot_' + slotNum];
        const vehicle = slotData?.vehicle;
        const color = slotData?.color || 0;
        const stock = getVehicleStock(vehicle);
        const price = getVehiclePrice(vehicle);
        const gcPrice = getVehicleGCPrice(vehicle);
        const colorName = getColorName(color);
        const stockItem = currentData.stock.find(s => s.vehicle === vehicle);
        const description = stockItem ? stockItem.description : '';
        const gcPriceDisplay = gcPrice > 0 ? ` / ${formatNumber(gcPrice)} DE-Coin` : '';
        const card = $(`
            <div class="showroom-card ${!vehicle ? 'empty' : ''}" data-slot="${slotNum}" data-vehicle="${vehicle || ''}" data-color="${color}" data-description="${escapeHtml(description || '')}">
                <div class="card-header">
                    <span class="slot-number">${currentLocale['ui_slot'] || 'Slot'} ${slotNum}</span>
                    ${vehicle ? `<span class="color-badge" style="background-color: ${getColorHex(color)};" title="${colorName}"></span>` : ''}
                </div>
                <div class="card-body">
                    <h3>${vehicle ? formatVehicleName(vehicle) : (currentLocale['ui_empty_slot'] || 'Empty Slot')}</h3>
                    ${vehicle ? `
                        <div class="card-info">
                            <div class="info-item"><span>${currentLocale['ui_stock'] || 'Stock'}:</span><span>${stock || 0}</span></div>
                            <div class="info-item"><span>${currentLocale['ui_price'] || 'Price'}:</span><span>$${formatMoney(price || 0)}${gcPriceDisplay}</span></div>
                            <div class="info-item"><span>${currentLocale['ui_color'] || 'Color'}:</span><span>${colorName}</span></div>
                        </div>
                        ${description ? `<div class="card-description-tooltip">${description}</div>` : ''}
                    ` : ''}
                </div>
            </div>
        `);
        card.click(function() {
            showVehicleModal(parseInt($(this).data('slot')), $(this).data('vehicle') || null, stock, price, gcPrice, parseInt($(this).data('color')) || 0);
        });
        grid.append(card);
    });
}

function loadInventory() {
    inventoryFilterState.filteredStock = currentData.stock || [];
    applyInventoryFilters();
}

function showEditPriceModal(vehicle, currentPrice) {
    selectedVehicle = vehicle;
    const vehicleInfo = currentData.stock.find(v => v.vehicle === vehicle);
    $('#editPriceVehicleName').text(vehicleInfo ? vehicleInfo.label : formatVehicleName(vehicle));
    $('#editPriceCurrentPrice').text('$' + formatMoney(currentPrice));
    $('#newPriceInput').val(currentPrice);
    $('#editPriceModal').addClass('active');
}

function showEditGCPriceModal(vehicle, currentGCPrice) {
    selectedVehicle = vehicle;
    const vehicleInfo = currentData.stock.find(v => v.vehicle === vehicle);
    $('#editGCPriceVehicleName').text(vehicleInfo ? vehicleInfo.label : formatVehicleName(vehicle));
    $('#editGCPriceCurrentPrice').text(formatNumber(currentGCPrice) + ' DE-Coin');
    $('#newGCPriceInput').val(currentGCPrice);
    $('#editGCPriceModal').addClass('active');
}

function showEditDescriptionModal(vehicle, currentDescription) {
    selectedVehicle = vehicle;
    const vehicleInfo = currentData.stock.find(v => v.vehicle === vehicle);
    $('#editDescriptionVehicleName').text(vehicleInfo ? vehicleInfo.label : formatVehicleName(vehicle));
    $('#newDescriptionInput').val(currentDescription || '');
    $('#editDescriptionModal').addClass('active');
}

function confirmEditPrice() {
    const newPrice = parseInt($('#newPriceInput').val());
    if (newPrice < 0) return;
    $.post('https://tommy-dealership/updateVehiclePrice', JSON.stringify({ vehicle: selectedVehicle, price: newPrice }), function(success) {
        if (success) {
            $('#editPriceModal').removeClass('active');
            const stockItem = currentData.stock.find(s => s.vehicle === selectedVehicle);
            if (stockItem) stockItem.price = newPrice;
            applyInventoryFilters();
        }
    });
}

function confirmEditGCPrice() {
    const newGCPrice = parseInt($('#newGCPriceInput').val()) || 0;
    if (newGCPrice < 0) return;
    $.post('https://tommy-dealership/updateVehicleGCPrice', JSON.stringify({ vehicle: selectedVehicle, gcPrice: newGCPrice }), function(success) {
        if (success) {
            $('#editGCPriceModal').removeClass('active');
            const stockItem = currentData.stock.find(s => s.vehicle === selectedVehicle);
            if (stockItem) stockItem.gcPrice = newGCPrice;
            applyInventoryFilters();
            loadShowroomVehicles();
        }
    });
}

function confirmEditDescription() {
    const newDescription = $('#newDescriptionInput').val().trim();
    $.post('https://tommy-dealership/updateVehicleDescription', JSON.stringify({ vehicle: selectedVehicle, description: newDescription }), function(success) {
        if (success) {
            $('#editDescriptionModal').removeClass('active');
            const stockItem = currentData.stock.find(s => s.vehicle === selectedVehicle);
            if (stockItem) stockItem.description = newDescription;
            applyInventoryFilters();
            loadShowroomVehicles();
        }
    });
}

function toggleSelfPurchase(vehicle, enabled) {
    $.post('https://tommy-dealership/toggleSelfPurchase', JSON.stringify({ vehicle: vehicle, enabled: enabled }), function(success) {
        if (success) { const stockItem = currentData.stock.find(s => s.vehicle === vehicle); if (stockItem) stockItem.allowSelfPurchase = enabled; }
        else { $(`.toggle-self-purchase[data-vehicle="${vehicle}"]`).prop('checked', !enabled); }
    });
}

function showRestockModalForVehicle(vehicle, price, gcPrice) {
    selectedVehicle = vehicle;
    $('#restockPrice').val(price || 0);
    $('#restockGCPrice').val(gcPrice || 0);
    $('#restockAmount').val(1);
    $('#restockModal').addClass('active');
}

function switchStatsTab(tab) {
    $('.stats-nav-btn').removeClass('active');
    $(`.stats-nav-btn[data-stats-tab="${tab}"]`).addClass('active');
    $('.stats-section').removeClass('active');
    if (tab === 'employee-sales') { $('#employeeSalesSection').addClass('active'); }
    else if (tab === 'self-purchases') { $('#selfPurchasesSection').addClass('active'); }
}

function loadStatistics() {
    if (currentData.playerGrade < 4) return;
    $('#totalSalesValue').text('$' + formatMoney(currentData.totalSales || 0));
    $('#totalCommissionValue').text('$' + formatMoney(currentData.totalCommission || 0));
    $('#totalSelfPurchaseValue').text('$' + formatMoney(currentData.totalSelfPurchase || 0));
    statisticsState.allSales = currentData.sales || [];
    statisticsState.allSelfPurchases = currentData.selfPurchases || [];
    statisticsState.salesDisplayCount = 10;
    statisticsState.selfPurchaseDisplayCount = 10;
    renderSalesTable();
    renderSelfPurchasesTable();
}

function renderSalesTable() {
    const tbody = $('#salesTableBody');
    tbody.empty();
    const sales = statisticsState.allSales;
    const displayCount = statisticsState.salesDisplayCount;
    if (!sales || sales.length === 0) {
        tbody.append(`<tr><td colspan="7" style="text-align: center; padding: 40px; color: rgba(255,255,255,0.5);">${currentLocale['ui_no_sales'] || 'No sales'}</td></tr>`);
        $('#salesLoadMoreContainer').hide();
        return;
    }
    sales.slice(0, displayCount).forEach(sale => {
        let priceDisplay = '$' + formatMoney(sale.price);
        if (sale.payment_type === 'gc') priceDisplay = formatNumber(sale.price) + ' DE-Coin';
        tbody.append($(`
            <tr>
                <td>${sale.seller_name}</td>
                <td>${sale.buyer_name}</td>
                <td>${formatVehicleName(sale.vehicle)}</td>
                <td>${sale.plate || 'N/A'}</td>
                <td>${priceDisplay}</td>
                <td>${sale.payment_type === 'gc' ? '-' : '$' + formatMoney(sale.commission)}</td>
                <td>${formatDate(sale.sold_at)}</td>
            </tr>
        `));
    });
    if (sales.length > displayCount) {
        $('#salesLoadMoreContainer').show();
        $('#salesLoadMoreText').text(`${currentLocale['ui_load_more'] || 'Xem Thêm'} (${sales.length - displayCount})`);
    } else { $('#salesLoadMoreContainer').hide(); }
}

function renderSelfPurchasesTable() {
    const tbody = $('#selfPurchaseTableBody');
    tbody.empty();
    const purchases = statisticsState.allSelfPurchases;
    const displayCount = statisticsState.selfPurchaseDisplayCount;
    if (!purchases || purchases.length === 0) {
        tbody.append(`<tr><td colspan="6" style="text-align: center; padding: 40px; color: rgba(255,255,255,0.5);">${currentLocale['ui_no_self_purchases'] || 'No self purchases'}</td></tr>`);
        $('#selfPurchaseLoadMoreContainer').hide();
        return;
    }
    purchases.slice(0, displayCount).forEach(purchase => {
        let paymentType = currentLocale['ui_cash'] || 'Cash';
        let priceDisplay = '$' + formatMoney(purchase.price);
        if (purchase.payment_type === 'bank') { paymentType = currentLocale['ui_bank'] || 'Bank'; }
        else if (purchase.payment_type === 'gc') { paymentType = currentLocale['ui_gold_coin'] || 'DE-Coin'; priceDisplay = formatNumber(purchase.price) + ' DE-Coin'; }
        tbody.append($(`
            <tr>
                <td>${purchase.buyer_name || 'Unknown'}</td>
                <td>${formatVehicleName(purchase.vehicle)}</td>
                <td>${purchase.plate || 'N/A'}</td>
                <td>${priceDisplay}</td>
                <td>${paymentType}</td>
                <td>${formatDate(purchase.purchased_at)}</td>
            </tr>
        `));
    });
    if (purchases.length > displayCount) {
        $('#selfPurchaseLoadMoreContainer').show();
        $('#selfPurchaseLoadMoreText').text(`${currentLocale['ui_load_more'] || 'Xem Thêm'} (${purchases.length - displayCount})`);
    } else { $('#selfPurchaseLoadMoreContainer').hide(); }
}

function showVehicleModal(slot, vehicle, stock, price, gcPrice, color) {
    selectedSlot = slot;
    selectedVehicle = vehicle;
    selectedColor = color || 0;
    const gcPriceDisplay = gcPrice > 0 ? ` / ${formatNumber(gcPrice)} DE-Coin` : '';
    $('#modalVehicleName').text(vehicle ? formatVehicleName(vehicle) : (currentLocale['ui_empty_slot'] || 'Empty Slot'));
    $('#modalStock').text(stock || 0);
    $('#modalPrice').text('$' + formatMoney(price || 0) + gcPriceDisplay);
    $('#modalColor').text(getColorName(selectedColor));
    if (vehicle && stock > 0) { $('#sellBtn, #testDriveBtn, #changeColorBtn').show(); }
    else { $('#sellBtn, #testDriveBtn, #changeColorBtn').hide(); }
    if (vehicle && currentData.playerGrade >= 4) { $('#restockBtn').show(); } else { $('#restockBtn').hide(); }
    $('#vehicleModal').addClass('active');
}

function showPlayerSelect() { currentAction = 'sell'; loadNearbyPlayers(); }
function showPlayerSelectForTest() { currentAction = 'test'; loadNearbyPlayers(); }

function loadNearbyPlayers() {
    $.post('https://tommy-dealership/getNearbyPlayers', JSON.stringify({}), function(players) {
        const list = $('#playerList');
        list.empty();
        if (players.length === 0) {
            list.append(`<div style="text-align: center; padding: 40px; color: rgba(255,255,255,0.5);"><p>No players nearby</p></div>`);
        } else {
            players.forEach(player => {
                const item = $(`<div class="player-item" data-id="${player.id}"><div><h4>${player.name}</h4><p>ID: ${player.id}</p></div></div>`);
                item.click(function() { selectPlayer(player); });
                list.append(item);
            });
        }
        $('#vehicleModal').removeClass('active');
        $('#playerModal').addClass('active');
    });
}

function selectPlayer(player) {
    selectedPlayer = player;
    if (currentAction === 'sell') { showPaymentModal(); }
    else if (currentAction === 'test') { startTestDrive(); }
}

function showPaymentModal() {
    const price = getVehiclePrice(selectedVehicle);
    const gcPrice = getVehicleGCPrice(selectedVehicle);
    $('#paymentCustomerName').text(selectedPlayer.name);
    $('#paymentVehicleName').text(formatVehicleName(selectedVehicle));
    $('#paymentPriceValue').text('$' + formatMoney(price));
    $('#paymentGCPriceValue').text(gcPrice > 0 ? formatNumber(gcPrice) + ' DE-Coin' : 'N/A');
    if (gcPrice > 0) { $('#payGCBtn').show(); } else { $('#payGCBtn').hide(); }
    $('#playerModal').removeClass('active');
    $('#paymentModal').addClass('active');
    $('#payCashBtn').off('click').on('click', function() { processSale('cash'); });
    $('#payBankBtn').off('click').on('click', function() { processSale('bank'); });
    $('#payGCBtn').off('click').on('click', function() { processSale('gc'); });
}

function processSale(paymentType) {
    $.post('https://tommy-dealership/sellVehicle', JSON.stringify({ vehicle: selectedVehicle, targetId: selectedPlayer.id, paymentType: paymentType, slot: selectedSlot, color: selectedColor }), function(success) {
        if (success) { $('#paymentModal').removeClass('active'); closeTablet(); }
    });
}

function startTestDrive() {
    $.post('https://tommy-dealership/startTestDrive', JSON.stringify({ vehicle: selectedVehicle, targetId: selectedPlayer.id, slot: selectedSlot, color: selectedColor }), function(success) {
        if (success) { $('#playerModal').removeClass('active'); closeTablet(); }
    });
}

function showRestockModal() {
    const price = getVehiclePrice(selectedVehicle);
    const gcPrice = getVehicleGCPrice(selectedVehicle);
    $('#restockPrice').val(price || 0);
    $('#restockGCPrice').val(gcPrice || 0);
    $('#restockAmount').val(1);
    $('#vehicleModal').removeClass('active');
    $('#restockModal').addClass('active');
}

function confirmRestock() {
    const amount = parseInt($('#restockAmount').val());
    const price = parseInt($('#restockPrice').val());
    const gcPrice = parseInt($('#restockGCPrice').val()) || 0;
    if (amount < 1 || price < 0) return;
    $.post('https://tommy-dealership/restockVehicle', JSON.stringify({ vehicle: selectedVehicle, amount: amount, price: price, gcPrice: gcPrice, slot: selectedSlot }), function(success) {
        if (success) { $('#restockModal').removeClass('active'); }
    });
}

function showImportModal() {
    $('#importVehicleName').val('');
    $('#importQuantity').val(1);
    $('#importPrice').val(0);
    $('#importGCPrice').val(0);
    $('#importDescription').val('');
    $('#importModal').addClass('active');
}

function confirmImport() {
    const vehicle = $('#importVehicleName').val().trim().toLowerCase();
    const quantity = parseInt($('#importQuantity').val());
    const price = parseInt($('#importPrice').val());
    const gcPrice = parseInt($('#importGCPrice').val()) || 0;
    if (!vehicle || quantity < 1 || price < 0) return;
    $.post('https://tommy-dealership/importVehicle', JSON.stringify({ vehicle: vehicle, quantity: quantity, price: price, gcPrice: gcPrice, description: $('#importDescription').val().trim() }), function(success) {
        if (success) { $('#importModal').removeClass('active'); }
    });
}

function showChangeVehicleModal() {
    const list = $('#vehicleSelectList');
    list.empty();
    $('#changeVehicleSearch').val('');
    $('#clearChangeVehicleSearch').hide();
    if (!currentData.stock || currentData.stock.length === 0) {
        list.append(`<div style="text-align: center; padding: 40px; color: rgba(255,255,255,0.5);"><p>${currentLocale['ui_no_sales'] || 'No items'}</p></div>`);
    } else {
        list.data('allVehicles', currentData.stock.filter(item => item.stock > 0));
        renderChangeVehicleList(list.data('allVehicles'));
    }
    $('#vehicleModal').removeClass('active');
    $('#changeVehicleModal').addClass('active');
}

function filterChangeVehicleList(searchText) {
    const list = $('#vehicleSelectList');
    const allVehicles = list.data('allVehicles') || [];
    if (!searchText || searchText.length === 0) { renderChangeVehicleList(allVehicles); return; }
    renderChangeVehicleList(allVehicles.filter(item => (item.label || '').toLowerCase().includes(searchText) || (item.vehicle || '').toLowerCase().includes(searchText)));
}

function renderChangeVehicleList(vehicles) {
    const list = $('#vehicleSelectList');
    list.empty();
    if (!vehicles || vehicles.length === 0) {
        list.append(`<div style="text-align: center; padding: 40px; color: rgba(255,255,255,0.5);"><p>${currentLocale['ui_no_results'] || 'Không tìm thấy kết quả'}</p></div>`);
        return;
    }
    vehicles.forEach(item => {
        const gcPriceDisplay = item.gcPrice > 0 ? ` / ${formatNumber(item.gcPrice)} DE-Coin` : '';
        const selectItem = $(`
            <div class="vehicle-select-item" data-vehicle="${item.vehicle}">
                <div class="vehicle-select-info">
                    <h4>${item.label || formatVehicleName(item.vehicle)}</h4>
                    <p>${item.vehicle} - $${formatMoney(item.price)}${gcPriceDisplay}</p>
                </div>
                <span class="vehicle-select-stock">${item.stock} ${currentLocale['ui_available'] || 'Available'}</span>
            </div>
        `);
        selectItem.click(function() { changeShowroomVehicle(item.vehicle); });
        list.append(selectItem);
    });
}

function changeShowroomVehicle(vehicle) {
    $.post('https://tommy-dealership/changeShowroomVehicle', JSON.stringify({ slot: selectedSlot, vehicle: vehicle }), function(success) {
        if (success) { $('#changeVehicleModal').removeClass('active'); }
    });
}

function showColorPickerModal() {
    const grid = $('#colorGrid');
    grid.empty();
    currentColors.forEach(colorData => {
        const colorItem = $(`
            <div class="color-item" data-colorindex="${colorData.colorindex}" title="${colorData.name}">
                <div class="color-preview" style="background-color: ${getColorHex(colorData.colorindex)};"></div>
                <span class="color-name">${colorData.name}</span>
            </div>
        `);
        colorItem.click(function() { changeShowroomColor(colorData.colorindex); });
        grid.append(colorItem);
    });
    $('#vehicleModal').removeClass('active');
    $('#colorPickerModal').addClass('active');
}

function changeShowroomColor(colorIndex) {
    $.post('https://tommy-dealership/changeShowroomColor', JSON.stringify({ slot: selectedSlot, color: colorIndex }), function(success) {
        if (success) { $('#colorPickerModal').removeClass('active'); }
    });
}

function clearShowroomSlot() {
    $.post('https://tommy-dealership/clearShowroomSlot', JSON.stringify({ slot: selectedSlot }), function(success) {
        if (success) { $('#vehicleModal').removeClass('active'); }
    });
}

function getVehicleStock(vehicle) {
    if (!vehicle || !currentData.stock) return 0;
    const item = currentData.stock.find(s => s.vehicle === vehicle);
    return item ? item.stock : 0;
}

function getVehiclePrice(vehicle) {
    if (!vehicle || !currentData.stock) return 0;
    const item = currentData.stock.find(s => s.vehicle === vehicle);
    return item ? item.price : 0;
}

function getVehicleGCPrice(vehicle) {
    if (!vehicle || !currentData.stock) return 0;
    const item = currentData.stock.find(s => s.vehicle === vehicle);
    return item ? (item.gcPrice || 0) : 0;
}

function getColorName(colorIndex) {
    if (!currentColors || currentColors.length === 0) return 'Unknown';
    const color = currentColors.find(c => c.colorindex === colorIndex);
    return color ? color.name : 'Unknown';
}

function getColorHex(colorIndex) {
    const colorMap = {
        0: '#000000', 1: '#1C1C1C', 2: '#323232', 3: '#454545', 4: '#999999',
        5: '#ABABAB', 6: '#B3B3B3', 7: '#C8C8C8', 8: '#CECECE', 9: '#707070',
        10: '#575757', 11: '#2E2E2E', 27: '#FF0000', 28: '#E60000', 29: '#CC0000',
        30: '#B30000', 31: '#990000', 32: '#800000', 33: '#660000', 34: '#4D0000',
        35: '#FF6347', 61: '#00008B', 62: '#0000CD', 63: '#0000FF', 64: '#1E90FF',
        65: '#4169E1', 66: '#6495ED', 67: '#87CEEB', 68: '#87CEFA', 69: '#00BFFF',
        70: '#5F9EA0', 71: '#8B008B', 72: '#9370DB', 88: '#FFFF00', 89: '#FFD700',
        90: '#CD7F32', 91: '#DAA520', 92: '#00FF00', 49: '#006400', 50: '#228B22',
        51: '#2E8B57', 52: '#556B2F', 53: '#00FF00', 54: '#7FFF00', 96: '#D2691E',
        97: '#8B4513', 98: '#A0522D', 99: '#FFD700', 100: '#8B7355', 101: '#8B4513',
        102: '#DEB887', 103: '#D2691E', 104: '#A0522D', 105: '#F4A460', 106: '#FFDEAD',
        107: '#FFFACD', 111: '#F0FFFF', 112: '#F8F8FF', 135: '#FF69B4', 136: '#FFA07A',
        137: '#FFB6C1', 138: '#FFA500', 141: '#191970', 142: '#4B0082', 143: '#722F37',
        145: '#8B00FF', 147: '#0C0C0C', 150: '#B22222'
    };
    return colorMap[colorIndex] || '#CCCCCC';
}

function formatVehicleName(vehicle) {
    if (!vehicle) return '';
    return vehicle.charAt(0).toUpperCase() + vehicle.slice(1);
}

function formatMoney(amount) {
    return amount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function formatNumber(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
}

function escapeHtml(text) {
    if (!text) return '';
    const map = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' };
    return text.replace(/[&<>"']/g, m => map[m]);
}

let Config = { Shops: {} };

function buildRuntimeConfig(data) {
    if (!data || !data.shop) return;
    const existing = Config.Shops[data.shop];
    if (existing && Object.keys(existing.ShowroomVehicles || {}).length > 0) return;
    const slots = {};
    Object.keys(data.showroomVehicles || {}).forEach(key => {
        const n = parseInt(key.replace('slot_', ''));
        if (!isNaN(n)) slots[n] = {};
    });
    if (Object.keys(slots).length === 0) { for (let i = 1; i <= 10; i++) slots[i] = {}; }
    Config.Shops[data.shop] = { ShopLabel: data.shopLabel || data.shop, ShowroomVehicles: slots };
}