local currentBoomboxId = nil
local monitorVisibleEntity = nil
local activeBoomboxId = nil
local isBusy = false
local _unused = nil
local lastDuiEntity = nil
local needsSync = true
local nuiObj = nil
local pendingImages = {}
local streamerMode = false
local txdName = "rm_boombox_monitor"
local runtimeTxd = CreateRuntimeTxd(txdName)
local boomboxes = {}
local contextOptions = {}

contextOptions[1] = {
    icon = "fa-solid fa-arrow-up-right-from-square",
    title = Strings.enter_url,
    description = Strings.enter_url_desc
}
contextOptions[2] = {
    icon = "fa-solid fa-xmark",
    title = Strings.remove_boombox,
    description = Strings.remove_boombox_desc
}

CreateThread(function()
    nuiObj = create3DNui("web/dist/index.html", 900, 1080, 2.0)
    if "default" == cfg.framework.targetScript then
        contextOptions[3] = {
            icon = "fa-solid fa-hand",
            title = Strings.take_in_hand,
            description = Strings.take_in_hand_desc
        }
    end
end)

function trim(str)
    return string.gsub(str, "^%s*(.-)%s*$", "%1")
end

function setNetworkObj(entity)
    if not NetworkGetEntityIsNetworked(entity) then
        while true do
            if NetworkGetEntityIsNetworked(entity) then
                break
            end
            NetworkRegisterEntityAsNetworked(entity)
            Wait(10)
        end
    end
end

function getBase64Image(url, callback)
    local id = #pendingImages + 1
    SendNUIMessage({
        type = "base64",
        url = url,
        id = id
    })
    pendingImages[id] = "waiting"
    while true do
        if "waiting" ~= pendingImages[id] then
            break
        end
        Wait(0)
    end
    local base64 = pendingImages[id]
    pendingImages[id] = nil
    if callback then
        callback(base64)
    else
        return base64
    end
end

function rotationToDirection(rotation)
    local zRad = math.rad(rotation.z)
    local xRad = math.rad(math.min(math.max(rotation.x, -30.0), 30.0))
    local cosX = math.abs(math.cos(xRad))
    return vector3(-math.sin(zRad) * cosX, math.cos(zRad) * cosX, math.sin(xRad))
end

function useBoombox(boomboxId)
    for index, option in pairs(contextOptions) do
        if 1 == index then
            option.onSelect = function()
                SendNUIMessage({
                    type = "ShowInput",
                    state = true
                })
                SetNuiFocus(true, true)
            end
        elseif 2 == index then
            option.onSelect = function()
                local animDict = "random@domestic"
                madCore.requestAnimDict(animDict)
                TaskPlayAnim(cache.ped, animDict, "pickup_low", 8.0, -8, 2000, 2, 0, 0, 0, 0)
                Wait(1000)
                TriggerServerEvent("boombox:server:removeBoombox", boomboxId)
                RemoveAnimDict(animDict)
            end
        elseif 3 == index then
            option.onSelect = function()
                takeInHand(boomboxId)
            end
        end
    end
    lib.registerContext({
        id = "rm_boombox",
        title = "Action",
        options = contextOptions
    })
    currentBoomboxId = boomboxId
    lib.showContext("rm_boombox")
end

function setFilterSound(boomboxEntity)
    local playerPed = cache.ped
    local frequency = 350
    if IsEntityInWater(playerPed) then
        frequency = 150
        nuiObj:msg({
            type = "SetFilter",
            filterType = "lowpass",
            frequency = frequency
        })
        return
    end
    if IsPedInAnyVehicle(playerPed) then
        local vehicle = GetVehiclePedIsIn(playerPed)
        local hasOpening = false
        for doorIndex = 0, 3, 1 do
            if IsVehicleWindowIntact(vehicle, doorIndex) then
                if not (GetVehicleDoorAngleRatio(vehicle, doorIndex) > 0) then
                    goto continue
                end
            end
            hasOpening = true
            break
            ::continue::
        end
        local filterType = "bandpass"
        if hasOpening then
            filterType = "notch"
        end
        nuiObj:msg({
            type = "SetFilter",
            filterType = filterType,
            frequency = frequency
        })
        return
    end
    if not HasEntityClearLosToEntity(boomboxEntity, playerPed, 17) then
        nuiObj:msg({
            type = "SetFilter",
            filterType = "lowpass",
            frequency = frequency
        })
        return
    end
    nuiObj:msg({
        type = "ResetFilter"
    })
end

function updateSound(boomboxEntity, maxDistance, maxVolume)
    local playerPed = cache.ped
    local camRot = GetGameplayCamRot(2)
    local forward = rotationToDirection(camRot)
    local boneIndex = GetEntityBoneIndexByName(playerPed, "BONETAG_HEAD")
    local pedRight, pedForward, pedUp, pedPos = GetEntityMatrix(playerPed)
    local boomRight, boomForward, boomUp, boomPos = GetEntityMatrix(boomboxEntity)
    local headPos
    if -1 ~= boneIndex then
        headPos = GetWorldPositionOfEntityBone(playerPed, boneIndex) or pedPos
    else
        headPos = pedPos
    end
    local position = boomPos + vector3(0.0, 0.1, 0.0)
    local orientation = (boomRight * -1) * vector3(1.0, 1.0, 1.0)
    nuiObj:msg({
        type = "UpdatePlayer",
        speakerData = {
            position = position,
            orientation = orientation,
            distance = #(headPos - position),
            up = pedUp,
            forward = forward,
            playerPosition = pedPos,
            maxDistance = maxDistance,
            maxVolume = maxVolume
        }
    })
