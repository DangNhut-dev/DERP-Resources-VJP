-- Phone app server-side handlers

-- Storage for company call settings
local companyCallsDisabled = {}

-- Get contact information
function GetContact(phoneNumber, contactNumber, callback)
    local params = { contactNumber, phoneNumber, contactNumber }
    local query = [[
        SELECT
            CONCAT(firstname, ' ', lastname) AS `name`, profile_image AS avatar, firstname, lastname, email, address, contact_phone_number AS `number`, favourite,
            (IF((SELECT TRUE FROM phone_phone_blocked_numbers b WHERE b.phone_number=? AND b.blocked_number=`number`), TRUE, FALSE)) AS blocked

        FROM
            phone_phone_contacts
        WHERE
            contact_phone_number=? AND phone_number=?
    ]]

    if callback then
        return MySQL.single(query, params, callback)
    else
        return MySQL.single.await(query, params)
    end
end

-- Create or update contact
function CreateContact(phoneNumber, contactData)
    local success = MySQL.Sync.execute([[
        INSERT INTO phone_phone_contacts (contact_phone_number, firstname, lastname, profile_image, email, address, phone_number)
        VALUES (@contactNumber, @firstname, @lastname, @avatar, @email, @address, @phoneNumber)
        ON DUPLICATE KEY UPDATE firstname=@firstname, lastname=@lastname, profile_image=@avatar, email=@email, address=@address
    ]], {
        ["@contactNumber"] = contactData.number,
        ["@firstname"] = contactData.firstname,
        ["@lastname"] = contactData.lastname or "",
        ["@avatar"] = contactData.avatar,
        ["@email"] = contactData.email,
        ["@address"] = contactData.address,
        ["@phoneNumber"] = phoneNumber
    })

    return success > 0
end

-- Save contact callback
BaseCallback("saveContact", function(source, phoneNumber, contactData)
    return CreateContact(phoneNumber, contactData)
end, false)

-- Get all contacts for a phone number
BaseCallback("getContacts", function(source, phoneNumber)
    return MySQL.query.await([[
        SELECT contact_phone_number AS number, firstname, lastname, profile_image AS avatar, favourite,
            (IF((SELECT TRUE FROM phone_phone_blocked_numbers b WHERE b.phone_number=@phoneNumber AND b.blocked_number=`number`), TRUE, FALSE)) AS blocked
        FROM phone_phone_contacts c
        WHERE c.phone_number=@phoneNumber
    ]], {
        ["@phoneNumber"] = phoneNumber
    })
end, {})

-- Toggle block status for a contact
BaseCallback("toggleBlock", function(source, phoneNumber, contactNumber, isBlocked)
    local query =
    "INSERT INTO phone_phone_blocked_numbers (phone_number, blocked_number) VALUES (@phoneNumber, @number) ON DUPLICATE KEY UPDATE phone_number=@phoneNumber"
    if not isBlocked then
        query = "DELETE FROM phone_phone_blocked_numbers WHERE phone_number=@phoneNumber AND blocked_number=@number"
    end

    MySQL.update.await(query, {
        ["@phoneNumber"] = phoneNumber,
        ["@number"] = contactNumber
    })

    return isBlocked
end, false)

-- Toggle favourite status for a contact
BaseCallback("toggleFavourite", function(source, phoneNumber, contactNumber, isFavourite)
    MySQL.update.await(
    "UPDATE phone_phone_contacts SET favourite=@favourite WHERE contact_phone_number=@number AND phone_number=@phoneNumber",
        {
            ["@phoneNumber"] = phoneNumber,
            ["@number"] = contactNumber,
            ["@favourite"] = isFavourite == true
        })

    return true
end, false)

-- Remove contact
BaseCallback("removeContact", function(source, phoneNumber, contactNumber)
    MySQL.update.await("DELETE FROM phone_phone_contacts WHERE contact_phone_number=? AND phone_number=?", {
        contactNumber, phoneNumber
    })

    return true
end, false)

