-- Account Switcher for LB Phone
-- Handles switching between different accounts for social media apps

-- Apps that support account switching
local supportedApps = {
    Twitter = true,
    Instagram = true,
    TikTok = true,
    Mail = true,
    DarkChat = true
}

-- Handle account switcher NUI callbacks
RegisterNUICallback("AccountSwitcher", function(data, callback)
    debugprint("AccountSwitcher:" .. (data.action or ""))
    
    -- Validate current phone and app
    if not currentPhone or not supportedApps[data.app] then
        debugprint("AccountSwitcher: Invalid app / no currentPhone", data.app)
        callback(false)
        return
    end
    
    if data.action == "switch" then
        -- Switch to a different account
        TriggerCallback("accountSwitcher:switchAccount", callback, data.app, data.account)
    elseif data.action == "getAccounts" then
        -- Get list of available accounts for the app
        TriggerCallback("accountSwitcher:getAccounts", function(accounts)
            if not accounts then
                callback(false)
                return
            end
            
            -- Extract usernames from account data
            local usernames = {}
            for i = 1, #accounts do
                usernames[i] = accounts[i].username
            end
            
            callback(usernames)
        end, data.app)
    end
end)
