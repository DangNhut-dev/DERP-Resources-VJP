local PlayerData = {}
local isPlayerLoaded = false
local isMarketOpen = false
local SpawnedPeds = {}
local CurrentHourVN = 0

local function isInventoryOpen()
    return LocalPlayer.state.inv_open == true
end

RegisterNetEvent('qb-npc-market:updateCurrentHour', function(hour)
    CurrentHourVN = hour
end)

local function ShouldSpawnNPC(npc)
    if not npc.time then return true end
    local startHour = npc.time.starttime
    local endHour = npc.time.endtime
    if startHour > endHour then
        return CurrentHourVN >= startHour or CurrentHourVN < endHour
    else
        return CurrentHourVN >= startHour and CurrentHourVN < endHour
    end
end

local function CanAccessNPC(npc)
    if not isPlayerLoaded then return false end
    if not npc.requiredJob then return true end
    if not PlayerData.job then return false end
    local playerJob = PlayerData.job.name
    local playerGrade = PlayerData.job.grade.level
    for job, reqGrade in pairs(npc.requiredJob) do
        if playerJob == job and playerGrade >= reqGrade then
            return true
        end
    end
    return false
end

function RefreshAllTargets()
    for idx, ped in pairs(SpawnedPeds) do
        local npc = Config.MarketNPCs[idx]
        if npc and DoesEntityExist(ped) then
            exports.ox_target:removeLocalEntity(ped)
            if CanAccessNPC(npc) then
                exports.ox_target:addLocalEntity(ped, {
                    {
                        name = 'npc_market_' .. npc.id,
                        icon = 'fas fa-shopping-basket',
                        label = npc.label,
                        distance = 2.5,
                        onSelect = function()
                            if isInventoryOpen() then
                                lib.notify({ title = 'Vui lòng đóng inventory trước!', type = 'error' })
                                return
                            end
                            TriggerEvent('qb-npc-market:openUI', npc.id)
                        end
                    }
                })
            end
        end
    end
end

local function SpawnNPC(idx, npc)
    if SpawnedPeds[idx] and DoesEntityExist(SpawnedPeds[idx]) then return end

    RequestModel(npc.ped)
    while not HasModelLoaded(npc.ped) do Wait(10) end

    local ped = CreatePed(4, npc.ped, npc.coords.x, npc.coords.y, npc.coords.z - 1, npc.coords.w, false, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_STAND_IMPATIENT', 0, true)
    FreezeEntityPosition(ped, true)

    SpawnedPeds[idx] = ped

    if CanAccessNPC(npc) then
        exports.ox_target:addLocalEntity(ped, {
            {
                name = 'npc_market_' .. npc.id,
                icon = 'fas fa-shopping-basket',
                label = npc.label,
                distance = 2.5,
                onSelect = function()
                    if isInventoryOpen() then return end
                    TriggerEvent('qb-npc-market:openUI', npc.id)
                end
            }
        })
    end
end

local function DeleteNPC(idx)
    if SpawnedPeds[idx] and DoesEntityExist(SpawnedPeds[idx]) then
        exports.ox_target:removeLocalEntity(SpawnedPeds[idx])
        DeleteEntity(SpawnedPeds[idx])
        SpawnedPeds[idx] = nil
    end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = exports.qbx_core:GetPlayerData()
    isPlayerLoaded = true
    RefreshAllTargets()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(jobInfo)
    PlayerData.job = jobInfo
    RefreshAllTargets()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    isPlayerLoaded = false
    PlayerData = {}
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    local pd = exports.qbx_core:GetPlayerData()
    if pd and pd.citizenid then
        PlayerData = pd
        isPlayerLoaded = true
    end
end)

CreateThread(function()
    while not isPlayerLoaded do Wait(100) end
    Wait(2000)
    lib.callback('qb-npc-market:getCurrentHour', false, function(hour)
        CurrentHourVN = hour
        for idx, npc in ipairs(Config.MarketNPCs) do
            if npc.enabled and ShouldSpawnNPC(npc) then
                SpawnNPC(idx, npc)
            end
        end
    end)
end)

CreateThread(function()
    while not isPlayerLoaded do Wait(1000) end
    while true do
        Wait(60000)
        for idx, npc in ipairs(Config.MarketNPCs) do
            if npc.enabled then
                local shouldSpawn = ShouldSpawnNPC(npc)
                local isSpawned = SpawnedPeds[idx] and DoesEntityExist(SpawnedPeds[idx])
                if shouldSpawn and not isSpawned then
                    SpawnNPC(idx, npc)
                elseif not shouldSpawn and isSpawned then
                    DeleteNPC(idx)
                end
            end
        end
    end
end)

