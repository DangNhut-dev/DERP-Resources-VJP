-- Custom App Handler for LB Phone
-- Manages custom applications, UI components, and their lifecycle events

-- Storage for popup and context menu callbacks
local popupCallbacks = {}

-- Valid button colors for UI components
local validColors = {
    blue = true,
    red = true,
    green = true,
    yellow = true
}

-- Component types and their expected return values
local componentTypes = {
    gallery = {"image"},
    gif = {"gif"},
    emoji = {"emoji"},
    camera = {"url"},
    colorpicker = {"color"},
    contactselector = {"contact"}
}

-- Generate unique ID for callbacks
local function generateId()
    local id = math.random(999999999)
    while popupCallbacks[id] do
        id = math.random(999999999)
    end
    return id
end

-- Register NUI callback for custom app actions
RegisterNUICallback("CustomApp", function(data, callback)
    local appName = data.app
    local action = data.action
    
    callback("ok")
    
    if not action or not appName then
        debugprint("invalid data")
        return
    end
    
    local appConfig = Config.CustomApps[appName]
    
    if action == "open" then
        -- Trigger server event if app requires server-side handling
        if appConfig and appConfig.onServerUse then
            TriggerServerEvent("lb-phone:customApp", appName)
        end
        
        -- Close phone if app has no UI and doesn't keep phone open
        if not (appConfig and appConfig.ui) then
            if not (appConfig and appConfig.keepOpen) then
                debugprint("Closing phone due to custom app without ui")
                ToggleOpen(false)
            end
        end
        
        -- Execute onUse callback in new thread
        if appConfig and appConfig.onUse then
            Citizen.CreateThreadNow(function()
                appConfig.onUse()
            end)
        end
        
        -- Execute onOpen callback in new thread
        if appConfig and appConfig.onOpen then
            Citizen.CreateThreadNow(function()
                appConfig.onOpen()
            end)
        end
        
    elseif action == "close" then
        if appConfig and appConfig.onClose then
            appConfig.onClose()
        end
        
    elseif action == "install" then
        if appConfig and appConfig.onInstall then
            appConfig.onInstall()
        end
        
    elseif action == "uninstall" then
        if appConfig and appConfig.onDelete then
            appConfig.onDelete()
        end
    end
end)
-- Handle popup button clicks
RegisterNUICallback("PopUp", function(callbackId, callback)
    local popupCallback = popupCallbacks[callbackId]
    if not popupCallback then
        return
    end
    
    callback("ok")
    popupCallback()
    popupCallbacks[callbackId] = nil
end)

