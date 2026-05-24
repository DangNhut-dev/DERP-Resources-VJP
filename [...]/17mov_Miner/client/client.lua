local elevator
local teamMembers = {}
local currentMagazineType
local carriedObject
local mineCounter = 0
local propsObjects = {
    rails = {},
    lights = {},
    supports = {
        pillarLeft = {},
        pillarRight = {},
        connectorLeft = {},
        connectorRight = {},
        lintel = {}
    }
}
local propsObjectsTable = {}
propsObjectsTable.Rails = {}
propsObjectsTable.Lights = {}
propsObjectsTable.SupportPillarLeft = {}
propsObjectsTable.SupportPillarRight = {}
propsObjectsTable.SupportConnectorLeft = {}
propsObjectsTable.SupportConnectorRight = {}
propsObjectsTable.SupportLintel = {}

local lastStackCoords
local headlampObject
local magazine = {}
local magazineData = {}
local inJobArea = false
OnDuty = false
local scriptInitialized = false
local PlayerData
local haveWorkClothes = false
local lobbyMembers = {}
local myServerId = GetPlayerServerId(PlayerId())
local menuOpen = true
local nuiLoaded = false
local tutorialShowing = false
local currentTutorialName = ""
local isBack = false
local HaveGear = false
local HaveClothes = false
local spawnedPed
local foodTrayObject = 0
local seatedPlayer = 0
local seatedChairId = 0
local gasEffectActive = false

local originalNetToObj = NetToObj
function NetToObj(netId)
    if NetworkDoesNetworkIdExist(netId) then
        return originalNetToObj(netId)
    else
        return 0
    end
end

local originalNetToVeh = NetToVeh
function NetToVeh(netId)
    if NetworkDoesNetworkIdExist(netId) then
        return originalNetToVeh(netId)
    else
        return 0
    end
end

-- Hàm xóa đệ quy entities (dùng cho cleanup objects)
local function deleteRecursive(obj)
    if "table" == type(obj) then
        for _, item in pairs(obj) do
            deleteRecursive(item)
        end
    else
        if obj and DoesEntityExist(obj) then
            DeleteEntity(obj)
        end
    end
end

RegisterNUICallback("nuiLoaded", function(data, cb)
    nuiLoaded = true
    local langTable = {}
    
    for key, value in pairs(Config.Lang) do
        if string.sub(key, 1, string.len("NUI_")) == "NUI_" then
            local cleanKey = string.sub(key, string.len("NUI_") + 1)
            langTable[cleanKey] = value
        end
    end
    
    SendNUIMessage({
        action = "SetupLang",
        lang = langTable
    })
    
    cb("ok")
end)

function CreateNewElevator()
    local elevatorData = {}
    elevatorData.ElevatorModel = 2064695006
    elevatorData.rightDoorModel = -2064916375
    elevatorData.leftDoorModel = 937182807
    elevatorData.buttonModel = -1231044648
    elevatorData.DoorsBeingAnimated = false
    elevatorData.beingAnimated = false
    elevatorData.frontDoorsOpened = false
    elevatorData.backDoorsOpened = false
    elevatorData.currentState = "up"
    elevatorData.doorsClosed = true
    elevatorData.movementSpeed = 5.0
    elevatorData.sizeX = 7.7
    elevatorData.sizeY = 9.8
    
    Functions.SpawnObject(
        elevatorData.ElevatorModel,
        function(obj)
            elevatorData.elevator = obj
            elevatorData.coordinates = GetEntityCoords(obj)
        end,
        vec3(2428.1875, 1531.82007, 41.1022453),
        false,
        true
    )
    
    local doorConfigs = {}
    doorConfigs.frontRDoor = {
        variable = "frontRDoor",
        offset = {
            offset = vec3(3.4, 0.81, -0.47),
            rotation = vec3(0, 0, 0)
        },
        model = elevatorData.rightDoorModel
    }
    doorConfigs.frontLDoor = {
        variable = "frontLDoor",
        offset = {
            offset = vec3(3.4, -0.81, -0.47),
            rotation = vec3(0, 0, 0)
        },
        model = elevatorData.leftDoorModel
    }
    doorConfigs.backRDoor = {
        variable = "backRDoor",
        offset = {
            offset = vec3(-3.4, 0.81, -0.47),
            rotation = vec3(0, 0, 0)
        },
        model = elevatorData.rightDoorModel
    }
    doorConfigs.backLDoor = {
        variable = "backLDoor",
        offset = {
            offset = vec3(-3.4, -0.81, -0.47),
            rotation = vec3(0, 0, 0)
        },
        model = elevatorData.leftDoorModel
    }
    
    for doorKey, doorConfig in pairs(doorConfigs) do
        doorConfig.offset.ogOffset = doorConfig.offset.offset
        
        Functions.SpawnObject(
            doorConfig.model,
            function(obj)
                elevatorData[doorConfig.variable] = obj
                AttachEntityToEntity(
                    obj,
                    elevatorData.elevator,
                    0,
                    doorConfig.offset.offset.x,
                    doorConfig.offset.offset.y,
                    doorConfig.offset.offset.z,
                    doorConfig.offset.rotation.x,
                    doorConfig.offset.rotation.y,
                    doorConfig.offset.rotation.z,
                    false,
                    false,
                    true,
                    false,
                    2,
                    true
                )
            end,
            elevatorData.coordinates,
            false,
            true
        )
    end
    
    local buttonConfigs = {}
    buttonConfigs.upBtn = {
        variable = "upBtn",
        coords = vector3(2432.0, 1533.79, 40.2),
        rotation = vec3(0.0, 0.0, 0.0)
    }
    buttonConfigs.insideBtn = {
        variable = "insideBtn",
        attach = true,
        coords = elevatorData.coordinates,
        offset = vec3(-3.17, -1.95, -0.71),
        rotation = vec3(0.0, 0.0, 0.0)
    }
    
    for btnKey, btnConfig in pairs(buttonConfigs) do
        Functions.SpawnObject(
            elevatorData.buttonModel,
            function(obj)
                local buttonName = "btn" .. btnConfig.variable
                elevatorData[buttonName] = obj
                
                if btnConfig.attach then
                    AttachEntityToEntity(
                        obj,
                        elevatorData.elevator,
                        0,
                        btnConfig.offset.x,
                        btnConfig.offset.y,
                        btnConfig.offset.z,
                        btnConfig.rotation.x,
                        btnConfig.rotation.y,
                        btnConfig.rotation.z,
                        false,
                        false,
                        true,
                        false,
                        2,
                        true
                    )
                else
                    SetEntityRotation(
                        obj,
                        btnConfig.rotation.x,
                        btnConfig.rotation.y,
                        btnConfig.rotation.z,
                        0,
                        false
                    )
                end
            end,
            btnConfig.coords,
            false,
            true
        )
    end
    
    function elevatorData.buildProtection()
        for doorKey, doorConfig in pairs(doorConfigs) do
            Functions.SpawnObject(
                doorConfig.model,
                function(obj)
                    Entity(obj).state.isProtection = true
                    local protectionName = "protection" .. doorConfig.variable
                    elevatorData[protectionName] = obj
                    
                    AttachEntityToEntity(
                        obj,
                        elevatorData.elevator,
                        0,
                        doorConfig.offset.ogOffset.x,
                        doorConfig.offset.ogOffset.y,
                        doorConfig.offset.ogOffset.z,
                        doorConfig.offset.rotation.x,
                        doorConfig.offset.rotation.y,
                        doorConfig.offset.rotation.z,
                        false,
                        false,
                        true,
                        false,
                        2,
                        true
                    )
                    
                    SetEntityVisible(obj, false, false)
                end,
                elevatorData.coordinates,
                false,
                true
            )
        end
    end
    
    function elevatorData.removeProtection()
        for doorKey, doorConfig in pairs(doorConfigs) do
            local protectionName = "protection" .. doorConfig.variable
            Functions.DeleteEntity(elevatorData[protectionName])
        end
        
        local allObjects = GetGamePool("CObject")
        for _, obj in pairs(allObjects) do
            if Entity(obj).state.isProtection == true then
                DeleteEntity(obj)
            end
        end
    end
    
    function elevatorData.animateDoors(isBack, param2)
        local doorOpenDistance = 1.77
        local doorAnimSpeed = 0.0075
        local skipProtection = param2

        if not isBack then
            param2 = not param2
        end

        if not isBack then
            if elevatorData.frontDoorsOpened and not param2 then
                return Functions.Error("TRIED TO OPEN FRONT DOORS WHILE THEY'RE ALREADY OPENED")
            end
        end

        if isBack then
            if elevatorData.backDoorsOpened and param2 then
                return Functions.Error("TRIED TO OPEN BACK DOORS WHILE THEY'RE ALREADY OPENED")
            end
        end

        if skipProtection ~= true then
            elevatorData.buildProtection()
        end

        local doorsToAnimate = {}
        local direction = param2 and -1 or 1

        if not isBack then
            elevatorData.frontDoorsOpened = not param2

            table.insert(doorsToAnimate, {
                object = elevatorData.frontRDoor,
                key = "frontRDoor",
                currOffset = doorConfigs.frontRDoor.offset.offset,
                targetOffsetY = doorConfigs.frontRDoor.offset.offset.y + (doorOpenDistance * direction),
                currRotation = doorConfigs.frontRDoor.offset.rotation,
                direction = 1 * direction
            })

            table.insert(doorsToAnimate, {
                object = elevatorData.frontLDoor,
                key = "frontLDoor",
                currOffset = doorConfigs.frontLDoor.offset.offset,
                targetOffsetY = doorConfigs.frontLDoor.offset.offset.y - (doorOpenDistance * direction),
                currRotation = doorConfigs.frontLDoor.offset.rotation,
                direction = -1 * direction
            })
        else
            elevatorData.backDoorsOpened = not param2 and not isBack
            local backDirection = param2 and 1 or -1

            table.insert(doorsToAnimate, {
                object = elevatorData.backRDoor,
                key = "backRDoor",
                currOffset = doorConfigs.backRDoor.offset.offset,
                targetOffsetY = doorConfigs.backRDoor.offset.offset.y + (doorOpenDistance * backDirection),
                currRotation = doorConfigs.backRDoor.offset.rotation,
                direction = 1 * backDirection
            })

            table.insert(doorsToAnimate, {
                object = elevatorData.backLDoor,
                key = "backLDoor",
                currOffset = doorConfigs.backLDoor.offset.offset,
                targetOffsetY = doorConfigs.backLDoor.offset.offset.y - (doorOpenDistance * backDirection),
                currRotation = doorConfigs.backLDoor.offset.rotation,
                direction = -1 * backDirection
            })
        end

        elevatorData.beingAnimated = true
        local animationComplete = false
        local targetFrameTime = 16.666666666666668

        while not animationComplete do
            animationComplete = true
            local frameStart = GetGameTimer()

            for _, doorData in ipairs(doorsToAnimate) do
                local newOffsetY = doorData.currOffset.y + (doorAnimSpeed * doorData.direction)

                if doorData.direction > 0 and newOffsetY > doorData.targetOffsetY then
                    newOffsetY = doorData.targetOffsetY
                elseif doorData.direction < 0 and newOffsetY < doorData.targetOffsetY then
                    newOffsetY = doorData.targetOffsetY
                else
                    animationComplete = false
                end

                doorData.currOffset = vec3(doorData.currOffset.x, newOffsetY, doorData.currOffset.z)
                doorConfigs[doorData.key].offset.offset = doorData.currOffset

                AttachEntityToEntity(
                    doorData.object,
                    elevatorData.elevator,
                    0,
                    doorData.currOffset.x,
                    doorData.currOffset.y,
                    doorData.currOffset.z,
                    doorData.currRotation.x,
                    doorData.currRotation.y,
                    doorData.currRotation.z,
                    false,
                    false,
                    true,
                    false,
                    2,
                    true
                )
            end

            local frameTime = GetGameTimer() - frameStart
            if targetFrameTime > frameTime then
                Wait(targetFrameTime - frameTime)
            end
        end

        if skipProtection ~= true then
            elevatorData.removeProtection()
        end

        if skipProtection then
            for _, doorData in pairs(doorsToAnimate) do
                AttachEntityToEntity(
                    doorData.object,
                    elevatorData.elevator,
                    0,
                    doorData.currOffset.x,
                    doorData.currOffset.y - (doorOpenDistance * -doorData.direction),
                    doorData.currOffset.z,
                    doorData.currRotation.x,
                    doorData.currRotation.y,
                    doorData.currRotation.z,
                    false,
                    false,
                    true,
                    false,
                    2,
                    true
                )
            end
        else
            for _, doorData in pairs(doorsToAnimate) do
                AttachEntityToEntity(
                    doorData.object,
                    elevatorData.elevator,
                    0,
                    doorData.currOffset.x,
                    doorData.currOffset.y,
                    doorData.currOffset.z,
                    doorData.currRotation.x,
                    doorData.currRotation.y,
                    doorData.currRotation.z,
                    false,
                    false,
                    true,
                    false,
                    2,
                    true
                )
            end
        end

        elevatorData.beingAnimated = false
    end
    
    function elevatorData.GlowButton(buttonName, isActive)
        local buttonObj = elevatorData[buttonName]
        
        if buttonObj == nil then
            return Functions.Error("Cant Find the " .. buttonName .. " button in GlowButton method")
        end
        
        local color = isActive or Config.MarkerSettings.Active
        if not isActive or not isActive then
            color = Config.MarkerSettings.UnActive
        end
        
        elevatorData.DisableBtnsGlow()
        SetEntityDrawOutlineColor(color.r, color.g, color.b, color.a)
        SetEntityDrawOutlineShader(0)
        SetEntityDrawOutline(buttonObj, true)
    end
    
    function elevatorData.DisableBtnsGlow()
        for btnKey, btnConfig in pairs(buttonConfigs) do
            local buttonName = "btn" .. btnConfig.variable
            SetEntityDrawOutline(elevatorData[buttonName], false)
        end
    end
    
    function elevatorData.TaskGoToCoords(offsetZ)
        if elevatorData.beingAnimated then
            return Functions.Error("Can't call TaskGoToCoords method because elevator is already in run")
        end
        
        elevatorData.beingAnimated = true
        
        local currentCoords = GetEntityCoords(elevatorData.elevator)
        local targetCoords = vec3(currentCoords.x, currentCoords.y, currentCoords.z + offsetZ)
        local distance = #(currentCoords - targetCoords)
        local travelTime = distance / elevatorData.movementSpeed
        
        Wait(travelTime * 1000)
        
        local playerPed = PlayerPedId()
        local playerOffset = GetEntityCoords(playerPed) - currentCoords
        
        SetEntityCoords(
            elevatorData.elevator,
            targetCoords.x,
            targetCoords.y,
            targetCoords.z,
            false,
            false,
            false,
            false
        )
        
        local newElevatorCoords = GetEntityCoords(elevatorData.elevator)
        local newPlayerCoords = newElevatorCoords + playerOffset
        
        if GetEntityCoords(PlayerPedId()).z >= 0 and offsetZ > 0 then
            return Functions.Error("Attempt to set invalid player coordinates in elevator")
        end
        
        if math.abs(playerOffset.x) > elevatorData.sizeX / 2 or math.abs(playerOffset.y) > elevatorData.sizeY / 2 then
            SetEntityCoords(
                playerPed,
                newElevatorCoords.x,
                newElevatorCoords.y,
                newElevatorCoords.z - 1.0,
                false,
                false,
                false,
                false
            )
        else
            SetEntityCoords(
                playerPed,
                newPlayerCoords.x,
                newPlayerCoords.y,
                newPlayerCoords.z - 1.0,
                false,
                false,
                false,
                false
            )
        end
        
        elevatorData.beingAnimated = false
    end
    
    function elevatorData.isInside(entity, customCoords)
        local entityCoords = GetEntityCoords(entity)
        
        if customCoords ~= nil then
            entityCoords = customCoords
        end
        
        local elevatorCoords = GetEntityCoords(elevatorData.elevator)
        local minX = elevatorCoords.x - elevatorData.sizeX / 2
        local maxX = elevatorCoords.x + elevatorData.sizeX / 2
        local minY = elevatorCoords.y - elevatorData.sizeY / 2
        local maxY = elevatorCoords.y + elevatorData.sizeY / 2
        
        if entityCoords.x >= minX and entityCoords.x <= maxX and
           entityCoords.y >= minY and entityCoords.y <= maxY then
            return true
        else
            return false
        end
    end
    
    return elevatorData
