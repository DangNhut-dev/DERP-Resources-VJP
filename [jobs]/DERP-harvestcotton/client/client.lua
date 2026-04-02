local treeProps     = {}   -- [idx] = entity handle
local treeStates    = {}   -- [idx] = { available = bool }
local treeAvailable = {}   -- [idx] = bool (alias dùng trong target)
local isHarvesting  = false
local npcModelHash  = nil
local propHashReady    = nil
local propHashCooldown = nil
local streamerReady    = false

-- Pre-load tất cả model cần thiết
Citizen.CreateThread(function()
    local nHash = GetHashKey(Config.NpcModel)
    local rHash = GetHashKey(Config.PropReady)
    local cHash = GetHashKey(Config.PropCooldown)

    RequestModel(nHash)
    RequestModel(rHash)
    RequestModel(cHash)

    local deadline = GetGameTimer() + 10000
    while not (HasModelLoaded(nHash) and HasModelLoaded(rHash) and HasModelLoaded(cHash)) do
        if GetGameTimer() > deadline then break end
        Citizen.Wait(50)
    end

    npcModelHash       = nHash
    propHashReady      = rHash
    propHashCooldown   = cHash
    streamerReady      = true
end)

-- Spawn NPC tại vị trí xác định, đánh bat + ragdoll target rồi despawn
local function spawnSlappingNpc(spawnCoords, npcHeading, isTarget)
    if not npcModelHash then return end

    local npc = CreatePed(4, npcModelHash, spawnCoords.x, spawnCoords.y, spawnCoords.z, npcHeading, false, true)
    if not DoesEntityExist(npc) or npc == 0 then return end

    SetEntityAsMissionEntity(npc, true, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetPedCanRagdoll(npc, false)
    SetPedFleeAttributes(npc, 0, false)
    SetEntityInvincible(npc, true)

    Citizen.CreateThread(function()
        local batHash = GetHashKey('WEAPON_BAT')
        RequestWeaponAsset(batHash, 31, 0)
        local deadline = GetGameTimer() + 5000
        while not HasWeaponAssetLoaded(batHash) do
            if GetGameTimer() > deadline then break end
            Citizen.Wait(10)
        end
        if not DoesEntityExist(npc) then return end
        GiveWeaponToPed(npc, batHash, 1, false, true)
        SetCurrentPedWeapon(npc, batHash, true)

        local dict = 'melee@unarmed@streamed_core'
        RequestAnimDict(dict)
        deadline = GetGameTimer() + 3000
        while not HasAnimDictLoaded(dict) do
            if GetGameTimer() > deadline then break end
            Citizen.Wait(10)
        end
        if not DoesEntityExist(npc) then return end

        Citizen.Wait(400)
        if HasAnimDictLoaded(dict) then
            TaskPlayAnim(npc, dict, 'heavy_punch_a', 8.0, -8.0, 3000, 0, 0.0, false, false, false)
        end

        -- Chỉ apply damage + ragdoll + control cho target player
        if isTarget then
            Citizen.Wait(700)
            local ped = PlayerPedId()
            if DoesEntityExist(ped) then
                SetPedSuffersCriticalHits(ped, false)
                ApplyDamageToPed(ped, 15, false)
                SetPedToRagdoll(ped, 2000, 2000, 0, false, false, false)
            end
            Citizen.Wait(2000)
            EnableAllControlActions(0)
        end

        Citizen.Wait(isTarget and 500 or 3100)
        if DoesEntityExist(npc) then
            ClearPedTasks(npc)
            DeleteEntity(npc)
        end
    end)
end

-- Flow: minigame -> progressbar hoặc npc tát
local function startHarvest(treeIdx)
    exports['boii_minigames']:skill_circle({
        style     = 'default',
        icon      = 'fa-solid fa-seedling',
        area_size = Config.SkillCircle.area_size,
        speed     = Config.SkillCircle.speed,
    }, function(result)
        if result == 'perfect' or result == 'success' then
            Citizen.CreateThread(function()
                local ok = lib.progressBar({
                    duration     = Config.ProgressBarTime,
                    label        = 'Đang thu hoạch bông...',
                    useWhileDead = false,
                    canCancel    = false,
                    disable      = { move = true, car = true, combat = true },
                    anim         = {
                        dict = 'amb@world_human_gardener_plant@male@base',
                        clip = 'base',
                    },
                })
                if ok then
                    local ped     = PlayerPedId()
                    local coords  = GetEntityCoords(ped)
                    local heading = GetEntityHeading(ped)
                    TriggerServerEvent('derp-harvestcotton:server:harvest', treeIdx, true, coords.x, coords.y, coords.z, heading)
                end
                isHarvesting = false
            end)
        else
            local ped     = PlayerPedId()
            local coords  = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            DisableAllControlActions(0)
            TriggerServerEvent('derp-harvestcotton:server:harvest', treeIdx, false, coords.x, coords.y, coords.z, heading)
            isHarvesting = false
        end
    end)
end

-- Spawn 1 prop (model đã pre-load, không cần RequestModel)
local function spawnProp(hash, coords)
    local obj = CreateObject(hash, coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(obj, coords.w or 0.0)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
    return obj
end

-- Gắn ox_target lên prop cây
local function addTreeTarget(treeIdx, entity)
    exports.ox_target:addLocalEntity(entity, {
        {
            name     = 'harvest_cotton_' .. treeIdx,
            label    = 'Thu hoạch bông',
            icon     = 'fas fa-seedling',
            distance = 2.5,
            onSelect = function()
                if isHarvesting or not treeAvailable[treeIdx] then return end

                local ped = PlayerPedId()

                if IsPedInAnyVehicle(ped, false) then
                    lib.notify({ title = 'Thu hoạch bông', description = 'Bạn đang ở trên xe', type = 'error' })
                    return
                end

                local slots = exports.ox_inventory:Search('slots', 'scissors')
                if not slots or not next(slots) then
                    lib.notify({ title = 'Thu hoạch bông', description = 'Bạn cần kéo để thu hoạch', type = 'error' })
                    return
                end
                local hasUsable = false
                for _, slot in pairs(slots) do
                    local dur = slot.metadata and slot.metadata.durability
                    if dur == nil or dur > 0 then
                        hasUsable = true
                        break
                    end
                end
                if not hasUsable then
                    lib.notify({ title = 'Thu hoạch bông', description = 'Kéo của bạn đã hỏng', type = 'error' })
                    return
                end
                isHarvesting = true
                startHarvest(treeIdx)
            end,
        }
    })
end

-- Xóa prop đang spawn của 1 cây
local function despawnTree(treeIdx)
    local prop = treeProps[treeIdx]
    if prop and DoesEntityExist(prop) then
        pcall(function() exports.ox_target:removeLocalEntity(prop) end)
        DeleteObject(prop)
    end
    treeProps[treeIdx] = nil
end

-- Spawn prop đúng model theo trạng thái
local function spawnTree(treeIdx)
    local state = treeStates[treeIdx]
    if not state then return end
    local tree  = Config.Trees[treeIdx]
    local hash  = state.available and propHashReady or propHashCooldown
    if not hash then return end

    local obj = spawnProp(hash, tree.coords)
    treeProps[treeIdx] = obj
    treeAvailable[treeIdx] = state.available

    if state.available then
        addTreeTarget(treeIdx, obj)
    end
end

-- Streaming thread: check mỗi 1500ms, spawn/despawn theo khoảng cách
Citizen.CreateThread(function()
    while not streamerReady do
        Citizen.Wait(200)
    end
    while true do
        Citizen.Wait(1500)
        local ped    = PlayerPedId()
        local pc     = GetEntityCoords(ped)
        local range2 = Config.StreamRange * Config.StreamRange

        for i, tree in ipairs(Config.Trees) do
            local tc = tree.coords
            local dx = pc.x - tc.x
            local dy = pc.y - tc.y
            local d2 = dx * dx + dy * dy

            local spawned = treeProps[i] and DoesEntityExist(treeProps[i])

            if d2 <= range2 then
                if not spawned then
                    spawnTree(i)
                else
                    -- Nếu trạng thái thay đổi trong khi đang trong range: swap prop
                    local state = treeStates[i]
                    if state then
                        local curAvail = treeAvailable[i]
                        if curAvail ~= state.available then
                            despawnTree(i)
                            spawnTree(i)
                        end
                    end
                end
            else
                if spawned then
                    despawnTree(i)
                end
            end
        end
    end
end)

-- Xin trạng thái cây từ server khi resource khởi động
AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Citizen.CreateThread(function()
        while not NetworkIsPlayerActive(PlayerId()) do
            Citizen.Wait(500)
        end
        TriggerServerEvent('derp-harvestcotton:server:requestStates')
    end)
end)

-- Dọn dẹp prop khi resource dừng
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for i, prop in pairs(treeProps) do
        if DoesEntityExist(prop) then
            DeleteObject(prop)
        end
        treeProps[i] = nil
    end
end)

-- Nhận lệnh spawn NPC từ server (broadcast cho tất cả)
RegisterNetEvent('derp-harvestcotton:client:spawnSlapper', function(sx, sy, sz, npcHeading, targetServerId)
    local spawnCoords = vector3(sx, sy, sz)
    local isTarget    = GetPlayerServerId(PlayerId()) == targetServerId
    spawnSlappingNpc(spawnCoords, npcHeading, isTarget)
end)

-- Nhận trạng thái ban đầu từ server — streamer thread sẽ tự spawn khi trong range
RegisterNetEvent('derp-harvestcotton:client:initStates', function(states)
    for i, state in pairs(states) do
        treeStates[i] = { available = state.available }
    end
end)

-- Cập nhật trạng thái 1 cây khi cooldown bắt đầu/kết thúc
-- Streaming thread sẽ detect thay đổi và swap prop nếu đang trong range
RegisterNetEvent('derp-harvestcotton:client:setTreeState', function(treeIdx, available)
    if not treeStates[treeIdx] then treeStates[treeIdx] = {} end
    treeStates[treeIdx].available = available
end)