end

function setFullScreen(boomboxId)
    if not boomboxes[boomboxId] then
        return
    end
    isBusy = true
    boomboxes[boomboxId].player.fullscreen = not boomboxes[boomboxId].player.fullscreen
    if boomboxes[boomboxId].player.fullscreen then
        if DoesEntityExist(boomboxes[boomboxId].monitor) then
            DeleteEntity(boomboxes[boomboxId].monitor)
        end
        local monitorModel = "prop_monitor_02"
        local boomboxEntity = NetToObj(boomboxes[boomboxId].data.netId)
        if not DoesEntityExist(boomboxEntity) then
            return madCore.debug("setFullScreen -> entity does not exist")
        end
        local boomboxCoords = GetEntityCoords(boomboxEntity)
        madCore.requestModel(monitorModel)
        local minDim, maxDim = GetModelDimensions(GetEntityModel(boomboxEntity))
        boomboxes[boomboxId].monitor = CreateObject(monitorModel, boomboxCoords, true, false, false)
        NetworkFadeInEntity(boomboxes[boomboxId].monitor, 6)
        SetEntityNoCollisionEntity(boomboxes[boomboxId].monitor, boomboxEntity, false)
        AttachEntityToEntity(boomboxes[boomboxId].monitor, boomboxEntity, -1, 0.0, 0.0, maxDim.z, 0.0, 0.0, 90.0, true, false, false, false, 2, true)
    end
    TriggerServerEvent("boombox:server:sync", {
        type = "fullscreen",
        boomboxId = boomboxId,
        monitor = boomboxes[boomboxId].monitor and ObjToNet(boomboxes[boomboxId].monitor) or nil,
        state = boomboxes[boomboxId].player.fullscreen
    })
    isBusy = false
end

function syncBoombox(boomboxId)
    if not boomboxes[boomboxId] then
        return madCore.debug("syncBoombox -> boombox does not exist")
    end
    if not boomboxes[boomboxId].data.netId then
        return madCore.debug("syncBoombox -> netId does not exist")
    end
    if not NetworkDoesNetworkIdExist(boomboxes[boomboxId].data.netId) then
        return madCore.debug("syncBoombox -> netId does not exist 2")
    end
    local boomboxEntity = NetToObj(boomboxes[boomboxId].data.netId)
    if not DoesEntityExist(boomboxEntity) then
        return madCore.debug("syncBoombox -> entity does not exist")
    end
    if not boomboxes[boomboxId].player then
        return madCore.debug("syncBoombox -> player does not exist")
    end
    if activeBoomboxId ~= boomboxId then
        return madCore.debug("syncBoombox -> not same Id")
    end
    nuiObj:msg({
        type = "Pause",
        state = boomboxes[boomboxId].player.playing
    })
    nuiObj:msg({
        type = "Loop",
        state = boomboxes[boomboxId].player.loop
    })
    nuiObj:msg({
        type = "SetVolume",
        volume = boomboxes[boomboxId].player.volume
    })
    if not boomboxes[boomboxId].player.fullscreen then
        if boomboxes[boomboxId].data.monitor then
            if NetworkDoesNetworkIdExist(boomboxes[boomboxId].data.monitor) then
                local monitorEntity = NetworkGetEntityFromNetworkId(boomboxes[boomboxId].data.monitor)
                if DoesEntityExist(monitorEntity) then
                    NetworkRequestControlOfEntity(monitorEntity)
                    DeleteEntity(monitorEntity)
                end
            end
        end
    end
    nuiObj:msg({
        type = "ExpandVideo",
        state = boomboxes[boomboxId].player.fullscreen
    })
    if boomboxes[boomboxId].player.fullscreen then
        if #boomboxes[boomboxId].queue > 0 then
            if boomboxes[boomboxId].image then
                boomboxes[boomboxId].texture = CreateRuntimeTextureFromImage(runtimeTxd, boomboxId, boomboxes[boomboxId].image)
                AddReplaceTexture("prop_monitor_02", "script_rt_tvscreen", txdName, boomboxId)
            else
                getBase64Image(boomboxes[boomboxId].queue[1].thumbnail, function(base64)
                    boomboxes[boomboxId].image = base64
                    boomboxes[boomboxId].texture = CreateRuntimeTextureFromImage(runtimeTxd, boomboxId, boomboxes[boomboxId].image)
                    AddReplaceTexture("prop_monitor_02", "script_rt_tvscreen", txdName, boomboxId)
                end)
            end
        end
    end
end