end

CreateThread(function()
    while not nuiLoaded do
        Wait(100)
    end
    
    SendNUIMessage({
        action = "setProgressBarAlign",
        align = Config.ProgressBarAlign,
        offset = Config.ProgressBarOffset
    })
    
    if not Config.EnableCloakroom then
        SendNUIMessage({
            action = "hideCloakroom"
        })
    end
    
    if Config.letBossSplitReward then
        RegisterNUICallback("checkIfThisRewardIsFine", function(data, cb)
            local rewardValue = math.floor(data.value)
            local playerId = data.plyId
            
            if rewardValue > 100 or rewardValue < 0 then
                Notify(Config.Lang.wrongReward1)
                cb(false)
                return
            end
            
            Functions.TriggerServerCallback(
                "gta5vn_miner:CheckThisReward",
                function(isValid)
                    if isValid then
                        cb(true)
                    else
                        cb(false)
                        Notify(Config.Lang.wrongReward2)
                    end
                end,
                rewardValue,
                playerId
            )
        end)
    else
        SendNUIMessage({
            action = "hideManageRewards"
        })
    end
    
    elevator = CreateNewElevator()
    TriggerEvent("gta5vn_miner:UpdateWalls")
    
    local forceExitPoints = {
        vector3(2410.42, 1591.86, -32.68),
        vector3(2417.86, 1531.65, -32.75),
        vector3(2402.12, 1592.73, -32.75),
        vector3(2394.51, 1592.07, -32.75),
        vector3(2336.03, 1535.63, -32.75),
        vector3(2336.01, 1527.9, -32.75),
        vector3(2394.33, 1471.67, -32.75),
        vector3(2402.78, 1472.59, -32.75),
        vector3(2410.8, 1472.36, -32.75),
        vector3(2427.75, 1531.9, 39.97)
    }
    
    CreateThread(function()
        while true do
            local sleep = 1000
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            for _, exitPoint in pairs(forceExitPoints) do
                local distance = #(playerCoords - exitPoint)
                
                if not OnDuty and distance < 30.0 then
                    sleep = 0
                    DrawMarker(
                        42,
                        exitPoint.x,
                        exitPoint.y,
                        exitPoint.z + 1.5,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        3.0, 3.0, 3.0,
                        Config.MarkerSettings.UnActive.r,
                        Config.MarkerSettings.UnActive.g,
                        Config.MarkerSettings.UnActive.b,
                        Config.MarkerSettings.UnActive.a,
                        false,
                        true,
                        2,
                        false,
                        nil,
                        nil,
                        false
                    )
                    
                    if distance < 3.0 then
                        ShowHelpNotification(Config.Lang.forceExit)
                        
                        if IsControlJustReleased(0, 38) then
                            SetEntityCoords(playerPed, 2432.08, 1531.85, 39.89, true, false, false, false)
                            SetEntityHeading(playerPed, 272.08)
                        end
                    end
                end
            end
            
            Wait(sleep)
        end
    end)
    
    CreateThread(function()
        local scenariosDisabled = false
        
        while true do
            local allObjects = GetGamePool("CObject")
            
            if allObjects ~= nil then
                for _, obj in pairs(allObjects) do
                    local model = GetEntityModel(obj)
                    
                    if model == 1885822738 then
                        if not IsEntityAttachedToAnyPed(obj) then
                            DeleteObject(obj)
                            SetEntityCoords(obj, 0.0, 0.0, 0.0, false, false, false, false)
                        end
                    end
                end
            end
            
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - Config.DeadCoords)
            
            if distance < 500.0 then
                SetScenarioTypeEnabled("WORLD_VEHICLE_DRIVE_SOLO", false)
                SetScenarioTypeEnabled("WORLD_HUMAN_SMOKING", false)
                SetScenarioTypeEnabled("WORLD_HUMAN_HANG_OUT_STREET", false)
                SetScenarioTypeEnabled("WORLD_VEHICLE_DRIVE_PASSENGERS", false)
                SetScenarioTypeEnabled("DRIVE", false)
                SetScenarioTypeEnabled("WORLD_RABBIT_EATING", false)
                SetScenarioTypeEnabled("WORLD_DEER_GRAZING", false)
                SetScenarioTypeEnabled("WORLD_HUMAN_STAND_IMPATIENT", false)
                SetScenarioTypeEnabled("WORLD_VEHICLE_EMPTY", false)
                SetScenarioTypeEnabled("WORLD_HUMAN_STAND_MOBILE", false)
                SetScenarioTypeEnabled("WORLD_HUMAN_DRINKING", false)
                scenariosDisabled = true
            elseif scenariosDisabled then
                SetScenarioTypeEnabled("WORLD_VEHICLE_DRIVE_SOLO", true)
                SetScenarioTypeEnabled("WORLD_HUMAN_SMOKING", true)
                SetScenarioTypeEnabled("WORLD_HUMAN_HANG_OUT_STREET", true)
                SetScenarioTypeEnabled("WORLD_VEHICLE_DRIVE_PASSENGERS", true)
                SetScenarioTypeEnabled("DRIVE", true)
                SetScenarioTypeEnabled("WORLD_RABBIT_EATING", true)
                SetScenarioTypeEnabled("WORLD_DEER_GRAZING", true)
                SetScenarioTypeEnabled("WORLD_HUMAN_STAND_IMPATIENT", true)
                SetScenarioTypeEnabled("WORLD_VEHICLE_EMPTY", true)
                SetScenarioTypeEnabled("WORLD_HUMAN_STAND_MOBILE", true)
                SetScenarioTypeEnabled("WORLD_HUMAN_DRINKING", true)
                scenariosDisabled = false
            end
            
            Wait(500)
        end
    end)
    
    Functions.TriggerServerCallback("gta5vn_miner:DownloadTakenSeats", function(takenSeats)
        for seatId in pairs(takenSeats) do
            Config.Restaurant.objects[seatId].taken = true
        end
    end)
    
    for objId, objData in pairs(Config.Restaurant.objects) do
        Functions.SpawnObject(
            objData.model,
            function(obj)
                objData.obj = obj
                FreezeEntityPosition(obj, true)
                SetEntityRotation(obj, objData.rotation.x, objData.rotation.y, objData.rotation.z, 0, false)
            end,
            objData.coordinates,
            false,
            true
        )
    end
end)

RegisterNUICallback("tutorialClosed", function()
    SetNuiFocus(false, false)
    tutorialShowing = false
    currentTutorialName = ""
end)

RegisterNetEvent("gta5vn_miner:UpdateHostPercentages")
AddEventHandler("gta5vn_miner:UpdateHostPercentages", function(percentages)
    SendNUIMessage({
        action = "updateHostRewards",
        value = percentages
    })
end)

RegisterNetEvent("gta5vn_miner:SetMyReward")
AddEventHandler("gta5vn_miner:SetMyReward", function(reward)
    SendNUIMessage({
        action = "updateMyReward",
        reward = reward
    })
end)

RegisterNUICallback("menuClosed", function()
    menuOpen = false
    SetNuiFocus(false, false)
end)

RegisterNUICallback("dontShowTutorialAgain", function(data, cb)
    SetResourceKvpInt("17mov_Tutorials:" .. currentTutorialName, 1)
end)

RegisterNetEvent("gta5vn_miner:clearMyLobby")
AddEventHandler("gta5vn_miner:clearMyLobby", function()
    lobbyMembers = {}
    
    Functions.TriggerServerCallback("gta5vn_miner:init", function(playerInfo)
        SendNUIMessage({
            action = "Init",
            name = playerInfo.name,
            myId = playerInfo.source
        })
        scriptInitialized = true
    end)
end)

RegisterNetEvent("gta5vn_miner:RefreshMugs")
AddEventHandler("gta5vn_miner:RefreshMugs", function(members, isUpdate)
    while not scriptInitialized do
        Wait(100)
    end
    
    for _, member in pairs(members) do
        SendNUIMessage({
            action = "DeleteNearbyPlayer",
            id = member.id
        })
        
        if lobbyMembers[member.id] == nil then
            if myServerId == member.id then
                lobbyMembers[member.id] = {
                    name = member.name,
                    id = member.id,
                    isHost = member.isHost,
                    rewardPercent = member.rewardPercent,
                    itsMe = true
                }
            else
                lobbyMembers[member.id] = {
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
                showQuitBtn = lobbyMembers[member.id].itsMe
            })
        end
    end
    
    local memberCount = 0
    for memberId, memberData in pairs(lobbyMembers) do
        local stillInLobby = false
        
        for _, member in pairs(members) do
            if member.id == memberId then
                stillInLobby = true
                break
            end
        end
        
        if not stillInLobby then
            lobbyMembers[memberId] = nil
            SendNUIMessage({
                action = "DeletePlayer",
                id = memberId
            })
        else
            memberCount = memberCount + 1
        end
    end
    
    if memberCount == 1 then
        Functions.TriggerServerCallback("gta5vn_miner:init", function(playerInfo)
            SendNUIMessage({
                action = "Init",
                name = playerInfo.name,
                myId = playerInfo.source
            })
            scriptInitialized = true
        end)
    end
    
    Functions.TriggerServerCallback("gta5vn_miner:IfPlayerOwnsTeam", function(isHost)
        SendNUIMessage({
            action = "ToggleHostHUD",
            boolean = isHost
        })
    end)
end)

local markersDisabled = false

function StartMarkers(jobData)
    if markersDisabled then
        return
    end
    
    if Config.RequiredJob ~= "none" then
        if jobData.job.name ~= Config.RequiredJob then
            markersDisabled = false
            return
        end
    end
    
    markersDisabled = true
    
    if Config.UseTarget then
        Config.Locations2 = {}
        SpawnPeds()
        
        while markersDisabled do
            Wait(0)
            
            local playerCoords = GetEntityCoords(PlayerPedId())
            local isInMarker = false
            local hasExited = false
            local letSleep = true
            local currentStation = nil
            local currentPart = nil
            local currentIterator = nil
            
            if Config.RequiredJob ~= "none" and jobData.job.name == Config.RequiredJob or Config.RequiredJob == "none" then
                for locationName, locationData in pairs(Config.Locations2) do
                    if not locationData.turnedOff and (OnDuty or locationData.type ~= "duty") then
                        for coordIndex, coords in pairs(locationData.Coords) do
                            local distance = #(playerCoords - coords)
                            
                            if distance < 125 then
                                if distance > locationData.scale.x then
                                    if locationName == "FinishJobBoat" then
                                        DrawMarker(
                                            35,
                                            coords.x,
                                            coords.y,
                                            coords.z + 3.5,
                                            0.0, 0.0, 0.0,
                                            0.0, 0.0, 0.0,
                                            locationData.scale.x,
                                            locationData.scale.y,
                                            locationData.scale.z,
                                            Config.MarkerSettings.UnActive.r,
                                            Config.MarkerSettings.UnActive.g,
                                            Config.MarkerSettings.UnActive.b,
                                            Config.MarkerSettings.UnActive.a,
                                            false,
                                            true,
                                            2,
                                            false,
                                            nil,
                                            nil,
                                            false
                                        )
                                    end
                                    
                                    DrawMarker(
                                        6,
                                        coords.x,
                                        coords.y,
                                        coords.z - 1,
                                        0.0, 0.0, 0.0,
                                        -90.0, 0.0, 0.0,
                                        locationData.scale.x,
                                        locationData.scale.y,
                                        locationData.scale.z,
                                        Config.MarkerSettings.UnActive.r,
                                        Config.MarkerSettings.UnActive.g,
                                        Config.MarkerSettings.UnActive.b,
                                        Config.MarkerSettings.UnActive.a,
                                        false,
                                        false,
                                        2,
                                        false,
                                        nil,
                                        nil,
                                        false
                                    )
                                    
                                    letSleep = false
                                else
                                    letSleep = false
                                    
                                    if locationName == "FinishJobBoat" then
                                        DrawMarker(
                                            35,
                                            coords.x,
                                            coords.y,
                                            coords.z + 3.5,
                                            0.0, 0.0, 0.0,
                                            0.0, 0.0, 0.0,
                                            locationData.scale.x,
                                            locationData.scale.y,
                                            locationData.scale.z,
                                            Config.MarkerSettings.Active.r,
                                            Config.MarkerSettings.Active.g,
                                            Config.MarkerSettings.Active.b,
                                            Config.MarkerSettings.Active.a,
                                            false,
                                            true,
                                            2,
                                            false,
                                            nil,
                                            nil,
                                            false
                                        )
                                    end
                                    
                                    DrawMarker(
                                        6,
                                        coords.x,
                                        coords.y,
                                        coords.z - 1,
                                        0.0, 0.0, 0.0,
                                        -90.0, 0.0, 0.0,
                                        locationData.scale.x,
                                        locationData.scale.y,
                                        locationData.scale.z,
                                        Config.MarkerSettings.Active.r,
                                        Config.MarkerSettings.Active.g,
                                        Config.MarkerSettings.Active.b,
                                        Config.MarkerSettings.Active.a,
                                        false,
                                        true,
                                        2,
                                        false,
                                        nil,
                                        nil,
                                        false
                                    )
                                    
                                    isInMarker = true
                                    currentStation = locationName
                                    currentPart = locationName
                                    currentIterator = coordIndex
                                end
                            end
                        end
                    end
                end
                
                if isInMarker and not HasAlreadyEnteredMarker or isInMarker and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentIterator) then
                    if LastStation and LastPart and LastPartNum and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentIterator) then
                        TriggerEvent("gta5vn_miner:ExitedMarker", LastStation, LastPart, LastPartNum)
                        hasExited = true
                    end
                    
                    HasAlreadyEnteredMarker = true
                    LastStation = currentStation
                    LastPart = currentPart
                    LastPartNum = currentIterator
                    TriggerEvent("gta5vn_miner:EnteredMarker", currentPart)
                end
                
                if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
                    HasAlreadyEnteredMarker = false
                    TriggerEvent("gta5vn_miner:ExitedMarker", LastStation, LastPart, LastPartNum)
                end
                
                if letSleep then
                    Wait(500)
                end
            end
        end
        
        DeleteEntity(spawnedPed)
    else
        while markersDisabled do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local isInMarker = false
            local hasExited = false
            local letSleep = true
            local currentStation = nil
            local currentPart = nil
            local currentIterator = nil
            
            if Config.RequiredJob ~= "none" and jobData.job.name == Config.RequiredJob or Config.RequiredJob == "none" then
                for locationName, locationData in pairs(Config.Locations) do
                    if not locationData.turnedOff then
                        for coordIndex, coords in pairs(locationData.Coords) do
                            local distance = #(playerCoords - coords)
                            
                            if distance < 125 then
                                if distance > locationData.scale.x then
                                    DrawMarker(
                                        6,
                                        coords.x,
                                        coords.y,
                                        coords.z - 1,
                                        0.0, 0.0, 0.0,
                                        -90.0, 0.0, 0.0,
                                        locationData.scale.x,
                                        locationData.scale.y,
                                        locationData.scale.z,
                                        Config.MarkerSettings.UnActive.r,
                                        Config.MarkerSettings.UnActive.g,
                                        Config.MarkerSettings.UnActive.b,
                                        Config.MarkerSettings.UnActive.a,
                                        false,
                                        false,
                                        2,
                                        false,
                                        nil,
                                        nil,
                                        false
                                    )
                                    letSleep = false
                                else
                                    letSleep = false
                                    
                                    DrawMarker(
                                        6,
                                        coords.x,
                                        coords.y,
                                        coords.z - 1,
                                        0.0, 0.0, 0.0,
                                        -90.0, 0.0, 0.0,
                                        locationData.scale.x,
                                        locationData.scale.y,
                                        locationData.scale.z,
                                        Config.MarkerSettings.Active.r,
                                        Config.MarkerSettings.Active.g,
                                        Config.MarkerSettings.Active.b,
                                        Config.MarkerSettings.Active.a,
                                        false,
                                        false,
                                        2,
                                        false,
                                        nil,
                                        nil,
                                        false
                                    )
                                    
                                    isInMarker = true
                                    currentStation = locationName
                                    currentPart = locationName
                                    currentIterator = coordIndex
                                end
                            end
                        end
                    end
                end
                
                if isInMarker and not HasAlreadyEnteredMarker or isInMarker and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentIterator) then
                    if LastStation and LastPart and LastPartNum and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentIterator) then
                        TriggerEvent("gta5vn_miner:ExitedMarker", LastStation, LastPart, LastPartNum)
                        hasExited = true
                    end
                    
                    HasAlreadyEnteredMarker = true
                    LastStation = currentStation
                    LastPart = currentPart
                    LastPartNum = currentIterator
                    TriggerEvent("gta5vn_miner:EnteredMarker", currentPart)
                end
                
                if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
                    HasAlreadyEnteredMarker = false
                    TriggerEvent("gta5vn_miner:ExitedMarker", LastStation, LastPart, LastPartNum)
                end
                
                if letSleep then
                    Wait(500)
                end
            end
            
            Wait(0)
        end
    end
