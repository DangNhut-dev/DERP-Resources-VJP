local callbacks = {}
local callbackIdCounter = 0

Functions.SpawnedObjects = {}

Functions.BoneNames = {
    SKEL_R_HAND = 57005,
    SKEL_L_HAND = 18905,
    SKEL_HEAD = 12844,
    PH_R_HAND = 28422,
}

function Functions.LoadModel(model)
    if HasModelLoaded(model) then
        return
    end
    RequestModel(model)
    while true do
        if HasModelLoaded(model) then
            break
        end
        Wait(0)
    end
end

function Functions.RequestAnimDict(dict)
    if HasAnimDictLoaded(dict) then
        return
    end
    RequestAnimDict(dict)
    while true do
        if HasAnimDictLoaded(dict) then
            break
        end
        Wait(0)
    end
end

function Functions.SpawnVehicle(model, coords, warpIntoVehicle)
    Functions.LoadModel(model)
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetVehRadioStation(vehicle, "OFF")
    SetVehicleFuelLevel(vehicle, 100.0)
    if warpIntoVehicle then
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    end
    local timeout = 100
    while not DoesEntityExist(vehicle) and timeout > 0 do
        Citizen.Wait(100)
        timeout = timeout - 1
    end
    return vehicle
end

function Functions.RequestControlOfEntity(entity)
    local deadline = GetGameTimer() + 50
    while true do
        if NetworkHasControlOfEntity(entity) then
            break
        end
        if not (deadline > GetGameTimer()) then
            break
        end
        NetworkRequestControlOfEntity(entity)
        Citizen.Wait(0)
    end
    return NetworkHasControlOfEntity(entity)
end

function Functions.SpawnObject(model, onSpawnedCb, coords, isNetworked, isFrozen, NoCollisions, migrateControl, invisible)
    local ped = PlayerPedId()
    if type(model) == "string" then
        model = GetHashKey(model) or model
    end
    if not IsModelInCdimage(model) then
        return Functions.Error("CAN'T SPAWN OBJECT BECAUSE MODEL DOESNT EXIST: " .. model)
    end
    if coords then
        if type(coords) == "table" then
            coords = vec3(coords.x, coords.y, coords.z) or coords
        end
    else
        coords = GetEntityCoords(ped)
    end
    if isNetworked == nil then
        isNetworked = true
    end
    if isFrozen == nil then
        isFrozen = true
    end
    Functions.LoadModel(model)
    local obj = CreateObjectNoOffset(model, coords.x, coords.y, coords.z, isNetworked, true, true)
    if isNetworked and migrateControl then
        SetNetworkIdExistsOnAllMachines(ObjToNet(obj), true)
        SetNetworkIdCanMigrate(ObjToNet(obj), false)
        N_0x0379daf89ba09aa5(obj, true)
    end
    if invisible then
        SetEntityVisible(obj, false, true)
    end
    if isNetworked and NoCollisions then
        SetEntityCollision(obj, false, false)
    end
    if type(coords) == "vector4" then
        SetEntityHeading(obj, coords.w)
    end
    Functions.SpawnedObjects[tostring(obj)] = true
    FreezeEntityPosition(obj, isFrozen)
    SetEntityLodDist(obj, 500)
    if onSpawnedCb then
        onSpawnedCb(obj)
    end
    return obj
end

function Functions.DeleteEntity(entity)
    if entity == nil then
        return Functions.Error("ATTEMPTED TO DELETE A NIL OBJECT")
    end
    if type(entity) ~= "number" then
        return Functions.Error("ATTEMPTED TO DELETE A " .. type(entity) .. " TYPE: " .. entity)
    end
    DetachEntity(entity, false, false)
    SetEntityAsMissionEntity(entity, false, true)
    DeleteObject(entity)
    Functions.SpawnedObjects[tostring(entity)] = nil
end