function attachVehicle(boomboxId, attachType)
    if not boomboxes[boomboxId] then
        return
    end
    if not NetworkDoesNetworkIdExist(boomboxes[boomboxId].data.netId) then
        return madCore.debug("attachVehicle -> netId does not exist")
    end
    local boomboxEntity = NetToObj(boomboxes[boomboxId].data.netId)
    if not DoesEntityExist(boomboxEntity) then
        return madCore.debug("attachVehicle -> entity does not exist")
    end
    local boomboxCfg = cfg.boomboxes[boomboxes[boomboxId].data.bType]
    if not boomboxCfg then
        return madCore.debug("attachVehicle -> config does not exist")
    end
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 5.0, false)
    if not DoesEntityExist(vehicle) then
        return madCore.showNotify(madCore.getPhrase("no_nearby_vehicle"))
    end
    if not NetworkDoesNetworkIdExist(VehToNet(vehicle)) then
        return madCore.debug("attachVehicle -> netId does not exist")
    end
    if "trunk" == attachType then
        if 0 == GetVehicleDoorAngleRatio(vehicle, 5) then
            return madCore.showNotify(madCore.getPhrase("boombox_vehicle_trunk_open"))
        end
    end
    isBusy = true
    local vehicleModel = GetEntityModel(vehicle)
    local offset = nil
    local rotation = nil
    local boneName = "chassis"
    if "trunk" == attachType then
        boneName = ""
        offset = (cfg.vehicleOffsets[vehicleModel] and cfg.vehicleOffsets[vehicleModel].trunkOffset) or vector3(0.0, -1.75, 0.15)
        rotation = (cfg.vehicleOffsets[vehicleModel] and cfg.vehicleOffsets[vehicleModel].trunkRotation) or vector3(0.0, 0.0, 270.0)
    elseif "chasis" == attachType then
        boneName = "chassis"
        local _minDim, maxDim = GetModelDimensions(vehicleModel)
        offset = (cfg.vehicleOffsets[vehicleModel] and cfg.vehicleOffsets[vehicleModel].vehicleOffset) or vector3(0.0, 0.0, maxDim.z - 0.2)
        rotation = (cfg.vehicleOffsets[vehicleModel] and cfg.vehicleOffsets[vehicleModel].vehicleRotation) or vector3(0.0, 0.0, 90.0)
    end
    local boneIndex = GetEntityBoneIndexByName(vehicle, boneName)
    if -1 == boneIndex then
        boneIndex = 0
    end
    TaskTurnPedToFaceEntity(cache.ped, vehicle, 500)
    local animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
    madCore.requestAnimDict(animDict)
    TaskPlayAnim(cache.ped, animDict, "machinic_loop_mechandplayer", 3.0, -2.0, 2000, 16, 0, 0, 0, 0)
    Wait(2000)
    AttachEntityToEntity(boomboxEntity, vehicle, boneIndex, offset, rotation, false, false, false, false, 2, true)
    madCore.hideTextUI()
    madCore.showNotify(madCore.getPhrase("boombox_vehicle_action"))
    boomboxes[boomboxId].onVehicle = trim(GetVehicleNumberPlateText(vehicle))
    boomboxes[boomboxId].onHand = false
    RemoveAnimDict(animDict)
    isBusy = false
end

function attachInHand(boomboxId)
    if not boomboxes[boomboxId] then
        return
    end
    if not NetworkDoesNetworkIdExist(boomboxes[boomboxId].data.netId) then
        return madCore.debug("attachVehicle -> netId does not exist")
    end
    local boomboxEntity = NetToObj(boomboxes[boomboxId].data.netId)
    if not DoesEntityExist(boomboxEntity) then
        return madCore.debug("attachVehicle -> entity does not exist")
    end
    local boomboxCfg = cfg.boomboxes[boomboxes[boomboxId].data.bType]
    if not boomboxCfg then
        return madCore.debug("attachVehicle -> config does not exist")
    end
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 5.0, false)
    if not DoesEntityExist(vehicle) then
        return madCore.showNotify(madCore.getPhrase("no_nearby_vehicle"))
    end
    local plate = trim(GetVehicleNumberPlateText(vehicle))
    if plate ~= boomboxes[boomboxId].onVehicle then
        return madCore.showNotify(madCore.getPhrase("boombox_vehicle_not_found"))
    end
    isBusy = true
    TaskTurnPedToFaceEntity(cache.ped, vehicle, 500)
    local animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
    madCore.requestAnimDict(animDict)
    TaskPlayAnim(cache.ped, animDict, "machinic_loop_mechandplayer", 3.0, -2.0, 2000, 16, 0, 0, 0, 0)
    Wait(2000)
    DetachEntity(boomboxEntity)
    AttachEntityToEntity(boomboxEntity, cache.ped, GetPedBoneIndex(cache.ped, 57005), boomboxCfg.handOffset, boomboxCfg.handRotation, true, true, false, false, 1, true)
    madCore.hideTextUI()
    madCore.showTextUI(madCore.getPhrase("boombox_hand_action"))
    RemoveAnimDict(animDict)
    isBusy = false
    boomboxes[boomboxId].onVehicle = nil
    boomboxes[boomboxId].onHand = true
end

