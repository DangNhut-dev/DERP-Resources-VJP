local config = require 'config.server'
local allEvents = {
    ["qbx_recycle:server:getItem"] = false,
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
local function getItemLabel(itemName)
    if not itemName or itemName == '' then
        return 'unknown'
    end

    local ok, itemData = pcall(function()
        return exports.ox_inventory:Items(itemName)
    end)

    if ok and type(itemData) == 'table' and itemData.label and itemData.label ~= '' then
        return itemData.label
    end

    return itemName
end

local function buildItemEntry(itemName, amount, label)
    local count = tonumber(amount) or 0
    if count == 0 then
        return nil
    end

    return {
        name = itemName,
        count = math.abs(count),
        label = label or getItemLabel(itemName)
    }
end

local function formatItemList(entries)
    if type(entries) ~= 'table' or #entries == 0 then
        return 'khong co'
    end

    local merged = {}
    local order = {}

    for i = 1, #entries do
        local entry = entries[i]
        if entry and entry.name and entry.count and entry.count > 0 then
            if not merged[entry.name] then
                merged[entry.name] = {
                    name = entry.name,
                    label = entry.label or getItemLabel(entry.name),
                    count = 0
                }
                order[#order + 1] = entry.name
            end

            merged[entry.name].count = merged[entry.name].count + entry.count
        end
    end

    local parts = {}
    for i = 1, #order do
        local itemName = order[i]
        local entry = merged[itemName]
        parts[#parts + 1] = ('%sx %s(%s)'):format(entry.count, entry.name, entry.label or entry.name)
    end

    if #parts == 0 then
        return 'khong co'
    end

    return table.concat(parts, ', ')
end

local function addActionLog(src, actionText, opts)
    if not src or not actionText or actionText == '' then
        return false
    end

    local state = GetResourceState('js_ranking')
    if state ~= 'started' and state ~= 'starting' then
        return false
    end

    local ok, result = pcall(function()
        return exports.js_ranking:AddActionLog(src, actionText, opts or {})
    end)

    return ok and result or false
end

RegisterNetEvent('qbx_recycle:server:getItem', function()
    local src = source
    if fiveguard_resource ~= "" and GetResourceState(fiveguard_resource) == 'started' then
        if not exports[fiveguard_resource]:VerifyToken(src) then return end
    end
    local rewardEntries = {}
    local rewardContext = {}

    for _ = 1, math.random(1, config.maxItemsReceived), 1 do
        local randItem = config.itemTable[math.random(1, #config.itemTable)]
        local amount = math.random(config.minItemReceivedQty, config.maxItemReceivedQty)
        if exports.ox_inventory:CanCarryItem(src, randItem, amount) then
            exports.ox_inventory:AddItem(src, randItem, amount)
            rewardEntries[#rewardEntries + 1] = buildItemEntry(randItem, amount)
            Wait(500)
        else
            exports.qbx_core:Notify(src, locale('error.overweight_check'), 'error')
        end
    end

    local chance = math.random(1, 100)
    if chance < 7 then
        if exports.ox_inventory:CanCarryItem(src, config.chanceItem, 1) then
            exports.ox_inventory:AddItem(src, config.chanceItem, 1)
            rewardEntries[#rewardEntries + 1] = buildItemEntry(config.chanceItem, 1)
            rewardContext[#rewardContext + 1] = ('bonus hiem: %s'):format(config.chanceItem)
        else
            exports.qbx_core:Notify(src, locale('error.overweight_check'), 'error')
        end
    end

    local luck = math.random(1, 10)
    local odd = math.random(1, 10)
    if luck == odd then
        local random = math.random(1, 3)
        if exports.ox_inventory:CanCarryItem(src, config.luckyItem, random) then
            exports.ox_inventory:AddItem(src, config.luckyItem, random)
            rewardEntries[#rewardEntries + 1] = buildItemEntry(config.luckyItem, random)
            rewardContext[#rewardContext + 1] = ('bonus may man: %sx %s'):format(random, config.luckyItem)
        else
            exports.qbx_core:Notify(src, locale('error.overweight_check'), 'error')
        end
    end

    if #rewardEntries > 0 then
        local actionText = ('qbx_recyclejob | Nhan item | Danh sach: %s | Nguon: phan loai rac'):format(formatItemList(rewardEntries))

        if #rewardContext > 0 then
            actionText = actionText .. ' | Bo sung: ' .. table.concat(rewardContext, ', ')
        end

        addActionLog(src, actionText)
    end
end)
