-- Messages app server-side handlers

-- Find existing direct message channel between two phone numbers
local function FindDirectMessageChannel(senderNumber, recipientNumber)
    return MySQL.scalar.await([[
        SELECT c.id FROM phone_message_channels c
        WHERE c.is_group = 0
            AND EXISTS (SELECT TRUE FROM phone_message_members m WHERE m.channel_id = c.id AND m.phone_number = ?)
            AND EXISTS (SELECT TRUE FROM phone_message_members m WHERE m.channel_id = c.id AND m.phone_number = ?)
    ]], {senderNumber, recipientNumber})
end

-- Send message function (core messaging functionality)
function SendMessage(senderNumber, recipientNumber, content, attachments, callback, channelId)
    -- Validate required parameters
    if not (channelId or recipientNumber) or not senderNumber then
        return
    end
    
    -- Check if message or attachments are provided
    if not content then
        if attachments and #attachments ~= 0 then
            -- Attachments provided, continue
        else
            debugprint("No message or attachments provided")
            return
        end
    end
    
    -- Clean up empty content or attachments
    if content and #content == 0 then
        content = nil
    end
    
    if not content and (not attachments or #attachments == 0) then
        debugprint("No attachments provided")
        return
    end
    
    -- Find or create channel
    if not channelId then
        channelId = FindDirectMessageChannel(senderNumber, recipientNumber)
    end
    
    local senderSource = GetSourceFromNumber(senderNumber)
    
    -- Create new direct message channel if none exists
    if not channelId then
        channelId = MySQL.insert.await("INSERT INTO phone_message_channels (is_group) VALUES (0)")
        
        -- Add both members to the channel
        MySQL.update.await("INSERT INTO phone_message_members (channel_id, phone_number) VALUES (?, ?), (?, ?)", {
            channelId, senderNumber, channelId, recipientNumber
        })
        
        local recipientSource = GetSourceFromNumber(recipientNumber)
        local timestamp = os.time() * 1000
        
        -- Notify sender about new channel
        if senderSource then
            TriggerClientEvent("phone:messages:newChannel", senderSource, {
                id = channelId,
                lastMessage = content,
                timestamp = timestamp,
                number = recipientNumber,
                isGroup = false,
                unread = false
            })
        end
        
        -- Notify recipient about new channel
        if recipientSource then
            TriggerClientEvent("phone:messages:newChannel", recipientSource, {
                id = channelId,
                lastMessage = content,
                timestamp = timestamp,
                number = senderNumber,
                isGroup = false,
                unread = true
            })
        end
    end
    
    -- Log the message if sender is online
    if senderSource then
        Log("Messages", senderSource, "info", L("BACKEND.LOGS.MESSAGE_TITLE"), L("BACKEND.LOGS.NEW_MESSAGE", {
            sender = FormatNumber(senderNumber),
            recipient = FormatNumber(recipientNumber),
            message = content or "Attachment"
        }))
    end
    
    -- Encode attachments if they're a table
    if type(attachments) == "table" then
        attachments = json.encode(attachments)
    end
    
    -- Insert message into database
    local messageId = MySQL.insert.await("INSERT INTO phone_message_messages (channel_id, sender, content, attachments) VALUES (@channelId, @sender, @content, @attachments)", {
        ["@channelId"] = channelId,
        ["@sender"] = senderNumber,
        ["@content"] = content,
        ["@attachments"] = attachments
    })
    
    if not messageId then
        if callback then
            callback(false)
        end
        return
    end
    
    -- Update channel's last message
    local lastMessagePreview = string.sub(content or "Attachment", 1, 50)
    MySQL.update("UPDATE phone_message_channels SET last_message = ? WHERE id = ?", {lastMessagePreview, channelId})
    
    -- Update unread count for other members
    MySQL.update("UPDATE phone_message_members SET unread = unread + 1 WHERE channel_id = ? AND phone_number != ?", {channelId, senderNumber})
    
    -- Mark channel as not deleted for all members
    MySQL.update("UPDATE phone_message_members SET deleted = 0 WHERE channel_id = ?", {channelId})
    
    -- Get all channel members except sender
    local members = MySQL.query.await("SELECT phone_number FROM phone_message_members WHERE channel_id = ? AND phone_number != ?", {channelId, senderNumber})
    
    -- Notify all members about new message
    for i = 1, #members do
        local memberNumber = members[i].phone_number
        if memberNumber ~= senderNumber then
            local memberSource = GetSourceFromNumber(memberNumber)
            
            if memberSource then
                TriggerClientEvent("phone:messages:newMessage", memberSource, channelId, messageId, senderNumber, content, attachments)
            end
            
            -- Send notification (skip for call messages)
            if content ~= "<!CALL-NO-ANSWER!>" then
                local contact = GetContact(senderNumber, memberNumber)
                local senderName = (contact and contact.name) or senderNumber
                local thumbnail = nil
                
                if attachments then
                    local attachmentData = json.decode(attachments)
                    thumbnail = attachmentData[1]
                end
                
                SendNotification(memberNumber, {
                    app = "Messages",
                    title = senderName,
                    content = content,
                    thumbnail = thumbnail,
                    avatar = contact and contact.avatar,
                    showAvatar = true
                })
            end
        end
    end
    
    -- Execute callback if provided
    if callback then
        callback(channelId)
    end
    
    -- Trigger message sent event
    TriggerEvent("lb-phone:messages:messageSent", {
        channelId = channelId,
        messageId = messageId,
        sender = senderNumber,
        recipient = recipientNumber,
        message = content,
        attachments = attachments
    })
    
    return {
        channelId = channelId,
        messageId = messageId
    }
end

-- Export functions for external use
exports("SentMoney", function(senderNumber, recipientNumber, amount)
    assert(type(senderNumber) == "string", "Expected string for argument 1, got " .. type(senderNumber))
    assert(type(recipientNumber) == "string", "Expected string for argument 2, got " .. type(recipientNumber))
    assert(type(amount) == "number", "Expected number for argument 3, got " .. type(amount))
    
    local message = "<!SENT-PAYMENT-" .. math.floor(amount + 0.5) .. "!>"
    SendMessage(senderNumber, recipientNumber, message)
end)

exports("SendCoords", function(senderNumber, recipientNumber, coords)
    assert(type(senderNumber) == "string", "Expected string for argument 1, got " .. type(senderNumber))
    assert(type(recipientNumber) == "string", "Expected string for argument 2, got " .. type(recipientNumber))
    assert(type(coords) == "vector2", "Expected vector2 for argument 3, got " .. type(coords))
    
    local message = "<!SENT-LOCATION-X=" .. coords.x .. "Y=" .. coords.y .. "!>"
    SendMessage(senderNumber, recipientNumber, message)
end)

exports("SendMessage", function(senderNumber, recipientNumber, content, attachments, callback, channelId)
    assert(type(senderNumber) == "string", "Expected string for argument 1, got " .. type(senderNumber))
    assert(type(recipientNumber) == "string", "Expected string or nil for argument 2, got " .. type(recipientNumber))
    assert(type(content) == "string", "Expected string or nil for argument 3, got " .. type(content))
    assert(type(attachments) == "table", "Expected table, string or nil for argument 4, got " .. type(attachments))
    assert(type(callback) == "function", "Expected function or nil for argument 5, got " .. type(callback))
    
    return SendMessage(senderNumber, recipientNumber, content, attachments, callback, channelId)
end)

-- Send message callback
BaseCallback("messages:sendMessage", function(source, phoneNumber, recipientNumber, content, attachments, channelId)
    if ContainsBlacklistedWord(source, "Messages", content) then
        return false
    end
    
    return SendMessage(phoneNumber, recipientNumber, content, attachments, nil, channelId)
end)

-- Create group message
BaseCallback("messages:createGroup", function(source, phoneNumber, members, initialMessage, attachments)
    local groupId = MySQL.insert.await("INSERT INTO phone_message_channels (is_group) VALUES (1)")
    if not groupId then
        return false
    end
    
    -- Add creator as owner
    local groupMembers = {{number = phoneNumber, isOwner = true}}
    MySQL.update.await("INSERT INTO phone_message_members (channel_id, phone_number, is_owner) VALUES (?, ?, 1)", {groupId, phoneNumber})
    
    -- Add other members
    for i = 1, #members do
        local memberNumber = members[i]
        MySQL.update.await("INSERT INTO phone_message_members (channel_id, phone_number, is_owner) VALUES (?, ?, 0)", {groupId, memberNumber})
        table.insert(groupMembers, {number = memberNumber, isOwner = false})
    end
    
    -- Create channel data
    local channelData = {
        id = groupId,
        lastMessage = initialMessage,
        timestamp = os.time() * 1000,
        name = nil,
        isGroup = true,
        members = groupMembers,
        unread = false
    }
    
    -- Notify all members about new group
    for i = 1, #members do
        local memberSource = GetSourceFromNumber(members[i])
        if memberSource then
            TriggerClientEvent("phone:messages:newChannel", memberSource, channelData)
        end
    end
    
    -- Notify creator
    TriggerClientEvent("phone:messages:newChannel", source, channelData)
    
    -- Send initial message if provided
    return SendMessage(phoneNumber, nil, initialMessage, attachments, nil, groupId)
end)

-- Rename group
BaseCallback("messages:renameGroup", function(source, phoneNumber, groupId, newName)
    local affectedRows = MySQL.update.await("UPDATE phone_message_channels SET `name` = ? WHERE id = ? AND is_group = 1", {newName, groupId})
    local success = affectedRows > 0
    
    if success then
        TriggerClientEvent("phone:messages:renameGroup", -1, groupId, newName)
    end
    
    return success
end)

-- Get recent message channels
BaseCallback("messages:getRecentMessages", function(source, phoneNumber)
    return MySQL.query.await([[
        SELECT
            channel.id AS channel_id,
            channel.is_group,
            channel.`name`,
            channel.last_message,
            channel.last_message_timestamp,
            channel_member.phone_number,
            channel_member.is_owner,
            channel_member.unread,
            channel_member.deleted
        FROM
            phone_message_members target_member

        INNER JOIN phone_message_channels channel
            ON channel.id = target_member.channel_id

        INNER JOIN phone_message_members channel_member
            ON channel_member.channel_id = channel.id

        WHERE
            target_member.phone_number = ?

        ORDER BY
            channel.last_message_timestamp DESC
    ]], {phoneNumber})
end)

-- Get messages from a channel
BaseCallback("messages:getMessages", function(source, phoneNumber, channelId, page)
    return MySQL.query.await([[
        SELECT id, sender, content, attachments, `timestamp`
        FROM phone_message_messages

        WHERE channel_id = ? AND EXISTS (SELECT TRUE FROM phone_message_members m WHERE m.channel_id = ? AND m.phone_number = ?)

        ORDER BY `timestamp` DESC
        LIMIT ?, ?
    ]], {channelId, channelId, phoneNumber, page * 25, 25})
end)

-- Delete message
BaseCallback("messages:deleteMessage", function(source, phoneNumber, messageId, channelId)
    if not Config.DeleteMessages then
        return false
    end
    
    -- Check if this is the latest message
    local latestMessageId = MySQL.scalar.await("SELECT MAX(id) FROM phone_message_messages WHERE channel_id = ?", {channelId})
    local isLatestMessage = latestMessageId == messageId
    
    -- Delete the message
    local affectedRows = MySQL.update.await("DELETE FROM phone_message_messages WHERE id = ? AND sender = ? AND channel_id = ?", {
        messageId, phoneNumber, channelId
    })
    local success = affectedRows > 0
    
    -- Update channel's last message if this was the latest message
    if success and isLatestMessage then
        MySQL.update.await("UPDATE phone_message_channels SET last_message = ? WHERE id = ?", {
            L("APPS.MESSAGES.MESSAGE_DELETED"), channelId
        })
    end
    
    -- Notify all clients about message deletion
    if success then
        TriggerClientEvent("phone:messages:messageDeleted", -1, channelId, messageId, isLatestMessage)
    end
    
    return success
end)

-- Add member to group
BaseCallback("messages:addMember", function(source, phoneNumber, groupId, newMemberNumber)
    local affectedRows = MySQL.update.await("INSERT IGNORE INTO phone_message_members (channel_id, phone_number) VALUES (?, ?)", {
        groupId, newMemberNumber
    })
    local success = affectedRows > 0
    local newMemberSource = GetSourceFromNumber(newMemberNumber)
    
    if not success then
        return false
    end
    
    -- Notify all members about new member
    TriggerClientEvent("phone:messages:memberAdded", -1, groupId, newMemberNumber)
    
    if not newMemberSource then
        return true
    end
    
    -- Send group info to new member
    local members = MySQL.Sync.fetchAll("SELECT phone_number AS `number`, is_owner AS isOwner FROM phone_message_members WHERE channel_id = ?", {groupId})
    local groupInfo = MySQL.single.await("SELECT `name`, last_message, last_message_timestamp FROM phone_message_channels WHERE id = ?", {groupId})
    
    if #members > 0 and groupInfo then
        TriggerClientEvent("phone:messages:newChannel", newMemberSource, {
            id = groupId,
            lastMessage = groupInfo.last_message,
            timestamp = groupInfo.last_message_timestamp,
            name = groupInfo.name,
            isGroup = true,
            members = members,
            unread = false
        })
    end
    
    return true
end)

-- Remove member from group
BaseCallback("messages:removeMember", function(source, phoneNumber, groupId, targetMemberNumber)
    -- Check if requester is owner
    local isOwner = MySQL.scalar.await("SELECT is_owner FROM phone_message_members WHERE channel_id = ? AND phone_number = ?", {
        groupId, phoneNumber
    })
    
    if not isOwner then
        return false
    end
    
    -- Remove the member
    local affectedRows = MySQL.update.await("DELETE FROM phone_message_members WHERE channel_id = ? AND phone_number = ?", {
        groupId, targetMemberNumber
    })
    local success = affectedRows > 0
    
    if success then
        TriggerClientEvent("phone:messages:memberRemoved", -1, groupId, targetMemberNumber)
    end
    
    return success
end)

-- Leave group
BaseCallback("messages:leaveGroup", function(source, phoneNumber, groupId)
    -- Check if leaving member is owner
    local isOwner = MySQL.scalar.await("SELECT is_owner FROM phone_message_members WHERE channel_id = ? AND phone_number = ?", {
        groupId, phoneNumber
    })
    
    -- If owner is leaving, transfer ownership to another member
    if isOwner then
        MySQL.update.await([[
            UPDATE phone_message_members m
            SET is_owner = TRUE
            WHERE m.channel_id = ?
            AND m.phone_number != ?
            LIMIT 1
        ]], {groupId, phoneNumber})
        
        -- Get new owner
        local newOwner = MySQL.scalar.await("SELECT phone_number FROM phone_message_members WHERE channel_id = ? AND is_owner = TRUE", {groupId})
        TriggerClientEvent("phone:messages:ownerChanged", -1, groupId, newOwner)
    end
    
    -- Remove member from group
    local affectedRows = MySQL.update.await("DELETE FROM phone_message_members WHERE channel_id = ? AND phone_number = ?", {
        groupId, phoneNumber
    })
    local success = affectedRows > 0
    
    -- Check if group is now empty
    local remainingMembers = MySQL.scalar.await("SELECT COUNT(1) FROM phone_message_members WHERE channel_id = ?", {groupId})
    local isEmpty = remainingMembers == 0
    
    if success then
        TriggerClientEvent("phone:messages:memberRemoved", -1, groupId, phoneNumber)
    end
    
    -- Delete empty group
    if isEmpty then
        MySQL.update.await("DELETE FROM phone_message_channels WHERE id = ?", {groupId})
        debugprint("Deleted group " .. groupId .. " due to it being empty")
    end
    
    return success
end)

-- Mark messages as read
BaseCallback("messages:markRead", function(source, phoneNumber, channelId)
    MySQL.update.await("UPDATE phone_message_members SET unread = 0 WHERE channel_id = ? AND phone_number = ?", {
        channelId, phoneNumber
    })
    return true
end)

-- Delete conversations
BaseCallback("messages:deleteConversations", function(source, phoneNumber, channelIds)
    if type(channelIds) ~= "table" then
        debugprint("expected table, got " .. type(channelIds))
        return false
    end
    
    MySQL.update.await("UPDATE phone_message_members SET deleted = 1 WHERE channel_id IN (?) AND phone_number = ?", {
        channelIds, phoneNumber
    })
    return true
end)