-- Handle popup input changes
RegisterNUICallback("PopUpInputChanged", function(data, callback)
    local callbackId = data.id
    local value = data.value
    local inputCallback = popupCallbacks[callbackId]
    
    if not inputCallback then
        return
    end
    
    callback("ok")
    inputCallback(value)
end)
-- Function to set up popup with validation and callbacks
local function setupPopup(popupData, isExport)
    assert(popupData.buttons and #popupData.buttons > 0, "You need at least one button")
    
    for _, button in pairs(popupData.buttons) do
        assert(button.title, "You need a title for each button")
        assert(validColors[button.color or "blue"], "Invalid color")
        
        if isExport then
            if button.cb then
                local callbackId = generateId()
                local originalCallback = button.cb
                popupCallbacks[callbackId] = function()
                    originalCallback(button.callbackId)
                end
                button.cb = callbackId
            end
        else
            if button.callbackId then
                local callbackId = generateId()
                popupCallbacks[callbackId] = function()
                    isExport(button.callbackId)
                end
                button.cb = callbackId
            end
        end
    end
    
    -- Handle input onChange callback
    local input = popupData.input
    if input and input.onChange then
        local callbackId = generateId()
        
        if isExport then
            local originalCallback = input.onChange
            popupCallbacks[callbackId] = originalCallback
        else
            popupCallbacks[callbackId] = function(value)
                SendReactMessage("customApp:sendMessage", {
                    identifier = "any",
                    message = {
                        type = "popUpInputChanged",
                        value = value
                    }
                })
            end
        end
        
        input.onChange = callbackId
    end
    
    SendReactMessage("onComponentUse", {
        type = "popup",
        data = popupData
    })
end

-- Register NUI callback for setting popup
RegisterNUICallback("SetPopUp", setupPopup)

-- Export popup function
exports("SetPopUp", function(popupData)
    setupPopup(popupData, true)
end)

-- Handle context menu button clicks
RegisterNUICallback("ContextMenu", function(callbackId, callback)
    local contextCallback = popupCallbacks[callbackId]
    if not contextCallback then
        return
    end
    
    contextCallback()
    popupCallbacks[callbackId] = nil
    callback("ok")
end)

-- Function to set up context menu with validation and callbacks
local function setupContextMenu(menuData, isExport)
    assert(menuData.buttons and #menuData.buttons > 0, "You need at least one button")
    
    for _, button in pairs(menuData.buttons) do
        assert(button.title, "You need a title for each button")
        assert(validColors[button.color or "blue"], "Invalid colour")
        
        if isExport then
            assert(button.cb, "You need a callback for each button")
        else
            assert(button.callbackId, "You need a callback for each button")
        end
        
        local callbackId = generateId()
        local originalCallback = button.cb
        
        popupCallbacks[callbackId] = function()
            if isExport then
                originalCallback()
            else
                isExport(button.callbackId)
            end
        end
        
        button.cb = callbackId
    end
    
    SendReactMessage("onComponentUse", {
        type = "contextmenu",
        data = menuData
    })
end

-- Register NUI callback for setting context menu
RegisterNUICallback("SetContextMenu", setupContextMenu)

-- Export context menu function
exports("SetContextMenu", function(menuData)
    setupContextMenu(menuData, true)
end)

-- Function to set up camera component
local function setupCameraComponent(cameraData, callback)
    if type(cameraData) ~= "table" or not cameraData then
        cameraData = {}
    end
    
    local promise = nil
    local wasPhoneOpen = phoneOpen
    local callbackId = generateId()
    
    cameraData.id = callbackId
    
    -- Open phone if not already open
    if not wasPhoneOpen then
        debugprint("Opening phone due to camera component")
        ToggleOpen(true)
    end
    
    -- Create promise if no callback provided
    if not callback then
        promise = promise.new()
    end
    
    popupCallbacks[callbackId] = function(data)
        if callback then
            callback(data.url)
        else
            promise:resolve(data.url)
        end
        
        -- Close phone if it wasn't open before
        if not wasPhoneOpen then
            debugprint("Closing phone due to camera component")
            ToggleOpen(false)
        end
    end
    
    SendReactMessage("onComponentUse", {
        type = "camera",
        data = cameraData
    })
    
    if not callback then
        return Citizen.Await(promise)
    end
end

-- Export camera component function
exports("SetCameraComponent", setupCameraComponent)

-- Function to set up contact modal
local function setupContactModal(phoneNumber)
    assert(phoneNumber, "You need to provide a phone number")
    
    SendReactMessage("onComponentUse", {
        type = "contactmodal",
        data = phoneNumber
    })
end

-- Register NUI callback for setting contact modal
RegisterNUICallback("SetContactModal", function(data, callback)
    setupContactModal(data)
    callback("ok")
end)

-- Export contact modal function
exports("SetContactModal", setupContactModal)

-- Handle component usage
RegisterNUICallback("UsedComponent", function(data, callback)
    local callbackId = data and data.id
    
    if not callbackId or not popupCallbacks[callbackId] then
        return
    end
    
    popupCallbacks[callbackId](data)
    popupCallbacks[callbackId] = nil
    callback("ok")
end)

-- Function to show generic components
local function showComponent(componentData, callback)
    local componentType = componentData.component
    
    assert(componentType, "You need to specify a component")
    assert(componentTypes[componentType], "Invalid component")
    
    local callbackId = generateId()
    
    popupCallbacks[callbackId] = function(data)
        local results = {}
        for _, returnType in pairs(componentTypes[componentType]) do
            table.insert(results, data[returnType])
        end
        callback(table.unpack(results))
    end
    
    componentData.id = callbackId
    
    SendReactMessage("onComponentUse", {
        type = componentType,
        data = componentData
    })
end

-- Register NUI callback for showing components
RegisterNUICallback("ShowComponent", showComponent)

-- Export component function
exports("ShowComponent", showComponent)

-- Register NUI callback for creating calls
RegisterNUICallback("CreateCall", function(data, callback)
    CreateCall(data)
    callback("ok")
end)

-- Register NUI callback for getting settings
RegisterNUICallback("GetSettings", function(data, callback)
    callback(settings)
end)

-- Register NUI callback for getting locale
RegisterNUICallback("GetLocale", function(data, callback)
    callback(L(data.path, data.format))
end)

-- Register NUI callback for sending notifications
RegisterNUICallback("SendNotification", function(data, callback)
    -- Remove buttons from custom data if present (security measure)
    if data and data.customData and data.customData.buttons then
        data.customData.buttons = nil
        debugprint("You cannot create notifications with buttons from the NUI.")
    end
    
    TriggerEvent("phone:sendNotification", data)
    callback(true)
end)
