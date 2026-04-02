Framework = Config.CoreExport()

function table_includes(table, value)
    for k, v in pairs(table) do
        if k == value then
            return true
        end
    end

    return false
end

function DrawText3D(text, x, y, z, scaleX, scaleY)
    local onScreen = World3dToScreen2d(x, y, z)

    if onScreen then		
        local px,py,pz=table.unpack(GetGameplayCamCoords())
        local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
    
        local scale = (1/dist)*20
        local fov = (1/GetGameplayCamFov())*100
        local scale = scale*fov
    
        SetTextScale(scaleX*scale, scaleY*scale)
        SetTextCentre(1)
        SetTextProportional(1)
        SetTextOutline()
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)

        SetTextEntry("STRING")
        AddTextComponentString(text)
        SetDrawOrigin(x, y, z)
        EndTextCommandDisplayText(0.0, 0.0)
        ClearDrawOrigin()
    end
end

function createPedOnCoord(hash, x, y, z, w)
    local pedHashKey = GetHashKey(hash)
    local pedCoords = vector4(x, y, z, w)

    RequestModel(pedHashKey)
    while not HasModelLoaded(pedHashKey) do
        Wait(0)
    end

    local ped = CreatePed(0, pedHashKey, pedCoords.x, pedCoords.y, pedCoords.z - 1, pedCoords.w, false, true)
    
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedDiesWhenInjured(ped, false)
    SetPedCanPlayAmbientAnims(ped, false)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetEntityAsMissionEntity(ped, true, true)

    return ped
end

function triggerServerCallback(...)
    if Config.Framework == "qb" then
        Framework.Functions.TriggerCallback(...)
    else
        Framework.TriggerServerCallback(...)
    end
end

function isJobExists(job)
    local jobs = Config.CardTypes

    for k,v in pairs(jobs) do
        if v.job == job then
            return job
        end
    end

    return "citizen"
end

