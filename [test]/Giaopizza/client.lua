local activeJob           = false
local jobVehicle          = 0
local currentZone         = nil
local currentBlip         = 0
local nearPoint           = false
local deliveryCooldown    = false
local takeCooldown        = false
local localAccumPay       = 0
local localTotalDelivered = 0
local deliveryCoords      = nil
local pizzaTaken          = false
local pizzaProp           = 0
local transitioning       = false

-- ─── Prop pizza ──────────────────────────────────────────────────────────────
local pizzaModelName = 'prop_pizza_box_01'
local pizzaModel     = GetHashKey(pizzaModelName)

local function attachPizzaProp()
    if DoesEntityExist(pizzaProp) then return end
    CreateThread(function()
        local ped = PlayerPedId()
        RequestModel(pizzaModel)
        local t = 0
        while not HasModelLoaded(pizzaModel) and t < 10000 do
            Wait(10)
            t = t + 10
        end
        if not HasModelLoaded(pizzaModel) then return end
        local coords = GetEntityCoords(ped)
        pizzaProp = CreateObject(pizzaModel, coords.x, coords.y, coords.z, true, true, false)
        SetModelAsNoLongerNeeded(pizzaModel)
        SetEntityCollision(pizzaProp, false, false)
        FreezeEntityPosition(pizzaProp, true)
        Wait(0)
        AttachEntityToEntity(
            pizzaProp, ped,
            GetPedBoneIndex(ped, 0),
            0.0, 0.60, 0.1,
            0.0, 0.0, 0.0,
            true, true, false, true, 1, true
        )
    end)
end

local animDict = 'anim@heists@box_carry@'
CreateThread(function()
    while true do
        Wait(500)
        if pizzaTaken then
            local ped = PlayerPedId()
            if not DoesEntityExist(pizzaProp) then
                pizzaProp = 0
                attachPizzaProp()
            elseif not IsEntityPlayingAnim(ped, animDict, 'idle', 3) then
                lib.requestAnimDict(animDict)
                TaskPlayAnim(ped, animDict, 'idle', 8.0, -8.0, -1, 49, 0, false, false, false)
            end
        end
    end
end)

local function detachPizzaProp()
    if DoesEntityExist(pizzaProp) then
        DetachEntity(pizzaProp, true, true)
        DeleteObject(pizzaProp)
        ClearPedTasks(PlayerPedId())
    end
    pizzaProp = 0
end

local function deleteJobVehicle()
    if DoesEntityExist(jobVehicle) then
        DeleteEntity(jobVehicle)
    end
    jobVehicle = 0
end

local function clearCurrentPoint()
    nearPoint      = false
    deliveryCoords = nil
    lib.hideTextUI()
    if currentZone then
        currentZone:remove()
        currentZone = nil
    end
    if DoesBlipExist(currentBlip) then
        RemoveBlip(currentBlip)
        currentBlip = 0
    end
end

local function removeVehicleTarget()
    if jobVehicle ~= 0 then
        pcall(function() exports.ox_target:removeLocalEntity(jobVehicle) end)
    end
end

local function resetJobState()
    activeJob           = false
    deliveryCooldown    = false
    takeCooldown        = false
    transitioning       = false
    localAccumPay       = 0
    localTotalDelivered = 0
    pizzaTaken          = false
    detachPizzaProp()
    removeVehicleTarget()
    clearCurrentPoint()
    ClearGpsPlayerWaypoint()
end

