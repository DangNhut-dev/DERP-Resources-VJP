local animPlaying = false

local function IsPoliceOnDuty()
    local playerData = exports.qbx_core:GetPlayerData()
    if not playerData or not playerData.job then return false end
    return playerData.job.name == Config.PoliceJob and playerData.job.onduty == true
end

local function PlayUnequipAnim()
    if animPlaying then return end
    animPlaying = true
    local ped = cache.ped
    lib.requestAnimDict(Config.AnimDict)
    TaskPlayAnim(ped, Config.AnimDict, Config.AnimName, 3.0, 3.0, Config.AnimDuration, 49, 0, false, false, false)
    SetTimeout(Config.AnimDuration, function()
        ClearPedTasks(ped)
        RemoveAnimDict(Config.AnimDict)
        animPlaying = false
    end)
end

local function GetPidFromPed(targetPed)
    for _, pid in ipairs(GetActivePlayers()) do
        if GetPlayerPed(pid) == targetPed then
            return pid
        end
    end
    return -1
end

local function OnSelect(data, itemType)
    local pid = GetPidFromPed(data.entity)
    if pid == -1 or pid == PlayerId() then return end
    local targetSrc = GetPlayerServerId(pid)
    if not targetSrc or targetSrc == 0 then return end
    PlayUnequipAnim()
    TriggerServerEvent('DERP-unequipmaskandbaloPD:requestUnequip', targetSrc, itemType)
end

exports.ox_target:addGlobalPlayer({
    {
        name     = 'derp_pd_unequip_mask',
        label    = 'Tháo mặt nạ',
        icon     = 'fas fa-mask',
        distance = Config.TargetDistance,
        canInteract = IsPoliceOnDuty,
        onSelect = function(data) OnSelect(data, 'mask') end,
    },
    {
        name     = 'derp_pd_unequip_backpack',
        label    = 'Tháo balo',
        icon     = 'fas fa-briefcase',
        distance = Config.TargetDistance,
        canInteract = IsPoliceOnDuty,
        onSelect = function(data) OnSelect(data, 'backpack') end,
    },
})

RegisterNetEvent('DERP-unequipmaskandbaloPD:notify', function(ntype, msg)
    lib.notify({ type = ntype, description = msg })
end)