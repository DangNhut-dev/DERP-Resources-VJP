-- Notification management for LB Phone
-- Handles notification display, deletion, and interactive buttons

local notificationActions = {}

-- Get all notifications from server
local function getNotifications()
    local notifications = AwaitCallback("getNotifications")
    
    -- Process notifications and handle legacy format
    for i = 1, #notifications do
        local notification = notifications[i]
        
        -- Handle legacy title/content format
        if notification.content == nil then
            notification.content = notification.title
            notification.title = nil
        end
        
        -- Process custom data for interactive buttons
        if notification.custom_data then
            local customData = json.decode(notification.custom_data)
            if customData.buttons then
                notification.actions = customData.buttons
                notificationActions[notification.id] = notification
            end
            notification.custom_data = nil
        end
    end
    
    return notifications
end

-- Delete a specific notification
local function deleteNotification(notificationId)
    if not notificationId then
        return true
    end
    
    -- Handle client-side notifications
    if type(notificationId) == "string" and notificationId:find("client%-notification%-") then
        notificationActions[notificationId] = nil
        return true
    end
    
    -- Delete server-side notification
    local success = AwaitCallback("deleteNotification", notificationId)
    if not success then
        return false
    end
    
    -- Remove from local actions cache
    if notificationActions[notificationId] then
        notificationActions[notificationId] = nil
    end
    
    return success
end

-- Clear all notifications for a specific app
local function clearNotifications(appName)
    local success = AwaitCallback("clearNotifications", appName)
    if not success then
        return false
    end
    
    -- Remove matching notifications from local actions cache
    for id, notification in pairs(notificationActions) do
        if notification.app == appName then
            notificationActions[id] = nil
        end
    end
    
    return success
end

-- Handle notification button press
local function handleNotificationButton(notificationId, buttonIndex)
    local notification = notificationActions[notificationId]
    if not notification or not notification.actions then
        debugprint("No buttons found for notification", notificationId)
        return false
    end
    
    local button = notification.actions[buttonIndex]
    if not button then
        debugprint("Button not found for notification", notificationId, buttonIndex)
        return false
    end
    
    -- Trigger button event
    if button.event then
        if button.server then
            TriggerServerEvent(button.event, button.data)
        else
            TriggerEvent(button.event, button.data)
        end
    end
    
    return true
end

-- Handle Notifications NUI callbacks
RegisterNUICallback("Notifications", function(data, callback)
    local action = data.action
    debugprint("Notifications:" .. (action or ""))
    
    if action == "getNotifications" then
        return callback(getNotifications())
    elseif action == "deleteNotification" then
        if data.id ~= nil then
            return callback(deleteNotification(data.id))
        end
    elseif action == "clearNotifications" then
        return callback(clearNotifications(data.app))
    elseif action == "button" then
        callback(handleNotificationButton(data.id, (data.buttonId or 0) + 1))
    end
end)

-- Handle incoming notifications from server
RegisterNetEvent("phone:sendNotification", function(notification)
    -- Check if player has phone and it's not disabled
    if not HasPhoneItem(currentPhone) or phoneDisabled then
        debugprint("no phone, not showing notification")
        return
    end
    
    -- Handle legacy title/content format
    if notification.content == nil then
        notification.content = notification.title
        notification.title = nil
    end
    
    -- Process custom data for interactive buttons
    if notification.customData then
        if notification.customData.buttons and notification.id then
            notification.actions = notification.customData.buttons
            notificationActions[notification.id] = notification
        end
        notification.customData = nil
    end
    
    -- Send notification to UI
    SendReactMessage("newNotification", notification)
end)

-- Export function to send notifications from other resources
exports("SendNotification", function(notification)
    -- Generate unique ID for client-side notifications
    notification.id = "client-notification-" .. math.random()
    TriggerEvent("phone:sendNotification", notification)
end)