local function setDeliveryPoint(pt)
    clearCurrentPoint()
    deliveryCoords = vec3(pt.x, pt.y, pt.z)

    SetNewWaypoint(pt.x, pt.y)

    currentBlip = AddBlipForCoord(pt.x, pt.y, pt.z)
    SetBlipSprite(currentBlip, 889)
    SetBlipDisplay(currentBlip, 2)
    SetBlipScale(currentBlip, 0.85)
    SetBlipColour(currentBlip, 17)
    SetBlipAsShortRange(currentBlip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Giao Pizza')
    EndTextCommandSetBlipName(currentBlip)

    currentZone = lib.points.new({
        coords   = vec3(pt.x, pt.y, pt.z),
        distance = 30.0,
    })
end

-- Forward declare để addVehicleTarget có thể dùng lại chính nó
local addVehicleTarget

addVehicleTarget = function(veh)
    exports.ox_target:addLocalEntity(veh, {
        {
            label       = 'Lấy Pizza',
            icon        = 'fas fa-pizza-slice',
            distance    = 1.15,
            bones       = { 'bodyshell' },
            canInteract = function()
                return activeJob and not takeCooldown and not pizzaTaken
            end,
            onSelect    = function()
                if takeCooldown or pizzaTaken then return end
                if not DoesEntityExist(jobVehicle) or IsEntityDead(jobVehicle) then
                    lib.notify({ title = 'Giao Pizza', description = 'Xe không còn tồn tại.', type = 'error' })
                    return
                end
                takeCooldown = true
                local done = lib.progressBar({
                    duration     = 4000,
                    label        = 'Lấy Pizza...',
                    useWhileDead = false,
                    canCancel    = false,
                    disable      = {
                        move   = true,
                        car    = true,
                        combat = true,
                        mouse  = false,
                    },
                    anim = {
                        dict     = 'anim@amb@nightclub@mini@drinking@bar@player_bartender@one',
                        clip     = 'one_bartender',
                        flag     = 49,
                        blendIn  = 8.0,
                        blendOut = -8.0,
                        duration = -1,
                    },
                })
                if done then
                    pizzaTaken = true
                    attachPizzaProp()
                    SetVehicleDoorsLocked(jobVehicle, 2)
                    if IsPedInVehicle(PlayerPedId(), jobVehicle, false) then
                        TaskLeaveVehicle(PlayerPedId(), jobVehicle, 0)
                    end
                    TriggerServerEvent('giaopizza:server:takePizza')
                end
                SetTimeout(300, function() takeCooldown = false end)
            end,
        },
    })
end

-- ─── Giữ trạng thái khóa xe đúng theo pizzaTaken ────────────────────────────
local blockNotifyCooldown = false
CreateThread(function()
    while true do
        if activeJob and DoesEntityExist(jobVehicle) then
            Wait(0)
            local ped = PlayerPedId()
            if not pizzaTaken then
                SetVehicleDoorsLocked(jobVehicle, 0)
            else
                SetVehicleDoorsLocked(jobVehicle, 2)
                if IsPedInAnyVehicle(ped, false) then
                    TaskLeaveVehicle(ped, GetVehiclePedIsIn(ped, false), 0)
                    if not blockNotifyCooldown then
                        blockNotifyCooldown = true
                        lib.notify({ title = 'Giao Pizza', description = 'Không được lên xe khi đang mang hàng.', type = 'error' })
                        SetTimeout(3000, function() blockNotifyCooldown = false end)
                    end
                end
            end
        else
            Wait(500)
        end
    end
end)

-- ─── Detect xe job bị phá hủy/nổ ───────────────────────────────────────────
CreateThread(function()
    Wait(3000)
    while true do
        Wait(1000)
        if activeJob and jobVehicle ~= 0 and not pizzaTaken and not transitioning then
            local vehDead = not DoesEntityExist(jobVehicle)
                or IsEntityDead(jobVehicle)
            if vehDead then
                lib.notify({ title = 'Giao Pizza', description = 'Xe bị hỏng! Job thất bại.', type = 'error' })
                removeVehicleTarget()
                jobVehicle = 0
                TriggerServerEvent('giaopizza:server:cancelJob')
            end
        end
    end
end)

-- ─── HUD tiền tích lũy + số đơn ─────────────────────────────────────────────
CreateThread(function()
    while true do
        if activeJob then
            Wait(0)
            local pw, ph = 0.090, 0.032
            local cx     = pw * 0.55 - 0.005
            local cy     = 1.0 - ph * 0.5 - 0.400

            -- ── Ô Tiền Lãi ──
            DrawRect(cx, cy, pw, ph, 0, 0, 0, 160)

            SetTextFont(4)
            SetTextScale(0.0, 0.28)
            SetTextColour(255, 255, 255, 220)
            SetTextEntry('STRING')
            AddTextComponentString('📦')
            DrawText(cx - pw * 0.48, cy - 0.011)

            SetTextFont(4)
            SetTextScale(0.0, 0.32)
            SetTextColour(200, 200, 200, 220)
            SetTextOutline()
            SetTextEntry('STRING')
            AddTextComponentString('Đơn:')
            DrawText(cx - pw * 0.35, cy - 0.013)

            SetTextFont(4)
            SetTextScale(0.0, 0.30)
            SetTextColour(255, 255, 255, 255)
            SetTextOutline()
            SetTextEntry('STRING')
            AddTextComponentString(('#%d'):format(localTotalDelivered))
            DrawText(cx + pw * 0.03, cy - 0.011)

            -- ── Ô Tích Lũy (ngay dưới) ──
            local cy2 = cy + ph + 0.003
            DrawRect(cx, cy2, pw, ph, 0, 0, 0, 160)

            SetTextFont(4)
            SetTextScale(0.0, 0.28)
            SetTextColour(255, 255, 255, 220)
            SetTextEntry('STRING')
            AddTextComponentString('🍕')
            DrawText(cx - pw * 0.48, cy2 - 0.011)

            SetTextFont(4)
            SetTextScale(0.0, 0.32)
            SetTextColour(200, 200, 200, 220)
            SetTextOutline()
            SetTextEntry('STRING')
            AddTextComponentString('Tích Lũy:')
            DrawText(cx - pw * 0.35, cy2 - 0.013)

            SetTextFont(4)
            SetTextScale(0.0, 0.30)
            SetTextColour(255, 255, 255, 255)
            SetTextOutline()
            SetTextEntry('STRING')
            AddTextComponentString(('$%d'):format(localAccumPay))
            DrawText(cx + pw * 0.05, cy2 - 0.011)
        else
            Wait(500)
        end
    end
end)

-- ─── Thread check gần điểm giao ─────────────────────────────────────────────
CreateThread(function()
    while true do
        Wait(200)
        local coords = deliveryCoords
        if activeJob and coords and pizzaTaken then
            local dist    = #(GetEntityCoords(PlayerPedId()) - coords)
            local inRange = dist <= Config.Job.interactRadius

            if inRange and not nearPoint then
                nearPoint = true
                lib.showTextUI('[E] Giao Pizza', { position = 'left-center', icon = 'fas fa-pizza-slice' })
            elseif not inRange and nearPoint then
                nearPoint = false
                lib.hideTextUI()
            end
        else
            if nearPoint then
                nearPoint = false
                lib.hideTextUI()
            end
        end
    end
end)

-- ─── Thread bấm E giao hàng ─────────────────────────────────────────────────
CreateThread(function()
    while true do
        if activeJob and nearPoint and pizzaTaken then
            Wait(0)
            if IsControlJustPressed(0, 38) and not deliveryCooldown then
                deliveryCooldown = true
                nearPoint = false
                lib.hideTextUI()
                local done = lib.progressBar({
                    duration     = 3000,
                    label        = 'Giao Pizza...',
                    useWhileDead = false,
                    canCancel    = false,
                    disable      = {
                        move   = true,
                        car    = true,
                        combat = true,
                        mouse  = false,
                    },
                })
                if done then
                    detachPizzaProp()
                    pizzaTaken = false
                    TriggerServerEvent('giaopizza:server:arrivedPoint')
                end
                SetTimeout(300, function() deliveryCooldown = false end)
            end
        else
            Wait(300)
        end
    end
end)

-- ─── Marker điểm giao ────────────────────────────────────────────────────────
local markerGroundZ = nil

CreateThread(function()
    while true do
        local coords = deliveryCoords
        if activeJob and coords then
            Wait(0)
            local found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)
            if found then markerGroundZ = groundZ end
            local drawZ = markerGroundZ or (coords.z - 1.0)
            DrawMarker(
                1,
                coords.x, coords.y, drawZ,
                0, 0, 0, 0, 0, 0,
                1.0, 1.0, 0.2,
                100, 200, 255, 140,
                false, true, 2, false, nil, nil, false
            )
        else
            markerGroundZ = nil
            Wait(500)
        end
    end
end)

