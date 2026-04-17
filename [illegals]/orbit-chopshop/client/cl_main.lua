local QBX = exports.qbx_core

local PlayerJob = {}
local secondwave = false
local vehicle
local start = false
local removedpart = false

local dropoffx = nil
local dropoffy = nil
local dropoffz = nil
local dropoffm = nil

local LicensePlate = nil
local randomLoc = nil
local copsCalled = false
local scrapblip = false
local targetVehicleModel = nil
local targetVehiclePlate = nil
local randomCoords = nil
local blip = nil
local blip2 = nil

local pendingSpawnCoords = nil
local pendingSpawnTriggered = false

local function dbg(msg, ...)
    print(('[chopshop-debug] ' .. msg):format(...))
end

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    PlayerJob = QBX:GetPlayerData().job
end)

CreateThread(function()
    Wait(500)
    local pd = QBX:GetPlayerData()
    if pd and pd.job then
        PlayerJob = pd.job
    end
end)

CreateThread(function()
    while true do
        Wait(200)
        while dropoffx and dropoffy and dropoffz do
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local dis = #(pos - vector3(dropoffx, dropoffy, dropoffz))
            SetDrawOrigin(dropoffx, dropoffy, dropoffz, 0)
            if dis <= 8 then
                if IsPedInAnyVehicle(ped) and not start then
                    DrawSprite("orbit_ui", "key", 0, 0, 0.018, 0.030, 0, 255, 255, 255, 255)
                    DrawSprite("orbit_ui", "start_chop", 0.044, 0, 0.06, 0.028, 0, 255, 255, 255, 255)
                    if IsControlJustPressed(0, 38) then
                        ScrapVehicle()
                    end
                end
            end
            Wait(3)
        end
    end
end)

local mert = false

CreateThread(function()
    while true do
        Wait(200)
        if scrapblip then
            Wait(1000)
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local dist = #(pos - vector3(Config.VehicleCoords[randomCoords]['coords'].x, Config.VehicleCoords[randomCoords]['coords'].y, Config.VehicleCoords[randomCoords]['coords'].z))
            local scanner = vector3(Config.VehicleCoords[randomCoords]['radarCoords'].x, Config.VehicleCoords[randomCoords]['radarCoords'].y, Config.VehicleCoords[randomCoords]['radarCoords'].z)

            Wait(1)

            if not mert then
                exports['orbit-chopshop']:SetupDigiScanner(scanner, {})
                mert = true
            end

            if dist <= 3 then
                if not copsCalled then
                    local s1, s2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
                    local street1 = GetStreetNameFromHashKey(s1)
                    local street2 = GetStreetNameFromHashKey(s2)
                    local streetLabel = street1
                    if street2 then streetLabel = streetLabel .. " " .. street2 end
                    TriggerServerEvent('orbit-chopshop:server:callCops', "Chopshop", 0, streetLabel, pos, targetVehicleModel, targetVehiclePlate)
                    copsCalled = true
                end
                Wait(5000)
                QBX:Notify(Config.Locale["FoundVeh"], 'success')
                exports["orbit-ui"]:Show(Config.Locale["title"], Config.Locale["chop3"])
                Wait(10000)
                QBX:Notify(Config.Locale["ScrapBlip"], 'inform')
                CreateBlip2()
                SetNewWaypoint(dropoffx, dropoffy)
                scrapblip = false
            end
        end
    end
end)