end

Citizen.CreateThread(function()
    PlayerData = GetPlayerData()
    
    while PlayerData == nil or PlayerData.job == nil do
        PlayerData = GetPlayerData()
        Wait(1000)
    end
    
    if Config.RestrictBlipToRequiredJob and Config.RequiredJob ~= PlayerData.job.name or not Config.RestrictBlipToRequiredJob then
        MakeBlip()
    end
    
    Wait(5000)
    StartMarkers(PlayerData)
end)

local blipCreated = false

function MakeBlip()
    if blipCreated then
        return
    end
    
    blipCreated = true
    
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
end

function DeleteBlip()
    blipCreated = false
    
    for _, blipData in pairs(Config.Blips) do
        RemoveBlip(blipData.blip)
        blipData.blip = nil
    end
end

local scriptLoaded = false

function InitalizeScript(skipWait)
    if scriptLoaded then
        return
    end
    
    while not nuiLoaded do
        Wait(100)
    end
    
    PlayerData = GetPlayerData()
    
    if not skipWait then
        Wait(5500)
    end
    
    scriptLoaded = true
    
    if Config.RequiredJob ~= "none" and Config.RestrictBlipToRequiredJob then
        while PlayerData == nil or PlayerData.job == nil do
            PlayerData = GetPlayerData()
            Wait(100)
        end
        
        if PlayerData.job.name == Config.RequiredJob or not Config.RestrictBlipToRequiredJob then
            MakeBlip()
        end
    else
        MakeBlip()
    end
    
    Wait(3500)
    
    Functions.TriggerServerCallback("gta5vn_miner:init", function(playerInfo)
        SendNUIMessage({
            action = "Init",
            name = playerInfo.name,
            myId = playerInfo.source
        })
        scriptInitialized = true
    end)
end

RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    InitalizeScript()
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function()
    InitalizeScript()
end)

RegisterNetEvent("QBCore:Client:OnJobUpdate")
AddEventHandler("QBCore:Client:OnJobUpdate", function(jobData)
    PlayerData = GetPlayerData()
    
    if Config.RequiredJob ~= "none" and Config.RestrictBlipToRequiredJob and PlayerData.job.name == Config.RequiredJob or not Config.RestrictBlipToRequiredJob then
        MakeBlip()
    else
        DeleteBlip()
    end
    
    if Config.RequiredJob ~= "none" and PlayerData.job.name == Config.RequiredJob or Config.RequiredJob == "none" then
        StartMarkers(PlayerData)
    else
        markersDisabled = false
    end
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(jobData)
    while PlayerData == nil or PlayerData.job == nil do
        PlayerData = GetPlayerData()
        Wait(1000)
    end
    
    PlayerData.job = jobData
    
    if Config.RequiredJob ~= "none" and Config.RestrictBlipToRequiredJob and PlayerData.job.name == Config.RequiredJob or not Config.RestrictBlipToRequiredJob then
        MakeBlip()
    else
        DeleteBlip()
    end
    
    if Config.RequiredJob ~= "none" and PlayerData.job.name == Config.RequiredJob or Config.RequiredJob == "none" then
        StartMarkers(PlayerData)
    else
        markersDisabled = false
    end
end)

AddEventHandler("gta5vn_miner:EnteredMarker", function(part)
    local displayTime = 0
    CurrentAction = Config.Locations[part].CurrentAction
    CurrentActionMsg = Config.Locations[part].CurrentActionMsg
    CurrentActionStation = part
    
    while displayTime < 500 do
        Wait(0)
        ShowHelpNotification(CurrentActionMsg)
        displayTime = displayTime + 1
    end
end)

AddEventHandler("gta5vn_miner:ExitedMarker", function(station)
    CurrentAction = nil
    CurrentActionMsg = nil
    CurrentActionStation = nil
end)

RegisterCommand("+17MovMinerJobStartMarkerAction", function()
end, false)

RegisterCommand("-17MovMinerJobStartMarkerAction", function()
    if CurrentAction ~= nil then
        if CurrentAction == "open_dutyToggle" then
            OpenDutyMenu()
        end
    end
end, false)

TriggerEvent("chat:removeSuggestion", "/+17MovMinerJobStartMarkerAction")
TriggerEvent("chat:removeSuggestion", "/-17MovMinerJobStartMarkerAction")

RegisterKeyMapping("+17MovMinerJobStartMarkerAction", Config.Lang.keybind, "keyboard", "E")

local nearbyPlayersCache = {}

-- Trong client.lua, thay TOÀN BỘ function OpenDutyMenu bằng đoạn này:

function OpenDutyMenu()
    if not scriptLoaded then
        InitalizeScript(true)
        return print("SCRIPT NOT READY - WAIT UNTIL SCRIPT PROPERLY LOAD")
    end

    if not scriptInitialized then
        Functions.TriggerServerCallback("gta5vn_miner:init", function(playerInfo)
            SendNUIMessage({
                action = "Init",
                name = playerInfo.name,
                myId = playerInfo.source
            })
            scriptInitialized = true
        end)
        return print("SCRIPT NOT READY - WAIT UNTIL SCRIPT PROPERLY LOAD")
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "OpenWorkMenu"
    })

    menuOpen = true
    local nearbyTabVisible = false
    local nearbyListIsRefreshing = false

    CreateThread(function()
        while menuOpen do
            local activePlayers = GetActivePlayers()
            local myCoords = GetEntityCoords(PlayerPedId())
            local nearbyPlayerIds = {}
            local foundNearbyPlayers = false

            for _, playerId in pairs(activePlayers) do
                if PlayerId() ~= playerId then
                    local playerPed = GetPlayerPed(playerId)
                    local distance = #(myCoords - GetEntityCoords(playerPed))

                    if distance < 10.0 then
                        table.insert(nearbyPlayerIds, GetPlayerServerId(playerId))
                    end
                end
            end

            if #nearbyPlayerIds > 0 then
                Functions.TriggerServerCallback("gta5vn_miner:GetPlayersNames", function(playersData)
                    for _, playerData in pairs(playersData) do
                        if lobbyMembers[playerData.id] == nil then
                            foundNearbyPlayers = true

                            if nearbyPlayersCache[playerData.id] == nil then
                                nearbyPlayersCache[playerData.id] = {
                                    id = playerData.id,
                                    name = playerData.name
                                }

                                CreateThread(function()
                                    while not nearbyTabVisible do
                                        Wait(10)
                                    end

                                    SendNUIMessage({
                                        action = "addNewNearbyPlayer",
                                        id = playerData.id,
                                        name = playerData.name
                                    })
                                end)
                            end
                        else
                            playersData[_] = nil
                        end
                    end

                    for cachedId, cachedData in pairs(nearbyPlayersCache) do
                        local stillNearby = false
                        local playerId = cachedData.id

                        for _, playerData in pairs(playersData) do
                            if playerData and playerData.id == playerId then
                                stillNearby = true
                                break
                            end
                        end

                        if not stillNearby then
                            nearbyPlayersCache[playerId] = nil
                            nearbyListIsRefreshing = true

                            SendNUIMessage({
                                action = "DeleteNearbyPlayer",
                                id = cachedData.id
                            })

                            CreateThread(function()
                                Wait(250)
                                nearbyListIsRefreshing = false
                            end)
                        end
                    end

                    if not foundNearbyPlayers and nearbyTabVisible then
                        CreateThread(function()
                            while nearbyListIsRefreshing do
                                Wait(10)
                            end

                            SendNUIMessage({
                                action = "hideNearbyPlayersTab"
                            })

                            CreateThread(function()
                                Wait(250)
                                nearbyTabVisible = false
                            end)
                        end)
                    elseif foundNearbyPlayers and not nearbyTabVisible then
                        SendNUIMessage({
                            action = "showNearbyPlayersTab"
                        })

                        CreateThread(function()
                            Wait(250)
                            nearbyTabVisible = true
                        end)
                    end
                end, nearbyPlayerIds)
            else
                if nearbyTabVisible then
                    for cachedId, _ in pairs(nearbyPlayersCache) do
                        SendNUIMessage({
                            action = "DeleteNearbyPlayer",
                            id = cachedId
                        })
                        nearbyPlayersCache[cachedId] = nil
                    end

                    SendNUIMessage({
                        action = "hideNearbyPlayersTab"
                    })
                    nearbyTabVisible = false
                end
            end

            Wait(2500)
        end
    end)
end

RegisterNUICallback("changeClothes", function(data)
    if data.type == "work" then
        haveWorkClothes = true
        ChangeClothes("work")
    else
        haveWorkClothes = false
        ChangeClothes("citizen")
    end
end)

RegisterNUICallback("requestReacted", function(data)
    SetNuiFocus(false, false)
    local accepted = data.boolean
    TriggerServerEvent("gta5vn_miner:ClientReactRequest", accepted)
end)

RegisterNUICallback("sendRequest", function(data)
    if OnDuty then
        return Notify(Config.Lang.cantInvite)
    end
    
    TriggerServerEvent("gta5vn_miner:SendRequestToClient_sv", tonumber(data.id))
end)

RegisterNUICallback("kickPlayerFromLobby", function(data)
    local playerId = tonumber(data.id)
    Notify(string.format(Config.Lang.kicked, lobbyMembers[playerId].name))
    TriggerServerEvent("gta5vn_miner:KickPlayerFromLobby", playerId, true)
end)

RegisterNUICallback("focusOff", function(data)
    SetNuiFocus(false, false)
end)

RegisterNUICallback("notify", function(data)
    Notify(data.msg)
end)

RegisterNetEvent("gta5vn_miner:SendRequestToClient_cl")
AddEventHandler("gta5vn_miner:SendRequestToClient_cl", function(senderName, senderId)
    SendNUIMessage({
        action = "ShowInviteBox",
        name = senderName
    })
    SetNuiFocus(true, true)
end)

RegisterNUICallback("startJob", function(data)
    if not OnDuty then
        TriggerServerEvent("gta5vn_miner:StartJob_sv")
    else
        TriggerServerEvent("gta5vn_miner:endJob_sv", true, true)
    end
end)

RegisterNUICallback("leaveLobby", function(data)
    if OnDuty then
        return Notify(Config.Lang.cantLeaveLobby)
    end
    
    local playerId = tonumber(data.id)
    TriggerServerEvent("gta5vn_miner:KickPlayerFromLobby", playerId, false, GetPlayerServerId(PlayerId()))
    Notify(Config.Lang.quit)
end)

function AddBlip17(label, sprite, coords, color)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    
    if sprite ~= nil then
        SetBlipSprite(blip, sprite)
    end
    
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.6)
    SetBlipColour(blip, color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label)
    EndTextCommandSetBlipName(blip)
    
    return blip
end

RegisterNUICallback("tutorialClosed", function()
    tutorialShowing = false
    DisableControlAction(0, 30, false)
    DisableControlAction(0, 31, false)
    DisableControlAction(0, 32, false)
    DisableControlAction(0, 33, false)
    DisableControlAction(0, 34, false)
    DisableControlAction(0, 35, false)
end)

