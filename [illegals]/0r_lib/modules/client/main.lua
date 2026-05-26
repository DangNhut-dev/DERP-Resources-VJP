ResmonFramework = nil
Resmon.Lib.PlayerData = {}
Resmon.Lib.CurrentRequestId = 0
Resmon.Lib.ServerCallbacks = {}
Resmon.Lib.UI = {}
Resmon.Lib.Callback = {}
Resmon.Lib.PropertiesVehicle = {}
-- > Craft script
Resmon.Lib.Craft = {}
-- > Apartment script
Resmon.Lib.Apartment = {}
--<

if GetResourceState(Config.CoreName["ESX"]) ~= 'missing' then
    Config.Framework = 'ESX'
    ResmonFramework = exports[Config.CoreName["ESX"]].getSharedObject()
end

if GetResourceState(Config.CoreName["QBCore"]) ~= 'missing' then
    Config.Framework = 'QBCore'
    ResmonFramework = exports[Config.CoreName["QBCore"]].GetCoreObject()
end

Resmon.Lib.GetFramework = function()
    return Config.Framework
end

Resmon.Lib.PlayerLoadedEvent = Config.PlayerLoadedEvents[Config.Framework]

exports('GetFramework', function()
    return Config.Framework
end)

Resmon.Lib.GenerateHash = function(metin, char1)
    local silinmisMetin = string.gsub(metin, char1, "")

    local karisikMetin = ""
    for i = 1, string.len(silinmisMetin) do
        local karakter = string.sub(silinmisMetin, i, i)
        local rastgeleKarakter = string.char(math.random(32, 126))
        karisikMetin = karisikMetin .. rastgeleKarakter
    end

    return karisikMetin
end

Resmon.Lib.Callback.Client = function(name, cb, ...)
    Resmon.Lib.ServerCallbacks[Resmon.Lib.CurrentRequestId] = cb

    TriggerServerEvent('0R:Core:TriggerCallback', name, Resmon.Lib.CurrentRequestId, ...)

    if Resmon.Lib.CurrentRequestId < 65535 then
        Resmon.Lib.CurrentRequestId = Resmon.Lib.CurrentRequestId + 1
    else
        Resmon.Lib.CurrentRequestId = 0
    end
end

Resmon.Lib.IsPlayerLoaded = function()
    if Config.Framework == "QBCore" then
        return ResmonFramework.IsPlayerLoaded()
    else
        return LocalPlayer.state.isLoggedIn
    end
end

Resmon.Lib.GetPlayerData = function()
    local PlayerData = {}
    if Config.Framework == 'QBCore' then
        PlayerData = ResmonFramework.GetPlayerData()
        for key, value in pairs(PlayerData.accounts) do
            if value.name == "bank" then
                PlayerData.bank = value.money
            elseif value.name == "money" then
                PlayerData.cash = value.money
            end
        end
    else
        PlayerData = ResmonFramework.Functions.GetPlayerData()
        PlayerData.identifier = ResmonFramework.Functions.GetPlayerData().citizenid
        PlayerData.cash = PlayerData.money.cash
        PlayerData.bank = PlayerData.money.bank
    end
    return PlayerData
end

function Resmon.Lib.GetPlate(vehicle)
    if vehicle == 0 then return end
    return Resmon.Lib.Trim(GetVehicleNumberPlateText(vehicle))
end

Resmon.Lib.DumpTable = function(table, nb)
    if nb == nil then
        nb = 0
    end
    if type(table) == 'table' then
        local s = ''
        for i = 1, nb + 1, 1 do
            s = s .. "    "
        end
        s = '{\n'
        for k, v in pairs(table) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            for i = 1, nb, 1 do
                s = s .. "    "
            end
            s = s .. '[' .. k .. '] = ' .. Resmon.Lib.DumpTable(v, nb + 1) .. ',\n'
        end
        for i = 1, nb, 1 do
            s = s .. "    "
        end
        return s .. '}'
    else
        return tostring(table)
    end
