// ==================== PLANT INFO FUNCTIONS ====================
let plantInfoInterval = null;

function showPlantInfo(data) {
    const plantInfo = document.getElementById('plantInfo');
    plantInfo.classList.remove('hidden');
    
    document.getElementById('seedNameHeader').textContent = `Thông Tin Cây`;
    updatePlantInfo(data);
}

function updatePlantInfo(data) {
    document.getElementById('seedName').textContent = data.seedName;
    
    const waterPercent = Math.round(data.waterLevel || 0);
    // document.getElementById('waterLevel').textContent = `${waterPercent}%`;
    document.getElementById('waterFill').style.width = `${waterPercent}%`;
    
    const waterFill = document.getElementById('waterFill');
    if (waterPercent > 60) {
        waterFill.style.background = 'linear-gradient(90deg, #00BFFF, #1E90FF)';
    } else if (waterPercent > 30) {
        waterFill.style.background = 'linear-gradient(90deg, #FFD700, #FFA500)';
    } else {
        waterFill.style.background = 'linear-gradient(90deg, #FF6347, #FF4500)';
    }
    
    const timeLeft = data.timeRemaining;
    const minutes = Math.floor(timeLeft / 60000);
    const seconds = Math.floor((timeLeft % 60000) / 1000);
    document.getElementById('timeRemaining').textContent = `${minutes}:${seconds.toString().padStart(2, '0')}`;
    
    const statusEl = document.getElementById('plantStatus');
    const waterWarning = document.getElementById('waterWarning');
    const waterDepletedWarning = document.getElementById('waterDepletedWarning');
    
    if (data.isWithered) {
        statusEl.textContent = 'Cây đã héo!';
        statusEl.style.color = '#8B4513';
        waterWarning.style.display = 'none';
        waterDepletedWarning.style.display = 'none';
    } else if (data.needsWater) {
        statusEl.textContent = 'Chờ tưới nước dinh dưỡng...';
        statusEl.style.color = '#FFA500';
        waterWarning.style.display = 'block';
        waterDepletedWarning.style.display = 'none';
    } else if (waterPercent <= 0) {
        statusEl.textContent = 'Hết nước dinh dưỡng - Tạm ngừng';
        statusEl.style.color = '#FF4500';
        waterWarning.style.display = 'none';
        waterDepletedWarning.style.display = 'block';
    } else if (data.isReady) {
        statusEl.textContent = 'Sẵn sàng thu hoạch!';
        statusEl.style.color = '#00FF00';
        waterWarning.style.display = 'none';
        waterDepletedWarning.style.display = 'none';
    } else {
        statusEl.textContent = 'Đang phát triển...';
        statusEl.style.color = '#FFD700';
        waterWarning.style.display = 'none';
        waterDepletedWarning.style.display = 'none';
    }
    
    const fertilizerBonus = document.getElementById('fertilizerBonus');
    if (data.hasFertilizer) {
        const bonusPercent = Math.round((data.fertilizerBonus || 0) * 100);
        document.getElementById('fertilizerPercent').textContent = bonusPercent;
        fertilizerBonus.style.display = 'flex';
    } else {
        fertilizerBonus.style.display = 'none';
    }
    
    const uvBonus = document.getElementById('uvBonus');
    if (data.hasUVLight) {
        const extraAmount = (data.harvestAmount || 0);
        document.getElementById('uvAmount').textContent = extraAmount;
        uvBonus.style.display = 'flex';
    } else {
        uvBonus.style.display = 'none';
    }
}

function closePlantInfo() {
    const plantInfo = document.getElementById('plantInfo');
    plantInfo.classList.add('hidden');
    if (plantInfoInterval) {
        clearInterval(plantInfoInterval);
        plantInfoInterval = null;
    }
    fetch(`https://${GetParentResourceName()}/closePlantInfo`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).catch(err => {});
}

// ==================== PROCESSING GAME FUNCTIONS ====================
let gameActive = false;
let circlePoints = [];
let isDrawing = false;
let circlesCompleted = 0;
let gameTimer = null;
let timeRemaining = 60;