RegisterNetEvent("gta5vn_miner:StartJob_cl")
AddEventHandler("gta5vn_miner:StartJob_cl", function(teamData, isLeader)
    OnDuty = true
    inJobArea = true
    isBack = false
    
    SendNUIMessage({
        action = "replaceStartBtn"
    })
    
    CreateThread(function()
        if not haveWorkClothes and Config.RequireWorkClothes then
            haveWorkClothes = true
            ChangeClothes("work")
        end
    end)
    
    if not isBack then
        local tutorialKey = GetResourceKvpInt("17mov_Tutorials:" .. Config.Lang.startingTutorial)
        
        if tutorialKey == 0 then
            currentTutorialName = Config.Lang.startingTutorial
            
            SendNUIMessage({
                action = "showTutorial",
                customText = Config.Lang.startingTutorial
            })
            
            tutorialShowing = true
            
            CreateThread(function()
                while tutorialShowing do
                    Wait(0)
                    DisableControlAction(0, 30, true)
                    DisableControlAction(0, 31, true)
                    DisableControlAction(0, 32, true)
                    DisableControlAction(0, 33, true)
                    DisableControlAction(0, 34, true)
                    DisableControlAction(0, 35, true)
                end
            end)
            
            SetNuiFocus(true, true)
        end
    end
    
    SendNUIMessage({
        action = "updateCounter",
        value = 0
    })
    
    SendNUIMessage({
        action = "showCounter"
    })
    
    CreateThread(function()
        while OnDuty do
            local sleep = 1000
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local gearCoords = Config.GrabGearCoordinates
            local distance = #(playerCoords - gearCoords)
            
            if distance < 5.0 then
                sleep = 0
                DrawText3Ds(
                    gearCoords.x,
                    gearCoords.y,
                    gearCoords.z,
                    HaveGear and Config.Lang.putGear or Config.Lang.grabGear
                )
                
                if IsControlJustReleased(0, 38) and distance < 2.0 then
                    local newGearStatus = not HaveGear
                    ToggleGear()
                    TriggerServerEvent("gta5vn_miner:GearStatus", newGearStatus, ObjToNet(headlampObject))
                end
            end
            
            Wait(sleep)
        end
    end)
    
    CreateThread(function()
        while OnDuty do
            local sleep = 1000
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local clothesCoords = Config.ChangeClothesCoordinates
            local distance = #(playerCoords - clothesCoords)
            
            if distance < 5.0 then
                sleep = 0
                DrawText3Ds(
                    clothesCoords.x,
                    clothesCoords.y,
                    clothesCoords.z,
                    HaveClothes and Config.Lang.civClothes or Config.Lang.workClothes
                )
                
                if IsControlJustReleased(0, 38) and distance < 2.0 then
                    local newClothesStatus = not HaveClothes
                    ChangeClothes(HaveClothes and "civ" or "work")
                    TriggerServerEvent("gta5vn_miner:ClothesStatus", newClothesStatus)
                end
            end
            
            Wait(sleep)
        end
    end)
    
    CreateThread(function()
        if Config.Restaurant.enable then
            while inJobArea do
                local sleep = 1000
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                
                if not DoesEntityExist(foodTrayObject) then
                    local distance = #(playerCoords - Config.Restaurant.coordinates)
                    
                    if distance < 10.0 then
                        sleep = 0
                        DrawText3Ds(
                            Config.Restaurant.coordinates.x,
                            Config.Restaurant.coordinates.y,
                            Config.Restaurant.coordinates.z,
                            Config.Lang.takeFood
                        )
                        
                        if distance < 2.0 and IsControlJustReleased(0, 38) then
                            TakeFoodTray()
                        end
                    end
                else
                    for objId, objData in pairs(Config.Restaurant.objects) do
                        if not objData.taken and objData.type == "chair" then
                            local distance = #(playerCoords - objData.coordinates)
                            
                            if distance < 5.0 then
                                sleep = 0
                                DrawText3Ds(
                                    objData.coordinates.x,
                                    objData.coordinates.y,
                                    objData.coordinates.z + 1.0,
                                    Config.Lang.sitChair
                                )
                                
                                if distance < 2.0 and IsControlJustReleased(0, 38) then
                                    SitOnChair(objData, objId)
                                end
                            end
                        end
                    end
                end
                
                Wait(sleep)
            end
        end
    end)
    
    CreateThread(function()
        while OnDuty do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local elevatorCoords = GetEntityCoords(elevator.elevator)
            local distance = #(playerCoords - elevatorCoords)
            local sleep = 1000
            
            if distance < 50.0 and not elevator.beingAnimated and not elevator.DoorsBeingAnimated then
                local isInside = elevator.isInside(playerPed)
                
                if not elevator.frontDoorsOpened and not isInside and elevator.currentState == "up" then
                    elevator.GlowButton("btnupBtn")
                    local buttonDist = #(playerCoords - GetEntityCoords(elevator.btnupBtn))
                    
                    if buttonDist < 3.0 then
                        sleep = 0
                        ShowHelpNotification(Config.Lang.openDoors)
                        
                        if IsControlJustReleased(0, 38) then
                            Functions.TriggerServerCallback("gta5vn_miner:CheckTeamIsReady", function(isReady)
                                if isReady or Config.RequireGear == false then
                                    TriggerServerEvent("gta5vn_miner:ElevatorOpenDoors")
                                else
                                    Notify(Config.Lang.noClothes)
                                end
                            end)
                        end
                    end
                elseif elevator.frontDoorsOpened and isInside and elevator.currentState == "up" then
                    elevator.GlowButton("btninsideBtn")
                    local buttonDist = #(playerCoords - GetEntityCoords(elevator.btninsideBtn))
                    
                    if buttonDist < 3.0 then
                        sleep = 0
                        ShowHelpNotification(Config.Lang.goDown)
                        
                        if IsControlJustReleased(0, 38) then
                            Functions.TriggerServerCallback("gta5vn_miner:GetTeamCoordinates", function(teamCoords)
                                if type(teamCoords) == "table" then
                                    local allInside = true
                                    
                                    for _, coords in pairs(teamCoords) do
                                        if not elevator.isInside(nil, coords) then
                                            Notify(Config.Lang.somebodyNotInElevator)
                                            allInside = false
                                            break
                                        end
                                    end
                                    
                                    if allInside then
                                        TriggerServerEvent("gta5vn_miner:ElevatorGoDown")
                                    end
                                else
                                    Notify(Config.Lang.noClothes)
                                end
                            end)
                        end
                    end
                elseif distance < 10.0 and elevator.backDoorsOpened and elevator.currentState == "down" then
                    elevator.GlowButton("btninsideBtn")
                    local buttonDist = #(playerCoords - GetEntityCoords(elevator.btninsideBtn))
                    
                    if buttonDist < 3.0 then
                        sleep = 0
                        ShowHelpNotification(Config.Lang.goBack)
                        
                        if IsControlJustReleased(0, 38) and not false then
                            
                            Functions.TriggerServerCallback("gta5vn_miner:IfPlayerIsHost", function(isHost)
                                if isHost then
                                    Functions.TriggerServerCallback("gta5vn_miner:GetTeamCoordinates", function(teamCoords)
                                        local allInside = true
                                        
                                        for _, coords in pairs(teamCoords) do
                                            if not elevator.isInside(nil, coords) then
                                                Notify(Config.Lang.somebodyNotInElevator)
                                                allInside = false
                                                break
                                            end
                                        end
                                        
                                        
                                        if allInside then
                                            local allProps = Functions.TableJoin(propsObjects.rails, propsObjects.lights, propsObjects.supports)
                                            
                                            if #allProps > 0 and Config.Events.gas.running == false then
                                                SendNUIMessage({
                                                    action = "openWarning"
                                                })
                                                SetNuiFocus(true, true)
                                            else
                                                return TriggerServerEvent("gta5vn_miner:ElevatorBack")
                                            end
                                        end
                                    end, true)
                                else
                                    Notify(Config.Lang.no_permission)
                                end
                            end)
                        end
                    end
                else
                    elevator.DisableBtnsGlow()
                end
            else
                elevator.DisableBtnsGlow()
            end
            
            Wait(sleep)
        end
    end)
    
    CreateThread(function()
        while OnDuty do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local allProps = Functions.TableJoin(propsObjects.rails, propsObjects.lights, propsObjects.supports)
            local sleep = 1000
            
            if propsObjectsTable ~= nil then
                for propType, propList in pairs(propsObjectsTable) do
                    for i = 1, #propList do
                        SetEntityDrawOutline(propList[i], false)
                    end
                end
            end
            
            if carriedObject then
                local carriedModel = GetEntityModel(carriedObject)
                
                if propsObjectsTable ~= nil then
                    for propType, propList in pairs(propsObjectsTable) do
                        local lastProp = propList[#propList]
                        local propConfig = Config.Props[propType]
                        local targetModel = nil
                        local targetCoords = nil
                        local distance = nil
                        
                        if lastProp and DoesEntityExist(lastProp) then
                            targetModel = GetEntityModel(lastProp)
                            targetCoords = GetEntityCoords(lastProp)
                        else
                            targetModel = propConfig.model
                            
                            if propConfig.stackCoordinates then
                                targetCoords = propConfig.stackCoordinates[1]
                            else
                                targetCoords = propConfig.stackCoords
                            end
                        end
                        
                        local distVec = vec3(playerCoords.x, playerCoords.y, playerCoords.z) - vec3(targetCoords.x, targetCoords.y, targetCoords.z)
                        distance = #distVec
                        
                        if (carriedModel == targetModel or carriedModel == -478635748 and targetModel == -2021346006) and distance < 5 then
                            if math.abs(playerCoords.z - targetCoords.z) < 20 then
                                sleep = 0
                                
                                if propConfig.stackCoordinates ~= nil and #propList < #propConfig.stackCoordinates or propConfig.stackCoordinates == nil then
                                    if distance < propConfig.interactionDistance then
                                        ShowHelpNotification(Config.Lang.placePropBack)
                                        
                                        if IsControlJustReleased(0, 38) then
                                            local newCoords = nil
                                            
                                            if propConfig.stackCoords then
                                                newCoords = vec3(
                                                    targetCoords.x + propConfig.stackOffest.x,
                                                    targetCoords.y + propConfig.stackOffest.y,
                                                    targetCoords.z + propConfig.stackOffest.z
                                                )
                                            else
                                                newCoords = vec3(lastStackCoords.x, lastStackCoords.y, lastStackCoords.z)
                                            end
                                            
                                            local rotation = propConfig.stackRotation
                                            
                                            TriggerServerEvent("17mov_miner:MagazinePropPutBack", carriedModel, newCoords, rotation, propType)
                                            DeleteEntity(carriedObject)
                                            carriedObject = nil
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                for i = 1, #allProps do
                    if carriedObject then
                        local propModel = GetEntityModel(allProps[i])
                        
                        if carriedModel ~= propModel and not (carriedModel == -478635748 and propModel == -2021346006) and not (carriedModel == -653882587 and propModel == -915189888) then
                            local propCoords = GetEntityCoords(allProps[i])
                            
                            if math.abs(playerCoords.z - propCoords.z) < 10 then
                                sleep = 0
                                local distance2D = #(vec2(playerCoords.x, playerCoords.y) - vec2(propCoords.x, propCoords.y))
                                
                                if distance2D < 1.5 then
                                    ShowHelpNotification(Config.Lang.placeProp)
                                    
                                    if IsControlJustReleased(0, 38) then
                                        local propCategory = nil
                                        local propIndex = nil
                                        
                                        if magazine[currentMagazineType] ~= nil then
                                            for category, props in pairs(magazine[currentMagazineType]) do
                                                if category == "rails" or category == "lights" then
                                                    for idx, prop in pairs(props) do
                                                        if prop == allProps[i] then
                                                            propCategory = category
                                                            propIndex = idx
                                                        end
                                                    end
                                                elseif category == "supports" then
                                                    for idx, supportProps in pairs(props) do
                                                        for supportPart, supportProp in pairs(supportProps) do
                                                            if supportProp == allProps[i] then
                                                                propCategory = supportPart
                                                                propIndex = idx
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                            
                                            DeleteEntity(carriedObject)
                                            TriggerServerEvent("gta5vn_miner:PlaceProp", propCategory, propIndex)
                                            carriedObject = nil
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            else
                local closestProp = nil
                local closestDistance = 100
                local closestPropType = nil
                
                for i = 1, #allProps do
                    local propModel = GetEntityModel(allProps[i])
                    
                    if propsObjectsTable ~= nil then
                        for propType, propList in pairs(propsObjectsTable) do
                            local lastProp = propList[#propList]
                            
                            if lastProp and DoesEntityExist(lastProp) then
                                local lastPropModel = GetEntityModel(lastProp)
                                local lastPropCoords = GetEntityCoords(lastProp)
                                local distVec = vec3(playerCoords.x, playerCoords.y, playerCoords.z) - vec3(lastPropCoords.x, lastPropCoords.y, lastPropCoords.z)
                                local distance = #distVec
                                
                                if propModel == lastPropModel then
                                    SetEntityDrawOutlineShader(1)
                                    SetEntityDrawOutline(lastProp, true)
                                end
                                
                                if math.abs(playerCoords.z - lastPropCoords.z) < 20 and closestDistance > distance then
                                    closestDistance = distance
                                    closestProp = lastProp
                                    closestPropType = propType
                                end
                            end
                        end
                    end
                end
                
                if closestProp and closestDistance < 5 and closestPropType then
                    local propConfig = Config.Props[closestPropType]
                    sleep = 0
                    
                    if closestDistance < propConfig.interactionDistance then
                        ShowHelpNotification(Config.Lang.pickUp)
                        
                        if IsControlJustReleased(0, 38) then
                            lastStackCoords = GetEntityCoords(closestProp)
                            local myCoords = GetEntityCoords(PlayerPedId())
                            
                            local newObject = CreateObject(
                                closestPropType == "Rails" and -478635748 or Config.Props[closestPropType].model,
                                myCoords.x,
                                myCoords.y,
                                myCoords.z,
                                true,
                                true,
                                true
                            )
                            
                            carriedObject = newObject
                            
                            local boneIndex = GetPedBoneIndex(playerPed, closestPropType == "Rails" and 57005 or 28422)
                            
                            AttachEntityToEntity(
                                carriedObject,
                                playerPed,
                                boneIndex,
                                propConfig.attachToPed.offset.x,
                                propConfig.attachToPed.offset.y,
                                propConfig.attachToPed.offset.z,
                                propConfig.attachToPed.rotation.x,
                                propConfig.attachToPed.rotation.y,
                                propConfig.attachToPed.rotation.z,
                                true,
                                true,
                                false,
                                true,
                                2,
                                true
                            )
                            
                            SetEntityDrawOutline(carriedObject, false)
                            CarringAnim(closestPropType == "Rails")
                            
                            if propsObjectsTable then
                                TriggerServerEvent("17mov_miner:MagazinePropDelete", closestPropType, #propsObjectsTable[closestPropType])
                            end
                        end
                    end
                end
            end
            
            Wait(sleep)
        end
    end)
end)
-- Part 2: Deobfuscated continuation

RegisterNetEvent("17mov_miner:MagazinePropPutBack")
AddEventHandler("17mov_miner:MagazinePropPutBack", function(model, coords, rotation, propType)
  local tempObj
  
  if -478635748 == model then
    model = -2021346006
  end
  
  tempObj = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
  FreezeEntityPosition(tempObj, true)
  SetEntityRotation(tempObj, rotation.x, rotation.y, rotation.z, 0, false)
  SetEntityCoords(tempObj, coords.x, coords.y, coords.z, false, false, false, false)
  
  if 0 ~= tempObj then
    if DoesEntityExist(tempObj) then
      table.insert(propsObjectsTable[propType], tempObj)
      return
    end
  end
  
  Functions.Error("Tried to add tempObj but it doesn't exist. Restarting. ", tempObj)
  Citizen.Wait(10)
  
  if IsModelInCdimage(model) then
    TriggerEvent("17mov_miner:MagazinePropPutBack", model, coords, rotation, propType)
  end
end)

RegisterNetEvent("17mov_miner:MagazinePropDelete")
AddEventHandler("17mov_miner:MagazinePropDelete", function(propType, index)
  DeleteEntity(propsObjectsTable[propType][index])
  
  if nil ~= propsObjectsTable[propType][index] then
    table.remove(propsObjectsTable[propType], index)
  end
end)

RegisterNUICallback("acceptWarning", function()
  return TriggerServerEvent("gta5vn_miner:ElevatorBack", false)
end)

function CarringAnim(isRails)
  CreateThread(function()
    while true do
      if nil == carriedObject then
        break
      end
      
      local ped = PlayerPedId()
      local animDict, animName
      
      if isRails then
        animDict = "rail@anim"
        animName = "rail_anim"
      else
        animDict = "anim@heists@box_carry@"
        animName = "idle"
      end
      
      SetEntityMaxSpeed(ped, 5.0)
      SetCurrentPedWeapon(ped, -1569615261, true)
      DisablePlayerFiring(ped, true)
      
      if not IsEntityPlayingAnim(ped, animDict, animName, 3) then
        Functions.RequestAnimDict(animDict)
        TaskPlayAnim(ped, animDict, animName, 3.5, -8, -1, isRails and 33 or 49, 0, false, false, false)
      end
      
      Wait(10)
    end
    
    local ped = PlayerPedId()
    SetEntityMaxSpeed(ped, -1.0)
    ClearPedSecondaryTask(ped)
  end)
end

RegisterNetEvent("gta5vn_miner:endJob_cl")
AddEventHandler("gta5vn_miner:endJob_cl", function(shouldChangeClothes)
  OnDuty = false
  currentMagazineType = nil
  
  TriggerEvent("gta5vn_miner:StopMinecartSound")
  
  SendNUIMessage({action = "startBtnBackToNormal"})
  SendNUIMessage({action = "hideCounter"})
  
  if shouldChangeClothes then
    if HaveClothes then
      ChangeClothes("citizen")
    end
    
    if HaveGear then
      if DoesEntityExist(headlampObject) then
        ToggleGear()
        DeleteEntity(headlampObject)
      end
    end
  end
  
  Citizen.Wait(10)
  elevator.DisableBtnsGlow()
  
  Citizen.Wait(1200000)
  inJobArea = false
end)

RegisterNetEvent("gta5vn_miner:CheckObjectsToBuild")
AddEventHandler("gta5vn_miner:CheckObjectsToBuild", function(data)
  TriggerEvent("gta5vn_miner:UpdateEntites")
end)

RegisterNetEvent("gta5vn_miner:BuildProp")
AddEventHandler("gta5vn_miner:BuildProp", function(propType, index)
  if "rails" == propType or "lights" == propType then
    magazineData[currentMagazineType][propType][index] = true
  else
    if not magazineData[currentMagazineType].supports[index] then
      magazineData[currentMagazineType].supports[index] = {}
    end
    magazineData[currentMagazineType].supports[index][propType] = true
  end
  
  TriggerEvent("gta5vn_miner:UpdateEntites")
end)

RegisterNetEvent("gta5vn_miner:ShowProp")
AddEventHandler("gta5vn_miner:ShowProp", function(mineshaftId, buildData)
  if nil ~= magazine[mineshaftId] then
    for propType, propsTable in pairs(magazine[mineshaftId]) do
      if "rails" == propType or "lights" == propType then
        for i = 1, #propsTable do
          if buildData[propType][i] then
            SetEntityVisible(propsTable[i], true, true)
          else
            SetEntityVisible(propsTable[i], false, false)
          end
        end
      elseif "minecart" ~= propType and "minecartRock" ~= propType then
        for i = 1, #propsTable do
          for subType, obj in pairs(propsTable[i]) do
            if buildData[propType][i] then
              if buildData[propType][i][subType] then
                SetEntityVisible(obj, true, true)
              end
            else
              SetEntityVisible(obj, false, false)
            end
          end
        end
      end
    end
  end
end)

RegisterNetEvent("gta5vn_miner:DestroyThisMineshaft")
AddEventHandler("gta5vn_miner:DestroyThisMineshaft", function(mineshaftId)
  deleteRecursive(magazine[mineshaftId])
  magazine[mineshaftId] = nil
  magazineData[mineshaftId] = nil
end)

RegisterNetEvent("gta5vn_miner:CreateThisMineshaft")
AddEventHandler("gta5vn_miner:CreateThisMineshaft", function(mineshaftId, startRailIndex)
  local mineshaftConfig = Config.Mineshatfs[mineshaftId]
  local magazineEntry = {
    rails = {},
    supports = {},
    lights = {}
  }
  
  if nil ~= teamMembers[mineshaftId] then
    while true do
      if not DoesEntityExist(teamMembers[mineshaftId]) then
        break
      end
      DeleteEntity(teamMembers[mineshaftId])
      Citizen.Wait(10)
    end
  end
  
  for propType, propConfig in pairs(Config.Props) do
    if "Rails" == propType then
      local currentPos = mineshaftConfig.railsStart
      
      for i = 1, mineshaftConfig.railsQuantity do
        Functions.LoadModel(-2021346006)
        magazineEntry.rails[i] = CreateObjectNoOffset(-2021346006, currentPos.x, currentPos.y, mineshaftConfig.railsStart.z, false, true, false)
        
        while true do
          if DoesEntityExist(magazineEntry.rails[i]) then
            break
          end
          Wait(10)
        end
        
        SetEntityRotation(magazineEntry.rails[i], mineshaftConfig.railsRotation.x, mineshaftConfig.railsRotation.y, mineshaftConfig.railsRotation.z, 0, false)
        FreezeEntityPosition(magazineEntry.rails[i], true)
        SetEntityCoords(magazineEntry.rails[i], currentPos.x, currentPos.y, mineshaftConfig.railsStart.z, false, false, false, false)
        SetEntityVisible(magazineEntry.rails[i], false, false)
        table.insert(Movement.SpawnedObjects, magazineEntry.rails[i])
        
        currentPos = currentPos + (mineshaftConfig.forwardVector * 5.0)
      end
      
    elseif "Lights" == propType then
      local currentPos = mineshaftConfig.lightsStart
      
      for i = 1, mineshaftConfig.lightsQuantity do
        Functions.LoadModel(-915189888)
        magazineEntry.lights[i] = CreateObjectNoOffset(-915189888, currentPos.x, currentPos.y, mineshaftConfig.lightsStart.z, false, true, false)
        
        while true do
          if DoesEntityExist(magazineEntry.lights[i]) then
            break
          end
          Wait(10)
        end
        
        SetEntityRotation(magazineEntry.lights[i], mineshaftConfig.lightsRotation.x, mineshaftConfig.lightsRotation.y, mineshaftConfig.lightsRotation.z, 0, false)
        FreezeEntityPosition(magazineEntry.lights[i], true)
        table.insert(Movement.SpawnedObjects, magazineEntry.lights[i])
        SetEntityVisible(magazineEntry.lights[i], false, false)
        
        currentPos = currentPos + (mineshaftConfig.forwardVector * 6)
      end
      
    else
      local currentPos = mineshaftConfig.supportsStart
      
      for i = 1, mineshaftConfig.supportsQuantity do
        if not magazineEntry.supports[i] then
          magazineEntry.supports[i] = {}
        end
        
        local offsetPos = currentPos + propConfig.offset
        local finalRotation = mineshaftConfig.supportsRotation - (propConfig.rotation * -1)
        local worldPos = Functions.RotateAroundPoint(currentPos.x, currentPos.y, currentPos.z, finalRotation.x, finalRotation.y, finalRotation.z, offsetPos.x, offsetPos.y, offsetPos.z)
        
        Functions.LoadModel(propConfig.model)
        magazineEntry.supports[i][propType] = CreateObjectNoOffset(propConfig.model, worldPos.x, worldPos.y, worldPos.z, false, true, false)
        
        while true do
          if DoesEntityExist(magazineEntry.supports[i][propType]) then
            break
          end
          Wait(10)
        end
        
        SetEntityRotation(magazineEntry.supports[i][propType], finalRotation.x, finalRotation.y, finalRotation.z, 0, false)
        FreezeEntityPosition(magazineEntry.supports[i][propType], true)
        SetEntityVisible(magazineEntry.supports[i][propType], false, false)
        table.insert(Movement.SpawnedObjects, magazineEntry.supports[i][propType])
        
        currentPos = currentPos + (mineshaftConfig.forwardVector * 6)
        currentPos = vector3(currentPos.x, currentPos.y, mineshaftConfig.supportsStart.z)
      end
    end
  end
  
  SetEntityVisible(magazineEntry.rails[1], true, true)
  
  local minecartPos = GetEntityCoords(magazineEntry.rails[startRailIndex])
  minecartPos = minecartPos + (mineshaftConfig.forwardVector * Config.MinecartForwardOffset)
  minecartPos = minecartPos + Config.MinecartOffset
  local minecartRotation = mineshaftConfig.railsRotation
  
  magazineEntry.minecart = CreateObjectNoOffset(Config.MinecartModel, minecartPos.x, minecartPos.y, minecartPos.z, false, true, false)
  
  while true do
    if DoesEntityExist(magazineEntry.minecart) then
      break
    end
    Wait(10)
  end
  
  SetEntityRotation(magazineEntry.minecart, minecartRotation.x, minecartRotation.y, minecartRotation.z, 2, false)
  FreezeEntityPosition(magazineEntry.minecart, true)
  table.insert(Movement.SpawnedObjects, magazineEntry.minecart)
  
  local minecartCoords = GetEntityCoords(magazineEntry.minecart)
  Functions.SpawnObject(Config.RockModel, function(rockObj)
    magazineEntry.minecartRock = rockObj
    AttachEntityToEntity(rockObj, magazineEntry.minecart, 0, Config.RockInMinecaftMinOffset.x, Config.RockInMinecaftMinOffset.y, Config.RockInMinecaftMinOffset.z, Config.RockInMinecaftRotation.x, Config.RockInMinecaftRotation.y, Config.RockInMinecaftRotation.z, true, true, true, false, 2, true)
  end, minecartCoords, false, true)
  
  magazine[mineshaftId] = magazineEntry
  magazineData[mineshaftId] = {
    rails = {[1] = true},
    lights = {},
    supports = {}
  }
  
  local startTime = GetGameTimer()
  local timeout = 5000
  
  while true do
    if nil ~= currentMagazineType then
      break
    end
    Citizen.Wait(100)
    if timeout <= (GetGameTimer() - startTime) then
      break
    end
  end
end)

RegisterNetEvent("gta5vn_miner:MineshaftCreated")
AddEventHandler("gta5vn_miner:MineshaftCreated", function(wallNetId, mineshaftId)
  local startTime = GetGameTimer()
  mineCounter = 0
  
  while true do
    if NetworkDoesNetworkIdExist(wallNetId) then
      break
    end
    
    if (GetGameTimer() - startTime) > 1500 then
      Functions.Error(string.format("Cloudn't find wall with NetId: %s", wallNetId))
    end
    
    Wait(100)
  end
  
  while true do
    if 0 ~= mineCounter then
      if mineCounter ~= wallNetId then
        break
      end
    end
    
    mineCounter = NetToObj(wallNetId)
    
    if (GetGameTimer() - startTime) > 1500 then
      Functions.Error(string.format("Cloudn't get entity with NetId: %s", wallNetId))
    end
    
    if 0 ~= mineCounter then
      if mineCounter ~= wallNetId then
        goto continue
      end
    end
    Wait(100)
    ::continue::
  end
  
  currentMagazineType = mineshaftId
  local mineshaftConfig = Config.Mineshatfs[mineshaftId]
  
  SetEntityRotation(mineCounter, mineshaftConfig.wallRotation.x, mineshaftConfig.wallRotation.y, mineshaftConfig.wallRotation.z, 2, false)
  
  SpawnPropsStack()
  
  while true do
    if not OnDuty then
      break
    end
    
    local waitTime = 1000
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    local wallPos = GetEntityCoords(mineCounter)
    local distance = #(playerPos - wallPos)
    
    if distance < 10.0 then
      if not AlreadyMining then
        if not carriedObject then
          waitTime = 0
          DrawText3Ds(wallPos.x, wallPos.y, wallPos.z - 1.0, Config.Lang.startMining)
          
          if distance < 3.0 then
            DisableControlAction(0, 24, true)
            
            if IsControlJustReleased(0, 38) then
              Functions.TriggerServerCallback("gta5vn_miner:CheckIfMiningPossible", function(canMine)
                if canMine then
                  if nil ~= propsObjects then
                    if nil ~= propsObjects.rails then
                      if #propsObjects.rails > 0 then
                        goto hasProps
                      end
                    end
                  end
                  
                  if not (#propsObjects.supports > 0) then
                    if not (#propsObjects.lights > 0) then
                      goto noProps
                    end
                  end
                  
                  ::hasProps::
                  Notify(Config.Lang.firstFinishBuilding)
                  goto done
                  
                  ::noProps::
                  MiningAnimation(mineCounter)
                  
                  ::done::
                end
              end)
            end
          end
        end
      end
    end
    
    Wait(waitTime)
  end
end)

RegisterNetEvent("gta5vn_miner:UpdateEntites")
AddEventHandler("gta5vn_miner:UpdateEntites", function(customBuildData, customWallPos)
  if not currentMagazineType then
    return
  end
  
  if not magazine[currentMagazineType] then
    return
  end
  
  local buildData = customBuildData or magazineData[currentMagazineType]
  local tempNeededObjects = {
    rails = {},
    supports = {},
    lights = {}
  }
  
  if magazine[currentMagazineType].rails then
    for i = 1, #magazine[currentMagazineType].rails do
      local isBuilt = false
      
      for builtIndex in pairs(buildData.rails) do
        if builtIndex == i then
          isBuilt = true
        end
      end
      
      SetEntityVisible(magazine[currentMagazineType].rails[i], isBuilt, false)
      FreezeEntityPosition(magazine[currentMagazineType].rails[i], true)
      
      if not isBuilt then
        table.insert(tempNeededObjects.rails, i)
      end
    end
  end
  
  if magazine[currentMagazineType].supports then
    for i = 1, #magazine[currentMagazineType].supports do
      for subType, obj in pairs(magazine[currentMagazineType].supports[i]) do
        FreezeEntityPosition(obj, true)
        
        if buildData.supports[i] then
          if buildData.supports[i][subType] then
            SetEntityVisible(obj, true, false)
          end
        else
          SetEntityVisible(obj, false, false)
          
          if not tempNeededObjects.supports[i] then
            tempNeededObjects.supports[i] = {}
          end
          table.insert(tempNeededObjects.supports[i], subType)
        end
      end
    end
  end
  
  if magazine[currentMagazineType].lights then
    for i = 1, #magazine[currentMagazineType].lights do
      local isBuilt = false
      
      for builtIndex in pairs(buildData.lights) do
        if builtIndex == i then
          isBuilt = true
        end
      end
      
      SetEntityVisible(magazine[currentMagazineType].lights[i], isBuilt, false)
      FreezeEntityPosition(magazine[currentMagazineType].lights[i], true)
      
      if not isBuilt then
        table.insert(tempNeededObjects.lights, i)
      end
    end
  end
  
  local forwardVector = Config.Mineshatfs[currentMagazineType].forwardVector
  local wallPos = customWallPos or GetEntityCoords(mineCounter)
  propsObjects = {
    rails = {},
    lights = {},
    supports = {}
  }
  
  local supportDependencies = {}
  
  for supportIndex in pairs(tempNeededObjects.supports) do
    local missingParts = {}
    
    for _, partType in pairs(tempNeededObjects.supports[supportIndex]) do
      if "SupportPillarLeft" == partType or "SupportPillarRight" == partType then
        table.insert(missingParts, partType)
      elseif "SupportConnectorLeft" == partType then
        local hasLeftPillar = true
        
        for _, checkPart in pairs(tempNeededObjects.supports[supportIndex]) do
          if "SupportPillarLeft" == checkPart then
            hasLeftPillar = false
          end
        end
        
        if hasLeftPillar then
          table.insert(missingParts, partType)
        end
      elseif "SupportConnectorRight" == partType then
        local hasRightPillar = true
        
        for _, checkPart in pairs(tempNeededObjects.supports[supportIndex]) do
          if "SupportPillarRight" == checkPart then
            hasRightPillar = false
          end
        end
        
        if hasRightPillar then
          table.insert(missingParts, partType)
        end
      elseif "SupportLintel" == partType then
        local hasConnector = true
        
        for _, checkPart in pairs(tempNeededObjects.supports[supportIndex]) do
          if "SupportConnectorLeft" == checkPart or "SupportConnectorRight" == checkPart then
            hasConnector = false
          end
        end
        
        if hasConnector then
          table.insert(missingParts, partType)
        end
      end
    end
    
    for _, partType in pairs(missingParts) do
      local supportObj = magazine[currentMagazineType].supports[supportIndex][partType]
      
      if supportObj then
        if DoesEntityExist(supportObj) then
          local objPos = GetEntityCoords(supportObj)
          local diff = wallPos - objPos
          local dotProduct = Functions.DotProduct(diff, forwardVector)
          
          if dotProduct > 1.5 then
            table.insert(propsObjects.supports, supportObj)
            supportDependencies[supportIndex] = true
          else
            supportDependencies[supportIndex] = false
          end
        end
      end
    end
  end
  
  for _, railIndex in pairs(tempNeededObjects.rails) do
    local railObj = magazine[currentMagazineType].rails[railIndex]
    
    if railObj then
      if DoesEntityExist(railObj) then
        local railPos = GetEntityCoords(railObj)
        local diff = wallPos - railPos
        local dotProduct = Functions.DotProduct(diff, forwardVector)
        
        if not (dotProduct > 3.5) then
          if not (true == supportDependencies[railIndex - 1]) then
            if not (true == supportDependencies[railIndex]) then
              goto skipRail
            end
          end
        end
        
        table.insert(propsObjects.rails, railObj)
        ::skipRail::
      end
    end
  end
  
  for _, lightIndex in pairs(tempNeededObjects.lights) do
    local lightObj = magazine[currentMagazineType].lights[lightIndex]
    
    if lightObj then
      if DoesEntityExist(lightObj) then
        local lightPos = GetEntityCoords(lightObj)
        local diff = wallPos - lightPos
        local dotProduct = Functions.DotProduct(diff, forwardVector)
        
        if dotProduct > 1.5 then
          if not tempNeededObjects.supports[lightIndex] then
            table.insert(propsObjects.lights, lightObj)
          end
        end
      end
    end
  end
  
  local hasNeededObjects = false
  local outlinedObjects = {}
  
  for _, objTable in pairs(propsObjects) do
    for i = 1, #objTable do
      hasNeededObjects = true
      SetEntityDrawOutlineShader(1)
      SetEntityDrawOutlineColor(Config.MarkerSettings.UnActive.r, Config.MarkerSettings.UnActive.g, Config.MarkerSettings.UnActive.b, Config.MarkerSettings.UnActive.a)
      SetEntityVisible(objTable[i], true, true)
      SetEntityDrawOutline(objTable[i], true)
      SetEntityVisible(objTable[i], false, false)
      outlinedObjects[objTable[i]] = true
      
      if AlreadyMining then
        AlreadyMining = false
      end
      
      Citizen.Wait(0)
    end
  end
  
  for _, objTable in pairs(magazine[currentMagazineType]) do
    if "table" == type(objTable) then
      for i = 1, #objTable do
        if "table" == type(objTable[i]) then
          for _, subObj in pairs(objTable[i]) do
            if not outlinedObjects[subObj] then
              SetEntityDrawOutline(subObj, false)
            end
          end
        else
          if not outlinedObjects[objTable[i]] then
            SetEntityDrawOutline(objTable[i], false)
          end
        end
      end
    end
  end
  
  if hasNeededObjects then
    if not isBack then
      isBack = true
      
      if 0 == GetResourceKvpInt("17mov_Tutorials:" .. Config.Lang.buildingTutorial) then
        currentTutorialName = Config.Lang.buildingTutorial
        SendNUIMessage({action = "showTutorial", customText = Config.Lang.buildingTutorial})
        tutorialShowing = true
        
        CreateThread(function()
          while true do
            if not tutorialShowing then
              break
            end
            
            Wait(0)
            DisableControlAction(0, 30, true)
            DisableControlAction(0, 31, true)
            DisableControlAction(0, 32, true)
            DisableControlAction(0, 33, true)
            DisableControlAction(0, 34, true)
            DisableControlAction(0, 35, true)
          end
        end)
        
        SetNuiFocus(true, true)
      end
    end
  end
end)

local currentlyAiming = false
local hintObject = nil
local propToPlace = nil
local hitCounter = 0

function MiningAnimation(wallEntity)
  TriggerServerEvent("gta5vn_miner:StartedMining")
  
  local animDict = "melee@large_wpn@streamed_core"
  local animName = "ground_attack_on_spot"
  local idleAnim = "dodge_generic_centre"
  local pickaxeObject = nil
  local isHittingBonus = false
  
  AlreadyMining = true
  
  local playerPed = PlayerPedId()
  local playerPos = GetEntityCoords(playerPed)
  local lastValidPos = playerPos
  
  Functions.SpawnObject(260873931, function(obj)
    pickaxeObject = obj
    AttachEntityToEntity(pickaxeObject, playerPed, GetPedBoneIndex(playerPed, 57005), 0.1, -0.1, -0.02, 90.0, 0.0, 180.0, true, true, false, true, 1, true)
  end, GetEntityCoords(playerPed), true, true)
  
  if nil ~= hintObject then
    if DoesEntityExist(hintObject) then
      DeleteEntity(hintObject)
    end
  end
  
  local wallPos = GetEntityCoords(wallEntity)
  local playerForward = GetEntityForwardVector(playerPed)
  local wallDirection = Functions.NormalizeVector3(wallPos - playerPos)
  local dotProduct = Functions.DotProduct(playerForward, wallDirection)
  
  local offsetDistance = -1.5
  local playerOffsetFromWall = GetOffsetFromEntityGivenWorldCoords(mineCounter, playerPos.x, playerPos.y, playerPos.z)
  local targetPos = GetOffsetFromEntityInWorldCoords(mineCounter, playerOffsetFromWall.x, offsetDistance, playerOffsetFromWall.z)
  SetEntityCoords(playerPed, targetPos.x, targetPos.y, playerPos.z - 1.0, true, false, false, false)
  
  if not (dotProduct > 1.0) then
    if not (dotProduct < 0.3) then
      goto skipTurn
    end
  end
  
  TaskTurnPedToFaceEntity(playerPed, wallEntity, 1500)
  Wait(1500)
  
  ::skipTurn::
  
  Functions.RequestAnimDict(animDict)
  SpawnPropAtRaycastWall()
  SendNUIMessage({action = "showCrosshair"})
  
  CreateThread(function()
    while true do
      if not AlreadyMining then
        break
      end
      
      if IsDisabledControlPressed(0, 18) then
        if not currentlyAiming then
          currentlyAiming = true
          hitCounter = hitCounter + 1
          
          ClearPedTasks(playerPed)
          TaskPlayAnim(playerPed, animDict, animName, 8.0, 8.0, -1, 48, 0, false, false, false)
          
          Wait(850)
          
          if nil ~= hintObject then
            if DoesEntityExist(hintObject) then
              DeleteEntity(hintObject)
            end
          end
          
          if isHittingBonus then
            Functions.PlaySound("bonus", Config.SoundVolumeMultipler)
          end
          
          if AlreadyMining then
            TriggerServerEvent("gta5vn_miner:WallHit", isHittingBonus)
          end
          
          Wait(100)
          
          local currentPlayerPos = GetEntityCoords(playerPed)
          local playerOffsetNew = GetOffsetFromEntityGivenWorldCoords(mineCounter, currentPlayerPos.x, currentPlayerPos.y, currentPlayerPos.z)
          local newTargetPos = GetOffsetFromEntityInWorldCoords(mineCounter, playerOffsetNew.x, offsetDistance, playerOffsetNew.z)
          SetEntityCoords(playerPed, newTargetPos.x, newTargetPos.y, playerPos.z - 1.0, true, true, false, false)
          
          SpawnPropAtRaycastWall()
          
          Wait(GetAnimDuration(animDict, animName) * 1000 - 1650)
          
          currentlyAiming = false
        end
      end
      
      SetCurrentPedWeapon(playerPed, -1569615261, true)
      DisablePlayerFiring(playerPed, true)
      
      Wait(0)
    end
  end)
  
  CreateThread(function()
    while true do
      if not AlreadyMining then
        break
      end
      
      TriggerServerEvent("gta5vn_miner:StartedMining")
      Citizen.Wait(2500)
    end
  end)
  
  while true do
    if not AlreadyMining then
      break
    end
    
    local currentPed = PlayerPedId()
    ShowHelpNotification(Config.Lang.mouseForMine)
    
    local pedHeading = GetEntityHeading(currentPed)
    local wallHeading = GetEntityHeading(mineCounter)
    local headingDiff = math.abs(pedHeading - wallHeading) % 360
    
    if headingDiff > 180 then
      headingDiff = 360 - headingDiff
    end
    
    if headingDiff > 120 then
      AlreadyMining = false
    end
    
    local currentPos = GetEntityCoords(currentPed)
    lastValidPos = currentPos
    
    if lastValidPos then
      local movement = #(lastValidPos - lastValidPos)
      
      if nil ~= hintObject then
        local hintPos = GetEntityCoords(hintObject)
        movement = #(hintPos - lastValidPos)
      end
      
      if movement > 2.0 then
        lastValidPos = lastValidPos
      end
    end
    
    local distToWall = #(GetEntityCoords(wallEntity) - GetEntityCoords(currentPed))
    
    if distToWall > 5.0 then
      AlreadyMining = false
    end
    
    if not IsEntityPlayingAnim(currentPed, animDict, idleAnim, 3) then
      if not currentlyAiming then
        TaskPlayAnim(currentPed, animDict, idleAnim, 8.0, 8.0, -1, 48, 0, false, false, false)
      end
    end
    
    isHittingBonus = CheckIfPlayerAimingAtHint(wallEntity)
    
    DisableControlAction(0, 24, true)
    Wait(0)
  end
  
  Functions.DeleteEntity(pickaxeObject)
  ClearPedTasks(PlayerPedId())
  SendNUIMessage({action = "hideCrosshair"})
  
  if nil ~= hintObject then
    if DoesEntityExist(hintObject) then
      DeleteEntity(hintObject)
    end
  end
  
  TriggerServerEvent("gta5vn_miner:MiningStop")
end

function SpawnPropAtRaycastWall()
  local maxAttempts = 10
  local attempts = 0
  local foundValidSpot = false
  local targetCoords = vec3(0, 0, 0)
  
  local playerPos = GetEntityCoords(PlayerPedId())
  local playerOffsetFromWall = GetOffsetFromEntityGivenWorldCoords(mineCounter, playerPos.x, playerPos.y, playerPos.z)
  
  local xOffset = playerOffsetFromWall.x
  local yOffset = -0.15
  local zOffset = -1.65
  
  if xOffset < -1.65 then
    xOffset = -1.65
  end
  if xOffset > 1.9 then
    xOffset = 1.9
  end
  
  while not foundValidSpot and maxAttempts > attempts do
    xOffset = xOffset + Functions.randomFloat(-0.5, 0.5)
    zOffset = Functions.randomFloat(-0.6, -1.8)
    
    if xOffset < 2.4 then
      if xOffset > -2.15 then
        attempts = attempts + 1
        targetCoords = GetOffsetFromEntityInWorldCoords(mineCounter, xOffset, yOffset, zOffset)
        
        if nil ~= propToPlace then
          if #(targetCoords - propToPlace) >= 0.75 then
            foundValidSpot = true
          end
        else
          foundValidSpot = true
        end
      end
    end
    
    Wait(0)
  end
  
  Functions.SpawnObject(921401054, function(obj)
    hintObject = obj
    local pedRotation = GetEntityRotation(PlayerPedId())
    SetEntityRotation(hintObject, pedRotation.x, pedRotation.y, pedRotation.z, 0, false)
    SetEntityVisible(obj, false, false)
  end, targetCoords, false, true)
  
  propToPlace = targetCoords
end

local hintColorCurrent = Functions.DeepCopy(Config.MiningHintColor)
local hintSizeCurrent = 0.1

function CheckIfPlayerAimingAtHint(wallEntity)
  local isAimingAtHint = false
  
  if nil ~= hintObject then
    if DoesEntityExist(hintObject) then
      local playerPed = PlayerPedId()
      local camCoords = GetGameplayCamCoord()
      local camDirection = Functions.RotationToDirection(GetGameplayCamRot(2))
      local rayStart = camCoords
      local rayEnd = rayStart + (camDirection * 1000.0)
      
      local rayHandle = StartShapeTestRay(rayStart.x, rayStart.y, rayStart.z, rayEnd.x, rayEnd.y, rayEnd.z, 4294967295, playerPed, 0)
      local _, hit, hitCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
      
      local targetColor = hintColorCurrent
      local targetSize = 0.1
      
      if entityHit == hintObject then
        isAimingAtHint = true
        targetColor = Config.MarkerSettings.Active
        targetColor.a = 0.9
        targetSize = 0.12
      elseif entityHit == wallEntity then
        targetColor = Config.MiningHintColor
      end
      
      hintColorCurrent.r = math.floor(Functions.Lerp(hintColorCurrent.r, targetColor.r, 0.2) + 0.5)
      hintColorCurrent.g = math.floor(Functions.Lerp(hintColorCurrent.g, targetColor.g, 0.2) + 0.5)
      hintColorCurrent.b = math.floor(Functions.Lerp(hintColorCurrent.b, targetColor.b, 0.2) + 0.5)
      hintColorCurrent.a = Functions.Lerp(hintColorCurrent.a, targetColor.a, 0.1)
      hintSizeCurrent = Functions.Lerp(hintSizeCurrent, targetSize, 0.1)
      
      local hintRotation = GetEntityRotation(wallEntity)
      SetEntityRotation(hintObject, hintRotation.x, hintRotation.y, hintRotation.z, 0, false)
      
      DrawSphere(propToPlace.x, propToPlace.y, propToPlace.z, hintSizeCurrent, hintColorCurrent.r, hintColorCurrent.g, hintColorCurrent.b, hintColorCurrent.a)
    end
  end
  
  return isAimingAtHint
end

function SpawnPropsStack()
  for propType, propConfig in pairs(Config.Props) do
    local quantity = 0
    
    if "Rails" == propType then
      quantity = Config.Mineshatfs[currentMagazineType].railsQuantity
    elseif "Lights" == propType then
      quantity = Config.Mineshatfs[currentMagazineType].lightsQuantity
    else
      quantity = Config.Mineshatfs[currentMagazineType].supportsQuantity
    end
    
    local startIndex = (nil == propConfig.stackCoords) and 1 or 0
    local endIndex = (nil ~= propConfig.stackCoords) and quantity or (quantity - 1)
    
    for i = startIndex, endIndex do
      local spawnCoords = nil
      
      if propConfig.stackCoords then
        spawnCoords = propConfig.stackCoords + (propConfig.stackOffest * i)
      else
        spawnCoords = propConfig.stackCoordinates[i]
      end
      
      Functions.SpawnObject(propConfig.model, function(obj)
        SetEntityRotation(obj, propConfig.stackRotation.x, propConfig.stackRotation.y, propConfig.stackRotation.z, 0, false)
        Entity(obj).state.objType = propType
        Entity(obj).state.objIndex = i
        table.insert(propsObjectsTable[propType], obj)
      end, spawnCoords, false, true)
    end
  end
end

RegisterNetEvent("gta5vn_miner:TeammateDead")
AddEventHandler("gta5vn_miner:TeammateDead", function()
  OnDuty = false
  Notify(Config.Lang.teammateDown)
  
  local playerPed = PlayerPedId()
  local spawnPos = vector4(2428.31, 1531.46, -32.76, 87.3)
  
  SetEntityCoords(playerPed, spawnPos.x, spawnPos.y, spawnPos.z, true, false, false, false)
  SetEntityHeading(playerPed, spawnPos.w)
end)

function CheckIsDead()
  CreateThread(function()
    TriggerEvent("qb-weathersync:client:DisableSync")
    
    while true do
      if not spawnedPed then
        break
      end
      
      local playerPed = PlayerPedId()
      local playerPos = GetEntityCoords(playerPed)
      
      if math.abs(playerPos.z - Config.Mineshatfs[1].railsStart.z) > 20 then
        break
      end
      
      if IsDead(playerPed) then
        TriggerEvent("qb-weathersync:client:EnableSync")
        SetArtificialLightsState(false)
        SetEntityCoords(playerPed, Config.DeadCoords.x, Config.DeadCoords.y, Config.DeadCoords.z, false, true, false, false)
        TriggerServerEvent("gta5vn_miner:ElevatorBack")
        TriggerServerEvent("gta5vn_miner:ImDead")
        break
      end
      
      Wait(1500)
    end
  end)
end

function CheckIsInMineshaft()
  CreateThread(function()
    local wasInside = false
    local mineshaftZ = -32
    
    while true do
      if not seatedPlayer then
        break
      end
      
      local playerPed = PlayerPedId()
      local playerPos = GetEntityCoords(playerPed)
      local isInside = math.abs(mineshaftZ - playerPos.z) < 15
      
      if wasInside and not isInside then
        SetEntityCoords(playerPed, Config.DeadCoords.x, Config.DeadCoords.y, Config.DeadCoords.z, false, false, false, false)
      elseif not wasInside and isInside then
        wasInside = true
      end
      
      Wait(1500)
    end
  end)
end

function WarpMinecartTo(targetPos, speed, mineshaftId)
  local startPos = GetEntityCoords(magazine[mineshaftId].minecart)
  local totalDistance = math.sqrt((targetPos.x - startPos.x)^2 + (targetPos.y - startPos.y)^2 + (targetPos.z - startPos.z)^2)
  
  local progress = 0.0
  local distanceTraveled = 0.0
  local lastTime = GetGameTimer()
  
  while totalDistance > distanceTraveled do
    local currentTime = GetGameTimer()
    local deltaTime = (currentTime - lastTime) / 1000
    local movement = speed * deltaTime
    distanceTraveled = distanceTraveled + movement
    progress = math.min(distanceTraveled / totalDistance, 1.0)
    
    local x = Functions.Lerp(startPos.x, targetPos.x, progress)
    local y = Functions.Lerp(startPos.y, targetPos.y, progress)
    local z = Functions.Lerp(startPos.z, targetPos.z, progress)
    
    SetEntityCoords(magazine[mineshaftId].minecart, x, y, z, false, false, false, false)
    
    if totalDistance <= distanceTraveled then
      break
    end
    
    lastTime = GetGameTimer()
    Wait(0)
  end
end

RegisterNetEvent("gta5vn_miner:UpdateMinecart")
AddEventHandler("gta5vn_miner:UpdateMinecart", function(railIndex, mineshaftId, myServerId, requesterId)
  local railObj = magazine[mineshaftId].rails[railIndex]
  local railPos = GetEntityCoords(railObj)
  railPos = railPos + (Config.Mineshatfs[currentMagazineType].forwardVector * Config.MinecartForwardOffset)
  railPos = railPos + Config.MinecartOffset
  
  if myServerId == requesterId then
    TriggerServerEvent("gta5vn_miner:StartMinecartSound")
    
    local soundStopped = false
    CreateThread(function()
      Citizen.Wait(10000)
      if not soundStopped then
        TriggerServerEvent("gta5vn_miner:StopMinecartSound")
      end
    end)
    
    WarpMinecartTo(railPos, 1, mineshaftId)
    soundStopped = true
    TriggerServerEvent("gta5vn_miner:StopMinecartSound")
  else
    WarpMinecartTo(railPos, 1, mineshaftId)
  end
end)

RegisterNetEvent("gta5vn_miner:UpdateMinecartContent")
AddEventHandler("gta5vn_miner:UpdateMinecartContent", function(fillPercent, mineshaftId)
  local startTime = GetGameTimer()
  fillPercent = fillPercent / 100
  
  if fillPercent > 1 then
    fillPercent = 1
  end
  
  local offsetX = Functions.Lerp(Config.RockInMinecaftMinOffset.x, Config.RockInMinecaftMaxOffset.x, fillPercent)
  local offsetY = Functions.Lerp(Config.RockInMinecaftMinOffset.y, Config.RockInMinecaftMaxOffset.y, fillPercent)
  local offsetZ = Functions.Lerp(Config.RockInMinecaftMinOffset.z, Config.RockInMinecaftMaxOffset.z, fillPercent)
  
  AttachEntityToEntity(magazine[mineshaftId].minecartRock, magazine[mineshaftId].minecart, 0, offsetX, offsetY, offsetZ, Config.RockInMinecaftRotation.x, Config.RockInMinecaftRotation.y, Config.RockInMinecaftRotation.z, true, true, true, false, 2, true)
end)

RegisterNetEvent("gta5vn_miner:StartMinecartSound")
AddEventHandler("gta5vn_miner:StartMinecartSound", function(mineshaftId)
  local minecart = magazine[mineshaftId].minecart
  local playerPed = PlayerPedId()
  local playerPos = GetEntityCoords(playerPed)
  local minecartPos = GetEntityCoords(minecart)
  
  local distance = #(vec3(playerPos.x, playerPos.y, playerPos.z) - vec3(minecartPos.x, minecartPos.y, minecartPos.z))
  
  if nil ~= currentMagazineType and distance < 100 then
    if math.abs(playerPos.z - minecartPos.z) < 20 then
      Functions.PlayAudioAtCoords("minecart", Config.SoundVolumeMultipler, minecart, 50, true, true, "minecart")
      Citizen.Wait(10000)
      Functions.StopSound("minecart")
    end
  end
end)

RegisterNetEvent("gta5vn_miner:StopMinecartSound")
AddEventHandler("gta5vn_miner:StopMinecartSound", function()
  Functions.StopSound("minecart")
end)

RegisterNetEvent("gta5vn_miner:PlayMiningSound")
AddEventHandler("gta5vn_miner:PlayMiningSound", function(coords)
  if nil ~= currentMagazineType then
    Functions.PlayAudioAtCoords("pickaxe", Config.SoundVolumeMultipler, coords, 50)
  end
end)

RegisterNetEvent("gta5vn_miner:StopMining")
AddEventHandler("gta5vn_miner:StopMining", function()
  AlreadyMining = false
  Notify(Config.Lang.maximum)
end)

RegisterNetEvent("gta5vn_miner:UpdateWalls")
AddEventHandler("gta5vn_miner:UpdateWalls", function(mineshaftIds)
  if nil ~= mineshaftIds then
    local tempTable = {}
    for _, id in pairs(mineshaftIds) do
      tempTable[id] = true
    end
    mineshaftIds = tempTable
  end
  
  for i = 1, #Config.Mineshatfs do
    if mineshaftIds then
      if mineshaftIds[i] then
        if teamMembers[i] then
          if DoesEntityExist(teamMembers[i]) then
            DeleteEntity(teamMembers[i])
            teamMembers[i] = nil
          end
        end
      end
    else
      if teamMembers[i] then
        if DoesEntityExist(teamMembers[i]) then
          goto skipSpawn
        end
      end
      
      if i ~= currentMagazineType then
        local function pointInPolygon(point, v1, v2, v3, v4)
          local function cross2D(a, b)
            return a.x * b.y - b.x * a.y
          end
          
          local function vectorSub(a, b)
            return {x = b.x - a.x, y = b.y - a.y}
          end
          
          local edges = {
            vectorSub(v1, v2),
            vectorSub(v2, v3),
            vectorSub(v3, v4),
            vectorSub(v4, v1)
          }
          
          local pointVectors = {
            vectorSub(v1, point),
            vectorSub(v2, point),
            vectorSub(v3, point),
            vectorSub(v4, point)
          }
          
          local crossProducts = {}
          for j = 1, #edges do
            crossProducts[j] = cross2D(edges[j], pointVectors[j])
          end
          
          local allPositive = crossProducts[1] > 0
          
          for j = 2, #crossProducts do
            if allPositive then
              if crossProducts[j] < 0 then
                return false
              end
            else
              if crossProducts[j] > 0 then
                return false
              end
            end
          end
          
          return true
        end
        
        Functions.SpawnObject(Config.WallModel, function(wallObj)
          teamMembers[i] = wallObj
          SetEntityRotation(wallObj, Config.Mineshatfs[i].wallRotation.x, Config.Mineshatfs[i].wallRotation.y, Config.Mineshatfs[i].wallRotation.z, 0, false)
          
          local wallHeight = 47.2
          local wallWidth = 5.3
          local playerPed = PlayerPedId()
          local playerPos = GetEntityCoords(playerPed)
          
          local cornerBR = GetOffsetFromEntityInWorldCoords(wallObj, wallWidth/2, 0.0, 0.0)
          local cornerBL = GetOffsetFromEntityInWorldCoords(wallObj, wallWidth/-2, 0.0, 0.0)
          local cornerTL = GetOffsetFromEntityInWorldCoords(wallObj, wallWidth/-2, wallHeight, 0.0)
          local cornerTR = GetOffsetFromEntityInWorldCoords(wallObj, wallWidth/2, wallHeight, 0.0)
          
          if pointInPolygon(playerPos, cornerBR, cornerBL, cornerTL, cornerTR) then
            if (cornerBR.z + 10) > playerPos.z then
              if (cornerBR.z - 10) < playerPos.z then
                local safePos = GetOffsetFromEntityInWorldCoords(wallObj, 0.0, -2.0, -2.0)
                SetEntityCoords(playerPed, safePos.x, safePos.y, safePos.z, true, false, false, false)
              end
            end
          end
        end, Config.Mineshatfs[i].wallCoordinates, false, true)
      end
      
      ::skipSpawn::
    end
  end
end)

RegisterNetEvent("gta5vn_miner:UpdateProgress")
AddEventHandler("gta5vn_miner:UpdateProgress", function(progress)
  SendNUIMessage({
    action = "updateCounter",
    value = math.floor(progress * 100) / 100
  })
end)

RegisterNetEvent("gta5vn_miner:ElevatorOpenDoors")
AddEventHandler("gta5vn_miner:ElevatorOpenDoors", function(isBack)
  elevator.animateDoors(isBack, true)
end)

RegisterNetEvent("gta5vn_miner:ElevatorGoDown")
AddEventHandler("gta5vn_miner:ElevatorGoDown", function()
  elevator.animateDoors(false, false)
  elevator.TaskGoToCoords(-72.7)
  elevator.currentState = "down"
  
  spawnedPed = true
  seatedPlayer = true
  
  if 0 == GetResourceKvpInt("17mov_Tutorials:" .. Config.Lang.downTutorial) then
    currentTutorialName = Config.Lang.downTutorial
    
    local letters = {"A", "B", "C", "D", "E", "F", "G", "H"}
    SendNUIMessage({
      action = "showTutorial",
      customText = string.format(Config.Lang.downTutorial, letters[currentMagazineType])
    })
    
    tutorialShowing = true
    CreateThread(function()
      while true do
        if not tutorialShowing then
          break
        end
        
        Wait(0)
        DisableControlAction(0, 30, true)
        DisableControlAction(0, 31, true)
        DisableControlAction(0, 32, true)
        DisableControlAction(0, 33, true)
        DisableControlAction(0, 34, true)
        DisableControlAction(0, 35, true)
      end
    end)
    
    SetNuiFocus(true, true)
  end
  
  elevator.animateDoors(true, true)
  
  CreateThread(function()
    while true do
      if not OnDuty then
        break
      end
      
      Wait(1000)
      TriggerEvent("gta5vn_miner:UpdateEntites")
    end
  end)
  
  CheckIsDead()
  CheckIsInMineshaft()
end)

RegisterNetEvent("gta5vn_miner:ElevatorBack_cl")
AddEventHandler("gta5vn_miner:ElevatorBack_cl", function(myServerId, requesterId, shouldEndJob)
  spawnedPed = false
  seatedPlayer = false
  
  elevator.animateDoors(true, false)
  
  if gasEffectActive then
    gasEffectActive = false
    SetTimecycleModifier("")
    RemoveTimecycleModifier("mineshaft_gas")
    RemoveParticleFx(Config.Events.gas.particles, true)
  end
  
  deleteRecursive(carriedObject)
  carriedObject = nil
  mineCounter = 0
  propsObjects = {}
  deleteRecursive(foodTrayObject)
  foodTrayObject = nil
  deleteRecursive(propsObjectsTable)
  propsObjectsTable = {
    Rails = {},
    Lights = {},
    SupportPillarLeft = {},
    SupportPillarRight = {},
    SupportConnectorLeft = {},
    SupportConnectorRight = {},
    SupportLintel = {}
  }
  deleteRecursive(magazine[currentMagazineType])
  
  elevator.TaskGoToCoords(72.7)
  TriggerServerEvent("gta5vn_miner_ExitBucket")
  
  CreateThread(function()
    if HaveGear then
      ToggleGear()
      DeleteEntity(headlampObject)
    end
  end)
  
  CreateThread(function()
    ChangeClothes()
  end)
  
  TriggerEvent("gta5vn_miner:UpdateWalls")

  elevator.currentState = "up"
  elevator.animateDoors(false, true)
  CreateThread(function()
    Wait(5000)
    if elevator.frontDoorsOpened then
      local playerPed = PlayerPedId()
      if not elevator.isInside(playerPed) then
        elevator.animateDoors(false, false)
      end
    end
  end)
  TriggerEvent("qb-weathersync:client:EnableSync")

  if myServerId == requesterId then
    TriggerServerEvent("gta5vn_miner:endJob_sv", shouldEndJob)
  end
end)

gasEffectActive = false

RegisterNetEvent("gta5vn_miner:RunEvent")
AddEventHandler("gta5vn_miner:RunEvent", function(eventName, coords, rotation, duration)
  if nil == currentMagazineType then
    return
  end
  
  Config.Events[eventName].running = true
  
  CreateThread(function()
    while true do
      local playerPos = GetEntityCoords(PlayerPedId())
      
      if math.abs(playerPos.z - Config.Mineshatfs[1].wallCoordinates.z) > 10 then
        Config.Events[eventName].running = false
        break
      end
      
      Wait(100)
    end
  end)
  
  if "gas" == eventName then
    Functions.PlayAudioAtCoords("gas", Config.SoundVolumeMultipler, coords, 100)
    Notify(Config.Lang.gasLeak)
    
    if not HasNamedPtfxAssetLoaded("core") then
      RequestNamedPtfxAsset("core")
      while true do
        if HasNamedPtfxAssetLoaded("core") then
          break
        end
        Wait(10)
      end
    end
    
    Functions.PlayAudioAtCoords("explode", Config.SoundVolumeMultipler, coords, 100)
    
    UseParticleFxAssetNextCall("core")
    StartParticleFxNonLoopedAtCoord("exp_grd_gas_can", coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 1065353216, false, false, false)
    
    Wait(3500)
    
    if not HasNamedPtfxAssetLoaded("core") then
      RequestNamedPtfxAsset("core")
      while true do
        if HasNamedPtfxAssetLoaded("core") then
          break
        end
        Wait(10)
      end
    end
    
    UseParticleFxAssetNextCall("core")
    Config.Events[eventName].particles = StartParticleFxLoopedAtCoord("ent_amb_steam", coords.x, coords.y, coords.z, rotation.x + 90.0, rotation.y, rotation.z, 1065353216, false, false, false, false)
    
    CreateTimecycleModifier("mineshaft_gas")
    SetTimecycleModifierVar("mineshaft_gas", "screen_blur_intensity", 0.2, 0.0)
    SetTimecycleModifierVar("mineshaft_gas", "fog_start", 1.0, 0.0)
    SetTimecycleModifierVar("mineshaft_gas", "fog_near_col_r", 0.5, 0.5)
    SetTimecycleModifierVar("mineshaft_gas", "fog_near_col_g", 0.5, 0.5)
    SetTimecycleModifierVar("mineshaft_gas", "fog_near_col_b", 0.5, 0.5)
    SetTimecycleModifierVar("mineshaft_gas", "fog_near_col_a", 0.0, 1.0)
    SetTimecycleModifier("mineshaft_gas")
    
    local scaleStart = 1.0
    local alphaStart = 1.0
    local blurStart = 0.0
    local densityStart = 0.0
    local falloffStart = 0.0
    local heightStart = 0.0
    local scaleTarget = 3.0
    local alphaTarget = 20.0
    local blurTarget = 0.2
    local densityTarget = 70.0
    local falloffTarget = 200.0
    local heightTarget = 50.0
    local targetTimePost = 30.0
    local eventDuration = 10000
    
    local function lerpValue(from, to, elapsed, total)
      if elapsed > total then
        elapsed = total
      end
      return from + ((to - from) * (elapsed / total))
    end
    
    local startTime = GetGameTimer()
    local lastHealthLoss = 0
    gasEffectActive = true
    
    CreateThread(function()
      Citizen.Wait(4000)
      
      while true do
        if not gasEffectActive then
          break
        end
        
        Citizen.Wait(50)
        
        local currentTime = GetGameTimer()
        local elapsed = currentTime - startTime
        local timeSinceLastDamage = currentTime - lastHealthLoss
        
        if timeSinceLastDamage >= Config.Events.gas.healthLossInterval then
          local playerPed = PlayerPedId()
          local health = GetEntityHealth(playerPed)
          
          if health > 0 then
            local newHealth = health - Config.Events.gas.healthLossValue
            SetEntityHealth(playerPed, newHealth)
            lastHealthLoss = currentTime
            
            local currentDensity = lerpValue(densityTarget, falloffTarget, elapsed - eventDuration, eventDuration)
            SetTimecycleModifierVar("mineshaft_gas", "fog_density", currentDensity, 100.0)
          end
        end
      end
    end)
    
    while true do
      if not Config.Events[eventName].running then
        break
      end
      
      local currentTime = GetGameTimer()
      local elapsed = currentTime - startTime
      
      if eventDuration >= elapsed then
        local currentScale = lerpValue(scaleStart, scaleTarget, elapsed, eventDuration)
        local currentAlpha = lerpValue(alphaStart, alphaTarget, elapsed, eventDuration)
        local currentBlur = lerpValue(blurStart, blurTarget, elapsed, eventDuration)
        local currentDensity = lerpValue(densityStart, densityTarget, elapsed, eventDuration)
        local currentFalloff = lerpValue(falloffStart, falloffTarget, elapsed, eventDuration)
        local currentHeight = lerpValue(heightStart, heightTarget, elapsed, eventDuration)
        
        SetParticleFxLoopedScale(Config.Events[eventName].particles, currentScale)
        SetParticleFxLoopedAlpha(Config.Events[eventName].particles, currentAlpha)
        SetTimecycleModifierVar("mineshaft_gas", "screen_blur_intensity", currentBlur, 0.0)
        SetTimecycleModifierVar("mineshaft_gas", "fog_density", currentDensity, 100.0)
        SetTimecycleModifierVar("mineshaft_gas", "fog_falloff", currentFalloff, 70.0)
        SetTimecycleModifierVar("mineshaft_gas", "fog_base_height", currentHeight, 125.0)
      end
      
      Wait(50)
    end
    
  elseif "blackout" == eventName then
    Functions.PlaySound("lightsfailure", Config.SoundVolumeMultipler)
    ToggleLights(false)
    Citizen.Wait(duration)
    ToggleLights(true)
  end
end)

function ToggleLights(state)
  state = not state
  Citizen.Wait(100)
  SetArtificialLightsState(state)
  Citizen.Wait(25)
  
  for i = 1, 3 do
    SetArtificialLightsState(not state)
    Citizen.Wait(25)
    SetArtificialLightsState(state)
  end
  
  Citizen.Wait(180)
  
  for i = 1, 3 do
    SetArtificialLightsState(not state)
    Citizen.Wait(10)
    SetArtificialLightsState(state)
  end
  
  Citizen.Wait(10)
  SetArtificialLightsState(not state)
  Citizen.Wait(180)
  SetArtificialLightsState(state)
end

CreateThread(function()
  SetArtificialLightsState(false)
end)

RegisterNetEvent("gta5vn_miner:StopEvent")
AddEventHandler("gta5vn_miner:StopEvent", function(eventName)
  Config.Events[eventName].running = false
end)

AddEventHandler("onResourceStop", function(resourceName)
  if GetCurrentResourceName() ~= resourceName then
    return
  end
  
  for propType, propsTable in pairs(propsObjectsTable) do
    if "table" == type(propsTable) then
      for _, obj in pairs(propsTable) do
        if "number" == type(obj) then
          DeleteEntity(obj)
        end
      end
    else
      if "number" == type(propsTable) then
        if DoesEntityExist(propsTable) then
          DeleteEntity(propsTable)
        end
      end
    end
  end
end)

function SitOnChair(chairData, chairId)
  TriggerServerEvent("gta5vn_miner:SeatTaken", chairId)
  
  carriedObject = nil
  local playerPed = PlayerPedId()
  local playerStartPos = GetEntityCoords(playerPed)
  local chairPos = GetEntityCoords(chairData.obj)
  local sitPosition = GetOffsetFromEntityInWorldCoords(chairData.obj, 0, 0.16, 0.4)
  local trayPosition = GetOffsetFromEntityInWorldCoords(chairData.obj, chairData.trayOffset.x, chairData.trayOffset.y, chairData.trayOffset.z)
  
  ClearPedTasksImmediately(playerPed)
  SetEntityCoords(playerPed, chairPos.x, chairPos.y, chairPos.z, true, false, false, false)
  FreezeEntityPosition(playerPed, true)
  TaskStartScenarioAtPosition(playerPed, "PROP_HUMAN_SEAT_BENCH", sitPosition.x, sitPosition.y, sitPosition.z, GetEntityHeading(chairData.obj) + 180.0, 0, false, true)
  
  DetachEntity(foodTrayObject, false, true)
  SetEntityCoords(foodTrayObject, trayPosition.x, trayPosition.y, trayPosition.z, false, false, false, false)
  SetEntityRotation(foodTrayObject, chairData.rotation.x, chairData.rotation.y, chairData.rotation.z, 0, false)
  FreezeEntityPosition(foodTrayObject, true)
  
  local shouldContinue = false
  CreateThread(function()
    while true do
      if shouldContinue then
        break
      end
      
      Citizen.Wait(0)
      SetEntityCollision(chairData.obj, false, false)
      SetEntityCoords(foodTrayObject, trayPosition.x, trayPosition.y, trayPosition.z, false, false, false, false)
      SetEntityRotation(foodTrayObject, chairData.rotation.x, chairData.rotation.y, chairData.rotation.z, 0, false)
      FreezeEntityPosition(foodTrayObject, true)
      
      if not IsPedUsingScenario(playerPed, "PROP_HUMAN_SEAT_BENCH") then
        TaskStartScenarioAtPosition(playerPed, "PROP_HUMAN_SEAT_BENCH", sitPosition.x, sitPosition.y, sitPosition.z, GetEntityHeading(chairData.obj) + 180.0, 0, false, true)
      end
    end
  end)
  
  Citizen.Wait(100)
  
  local eatAnimDict = "mp_player_inteat@burger"
  local eatAnimName = "mp_player_int_eat_burger_fp"
  
  Functions.RequestAnimDict(eatAnimDict)
  TaskPlayAnim(playerPed, eatAnimDict, eatAnimName, 2.0, 2.0, -1, 51, 0, false, false, false)
  
  local handBone = GetPedBoneIndex(playerPed, 18905)
  AttachEntityToEntity(L28_1, playerPed, handBone, 0.12, 0.028, 0.01, 10.0, 175.0, 0.0, true, true, false, true, 1, true)
  
  Citizen.Wait(5000)
  DeleteObject(L28_1)
  StopEntityAnim(playerPed, eatAnimDict, eatAnimName, 3)
  
  Citizen.Wait(1000)
  
  local drinkAnimDict = "mp_player_intdrink"
  local drinkAnimName = "loop_bottle"
  
  Functions.RequestAnimDict(drinkAnimDict)
  TaskPlayAnim(playerPed, drinkAnimDict, drinkAnimName, 2.0, 2.0, -1, 51, 0, false, false, false)
  
  local drinkBone = GetPedBoneIndex(playerPed, 18905)
  AttachEntityToEntity(L29_1, playerPed, drinkBone, 0.12, 0.008, 0.03, 240.0, -60.0, 0.0, true, true, false, true, 1, true)
  
  Citizen.Wait(5000)
  DeleteObject(L29_1)
  
  shouldContinue = true
  
  local exitPosition = playerStartPos + vec3(0.0, 0.0, -1.0)
  Citizen.Wait(0)
  ClearPedTasks(playerPed)
  SetEntityCoords(playerPed, exitPosition.x, exitPosition.y, exitPosition.z, true, false, false, false)
  FreezeEntityPosition(playerPed, false)
  SetEntityCollision(chairData.obj, true, true)
  
  Functions.DeleteEntity(L28_1)
  Functions.DeleteEntity(L29_1)
  Functions.DeleteEntity(foodTrayObject)
  
  Config.Restaurant.restoreStatus()
  TriggerServerEvent("gta5vn_miner:SeatNowFree", chairId)
end

RegisterNetEvent("gta5vn_miner:SeatTaken")
AddEventHandler("gta5vn_miner:SeatTaken", function(seatId)
  Config.Restaurant.objects[seatId].taken = true
end)

RegisterNetEvent("gta5vn_miner:SeatNowFree")
AddEventHandler("gta5vn_miner:SeatNowFree", function(seatId)
  Config.Restaurant.objects[seatId].taken = nil
end)

function TakeFoodTray()
  if not DoesEntityExist(foodTrayObject) then
    Functions.SpawnObject(Config.Restaurant.tray.model, function(trayObj)
      foodTrayObject = trayObj
      
      Functions.SpawnObject(Config.Restaurant.tray.burgerModel, function(burgerObj)
        L28_1 = burgerObj
        SetEntityCollision(burgerObj, false, false)
        FreezeEntityPosition(burgerObj, true)
        AttachEntityToEntity(burgerObj, foodTrayObject, 0, Config.Restaurant.tray.burgerOffset.x, Config.Restaurant.tray.burgerOffset.y, Config.Restaurant.tray.burgerOffset.z, 0.0, 0.0, 0.0, true, true, true, false, 2, true)
      end)
      
      Functions.SpawnObject(Config.Restaurant.tray.waterModel, function(waterObj)
        L29_1 = waterObj
        SetEntityCollision(waterObj, false, false)
        FreezeEntityPosition(waterObj, true)
        AttachEntityToEntity(waterObj, foodTrayObject, 0, Config.Restaurant.tray.waterOffset.x, Config.Restaurant.tray.waterOffset.y, Config.Restaurant.tray.waterOffset.z, 0.0, 0.0, 0.0, true, true, true, false, 2, true)
      end)
      
      AttachEntityToEntity(trayObj, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), Config.Restaurant.tray.wearingAnim.trayOffset.x, Config.Restaurant.tray.wearingAnim.trayOffset.y, Config.Restaurant.tray.wearingAnim.trayOffset.z, Config.Restaurant.tray.wearingAnim.trayRotation.x, Config.Restaurant.tray.wearingAnim.trayRotation.y, Config.Restaurant.tray.wearingAnim.trayRotation.z, true, true, false, true, 2, true)
    end, GetEntityCoords(PlayerPedId()), true, true)
    
    carriedObject = foodTrayObject
    CarringAnim()
  end
end

local PreviousHatIndex = 0
local PreviousHatTexture = 0
-- HaveGear đã được khai báo ở đầu file (line 42), không cần khai báo lại

function ToggleGear()
  RequestAnimDict("clothingshirt")
  
  while true do
    if HasAnimDictLoaded("clothingshirt") then
      break
    end
    Wait(0)
  end
  
  TaskPlayAnim(PlayerPedId(), "clothingshirt", "try_shirt_positive_d", 8.0, 1.0, -1, 49, 0, false, false, false)
  Wait(1000)
  
  local playerPed = PlayerPedId()
  
  if not HaveGear then
    local model = 1885822738
    RequestModel(model)
    
    while true do
      if HasModelLoaded(model) then
        break
      end
      Wait(0)
    end
    
    headlampObject = CreateObject(model, 1.0, 1.0, 1.0, true, true, false)
    SetEntityCollision(headlampObject, false, false)
    AttachEntityToEntity(headlampObject, playerPed, GetPedBoneIndex(playerPed, 24818), 0.18, -0.05, 0.0, -180.0, 90.0, 0.0, true, true, false, false, 2, true)
  end
  
  HaveGear = not HaveGear
  SetEnableScubaGearLight(playerPed, HaveGear)
  TriggerServerEvent("gta5vn_miner:ToggleLightState", HaveGear)
  
  Wait(1000)
  ClearPedTasks(playerPed)
  
  local lightOn = true
  local lastToggleTime = GetGameTimer()
  local toggleHintDuration = 10000
  
  CreateThread(function()
    while true do
      if not HaveGear then
        break
      end
      
      local ped = PlayerPedId()
      
      if (GetGameTimer() - lastToggleTime) < toggleHintDuration then
        ShowHelpNotification(Config.Lang.lightToggle)
      end
      
      if IsControlJustReleased(0, Config.LightToggleButton) then
        lightOn = not lightOn
        SetEnableScubaGearLight(ped, lightOn)
        TriggerServerEvent("gta5vn_miner:ToggleLightState", lightOn)
      end
      
      AttachEntityToEntity(headlampObject, ped, GetPedBoneIndex(ped, 24818), 0.18, -0.05, 0.0, -180.0, 90.0, 0.0, true, true, false, false, 2, true)
      
      Citizen.Wait(0)
    end
    
    DeleteEntity(headlampObject)
  end)
end

RegisterNetEvent("gta5vn_miner:ToggleLightState")
AddEventHandler("gta5vn_miner:ToggleLightState", function(netId, state)
  local entity = NetworkGetEntityFromNetworkId(netId)
  
  if 0 ~= entity or entity ~= netId then
    local model = GetEntityModel(entity)
    
    if 1885233650 ~= model then
      if -1667301416 ~= model then
        return
      end
    end
    
    SetEnableScubaGearLight(entity, state)
  end
end)