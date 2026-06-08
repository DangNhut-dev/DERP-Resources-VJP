OnDuty = false
JobVehicleNetId = nil
local jobVehicle = nil
local playerData = nil
local heldBagObject = 0
local bagsCounter = 0
local menuInitialized = false
local myPartyMembers = {}
local workMenuOpen = true
local currentTutorialKey = ""
local scriptInitialized = false
local nuiLoaded = false
local nuiScriptReady = false
local bagsBlocked = {}
local markersActive = false
local currentBin = nil
local currentBag = nil
local interactionThreadRunning = false
local blipsCreated = false
local nearbyPlayers = {}
local workClothesActive = false
local canEndJob = true
local tutorialBagsToHighlight = 0
IsPerformingAction = false
local spawnedBags = {}
local _NetToObj = NetToObj
local _NetToVeh = NetToVeh
local _ObjToNet = ObjToNet

function NetToObj(netId)
    if NetworkDoesNetworkIdExist(netId) then
        return _NetToObj(netId)
    else
        return 0
    end
end

function NetToVeh(netId)
    if NetworkDoesNetworkIdExist(netId) then
        return _NetToVeh(netId)
    else
        return 0
    end
end

function ObjToNet(obj)
    if NetworkGetEntityIsNetworked(obj) then
        return _ObjToNet(obj)
    end
end

function GetClosestPlayers(coords, maxDistance, excludeSelf)
    local playerPed = PlayerPedId()
    local result = {}
    local activePlayers = GetActivePlayers()
    for i = 1, #activePlayers do
        local ped = GetPlayerPed(activePlayers[i])
        local distance = #(GetEntityCoords(ped) - coords)
        if maxDistance > distance and (excludeSelf and ped ~= playerPed or not excludeSelf) then
            result[#result + 1] = GetPlayerServerId(activePlayers[i])
        end
    end
    return result
end

CreateThread(function()
    while not nuiLoaded do
        Citizen.Wait(100)
    end

    if Config.UseModernUI then
        SendNUIMessage({ ui = "new" })
    else
        SendNUIMessage({ ui = "old" })
        nuiScriptReady = true
        Citizen.Wait(500)
    end

    while not nuiScriptReady do
        Citizen.Wait(100)
    end

    SendNUIMessage({
        action = "setProgressBarAlign",
        align = Config.ProgressBarAlign,
        offset = Config.ProgressBarOffset
    })

    if not Config.EnableCloakroom then
        SendNUIMessage({ action = "hideCloakroom" })
    end
end)

RegisterNetEvent("17mov_Garbage:UpdateHostPercentages", function(value)
    SendNUIMessage({
        action = "updateHostRewards",
        value = value
    })
end)

RegisterNetEvent("17mov_Garbage:SetMyReward", function(reward)
    SendNUIMessage({
        action = "updateMyReward",
        reward = reward
    })
end)

RegisterNetEvent("17mov_Garbage:clearMyLobby", function()
    myPartyMembers = {}
    Functions.TriggerServerCallback("17mov_Garbage:init", function(data)
        SendNUIMessage({
            action = "Init",
            name = data.name,
            myId = data.source
        })
        menuInitialized = true
    end)
end)

function StartMarkers(pData)
    if markersActive then
        return
    end

    if Config.RequiredJob ~= "none" then
        if pData.job.name ~= Config.RequiredJob then
            markersActive = false
            return
        end
    end

    markersActive = true

    if Config.UseTarget then
        SpawnStartingPed()

        local bagModels = {}
        local dumpsterModels = {}

        for bagModel, _ in pairs(Config.BagAttachments) do
            table.insert(bagModels, bagModel)
        end

        if Config.EnableBins then
            for sceneIdx = 1, #Config.Scenes do
                for _, modelName in pairs(Config.Scenes[sceneIdx].Models) do
                    table.insert(dumpsterModels, GetHashKey(modelName))
                end
            end
        end

        AddModelsToTarget(bagModels)

        if Config.EnableBins then
            AddDumpstersToTarget(dumpsterModels)
        end

        Config.Locations2 = {
            FinishJob = Config.Locations.FinishJob
        }

        while markersActive do
            Citizen.Wait(0)
            local playerCoords = GetEntityCoords(PlayerPedId())
            local insideMarker = false
            local justExited = false
            local shouldWait = true
            local foundStation = nil
            local foundPart = nil
            local foundPartNum = nil

            local requiredJobCheck
            if Config.RequiredJob ~= "none" and pData.job.name == Config.RequiredJob then
                requiredJobCheck = pData.job.name
            else
                requiredJobCheck = Config.RequiredJob
            end

            if requiredJobCheck == "none" or requiredJobCheck == pData.job.name or Config.RequiredJob == "none" then
                for stationName, station in pairs(Config.Locations2) do
                    if station.grade and not (pData.job.grade >= station.grade) then
                        goto continue_station
                    end
                    if not OnDuty and station.type ~= "duty" then
                        goto continue_station
                    end

                    for partNum, partCoords in pairs(station.Coords) do
                        local distance = #(playerCoords - partCoords)
                        local markerColor = nil

                        if distance < 20 then
                            if distance > station.scale.x then
                                markerColor = Config.MarkerSettings.UnActive
                            elseif distance < station.scale.x then
                                markerColor = Config.MarkerSettings.Active
                                insideMarker = true
                                foundStation = stationName
                                foundPart = stationName
                                foundPartNum = Iterator
                            end

                            if markerColor then
                                DrawMarker(6, partCoords.x, partCoords.y, partCoords.z - 1,
                                    0.0, 0.0, 0.0, -90.0, 0.0, 0.0,
                                    station.scale.x, station.scale.y, station.scale.z,
                                    Config.MarkerSettings.Active.r, Config.MarkerSettings.Active.g,
                                    Config.MarkerSettings.Active.b, Config.MarkerSettings.Active.a,
                                    false, false, 2, false, false, false, false)
                                shouldWait = false
                            end
                        end
                    end
                    ::continue_station::
                end

                if insideMarker and (not HasAlreadyEnteredMarker or LastStation ~= foundStation or LastPart ~= foundPart or LastPartNum ~= foundPartNum) then
                    if LastStation and LastPart and LastPartNum and (LastStation ~= foundStation or LastPart ~= foundPart or LastPartNum ~= foundPartNum) then
                        TriggerEvent("17mov_Garbage:ExitedMarker", LastStation, LastPart, LastPartNum)
                        justExited = true
                    end
                    HasAlreadyEnteredMarker = true
                    LastStation = foundStation
                    LastPart = foundPart
                    LastPartNum = foundPartNum
                    TriggerEvent("17mov_Garbage:EnteredMarker", foundPart)
                end

                if not justExited and not insideMarker and HasAlreadyEnteredMarker then
                    HasAlreadyEnteredMarker = false
                    TriggerEvent("17mov_Garbage:ExitedMarker", LastStation, LastPart, LastPartNum)
                end

                if shouldWait then
                    Citizen.Wait(500)
                end
            end
        end

        Functions.DeleteEntity(SpawnedPed)
    else
        while markersActive do
            Citizen.Wait(0)
            local playerCoords = GetEntityCoords(PlayerPedId())
            local insideMarker = false
            local justExited = false
            local shouldWait = true
            local foundStation = nil
            local foundPart = nil
            local foundPartNum = nil

            local requiredJobCheck
            if Config.RequiredJob ~= "none" and pData.job.name == Config.RequiredJob then
                requiredJobCheck = pData.job.name
            else
                requiredJobCheck = Config.RequiredJob
            end

            if requiredJobCheck == "none" or requiredJobCheck == pData.job.name or Config.RequiredJob == "none" then
                for stationName, station in pairs(Config.Locations) do
                    if station.grade and not (pData.job.grade >= station.grade) then
                        goto continue_station2
                    end
                    if not OnDuty and station.type ~= "duty" then
                        goto continue_station2
                    end

                    for partNum, partCoords in pairs(station.Coords) do
                        local distance = #(playerCoords - partCoords)
                        local markerColor = nil

                        if distance < 20 then
                            if distance > station.scale.x then
                                markerColor = Config.MarkerSettings.UnActive
                            elseif distance < station.scale.x then
                                markerColor = Config.MarkerSettings.Active
                                insideMarker = true
                                foundStation = stationName
                                foundPart = stationName
                                foundPartNum = Iterator
                            end

                            if markerColor then
                                DrawMarker(6, partCoords.x, partCoords.y, partCoords.z - 1,
                                    0.0, 0.0, 0.0, -90.0, 0.0, 0.0,
                                    station.scale.x, station.scale.y, station.scale.z,
                                    markerColor.r, markerColor.g, markerColor.b, markerColor.a,
                                    false, false, 2, false, false, false, false)
                                shouldWait = false
                            end
                        end
                    end
                    ::continue_station2::
                end

                if insideMarker and (not HasAlreadyEnteredMarker or LastStation ~= foundStation or LastPart ~= foundPart or LastPartNum ~= foundPartNum) then
                    if LastStation and LastPart and LastPartNum and (LastStation ~= foundStation or LastPart ~= foundPart or LastPartNum ~= foundPartNum) then
                        TriggerEvent("17mov_Garbage:ExitedMarker", LastStation, LastPart, LastPartNum)
                        justExited = true
                    end
                    HasAlreadyEnteredMarker = true
                    LastStation = foundStation
                    LastPart = foundPart
                    LastPartNum = foundPartNum
                    TriggerEvent("17mov_Garbage:EnteredMarker", foundPart)
                end

                if not justExited and not insideMarker and HasAlreadyEnteredMarker then
                    HasAlreadyEnteredMarker = false
                    TriggerEvent("17mov_Garbage:ExitedMarker", LastStation, LastPart, LastPartNum)
                end

                if shouldWait then
                    Citizen.Wait(500)
                end
            end
        end
    end
end

Citizen.CreateThread(function()
    playerData = GetPlayerData()
    while playerData == nil or playerData.job == nil do
        Citizen.Wait(100)
        playerData = GetPlayerData()
    end

    if not Config.RestrictBlipToRequiredJob or Config.RequiredJob == playerData.job.name then
        MakeBlip()
    end

    Citizen.Wait(5000)
    StartMarkers(playerData)
end)

function MakeBlip()
    if blipsCreated then
        return
    end

    for _, blipData in pairs(Config.Blips) do
        blipData.blip = AddBlipForCoord(blipData.Pos.x, blipData.Pos.y, blipData.Pos.z)
        SetBlipSprite(blipData.blip, blipData.Sprite)
        SetBlipDisplay(blipData.blip, 4)
        SetBlipScale(blipData.blip, blipData.Scale)
        SetBlipColour(blipData.blip, blipData.Color)
        SetBlipAsShortRange(blipData.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blipData.Label)
        EndTextCommandSetBlipName(blipData.blip)
    end

    blipsCreated = true
end

function DeleteBlip()
    blipsCreated = false
    for _, blipData in pairs(Config.Blips) do
        RemoveBlip(blipData.blip)
        blipData.blip = nil
    end
end

function InitalizeScript(skipWait)
    if scriptInitialized then
        return
    end

    if Config.UseModernUI then
        while not nuiScriptReady do
            Citizen.Wait(100)
        end
    else
        Citizen.Wait(5500)
    end

    playerData = GetPlayerData()
    if not skipWait then
        Citizen.Wait(5500)
    end

    scriptInitialized = true

    if Config.RequiredJob ~= "none" then
        if Config.RestrictBlipToRequiredJob then
            while playerData == nil or playerData.job == nil do
                playerData = GetPlayerData()
                Citizen.Wait(100)
            end

            local shouldMakeBlip
            if playerData.job.name ~= Config.RequiredJob then
                shouldMakeBlip = Config.RestrictBlipToRequiredJob
            end

            if not shouldMakeBlip then
                MakeBlip()
            end
        end
    else
        MakeBlip()
    end

    Functions.TriggerServerCallback("17mov_Garbage:init", function(data)
        SendNUIMessage({
            action = "Init",
            name = data.name,
            myId = data.source
        })
        menuInitialized = true
    end)
end

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    InitalizeScript()
end)

