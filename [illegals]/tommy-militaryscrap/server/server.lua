local lib = lib

local function IsJsRankingStarted()
    return GetResourceState('js_ranking') == 'started'
end

local function GetOxItemLabel(itemName, fallbackLabel)
    if fallbackLabel and fallbackLabel ~= '' then
        return tostring(fallbackLabel)
    end
    if not itemName or itemName == '' then return 'unknown' end

    local itemData
    local ok = pcall(function()
        itemData = exports.ox_inventory:Items(itemName)
    end)
    if ok and type(itemData) == 'table' and itemData.label and itemData.label ~= '' then
        return tostring(itemData.label)
    end
    return tostring(itemName)
end

local function FormatScrapItem(itemName, count, fallbackLabel, mode)
    local amount = math.floor(tonumber(count) or 0)
    local label = GetOxItemLabel(itemName, fallbackLabel)
    local display = tostring(itemName or '')
    if label ~= '' and label ~= display then
        display = ('%s(%s)'):format(display, label)
    end
    local prefix = ''
    if mode == 'add' then prefix = '+'
    elseif mode == 'remove' then prefix = '-' end
    if amount > 0 then
        return ('%s%s x%s'):format(prefix, display, amount)
    end
    return prefix .. display
end

local function BuildItemList(items)
    if type(items) ~= 'table' or #items == 0 then return nil end
    return table.concat(items, ', ')
end

local function BuildScrapActionText(title, details)
    local message = ('[tommy-militaryscrap] | %s'):format(tostring(title or ''))
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

local function AddActionLog(anyPlayer, actionText, opts)
    if not IsJsRankingStarted() then return false end
    if not actionText or actionText == '' then return false end
    local ok = pcall(function()
        exports['js_ranking']:AddActionLog(anyPlayer, actionText, opts)
    end)
    return ok
end

local function LogScrapAction(anyPlayer, title, details, opts)
    return AddActionLog(anyPlayer, BuildScrapActionText(title, details), opts)
end

local function GetZoneLabelByCoords(coords)
    for _, zone in ipairs(Config.RedZones) do
        if #(coords - zone.coords) <= zone.radius then
            return zone.label or 'unknown'
        end
    end
    return 'unknown'
end

local crateStates = {}
local refiningPlayers = {}

local function getCrateById(id)
    for _, c in ipairs(Config.Crates) do
        if c.id == id then return c end
    end
    return nil
end

local function getRecipeByIndex(idx)
    return Config.RefineryRecipes[idx]
end

local function isInsideAnyZone(coords)
    for _, zone in ipairs(Config.RedZones) do
        if #(coords - zone.coords) <= zone.radius then
            return true
        end
    end
    return false
end

local function getPoliceCount()
    local count = 0
    local players = exports.qbx_core:GetQBPlayers()
    for _, p in pairs(players) do
        if p and p.PlayerData and p.PlayerData.job then
            for _, jobName in ipairs(Config.PoliceJobs) do
                if p.PlayerData.job.name == jobName and p.PlayerData.job.onduty then
                    count = count + 1
                    break
                end
            end
        end
    end
    return count
end

local function getAdvancedLockpickSlot(src)
    local items = exports.ox_inventory:Search(src, 'slots', Config.AdvancedLockpickItem)
    if not items or #items == 0 then return nil end

    local bestSlot, bestDurability = nil, -1
    for _, item in ipairs(items) do
        local dur = item.metadata and item.metadata.durability
        if dur == nil then dur = 100 end
        if dur > 0 and dur > bestDurability then
            bestSlot = item.slot
            bestDurability = dur
        end
    end
    return bestSlot, bestDurability
end

local function hasLockpick(src)
    local advSlot, advDur = getAdvancedLockpickSlot(src)
    if advSlot then return true, 'advanced', advSlot, advDur end

    local hasNormal = exports.ox_inventory:GetItemCount(src, Config.LockpickItem) > 0
    if hasNormal then return true, 'normal', nil, nil end

    return false, nil, nil, nil
end

local function notify(src, title, desc, ntype)
    TriggerClientEvent('ox_lib:notify', src, {
        title = title,
        description = desc,
        type = ntype or 'inform',
        position = 'top'
    })
end

