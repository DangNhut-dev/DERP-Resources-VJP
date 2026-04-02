lib.locale()

local QBX = exports.qbx_core

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBX:GetPlayerData()
    TriggerServerEvent("drc_houserobbery:sync")
    TriggerServerEvent("drc_houserobbery:missionsync2")
end)

RegisterNetEvent("drc_houserobbery:notify")
AddEventHandler("drc_houserobbery:notify", function(type, title, text)
    Notify(type, title, text)
end)

Notify = function(type, title, text)
    if Config.NotificationType == "ox_lib" then
        if type == "info" then
            lib.notify({ title = title, description = text, type = "inform", duration = 15000 })
        elseif type == "error" then
            lib.notify({ title = title, description = text, type = "error" })
        elseif type == "success" then
            lib.notify({ title = title, description = text, type = "success" })
        end
    elseif Config.NotificationType == "qbcore" then
        if type == "success" then
            QBX:Notify(text, "success", 10000)
        elseif type == "info" then
            QBX:Notify(text, "inform", 15000)
        elseif type == "error" then
            QBX:Notify(text, "error", 10000)
        end
    elseif Config.NotificationType == "custom" then
        print("add your notification system! in cl_Utils.lua")
    end
end

ProgressBar = function(duration, label)
    if Config.Progress == "ox_lib" then
        lib.progressBar({
            duration = duration,
            label = label,
            useWhileDead = false,
            canCancel = false
        })
    elseif Config.Progress == "qbcore" then
        QBX:Notify(label, 'inform', duration)
        Wait(duration)
    elseif Config.Progress == "progressBars" then
        exports['progressBars']:startUI(duration, label)
        Wait(duration)
    end
end

TextUIShow = function(text)
    if Config.TextUI == "ox_lib" then
        lib.showTextUI(text, { position = 'left-center' })
    elseif Config.TextUI == "esx" then
        exports["esx_textui"]:TextUI(text)
    elseif Config.TextUI == "luke" then
        TriggerEvent('luke_textui:ShowUI', text)
    elseif Config.TextUI == "custom" then
        print("add your textui system! in cl_Utils.lua")
    end
end

IsTextUIShowed = function()
    if Config.TextUI == "ox_lib" then
        return lib.isTextUIOpen()
    end
    return false
end

TextUIHide = function()
    if Config.TextUI == "ox_lib" then
        lib.hideTextUI()
    elseif Config.TextUI == "esx" then
        exports["esx_textui"]:HideUI()
    elseif Config.TextUI == "luke" then
        TriggerEvent('luke_textui:HideUI')
    elseif Config.TextUI == "custom" then
        print("add your textui system! in cl_Utils.lua")
    end
end

Draw3DText = function(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)

    if onScreen then
        SetTextFont(Config.FontId)
        SetTextScale(0.33, 0.30)
        SetTextDropshadow(10, 100, 100, 100, 255)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 350
        DrawRect(_x, _y + 0.0135, 0.025 + factor, 0.03, 0, 0, 0, 10)
    end
end