function startProcessingGame(data) {
    const gameUI = document.getElementById('processingGame');
    gameUI.classList.remove('hidden');
    gameActive = true;
    circlesCompleted = 0;
    timeRemaining = data.totalTime / 1000;
    document.getElementById('circleCount').textContent = '0';
    document.getElementById('progressPercent').textContent = '0';
    document.getElementById('timeLeft').textContent = timeRemaining;
    document.getElementById('gameProgress').style.width = '0%';
    document.getElementById('dryProgress').style.background = 'conic-gradient(#90EE90 0%, #333 0%)';
    document.getElementById('dryProgress').textContent = '0%';
    document.getElementById('powerLight').classList.add('active');
    document.getElementById('heatLight').classList.add('active');
    initCanvas();
    startGameTimer(data.totalTime);
}

function initCanvas() {
    const canvas = document.getElementById('drawingCanvas');
    const ctx = canvas.getContext('2d');
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    canvas.onmousedown = (e) => {
        if (!gameActive) return;
        isDrawing = true;
        circlePoints = [];
        const rect = canvas.getBoundingClientRect();
        circlePoints.push({ x: e.clientX - rect.left, y: e.clientY - rect.top });
    };
    
    canvas.onmousemove = (e) => {
        if (!gameActive || !isDrawing) return;
        const rect = canvas.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;
        circlePoints.push({ x, y });
        ctx.strokeStyle = '#FF4500';
        ctx.lineWidth = 3;
        ctx.lineCap = 'round';
        ctx.lineJoin = 'round';
        if (circlePoints.length > 1) {
            ctx.beginPath();
            ctx.moveTo(circlePoints[circlePoints.length - 2].x, circlePoints[circlePoints.length - 2].y);
            ctx.lineTo(x, y);
            ctx.stroke();
        }
    };
    
    canvas.onmouseup = () => {
        if (!gameActive || !isDrawing) return;
        isDrawing = false;
        if (isCircleComplete(circlePoints)) {
            circlesCompleted++;
            updateGameProgress();
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            circlePoints = [];
            if (circlesCompleted >= 10) {
                endGame(true);
            }
        } else {
            setTimeout(() => {
                ctx.clearRect(0, 0, canvas.width, canvas.height);
                circlePoints = [];
            }, 500);
        }
    };
    
    canvas.onmouseleave = () => { isDrawing = false; };
}

function isCircleComplete(points) {
    if (points.length < 20) return false;
    const first = points[0];
    const last = points[points.length - 1];
    const distance = Math.sqrt(Math.pow(last.x - first.x, 2) + Math.pow(last.y - first.y, 2));
    if (distance > 50) return false;
    let totalAngle = 0;
    const center = getCenter(points);
    for (let i = 1; i < points.length; i++) {
        const angle1 = Math.atan2(points[i - 1].y - center.y, points[i - 1].x - center.x);
        const angle2 = Math.atan2(points[i].y - center.y, points[i].x - center.x);
        let diff = angle2 - angle1;
        if (diff > Math.PI) diff -= 2 * Math.PI;
        if (diff < -Math.PI) diff += 2 * Math.PI;
        totalAngle += diff;
    }
    const fullCircles = Math.abs(totalAngle) / (2 * Math.PI);
    return fullCircles >= 0.8;
}

function getCenter(points) {
    let sumX = 0, sumY = 0;
    points.forEach(p => { sumX += p.x; sumY += p.y; });
    return { x: sumX / points.length, y: sumY / points.length };
}

function updateGameProgress() {
    const percent = Math.floor((circlesCompleted / 10) * 100);
    document.getElementById('circleCount').textContent = circlesCompleted;
    document.getElementById('progressPercent').textContent = percent;
    document.getElementById('gameProgress').style.width = `${percent}%`;
    document.getElementById('dryProgress').style.background = `conic-gradient(#90EE90 ${percent}%, #333 ${percent}%)`;
    document.getElementById('dryProgress').textContent = `${percent}%`;
}
function startGameTimer(totalTime) {
    if (gameTimer) clearInterval(gameTimer);
    gameTimer = setInterval(() => {
        timeRemaining--;
        document.getElementById('timeLeft').textContent = timeRemaining;
        if (timeRemaining <= 0) {
            endGame(false);
        }
    }, 1000);
}