local function rollRewards(src)
    local granted = {}
    for _, reward in ipairs(Config.Rewards) do
        if math.random(1, 100) <= reward.chance then
            local amount = math.random(reward.min, reward.max)
            local ok = exports.ox_inventory:AddItem(src, reward.item, amount)
            if ok then
                granted[#granted + 1] = { item = reward.item, amount = amount }
            end
        end
    end
    return granted
end

lib.callback.register('tommy-militaryscrap:server:startLockpick', function(source, crateId)
    local src = source
    local crate = getCrateById(crateId)
    if not crate then return false end

    if getPoliceCount() < Config.MinPolice then
        notify(src, 'Không khả dụng', 'Không đủ cảnh sát để thực hiện', 'error')
        return false
    end

    if crateStates[crateId] then
        notify(src, 'Lỗi', 'Thùng này đang được cạy hoặc đã bị mở', 'error')
        return false
    end

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return false end
    local pcoords = GetEntityCoords(ped)
    if #(pcoords - vector3(crate.coords.x, crate.coords.y, crate.coords.z)) > Config.CrateInteractDistance + 2.0 then
        return false
    end

    if not isInsideAnyZone(pcoords) then
        notify(src, 'Lỗi', 'Bạn không ở trong khu vực hợp lệ', 'error')
        return false
    end

    local has, lockType, advSlot, advDur = hasLockpick(src)
    if not has then
        notify(src, 'Lỗi', 'Bạn không có dụng cụ cạy khóa', 'error')
        return false
    end

    crateStates[crateId] = {
        player = src,
        started = os.time(),
        lockType = lockType,
        advSlot = advSlot,
        advDur = advDur
    }
    return true
end)

RegisterNetEvent('tommy-militaryscrap:server:lockpickFailed', function(crateId)
    local src = source
    local state = crateStates[crateId]
    if not state or state.player ~= src then return end

    if state.lockType == 'normal' then
        if math.random(1, 100) <= Config.LockpickBreakChance then
            exports.ox_inventory:RemoveItem(src, Config.LockpickItem, 1)
            notify(src, 'Hỏng dụng cụ', 'Lockpick đã bị gãy', 'error')
        end
    elseif state.lockType == 'advanced' and state.advSlot then
        local newDur = (state.advDur or 100) - Config.AdvancedLockpickDurabilityLoss
        if newDur <= 0 then
            exports.ox_inventory:RemoveItem(src, Config.AdvancedLockpickItem, 1, nil, state.advSlot)
            notify(src, 'Hỏng dụng cụ', 'Dụng cụ bẻ khóa đã hỏng hoàn toàn', 'error')
        else
            exports.ox_inventory:SetMetadata(src, state.advSlot, { durability = newDur })
        end
    end

    crateStates[crateId] = nil
end)

RegisterNetEvent('tommy-militaryscrap:server:lockpickSuccess', function(crateId)
    local src = source
    local state = crateStates[crateId]
    if not state or state.player ~= src then return end

    if state.lockType == 'advanced' and state.advSlot then
        local newDur = (state.advDur or 100) - Config.AdvancedLockpickDurabilityLoss
        if newDur <= 0 then
            exports.ox_inventory:RemoveItem(src, Config.AdvancedLockpickItem, 1, nil, state.advSlot)
            notify(src, 'Hỏng dụng cụ', 'Dụng cụ bẻ khóa đã hỏng hoàn toàn', 'error')
        else
            exports.ox_inventory:SetMetadata(src, state.advSlot, { durability = newDur })
        end
    end
end)

RegisterNetEvent('tommy-militaryscrap:server:cancelLockpick', function(crateId)
    local src = source
    local state = crateStates[crateId]
    if state and state.player == src then
        crateStates[crateId] = nil
    end
end)

RegisterNetEvent('tommy-militaryscrap:server:finishLockpick', function(crateId)
    local src = source
    local crate = getCrateById(crateId)
    if not crate then return end

    local state = crateStates[crateId]
    if not state or state.player ~= src then return end
    if state.opened then return end

    if getPoliceCount() < Config.MinPolice then
        crateStates[crateId] = nil
        notify(src, 'Không khả dụng', 'Không đủ cảnh sát để thực hiện', 'error')
        return
    end

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then
        crateStates[crateId] = nil
        return
    end
    local pcoords = GetEntityCoords(ped)
    if #(pcoords - vector3(crate.coords.x, crate.coords.y, crate.coords.z)) > Config.CrateInteractDistance + 2.0 then
        crateStates[crateId] = nil
        return
    end

    if not isInsideAnyZone(pcoords) then
        crateStates[crateId] = nil
        return
    end

    if not exports.ox_inventory:CanCarryItem(src, Config.Rewards[1].item, Config.Rewards[1].min) then
        crateStates[crateId] = nil
        notify(src, 'Lỗi', 'Túi đồ không đủ chỗ', 'error')
        return
    end

    state.opened = true

    local granted = rollRewards(src)

    TriggerClientEvent('tommy-militaryscrap:client:despawnCrate', -1, crateId)

    if #granted > 0 then
        local lines = {}
        local logItems = {}
        for _, g in ipairs(granted) do
            local itemData = exports.ox_inventory:Items(g.item)
            local label = (itemData and itemData.label) or g.item
            lines[#lines + 1] = ('+%dx %s'):format(g.amount, label)
            logItems[#logItems + 1] = FormatScrapItem(g.item, g.amount, label, 'add')
        end
        notify(src, 'Cạy thành công', table.concat(lines, '\n'), 'success')

        LogScrapAction(src, 'mở thùng quân dụng thành công', {
            { 'vị trí', GetZoneLabelByCoords(pcoords) },
            { 'crate', '#' .. tostring(crateId) },
            { 'dụng cụ', state.lockType or 'unknown' },
            { 'nhận', BuildItemList(logItems) }
        })
    else
        notify(src, 'Cạy thành công', 'Thùng trống', 'inform')

        LogScrapAction(src, 'mở thùng quân dụng thành công', {
            { 'vị trí', GetZoneLabelByCoords(pcoords) },
            { 'crate', '#' .. tostring(crateId) },
            { 'dụng cụ', state.lockType or 'unknown' },
            { 'nhận', 'thùng trống' }
        })
    end

    SetTimeout((crate.respawn or Config.RespawnTime) * 1000, function()
        crateStates[crateId] = nil
        TriggerClientEvent('tommy-militaryscrap:client:respawnCrate', -1, crateId)
    end)
end)

lib.callback.register('tommy-militaryscrap:server:canRefine', function(source, recipeIndex)
    local src = source
    local recipe = getRecipeByIndex(recipeIndex)
    if not recipe then return false end

    if refiningPlayers[src] then
        notify(src, 'Lỗi', 'Bạn đang tinh chế rồi', 'error')
        return false
    end

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return false end
    local pcoords = GetEntityCoords(ped)

    local nearRefinery = false
    for _, c in ipairs(Config.RefineryLocations) do
        if #(pcoords - c) <= Config.RefineryInteractDistance + 2.0 then
            nearRefinery = true
            break
        end
    end
    if not nearRefinery then
        notify(src, 'Lỗi', 'Bạn không ở gần xưởng', 'error')
        return false
    end

    local have = exports.ox_inventory:GetItemCount(src, recipe.input.item)
    if have < recipe.input.amount then
        local inputItem = exports.ox_inventory:Items(recipe.input.item)
        local inputLabel = (inputItem and inputItem.label) or recipe.input.item
        notify(src, 'Lỗi', ('Cần %dx %s'):format(recipe.input.amount, inputLabel), 'error')
        return false
    end

    if not exports.ox_inventory:CanCarryItem(src, recipe.output.item, recipe.output.amount) then
        notify(src, 'Lỗi', 'Túi đồ không đủ chỗ', 'error')
        return false
    end

    refiningPlayers[src] = recipeIndex
    return true
end)

RegisterNetEvent('tommy-militaryscrap:server:finishRefine', function(recipeIndex)
    local src = source
    local pending = refiningPlayers[src]
    refiningPlayers[src] = nil

    if pending ~= recipeIndex then return end

    local recipe = getRecipeByIndex(recipeIndex)
    if not recipe then return end

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return end
    local pcoords = GetEntityCoords(ped)

    local nearRefinery = false
    for _, c in ipairs(Config.RefineryLocations) do
        if #(pcoords - c) <= Config.RefineryInteractDistance + 2.0 then
            nearRefinery = true
            break
        end
    end
    if not nearRefinery then return end

    local have = exports.ox_inventory:GetItemCount(src, recipe.input.item)
    if have < recipe.input.amount then
        notify(src, 'Lỗi', 'Không đủ nguyên liệu', 'error')
        return
    end

    if not exports.ox_inventory:CanCarryItem(src, recipe.output.item, recipe.output.amount) then
        notify(src, 'Lỗi', 'Túi đồ không đủ chỗ', 'error')
        return
    end

    local beforeMaterial = have

    local removed = exports.ox_inventory:RemoveItem(src, recipe.input.item, recipe.input.amount)
    if not removed then
        notify(src, 'Lỗi', 'Không thể lấy nguyên liệu', 'error')
        return
    end

    local added = exports.ox_inventory:AddItem(src, recipe.output.item, recipe.output.amount)
    if not added then
        notify(src, 'Lỗi', 'Không thể nhận sản phẩm', 'error')
        return
    end

    local inputItem  = exports.ox_inventory:Items(recipe.input.item)
    local outputItem = exports.ox_inventory:Items(recipe.output.item)
    local inputLabel  = (inputItem  and inputItem.label)  or recipe.input.item
    local outputLabel = (outputItem and outputItem.label) or recipe.output.item

    notify(src, 'Tinh chế thành công', ('+%dx %s'):format(recipe.output.amount, outputLabel), 'success')

    local consumedText = FormatScrapItem(recipe.input.item, recipe.input.amount, inputLabel, 'remove')
    local producedText = FormatScrapItem(recipe.output.item, recipe.output.amount, outputLabel, 'add')

    LogScrapAction(src, 'tinh chế linh kiện', {
        { 'recipe', recipe.label or 'unknown' },
        { 'tiêu hao', consumedText },
        { 'nhận', producedText }
    }, { beforeMaterial = { [recipe.input.item] = beforeMaterial } })
end)

AddEventHandler('playerDropped', function()
    local src = source
    refiningPlayers[src] = nil
    for id, state in pairs(crateStates) do
        if state.player == src and not state.opened then
            crateStates[id] = nil
        end
    end
end)