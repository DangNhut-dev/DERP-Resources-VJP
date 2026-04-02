
CreatedUIFrame = false

Citizen.CreateThread(function()
    while not CreatedUIFrame do
        Wait(10)
    end

    Wait(300)

    if Config.AutoHandleUIV2 and IsUIV2Active then
        local hasGetConfig = pcall(function()
            return exports.ZSX_UIV2.GetConfig
        end)

        if hasGetConfig then
            local success, uiv2Config = pcall(exports.ZSX_UIV2.GetConfig)

            if not success then
                Config.UseMusicFromUIV2 = false
            elseif uiv2Config then
                local useMusicInMultichar = uiv2Config.UseMusicInMulticharacter
                local message = useMusicInMultichar and "^2Setting^7 UIV2 Music Handler to be used in Multicharacter." or "^1Disabling^7 UIV2 Muisc Handler in Multicharacter."
                debugPrint("[^3UIV2^7] " .. message)
                Config.UseMusicFromUIV2 = useMusicInMultichar
            end
        end
    end

    -- print('[DEBUG] Before SendConfig')
    NUI.SendConfig()
    -- print('[DEBUG] Before SendDefaultSettings')
    NUI.SendDefaultSettings()
    -- print('[DEBUG] Before SendDefaultMusic')
    NUI.SendDefaultMusic()

    -- print('[DEBUG] Waiting 2000ms')
    Wait(2000)

    -- print('[DEBUG] Loading street names')
    for locationId, location in pairs(Config.Locations) do
        local streetHash = GetStreetNameAtCoord(location.coords.x, location.coords.y, location.coords.z)
        Config.Locations[locationId].street = GetStreetNameFromHashKey(streetHash)
    end
    -- print('[DEBUG] Init thread done')
end)

RegisterNUICallback("createdUIFrame", function(data)
    -- print('[DEBUG] createdUIFrame callback received')
    CreatedUIFrame = true
end)

RegisterNUICallback("selectedCharacter", function(data)
    -- print('[DEBUG] selectedCharacter callback received, id: ' .. tostring(data.id))
    if not NUI.Vars.isOn then
        -- print('[DEBUG] NUI is not on, returning')
        return
    end

    Framework.TriggerServerCallback("DERP-multicharacter:Event:SelectedCharacter", function(skinData)
        NUI.UsageOfKeydowns(false)
        SetNuiFocus(false, false)

        if FrameworkSelected == "ESX" then
            Citizen.CreateThread(function()
                Wait(1000)
                TriggerEvent("playerSpawned")
                TriggerServerEvent("esx:onPlayerSpawn")
                TriggerEvent("esx:onPlayerSpawn")
                TriggerEvent("esx:restoreLoadout")
            end)
        end

        if FrameworkSelected == "QBCore" or FrameworkSelected == "QBX" then
            Citizen.CreateThread(function()
                Wait(2000)
                
                local ped = PlayerPedId()
                local currentCharacter = Entity.Vars.currentCharacter
                
                if not currentCharacter or not currentCharacter.skin then
                    return
                end
                
                local skinData = currentCharacter.skin
                local skinModel = skinData.model
                if skinModel and skinModel ~= 0 then
                    local modelHash = type(skinModel) == 'string' and joaat(skinModel) or skinModel
                    RequestModel(modelHash)
                    while not HasModelLoaded(modelHash) do
                        Wait(10)
                    end
                    SetPlayerModel(PlayerId(), modelHash)
                    SetModelAsNoLongerNeeded(modelHash)
                    Wait(500)
                elseif not IsPedModel(ped, `mp_m_freemode_01`) and not IsPedModel(ped, `mp_f_freemode_01`) then
                    local isMale = currentCharacter.sex == "m" or currentCharacter.gender == 0
                    local model = isMale and `mp_m_freemode_01` or `mp_f_freemode_01`
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Wait(10)
                    end
                    SetPlayerModel(PlayerId(), model)
                    SetModelAsNoLongerNeeded(model)
                    SetPedDefaultComponentVariation(PlayerPedId())
                    Wait(500)
                end
                
                Wait(500)
                exports['illenium-appearance']:setPedAppearance(PlayerPedId(), skinData)
            end)
        end

        TriggerEvent("DERP-multicharacter:Listener:SelectedCharacter", data.id)
        Entity.Cam(false)
    end, Entity.Vars.currentID)
end)

RegisterNUICallback("UIReady", function()
    -- print('[DEBUG] UIReady callback received')
    TriggerEvent("DERP-multicharacter:Listener:NUIReady", true)
    NUI.Vars.Ready = true
    -- print('[DEBUG] Before NUI.Prepare')
    NUI.Prepare()
    -- print('[DEBUG] After NUI.Prepare')
end)

RegisterNUICallback("screenShown", function(data, cb)
    Cameras.HandleScreens(data.alignment, data.init, data.screen)
end)

RegisterNUICallback("slideCameraForce", function(data)
    Cameras.HandleScreens(data.alignment, data.init)
end)

RegisterNUICallback("updatedUserSetting", function(data)
    if data.setting == "filters" then
        if Filters.Data.filter ~= "none" then
            Filters.Disable()
        end
        Filters.Show(data.settingData.name, data.settingData.value)
    elseif data.setting == "cameras" then
        Cameras.Data.Anim = data.settingData
    end

    WorkerUpdatedUserStorage(data.setting, data.settingData)
end)

RegisterNUICallback("gatherStorage", function(data)
    Storage.Set(data)
    WorkerGetUserStorage(data)
    NUI.SendUserConfig()
end)

RegisterCommand("fix_fadeout", function()
    DoScreenFadeIn(10)
    Client.BlackScreen(false, false)
end)

RegisterCommand("getCamRot", function()
    local camRot = GetCamRot(Entity.Vars.MainCamera, 2)
    debugPrint("Cam rot:" .. tostring(camRot))
end)

RegisterNUICallback("removeCharacter", function()
    if not Config.UI.delete_character then
        return
    end

    Framework.TriggerServerCallback("DERP-multicharacter:Event:RemoveCharacter", function(success, characterData)
        TriggerEvent("DERP-multicharacter:Listener:CharacterRemoved", Entity.Vars.currentID, characterData, success)

        if success then
            NUI.SetSlots()
            NUI.Prepare()
            local firstCharacter = Entity.GetFirstCharacter()
            Entity.Swap(firstCharacter, firstCharacter.id)
        else
            ConfigIdentity.ShowIdentity()
        end
    end, Entity.Vars.currentID)
end)

RegisterNUICallback("handleButtonSlider", function(data)
    if data.action == "CAMERA_ANIMATION_PLAY" then
        Cameras.PlayAnimationCam()
    elseif data.action == "GAME_FILTERS_RESET" then
        Filters.Reset()
    end
end)

function Logout()
    if canLogout() then
        if not LocalPlayer.state.isInMulticharacter then
            Framework.TriggerServerCallback("DERP-multicharacter:Event:Logout", function()
                Entity.Logout()
            end)
        end
    end
end

if Config.Commands.logout.use then
    RegisterCommand(Config.Commands.logout.commandName, function()
        Logout()
    end)
end