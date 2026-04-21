local isPhoneOpen = false
local isAnimating = false
local phoneProp = 0

local PlayerState = LocalPlayer.state

-- Kiem tra dieu kien co the mo phone
local function CanOpenPhone()
    local ped = cache.ped
    if not ped or ped == 0 then return false end
    if IsPedDeadOrDying(ped, true) and Config.UseConditions.disableOnDead then return false end
    if PlayerState.isCuffed and Config.UseConditions.disableOnCuffed then return false end
    if IsPedSwimming(ped) and not Config.UseConditions.allowWhileSwimming then return false end
    if IsPedFalling(ped) and not Config.UseConditions.allowWhileFalling then return false end
    return true
end

-- Load animation dict
local function LoadAnim(dict)
    if HasAnimDictLoaded(dict) then return true end
    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 2000
    while not HasAnimDictLoaded(dict) and GetGameTimer() < timeout do
        Wait(10)
    end
    return HasAnimDictLoaded(dict)
end

-- Load model prop
local function LoadModel(model)
    if HasModelLoaded(model) then return true end
    RequestModel(model)
    local timeout = GetGameTimer() + 2000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do
        Wait(10)
    end
    return HasModelLoaded(model)
end

-- Attach prop phone vao tay
local function AttachProp()
    if not Config.Prop.enabled then return end
    if phoneProp ~= 0 and DoesEntityExist(phoneProp) then return end
    local ped = cache.ped
    if not LoadModel(Config.Prop.model) then return end

    local coords = GetEntityCoords(ped)
    phoneProp = CreateObject(Config.Prop.model, coords.x, coords.y, coords.z, true, true, false)
    AttachEntityToEntity(
        phoneProp, ped,
        GetPedBoneIndex(ped, Config.Prop.bone),
        Config.Prop.offset.x, Config.Prop.offset.y, Config.Prop.offset.z,
        Config.Prop.rotation.x, Config.Prop.rotation.y, Config.Prop.rotation.z,
        true, true, false, true, 1, true
    )
    SetModelAsNoLongerNeeded(Config.Prop.model)
end

-- Xoa prop phone
local function DetachProp()
    if phoneProp ~= 0 and DoesEntityExist(phoneProp) then
        DeleteEntity(phoneProp)
    end
    phoneProp = 0
end

-- Choi animation cam phone
local function PlayPhoneAnim()
    local ped = cache.ped
    if not LoadAnim(Config.AnimationDict) then return end
    if not IsEntityPlayingAnim(ped, Config.AnimationDict, Config.AnimationName, 3) then
        TaskPlayAnim(ped, Config.AnimationDict, Config.AnimationName, 3.0, 3.0, -1, 49, 0, false, false, false)
    end
end

-- Dung animation cam phone
local function StopPhoneAnim()
    local ped = cache.ped
    StopAnimTask(ped, Config.AnimationDict, Config.AnimationName, 1.0)
end

-- Disable controls khi phone mo
local function DisableControlsThread()
    CreateThread(function()
        while isPhoneOpen do
            for i = 1, #Config.DisableControlsOnOpen do
                DisableControlAction(0, Config.DisableControlsOnOpen[i], true)
            end
            Wait(0)
        end
    end)
end

-- Sync gio trong game sang NUI khi phone mo
local function GameClockThread()
    CreateThread(function()
        local lastH, lastM, lastD, lastMo, lastY = -1, -1, -1, -1, -1
        while isPhoneOpen do
            local h = GetClockHours()
            local m = GetClockMinutes()
            local d = GetClockDayOfMonth()
            local mo = GetClockMonth() + 1
            local y = GetClockYear()
            local dow = GetClockDayOfWeek()
            if h ~= lastH or m ~= lastM or d ~= lastD or mo ~= lastMo or y ~= lastY then
                lastH, lastM, lastD, lastMo, lastY = h, m, d, mo, y
                SendNUIMessage({
                    action = 'clock',
                    hour = h, minute = m,
                    day = d, month = mo, year = y,
                    dayOfWeek = dow
                })
            end
            Wait(2000)
        end
    end)
end

