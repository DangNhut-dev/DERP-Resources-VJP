local QBX = exports.qbx_core
local playerCooldowns = {}
local allEvents = {
    ["derp_npcrobbery:server:robZone"] = false,
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
local function getOnDutyPoliceCount()
    local count = 0
    for _, v in pairs(exports.qbx_core:GetQBPlayers()) do
        if v and v.PlayerData.job.type == 'leo' and v.PlayerData.job.onduty then
            count = count + 1
        end
    end
    return count
end

local function isResourceStarted(resourceName)
    return GetResourceState(resourceName) == 'started'
end

local function getItemLabel(itemName)
    if not itemName or itemName == '' then
        return ''
    end

    local ok, itemData = pcall(function()
        return exports.ox_inventory:Items(itemName)
    end)

    if ok and type(itemData) == 'table' and itemData.label and itemData.label ~= '' then
        return tostring(itemData.label)
    end

    return tostring(itemName)
end

local function formatRewardItem(itemName, count)
    local item = tostring(itemName or '')
    local amount = math.floor(tonumber(count) or 0)
    local label = getItemLabel(item)
    local display = item

    if label ~= '' and label ~= item then
        display = ('%s(%s)'):format(item, label)
    end

    if amount > 0 then
        return ('+%s x%s'):format(display, amount)
    end

    return ('+%s'):format(display)
end

local function forwardActionLog(anyPlayer, actionText, opts)
    if not actionText or actionText == '' then
        return false
    end

    opts = opts or {}

    if isResourceStarted('ox_inventory') then
        local ok = pcall(function()
            exports.ox_inventory:AddActionLog(anyPlayer, actionText, opts)
        end)

        if ok then
            return true
        end
    end

    if isResourceStarted('js_ranking') then
        local ok = pcall(function()
            exports['js_ranking']:AddActionLog(anyPlayer, actionText, opts)
        end)

        if ok then
            return true
        end
    end

    return false
end

exports('AddActionLog', forwardActionLog)

local function addRobberyRewardLog(src, zoneLabel, cashAmount, itemList)
    local parts = {
        '[npcrobbery] | Cướp NPC'
    }

    local safeZoneLabel = tostring(zoneLabel or 'Không xác định')
    parts[#parts + 1] = ('vị trí: %s'):format(safeZoneLabel)

    local cashValue = math.floor(tonumber(cashAmount) or 0)
    if cashValue > 0 then
        parts[#parts + 1] = ('tiền: +cash x%s'):format(cashValue)
    end

    if type(itemList) == 'table' and #itemList > 0 then
        local formattedItems = {}

        for i = 1, #itemList do
            local entry = itemList[i]
            if type(entry) == 'table' and entry.name then
                formattedItems[#formattedItems + 1] = formatRewardItem(entry.name, entry.count)
            end
        end

        if #formattedItems > 0 then
            parts[#parts + 1] = ('item: %s'):format(table.concat(formattedItems, ', '))
        end
    end

    if #parts <= 2 then
        return false
    end

    return forwardActionLog(src, table.concat(parts, ' | '), {
        source = src,
        deferMs = 0
    })
end

lib.callback.register('derp_npcrobbery:server:checkCooldown', function(source)
    local src = source
    if getOnDutyPoliceCount() < 1 then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Cướp', description = 'Không thể thực hiện được ngay bây giờ', type = 'error' })
        return false
    end
    local now = GetGameTimer()
    if playerCooldowns[src] and playerCooldowns[src] > now then
        return false
    end
    playerCooldowns[src] = now + Config.PlayerCooldown
    return true
end)

RegisterNetEvent('derp_npcrobbery:server:robZone', function(zoneId)
    local src = source
    if fiveguard_resource ~= "" and GetResourceState(fiveguard_resource) == 'started' then
        if not exports[fiveguard_resource]:VerifyToken(src) then return end
    end
    local zone = Config.Zones[zoneId]
    if not zone then return end

    local xPlayer = QBX:GetPlayer(src)
    if not xPlayer then return end

    local reward = Config.ZoneReward
    local cash = math.random(reward.cashMin, reward.cashMax)
    local cashAdded = exports.ox_inventory:AddItem(src, 'cash', cash)
    local rewardedCash = cashAdded and cash or 0
    local rewardedItems = {}

    TriggerClientEvent('ox_lib:notify', src, {
        title = zone.label,
        description = 'Tìm được $' .. cash,
        type = 'success',
    })

    if math.random(100) <= reward.itemChance then
        local roll = math.random(100)
        local accum = 0
        for _, v in ipairs(reward.items) do
            accum = accum + v.chance
            if roll <= accum then
                local itemAdded = exports.ox_inventory:AddItem(src, v.item, 1)

                if itemAdded then
                    rewardedItems[#rewardedItems + 1] = {
                        name = v.item,
                        count = 1,
                    }
                end

                TriggerClientEvent('ox_lib:notify', src, {
                    title = 'Tìm được đồ',
                    description = v.item,
                    type = 'success',
                })
                break
            end
        end
    end

    addRobberyRewardLog(src, zone.label, rewardedCash, rewardedItems)

    local allZones = #Config.Zones
    local done = 0
end)

RegisterNetEvent('derp_npcrobbery:server:dispatch', function(coords, streetLabel)
    local src = source
    if GetResourceState('lb-tablet') ~= 'started' then return end
    if not coords then return end
    streetLabel = streetLabel or 'Không xác định'

    exports['lb-tablet']:AddDispatch({
        priority = 'medium',
        code = '10-30',
        title = 'Cướp Người',
        description = 'Phát hiện hành vi cướp giật tại ' .. streetLabel,
        location = {
            label = streetLabel,
            coords = vec2(coords.x, coords.y),
        },
        time = 120,
        job = 'police',
        fields = {
            { icon = 'fas fa-person', label = 'Loại', value = 'Cướp người đi đường' },
            { icon = 'fas fa-map-marker-alt', label = 'Vị trí', value = streetLabel },
        },
        blip = {
            sprite = 153,
            color = 1,
            size = 1.5,
            label = '10-30 Cướp Người',
        },
    })
end)

AddEventHandler('playerDropped', function()
    playerCooldowns[source] = nil
end)
