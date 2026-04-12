local disableCrouch = Config.DisableCrouch
local antiJumpSpam = Config.AntiJumpSpam
local jumpCooldown = Config.JumpCooldown
local antiPunchSpam = Config.AntiPunchSpam
local punchCooldown = Config.PunchCooldown
local disableHelmet = Config.DisableHelmet

local lastJump = 0
local lastPunch = 0
local helmetTick = 0

CreateThread(function()
    local lastDamage = 0.0
    local vehicle = nil
    local SLEEP_TIME_IN_VEHICLE = 100
    local SLEEP_TIME_OUTSIDE_VEHICLE = 1000
    local SHAKE_RATE_CONSTANT = 250.0

    while true do
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed) then
            local curVehicle = GetVehiclePedIsIn(playerPed, false)
            local shakeRate = GetEntitySpeed(curVehicle) / SHAKE_RATE_CONSTANT
            local curVehicleHealth = GetVehicleBodyHealth(curVehicle)

            if curVehicleHealth ~= lastDamage then
                ShakeGameplayCam("MEDIUM_EXPLOSION_SHAKE", shakeRate)
            end

            lastDamage = curVehicleHealth
            vehicle = curVehicle
            Wait(SLEEP_TIME_IN_VEHICLE)
        else
            vehicle = nil
            Wait(SLEEP_TIME_OUTSIDE_VEHICLE)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local now = GetGameTimer()

        if disableCrouch then
            DisableControlAction(0, 36, true)
            if GetPedStealthMovement(ped) then
                SetPedStealthMovement(ped, false, 0)
            end
        end

        if antiJumpSpam then
            if now - lastJump < jumpCooldown then
                DisableControlAction(0, 22, true)
            elseif IsDisabledControlJustPressed(0, 22) or IsControlJustPressed(0, 22) then
                lastJump = now
            end
        end

        if antiPunchSpam then
            local meleeControls = {24,25,140,141,142}
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
    end
end)

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
            local vehicle      = GetVehiclePedIsIn(ped, false)
            local vehicleClass = GetVehicleClass(vehicle)
            local isBike       = vehicleClass == 8 or vehicleClass == 13

            local function setFPS()
                if isBike then
                    SetCamViewModeForContext(2, 4)
                else
                    SetCamViewModeForContext(1, 4)
                end
            end

            local function restoreCam()
                if isBike then
                    SetCamViewModeForContext(2, lastCamMode)
                else
                    SetCamViewModeForContext(1, lastCamMode)
                end
            end

            while cache.seat do
                if IsPedDeadOrDying(ped, false) or IsPedRagdoll(ped) then
                    if wasAiming then
                        wasAiming = false
                    end
                    restoreCam()
                    Wait(500)
                else
                    local aiming = IsControlPressed(0, 25) and isWeaponAllowed()

                    if aiming then
                        if not wasAiming then
                            lastCamMode = isBike and GetCamViewModeForContext(2) or GetCamViewModeForContext(1)
                            wasAiming   = true
                            resetUntil  = 0
                        end
                        setFPS()
                    else
                        if wasAiming then
                            wasAiming  = false
                            resetUntil = GetGameTimer() + 300
                        end
                        if resetUntil > 0 and GetGameTimer() < resetUntil then
                            restoreCam()
                        elseif resetUntil > 0 then
                            resetUntil = 0
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

-- RegisterCommand('gethash', function()
--     local _, wep = GetCurrentPedWeapon(PlayerPedId(), true)
--     print('Unsigned: ' .. wep)
--     print('Signed: ' .. (wep > 2147483647 and wep - 4294967296 or wep))
-- end, false)

-- Citizen.CreateThread(function()
--     for i = 1, 12 do
--         EnableDispatchService(i, false)
--     end
--     SetMaxWantedLevel(0)

--     SetGarbageTrucks(false)                       -- Xe rác ngẫu nhiên [true/false]
--     SetRandomBoats(false)                         -- Thuyền ngẫu nhiên [true/false]
--     SetCreateRandomCops(false)                    -- Cops ngẫu nhiên (xe / ped) [true/false]
--     SetCreateRandomCopsNotOnScenarios(false)      -- Cops không theo kịch bản [true/false]
--     SetCreateRandomCopsOnScenarios(false)         -- Cops theo kịch bản [true/false]

--     while true do
--         Citizen.Wait(1500)
--         local pid = PlayerId()
--         if GetPlayerWantedLevel(pid) ~= 0 then
--             ClearPlayerWantedLevel(pid)
--         end
--     end
-- end)

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