-- ─── Spawn xe ────────────────────────────────────────────────────────────────
local function spawnVehicle(slotCoords, plate)
    local model = lib.requestModel(Config.Vehicle.model, 5000)
    if not model then
        lib.notify({ title = 'Giao Pizza', description = 'Không thể tải xe.', type = 'error' })
        return false
    end

    local veh = CreateVehicle(model, slotCoords.x, slotCoords.y, slotCoords.z, slotCoords.w, true, false)
    SetVehicleColours(veh, Config.Vehicle.color1)
    SetModelAsNoLongerNeeded(model)
    SetVehicleNumberPlateText(veh, plate)
    SetVehicleFuelLevel(veh, 100.0)
    Entity(veh).state:set('fuel', 100.0, true)
    SetVehicleEngineOn(veh, true, true, false)
    SetVehicleDoorsLocked(veh, 0)

    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)

    jobVehicle = veh

    local elapsed = 0
    while not NetworkGetEntityIsNetworked(veh) and elapsed < 5000 do
        Wait(50)
        elapsed = elapsed + 50
    end

    if not NetworkGetEntityIsNetworked(veh) then
        lib.notify({ title = 'Giao Pizza', description = 'Lỗi đồng bộ xe, thử lại.', type = 'error' })
        return false
    end

    local netId = NetworkGetNetworkIdFromEntity(veh)
    lib.callback.await('qbx_vehiclekeys:server:giveKeys', false, netId)
    TriggerServerEvent('giaopizza:server:vehicleSpawned', netId, plate)

    addVehicleTarget(veh)

    return true
end

