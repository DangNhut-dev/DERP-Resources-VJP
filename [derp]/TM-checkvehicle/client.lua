local QBX = exports.qbx_core

local activeDisplays = {}

local function canCheck()
    local pd = QBX:GetPlayerData()
    if not pd or not pd.job then return false end
    if pd.job.name ~= 'mechanic' then return false end
    -- if not pd.job.onduty then return false end
    return true
end

local function getHealthColor(percent)
    if percent > 70 then
        return 0, 200, 80
    elseif percent >= 30 then
        return 230, 190, 40
    else
        return 220, 40, 40
    end
end

local function drawText3D(coords, engine, body)
    local cam = GetGameplayCamCoord()
    local dist = #(cam - coords)
    if dist > 10.0 then return end

    local scale = 0.35 * (1.0 / dist) * 8.0
    if scale > 0.6 then scale = 0.6 end
    if scale < 0.18 then scale = 0.18 end

    local er, eg, eb = getHealthColor(engine)
    local br, bg, bb = getHealthColor(body)

    SetDrawOrigin(coords.x, coords.y, coords.z, 0)

    SetTextScale(scale, scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 220)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 220)
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry('STRING')
    AddTextComponentString('Động cơ')
    DrawText(0.0, -0.030)

    SetTextScale(scale, scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(er, eg, eb, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 220)
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry('STRING')
    AddTextComponentString(('%d%%'):format(engine))
    DrawText(0.0, 0.000)

    SetTextScale(scale, scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 220)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 220)
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry('STRING')
    AddTextComponentString('Khung xe')
    DrawText(0.0, 0.040)

    SetTextScale(scale, scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(br, bg, bb, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 220)
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry('STRING')
    AddTextComponentString(('%d%%'):format(body))
    DrawText(0.0, 0.070)

    ClearDrawOrigin()
end

CreateThread(function()
    while true do
        local sleep = 500
        local now = GetGameTimer()

        for netId, data in pairs(activeDisplays) do
            if now >= data.expireAt then
                activeDisplays[netId] = nil
            else
                local entity = NetworkGetEntityFromNetworkId(netId)
                if entity and entity ~= 0 and DoesEntityExist(entity) then
                    sleep = 0
                    local boneIdx = GetEntityBoneIndexByName(entity, 'engine')
                    local coords
                    if boneIdx ~= -1 then
                        coords = GetWorldPositionOfEntityBone(entity, boneIdx)
                    else
                        coords = GetEntityCoords(entity)
                    end
                    drawText3D(coords + vector3(0.0, 0.0, 0.4), data.engine, data.body)
                else
                    activeDisplays[netId] = nil
                end
            end
        end

        Wait(sleep)
    end
end)

local function startCheck(vehicle)
    if not canCheck() then
        lib.notify({ type = 'error', description = 'Chỉ thợ máy on duty mới kiểm tra được!' })
        return
    end

    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        lib.notify({ type = 'error', description = 'Bạn phải đứng ngoài xe để kiểm tra!' })
        return
    end

    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
        lib.notify({ type = 'error', description = 'Không tìm thấy xe!' })
        return
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if not netId or netId == 0 then
        lib.notify({ type = 'error', description = 'Xe không hợp lệ!' })
        return
    end

    local success = lib.progressBar({
        duration = 10000,
        label = 'Đang kiểm tra xe...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped',
        },
    })

    ClearPedTasks(ped)

    if not success then
        lib.notify({ type = 'error', description = 'Đã hủy kiểm tra' })
        return
    end

    if not DoesEntityExist(vehicle) then
        lib.notify({ type = 'error', description = 'Xe đã biến mất!' })
        return
    end

    local engineRaw = GetVehicleEngineHealth(vehicle)
    local bodyRaw = GetVehicleBodyHealth(vehicle)

    local enginePct = math.floor(math.max(0, math.min(100, (engineRaw / 1000) * 100)))
    local bodyPct = math.floor(math.max(0, math.min(100, (bodyRaw / 1000) * 100)))

    activeDisplays[netId] = {
        engine = enginePct,
        body = bodyPct,
        expireAt = GetGameTimer() + 15000,
    }
end

CreateThread(function()
    exports.ox_target:addGlobalVehicle({
        {
            name = 'tm_checkvehicle',
            icon = 'fas fa-stethoscope',
            label = 'Kiểm tra xe',
            bones = { 'engine' },
            distance = 2.0,
            canInteract = function(entity)
                if not entity or not DoesEntityExist(entity) then return false end
                local ped = PlayerPedId()
                if IsPedInAnyVehicle(ped, false) then return false end
                return canCheck()
            end,
            onSelect = function(data)
                startCheck(data.entity)
            end,
        },
    })
end)

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() ~= resource then return end
    exports.ox_target:removeGlobalVehicle('tm_checkvehicle')
    activeDisplays = {}
end)