CreateThread(function()
    SetDisableAmbientMeleeMove(PlayerPedId(), true)
      while true do
          Wait(1)
          local ped = PlayerPedId()
          if IsPedUsingActionMode(ped) then
        SetPedUsingActionMode(ped, -1, -1, 1)
      end
    end
end)

-- -- roll Prevention
CreateThread(function()
    while true do
        if (not IsPedInAnyVehicle(PlayerPedId(),false)) then
            Wait(4)
            if IsPlayerFreeAiming(PlayerPedId()) then
                DisableControlAction(0, 22, 1)
            else
                Wait(100)
            end
        else
            Wait(500)
        end
    end
end)

-- helicopter audio
function EnableSubmix(submixID)
    SetAudioSubmixEffectRadioFx(submixID, 0)
    SetAudioSubmixEffectParamInt(submixID, 0, `default`, 1)
    SetAudioSubmixEffectParamFloat(submixID, 0, `freq_low`, 0.0)
    SetAudioSubmixEffectParamFloat(submixID, 0, `freq_hi`, 10000.0)
    SetAudioSubmixEffectParamFloat(submixID, 0, `fudge`, 0.0)
    SetAudioSubmixEffectParamFloat(submixID, 0, `rm_mix`, 0.2)
end

function DisableSubmix(submixID)
    SetAudioSubmixEffectRadioFx(submixID, 0)
    SetAudioSubmixEffectParamInt(submixID, 0, `enabled`, 0)
end

local soundmix = false
local submixID = 0

CreateThread(function()
    while true do
        Wait(500)
        local ped = PlayerPedId()
        local currentVehicle = GetVehiclePedIsIn(ped, false)
        local vehmodel = GetEntityModel(currentVehicle)

        if IsThisModelAHeli(vehmodel) or IsThisModelAPlane(vehmodel) then
            local engineRunning = GetIsVehicleEngineRunning(currentVehicle)
            local inVehicle = IsPedInAnyVehicle(ped, false)

            if inVehicle and engineRunning then
                if not soundmix then
                    EnableSubmix(submixID)
                    soundmix = true
                end
            elseif soundmix then
                DisableSubmix(submixID)
                soundmix = false
            end
        elseif soundmix then
            DisableSubmix(submixID)
            soundmix = false
        end
    end
end)

-- -- Giới hạn tốc độ tối đa
local speedLimit = 120.0 -- mph
local maxSpeedMS = speedLimit / 2.236936 -- đổi mph sang m/s

-- Hàm kiểm tra tốc độ phương tiện
local function checkSpeed(vehicle)
    if DoesEntityExist(vehicle) then
        local speed = GetEntitySpeed(vehicle) * 2.236936 -- mph
        local class = GetVehicleClass(vehicle)

        -- Loại trừ các class đặc biệt (máy bay, trực thăng, emergency, tàu...)
        if class ~= 15 and class ~= 16 and class ~= 17 and class ~= 18 and class ~= 19 then
            -- Cài đặt tốc độ tối đa
            SetVehicleMaxSpeed(vehicle, maxSpeedMS)

            -- Nếu đã vượt quá tốc độ giới hạn thì giảm ngay
            if speed > speedLimit then
                SetEntityMaxSpeed(vehicle, maxSpeedMS)
            end
        else
            -- Bỏ giới hạn cho các phương tiện đặc biệt
            SetVehicleMaxSpeed(vehicle, 0.0)
        end
    end
end

-- -- Thread kiểm tra liên tục
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500) -- check mỗi nửa giây cho nhẹ
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if vehicle ~= 0 then
            checkSpeed(vehicle)
        end
    end
end)

-- Citizen.CreateThread(function()
-- 	while true do
-- 		Citizen.Wait(0)
-- 		if currentWeaponHash ~= -1569615261 then
--         	SetPlayerLockon(PlayerId(), false)
--         else
--         	SetPlayerLockon(PlayerId(), true)
-- 		end
-- 	end
-- end)