RegisterNetEvent("esx:playerLoaded", function()
    InitalizeScript()
end)

RegisterNetEvent("QBCore:Client:OnJobUpdate", function(newJob)
    playerData = GetPlayerData()

    local shouldDeleteBlip
    if Config.RequiredJob ~= "none" and Config.RestrictBlipToRequiredJob and playerData.job.name == Config.RequiredJob then
        shouldDeleteBlip = false
    else
        shouldDeleteBlip = Config.RestrictBlipToRequiredJob
    end

    if not shouldDeleteBlip then
        MakeBlip()
    else
        DeleteBlip()
    end

    local requiredJobCheck
    if Config.RequiredJob ~= "none" and playerData.job.name == Config.RequiredJob then
        requiredJobCheck = playerData.job.name
    else
        requiredJobCheck = Config.RequiredJob
    end

    if requiredJobCheck == "none" then
        StartMarkers(playerData)
    else
        markersActive = false
    end
end)

RegisterNetEvent("esx:setJob", function(newJob)
    while playerData == nil or playerData.job == nil do
        playerData = GetPlayerData()
        Citizen.Wait(1000)
    end
    playerData.job = newJob

    local shouldDeleteBlip
    if Config.RequiredJob ~= "none" and Config.RestrictBlipToRequiredJob and playerData.job.name == Config.RequiredJob then
        shouldDeleteBlip = false
    else
        shouldDeleteBlip = Config.RestrictBlipToRequiredJob
    end

    if not shouldDeleteBlip then
        MakeBlip()
    else
        DeleteBlip()
    end

    local requiredJobCheck
    if Config.RequiredJob ~= "none" and playerData.job.name == Config.RequiredJob then
        requiredJobCheck = playerData.job.name
    else
        requiredJobCheck = Config.RequiredJob
    end

    if requiredJobCheck == "none" then
        StartMarkers(playerData)
    else
        markersActive = false
    end
end)

RegisterNetEvent("17mov_Garbage:EnteredMarker", function(stationKey)
    CurrentAction = Config.Locations[stationKey].CurrentAction
    CurrentActionMsg = Config.Locations[stationKey].CurrentActionMsg
    CurrentActionStation = stationKey

    for i = 0, 499 do
        Citizen.Wait(0)
        ShowHelpNotification(CurrentActionMsg)
    end
end)

RegisterNetEvent("17mov_Garbage:ExitedMarker", function(stationKey)
    CurrentAction = nil
    CurrentActionMsg = nil
    CurrentActionStation = nil
end)

RegisterCommand("+GarbageCollectorUseMarker", function()
end, false)

RegisterCommand("-GarbageCollectorUseMarker", function()
    if CurrentAction ~= nil then
        if CurrentAction == "open_dutyToggle" then
            OpenDutyMenu()
        elseif CurrentAction == "finish_job" then
            Functions.TriggerServerCallback("17mov_Garbage:IfPlayerIsHost", function(isHost)
                if isHost then
                    EndJob()
                else
                    Notify(_L("Lobby.EndJob.NoPermission"))
                end
            end)
        end
    end
end, false)

local function MoveEntityToCoords(entity, targetCoords, duration, await, onDone)
    local prom = promise.new()
    Citizen.CreateThread(function()
        local startCoords = GetEntityCoords(entity)
        local elapsed = 0
        local startTime = GetNetworkTimeAccurate()
        while elapsed < duration do
            local lerped = Functions.CorrectLerp(startCoords, targetCoords, elapsed / duration)
            SetEntityCoordsNoOffset(entity, lerped.x, lerped.y, lerped.z, false, false, false)
            elapsed = GetNetworkTimeAccurate() - startTime
            Wait(11)
        end
        SetEntityCoordsNoOffset(entity, targetCoords.x, targetCoords.y, targetCoords.z, false, false, false)
        onDone()
        prom:resolve(true)
    end)

    if await then
        return Citizen.Await(prom)
    end
end

local function InverseMatrix(m)
    local rot = {}
    rot[1] = { m[1][1], m[1][2], m[1][3] }
    rot[2] = { m[2][1], m[2][2], m[2][3] }
    rot[3] = { m[3][1], m[3][2], m[3][3] }

    local translation = { m[1][4], m[2][4], m[3][4] }

    local transposed = {}
    transposed[1] = { rot[1][1], rot[2][1], rot[3][1] }
    transposed[2] = { rot[1][2], rot[2][2], rot[3][2] }
    transposed[3] = { rot[1][3], rot[2][3], rot[3][3] }

    local negTrans = {}
    negTrans[1] = -(transposed[1][1] * translation[1] + transposed[1][2] * translation[2] + transposed[1][3] * translation[3])
    negTrans[2] = -(transposed[2][1] * translation[1] + transposed[2][2] * translation[2] + transposed[2][3] * translation[3])
    negTrans[3] = -(transposed[3][1] * translation[1] + transposed[3][2] * translation[2] + transposed[3][3] * translation[3])

    local result = {}
    result[1] = { transposed[1][1], transposed[1][2], transposed[1][3], negTrans[1] }
    result[2] = { transposed[2][1], transposed[2][2], transposed[2][3], negTrans[2] }
    result[3] = { transposed[3][1], transposed[3][2], transposed[3][3], negTrans[3] }
    result[4] = { 0, 0, 0, 1 }
    return result
end

local function BuildMatrix(rotation, translation)
    local rx = math.rad(rotation.x)
    local ry = math.rad(rotation.y)
    local rz = math.rad(rotation.z)
    local cosX = math.cos(rx)
    local sinX = math.sin(rx)
    local cosY = math.cos(ry)
    local sinY = math.sin(ry)
    local cosZ = math.cos(rz)
    local sinZ = math.sin(rz)

    local m = {}
    m[1] = {
        cosY * cosZ,
        cosZ * sinX * sinY - cosX * sinZ,
        sinX * sinZ + cosX * cosZ * sinY,
        translation.x
    }
    m[2] = {
        cosY * sinZ,
        cosX * cosZ + sinX * sinY * sinZ,
        cosX * sinY * sinZ - cosZ * sinX,
        translation.y
    }
    m[3] = {
        -sinY,
        cosY * sinX,
        cosX * cosY,
        translation.z
    }
    m[4] = { 0, 0, 0, 1 }
    return m
end

local function MultiplyMatrixVec(m, v)
    local x = m[1][1] * v.x + m[1][2] * v.y + m[1][3] * v.z + m[1][4]
    local y = m[2][1] * v.x + m[2][2] * v.y + m[2][3] * v.z + m[2][4]
    local z = m[3][1] * v.x + m[3][2] * v.y + m[3][3] * v.z + m[3][4]
    return vec3(x, y, z)
end

local function MultiplyInverseMatrixVec(m, v)
    Inversed_Matrix = InverseMatrix(m)
    local x = Inversed_Matrix[1][1] * v.x + Inversed_Matrix[1][2] * v.y + Inversed_Matrix[1][3] * v.z + Inversed_Matrix[1][4]
    local y = Inversed_Matrix[2][1] * v.x + Inversed_Matrix[2][2] * v.y + Inversed_Matrix[2][3] * v.z + Inversed_Matrix[2][4]
    local z = Inversed_Matrix[3][1] * v.x + Inversed_Matrix[3][2] * v.y + Inversed_Matrix[3][3] * v.z + Inversed_Matrix[3][4]
    return vec3(x, y, z)
end

local function IsBoxInBox(matrix, outerBox, innerBox)
    local bl = MultiplyInverseMatrixVec(matrix, innerBox.bottom_left)
    local tr = MultiplyInverseMatrixVec(matrix, innerBox.top_right)

    local minX = math.min(bl.x, tr.x)
    local maxX = math.max(bl.x, tr.x)
    local minY = math.min(bl.y, tr.y)
    local maxY = math.max(bl.y, tr.y)

    return minX >= outerBox.bottom_left.x
        and maxX <= outerBox.top_right.x
        and minY >= outerBox.bottom_left.y
        and maxY <= outerBox.top_right.y
end

local unloadMarkerActive = false

RegisterNetEvent("17mov_GarbageCollector:client:hideBox", function()
    if unloadMarkerActive then
        unloadMarkerActive = false
    end
end)

RegisterNetEvent("17mov_GarbageCollector:client:forceEndJob", function()
    canEndJob = true
    return TriggerServerEvent("17mov_Garbage:endJob_sv", true, true)
end)

local disableReverseControl = false

