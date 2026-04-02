LoadedNUI = false
TabletOpen = false
TabletId = nil
TabletSettings = nil
TabletDisabled = false
local isSetup = false
local cursorX = 0
local cursorY = 0
local controlInterval = nil
local focusInterval = nil
local timeInterval = nil
local tabletLoaded = nil
local playerId = nil
local function disableControlsLoop()
  DisableControlAction(0, 24, true)
  DisableControlAction(0, 25, true)
  DisableControlAction(0, 68, true)
  DisableControlAction(0, 69, true)
  DisableControlAction(0, 70, true)
  DisableControlAction(0, 91, true)
  DisableControlAction(0, 92, true)
  DisableControlAction(0, 106, true)
  DisableControlAction(0, 114, true)
  DisableControlAction(0, 140, true)
  DisableControlAction(0, 141, true)
  DisableControlAction(0, 142, true)
  DisableControlAction(0, 257, true)
  DisableControlAction(0, 263, true)
  DisableControlAction(0, 264, true)
  DisableControlAction(0, 330, true)
  DisableControlAction(0, 331, true)
  if playerId then
    DisablePlayerFiring(playerId, true)
  end
  DisableControlAction(0, 199, true)
  DisableControlAction(0, 200, true)
end
local function disableFocusControls()
  DisableControlAction(0, 1, true)
  DisableControlAction(0, 2, true)
  DisableControlAction(0, 245, true)
  DisableControlAction(0, 14, true)
  DisableControlAction(0, 15, true)
  DisableControlAction(0, 16, true)
  DisableControlAction(0, 17, true)
  DisableControlAction(0, 37, true)
  DisableControlAction(0, 50, true)
  DisableControlAction(0, 99, true)
  DisableControlAction(0, 115, true)
  DisableControlAction(0, 180, true)
  DisableControlAction(0, 181, true)
  DisableControlAction(0, 198, true)
  DisableControlAction(0, 241, true)
  DisableControlAction(0, 242, true)
  DisableControlAction(0, 261, true)
  DisableControlAction(0, 262, true)
  DisableControlAction(0, 85, true)
end
local function loadConfigFile(fileName)
  local file = LoadResourceFile(GetCurrentResourceName(), "config/" .. fileName .. ".json")
  local data = {}
  if not file then
    infoprint("error", "config/" .. fileName .. ".json file not found, did you delete it? Try reinstalling the resource.")
  else
    local decoded = json.decode(file)
    data = decoded
    if not data then
      infoprint("error", "config/" .. fileName .. ".json file has an error. Try reinstalling the resource.")
    end
  end
  return data or {}
end
local isPttPressed = false
local function toggleFocus()
  if TabletOpen then
    if Config.KeepInput then
      if not isPttPressed then
        goto continue
      end
    end
  end
  do return end
  ::continue::
  local pttPressed = false
  if Config.DisableFocusTalking then
    pttPressed = IsDisabledControlPressed(0, 249)
  else
    pttPressed = IsDisabledControlJustReleased(0, 249)
  end
  
  if pttPressed then
    debugprint("PTT is pressed, waiting before toggling focus")
    isPttPressed = true
    while true do
      if not IsDisabledControlPressed(0, 249) and not IsDisabledControlJustReleased(0, 249) then
        break
      end
      Wait(0)
    end
    isPttPressed = false
  end
  
  local shouldFocus = not IsNuiFocused()
  SetNuiFocus(shouldFocus, shouldFocus)
  SetNuiFocusKeepInput(shouldFocus)
  
  if focusInterval and not shouldFocus then
    focusInterval = ClearInterval(focusInterval)
  elseif not focusInterval and shouldFocus then
    focusInterval = SetInterval(disableFocusControls)
  end
  
  if shouldFocus then
    local screenW, screenH = GetActiveScreenResolution()
    SetCursorLocation(cursorX / screenW, cursorY / screenH)
  else
    cursorX, cursorY = GetNuiCursorPosition()
  end