-- Job accept: validate qua server
RegisterNetEvent('orbit-chopshop:jobaccept', function()
    dbg('Job accept triggered')
    local result = lib.callback.await('orbit-chopshop:server:requestJob', false)
    dbg('RequestJob result: allowed=%s reason=%s', tostring(result and result.allowed), tostring(result and result.reason))

    if not result or not result.allowed then
        if result and result.reason == 'cooldown' then
            QBX:Notify('Hiện tại không có nhiệm vụ mới, quay lại sau ' .. (result.remaining or '?') .. ' phút', 'error')
        elseif result and result.reason == 'active' then
            QBX:Notify(Config.Locale["JobActive"], 'error')
        else
            QBX:Notify(Config.Locale["CoolDown"], 'error')
        end
        return
    end

    local randomVeh = math.random(1, #Config.VehicleList)
    randomCoords = math.random(1, #Config.VehicleCoords)
    randomLoc = math.random(1, #Config.DeliveryCoords)

    dbg('Selected veh=%s coordsIdx=%s deliveryIdx=%s', Config.VehicleList[randomVeh].vehicle, randomCoords, randomLoc)

    SpawnVehicle(
        Config.VehicleList[randomVeh].vehicle,
        Config.VehicleCoords[randomCoords]['coords'].x,
        Config.VehicleCoords[randomCoords]['coords'].y,
        Config.VehicleCoords[randomCoords]['coords'].z,
        Config.VehicleCoords[randomCoords]['coords'].w
    )
end)

function SpawnVehicle(model, x, y, z, w)
    dbg('SpawnVehicle reserve: model=%s coords=%.2f,%.2f,%.2f', model, x, y, z)

    local result = lib.callback.await('orbit-chopshop:server:reserveJobVehicle', false, model, {
        x = x, y = y, z = z, w = w,
    })

    dbg('Reserve result: plate=%s', tostring(result and result.plate))

    if not result or not result.plate then
        dbg('Reserve FAILED')
        QBX:Notify('Không thể tạo nhiệm vụ, thử lại sau', 'error')
        TriggerServerEvent('orbit-chopshop:server:jobCancel')
        return
    end

    LicensePlate = result.plate
    targetVehiclePlate = result.plate
    targetVehicleModel = joaat(model)

    TriggerEvent('orbit-chopshop:client:setJobState', true)

    pendingSpawnCoords = vector3(
        Config.VehicleCoords[randomCoords]['coords'].x,
        Config.VehicleCoords[randomCoords]['coords'].y,
        Config.VehicleCoords[randomCoords]['coords'].z
    )
    pendingSpawnTriggered = false

    dropoffx = Config.DeliveryCoords[randomLoc]['coords'].x
    dropoffy = Config.DeliveryCoords[randomLoc]['coords'].y
    dropoffz = Config.DeliveryCoords[randomLoc]['coords'].z
    dropoffm = Config.DeliveryCoords[randomLoc]['coords'].w

    if Config.Email then
        QBX:Notify(Config.Locale["Email"], 'success')
    else
        QBX:Notify(Config.Locale["Ui"], 'success')
    end

    exports["orbit-ui"]:Show(Config.Locale["title"], Config.Locale["chop1"])

    Wait(math.random(600000, 1200000))
    -- Wait(math.random(600, 1200))

    if Config.Email then
        TriggerServerEvent('qb-phone:server:sendNewMail', {
            sender = "Chop Shop",
            subject = "Vehicle Located",
            message = "Hello,<br><br> The vehicle you need to collect is a<br><b>" ..
                model ..
                " </b> <br><br>The license plate is - <br><b>" ..
                LicensePlate ..
                "</b>.<br><br>The approximate position of the <b>vehicle</b> and the <b>scrapyard</b> you <b>need</b> to bring it to are marked on your GPS.",
        })
    else
        exports["orbit-ui"]:Show(Config.Locale["title"],
            "Xe trong vùng được đánh dấu.<br>Biển số: " .. LicensePlate)
    end

    Wait(math.random(1000, 2000))
    CreateBlip(x, y)
    scrapblip = true
end

function ScrapVehicle()
    local ped = PlayerPedId()
    vehicle = GetVehiclePedIsIn(ped, false)

    local currentPlate = GetVehicleNumberPlateText(vehicle)
    if currentPlate then currentPlate = currentPlate:gsub("%s+", "") end
    local jobPlate = LicensePlate and LicensePlate:gsub("%s+", "") or ""

    dbg('ScrapVehicle check: current=%s job=%s', currentPlate, jobPlate)

    if currentPlate ~= jobPlate then
        dbg('Plate MISMATCH - reject scrap')
        QBX:Notify(Config.Locale["WrongVeh"], 'error')
    else
        QBX:Notify(Config.Locale["Reminder"], 'inform', 8000)
        exports["orbit-ui"]:Show(Config.Locale["title"], Config.Locale["chop4"])
        StartChopping()
        DeleteBlip()
    end
end

CreateThread(function()
    while not HasStreamedTextureDictLoaded("orbit_ui") do
        Wait(10)
        RequestStreamedTextureDict("orbit_ui", true)
    end

    local sleep
    while true do
        sleep = 100
        if start then
            FreezeEntityPosition(vehicle, true)
            for k = 1, #Config.CarTable do
                SetDrawOrigin(Config.CarTable[k].coords.x, Config.CarTable[k].coords.y, Config.CarTable[k].coords.z, 0)
                if Config.CarTable[k].chopped == "cando" and DoesEntityExist(vehicle) and not IsPedInAnyVehicle(PlayerPedId()) then
                    sleep = 0
                    local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()),
                        Config.CarTable[k].coords.x, Config.CarTable[k].coords.y, Config.CarTable[k].coords.z, true)
                    if distance > 1 and distance < 5 then
                        DrawSprite("orbit_ui", "point", 0, 0, 0.015, 0.025, 0, 255, 255, 255, 200)
                    end
                    if distance < Config.CarTable[k].distance then
                        DrawSprite("orbit_ui", "key", 0, 0, 0.018, 0.030, 0, 255, 255, 255, 255)
                        DrawSprite("orbit_ui", "remove", 0.044, 0, 0.06, 0.028, 0, 255, 255, 255, 255)
                        if IsControlJustPressed(1, 38) then
                            StartAnimation(k)
                        end
                        if not removedpart then
                            removedpart = true
                        end
                    end
                end
            end

            if Config.CarTable[7].chopped == true and Config.CarTable[8].chopped == true and Config.CarTable[9].chopped == true and Config.CarTable[10].chopped == true and not secondwave then
                for i = 1, 6 do
                    Config.CarTable[i].chopped = "cando"
                end
                secondwave = true
            end

            if GetVehiclePedIsIn(PlayerPedId()) == vehicle and removedpart then
                local pos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "windscreen"))
                sleep = 0
                SetDrawOrigin(pos.x, pos.y, pos.z, 0)
                DrawSprite("orbit_ui", "key", 0, 0, 0.018, 0.030, 0, 255, 255, 255, 255)
                DrawSprite("orbit_ui", "destroy_car", 0.044, 0, 0.06, 0.028, 0, 255, 255, 255, 255)

                if IsControlJustPressed(1, 38) then
                    if lib.progressBar({
                        duration = 6500,
                        label = Config.Locale["crushing"],
                        useWhileDead = false,
                        canCancel = true,
                        disable = { move = true, car = true, combat = true },
                    }) then
                        TaskLeaveVehicle(PlayerPedId(), vehicle, 1)
                        exports["orbit-ui"]:Close()
                        Wait(1500)
                        NetworkFadeOutEntity(vehicle, false, false)
                        Wait(1000)
                        DeleteEntity(vehicle)
                        TriggerServerEvent('orbit-chopshop:server:jobComplete')
                        TriggerEvent('orbit-chopshop:client:setJobState', false)
                        Reset()
                        LicensePlate = nil
                        dropoffx = nil
                        dropoffy = nil
                        dropoffz = nil
                        dropoffm = nil
                    end
                end
            end

            if dropoffx and start and GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), dropoffx, dropoffy, dropoffz, true) > 50 then
                VehicleToFar()
            end
        end
        Wait(sleep)
    end