-- ─── Events từ server ────────────────────────────────────────────────────────
RegisterNetEvent('giaopizza:client:startJob', function(slotCoords, firstPoint, plate)
    if activeJob then return end
    activeJob           = true
    localAccumPay       = 0
    localTotalDelivered = 0
    pizzaTaken          = false

    local ok = spawnVehicle(slotCoords, plate)
    if not ok then
        resetJobState()
        TriggerServerEvent('giaopizza:server:cancelJob')
        return
    end

    setDeliveryPoint(firstPoint)
    lib.notify({
        title       = 'Nghề Giao Pizza',
        description = ('Thuê xe $%d. Lái xe đến điểm giao pizza!'):format(Config.Job.vehicleRent),
        type        = 'success',
    })
end)

RegisterNetEvent('giaopizza:client:nextPoint', function(totalDelivered, accumulatedPay, nextPoint)
    if not activeJob then return end

    transitioning       = true
    nearPoint           = false
    lib.hideTextUI()
    detachPizzaProp()
    pizzaTaken          = false
    localAccumPay       = accumulatedPay
    localTotalDelivered = totalDelivered

    exports.ox_target:removeLocalEntity(jobVehicle)
    if DoesEntityExist(jobVehicle) then
        SetVehicleDoorsLocked(jobVehicle, 0)
    end
    addVehicleTarget(jobVehicle)

    setDeliveryPoint(nextPoint)
    SetTimeout(3000, function() transitioning = false end)
    lib.notify({
        title       = 'Giao Pizza',
        description = ('Giao thành công!'):format(totalDelivered, accumulatedPay),
        type        = 'success',
    })
end)

RegisterNetEvent('giaopizza:client:pizzaTaken', function()
end)

RegisterNetEvent('giaopizza:client:finishJob', function(reward, delivered)
    resetJobState()
    lib.notify({
        title       = 'Giao Pizza',
        description = ('Hoàn thành! #%d đơn — Nhận: $%d'):format(delivered, reward),
        type        = 'success',
    })
end)

RegisterNetEvent('giaopizza:client:cancelJob', function()
    resetJobState()
    lib.notify({ title = 'Giao Pizza', description = 'Job đã bị hủy.', type = 'error' })
end)

RegisterNetEvent('giaopizza:client:deleteVehicle', function()
    removeVehicleTarget()
    deleteJobVehicle()
end)

-- ─── NPC blip cố định ────────────────────────────────────────────────────────
CreateThread(function()
    local npc     = Config.NPC.coords
    local npcBlip = AddBlipForCoord(npc.x, npc.y, npc.z)
    SetBlipSprite(npcBlip, 267)
    SetBlipDisplay(npcBlip, 2)
    SetBlipScale(npcBlip, 0.9)
    SetBlipColour(npcBlip, 17)
    SetBlipAsShortRange(npcBlip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Giao Pizza')
    EndTextCommandSetBlipName(npcBlip)
end)

-- ─── Spawn NPC ───────────────────────────────────────────────────────────────
local function spawnNPC()
    local npcCoords = Config.NPC.coords
    local model     = lib.requestModel(Config.NPC.model, 10000)
    if not model then return end

    local ped = CreatePed(4, model, npcCoords.x, npcCoords.y, npcCoords.z - 1.0, npcCoords.w, false, true)
    SetModelAsNoLongerNeeded(model)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetPedCanRagdoll(ped, false)

    exports.ox_target:addLocalEntity(ped, {
        {
            label       = 'Nhận Job Giao Pizza',
            icon        = 'fas fa-pizza-slice',
            distance    = 2.0,
            canInteract = function() return not activeJob end,
            onSelect    = function() TriggerServerEvent('giaopizza:server:requestJob') end,
        },
        {
            label       = 'Trả Job & Nhận Tiền',
            icon        = 'fas fa-money-bill-wave',
            distance    = 2.0,
            canInteract = function() return activeJob end,
            onSelect    = function()
                if not DoesEntityExist(jobVehicle) or IsEntityDead(jobVehicle) then
                    lib.notify({ title = 'Giao Pizza', description = 'Xe không còn tồn tại, không thể trả job.', type = 'error' })
                    return
                end
                local npc    = Config.NPC.coords
                local vehPos = GetEntityCoords(jobVehicle)
                if #(vehPos - vec3(npc.x, npc.y, npc.z)) > 8.0 then
                    lib.notify({ title = 'Giao Pizza', description = 'Phải đậu xe gần NPC để trả job.', type = 'error' })
                    return
                end
                TriggerServerEvent('giaopizza:server:returnJob')
            end,
        },
        {
            label       = 'Hủy Job',
            icon        = 'fas fa-times-circle',
            distance    = 2.0,
            canInteract = function() return activeJob end,
            onSelect    = function() TriggerServerEvent('giaopizza:server:cancelJob') end,
        },
    })
end

CreateThread(spawnNPC)