end

RegisterNetEvent('0R:Lib:Notify', function(data)
    SendNUIMessage({
        type = 'showNotify',
        data = data,
    })
end)

Resmon.Lib.Notify = function(data)
    SendNUIMessage({
        type = 'showNotify',
        data = data,
    })
end

RegisterCommand('bas', function()
    Resmon.Lib.Notify({
        title = 'SUCCESSFULL',
        text = 'Başarıyla 31 çektiniz. Sonra da donuna boşaldın.',
        type = 'success'
    })
end)

Resmon.Lib.ShowTextUI = function(text, icon)
    if not Config.CustomTextUI then
        SendNUIMessage({
            type = 'showUI',
            icon = icon,
            string = text
        })
    else
        Config.CustomTextUIFunc(text)
    end
end

Resmon.Lib.ShowNotify = function(title, type, duration, icon, text)
    if not Config.CustomNotify then
        if Config.Framework == 'QBCore' then
            ResmonFramework.ShowNotification(title, type, duration)
        else
            ResmonFramework.Functions.Notify(title, type, duration)
        end
    end
end

Resmon.Lib.HideTextUI = function()
    if not Config.CustomTextUI then
        SendNUIMessage({
            type = 'hideUI',
        })
    else
        Config.CustomTextUIHide()
    end
end

Resmon.Lib.GetClosestPlayer = function(coords)
    local players         = Resmon.Lib.GetPlayers()
    local closestDistance = -1
    local closestPlayer   = -1
    local coords          = coords
    local usePlayerPed    = false
    local playerPed       = PlayerPedId()
    local playerId        = PlayerId()

    if coords == nil then
        usePlayerPed = true
        coords       = GetEntityCoords(playerPed)
    end

    for i = 1, #players, 1 do
        local target = GetPlayerPed(players[i])

        if not usePlayerPed or (usePlayerPed and players[i] ~= playerId) then
            local targetCoords = GetEntityCoords(target)
            local distance     = GetDistanceBetweenCoords(targetCoords, coords.x, coords.y, coords.z, true)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer   = players[i]
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance
end

