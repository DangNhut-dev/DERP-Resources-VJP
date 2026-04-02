-- Phone Backup functionality for LB Phone
-- Handles creating, applying, and managing phone backups

-- Apply a backup to restore phone data
local function applyBackup(phoneNumber, callback)
    -- Prevent applying backup to currently equipped phone
    if phoneNumber == currentPhone then
        debugprint("can't apply backup since it's the currently equipped number")
        return callback(false)
    end
    
    -- Request backup application from server
    local success = AwaitCallback("backup:applyBackup", phoneNumber)
    debugprint("phone:backup:applyBackup", phoneNumber, ":", success)
    
    callback(success)
    
    if not success then
        return
    end
    
    -- Wait for backup to be applied, then refresh phone
    Wait(5000)
    OnDeath() -- Reset phone state
    Wait(500)
    FetchPhone() -- Fetch updated phone data
    Wait(500)
    ToggleOpen(true) -- Open phone to show restored data
end

-- Handle Backup NUI callbacks
RegisterNUICallback("Backup", function(data, callback)
    local action = data.action
    debugprint("Backup:" .. (action or ""))
    
    if action == "create" then
        -- Create a new backup
        TriggerCallback("backup:createBackup", callback)
    elseif action == "delete" then
        -- Delete an existing backup
        TriggerCallback("backup:deleteBackup", callback, data.number)
    elseif action == "apply" then
        -- Apply/restore a backup
        applyBackup(data.number, callback)
    elseif action == "get" then
        -- Get list of available backups
        TriggerCallback("backup:getBackups", callback)
    end
end)
