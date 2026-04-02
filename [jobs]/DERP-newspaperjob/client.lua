local activeJob     = false
local allDelivered  = false
local jobVehicle    = 0
local currentBlip   = 0
local lastInteract  = 0
local totalPoints   = 0
local workZones     = {}
local blipStore     = {}
local weaponHash    = nil

-- cache hash một lần duy nhất
local function getWeaponHash()
    if not weaponHash then
        weaponHash = GetHashKey(Config.Job.weapon)
    end
    return weaponHash
end

local function clearBlip()
    if DoesBlipExist(currentBlip) then
        RemoveBlip(currentBlip)
    end
    currentBlip = 0
end

local function deleteJobVehicle()
    if DoesEntityExist(jobVehicle) then
        DeleteEntity(jobVehicle)
    end
    jobVehicle = 0
end

local function clearWorkZones()
    for i = 1, #workZones do
        if workZones[i] then workZones[i]:remove() end
    end
    workZones = {}
    for k, v in pairs(blipStore) do
        if DoesBlipExist(v) then RemoveBlip(v) end
    end
    blipStore = {}
end

-- FIX: marker thread — chỉ vẽ khi activeJob, sleep 500ms khi idle
CreateThread(function()
    while true do
        if activeJob and #workZones > 0 then
            Wait(0)
            for i = 1, #workZones do
                local zone = workZones[i]
                if zone and zone.coords then
                    local pt = zone.coords
                    DrawMarker(
                        1,
                        pt.x, pt.y, pt.z - 1.5,
                        0, 0, 0, 0, 0, 0,
                        4.0, 4.0, 6.0,
                        30, 144, 255, 165,
                        false, true, 2, false, nil, nil, false
                    )
                end
            end
        else
            Wait(500)
        end
    end
end)

local function resetJobState()
    activeJob    = false
    allDelivered = false
    totalPoints  = 0
    clearBlip()
    clearWorkZones()
    ClearGpsPlayerWaypoint()
    -- FIX: disarm phía client không quyết được reward, chỉ visual
    -- server đã disarm qua ox_inventory:disarm event riêng
end

local function showNPCWaypoint()
    local npc = Config.NPC.coords
    SetNewWaypoint(npc.x, npc.y)
end

local function spawnVehicle(slotCoords)
    local model = lib.requestModel(Config.Vehicle.model, 5000)
    if not model then
        lib.notify({ title = 'Giao Báo', description = 'Không thể tải xe.', type = 'error' })
        return false
    end
    local veh = CreateVehicle(model, slotCoords.x, slotCoords.y, slotCoords.z, slotCoords.w, true, false)
    SetModelAsNoLongerNeeded(model)
    SetVehicleColours(veh, math.random(0, 159), math.random(0, 159))
    exports['cdn-fuel']:SetFuel(veh, 100.0)
    SetVehicleEngineOn(veh, true, true, false)
    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)

    local netId = NetworkGetNetworkIdFromEntity(veh)
    Wait(500)
    lib.callback.await('qbx_vehiclekeys:server:giveKeys', false, netId)

    jobVehicle = veh
    return true
end

