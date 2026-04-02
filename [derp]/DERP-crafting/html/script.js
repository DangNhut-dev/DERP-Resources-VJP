const IMG_BASE = 'nui://ox_inventory/web/images/';
const IMG_FALLBACK = IMG_BASE + 'placeholder.png';

let currentRecipes   = {};
let currentInventory = {};
let selectedRecipe   = null;
let craftingInterval = null;
let isCrafting       = false;

// ── Messages from client ──

window.addEventListener('message', function(event) {
    const data = event.data;
    switch (data.action) {
        case 'openCrafting':   openCrafting(data);                                                    break;
        case 'updateInventory': updateInventory(data.inventory);                                      break;
        case 'startCrafting':  startCraftingProgress(data.itemName, data.itemLabel, data.craftTime, data.quantity); break;
        case 'stopCrafting':   stopCraftingProgress();                                                break;
        case 'forceClosed':    stopCraftingProgress(); closeCrafting();                               break;
    }
});

// ── Helpers ──

function imgSrc(name) {
    return IMG_BASE + name + '.png';
}

function imgTag(name, alt) {
    return '<img src="' + imgSrc(name) + '" onerror="this.src=\'' + IMG_FALLBACK + '\'" alt="' + (alt || name) + '">';
}

// Recipe image: dung customImage neu co, fallback ve ox_inventory images
function recipeImgTag(recipe) {
    var src = recipe.image || imgSrc(recipe.itemName || '');
    return '<img src="' + src + '" onerror="this.src=\'' + IMG_FALLBACK + '\'" alt="' + (recipe.label || '') + '">';
}

function checkCanCraft(recipe) {
    for (const [name, amount] of Object.entries(recipe.ingredients)) {
        if ((currentInventory[name]?.amount || 0) < amount) return false;
    }
    return true;
}

// ── Open / Close ──

function openCrafting(data) {
    currentRecipes   = data.recipes;
    currentInventory = data.inventory;
    selectedRecipe   = null;
    isCrafting       = false;

    $('#bench-title').text(data.benchLabel.toUpperCase());
    $('#crafting-container').removeClass('hidden');

    renderRecipes();
    clearDetails();
}

function closeCrafting() {
    if (isCrafting) return;
    stopCraftingProgress();
    $('#crafting-container').addClass('hidden');
    $.post('https://DERP-crafting/close', JSON.stringify({}));
}

// ── Render recipes ──

function renderRecipes() {
    const recipesList = $('#recipes-list');
    recipesList.empty();

    const sorted = Object.entries(currentRecipes)
        .map(([itemName, recipe]) => ({ itemName, ...recipe }))
        .sort((a, b) => (a.id || 999) - (b.id || 999));

    sorted.forEach(recipe => {
        const canCraft = checkCanCraft(recipe);
        recipesList.append(
            '<div class="recipe-item" data-item="' + recipe.itemName + '" data-can-craft="' + canCraft + '">' +
                '<div class="recipe-image">' + recipeImgTag(recipe) + '</div>' +
                '<div class="recipe-info">' +
                    '<h3>' + recipe.label + '</h3>' +
                '</div>' +
            '</div>'
        );
    });

    $('.recipe-item').on('click', function() {
        if (isCrafting) return;
        $('.recipe-item').removeClass('active');
        $(this).addClass('active');
        const itemName = $(this).data('item');
        selectedRecipe = itemName;
        showRecipeDetails(itemName, currentRecipes[itemName], checkCanCraft(currentRecipes[itemName]));
    });
}

// ── Recipe details ──

function showRecipeDetails(itemName, recipe, canCraft) {
    const allowQuantity = recipe.allowQuantity !== false;

    const quantityHtml = allowQuantity ?
        '<input type="number" id="craft-quantity" class="quantity-input-simple" value="1" min="1" max="999" placeholder="SL" ' +
        'onkeypress="return event.charCode >= 48 && event.charCode <= 57" ' +
        'oninput="validateQuantityInput(this)" ' +
        'onchange="updateIngredientAmounts(\'' + itemName + '\')">' : '';

    let ingredientsHtml = '';
    for (const [ingName, baseAmount] of Object.entries(recipe.ingredients)) {
        const playerAmount = currentInventory[ingName]?.amount || 0;
        const ingLabel     = currentInventory[ingName]?.label || ingName;
        const ingImage     = currentInventory[ingName]?.image || imgSrc(ingName);
        const hasEnough    = playerAmount >= baseAmount;

        ingredientsHtml +=
            '<div class="ingredient-item ' + (hasEnough ? 'has-enough' : 'not-enough') + '" ' +
                 'data-ingredient="' + ingName + '" data-base-amount="' + baseAmount + '">' +
                '<div class="ingredient-image">' +
                    '<img src="' + ingImage + '" onerror="this.src=\'' + IMG_FALLBACK + '\'" alt="' + ingLabel + '">' +
                '</div>' +
                '<div class="ingredient-info">' +
                    '<span class="ingredient-name">' + ingLabel + '</span>' +
                    '<span class="ingredient-amount ' + (hasEnough ? 'enough' : 'not-enough') + '" ' +
                           'data-player-amount="' + playerAmount + '">' +
                        playerAmount + '/<span class="required-amount">' + baseAmount + '</span>' +
                    '</span>' +
                '</div>' +
            '</div>';
    }

    $('#recipe-details').html(
        '<div class="detail-content">' +
            '<div class="detail-header">' +
                '<div class="detail-header-image">' + recipeImgTag(Object.assign({itemName}, recipe)) + '</div>' +
                '<div class="detail-header-info">' +
                    '<h3>' + recipe.label + '</h3>' +
                    quantityHtml +
                '</div>' +
            '</div>' +
            '<div class="ingredients-title">' +
                '<i class="fas fa-layer-group"></i>' +
                '<span>NGUYEN LIEU CAN THIET</span>' +
            '</div>' +
            '<div class="ingredients-list">' + ingredientsHtml + '</div>' +
            '<button class="craft-btn" onclick="craftItemWithQuantity(\'' + itemName + '\')" ' + (!canCraft ? 'disabled' : '') + '>' +
                '<i class="fas fa-hammer"></i>' +
                '<span id="craft-btn-text">' + (canCraft ? 'CHE TAO NGAY' : 'THIEU NGUYEN LIEU') + '</span>' +
            '</button>' +
        '</div>'
    );
}

