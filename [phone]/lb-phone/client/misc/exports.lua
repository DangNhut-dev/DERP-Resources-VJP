-- Export functions for LB Phone
-- Provides external API functions for other resources to interact with the phone

-- Toggle home indicator visibility
exports("ToggleHomeIndicator", function(show)
    SendReactMessage("toggleShowHomeIndicator", show)
end)

-- Toggle landscape mode
exports("ToggleLandscape", function(enabled)
    SendReactMessage("toggleLandscape", enabled)
end)

-- Open a specific app with optional metadata
exports("OpenApp", function(appName, metadata)
    SendReactMessage("setApp", {
        name = appName,
        metadata = metadata
    })
end)

-- Close an app with optional parameters
exports("CloseApp", function(options)
    if not options then
        options = {}
    end
    
    debugprint("CloseApp: " .. (options.app or "nil") .. ", closeCompletely: " .. tostring(options.closeCompletely))
    
    SendReactMessage("closeApp", {
        app = options.app or nil,
        closeCompletely = options.closeCompletely == true
    })
end)
