-- Auto-delete old notifications system
-- This script automatically deletes old notifications based on configured hours

-- Check if auto-delete is enabled
if not Config.AutoDeleteNotifications then
    return
end

-- Validate configuration and set default if invalid
if type(Config.AutoDeleteNotifications) ~= "number" then
    Config.AutoDeleteNotifications = 168 -- Default: 7 days (168 hours)
end

-- Wait for database checker to finish
while true do
    if DatabaseCheckerFinished then
        break
    end
    Wait(500)
end

-- Main auto-delete loop
while true do
    debugprint("Deleting all old notifications..")
    
    local startTime = os.nanotime()
    
    -- Delete notifications older than configured hours
    MySQL.update("DELETE FROM phone_notifications WHERE `timestamp` < DATE_SUB(NOW(), INTERVAL ? HOUR)", {
        Config.AutoDeleteNotifications
    }, function(deletedCount)
        local endTime = os.nanotime()
        local executionTime = (endTime - startTime) / 1000000.0
        
        -- Format plural/singular notification text
        local notificationText = "notification"
        if deletedCount ~= 1 then
            notificationText = "notifications"
        end
        
        debugprint(string.format("Deleted %d %s in %.2f ms", deletedCount, notificationText, executionTime))
    end)
    
    -- Wait 1 hour before next cleanup (3600000 ms = 1 hour)
    Wait(3600000)
end