end)

function StartAnimation(k)
    if Config.CarTable[k].anim == "wheel1" or Config.CarTable[k].anim == "wheel2" or Config.CarTable[k].anim == "wheel3" or Config.CarTable[k].anim == "wheel4" then
        TriggerEvent('orbit-chopshop:wheelanimation')
        Wait(7000)
        if Config.CarTable[k].anim == "wheel1" then
            SetVehicleWheelXOffset(vehicle, 0, -2000)
        elseif Config.CarTable[k].anim == "wheel2" then
            SetVehicleWheelXOffset(vehicle, 2, -2000)
        elseif Config.CarTable[k].anim == "wheel3" then
            SetVehicleWheelXOffset(vehicle, 1, -2000)
        elseif Config.CarTable[k].anim == "wheel4" then
            SetVehicleWheelXOffset(vehicle, 3, -2000)
        end
        Config.CarTable[k].chopped = true
        TriggerServerEvent('orbit-chopshop:server:rewardplayer', Config.CarTable[k].anim)
    elseif Config.CarTable[k].anim == "door" then
        TaskOpenVehicleDoor(PlayerPedId(), vehicle, 3000, Config.CarTable[k].getin, 10)
        Wait(2500)
        TriggerEvent('orbit-chopshop:dooranimation')
        Wait(4200)
        SetVehicleDoorBroken(vehicle, Config.CarTable[k].destroy, true)
        Config.CarTable[k].chopped = true
        TriggerServerEvent('orbit-chopshop:server:rewardplayer', Config.CarTable[k].anim)
    elseif Config.CarTable[k].anim == "trunk" then
        SetVehicleDoorOpen(vehicle, Config.CarTable[k].destroy, false, true)
        TriggerEvent('orbit-chopshop:trunkanimation')
        Wait(2000)
        Config.CarTable[k].chopped = true
        TriggerServerEvent('orbit-chopshop:server:rewardplayer', Config.CarTable[k].anim)
        Wait(1000)
        SetVehicleDoorBroken(vehicle, Config.CarTable[k].destroy, true)
    elseif Config.CarTable[k].anim == "hood" then
        SetVehicleDoorOpen(vehicle, Config.CarTable[k].destroy, false, true)
        TriggerEvent('orbit-chopshop:hoodanimation')
        Wait(4000)
        SetVehicleDoorBroken(vehicle, Config.CarTable[k].destroy, true)
        Config.CarTable[k].chopped = true
        TriggerServerEvent('orbit-chopshop:server:rewardplayer', Config.CarTable[k].anim)
    end
