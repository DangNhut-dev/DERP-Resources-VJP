local tradeNPC    = nil
local isUIOpen    = false

local previewActive   = false
local savedAppearance = {}
local previewCam      = nil
local rotateThread    = nil

-- ==================== NPC ====================

local function ClearOldNPCs()
    local model  = joaat(Config.NPC.model)
    local coords = vec3(Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z)
    for _, ped in ipairs(GetGamePool('CPed')) do
        if GetEntityModel(ped) == model and not IsPedAPlayer(ped) then
            if #(GetEntityCoords(ped) - coords) < 5.0 and DoesEntityExist(ped) then
                SetEntityAsMissionEntity(ped, true, true)
                DeleteEntity(ped)
            end
        end
    end
end

local function SpawnNPC()
    ClearOldNPCs()
    local model = joaat(Config.NPC.model)
    lib.requestModel(model)

    tradeNPC = CreatePed(4, model,
        Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z - 1.0,
        Config.NPC.coords.w, false, false)

    SetEntityAsMissionEntity(tradeNPC, true, true)
    SetBlockingOfNonTemporaryEvents(tradeNPC, true)
    SetPedDiesWhenInjured(tradeNPC, false)
    SetPedCanPlayAmbientAnims(tradeNPC, true)
    SetPedCanRagdollFromPlayerImpact(tradeNPC, false)
    SetEntityInvincible(tradeNPC, true)
    FreezeEntityPosition(tradeNPC, true)
    SetModelAsNoLongerNeeded(model)

    if Config.NPC.scenario and Config.NPC.scenario ~= '' then
        TaskStartScenarioInPlace(tradeNPC, Config.NPC.scenario, 0, true)
    end

    exports.ox_target:addLocalEntity(tradeNPC, {
        {
            name     = 'tradeticket_open',
            label    = 'Đổi Quần Áo / Cửa Hàng',
            icon     = 'fas fa-ticket',
            distance = 2.0,
            onSelect = function()
                if isUIOpen then return end
                lib.callback('DERP-tradeticket:getItems', false, function(data)
                    if not data then return end
                    local ped    = PlayerPedId()
                    local gender = 0
                    if GetEntityModel(ped) == joaat('mp_f_freemode_01') then gender = 1 end
                    data.pedGender = gender

                    isUIOpen = true
                    SetNuiFocus(true, true)
                    SendNUIMessage({
                        action       = 'open',
                        resourceName = GetCurrentResourceName(),
                        data         = data,
                    })
                end)
            end,
        },
    })
end

AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    SpawnNPC()
end)

AddEventHandler('onClientResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    if tradeNPC and DoesEntityExist(tradeNPC) then
        exports.ox_target:removeLocalEntity(tradeNPC)
        SetEntityAsMissionEntity(tradeNPC, true, true)
        DeleteEntity(tradeNPC)
        tradeNPC = nil
    end
    if previewActive then
        RevertPreview()
        StopPreviewCamera()
        lib.hideTextUI()
    end
    if isUIOpen then
        SetNuiFocus(false, false)
        isUIOpen = false
    end
end)

-- ==================== Preview ====================

local function getSlotInfo(slotType)
    for _, info in pairs(Config.ClothingSlots) do
        if info.slotType == slotType then
            return info.componentId, info.componentType
        end
    end
    return nil, nil
end

local function SaveAppearance(slotType)
    local ped = PlayerPedId()
    local componentId, componentType = getSlotInfo(slotType)
    if not componentId then return end

    if componentType == 'component' then
        savedAppearance = {
            componentId   = componentId,
            componentType = 'component',
            drawableId    = GetPedDrawableVariation(ped, componentId),
            textureId     = GetPedTextureVariation(ped, componentId),
        }
    else
        savedAppearance = {
            componentId   = componentId,
            componentType = 'props',
            drawableId    = GetPedPropIndex(ped, componentId),
            textureId     = GetPedPropTextureIndex(ped, componentId),
        }
    end
end

local function ApplyPreview(slotType, drawableId, textureId)
    local ped = PlayerPedId()
    local componentId, componentType = getSlotInfo(slotType)
    if not componentId then return end

    if componentType == 'component' then
        SetPedComponentVariation(ped, componentId, drawableId, textureId, 2)
    else
        SetPedPropIndex(ped, componentId, drawableId, textureId, true)
    end
end

function RevertPreview()
    if not previewActive then return end
    local ped = PlayerPedId()

    if savedAppearance.componentId then
        if savedAppearance.componentType == 'component' then
            SetPedComponentVariation(ped, savedAppearance.componentId,
                savedAppearance.drawableId, savedAppearance.textureId, 2)
        else
            if savedAppearance.drawableId == -1 then
                ClearPedProp(ped, savedAppearance.componentId)
            else
                SetPedPropIndex(ped, savedAppearance.componentId,
                    savedAppearance.drawableId, savedAppearance.textureId, true)
            end
        end
    end

    FreezeEntityPosition(PlayerPedId(), false)
    savedAppearance = {}
    previewActive   = false
end

