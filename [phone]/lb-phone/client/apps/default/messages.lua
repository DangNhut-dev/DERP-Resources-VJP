-- Messages app for LB Phone
-- Handles SMS messaging, group chats, and message management

-- Actions that require interaction permission
local restrictedActions = {
    "sendMessage",
    "createGroup", 
    "renameGroup"
}

-- Register NUI callback for Messages actions
RegisterNUICallback("Messages", function(data, callback)
    if not currentPhone then
        return
    end
    
    local action = data.action
    debugprint("Messages:" .. (action or ""))
    
    -- Check interaction permission for restricted actions
    if table.contains(restrictedActions, action) then
        if not CanInteract() then
            return callback(false)
        end
    end
    
    -- Process attachments
    if data.attachments and #data.attachments == 0 then
        data.attachments = nil
    elseif data.attachments then
        data.attachments = json.encode(data.attachments)
    end
    
    if action == "sendMessage" then
        -- Send message to server and trigger local event
        TriggerServerEvent("phone:messages:messageSent", data.number, data.content, data.attachments)
        TriggerCallback("messages:sendMessage", callback, data.number, data.content, data.attachments, data.id)
        
    elseif action == "createGroup" then
        -- Extract member numbers from member objects
        local memberNumbers = {}
        for i = 1, #data.members do
            memberNumbers[i] = data.members[i].number
        end
        
        TriggerCallback("messages:createGroup", callback, memberNumbers, data.content, data.attachments)
        
    elseif action == "renameGroup" then
        -- Rename group chat
        TriggerCallback("messages:renameGroup", callback, data.id, data.name)
        
    elseif action == "getRecentMessages" then
        -- Get recent message conversations
        local recentMessages = AwaitCallback("messages:getRecentMessages")
        local conversations = {}
        
        -- Helper function to find conversation by ID
        local function findConversationIndex(channelId)
            for i = 1, #conversations do
                if conversations[i].id == channelId then
                    return i
                end
            end
            return false
        end
        
        -- Process messages to build conversation list
        for i = 1, #recentMessages do
            local message = recentMessages[i]
            local conversationIndex = findConversationIndex(message.channel_id)
            
            if not conversationIndex then
                if message.is_group then
                    -- Add group conversation
                    conversations[#conversations + 1] = {
                        id = message.channel_id,
                        lastMessage = message.last_message,
                        timestamp = message.last_message_timestamp,
                        name = message.name,
                        isGroup = true,
                        members = {{
                            isOwner = message.is_owner,
                            number = message.phone_number
                        }}
                    }
                else
                    -- Add individual conversation (exclude self)
                    if message.phone_number ~= currentPhone then
                        conversations[#conversations + 1] = {
                            id = message.channel_id,
                            lastMessage = message.last_message,
                            timestamp = message.last_message_timestamp,
                            number = message.phone_number,
                            isGroup = false
                        }
                    end
                end
            else
                -- Add member to existing group conversation
                if message.is_group then
                    local members = conversations[conversationIndex].members
                    members[#members + 1] = {
                        isOwner = message.is_owner,
                        number = message.phone_number
                    }
                end
            end
        end
        
        -- Set conversation metadata for current user
        for i = 1, #recentMessages do
            local message = recentMessages[i]
            local conversationIndex = findConversationIndex(message.channel_id)
            
            if conversationIndex and message.phone_number == currentPhone then
                conversations[conversationIndex].deleted = message.deleted
                conversations[conversationIndex].unread = message.unread > 0
            end
        end
        
        callback(conversations)
        
    elseif action == "getMessages" then
        -- Get messages for specific conversation
        TriggerCallback("messages:getMessages", function(messages)
            -- Decode attachments for each message
            for i = 1, #messages do
                local attachments = messages[i].attachments or "[]"
                messages[i].attachments = json.decode(attachments)
            end
            callback(messages)
        end, data.id, data.page)
        
    elseif action == "deleteMessage" then
        -- Delete message if enabled in config
        if Config.DeleteMessages then
            TriggerCallback("messages:deleteMessage", callback, data.id, data.channel)
        end
        
    elseif action == "addMember" then
        -- Add member to group
        TriggerCallback("messages:addMember", callback, data.id, data.number)
        
    elseif action == "removeMember" then
        -- Remove member from group
        TriggerCallback("messages:removeMember", callback, data.id, data.number)
        
    elseif action == "leaveGroup" then
        -- Leave group chat
        TriggerCallback("messages:leaveGroup", callback, data.id)
        
    elseif action == "markRead" then
        -- Mark conversation as read
        TriggerCallback("messages:markRead", callback, data.id)
        
    elseif action == "deleteConversations" then
        -- Delete multiple conversations
        TriggerCallback("messages:deleteConversations", callback, data.channels)
    end
end)

-- Handle new message from server
RegisterNetEvent("phone:messages:newMessage", function(channelId, messageId, sender, content, attachments)
    SendReactMessage("messages:newMessage", {
        channelId = channelId,
        messageId = messageId,
        sender = sender,
        content = content,
        attachments = attachments and json.decode(attachments) or {}
    })
end)

-- Handle message deletion from server
RegisterNetEvent("phone:messages:messageDeleted", function(channelId, messageId, isLastMessage)
    SendReactMessage("messages:messageDeleted", {
        channelId = channelId,
        messageId = messageId,
        isLastMessage = isLastMessage
    })
end)

-- Handle group rename from server
RegisterNetEvent("phone:messages:renameGroup", function(channelId, name)
    SendReactMessage("messages:renameGroup", {
        channelId = channelId,
        name = name
    })
end)

-- Handle member added to group from server
RegisterNetEvent("phone:messages:memberAdded", function(channelId, number)
    SendReactMessage("messages:addMember", {
        channelId = channelId,
        number = number
    })
end)

-- Handle member removed from group from server
RegisterNetEvent("phone:messages:memberRemoved", function(channelId, number)
    SendReactMessage("messages:removeMember", {
        channelId = channelId,
        number = number
    })
end)

-- Handle group owner change from server
RegisterNetEvent("phone:messages:ownerChanged", function(channelId, number)
    SendReactMessage("messages:changeOwner", {
        channelId = channelId,
        number = number
    })
end)

-- Handle new channel creation from server
RegisterNetEvent("phone:messages:newChannel", function(channelData)
    SendReactMessage("messages:newChannel", channelData)
end)