end
local opacityToggled = false
for keyName, keyData in pairs(Config.KeyBinds) do
  local keybind = AddKeyBind({
    name = keyName,
    description = keyData.description,
    defaultKey = keyData.bind,
    defaultMapper = keyData.mapper,
    onPress = function()
      TriggerEvent("lb-tablet:keyPressed", keyName)
    end,
    onRelease = function(held)
      TriggerEvent("lb-tablet:keyReleased", keyName, held)
      if keyName == "Focus" then
        toggleFocus()
      elseif keyName == "Open" then
        ToggleOpen()
      elseif keyName == "Opacity" then
        opacityToggled = not opacityToggled
        SendReactMessage("toggleOpacity", opacityToggled)
      end
    end
  })
  keyData.bindData = keybind
end
local configKeys = {
  "Debug", "CurrencyFormat", "DateLocale", "EmailDomain", "DefaultLocale", "FrameColor", 
  "AllowFrameColorChange", "Image", "Video", "Police", "Ambulance", "Browser", "RTCConfig", 
  "DobFormat", "AllowExternal", "Services", "LBPhone", "FadeOutsideTablet", "EvidenceStash", 
  "ShowDispatchWithoutItem", "ShowLocationsInDispatch", "Locations", "DispatchPosition", 
  "DispatchVisible", "Genders", "LiveEdit"
}
local defaultSettings = loadConfigFile("defaultSettings")
local configData = loadConfigFile("config")
PoliceAppData = configData.apps.Police
AmbulanceAppData = configData.apps.Ambulance
for i = 1, #configKeys do
  local key = configKeys[i]
  configData[key] = Config[key]
end
configData.defaultSettings = defaultSettings
configData.RealTime = Config.RealTime == true
local unlockKey = "SPACE"
if Config.KeyBinds and Config.KeyBinds.UnlockTablet and Config.KeyBinds.UnlockTablet.bind then
  unlockKey = Config.KeyBinds.UnlockTablet.bind
