local disableCrouch   = Config.DisableCrouch
local antiJumpSpam    = Config.AntiJumpSpam
local jumpCooldown    = Config.JumpCooldown
local antiPunchSpam   = Config.AntiPunchSpam
local punchCooldown   = Config.PunchCooldown
local disableHelmet   = Config.DisableHelmet

local lastJump        = 0
local lastPunch       = 0
local helmetTick      = 0
local meleeControls   = { 24, 25, 140, 141, 142 }

-- Main per-frame loop: crouch / jump / punch / helmet / action mode / roll prevention / aim-crouch
CreateThread(function()
    while true do
        Wait(0)
        local ped = cache.ped
        local now = GetGameTimer()
        local aiming = IsControlPressed(0, 25)

        if disableCrouch then
            DisableControlAction(0, 36, true)
            if GetPedStealthMovement(ped) then
                SetPedStealthMovement(ped, false, 0)
            end
        end

        -- Tắt crouch khi đang aim
        if aiming and LocalPlayer.state.crouch then
            LocalPlayer.state:set('crouch', false, false)
        end

        if antiJumpSpam then
            if now - lastJump < jumpCooldown then
                DisableControlAction(0, 22, true)
            elseif IsDisabledControlJustPressed(0, 22) or IsControlJustPressed(0, 22) then
                lastJump = now
            end
        end

        if antiPunchSpam then
            local inCooldown = (now - lastPunch) < punchCooldown
            if inCooldown then
                for i = 1, #meleeControls do
                    DisableControlAction(0, meleeControls[i], true)
                end
            else
                for i = 1, #meleeControls do
                    if IsControlJustPressed(0, meleeControls[i]) then
                        lastPunch = now
                        break
                    end
                end
            end
        end

        if disableHelmet and now - helmetTick > 1000 then
            SetPedConfigFlag(ped, 35, false)
            helmetTick = now
        end

        -- Action mode
        if IsPedUsingActionMode(ped) then
            SetPedUsingActionMode(ped, -1, -1, 1)
        end

        -- Roll prevention: chặn nhảy khi đang aim ngoài xe
        if not cache.vehicle and aiming then
            DisableControlAction(0, 22, true)
        end
    end
end)

-- Ambient melee move: set một lần khi ped thay đổi
lib.onCache('ped', function(ped)
    SetDisableAmbientMeleeMove(ped, true)
end)

-- Vehicle damage shake
lib.onCache('vehicle', function(vehicle)
    if not vehicle then return end
    CreateThread(function()
        local lastDamage = GetVehicleBodyHealth(vehicle)
        local SHAKE_RATE = 250.0
        while cache.vehicle == vehicle do
            local health = GetVehicleBodyHealth(vehicle)
            if health ~= lastDamage then
                ShakeGameplayCam('MEDIUM_EXPLOSION_SHAKE', GetEntitySpeed(vehicle) / SHAKE_RATE)
                lastDamage = health
            end
            Wait(100)
        end
    end)
end)

-- Speed limit
-- local speedLimit = 120.0
-- local maxSpeedMS = speedLimit / 2.236936
-- local excludedClass = { [15] = true, [16] = true, [17] = true, [18] = true, [19] = true }

-- lib.onCache('vehicle', function(vehicle)
--     if not vehicle then return end
--     CreateThread(function()
--         while cache.vehicle == vehicle do
--             Wait(500)
--             if not DoesEntityExist(vehicle) then break end
--             local class = GetVehicleClass(vehicle)
--             if excludedClass[class] then
--                 SetVehicleMaxSpeed(vehicle, 0.0)
--             else
--                 SetVehicleMaxSpeed(vehicle, maxSpeedMS)
--                 if GetEntitySpeed(vehicle) * 2.236936 > speedLimit then
--                     SetEntityMaxSpeed(vehicle, maxSpeedMS)
--                 end
--             end
--         end
--     end)
-- end)

-- Helicopter audio
local function EnableSubmix(id)
    SetAudioSubmixEffectRadioFx(id, 0)
    SetAudioSubmixEffectParamInt(id, 0, `default`, 1)
    SetAudioSubmixEffectParamFloat(id, 0, `freq_low`, 0.0)
    SetAudioSubmixEffectParamFloat(id, 0, `freq_hi`, 10000.0)
    SetAudioSubmixEffectParamFloat(id, 0, `fudge`, 0.0)
    SetAudioSubmixEffectParamFloat(id, 0, `rm_mix`, 0.2)