RegisterNetEvent('qb-npc-market:openUI', function(npcId)
    if isInventoryOpen() then return end

    local npcChosen = nil
    for _, npc in ipairs(Config.MarketNPCs) do
        if npc.id == npcId then
            npcChosen = npc
            break
        end
    end
    if not npcChosen then
        lib.notify({ title = 'Không tìm thấy sạp', type = 'error' })
        return
    end

    lib.callback('qb-npc-market:getMarketData', false, function(marketData)
        if not marketData then
            lib.notify({ title = 'Lỗi dữ liệu chợ', type = 'error' })
            return
        end
        if isInventoryOpen() then return end

        isMarketOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({ type = 'open', market = marketData })

        Wait(500)
        TriggerEvent('okokchat:client:CloseChat')

        CreateThread(function()
            while isMarketOpen do
                Wait(1000)
                if isInventoryOpen() then
                    isMarketOpen = false
                    SetNuiFocus(false, false)
                    SendNUIMessage({ type = 'close' })
                    break
                end
            end
        end)
    end, npcChosen.id)
end)

local function createMarketBlips()
    if not Config.MarketBlips then return end
    for _, blipInfo in ipairs(Config.MarketBlips) do
        local blip = AddBlipForCoord(blipInfo.coords.x, blipInfo.coords.y, blipInfo.coords.z)
        SetBlipSprite(blip, blipInfo.sprite or 52)
        SetBlipDisplay(blip, blipInfo.display or 4)
        SetBlipScale(blip, blipInfo.scale or 0.8)
        SetBlipColour(blip, blipInfo.color or 2)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(blipInfo.name or 'Market')
        EndTextCommandSetBlipName(blip)
    end
end

CreateThread(function()
    Wait(1000)
    createMarketBlips()
end)

RegisterNUICallback('buy', function(data, cb)
    if isInventoryOpen() then
        lib.notify({ title = 'Không thể mua khi inventory đang mở!', type = 'error' })
        cb('error')
        return
    end
    if not data.amount or type(data.amount) ~= 'number' then
        lib.notify({ title = 'Số lượng không hợp lệ', type = 'error' })
        cb('error')
        return
    end
    if data.amount <= 0 then
        lib.notify({ title = 'Số lượng phải lớn hơn 0', type = 'error' })
        cb('error')
        return
    end
    if math.floor(data.amount) ~= data.amount then
        lib.notify({ title = 'Số lượng phải là số nguyên', type = 'error' })
        cb('error')
        return
    end
    if GetResourceState('svc_runtime') == 'started' then
        exports['svc_runtime']:ExecuteServerEvent('qb-npc-market:buyItem', data.npcId, data.item, data.amount)
    else
        TriggerServerEvent('qb-npc-market:buyItem', data.npcId, data.item, data.amount)
    end
    cb('ok')
end)

RegisterNUICallback('sell', function(data, cb)
    if isInventoryOpen() then
        lib.notify({ title = 'Không thể bán khi inventory đang mở!', type = 'error' })
        cb('error')
        return
    end
    if not data.amount or type(data.amount) ~= 'number' then
        lib.notify({ title = 'Số lượng không hợp lệ', type = 'error' })
        cb('error')
        return
    end
    if data.amount <= 0 then
        lib.notify({ title = 'Số lượng phải lớn hơn 0', type = 'error' })
        cb('error')
        return
    end
    if math.floor(data.amount) ~= data.amount then
        lib.notify({ title = 'Số lượng phải là số nguyên', type = 'error' })
        cb('error')
        return
    end
    if GetResourceState('svc_runtime') == 'started' then
        exports['svc_runtime']:ExecuteServerEvent('qb-npc-market:sellItem', data.npcId, data.item, data.amount)
    else
        TriggerServerEvent('qb-npc-market:sellItem', data.npcId, data.item, data.amount)
    end
    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    isMarketOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNetEvent('qb-npc-market:updateItemAmount', function(itemName, newAmount)
    if isMarketOpen then
        SendNUIMessage({ type = 'updateItemAmount', itemName = itemName, amount = newAmount })
    end
end)

RegisterNUICallback('checkout', function(data, cb)
    if isInventoryOpen() then
        lib.notify({ title = 'Không thể mua khi inventory đang mở!', type = 'error' })
        cb('error')
        return
    end
    if type(data.items) ~= 'table' or #data.items == 0 then
        cb('error')
        return
    end
    local paymentType = data.paymentType
    if paymentType ~= 'cash' and paymentType ~= 'bank' and paymentType ~= 'dirty' then
        paymentType = 'cash'
    end
    if GetResourceState('svc_runtime') == 'started' then
        exports['svc_runtime']:ExecuteServerEvent('qb-npc-market:checkout', data.npcId, data.items, paymentType)
    else
        TriggerServerEvent('qb-npc-market:checkout', data.npcId, data.items, paymentType)
    end
    cb('ok')
end)

RegisterNetEvent('qb-npc-market:updateMoney', function(cash, bank, dirty)
    if isMarketOpen then
        SendNUIMessage({ type = 'updateMoney', cash = cash, bank = bank, dirty = dirty })
    end
end)