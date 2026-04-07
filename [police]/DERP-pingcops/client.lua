local function GetStreetLabel()
    local coords = GetEntityCoords(cache.ped)
    local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local street = GetStreetNameFromHashKey(streetHash)
    local crossing = crossingHash ~= 0 and GetStreetNameFromHashKey(crossingHash) or nil
    if crossing then
        return street .. ' / ' .. crossing, coords
    end
    return street, coords
end

local function PingDispatch(dispatchType)
    local streetLabel, coords = GetStreetLabel()
    TriggerServerEvent('DERP-pingcops:server:ping', dispatchType, {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        street = streetLabel,
    })
end

local function ShouldPlaySound(locationData)
    local playerData = exports.qbx_core:GetPlayerData()
    local isPoliceOnDuty = playerData.job.name == Config.Dispatch.job and playerData.job.onduty

    if isPoliceOnDuty then return true end

    local myCoords = GetEntityCoords(cache.ped)
    local dist = #(myCoords - vector3(locationData.x, locationData.y, locationData.z))
    return dist <= 5.0
end

RegisterNetEvent('DERP-pingcops:client:playSound', function(locationData)
    if not ShouldPlaySound(locationData) then return end

    CreateThread(function()
        for i = 1, 5 do
            PlaySoundFrontend(-1, 'TIMER_STOP', 'HUD_MINI_GAME_SOUNDSET', true)
            Wait(1000)
        end
    end)
end)

RegisterCommand('13a', function()
    PingDispatch('13a')
end, false)

RegisterCommand('13b', function()
    PingDispatch('13b')
end, false)