end

function VehicleToFar()
    DeleteEntity(vehicle)
    Reset()
    exports["orbit-ui"]:Close()
    QBX:Notify(Config.Locale["FarAway"], 'error')
    TriggerServerEvent('orbit-chopshop:server:jobCancel')
    TriggerEvent('orbit-chopshop:client:setJobState', false)
end

function CreateBlip(x, y)
    DeleteBlip()
    x = x + math.random(-75.0, 75.0)
    y = y + math.random(-75.0, 75.0)
    blip = AddBlipForRadius(x, y, 0.0, 100.0)
    SetBlipSprite(blip, 9)
    SetBlipColour(blip, 1)
    SetBlipAlpha(blip, 80)
end

function CreateBlip2()
    DeleteBlip()
    blip2 = AddBlipForCoord(dropoffx, dropoffy, dropoffz)
    SetBlipSprite(blip2, 380)
    SetBlipColour(blip2, 33)
    SetBlipAlpha(blip2, 200)
    SetBlipDisplay(blip2, 4)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Scrap Yard")
    EndTextCommandSetBlipName(blip2)
end

function DeleteBlip()
    if blip and DoesBlipExist(blip) then RemoveBlip(blip) end
    if blip2 and DoesBlipExist(blip2) then RemoveBlip(blip2) end
end

function StartChopping()
    for i = 1, #Config.CarTable do
        local pos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, Config.CarTable[i].vehBone))
        Config.CarTable[i].coords = pos
    end
    start = true
    for k = -1, 2 do
        local pedseat = GetPedInVehicleSeat(vehicle, k)
        TaskLeaveVehicle(pedseat, vehicle, 1)
    end
end

function Reset()
    for i = 1, #Config.CarTable do
        if i <= 6 then
            Config.CarTable[i].chopped = false
        else
            Config.CarTable[i].chopped = "cando"
        end
    end
    secondwave = false
    vehicle = nil
    start = false
    removedpart = false
    copsCalled = false
    mert = false
    pendingSpawnCoords = nil
    pendingSpawnTriggered = false
end

-- SCANNER
local scaleform = RequestScaleformMovie("DIGISCANNER")
local inScaleform = false
local ped = PlayerPedId()
local targetCoords = vector3(0, 0, 0)
local params = {}
local sfpos = { x = 0.1, y = 0.24, width = 0.21, height = 0.51 }
local wait_time = 1000
local scannerBlip = nil
local sfcolors = {
    red = { r = 255, g = 10, b = 10 },
    yellow = { r = 255, g = 209, b = 67 },
    lightblue = { r = 67, g = 200, b = 255 },
    green = { r = 0, g = 255, b = 80 }
}