local function createDeliveryPoints(points)
    clearWorkZones()
    -- FIX: throwCooldown per-point chống fire server event 2 lần cùng 1 điểm
    local throwCooldown = {}

    for k, v in ipairs(points) do
        local zone = lib.points.new({
            coords     = vec3(v.x, v.y, v.z),
            distance   = 30,
            pointIndex = v.pointIndex,
            nearby     = function(point)
                if point.isClosest and activeJob and not allDelivered then
                    if not throwCooldown[point.pointIndex] then
                        if IsProjectileTypeWithinDistance(point.coords.x, point.coords.y, point.coords.z, getWeaponHash(), Config.Job.zoneRadius, true) then
                            throwCooldown[point.pointIndex] = true
                            TriggerServerEvent('delivery:server:arrivedPoint', point.pointIndex)
                            -- FIX: reset cooldown sau 2s phòng server reject trả về
                            SetTimeout(2000, function()
                                throwCooldown[point.pointIndex] = nil
                            end)
                        end
                    end
                end
            end,
        })
        workZones[k] = zone

        blipStore[k] = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(blipStore[k], 40)
        SetBlipDisplay(blipStore[k], 2)
        SetBlipScale(blipStore[k], 0.85)
        SetBlipColour(blipStore[k], 61)
        SetBlipAsShortRange(blipStore[k], false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('Điểm Giao Báo')
        EndTextCommandSetBlipName(blipStore[k])
    end
end

RegisterNetEvent('delivery:client:startJob', function(points, total, slotCoords, areaLabel)
    -- FIX: guard activeJob — server đã validate nhưng client cũng tự guard
    if activeJob then return end
    activeJob    = true
    allDelivered = false
    totalPoints  = total

    local ok = spawnVehicle(slotCoords)
    if not ok then
        resetJobState()
        TriggerServerEvent('delivery:server:cancelJob')
        return
    end

    createDeliveryPoints(points)
    showNPCWaypoint()
    lib.notify({
        title       = 'Nghề Giao Báo',
        description = ('Khu vực: %s — Nhận %d tờ báo! Rút báo ra tay và ném vào các điểm chỉ định. Thời gian: 15 phút.'):format(areaLabel, total),
        type        = 'success',
    })

    -- countdown display — không dùng để logic, chỉ UI
    local timeLeft = Config.Job.timeout
    CreateThread(function()
        while activeJob and timeLeft > 0 do
            Wait(1000)
            timeLeft = timeLeft - 1
            local mins = math.floor(timeLeft / 60)
            local secs = timeLeft % 60
            lib.showTextUI(('Thời Gian Hủy Việc: %02d:%02d'):format(mins, secs), { position = 'left-center' })
        end
        lib.hideTextUI()
    end)
end)

RegisterNetEvent('delivery:client:removePoint', function(pointIndex, remaining)
    -- FIX: tìm zone theo pointIndex thay vì assume k == pointIndex
    for k, zone in pairs(workZones) do
        if zone and zone.pointIndex == pointIndex then
            zone:remove()
            workZones[k] = nil
            if blipStore[k] and DoesBlipExist(blipStore[k]) then
                RemoveBlip(blipStore[k])
                blipStore[k] = nil
            end
            break
        end
    end
    if remaining > 0 then
        lib.notify({ title = 'Giao Báo', description = ('Giao thành công! Còn %d điểm.'):format(remaining), type = 'success' })
    end
end)

RegisterNetEvent('delivery:client:allDelivered', function()
    if not activeJob then return end
    allDelivered = true
    clearWorkZones()
    lib.hideTextUI()
    lib.notify({ title = 'Giao Báo', description = 'Giao hết! Gặp quản lý nhận tiền.', type = 'inform' })
end)

RegisterNetEvent('delivery:client:finishJob', function(reward, delivered, deposit)
    resetJobState()
    lib.hideTextUI()
    lib.notify({
        title       = 'Giao Báo',
        description = ('Hoàn thành! Giao %d điểm — Tiền giao: $%d + Hoàn cọc: $%d = Tổng: $%d'):format(delivered, reward, deposit, reward + deposit),
        type        = 'success',
    })
end)

RegisterNetEvent('delivery:client:cancelJob', function()
    resetJobState()
    lib.hideTextUI()
    lib.notify({ title = 'Giao Báo', description = 'Job đã bị hủy. Mất tiền cọc.', type = 'error' })
end)

RegisterNetEvent('delivery:client:deleteVehicle', function()
    deleteJobVehicle()
end)

-- blip NPC cố định
CreateThread(function()
    local npc     = Config.NPC.coords
    local npcBlip = AddBlipForCoord(npc.x, npc.y, npc.z)
    SetBlipSprite(npcBlip, 590)
    SetBlipDisplay(npcBlip, 2)
    SetBlipScale(npcBlip, 0.6)
    SetBlipColour(npcBlip, 1)
    SetBlipAsShortRange(npcBlip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Giao Báo')
    EndTextCommandSetBlipName(npcBlip)
end)

-- NPC spawn + target
CreateThread(function()
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
            label    = 'Nhận Việc Giao Báo',
            icon     = 'fas fa-newspaper',
            distance = 2.0,
            canInteract = function()
                local now = GetGameTimer()
                return not activeJob and (now - lastInteract) > Config.Job.cooldown
            end,
            onSelect = function()
                lastInteract = GetGameTimer()
                TriggerServerEvent('delivery:server:requestJob')
            end,
        },
        {
            label    = 'Trả Việc & Nhận Tiền',
            icon     = 'fas fa-money-bill-wave',
            distance = 2.0,
            canInteract = function()
                return activeJob
            end,
            onSelect = function()
                TriggerServerEvent('delivery:server:returnJob')
            end,
        },
        -- {
        --     label    = 'Hủy Việc',
        --     icon     = 'fas fa-times-circle',
        --     distance = 2.0,
        --     canInteract = function()
        --         return activeJob
        --     end,
        --     onSelect = function()
        --         TriggerServerEvent('delivery:server:cancelJob')
        --     end,
        -- },
    })
end)