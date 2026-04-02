-- LB Phone Client Main File
-- Handles phone functionality, UI interactions, and core features

-- FiveM natives and functions
local DisableControlAction = DisableControlAction
local IsNuiFocused = IsNuiFocused
local DisablePlayerFiring = DisablePlayerFiring

-- Global phone state variables
phoneData = nil
currentPhone = nil
settings = nil
phoneOpen = false
SavedLocations = {}
PhoneOnScreen = false

-- Internal state variables
local playerData = nil
local isPlayerLoaded = false
local isFetchingPhone = false
local isConfigReceived = false

-- Function to wait for config to be received by UI
local function waitForConfig()
    if isConfigReceived then
        return
    end

    debugprint("waiting for config to be received")
    while not isConfigReceived do
        Wait(0)
    end
    debugprint("config received")
end

-- Main function to fetch phone data
function FetchPhone()
    debugprint("FetchPhone triggered")

    if isFetchingPhone then
        debugprint("already fetching phone")
        return
    end

    if not isConfigReceived then
        debugprint("config has not been sent to UI yet")
        return
    end

    isFetchingPhone = true

    -- Wait for framework to load
    while not FrameworkLoaded do
        debugprint("waiting for framework to load")
        Wait(500)
    end

    debugprint("triggering phone:playerLoaded")

    local phoneNumber = nil

    -- Get phone number from server or use existing
    if not isPlayerLoaded or not currentPhone then
        phoneNumber = AwaitCallback("playerLoaded")
        playerData = phoneNumber
        isPlayerLoaded = true
    else
        phoneNumber = playerData
    end

    debugprint("got number", phoneNumber)

    -- Check if player has phone number
    if not phoneNumber then
        debugprint("no number, checking if player has item")
        if HasPhoneItem() then
            debugprint("player has item; triggering phone:generatePhoneNumber")
            phoneNumber = AwaitCallback("generatePhoneNumber")
            debugprint("got number", phoneNumber)
        else
            debugprint("player does not have item")
        end
    end

    -- If still no number, return
    if not phoneNumber then
        isFetchingPhone = false
        if currentPhone then
            debugprint("no number. using SetPhone")
            SetPhone()
        end
        debugprint("no number, returning")
        return
    end

    -- Load default settings
    local defaultSettings = json.decode(GetConfigFile("defaultSettings.json"))

    -- Get latest version info
    local latestVersion = AwaitCallback("getLatestVersion")
    local currentVersion = GetResourceMetadata(GetCurrentResourceName(), "version", 0)

    if not latestVersion then
        latestVersion = currentVersion
    end

    -- Set locale and version info
    defaultSettings.locale = Config.DefaultLocale
    defaultSettings.version = currentVersion
    defaultSettings.latestVersion = latestVersion

    local isSetup = false

    debugprint("fetching phone data")
    local phoneInfo = AwaitCallback("getPhone", phoneNumber)
    debugprint("got phone data", json.encode(phoneInfo))

    if phoneInfo then
        -- Use existing settings or default
        if phoneInfo.settings then
            defaultSettings = phoneInfo.settings
        end

        -- Set phone name
        if phoneInfo.name then
            defaultSettings.name = phoneInfo.name
        else
            defaultSettings.name = "Not set"
        end

        defaultSettings.version = currentVersion
        defaultSettings.latestVersion = latestVersion

        -- Get saved locations
        SavedLocations = AwaitCallback("maps:getSavedLocations")

        -- Check if phone is set up
        isSetup = phoneInfo.is_setup or false

        currentPhone = phoneNumber

        -- Create phone data object
        local battery = 100
        if Config.Battery and Config.Battery.Enabled and phoneInfo.battery then
            battery = phoneInfo.battery
        end

        phoneData = {
            isSetup = isSetup,
            phoneNumber = phoneNumber,
            settings = defaultSettings,
            battery = battery
        }

        waitForConfig()

        debugprint("triggering phone:setPhoneData")
        SendReactMessage("setPhoneData", phoneData)

        TriggerEvent("lb-phone:numberChanged", phoneNumber)
        Wait(250)
    end

    settings = defaultSettings
    isFetchingPhone = false
end