function takeInHand(boomboxId)
    if not boomboxes[boomboxId] then
        return
    end
    if not NetworkDoesNetworkIdExist(boomboxes[boomboxId].data.netId) then
        return madCore.debug("takeInHand -> netId does not exist")
    end
    local boomboxEntity = NetToObj(boomboxes[boomboxId].data.netId)
    if not DoesEntityExist(boomboxEntity) then
        return madCore.debug("takeInHand -> entity does not exist")
    end
    local boomboxCfg = cfg.boomboxes[boomboxes[boomboxId].data.bType]
    if not boomboxCfg then
        return madCore.debug("takeInHand -> config does not exist")
    end
    boomboxes[boomboxId].onHand = true
    if boomboxes[boomboxId].data.monitor then
        if NetworkDoesNetworkIdExist(boomboxes[boomboxId].data.monitor) then
            local monitorEntity = NetworkGetEntityFromNetworkId(boomboxes[boomboxId].data.monitor)
            if DoesEntityExist(monitorEntity) then
                NetworkRequestControlOfEntity(monitorEntity)
                DeleteEntity(monitorEntity)
            end
        end
    end
    NetworkRequestControlOfEntity(boomboxEntity)
    TaskTurnPedToFaceEntity(cache.ped, boomboxEntity, 500)
    local animDict = "random@domestic"
    madCore.requestAnimDict(animDict)
    TaskPlayAnim(cache.ped, animDict, "pickup_low", 8.0, -8, 2000, 2, 0, 0, 0, 0)
    Wait(1000)
    AttachEntityToEntity(boomboxEntity, cache.ped, GetPedBoneIndex(cache.ped, 57005), boomboxCfg.handOffset, boomboxCfg.handRotation, true, true, false, false, 1, true)
    madCore.showTextUI(madCore.getPhrase("boombox_hand_action"))
    RemoveAnimDict(animDict)
end