RegisterNetEvent("17mov_Garbage:client:endStage", function(hostServerId)
    Citizen.CreateThread(function()
        local vehicle = NetToVeh(JobVehicleNetId)
        if not DoesEntityExist(vehicle) then
            return
        end

        local unloadCoords = Config.UnloadZone.coords
        local unloadRotation = Config.UnloadZone.rotation

        local foundGround, groundZ = GetGroundZFor_3dCoord(unloadCoords.x, unloadCoords.y, unloadCoords.z, false)
        if foundGround then
            unloadCoords = vec3(unloadCoords.x, unloadCoords.y, groundZ)
        end

        Functions.LoadModel(GetHashKey(Config.JobVehicleModel))
        local minDim, maxDim = GetModelDimensions(GetHashKey(Config.JobVehicleModel))
        local padding = vec3(0.5, 0.5, 0.2)
        local unloadMatrix = BuildMatrix(unloadRotation, unloadCoords)

        local topRight = vec3(maxDim.x + padding.x, maxDim.y + padding.y, maxDim.z - minDim.z + padding.z)
        local bottomLeft = vec3(minDim.x - padding.x, minDim.y - padding.y, minDim.z - padding.z)
        local markerSize = maxDim - minDim + 2 * padding

        local currentProgress = bagsCounter
        local progressPerBag = 100 / Config.BagsCountToFullUnload
        local mySvId = GetPlayerServerId(PlayerId())
        unloadMarkerActive = true

        while unloadMarkerActive do
            if vehicle ~= 0 then
                local vehTopRight = GetOffsetFromEntityInWorldCoords(vehicle, maxDim.x, maxDim.y, maxDim.z)
                local vehBottomLeft = GetOffsetFromEntityInWorldCoords(vehicle, minDim.x, minDim.y, minDim.z)

                local isInside = IsBoxInBox(unloadMatrix,
                    { bottom_left = bottomLeft, top_right = topRight },
                    { bottom_left = vehBottomLeft, top_right = vehTopRight })

                if isInside then
                    local vehHeading = GetEntityHeading(vehicle) % 360
                    local zoneHeading = unloadRotation.z % 360
                    local headingDiff = math.abs(vehHeading - zoneHeading)
                    if headingDiff > 180 then
                        headingDiff = 360 - headingDiff
                    end
                    local reversedDiff = math.abs(headingDiff - 180)
                    if headingDiff > 25 and reversedDiff > 25 then
                        isInside = false
                    end
                end

                local colorR = isInside and 0 or 255
                local colorG = isInside and 255 or 0

                DrawMarker(43, unloadCoords.x, unloadCoords.y, unloadCoords.z + 0.02,
                    0.0, 0.0, 0.0,
                    unloadRotation.x, unloadRotation.y, unloadRotation.z,
                    markerSize.x, markerSize.y, markerSize.z / 2.5,
                    colorR, colorG, 0, 50,
                    false, false, 2, false, false, false, false)

                if isInside then
                    local driver = GetPedInVehicleSeat(vehicle, -1)
                    if driver == PlayerPedId() and mySvId == hostServerId then
                        ShowHelpNotification(_L("Job.Markers.UnloadVehicle"))
                        if IsControlJustReleased(0, 38) then
                            unloadMarkerActive = false
                        end
                    end
                end
            end
            Wait(0)
        end

        if not unloadMarkerActive and mySvId == hostServerId then
            disableReverseControl = true
            Citizen.CreateThread(function()
                while disableReverseControl do
                    DisableControlAction(0, 75, true)
                    Wait(0)
                end
            end)

            FreezeEntityPosition(vehicle, true)
            TriggerServerEvent("17mov_GarbageCollector:server:hideBox")

            local bagsToSpawn = math.ceil(currentProgress / progressPerBag)
            local closestPlayers = GetClosestPlayers(GetEntityCoords(PlayerPedId()), 150, true)

            TriggerServerEvent("17mov_GarbageCollector:ToggleTrunk", JobVehicleNetId, true)
            TriggerServerEvent("17mov_GarbageCollector:server:startUnloadAnim", bagsToSpawn, closestPlayers)
        end
    end)
end)

RegisterNetEvent("17mov_GarbageCollector:client:startUnloadAnim", function(bagsCount, isLastBatch)
    local startMatrix = BuildMatrix(Config.Animation.rotation, Config.Animation.start_coords)
    local endPos = MultiplyMatrixVec(startMatrix, Config.Animation.end_coords_offset)

    for bagIdx = 1, bagsCount do
        Functions.SpawnObject(Config.Animation.model, function(spawnedBag)
            Entity(spawnedBag).state:set("GarbageBlock", true, false)

            if bagIdx == bagsCount and isLastBatch then
                TriggerServerEvent("17mov_GarbageCollector:ToggleTrunk", JobVehicleNetId, false)
            end

            SetEntityRotation(spawnedBag,
                Config.Animation.rotation.x,
                Config.Animation.rotation.y,
                Config.Animation.rotation.z, 2, false)

            MoveEntityToCoords(spawnedBag, endPos, Config.Animation.duration, false, function()
                if bagIdx == bagsCount then
                    disableReverseControl = false
                    Functions.DeleteEntity(spawnedBag)
                    canEndJob = true
                    if isLastBatch then
                        return TriggerServerEvent("17mov_Garbage:endJob_sv", true)
                    end
                    return
                end
            end)

            Wait(Config.Animation.duration / Config.Animation.max_bags_on_line)
        end, Config.Animation.start_coords, false, true, true)
    end
end)

TriggerEvent("chat:removeSuggestion", "/+GarbageCollectorUseMarker")
TriggerEvent("chat:removeSuggestion", "/-GarbageCollectorUseMarker")
RegisterKeyMapping("+GarbageCollectorUseMarker", _L("Command.MarkerInteraction.Description"), "keyboard", "E")

if Config.UseModernUI then
    function OpenDutyMenu()
        if not scriptInitialized then
            InitalizeScript(true)
            return print("SCRIPT NOT READY - WAIT UNTIL SCRIPT PROPERLY LOAD")
        end

        if not menuInitialized then
            Functions.TriggerServerCallback("17mov_Garbage:init", function(data)
                SendNUIMessage({
                    action = "Init",
                    name = data.name,
                    myId = data.source
                })
                menuInitialized = true
            end)
            return print("SCRIPT NOT READY - WAIT UNTIL SCRIPT PROPERLY LOAD")
        end

        SetNuiFocus(true, true)
        SendNUIMessage({ action = "OpenWorkMenu" })
        workMenuOpen = true

        local tabVisible = false
        local pendingHide = false
        local pendingShow = false

        CreateThread(function()
            while workMenuOpen do
                local activePlayers = GetActivePlayers()
                local myCoords = GetEntityCoords(PlayerPedId())
                local nearby = {}
                local foundNewPlayer = false

                for _, playerIdx in pairs(activePlayers) do
                    if PlayerId() ~= playerIdx then
                        local ped = GetPlayerPed(playerIdx)
                        local distance = #(myCoords - GetEntityCoords(ped))
                        if distance < 10.0 then
                            nearby[#nearby + 1] = GetPlayerServerId(playerIdx)
                        end
                    end
                end

                if #nearby == 0 and not pendingShow then
                    goto continue
                end

                Functions.TriggerServerCallback("17mov_Garbage:GetPlayersNames", function(result)
                    for idx, playerInfo in pairs(result) do
                        if nearbyPlayers[playerInfo.id] == nil then
                            foundNewPlayer = true
                            if nearbyPlayers[playerInfo.id] == nil then
                                nearbyPlayers[playerInfo.id] = { id = playerInfo.id, name = playerInfo.name }
                                CreateThread(function()
                                    while not tabVisible do
                                        Citizen.Wait(10)
                                    end
                                    SendNUIMessage({
                                        action = "addNewNearbyPlayer",
                                        id = playerInfo.id,
                                        name = playerInfo.name
                                    })
                                end)
                            end
                        else
                            result[idx] = nil
                        end
                    end

                    pendingShow = false
                    for _, existingPlayer in pairs(nearbyPlayers) do
                        pendingShow = true
                        local stillNearby = false
                        for _, incomingPlayer in pairs(result) do
                            if incomingPlayer.id == existingPlayer.id then
                                stillNearby = true
                                break
                            end
                        end
                        if not stillNearby then
                            nearbyPlayers[existingPlayer.id] = nil
                            pendingHide = true
                            SendNUIMessage({
                                action = "DeleteNearbyPlayer",
                                id = existingPlayer.id
                            })
                            CreateThread(function()
                                Citizen.Wait(250)
                                pendingHide = false
                            end)
                        end
                    end

                    if not foundNewPlayer and tabVisible then
                        CreateThread(function()
                            while pendingHide do
                                Citizen.Wait(10)
                            end
                            SendNUIMessage({ action = "hideNearbyPlayersTab" })
                            CreateThread(function()
                                Citizen.Wait(250)
                                tabVisible = false
                            end)
                        end)
                    elseif foundNewPlayer and not tabVisible then
                        SendNUIMessage({ action = "showNearbyPlayersTab" })
                        CreateThread(function()
                            Citizen.Wait(250)
                            tabVisible = true
                        end)
                    end
                end, nearby)

                ::continue::
                Citizen.Wait(2500)
            end
        end)
    end
else
    function OpenDutyMenu()
        if not scriptInitialized then
            InitalizeScript(true)
            return print("SCRIPT NOT READY - WAIT UNTIL SCRIPT PROPERLY LOAD")
        end

        if not menuInitialized then
            Functions.TriggerServerCallback("17mov_Garbage:init", function(data)
                SendNUIMessage({
                    action = "Init",
                    name = data.name,
                    myId = data.source
                })
                menuInitialized = true
            end)
            return print("SCRIPT NOT READY - WAIT UNTIL SCRIPT PROPERLY LOAD")
        end

        Functions.TriggerServerCallback("17mov_Garbage:IfPlayerIsHost", function(isHost)
            SendNUIMessage({ action = "HostStatusUpdate", status = isHost })
            SendNUIMessage({ action = "OpenWorkMenu" })
            SetNuiFocus(true, true)
        end)
    end
end

RegisterNetEvent("17mov_Garbage:SendRequestToClient_cl", function(hostName, _unused)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "ShowInviteBox",
        name = hostName
    })
end)

if Config.UseModernUI then
    RegisterNetEvent("17mov_Garbage:RefreshMugs", function(partyList, _unused)
        while not menuInitialized do
            Citizen.Wait(100)
        end

        for _, member in pairs(partyList) do
            SendNUIMessage({
                action = "DeleteNearbyPlayer",
                id = member.id
            })

            if myPartyMembers[member.id] == nil then
                local mySvId = GetPlayerServerId(PlayerId())
                if mySvId == member.id then
                    myPartyMembers[member.id] = {
                        name = member.name,
                        id = member.id,
                        isHost = member.isHost,
                        rewardPercent = member.rewardPercent,
                        itsMe = true
                    }
                else
                    myPartyMembers[member.id] = {
                        name = member.name,
                        id = member.id,
                        isHost = member.isHost,
                        rewardPercent = member.rewardPercent,
                        itsMe = false
                    }
                end

                SendNUIMessage({
                    action = "addNewMember",
                    name = member.name,
                    id = member.id,
                    isHost = member.isHost,
                    rewardPercent = member.rewardPercent,
                    showQuitBtn = myPartyMembers[member.id].itsMe
                })
            end
        end

        local memberCount = 0
        for _, storedMember in pairs(myPartyMembers) do
            local stillInParty = false
            for _, incomingMember in pairs(partyList) do
                if incomingMember.id == storedMember.id then
                    stillInParty = true
                    break
                end
            end
            if not stillInParty then
                myPartyMembers[storedMember.id] = nil
                SendNUIMessage({
                    action = "DeletePlayer",
                    id = storedMember.id
                })
            else
                memberCount = memberCount + 1
            end
        end

        if memberCount == 1 then
            Functions.TriggerServerCallback("17mov_Garbage:init", function(data)
                SendNUIMessage({
                    action = "Init",
                    name = data.name,
                    myId = data.source
                })
                menuInitialized = true
            end)
        end

        Functions.TriggerServerCallback("17mov_Garbage:IfPlayerOwnsTeam", function(owns)
            SendNUIMessage({
                action = "ToggleHostHUD",
                boolean = owns
            })
        end)
    end)