-- Function to refresh phone configuration and data
function RefreshPhone(skipFetch)
    debugprint("RefreshPhone triggered")

    -- Wait for phone fetching to complete
    if isFetchingPhone then
        debugprint("phone is being fetched, waiting before refreshing")
        while isFetchingPhone do
            Wait(0)
        end
    end

    -- Handle WebRTC configuration
    if Config.DynamicWebRTC and Config.DynamicWebRTC.Enabled then
        local webrtcCredentials = AwaitCallback("getWebRTCCredentials")

        if Config.DynamicWebRTC.RemoveStun and webrtcCredentials then
            -- Remove STUN servers without credentials
            for i = #webrtcCredentials, 1, -1 do
                if not webrtcCredentials[i].credential then
                    table.remove(webrtcCredentials, i)
                end
            end
        end

        if webrtcCredentials then
            Config.RTCConfig = Config.RTCConfig or {}
            Config.RTCConfig.iceServers = webrtcCredentials
        end
    end

    isConfigReceived = false

    -- Build config object for UI
    local uiConfig = json.decode(GetConfigFile("config.json"))

    -- Valet configuration
    uiConfig.valet = {
        enabled = Config.Valet and Config.Valet.Enabled or false,
        price = Config.Valet and Config.Valet.Price or 0,
        vehicleTypes = Config.Valet and Config.Valet.VehicleTypes or { "car" }
    }

    -- Add various config options
    uiConfig.locations = Config.Locations
    uiConfig.AllowExternal = Config.AllowExternal
    uiConfig.ExternalBlacklistedDomains = Config.ExternalBlacklistedDomains
    uiConfig.ExternalWhitelistedDomains = Config.ExternalWhitelistedDomains
    uiConfig.Format = Config.PhoneNumber.Format
    uiConfig.EmailDomain = Config.EmailDomain
    uiConfig.RealTime = Config.RealTime
    uiConfig.CurrencyFormat = Config.CurrencyFormat
    uiConfig.DeleteMessages = Config.DeleteMessages
    uiConfig.Battery = Config.Battery
    uiConfig.rtc = Config.RTCConfig
    uiConfig.PromoteBirdy = Config.PromoteBirdy
    uiConfig.DynamicIsland = Config.DynamicIsland
    uiConfig.SetupScreen = Config.SetupScreen
    uiConfig.MaxTransferAmount = Config.MaxTransferAmount
    uiConfig.EnableMessagePay = Config.EnableMessagePay
    uiConfig.EnableGIFs = Config.EnableGIFs
    uiConfig.GIFsFilter = Config.GIFsFilter or "low"
    uiConfig.EnableVoiceMessages = Config.EnableVoiceMessages
    uiConfig.DefaultLocale = Config.DefaultLocale
    uiConfig.DateLocale = Config.DateLocale
    uiConfig.Debug = Config.Debug
    uiConfig.TikTokTTS = Config.TrendyTTS or { { "English (US) - Female", "en_us_001" } }
    uiConfig.recordNearbyVoices = Config.Voice.RecordNearby
    uiConfig.frameColor = Config.FrameColor
    uiConfig.allowFrameColorChange = Config.AllowFrameColorChange
    uiConfig.unlockPhoneKey = Config.KeyBinds and Config.KeyBinds.UnlockPhone and Config.KeyBinds.UnlockPhone.Bind
    uiConfig.DeleteMail = Config.DeleteMail
    uiConfig.ChangePassword = Config.ChangePassword
    uiConfig.DeleteAccount = Config.DeleteAccount
    uiConfig.CustomCamera = Config.Camera and Config.Camera.Enabled or false
    uiConfig.UsernameFilter = Config.UsernameFilter and Config.UsernameFilter.Regex or "[a-zA-Z0-9]+"

    -- Crypto limits
    uiConfig.CryptoLimit = (Config.Crypto and Config.Crypto.Limits) or { Buy = 1000000, Sell = 1000000 }

    -- Image options
    uiConfig.imageOptions = {
        mime = Config.Image and Config.Image.Mime or "image/png",
        quality = Config.Image and Config.Image.Quality or 1.0
    }

    -- Video options
    uiConfig.videoOptions = {
        bitrate = Config.Video and Config.Video.Bitrate or 250,
        size = Config.Video and Config.Video.MaxSize or 10,
        duration = Config.Video and Config.Video.MaxDuration or 60,
        fps = Config.Video and Config.Video.FrameRate or 24
    }

    -- Companies configuration
    uiConfig.Companies = table.deep_clone(Config.Companies)
    if uiConfig.Companies and uiConfig.Companies.Services then
        for i = 1, #uiConfig.Companies.Services do
            if uiConfig.Companies.Services[i].onCustomIconClick then
                uiConfig.Companies.Services[i].onCustomIconClick = true
            end
        end
    end

    -- Custom apps
    if Config.CustomApps then
        for appName, appData in pairs(Config.CustomApps) do
            uiConfig.apps[appName] = FormatCustomAppDataForUI(appData)
        end
    end

    -- Check app access permissions
    for appName, appData in pairs(uiConfig.apps) do
        appData.access = HasAccessToApp(appName)
    end

    -- Default settings
    uiConfig.defaultSettings = json.decode(GetConfigFile("defaultSettings.json"))

    -- Remove apps based on framework/config
    local function removeAppFromDefaults(appName)
        for i = 1, #uiConfig.defaultSettings.apps do
            for j = 1, #uiConfig.defaultSettings.apps[i] do
                if uiConfig.defaultSettings.apps[i][j] == appName then
                    table.remove(uiConfig.defaultSettings.apps[i], j)
                    break
                end
            end
        end
    end

    -- Remove framework-specific apps if not available
    if Config.Framework == "standalone" and not Config.CustomFramework then
        uiConfig.apps.Wallet = nil
        uiConfig.apps.Home = nil
        uiConfig.apps.Garage = nil
        uiConfig.apps.Services = nil
        removeAppFromDefaults("Wallet")
        removeAppFromDefaults("Home")
        removeAppFromDefaults("Garage")
        removeAppFromDefaults("Services")
    end

    -- Remove Home app if no house script
    if not Config.HouseScript then
        uiConfig.apps.Home = nil
        debugprint("No Config.HouseScript, removed home app")
        removeAppFromDefaults("Home")
    end

    -- Remove Crypto app if not enabled
    if not (Config.Crypto and Config.Crypto.Enabled) then
        uiConfig.apps.Crypto = nil
        debugprint("Config.Crypto not enabled, removed crypto app")
        removeAppFromDefaults("Crypto")
    end

    -- Send config to UI
    SendReactMessage("setConfig", uiConfig)
    waitForConfig()

    -- Send phone data if available
    if phoneData then
        debugprint("phoneData is defined")
        SendReactMessage("setPhoneData", phoneData)
        return
    end

    -- Fetch phone if not skipping
    if not skipFetch then
        FetchPhone()
    end