end
configData.UnlockTabletKey = unlockKey
AddEventHandler("lb-tablet:customAppAdded", function(appData)
  configData.apps[appData.identifier] = appData
end)
AddEventHandler("lb-tablet:customAppRemoved", function(identifier)
  configData.apps[identifier] = nil
end)
local isFetchingTabletData = false
function FetchTabletData()
  debugprint("FetchTabletData: triggered")
  if isFetchingTabletData then
    debugprint("FetchTabletData: already fetching tablet data")
    return
  end
  isFetchingTabletData = true
  if not FrameworkLoaded then
    debugprint("FetchTabletData: waiting for framework to load")
    while not FrameworkLoaded do
      Wait(0)
    end
    debugprint("FetchTabletData: framework loaded")
  end
  SetTimeout(2500, function()
    SendReactMessage("setHasTablet", HasTabletItem())
  end)
  if not tabletLoaded then
    debugprint("FetchTabletData: fetching tablet data")
    TriggerEvent("lb-tablet:jobUpdated")
    local tabletData = AwaitCallback("getTablet")
    if tabletData then
      TabletId = tabletData.id
      TabletSettings = tabletData.settings
      isSetup = tabletData.isSetup
      tabletLoaded = true
      Citizen.CreateThreadNow(RefreshAllDispatches)
      debugprint("FetchTabletData: tablet fetched")
    else
      debugprint("FetchTabletData: ^1failed to fetch tablet^7 (tablet:getTablet returned nil)")
      isFetchingTabletData = false
      return
    end
  end
  debugprint("FetchTabletData: ^2tablet loaded^7 triggering setData")
  local baseUrl = GetBaseUrl()
  local serverIdentifier = baseUrl
  if string.find(baseUrl, "%.users%.cfx%.re") then
    local urlLen = #baseUrl
    local reversed = baseUrl:reverse()
    local dashPos = reversed:find("-") or (#baseUrl + 1)
    local startPos = urlLen - dashPos + 2
    local endPos = #baseUrl - #".users.cfx.re"
    serverIdentifier = string.sub(baseUrl, startPos, endPos)
  end
  if Config.LBPhone then
    local phoneConfig = GetPhoneConfig()
    local numberFormat = phoneConfig and phoneConfig.PhoneNumber and phoneConfig.PhoneNumber.Format
    if not numberFormat then
      numberFormat = "({3}) {3}-{4}"
    end
    configData.NumberFormat = numberFormat
  end
  local isPolice = IsPolice()
  local isAmbulance = IsAmbulance()
  if Config.RequireDutyMDT then
    local onDuty = IsOnDuty()
    if not onDuty then
      debugprint("Not on duty, disabling police and ambulance apps")
      isPolice = false
      isAmbulance = false
    end
  end
  configData.apps.Police = isPolice and PoliceAppData or nil
  configData.apps.Ambulance = isAmbulance and AmbulanceAppData or nil
  if not Config.RegistrationApp then
    configData.apps.Registration = nil
  end
  local customApps = GetCustomApps()
  for identifier, appData in pairs(customApps) do
    configData.apps[identifier] = appData
  end
  if Config.DynamicWebRTC and Config.DynamicWebRTC.Enabled then
    local webRTCCredentials = AwaitCallback("getWebRTCCredentials")
    if Config.DynamicWebRTC.RemoveStun and webRTCCredentials then
      for i = #webRTCCredentials, 1, -1 do
        if not webRTCCredentials[i].credential then
          table.remove(webRTCCredentials, i)
        end
      end
    end
    if webRTCCredentials then
      Config.RTCConfig = Config.RTCConfig or {}
      Config.RTCConfig.iceServers = webRTCCredentials
      configData.RTCConfig = Config.RTCConfig
    end
  end
  SendReactMessage("setData", {
    settings = TabletSettings or defaultSettings,
    config = configData,
    serverIdentifier = serverIdentifier,
    hasPhone = Config.LBPhone and GetPhoneNumber and GetPhoneNumber() ~= nil,
    isAdmin = IsAdmin(),
    isSetup = isSetup
  })
  isFetchingTabletData = false
end
function LogOut()
  debugprint("LogOut triggered")
  ToggleOpen(false)
  RemoveAllDispatches()
  tabletLoaded = false
  TabletId = nil
  TabletSettings = nil
end
ReactCallback("loaded", function()
  debugprint("loaded: triggered")
  LoadedNUI = true
  FetchTabletData()
end, "ok")
ReactCallback("getConfigFile", function(fileName)
  return loadConfigFile(fileName)
end)
ReactCallback("finishedSetup", function(settings)
  isSetup = true
  if settings then
    settings.name = LocalPlayer.state.lbTabletName or "??"
    TabletSettings = settings
  end
  TriggerServerEvent("tablet:finishedSetup", settings)
end, "ok")
ReactCallback("getLocales", function()
  return Config.Locales
end, {{locale = "en", name = "English"}})
local function factoryReset()
  LogOut()
  AwaitCallback("factoryReset")
  Wait(500)
  FetchTabletData()
  ToggleOpen(true)
end
exports("FactoryReset", factoryReset)
ReactCallback("factoryReset", function()
  factoryReset()
  return true
end)
ReactCallback("setSettings", function(settings)
  SendReactMessage("customApp:sendMessage", {
    identifier = "any",
    message = {
      action = "settingsUpdated",
      data = settings
    }
  })
  return AwaitCallback("setSettings", settings)
end)
ReactCallback("setName", function(name)
  return AwaitCallback("setName", name)
end)
ReactCallback("toggleInput", function(enabled)
  if Config.KeepInput then
    if enabled then
      Wait(200)
    end
    SetNuiFocusKeepInput(not enabled)
  end
end, "ok")
ReactCallback("setFocus", function()
  if not TabletOpen then
    ToggleOpen(true, nil, true)
  end
end, "ok")
ReactCallback("close", function()
  if TabletOpen then
    ToggleOpen(false, nil, true)
  end
end, "ok")
function ToggleOpen(shouldOpen, skipMessage, forceUnlock)
  local targetState = shouldOpen == nil and not TabletOpen or (shouldOpen == true)
  debugprint("ToggleOpen: " .. tostring(targetState) .. " " .. tostring(shouldOpen) .. " " .. tostring(skipMessage))
  
  if TabletDisabled and targetState then
    debugprint("ToggleOpen: tablet is disabled")
    return
  end
  
  if not tabletLoaded then
    debugprint("ToggleOpen: tablet has not loaded")
    debugprint("UI loaded:" .. tostring(LoadedNUI))
    return
  end
  
  if targetState == TabletOpen then
    debugprint("ToggleOpen: already " .. (targetState and "open" or "closed"))
    return
  end
  
  if targetState then
    if not CanOpenTablet() then
      debugprint("ToggleOpen: not allowed to open tablet (CanOpenTablet returned false)")
      return
    end
  end
  
  opacityToggled = false
  SendReactMessage("toggleOpacity", opacityToggled)
  TabletOpen = targetState
  SetNuiFocus(TabletOpen, TabletOpen)
  
  if Config.KeepInput then
    SetNuiFocusKeepInput(TabletOpen)
  end
  
  if TabletOpen then
    OnOpen()
  else
    OnClose()
  end
  
  if not skipMessage then
    SendReactMessage("setVisibility", TabletOpen)
    if forceUnlock then
      SetTimeout(100, function()
        SendReactMessage("unlock")
      end)
    end
  end
  
  TriggerServerEvent("tablet:toggleOpen", TabletOpen)
  UpdateAnimations()
  
  if not TabletOpen then
    while IsDisabledControlPressed(0, 199) or IsDisabledControlPressed(0, 200) do
      Wait(0)
      DisableControlAction(0, 199, true)
      DisableControlAction(0, 200, true)
    end
  end
  
  if not Config.KeepInput then
    return
  end
  
  if TabletOpen then
    playerId = PlayerId()
    
    if not controlInterval then
      controlInterval = SetInterval(disableControlsLoop)
    end
    if not focusInterval then
      focusInterval = SetInterval(disableFocusControls)
    end
    
    CreateThread(ControllerThread)
    
    if not Config.RealTime then
      if not timeInterval then
        timeInterval = SetInterval(function()
          local timeData
          if Config.CustomTime then
            timeData = Config.CustomTime()
          end
          if not timeData then
            timeData = {
              hour = GetClockHours(),
              minute = GetClockMinutes()
            }
          end
          SendReactMessage("updateTime", timeData)
        end, 1000)
      end
    end
  else
    if controlInterval then
      controlInterval = ClearInterval(controlInterval)
    end
    if focusInterval then
      focusInterval = ClearInterval(focusInterval)
    end
    if timeInterval then
      timeInterval = ClearInterval(timeInterval)
    end
  end
end
function ToggleDisabled(disabled)
  TabletDisabled = disabled == true
  if TabletDisabled and TabletOpen then
    ToggleOpen(false)
  end
end
exports("ToggleDisabled", ToggleDisabled)
exports("ToggleOpen", function(shouldOpen, forceUnlock)
  if type(shouldOpen) == "boolean" then
    ToggleOpen(shouldOpen, nil, forceUnlock == true)
  else
    ToggleOpen(nil, nil, forceUnlock == true)
  end
end)
exports("IsOpen", function()
  return TabletOpen
end)
RegisterNetEvent("tablet:toggleOpen", function(shouldOpen)
  if type(shouldOpen) == "boolean" then
    ToggleOpen(shouldOpen)
  else
    ToggleOpen()
  end
end)
if Config.OpenCommand then
  RegisterCommand(Config.OpenCommand, function()
    ToggleOpen()
  end, false)
end
AddEventHandler("onResourceStop", function(resourceName)
  if resourceName == GetCurrentResourceName() and TabletOpen then
    SetNuiFocus(false, false)
  end
end)
