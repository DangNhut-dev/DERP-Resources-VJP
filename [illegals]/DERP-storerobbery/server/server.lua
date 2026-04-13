local QBX        = exports.qbx_core
local robbedSafes = {}
local safeInProgress = {}
local lastRewardSafeByPlayer = {}

local allEvents = {
    ["derp_storerobbery:server:giveReward"] = false,
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

local function formatRewardItem(itemName, count, metadata)
    local item = tostring(itemName or '')
    local amount = math.floor(tonumber(count) or 0)
    local label = getItemLabel(item)
    local display = item

    if label ~= '' and label ~= item then
        display = ('%s(%s)'):format(item, label)
    end

    if type(metadata) == 'table' and metadata.worth ~= nil then
        display = ('%s [worth:%s]'):format(display, math.floor(tonumber(metadata.worth) or 0))
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

local function getSafeLabel(safeIndex)
    if safeIndex == nil then
        return 'Không xác định'
    end

    return ('Két #%s'):format(tostring(safeIndex))
end

local function addStoreRewardLog(src, safeIndex, rewardType, cashAmount, itemList)
    local parts = {
        '[storerobbery] | Cướp Két Cửa Hàng'
    }

    parts[#parts + 1] = ('két: %s'):format(getSafeLabel(safeIndex))

    local rewardKey = tostring(rewardType or 'cash')
    local cashValue = math.floor(tonumber(cashAmount) or 0)

    if rewardKey == 'cash' and cashValue > 0 then
        parts[#parts + 1] = ('tiền: +cash x%s'):format(cashValue)
    end

    if type(itemList) == 'table' and #itemList > 0 then
        local formattedItems = {}

        for i = 1, #itemList do
            local entry = itemList[i]
            if type(entry) == 'table' and entry.name then
                formattedItems[#formattedItems + 1] = formatRewardItem(entry.name, entry.count, entry.metadata)
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
        deferMs = 0,
    })
end

lib.callback.register('derp_storerobbery:server:checkSafe', function(source, safeIndex)
    if getOnDutyPoliceCount() < 3 then
        TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Không thể thực hiện được ngay bây giờ' })
        return false
    end

    local now = os.time() * 1000
    for i = 1, #Config.Safes do
        if robbedSafes[i] and robbedSafes[i] > now then
            return false
        end
    end
    if safeInProgress[safeIndex] then
        return false
    end
    safeInProgress[safeIndex] = source
    lastRewardSafeByPlayer[source] = safeIndex
    return true
end)

RegisterNetEvent('derp_storerobbery:server:setSafeRobbed', function(safeIndex)
    local src = source
    if safeInProgress[safeIndex] ~= src then return end
    safeInProgress[safeIndex] = nil
    lastRewardSafeByPlayer[src] = safeIndex
    local expireAt = (os.time() * 1000) + Config.Cooldown
    for i = 1, #Config.Safes do
        robbedSafes[i] = expireAt
    end
    TriggerClientEvent('derp_storerobbery:client:syncRobbed', -1, robbedSafes)
end)

RegisterNetEvent('derp_storerobbery:server:dispatch', function(coords, streetLabel)
    local src = source
    if GetResourceState('lb-tablet') ~= 'started' then return end
    if not coords then return end

    exports['lb-tablet']:AddDispatch({
        priority    = 'high',
        code        = '10-35',
        title       = 'Cướp Két Cửa Hàng',
        description = 'Phát hiện đột nhập két tại ' .. (streetLabel or 'không xác định'),
        location    = {
            label  = streetLabel or 'Không xác định',
            coords = coords and vec2(coords.x, coords.y) or nil,
        },
        time   = 120,
        job    = 'police',
        fields = {
            { icon = 'fas fa-store',          label = 'Loại',   value = 'Đột nhập két cửa hàng' },
            { icon = 'fas fa-map-marker-alt', label = 'Vị trí', value = streetLabel or 'Không rõ' },
        },
        blip = {
            sprite = 227,
            color  = 1,
            size   = 1.5,
            label  = '10-35 Cướp Két',
        },
    })
end)

RegisterNetEvent('derp_storerobbery:server:giveReward', function(amount)
    local src    = source
    if fiveguard_resource ~= "" and GetResourceState(fiveguard_resource) == 'started' then
        if not exports[fiveguard_resource]:VerifyToken(src) then return end
    end
    local capped = math.min(math.max(tonumber(amount) or 0, 15), Config.MoneyGame.maxReward)
    if capped <= 0 then return end

    local xPlayer = QBX:GetPlayer(src)
    if not xPlayer then return end

    local rewardType = Config.MoneyGame.rewardType
    local cashReward = 0
    local rewardedItems = {}

    if rewardType == 'black_money' then
        local added = exports.ox_inventory:AddItem(src, 'black_money', capped)

        if added then
            rewardedItems[#rewardedItems + 1] = {
                name = 'black_money',
                count = capped,
            }
        end
    elseif rewardType == 'markedbills' then
        local added = xPlayer.Functions.AddItem('markedbills', 1, false, { worth = capped })

        if added then
            rewardedItems[#rewardedItems + 1] = {
                name = 'markedbills',
                count = 1,
                metadata = { worth = capped },
            }
        end
    else
        local added = xPlayer.Functions.AddMoney('cash', capped)

        if added ~= false then
            cashReward = capped
        end

        rewardType = 'cash'
    end

    addStoreRewardLog(src, lastRewardSafeByPlayer[src], rewardType, cashReward, rewardedItems)

    TriggerClientEvent('ox_lib:notify', src, {
        title       = 'Két Tiền',
        description = 'Bạn nhận được $' .. capped,
        type        = 'success',
    })
end)

RegisterNetEvent('derp_storerobbery:server:cancelSafe', function(safeIndex)
    local src = source
    if safeInProgress[safeIndex] == src then
        safeInProgress[safeIndex] = nil
    end
    lastRewardSafeByPlayer[src] = nil
end)

AddEventHandler('playerDropped', function()
    local src = source
    for i, v in pairs(safeInProgress) do
        if v == src then safeInProgress[i] = nil end
    end
    lastRewardSafeByPlayer[src] = nil
end)

AddEventHandler('playerJoining', function()
    local now      = os.time() * 1000
    local syncData = {}
    for idx, expireMs in pairs(robbedSafes) do
        if expireMs > now then
            syncData[tostring(idx)] = expireMs
        end
    end
    TriggerClientEvent('derp_storerobbery:client:syncRobbed', source, syncData)
end)