function Functions.IsSpawnPointClear(coords)
    local checkPoint = vec3(coords.x, coords.y, coords.z)
    local pool = GetGamePool("CVehicle")
    if pool ~= nil then
        if type(pool) == "table" then
            goto iteratePool
        end
    end
    print("FAILED TO FETCH GAMEPOOL - Returning CLEAR")
    do return true end
    ::iteratePool::
    for _, veh in pairs(pool) do
        if #(GetEntityCoords(veh) - checkPoint) < 6.0 then
            return false
        end
    end
    return true
end

function Functions.TriggerServerCallback(name, cb, ...)
    callbackIdCounter = callbackIdCounter + 1
    local requestId = callbackIdCounter
    callbacks[name] = callbacks[name] or {}
    callbacks[name][requestId] = cb
    TriggerServerEvent("17mov_Callbacks:GetResponse" .. GetCurrentResourceName(), name, requestId, ...)
end

RegisterNetEvent("17mov_Callbacks:receiveData" .. GetCurrentResourceName(), function(name, requestId, ...)
    if callbacks[name] ~= nil then
        if callbacks[name][requestId] ~= nil then
            goto invoke
        end
    end
    do return end
    ::invoke::
    callbacks[name][requestId](...)
    if callbacks[name] ~= nil then
        if callbacks[name][requestId] ~= nil then
            callbacks[name][requestId] = nil
        end
    end
    if callbacks[name] ~= nil then
        if #callbacks[name] == 0 then
            callbacks[name] = nil
        end
    end
end)

RegisterNetEvent("onResourceStop", function(stoppedResource)
    if GetCurrentResourceName() ~= stoppedResource then
        return
    end
    for key, _ in pairs(Functions.SpawnedObjects) do
        local entity = tonumber(key)
        if entity then
            if DoesEntityExist(entity) then
                DeleteEntity(entity)
            end
        end
    end
end)

function Functions.GetBoneIndexByName(ped, boneName)
    local boneId = Functions.BoneNames[boneName]
    if boneId == nil then
        return Functions.Print("Attempted to get bone by name but this bone was never mapped")
    end
    return GetPedBoneIndex(ped, boneId)
end

Functions.IsInAnim = false