end

-- Handle job updates for app access control
RegisterNetEvent("lb-phone:jobUpdated", function(jobData)
    if not Config.WhitelistApps and not Config.BlacklistApps then
        return
    end

    debugprint("Job updated, refreshing whitelisted & blacklisted apps")

    -- Update whitelisted apps
    for appName, _ in pairs(Config.WhitelistApps or {}) do
        SendReactMessage("app:setHasAccess", {
            app = appName,
            hasAccess = HasAccessToApp(appName, jobData.job, jobData.grade)
        })
    end

    -- Update blacklisted apps
    for appName, _ in pairs(Config.BlacklistApps or {}) do
        SendReactMessage("app:setHasAccess", {
            app = appName,
            hasAccess = HasAccessToApp(appName, jobData.job, jobData.grade)
        })
    end

    -- Update custom apps
    for appName, _ in pairs(Config.CustomApps or {}) do
        SendReactMessage("app:setHasAccess", {
            app = appName,
            hasAccess = HasAccessToApp(appName, jobData.job, jobData.grade)
        })
    end
end)

-- Handle config received confirmation from UI
RegisterNUICallback("configReceived", function(data, callback)
    debugprint("UI has received the config (configReceived triggered)")
    isConfigReceived = true
    callback("ok")
end)

-- Handle phone data request from UI
RegisterNUICallback("getPhoneData", function(data, callback)
    debugprint("getPhoneData triggered")

    -- Wait for framework to load
    while not FrameworkLoaded do
        Wait(500)
    end

    Wait(1000)
    RefreshPhone()

    if not callback then
        debugprint("cb is not defined in getPhoneData", data)
        return
    end

    callback(true)
end)