function loadModel(model)
    if not IsModelValid(model) then
        return
    end
    if not HasModelLoaded(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(1)
        end
    end
end

function loadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(1)
        end
    end
end

function PlayAnimationProgressBar(type, options, cb)
    if not type or type == "no_progressbar" then
        type = Config.ProgressBarType
    end
    loadAnimDict(options.dict)
    local disableMovement = options.progressbar.disable_movement == "yes"
    if type == "qb_progressbar" then
        local busy = exports["progressbar"]:isDoingSomething()
        if busy then
            Config.Notify(_t("JobCreator.cant_do_this_because_busy"),"error")
            cb(false)
            return
        end
        local controlDisablesOptions = {
            disableMovement = disableMovement,
            disableCarMovement = disableMovement,
            disableMouse = false,
            disableCombat = true
        }
        local animOptions = {
            animDict = options.dict,
            anim = options.name,
            flags = tonumber(options.flags) or nil,
        }
        local propOptions = (options.prop.is_required == "yes") and {
            model = options.prop.model,
            bone = tonumber(options.prop.bone) or nil,
            coords = {
                x = tonumber(options.prop.coords.x),
                y = tonumber(options.prop.coords.y),
                z = tonumber(options.prop.coords.z)
            },
            rotation = {
                x = tonumber(options.prop.rotation.x),
                y = tonumber(options.prop.rotation.y),
                z = tonumber(options.prop.rotation.z)
            },
        } or nil
        Framework.Functions.Progressbar("jobcreator_progress", options.progressbar.title, tonumber(options.duration), false,
            true,
            controlDisablesOptions, animOptions, propOptions, {}, function()
                StopAnimTask(
                    PlayerPedId(),
                    animOptions.animDict,
                    animOptions.anim,
                    1.0
                )
                cb(true)
            end, function()
                StopAnimTask(
                    PlayerPedId(),
                    animOptions.animDict,
                    animOptions.anim,
                    1.0
                )
                cb(false)
            end)
    elseif type == "ox_progressbar" then
        local busy = lib.progressActive()
        if busy then
            Config.Notify(_t("JobCreator.cant_do_this_because_busy"),"error")
            cb(false)
            return
        end
        local complete = lib.progressBar({
            duration = options.duration,
            label = options.progressbar.title,
            useWhileDead = false,
            canCancel = true,
            disable = {
                move = disableMovement,
                car = disableMovement,
                mouse = false,
                combat = true
            },
            anim = {
                dict = options.dict,
                clip = options.name,
                flag = tonumber(options.flags) or nil
            },
            prop = options.prop.is_required == "yes" and {
                model = options.prop.model,
                bone = tonumber(options.prop.bone) or nil,
                pos = {
                    x = tonumber(options.prop.coords.x),
                    y = tonumber(options.prop.coords.y),
                    z = tonumber(options.prop.coords.z)
                },
                rot = {
                    x = tonumber(options.prop.rotation.x),
                    y = tonumber(options.prop.rotation.y),
                    z = tonumber(options.prop.rotation.z)
                }
            } or nil
        })
        cb(complete)
    elseif type == "custom_progressbar" then
        local complete = CustomProgressbar(options)
        StopAnimTask(
            PlayerPedId(),
            options.dict,
            options.name,
            1.0
        )
        cb(complete)
    end
end

function GetPedsInVehicle(vehicle)
    local otherPeds = {}
    for seat = -1, GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) - 2 do
        local pedInSeat = GetPedInVehicleSeat(vehicle, seat)
        if not IsPedAPlayer(pedInSeat) and pedInSeat ~= 0 then
            otherPeds[#otherPeds + 1] = pedInSeat
        end
    end
    return otherPeds
end

function BorrowOfVehicle(target, vehicle)
    loadAnimDict("mp_am_hold_up")
    local occupants = GetPedsInVehicle(vehicle)
    for p = 1, #occupants do
        local ped = occupants[p]
        CreateThread(function()
            TaskPlayAnim(ped, "mp_am_hold_up", "holdup_victim_20s", 8.0, -8.0, -1, 49, 0, false, false, false)
            PlayPain(ped, 1, 0)
            FreezeEntityPosition(vehicle, true)
            SetVehicleUndriveable(vehicle, true)
        end)
    end
    local options = {
        dict = Config.BadgeAnimation.dict,
        name = Config.BadgeAnimation.anim,
        flags = nil,
        duration = 1500,
        prop = {
            is_required = "yes",
            model = Config.BadgeAnimation.prop,
            bone = 28422,
            coords = {
                x = 0.065,
                y = 0.029,
                z = -0.035,
            },
            rotation = {
                x = 80.0,
                y = -1.90,
                z = 75.0
            }
        },
        progressbar = {
            title = _t("IdCard.progressbar_title"),
            disable_movement = false,
        }
    }
    PlayAnimationProgressBar(Config.ProgressBarType, options, function(response)
        if response then
            Config.Notify(_t("IdCard.borrow_success"), "success")
            local plate = GetVehicleNumberPlateText(vehicle)
            for p = 1, #occupants do
                local ped = occupants[p]
                CreateThread(function()
                    FreezeEntityPosition(vehicle, false)
                    SetVehicleUndriveable(vehicle, false)
                    TaskLeaveVehicle(ped, vehicle, 0)
                    PlayPain(ped, 1, 0)
                    Wait(1250)
                    ClearPedTasksImmediately(ped)
                    PlayPain(ped, 1, 0)
                    MakePedFlee(ped)
                end)
            end
            Config.GiveVehicleKey(plate)
        else
            Config.Notify(_t("IdCard.borrow_failed"), "error")
            MakePedFlee(target)
        end
    end)
end

function MakePedFlee(ped)
    SetPedFleeAttributes(ped, 0, 0)
    TaskReactAndFleePed(ped, PlayerPedId())
end

function playAnim()
    if gCreatedBadgeProp then return end
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    loadModel(Config.BadgeAnimation.prop)
    gCreatedBadgeProp = CreateObject(
        Config.BadgeAnimation.prop,
        coords.x,
        coords.y,
        coords.z + 0.2,
        true,
        true,
        true
    )
    local boneIndex = GetPedBoneIndex(ped, 28422)
    AttachEntityToEntity(
        gCreatedBadgeProp,
        ped,
        boneIndex,
        0.065, 0.029, -0.035, 80.0, -1.90, 75.0,
        true,
        true,
        false,
        true,
        1,
        true
    )
    loadAnimDict(Config.BadgeAnimation.dict)
    TaskPlayAnim(
        ped,
        Config.BadgeAnimation.dict,
        Config.BadgeAnimation.anim,
        8.0, -8, 10.0, 49, 0, 0, 0,
        0
    )
    CreateThread(function()
        Citizen.Wait(3000)
        ClearPedSecondaryTask(ped)
        if gCreatedBadgeProp then
            DeleteObject(gCreatedBadgeProp)
            gCreatedBadgeProp = nil
        end
    end)
end

function isJobWhitelistedToBorrow(jobName)
    return Config.BorrowWhitelist[jobName] or false
end

function RaycastCamera(flag)
    local coords, normal = GetWorldCoordFromScreenCoord(0.5, 0.5)
    local destination = coords + normal * 10
    local handle = StartShapeTestLosProbe(coords.x, coords.y, coords.z, destination.x, destination.y, destination.z,
        flag, PlayerPedId(), 4)

    while true do
        Wait(0)
        local retval, hit, endCoords, surfaceNormal, materialHash, entityHit = GetShapeTestResultIncludingMaterial(
            handle)

        if retval ~= 1 then
            return hit, entityHit, endCoords, surfaceNormal, materialHash
        end
    end
end

function doesPlayerBorrowingVehicle(isJob)
    if Config.BorrowOfVehicle and isJob then
        local playerCoords = GetEntityCoords(PlayerPedId())
        local hit, entityHit, endCoords = RaycastCamera(-1)
        local distance = #(playerCoords - endCoords)
        if entityHit ~= 0 then
            local success, result = pcall(GetEntityType, entityHit)
            entityType = success and result or 0
        end
        if hit and entityHit ~= 0 and entityType == 2 and distance <= 8.0 then
            local vehicle = entityHit
            local targetPed = GetPedInVehicleSeat(entityHit, -1)
            if targetPed ~= 0 and DoesEntityExist(targetPed) and IsPedInAnyVehicle(targetPed, false) and not IsEntityDead(targetPed) and not IsPedAPlayer(targetPed) then
                if GetPedInVehicleSeat(vehicle, -1) == targetPed then
                    BorrowOfVehicle(targetPed, vehicle)
                    return true
                end
            end
        end
    end

    return false
end

function GetClosestPlayer(coords)
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, player in ipairs(players) do
        local targetPed = GetPlayerPed(player)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = player
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance
end

function openCard(data, isJobCard, shown)
    if CardOpen then
        return
    end

    if not shown then
        playAnim()
    end

    if data.cardType ~= "driver" and data.cardType ~= "weapon" then
        data.cardType = isJobCard and isJobExists(data.jobName) or "citizen"
    end

    if data.cardType == "citizen" then
        data.jobGrade = 0
    end

    if doesPlayerBorrowingVehicle(isJobWhitelistedToBorrow(data.cardType)) then
        return
    end

    CardOpen = true
    PData = data

    data.face = "front"
    SendNUIMessage({
        action = "toggle",
        value = true,
        cardData = data,
        cardTypes = Config.CardTypes,
    })
    
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(true)

    if not shown then
        local closestTarget, distanceWithTarget = GetClosestPlayer(coords)
        if closestTarget ~= -1 and distanceWithTarget ~= -1 and distanceWithTarget <= 3.0 then
            TriggerServerEvent("0r_idcard:server:showCard", GetPlayerServerId(closestTarget), data, isJobCard, true)
        end
    end
end

function doesPlayerHasLicense(type, source)
    triggerServerCallback("0r_idcard:server:doesPlayerHasLicense", function(result)
        return result
    end, type, source)
end

function startMugshotAnimation()
    DoScreenFadeOut(200)
    Wait(200)
    local InProgress = true
	local PlayerPed = PlayerPedId()
	local SuspectCoods = GetEntityCoords(PlayerPed)
	local CitizenId = PData.license
	local Name = PData.name.firstname .. " " .. PData.name.lastname
	local DOB = PData.birthDate 
    local ScaleformBoard = LoadScale("mugshot_board_01")
    local RenderHandle = CreateRenderModel("ID_Text", "prop_police_id_text")
	CreateThread(function()
        while RenderHandle do
            HideHudAndRadarThisFrame()
            SetTextRenderId(RenderHandle)
            Set_2dLayer(4)
            SetScriptGfxDrawBehindPausemenu(1)
            DrawScaleformMovie(ScaleformBoard, 0.405, 0.37, 0.81, 0.74, 255, 255, 255, 255, 0)
            SetScriptGfxDrawBehindPausemenu(0)
            SetTextRenderId(GetDefaultScriptRendertargetRenderId())
            SetScriptGfxDrawBehindPausemenu(1)
            SetScriptGfxDrawBehindPausemenu(0)
            Wait(0)
        end
    end)
	Wait(250)
	BeginScaleformMovieMethod(ScaleformBoard, 'SET_BOARD')
    PushScaleformMovieMethodParameterString(Config.BoardHeader)
    PushScaleformMovieMethodParameterString(Name)
    PushScaleformMovieMethodParameterString(CitizenId)
    PushScaleformMovieMethodParameterString(DOB)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(math.random(000, 999))
    PushScaleformMovieFunctionParameterInt(116)
    EndScaleformMovieMethod()
	local MugCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
	SetCamCoord(MugCam, Config.CameraPos.pos)
    SetCamRot(MugCam, Config.CameraPos.rotation, 2)
    SetCamFov(MugCam, 35.0)
    RenderScriptCams(1, 0, 0, 1, 1)
    Wait(250)
	CreateThread(function()
        FreezeEntityPosition(PlayerPed, true)
        SetPauseMenuActive(false)
        while InProgress do
            DisableAllControlActions(0)
            EnableControlAction(0, 249, true)
            EnableControlAction(0, 46, true)
            Wait(0)
        end
    end)
	SetEntityCoords(PlayerPed, Config.MugShotCoords)
	SetEntityHeading(PlayerPed, Config.MugShotHeading)
    DoScreenFadeIn(200)
	loadModel("prop_police_id_board")
	loadModel("prop_police_id_text")
	local Board = CreateObject("prop_police_id_board", SuspectCoods, true, true, false)
	local BoardOverlay = CreateObject("prop_police_id_text", SuspectCoods, true, true, false)
	AttachEntityToEntity(BoardOverlay, Board, -1, 4103, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
	SetModelAsNoLongerNeeded("prop_police_id_board")
	SetModelAsNoLongerNeeded("prop_police_id_text")
    SetCurrentPedWeapon(PlayerPed, "weapon_unarmed", 1)
	ClearPedWetness(PlayerPed)
	ClearPedBloodDamage(PlayerPed)
	AttachEntityToEntity(Board, PlayerPed, GetPedBoneIndex(PlayerPed, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 2, 1)	
	loadAnimDict("mp_character_creation@lineup@male_a")
	TaskPlayAnim(PlayerPed, "mp_character_creation@lineup@male_a", "loop_raised", 8.0, 8.0, -1, 49, 0, false, false, false)
    Wait(6000)
    DoScreenFadeOut(200)
    Wait(200)
	DestroyCam(MugCam, 0)
    RenderScriptCams(0, 0, 1, 1, 1)
    SetFocusEntity(PlayerPed)
    ClearPedTasksImmediately(PlayerPed)
    FreezeEntityPosition(PlayerPed, false)
    DeleteObject(Board)
    DeleteObject(BoardOverlay)
    SetEntityCoords(PlayerPed, SuspectCoods)
    Wait(200)
    DoScreenFadeIn(200)
    RenderHandle = nil
	InProgress = false
end 

function LoadScale(scalef)
	local handle = RequestScaleformMovie(scalef)
    while not HasScaleformMovieLoaded(handle) do
        Wait(0)
    end
	return handle
end

function CreateRenderModel(name, model)
	local handle = 0
	if not IsNamedRendertargetRegistered(name) then
		RegisterNamedRendertarget(name, 0)
	end
	if not IsNamedRendertargetLinked(model) then
		LinkNamedRendertarget(model)
	end
	if IsNamedRendertargetRegistered(name) then
		handle = GetNamedRendertargetRenderId(name)
	end
	return handle
end