else
    RegisterNetEvent("17mov_Garbage:RefreshMugs", function(names, myId)
        while not menuInitialized do
            Citizen.Wait(100)
        end
        Citizen.Wait(100)
        SendNUIMessage({
            action = "refreshMugs",
            names = names,
            myId = myId
        })

        Functions.TriggerServerCallback("17mov_Garbage:IfPlayerIsHost", function(isHost)
            SendNUIMessage({
                action = "HostStatusUpdate",
                status = isHost
            })
        end)
    end)
end

local animNetTimeout = 3000

RegisterNetEvent("17mov_GarbageCollector:client:GarbageAnim", function(bagNetId, startTime, sceneIdx, ownerSrc, extraObjects, stageIdx)
    Citizen.CreateThread(function()
        local startTimer = GetGameTimer()
        local mySvId = GetPlayerServerId(PlayerId())

        while not NetworkDoesEntityExistWithNetworkId(bagNetId) do
            if GetGameTimer() - startTimer > animNetTimeout then
                return
            end
            Wait(1)
        end

        local bagEntity = NetToObj(bagNetId)

        local currentStage = stageIdx
        if Config.Debug.enabled and Config.Debug.bin_stage then
            currentStage = Config.Debug.bin_stage
        end

        local scene = Config.Scenes[sceneIdx]
        local bagAnim = {
            dict = scene.Stages[currentStage].Objects[2].animDict,
            clip = scene.Stages[currentStage].Objects[2].animClip
        }
        local pedAnim = {
            dict = scene.Stages[currentStage].Objects[1].animDict,
            clip = scene.Stages[currentStage].Objects[1].animClip
        }

        local ownerPed = GetPlayerPed(GetPlayerFromServerId(ownerSrc))
        local spawnedExtra = {}

        if mySvId ~= ownerSrc then
            for extraIdx = 1, #extraObjects do
                Functions.SpawnObject(extraObjects[extraIdx].model, function(spawnedObj)
                    SetEntityRotation(spawnedObj,
                        extraObjects[extraIdx].rotation.x,
                        extraObjects[extraIdx].rotation.y,
                        extraObjects[extraIdx].rotation.z, 2, false)
                    spawnedExtra[#spawnedExtra + 1] = spawnedObj
                    Entity(spawnedObj).state:set("GarbageBlock", true, false)
                end, extraObjects[extraIdx].coords, false, extraObjects[extraIdx].isFrozen, extraObjects[extraIdx].NoCollisions)
            end
        end

        local animStopped = false

        if bagEntity and NetworkGetEntityOwner(bagEntity) == PlayerId() then
            FreezeEntityPosition(bagEntity, true)
            SetEntityNoCollisionEntity(ownerPed, bagEntity, false)
            Functions.RequestAnimDict(bagAnim.dict)
            PlayEntityAnim(bagEntity, bagAnim.clip, bagAnim.dict, 2.0, false, false, false, 0, 0)

            while not IsEntityPlayingAnim(bagEntity, bagAnim.dict, bagAnim.clip, 3) do
                Wait(1)
            end
            while not IsEntityPlayingAnim(ownerPed, pedAnim.dict, pedAnim.clip, 3) do
                Wait(1)
            end

            local timeDiff = GetNetworkTimeAccurate() - startTime
            local pedProgress = timeDiff / (GetAnimDuration(pedAnim.dict, pedAnim.clip) * 1000)
            SetEntityAnimCurrentTime(ownerPed, pedAnim.dict, pedAnim.clip, pedProgress)
            local bagProgress = timeDiff / (GetAnimDuration(bagAnim.dict, bagAnim.clip) * 1000)
            SetEntityAnimCurrentTime(bagEntity, bagAnim.dict, bagAnim.clip, bagProgress)

            while IsEntityPlayingAnim(bagEntity, bagAnim.dict, bagAnim.clip, 3) do
                if not IsEntityPlayingAnim(ownerPed, pedAnim.dict, pedAnim.clip, 3) then
                    StopEntityAnim(bagEntity, bagAnim.clip, bagAnim.dict, 1)
                    animStopped = true
                end
                Wait(1)
            end

            TriggerServerEvent("17mov_GarbageCollector:server:GarbageSetOcupied", bagNetId, #scene.Stages, nil, animStopped)
            SetEntityNoCollisionEntity(ownerPed, bagEntity, true)
            FreezeEntityPosition(bagEntity, false)
        elseif bagEntity then
            Functions.RequestAnimDict(bagAnim.dict)

            while not IsEntityPlayingAnim(bagEntity, bagAnim.dict, bagAnim.clip, 3) do
                Wait(1)
            end
            while not IsEntityPlayingAnim(ownerPed, pedAnim.dict, pedAnim.clip, 3) do
                Wait(1)
            end

            local timeDiff = GetNetworkTimeAccurate() - startTime
            local pedProgress = timeDiff / (GetAnimDuration(pedAnim.dict, pedAnim.clip) * 1000)
            SetEntityAnimCurrentTime(ownerPed, pedAnim.dict, pedAnim.clip, pedProgress)
            local bagProgress = timeDiff / (GetAnimDuration(bagAnim.dict, bagAnim.clip) * 1000)
            SetEntityAnimCurrentTime(bagEntity, bagAnim.dict, bagAnim.clip, bagProgress)

            while IsEntityPlayingAnim(bagEntity, bagAnim.dict, bagAnim.clip, 3) do
                Wait(1)
            end
        end

        if #spawnedExtra > 0 then
            for i = 1, #spawnedExtra do
                Functions.DeleteEntity(spawnedExtra[i])
            end
        end
    end)
end)

local function StartBinInteractionThread()
    if interactionThreadRunning then
        return
    end
    interactionThreadRunning = true

    local resourceName = GetCurrentResourceName()
    CreateThread(function()
        while interactionThreadRunning do
            local waitTime = 1000
            if currentBin then
                waitTime = 0
                local sceneData = currentBin.scene
                local binObject = currentBin.object
                local sceneId = currentBin.sceneId
                local drawCoords = GetOffsetFromEntityInWorldCoords(binObject,
                    sceneData.DrawTextOffset.x,
                    sceneData.DrawTextOffset.y,
                    sceneData.DrawTextOffset.z)

                if Entity(binObject).state.GarbageOccupied or IsHoldingTrash() then
                    goto continue
                end

                local debugPrefix = (Config.Debug.enabled and "DEBUG: ") or ""
                DrawText3Ds(drawCoords.x, drawCoords.y, drawCoords.z,
                    debugPrefix .. Config.KeybindSettings.bagsInteractionkeyString .. _L("Job.Gameplay.SearchDumpster"),
                    binObject)

                if IsControlJustReleased(0, 38) then
                    StartScene(sceneData, sceneId, binObject)
                end
            else
                if currentBag then
                    waitTime = 0
                    local bagCoords = GetEntityCoords(currentBag)
                    local bagScript = GetEntityScript(currentBag)

                    if not Entity(currentBag).state.GarbageBlock and (bagScript == nil or bagScript == resourceName) then
                        if not IsHoldingTrash() and not HasObjectBeenBroken(currentBag) then
                            DrawText3Ds(bagCoords.x, bagCoords.y, bagCoords.z,
                                Config.KeybindSettings.bagsInteractionkeyString .. _L("Job.Gameplay.Pick"),
                                currentBag)
                            if IsControlJustReleased(0, Config.KeybindSettings.bagsInteractionKey) then
                                PickTrash(currentBag)
                            end
                        end
                    end
                else
                    interactionThreadRunning = false
                    return
                end
            end
            ::continue::
            Citizen.Wait(waitTime)
        end
    end)
end

RegisterNetEvent("17mov_GarbageCollector:client:TeleportCrewMembers", function(vehNetId, seatStart, netStartTime)
    while not NetworkDoesEntityExistWithNetworkId(vehNetId) do
        Wait(10)
    end

    local timeout = 5000
    local startTimer = GetGameTimer()
    local vehicle = nil
    while not vehicle or vehicle == vehNetId do
        if timeout < GetGameTimer() - startTimer then
            return Notify("Teleporting crew members failed, vehicle not found")
        end
        vehicle = NetToVeh(vehNetId)
        Wait(10)
    end

    DoScreenFadeOut(300)
    while not IsScreenFadedOut() do
        Citizen.Wait(1)
    end

    local seatFound = false
    for seatIdx = 0 + seatStart, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
        if IsVehicleSeatFree(vehicle, seatIdx) then
            local playerPed = PlayerPedId()
            seatFound = true
            TaskEnterVehicle(playerPed, vehicle, -1, seatIdx, 2.0, 16, 0)
            Wait(100)
            break
        end
    end

    local elapsed = GetNetworkTimeAccurate() - netStartTime
    Wait(2000 - elapsed)
    DoScreenFadeIn(300)

    if not seatFound then
        Notify("No free seat found in vehicle")
    end
end)

local function IsExploitFixClear()
    if not Config.EnableExploitFix then
        return true
    end

    local playerPed = PlayerPedId()
    local myId = PlayerId()
    local activePlayers = GetActivePlayers()

    for _, otherId in ipairs(activePlayers) do
        if otherId ~= myId then
            local otherPed = GetPlayerPed(otherId)
            local distance = #(GetEntityCoords(playerPed) - GetEntityCoords(otherPed))
            if distance < Config.ExploitFixDistance then
                return false
            end
        end
    end
    return true
end

RegisterNetEvent("17mov_Garbage:StartJob_cl", function(hostSrc, mySrc, _unused, isJoin, vehNetId)
    local spawnPoint = Config.SpawnPoint
    bagsCounter = 0
    OnDuty = true
    tutorialBagsToHighlight = 0

    if GetResourceKvpInt("17mov_Tutorials:" .. "garbageTutorial") == 0 then
        tutorialBagsToHighlight = 5
        currentTutorialKey = "garbageTutorial"
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "showTutorial",
            customText = _L("Job.Gameplay.Tutorial")
        })
    end

    CreateThread(function()
        if not workClothesActive and Config.RequireWorkClothes then
            workClothesActive = true
            ChangeClothes("work")
        end
    end)

    if hostSrc == mySrc then
        if not isJoin then
            if Config.EnableVehicleTeleporting then
                DoScreenFadeOut(300)
                while not IsScreenFadedOut() do
                    Wait(1)
                end
            end

            PrepeareVehicle()
            local vehicle = Functions.SpawnVehicle(Config.JobVehicleModel, spawnPoint, Config.EnableVehicleTeleporting)
            SetVehicle(vehicle)

            local timer = GetGameTimer()
            while not DoesEntityExist(vehicle) and GetGameTimer() - timer < 2000 do
                Wait(1)
            end

            timer = GetGameTimer()
            while not VehToNet(vehicle) and GetGameTimer() - timer < 2000 do
                Wait(1)
            end

            jobVehicle = vehicle
            JobVehicleNetId = VehToNet(vehicle)

            local netStartTime = GetNetworkTimeAccurate()
            if Config.EnableVehicleCrewMembersTeleporting then
                TriggerServerEvent("17mov_GarbageCollector:server:TeleportCrewMembers", JobVehicleNetId, netStartTime)
            end

            Citizen.Wait(2000)
            DoScreenFadeIn(300)
        else
            jobVehicle = NetToVeh(vehNetId)
            JobVehicleNetId = vehNetId

            local attempts = 0
            while jobVehicle == 0 do
                jobVehicle = NetToVeh(vehNetId)
                Citizen.Wait(100)
                attempts = attempts + 1
                if attempts > 300 then
                    break
                end
            end

            while not DoesEntityExist(jobVehicle) and attempts < 300 do
                Citizen.Wait(100)
            end

            if Config.UseTarget then
                AddJobVehicleToTargetSystem(jobVehicle)
            end
        end

        if Config.UseTarget then
            AddJobVehicleToTargetSystem(jobVehicle)
        end

        TriggerServerEvent("17mov_GarbageJob:SendVehicleNetId", JobVehicleNetId)
    elseif not isJoin then
        while true do
            Citizen.Wait(0)
            local nearbyVehicle = GetClosestVehicle(vector3(spawnPoint.x, spawnPoint.y, spawnPoint.z))
            if nearbyVehicle ~= nil then
                local distance = #(vector3(spawnPoint.x, spawnPoint.y, spawnPoint.z) - GetEntityCoords(nearbyVehicle))
                if distance < 5.0 then
                    Citizen.Wait(300)
                    if Config.UseTarget then
                        AddJobVehicleToTargetSystem(nearbyVehicle)
                    end
                    JobVehicleNetId = VehToNet(nearbyVehicle)
                    jobVehicle = nearbyVehicle
                    break
                end
            end
        end

        if Config.GiveKeysToAllLobby then
            SetVehicle(jobVehicle)
        end
    else
        jobVehicle = NetToVeh(vehNetId)
        JobVehicleNetId = vehNetId

        local attempts = 0
        while jobVehicle == 0 do
            jobVehicle = NetToVeh(vehNetId)
            Citizen.Wait(100)
            attempts = attempts + 1
            if attempts > 400 then
                break
            end
        end

        while not DoesEntityExist(jobVehicle) and attempts < 400 do
            Citizen.Wait(100)
        end

        if Config.UseTarget then
            AddJobVehicleToTargetSystem(jobVehicle)
        end
    end

    SendNUIMessage({ action = "showCounter" })

    CreateThread(function()
        while OnDuty do
            if JobVehicleNetId ~= 0 and JobVehicleNetId ~= nil and NetworkDoesNetworkIdExist(JobVehicleNetId) then
                local netVehicle = NetToVeh(JobVehicleNetId)
                if jobVehicle ~= netVehicle and netVehicle ~= JobVehicleNetId then
                    if Config.UseTarget then
                        DeleteEntityFromTarget(jobVehicle)
                    end
                    jobVehicle = NetToVeh(JobVehicleNetId)
                    if Config.UseTarget then
                        AddJobVehicleToTargetSystem(jobVehicle)
                    end
                end
            end
            Citizen.Wait(5000)
        end
    end)

    CreateThread(function()
        while OnDuty do
            if Config.UseTarget then
                break
            end

            local playerPed = PlayerPedId()
            local myCoords = GetEntityCoords(playerPed)
            local objectPool = GetGamePool("CObject")
            local foundBin = nil
            local foundBag = nil
            local closestDist = 1.5

            for _, obj in pairs(objectPool) do
                local objModel = GetEntityModel(obj)

                if Config.EnableBins then
                    for sceneIdx, scene in pairs(Config.Scenes) do
                        local isSceneModel = false
                        for _, modelName in pairs(scene.Models) do
                            if objModel == GetHashKey(modelName) then
                                isSceneModel = true
                            end
                        end

                        if isSceneModel then
                            local objCoords = GetEntityCoords(obj)
                            local distance = #(myCoords - objCoords)
                            if distance <= scene.Distance then
                                foundBin = {
                                    scene = scene,
                                    object = obj,
                                    sceneId = sceneIdx
                                }
                            end
                        end
                    end
                end

                if not foundBin then
                    local objCoords = GetEntityCoords(obj)
                    local distance = #(myCoords - objCoords)
                    local objModelHash = GetEntityModel(obj)
                    if Config.BagAttachments[objModelHash] and closestDist > distance then
                        if not IsEntityAttachedToAnyPed(obj) then
                            foundBag = obj
                            closestDist = distance
                        end
                    end
                end
            end

            local newBinObject = foundBin and foundBin.object
            local currentBinObject = currentBin and currentBin.object

            if newBinObject == currentBinObject and foundBag == currentBag then
                goto continue
            end

            if Config.EnableBins then
                currentBin = foundBin
            end

            currentBag = foundBag

            if not currentBin and not currentBag then
                goto continue
            end

            StartBinInteractionThread()
            ::continue::
            Citizen.Wait(300)
        end
    end)

    Citizen.CreateThread(function()
        if tutorialBagsToHighlight <= 0 or not Config.HighlightOnTutorial then
            return
        end

        local validModels = {}
        for bagHash, _ in pairs(Config.BagAttachments) do
            validModels[tostring(bagHash)] = true
        end

        if Config.EnableBins then
            for sceneIdx = 1, #Config.Scenes do
                for _, modelName in pairs(Config.Scenes[sceneIdx].Models) do
                    validModels[tostring(GetHashKey(modelName))] = true
                end
            end
        end

        local maxHighlight = tutorialBagsToHighlight
        local maxDistance = 10.0
        local tickRate = 500
        local previousHighlighted = {}

        while OnDuty do
            Citizen.Wait(tickRate)
            local playerPed = PlayerPedId()
            local myCoords = GetEntityCoords(playerPed)
            local candidates = {}

            for obj in EnumerateObjects() do
                local objModel = GetEntityModel(obj)
                if DoesEntityExist(obj) and validModels[tostring(objModel)] and not spawnedBags[tostring(objModel)] then
                    local distance = #(myCoords - GetEntityCoords(obj))
                    if maxDistance >= distance and not Entity(obj).state.GarbageBlock and not IsEntityAttachedToAnyPed(obj) then
                        candidates[#candidates + 1] = { object = obj, distance = distance }
                    end
                end
            end

            table.sort(candidates, function(a, b) return a.distance < b.distance end)

            local currentHighlighted = {}
            for i = 1, math.min(maxHighlight, #candidates) do
                SetEntityDrawOutline(candidates[i].object, true)
                SetEntityDrawOutlineColor(89, 198, 100, 130)
                currentHighlighted[tostring(candidates[i].object)] = true
            end

            for key, _ in pairs(previousHighlighted) do
                if not currentHighlighted[key] then
                    local objId = tonumber(key)
                    if objId then
                        SetEntityDrawOutline(objId, false)
                    end
                end
            end

            previousHighlighted = currentHighlighted
        end

        spawnedBags = {}
    end)
end)

RegisterNetEvent("17mov_GarbageCollector:client:fixRotation", function(binNetId)
    if not NetworkDoesEntityExistWithNetworkId(binNetId) then
        return
    end

    local binObj = NetToObj(binNetId)
    local validPos = json.decode(Entity(binObj).state.validPos)

    SetEntityCoordsNoOffset(binObj, validPos.coords.x, validPos.coords.y, validPos.coords.z, true, true, true)
    SetEntityRotation(binObj, validPos.rotation.x, validPos.rotation.y, validPos.rotation.z, 0, false)
end)

Citizen.CreateThread(function()
    if not Config.FixBinsPosition then
        return
    end

    local validModels = {}
    for bagHash, _ in pairs(Config.BagAttachments) do
        validModels[tostring(bagHash)] = true
    end

    for sceneIdx = 1, #Config.Scenes do
        for _, modelName in pairs(Config.Scenes[sceneIdx].Models) do
            validModels[tostring(GetHashKey(modelName))] = true
        end
    end

    local checkInterval = 5000
    local trackedObjects = {}

    local function CheckObject(obj, model)
        Citizen.CreateThread(function()
            if not Entity(obj).state.validPos then
                return
            end

            local timeout = 5000
            local startTimer = GetGameTimer()
            while NetworkGetEntityOwner(obj) == -1 do
                if GetGameTimer() - startTimer > timeout then
                    return
                end
                Citizen.Wait(50)
            end

            local ownerSvId = GetPlayerServerId(NetworkGetEntityOwner(obj))
            local mySvId = GetPlayerServerId(PlayerId())
            if ownerSvId == mySvId and DoesEntityExist(obj) then
                TriggerServerEvent("17mov_GarbageCollector:server:fixRotation", ObjToNet(obj))
            end
        end)
    end

    while true do
        local currentObjects = {}
        for obj in EnumerateObjects() do
            local model = GetEntityModel(obj)
            if DoesEntityExist(obj) and validModels[tostring(model)] then
                currentObjects[tostring(obj)] = model
                if not trackedObjects[tostring(obj)] then
                    CheckObject(obj, model)
                end
            end
        end
        trackedObjects = currentObjects
        Citizen.Wait(checkInterval)
    end
end)

function EnumerateObjects()
    return coroutine.wrap(function()
        local iter, obj = FindFirstObject()
        if iter == -1 then
            return
        end
        local success
        repeat
            coroutine.yield(obj)
            success, obj = FindNextObject(iter)
        until not success
        EndFindObject(iter)
    end)
end

RegisterNetEvent("multiplayerGarbage:searchDumpster", function(data)
    local objectModel = GetEntityModel(data.entity)

    if Entity(data.entity).state.GarbageOccupied or IsHoldingTrash() then
        return
    end

    for sceneIdx = 1, #Config.Scenes do
        for _, modelName in pairs(Config.Scenes[sceneIdx].Models) do
            if GetHashKey(modelName) == objectModel then
                StartScene(Config.Scenes[sceneIdx], sceneIdx, data.entity)
            end
        end
    end
end)

RegisterNetEvent("multiplayerGarbage:collectBag", function(data)
    if IsEntityAttachedToAnyPed(data.entity) or Entity(data.entity).state.GarbageBlock then
        return
    end
    PickTrash(data.entity)
end)

RegisterNetEvent("multiplayerGarbage:PutIn", function(...)
    if not IsHoldingTrash() then
        return
    end

    local data = (...)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehMin, _ = GetModelDimensions(Config.JobVehicleModel)
    local throwPos = GetOffsetFromEntityInWorldCoords(jobVehicle, 0.0, vehMin.y, 0.5)
    local distance = #(playerCoords - throwPos)

    local vehHeading = GetEntityHeading(jobVehicle)
    local pedHeading = GetEntityHeading(playerPed)
    local headingDiff = math.abs(vehHeading - pedHeading)

    if JobVehicleNetId and (not JobVehicleNetId or data.entity == _NetToVeh(JobVehicleNetId)) then
    else
        return Notify(_L("Job.Gameplay.InvalidVehicle"))
    end

    if headingDiff > 180 then
        headingDiff = 360 - headingDiff
    end

    if distance < 1.0 then
        ThrowTrash(jobVehicle, heldBagObject)
    else
        Notify(_L("Job.Gameplay.InvalidPosition"))
    end
end)

function PickTrash(bagEntity)
    local playerPed = PlayerPedId()
    local bagModel = GetEntityModel(bagEntity)
    local bagCoords = GetEntityCoords(bagEntity)
    local bagNetIdToSend = nil

    if not IsExploitFixClear() then
        return Notify(_L("Job.Gameplay.Exploit"))
    end

    if NetworkGetEntityIsNetworked(bagEntity) then
        bagNetIdToSend = ObjToNet(bagEntity)
    end

    local serverAllowed = CheckServerAllow(bagCoords, not NetworkGetEntityIsNetworked(bagEntity), bagNetIdToSend)
    if not serverAllowed then
        return
    end

    local attachData = Config.BagAttachments[bagModel]
    if not attachData then
        TriggerServerEvent("17mov_GarbageCollector:server:clearRequest")
        return Functions.Print("CANNOT FIND OFFSET DATA FOR THE PROVIDED BAG.")
    end

    local pedCoords = GetEntityCoords(playerPed)
    local pedHeading = GetEntityHeading(playerPed)
    local dx = bagCoords.x - pedCoords.x
    local dy = bagCoords.y - pedCoords.y
    local angle = math.deg(math.atan2(dy, dx))
    local relative = angle - pedHeading - 90
    relative = -relative
    if relative > 180 then
        relative = relative - 360
    elseif relative < -180 then
        relative = relative + 360
    end

    local animName = "pickup"
    local animDuration = 16
    if relative >= -15 and relative <= 15 then
        animName = "pickup"
        animDuration = 16
    elseif relative > 15 and relative <= 60 then
        animName = "pickup_45_r"
        animDuration = 14
    elseif relative < -15 and relative >= -60 then
        animName = "pickup_45_l"
        animDuration = 15
    elseif relative > 60 and relative <= 120 then
        animName = "pickup_90_r"
        animDuration = 14
    elseif relative < -60 and relative >= -120 then
        animName = "pickup_90_l"
        animDuration = 14
    end

    local waitMs = animDuration * 33.333333333333336

    Functions.RequestAnimDict("anim@heists@narcotics@trash")
    TaskTurnPedToFaceEntity(playerPed, bagEntity, 1000)
    Wait(300)
    TaskPlayAnim(playerPed, "anim@heists@narcotics@trash", animName, 2.0, 2.0, -1, 49, 0, false, false, false)
    Citizen.Wait(waitMs or 500)

    local nearbyIds = {}
    local myCoords = GetEntityCoords(PlayerPedId())
    for _, activeId in pairs(GetActivePlayers()) do
        local activePed = GetPlayerPed(activeId)
        if activePed ~= playerPed then
            local activeDist = #(GetEntityCoords(activePed) - myCoords)
            if activeDist < 200.0 then
                table.insert(nearbyIds, GetPlayerServerId(activeId))
            end
        end
    end

    local bagOwner = NetworkGetEntityOwner(bagEntity)
    if bagOwner == -1 then
        Functions.DeleteEntity(bagEntity)
        TriggerServerEvent("17mov_GarbageCollector:BagCollected", nearbyIds, {
            coords = bagCoords,
            model = bagModel
        })
    else
        if NetworkGetEntityOwner(bagEntity) ~= PlayerId() then
            local bagNet = ObjToNet(bagEntity)
            if bagNet then
                TriggerServerEvent("17mov_GarbageCollector:server:BagCollected", bagNet)
            end
        elseif NetworkGetEntityOwner(bagEntity) == PlayerId() then
            Functions.DeleteEntity(bagEntity)
        end
    end

    while DoesEntityExist(bagEntity) do
        Wait(1)
    end

    Functions.SpawnObject(bagModel, function(spawnedBag)
        local bagRotation = GetEntityRotation(bagEntity)
        local boneIndex = Functions.GetBoneIndexByName(playerPed, "SKEL_R_HAND")
        if boneIndex == nil then
            Functions.DeleteEntity(spawnedBag)
            return Functions.DeleteEntity(bagEntity)
        end

        heldBagObject = spawnedBag
        OnBagPickup(heldBagObject)
        SetEntityRotation(spawnedBag, bagRotation.x, bagRotation.y, bagRotation.z, 2, false)
        AttachEntityToEntity(spawnedBag, playerPed, boneIndex,
            attachData.offset.x, attachData.offset.y, attachData.offset.z,
            attachData.rotation.x, attachData.rotation.y, attachData.rotation.z,
            false, false, false, true, 1, true)
    end, bagCoords, true, false)

    Citizen.Wait(waitMs or 500)
    TriggerServerEvent("17mov_GarbageCollector:server:clearRequest")
    PlayBagWearingAnim()
end

function Functions.GetObjectOfTypeAtGivenCoords(coords, modelHash)
    local closestObj = nil
    local closestDist = 5
    local pool = GetGamePool("CObject")

    for _, obj in ipairs(pool) do
        if GetEntityModel(obj) == modelHash then
            local distance = #(GetEntityCoords(obj) - coords)
            if closestDist == nil or closestDist > distance then
                closestObj = obj
                closestDist = distance
            end
        end
    end

    return closestObj, closestDist
end

RegisterNetEvent("17mov_GarbageCollector:BagCollected", function(data)
    local closestObj = nil
    local closestDist = 5
    local pool = GetGamePool("CObject")

    for _, obj in ipairs(pool) do
        if GetEntityModel(obj) == data.model and NetworkGetEntityOwner(obj) == -1 then
            local objCoords = GetEntityCoords(obj)
            local targetCoords = vector3(data.coords.x, data.coords.y, data.coords.z)
            local distance = #(objCoords - targetCoords)
            if closestDist == nil or closestDist > distance then
                closestObj = obj
                closestDist = distance
            end
        end
    end

    if closestObj and closestDist then
        Functions.RequestControlOfEntity(closestObj)
        Functions.DeleteEntity(closestObj)
    end

    if Config.BlockBagsRespawning then
        table.insert(bagsBlocked, {
            model = data.model,
            coords = data.coords,
            time = GetGameTimer()
        })
    end
end)

if Config.BlockBagsRespawning then
    CreateThread(function()
        while true do
            Citizen.Wait(1000)
            for blockedIdx, blockedBag in pairs(bagsBlocked) do
                local elapsed = GetGameTimer() - blockedBag.time
                if elapsed < Config.BagRespawnTime then
                    local pool = GetGamePool("CObject")
                    for _, obj in ipairs(pool) do
                        local objModel = GetEntityModel(obj)
                        local objCoords = GetEntityCoords(obj)
                        local blockedCoords = vector3(blockedBag.coords.x, blockedBag.coords.y, blockedBag.coords.z)
                        local distance = #(objCoords - blockedCoords)

                        if objModel == blockedBag.model and distance < 0.1 and NetworkGetEntityOwner(obj) == -1 then
                            Functions.RequestControlOfEntity(obj)
                            Functions.DeleteEntity(obj)
                        end
                    end
                else
                    table.remove(bagsBlocked, blockedIdx)
                end
            end
        end
    end)
end

function PlayBagWearingAnim()
    local stillTimer = 0
    local fidgetPlaying = false
    Functions.RequestAnimDict("anim@heists@narcotics@trash")

    Citizen.CreateThread(function()
        while heldBagObject ~= 0 and DoesEntityExist(heldBagObject) do
            local playerPed = PlayerPedId()

            if not IsPedInAnyVehicle(playerPed, false) and IsPedOnFoot(playerPed)
                and not IsPedFalling(playerPed) and not IsPedRagdoll(playerPed)
                and not IsPedDeadOrDying(playerPed, false) and not IsPedClimbing(playerPed) then

                if IsPedStill(playerPed) then
                    stillTimer = stillTimer + GetFrameTime()
                    if fidgetPlaying then
                        if not IsEntityPlayingAnim(playerPed, "anim@heists@narcotics@trash", "idle_fidget", 3) then
                            fidgetPlaying = false
                            stillTimer = 0
                        end
                    else
                        if stillTimer >= 10.0 then
                            if math.random(1, 100) <= 10 then
                                TaskPlayAnim(playerPed, "anim@heists@narcotics@trash", "idle_fidget", 1.0, 1.0, -1, 49, 0, false, false, false)
                                fidgetPlaying = true
                            else
                                if not IsEntityPlayingAnim(playerPed, "anim@heists@narcotics@trash", "idle", 3) then
                                    TaskPlayAnim(playerPed, "anim@heists@narcotics@trash", "idle", 1.0, 1.0, -1, 49, 0, false, false, false)
                                end
                            end
                        else
                            if not IsEntityPlayingAnim(playerPed, "anim@heists@narcotics@trash", "idle", 3) and not fidgetPlaying then
                                TaskPlayAnim(playerPed, "anim@heists@narcotics@trash", "idle", 1.0, 1.0, -1, 49, 0, false, false, false)
                            end
                        end
                    end
                elseif IsPedWalking(playerPed) then
                    stillTimer = 0
                    if not IsEntityPlayingAnim(playerPed, "anim@heists@narcotics@trash", "walk", 3) then
                        TaskPlayAnim(playerPed, "anim@heists@narcotics@trash", "walk", 2.5, 2.5, -1, 49, 0, false, false, false)
                    end
                    fidgetPlaying = false
                elseif IsPedRunning(playerPed) or IsPedSprinting(playerPed) then
                    stillTimer = 0
                    if not IsEntityPlayingAnim(playerPed, "anim@heists@narcotics@trash", "run", 3) then
                        TaskPlayAnim(playerPed, "anim@heists@narcotics@trash", "run", 1.0, 1.0, -1, 49, 0, false, false, false)
                    end
                    fidgetPlaying = false
                else
                    stillTimer = 0
                    if not IsEntityPlayingAnim(playerPed, "anim@heists@narcotics@trash", "idle", 3) and not fidgetPlaying then
                        TaskPlayAnim(playerPed, "anim@heists@narcotics@trash", "idle", 1.0, 1.0, -1, 49, 0, false, false, false)
                    end
                end
            else
                stillTimer = 0
                fidgetPlaying = false
            end

            if not Config.UseTarget then
                local myCoords = GetEntityCoords(playerPed)
                local throwPos = GetOffsetFromEntityInWorldCoords(jobVehicle, Config.JobVehicleBackOffset)
                local distance = #(myCoords - throwPos)
                local vehHeading = GetEntityHeading(jobVehicle)
                local pedHeading = GetEntityHeading(playerPed)
                local headingDiff = math.abs(vehHeading - pedHeading)
                if headingDiff > 180 then
                    headingDiff = 360 - headingDiff
                end

                if distance < 1.0 then
                    DrawText3Ds(throwPos.x, throwPos.y, throwPos.z,
                        Config.KeybindSettings.bagsInteractionkeyString .. _L("Job.Gameplay.Throw"),
                        jobVehicle)
                    if IsControlJustReleased(0, Config.KeybindSettings.bagsInteractionKey) then
                        ThrowTrash(jobVehicle, heldBagObject)
                    end
                else
                    if IsControlJustReleased(0, Config.KeybindSettings.bagsInteractionKey) then
                        DetachEntity(heldBagObject, true, true)
                        OnBagDetach(heldBagObject)
                        Citizen.CreateThread(function()
                            Wait(2)
                            heldBagObject = 0
                            ClearPedTasks(playerPed)
                        end)
                    end
                end
            else
                if IsControlJustReleased(0, Config.KeybindSettings.bagsInteractionKey) then
                    DetachEntity(heldBagObject, true, true)
                    OnBagDetach(heldBagObject)
                    Citizen.CreateThread(function()
                        Wait(2)
                        heldBagObject = 0
                        ClearPedTasks(playerPed)
                    end)
                end
            end

            Citizen.Wait(0)
        end
    end)
end

RegisterNetEvent("17mov_GarbageCollector:ToggleTrunk", function(vehNetId, open)
    local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
    if vehicle and DoesEntityExist(vehicle) then
        if GetEntityModel(vehicle) == 1917016601 then
            if open then
                SetVehicleDoorOpen(vehicle, 5, false, false)
            else
                SetVehicleDoorShut(vehicle, 5, false)
            end
        end
    end
end)

function IsHoldingTrash()
    return heldBagObject ~= 0
end

function ThrowTrash(vehicle, bagObject)
    if not Functions.RequestControlOfEntity(bagObject) then
        Functions.Print("CANNOT CHANGE PROP OWNERSHIP")
    end

    local vehNetId = VehToNet(vehicle)
    TriggerServerEvent("17mov_GarbageCollector:ToggleTrunk", vehNetId, true)

    local playerPed = PlayerPedId()
    local pedHeading = GetEntityHeading(playerPed)
    local vehHeading = GetEntityHeading(vehicle)
    local startTimer = GetGameTimer()
    local turnDuration = 300

    CreateThread(function()
        while GetGameTimer() - startTimer < 2000 do
            if GetVehicleDoorAngleRatio(vehicle, 5) > 0.1 then
                break
            end
            Citizen.Wait(100)
        end
    end)

    while turnDuration > GetGameTimer() - startTimer do
        local progress = (GetGameTimer() - startTimer) / turnDuration
        local diff = vehHeading - pedHeading
        if diff > 180 then
            diff = diff - 360
        elseif diff < -180 then
            diff = diff + 360
        end

        local newHeading
        if diff > 0 then
            newHeading = Functions.Lerp(pedHeading, pedHeading + diff, progress)
        else
            newHeading = Functions.Lerp(pedHeading, pedHeading + diff, progress)
        end

        SetEntityHeading(playerPed, newHeading)
        Citizen.Wait(0)
    end

    SetEntityHeading(playerPed, vehHeading)
    Functions.RequestAnimDict("anim@heists@narcotics@trash")
    heldBagObject = 0
    OnBagDetach(heldBagObject)

    local throwAnimDuration = 833.3333333333334
    local bagModel = GetEntityModel(bagObject)
    TaskPlayAnim(playerPed, "anim@heists@narcotics@trash", "throw_ranged_b", 2.0, 2.0, -1, 32, 0, false, false, false)
    Citizen.Wait(throwAnimDuration or 500)
    Functions.DeleteEntity(bagObject)
    Citizen.Wait(throwAnimDuration or 500)
    ClearPedTasks(playerPed)
    TriggerServerEvent("17mov_Garbage:UpdateServerPartyBagsCounter", bagModel)
    TriggerServerEvent("17mov_GarbageCollector:ToggleTrunk", vehNetId, false)
end

function CheckServerAllow(coords, isNotNetworked, bagNetId)
    local prom = promise.new()
    Functions.TriggerServerCallback("17mov_GarbageCollector:CheckAllow", function(result)
        prom:resolve(result)
    end, coords, isNotNetworked, bagNetId)
    return Citizen.Await(prom)
end

function IsGarbageOccupied(netId)
    local prom = promise.new()
    Functions.TriggerServerCallback("17mov_GarbageCollector:server:GarbageGetOcupied", function(result)
        prom:resolve(result)
    end, netId)
    return Citizen.Await(prom)
end

function StartScene(sceneData, sceneId, binEntity)
    local binRoll = GetEntityRoll(binEntity)
    local binPitch = GetEntityPitch(binEntity)

    if not IsExploitFixClear() then
        return Notify(_L("Job.Gameplay.Exploit"))
    end

    if math.abs(binRoll) > 50.0 or math.abs(binPitch) > 50.0 then
        Notify(_L("Job.Gameplay.DumpsterNotStable"))
        return
    end

    Functions.IsInAnim = true
    local binModel = GetEntityModel(binEntity)
    local stageIdx = 1
    local bagAttachIdx = 3
    local totalStages = #sceneData.Stages

    if not NetworkGetEntityIsNetworked(binEntity) then
        NetworkRegisterEntityAsNetworked(binEntity)
        while not NetworkGetEntityIsNetworked(binEntity) do
            Wait(1)
        end

        local binNetId = ObjToNet(binEntity)
        while not binNetId do
            binNetId = ObjToNet(binEntity)
            Wait(1)
        end

        SetNetworkIdCanMigrate(binNetId, true)
        SetNetworkIdExistsOnAllMachines(binNetId, true)
        TriggerServerEvent("17mov_GarbageCollector:server:GarbageSetOcupied", binNetId, nil, {
            coords = GetEntityCoords(binEntity),
            rotation = GetEntityRotation(binEntity, 0)
        })
    else
        if IsGarbageOccupied(ObjToNet(binEntity)) then
            Functions.IsInAnim = false
            return print("This is occupied")
        end
    end

    if Entity(binEntity).state.currentStage then
        stageIdx = Entity(binEntity).state.currentStage
    end

    if Config.Debug.enabled then
        stageIdx = Config.Debug.bin_stage or stageIdx
    end

    local stageData = Functions.DeepCopy(sceneData.Stages[stageIdx])
    local playerWorldOffset = GetOffsetFromEntityInWorldCoords(binEntity,
        stageData.PlayerOffset.x, stageData.PlayerOffset.y, stageData.PlayerOffset.z)
    local sceneObjectOffset = GetOffsetFromEntityInWorldCoords(binEntity,
        stageData.Objects[2].offset.x, stageData.Objects[2].offset.y, stageData.Objects[2].offset.z)

    local bagModelHash = nil

    for objIdx, objData in pairs(stageData.Objects) do
        if objData.object == "PlayerPed" then
            stageData.Objects[objIdx].coords = playerWorldOffset
            stageData.Objects[objIdx].heading = GetEntityHeading(binEntity)
        elseif objData.object == "SceneModel" then
            local resolvedModel = sceneData.Models[1]
            for modelIdx = 1, #sceneData.Models do
                if GetEntityModel(binEntity) == GetHashKey(sceneData.Models[modelIdx]) then
                    resolvedModel = sceneData.Models[modelIdx]
                end
            end
            stageData.Objects[objIdx].model = resolvedModel
            stageData.Objects[objIdx].object = binEntity
            stageData.Objects[objIdx].coords = sceneObjectOffset
            stageData.Objects[objIdx].IsSceneObject = true
        end
    end

    for objIdx, objData in pairs(stageData.Objects) do
        if objData.object ~= "PlayerPed" and objData.object ~= "SceneModel" and objData.attachment then
            bagAttachIdx = objIdx
            bagModelHash = GetHashKey(objData.model)
        end
    end

    local attachOffset = stageData.PlayerOffset + vec3(0, 0, 1.0)
    AttachEntityToEntity(PlayerPedId(), binEntity, 0,
        attachOffset.x, attachOffset.y, attachOffset.z,
        0.0, 0.0, 0.0,
        false, true, true, false, 2, true)

    local sceneRef = {
        coords = playerWorldOffset,
        rotation = GetEntityRotation(binEntity)
    }

    local scenePromise = promise.new()
    Functions.StartScene(sceneRef, stageData.Objects, sceneId, function(sceneResult, wasAborted)
        DetachEntity(PlayerPedId(), false, false)
        if tutorialBagsToHighlight > 0 then
            spawnedBags[tostring(binModel)] = true
        end

        if stageIdx < totalStages then
            local bagObj = sceneResult.objects[bagAttachIdx].object
            if not wasAborted and DoesEntityExist(bagObj) then
                scenePromise:resolve()
                Functions.DeleteEntity(bagObj)
                return
            end

            if not bagModelHash then
                bagModelHash = GetEntityModel(bagObj)
            end

            local bagRotation = GetEntityRotation(bagObj)
            local bagCoords = GetEntityCoords(bagObj)

            if not CheckServerAllow(bagCoords) then
                scenePromise:resolve()
                Functions.DeleteEntity(bagObj)
                return
            end

            Functions.DeleteEntity(bagObj)
            local newBag = Functions.SpawnObject(bagModelHash, nil, bagCoords, true, false)
            if newBag then
                local ped = PlayerPedId()
                local attachCfg = Config.BagAttachments[bagModelHash]
                local boneIndex = Functions.GetBoneIndexByName(ped, "SKEL_R_HAND")
                if boneIndex == nil then
                    scenePromise:resolve()
                    Functions.DeleteEntity(newBag)
                    return
                end

                heldBagObject = newBag
                OnBagPickup(heldBagObject)
                SetEntityRotation(heldBagObject, bagRotation.x, bagRotation.y, bagRotation.z, 2, false)
                AttachEntityToEntity(heldBagObject, ped, boneIndex,
                    attachCfg.offset.x, attachCfg.offset.y, attachCfg.offset.z,
                    attachCfg.rotation.x, attachCfg.rotation.y, attachCfg.rotation.z,
                    true, true, false, true, 1, true)
                PlayBagWearingAnim()
            end
        end
        scenePromise:resolve()
    end, stageIdx)

    Citizen.Await(scenePromise)
    Functions.IsInAnim = false
    TriggerServerEvent("17mov_GarbageCollector:server:clearRequest")
end

RegisterNetEvent("17mov_Garbage:UpdateBagsCounter", function(value)
    bagsCounter = value
    SendNUIMessage({
        action = "updateCounter",
        value = value
    })
end)

function EndJob()
    if not canEndJob then
        return
    end
    canEndJob = false

    if bagsCounter < 100 and Config.RequireFullJob then
        canEndJob = true
        return Notify(_L("Lobby.EndJob.DoEverything"))
    end

    local driverPed = GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId(), false), -1)
    if driverPed ~= PlayerPedId() then
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            canEndJob = true
            return Notify(_L("Lobby.EndJob.NotDriver"))
        end
    end

    local playerVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local trackedVehicle = _NetToVeh(JobVehicleNetId)

    if playerVehicle == trackedVehicle then
        if Config.EnableUnloadStage and bagsCounter > 0 then
            if GetResourceKvpInt("17mov_Tutorials:" .. "endStageTutorial") == 0 then
                currentTutorialKey = "endStageTutorial"
                SetNuiFocus(true, true)
                SendNUIMessage({
                    action = "showTutorial",
                    customText = _L("Job.Gameplay.EndStageTutorial")
                })
            end
            return TriggerServerEvent("17mov_Garbage:server:endStage")
        end

        canEndJob = true
        return TriggerServerEvent("17mov_Garbage:endJob_sv", true)
    end

    SetNuiFocus(true, true)
    SendNUIMessage({ action = "openWarning" })
    canEndJob = true
