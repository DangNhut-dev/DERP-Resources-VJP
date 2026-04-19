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