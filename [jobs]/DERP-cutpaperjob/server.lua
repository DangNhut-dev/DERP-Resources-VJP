local cooldowns = {}
local allEvents = {
    ["DERP-cutpaper:server:giveItem"] = false,
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
local COOLDOWN_MS = Config.Work.interval - 2000

local function isJsRankingStarted()
    return GetResourceState('js_ranking') == 'started'
end

local function getItemLabel(itemName)
    if itemName == Config.Work.item and Config.Work.itemLabel and Config.Work.itemLabel ~= '' then
        return Config.Work.itemLabel
    end

    local ok, item = pcall(function()
        return exports.ox_inventory:Items(itemName)
    end)

    if ok and item and item.label and item.label ~= '' then
        return item.label
    end

    return tostring(itemName or '')
end

local function formatItemList(items)
    if type(items) ~= 'table' or #items == 0 then return nil end

    local parts = {}

    for i = 1, #items do
        local entry = items[i]
        local name = tostring(entry.name or '')
        local count = tonumber(entry.count) or 0
        local label = getItemLabel(name)

        if label ~= '' and label ~= name then
            parts[#parts + 1] = ('%sx %s(%s)'):format(count, name, label)
        else
            parts[#parts + 1] = ('%sx %s'):format(count, name)
        end
    end

    if #parts == 0 then return nil end
    return table.concat(parts, ', ')
end

local function tryAddActionLog(src, actionText, opts)
    if type(src) ~= 'number' or src <= 0 then return false end
    if not isJsRankingStarted() then return false end
    if not actionText or actionText == '' then return false end

    local ok = pcall(function()
        exports['js_ranking']:AddActionLog(src, actionText, opts)
    end)

    return ok
end

local function logRewardItem(src, items, isDouble)
    local itemText = formatItemList(items)
    if not itemText then return end

    local modeText = isDouble and 'x2' or 'thường'
    local actionText = ('DERP-cutpaperjob | Nhận item | Danh sách: %s | Chế độ: %s'):format(itemText, modeText)

    tryAddActionLog(src, actionText)
end

-- ============================
--   GIVE ITEM
-- ============================

RegisterNetEvent('DERP-cutpaper:server:giveItem', function(isDouble)
    local src = source
    if fiveguard_resource ~= "" and GetResourceState(fiveguard_resource) == 'started' then
        if not exports[fiveguard_resource]:VerifyToken(src) then return end
    end
    if not src or src <= 0 then return end

    local now = GetGameTimer()
    if cooldowns[src] and (now - cooldowns[src]) < COOLDOWN_MS then return end
    cooldowns[src] = now

    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return end

    if GetEntityHealth(ped) <= 0 then return end
    if GetVehiclePedIsIn(ped, false) ~= 0 then return end

    local coords = GetEntityCoords(ped)
    local dist   = #(coords - Config.Zone.coord)
    if dist > Config.Zone.radius + 5.0 then return end

    local amount = isDouble == true and Config.Work.doubleAmount or Config.Work.itemAmount

    local scissorsSlots = exports.ox_inventory:Search(src, 'slots', Config.Work.requiredItem)
    if not scissorsSlots or not next(scissorsSlots) then return end
    local hasUsable = false
    for _, slot in pairs(scissorsSlots) do
        local dur = slot.metadata and slot.metadata.durability
        if dur == nil or dur > 0 then
            hasUsable = true
            break
        end
    end
    if not hasUsable then return end

    local success = exports.ox_inventory:AddItem(src, Config.Work.item, amount)
    if success then
        logRewardItem(src, {
            {
                name = Config.Work.item,
                count = amount,
            }
        }, isDouble == true)

        TriggerClientEvent('ox_lib:notify', src, {
            title       = 'Cắt Giấy',
            description = 'Nhận được ' .. amount .. 'x ' .. Config.Work.itemLabel,
            type        = 'success',
        })
    end
end)

-- ============================
--   CLEANUP ON DROP
-- ============================

AddEventHandler('playerDropped', function()
    cooldowns[source] = nil
end)
