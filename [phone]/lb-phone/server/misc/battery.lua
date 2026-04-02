-- Phone battery management system
-- Handles battery levels, saving, and phone death state

-- Store battery levels for each phone number
local batteryLevels = {}

-- Event handler to set battery level for a phone
RegisterNetEvent("phone:battery:setBattery", function(batteryLevel)
    local source = source
    
    -- Check if battery system is enabled
    if not Config.Battery.Enabled then
        debugprint("setBattery: battery system disabled")
        return
    end
    
    -- Validate battery level
    if type(batteryLevel) ~= "number" or batteryLevel < 0 or batteryLevel > 100 then
        debugprint("setBattery: invalid battery")
        return
    end
    
    local phoneNumber = GetEquippedPhoneNumber(source)
    if not phoneNumber then
        return
    end
    
    -- Store battery level in memory
    batteryLevels[phoneNumber] = batteryLevel
end)

-- Function to check if a phone is dead (battery at 0%)
function IsPhoneDead(phoneNumber)
    if not Config.Battery.Enabled then
        return false
    end
    
    return batteryLevels[phoneNumber] == 0
end

-- Export IsPhoneDead function
exports("IsPhoneDead", IsPhoneDead)

-- Function to save battery level to database for a specific player
function SaveBattery(source)
    local phoneNumber = GetEquippedPhoneNumber(source)
    if not phoneNumber or not batteryLevels[phoneNumber] then
        return
    end
    
    debugprint(string.format("saving battery level (%s) for %s", batteryLevels[phoneNumber], phoneNumber))
    
    -- Update battery in database
    MySQL.update("UPDATE phone_phones SET battery = ? WHERE phone_number = ?", {
        batteryLevels[phoneNumber],
        phoneNumber
    }, function()
        -- Clear from memory after saving
        batteryLevels[phoneNumber] = nil
    end)
end

-- Export SaveBattery function
exports("SaveBattery", SaveBattery)

-- Function to save all battery levels for all players
local function SaveAllBatteries()
    debugprint("saving all battery levels")
    
    local players = GetPlayers()
    for i = 1, #players do
        SaveBattery(players[i])
    end
end

-- Export SaveAllBatteries function
exports("SaveAllBatteries", SaveAllBatteries)

-- Save battery when player disconnects
AddEventHandler("playerDropped", function()
    SaveBattery(source)
end)

-- Save all batteries before scheduled restart (1 minute warning)
AddEventHandler("txAdmin:events:scheduledRestart", function(eventData)
    if eventData.secondsRemaining == 60 then
        SaveAllBatteries()
    end
end)

-- Save all batteries on server shutdown
AddEventHandler("txAdmin:events:serverShuttingDown", SaveAllBatteries)

-- Save all batteries when resource stops
AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        SaveAllBatteries()
    end
end)