-- Wrapper bridge qb-target API → ox_target API
Target = function()
    if Config.Target == "ox_target" then
        local wrapper = {}

        -- qb-target: AddTargetEntity(entity, { options = {...}, distance = N })
        -- ox_target: addLocalEntity(entity, { {name, icon, label, distance, onSelect, canInteract} })
        function wrapper:AddTargetEntity(entity, data)
            local oxOptions = {}
            for _, opt in ipairs(data.options) do
                oxOptions[#oxOptions + 1] = {
                    name = opt.label,
                    icon = opt.icon or 'fas fa-circle',
                    label = opt.label,
                    distance = data.distance or 2.0,
                    canInteract = opt.canInteract or nil,
                    onSelect = function()
                        if opt.action then
                            opt.action(entity)
                        elseif opt.event then
                            if opt.type == 'server' then
                                TriggerServerEvent(opt.event, opt.args)
                            else
                                TriggerEvent(opt.event, opt.args)
                            end
                        end
                    end,
                }
            end
            exports['ox_target']:addLocalEntity(entity, oxOptions)
        end

        -- qb-target: AddCircleZone(name, coords, radius, zoneData, targetData)
        -- ox_target: addSphereZone({ coords, radius, debug, options })
        function wrapper:AddCircleZone(name, coords, radius, zoneData, targetData)
            local oxOptions = {}
            for _, opt in ipairs(targetData.options) do
                oxOptions[#oxOptions + 1] = {
                    name = name .. '_' .. (opt.label or ''),
                    icon = opt.icon or 'fas fa-circle',
                    label = opt.label,
                    distance = targetData.distance or 2.0,
                    canInteract = opt.canInteract or nil,
                    onSelect = function()
                        if opt.action then
                            opt.action()
                        elseif opt.event then
                            if opt.type == 'server' then
                                TriggerServerEvent(opt.event, opt.args)
                            else
                                TriggerEvent(opt.event, opt.args)
                            end
                        end
                    end,
                }
            end
            return exports['ox_target']:addSphereZone({
                coords = coords,
                radius = radius,
                debug = zoneData and zoneData.debugPoly or false,
                options = oxOptions,
            })
        end

        -- qb-target: RemoveZone(name) → ox_target: removeZone(id)
        function wrapper:RemoveZone(id)
            if id then
                exports['ox_target']:removeZone(id)
            end
        end

        return wrapper
    elseif Config.Target == "qtarget" then
        return exports['qtarget']
    elseif Config.Target == "qb-target" then
        return exports['qb-target']
    end
end

Dispatch = function(coords, type)
    if Config.Dispatch.enabled then
        if Config.Dispatch.script == "lb-tablet" then
            if type == "houserobbery" then
                local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
                local streetLabel = GetStreetNameFromHashKey(streetHash) or 'Không xác định'
                local street2 = (crossingHash and crossingHash ~= 0) and GetStreetNameFromHashKey(crossingHash) or ''
                if street2 ~= '' then streetLabel = streetLabel .. ' & ' .. street2 end
                TriggerServerEvent('drc_houserobbery:server:dispatch', coords, streetLabel)
            end
        elseif Config.Dispatch.script == "cd_dispatch" then
            if type == "houserobbery" then
                TriggerServerEvent('cd_dispatch:AddNotification', {
                    job_table = Config.PoliceJobs,
                    coords = coords,
                    title = "10-90 - Trộm Nhà",
                    message = "Phát hiện hành vi đột nhập nhà",
                    flash = 0,
                    unique_id = tostring(math.random(0000000, 9999999)),
                    blip = {
                        sprite = 40, scale = 1.2, colour = 1, flashes = false,
                        text = "Trộm Nhà", time = (5 * 60 * 1000), sound = 1,
                    }
                })
            end
        elseif Config.Dispatch.script == "linden_outlawalert" then
            if type == "houserobbery" then
                local data = { displayCode = "10-90", description = "Trộm Nhà", isImportant = 1,
                    recipientList = Config.PoliceJobs,
                    length = '10000', infoM = 'fa-info-circle', info = "Phát hiện hành vi đột nhập nhà" }
                local dispatchData = { dispatchData = data, caller = 'alarm', coords = coords }
                TriggerServerEvent('wf-alerts:svNotify', dispatchData)
            end
        elseif Config.Dispatch.script == "ps-disptach" then
            if type == "houserobbery" then
                exports["ps-dispatch"]:CustomAlert({
                    coords = coords,
                    message = "Trộm Nhà",
                    dispatchCode = "10-90",
                    description = "Phát hiện hành vi đột nhập nhà",
                    radius = 0, sprite = 40, color = 1, scale = 1.2, length = 3,
                })
            end
        elseif Config.Dispatch.script == "core-dispatch" then
            if type == "houserobbery" then
                for k, v in pairs(Config.PoliceJobs) do
                    exports['core_dispatch']:addCall("10-90", "Phát hiện hành vi đột nhập nhà",
                        {}, {coords.xyz}, v, 10000, 11, 5)
                end
            end
        elseif Config.Dispatch.script == "custom" then
            print("add your dispatch system! in cl_Utils.lua")
        end
    end
end

function CheckJob()
    local HasJob = false
    local jobName = QBX:GetPlayerData().job.name
    for _, job in pairs(Config.PoliceJobs) do
        if jobName == job then
            HasJob = true
        end
    end
    return HasJob