-- Mo phone
function OpenPhone()
    if isPhoneOpen or isAnimating then return end
    if not CanOpenPhone() then
        lib.notify({ title = 'Phone', description = 'Không thể sử dụng lúc này', type = 'error' })
        return
    end

    isAnimating = true
    PlayPhoneAnim()
    AttachProp()
    isPhoneOpen = true
    isAnimating = false

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        apps = Apps.GetList(),
        clock = {
            hour = GetClockHours(),
            minute = GetClockMinutes(),
            day = GetClockDayOfMonth(),
            month = GetClockMonth() + 1,
            year = GetClockYear(),
            dayOfWeek = GetClockDayOfWeek()
        }
    })

    DisableControlsThread()
    GameClockThread()
end

-- Dong phone
function ClosePhone()
    if not isPhoneOpen then return end
    isPhoneOpen = false

    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    StopPhoneAnim()
    DetachProp()
end

-- Check phone dang mo
function IsPhoneOpen()
    return isPhoneOpen
end

-- Event tu item client trigger (goi khi nguoi choi su dung item blackphone)
RegisterNetEvent('derp-blackphone:client:useItem', function()
    if isPhoneOpen then
        ClosePhone()
        return
    end
    if not CanOpenPhone() then
        lib.notify({ title = 'Phone', description = 'Không thể sử dụng lúc này', type = 'error' })
        return
    end
    TriggerServerEvent('derp-blackphone:server:requestOpen')
end)

-- Event mo phone tu server
RegisterNetEvent('derp-blackphone:client:open', function()
    OpenPhone()
end)

-- Event dong phone
RegisterNetEvent('derp-blackphone:client:close', function()
    ClosePhone()
end)

-- Auto dong phone khi bi cong (khoi phuc sau khi co server ID)
CreateThread(function()
    while GetPlayerServerId(PlayerId()) == 0 do Wait(100) end
    AddStateBagChangeHandler('isCuffed', ('player:%s'):format(GetPlayerServerId(PlayerId())), function(_, _, value)
        if value and Config.CloseOnCuffed and isPhoneOpen then
            ClosePhone()
        end
    end)
end)

-- Auto dong phone khi chet (qbx_core event)
AddEventHandler('qbx_medical:client:onPlayerDied', function()
    if Config.CloseOnDeath and isPhoneOpen then
        ClosePhone()
    end
end)

AddEventHandler('baseevents:onPlayerKilled', function()
    if Config.CloseOnDeath and isPhoneOpen then
        ClosePhone()
    end
end)

-- Keybind optional
if Config.OpenKeybind then
    lib.addKeybind({
        name = 'openblackphone',
        description = 'Mở Black Phone',
        defaultKey = Config.KeybindKey,
        onPressed = function()
            TriggerEvent('derp-blackphone:client:useItem')
        end
    })
end

-- Cleanup khi resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if isPhoneOpen then
        SetNuiFocus(false, false)
        StopPhoneAnim()
    end
    DetachProp()
end)

-- Export cho resource khac dang ky app
-- data: { id, name, icon, color, resource, order? }
exports('RegisterApp', function(data)
    if not data or not data.id or not data.resource then return false end

    local ok = Apps.Register({
        id = data.id,
        name = data.name or data.id,
        icon = data.icon or 'fa-solid fa-square',
        color = data.color or '#05f2f2',
        enabled = true,
        order = data.order or 99,
        external = true,
        resource = data.resource
    })

    if ok and isPhoneOpen then
        SendNUIMessage({
            action = 'updateApps',
            apps = Apps.GetList()
        })
    end
    return ok
end)

exports('UnregisterApp', function(appId)
    if not appId then return false end
    for i = #Apps.Registered, 1, -1 do
        if Apps.Registered[i].id == appId and Apps.Registered[i].external then
            table.remove(Apps.Registered, i)
            break
        end
    end
    if isPhoneOpen then
        SendNUIMessage({
            action = 'updateApps',
            apps = Apps.GetList()
        })
    end
    return true
end)

exports('IsAppRegistered', function(appId)
    return Apps.Get(appId) ~= nil
end)

-- Push message toi app NUI (forward tu resource khac vao iframe app)
exports('PushAppMessage', function(appId, payload)
    if not appId or not payload then return false end
    if not isPhoneOpen then return false end
    SendNUIMessage({
        action = 'pushToApp',
        appId = appId,
        payload = payload
    })
    return true
end)

