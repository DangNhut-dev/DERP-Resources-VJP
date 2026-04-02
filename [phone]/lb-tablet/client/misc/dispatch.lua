local dispatches = {}
local notificationKeys = {
  "NotificationUp",
  "NotificationDown", 
  "NotificationDismiss",
  "NotificationView",
  "NotificationRespond",
  "NotificationExpand"
}
local dispatchVisible = true
local dutyDispatchVisible = true
local currentDispatchJob = nil
local dismissedDispatches = {}
local function DismissDispatch(id)
  local dispatch = dispatches[id]
  if not dispatch then
    debugprint("DismissDispatch: No dispatch found with id", id)
    return
  end
  local blipHandle = dispatch.blip and dispatch.blip.handle
  if blipHandle then
    RemoveBlip(blipHandle)
  end
  dismissedDispatches[id] = true
end
ReactCallback("Dispatch", function(data)
  local action = data.action
  if action == "respondDispatch" then
    if data.id then
      local dispatch = dispatches[data.id]
      if dispatch then
        RespondToDispatch(dispatch)
      end
    else
      debugprint("Invalid dispatch id for respond", data.id)
    end
    return "ok"
  elseif action == "deleteDispatch" then
    return AwaitCallback("deleteDispatch", data.id)
  elseif action == "clearDispatches" then
    if data.removeForEveryone then
      return AwaitCallback("clearDispatches")
    else
      RemoveAllDispatches()
      return true
    end
  elseif action == "dismissDispatch" then
    if data.id then
      DismissDispatch(data.id)
    end
    return "ok"
  end
end)
function GetDispatchControls()
  local controls = {}
  for i = 1, #notificationKeys do
    local keyName = notificationKeys[i]
    local bindData = Config.KeyBinds[keyName] and Config.KeyBinds[keyName].bindData
    if bindData then
      local instructionalButton = GetControlInstructionalButton(0, bindData.hash, true)
      local buttonPrefix = instructionalButton:sub(1, 2)
      if buttonPrefix == "b_" then
        controls[keyName] = GetInstructionalButtonName(instructionalButton)
      elseif buttonPrefix == "t_" then
        controls[keyName] = instructionalButton:sub(3)
      end
    end
  end
  return controls
end
local function SetDispatchControls()
  SendReactMessage("dispatch:setControls", GetDispatchControls())
end
local function UpdateZIndex()
  if not Config.DispatchUpdateZIndex then
    debugprint("Config.DispatchUpdateZIndex is false, not updating z-index")
    return
  end
  if TabletOpen then
    debugprint("Tablet is open, already has high z-index")
    return
  end
  if not SetNuiZindex then
    debugprint("SetNuiZindex does not exist")
    return
  end
  if dispatchVisible then
    debugprint("Dispatch is visible; setting z-index to 99")
    SetNuiZindex(99)
  else
    debugprint("Dispatch not visible & tablet not open; setting z-index to 0")
    SetNuiZindex(0)
  end
end
local function CreateDispatchBlip(dispatch)
  if not Config.DispatchBlip.Enabled then
    return
  end
  if dispatch.blip == false or (dispatch.blip == nil and not Config.DispatchBlip.Default) then
    return
  end
  if not IsOnDuty() then
    if dispatch.blip and dispatch.blip.handle then
      RemoveBlip(dispatch.blip.handle)
    end
    return
  end
  if not dispatch.blip then
    dispatch.blip = {}
  end
  local sprite = dispatch.blip.sprite or Config.DispatchBlip.Default.Sprite
  local color = dispatch.blip.color or Config.DispatchBlip.Default.Color
  local label = dispatch.blip.label or Config.DispatchBlip.Default.Label
  local size = dispatch.blip.size or Config.DispatchBlip.Default.Size
  local shortRange = dispatch.blip.shortRange or Config.DispatchBlip.Default.ShortRange
  
  dispatch.blip.handle = CreateBlip(
    vector2(dispatch.location.coords.x, dispatch.location.coords.y),
    sprite,
    color,
    FormatString(label, {
      dispatch_title = dispatch.title,
      id = dispatch.id,
      priority = dispatch.priority
    }),
    size,
    shortRange
  )
end
local function AddDispatch(dispatch)
  dispatches[dispatch.id] = dispatch
  CreateDispatchBlip(dispatch)
  SetDispatchControls()
  SendReactMessage("dispatch:add", dispatch)
  UpdateZIndex()
  debugprint("Dispatch: Added dispatch", dispatch.id, dispatch.title)
end
local function UpdateDispatch(dispatch)
  local oldDispatch = dispatches[dispatch.id]
  if not oldDispatch then
    debugprint("Old dispatch not found", dispatch.id)
    return
  end
  if dismissedDispatches[dispatch.id] then
    debugprint("Dispatch is dismissed, not updating", dispatch.id)
    return
  end
  if oldDispatch and oldDispatch.blip and oldDispatch.blip.handle then
    RemoveBlip(oldDispatch.blip.handle)
  end
  dispatches[dispatch.id] = dispatch
  CreateDispatchBlip(dispatch)
  SetDispatchControls()
  SendReactMessage("dispatch:update", dispatch)