-- Control disable thread for when phone is open
local function controlDisableThread()
    local playerId = PlayerId()

    while phoneOpen do
        Wait(0)

        -- Disable various controls while phone is open
        DisableControlAction(0, 199, true) -- INPUT_FRONTEND_PAUSE
        DisableControlAction(0, 200, true) -- INPUT_FRONTEND_PAUSE_ALTERNATE
        DisableControlAction(0, 24, true)  -- INPUT_ATTACK
        DisableControlAction(0, 25, true)  -- INPUT_AIM
        DisableControlAction(0, 69, true)  -- INPUT_VEH_ATTACK
        DisableControlAction(0, 70, true)  -- INPUT_VEH_ATTACK2
        DisableControlAction(0, 91, true)  -- INPUT_VEH_PASSENGER_ATTACK
        DisableControlAction(0, 92, true)  -- INPUT_VEH_PASSENGER_AIM
        DisableControlAction(0, 106, true) -- INPUT_VEH_MOUSE_CONTROL_OVERRIDE
        DisableControlAction(0, 114, true) -- INPUT_VEH_FLY_MOUSE_CONTROL_OVERRIDE
        DisableControlAction(0, 140, true) -- INPUT_MELEE_ATTACK_LIGHT
        DisableControlAction(0, 141, true) -- INPUT_MELEE_ATTACK_HEAVY
        DisableControlAction(0, 142, true) -- INPUT_MELEE_ATTACK_ALTERNATE
        DisableControlAction(0, 257, true) -- INPUT_ATTACK2
        DisableControlAction(0, 263, true) -- INPUT_MELEE_ATTACK1
        DisableControlAction(0, 264, true) -- INPUT_MELEE_ATTACK2
        DisableControlAction(0, 330, true) -- INPUT_VEH_DECELERATEE
        DisableControlAction(0, 331, true) -- INPUT_VEH_BRAKE

        DisablePlayerFiring(playerId, true)

        -- Additional controls when NUI is focused
        if IsNuiFocused() then
            DisableControlAction(0, 1, true)   -- INPUT_LOOK_LR
            DisableControlAction(0, 2, true)   -- INPUT_LOOK_UD
            DisableControlAction(0, 245, true) -- INPUT_CHAT
            DisableControlAction(0, 14, true)  -- INPUT_WEAPON_WHEEL_NEXT
            DisableControlAction(0, 15, true)  -- INPUT_WEAPON_WHEEL_PREV
            DisableControlAction(0, 16, true)  -- INPUT_SELECT_NEXT_WEAPON
            DisableControlAction(0, 17, true)  -- INPUT_SELECT_PREV_WEAPON
            DisableControlAction(0, 37, true)  -- INPUT_SELECT_WEAPON
            DisableControlAction(0, 50, true)  -- INPUT_AIM
            DisableControlAction(0, 99, true)  -- INPUT_VEH_SELECT_NEXT_WEAPON
            DisableControlAction(0, 115, true) -- INPUT_VEH_FLY_SELECT_NEXT_WEAPON
            DisableControlAction(0, 180, true) -- INPUT_CURSOR_SCROLL_UP
            DisableControlAction(0, 181, true) -- INPUT_CURSOR_SCROLL_DOWN
            DisableControlAction(0, 198, true) -- INPUT_FRONTEND_PAUSE
            DisableControlAction(0, 241, true) -- INPUT_CURSOR_X
            DisableControlAction(0, 242, true) -- INPUT_CURSOR_Y
            DisableControlAction(0, 261, true) -- INPUT_VEH_MELEE_LEFT
            DisableControlAction(0, 262, true) -- INPUT_VEH_MELEE_RIGHT
            DisableControlAction(0, 85, true)  -- INPUT_VEH_RADIO_WHEEL
        end
    end

    -- Handle escape key spam prevention
    while IsDisabledControlPressed(0, 200) do
        DisableControlAction(0, 200, true)
        Wait(0)
    end

    -- Handle camera transitions
    if cameraOpen then
        if IsWalkingCamEnabled() then
            local wasSelfieCam = IsSelfieCam()
            DisableWalkableCam()

            while not phoneOpen do
                Wait(500)
            end

            if cameraOpen then
                SetPhoneAction("camera")
                EnableWalkableCam(wasSelfieCam)
            end
        end
    end
