local treeStates      = {}
local playerCooldowns = {}

-- Khởi tạo trạng thái các cây khi resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for i = 1, #Config.Trees do
        treeStates[i] = { available = true }
    end
end)

-- Dọn dẹp cooldown khi player disconnect
AddEventHandler('playerDropped', function()
    playerCooldowns[source] = nil
end)

-- Gửi trạng thái toàn bộ cây cho client vừa load
RegisterNetEvent('derp-harvestcotton:server:requestStates', function()
    TriggerClientEvent('derp-harvestcotton:client:initStates', source, treeStates)
end)

-- Xử lý thu hoạch
RegisterNetEvent('derp-harvestcotton:server:harvest', function(treeIdx, success, px, py, pz, heading)
    local src = source

    -- Validate input
    if type(treeIdx) ~= 'number' or treeIdx < 1 or treeIdx > #Config.Trees then return end
    if type(success) ~= 'boolean' then return end
    if type(px) ~= 'number' or type(py) ~= 'number' or type(pz) ~= 'number' then return end
    if type(heading) ~= 'number' then return end

    -- Anti-spam per player
    local now = GetGameTimer()
    if playerCooldowns[src] and (now - playerCooldowns[src]) < Config.ProgressBarTime then return end
    playerCooldowns[src] = now

    -- Validate cây còn available
    if not treeStates[treeIdx] or not treeStates[treeIdx].available then return end

    -- Kiểm tra có scissors không
    local scissorsSlots = exports.ox_inventory:Search(src, 'slots', 'scissors')
    if not scissorsSlots or not next(scissorsSlots) then
        TriggerClientEvent('ox_lib:notify', src, {
            title       = 'Thu hoạch bông',
            description = 'Bạn cần kéo để thu hoạch',
            type        = 'error',
        })
        return
    end
    local usableSlot = nil
    for _, slot in pairs(scissorsSlots) do
        local dur = slot.metadata and slot.metadata.durability
        if dur == nil or dur > 0 then
            usableSlot = slot
            break
        end
    end
    if not usableSlot then
        TriggerClientEvent('ox_lib:notify', src, {
            title       = 'Thu hoạch bông',
            description = 'Kéo của bạn đã hỏng',
            type        = 'error',
        })
        return
    end

    -- Validate coords gần cây (chống teleport exploit)
    local tree    = Config.Trees[treeIdx]
    local dx      = px - tree.coords.x
    local dy      = py - tree.coords.y
    local dist    = math.sqrt(dx * dx + dy * dy)
    if dist > 10.0 then return end

    -- Khoá cây, broadcast cho tất cả client
    treeStates[treeIdx].available = false
    TriggerClientEvent('derp-harvestcotton:client:setTreeState', -1, treeIdx, false)

    if success then
        local amount = math.random(Config.ItemMin, Config.ItemMax)
        exports.ox_inventory:AddItem(src, Config.ItemName, amount)
        TriggerClientEvent('ox_lib:notify', src, {
            title       = 'Thu hoạch bông',
            description = 'Nhận được ' .. amount .. ' bông cotton',
            type        = 'success',
        })
    else
        -- Tính vị trí spawn NPC sau lưng player (server tính để tất cả client dùng chung)
        local rad   = math.rad(heading)
        local sx    = px - math.sin(rad) * 1.8
        local sy    = py - math.cos(rad) * 1.8
        local sz    = pz - 1.0
        -- NPC quay mặt về phía player = heading player
        TriggerClientEvent('derp-harvestcotton:client:spawnSlapper', -1, sx, sy, sz, heading, src)
    end

    -- Mở lại cây sau cooldown
    SetTimeout(Config.CooldownTime, function()
        if not treeStates[treeIdx] then return end
        treeStates[treeIdx].available = true
        TriggerClientEvent('derp-harvestcotton:client:setTreeState', -1, treeIdx, true)
    end)
end)