Resmon.Lib.GetPlayers = function(onlyOtherPlayers, returnKeyValue, returnPeds)
    local players, myPlayer = {}, PlayerId()

    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)

        if DoesEntityExist(ped) and ((onlyOtherPlayers and player ~= myPlayer) or not onlyOtherPlayers) then
            if returnKeyValue then
                players[player] = ped
            else
                players[#players + 1] = returnPeds and ped or player
            end
        end
    end

    return players
end

Resmon.Lib.PropertiesVehicle.Get = function(vehicle)
    if DoesEntityExist(vehicle) then
        local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)

        local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
        if GetIsVehiclePrimaryColourCustom(vehicle) then
            local r, g, b = GetVehicleCustomPrimaryColour(vehicle)
            colorPrimary = { r, g, b }
        end

        if GetIsVehicleSecondaryColourCustom(vehicle) then
            local r, g, b = GetVehicleCustomSecondaryColour(vehicle)
            colorSecondary = { r, g, b }
        end

        local extras = {}
        for extraId = 0, 12 do
            if DoesExtraExist(vehicle, extraId) then
                local state = IsVehicleExtraTurnedOn(vehicle, extraId) == 1
                extras[tostring(extraId)] = state
            end
        end

        local modLivery = GetVehicleMod(vehicle, 48)
        if GetVehicleMod(vehicle, 48) == -1 and GetVehicleLivery(vehicle) ~= 0 then
            modLivery = GetVehicleLivery(vehicle)
        end

        local tireHealth = {}
        for i = 0, 3 do
            tireHealth[i] = GetVehicleWheelHealth(vehicle, i)
        end

        local tireBurstState = {}
        for i = 0, 5 do
            tireBurstState[i] = IsVehicleTyreBurst(vehicle, i, false)
        end

        local tireBurstCompletely = {}
        for i = 0, 5 do
            tireBurstCompletely[i] = IsVehicleTyreBurst(vehicle, i, true)
        end

        local windowStatus = {}
        for i = 0, 7 do
            windowStatus[i] = IsVehicleWindowIntact(vehicle, i) == 1
        end

        local doorStatus = {}
        for i = 0, 5 do
            doorStatus[i] = IsVehicleDoorDamaged(vehicle, i) == 1
        end

        return {
            model = GetEntityModel(vehicle),
            plate = Resmon.Lib.GetPlate(vehicle),
            plateIndex = GetVehicleNumberPlateTextIndex(vehicle),
            bodyHealth = Resmon.Lib.Round(GetVehicleBodyHealth(vehicle), 0.1),
            engineHealth = Resmon.Lib.Round(GetVehicleEngineHealth(vehicle), 0.1),
            tankHealth = Resmon.Lib.Round(GetVehiclePetrolTankHealth(vehicle), 0.1),
            fuelLevel = Resmon.Lib.Round(GetVehicleFuelLevel(vehicle), 0.1),
            dirtLevel = Resmon.Lib.Round(GetVehicleDirtLevel(vehicle), 0.1),
            oilLevel = Resmon.Lib.Round(GetVehicleOilLevel(vehicle), 0.1),
            color1 = colorPrimary,
            color2 = colorSecondary,
            pearlescentColor = pearlescentColor,
            dashboardColor = GetVehicleDashboardColour(vehicle),
            wheelColor = wheelColor,
            wheels = GetVehicleWheelType(vehicle),
            wheelSize = GetVehicleWheelSize(vehicle),
            wheelWidth = GetVehicleWheelWidth(vehicle),
            tireHealth = tireHealth,
            tireBurstState = tireBurstState,
            tireBurstCompletely = tireBurstCompletely,
            windowTint = GetVehicleWindowTint(vehicle),
            windowStatus = windowStatus,
            doorStatus = doorStatus,
            xenonColor = GetVehicleXenonLightsColour(vehicle),
            neonEnabled = {
                IsVehicleNeonLightEnabled(vehicle, 0),
                IsVehicleNeonLightEnabled(vehicle, 1),
                IsVehicleNeonLightEnabled(vehicle, 2),
                IsVehicleNeonLightEnabled(vehicle, 3)
            },
            neonColor = table.pack(GetVehicleNeonLightsColour(vehicle)),
            headlightColor = GetVehicleHeadlightsColour(vehicle),
            interiorColor = GetVehicleInteriorColour(vehicle),
            extras = extras,
            tyreSmokeColor = table.pack(GetVehicleTyreSmokeColor(vehicle)),
            modSpoilers = GetVehicleMod(vehicle, 0),
            modFrontBumper = GetVehicleMod(vehicle, 1),
            modRearBumper = GetVehicleMod(vehicle, 2),
            modSideSkirt = GetVehicleMod(vehicle, 3),
            modExhaust = GetVehicleMod(vehicle, 4),
            modFrame = GetVehicleMod(vehicle, 5),
            modGrille = GetVehicleMod(vehicle, 6),
            modHood = GetVehicleMod(vehicle, 7),
            modFender = GetVehicleMod(vehicle, 8),
            modRightFender = GetVehicleMod(vehicle, 9),
            modRoof = GetVehicleMod(vehicle, 10),
            modEngine = GetVehicleMod(vehicle, 11),
            modBrakes = GetVehicleMod(vehicle, 12),
            modTransmission = GetVehicleMod(vehicle, 13),
            modHorns = GetVehicleMod(vehicle, 14),
            modSuspension = GetVehicleMod(vehicle, 15),
            modArmor = GetVehicleMod(vehicle, 16),
            modKit17 = GetVehicleMod(vehicle, 17),
            modTurbo = IsToggleModOn(vehicle, 18),
            modKit19 = GetVehicleMod(vehicle, 19),
            modSmokeEnabled = IsToggleModOn(vehicle, 20),
            modKit21 = GetVehicleMod(vehicle, 21),
            modXenon = IsToggleModOn(vehicle, 22),
            modFrontWheels = GetVehicleMod(vehicle, 23),
            modBackWheels = GetVehicleMod(vehicle, 24),
            modCustomTiresF = GetVehicleModVariation(vehicle, 23),
            modCustomTiresR = GetVehicleModVariation(vehicle, 24),
            modPlateHolder = GetVehicleMod(vehicle, 25),
            modVanityPlate = GetVehicleMod(vehicle, 26),
            modTrimA = GetVehicleMod(vehicle, 27),
            modOrnaments = GetVehicleMod(vehicle, 28),
            modDashboard = GetVehicleMod(vehicle, 29),
            modDial = GetVehicleMod(vehicle, 30),
            modDoorSpeaker = GetVehicleMod(vehicle, 31),
            modSeats = GetVehicleMod(vehicle, 32),
            modSteeringWheel = GetVehicleMod(vehicle, 33),
            modShifterLeavers = GetVehicleMod(vehicle, 34),
            modAPlate = GetVehicleMod(vehicle, 35),
            modSpeakers = GetVehicleMod(vehicle, 36),
            modTrunk = GetVehicleMod(vehicle, 37),
            modHydrolic = GetVehicleMod(vehicle, 38),
            modEngineBlock = GetVehicleMod(vehicle, 39),
            modAirFilter = GetVehicleMod(vehicle, 40),
            modStruts = GetVehicleMod(vehicle, 41),
            modArchCover = GetVehicleMod(vehicle, 42),
            modAerials = GetVehicleMod(vehicle, 43),
            modTrimB = GetVehicleMod(vehicle, 44),
            modTank = GetVehicleMod(vehicle, 45),
            modWindows = GetVehicleMod(vehicle, 46),
            modKit47 = GetVehicleMod(vehicle, 47),
            modLivery = modLivery,
            modKit49 = GetVehicleMod(vehicle, 49),
            liveryRoof = GetVehicleRoofLivery(vehicle),
        }
    else
        return
    end
