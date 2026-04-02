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

RegisterCommand('getprop', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    
    local dest = {
        x = coords.x + forward.x * 5.0,
        y = coords.y + forward.y * 5.0,
        z = coords.z + 0.5
    }
    
    local _, hit, _, _, entity = GetShapeTestResult(
        StartShapeTestRay(
            coords.x, coords.y, coords.z + 0.5,
            dest.x, dest.y, dest.z,
            -1, ped, 0
        )
    )
    
    if hit and entity ~= 0 then
        local hash = GetEntityModel(entity)
        local eCoords = GetEntityCoords(entity)
        print('=== ENTITY INFO ===')
        print('Hash: ' .. hash)
        print('Coords: ' .. eCoords.x .. ', ' .. eCoords.y .. ', ' .. eCoords.z)
        print('Is Object: ' .. tostring(IsEntityAnObject(entity)))
    else
        print('Không tìm thấy entity phía trước')
    end
end, false)