function endGame(success) {
    gameActive = false;
    isDrawing = false;
    if (gameTimer) {
        clearInterval(gameTimer);
        gameTimer = null;
    }
    document.getElementById('powerLight').classList.remove('active');
    document.getElementById('heatLight').classList.remove('active');
    setTimeout(() => {
        const gameUI = document.getElementById('processingGame');
        gameUI.classList.add('hidden');
        fetch(`https://${GetParentResourceName()}/finishProcessing`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ success: success })
        });
    }, 1000);
}

function closeProcessingGame() {
    endGame(false);
}

// ==================== DRYING SYSTEM ====================
let currentRackId = null;
let selectedBuds = {};
let originalBudsAmount = {};

function openDryingUI(data) {
    currentRackId = data.rackId;
    selectedBuds = {};
    originalBudsAmount = {};
    const dryingUI = document.getElementById('dryingStation');
    dryingUI.classList.remove('hidden');
    populateBudsList(data.buds);
    updateDryingGrid();
    SetNuiFocus(true, true);
}

function populateBudsList(buds) {
    const budsList = document.getElementById('budsList');
    budsList.innerHTML = '';
    if (!buds || buds.length === 0) {
        budsList.innerHTML = '<p class="empty-text">Không có cần để phơi</p>';
        return;
    }
    buds.forEach(bud => {
        originalBudsAmount[bud.name] = bud.amount;
        const budEl = document.createElement('div');
        budEl.className = 'bud-item';
        budEl.dataset.name = bud.name;
        budEl.dataset.label = bud.label;
        budEl.innerHTML = `
            <img src="https://cfx-nui-ox_inventory/web/images/${bud.image}" alt="${bud.label}" draggable="false">
            <div class="bud-info">
                <div class="bud-name">${bud.label}</div>
                <div class="bud-count">x${bud.amount}</div>
            </div>
        `;
        budEl.addEventListener('click', function() {
            const budName = this.dataset.name;
            const originalAmount = originalBudsAmount[budName];
            const totalItems = Object.values(selectedBuds).reduce((sum, val) => sum + val, 0);
            if (totalItems >= 9) return;
            const alreadySelected = selectedBuds[budName] || 0;
            if (alreadySelected >= originalAmount) return;
            if (!selectedBuds[budName]) selectedBuds[budName] = 0;
            selectedBuds[budName]++;
            updateDryingGrid();
        });
        budsList.appendChild(budEl);
    });
}


// Hàm cập nhật hiển thị số lượng còn lại trong danh sách
function updateBudsListDisplay() {
    const budItems = document.querySelectorAll('.bud-item');
    budItems.forEach(item => {
        const budName = item.dataset.name;
        const originalAmount = originalBudsAmount[budName] || 0;
        const selectedAmount = selectedBuds[budName] || 0;
        const remainingAmount = originalAmount - selectedAmount;
        const countEl = item.querySelector('.bud-count');
        countEl.textContent = `x${remainingAmount}`;
        if (remainingAmount === 0) {
            item.style.opacity = '0.5';
            item.style.cursor = 'not-allowed';
        } else {
            item.style.opacity = '1';
            item.style.cursor = 'pointer';
        }
    });
}

function openBudQuantityModal(bud) {
    const modal = document.getElementById('budQuantityModal');
    const input = document.getElementById('budQuantityInput');
    const available = document.getElementById('budQuantityAvailable');
    const itemName = document.getElementById('budQuantityItemName');
    
    const alreadySelected = selectedBuds[bud.name] || 0;
    const maxCanAdd = bud.amount - alreadySelected;
    
    itemName.textContent = bud.label;
    available.textContent = maxCanAdd;
    input.value = Math.min(1, maxCanAdd);
    input.max = maxCanAdd;
    input.dataset.budName = bud.name;
    
    modal.classList.remove('hidden');
}

