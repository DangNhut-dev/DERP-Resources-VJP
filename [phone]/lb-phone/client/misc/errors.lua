-- Error handling and logging for LB Phone
-- Handles UI errors and provides crash recovery functionality

-- Handle error logging from the UI
RegisterNUICallback("logError", function(data, callback)
    local uiPage = GetResourceMetadata(GetCurrentResourceName(), "ui_page", 0)
    
    -- Only process errors from the correct UI page
    if uiPage == "ui/dist/index.html" then
        local errorMessage = data.error or "No error message"
        local stackTrace = data.stack or "No stack"
        local componentStack = data.componentStack or "No component stack"
        
        -- Send error details to server for logging
        TriggerServerEvent("phone:logError", errorMessage, stackTrace, componentStack)
    end
    
    local wasPhoneOpen = phoneOpen
    
    -- Reset phone state after error
    OnDeath()
    
    -- Reopen phone if it was open when the error occurred
    if wasPhoneOpen then
        debugprint("Opening phone due to error")
        ToggleOpen(true)
    end
    
    -- Wait before showing crash notification
    Wait(5000)
    
    -- Show system crash notification
    TriggerEvent("phone:sendNotification", {
        app = "Settings",
        title = "System Crash",
        content = "Your phone crashed. Press F8 for more info."
    })
    
    callback("ok")
end)