function Functions.StartScene(sceneInfo, sceneObjects, stageIndex, onDoneCb, progressPercent)
    local scene = {
        ready = false,
        originPoint = sceneInfo,
        objects = sceneObjects,
    }
    local upVec = vec3(0, 0, 1)
    local forwardVec = nil
    local rightVec = nil
    Functions.SpawnObject("p_car_keys_01", function(tmpObj)
        SetEntityRotation(tmpObj, sceneInfo.rotation.x, sceneInfo.rotation.y, sceneInfo.rotation.z, 2, false)
        local rightM, forwardM = GetEntityMatrix(tmpObj)
        rightVec = forwardM
        forwardVec = rightM
        Functions.DeleteEntity(tmpObj)
    end, sceneInfo.coords, false, true)

    local spawnedObjectsList = {}
    for _, sceneObj in pairs(scene.objects) do
        if not sceneObj.object then
            local worldCoords = sceneInfo.coords
                + forwardVec * sceneObj.offset.y
                + rightVec * sceneObj.offset.x
                + upVec * sceneObj.offset.z
            Functions.SpawnObject(sceneObj.model, function(newObj)
                local heading = nil
                if sceneObj.rotation == nil then
                    sceneObj.rotation = vec3(0, 0, 0)
                end
                if sceneObj.rotationRelativeTo then
                    local relObj = scene.objects[sceneObj.rotationRelativeTo].object
                    if relObj == nil then
                        return Functions.Print("Attempted to make relative rotation but the relative object doesn't exist yet.")
                    end
                    heading = (GetEntityHeading(relObj) + sceneObj.rotation.y) % 360.0
                else
                    if sceneObj.rotation then
                        local dir = worldCoords - sceneInfo.coords
                        heading = (GetHeadingFromVector_2d(dir.x, dir.y) + sceneObj.rotation.y) % 360
                    end
                end
                SetEntityHeading(newObj, heading)
                sceneObj.object = newObj
                sceneObj.type = "object"
                sceneObj.ready = true
                if sceneObj.isNetworked then
                    Entity(newObj).state:set("GarbageBlock", true, true)
                else
                    spawnedObjectsList[#spawnedObjectsList + 1] = {
                        model = sceneObj.model,
                        coords = GetEntityCoords(newObj),
                        rotation = GetEntityRotation(newObj, 2),
                        isFrozen = sceneObj.isFrozen,
                        NoCollisions = sceneObj.NoCollisions,
                    }
                    Entity(newObj).state:set("GarbageBlock", true, false)
                end
            end, worldCoords, sceneObj.isNetworked, sceneObj.isFrozen, sceneObj.NoCollisions)
        else
            if sceneObj.object then
                local pos = GetEntityCoords(sceneObj.object)
                local adjust = vec3(0.0, 0.0, 0.0)
                if type(sceneObj.object) == "string" then
                    if sceneObj.object == "PlayerPed" then
                        sceneObj.object = PlayerPedId()
                        sceneObj.type = "ped"
                        adjust = vec3(0.0, 0.0, -1.0)
                        pos = GetEntityCoords(sceneObj.object) + adjust
                    end
                end
                sceneObj.ready = true
            end
        end
        if not sceneObj.type then
            sceneObj.type = "object"
        end
        if sceneObj.animDict then
            if not sceneObj.IsSceneObject then
                Functions.RequestAnimDict(sceneObj.animDict)
            end
        end
    end

    while true do
        if scene.ready then
            break
        end
        local allReady = true
        for _, sceneObj in pairs(scene.objects) do
            if not sceneObj.ready then
                allReady = false
                break
            end
        end
        if allReady then
            scene.ready = true
            scene.playing = true
            scene.startTime = GetGameTimer()
        end
        Wait(10)
    end

    local syncAnimTime = nil
    local pendingAttachments = 0
    local pendingStopFrames = 0
    local playingAnimList = {}
    local mainPedAnim = {}
    for _, sceneObj in pairs(scene.objects) do
        if sceneObj.object then
            if sceneObj.animDict then
                if sceneObj.animClip then
                    if sceneObj.type == "object" then
                        if sceneObj.IsSceneObject then
                            local objCoords = GetEntityCoords(sceneObj.object)
                            local closestPlayers = GetClosestPlayers(objCoords, 168.0)
                            while not syncAnimTime do
                                Wait(1)
                            end
                            TriggerServerEvent("17mov_GarbageCollector:server:GarbageAnim",
                                closestPlayers, ObjToNet(sceneObj.object), syncAnimTime, stageIndex, spawnedObjectsList, progressPercent)
                        else
                            Functions.RequestAnimDict(sceneObj.animDict)
                            PlayEntityAnim(sceneObj.object, sceneObj.animClip, sceneObj.animDict, 2.0, false, false, false, 0, 0)
                        end
                    else
                        if sceneObj.stayInLastFrame then
                            sceneObj.flag = sceneObj.flag + 2
                        end
                        Citizen.CreateThread(function()
                            mainPedAnim = {
                                obj = sceneObj.object,
                                dict = sceneObj.animDict,
                                clip = sceneObj.animClip,
                            }
                            Functions.RequestAnimDict(sceneObj.animDict)
                            TaskPlayAnim(sceneObj.object, sceneObj.animDict, sceneObj.animClip,
                                2.0, 2.0, sceneObj.duration or -1, sceneObj.flag or 0, 0.0, false, false, false)
                            syncAnimTime = GetNetworkTimeAccurate()
                        end)
                    end
                    playingAnimList[#playingAnimList + 1] = {
                        obj = sceneObj.object,
                        dict = sceneObj.animDict,
                        clip = sceneObj.animClip,
                    }
                end
            end
        end
        if sceneObj.attachment then
            pendingAttachments = pendingAttachments + 1
            local parentObj = scene.objects[sceneObj.attachment.attachToIndex]
            local parentDuration = GetAnimDuration(parentObj.animDict, parentObj.animClip)
            local totalFrames = parentDuration * 30
            sceneObj.attachment.time = sceneObj.attachment.atFrame / totalFrames
        end
        if sceneObj.stopAtFrame then
            pendingStopFrames = pendingStopFrames + 1
            local animDuration = GetAnimDuration(sceneObj.animDict, sceneObj.animClip)
            local totalFrames = animDuration * 30
            sceneObj.stopTime = sceneObj.stopAtFrame / totalFrames
        end
    end

    local confirmedPlaying = {}
    local animWaitTimeout = 5000
    local animWaitStart = GetGameTimer()
    while #confirmedPlaying < #playingAnimList do
        if not (animWaitTimeout > GetGameTimer() - animWaitStart) then
            break
        end
        for i = 1, #playingAnimList, 1 do
            if DoesEntityExist(playingAnimList[i].obj) then
                if IsEntityPlayingAnim(playingAnimList[i].obj, playingAnimList[i].dict, playingAnimList[i].clip, 3) then
                    if not confirmedPlaying[i] then
                        confirmedPlaying[i] = true
                    end
                end
            end
        end
        Wait(30)
    end
    if #confirmedPlaying < #playingAnimList then
        onDoneCb(scene, false)
        return print("FATAL ERROR WHILE WAITING FOR ANIMATIONS")
    end

    CreateThread(function()
        local finishedNormally = true
        while true do
            if not scene.playing then
                break
            end
            Citizen.Wait(0)
            local anyAnimRunning = false
            local now = GetGameTimer()
            for _, sceneObj in pairs(scene.objects) do
                if sceneObj.object then
                    if sceneObj.animDict then
                        if sceneObj.animClip then
                            local durMs = GetAnimDuration(sceneObj.animDict, sceneObj.animClip) * 1000
                            if durMs > now - scene.startTime then
                                anyAnimRunning = true
                            end
                        end
                    end
                end
            end
            if anyAnimRunning then
                if not IsEntityPlayingAnim(mainPedAnim.obj, mainPedAnim.dict, mainPedAnim.clip, 3) then
                    anyAnimRunning = false
                    finishedNormally = false
                end
            end
            if not anyAnimRunning then
                scene.playing = false
            end
            DisableAllControlActions(0)
            EnableControlAction(0, 0, true)
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
        end
        for _, sceneObj in pairs(scene.objects) do
            if sceneObj.isFrozen then
                if sceneObj.object then
                    if not sceneObj.IsSceneObject then
                        FreezeEntityPosition(sceneObj.object, false)
                    end
                end
            end
            if sceneObj.destroy then
                Functions.DeleteEntity(sceneObj.object)
            end
        end
        if onDoneCb then
            onDoneCb(scene, finishedNormally)
        end
    end)

    while pendingAttachments > 0 or pendingStopFrames > 0 do
        if not scene.playing then
            break
        end
        for _, sceneObj in pairs(scene.objects) do
            if sceneObj.attachment then
                if sceneObj.attachment.attachToIndex then
                    if not sceneObj.attachment.attached then
                        local parentObj = scene.objects[sceneObj.attachment.attachToIndex]
                        if parentObj then
                            if parentObj.animDict then
                                if parentObj.animClip then
                                    local curTime = GetEntityAnimCurrentTime(parentObj.object, parentObj.animDict, parentObj.animClip)
                                    if curTime >= sceneObj.attachment.time then
                                        local boneIndex = Functions.GetBoneIndexByName(parentObj.object, sceneObj.attachment.bone)
                                        if boneIndex ~= nil then
                                            AttachEntityToEntity(
                                                sceneObj.object, parentObj.object, boneIndex,
                                                sceneObj.attachment.offset.x, sceneObj.attachment.offset.y, sceneObj.attachment.offset.z,
                                                sceneObj.attachment.rotation.x, sceneObj.attachment.rotation.y, sceneObj.attachment.rotation.z,
                                                true, true, sceneObj.attachment.collision or false,
                                                true, 1, sceneObj.attachment.syncRot
                                            )
                                            sceneObj.attachment.attached = true
                                            pendingAttachments = pendingAttachments - 1
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if sceneObj.stopAtFrame then
                local curTime = GetEntityAnimCurrentTime(sceneObj.object, sceneObj.animDict, sceneObj.animClip)
                if curTime >= sceneObj.stopTime then
                    SetEntityAnimCurrentTime(sceneObj.object, sceneObj.animDict, sceneObj.animClip, sceneObj.stopTime)
                end
            end
        end
        Wait(0)
    end