function closeBudQuantityModal() {
    const modal = document.getElementById('budQuantityModal');
    modal.classList.add('hidden');
}

function increaseBudQuantity() {
    const input = document.getElementById('budQuantityInput');
    const max = parseInt(input.max);
    const current = parseInt(input.value);
    
    if (current < max) {
        input.value = current + 1;
    }
}

function decreaseBudQuantity() {
    const input = document.getElementById('budQuantityInput');
    const current = parseInt(input.value);
    
    if (current > 1) {
        input.value = current - 1;
    }
}

function confirmBudQuantity() {
    const input = document.getElementById('budQuantityInput');
    const budName = input.dataset.budName;
    const quantity = parseInt(input.value);
    
    if (quantity > 0) {
        const totalItems = Object.values(selectedBuds).reduce((sum, val) => sum + val, 0);
        
        if (totalItems + quantity > 9) {
            alert('Bàn sấy chỉ có 9 ô! Không thể thêm nữa.');
            closeBudQuantityModal();
            return;
        }
        
        if (!selectedBuds[budName]) {
            selectedBuds[budName] = 0;
        }
        
        selectedBuds[budName] += quantity;
        
        updateDryingGrid();
        closeBudQuantityModal();
    }
}

function updateDryingGrid() {
    const grid = document.getElementById('dryingGrid');
    grid.innerHTML = '';
    let items = [];
    for (let budName in selectedBuds) {
        for (let i = 0; i < selectedBuds[budName]; i++) {
            items.push(budName);
        }
    }
    for (let i = 0; i < 9; i++) {
        const slot = document.createElement('div');
        slot.className = 'drying-slot';
        if (items[i]) {
            const budName = items[i];
            slot.innerHTML = `<img src="https://cfx-nui-ox_inventory/web/images/${budName}.png" alt="${budName}">`;
            slot.classList.add('filled');
            slot.addEventListener('click', function() {
                removeBudFromGrid(budName);
            });
        }
        grid.appendChild(slot);
    }
    const startBtn = document.getElementById('startDryingBtn');
    startBtn.disabled = items.length === 0;
    updateBudsListDisplay();
}

function removeBudFromGrid(budName) {
    if (selectedBuds[budName]) {
        selectedBuds[budName]--;
        if (selectedBuds[budName] <= 0) {
            delete selectedBuds[budName];
        }
        updateDryingGrid();
    }
}

function startDrying() {
    if (Object.keys(selectedBuds).length === 0) return;
    const items = [];
    for (let budName in selectedBuds) {
        items.push({ name: budName, amount: selectedBuds[budName] });
    }
    fetch(`https://${GetParentResourceName()}/startDrying`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ rackId: currentRackId, items: items })
    }).then(() => { closeDryingUI(); });
}

function closeDryingUI() {
    const dryingUI = document.getElementById('dryingStation');
    dryingUI.classList.add('hidden');
    selectedBuds = {};
    originalBudsAmount = {};
    currentRackId = null;
    fetch(`https://${GetParentResourceName()}/closeDryingUI`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).catch(err => {});
}

// ==================== INFUSION SYSTEM ====================
let currentInfusionTableId = null;
let selectedBud = null;
let selectedIngredients = {};
let originalIngredientsAmount = {};
let originalIngredientsLabel = {};
let isInfusing = false;
let infusionTimer = null;

// Hàm mở UI tẩm
function openInfusionUI(data) {
    currentInfusionTableId = data.tableId;
    selectedBud = null;
    selectedIngredients = {};
    originalIngredientsLabel = {};
    originalIngredientsAmount = {};
    isInfusing = false;
    const infusionUI = document.getElementById('infusionStation');
    infusionUI.classList.remove('hidden');
    populateInfusionBudsList(data.buds);
    populateInfusionIngredientsList(data.ingredients);
    updateSelectedInfusionItems();
    SetNuiFocus(true, true);
}

