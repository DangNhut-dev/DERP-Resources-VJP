-- Controller compatibility for LB Phone
-- Handles gamepad/controller input when using the phone UI

local cursorX = 0.5
local cursorY = 0.5
local sensitivity = 0.005
local keyboardToggled = false

-- Check if player is using a controller (not keyboard)
local function isUsingController()
    return not IsUsingKeyboard(0)
end

-- Get controller input with deadzone filtering
local function getControllerInput(control)
    local input = GetDisabledControlNormal(0, control)
    local deadzone = 0.1
    
    if input < -deadzone or input > deadzone then
        return input
    end
    
    return 0.0
end

-- Handle keyboard toggle for controller users
RegisterNUICallback("toggleInput", function(enabled)
    if not isUsingController() then
        return
    end
    
    keyboardToggled = enabled == true
    
    -- Add delay when disabling to prevent immediate re-enabling
    if not enabled then
        Wait(250)
        if keyboardToggled then
            return
        end
    end
    
    SendReactMessage("controller:toggleKeyboard", keyboardToggled)
end)

-- Main controller input handling
local function handleControllerInput()
    -- Get analog stick inputs
    local leftStickX = getControllerInput(1)  -- Left stick X
    local leftStickY = getControllerInput(2)  -- Left stick Y
    local rightStickY = getControllerInput(31) -- Right stick Y (for scrolling)
    
    -- Update cursor position based on left stick input
    cursorX = cursorX + (leftStickX * sensitivity)
    cursorY = cursorY + (leftStickY * sensitivity)
    
    -- Clamp cursor position to screen bounds
    cursorX = math.min(0.99999, math.max(0, cursorX))
    cursorY = math.min(1.0, math.max(0, cursorY))
    
    -- Handle controller button presses
    if IsDisabledControlJustPressed(0, 18) then -- Enter/A button
        SendReactMessage("controller:press", {
            x = cursorX,
            y = cursorY
        })
    elseif IsDisabledControlJustReleased(0, 18) then -- Enter/A button release
        SendReactMessage("controller:release", {
            x = cursorX,
            y = cursorY
        })
    elseif IsDisabledControlJustReleased(0, 199) or IsDisabledControlJustReleased(0, 177) then -- Pause/Back buttons
        ToggleOpen(false)
    end
    
    -- Update cursor position if there's movement
    if leftStickX ~= 0.0 or leftStickY ~= 0.0 then
        SetCursorLocation(cursorX, cursorY)
    end
    
    -- Handle scrolling with right stick
    if rightStickY ~= 0.0 then
        SendReactMessage("controller:scroll", {
            amount = math.floor(rightStickY * 25),
            x = cursorX,
            y = cursorY
        })
    end
    
    -- Disable all control actions to prevent game interference
    DisableAllControlActions(0)
    DisableAllControlActions(1)
    DisableAllControlActions(2)
    InvalidateIdleCam()
end

-- Main controller thread
function ControllerThread()
    while phoneOpen do
        Wait(0)
        
        if isUsingController() and IsNuiFocused() then
            handleControllerInput()
        else
            Wait(500)
        end
    end
    
    -- Reset cursor position when phone closes
    cursorX = 0.5
    cursorY = 0.5
    
    if isUsingController() then
        SetCursorLocation(cursorX, cursorY)
    end
end