end

-- Main function to toggle phone open/close
function ToggleOpen(open, skipFocus)
    if open == nil then
        open = not phoneOpen
    end

    open = open == true

    debugprint("ToggleOpen triggered", tostring(open), tostring(skipFocus))

    -- Check if phone is disabled
    if phoneDisabled and open then
        debugprint("phone is disabled, returning")
        return
    end

    -- Check if already in desired state
    if phoneOpen == open then
        debugprint("phoneOpen & open are both the same value, returning")
        return
    end

    -- Check if framework is loaded
    if not FrameworkLoaded then
        infoprint("warning", "Framework not loaded")
        return
    end

    -- Check if player is dead when trying to open
    if open then
        if IsPedDeadOrDying(PlayerPedId(), true) then
            debugprint("player ped is dead/dying, returning")
            return
        end

        -- Check if phone can be opened
        if CanOpenPhone and not CanOpenPhone() then
            debugprint("CanOpenPhone returned false, returning")
            return
        end

        -- Check if NUI is already focused
        if IsNuiFocused() and Config.DisableOpenNUI then
            infoprint("info",
                "Not opening the phone as another script has NUI focus. You can disable this behavior by setting Config.DisableOpenNUI to false.")
            return
        end

        -- Check if tablet is open
        if GetResourceState("lb-tablet") == "started" then
            local success, isTabletOpen = pcall(function()
                return exports["lb-tablet"]:IsOpen()
            end)
            if success and isTabletOpen then
                infoprint("info",
                    "Not opening the phone as the tablet is open. You can disable this behavior by setting Config.DisableTabletOpenPhone to false.")
                return
            end
        end
    end

    -- Ensure phone number exists
    if not currentPhone then
        debugprint("no phone, fetching")
        FetchPhone()
        if not currentPhone then
            debugprint("still no phone after fetching, returning")
            return
        end
    end

    -- Check if player has phone item when opening
    if open then
        if not HasPhoneItem(currentPhone) then
            debugprint("HasPhoneItem returned false. Phone number:", tostring(currentPhone))
            TriggerServerEvent("phone:togglePhone")
            SendReactMessage("closePhone")
            return
        end
    end

    -- Handle selfie cam when closing
    if not open then
        if IsWalkingCamEnabled() and IsSelfieCam() then
            ToggleSelfieCam(false)
        end
    end

    -- Handle live streaming when closing
    if not open and Config.EndLiveClose then
        local wasWatchingLive = IsWatchingLive()
        EndLive()
        if wasWatchingLive then
            SendReactMessage("instagram:liveEnded", wasWatchingLive)
        end
    end

    phoneOpen = open

    if open then
        debugprint("should open phone. sending openPhone event to ui")
        SendReactMessage("openPhone")

        if not skipFocus then
            SetNuiFocus(true, true)
            SetNuiFocusKeepInput(Config.KeepInput)
        end

        -- Start control disable thread if KeepInput is enabled
        if Config.KeepInput then
            CreateThread(controlDisableThread)
        end

        -- Start controller thread if available
        if ControllerThread then
            CreateThread(ControllerThread)
        end

        debugprint("setting animation action")

        -- Set appropriate phone action/animation
        if IsWalkingCamEnabled() then
            SetPhoneAction("camera")
        elseif IsInCall() then
            SetPhoneAction("call")
        else
            SetPhoneAction("default")
        end
    else
        debugprint("sending closePhone event to ui")
        PlayCloseAnim()
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        SendReactMessage("closePhone")
    end

    -- Notify server if phone is set up
    if phoneData and phoneData.isSetup then
        TriggerServerEvent("phone:togglePhone", open, settings and settings.name)
    end

    -- Trigger local event
    TriggerEvent("lb-phone:phoneToggled", open)