end

local function DisableSubmix(id)
    SetAudioSubmixEffectRadioFx(id, 0)
    SetAudioSubmixEffectParamInt(id, 0, `enabled`, 0)
end

local submixID  = 0
local soundmix  = false

lib.onCache('vehicle', function(vehicle)
    if not vehicle then
        if soundmix then
            DisableSubmix(submixID)
            soundmix = false
        end
        return
    end
    CreateThread(function()
        while cache.vehicle == vehicle do
            Wait(500)
            local model = GetEntityModel(vehicle)
            if (IsThisModelAHeli(model) or IsThisModelAPlane(model)) and GetIsVehicleEngineRunning(vehicle) then
                if not soundmix then
                    EnableSubmix(submixID)
                    soundmix = true
                end
            elseif soundmix then
                DisableSubmix(submixID)
                soundmix = false
            end
        end
    end)
end)

-- In-vehicle FPS aim
if Config.InVehicleFPSAim then
    local blacklistFPS = {}
    for name in pairs(Config.FPSAimBlacklist) do
        blacklistFPS[GetHashKey(name)] = true
    end

    local lastCamMode = 2

    local function isWeaponAllowed()
        return not blacklistFPS[GetSelectedPedWeapon(cache.ped)]
    end

    local function resetCam()
        SetFollowVehicleCamViewMode(lastCamMode)
    end

    local function blockAimingOnEnter()
        CreateThread(function()
            while IsControlPressed(0, 25) do
                SetPlayerCanDoDriveBy(cache.playerId, false)
                Wait(10)
            end
            SetPlayerCanDoDriveBy(cache.playerId, true)
        end)
    end

    local function vehicleAimLoop()
        Wait(300)
        CreateThread(function()
            local wasAiming  = false
            local resetUntil = 0
            local ped        = cache.ped
            local vehicle    = GetVehiclePedIsIn(ped, false)
            local vClass     = GetVehicleClass(vehicle)
            local isBike     = vClass == 8 or vClass == 13

            local function setFPS()
                SetCamViewModeForContext(isBike and 2 or 1, 4)
            end

            local function restoreCam()
                SetCamViewModeForContext(isBike and 2 or 1, lastCamMode)
            end

            while cache.seat do
                if IsPedDeadOrDying(ped, false) or IsPedRagdoll(ped) then
                    wasAiming = false
                    restoreCam()
                    Wait(500)
                else
                    local aiming = IsControlPressed(0, 25) and isWeaponAllowed()
                    if aiming then
                        if not wasAiming then
                            lastCamMode = GetCamViewModeForContext(isBike and 2 or 1)
                            wasAiming   = true
                            resetUntil  = 0
                        end
                        setFPS()
                    else
                        if wasAiming then
                            wasAiming  = false
                            resetUntil = GetGameTimer() + 300
                        end
                        if resetUntil > 0 then
                            if GetGameTimer() < resetUntil then
                                restoreCam()
                            else
                                resetUntil = 0
                            end
                        end
                    end
                    Wait(1)
                end
            end

            restoreCam()
        end)
    end

    SetPlayerCanDoDriveBy(cache.playerId, true)

    lib.onCache('seat', function(newSeat)
        if not newSeat then
            resetCam()
            return
        end
        lastCamMode = GetFollowVehicleCamViewMode()
        if IsControlPressed(0, 25) and isWeaponAllowed() then
            blockAimingOnEnter()
        end
        vehicleAimLoop()
    end)
end

-- Chặn crouch bật lên khi đang aim
AddStateBagChangeHandler('crouch', ('player:%s'):format(cache.serverId), function(_, _, value)
    if value and IsControlPressed(0, 25) then
        LocalPlayer.state:set('crouch', false, false)
    end
end)

-- Open map keybind
lib.addKeybind({
    name        = 'open_map',
    description = 'Mở bản đồ',
    defaultKey  = 'P',
    onPressed   = function()
        CreateThread(function()
            ActivateFrontendMenu(-1171018317, 0, -1)
            while not IsFrontendReadyForControl() do
                Wait(10)
            end
            Wait(20)
            SetControlNormal(2, 201, 1.0)
        end)
    end,
})