end

RegisterNetEvent("17mov_Garbage:endJob_cl", function()
    if RemoveKeys ~= nil then
        RemoveKeys()
    end

    SendNUIMessage({
        action = "updateCounter",
        value = 0
    })

    if Config.RequireWorkClothes and not Config.EnableCloakroom then
        workClothesActive = false
        ChangeClothes("citizen")
    end

    if Config.UseTarget then
        DeleteEntityFromTarget(jobVehicle)
    end

    bagsCounter = 0
    heldBagObject = 0
    OnDuty = false

    SendNUIMessage({ action = "hideCounter" })
end)

if Config.LetBossSplitReward then
    RegisterNUICallback("checkIfThisRewardIsFine", function(data, cb)
        local value = math.floor(data.value)
        local plyId = data.plyId

        if value > 100 or value < 0 then
            Notify(_L("Lobby.Reward.InvalidPerect"))
            return cb(false)
        end

        Functions.TriggerServerCallback("17mov_Garbage:CheckThisReward", function(result)
            if result then
                cb(true)
            else
                Notify(_L("Lobby.Reward.TooMuchPerect"))
                cb(false)
            end
        end, value, plyId)
    end)
else
    CreateThread(function()
        while not nuiScriptReady do
            Citizen.Wait(100)
        end
        SendNUIMessage({ action = "hideManageRewards" })
    end)