end

-- Handle input toggle from UI with PTT support
RegisterNUICallback("toggleInput", function(data, callback)
    callback("ok")


    if not Config.KeepInput then
        return
    end

    -- Check for PTT (Push to Talk) key press
    local isPTTPressed = false
    if Config.DisableFocusTalking then
        isPTTPressed = IsDisabledControlPressed(0, 249)
    else
        isPTTPressed = IsDisabledControlJustReleased(0, 249)
    end

    if isPTTPressed then
        if data then
            debugprint("PTT is pressed, ignoring toggle focus")
            return
        end

        debugprint("PTT is pressed, waiting before toggling focus")
        while true do
            local stillPressed = false
            if Config.DisableFocusTalking then
                stillPressed = IsDisabledControlPressed(0, 249)
            else
                stillPressed = IsDisabledControlJustReleased(0, 249)
            end

            if not stillPressed then
                break
            end
            Wait(100)
        end
    end

    if data then
        Wait(200)
    end

    SetNuiFocusKeepInput(not data)
end)

-- Variable to track focus waiting state
local waitingForFocus = false

-- Handle key press events
AddEventHandler("lb-phone:keyPressed", function(action)
    if IsPauseMenuActive() then
        return
    end

    if action == "Open" then
        debugprint("Pressed open keybind")
        ToggleOpen(not phoneOpen)
    elseif action == "Focus" then
        if not phoneOpen or waitingForFocus then
            return
        end

        -- Check for PTT key press
        local isPTTPressed = false
        if Config.DisableFocusTalking then
            isPTTPressed = IsDisabledControlPressed(0, 249)
        else
            isPTTPressed = IsDisabledControlJustReleased(0, 249)
        end

        if isPTTPressed then
            debugprint("PTT is pressed, waiting before toggling focus")
            waitingForFocus = true
            while IsDisabledControlPressed(0, 249) or IsDisabledControlJustReleased(0, 249) do
                Wait(0)
            end
            waitingForFocus = false
        end

        local isFocused = IsNuiFocused()
        SetNuiFocus(not isFocused, not isFocused)

        if not isFocused then
            SetNuiFocusKeepInput(Config.KeepInput)
        else
            SetNuiFocusKeepInput(false)
        end
    elseif action == "StopSounds" then
        SendReactMessage("stopSounds")
    end

    -- Call handling
    if action == "AnswerCall" then
        SendReactMessage("usedCommand", "answer")
    elseif action == "DeclineCall" then
        SendReactMessage("usedCommand", "decline")
    end

    -- Camera controls
    if action == "TakePhoto" then
        SendReactMessage("camera:usedCommand", "toggleTaking")
    elseif action == "ToggleFlash" then
        SendReactMessage("camera:usedCommand", "toggleFlash")
    elseif action == "LeftMode" then
        SendReactMessage("camera:usedCommand", "leftMode")
    elseif action == "RightMode" then
        SendReactMessage("camera:usedCommand", "rightMode")
    elseif action == "FlipCamera" then
        SendReactMessage("camera:usedCommand", "toggleFlip")
    end
end)

-- Setup keybinds and commands
for keyName, keyData in pairs(Config.KeyBinds) do
    if keyData.Command then
        keyData.Command = keyData.Command:lower()

        if keyData.Bind then
            -- Use keybind system
            keyData.bindData = AddKeyBind({
                name = keyData.Command,
                description = keyData.Description or "no description",
                defaultKey = keyData.Bind,
                defaultMapper = keyData.Mapper,
                secondaryKey = keyData.SecondaryBind,
                secondaryMapper = keyData.SecondaryMapper,
                onPress = function()
                    TriggerEvent("lb-phone:keyPressed", keyName)
                end,
                onRelease = function(duration)
                    TriggerEvent("lb-tablet:keyReleased", keyName, duration)
                end
            })
        else
            -- Use command system
            RegisterCommand(keyData.Command, function()
                TriggerEvent("lb-phone:keyPressed", keyName)
                Wait(0)
                TriggerEvent("lb-phone:keyReleased", keyName, 0)
            end, false)
        end
    end
