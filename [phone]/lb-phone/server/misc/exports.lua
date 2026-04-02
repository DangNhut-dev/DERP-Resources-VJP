-- Supported social media apps
local supportedApps = {
    twitter = true,
    instagram = true,
    tiktok = true
}

-- App name mapping from client names to server names
local appNameMapping = {
    birdy = "twitter",
    instapic = "instagram",
    trendy = "tiktok"
}

-- Display names for apps
local appDisplayNames = {
    twitter = "Twitter",
    instagram = "Instagram",
    tiktok = "TikTok"
}
-- Function to toggle verified status for a user
function ToggleVerified(appName, username, verified)
    assert(type(appName) == "string", "Invalid app")
    
    -- Convert to lowercase and handle app name mapping
    appName = appName:lower()
    if not supportedApps[appName] then
        appName = tostring(appNameMapping[appName])
    end
    
    assert(supportedApps[appName], "Invalid app")
    assert(type(username) == "string", "Invalid username")
    
    -- Trigger event for other systems
    TriggerEvent("lb-phone:toggleVerified", appName, username, verified)
    
    -- Update database
    local updated = MySQL.Sync.execute(string.format("UPDATE phone_%s_accounts SET verified=@verified WHERE username=@username", appName), {
        ["@username"] = username,
        ["@verified"] = verified
    })
    
    local success = updated > 0
    
    -- Send notification to user if verified and app has display name
    if success and verified and appDisplayNames[appName] then
        local phoneNumbers = MySQL.query.await("SELECT phone_number FROM phone_logged_in_accounts WHERE app = ? AND username = ? AND `active` = 1", {
            appName, username
        })
        
        for i = 1, #phoneNumbers do
            local phoneNumber = phoneNumbers[i].phone_number
            SendNotification(phoneNumber, {
                app = appDisplayNames[appName],
                title = L("BACKEND.MISC.VERIFIED")
            })
        end
    end
    
    return success
end

-- Export ToggleVerified function
exports("ToggleVerified", ToggleVerified)
-- Function to check if a user is verified
exports("IsVerified", function(appName, username)
    assert(type(appName) == "string", "Invalid app")
    
    -- Convert to lowercase and handle app name mapping
    appName = appName:lower()
    if not supportedApps[appName] then
        appName = tostring(appNameMapping[appName])
    end
    
    assert(supportedApps[appName], "Invalid app")
    assert(type(username) == "string", "Invalid username")
    
    local verified = MySQL.Sync.fetchScalar(string.format("SELECT verified FROM phone_%s_accounts WHERE username=@username", appName), {
        ["@username"] = username
    })
    
    return verified or false
end)
-- Username field mapping for different apps
local usernameFields = {
    twitter = "username",
    instagram = "username", 
    tiktok = "username",
    mail = "address",
    darkchat = "username"
}

-- Function to change password for a user
function ChangePassword(appName, username, newPassword)
    assert(type(appName) == "string", "Invalid app")
    
    -- Convert to lowercase and handle app name mapping
    appName = appName:lower()
    if not usernameFields[appName] then
        appName = tostring(appNameMapping[appName])
    end
    
    assert(usernameFields[appName], "Invalid app")
    assert(type(username) == "string", "Invalid username")
    assert(type(newPassword) == "string", "Invalid password")
    
    -- Update password in database
    local updated = MySQL.Sync.execute(string.format("UPDATE phone_%s_accounts SET password=@password WHERE %s=@username", appName, usernameFields[appName]), {
        ["@username"] = username,
        ["@password"] = GetPasswordHash(newPassword)
    })
    
    if updated <= 0 then
        return false
    end
    
    -- Log out all sessions for this user
    MySQL.update("DELETE FROM phone_logged_in_accounts WHERE app = ? AND username = ?", {
        appName, username
    })
    
    return true
end

-- Export ChangePassword function
exports("ChangePassword", ChangePassword)
-- Export function to get equipped phone number
exports("GetEquippedPhoneNumber", function(sourceOrIdentifier)
    -- If it's a number (player source), use existing function
    if type(sourceOrIdentifier) == "number" then
        return GetEquippedPhoneNumber(sourceOrIdentifier)
    end
    
    -- Try to get source from identifier
    local source = nil
    if GetSourceFromIdentifier then
        source = GetSourceFromIdentifier(sourceOrIdentifier)
    end
    
    if source then
        return GetEquippedPhoneNumber(source)
    end
    
    -- Fallback: query database directly
    local tableName = "phone_phones"
    local columnName = "id"
    
    if Config.Item and Config.Item.Unique then
        tableName = "phone_last_phone"
    end
    
    return MySQL.scalar.await(string.format("SELECT phone_number FROM %s WHERE %s = ?", tableName, columnName), {
        sourceOrIdentifier
    })
end)