// Hàm đóng UI tẩm
function closeInfusionUI() {
    const infusionUI = document.getElementById('infusionStation');
    infusionUI.classList.add('hidden');
    if (infusionTimer) {
        clearInterval(infusionTimer);
        infusionTimer = null;
    }
    selectedBud = null;
    selectedIngredients = {};
    originalIngredientsLabel = {};
    originalIngredientsAmount = {};
    isInfusing = false;
    currentInfusionTableId = null;
    const overlay = document.getElementById('infusionOverlay');
    overlay.classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/closeInfusionUI`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).catch(err => {});
}

// Hàm hiển thị danh sách loại cần
function populateInfusionBudsList(buds) {
    const budsList = document.getElementById('infusionBudsList');
    budsList.innerHTML = '';
    if (!buds || buds.length === 0) {
        budsList.innerHTML = '<p class="empty-text">Không có cần khô</p>';
        return;
    }
    buds.forEach(bud => {
        const budEl = document.createElement('div');
        budEl.className = 'infusion-bud-item';
        budEl.dataset.name = bud.name;
        budEl.dataset.label = bud.label;
        budEl.innerHTML = `
            <img src="https://cfx-nui-ox_inventory/web/images/${bud.image}" alt="${bud.label}" draggable="false">
            <div class="bud-info">
                <div class="bud-name">${bud.label}</div>
                <div class="bud-count">x${bud.amount}</div>
            </div>
        `;
        budEl.addEventListener('click', function() {
            if (isInfusing) return;
            document.querySelectorAll('.infusion-bud-item').forEach(el => {
                el.classList.remove('selected');
            });
            this.classList.add('selected');
            selectedBud = {
                name: this.dataset.name,
                label: this.dataset.label,
                amount: parseInt(bud.amount)
            };
            updateSelectedInfusionItems();
        });
        budsList.appendChild(budEl);
    });
}

// Hàm hiển thị danh sách nguyên liệu
function populateInfusionIngredientsList(ingredients) {
    const ingredientsList = document.getElementById('infusionIngredientsList');
    ingredientsList.innerHTML = '';
    if (!ingredients || ingredients.length === 0) {
        ingredientsList.innerHTML = '<p class="empty-text">Không có nguyên liệu</p>';
        return;
    }
    ingredients.forEach(ingredient => {
        originalIngredientsAmount[ingredient.name] = ingredient.amount;
        originalIngredientsLabel[ingredient.name] = ingredient.label;
        const ingredientEl = document.createElement('div');
        ingredientEl.className = 'infusion-ingredient-item';
        ingredientEl.dataset.name = ingredient.name;
        ingredientEl.dataset.label = ingredient.label;
        ingredientEl.innerHTML = `
            <img src="https://cfx-nui-ox_inventory/web/images/${ingredient.image}" alt="${ingredient.label}" draggable="false">
            <div class="ingredient-info">
                <div class="ingredient-name">${ingredient.label}</div>
                <div class="ingredient-count">x${ingredient.amount}</div>
            </div>
        `;
        ingredientEl.addEventListener('click', function() {
            if (isInfusing) return;
            const itemName = this.dataset.name;
            const itemLabel = this.dataset.label;
            const originalAmount = originalIngredientsAmount[itemName];
            const alreadySelected = selectedIngredients[itemName] || 0;
            
            // Kiểm tra đã chọn hết chưa
            if (alreadySelected >= originalAmount) return;
            
            // Thêm 1 item
            if (!selectedIngredients[itemName]) {
                selectedIngredients[itemName] = 0;
            }
            selectedIngredients[itemName]++;
            updateSelectedInfusionItems();
        });
        ingredientsList.appendChild(ingredientEl);
    });
}

// Hàm mở modal chọn số lượng
let currentInfusionItem = null;

function openInfusionQuantityModal(itemName, itemLabel, maxAmount) {
    currentInfusionItem = { name: itemName, label: itemLabel, max: maxAmount };
    const modal = document.getElementById('infusionQuantityModal');
    const input = document.getElementById('infusionQuantityInput');
    const available = document.getElementById('infusionQuantityAvailable');
    const title = document.getElementById('infusionQuantityTitle');
    title.textContent = itemLabel;
    available.textContent = maxAmount;
    const alreadySelected = selectedIngredients[itemName] || 0;
    const canAdd = maxAmount - alreadySelected;
    input.value = Math.min(1, canAdd);
    input.max = canAdd;
    modal.classList.remove('hidden');
}

function closeInfusionQuantityModal() {
    const modal = document.getElementById('infusionQuantityModal');
    modal.classList.add('hidden');
    currentInfusionItem = null;
}

function increaseInfusionQuantity() {
    const input = document.getElementById('infusionQuantityInput');
    const max = parseInt(input.max);
    const current = parseInt(input.value);
    if (current < max) {
        input.value = current + 1;
    }
}

function decreaseInfusionQuantity() {
    const input = document.getElementById('infusionQuantityInput');
    const current = parseInt(input.value);
    if (current > 1) {
        input.value = current - 1;
    }
}

function confirmInfusionQuantity() {
    if (!currentInfusionItem) return;
    const input = document.getElementById('infusionQuantityInput');
    const quantity = parseInt(input.value);
    if (quantity > 0) {
        if (!selectedIngredients[currentInfusionItem.name]) {
            selectedIngredients[currentInfusionItem.name] = 0;
        }
        selectedIngredients[currentInfusionItem.name] += quantity;
        updateSelectedInfusionItems();
        closeInfusionQuantityModal();
    }
}

// Hàm cập nhật hiển thị nguyên liệu đã chọn
function updateSelectedInfusionItems() {
    const selectedBudEl = document.getElementById('selectedInfusionBud');
    const selectedIngredientsEl = document.getElementById('selectedInfusionIngredients');
    const mixBtn = document.getElementById('mixInfusionBtn');
    if (selectedBud) {
        selectedBudEl.innerHTML = `
            <div class="selected-item">
                <img src="https://cfx-nui-ox_inventory/web/images/${selectedBud.name}.png" alt="${selectedBud.label}">
                <span>${selectedBud.label} x1</span>
                <button onclick="removeSelectedBud()">✕</button>
            </div>
        `;
    } else {
        selectedBudEl.innerHTML = '<p class="empty-text">Chưa chọn loại cần</p>';
    }
    if (Object.keys(selectedIngredients).length > 0) {
        selectedIngredientsEl.innerHTML = '';
        for (let itemName in selectedIngredients) {
            const amount = selectedIngredients[itemName];
            const itemEl = document.createElement('div');
            itemEl.className = 'selected-item';
            const label = originalIngredientsLabel[itemName] || itemName;
            itemEl.innerHTML = `
                <img src="https://cfx-nui-ox_inventory/web/images/${itemName}.png" alt="${label}">
                <span>${label} x${amount}</span>
                <button onclick="removeSelectedIngredient('${itemName}')">✕</button>
            `;
            selectedIngredientsEl.appendChild(itemEl);
        }
    } else {
        selectedIngredientsEl.innerHTML = '<p class="empty-text">Chưa có nguyên liệu</p>';
    }
    const canMix = selectedBud && Object.keys(selectedIngredients).length > 0;
    mixBtn.disabled = !canMix;
    updateInfusionIngredientsDisplay();
}

function updateInfusionIngredientsDisplay() {
    const ingredientItems = document.querySelectorAll('.infusion-ingredient-item');
    ingredientItems.forEach(item => {
        const itemName = item.dataset.name;
        const originalAmount = originalIngredientsAmount[itemName] || 0;
        const selectedAmount = selectedIngredients[itemName] || 0;
        const remainingAmount = originalAmount - selectedAmount;
        const countEl = item.querySelector('.ingredient-count');
        countEl.textContent = `x${remainingAmount}`;
        if (remainingAmount === 0) {
            item.style.opacity = '0.5';
            item.style.cursor = 'not-allowed';
        } else {
            item.style.opacity = '1';
            item.style.cursor = 'pointer';
        }
    });
}

function removeSelectedBud() {
    if (isInfusing) return;
    selectedBud = null;
    document.querySelectorAll('.infusion-bud-item').forEach(el => {
        el.classList.remove('selected');
    });
    updateSelectedInfusionItems();
}

function removeSelectedIngredient(itemName) {
    if (isInfusing) return;
    delete selectedIngredients[itemName];
    updateSelectedInfusionItems();
}

// Hàm bắt đầu trộn
function startInfusionMixing() {
    if (!selectedBud || Object.keys(selectedIngredients).length === 0) return;
    if (isInfusing) return;
    isInfusing = true;
    fetch(`https://${GetParentResourceName()}/startInfusion`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            budType: selectedBud.name,
            budAmount: 1,
            ingredients: selectedIngredients
        })
    });
    const overlay = document.getElementById('infusionOverlay');
    overlay.classList.remove('hidden');
    document.getElementById('infusionTimerValue').textContent = '0.0s';
    document.getElementById('infusionTimerHint').textContent = 'Đang trộn... Bấm "Dừng" khi muốn lấy kết quả.';
}

