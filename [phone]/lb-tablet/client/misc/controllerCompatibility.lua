local cursorX, cursorY = 0.5, 0.5
local sensitivity = 0.005
local inputEnabled = false

local function isUsingController()
  return not IsUsingKeyboard(0)
end

local function getControlNormal(control)
  local value = GetDisabledControlNormal(0, control)
  return (value < -0.1 or value > 0.1) and value or 0.0
end

RegisterNUICallback("toggleInput", function(enabled)
  if not isUsingController() then return end
  inputEnabled = enabled == true
  if not enabled then
    Wait(250)
    if inputEnabled then return end
  end
  SendReactMessage("controller:toggleKeyboard", inputEnabled)
end)

local function handleControllerInput()
  local lookX = getControlNormal(1)
  local lookY = getControlNormal(2)
  local scroll = getControlNormal(31)

  cursorX = cursorX + (lookX * sensitivity)
  cursorY = cursorY + (lookY * sensitivity)
  cursorX = math.max(0, math.min(0.99999, cursorX))
  cursorY = math.max(0, math.min(1.0, cursorY))

  if IsDisabledControlJustPressed(0, 18) then
    SendReactMessage("controller:press", { x = cursorX, y = cursorY })
  elseif IsDisabledControlJustReleased(0, 18) then
    SendReactMessage("controller:release", { x = cursorX, y = cursorY })
  elseif IsDisabledControlJustReleased(0, 199) or IsDisabledControlJustReleased(0, 177) then
    ToggleOpen(false)
  end

  if lookX ~= 0.0 or lookY ~= 0.0 then
    SetCursorLocation(cursorX, cursorY)
  end

  if scroll ~= 0.0 then
    SendReactMessage("controller:scroll", {
      amount = math.floor(scroll * 25),
      x = cursorX,
      y = cursorY
    })
  end

  DisableAllControlActions(0)
  DisableAllControlActions(1)
  DisableAllControlActions(2)
  InvalidateIdleCam()
end

function ControllerThread()
  while true do
    if not TabletOpen then break end
    Wait(0)
    if isUsingController() and IsNuiFocused() then
      handleControllerInput()
    else
      Wait(500)
    end
  end
  cursorX, cursorY = 0.5, 0.5
  if isUsingController() then
    SetCursorLocation(cursorX, cursorY)
  end
end