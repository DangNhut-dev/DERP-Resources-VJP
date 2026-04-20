local spawnedNPCs = {}
local watchedOrders = {}  -- Orders cua chinh player (co option giao hang)
local foreignOrders = {}  -- Orders cua player khac (chi hien NPC, khong co target)
local dispatchSent = {}
local blips = {}

local function LoadModel(model)
    if HasModelLoaded(model) then return true end
    RequestModel(model)
    local timeout = GetGameTimer() + 3000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do
        Wait(10)
    end
    return HasModelLoaded(model)
end

-- Spawn NPC tai location cho 1 order
local function SpawnDeliveryNPC(order)
    if spawnedNPCs[order.id] and DoesEntityExist(spawnedNPCs[order.id].ped) then return end
    if not order.npc or not order.npc.ped then
        if Config.Debug then
            print(('[weedshop] Spawn fail order #%s: thieu npc/ped data'):format(tostring(order.id)))
        end
        return
    end
    if not order.location or not order.location.coords then
        if Config.Debug then
            print(('[weedshop] Spawn fail order #%s: thieu location'):format(tostring(order.id)))
        end
        return
    end

    if not LoadModel(order.npc.ped) then
        if Config.Debug then
            print(('[weedshop] Spawn fail order #%s: khong load duoc model %s'):format(
                tostring(order.id), tostring(order.npc.ped)))
        end
        return
    end

    local c = order.location.coords
    local ped = CreatePed(4, order.npc.ped, c.x, c.y, c.z - 1.0, c.w or 0.0, false, true)
    if not ped or ped == 0 then
        if Config.Debug then print('[weedshop] CreatePed fail') end
        return
    end

    if Config.Debug then
        print(('[weedshop] Spawned NPC #%d (%s) cho order #%d tai %.1f,%.1f,%.1f'):format(
            order.npc.id, order.npc.name or '?', order.id, c.x, c.y, c.z))
    end

    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 17, true)
    SetPedCanRagdoll(ped, false)
    SetPedDiesWhenInjured(ped, false)
    FreezeEntityPosition(ped, false)
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_STAND_IMPATIENT', 0, true)

    SetModelAsNoLongerNeeded(order.npc.ped)

    spawnedNPCs[order.id] = {
        ped = ped,
        orderId = order.id,
        npcId = order.npc.id,
        npcName = order.npc.name,
        foreign = order.foreign or false
    }

    -- Chi add ox_target cho NPC cua chinh player (owner)
    if not order.foreign then
        exports.ox_target:addLocalEntity(ped, {
            {
                name = 'derp_weedshop_deliver_' .. order.id,
                label = 'Giao hang (' .. order.amount .. 'g)',
                icon = 'fa-solid fa-hand-holding-dollar',
                distance = 2.0,
                onSelect = function()
                    TriggerEvent('derp-weedshop:client:tryDeliver', order.id)
                end
            }
        })
    end
end

-- Despawn NPC cua 1 order
local function DespawnNPC(orderId)
    local data = spawnedNPCs[orderId]
    if not data then return end

    if data.ped and DoesEntityExist(data.ped) then
        exports.ox_target:removeLocalEntity(data.ped, { 'derp_weedshop_deliver_' .. orderId })

        -- Walk away roi delete
        local px, py, pz = table.unpack(GetEntityCoords(data.ped))
        TaskWanderStandard(data.ped, 10.0, 10)
        SetEntityAsMissionEntity(data.ped, true, true)

        CreateThread(function()
            Wait(15000)
            if DoesEntityExist(data.ped) then
                DeleteEntity(data.ped)
            end
        end)
    end

    spawnedNPCs[orderId] = nil
end

-- Tao blip cho order
local function CreateOrderBlip(order)
    if blips[order.id] then return end
    if not order.location or not order.location.coords then return end
    local c = order.location.coords
    local blip = AddBlipForCoord(c.x, c.y, c.z)
    SetBlipSprite(blip, 500)
    SetBlipColour(blip, 2)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Giao hang: ' .. (order.location.label or ''))
    EndTextCommandSetBlipName(blip)
    blips[order.id] = blip
end

local function RemoveOrderBlip(orderId)
    if blips[orderId] then
        RemoveBlip(blips[orderId])
        blips[orderId] = nil
    end
end

-- Watch active orders
local function AddWatchedOrder(order)
    watchedOrders[order.id] = order
    CreateOrderBlip(order)
end

local function RemoveWatchedOrder(orderId)
    watchedOrders[orderId] = nil
    DespawnNPC(orderId)
    RemoveOrderBlip(orderId)
    dispatchSent[orderId] = nil
end