end

RegisterNUICallback("driverLoaded", function(data, cb)
    nuiLoaded = true
    cb({})
end)

RegisterNUICallback("nuiLoaded", function(data, cb)
    nuiScriptReady = true
    cb({})
end)

RegisterNUICallback("acceptWarning", function(data, cb)
    TriggerServerEvent("17mov_Garbage:endJob_sv", false)
    cb({})
end)

RegisterNUICallback("tutorialClosed", function(data, cb)
    SetNuiFocus(false, false)
    currentTutorialKey = ""
    cb({})
end)

RegisterNUICallback("menuClosed", function(data, cb)
    workMenuOpen = false
    SetNuiFocus(false, false)
    cb({})
end)

RegisterNUICallback("dontShowTutorialAgain", function(data, cb)
    SetResourceKvpInt("17mov_Tutorials:" .. currentTutorialKey, 1)
    cb({})
end)

RegisterNUICallback("startJob", function(data, cb)
    local myCoords = GetEntityCoords(PlayerPedId())
    local distance = #(myCoords - Config.Locations.DutyToggle.Coords[1])
    if distance > 25.0 then
        return
    end

    if not OnDuty then
        if Functions.IsSpawnPointClear(Config.SpawnPoint) then
            TriggerServerEvent("17mov_Garbage:StartJob_sv")
        else
            Notify(_L("Lobby.StartJob.SpawnpointBusy"))
        end
    else
        Notify(_L("Lobby.StartJob.AlreadyWorking"))
    end

    cb({})
end)