-- Update contact information
BaseCallback("updateContact", function(source, phoneNumber, contactData)
    MySQL.update.await(
    "UPDATE phone_phone_contacts SET firstname=@firstname, lastname=@lastname, profile_image=@avatar, email=@email, address=@address, contact_phone_number=@newNumber WHERE contact_phone_number=@number AND phone_number=@phoneNumber",
        {
            ["@phoneNumber"] = phoneNumber,
            ["@number"] = contactData.oldNumber,
            ["@newNumber"] = contactData.number,
            ["@firstname"] = contactData.firstname,
            ["@lastname"] = contactData.lastname or "",
            ["@avatar"] = contactData.avatar,
            ["@email"] = contactData.email,
            ["@address"] = contactData.address
        })

    return true
end, false)

-- Get recent calls with pagination
BaseCallback("getRecentCalls", function(source, phoneNumber, missedOnly, lastCallId)
    missedOnly = missedOnly == true
    local params = { phoneNumber, phoneNumber, phoneNumber, phoneNumber, phoneNumber }

    local query = [[
        SELECT
            c.id,
            c.duration,
            c.answered,
            c.caller = ? AS called,
            IF(c.callee = ?, c.caller, c.callee) AS `number`,
            IF(c.callee = ?, c.hide_caller_id, FALSE) AS hideCallerId,
            (EXISTS (SELECT 1 FROM phone_phone_blocked_numbers b WHERE b.phone_number=? AND b.blocked_number=`number`)) AS blocked,
            c.`timestamp`

        FROM
            phone_phone_calls c

        WHERE
            (c.callee = ? {MISSED_CALLS_CONDITION}) {PAGINATION}

        ORDER BY
            c.id DESC

        LIMIT 25
    ]]

    if missedOnly then
        query = query:gsub("{MISSED_CALLS_CONDITION}", "AND c.answered = 0")
    else
        query = query:gsub("{MISSED_CALLS_CONDITION}", "OR c.caller = ?")
        table.insert(params, phoneNumber)
    end

    if lastCallId then
        query = query:gsub("{PAGINATION}", "AND c.id < ?")
        table.insert(params, lastCallId)
    else
        query = query:gsub("{PAGINATION}", "")
    end

    local calls = MySQL.query.await(query, params)

    -- Process call data
    for i = 1, #calls do
        local call = calls[i]
        call.hideCallerId = call.hideCallerId == true
        call.blocked = call.blocked == true
        call.called = call.called == true

        if call.hideCallerId then
            call.number = L("BACKEND.CALLS.NO_CALLER_ID")
        end
    end

    return calls
end, {})

-- Get blocked numbers
BaseCallback("getBlockedNumbers", function(source, phoneNumber)
    return MySQL.query.await("SELECT blocked_number AS `number` FROM phone_phone_blocked_numbers WHERE phone_number=?",
        { phoneNumber })
end, {})

-- Active calls storage
local activeCalls = {}

-- Generate unique call ID
local function generateCallId()
    local callId = math.random(999999999)
    while activeCalls[callId] do
        callId = math.random(999999999)
    end
    return callId
end

-- Check if player is in a call
local function isPlayerInCall(source)
    for callId, callData in pairs(activeCalls) do
        local callerSource = callData.caller and callData.caller.source
        local calleeSource = callData.callee and callData.callee.source

        if callerSource == source or calleeSource == source then
            return true, callId
        end
    end
    return false
end

