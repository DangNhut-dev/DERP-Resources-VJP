-- Security functionality for LB Phone
-- Handles PIN authentication, Face ID, and security-related operations

local cachedPin = nil
local cachedFaceId = nil
local userIdentifier = nil

-- Reset all security data
function ResetSecurity(skipUIUpdate)
    debugprint("ResetSecurity triggered")
    cachedPin = nil
    cachedFaceId = nil
    userIdentifier = nil
    
    if not skipUIUpdate then
        SendReactMessage("resetSecurity")
    end
end

-- Get user identifier for security operations
function GetIdentifier()
    if not userIdentifier then
        userIdentifier = AwaitCallback("security:getIdentifier")
        debugprint("getIdentifier:", userIdentifier)
    end
    
    return userIdentifier or "unknown"
end

-- Validate PIN format
local function isValidPin(pin)
    if pin and type(pin) == "string" then
        if #pin ~= 4 then
            debugprint("invalid data.pin: invalid length", pin)
            return false
        else
            local pinNumber = tonumber(pin)
            if not pinNumber then
                debugprint("invalid data.pin: failed to convert to number", pin)
                return false
            end
        end
        return true
    end
    return false
end

-- Handle Security NUI callbacks
RegisterNUICallback("Security", function(data, callback)
    local action = data.action
    debugprint("Security:" .. (action or ""), data)
    
    if action == "setPin" then
        -- Prevent setting the same PIN
        if data.pin == cachedPin then
            debugprint("Failed to set pin: new pin is the same as the old pin")
            return callback(false)
        end
        
        -- Validate PIN format
        if not isValidPin(data.pin) then
            debugprint("Failed to set pin: invalid pin")
            return callback(false)
        end
        
        -- Set PIN on server
        local success = AwaitCallback("security:setPin", data.pin, cachedPin)
        if success then
            debugprint("Successfully set pin to", data.pin)
            cachedPin = data.pin
        else
            debugprint("Failed to set pin")
        end
        
        callback(success)
        
    elseif action == "removePin" then
        -- Remove PIN from server
        local success = AwaitCallback("security:removePin", cachedPin)
        if success then
            ResetSecurity()
        end
        callback(success)
        
    elseif action == "verifyPin" then
        -- Use cached PIN if available
        if cachedPin then
            debugprint("Has cached pin", cachedPin, data.pin)
            return callback(cachedPin == data.pin)
        end
        
        -- Validate PIN format
        if not isValidPin(data.pin) then
            debugprint("Failed to verify pin: invalid pin")
            return callback(false)
        end
        
        -- Verify PIN with server
        local success = AwaitCallback("security:verifyPin", data.pin)
        debugprint("security:verifyPin returned:", success)
        
        if success then
            debugprint("Correct pin, caching it", data.pin)
            cachedPin = data.pin
        end
        
        callback(success)
        
    elseif action == "setFaceId" then
        -- Verify PIN before enabling Face ID
        if not cachedPin or cachedPin ~= data.pin then
            debugprint("Failed to enable Face Unlock: incorrect pin")
            debugprint(cachedPin, data.pin)
            return callback(false)
        end
        
        debugprint("Correct pin, triggering enableFaceUnlock")
        TriggerCallback("security:enableFaceUnlock", callback, data.pin)
        
    elseif action == "removeFaceId" then
        -- Verify PIN before disabling Face ID
        if not cachedPin or cachedPin ~= data.pin then
            debugprint("Failed to disable Face Unlock: incorrect pin")
            return callback(false)
        end
        
        debugprint("Correct pin, triggering disableFaceUnlock")
        TriggerCallback("security:disableFaceUnlock", callback, data.pin)
        
    elseif action == "verifyFace" then
        -- Check if face is obstructed
        if IsFaceObstructed() then
            debugprint("Face is obstructed")
            return callback(false)
        end
        
        -- Ensure we have user identifier
        if not userIdentifier then
            GetIdentifier()
        end
        
        -- Use cached Face ID if available
        if cachedFaceId then
            debugprint("Has cached face, returning:", cachedFaceId == userIdentifier)
            return callback(cachedFaceId == userIdentifier)
        end
        
        -- Verify Face ID with server
        local success = AwaitCallback("security:verifyFace")
        debugprint("security:verifyFace returned:", success)
        
        if success then
            cachedFaceId = userIdentifier
        end
        
        callback(success)
        
    elseif action == "factoryReset" then
        -- Trigger factory reset
        TriggerServerEvent("phone:factoryReset")
    end
end)

-- Handle factory reset from server
RegisterNetEvent("phone:factoryReset", function()
    OnDeath()
    ResetSecurity()
    FetchPhone()
end)

-- Handle security reset for specific phone number
RegisterNetEvent("phone:security:reset", function(phoneNumber)
    if phoneNumber == currentPhone then
        ResetSecurity()
        Wait(500)
        FetchPhone()
    end
end)