RegisterNUICallback("leaveLobby", function(data, cb)
    if OnDuty then
        return Notify(_L("Lobby.Player.CantExit"))
    end

    local targetId = tonumber(data.id)
    TriggerServerEvent("17mov_Garbage:KickPlayerFromLobby", targetId, false, GetPlayerServerId(PlayerId()))
    Notify(_L("Lobby.Player.Quit"))
    cb({})
end)

RegisterNUICallback("focusOff", function(data, cb)
    SetNuiFocus(false, false)
    cb({})
end)

RegisterNUICallback("notify", function(data, cb)
    Notify(data.msg)
    cb({})
end)

RegisterNUICallback("changeClothes", function(data, cb)
    if data.type == "work" then
        workClothesActive = true
        ChangeClothes("work")
    else
        workClothesActive = false
        ChangeClothes("citizen")
    end
    cb({})
end)

RegisterNUICallback("GetClosestPlayers", function(data, cb)
    local activePlayers = GetActivePlayers()
    local myCoords = GetEntityCoords(PlayerPedId())
    local result = {}

    for _, playerIdx in pairs(activePlayers) do
        if PlayerId() ~= playerIdx then
            local otherPed = GetPlayerPed(playerIdx)
            local distance = #(myCoords - GetEntityCoords(otherPed))
            if distance < 20.0 then
                table.insert(result, GetPlayerServerId(playerIdx))
            end
        end
    end

    Functions.TriggerServerCallback("17mov_Garbage:IfPlayerIsHost", function(isHost)
        if isHost then
            Functions.TriggerServerCallback("17mov_Garbage:GetPlayersNames", function(names)
                cb(names)
                if #names == 0 then
                    Notify(_L("Lobby.StartJob.NobodyNearby"))
                end
            end, result)
        else
            Notify(_L("Lobby.EndJob.NoPermission"))
        end
    end)
end)