end
local function RemoveDispatch(id)
  local dispatch = dispatches[id]
  if not dispatch then
    return
  end
  if dispatch.blip and dispatch.blip.handle then
    RemoveBlip(dispatch.blip.handle)
  end
  dispatches[id] = nil
  dismissedDispatches[id] = nil
  SendReactMessage("dispatch:remove", id)
end
RegisterNetEvent("tablet:addDispatch", function(dispatch)
  if Config.DispatchEnabled == false then
    debugprint("tablet:addDispatch - Config.DispatchEnabled is set to false")
    return
  end
  if currentDispatchJob ~= dispatch.job then
    debugprint("Not adding dispatch as job is different", currentDispatchJob, dispatch.job)
    return
  end
  AddDispatch(dispatch)
end)
RegisterNetEvent("tablet:updateDispatch", function(dispatch)
  if currentDispatchJob ~= dispatch.job then
    return debugprint("Not updating dispatch as job is different")
  end
  UpdateDispatch(dispatch)
end)

RegisterNetEvent("tablet:removeAllDispatches", function(job)
  if currentDispatchJob ~= job then
    debugprint("Not removing all dispatches as job is different", currentDispatchJob, job)
    return
  end
  RemoveAllDispatches()
end)

RegisterNetEvent("tablet:removeDispatch", function(id)
  RemoveDispatch(id)
end)
function ToggleDispatchVisible(visible)
  dispatchVisible = visible == true
  if dutyDispatchVisible then
    SendReactMessage("dispatch:toggleDispatch", dispatchVisible)
    UpdateZIndex()
  else
    debugprint("Dispatch is not visible as dutyDispatchVisible is false")
  end
end
exports("ToggleDispatchVisible", ToggleDispatchVisible)
exports("IsDispatchVisible", function()
  return dispatchVisible
end)
function RemoveAllDispatches()
  debugprint("Removing all dispatches")
  for id, _ in pairs(dispatches) do
    RemoveDispatch(id)
  end
end
function RefreshAllDispatches()
  local newJob = nil
  local newDispatches = {}
  
  if IsPolice() then
    local permissions = GetPermissions("Police")
    if permissions and permissions.dispatch and permissions.dispatch.view ~= false then
      newJob = "police"
      local dispatches = AwaitCallback("police:getDispatches")
      newDispatches = dispatches or {}
      debugprint("Dispatch: RefreshAllDispatches - newJob = police")
    end
  elseif IsAmbulance() then
    local permissions = GetPermissions("Ambulance")
    if permissions and permissions.dispatch and permissions.dispatch.view ~= false then
      newJob = "ambulance"
      local dispatches = AwaitCallback("ambulance:getDispatches")
      newDispatches = dispatches or {}
      debugprint("Dispatch: RefreshAllDispatches - newJob = ambulance")
    end
  else
    debugprint("Dispatch: RefreshAllDispatches - No job found, removing all dispatches")
    RemoveAllDispatches()
    currentDispatchJob = nil
    return
  end
  
  if newJob ~= currentDispatchJob then
    debugprint("Dispatch: RefreshAllDispatches - newJob is different from currentDispatchJob", newJob, currentDispatchJob)
    RemoveAllDispatches()
    currentDispatchJob = newJob
  end
  
  SetDispatchControls()
  
  for id, dispatch in pairs(newDispatches) do
    if dispatches[id] then
      UpdateDispatch(dispatch)
    else
      AddDispatch(dispatch)
    end
    dispatches[id] = dispatch
  end
  
  for id, _ in pairs(dispatches) do
    if not newDispatches[id] then
      RemoveDispatch(id)
    end
  end
end
local notificationKeyMap = {
  NotificationUp = "up",
  NotificationDown = "down",
  NotificationDismiss = "dismiss",
  NotificationView = "view",
  NotificationRespond = "respond",
  NotificationExpand = "expand"
}

AddEventHandler("lb-tablet:keyReleased", function(key)
  local action = notificationKeyMap[key]
  if not action then return end

  if dispatchVisible then
    if IsNuiFocused() then
      if not TabletOpen then
        return
      end
      if IsNuiFocusKeepingInput() then
        return
      end
    end
  end

  SendReactMessage("dispatch:" .. action)
end)

AddEventHandler("lb-tablet:jobUpdated", function()
  debugprint("Dispatch: job updated, refreshing all dispatches & visibility")
  if Config.RequireDutyDispatch then
    dutyDispatchVisible = IsOnDuty()
    if dutyDispatchVisible then
      SendReactMessage("dispatch:toggleDispatch", dispatchVisible)
    else
      SendReactMessage("dispatch:toggleDispatch", false)
    end
    debugprint("Dispatch: dutyDispatchVisible:", dutyDispatchVisible, "dispatchVisible:", dispatchVisible)
  end
  RefreshAllDispatches()
end)

exports("AddDispatch", function(dispatch)
  if not Config.AllowClientDispatch then
    infoprint("error", "AddDispatch: Config.AllowClientDispatch is set to false")
    return false
  end
  TriggerServerEvent("lb-tablet:addDispatch", dispatch)
end)
