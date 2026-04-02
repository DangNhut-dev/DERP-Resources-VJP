local notificationActions = {}

local function getNotifications()
    local notifications = AwaitCallback("notifications:get")
    for _, notification in ipairs(notifications) do
        if notification.customData then
            local customData = json.decode(notification.customData)
            if customData.buttons then
                notification.actions = customData.buttons
                notificationActions[notification.id] = notification
            end
            notification.customData = nil
        end
    end
    return notifications
end

local function handleButtonPress(notificationId, buttonIndex)
    local notification = notificationActions[notificationId]
    local buttons = notification and notification.actions
    if not buttons then
        debugprint("No buttons found for notification", notificationId)
        return false
    end
    local button = buttons[buttonIndex]
    if not button then
        debugprint("Button not found for notification", notificationId, buttonIndex)
        return false
    end
    if button.event then
        if button.server then
            TriggerServerEvent(button.event, button.data)
        else
            TriggerEvent(button.event, button.data)
        end
    end
    return true
end

local function deleteNotification(id)
    if not id then
        return true
    end
    if type(id) == "string" and id:find("client%-notification%-") then
        return true
    end
    local success = AwaitCallback("notifications:delete", id)
    if not success then
        return false
    end
    return success
end

ReactCallback("Notifications", function(data)
    local action = data.action
    if action == "getNotifications" then
        return getNotifications()
    elseif action == "button" then
        return handleButtonPress(data.id, (data.buttonId or 0) + 1)
    elseif action == "deleteNotification" then
        return deleteNotification(data.id)
    elseif action == "clearNotifications" then
        return AwaitCallback("notifications:clear", data.app)
    end
end)

RegisterNetEvent("tablet:notifications:new", function(notification)
    if not notification.id then
        notification.id = "client-notification-" .. math.random()
    end
    if notification.customData then
        if notification.customData.buttons then
            notification.actions = notification.customData.buttons
            notificationActions[notification.id] = notification
        end
        notification.customData = nil
    end
    SendReactMessage("newNotification", notification)
end)

exports("SendNotification", function(notification)
    TriggerEvent("tablet:notifications:new", notification)
end)