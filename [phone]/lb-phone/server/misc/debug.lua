-- Debug command for server-side phone debugging
-- Allows toggling debug mode on/off via console command

RegisterCommand("svphonedebug", function()
    -- Toggle debug mode
    Config.Debug = not Config.Debug

    -- Print status twice (original behavior preserved)
    infoprint("info", "Server Debug " .. (Config.Debug and "enabled" or "disabled"))
    Wait(0)
    infoprint("info", "Server Debug " .. (Config.Debug and "enabled" or "disabled"))
end, true) -- Restricted to console/admin only