end

Config.Scenes = {
    [1] = {
        Models = {
            "prop_dumpster_01a",
            "prop_dumpster_02a",
            "prop_dumpster_02b",
        },
        Distance = 1.5,
        DrawTextOffset = vec3(0.0, -0.5, 1.3),
        Stages = {
            [1] = {
                PlayerOffset = vec3(0.0, -0.92, 0.0),
                Objects = {
                    [1] = {
                        object = "PlayerPed",
                        isFrozen = true,
                        lerpDuration = 1000,
                        animDict = "17mov_garbage",
                        animClip = "ped_dumpster_01a_1",
                        isLooped = false,
                        stayInLastFrame = false,
                        flag = 32,
                        destroy = false,
                    },
                    [2] = {
                        object = "SceneModel",
                        isNetworked = false,
                        isFrozen = true,
                        offset = vec3(0.0, 0.0, 0.0),
                        animDict = "17mov_garbage",
                        animClip = "prop_dumpster_01a_1",
                        isLooped = false,
                        stayInLastFrame = false,
                        destroy = false,
                    },
                    [3] = {
                        model = "prop_rub_binbag_08",
                        isNetworked = true,
                        isFrozen = true,
                        NoCollisions = true,
                        offset = vec3(0.408, 0.646, 0.8200000000000001),
                        rotation = vec3(0, 0, 0),
                        rotationRelativeTo = 2,
                        destroy = false,
                        attachment = {
                            offset = vec3(0.0, 0.0, 0.0),
                            rotation = vec3(0.0, 0.0, 0.0),
                            attachToIndex = 1,
                            atFrame = 75,
                            bone = "PH_R_HAND",
                            syncRot = true,
                        },
                    },
                    [4] = {
                        model = "prop_rub_binbag_06",
                        isNetworked = false,
                        isFrozen = true,
                        NoCollisions = true,
                        offset = vec3(-0.333861, 0.737725, 0.7),
                        rotation = vec3(0.0, 0.0, 0.0),
                        rotationRelativeTo = 2,
                        destroy = true,
                    },
                    [5] = {
                        model = "prop_rub_binbag_06",
                        isNetworked = false,
                        isFrozen = true,
                        NoCollisions = true,
                        offset = vec3(-0.577896, 0.975279, 0.722757),
                        rotation = vec3(0.0, 0.0, 0.0),
                        rotationRelativeTo = 2,
                        destroy = true,
                    },
                    [6] = {
                        model = "prop_rub_binbag_08",
                        isNetworked = false,
                        isFrozen = true,
                        NoCollisions = true,
                        offset = vec3(-0.021977, 1.01418, 0.817227),
                        rotation = vec3(0.0, 0.0, 0.0),
                        rotationRelativeTo = 2,
                        destroy = true,
                    },
                    [7] = {
                        model = "prop_rub_binbag_06",
                        isNetworked = false,
                        isFrozen = true,
                        NoCollisions = true,
                        offset = vec3(0.446679, 1.15301, 0.722757),
                        rotation = vec3(0.0, 0.0, 0.0),
                        rotationRelativeTo = 2,
                        destroy = true,
                    },
                },
            },
            [2] = {
                PlayerOffset = vec3(0.0, -0.92, 0.0),
                Objects = {
                    [1] = {
                        object = "PlayerPed",
                        isFrozen = true,
                        lerpDuration = 1000,
                        animDict = "17mov_garbage",
                        animClip = "ped_dumpster_01a_2",
                        isLooped = false,
                        stayInLastFrame = false,
                        flag = 32,
                        destroy = false,
                    },
                    [2] = {
                        object = "SceneModel",
                        isNetworked = false,
                        isFrozen = true,
                        offset = vec3(0.0, 0.0, 0.0),
                        animDict = "17mov_garbage",
                        animClip = "prop_dumpster_01a_2",
                        isLooped = false,
                        stayInLastFrame = false,
                        destroy = false,
                    },
                    [3] = {
                        model = "prop_rub_binbag_06",
                        isNetworked = true,
                        isFrozen = true,
                        NoCollisions = true,
                        offset = vec3(-0.333861, 0.737725, 0.7),
                        rotation = vec3(0.0, 0.0, 0.0),
                        rotationRelativeTo = 2,
                        destroy = false,
                        attachment = {
                            offset = vec3(0.0, 0.0, 0.0),
                            rotation = vec3(0.0, 0.0, 0.0),
                            attachToIndex = 1,
                            atFrame = 83,
                            bone = "PH_R_HAND",
                            syncRot = true,
                        },
                    },
                    [4] = {
                        model = "prop_rub_binbag_06",
                        isNetworked = false,
                        isFrozen = true,
                        NoCollisions = true,
                        offset = vec3(-0.577896, 0.975279, 0.722757),
                        rotation = vec3(0.0, 0.0, 0.0),
                        rotationRelativeTo = 2,
                        destroy = true,
                    },
                    [5] = {
                        model = "prop_rub_binbag_08",
                        isNetworked = false,
                        isFrozen = true,
                        NoCollisions = true,
                        offset = vec3(-0.021977, 1.01418, 0.817227),
                        rotation = vec3(0.0, 0.0, 0.0),
                        rotationRelativeTo = 2,
                        destroy = true,
                    },
                    [6] = {
                        model = "prop_rub_binbag_06",
                        isNetworked = false,
                        isFrozen = true,
                        NoCollisions = true,
                        offset = vec3(0.446679, 1.15301, 0.722757),
                        rotation = vec3(0.0, 0.0, 0.0),
                        rotationRelativeTo = 2,
                        destroy = true,
                    },
                },
            },
            [3] = {
                PlayerOffset = vec3(0.0, -0.89, 0.0),
                Objects = {
                    [1] = {
                        object = "PlayerPed",
                        isFrozen = true,
                        lerpDuration = 1000,
                        animDict = "17mov_garbage",
                        animClip = "ped_dumpster_01a_3",
                        isLooped = false,
                        stayInLastFrame = false,
                        flag = 32,
                        destroy = false,
                    },
                    [2] = {
                        object = "SceneModel",
                        isNetworked = false,
                        isFrozen = true,
                        offset = vec3(0.0, 0.0, 0.0),
                        animDict = "17mov_garbage",
                        animClip = "prop_dumpster_01a_3",
                        isLooped = false,
                        stayInLastFrame = false,
                        destroy = false,
                    },
                    [3] = {
                        model = "prop_rub_binbag_06",
                        isNetworked = true,
                        isFrozen = true,
                        NoCollisions = true,
                        offset = vec3(-0.577896, 0.975279, 0.722757),
                        rotation = vec3(0.0, 0.0, 0.0),
                        rotationRelativeTo = 2,
                        destroy = false,
                        attachment = {
                            offset = vec3(0.0, 0.0, 0.0),
                            rotation = vec3(0.0, 0.0, 0.0),
                            attachToIndex = 1,
                            atFrame = 85,
                            bone = "PH_R_HAND",
                            syncRot = true,
                        },
                    },
                    [4] = {
                        model = "prop_rub_binbag_08",
                        isNetworked = false,
                        isFrozen = true,
                        offset = vec3(-0.021977, 1.01418, 0.817227),
                        rotation = vec3(0.0, 0.0, 0.0),
                        NoCollisions = true,
                        rotationRelativeTo = 2,
                        destroy = true,
                    },
                    [5] = {
                        model = "prop_rub_binbag_06",
                        isNetworked = false,
                        isFrozen = true,
                        offset = vec3(0.446679, 1.15301, 0.722757),
                        rotation = vec3(0.0, 0.0, 0.0),
                        rotationRelativeTo = 2,
                        NoCollisions = true,
                        destroy = true,
                    },
                },
            },
            [4] = {
                PlayerOffset = vec3(0.0, -0.75, 0.0),
                Objects = {
                    [1] = {
                        object = "PlayerPed",
                        isFrozen = true,
                        lerpDuration = 1000,
                        animDict = "17mov_garbage",
                        animClip = "ped_dumpster_01a_4",
                        isLooped = false,
                        stayInLastFrame = false,
                        flag = 32,
                        destroy = false,
                    },
                    [2] = {
                        object = "SceneModel",
                        isNetworked = false,
                        isFrozen = true,
                        offset = vec3(0.0, 0.0, 0.0),
                        animDict = "17mov_garbage",
                        animClip = "prop_dumpster_01a_4",
                        isLooped = false,
                        stayInLastFrame = false,
                        destroy = false,
                    },
                    [3] = {
                        model = "prop_rub_binbag_08",
                        isNetworked = true,
                        isFrozen = true,
                        offset = vec3(-0.021977, 0.751418, 0.817227),
                        rotation = vec3(0.0, 0.0, 0.0),
                        rotationRelativeTo = 2,
                        NoCollisions = true,
                        destroy = false,
                        attachment = {
                            offset = vec3(0.0, 0.0, 0.0),
                            rotation = vec3(0.0, 0.0, 0.0),
                            attachToIndex = 1,
                            atFrame = 89,
                            bone = "PH_R_HAND",
                            syncRot = true,
                            collision = false,
                        },
                    },
                    [4] = {
                        model = "prop_rub_binbag_06",
                        isNetworked = false,
                        isFrozen = true,
                        NoCollisions = true,
                        offset = vec3(0.446679, 1.15301, 0.722757),
                        rotation = vec3(0.0, 0.0, 0.0),
                        rotationRelativeTo = 2,
                        destroy = true,
                    },
                },
            },
            [5] = {
                PlayerOffset = vec3(0.0, -0.75, 0.0),
                Objects = {
                    [1] = {
                        object = "PlayerPed",
                        isFrozen = true,
                        lerpDuration = 1000,
                        animDict = "17mov_garbage",
                        animClip = "ped_dumpster_01a_5",
                        isLooped = false,
                        stayInLastFrame = false,
                        flag = 32,
                        destroy = false,
                    },
                    [2] = {
                        object = "SceneModel",
                        isNetworked = false,
                        isFrozen = true,
                        offset = vec3(0.0, 0.0, 0.0),
                        animDict = "17mov_garbage",
                        animClip = "prop_dumpster_01a_5",
                        isLooped = false,
                        stayInLastFrame = false,
                        destroy = false,
                    },
                    [3] = {
                        model = "prop_rub_binbag_06",
                        isNetworked = true,
                        isFrozen = true,
                        offset = vec3(0.345628, 0.755058, 0.7297739999999999),
                        rotation = vec3(0.0, 0.0, 0.0),
                        rotationRelativeTo = 2,
                        destroy = false,
                        NoCollisions = true,
                        attachment = {
                            offset = vec3(0.0, 0.0, 0.0),
                            rotation = vec3(0.0, 0.0, 0.0),
                            attachToIndex = 1,
                            atFrame = 113,
                            bone = "PH_R_HAND",
                            syncRot = true,
                            collision = false,
                        },
                    },
                },
            },
            [6] = {
                PlayerOffset = vec3(0.0, -0.86, 0.0),
                Objects = {
                    [1] = {
                        object = "PlayerPed",
                        isFrozen = true,
                        lerpDuration = 1000,
                        animDict = "17mov_garbage",
                        animClip = "ped_dumpster_01a_6",
                        isLooped = false,
                        stayInLastFrame = false,
                        flag = 32,
                        destroy = false,
                    },
                    [2] = {
                        object = "SceneModel",
                        isNetworked = false,
                        isFrozen = true,
                        offset = vec3(0.0, 0.0, 0.0),
                        animDict = "17mov_garbage",
                        animClip = "prop_dumpster_01a_6",
                        isLooped = false,
                        stayInLastFrame = false,
                        destroy = false,
                    },
                },
            },
        },
    },
}