-- Sync orders tu server
RegisterNetEvent('derp-weedshop:client:syncOrders', function(orders)
    if Config.Debug then
        print(('[weedshop] syncOrders nhan %d orders'):format(#(orders or {})))
        for _, o in ipairs(orders or {}) do
            print(('[weedshop]   Order #%s: npc_id=%s deadline_unix=%s deadline_at=%s location=%s'):format(
                tostring(o.id),
                tostring(o.npc_id),
                tostring(o.deadline_unix),
                tostring(o.deadline_at),
                tostring(o.location and o.location.label or 'nil')
            ))
            if o.npc then
                print(('[weedshop]     npc: id=%s name=%s ped=%s'):format(
                    tostring(o.npc.id), tostring(o.npc.name), tostring(o.npc.ped)))
            else
                print('[weedshop]     npc: nil')
            end
        end
    end
    -- Remove orders khong con
    local activeIds = {}
    for _, o in ipairs(orders or {}) do activeIds[o.id] = true end
    for id, _ in pairs(watchedOrders) do
        if not activeIds[id] then RemoveWatchedOrder(id) end
    end
    -- Add orders moi
    for _, o in ipairs(orders or {}) do
        if not watchedOrders[o.id] then
            AddWatchedOrder(o)
        else
            -- Update data (deadline, npc) neu da watched
            watchedOrders[o.id] = o
        end
    end
end)

RegisterNetEvent('derp-weedshop:client:orderEnded', function(orderId)
    RemoveWatchedOrder(orderId)
    if foreignOrders[orderId] then
        foreignOrders[orderId] = nil
        DespawnNPC(orderId)
    end
end)

-- Sync foreign orders (NPC cua player khac) tu server
-- Server broadcast khi order moi tao va khi order ket thuc
RegisterNetEvent('derp-weedshop:client:foreignOrderAdd', function(order)
    if not order or not order.id then return end
    -- Tranh overlap voi own order
    if watchedOrders[order.id] then return end
    order.foreign = true
    foreignOrders[order.id] = order
end)

RegisterNetEvent('derp-weedshop:client:foreignOrderRemove', function(orderId)
    if not orderId then return end
    foreignOrders[orderId] = nil
    if spawnedNPCs[orderId] and spawnedNPCs[orderId].foreign then
        DespawnNPC(orderId)
    end
end)

-- Full sync foreign orders khi player join / resource start
RegisterNetEvent('derp-weedshop:client:syncForeignOrders', function(orders)
    -- Clear cu
    for id, _ in pairs(foreignOrders) do
        if spawnedNPCs[id] and spawnedNPCs[id].foreign then
            DespawnNPC(id)
        end
    end
    foreignOrders = {}
    -- Add moi
    for _, o in ipairs(orders or {}) do
        if not watchedOrders[o.id] then
            o.foreign = true
            foreignOrders[o.id] = o
        end
    end
end)

-- Thread check proximity -> spawn/despawn NPC + trigger dispatch
CreateThread(function()
    while true do
        local sleep = 2000
        local ped = cache.ped
        local hasAny = next(watchedOrders) or next(foreignOrders)
        if ped and ped ~= 0 and hasAny then
            local coords = GetEntityCoords(ped)
            local now = GetCloudTimeAsInt()
            local earlyWindowSec = (Config.DeliveryWindows and Config.DeliveryWindows.earlyWindowMinutes or 5) * 60
            local lateMaxSec = earlyWindowSec + ((Config.DeliveryWindows and Config.DeliveryWindows.ontimeWindowMinutes or 5) * 60)
                                            + ((Config.DeliveryWindows and Config.DeliveryWindows.lateWindowMinutes or 5) * 60)

            -- Process own orders (co dispatch + target)
            for orderId, order in pairs(watchedOrders) do
                if order.location and order.location.coords then
                    local c = order.location.coords
                    local dist = #(coords - vector3(c.x, c.y, c.z))
                    local deadlineUnix = tonumber(order.deadline_unix) or 0
                    local spawnFromUnix = deadlineUnix - earlyWindowSec
                    local spawnUntilUnix = deadlineUnix + (lateMaxSec - earlyWindowSec)
                    local npcShouldBePresent = deadlineUnix > 0
                        and now >= spawnFromUnix
                        and now <= spawnUntilUnix

                    if dist < Config.NPCSpawnRadius and npcShouldBePresent then
                        sleep = 500
                        if not spawnedNPCs[orderId] then
                            SpawnDeliveryNPC(order)
                        end

                        if dist < Config.DispatchRadius and not dispatchSent[orderId] then
                            dispatchSent[orderId] = true
                            local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
                            local streetLabel = GetStreetNameFromHashKey(streetHash)
                            TriggerServerEvent('derp-weedshop:server:triggerDispatch', {
                                coords = { x = coords.x, y = coords.y, z = coords.z },
                                streetLabel = streetLabel
                            })
                        end
                    elseif dist > Config.NPCDespawnRadius or not npcShouldBePresent then
                        if spawnedNPCs[orderId] then
                            DespawnNPC(orderId)
                        end
                    end
                end
            end

            -- Process foreign orders (chi spawn NPC, khong target, khong dispatch)
            for orderId, order in pairs(foreignOrders) do
                if order.location and order.location.coords then
                    local c = order.location.coords
                    local dist = #(coords - vector3(c.x, c.y, c.z))
                    local deadlineUnix = tonumber(order.deadline_unix) or 0
                    local spawnFromUnix = deadlineUnix - earlyWindowSec
                    local spawnUntilUnix = deadlineUnix + (lateMaxSec - earlyWindowSec)
                    local npcShouldBePresent = deadlineUnix > 0
                        and now >= spawnFromUnix
                        and now <= spawnUntilUnix

                    if dist < Config.NPCSpawnRadius and npcShouldBePresent then
                        sleep = 500
                        if not spawnedNPCs[orderId] then
                            SpawnDeliveryNPC(order)
                        end
                    elseif dist > Config.NPCDespawnRadius or not npcShouldBePresent then
                        if spawnedNPCs[orderId] then
                            DespawnNPC(orderId)
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

-- Cleanup khi resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for orderId, _ in pairs(spawnedNPCs) do DespawnNPC(orderId) end
    for orderId, _ in pairs(blips) do RemoveBlip(blips[orderId]) end
end)

-- Request foreign orders sync khi resource start
CreateThread(function()
    Wait(3000) -- Cho player load xong
    TriggerServerEvent('derp-weedshop:server:requestForeignSync')
end)

-- Export cho main.lua
_WeedshopNPC = {
    SpawnDeliveryNPC = SpawnDeliveryNPC,
    DespawnNPC = DespawnNPC,
    AddWatchedOrder = AddWatchedOrder,
    RemoveWatchedOrder = RemoveWatchedOrder,
    GetWatchedOrders = function() return watchedOrders end
}