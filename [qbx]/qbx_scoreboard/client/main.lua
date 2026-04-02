local config = require 'config.client'
local isScoreboardOpen, onDutyAdmins

local function drawText3dNoBg(coords, text)
    local onScreen, sx, sy = World3dToScreen2d(coords.x, coords.y, coords.z)
    if not onScreen then return end

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 255)
    SetTextOutline()
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    DrawText(sx, sy)
end

local function shouldShowPlayerId(targetServerId)
    if config.idVisibility == 'all' then return true end
    if onDutyAdmins and onDutyAdmins[cache.serverId] then return true end
    if config.idVisibility == 'admin_only' then return false end
    if config.idVisibility == 'admin_excluded' and onDutyAdmins and onDutyAdmins[targetServerId] then return false end
    return true
end

local function drawPlayerNumbers()
    CreateThread(function()
        while isScoreboardOpen do
            local players = cache('nearbyPlayers', function()
                local p = lib.getNearbyPlayers(GetEntityCoords(cache.ped), config.visibilityDistance, true)
                for i = #p, 1, -1 do
                    p[i].serverId = GetPlayerServerId(p[i].id)
                    if not shouldShowPlayerId(p[i].serverId) then
                        p[i] = p[#p]
                        p[#p] = nil
                    end
                end
                return p
            end, 1000)

            for i = 1, #players do
                local player = players[i]
                local pedCoords = GetEntityCoords(player.ped)
                drawText3dNoBg(vec3(pedCoords.x, pedCoords.y, pedCoords.z + 1.0), '[' .. player.serverId .. ']')
            end
            Wait(0)
        end
    end)
end

local function closeScoreboard()
    isScoreboardOpen = false
end

local function openScoreboard()
    if isScoreboardOpen then return end

    local _, _, admins = lib.callback.await('qbx_scoreboard:server:getScoreboardData')
    onDutyAdmins = admins

    isScoreboardOpen = true
    TriggerServerEvent('qbx_scoreboard:server:notifyNearby')
    drawPlayerNumbers()

    SetTimeout(5000, function()
        closeScoreboard()
    end)
end

lib.addKeybind({
    name        = 'scoreboard',
    description = 'Open Scoreboard',
    defaultKey  = config.openKey,
    onPressed   = openScoreboard,
})

RegisterCommand('ccid', function()
    local citizenId = lib.callback.await('qbx_scoreboard:server:getCitizenId')
    if not citizenId then return end
    lib.setClipboard(citizenId)
    lib.notify({ title = 'Citizen ID', description = citizenId .. ' đã được copy', type = 'success' })
end, false)