RegisterNUICallback("requestReacted", function(data, cb)
    local accepted = data.boolean
    SetNuiFocus(false, false)
    TriggerServerEvent("17mov_Garbage:ClientReactRequest", accepted)
    cb({})
end)

RegisterNUICallback("sendRequest", function(data, cb)
    if OnDuty then
        return Notify(_L("Lobby.StartJob.CantInvite"))
    end

    if Config.UseModernUI then
        TriggerServerEvent("17mov_Garbage:SendRequestToClient_sv", tonumber(data.id))
    else
        Notify(_L("Lobby.StartJob.InviteSent"))
        TriggerServerEvent("17mov_Garbage:SendRequestToClient_sv", data.id)
    end

    cb({})
end)

RegisterNUICallback("kickPlayerFromLobby", function(data, cb)
    if Config.UseModernUI then
        local targetId = tonumber(data.id)
        Notify(_L("Lobby.Player.MemberKicked", myPartyMembers[targetId].name))
        TriggerServerEvent("17mov_Garbage:KickPlayerFromLobby", targetId, true)
    else
        Notify(_L("Lobby.Player.MemberKicked", data.name))
        TriggerServerEvent("17mov_Garbage:KickPlayerFromLobby", data.id, true)
    end

    cb({})
end)

if Config.Debug.enabled then
    CreateThread(function()
        while true do
            if Config.UseTarget then
                break
            end

            local playerPed = PlayerPedId()
            local myCoords = GetEntityCoords(playerPed)
            local objectPool = GetGamePool("CObject")
            local foundBin = nil
            local foundBag = nil
            local closestDist = 1.5

            for _, obj in pairs(objectPool) do
                local objModel = GetEntityModel(obj)

                for sceneIdx, scene in pairs(Config.Scenes) do
                    local isSceneModel = false
                    for _, modelName in pairs(scene.Models) do
                        if objModel == GetHashKey(modelName) then
                            isSceneModel = true
                        end
                    end

                    if isSceneModel then
                        local objCoords = GetEntityCoords(obj)
                        local distance = #(myCoords - objCoords)
                        if distance <= scene.Distance then
                            foundBin = {
                                scene = scene,
                                object = obj,
                                sceneId = sceneIdx
                            }
                        end
                    end
                end

                if not foundBin then
                    local objCoords = GetEntityCoords(obj)
                    local distance = #(myCoords - objCoords)
                    local objModelHash = GetEntityModel(obj)
                    if Config.BagAttachments[objModelHash] and closestDist > distance then
                        if not IsEntityAttachedToAnyPed(obj) then
                            foundBag = obj
                            closestDist = distance
                        end
                    end
                end
            end

            local newBinObject = foundBin and foundBin.object
            local currentBinObject = currentBin and currentBin.object

            if newBinObject == currentBinObject and foundBag == currentBag then
                goto continue_debug
            end

            currentBin = foundBin
            currentBag = foundBag

            if not currentBin and not currentBag then
                goto continue_debug
            end

            StartBinInteractionThread()
            ::continue_debug::
            Citizen.Wait(300)
        end
    end)
end