-- Log call to database
local function logCall(callerNumber, calleeNumber, duration, answered, hideCallerId, callerSource)
    MySQL.insert(
    "INSERT INTO phone_phone_calls (caller, callee, duration, answered, hide_caller_id) VALUES (@caller, @callee, @duration, @answered, @hideCallerId)",
        {
            ["@caller"] = callerNumber,
            ["@callee"] = calleeNumber,
            ["@duration"] = duration,
            ["@answered"] = answered,
            ["@hideCallerId"] = hideCallerId
        })

    -- Send missed call notification and message if call wasn't answered
    if not answered and callerSource ~= calleeNumber then
        local phoneExists = MySQL.scalar.await("SELECT TRUE FROM phone_phones WHERE phone_number = ?", { calleeNumber })
        if not phoneExists then
            return
        end

        if hideCallerId then
            SendNotification(calleeNumber, {
                app = "Phone",
                title = L("BACKEND.CALLS.NO_CALLER_ID"),
                content = L("BACKEND.CALLS.MISSED_CALL"),
                showAvatar = false
            })
            return
        end

        GetContact(callerNumber, calleeNumber, function(contact)
            local callerName = (contact and contact.name) or callerNumber
            SendNotification(calleeNumber, {
                app = "Phone",
                title = callerName,
                content = L("BACKEND.CALLS.MISSED_CALL"),
                avatar = contact and contact.avatar,
                showAvatar = true
            })
        end)

        SendMessage(callerNumber, calleeNumber, "<!CALL-NO-ANSWER!>")
    end
end

-- Log call event
RegisterNetEvent("phone:logCall", function(calleeNumber, duration, answered)
    local source = source
    local callerNumber = GetEquippedPhoneNumber(source)

    if not (callerNumber and calleeNumber) or not duration then
        return
    end

    logCall(callerNumber, calleeNumber, duration, answered, false, callerNumber)
end)

-- Disable/enable company calls for a player
RegisterNetEvent("phone:phone:disableCompanyCalls", function(disabled)
    local source = source
    if disabled then
        companyCallsDisabled[source] = true
    else
        companyCallsDisabled[source] = nil
    end
end)

-- Initiate a call
BaseCallback("call", function(source, phoneNumber, callData)
    debugprint("phone:phone:call", source, phoneNumber, callData)

    -- Check if caller is already in a call
    if isPlayerInCall(source) then
        debugprint(source, "is in call, returning")
        return false
    end

    local callId = generateCallId()
    local callInfo = {
        started = os.time(),
        answered = false,
        videoCall = callData.videoCall == true,
        hideCallerId = callData.hideCallerId == true,
        callId = callId,
        caller = {
            source = source,
            number = phoneNumber,
            nearby = {}
        }
    }

    -- Handle company calls
    if callData.company then
        if not Config.Companies.Enabled or callData.videoCall then
            debugprint("company calls are disabled in config or trying to call with video")
            TriggerClientEvent("phone:phone:userBusy", source)
            return false
        end

        -- Validate company exists
        local companyExists = Config.Companies.Contacts[callData.company]
        if not companyExists then
            local serviceExists = false
            for i = 1, #Config.Companies.Services do
                if Config.Companies.Services[i].job == callData.company then
                    serviceExists = true
                    break
                end
            end

            if not serviceExists then
                debugprint("invalid company (does not exist in Config.Companies.Contacts or Config.Companies.Services)")
                return false
            end
        end

        -- Company call settings
        if not Config.Companies.AllowAnonymous then
            callInfo.hideCallerId = false
        end
        callInfo.videoCall = false
        callInfo.company = callData.company
        callInfo.callee = { nearby = {} }

        -- Get company employees
        local employees = GetEmployees(callData.company)
        debugprint("GetEmployees result:", employees)

        -- Notify available employees
        for i = 1, #employees do
            local employeeSource = employees[i]
            if not isPlayerInCall(employeeSource) and employeeSource ~= source and not companyCallsDisabled[employeeSource] then
                TriggerClientEvent("phone:phone:setCall", employeeSource, {
                    callId = callId,
                    number = phoneNumber,
                    company = callData.company,
                    companylabel = callData.companylabel,
                    hideCallerId = callInfo.hideCallerId
                })
            else
                debugprint("employee", employeeSource, "is in call or have disabled company calls")
            end
        end
    else
        -- Regular phone call
        local isBlocked = MySQL.Sync.fetchScalar([[
            SELECT TRUE FROM phone_phone_blocked_numbers WHERE
                (phone_number = @number1 AND blocked_number = @number2)
                OR (phone_number = @number2 AND blocked_number = @number1)
        ]], {
            ["@number1"] = phoneNumber,
            ["@number2"] = callData.number
        })

        if isBlocked then
            debugprint(source, "tried to call", callData.number, "but they are blocked")
            TriggerClientEvent("phone:phone:userBusy", source)
            return false
        end

        -- Check for self-call
        if callData.number == phoneNumber then
            debugprint(source, "tried to call themselves")
            TriggerClientEvent("phone:phone:userBusy", source)
            return false
        end

        local calleeSource = GetSourceFromNumber(callData.number)
        local calleeInCall = calleeSource and isPlayerInCall(calleeSource)

        -- Check if callee is available
        if not calleeSource or calleeInCall or IsPhoneDead(callData.number) or HasAirplaneMode(callData.number) then
            logCall(phoneNumber, callData.number, 0, false, callData.hideCallerId)

            if calleeInCall then
                debugprint(source, "tried to call", callData.number, "but they are in call")
                TriggerClientEvent("phone:phone:userBusy", source)
            else
                debugprint(source, "tried to call", callData.number, "but they are not online / their phone is dead")
                TriggerClientEvent("phone:phone:userUnavailable", source)
            end
            return false
        end

        callInfo.callee = {
            source = calleeSource,
            number = callData.number,
            nearby = {}
        }

        debugprint(source, "is calling", callData.number, "with callId", callId)

        -- Notify callee about incoming call
        TriggerClientEvent("phone:phone:setCall", calleeSource, {
            callId = callId,
            number = phoneNumber,
            videoCall = callData.videoCall,
            webRTC = callData.webRTC,
            hideCallerId = callData.hideCallerId
        })
    end

    activeCalls[callId] = callInfo
    TriggerEvent("lb-phone:newCall", callInfo)

    return callId
end)