end

local ra = false

RegisterCommand('ra', function()
    ra = not ra
    if ra then
        SetNuiFocus(1, 1)
    else
        SetNuiFocus(0, 0)
    end
end)

Resmon.Lib.A11SFUNCTION = function(animDict, cb)
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)

        while not HasAnimDictLoaded(animDict) do
            Wait(0)
        end
    end

    if cb ~= nil then
        cb()
    end
end

Resmon.Lib.PropertiesVehicle.Set = function(vehicle, props)
    if DoesEntityExist(vehicle) then
        if props.extras then
            for id, enabled in pairs(props.extras) do
                if enabled then
                    SetVehicleExtra(vehicle, tonumber(id), 0)
                else
                    SetVehicleExtra(vehicle, tonumber(id), 1)
                end
            end
        end

        local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
        local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
        SetVehicleModKit(vehicle, 0)
        if props.plate then
            SetVehicleNumberPlateText(vehicle, props.plate)
        end
        if props.plateIndex then
            SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex)
        end
        if props.bodyHealth then
            SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0)
        end
        if props.engineHealth then
            SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0)
        end
        if props.tankHealth then
            SetVehiclePetrolTankHealth(vehicle, props.tankHealth)
        end
        if props.fuelLevel then
            SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0)
        end
        if props.dirtLevel then
            SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0)
        end
        if props.oilLevel then
            SetVehicleOilLevel(vehicle, props.oilLevel)
        end
        if props.color1 then
            if type(props.color1) == "number" then
                ClearVehicleCustomPrimaryColour(vehicle)
                SetVehicleColours(vehicle, props.color1, colorSecondary)
            else
                SetVehicleCustomPrimaryColour(vehicle, props.color1[1], props.color1[2], props.color1[3])
            end
        end
        if props.color2 then
            if type(props.color2) == "number" then
                ClearVehicleCustomSecondaryColour(vehicle)
                SetVehicleColours(vehicle, props.color1 or colorPrimary, props.color2)
            else
                SetVehicleCustomSecondaryColour(vehicle, props.color2[1], props.color2[2], props.color2[3])
            end
        end
        if props.pearlescentColor then
            SetVehicleExtraColours(vehicle, props.pearlescentColor, wheelColor)
        end
        if props.interiorColor then
            SetVehicleInteriorColor(vehicle, props.interiorColor)
        end
        if props.dashboardColor then
            SetVehicleDashboardColour(vehicle, props.dashboardColor)
        end
        if props.wheelColor then
            SetVehicleExtraColours(vehicle, props.pearlescentColor or pearlescentColor, props.wheelColor)
        end
        if props.wheels then
            SetVehicleWheelType(vehicle, props.wheels)
        end
        if props.tireHealth then
            for wheelIndex, health in pairs(props.tireHealth) do
                SetVehicleWheelHealth(vehicle, wheelIndex, health)
            end
        end
        if props.tireBurstState then
            for wheelIndex, burstState in pairs(props.tireBurstState) do
                if burstState then
                    SetVehicleTyreBurst(vehicle, tonumber(wheelIndex), false, 1000.0)
                end
            end
        end
        if props.tireBurstCompletely then
            for wheelIndex, burstState in pairs(props.tireBurstCompletely) do
                if burstState then
                    SetVehicleTyreBurst(vehicle, tonumber(wheelIndex), true, 1000.0)
                end
            end
        end
        if props.windowTint then
            SetVehicleWindowTint(vehicle, props.windowTint)
        end
        if props.windowStatus then
            for windowIndex, smashWindow in pairs(props.windowStatus) do
                if not smashWindow then SmashVehicleWindow(vehicle, windowIndex) end
            end
        end
        if props.doorStatus then
            for doorIndex, breakDoor in pairs(props.doorStatus) do
                if breakDoor then
                    SetVehicleDoorBroken(vehicle, tonumber(doorIndex), true)
                end
            end
        end
        if props.neonEnabled then
            SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
            SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
            SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
            SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
        end
        if props.neonColor then
            SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
        end
        if props.headlightColor then
            SetVehicleHeadlightsColour(vehicle, props.headlightColor)
        end
        if props.interiorColor then
            SetVehicleInteriorColour(vehicle, props.interiorColor)
        end
        if props.wheelSize then
            SetVehicleWheelSize(vehicle, props.wheelSize)
        end
        if props.wheelWidth then
            SetVehicleWheelWidth(vehicle, props.wheelWidth)
        end
        if props.tyreSmokeColor then
            SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
        end
        if props.modSpoilers then
            SetVehicleMod(vehicle, 0, props.modSpoilers, false)
        end
        if props.modFrontBumper then
            SetVehicleMod(vehicle, 1, props.modFrontBumper, false)
        end
        if props.modRearBumper then
            SetVehicleMod(vehicle, 2, props.modRearBumper, false)
        end
        if props.modSideSkirt then
            SetVehicleMod(vehicle, 3, props.modSideSkirt, false)
        end
        if props.modExhaust then
            SetVehicleMod(vehicle, 4, props.modExhaust, false)
        end
        if props.modFrame then
            SetVehicleMod(vehicle, 5, props.modFrame, false)
        end
        if props.modGrille then
            SetVehicleMod(vehicle, 6, props.modGrille, false)
        end
        if props.modHood then
            SetVehicleMod(vehicle, 7, props.modHood, false)
        end
        if props.modFender then
            SetVehicleMod(vehicle, 8, props.modFender, false)
        end
        if props.modRightFender then
            SetVehicleMod(vehicle, 9, props.modRightFender, false)
        end
        if props.modRoof then
            SetVehicleMod(vehicle, 10, props.modRoof, false)
        end
        if props.modEngine then
            SetVehicleMod(vehicle, 11, props.modEngine, false)
        end
        if props.modBrakes then
            SetVehicleMod(vehicle, 12, props.modBrakes, false)
        end
        if props.modTransmission then
            SetVehicleMod(vehicle, 13, props.modTransmission, false)
        end
        if props.modHorns then
            SetVehicleMod(vehicle, 14, props.modHorns, false)
        end
        if props.modSuspension then
            SetVehicleMod(vehicle, 15, props.modSuspension, false)
        end
        if props.modArmor then
            SetVehicleMod(vehicle, 16, props.modArmor, false)
        end
        if props.modKit17 then
            SetVehicleMod(vehicle, 17, props.modKit17, false)
        end
        if props.modTurbo then
            ToggleVehicleMod(vehicle, 18, props.modTurbo)
        end
        if props.modKit19 then
            SetVehicleMod(vehicle, 19, props.modKit19, false)
        end
        if props.modSmokeEnabled then
            ToggleVehicleMod(vehicle, 20, props.modSmokeEnabled)
        end
        if props.modKit21 then
            SetVehicleMod(vehicle, 21, props.modKit21, false)
        end
        if props.modXenon then
            ToggleVehicleMod(vehicle, 22, props.modXenon)
        end
        if props.xenonColor then
            SetVehicleXenonLightsColor(vehicle, props.xenonColor)
        end
        if props.modFrontWheels then
            SetVehicleMod(vehicle, 23, props.modFrontWheels, false)
        end
        if props.modBackWheels then
            SetVehicleMod(vehicle, 24, props.modBackWheels, false)
        end
        if props.modCustomTiresF then
            SetVehicleMod(vehicle, 23, props.modFrontWheels, props.modCustomTiresF)
        end
        if props.modCustomTiresR then
            SetVehicleMod(vehicle, 24, props.modBackWheels, props.modCustomTiresR)
        end
        if props.modPlateHolder then
            SetVehicleMod(vehicle, 25, props.modPlateHolder, false)
        end
        if props.modVanityPlate then
            SetVehicleMod(vehicle, 26, props.modVanityPlate, false)
        end
        if props.modTrimA then
            SetVehicleMod(vehicle, 27, props.modTrimA, false)
        end
        if props.modOrnaments then
            SetVehicleMod(vehicle, 28, props.modOrnaments, false)
        end
        if props.modDashboard then
            SetVehicleMod(vehicle, 29, props.modDashboard, false)
        end
        if props.modDial then
            SetVehicleMod(vehicle, 30, props.modDial, false)
        end
        if props.modDoorSpeaker then
            SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false)
        end
        if props.modSeats then
            SetVehicleMod(vehicle, 32, props.modSeats, false)
        end
        if props.modSteeringWheel then
            SetVehicleMod(vehicle, 33, props.modSteeringWheel, false)
        end
        if props.modShifterLeavers then
            SetVehicleMod(vehicle, 34, props.modShifterLeavers, false)
        end
        if props.modAPlate then
            SetVehicleMod(vehicle, 35, props.modAPlate, false)
        end
        if props.modSpeakers then
            SetVehicleMod(vehicle, 36, props.modSpeakers, false)
        end
        if props.modTrunk then
            SetVehicleMod(vehicle, 37, props.modTrunk, false)
        end
        if props.modHydrolic then
            SetVehicleMod(vehicle, 38, props.modHydrolic, false)
        end
        if props.modEngineBlock then
            SetVehicleMod(vehicle, 39, props.modEngineBlock, false)
        end
        if props.modAirFilter then
            SetVehicleMod(vehicle, 40, props.modAirFilter, false)
        end
        if props.modStruts then
            SetVehicleMod(vehicle, 41, props.modStruts, false)
        end
        if props.modArchCover then
            SetVehicleMod(vehicle, 42, props.modArchCover, false)
        end
        if props.modAerials then
            SetVehicleMod(vehicle, 43, props.modAerials, false)
        end
        if props.modTrimB then
            SetVehicleMod(vehicle, 44, props.modTrimB, false)
        end
        if props.modTank then
            SetVehicleMod(vehicle, 45, props.modTank, false)
        end
        if props.modWindows then
            SetVehicleMod(vehicle, 46, props.modWindows, false)
        end
        if props.modKit47 then
            SetVehicleMod(vehicle, 47, props.modKit47, false)
        end
        if props.modLivery then
            SetVehicleMod(vehicle, 48, props.modLivery, false)
            SetVehicleLivery(vehicle, props.modLivery)
        end
        if props.modKit49 then
            SetVehicleMod(vehicle, 49, props.modKit49, false)
        end
        if props.liveryRoof then
            SetVehicleRoofLivery(vehicle, props.liveryRoof)
        end
    end
