-- Phone security system
-- Handles PIN codes, Face ID, and security-related callbacks

-- Legacy callback to get player identifier
RegisterLegacyCallback("security:getIdentifier", function(source, callback)
    callback(GetIdentifier(source))
end)

-- Callback to set PIN code for a phone
BaseCallback("security:setPin", function(source, phoneNumber, newPin, currentPin)
    -- Validate PIN format (must be 4-digit string)
    if type(newPin) ~= "string" or #newPin ~= 4 then
        debugprint("Failed to set pin: invalid type or length")
        return false
    end
    
    -- Update PIN in database (only if current PIN matches or is NULL)
    local updated = MySQL.update.await("UPDATE phone_phones SET pin = ? WHERE phone_number = ? AND (pin = ? OR pin IS NULL)", {
        newPin,
        phoneNumber,
        currentPin or ""
    })
    
    local success = updated > 0
    debugprint("phone:security:setPin", GetPlayerName(source), success, phoneNumber, newPin, currentPin)
    
    return success
end, false)

-- Callback to remove PIN code from a phone
BaseCallback("security:removePin", function(source, phoneNumber, currentPin)
    -- Validate PIN format
    if type(currentPin) ~= "string" or #currentPin ~= 4 then
        debugprint("Failed to remove pin: invalid type or length")
        return false
    end
    
    -- Remove PIN and Face ID from database
    local updated = MySQL.update.await("UPDATE phone_phones SET pin = NULL, face_id = NULL WHERE phone_number = ? AND (pin = ? OR pin IS NULL)", {
        phoneNumber,
        currentPin
    })
    
    return updated > 0
end, false)

-- Callback to verify PIN code
BaseCallback("security:verifyPin", function(source, phoneNumber, inputPin)
    -- Validate PIN format
    if type(inputPin) ~= "string" or #inputPin ~= 4 then
        debugprint("Failed to verify pin: invalid type or length")
        return false
    end
    
    -- Get stored PIN from database
    local storedPin = MySQL.scalar.await("SELECT pin FROM phone_phones WHERE phone_number = ?", {
        phoneNumber
    })
    
    -- PIN is valid if it's NULL (no PIN set) or matches input
    local isValid = storedPin == nil or storedPin == inputPin
    debugprint("phone:security:verifyPin", GetPlayerName(source), isValid, storedPin, inputPin)
    
    return isValid
end, false)

-- Callback to enable Face ID unlock
BaseCallback("security:enableFaceUnlock", function(source, phoneNumber, pin)
    -- Validate PIN format
    if type(pin) ~= "string" or #pin ~= 4 then
        debugprint("Failed to enable face unlock: invalid type or length")
        return false
    end
    
    local identifier = GetIdentifier(source)
    
    -- Set Face ID to player identifier (only if PIN matches)
    local updated = MySQL.update.await("UPDATE phone_phones SET face_id = ? WHERE phone_number = ? AND pin = ?", {
        identifier,
        phoneNumber,
        pin
    })
    
    return updated > 0
end, false)

-- Callback to disable Face ID unlock
BaseCallback("security:disableFaceUnlock", function(source, phoneNumber, pin)
    -- Validate PIN format
    if type(pin) ~= "string" or #pin ~= 4 then
        debugprint("Failed to disable face unlock: invalid type or length")
        return false
    end
    
    -- Remove Face ID from database
    return MySQL.update.await("UPDATE phone_phones SET face_id = NULL WHERE phone_number = ? AND (pin = ? OR pin IS NULL)", {
        phoneNumber,
        pin
    })
end, false)

-- Callback to verify Face ID
BaseCallback("security:verifyFace", function(source, phoneNumber)
    local identifier = GetIdentifier(source)
    
    -- Get stored Face ID from database
    local storedFaceId = MySQL.scalar.await("SELECT face_id FROM phone_phones WHERE phone_number = ?", {
        phoneNumber
    })
    
    debugprint("phone:security:verifyFace", GetPlayerName(source), storedFaceId, identifier)
    
    -- Face ID is valid if it matches player identifier
    return storedFaceId == identifier
end, false)

-- Function to reset all security settings for a phone
function ResetSecurity(phoneNumber)
    assert(type(phoneNumber) == "string", "Invalid argument #1 to ResetSecurity, expected string, got " .. type(phoneNumber))
    
    -- Clear PIN and Face ID
    MySQL.update.await("UPDATE phone_phones SET pin = NULL, face_id = NULL WHERE phone_number = ?", {
        phoneNumber
    })
    
    -- Notify client if player is online
    local source = GetSourceFromNumber(phoneNumber)
    if source then
        TriggerClientEvent("phone:security:reset", source, phoneNumber)
    end
end

-- Export function to get PIN for a phone number
exports("GetPin", function(phoneNumber)
    assert(type(phoneNumber) == "string", "Invalid argument #1 to GetPin, expected string, got " .. type(phoneNumber))
    
    return MySQL.scalar.await("SELECT pin FROM phone_phones WHERE phone_number = ?", {
        phoneNumber
    })
end)

-- Export ResetSecurity function
exports("ResetSecurity", ResetSecurity)