-- Check player co phone item khong (client-side cache)
local function PlayerHasPhone()
    if not Config.Item then return false end
    local count = exports.ox_inventory:Search('count', Config.Item)
    return type(count) == 'number' and count > 0
end

-- Notify export: hien banner thong bao tren UI cua phone
-- data = {
--   appId = 'weedshop',           -- bat buoc, app ID da register
--   title = 'Marcus Johnson',     -- bat buoc, line dau
--   body = 'Hang ngon do bro',    -- bat buoc, line noi dung
--   icon = 'fa-solid fa-cannabis',-- optional, font awesome class (default tu app config)
--   color = '#4ade80',            -- optional, mau icon (default tu app config)
--   onClick = { ... }             -- optional, payload gui cho app khi click banner
-- }
exports('Notify', function(data)
    if Config.Debug then
        print(('[BlackPhone] Notify called: appId=%s title=%s'):format(
            tostring(data and data.appId), tostring(data and data.title)))
    end
    if not data or not data.appId or not data.title or not data.body then
        if Config.Debug then print('[BlackPhone] Notify rejected: missing required fields') end
        return false
    end
    if isAnimating then
        if Config.Debug then print('[BlackPhone] Notify rejected: isAnimating') end
        return false
    end
    -- Khong notify khi phone dang mo (vi user dang dung phone roi)
    if isPhoneOpen then
        if Config.Debug then print('[BlackPhone] Notify rejected: phone is open') end
        return false
    end
    if not PlayerHasPhone() then
        if Config.Debug then print('[BlackPhone] Notify rejected: no phone item') end
        return false
    end

    local app = Apps.Get(data.appId)
    if Config.Debug then
        print(('[BlackPhone] Notify sending to NUI (app registered: %s)'):format(tostring(app ~= nil)))
    end
    SendNUIMessage({
        action = 'notify',
        notification = {
            appId = data.appId,
            appName = (app and app.name) or data.appName or 'App',
            title = data.title,
            body = data.body,
            icon = data.icon or (app and app.icon) or 'fa-solid fa-bell',
            color = data.color or (app and app.color) or '#05F2F2',
            onClick = data.onClick or nil,
            timestamp = GetCloudTimeAsInt()
        }
    })
    return true
end)

-- Command test notification
-- RegisterCommand('testphonenotify', function(_, args)
--     local title = args[1] or 'Test Notify'
--     local body = args[2] or 'Banner thong bao tu command test'
--     local appId = args[3] or 'weedshop'
--     local resName = GetCurrentResourceName()
--     local result = exports[resName]:Notify({
--         appId = appId,
--         title = title,
--         body = body,
--         icon = 'fa-solid fa-bell',
--         color = '#05F2F2'
--     })
--     print(('[BlackPhone] testphonenotify result: %s (resource: %s)'):format(tostring(result), resName))
--     lib.notify({ title = 'Test Notify', description = 'Result: ' .. tostring(result), type = 'inform' })
-- end, false)

-- NUI callback: phat sound notify (native GTA fallback khi HTML5 audio bi block)
RegisterNUICallback('playNotifSound', function(data, cb)
    cb({ ok = true })
    -- Native GTA sound: dung PHONE notification sound
    PlaySoundFrontend(-1, 'Text_Arrive_Tone', 'Phone_SoundSet_Default', true)
end)

-- Khi player click banner notification -> mo phone + auto navigate vao app
RegisterNUICallback('notificationClicked', function(data, cb)
    cb({ ok = true })
    if not data or not data.appId then return end
    -- Trigger mo phone (giong nhu su dung item)
    TriggerEvent('derp-blackphone:client:useItem')
    -- Sau khi phone mo, push vao app target
    SetTimeout(600, function()
        if isPhoneOpen then
            SendNUIMessage({
                action = 'openApp',
                appId = data.appId,
                onClick = data.onClick
            })
            -- Forward onClick payload vao app neu app dang chay
            if data.onClick then
                SendNUIMessage({
                    action = 'pushToApp',
                    appId = data.appId,
                    payload = {
                        action = 'notification:click',
                        data = data.onClick
                    }
                })
            end
        end
    end)
end)