local function ScaleformMethod(sf, name, data)
    BeginScaleformMovieMethod(sf, name)
    for _, v in ipairs(data or {}) do
        if name == "SET_DISTANCE" then
            PushScaleformMovieMethodParameterFloat(v)
        else
            PushScaleformMovieMethodParameterInt(v)
        end
    end
    PopScaleformMovieFunctionVoid()
end

local sfbars = {
    { dist = 500, bars = 30.0,  wait = 7000 },
    { dist = 400, bars = 40.0,  wait = 6000 },
    { dist = 300, bars = 50.0,  wait = 5000 },
    { dist = 150, bars = 60.0,  wait = 4000 },
    { dist = 80,  bars = 70.0,  wait = 3000 },
    { dist = 40,  bars = 80.0,  wait = 2000 },
    { dist = 10,  bars = 90.0,  wait = 1000 },
    { dist = 0,   bars = 100.0, wait = 500 },
}

local function SetScaleformColor(bar, dot)
    if not inScaleform then return end
    ScaleformMethod(scaleform, "SET_COLOUR", { bar.r, bar.g, bar.b, dot.r, dot.g, dot.b })
end

local function Flashing(dat)
    if dat then
        ScaleformMethod(scaleform, "flashOn")
    else
        ScaleformMethod(scaleform, "flashOff")
    end
end

local function TriggerEvents()
    inScaleform = false
    if scannerBlip then
        RemoveBlip(scannerBlip)
        scannerBlip = nil
    end
    if params.event then
        if params.isServer then
            TriggerServerEvent(params.event, params.args)
        elseif params.isCommand then
            ExecuteCommand(params.event)
        elseif params.isAction then
            params.event(params.args)
        else
            TriggerEvent(params.event, params.args)
        end
    end
end

local form = nil

function SetupScaleform(sfName, Buttons)
    local sf = RequestScaleformMovie(sfName)
    while not HasScaleformMovieLoaded(sf) do Wait(0) end
    DrawScaleformMovieFullscreen(sf, 255, 255, 255, 0, 0)
    for i = 1, #Buttons do
        PushScaleformMovieFunction(sf, Buttons[i].type)
        if Buttons[i].int then PushScaleformMovieFunctionParameterInt(Buttons[i].int) end
        if Buttons[i].keyIndex then
            for _, v in pairs(Buttons[i].keyIndex) do
                N_0xe83a3e3557a56640(GetControlInstructionalButton(2, v, true))
            end
        end
        if Buttons[i].name then
            BeginTextCommandScaleformString("STRING")
            AddTextComponentScaleform(Buttons[i].name)
            EndTextCommandScaleformString()
        end
        if Buttons[i].type == 'SET_BACKGROUND_COLOUR' then
            for u = 1, 4 do PushScaleformMovieFunctionParameterInt(80) end
        end
        PopScaleformMovieFunctionVoid()
    end
    return sf
end

