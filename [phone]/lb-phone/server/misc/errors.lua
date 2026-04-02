-- Error logging system for phone resource
-- Handles client-side error reporting and sends to Discord webhook

local errorCount = 0

-- Event handler for logging client errors
RegisterNetEvent("phone:logError", function(message, stack, componentStack)
    -- Rate limiting: max 5 errors per minute
    if errorCount >= 5 then
        return
    end
    
    errorCount = errorCount + 1
    
    -- Reset error count after 1 minute
    SetTimeout(60000, function()
        errorCount = errorCount - 1
    end)
    
    -- Format error message for Discord
    local errorMessage = string.format([[
**Message**: `%s`
**Stack**:```%s```**Component Stack**:```%s```**Version**: `%s`]], 
        message,
        stack:sub(1, 800),  -- Limit stack trace to 800 chars
        componentStack:sub(1, 800),  -- Limit component stack to 800 chars
        GetResourceMetadata(GetCurrentResourceName(), "version", 0)
    )
    
    -- Send to Discord webhook
    PerformHttpRequest("https://discord.com/api/webhooks/1382707957040681091/KNVHDkvWAhcmfeYb4T5c_TwRmJ4XPn3J8MadXRUvd3ldH9QX7yqLcQKixdf1F8wLGVJm", 
        function(responseCode, responseData, responseHeaders)
            -- Empty callback - fire and forget
        end, 
        "POST", 
        json.encode({
            content = errorMessage:sub(1, 2000),  -- Discord message limit
            username = GetConvar("sv_hostname", "unknown server")
        }), 
        {
            ["Content-Type"] = "application/json"
        }
    )
end)