end

function GetJob()
    return QBX:GetPlayerData().job.name
end

local function EnumerateEntitiesWithinDistance(entities, isPlayerEntities, coords, maxDistance)
    local nearbyEntities = {}

    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        coords = GetEntityCoords(cache.ped)
    end

    for k, entity in pairs(entities) do
        local distance = #(coords - GetEntityCoords(entity))
        if distance <= maxDistance then
            nearbyEntities[#nearbyEntities + 1] = isPlayerEntities and k or entity
        end
    end

    return nearbyEntities
end

function GetAvailableVehicleSpawnPoint(SpawnPoints)
    local spawnPoints = SpawnPoints
    local found, foundSpawnPoint = false, nil

    for i = 1, #spawnPoints do
        if IsSpawnPointClear(spawnPoints[i].Coords, spawnPoints[i].Radius) then
            found, foundSpawnPoint = true, spawnPoints[i]
            break
        end
    end

    if found then
        return true, foundSpawnPoint
    else
        Notify("error", locale("error"), locale("FreeSpace"))
        return false
    end
end

function GetVehicles()
    return GetGamePool('CVehicle')
end

function GetVehiclesInArea(coords, maxDistance)
    return EnumerateEntitiesWithinDistance(GetVehicles(), false, coords, maxDistance)
end

function IsSpawnPointClear(coords, maxDistance)
    return #GetVehiclesInArea(coords, maxDistance) == 0
end

-- Client-side spawn thay cho QBCore.Functions.SpawnVehicle
SpawnVehicle = function(model, coords, heading)
    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end

    local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, heading, true, true)
    local timeout = 0
    while not DoesEntityExist(vehicle) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end

    if DoesEntityExist(vehicle) then
        SetEntityHeading(vehicle, heading)
        local plate = GetVehicleNumberPlateText(vehicle)
        TriggerEvent("vehiclekeys:client:SetOwner", plate)
    end

    SetModelAsNoLongerNeeded(hash)
end

GetClosestCar = function(coords)
    return lib.getClosestVehicle(coords, 5.0, false)
end

HackingMinigame = function()
    local result = lib.waitFor(function()
        local done = false
        local outcome = false
        exports['boii_minigames']:wire_cut({
            style = 'default',
            timer = 60000
        }, function(success)
            outcome = success
            done = true
        end)
        while not done do Wait(0) end
        return outcome
    end)
    return result
end

LockPickMinigame = function()
    local result = false
    local done = false
    exports['boii_minigames']:safe_crack({
        style = 'default',
        difficulty = 3
    }, function(success)
        result = success
        done = true
    end)
    while not done do Wait(0) end
    return result
end

local minigamefinished = nil
DoorLockPickMinigame = function()
    if Config.QuasarLockpickMinigame then
        local success = false
        TriggerEvent('lockpick:client:openLockpick', function(s)
            success = s
            minigamefinished = true
        end)
        repeat
            Wait(100)
        until minigamefinished ~= nil
        minigamefinished = nil
        return success
    else
        local success = exports['lockpick']:startLockpick()
        return success
    end
end

AlarmSound = function()
    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 20.0, "alarm", 0.35)
end

DoorSound = function()
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.25)
end

RegisterNetEvent("drc_houserobbery:lootbag")
AddEventHandler("drc_houserobbery:lootbag", function()
    lib.requestAnimDict("anim@heists@ornate_bank@grab_cash")
    TaskPlayAnim(cache.ped, "anim@heists@ornate_bank@grab_cash", "intro", 3.0, 1.0, -1, 49, 0, false, false, false)
    RemoveAnimDict("anim@heists@ornate_bank@grab_cash")
    Wait(1400)
    ClearPedTasks(cache.ped)
    SetPedComponentVariation(cache.ped, 5, Config.NeedBag.var, Config.NeedBag.color, 0)
end)

OnHouseEnter = function()
    if Config.TimeChange and Config.TimeSync == "realtime" then
        TriggerServerEvent("realtime:event")
    end
end

OnHouseLeave = function()
    if Config.TimeChange and Config.TimeSync == "realtime" then
        TriggerServerEvent("realtime:event")
    end
end