local QBX        = exports.qbx_core
local robbedSafes = {}
local safeInProgress = {}

lib.callback.register('derp_storerobbery:server:checkSafe', function(source, safeIndex)
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
    return true
end)

RegisterNetEvent('derp_storerobbery:server:setSafeRobbed', function(safeIndex)
    local src = source
    if safeInProgress[safeIndex] ~= src then return end
    safeInProgress[safeIndex] = nil
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
    local capped = math.min(math.max(tonumber(amount) or 0, 15), Config.MoneyGame.maxReward)
    if capped <= 0 then return end

    local xPlayer = QBX:GetPlayer(src)
    if not xPlayer then return end

    if Config.MoneyGame.rewardType == 'black_money' then
        exports.ox_inventory:AddItem(src, 'black_money', capped)
    elseif Config.MoneyGame.rewardType == 'markedbills' then
        xPlayer.Functions.AddItem('markedbills', 1, false, { worth = capped })
    else
        xPlayer.Functions.AddMoney('cash', capped)
    end

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
end)

AddEventHandler('playerDropped', function()
    local src = source
    for i, v in pairs(safeInProgress) do
        if v == src then safeInProgress[i] = nil end
    end
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