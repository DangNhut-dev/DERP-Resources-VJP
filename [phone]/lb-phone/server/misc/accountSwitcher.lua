-- Account Switcher for Phone Apps
-- Manages logged in accounts across different social media and communication apps

-- Cache for active accounts per app
local activeAccounts = {}

-- Supported apps for account switching
local supportedApps = {
    Twitter = true,
    Instagram = true,
    Mail = true,
    TikTok = true,
    DarkChat = true
}

-- App name mapping for client-side app names to server-side app names
local appNameMapping = {
    instapic = "Instagram",
    birdy = "Twitter",
    trendy = "TikTok",
    darkchat = "DarkChat",
    mail = "Mail"
}

-- Initialize cache for each supported app
for appName, _ in pairs(supportedApps) do
    activeAccounts[appName] = {}
end
-- Switch active account for a specific app
BaseCallback("accountSwitcher:switchAccount", function(source, phoneNumber, appName, username)
    -- Check if app is supported
    if not supportedApps[appName] then
        return false
    end
    
    -- Verify the user is actually logged into this account
    local isLoggedIn = MySQL.scalar.await("SELECT TRUE FROM phone_logged_in_accounts WHERE phone_number = ? AND app = ? AND username = ?", {
        phoneNumber, appName, username
    })
    
    if not isLoggedIn then
        print(string.format("Possible abuse? %s (%i) tried to switch to an account they aren't logged into.", GetPlayerName(source), source))
        return false
    end
    
    -- Update database to set the specified account as active
    local updated = MySQL.update.await("UPDATE phone_logged_in_accounts SET `active` = (username = ?) WHERE phone_number = ? AND app = ?", {
        username, phoneNumber, appName
    })
    
    if updated > 0 then
        -- Update cache
        activeAccounts[appName][phoneNumber] = username
        
        -- Trigger event for other systems
        TriggerEvent("phone:loggedInToAccount", appName, phoneNumber, username)
    end
    
    return updated > 0
end)
-- Get all accounts for a specific app and phone number
BaseCallback("accountSwitcher:getAccounts", function(source, phoneNumber, appName)
    -- Check if app is supported
    if not supportedApps[appName] then
        return {}
    end
    
    -- Get all logged in accounts for this phone number and app
    return MySQL.query.await("SELECT username FROM phone_logged_in_accounts WHERE phone_number = ? AND app = ?", {
        phoneNumber, appName
    })
end)
-- Add a logged in account for a phone number and app
function AddLoggedInAccount(phoneNumber, appName, username)
    assert(supportedApps[appName], "Invalid app: " .. appName)
    assert(type(phoneNumber) == "string", "Invalid phone number. Expected string.")
    assert(type(username) == "string", "Invalid username. Expected string.")
    
    -- Deactivate all other accounts for this phone number and app
    MySQL.update.await("UPDATE phone_logged_in_accounts SET `active` = 0 WHERE phone_number = ? AND app = ? AND username != ?", {
        phoneNumber, appName, username
    })
    
    -- Insert or update the account as active
    local updated = MySQL.update.await("INSERT INTO phone_logged_in_accounts (phone_number, app, username, active) VALUES (?, ?, ?, 1) ON DUPLICATE KEY UPDATE active = 1", {
        phoneNumber, appName, username
    })
    
    if updated > 0 then
        -- Update cache
        activeAccounts[appName][phoneNumber] = username
        
        -- Trigger event
        TriggerEvent("phone:loggedInToAccount", appName, phoneNumber, username)
    end
    
    return updated > 0
end

-- Remove a logged in account
function RemoveLoggedInAccount(phoneNumber, appName, username)
    assert(supportedApps[appName], "Invalid app: " .. appName)
    assert(type(phoneNumber) == "string", "Invalid phone number. Expected string.")
    assert(type(username) == "string", "Invalid username. Expected string.")
    
    -- Delete the account from database
    local deleted = MySQL.update.await("DELETE FROM phone_logged_in_accounts WHERE phone_number = ? AND app = ? AND username = ?", {
        phoneNumber, appName, username
    })
    
    if deleted > 0 then
        -- Clear from cache if it was the active account
        if activeAccounts[appName][phoneNumber] == username then
            activeAccounts[appName][phoneNumber] = nil
        end
        
        -- Trigger event
        TriggerEvent("phone:loggedOutFromAccount", appName, username, phoneNumber)
    end
    
    return deleted > 0
end

-- Get the currently logged in account for a phone number and app
function GetLoggedInAccount(phoneNumber, appName, skipCache)
    assert(supportedApps[appName], "Invalid app: " .. appName)
    assert(type(phoneNumber) == "string", "Invalid phone number. Expected string.")
    
    -- Check cache first
    if activeAccounts[appName][phoneNumber] then
        return activeAccounts[appName][phoneNumber]
    end
    
    -- Query database
    local username = MySQL.scalar.await("SELECT username FROM phone_logged_in_accounts WHERE phone_number = ? AND app = ? AND active = 1", {
        phoneNumber, appName
    })
    
    -- Update cache if found and not skipping cache
    if username and not skipCache then
        debugprint("AccountSwitcher: Setting cache for " .. phoneNumber .. ", logged in as " .. username .. " on " .. appName)
        activeAccounts[appName][phoneNumber] = username
    end
    
    return username or false
end

-- Get all phone numbers logged into a specific username for an app
function GetLoggedInNumbers(appName, username)
    assert(supportedApps[appName], "Invalid app: " .. appName)
    assert(type(username) == "string", "Invalid username. Expected string.")
    
    local results = MySQL.query.await("SELECT phone_number FROM phone_logged_in_accounts WHERE app = ? AND username = ?", {
        appName, username
    })
    
    if not results then
        return {}
    end
    
    local phoneNumbers = {}
    for i = 1, #results do
        phoneNumbers[#phoneNumbers + 1] = results[i].phone_number
    end
    
    return phoneNumbers
end

-- Get all active accounts for an app
function GetActiveAccounts(appName)
    return activeAccounts[appName] or {}
end

-- Clear active accounts cache for a specific username (except for a specific phone number)
function ClearActiveAccountsCache(appName, username, exceptPhoneNumber)
    assert(supportedApps[appName], "Invalid app: " .. appName)
    assert(type(username) == "string", "Invalid username. Expected string.")
    
    for phoneNumber, cachedUsername in pairs(activeAccounts[appName]) do
        if cachedUsername == username and phoneNumber ~= exceptPhoneNumber then
            activeAccounts[appName][phoneNumber] = nil
        end
    end
end

-- Export function to get social media username from client app name
exports("GetSocialMediaUsername", function(phoneNumber, clientAppName)
    assert(type(phoneNumber) == "string", "Invalid phone number. Expected string.")
    assert(type(clientAppName) == "string", "Invalid app. Expected string.")
    assert(appNameMapping[clientAppName], "Invalid app: " .. clientAppName)
    
    return GetLoggedInAccount(phoneNumber, appNameMapping[clientAppName], true)
end)

-- Clean up cache when player disconnects
AddEventHandler("playerDropped", function()
    local phoneNumber = GetEquippedPhoneNumber(source)
    if not phoneNumber then
        return
    end
    
    -- Clear from all app caches
    for appName, appCache in pairs(activeAccounts) do
        if appCache[phoneNumber] then
            appCache[phoneNumber] = nil
            debugprint("AccountSwitcher: Player dropped, logging out " .. phoneNumber .. " from " .. appName)
        end
    end
end)
