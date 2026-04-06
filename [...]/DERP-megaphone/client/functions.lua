local attachedProp = 0

-- Notify dùng ox_lib
local function notify(text)
    lib.notify({ description = text, type = 'inform' })
end

local function printDebug(text)
    if not Config.debug then return end
    print(text)
end

-- ────────────────────────────────────────────────────────────
-- VOICE
-- ────────────────────────────────────────────────────────────

function setProximity(distance)
    exports['pma-voice']:overrideProximityRange(distance, true)
    printDebug('[Proximity] Changed To ' .. distance)
end

function toggleMegaphone(micType, status)
    local srcSrv = GetPlayerServerId(PlayerId())
    local proximity = Config.proximityDistances[micType]

    if status and proximity then
        setProximity(proximity)
        MumbleSetAudioInputIntent(`music`)
        if Config.volume ~= -1.0 then
            MumbleSetVolumeOverrideByServerId(srcSrv, Config.volume)
        end
        notify('Megaphone Bật')
        TriggerServerEvent('DERP-megaphone:server:addsubmix', srcSrv)
    else
        exports['pma-voice']:clearProximityOverride()
        MumbleSetAudioInputIntent(`speech`)
        if Config.volume ~= -1.0 then
            MumbleSetVolumeOverrideByServerId(srcSrv, -1.0)
        end
        notify('Megaphone Tắt')
        TriggerServerEvent('DERP-megaphone:server:removesubmix', srcSrv)
        printDebug('[Megaphone] Proximity reset to default')
    end

    if micType == 'handHeld' then
        handleMegaphoneAnimation(status)
    end
end

-- ────────────────────────────────────────────────────────────
-- ANIMATION & PROP
-- ────────────────────────────────────────────────────────────

function handleMegaphoneAnimation(enable)
    local ped = PlayerPedId()
    local dict = 'amb@world_human_mobile_film_shocking@female@base'
    local anim = 'base'

    if enable then
        loadAnimDict(dict)
        attachProp('prop_megaphone_01', 28422, 0.04, -0.01, 0.0, 22.0, -4.0, 87.0, 2, false)
        if not IsEntityPlayingAnim(ped, dict, anim, 3) then
            TaskPlayAnim(ped, dict, anim, 1.0, 1.0, GetAnimDuration(dict, anim), 49, 0, 0, 0, 0)
        end
    else
        StopAnimTask(ped, dict, anim, 3.0)
        removeAttachedProp()
    end
end

function removeAttachedProp()
    if DoesEntityExist(attachedProp) then
        DeleteEntity(attachedProp)
        attachedProp = 0
    end
end

function attachProp(model, boneNumber, x, y, z, xR, yR, zR, vertexIndex, disableCollision)
    removeAttachedProp()

    local modelHash = GetHashKey(model)
    local ped       = PlayerPedId()
    local boneIndex = GetPedBoneIndex(ped, boneNumber)

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Wait(10) end

    attachedProp = CreateObject(modelHash, 1.0, 1.0, 1.0, true, true, false)
    if disableCollision then
        SetEntityCollision(attachedProp, false, false)
    end

    AttachEntityToEntity(attachedProp, ped, boneIndex, x, y, z, xR, yR, zR, true, true, false, false, vertexIndex or 2, true)
    SetModelAsNoLongerNeeded(modelHash)
end

function loadAnimDict(dict)
    if HasAnimDictLoaded(dict) then return end
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(5) end
end

-- ────────────────────────────────────────────────────────────
-- SUBMIX EVENTS
-- ────────────────────────────────────────────────────────────

RegisterNetEvent('DERP-megaphone:client:addsubmix', function(id)
    local fx = CreateAudioSubmix('megaphone')
    SetAudioSubmixEffectRadioFx(fx, 1)
    SetAudioSubmixEffectParamInt(fx, 1, GetHashKey('default'), 1)
    SetAudioSubmixEffectParamFloat(fx, 1, GetHashKey('freq_low'),   10.0)
    SetAudioSubmixEffectParamFloat(fx, 1, GetHashKey('freq_hi'),    10000.0)
    SetAudioSubmixEffectParamFloat(fx, 1, GetHashKey('rm_mod_freq'), 300.0)
    SetAudioSubmixEffectParamFloat(fx, 1, GetHashKey('rm_mix'),     0.2)
    SetAudioSubmixEffectParamFloat(fx, 1, GetHashKey('fudge'),      0.0)
    SetAudioSubmixEffectParamFloat(fx, 1, GetHashKey('o_freq_lo'),  200.0)
    SetAudioSubmixEffectParamFloat(fx, 1, GetHashKey('o_freq_hi'),  5000.0)
    AddAudioSubmixOutput(fx, 1)
    MumbleSetSubmixForServerId(id, fx)
    printDebug('[Submix] Added for ID: ' .. id)
end)

RegisterNetEvent('DERP-megaphone:client:removesubmix', function(id)
    MumbleSetSubmixForServerId(id, -1)
    printDebug('[Submix] Removed for ID: ' .. id)
end)

-- ────────────────────────────────────────────────────────────
-- MIC ZONE HELPERS
-- ────────────────────────────────────────────────────────────

function handleMicInteraction(isInside, zone)
    if isInside then
        toggleMegaphone('stage', true)
    else
        toggleMegaphone('stage', false)
        zone:remove()
    end
end

function createMicPoly(model)
    local pCoords    = GetEntityCoords(PlayerPedId())
    local micEntity  = GetClosestObjectOfType(pCoords.x, pCoords.y, pCoords.z, 20.0, model, false, false, false)
    if micEntity == 0 then
        printDebug('[Error] Microphone object not found nearby.')
        return
    end

    local coords = GetEntityCoords(micEntity)
    lib.zones.box({
        coords   = vec3(coords.x, coords.y, coords.z),
        size     = vec3(1.5, 1.0, 4.0),
        rotation = GetEntityHeading(micEntity),
        onEnter  = function(self) handleMicInteraction(true,  self) end,
        onExit   = function(self) handleMicInteraction(false, self) end,
        debug    = Config.debug
    })
end

function createMicZoneAtLocation(location)
    lib.zones.poly({
        points = {
            vec3(location.coords.x + 1.5, location.coords.y,       location.coords.z),
            vec3(location.coords.x,       location.coords.y + 1.5, location.coords.z),
            vec3(location.coords.x - 1.5, location.coords.y,       location.coords.z),
            vec3(location.coords.x,       location.coords.y - 1.5, location.coords.z),
        },
        thickness = 4.0,
        debug     = Config.debug,
        onEnter   = function(self) handleMicInteraction(true,  self) end,
        onExit    = function(self) handleMicInteraction(false, self) end,
    })
    printDebug('[Microphone] Zone created at: ' .. tostring(location.coords))
end
