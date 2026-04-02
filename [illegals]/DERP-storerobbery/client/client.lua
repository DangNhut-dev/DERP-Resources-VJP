local robbedCooldowns = {}
local isDoingAction   = false

local function getStreetLabel(coords)
    local hash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    return GetStreetNameFromHashKey(hash) or 'Không xác định'
end

local function startMoneyGame()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'start',
        config = {
            duration    = Config.MoneyGame.duration,
            coinValue   = Config.MoneyGame.coinValue,
            bombPenalty = Config.MoneyGame.bombPenalty,
            maxReward   = Config.MoneyGame.maxReward,
            spawnRate   = Config.MoneyGame.spawnRate,
        }
    })
end

RegisterNUICallback('moneyGameEnd', function(data, cb)
    SetNuiFocus(false, false)
    local amount = tonumber(data.amount) or 0
    if amount > 0 then
        TriggerServerEvent('derp_storerobbery:server:giveReward', amount)
    end
    cb('ok')
end)

local function handleSafe(safeIndex)
    if isDoingAction then return end

    for i = 1, #Config.Safes do
        if robbedCooldowns[i] and robbedCooldowns[i] > GetGameTimer() then
            lib.notify({ title = 'Két', description = 'Không thể cướp két ngay bây giờ, hãy thử lại sau.', type = 'error' })
            return
        end
    end

    if Config.RequireItem then
        if exports.ox_inventory:Search('count', Config.RequiredItem) < 1 then
            lib.notify({ title = 'Két', description = 'Bạn cần gì đó để làm.', type = 'error' })
            return
        end
    end

    lib.callback('derp_storerobbery:server:checkSafe', false, function(ok)
        if not ok then
            lib.notify({ title = 'Két', description = 'Không thể mở két lúc này.', type = 'error' })
            return
        end

        isDoingAction = true
        local coords = Config.Safes[safeIndex].coords

        -- Anim 1: Lấy laptop ra hack pincode
        lib.requestAnimDict('amb@code_human_in_bus_passenger_idles@female@tablet@base')
        local tabletProp = CreateObject(`prop_cs_tablet`, 0.0, 0.0, 0.0, true, true, false)
        AttachEntityToEntity(tabletProp, cache.ped, GetPedBoneIndex(cache.ped, 60309),
            0.03, 0.002, 0.0, 10.0, 160.0, 0.0, true, false, false, false, 2, true)
        TaskPlayAnim(cache.ped, 'amb@code_human_in_bus_passenger_idles@female@tablet@base', 'base',
            3.0, 1.0, -1, 49, 0, false, false, false)

        -- Minigame 1: Pincode
        local pincodeSuccess, done = false, false
        exports['boii_minigames']:pincode({
            style      = 'default',
            difficulty = Config.Pincode.difficulty,
            guesses    = Config.Pincode.guesses,
        }, function(success)
            pincodeSuccess = success
            done = true
        end)
        while not done do Wait(100) end

        -- Dọn anim + prop tablet
        ClearPedSecondaryTask(cache.ped)
        DetachEntity(tabletProp, true, false)
        DeleteEntity(tabletProp)
        RemoveAnimDict('amb@code_human_in_bus_passenger_idles@female@tablet@base')

        -- Dispatch dù thành công hay thất bại
        TriggerServerEvent('derp_storerobbery:server:dispatch', coords, getStreetLabel(coords))

        if not pincodeSuccess then
            lib.notify({ title = 'Két', description = 'Mã sai! Báo động kích hoạt.', type = 'error' })
            TriggerServerEvent('derp_storerobbery:server:cancelSafe', safeIndex)
            isDoingAction = false
            return
        end

        lib.notify({ title = 'Két', description = 'Mã đúng! Tiếp tục phá két...', type = 'success' })

        -- Anim 2: Khoan két
        lib.requestAnimDict('amb@prop_human_bum_bin@idle_b')
        TaskPlayAnim(cache.ped, 'amb@prop_human_bum_bin@idle_b', 'idle_d',
            8.0, 8.0, -1, 50, 0, false, false, false)

        -- Minigame 2: Safe crack
        local safeCrackSuccess
        done = false
        exports['boii_minigames']:safe_crack({
            style      = 'default',
            difficulty = Config.SafeCrack.difficulty,
        }, function(success)
            safeCrackSuccess = success
            done = true
        end)
        while not done do Wait(100) end

        -- Dọn anim khoan
        StopAnimTask(cache.ped, 'amb@prop_human_bum_bin@idle_b', 'idle_d', 1.0)
        RemoveAnimDict('amb@prop_human_bum_bin@idle_b')
        ClearPedTasks(cache.ped)

        if not safeCrackSuccess then
            lib.notify({ title = 'Két', description = 'Phá két thất bại!', type = 'error' })
            TriggerServerEvent('derp_storerobbery:server:cancelSafe', safeIndex)
            isDoingAction = false
            return
        end

        -- Anim 3: Mở két lấy tiền ra
        lib.requestAnimDict('anim@heists@ornate_bank@grab_cash')
        TaskPlayAnim(cache.ped, 'anim@heists@ornate_bank@grab_cash', 'intro',
            3.0, 1.0, 2000, 49, 0, false, false, false)
        Wait(2000)
        ClearPedTasks(cache.ped)
        RemoveAnimDict('anim@heists@ornate_bank@grab_cash')

        lib.notify({ title = 'Két', description = 'Két mở! Hứng tiền nào!', type = 'success' })

        for i = 1, #Config.Safes do
            robbedCooldowns[i] = GetGameTimer() + Config.Cooldown
        end
        TriggerServerEvent('derp_storerobbery:server:setSafeRobbed', safeIndex)

        startMoneyGame()
        isDoingAction = false
    end, safeIndex)
end

CreateThread(function()
    for i, safe in ipairs(Config.Safes) do
        exports.ox_target:addSphereZone({
            coords  = safe.coords,
            radius  = 1.0,
            debug   = false,
            options = {
                {
                    name     = 'derp_safe_' .. i,
                    icon     = 'fas fa-lock',
                    label    = 'Mở Két',
                    distance = 1.5,
                    onSelect = function()
                        handleSafe(i)
                    end,
                }
            }
        })
    end
end)

RegisterNetEvent('derp_storerobbery:client:syncRobbed', function(data)
    for idx, expireMs in pairs(data) do
        robbedCooldowns[tonumber(idx)] = GetGameTimer() + math.max(0, expireMs - (os.time() * 1000))
    end
end)

RegisterCommand('testcatch', function()
    startMoneyGame()
end, false)