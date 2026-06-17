
local isStuck = false
local isInteracting = false
local postBoxModels = {}
local lockpickItems = {}
local postBoxStates = {}

function MoveToPostBox(entity, heading)
    local coords = GetOffsetFromEntityInWorldCoords(entity, 0.05, -0.5, 1.0)
    TaskGoStraightToCoord(cache.ped, coords.x, coords.y, coords.z, 1.0, -1, heading, 1.0)

    local timeout = GetGameTimer() + 3000
    while #(GetEntityCoords(cache.ped) - coords) > 0.2 and GetGameTimer() < timeout do
        Wait(100)
    end
end

RegisterNetEvent("prp-pettycrime:client:startup", function(activityType, data)
    if activityType ~= "post_boxes" then return end

    postBoxModels = data.models
    lockpickItems = data.items

    if Config.Debug then
        for _, model in ipairs(postBoxModels) do
            TriggerEvent("prp-pettycrime:client:registerDebugModel", model, "Post Box")
        end
    end

    bridge.target.addModel(postBoxModels, {
        {
            name = "postbox-lockpick",
            icon = "fas fa-key",
            label = locale("target.postbox.lockpick"),
            onSelect = function(data)
                if isInteracting then return end
                isInteracting = true

                local success, err = pcall(function()
                    local entity = data.entity
                    local coords = GetEntityCoords(entity)
                    local model = GetEntityModel(entity)
                    local heading = GetEntityHeading(entity)

                    MoveToPostBox(entity, heading)

                    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
                    local streetName = GetStreetNameFromHashKey(streetHash)
                    local zoneName = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
                    local locationLabel = (streetName ~= "" and ("%s, %s"):format(streetName, zoneName)) or zoneName

                    TriggerServerEvent("prp-pettycrime:server:postboxLockpick", GetEntityArchetypeName(entity), model, coords, locationLabel)
                end)

                if not success then
                    lib.print.error("Lockpick postbox error:", err)
                end

                isInteracting = false
            end,
            canInteract = function(entity, distance)
                if not IsInsidePostBoxZone() then return false end
                if isStuck then return false end
                if distance > Config.PostBoxes.targetDistance then return false end
                if HasObjectBeenBroken(entity) or cache.vehicle then return false end

                local key = GetLocationKey(GetEntityCoords(entity))
                return not postBoxStates[key]
            end
        },
        {
            name = "postbox-steal",
            icon = "fas fa-hands",
            label = locale("target.postbox.take"),
            onSelect = function(data)
                if isInteracting then return end
                isInteracting = true

                local success, err = pcall(function()
                    local entity = data.entity
                    local coords = GetEntityCoords(entity)
                    local model = GetEntityModel(entity)
                    local heading = GetEntityHeading(entity)

                    MoveToPostBox(entity, heading)

                    TriggerServerEvent("prp-pettycrime:server:postboxSteal", GetEntityArchetypeName(entity), model, coords)
                end)

                if not success then
                    lib.print.error("Steal postbox error:", err)
                end

                isInteracting = false
            end,
            canInteract = function(entity, distance)
                if not IsInsidePostBoxZone() then return false end
                if isStuck then return false end
                if distance > Config.PostBoxes.targetDistance then return false end
                if HasObjectBeenBroken(entity) or cache.vehicle then return false end

                local key = GetLocationKey(GetEntityCoords(entity))
                return postBoxStates[key] == "lockpicked"
            end
        }
    })
end)

RegisterNetEvent("prp-pettycrime:client:postboxUpdateOptionState", function(key, state)
    postBoxStates[key] = state
end)

RegisterNetEvent("prp-pettycrime:client:postboxResetOptionStates", function(keys)
    for _, key in ipairs(keys) do
        postBoxStates[key] = nil
    end
end)

RegisterNetEvent("prp-pettycrime:client:postboxSetStuck", function(animData, unstuckAnimData, minigameData, progressData)
    bridge.fw.notify("error", locale("notifications.postbox.stuck"))
    isStuck = true

    local controlsToDisable = { 22, 23, 30, 31 }
    local playerCoords = GetEntityCoords(cache.ped)

    lib.requestAnimDict(animData.dict)
    TaskPlayAnim(cache.ped, animData.dict, animData.clip, animData.blendIn or 3.0, animData.blendOut or 1.0, animData.duration or -1, animData.flag or 49, animData.playbackRate or 0, animData.lockX, animData.lockY, animData.lockZ)

    CreateThread(function()
        while isStuck do
            Wait(1000)
            if #(GetEntityCoords(cache.ped) - playerCoords) > 3.0 then
                isStuck = false
            end
        end
    end)

    CreateThread(function()
        bridge.fw.showTextUI(locale("text.postbox.unstuck"))
        local ped = cache.ped

        while isStuck do
            Wait(0)

            for _, control in ipairs(controlsToDisable) do
                DisableControlAction(0, control, true)
            end

            if IsControlJustReleased(0, 38) then
                if not bridge.minigames.isPlaying() then
                    local success = bridge.minigames.play("lockpick", minigameData.options, minigameData.otherOptions)
                    if success then
                        isStuck = false
                    else
                        bridge.fw.notify("error", locale("notifications.postbox.still_stuck"))
                    end
                end
            end

            if not IsEntityPlayingAnim(ped, animData.dict, animData.clip, 3) then
                TaskPlayAnim(ped, animData.dict, animData.clip, animData.blendIn or 3.0, animData.blendOut or 1.0, animData.duration or -1, animData.flag or 49, animData.playbackRate or 0, animData.lockX, animData.lockY, animData.lockZ)
            end
        end

        ClearPedTasks(cache.ped)

        bridge.fw.progressBar({
            duration = progressData.duration,
            label = progressData.text,
            controlDisables = { disableMovement = true },
            canCancel = false,
            animation = {
                animDict = progressData.anim.dict,
                animClip = progressData.anim.clip,
                animFlag = progressData.anim.flag
            }
        })

        bridge.fw.notify("info", locale("notifications.postbox.unstuck"))
        RemoveAnimDict(animData.dict)
        bridge.fw.hideTextUI()
    end)
end)

AddEventHandler("onResourceStop", function(resourceName)
    if cache.resource ~= resourceName then return end

    bridge.target.removeModel(postBoxModels, { "postbox-steal" })
end)
