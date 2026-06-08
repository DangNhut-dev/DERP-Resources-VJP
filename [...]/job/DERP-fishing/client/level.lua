local xp = 0

---@param l number
local function updated(l)
    if not l then return end

    xp = l
    Update(GetCurrentLevel())
end

local function fetchLevel()
    TriggerServerEvent('derp-fishing:requestLevel')
end

RegisterNetEvent('esx:playerLoaded', fetchLevel)
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', fetchLevel)

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= cache.resource then return end
    SetTimeout(2000, fetchLevel)
end)

RegisterNetEvent('derp-fishing:updateLevel', updated)

function GetCurrentLevel()
    return math.floor(xp / Config.xpPerLevel) + 1
end

function GetCurrentLevelProgress()
    return (xp % Config.xpPerLevel) / Config.xpPerLevel
end