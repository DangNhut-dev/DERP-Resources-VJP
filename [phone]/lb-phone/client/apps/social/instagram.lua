-- Instagram/InstaPic App for LB Phone
-- Handles social media functionality including posts, stories, live streaming, and messaging

local isLive = false
local watchingUsername = nil
local watchingSources = {}

-- Actions that require interaction permission
local restrictedActions = {"sendLiveMessage", "logIn", "toggleFollow", "toggleLike", "postComment", "sendMessage"}

-- Register NUI callback for Instagram actions
RegisterNUICallback("Instagram", function(data, callback)
    if not currentPhone then
        return
    end
    
    local action = data.action
    debugprint("InstaPic:" .. (action or ""))
    
    -- Check if action requires interaction permission
    if table.contains(restrictedActions, action) then
        if not CanInteract() then
            return callback(false)
        end
    end
    
    -- Live streaming actions
    if action == "getLives" then
        TriggerCallback("instagram:getLives", callback)
        
    elseif action == "getLiveViewers" then
        TriggerCallback("instagram:getLiveViewers", callback, data.username)
        
    elseif action == "goLive" then
        local canGoLive = AwaitCallback("instagram:canGoLive")
        if not canGoLive then
            debugprint("not allowed to go live")
            callback(false)
            return
        end
        debugprint("allowed to go live; setting live stream on ui")
        callback(true)
        
    elseif action == "setLive" then
        debugprint("sending server event to start livestream")
        TriggerServerEvent("phone:instagram:startLive", data.id)
        isLive = true
        EnableWalkableCam()
        
    elseif action == "endLive" then
        EndLive()
        callback(true)
        
    elseif action == "viewLive" then
        local liveData = AwaitCallback("instagram:viewLive", data.username)
        if not liveData then
            return callback(false)
        end
        
        local volume = (settings and settings.sound and settings.sound.volume) or 0.5
        watchingUsername = data.username
        
        -- Add host to watching sources
        watchingSources[#watchingSources + 1] = liveData.host
        
        -- Add participants to watching sources
        for i = 1, #liveData.participants do
            watchingSources[#watchingSources + 1] = liveData.participants[i].source
        end
        
        debugprint("InstaPic: adding voice targets. Volume:", volume)
        MumbleClearVoiceTargetPlayers(1)
        
        for i = 1, #watchingSources do
            local source = watchingSources[i]
            MumbleAddVoiceTargetPlayerByServerId(1, source)
            MumbleSetVolumeOverrideByServerId(source, volume)
            debugprint("started listening to", source)
        end
        
        callback(#liveData.viewers)
        
    elseif action == "stopViewing" then
        AwaitCallback("instagram:stopViewing", data.username)
        MumbleClearVoiceTargetPlayers(1)
        
        for i = 1, #watchingSources do
            MumbleSetVolumeOverrideByServerId(watchingSources[i], -1.0)
            debugprint("stopped listening to", watchingSources[i])
        end
        
        watchingUsername = nil
        watchingSources = {}
        
    elseif action == "sendLiveMessage" then
        TriggerServerEvent("phone:instagram:sendLiveMessage", data.data)
        
    elseif action == "addCall" then
        TriggerServerEvent("phone:instagram:addCall", data.id)
        
    elseif action == "inviteLive" then
        TriggerServerEvent("phone:instagram:inviteLive", data.username)
        
    elseif action == "removeLive" then
        TriggerServerEvent("phone:instagram:removeLive", data.username)
        
    elseif action == "joinLive" then
        local joinResult = AwaitCallback("instagram:joinLive", data.username, data.streamId)
        callback(joinResult)
        if not joinResult then
            return
        end
        isLive = true
        EnableWalkableCam()
    end
    
    -- Story actions
    if action == "addToStory" then
        local canCreateStory = AwaitCallback("instagram:canCreateStory")
        if not canCreateStory then
            debugprint("not allowed to go create story")
            callback(false)
            return
        end
        debugprint("allowed to create story")
        TriggerCallback("instagram:addToStory", callback, data.media, data.metadata)
        
    elseif action == "removeFromStory" then
        TriggerCallback("instagram:removeFromStory", callback, data.id)
        
    elseif action == "getStories" then
        TriggerCallback("instagram:getStories", callback)
        
    elseif action == "getStory" then
        TriggerCallback("instagram:getStory", callback, data.username)
        
    elseif action == "getViewers" then
        TriggerCallback("instagram:getViewers", callback, data.id, data.page)
        
    elseif action == "viewedStory" then
        TriggerCallback("instagram:viewedStory", callback, data.id)
    end
    
    -- Camera actions
    if action == "flipCamera" then
        ToggleSelfieCam(not IsSelfieCam())
        
    -- Account management
    elseif action == "createAccount" then
        TriggerCallback("instagram:createAccount", callback, data.name, data.username, data.password)
        
    elseif action == "changePassword" then
        TriggerCallback("instagram:changePassword", callback, data.oldPassword, data.newPassword)
        
    elseif action == "deleteAccount" then
        TriggerCallback("instagram:deleteAccount", callback, data.password)
        
    elseif action == "logIn" then
        TriggerCallback("instagram:logIn", callback, data.username, data.password)
        
    elseif action == "signOut" then
        TriggerCallback("instagram:signOut", callback)
        
    elseif action == "isLoggedIn" then
        TriggerCallback("instagram:isLoggedIn", callback)
        
    -- Profile and posts
    elseif action == "getProfile" then
        TriggerCallback("instagram:getProfile", callback, data.username)
        
    elseif action == "newPost" then
        TriggerCallback("instagram:createPost", callback, json.encode(data.data.images), data.data.caption, data.data.location)
        
    elseif action == "deletePost" then
        TriggerCallback("instagram:deletePost", callback, data.id)
        
    elseif action == "getPosts" then
        TriggerCallback("instagram:getPosts", callback, data.filters, data.page)
        
    elseif action == "getPost" then
        TriggerCallback("instagram:getPost", callback, data.id)
        
    elseif action == "updateProfile" then
        TriggerCallback("instagram:updateProfile", callback, data.data)
        
    -- Social interactions
    elseif action == "getFollowers" then
        TriggerCallback("instagram:getData", callback, "followers", data.data)
        
    elseif action == "getFollowing" then
        TriggerCallback("instagram:getData", callback, "following", data.data)
        
    elseif action == "getLikes" then
        TriggerCallback("instagram:getData", callback, "likes", data.data)
        
    elseif action == "toggleFollow" then
        TriggerCallback("instagram:toggleFollow", callback, data.data.username, data.data.following)
        
    elseif action == "toggleLike" then
        TriggerCallback("instagram:toggleLike", callback, data.data.postId, data.data.toggle, data.data.isComment)
        
    -- Comments
    elseif action == "getComments" then
        local comments = AwaitCallback("instagram:getComments", data.postId, data.page or 0)
        local formattedComments = {}
        
        
        for i = 1, #comments do
            local comment = comments[i]
            local formatted = {}
            
            -- User data
            local user = {}
            user.username = comment.username
            user.avatar = comment.profile_image
            user.verified = comment.verified
            formatted.user = user
            
            -- Comment data
            local commentData = {}
            commentData.content = comment.comment
            commentData.timestamp = comment.timestamp
            commentData.likes = comment.like_count
            commentData.liked = comment.liked
            commentData.id = comment.id
            formatted.comment = commentData
            
            formattedComments[i] = formatted
        end
        

        callback(formattedComments)
        
    elseif action == "postComment" then
        TriggerCallback("instagram:postComment", callback, data.data.postId, data.data.comment)
        
    -- Notifications and follow requests
    elseif action == "getNotifications" then
        TriggerCallback("instagram:getNotifications", callback, data.page or 0)
        
    elseif action == "getFollowRequests" then
        TriggerCallback("instagram:getFollowRequests", callback, data.page or 0)
        
    elseif action == "handleFollowRequest" then
        TriggerCallback("instagram:handleFollowRequest", callback, data.username, data.accept)
    end
    
    -- Messaging
    if action == "getRecentMessages" then
        local messages = AwaitCallback("instagram:getRecentMessages", data.page)
        
        -- Decode attachments for each message
        for i = 1, #messages do
            local message = messages[i]
            if message.attachments then
                message.attachments = json.decode(message.attachments)
            end
        end
        
        callback(messages)
        
    elseif action == "getMessages" then
        local messages = AwaitCallback("instagram:getMessages", data.username, data.page)
        
        -- Decode attachments for each message
        for i = 1, #messages do
            local message = messages[i]
            if message.attachments then
                message.attachments = json.decode(message.attachments)
            end
        end
        
        callback(messages)
        
    elseif action == "sendMessage" then
        TriggerCallback("instagram:sendMessage", callback, data.username, data.message)
        
    elseif action == "search" then
        TriggerCallback("instagram:search", callback, data.query)
    end
end)

-- Handle live message notifications
RegisterNetEvent("phone:instagram:addLiveMessage", function(messageData)
    SendReactMessage("instagram:addMessage", messageData)
end)

-- Handle live stream updates
RegisterNetEvent("phone:instagram:updateLives", function(liveData)
    SendReactMessage("instagram:updateLives", liveData)
end)

-- Handle live stream ending
RegisterNetEvent("phone:instagram:endLive", function(username)
    if username == watchingUsername then
        MumbleClearVoiceTargetPlayers(1)
        
        for i = 1, #watchingSources do
            MumbleSetVolumeOverrideByServerId(watchingSources[i], -1.0)
            debugprint("InstaPic endLive: stopped listening to", watchingSources[i])
        end
        
        watchingUsername = nil
        watchingSources = {}
    end
    
    SendReactMessage("instagram:liveEnded", username)
end)

-- Handle user joining live stream
RegisterNetEvent("phone:instagram:joinedLive", function(joinData)
    SendReactMessage("instagram:joinedLive", joinData)
    
    local playerSource = GetPlayerServerId(PlayerId())
    if joinData.source == playerSource then
        return
    end
    
    watchingSources[#watchingSources + 1] = joinData.source
    
    local volume = (settings and settings.sound and settings.sound.volume) or 0.5
    MumbleAddVoiceTargetPlayerByServerId(1, joinData.source)
    MumbleSetVolumeOverrideByServerId(joinData.source, volume)
    debugprint("InstaPic joinedLive: started listening to", joinData.source, "volume:", volume)
end)

-- Handle settings updates for voice volume
AddEventHandler("lb-phone:settingsUpdated", function()
    if not watchingUsername or #watchingSources == 0 then
        return
    end
    
    local volume = (settings and settings.sound and settings.sound.volume) or 0.5
    
    for i = 1, #watchingSources do
        local source = watchingSources[i]
        local playerSource = GetPlayerServerId(PlayerId())
        
        if source ~= playerSource then
            MumbleSetVolumeOverrideByServerId(source, volume)
            debugprint("InstaPic settingsUpdated: set volume to", volume, "for", source)
        end
    end
end)

-- Handle user leaving live stream
RegisterNetEvent("phone:instagram:leftLive", function(host, participant, participantSource)
    SendReactMessage("instagram:leftLive", {
        host = host,
        participant = participant
    })
    
    local playerSource = GetPlayerServerId(PlayerId())
    if participantSource == playerSource then
        return
    end
    
    for i = 1, #watchingSources do
        if watchingSources[i] == participantSource then
            MumbleSetVolumeOverrideByServerId(participantSource, -1.0)
            MumbleRemoveVoiceTargetPlayerByServerId(1, participantSource)
            debugprint("InstaPic leftLive: stopped listening to", participantSource)
            table.remove(watchingSources, i)
            break
        end
    end
end)

-- Handle call ending
RegisterNetEvent("phone:instagram:endCall", function(callData)
    SendReactMessage("instagram:endCall", callData)
end)

-- Handle viewer count updates
RegisterNetEvent("phone:instagram:updateViewers", function(username, viewers)
    SendReactMessage("instagram:updateViewers", {
        username = username,
        viewers = viewers
    })
end)

-- Handle profile data updates
RegisterNetEvent("phone:instagram:updateProfileData", function(username, data, increment)
    debugprint("updateProfileData", username, data, increment)
    SendReactMessage("instagram:updateProfileData", {
        username = username,
        data = data,
        increment = increment
    })
end)

-- Handle post data updates
RegisterNetEvent("phone:instagram:updatePostData", function(postId, data, increment)
    debugprint("updatePostData", postId, data, increment)
    SendReactMessage("instagram:updatePostData", {
        postId = postId,
        data = data,
        increment = increment
    })
end)

-- Handle comment likes updates
RegisterNetEvent("phone:instagram:updateCommentLikes", function(commentId, increment)
    debugprint("updateCommentLikes", commentId, increment)
    SendReactMessage("instagram:updateCommentLikes", {
        commentId = commentId,
        increment = increment
    })
end)

-- Handle new message notifications
RegisterNetEvent("phone:instagram:newMessage", function(messageData)
    SendReactMessage("instagram:newMessage", messageData)
end)

-- Handle live stream invitations
RegisterNetEvent("phone:instagram:invitedLive", function(inviteData)
    SendReactMessage("instagram:invitedLive", inviteData)
end)

-- Handle being removed from live stream
RegisterNetEvent("phone:instagram:removedLive", function()
    EndLive()
end)

-- Handle new post notifications
RegisterNetEvent("phone:instagram:newPost", function(postData)
    TriggerEvent("lb-phone:instapic:newPost", postData)
end)

-- Function to end live streaming
function EndLive()
    if not isLive then
        return
    end
    
    isLive = false
    DisableWalkableCam()
    AwaitCallback("instagram:endLive")
end

-- Function to check if currently live streaming
function IsLive()
    return isLive
end

-- Function to check if watching a live stream
function IsWatchingLive()
    return watchingUsername
end

-- Export functions
exports("IsLive", IsLive)