function UpdateBars(dist)
    if not scaleform then return end

    for i = 1, #sfbars do
        if dist > sfbars[i].dist then
            wait_time = sfbars[i].wait
            ScaleformMethod(scaleform, "SET_DISTANCE", { sfbars[i].bars })
            break
        end
    end

    if dist < 1.0 then
        wait_time = 250
        SetScaleformColor(sfcolors.green, sfcolors.green)
        Flashing(true)
        if not mert then
            mert = true
            if not copsCalled then
                local pos = GetEntityCoords(PlayerPedId())
                local s1, s2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
                local street1 = GetStreetNameFromHashKey(s1)
                local street2 = GetStreetNameFromHashKey(s2)
                local streetLabel = street1
                if street2 then streetLabel = streetLabel .. " " .. street2 end
                TriggerServerEvent('orbit-chopshop:server:callCops', "Chopshop", 0, streetLabel, pos, targetVehicleModel, targetVehiclePlate)
                copsCalled = true
            end
            exports['boii_minigames']:chip_hack({
                style = 'default',
                loading_time = 5000,
                chips = 2,
                timer = 90000,
            }, function(success)
                if success then
                    TriggerEvents()
                    TriggerEvent("vehiclekeys:client:SetOwner", LicensePlate)
                    QBX:Notify(Config.Locale["RadarSuccess"], 'success')
                    Wait(5000)
                    QBX:Notify(Config.Locale["FoundVeh"], 'success')
                    exports["orbit-ui"]:Show(Config.Locale["title"], Config.Locale["chop3"])
                    Wait(10000)
                    QBX:Notify(Config.Locale["ScrapBlip"], 'inform')
                    CreateBlip2()
                    SetNewWaypoint(dropoffx, dropoffy)
                    scrapblip = false
                else
                    if not copsCalled then
                        local pos = GetEntityCoords(PlayerPedId())
                        local s1, s2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
                        local street1 = GetStreetNameFromHashKey(s1)
                        local street2 = GetStreetNameFromHashKey(s2)
                        local streetLabel = street1
                        if street2 then streetLabel = streetLabel .. " " .. street2 end
                        TriggerServerEvent('orbit-chopshop:server:callCops', "Chopshop", 0, streetLabel, pos, targetVehicleModel, targetVehiclePlate)
                        copsCalled = true
                    end
                    QBX:Notify(Config.Locale["RadarError"], 'error')
                    Wait(2000)
                    mert = false
                end
            end)
        end
        DrawScaleformMovieFullscreen(form, 255, 255, 255, 255, 0)
    end
end

local function HeadingCheck(playerCoords, playerHeading, tgtCoords)
    local x = tgtCoords.x - playerCoords.x
    local y = tgtCoords.y - playerCoords.y
    local targetHeading = GetHeadingFromVector_2d(x, y)
    return math.abs(playerHeading - targetHeading) < 20
end

CreateThread(function()
    while not HasScaleformMovieLoaded(scaleform) do Wait(0) end
end)

local function InitiateDigiScanner()
    ped = PlayerPedId()
    if not inScaleform then
        inScaleform = true
        local data = 0
        local playerCoords = GetEntityCoords(ped)
        local playerHeading = GetEntityHeading(ped)
        local dist = #(playerCoords - targetCoords)

        if HeadingCheck(playerCoords, playerHeading, targetCoords) then
            SetScaleformColor(sfcolors.lightblue, sfcolors.yellow)
        else
            SetScaleformColor(sfcolors.red, sfcolors.red)
        end

        UpdateBars(dist)
        inScaleform = true

        if not IsNamedRendertargetRegistered('digiscanner') then
            RegisterNamedRendertarget('digiscanner', 0)
        end
        LinkNamedRendertarget(GetWeapontypeModel(joaat('weapon_digiscanner')))

        if IsNamedRendertargetRegistered('digiscanner') then
            data = GetNamedRendertargetRenderId('digiscanner')
        end

        while inScaleform do
            SetTextRenderId(data)
            DrawScaleformMovie(scaleform, sfpos.x, sfpos.y, sfpos.width, sfpos.height, 100, 100, 100, 255, 0)
            SetTextRenderId(1)

            if IsPlayerFreeAiming(PlayerId()) then
                playerCoords = GetEntityCoords(ped)
                playerHeading = GetEntityHeading(ped)

                if HeadingCheck(playerCoords, playerHeading, targetCoords) then
                    SetScaleformColor(sfcolors.lightblue, sfcolors.yellow)
                else
                    SetScaleformColor(sfcolors.red, sfcolors.red)
                end

                dist = #(playerCoords - targetCoords)
                UpdateBars(dist)
            end

            if not inScaleform then break end
            Wait(1)
        end
    else
        inScaleform = false
        EndScaleformMovieMethodReturn()
    end
end

CreateThread(function()
    local sleep = 1000
    while true do
        if inScaleform then
            if GetSelectedPedWeapon(ped) == joaat('weapon_digiscanner') then
                if IsPlayerFreeAiming(PlayerId()) then
                    local c = GetEntityCoords(ped)
                    PlaySoundFromCoord(-1, "IDLE_BEEP", c.x, c.y, c.z, 'EPSILONISM_04_SOUNDSET', true, 5.0, false)
                end
                Wait(wait_time)
                sleep = 0
            else
                sleep = 5000
            end
        end
        Wait(sleep)
    end
end)