end

function Resmon.Lib.Trim(value)
    if not value then return nil end
    return (string.gsub(value, '^%s*(.-)%s*$', '%1'))
end

function Resmon.Lib.FirstToUpper(value)
    if not value then return nil end
    return (value:gsub("^%l", string.upper))
end

function Resmon.Lib.Round(value, numDecimalPlaces)
    if not numDecimalPlaces then return math.floor(value + 0.5) end
    local power = 10 ^ numDecimalPlaces
    return math.floor((value * power) + 0.5) / (power)
end

---@param model number | string
function Resmon.Lib.LoadModel(model)
    if HasModelLoaded(model) then
        return
    end
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
end

---@param model number | string
function Resmon.Lib.LoadWeaponAsset(model)
    local modelHash = GetHashKey(model)
    if HasWeaponAssetLoaded(modelHash) then
        return
    end
    RequestWeaponAsset(modelHash, 31, 0)
    while not HasWeaponAssetLoaded(modelHash) do Wait(10) end
end

function Resmon.Lib.GetClosestObjectsOfType(model, coords, dist)
    local ped = PlayerPedId()
    local objects = GetGamePool('CObject')
    local closestObjects = {}
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(ped)
    end
    for i = 1, #objects, 1 do
        local objectCoords = GetEntityCoords(objects[i])
        local distance = #(objectCoords - coords)
        if distance <= dist and GetEntityModel(objects[i]) == GetHashKey(model) then
            table.insert(closestObjects, objects[i])
        end
    end
    return closestObjects
end

function Resmon.Lib.Craft.LoadPropOnTable(model, x, y, z, type)
    local createdObject = nil
    local _rot = vector3(0.0, 0.0, 30.0)
    if type == "weapon" then
        Resmon.Lib.LoadWeaponAsset(model)
        createdObject = CreateWeaponObject(
            model,
            0,
            x,
            y,
            z,
            true,
            1.3,
            0
        )
    else
        Resmon.Lib.LoadModel(model)
        createdObject = CreateObject(
            model,
            x,
            y,
            z,
            false,
            false,
            false
        )
    end
    SetModelAsNoLongerNeeded(model)
    return createdObject
end

function Resmon.Lib.Apartment._0xcfpLr()
    local xPlayer = Resmon.Lib.GetPlayerData()
    if not xPlayer.metadata then
        return nil, nil
    end
    local apartmentId = xPlayer.metadata.inApartment
    local roomId = xPlayer.metadata.inApartmentRoom
    return apartmentId, roomId
end

function Resmon.Lib.Apartment._0xcfpFED(coords, state)
    local objects = Resmon.Lib.GetClosestObjectsOfType("v_ilev_garageliftdoor", coords, 3.0)
    for _, value in pairs(objects) do
        FreezeEntityPosition(value, state)
    end
end