function createBoombox(netId, boomboxId)
    while true do
        if boomboxes[boomboxId] then
            break
        end
        Wait(100)
    end
    while true do
        if NetworkDoesNetworkIdExist(netId) then
            break
        end
        Wait(100)
    end
    if not NetworkDoesNetworkIdExist(netId) then
        return madCore.debug("createBoombox -> netId does not exist")
    end
    local boomboxEntity = NetToObj(netId)
    if not DoesEntityExist(boomboxEntity) then
        return madCore.debug("createBoombox -> entity does not exist")
    end
    local boomboxCfg = cfg.boomboxes[boomboxes[boomboxId].data.bType]
    if not boomboxCfg then
        return madCore.debug("createBoombox -> config does not exist")
    end
    if "default" ~= cfg.framework.targetScript then
        madCore.addEntityTarget(boomboxEntity, {
            label = madCore.getPhrase("boombox_target_label"),
            canInteract = function()
                if not boomboxes[boomboxId] then
                    return false
                end
                if not boomboxes[boomboxId].data.disableOwner then
                    if boomboxes[boomboxId].data.owner ~= madCore.identifier then
                        return false
                    end
                end
                return true
            end,
            onSelect = function()
                useBoombox(boomboxId)
            end
        })
        madCore.addEntityTarget(boomboxEntity, {
            icon = "fa-solid fa-hand",
            label = madCore.getPhrase("boombox_take_in_hand"),
            canInteract = function()
                if not boomboxes[boomboxId] then
                    return false
                end
                if not boomboxCfg.canPutHand then
                    return false
                end
                if boomboxes[boomboxId].data.owner ~= madCore.identifier then
                    return false
                end
                if boomboxes[boomboxId].onHand then
                    return false
                end
                return true
            end,
            onSelect = function()
                takeInHand(boomboxId)
            end
        })
    end
    if GetEntityLodDist(boomboxEntity) < boomboxCfg.radius then
        SetEntityLodDist(boomboxEntity, boomboxCfg.radius)
    end
    if NetworkHasControlOfEntity(boomboxEntity) and not IsEntityAttached(boomboxEntity) then
        FreezeEntityPosition(boomboxEntity, true)
        SetEntityInvincible(boomboxEntity, true)
    end
    local boomboxCoords = GetEntityCoords(boomboxEntity)
    local _minDim, maxDim = GetModelDimensions(GetEntityModel(boomboxEntity))
    boomboxes[boomboxId].lastCoord = boomboxCoords
    boomboxes[boomboxId].zone = lib.zones.sphere({
        coords = boomboxCoords,
        radius = (boomboxCfg.radius or 30.0) + 10.0,
        debug = false,
        onEnter = function()
            local playerPed = cache.ped
            local playerCoords = GetEntityCoords(playerPed)
            local boomboxPos = GetEntityCoords(boomboxEntity)
            local distance = #(playerCoords - boomboxPos)
            local nearestId = boomboxId
            local nearestDist = distance
            for entryId, entry in pairs(boomboxes) do
                if entry then
                    if entry.data and entry.data.netId then
                        if NetworkDoesNetworkIdExist(entry.data.netId) then
                            local otherEntity = NetToObj(entry.data.netId)
                            if DoesEntityExist(otherEntity) then
                                local otherDist = #(playerCoords - GetEntityCoords(otherEntity))
                                if nearestDist > otherDist then
                                    nearestDist = otherDist
                                    nearestId = entryId
                                    activeBoomboxId = entryId
                                end
                            end
                        end
                    end
                end
            end
            while true do
                if NetworkDoesNetworkIdExist(netId) then
                    break
                end
                Wait(100)
            end
            if #boomboxes[nearestId].queue > 0 then
                nuiObj:msg({
                    type = "LoadVideo",
                    musics = boomboxes[nearestId].queue or {},
                    key = nearestId
                })
            end
            Wait(100)
            TriggerServerEvent("boombox:server:duration", nearestId)
            syncBoombox(nearestId)
            needsSync = true
        end,
        inside = function()
            local playerPed = cache.ped
            local playerCoords = GetEntityCoords(playerPed)
            local nearestId = nil
            local nearestDist = nil
            for entryId, entry in pairs(boomboxes) do
                if entry then
                    if entry.data and entry.data.netId then
                        if NetworkDoesNetworkIdExist(entry.data.netId) then
                            local otherEntity = NetToObj(entry.data.netId)
                            if DoesEntityExist(otherEntity) then
                                local otherDist = #(playerCoords - GetEntityCoords(otherEntity))
                                if not nearestDist or nearestDist > otherDist then
                                    nearestDist = otherDist
                                    nearestId = entryId
                                    activeBoomboxId = entryId
                                end
                            end
                        end
                    end
                end
            end
            if boomboxId ~= nearestId then
                return
            end
            if streamerMode then
                return
            end
            if nuiObj and nuiObj:visible() then
                if not monitorVisibleEntity then
                    nuiObj:hide()
                end
            end
            local nearestEntry = boomboxes[nearestId]
            if nearestEntry then
                local nearestObj = NetToObj(nearestEntry.data.netId)
                if lastDuiEntity ~= nearestObj then
                    if #nearestEntry.queue > 0 then
                        local _nMin, nMax = GetModelDimensions(GetEntityModel(NetToObj(nearestEntry.data.netId)))
                        nuiObj:attach({
                            entity = NetToObj(nearestEntry.data.netId),
                            offset = vec3(-0.1, 0.0, nMax.z * 0.3)
                        })
                        nuiObj:msg({
                            type = "ResetPlayer",
                            boomboxId = nearestId
                        })
                        Wait(100)
                        nuiObj:msg({
                            type = "LoadVideo",
                            musics = nearestEntry.queue,
                            key = nearestId
                        })
                    end
                    Wait(100)
                    TriggerServerEvent("boombox:server:duration", nearestId)
                    syncBoombox(nearestId)
                    needsSync = true
                    lastDuiEntity = NetToObj(nearestEntry.data.netId)
                end
                local nearestObj2 = NetToObj(nearestEntry.data.netId)
                if nearestObj2 then
                    if DoesEntityExist(nearestObj2) then
                        if #nearestEntry.queue > 0 then
                            if nearestEntry.player and nearestEntry.player.playing then
                                setFilterSound(nearestObj2)
                                updateSound(nearestObj2, boomboxCfg.radius, boomboxCfg.maxVolume)
                            end
                        end
                        local entityCoords = GetEntityCoords(nearestObj2)
                        local distToBoombox = #(entityCoords - playerCoords)
                        if distToBoombox < 5.0 then
                            if "default" == cfg.framework.targetScript then
                                local isOpen, currentText = lib.isTextUIOpen()
                                if not isOpen then
                                    if currentText ~= madCore.getPhrase("boombox_menu_action") then
                                        madCore.showTextUI(madCore.getPhrase("boombox_menu_action"))
                                    end
                                end
                            end
                            if "default" == cfg.framework.targetScript then
                                local canShowMenu = nearestEntry.data.owner == madCore.identifier or nearestEntry.data.disableOwner
                                if canShowMenu then
                                    if IsControlJustPressed(0, cfg.keybinds.actionKeys.boomboxMenu) then
                                        useBoombox(nearestId)
                                    end
                                end
                            end
                            if monitorVisibleEntity ~= nearestObj2 then
                                if next(nearestEntry.queue) then
                                    if needsSync then
                                        local _eMin, eMax = GetModelDimensions(GetEntityModel(nearestObj2))
                                        nuiObj:show(entityCoords.xyz, 2.0)
                                        nuiObj:attach({
                                            entity = nearestObj2,
                                            offset = vec3(-0.1, 0.0, eMax.z * 0.3)
                                        })
                                        monitorVisibleEntity = nearestObj2
                                    end
                                end
                            end
                            if not boomboxes[nearestId].onHand and IsControlJustPressed(0, cfg.keybinds.uiKeybinds.hide_ui.key) then
                                if not isBusy then
                                    isBusy = true
                                    needsSync = not needsSync
                                    if not needsSync then
                                        nuiObj:hide()
                                        monitorVisibleEntity = nil
                                    end
                                    isBusy = false
                                end
                            end
                            if boomboxes[nearestId].onHand or (boomboxes[nearestId].onVehicle and nearestEntry.data.owner == madCore.identifier) then
                                if IsControlJustPressed(0, cfg.keybinds.actionKeys.putDown) then
                                    if not isBusy then
                                        if not boomboxes[nearestId].onVehicle then
                                            isBusy = true
                                            local animDict = "random@domestic"
                                            madCore.requestAnimDict(animDict)
                                            TaskPlayAnim(cache.ped, animDict, "pickup_low", 8.0, -8, 2000, 2, 0, 0, 0, 0)
                                            Wait(1000)
                                            DetachEntity(nearestObj2)
                                            PlaceObjectOnGroundProperly(nearestObj2)
                                            FreezeEntityPosition(nearestObj2, true)
                                            local newCoords = GetEntityCoords(nearestObj2)
                                            local newHeading = GetEntityHeading(nearestObj2)
                                            TriggerServerEvent("boombox:server:updatePosition", {
                                                boomboxId = nearestId,
                                                coords = vector3(newCoords.x, newCoords.y, newCoords.z),
                                                heading = newHeading
                                            })
                                            RemoveAnimDict(animDict)
                                            madCore.hideTextUI()
                                            isBusy = false
                                            boomboxes[nearestId].onHand = false
                                            boomboxes[nearestId].onVehicle = nil
                                        end
                                    end
                                end
                                if boomboxes[nearestId].onHand and not boomboxes[nearestId].onVehicle then
                                    if IsControlJustPressed(0, cfg.keybinds.actionKeys.placeInVehicle) then
                                        if not isBusy then
                                            if boomboxCfg.canPutVehicle then
                                                attachVehicle(nearestId, "chasis")
                                            end
                                        end
                                    elseif IsControlJustPressed(0, cfg.keybinds.actionKeys.placeInTrunk) then
                                        if not isBusy then
                                            if boomboxCfg.canPutVehicle then
                                                attachVehicle(nearestId, "trunk")
                                            end
                                        end
                                    end
                                end
                                if boomboxes[nearestId].onVehicle then
                                    if IsControlJustPressed(0, cfg.keybinds.actionKeys.takeInHand) then
                                        if not isBusy then
                                            attachInHand(nearestId)
                                        end
                                    end
                                end
                            end
                            if #nearestEntry.queue > 0 then
                                local canControl = nearestEntry.data.owner == madCore.identifier or nearestEntry.data.disableOwner
                                if canControl then
                                    if not IsEntityAttached(nearestObj2) then
                                        if IsControlJustPressed(0, cfg.keybinds.uiKeybinds.fullscreen.key) then
                                            setFullScreen(nearestId)
                                        end
                                        if IsControlJustPressed(0, cfg.keybinds.uiKeybinds.pause.key) then
                                            isBusy = true
                                            TriggerServerEvent("boombox:server:sync", {
                                                boomboxId = nearestId,
                                                type = "pause"
                                            })
                                            isBusy = false
                                        end
                                        if IsControlJustPressed(0, cfg.keybinds.uiKeybinds.loop.key) then
                                            isBusy = true
                                            TriggerServerEvent("boombox:server:sync", {
                                                boomboxId = nearestId,
                                                type = "loop"
                                            })
                                            isBusy = false
                                        end
                                        if IsControlJustPressed(0, cfg.keybinds.uiKeybinds.f_seek.key) then
                                            isBusy = true
                                            TriggerServerEvent("boombox:server:sync", {
                                                boomboxId = nearestId,
                                                type = "seek",
                                                state = "forward"
                                            })
                                            isBusy = false
                                        end
                                        if IsControlJustPressed(0, cfg.keybinds.uiKeybinds.b_seek.key) then
                                            isBusy = true
                                            TriggerServerEvent("boombox:server:sync", {
                                                boomboxId = nearestId,
                                                type = "seek",
                                                state = "backward"
                                            })
                                            isBusy = false
                                        end
                                        if IsControlJustPressed(0, cfg.keybinds.uiKeybinds.skip.key) then
                                            isBusy = true
                                            TriggerServerEvent("boombox:server:sync", {
                                                boomboxId = nearestId,
                                                type = "skip"
                                            })
                                            isBusy = false
                                        end
                                        if IsControlJustPressed(0, cfg.keybinds.uiKeybinds.volume_up.key) then
                                            isBusy = true
                                            TriggerServerEvent("boombox:server:sync", {
                                                boomboxId = nearestId,
                                                type = "volume",
                                                state = true
                                            })
                                            isBusy = false
                                        end
                                        if IsControlJustPressed(0, cfg.keybinds.uiKeybinds.volume_down.key) then
                                            isBusy = true
                                            TriggerServerEvent("boombox:server:sync", {
                                                boomboxId = nearestId,
                                                type = "volume",
                                                state = false
                                            })
                                            isBusy = false
                                        end
                                    end
                                end
                            end
                        else
                            if "default" == cfg.framework.targetScript then
                                local isOpen, currentText = lib.isTextUIOpen()
                                if isOpen then
                                    if currentText == madCore.getPhrase("boombox_menu_action") then
                                        madCore.hideTextUI()
                                    end
                                end
                            end
                            if not (nuiObj:visible() and monitorVisibleEntity == nearestObj2) and not monitorVisibleEntity then
                                nuiObj:hide()
                                monitorVisibleEntity = nil
                            end
                        end
                    end
                end
            end
        end,
        onExit = function()
            RemoveReplaceTexture("prop_monitor_02", "script_rt_tvscreen")
            boomboxes[boomboxId].texture = nil
            if not (nuiObj:visible() and monitorVisibleEntity == boomboxEntity) and not monitorVisibleEntity then
                nuiObj:hide()
                monitorVisibleEntity = nil
            end
        end
    })
