-- client.lua

local isAdminUIOpen = false

-- Send message to NUI
local function SendAnnounce(action, data)
    data.action = action
    SetNuiFocus(false, false)
    SendNUIMessage(data)
end

-- Receive announcement from server (custom + txAdmin intercepted)
RegisterNetEvent('derp-announce:send', function(data)
    if type(data) ~= 'table' then return end
    SendAnnounce('announce', {
        message = tostring(data.message or ''),
        time    = tonumber(data.time) or Config.DefaultTime,
        sound   = Config.Sound.enabled and Config.Sound.announce or nil,
        volume  = Config.Sound.volume
    })
end)

-- Open admin UI (triggered from server after validation)
RegisterNetEvent('derp-announce:openAdmin', function()
    if isAdminUIOpen then return end
    isAdminUIOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openAdmin' })
end)

-- Command: /announceui — server validates permission before opening UI
RegisterCommand('announceui', function()
    TriggerServerEvent('derp-announce:requestAdminUI')
end, false)

-- NUI close admin
RegisterNUICallback('closeAdmin', function(_, cb)
    isAdminUIOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

-- NUI submit announcement
RegisterNUICallback('sendAnnounce', function(data, cb)
    if type(data.message) ~= 'string' or data.message == '' then
        cb('invalid')
        return
    end
    TriggerServerEvent('derp-announce:create', {
        message = data.message,
        time    = tonumber(data.time) or Config.DefaultTime
    })
    isAdminUIOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)