end

-- Handle phone setup completion
RegisterNUICallback("finishedSetup", function(data, callback)
    if phoneData then
        phoneData.isSetup = true
    end

    if data then
        local characterName = AwaitCallback("getCharacterName")
        local phoneName = L("BACKEND.MISC.X_PHONE", {
            name = characterName.firstname,
            lastname = characterName.lastname
        })
        data.name = phoneName
    end

    SendReactMessage("setName", data.name)
    TriggerServerEvent("phone:setName", data.name)
    TriggerServerEvent("phone:togglePhone", phoneOpen, data and data.name)
    TriggerServerEvent("phone:finishedSetup", data)

    if Config.AutoBackup then
        TriggerCallback("backup:createBackup")
    end

    callback("ok")
end)

-- Check if user is admin
RegisterNUICallback("isAdmin", function(data, callback)
    TriggerCallback("isAdmin", callback)
end)

-- Set phone name
RegisterNUICallback("setPhoneName", function(data, callback)
    if settings then
        settings.name = data
    end

    TriggerServerEvent("phone:setName", data)
    callback("ok")
end)

-- Update phone settings
RegisterNUICallback("setSettings", function(data, callback)
    debugprint("setSettings triggered")

    if not phoneData then
        print("setSettings triggered, but phoneData is nil")
        return
    end

    settings = data
    phoneData.settings = settings
    callback("ok")

    -- Update call volume
    SetCallVolume(settings and settings.sound and settings.sound.callVolume)

    -- Save settings to server
    AwaitCallback("setSettings", settings)

    -- Trigger events
    TriggerEvent("lb-phone:settingsUpdated", data)
    SendReactMessage("customApp:sendMessage", {
        identifier = "any",
        message = {
            type = "settingsUpdated",
            settings = settings,
            action = "settingsUpdated",
            data = data
        }
    })
end)

-- Set cursor location
RegisterNUICallback("setCursorLocation", function(data, callback)
    local x, y = data.x, data.y
    local screenWidth, screenHeight = GetActiveScreenResolution()
    SetCursorLocation(x / screenWidth, y / screenHeight)
    callback("ok")
end)

-- Exit focus and close phone
RegisterNUICallback("exitFocus", function(data, callback)
    debugprint("exitFocus triggered")
    SetNuiFocus(false, false)
    ToggleOpen(false)
    callback("ok")
end)

-- Get available locales
RegisterNUICallback("getLocales", function(data, callback)
    callback(Config.Locales or { en = "English" })
end)

-- Set phone on screen status
RegisterNUICallback("setOnScreen", function(data, callback)
    data = data == true
    if PhoneOnScreen ~= data then
        TriggerEvent("lb-phone:setOnScreen", data)
        PhoneOnScreen = data
    end
    callback("ok")
end)

-- Export function to check if phone is on screen
exports("IsPhoneOnScreen", function()
    return PhoneOnScreen
end)

-- Function to send messages to React UI
function SendReactMessage(action, data)
    SendNUIMessage({
        action = action,
        data = data
    })
end

-- Thread to update time and service bars
CreateThread(function()
    local lastTime = {}
    local lastService = nil

    -- Wait for phone to be initialized
    while not currentPhone do
        debugprint("Waiting for currentPhone to be set before updating time & service")
        Wait(1000)
    end

    while true do
        -- Update time
        local currentTime
        if not Config.RealTime then
            if Config.CustomTime then
                currentTime = Config.CustomTime()
            end

            if not currentTime then
                currentTime = {
                    hour = GetClockHours(),
                    minute = GetClockMinutes()
                }
            end

            if currentTime.hour ~= lastTime.hour or currentTime.minute ~= lastTime.minute then
                lastTime.hour = currentTime.hour
                lastTime.minute = currentTime.minute
                SendReactMessage("updateTime", currentTime)
            end
        end

        -- Update service bars
        local currentService = GetServiceBars()
        if lastService ~= currentService then
            lastService = currentService
            SendReactMessage("updateService", currentService)
        end

        Wait(1000)
    end
end)

-- Function to get config files
function GetConfigFile(filename)
    return LoadResourceFile(GetCurrentResourceName(), "config/" .. filename)
