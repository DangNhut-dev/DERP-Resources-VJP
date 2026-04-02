-- modules/crafting.lua
local isCrafting   = {}
local craftSession = {}

local function validatePlayer(source, businessKey)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false, 'Không tìm thấy người chơi' end

    local config = Config.Businesses[businessKey]
    if not config then return false, 'Cửa hàng không hợp lệ' end

    if player.PlayerData.job.name ~= config.job then
        return false, 'Bạn không làm việc tại đây'
    end

    if not player.PlayerData.job.onduty then
        return false, 'Bạn chưa bắt đầu ca làm việc'
    end

    return true, nil
end

local function consumeIngredients(source, recipe, qty)
    for itemName, count in pairs(recipe) do
        local need = count * qty
        local has  = exports.ox_inventory:GetItemCount(source, itemName)
        if not has or has < need then
            return false, 'Không đủ nguyên liệu, thiếu: ' .. itemName
        end
    end
    for itemName, count in pairs(recipe) do
        exports.ox_inventory:RemoveItem(source, itemName, count * qty)
    end
    return true, nil
end

local function refundIngredients(source, recipe, remaining)
    if remaining <= 0 then return end
    for itemName, count in pairs(recipe) do
        exports.ox_inventory:AddItem(source, itemName, count * remaining)
    end
end

-- craftIndex: index của bàn trong config.crafts (1-based)
-- itemKey: key của item trong bàn đó
RegisterNetEvent('DERP-business:craft', function(businessKey, craftIndex, itemKey, qty)
    local source = source

    if type(businessKey) ~= 'string' or type(itemKey) ~= 'string' then return end
    if type(craftIndex) ~= 'number' or craftIndex < 1 then return end
    if type(qty) ~= 'number' or qty < 1 or qty > 99 then return end
    qty        = math.floor(qty)
    craftIndex = math.floor(craftIndex)

    local config = Config.Businesses[businessKey]
    if not config then return end

    -- validate bàn tồn tại
    local craftZone = config.crafts[craftIndex]
    if not craftZone then return end

    -- validate item thuộc đúng bàn này
    local itemData = craftZone.items and craftZone.items[itemKey]
    if not itemData then return end

    if isCrafting[source] then
        TriggerClientEvent('DERP-business:craftFailed', source, 'Bạn đang trong quá trình chế biến')
        return
    end

    local valid, reason = validatePlayer(source, businessKey)
    if not valid then
        TriggerClientEvent('DERP-business:craftFailed', source, reason)
        return
    end

    -- validate player gần bàn chế biến
    local pCoords = GetEntityCoords(GetPlayerPed(source))
    local zCoords = craftZone.coords
    if #(pCoords - vector3(zCoords.x, zCoords.y, zCoords.z)) > ((craftZone.radius or 1.5) * 3.0) then
        TriggerClientEvent('DERP-business:craftFailed', source, 'Bạn không ở tại bàn chế biến')
        return
    end

    local ok, failReason = consumeIngredients(source, itemData.recipe, qty)
    if not ok then
        TriggerClientEvent('DERP-business:craftFailed', source, failReason)
        return
    end

    isCrafting[source]   = true
    craftSession[source] = {
        itemKey  = itemKey,
        itemData = itemData,
        total    = qty,
        done     = 0,
    }

    TriggerClientEvent('DERP-business:craftBatchStart', source,
        itemData.label, itemData.time, itemData.anim, qty, itemData.recipe, itemData.type)
end)

RegisterNetEvent('DERP-business:craftOneCompleted', function()
    local source  = source
    local session = craftSession[source]
    if not session then
        TriggerClientEvent('DERP-business:craftConfirmed', source, false)
        return
    end

    session.done = session.done + 1
    exports.ox_inventory:AddItem(source, session.itemKey, 1)

    if session.done >= session.total then
        isCrafting[source]   = nil
        craftSession[source] = nil
    end

    TriggerClientEvent('DERP-business:craftConfirmed', source, true)
end)

RegisterNetEvent('DERP-business:craftCancelled', function(completedCount)
    local source  = source
    local session = craftSession[source]
    if not session then return end

    if type(completedCount) ~= 'number' then completedCount = 0 end
    completedCount = math.max(0, math.min(math.floor(completedCount), session.total))

    local remaining = session.total - completedCount
    refundIngredients(source, session.itemData.recipe, remaining)

    isCrafting[source]   = nil
    craftSession[source] = nil
end)

AddEventHandler('playerDropped', function()
    local source  = source
    local session = craftSession[source]
    if session then
        refundIngredients(source, session.itemData.recipe, session.total - session.done)
    end
    isCrafting[source]   = nil
    craftSession[source] = nil
end)