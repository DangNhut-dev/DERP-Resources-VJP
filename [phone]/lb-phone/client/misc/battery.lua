-- Battery management for LB Phone
-- Handles battery level, charging state, and phone death when battery is empty

local batteryLevel = 100
local isCharging = false

-- Set battery level and handle phone death at 0%
local function setBattery(battery)
    if not Config.Battery.Enabled then
        return
    end
    
    assert(type(battery) == "number", "setBattery: battery must be a number")
    assert(battery >= 0 and battery <= 100, "setBattery: battery must be between 0 and 100")
    
    batteryLevel = battery
    
    -- Handle phone death when battery reaches 0
    if battery == 0 then
        OnDeath()
        TriggerEvent("lb-phone:phoneDied")
    end
    
    -- Sync battery level with server
    TriggerServerEvent("phone:battery:setBattery", battery)
end

-- Handle NUI callback to set battery level
RegisterNUICallback("setBattery", function(data, callback)
    setBattery(data)
    callback("ok")
end)

-- Export function to set battery level
exports("SetBattery", function(battery)
    setBattery(battery)
    SendReactMessage("battery:setBattery", battery)
end)

-- Export function to get current battery level
exports("GetBattery", function()
    return batteryLevel
end)

-- Toggle charging state
function ToggleCharging(toggle)
    assert(type(toggle) == "boolean", "ToggleCharging: toggle must be a boolean")
    
    if isCharging == toggle then
        debugprint("ToggleCharging: charging is already set to", toggle)
        return
    end
    
    isCharging = toggle
    SendReactMessage("battery:toggleCharging", toggle)
end

-- Export charging toggle function
exports("ToggleCharging", ToggleCharging)

-- Export function to check if phone is charging
exports("IsCharging", function()
    return isCharging
end)

-- Check if phone is dead (battery at 0%)
function IsPhoneDead()
    if not Config.Battery.Enabled then
        return false
    end
    
    return batteryLevel == 0
end

-- Export phone death check function
exports("IsPhoneDead", IsPhoneDead)