function SetupDigiScanner(vector3Pos, parameters)
    params = {}
    if vector3Pos and parameters then
        form = SetupScaleform("instructional_buttons", {
            { type = "CLEAR_ALL" },
            { type = "SET_CLEAR_SPACE", int = 200 },
            { type = "DRAW_INSTRUCTIONAL_BUTTONS" },
            { type = "SET_BACKGROUND_COLOUR" },
        })
        params = parameters
        targetCoords = vector3Pos

        if parameters.blip then
            scannerBlip = AddBlipForCoord(vector3Pos)
            SetBlipSprite(scannerBlip, parameters.blip.sprite)
            SetBlipDisplay(scannerBlip, parameters.blip.display)
            if parameters.blip.scale then SetBlipScale(scannerBlip, parameters.blip.scale) end
            SetBlipColour(scannerBlip, parameters.blip.color)
            if parameters.blip.opacity then SetBlipAlpha(scannerBlip, parameters.blip.opacity) end
            if parameters.blip.text then
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentSubstringPlayerName(parameters.blip.text)
                EndTextCommandSetBlipName(scannerBlip)
            end
        end
        InitiateDigiScanner()
    end
end

CreateThread(function()
    while true do
        Wait(2000)
        if pendingSpawnCoords and not pendingSpawnTriggered then
            local pos = GetEntityCoords(PlayerPedId())
            local dist = #(pos - pendingSpawnCoords)
            if dist <= 100.0 then
                pendingSpawnTriggered = true
                dbg('Player vào range 100m, request spawn xe')
                local result = lib.callback.await('orbit-chopshop:server:spawnReservedVehicle', false)
                dbg('Spawn result: netId=%s plate=%s', tostring(result and result.netId), tostring(result and result.plate))

                if not result or not result.netId then
                    dbg('Spawn FAILED')
                    QBX:Notify('Lỗi tạo xe, vui lòng thử lại', 'error')
                    TriggerServerEvent('orbit-chopshop:server:jobCancel')
                    TriggerEvent('orbit-chopshop:client:setJobState', false)
                    pendingSpawnCoords = nil
                    pendingSpawnTriggered = false
                    LicensePlate = nil
                    targetVehiclePlate = nil
                    targetVehicleModel = nil
                else
                    local entityCheck = 0
                    local entity = NetworkGetEntityFromNetworkId(result.netId)
                    while (not entity or entity == 0 or not DoesEntityExist(entity)) and entityCheck < 30 do
                        Wait(100)
                        entity = NetworkGetEntityFromNetworkId(result.netId)
                        entityCheck = entityCheck + 1
                    end
                    dbg('Entity visible: %s', tostring(entity and DoesEntityExist(entity)))
                    pendingSpawnCoords = nil
                end
            end
        end
    end
end)

RegisterNetEvent('orbit-chopshop:client:forceCancel', function()
    DeleteBlip()
    Reset()
    exports["orbit-ui"]:Close()
    pendingSpawnCoords = nil
    pendingSpawnTriggered = false
    LicensePlate = nil
    targetVehiclePlate = nil
    targetVehicleModel = nil
    dropoffx = nil
    dropoffy = nil
    dropoffz = nil
    dropoffm = nil
    scrapblip = false
    TriggerEvent('orbit-chopshop:client:setJobState', false)
end)

RegisterNetEvent('orbit-chopshop:client:cancelJob', function()
    TriggerServerEvent('orbit-chopshop:server:jobCancel')

    if vehicle and DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
    end

    DeleteBlip()
    exports["orbit-ui"]:Close()
    Reset()

    LicensePlate = nil
    targetVehiclePlate = nil
    targetVehicleModel = nil
    dropoffx = nil
    dropoffy = nil
    dropoffz = nil
    dropoffm = nil
    scrapblip = false

    TriggerEvent('orbit-chopshop:client:setJobState', false)
    QBX:Notify('Đã hủy chuyến', 'inform')
end)

exports('SetupDigiScanner', SetupDigiScanner)