local treeStates      = {}
local playerCooldowns = {}
local allEvents = {
    ["derp-harvestcotton:server:harvest"] = false,
}
local fiveguard_resource = "svc_runtime"
AddEventHandler("fg:ExportsLoaded", function(fiveguard_res, res)
    if res == "*" or res == GetCurrentResourceName() then
        fiveguard_resource = fiveguard_res
        for event,cross_scripts in pairs(allEvents) do
            local retval, errorText = exports[fiveguard_res]:RegisterSafeEvent(event, {
                ban = true,
                log = true
            }, cross_scripts)
            if not retval then
                print("[fiveguard safe-events] "..errorText)
            end
        end
    end
end)
local function isJsRankingStarted()
    return GetResourceState('js_ranking') == 'started'
end

local function addActionLog(src, actionText, opts)
    if not isJsRankingStarted() then return false end
    if type(src) ~= 'number' or src <= 0 then return false end
    if not actionText or actionText == '' then return false end

    local ok = pcall(function()
        exports['js_ranking']:AddActionLog(src, actionText, opts or {})
    end)

    return ok
end

local function getItemLabel(itemName)
    local ok, item = pcall(function()
        return exports.ox_inventory:Items(itemName)
    end)

    if ok and type(item) == 'table' and item.label and item.label ~= '' then
        return tostring(item.label)
    end

    return tostring(itemName or '')
end

local function formatItem(itemName, amount)
    local name = tostring(itemName or '')
    local label = getItemLabel(name)
    local display = name

    if label ~= '' and label ~= name then
        display = ('%s(%s)'):format(name, label)
    end

    amount = math.floor(tonumber(amount) or 0)

    if amount > 0 then
        return ('%s x%s'):format(display, amount)
    end

    return display
end

local function buildActionText(title, details)
    local message = ('[DERP-harvestcotton] | %s'):format(tostring(title or ''))

    if type(details) == 'table' and #details > 0 then
        local parts = {}

        for i = 1, #details do
            local entry = details[i]
            local key = entry and entry[1]
            local value = entry and entry[2]

            if key and value ~= nil and value ~= '' then
                parts[#parts + 1] = ('%s: %s'):format(tostring(key), tostring(value))
            end
        end

        if #parts > 0 then
            message = message .. ' | ' .. table.concat(parts, ' | ')
        end
    end

    return message
end

local function logAction(src, title, details, opts)
    return addActionLog(src, buildActionText(title, details), opts)
end

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
    if fiveguard_resource ~= "" and GetResourceState(fiveguard_resource) == 'started' then
        if not exports[fiveguard_resource]:VerifyToken(src) then return end
    end
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
        local itemName = Config.ItemName
        local added = exports.ox_inventory:AddItem(src, itemName, amount)

        if added then
            logAction(src, 'Nhận item', {
                { 'danh sách', formatItem(itemName, amount) },
                { 'nguồn', 'thu hoạch bông' },
                { 'cây', tostring(treeIdx) },
            })
        end

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
