-- Chấm công: trigger lại client để toggle state
RegisterNetEvent('pyh-lumberjack:Sign')
AddEventHandler('pyh-lumberjack:Sign', function()
    TriggerClientEvent('pyh-lumberjack:Sign', source)
end)

-- Thuê xe: trigger lại client
RegisterNetEvent('pyh-lumberjack:rentBison')
AddEventHandler('pyh-lumberjack:rentBison', function()
    TriggerClientEvent('pyh-lumberjack:rentBison', source)
end)

-- Mua rìu
RegisterNetEvent('pyh-lumberjack:buyAxe')
AddEventHandler('pyh-lumberjack:buyAxe', function()
    local src    = source
    local player = GetPlayer(src)
    if not player then return end

    local price = Config.axePrice
    local cash  = player.PlayerData.money['cash']

    if cash < price then
        Notify(src, 'Bạn không đủ tiền mua rìu!', 'error')
        return
    end

    if GetItemCount(src, 'axe') > 0 then
        Notify(src, 'Bạn đã có rìu rồi!', 'error')
        return
    end

    player.Functions.RemoveMoney('cash', price)
    AddItem(src, 'axe', 1)
    Notify(src, 'Bạn đã mua rìu với giá $' .. price, 'success')
end)

-- State machine cây: standing | fallen | gone
local treeStates = {}

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for i = 1, #Config.trees do
        treeStates[i] = 'standing'
    end
end)

RegisterNetEvent('pyh-lumberjack:chopTree')
AddEventHandler('pyh-lumberjack:chopTree', function(treeIdx)
    local src = source

    if type(treeIdx) ~= 'number' or treeIdx < 1 or treeIdx > #Config.trees then return end
    if not treeStates[treeIdx] then return end

    -- Validate có rìu
    if GetItemCount(src, 'axe') < 1 then
        Notify(src, 'Bạn cần rìu để chặt cây!', 'error')
        return
    end

    local state = treeStates[treeIdx]

    if state == 'standing' then
        -- Lần 1: cây ngã
        treeStates[treeIdx] = 'fallen'
        TriggerClientEvent('pyh-lumberjack:setTreeState', -1, treeIdx, 'fallen')

    elseif state == 'fallen' then
        -- Lần 2: validate weight trước khi cho log
        local logWeight  = Config.itemWeights['log'] or 0
        local _, freeWeight = exports.ox_inventory:CanCarryWeight(src, 0)
        freeWeight       = freeWeight or 0
        local canReceive = math.floor(freeWeight / logWeight)

        if canReceive <= 0 then
            Notify(src, 'Túi đồ quá nặng, không thể nhận gỗ!', 'error')
            return
        end

        local giveAmount = math.min(Config.logPerChop, canReceive)

        if AddItem(src, 'log', giveAmount) then
            Notify(src, 'Nhận được ' .. giveAmount .. ' ' .. Config.itemLabels['log'] .. '!', 'success')
        else
            Notify(src, 'Túi đồ đầy!', 'error')
            return
        end

        treeStates[treeIdx] = 'gone'
        TriggerClientEvent('pyh-lumberjack:setTreeState', -1, treeIdx, 'gone')

        SetTimeout(Config.treeCooldown, function()
            treeStates[treeIdx] = 'standing'
            TriggerClientEvent('pyh-lumberjack:setTreeState', -1, treeIdx, 'standing')
        end)
    end
end)

-- Tính số lượng tối đa có thể xử lý dựa trên weight còn trống
local function calcMaxProcessable(src, fromItem, toItem, multiplier)
    local count = GetItemCount(src, fromItem)
    if count <= 0 then return 0 end

    local wFrom         = Config.itemWeights[fromItem] or 0
    local wTo           = (Config.itemWeights[toItem] or 0) * multiplier
    local weightGainPerUnit = wTo - wFrom

    if weightGainPerUnit <= 0 then
        -- Output nhẹ hơn hoặc bằng input → xử lý tất cả
        return count
    end

    -- CanCarryWeight trả về: canCarry (bool), freeWeight (number)
    local _, freeWeight = exports.ox_inventory:CanCarryWeight(src, 0)
    freeWeight = freeWeight or 0

    local maxByWeight = math.floor(freeWeight / weightGainPerUnit)
    return math.min(count, math.max(0, maxByWeight))
end

