local isSmoking = false
local activeEffect = nil
local lastSmokeEnd = 0

-- Play anim ói khi overdose
local function playPukeAnim()
    local ped = PlayerPedId()

    CreateThread(function()
        -- Force clear tất cả task hiện tại
        ClearPedTasksImmediately(ped)
        ClearPedSecondaryTask(ped)
        Wait(300)

        local p = PlayerPedId()
        local dict = 're@construction'
        local clip = 'out_of_breath'

        RequestAnimDict(dict)
        local timeout = GetGameTimer() + 3000
        while not HasAnimDictLoaded(dict) and GetGameTimer() < timeout do
            Wait(50)
        end

        if HasAnimDictLoaded(dict) then
            TaskPlayAnim(p, dict, clip, 8.0, -8.0, 6000, 1, 0, false, false, false)
        end

        Wait(6000)
        StopAnimTask(PlayerPedId(), dict, clip, 2.0)
    end)

    local hp = GetEntityHealth(ped)
    SetEntityHealth(ped, math.max(hp - 15, 1))
end

-- Dọn effect, prop, anim hiện tại
local function cleanupEffect()
    if activeEffect then
        if activeEffect.screenEffect then
            StopScreenEffect(activeEffect.screenEffect)
        end
        if activeEffect.sprintThread then
            activeEffect.sprintThread = false
        end
        if activeEffect.regenThread then
            activeEffect.regenThread = false
        end
        if activeEffect.staminaThread then
            activeEffect.staminaThread = false
        end
        if activeEffect.walkstyle then
            ResetPedMovementClipset(PlayerPedId(), 0.0)
        end
        activeEffect = nil
    end
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
end

-- Áp dụng effect theo loại
local function applyEffect(data)
    cleanupEffect()

    local effect = {
        type = data.effectType,
        screenEffect = data.screenEffect,
    }

    if data.screenEffect then
        StartScreenEffect(data.screenEffect, data.duration, false)
        SetTimeout(data.duration, function()
            StopScreenEffect(data.screenEffect)
        end)
    end

    if data.effectType == 'sprint' and data.sprintMult then
        SetRunSprintMultiplierForPlayer(PlayerId(), data.sprintMult)
        effect.sprintThread = true
        SetTimeout(data.duration, function()
            if effect.sprintThread then
                SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
                effect.sprintThread = false
            end
        end)

    elseif data.effectType == 'stamina' then
        effect.staminaThread = true
        CreateThread(function()
            while effect.staminaThread do
                RestorePlayerStamina(PlayerId(), 1.0)
                Wait(1000)
            end
        end)
        SetTimeout(data.duration, function()
            effect.staminaThread = false
        end)

    elseif data.effectType == 'regen' and data.healthTick and data.healthInterval then
        effect.regenThread = true
        CreateThread(function()
            while effect.regenThread do
                local ped = PlayerPedId()
                local hp = GetEntityHealth(ped)
                local maxHp = GetEntityMaxHealth(ped)
                if hp > 0 and hp < maxHp then
                    SetEntityHealth(ped, math.min(hp + data.healthTick, maxHp))
                end
                Wait(data.healthInterval)
            end
        end)
        SetTimeout(data.duration, function()
            effect.regenThread = false
        end)

    elseif data.effectType == 'high' then
        if data.shake then
            ShakeGameplayCam(data.shake.name, data.shake.intensity)
            SetTimeout(data.duration, function()
                StopGameplayCamShaking(true)
            end)
        end
        if data.walkstyle then
            effect.walkstyle = data.walkstyle
            CreateThread(function()
                RequestAnimSet(data.walkstyle)
                local timeout = GetGameTimer() + 5000
                while not HasAnimSetLoaded(data.walkstyle) and GetGameTimer() < timeout do
                    Wait(50)
                end
                if HasAnimSetLoaded(data.walkstyle) then
                    SetPedMovementClipset(PlayerPedId(), data.walkstyle, 1.0)
                end
            end)
            SetTimeout(data.duration, function()
                ResetPedMovementClipset(PlayerPedId(), 0.0)
                effect.walkstyle = nil
            end)
        end

    elseif data.effectType == 'light' then
        if data.shake then
            ShakeGameplayCam(data.shake.name, data.shake.intensity)
            SetTimeout(data.duration, function()
                StopGameplayCamShaking(true)
            end)
        end
        if data.walkstyle then
            effect.walkstyle = data.walkstyle
            CreateThread(function()
                RequestAnimSet(data.walkstyle)
                local timeout = GetGameTimer() + 5000
                while not HasAnimSetLoaded(data.walkstyle) and GetGameTimer() < timeout do
                    Wait(50)
                end
                if HasAnimSetLoaded(data.walkstyle) then
                    SetPedMovementClipset(PlayerPedId(), data.walkstyle, 1.0)
                end
            end)
            SetTimeout(data.duration, function()
                ResetPedMovementClipset(PlayerPedId(), 0.0)
                effect.walkstyle = nil
            end)
        end
    end

    activeEffect = effect