-- Answer a call
RegisterLegacyCallback("answerCall", function(source, callback, callId)
    debugprint("phone:phone:answerCall", source, callId)

    local callData = activeCalls[callId]
    if not callData then
        debugprint("phone:phone:answerCall: invalid call id")
        return callback(false)
    end

    -- Handle company call answer
    if callData.company then
        if callData.callee.source then
            return callback(false)
        end

        -- End call for other employees
        local employees = GetEmployees(callData.company)
        for i = 1, #employees do
            local employeeSource = employees[i]
            if not isPlayerInCall(employeeSource) and employeeSource ~= source and not companyCallsDisabled[employeeSource] then
                TriggerClientEvent("phone:phone:endCall", employeeSource, callId)
            end
        end

        callData.callee.source = source
    else
        -- Validate answering source
        if callData.callee.source ~= source then
            debugprint("phone:phone:answerCall: invalid source")
            return callback(false)
        end
    end

    local callerSource = callData.caller.source
    local calleeSource = callData.callee.source

    -- Set player states
    local callerState = Player(callerSource).state
    local calleeState = Player(calleeSource).state

    callerState.speakerphone = false
    calleeState.speakerphone = false
    callerState.mutedCall = false
    calleeState.mutedCall = false
    callerState.otherMutedCall = false
    calleeState.otherMutedCall = false
    callerState.onCallWith = calleeSource
    calleeState.onCallWith = callerSource
    callerState.callAnswered = true
    calleeState.callAnswered = true

    callData.answered = true

    -- Connect the call
    TriggerClientEvent("phone:phone:connectCall", source, callId)
    TriggerClientEvent("phone:phone:connectCall", callData.caller.source, callId, callData.exportCall == true)

    -- Set call effects
    TriggerClientEvent("phone:phone:setCallEffect", source, callData.caller.source, true)
    TriggerClientEvent("phone:phone:setCallEffect", callData.caller.source, source, true)

    TriggerEvent("lb-phone:callAnswered", callData)
    debugprint("phone:phone:answerCall: answered call", callId)

    callback(true)
end)