-- Client yêu cầu xử lý → server tính amount → trả về client để hiện progressbar
RegisterNetEvent('pyh-lumberjack:requestProcess')
AddEventHandler('pyh-lumberjack:requestProcess', function(processType)
    local src = source

    local fromItem, toItem, multiplier
    if processType == 'logs' then
        fromItem, toItem, multiplier = 'log', 'cleanlog', 1
    elseif processType == 'cleanLogs' then
        fromItem, toItem, multiplier = 'cleanlog', 'rawplank', Config.planksPerLog
    elseif processType == 'rawPlanks' then
        fromItem, toItem, multiplier = 'rawplank', 'sandedplank', 1
    elseif processType == 'sandedPlanks' then
        fromItem, toItem, multiplier = 'sandedplank', 'finishwood', 1
    else
        return
    end

    local amount = calcMaxProcessable(src, fromItem, toItem, multiplier)

    if amount <= 0 then
        local total = GetItemCount(src, fromItem)
        if total <= 0 then
            Notify(src, 'Bạn không có ' .. (Config.itemLabels[fromItem] or fromItem) .. ' để xử lý!', 'error')
        else
            Notify(src, 'Túi đồ không đủ chỗ để xử lý thêm!', 'error')
        end
        return
    end

    -- Trả về client để hiện progressbar
    TriggerClientEvent('pyh-lumberjack:startProcessBar', src, processType, amount)
end)

-- Client confirm sau khi progressbar xong → server thực sự xử lý
RegisterNetEvent('pyh-lumberjack:confirmProcess')
AddEventHandler('pyh-lumberjack:confirmProcess', function(processType, amount)
    local src = source
    if type(amount) ~= 'number' or amount <= 0 then return end

    local fromItem, toItem, multiplier
    if processType == 'logs' then
        fromItem, toItem, multiplier = 'log', 'cleanlog', 1
    elseif processType == 'cleanLogs' then
        fromItem, toItem, multiplier = 'cleanlog', 'rawplank', Config.planksPerLog
    elseif processType == 'rawPlanks' then
        fromItem, toItem, multiplier = 'rawplank', 'sandedplank', 1
    elseif processType == 'sandedPlanks' then
        fromItem, toItem, multiplier = 'sandedplank', 'finishwood', 1
    else
        return
    end

    -- Validate lại lần 2 phòng cheat
    local realMax = calcMaxProcessable(src, fromItem, toItem, multiplier)
    amount = math.min(amount, realMax)
    if amount <= 0 then
        Notify(src, 'Không thể xử lý!', 'error')
        return
    end

    local newAmount = amount * multiplier

    if not RemoveItem(src, fromItem, amount) then
        Notify(src, 'Lỗi khi lấy vật phẩm!', 'error')
        return
    end

    if AddItem(src, toItem, newAmount) then
        local lFrom = Config.itemLabels[fromItem] or fromItem
        local lTo   = Config.itemLabels[toItem]   or toItem
        Notify(src, 'Đã xử lý ' .. amount .. ' ' .. lFrom .. ' → ' .. newAmount .. ' ' .. lTo, 'success')
    else
        AddItem(src, fromItem, amount)
        Notify(src, 'Túi đồ đầy!', 'error')
    end
end)

RegisterNetEvent('pyh-lumberjack:sellWood')
AddEventHandler('pyh-lumberjack:sellWood', function()
    local src   = source
    local total = GetItemCount(src, 'finishwood')

    if total <= 0 then
        Notify(src, 'Bạn không có ' .. Config.itemLabels['finishwood'] .. ' để bán!', 'error')
        return
    end

    if not RemoveItem(src, 'finishwood', total) then
        Notify(src, 'Lỗi khi lấy vật phẩm!', 'error')
        return
    end

    local totalMoney = total * Config.woodPrice
    local player     = GetPlayer(src)
    player.Functions.AddMoney('cash', totalMoney)

    TriggerEvent("pyh-contacts:modifyRepS", src, "Lumberjack", (total / 100) * 0.5)
    Notify(src, 'Đã bán ' .. total .. ' ' .. Config.itemLabels['finishwood'] .. ' với giá $' .. totalMoney, 'success')
end)

-- Đăng ký axe useable qua ox_inventory
RegisterUsable('axe', function(src)
    TriggerClientEvent('pyh-lumberjack:useAxe', src)
end)