// Hàm dừng trộn
function stopInfusionMixing() {
    if (!isInfusing) return;
    fetch(`https://${GetParentResourceName()}/stopInfusion`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

// Hàm cập nhật thời gian từ client
function updateInfusionTime(time) {
    const timerValue = document.getElementById('infusionTimerValue');
    timerValue.textContent = time.toFixed(1) + 's';
}

// ==================== EVENT LISTENERS ====================
window.addEventListener('message', (event) => {
    const data = event.data;
    switch(data.action) {
        case 'showPlantInfo':
            showPlantInfo(data.plantData);
            break;
        case 'updatePlantInfo':
            updatePlantInfo(data.plantData);
            break;
        case 'updateTimeOnly':
            const minutes = Math.floor(data.timeRemaining / 60000);
            const seconds = Math.floor((data.timeRemaining % 60000) / 1000);
            document.getElementById('timeRemaining').textContent = `${minutes}:${seconds.toString().padStart(2, '0')}`;
            break;
        case 'updateWaterOnly':
            const waterPercent = Math.round(data.waterLevel || 0);
            // document.getElementById('waterLevel').textContent = `${waterPercent}%`;
            document.getElementById('waterFill').style.width = `${waterPercent}%`;
            const waterFill = document.getElementById('waterFill');
            if (waterPercent > 60) {
                waterFill.style.background = 'linear-gradient(90deg, #00BFFF, #1E90FF)';
            } else if (waterPercent > 30) {
                waterFill.style.background = 'linear-gradient(90deg, #FFD700, #FFA500)';
            } else {
                waterFill.style.background = 'linear-gradient(90deg, #FF6347, #FF4500)';
            }
            break;
        case 'closePlantInfo':
            closePlantInfo();
            break;
        case 'startProcessing':
            startProcessingGame(data);
            break;
        case 'closeProcessing':
            closeProcessingGame();
            break;
        case 'openDryingUI':
            openDryingUI(data);
            break;
        case 'closeDryingUI':
            closeDryingUI();
            break;
        case 'openInfusionUI':
            openInfusionUI(data);
            break;
        case 'closeInfusionUI':
            closeInfusionUI();
            break;
        case 'updateInfusionTime':
            updateInfusionTime(data.time);
            break;
    }
});

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        const plantInfo = document.getElementById('plantInfo');
        const processingGame = document.getElementById('processingGame');
        const dryingStation = document.getElementById('dryingStation');
        const budQuantityModal = document.getElementById('budQuantityModal');
        const infusionStation = document.getElementById('infusionStation');
        const infusionModal = document.getElementById('infusionQuantityModal');
        
        if (!plantInfo.classList.contains('hidden')) {
            closePlantInfo();
        }
        
        if (!processingGame.classList.contains('hidden')) {
            closeProcessingGame();
        }
        
        if (!dryingStation.classList.contains('hidden')) {
            closeDryingUI();
        }
        
        if (!budQuantityModal.classList.contains('hidden')) {
            closeBudQuantityModal();
        }
        
        if (!infusionStation.classList.contains('hidden')) {
            closeInfusionUI();
        }
        
        if (!infusionModal.classList.contains('hidden')) {
            closeInfusionQuantityModal();
        }
    }
});