end

-- Play anim hút + prop attach vào tay
local function playSmokeAnim()
    local ped = PlayerPedId()
    local animCfg = Config.Anim

    lib.requestAnimDict(animCfg.dict, 5000)
    TaskPlayAnim(ped, animCfg.dict, animCfg.clip, 8.0, -8.0, -1, animCfg.flag, 0, false, false, false)

    local propModel = joaat(animCfg.prop)
    lib.requestModel(propModel, 5000)
    local coords = GetEntityCoords(ped)
    local prop = CreateObject(propModel, coords.x, coords.y, coords.z + 0.2, true, true, false)
    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, animCfg.bone),
        animCfg.propPos.x, animCfg.propPos.y, animCfg.propPos.z,
        animCfg.propRot.x, animCfg.propRot.y, animCfg.propRot.z,
        true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(propModel)

    return prop
end

local function stopSmokeAnim(prop)
    local ped = PlayerPedId()
    StopAnimTask(ped, Config.Anim.dict, Config.Anim.clip, 2.0)
    if prop and DoesEntityExist(prop) then
        DetachEntity(prop, true, true)
        DeleteEntity(prop)
    end
end

-- Xử lý sự kiện dùng điếu
RegisterNetEvent('DERP-smokeweed:client:smoke', function(itemName)
    if isSmoking then return end

    local data = Config.Items[itemName]
    if not data then return end

    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) or IsPedSwimming(ped) or IsPedFalling(ped) then
        lib.notify({ title = 'Cần Sa', description = 'Không thể hút trong tình huống này.', type = 'error' })
        return
    end

    isSmoking = true
    local prop = playSmokeAnim()

    local ok = lib.progressBar({
        duration = data.progressTime,
        label = Config.ProgressLabel,
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
            car = true,
            combat = true,
            mouse = false,
        },
    })

    stopSmokeAnim(prop)

    if not ok then
        isSmoking = false
        TriggerServerEvent('DERP-smokeweed:server:cancelled', itemName)
        return
    end

    -- Check overdose: nếu vẫn còn trong duration của điếu trước -> ói, KHÔNG apply effect mới, giữ nguyên effect cũ
    -- local now = GetGameTimer()
    -- if now < lastSmokeEnd then
    --     playPukeAnim()
    --     TriggerServerEvent('DERP-smokeweed:server:consumed', itemName)
    --     SetTimeout(6000, function()
    --         isSmoking = false
    --     end)
    --     return
    -- end

    isSmoking = false
    lastSmokeEnd = GetGameTimer() + data.duration
    applyEffect(data)
    TriggerServerEvent('DERP-smokeweed:server:consumed', itemName)
end)

-- Dọn khi resource stop hoặc player chết
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    cleanupEffect()
end)

AddEventHandler('gameEventTriggered', function(name, args)
    if name == 'CEventNetworkEntityDamage' then
        local victim = args[1]
        local died = args[6]
        if died == 1 and victim == PlayerPedId() then
            cleanupEffect()
        end
    end
end)