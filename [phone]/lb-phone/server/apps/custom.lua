-- Custom app handler for server-side functionality
-- Handles custom app interactions defined in Config.CustomApps

RegisterNetEvent("lb-phone:customApp", function(appName)
    local source = source
    local customApp = Config.CustomApps[appName]
    
    -- Check if custom app exists and has server-side handler
    if customApp and customApp.onServerUse then
        customApp.onServerUse(source)
    end
end)