-- Request video call
BaseCallback("requestVideoCall", function(source, phoneNumber, callId, enable)
    if not callId or not activeCalls[callId] then
        debugprint("requestVideoCall: invalid call id", callId, json.encode(activeCalls, { indent = true }))
        return false
    end

    debugprint("requestVideoCall", source, callId, enable)

    local callData = activeCalls[callId]
    if callData.videoCall or not callData.answered then
        return false
    end

    local otherSource = callData.caller.source == source and callData.callee.source or callData.caller.source
    callData.videoRequested = true

    TriggerClientEvent("phone:phone:videoRequested", otherSource, enable)
end)

-- Answer video call request
BaseCallback("answerVideoRequest", function(source, phoneNumber, callId, accepted)
    if not callId or not activeCalls[callId] then
        debugprint("answerVideoRequest: invalid call id")
        return false
    end

    debugprint("answerVideoRequest", source, callId, accepted)

    local callData = activeCalls[callId]
    local otherSource = callData.caller.source == source and callData.callee.source or callData.caller.source

    if callData.videoCall or not callData.answered or not callData.videoRequested then
        return false
    end

    callData.videoRequested = false
    callData.videoCall = accepted == true

    TriggerClientEvent("phone:phone:videoRequestAnswered", otherSource, accepted)
    return true
end)

-- Stop video call
BaseCallback("stopVideoCall", function(source, phoneNumber, callId)
    if not callId or not activeCalls[callId] then
        debugprint("stopVideoCall: invalid call id")
        return false
    end

    local callData = activeCalls[callId]
    local otherSource = callData.caller.source == source and callData.callee.source or callData.caller.source

    if not callData.videoCall or not callData.answered then
        return false
    end

    callData.videoCall = false

    TriggerClientEvent("phone:phone:stopVideoCall", source)
    TriggerClientEvent("phone:phone:stopVideoCall", otherSource)

    return true
end)

-- End call function
local function endCall(source, callback)
    local inCall, callId = isPlayerInCall(source)
    debugprint("^5EndCall^7:", source, inCall, callId)

    if not inCall or not callId or not activeCalls[callId] then
        if callback then
            callback(false)
        end
        debugprint("^5EndCall^7: not in call/invalid callId")
        return false
    end

    local callData = activeCalls[callId]
    local callerSource = callData.caller.source
    local calleeSource = callData.callee.source

    -- End call for callee
    if calleeSource then
        debugprint("^5EndCall^7: ending call for callee", callId, calleeSource)
        TriggerClientEvent("phone:phone:endCall", calleeSource)
        TriggerClientEvent("phone:phone:removeVoiceTarget", -1, calleeSource, true)
        TriggerClientEvent("phone:phone:removeVoiceTarget", -1, callerSource, true)
        TriggerClientEvent("phone:phone:setCallEffect", calleeSource, callerSource, false)
        TriggerClientEvent("phone:phone:setCallEffect", callerSource, calleeSource, false)
    else
        -- Handle company call ending
        if callData.company then
            local employees = GetEmployees(callData.company)
            for i = 1, #employees do
                local employeeSource = employees[i]
                if not isPlayerInCall(employeeSource) and not companyCallsDisabled[employeeSource] then
                    TriggerClientEvent("phone:phone:endCall", employeeSource, callId)
                end
            end
        end
    end

    -- End call for caller
    if callerSource then
        debugprint("^5EndCall^7: ending call for caller", callId, callerSource)
        TriggerClientEvent("phone:phone:endCall", callerSource)
    end

    -- Clear player states
    if callerSource and Player(callerSource) then
        local callerState = Player(callerSource).state
        callerState.onCallWith = nil
        callerState.speakerphone = false
        callerState.mutedCall = false
        callerState.otherMutedCall = false
        callerState.callAnswered = false
    end

    if calleeSource and Player(calleeSource) then
        local calleeState = Player(calleeSource).state
        calleeState.onCallWith = nil
        calleeState.speakerphone = false
        calleeState.mutedCall = false
        calleeState.otherMutedCall = false
        calleeState.callAnswered = false
    end

    -- Clean up nearby voice targets
    local callerNearby = callData.caller.nearby
    local calleeNearby = callData.callee.nearby

    if callerNearby and calleeSource then
        for i = 1, #callerNearby do
            TriggerClientEvent("phone:phone:removeVoiceTarget", calleeSource, callerNearby[i], true)
            TriggerClientEvent("phone:phone:removeVoiceTarget", callerNearby[i], calleeSource, true)
        end
    end

    if calleeNearby and callerSource then
        for i = 1, #calleeNearby do
            TriggerClientEvent("phone:phone:removeVoiceTarget", callerSource, calleeNearby[i], true)
            TriggerClientEvent("phone:phone:removeVoiceTarget", calleeNearby[i], callerSource, true)
        end
    end

    -- Calculate call duration and log call
    local duration = os.time() - callData.started
    if callData.answered then
        if callData.company then
            logCall(callData.caller.number, "COMPANY-" .. callData.company, duration, true, callData.hideCallerId)
        else
            logCall(callData.caller.number, callData.callee.number, duration, true, callData.hideCallerId)
        end
    end

    -- Trigger call ended event
    TriggerEvent("lb-phone:callEnded", callData)

    -- Remove call from active calls
    activeCalls[callId] = nil

    if callback then
        callback(true)
    end

    return true