function clearDetails() {
    $('#recipe-details').html(
        '<div class="no-selection">' +
            '<i class="fas fa-hand-pointer"></i>' +
            '<p>Chon mot cong thuc de xem chi tiet</p>' +
        '</div>'
    );
}

// ── Inventory update ──

function updateInventory(inventory) {
    currentInventory = inventory;
    renderRecipes();
    if (selectedRecipe && currentRecipes[selectedRecipe]) {
        showRecipeDetails(selectedRecipe, currentRecipes[selectedRecipe], checkCanCraft(currentRecipes[selectedRecipe]));
    }
}

// ── Quantity helpers ──

function validateQuantityInput(input) {
    input.value = input.value.replace(/[^0-9]/g, '');
    const v = parseInt(input.value);
    if (!v || v < 1) input.value = 1;
    if (v > 999)     input.value = 999;
    if (selectedRecipe) updateIngredientAmounts(selectedRecipe);
}

function updateIngredientAmounts(itemName) {
    const recipe = currentRecipes[itemName];
    if (!recipe) return;

    const quantity = parseInt($('#craft-quantity').val()) || 1;
    if (quantity < 1 || quantity > 999) { $('#craft-quantity').val(1); return; }

    let allEnough = true;

    $('.ingredient-item').each(function() {
        const baseAmount   = $(this).data('base-amount');
        const playerAmount = $(this).find('.ingredient-amount').data('player-amount');
        const required     = baseAmount * quantity;
        const hasEnough    = playerAmount >= required;
        if (!hasEnough) allEnough = false;

        $(this).toggleClass('has-enough', hasEnough).toggleClass('not-enough', !hasEnough);
        $(this).find('.ingredient-amount')
               .toggleClass('enough', hasEnough).toggleClass('not-enough', !hasEnough)
               .find('.required-amount').text(required);
    });

    $('.craft-btn').prop('disabled', !allEnough);
    $('#craft-btn-text').text(allEnough ? 'CHE TAO NGAY' : 'THIEU NGUYEN LIEU');
}

// ── Craft ──

function craftItemWithQuantity(itemName) {
    const recipe = currentRecipes[itemName];
    if (!recipe) return;

    const allowQuantity = recipe.allowQuantity !== false;
    const quantity = allowQuantity ? (parseInt($('#craft-quantity').val()) || 1) : 1;

    if (quantity < 1 || quantity > 999) return;

    for (const [ingName, baseAmount] of Object.entries(recipe.ingredients)) {
        if ((currentInventory[ingName]?.amount || 0) < baseAmount * quantity) return;
    }

    $.post('https://DERP-crafting/craftItem', JSON.stringify({ itemName, quantity }));
}

// ── Crafting progress ──

function startCraftingProgress(itemName, itemLabel, craftTime, quantity) {
    isCrafting = true;
    $('.crafting-content').addClass('blurred');
    $('#crafting-overlay').removeClass('hidden');

    const quantityText = quantity > 1 ? ' (x' + quantity + ')' : '';
    $('#crafting-item-label').text('Dang che tao ' + itemLabel + quantityText);

    let timeElapsed = 0;
    $('#crafting-timer-text').text((craftTime / 1000).toFixed(1) + 's');
    if (craftingInterval) clearInterval(craftingInterval);

    craftingInterval = setInterval(function() {
        timeElapsed += 100;
        const timeLeft = Math.max(0, (craftTime - timeElapsed) / 1000);
        $('#crafting-timer-text').text(timeLeft.toFixed(1) + 's');
        $('#progress-bar').css('width', Math.min(100, (timeElapsed / craftTime) * 100) + '%');
        if (timeElapsed >= craftTime) clearInterval(craftingInterval);
    }, 100);
}

function stopCraftingProgress() {
    isCrafting = false;
    if (craftingInterval) { clearInterval(craftingInterval); craftingInterval = null; }
    $('.crafting-content').removeClass('blurred');
    $('#crafting-overlay').addClass('hidden');
    $('#progress-bar').css('width', '0%');
}

function cancelCrafting() {
    $.post('https://DERP-crafting/cancelCraft', JSON.stringify({}));
}

// ── ESC key ──

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape' && !isCrafting) closeCrafting();
});