end

RegisterNetEvent("boombox:client:placeBoombox", function(bType)
    local boomboxCfg = cfg.boomboxes[bType]
    if not boomboxCfg then
        return
    end
    if not IsModelValid(boomboxCfg.propModel) then
        return madCore.debug("boombox model is not valid")
    end
    local playerPed = cache.ped
    local playerCoords = GetEntityCoords(playerPed)
    if not cfg.options.enableMultipleBoomboxes then
        for _entryId, entry in pairs(boomboxes) do
            if entry then
                if entry.data then
                    if NetworkDoesNetworkIdExist(entry.data.netId) then
                        local otherEntity = NetToObj(entry.data.netId)
                        if DoesEntityExist(otherEntity) then
                            local distance = #(playerCoords - GetEntityCoords(otherEntity))
                            if distance < cfg.boomboxes[entry.data.bType].radius then
                                return madCore.showNotify(madCore.getPhrase("boombox_cant_place_zone"))
                            end
                        end
                    end
                end
            end
        end
    end
    for _idx, zone in pairs(cfg.options.blacklistZones) do
        if #(playerCoords - zone.xyz) < zone.w then
            return madCore.showNotify(madCore.getPhrase("boombox_cant_place_zone"))
        end
    end
    local placeCoords = playerCoords + (GetEntityForwardVector(playerPed) * 1.5)
    local animDict = "random@domestic"
    madCore.requestAnimDict(animDict)
    madCore.requestModel(boomboxCfg.propModel)
    local boomboxEntity = CreateObject(boomboxCfg.propModel, placeCoords, false, false, false)
    while true do
        if DoesEntityExist(boomboxEntity) then
            break
        end
        Wait(100)
    end
    SetEntityAlpha(boomboxEntity, 150)
    AttachEntityToEntity(boomboxEntity, cache.ped, 0, 0.5, 1.5, -0.5, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    madCore.showTextUI(madCore.getPhrase("boombox_place_action"))
    local placed = false
    while true do
        if not DoesEntityExist(boomboxEntity) then
            break
        end
        if IsControlJustPressed(0, cfg.keybinds.actionKeys.placeBoombox) then
            DetachEntity(boomboxEntity)
            placed = true
            break
        else
            if IsControlJustPressed(0, cfg.keybinds.actionKeys.cancelAction) then
                if DoesEntityExist(boomboxEntity) then
                    DeleteEntity(boomboxEntity)
                end
                madCore.hideTextUI()
                placed = false
                return
            end
        end
        Wait(0)
    end
    if not placed then
        return
    end
    madCore.hideTextUI()
    setNetworkObj(boomboxEntity)
    while true do
        if NetworkDoesNetworkIdExist(ObjToNet(boomboxEntity)) then
            break
        end
        Wait(100)
    end
    PlaceObjectOnGroundProperly(boomboxEntity)
    FreezeEntityPosition(boomboxEntity, true)
    SetEntityHeading(boomboxEntity, GetEntityHeading(playerPed))
    SetEntityInvincible(boomboxEntity, true)
    TaskPlayAnim(playerPed, animDict, "pickup_low", 8.0, -8, 2000, 2, 0, 0, 0, 0)
    Wait(1000)
    ResetEntityAlpha(boomboxEntity)
    RemoveAnimDict(animDict)
    SetModelAsNoLongerNeeded(boomboxCfg.propModel)
    Wait(1000)
    local finalCoords = GetEntityCoords(boomboxEntity)
    local finalHeading = GetEntityHeading(boomboxEntity)
    TriggerServerEvent("boombox:server:placeBoombox", {
        netId = ObjToNet(boomboxEntity),
        bType = bType,
        coords = vector3(finalCoords.x, finalCoords.y, finalCoords.z),
        heading = finalHeading
    })
end)

RegisterNetEvent("boombox:client:removeBoombox", function(boomboxId)
    if not boomboxes[boomboxId] then
        return madCore.debug("removeBoombox -> boombox data does not exist")
    end
    if not NetworkDoesNetworkIdExist(boomboxes[boomboxId].data.netId) then
        return madCore.debug("removeBoombox -> netId does not exist")
    end
    local boomboxEntity = NetToObj(boomboxes[boomboxId].data.netId)
    local boomboxCoords = GetEntityCoords(boomboxEntity)
    local playerCoords = GetEntityCoords(cache.ped)
    local distance = #(boomboxCoords - playerCoords)
    local boomboxCfg = cfg.boomboxes[boomboxes[boomboxId].data.bType]
    if distance < boomboxCfg.radius then
        if nuiObj:visible() then
            nuiObj:hide()
            monitorVisibleEntity = nil
        end
        nuiObj:msg({
            type = "ResetPlayer",
            boomboxId = boomboxId
        })
        if "default" == cfg.framework.targetScript then
            local isOpen, currentText = lib.isTextUIOpen()
            if isOpen then
                if currentText == madCore.getPhrase("boombox_menu_action") then
                    madCore.hideTextUI()
                end
            end
        end
    end
    if boomboxes[boomboxId].data.monitor then
        if NetworkDoesNetworkIdExist(boomboxes[boomboxId].data.monitor) then
            local monitorEntity = NetworkGetEntityFromNetworkId(boomboxes[boomboxId].data.monitor)
            if DoesEntityExist(monitorEntity) then
                NetworkRequestControlOfEntity(monitorEntity)
                DeleteEntity(monitorEntity)
            end
        end
    end
    if DoesEntityExist(boomboxEntity) then
        DeleteEntity(boomboxEntity)
    end
    if boomboxes[boomboxId].zone then
        boomboxes[boomboxId].zone:remove()
    end
    boomboxes[boomboxId] = nil
    monitorVisibleEntity = nil
end)

RegisterNUICallback("playUrl", function(data, cb)
    SendNUIMessage({
        type = "ShowInput",
        state = false
    })
    SetNuiFocus(false, false)
    if not data.url then
        return madCore.debug("playUrl -> url does not exist")
    end
    if not currentBoomboxId then
        return madCore.debug("playUrl -> currentId does not exist")
    end
    if not boomboxes[currentBoomboxId] then
        return madCore.debug("playUrl -> boombox does not exist")
    end
    local queue = boomboxes[currentBoomboxId].queue or {}
    if #queue > 0 then
        for index = 1, #queue, 1 do
            if queue[index].url == data.url then
                return cb("ok")
            end
        end
    end
    TriggerServerEvent("boombox:server:enterUrl", {
        url = data.url,
        boomboxId = currentBoomboxId
    })
    cb("ok")
end)

RegisterNUICallback("closeInput", function(_data, cb)
    SendNUIMessage({
        type = "ShowInput",
        state = false
    })
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("returnB64", function(data, cb)
    pendingImages[data.id] = data.base64
    cb({})
end)

RegisterNUICallback("webConfig", function(_data, cb)
    cb({
        keybinds = cfg.keybinds.uiKeybinds,
        config = cfg.webConfig
    })
end)

RegisterNetEvent("boombox:client:duration", function(data)
    if not data then
        return madCore.debug("[duration] -> data does not exist")
    end
    if not boomboxes[data.boomboxId] then
        return madCore.debug("[duration] -> boombox does not exist")
    end
    nuiObj:msg({
        type = "SyncSeconds",
        seconds = data.elapsed,
        boomboxId = data.boomboxId
    })
end)

AddStateBagChangeHandler("updateBoombox", nil, function(_bagName, _key, value, _reserved, _replicated)
    if not value then
        return madCore.debug("[updateBoombox] -> value does not exist")
    end
    if not boomboxes[value.boomboxId] then
        madCore.debug("[updateBoombox] -> boombox does not exist. creating boombox.")
        boomboxes[value.boomboxId] = value.data
        return createBoombox(value.data.data.netId, value.boomboxId)
    end
    madCore.debug("[updateBoombox] -> updating boombox.")
    if not boomboxes[value.boomboxId] then
        return madCore.debug("[updateBoombox] -> boombox does not exist")
    end
    local newQueue = value.data.queue or {}
    local oldQueue = boomboxes[value.boomboxId].queue or {}
    if activeBoomboxId then
        if activeBoomboxId == value.boomboxId then
            if #newQueue < 1 then
                if nuiObj:visible() then
                    nuiObj:hide()
                    monitorVisibleEntity = nil
                end
                nuiObj:msg({
                    type = "ResetPlayer",
                    boomboxId = value.boomboxId
                })
            else
                local newFirstUrl = (newQueue[1] and newQueue[1].url) or ""
                local oldFirstUrl = (oldQueue[1] and oldQueue[1].url) or ""
                if newFirstUrl ~= oldFirstUrl then
                    nuiObj:msg({
                        type = "LoadVideo",
                        musics = newQueue,
                        key = value.boomboxId
                    })
                else
                    if #newQueue ~= #oldQueue then
                        nuiObj:msg({
                            type = "LoadVideo",
                            musics = newQueue,
                            key = value.boomboxId
                        })
                    end
                end
            end
        end
    end
    boomboxes[value.boomboxId].data = value.data.data
    boomboxes[value.boomboxId].queue = value.data.queue
    boomboxes[value.boomboxId].player = value.data.player
    if not NetworkDoesNetworkIdExist(boomboxes[value.boomboxId].data.netId) then
        return
    end
    syncBoombox(value.boomboxId)
end)

AddStateBagChangeHandler("syncDuration", nil, function(_bagName, _key, value, _reserved, _replicated)
    if not value then
        return madCore.debug("[syncDuration] -> value does not exist")
    end
    if not boomboxes[value.boomboxId] then
        return madCore.debug("[syncDuration] -> boombox does not exist")
    end
    if not activeBoomboxId then
        return madCore.debug("[syncDuration] -> activ boombox does not exist")
    end
    if activeBoomboxId ~= value.boomboxId then
        return madCore.debug("[syncDuration] -> not same Id")
    end
    nuiObj:msg({
        type = "SyncSeconds",
        seconds = value.elapsed,
        boomboxId = value.boomboxId
    })
end)

CreateThread(function()
    while true do
        for _entryId, entry in pairs(boomboxes) do
            local netId = entry.data and entry.data.netId
            if netId then
                if NetworkDoesNetworkIdExist(netId) then
                    local boomboxEntity = NetToObj(netId)
                    if DoesEntityExist(boomboxEntity) then
                        if entry.zone then
                            local entityCoords = GetEntityCoords(boomboxEntity)
                            entry.lastCoord = entry.lastCoord or entityCoords
                            if #(entityCoords - entry.lastCoord) > 0.1 then
                                entry.lastCoord = entityCoords
                                entry.zone.coords = entityCoords
                            end
                        end
                    end
                end
            end
        end
        Wait(1000)
    end
end)

RegisterCommand(cfg.options.streamerModeCommand, function()
    streamerMode = not streamerMode
    local message
    if streamerMode then
        message = madCore.getPhrase("streamer_mod_enabled")
    else
        message = madCore.getPhrase("streamer_mod_disabled")
    end
    madCore.showNotify(message)
    nuiObj:msg({
        type = "MutePlayer",
        state = streamerMode
    })
    if streamerMode then
        nuiObj:hide()
        monitorVisibleEntity = nil
    end
end)

exports("getStreamerMode", function()
    return streamerMode
end)

exports("setStreamerMode", function(state)
    streamerMode = state
end)