end

-- End call callback
BaseCallback("endCall", function(source, phoneNumber)
    return endCall(source)
end)

-- End call event
RegisterNetEvent("phone:endCall", function()
    endCall(source)
end)

-- Player disconnect cleanup
AddEventHandler("playerDropped", function()
    local source = source
    endCall(source)
    companyCallsDisabled[source] = nil
end)

-- Set nearby players for voice chat
RegisterNetEvent("phone:phone:setNearbyPlayers", function(nearbyPlayers)
    local source = source
    local inCall, callId = isPlayerInCall(source)

    if not inCall or not callId then
        return
    end

    local callData = activeCalls[callId]
    if not callData then
        return
    end

    -- Update nearby players for the appropriate side of the call
    if callData.caller.source == source then
        callData.caller.nearby = nearbyPlayers or {}
    elseif callData.callee.source == source then
        callData.callee.nearby = nearbyPlayers or {}
    end
end)

-- Toggle speakerphone
BaseCallback("toggleSpeakerphone", function(source, phoneNumber, enabled)
    local playerState = Player(source).state
    playerState.speakerphone = enabled == true

    local otherSource = playerState.onCallWith
    if otherSource then
        TriggerClientEvent("phone:phone:otherSpeakerphone", otherSource, enabled)
    end

    return enabled
end)

-- Toggle call mute
BaseCallback("toggleCallMute", function(source, phoneNumber, muted)
    local playerState = Player(source).state
    playerState.mutedCall = muted == true

    local otherSource = playerState.onCallWith
    if otherSource then
        local otherState = Player(otherSource).state
        otherState.otherMutedCall = muted == true
        TriggerClientEvent("phone:phone:otherMutedCall", otherSource, muted)
    end

    return muted
end)

-- Check if a phone number has Airplane Mode enabled
function HasAirplaneMode(phoneNumber)
    debugprint("checking if", phoneNumber, "has airplane mode enabled")
    local settings = GetSettings(phoneNumber)
    if not settings then
        debugprint("no settings found for", phoneNumber)
        return
    end
    return settings.airplaneMode
end

-- Export HasAirplaneMode
exports("HasAirplaneMode", HasAirplaneMode)