local function StartPreviewCamera()
    local ped     = PlayerPedId()
    local coords  = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local rad     = math.rad(heading)

    local dist = 3.2
    local camX = coords.x - math.sin(rad) * dist
    local camY = coords.y - math.cos(rad) * dist
    local camZ = coords.z + 0.7

    previewCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(previewCam, camX, camY, camZ)
    PointCamAtEntity(previewCam, ped, 0.0, 0.0, 0.0, true)
    SetCamFov(previewCam, 45.0)
    RenderScriptCams(true, true, 500, true, false)
end

local function StopPreviewCamera()
    if previewCam then
        RenderScriptCams(false, true, 500, true, false)
        DestroyCam(previewCam, false)
        previewCam = nil
    end
end

local function StartRotateThread()
    if rotateThread then return end
    rotateThread = CreateThread(function()
        while previewActive do
            local dx = GetDisabledControlNormal(0, 220)
            if math.abs(dx) > 0.005 then
                local ped     = PlayerPedId()
                local heading = GetEntityHeading(ped)
                -- Giam toc xoay xuong 60
                SetEntityHeading(ped, heading - dx * 60.0)

                local newCoords  = GetEntityCoords(ped)
                local newHeading = GetEntityHeading(ped)
                local newRad     = math.rad(newHeading)
                local dist       = 3.2
                SetCamCoord(previewCam,
                    newCoords.x - math.sin(newRad) * dist,
                    newCoords.y - math.cos(newRad) * dist,
                    newCoords.z + 0.7)
            end
            Wait(0)
        end
        rotateThread = nil
    end)
end

local function StopPreviewFull()
    RevertPreview()
    StopPreviewCamera()
    lib.hideTextUI()
end

-- X de thoat preview (keycode 73)
CreateThread(function()
    while true do
        Wait(0)
        if previewActive then
            if IsControlJustPressed(0, 73) then
                StopPreviewFull()
                SetNuiFocus(true, true)
                SendNUIMessage({ action = 'previewStopped' })
            end
        end
    end
end)

-- ==================== NUI Callbacks ====================

RegisterNUICallback('closeUI', function(_, cb)
    if previewActive then
        StopPreviewFull()
    end
    isUIOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('previewItem', function(data, cb)
    if not data or not data.slotType then
        return cb({ error = 'missing_data' })
    end

    local ped       = PlayerPedId()
    local pedGender = 0
    if GetEntityModel(ped) == joaat('mp_f_freemode_01') then pedGender = 1 end

    if type(data.gender) == 'number' and data.gender ~= pedGender then
        return cb({ error = 'gender_mismatch' })
    end

    if previewActive then
        StopPreviewFull()
    end

    SaveAppearance(data.slotType)
    ApplyPreview(data.slotType, data.drawableId, data.textureId)

    FreezeEntityPosition(ped, true)
    previewActive = true

    StartPreviewCamera()
    StartRotateThread()

    lib.showTextUI('[X] Thoát thử đồ', {
        position  = 'left-center',
        icon      = 'xmark',
        iconColor = '#ff5050',
    })

    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hideUI' })

    cb('ok')
end)

RegisterNUICallback('stopPreview', function(_, cb)
    StopPreviewFull()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'previewStopped' })
    cb('ok')
end)

RegisterNUICallback('exchange', function(data, cb)
    if not data or type(data.selectedSlots) ~= 'table' or #data.selectedSlots == 0 then
        return cb({ error = 'invalid_data' })
    end
    lib.callback('DERP-tradeticket:exchange', false, function(result)
        cb(result or { error = 'timeout' })
    end, data.selectedSlots)
end)

RegisterNUICallback('buyShopItem', function(data, cb)
    if not data or type(data.itemId) ~= 'number' then
        return cb({ error = 'invalid_data' })
    end
    lib.callback('DERP-tradeticket:buyShopItem', false, function(result)
        cb(result or { error = 'timeout' })
    end, data.itemId)
end)

RegisterNUICallback('refreshItems', function(_, cb)
    lib.callback('DERP-tradeticket:getItems', false, function(data)
        if data then
            local ped    = PlayerPedId()
            local gender = 0
            if GetEntityModel(ped) == joaat('mp_f_freemode_01') then gender = 1 end
            data.pedGender = gender
        end
        cb(data or { materials = {}, rarityValue = {}, ticketItem = 'ticket', ticketCount = 0, shopItems = {} })
    end)
end)

RegisterNUICallback('confirmBuy', function(data, cb)
    if not data or type(data.itemId) ~= 'number' then
        return cb({ error = 'invalid_data' })
    end

    local label = tostring(data.label or '')
    local price = tonumber(data.price) or 0

    cb('ok')

    local confirmed = lib.alertDialog({
        header  = 'Xác nhận mua',
        content = ('Bạn mua **%s** với giá **%s vé**'):format(label, price),
        cancel  = true,
        labels  = {
            confirm = 'Thanh toán',
            cancel  = 'Không',
        },
    })

    if confirmed == 'confirm' then
        lib.callback('DERP-tradeticket:buyShopItem', false, function(res)
            SendNUIMessage({
                action = 'buyResult',
                result = res or { error = 'timeout' },
            })
        end, data.itemId)
    else
        SendNUIMessage({ action = 'buyResult', result = { cancelled = true } })
    end
end)