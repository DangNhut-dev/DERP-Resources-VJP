-- Custom App management for LB Phone
-- Handles registration, removal, and messaging for custom apps from other resources

-- Format custom app data for UI display
function FormatCustomAppDataForUI(appData)
    return {
        identifier = appData.identifier,
        resourceName = appData.resourceName,
        custom = true,
        name = appData.name,
        icon = appData.icon,
        description = appData.description,
        images = appData.images,
        developer = appData.developer,
        size = appData.size or 42000,
        price = appData.price,
        game = appData.game,
        landscape = appData.landscape or false,
        removable = not appData.defaultApp,
        disableInAppNotifications = appData.disableInAppNotifications,
        ui = appData.ui,
        fixBlur = appData.fixBlur,
        access = HasAccessToApp(appData.identifier)
    }
end

-- Export function to send messages to custom apps
exports("SendCustomAppMessage", function(identifier, message)
    local invokingResource = GetInvokingResource()
    
    if not identifier then
        return false, "No identifier provided"
    end
    
    local app = Config.CustomApps[identifier]
    if not app then
        return false, "App does not exist"
    end
    
    -- Verify the calling resource owns this app
    if app.resourceName ~= invokingResource then
        return false, "App was not created by " .. invokingResource
    end
    
    SendReactMessage("customApp:sendMessage", {
        identifier = identifier,
        message = message
    })
    
    return true
end)

-- Export function to add custom apps
exports("AddCustomApp", function(appData)
    local invokingResource = GetInvokingResource()
    
    -- Validate required fields
    if not appData or not appData.identifier then
        return false, "No identifier provided"
    end
    
    if not appData.name then
        return false, "No name provided"
    end
    
    if not appData.description then
        return false, "No description provided"
    end
    
    -- Check if app already exists
    if Config.CustomApps[appData.identifier] then
        return false, "App already exists"
    end
    
    -- Create app configuration
    Config.CustomApps[appData.identifier] = {
        identifier = appData.identifier,
        resourceName = invokingResource,
        custom = true,
        name = appData.name,
        icon = appData.icon,
        description = appData.description,
        images = appData.images,
        developer = appData.developer,
        size = appData.size or 42000,
        price = appData.price,
        game = appData.game,
        landscape = appData.landscape or false,
        removable = not appData.defaultApp,
        defaultApp = appData.defaultApp,
        disableInAppNotifications = appData.disableInAppNotifications,
        ui = appData.ui,
        fixBlur = appData.fixBlur,
        onOpen = appData.onOpen,
        onClose = appData.onClose,
        onUse = appData.onUse,
        onDelete = appData.onDelete,
        onInstall = appData.onInstall
    }
    
    debugprint("adding custom app", appData.identifier)
    
    -- Send app data to UI
    SendReactMessage("addCustomApp", FormatCustomAppDataForUI(Config.CustomApps[appData.identifier]))
    
    return true
end)

-- Export function to remove custom apps
exports("RemoveCustomApp", function(identifier)
    local invokingResource = GetInvokingResource()
    
    if not identifier then
        return false, "No identifier provided"
    end
    
    local app = Config.CustomApps[identifier]
    if not app then
        return false, "App does not exist"
    end
    
    -- Verify the calling resource owns this app
    if app.resourceName ~= invokingResource then
        return false, "App was not created by " .. invokingResource
    end
    
    -- Remove app from config and UI
    Config.CustomApps[identifier] = nil
    SendReactMessage("removeCustomApp", identifier)
    
    return true
end)

-- Clean up custom apps when their resource stops
AddEventHandler("onResourceStop", function(resourceName)
    for identifier, app in pairs(Config.CustomApps) do
        if app.resourceName == resourceName then
            Config.CustomApps[identifier] = nil
            SendReactMessage("removeCustomApp", identifier)
            debugprint("Removed app " .. identifier .. " due to resource stopping")
        end
    end
end)
