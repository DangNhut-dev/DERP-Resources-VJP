local blipsArray   = {}
local createdTrees = {}
local hasJob       = false
local hasVeh       = false
local npcEntity    = nil

local function contains(array, item)
    for _, value in ipairs(array) do
        if value == item then return true end
    end
    return false
end

-- Spawn NPC Axel tại coords config
local function spawnNpc()
    local model = GetHashKey(Config.npc.model)
    RequestModel(model)
    local deadline = GetGameTimer() + 5000
    while not HasModelLoaded(model) do
        if GetGameTimer() > deadline then return end
        Citizen.Wait(10)
    end

    local c   = Config.npc.coords
    local ped = CreatePed(4, model, c.x, c.y, c.z, c.w, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanRagdoll(ped, false)
    SetPedFleeAttributes(ped, 0, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    TaskStartScenarioInPlace(ped, Config.npc.scenario, 0, true)
    SetModelAsNoLongerNeeded(model)
    npcEntity = ped

    -- ox_target trên NPC
    exports.ox_target:addLocalEntity(ped, {
        {
            name     = 'lumberjack_npc_talk',
            label    = 'Nói chuyện với quản lý',
            icon     = 'fas fa-comment',
            distance = 2.0,
            onSelect = function()
                if IsPedInAnyVehicle(PlayerPedId(), false) then
                    Notify('Bạn đang ở trên xe!', 'error')
                    return
                end
                lib.showContext('lumberjack_main')
            end,
        }
    })
end

-- Menu chính
lib.registerContext({
    id    = 'lumberjack_main',
    title = 'Quản Lý Xưởng Gỗ',
    options = {
        {
            title    = 'Chấm công vào / ra',
            icon     = 'fas fa-sign-in-alt',
            onSelect = function()
                TriggerServerEvent('pyh-lumberjack:Sign')
            end,
        },
        -- {
        --     title    = 'Thuê xe Bison',
        --     icon     = 'fas fa-truck',
        --     onSelect = function()
        --         TriggerServerEvent('pyh-lumberjack:rentBison')
        --     end,
        -- },
        {
            title    = 'Cửa hàng dụng cụ',
            icon     = 'fas fa-shopping-cart',
            onSelect = function()
                lib.showContext('lumberjack_shop')
            end,
        },
        {
            title    = 'Bán gỗ thành phẩm',
            icon     = 'fas fa-dollar-sign',
            onSelect = function()
                TriggerServerEvent('pyh-lumberjack:sellWood')
            end,
        },
    }
})

-- Menu shop
lib.registerContext({
    id    = 'lumberjack_shop',
    title = 'Cửa hàng dụng cụ',
    menu  = 'lumberjack_main',
    options = {
        {
            title    = 'Rìu - $350',
            icon     = 'fas fa-hammer',
            image    = 'nui://ox_inventory/web/images/axe.png',
            onSelect = function()
                TriggerServerEvent('pyh-lumberjack:buyAxe')
            end,
        },
    }
})

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    spawnNpc()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if npcEntity and DoesEntityExist(npcEntity) then
        exports.ox_target:removeLocalEntity(npcEntity)
        DeleteEntity(npcEntity)
    end
    deleteCreatedTrees()
end)

local function createBlipsFromData(dataList)
    for _, data in ipairs(dataList) do
        local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
        SetBlipSprite(blip, data.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, data.scale)
        SetBlipColour(blip, data.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(data.label)
        EndTextCommandSetBlipName(blip)
        table.insert(blipsArray, blip)
    end
end

function deleteCreatedTrees()
    for i, tree in ipairs(createdTrees) do
        if DoesEntityExist(tree) then
            pcall(function()
                exports.ox_target:removeLocalEntity(tree)
            end)
            DeleteObject(tree)
        end
    end
    createdTrees = {}
end

function deleteBlips()
    for _, blip in ipairs(blipsArray) do
        RemoveBlip(blip)
    end
    blipsArray = {}
end

local function hasTreeFallen(entity)
    local rotation = GetEntityRotation(entity, 2)
    return math.abs(rotation.x) > 60.0
end

local function fallTree(entity)
    local rotation   = GetEntityRotation(entity, 2)
    local heading    = rotation.z  -- giữ nguyên heading hiện tại
    local pitch      = 0.0         -- bắt đầu từ thẳng đứng
    local startTime  = GetGameTimer()

    -- Chọn ngẫu nhiên ngã trái hoặc phải
    local direction  = (math.random(0, 1) == 0) and 1 or -1

    Citizen.CreateThread(function()
        while true do
            local now     = GetGameTimer()
            local elapsed = now - startTime

            pitch = pitch + (elapsed / 5) * (pitch / 250 + 0.3) * direction
            SetEntityRotation(entity, pitch, 0.0, heading, 2, true)

            if math.abs(pitch) >= 90.0 then
                SetEntityRotation(entity, 90.0 * direction, 0.0, heading, 2, true)
                break
            end

            startTime = now
            Citizen.Wait(0)
        end
    end)
end

local function spawnTreeAt(index)
    local item  = Config.trees[index]
    local model = Config.treeModel
    RequestModel(model)
    local deadline = GetGameTimer() + 5000
    while not HasModelLoaded(model) do
        if GetGameTimer() > deadline then return end
        Citizen.Wait(10)
    end

    local tree = CreateObject(GetHashKey(model), item.coords.x, item.coords.y, item.coords.z - 1, false, false, false)
    SetEntityRotation(tree, 0.0, 0.0, 0.0, 2, true)  -- đảm bảo cây thẳng đứng
    FreezeEntityPosition(tree, true)
    SetEntityAsMissionEntity(tree, true, true)
    createdTrees[index] = tree

    exports.ox_target:addLocalEntity(tree, {
        {
            name     = 'lumberjack_tree' .. index,
            label    = 'Chặt cây',
            icon     = 'fas fa-tree',
            distance = 2.0,
            onSelect = function()
                if IsPedInAnyVehicle(PlayerPedId(), false) then
                    Notify('Bạn đang ở trên xe!', 'error')
                    return
                end
                TriggerEvent('pyh-lumberjack:useAxe', index)
            end,
        }
    })
end

local function removeTreeAt(index)
    local tree = createdTrees[index]
    if tree and DoesEntityExist(tree) then
        pcall(function() exports.ox_target:removeLocalEntity(tree) end)
        DeleteObject(tree)
    end
    createdTrees[index] = nil
end

local function makeTrees()
    for index = 1, #Config.trees do
        Citizen.CreateThread(function()
            spawnTreeAt(index)
        end)
    end
    SetModelAsNoLongerNeeded(Config.treeModel)
end

-- Nhận state change từ server
RegisterNetEvent('pyh-lumberjack:setTreeState')
AddEventHandler('pyh-lumberjack:setTreeState', function(treeIdx, state)
    if state == 'fallen' then
        local tree = createdTrees[treeIdx]
        if tree and DoesEntityExist(tree) then
            -- Giữ freeze, chỉ rotate để cây ngã animation, không để physics kéo xuống
            fallTree(tree)
        end
    elseif state == 'gone' then
        removeTreeAt(treeIdx)
    elseif state == 'standing' then
        if hasJob then
            Citizen.CreateThread(function()
                spawnTreeAt(treeIdx)
            end)
        end
    end
end)

local function initJob()
    if not hasJob then return end
    if #createdTrees > 0 then return end

    local dataList = {
        { coords = Config.getClean,   label = "Lumberjack - Process Logs",          sprite = 503, scale = 0.8, color = 17 },
        { coords = Config.getCleaned, label = "Lumberjack - Get Cleaned Logs",       sprite = 504, scale = 0.8, color = 17 },
        { coords = Config.sand,       label = "Lumberjack - Sand Planks",            sprite = 505, scale = 0.8, color = 17 },
        { coords = Config.finish,     label = "Lumberjack - Apply Wood Finish",      sprite = 506, scale = 0.8, color = 17 },
    }

    for _, tree in ipairs(Config.trees) do
        table.insert(dataList, { coords = tree.coords, label = 'Tree', sprite = 502, scale = 0.3, color = 17 })
    end

    makeTrees()

    exports.ox_target:addSphereZone({
        coords   = Config.getClean,
        radius   = 2.0,
        name     = 'lumberjack_getClean',
        options  = {{ label = 'Xử lý gỗ', icon = 'fas fa-industry', onSelect = function()
            if IsPedInAnyVehicle(PlayerPedId(), false) then
                Notify('Bạn đang ở trên xe!', 'error')
                return
            end
            TriggerServerEvent("pyh-lumberjack:requestProcess", "logs")
        end }}
    })

    exports.ox_target:addSphereZone({
        coords   = Config.getCleaned,
        radius   = 2.0,
        name     = 'lumberjack_getCleaned',
        options  = {{ label = 'Gỗ → Ván thô', icon = 'fas fa-cut', onSelect = function()
            if IsPedInAnyVehicle(PlayerPedId(), false) then
                Notify('Bạn đang ở trên xe!', 'error')
                return
            end
            TriggerServerEvent("pyh-lumberjack:requestProcess", "cleanLogs")
        end }}
    })

    exports.ox_target:addSphereZone({
        coords   = Config.sand,
        radius   = 2.0,
        name     = 'lumberjack_sand',
        options  = {{ label = 'Chà nhám ván', icon = 'fas fa-tools', onSelect = function()
            if IsPedInAnyVehicle(PlayerPedId(), false) then
                Notify('Bạn đang ở trên xe!', 'error')
                return
            end
            TriggerServerEvent("pyh-lumberjack:requestProcess", "rawPlanks")
        end }}
    })


    exports.ox_target:addSphereZone({
        coords   = Config.finish,
        radius   = 2.0,
        name     = 'lumberjack_finish',
        options  = {{ label = 'Hoàn thiện gỗ', icon = 'fas fa-paint-brush', onSelect = function()
            if IsPedInAnyVehicle(PlayerPedId(), false) then
                Notify('Bạn đang ở trên xe!', 'error')
                return
            end
            TriggerServerEvent("pyh-lumberjack:requestProcess", "sandedPlanks")
        end }}
    })

    createBlipsFromData(dataList)
end

RegisterNetEvent("pyh-lumberjack:Sign")
AddEventHandler("pyh-lumberjack:Sign", function()
    hasJob = not hasJob
    if hasJob then
        Notify("Bạn đã chấm công vào!", "success")
        initJob()
    else
        Notify("Bạn đã chấm công ra!", "error")
        deleteCreatedTrees()
        deleteBlips()
        exports.ox_target:removeZone('lumberjack_finish')
        exports.ox_target:removeZone('lumberjack_sand')
        exports.ox_target:removeZone('lumberjack_getCleaned')
        exports.ox_target:removeZone('lumberjack_getClean')
    end
end)

RegisterNetEvent("pyh-lumberjack:rentBison")
AddEventHandler("pyh-lumberjack:rentBison", function()
    if not hasJob then return end
    if hasVeh then
        Notify("You already took a work vehicle today!", "error")
        return
    end

    local spawnPoint = Config.VehCoords
    if IsAnyVehicleNearPoint(spawnPoint.x, spawnPoint.y, spawnPoint.z, 2.0) then
        Notify("Vehicle Spawn Occupied!", "error")
        return
    end

    Citizen.CreateThread(function()
        local model = GetHashKey("Bison")
        RequestModel(model)
        local deadline = GetGameTimer() + 5000
        while not HasModelLoaded(model) do
            if GetGameTimer() > deadline then return end
            Citizen.Wait(10)
        end

        local veh = CreateVehicle(model, spawnPoint.x, spawnPoint.y, spawnPoint.z, spawnPoint.w, false, false)
        SetEntityHeading(veh, spawnPoint.w)
        SetVehicleEngineOn(veh, false, false)
        SetVehicleOnGroundProperly(veh)
        SetVehicleNeedsToBeHotwired(veh, false)
        SetVehicleDoorsLocked(veh, 1)
        exports["LegacyFuel"]:SetFuel(veh, 100)
        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
        SetModelAsNoLongerNeeded(model)
        hasVeh = true
    end)
end)

RegisterNetEvent("pyh-lumberjack:useAxe")
AddEventHandler("pyh-lumberjack:useAxe", function(treeIdx)
    if not hasJob then return end
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        Notify('Bạn đang ở trên xe!', 'error')
        return
    end

    -- Support cả trigger từ ox_target (có treeIdx) lẫn usable item (không có)
    local playerPed     = PlayerPedId()
    local playerCoords  = GetEntityCoords(playerPed)
    local closestObject = nil

    if treeIdx and createdTrees[treeIdx] and DoesEntityExist(createdTrees[treeIdx]) then
        closestObject = createdTrees[treeIdx]
    else
        -- Fallback: tìm cây gần nhất trong createdTrees
        local bestDist = 5.0
        for i, tree in pairs(createdTrees) do
            if DoesEntityExist(tree) then
                local d = #(playerCoords - GetEntityCoords(tree))
                if d < bestDist then
                    bestDist      = d
                    closestObject = tree
                    treeIdx       = i
                end
            end
        end
    end

    if not closestObject then return end

    local isFallen     = hasTreeFallen(closestObject)
    local objectCoords = GetEntityCoords(closestObject)
    local heading      = GetHeadingFromVector_2d(objectCoords.x - playerCoords.x, objectCoords.y - playerCoords.y)

    local animDict, animName
    if not isFallen then
        SetEntityHeading(playerPed, heading)
        animDict = "lumberjack@anims"
        animName = "axe_swing"
    else
        animDict = "melee@large_wpn@streamed_core"
        animName = "ground_attack_on_spot"
    end

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(1)
    end

    local axeModel = GetHashKey("w_me_hatchet")
    RequestModel(axeModel)
    while not HasModelLoaded(axeModel) do
        Citizen.Wait(1)
    end

    local axe = CreateObject(axeModel, playerCoords.x, playerCoords.y, playerCoords.z, true, true, true)
    AttachEntityToEntity(axe, playerPed, GetPedBoneIndex(playerPed, 57005), 0.1, 0.0, 0.0, 90.0, 180.0, 180.0, true, true, false, true, 1, true)

    local finalIdx = treeIdx
    ProgBar("choppingtree", "Chặt cây", 15000, {
        disableMovement    = true,
        disableCarMovement = true,
        disableMouse       = false,
        disableCombat      = true,
    }, { animDict = animDict, anim = animName },
    function()
        DetachEntity(axe, true, false)
        DeleteObject(axe)
        ClearPedTasks(playerPed)
        TriggerServerEvent("pyh-lumberjack:chopTree", finalIdx)
    end,
    function()
        DetachEntity(axe, true, false)
        DeleteObject(axe)
        ClearPedTasks(playerPed)
    end)
end)

-- Nhận yêu cầu hiện progressbar xử lý gỗ từ server
local processLabels = {
    logs        = 'Đang xử lý gỗ...',
    cleanLogs   = 'Đang cắt thành ván thô...',
    rawPlanks   = 'Đang chà nhám...',
    sandedPlanks = 'Đang hoàn thiện gỗ...',
}

RegisterNetEvent('pyh-lumberjack:startProcessBar')
AddEventHandler('pyh-lumberjack:startProcessBar', function(processType, amount)
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        Notify('Bạn đang ở trên xe!', 'error')
        return
    end
    local label = processLabels[processType] or 'Đang xử lý...'

    ProgBar('lumberjack_process', label .. ' (' .. amount .. ')', 20000, {
        disableMovement    = true,
        disableCarMovement = true,
        disableMouse       = false,
        disableCombat      = true,
    }, { animDict = 'amb@world_human_gardener_plant@male@idle_a', anim = 'idle_b' },
    function()
        TriggerServerEvent('pyh-lumberjack:confirmProcess', processType, amount)
    end,
    function()
        Notify('Đã hủy xử lý!', 'warning')
    end)
end)