end

-- Handle config file requests from UI
RegisterNUICallback("getConfigFile", function(data, callback)
    local fileContent = GetConfigFile(data .. ".json")
    local jsonData = json.decode(fileContent)
    callback(jsonData)
end)

-- Handle app logout events
RegisterNetEvent("phone:logoutFromApp", function(data)
    debugprint("logoutFromApp:", data)

    if data.number then
        if data.number == currentPhone then
            debugprint("Ignoring logoutFromApp event since number matches")
            return
        end
    end

    debugprint(data.app .. ":logout", data.username)
    SendReactMessage(data.app .. ":logout", data.username)
end)

-- Nearby players tracking
local nearbyPlayers = {}

function GetNearbyPlayers()
    return nearbyPlayers
end

-- Thread to track nearby players
CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local activePlayers = GetActivePlayers()
        local nearby = {}

        for i = 1, #activePlayers do
            local player = activePlayers[i]
            if player ~= PlayerId() then
                local ped = GetPlayerPed(player)
                local coords = GetEntityCoords(ped)
                local distance = #(playerCoords - coords)

                if distance <= 60.0 then
                    nearby[#nearby + 1] = {
                        player = player,
                        source = GetPlayerServerId(player),
                        ped = ped
                    }
                end
            end
        end

        nearbyPlayers = nearby
        Wait(5000)
    end
end)

-- Function to handle player logout
function LogOut()
    debugprint("LogOut triggered")

    -- Wait for phone fetching to complete
    while isFetchingPhone do
        debugprint("LogOut triggered, waiting for fetchingPhone to finish...")
        Wait(500)
    end

    AwaitCallback("setLastPhone")

    phoneData = nil
    currentPhone = nil
    settings = nil

    TriggerEvent("lb-phone:numberChanged", nil)
    ResetSecurity()
    OnDeath()
end

-- Function to set phone number
function SetPhone(phoneNumber, skipFetch)
    debugprint("SetPhone triggered", phoneNumber, skipFetch)

    -- Wait for phone fetching to complete
    while isFetchingPhone do
        debugprint("SetPhone triggered, waiting for fetchingPhone to finish...")
        Wait(500)
    end

    OnDeath()
    AwaitCallback("setLastPhone", phoneNumber)
    ResetSecurity(true)
    ToggleCharging(false)

    phoneData = nil
    currentPhone = nil
    settings = nil

    TriggerEvent("lb-phone:numberChanged", nil)

    if phoneNumber or skipFetch then
        FetchPhone()
    end

    if phoneNumber == nil and not skipFetch then
        local firstNumber = GetFirstNumber()
        if firstNumber then
            SetPhone(firstNumber)
        end
    end
end

-- Function to handle player death
function OnDeath()
    debugprint("OnDeath triggered")

    local wasWatchingLive = IsWatchingLive()
    EndLive()
    if wasWatchingLive then
        SendReactMessage("instagram:liveEnded", wasWatchingLive)
    end

    if flashlightEnabled then
        flashlightEnabled = false
        TriggerServerEvent("phone:toggleFlashlight", false)
    end

    EndCall()

    if phoneOpen then
        ToggleOpen(false)
    end
end

-- Register events and exports
RegisterNetEvent("phone:toggleOpen", ToggleOpen)
exports("ToggleOpen", ToggleOpen)
exports("IsOpen", function() return phoneOpen end)
exports("IsDisabled", function() return phoneDisabled end)
exports("ToggleDisabled", function(disabled)
    phoneDisabled = disabled == true
    debugprint("ToggleDisabled triggered", phoneDisabled)
    if phoneDisabled and phoneOpen then
        ToggleOpen(false)
    end
end)
exports("GetSettings", function() return settings end)
exports("GetAirplaneMode", function() return settings and settings.airplaneMode end)
exports("GetStreamerMode", function() return settings and settings.streamerMode end)
exports("GetEquippedPhoneNumber", function() return currentPhone end)

RegisterCommand('debugphone', function()
    local slots = exports['ox_inventory']:Search('slots', 'phone')
    TriggerServerEvent('lb-phone:debugSlots', json.encode(slots or {}))
end, false)