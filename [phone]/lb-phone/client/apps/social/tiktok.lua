-- TikTok/Trendy App for LB Phone
-- Handles video sharing, comments, messaging, and social interactions

-- Helper function to format video data from server response
local function formatVideoData(videoData)
    -- Decode metadata if it exists
    if videoData.metadata then
        videoData.metadata = json.decode(videoData.metadata)
    end

    -- Process music data
    if videoData.music then
        videoData.music = json.decode(videoData.music)

        -- Get music info from Music system if available
        if Music and Music.Songs and videoData.music and videoData.music.path then
            local song = Music.Songs[videoData.music.path]
            if song then
                local album = Music.Albums[song.album]
                if album and album.Cover then
                    song.Cover = album.Cover
                end

                local musicInfo = {}
                musicInfo.title = song.Title
                musicInfo.artist = song.Artist
                musicInfo.cover = song.Cover
                musicInfo.volume = videoData.music.volume
                musicInfo.path = videoData.music.path
                videoData.music = musicInfo
            end
        end
    end

    -- Convert numeric flags to boolean
    videoData.liked = (videoData.liked == 1)
    videoData.saved = (videoData.saved == 1)
    videoData.viewed = (videoData.viewed == 1)

    return videoData
end

-- Register NUI callback for TikTok actions
RegisterNUICallback("TikTok", function(data, callback)
    if not currentPhone then
        return
    end

    local action = data.action
    debugprint("tiktok:" .. (action or ""))

    -- Account management
    if action == "login" then
        local loginData = data.data
        TriggerCallback("tiktok:login", callback, loginData.username, loginData.password)
    elseif action == "signup" then
        local signupData = data.data
        TriggerCallback("tiktok:signup", callback, signupData.username, signupData.password, signupData.name)
    elseif action == "changePassword" then
        TriggerCallback("tiktok:changePassword", callback, data.oldPassword, data.newPassword)
    elseif action == "deleteAccount" then
        TriggerCallback("tiktok:deleteAccount", callback, data.password)
    elseif action == "logout" then
        TriggerCallback("tiktok:logout", callback)
    elseif action == "isLoggedIn" then
        TriggerCallback("tiktok:isLoggedIn", callback)

        -- Profile management
    elseif action == "getProfile" then
        TriggerCallback("tiktok:getProfile", callback, data.username)
    elseif action == "updateProfile" then
        TriggerCallback("tiktok:updateProfile", callback, data.data)
    elseif action == "searchAccounts" then
        TriggerCallback("tiktok:searchAccounts", callback, data.query, data.page)

        -- Social interactions
    elseif action == "toggleFollow" then
        local followData = data.data
        TriggerCallback("tiktok:toggleFollow", callback, followData.username, followData.follow)
    elseif action == "getFollowing" then
        TriggerCallback("tiktok:getFollowing", callback, data.username, data.page)
    elseif action == "getFollowers" then
        TriggerCallback("tiktok:getFollowers", callback, data.username, data.page)

        -- Video management
    elseif action == "uploadVideo" then
        local videoData = data.data

        -- Validate required fields
        if not videoData.src or not videoData.caption then
            return callback({
                success = false,
                error = "invalid_caption"
            })
        end

        -- Validate music data if present
        if videoData.music then
            if not videoData.music.path or not videoData.music.volume then
                return callback({
                    success = false,
                    error = "invalid_music"
                })
            end
            videoData.music = json.encode(videoData.music)
        end

        -- Process metadata
        if videoData.metadata then
            if type(videoData.metadata) == "table" then
                local isEmpty = true
                for _ in pairs(videoData.metadata) do
                    isEmpty = false
                    break
                end

                if isEmpty then
                    videoData.metadata = nil
                else
                    videoData.metadata = json.encode(videoData.metadata)
                end
            else
                videoData.metadata = nil
            end
        end

        TriggerCallback("tiktok:uploadVideo", callback, videoData)
    elseif action == "deleteVideo" then
        TriggerCallback("tiktok:deleteVideo", callback, data.id)
    elseif action == "togglePinnedVideo" then
        TriggerCallback("tiktok:togglePinnedVideo", callback, data.id, data.toggle)
    elseif action == "getVideos" then
        TriggerCallback("tiktok:getVideos", function(videos)
            print(json.encode(videos))
            -- Format each video
            for i = 1, #videos do
                videos[i] = formatVideoData(videos[i])
            end
            callback(videos)
        end, data.data, data.page or 0)
    elseif action == "getVideo" then
        TriggerCallback("tiktok:getVideo", function(result)
            if result.video then
                result.video = formatVideoData(result.video)
            end
            callback(result)
        end, data.id)
    elseif action == "setViewed" then
        TriggerServerEvent("phone:tiktok:setViewed", data.id)
        callback("ok")

        -- Video interactions
    elseif action == "toggleLike" then
        TriggerCallback("tiktok:toggleVideoAction", callback, "like", data.id, data.toggle)
    elseif action == "toggleSave" then
        TriggerCallback("tiktok:toggleVideoAction", callback, "save", data.id, data.toggle)

        -- Comments
    elseif action == "postComment" then
        local commentData = data.data
        TriggerCallback("tiktok:postComment", callback, commentData.id, commentData.replyTo, commentData.comment)
    elseif action == "getComments" then
        local commentData = data.data
        -- Try real server callback
        TriggerCallback("tiktok:getComments", function(response)
            callback(response)
        end, commentData.id, commentData.replyTo, data.page, commentData.sortBy or "newest",
            commentData.getReplies or false)
    elseif action == "deleteComment" then
        TriggerCallback("tiktok:deleteComment", callback, data.id, data.videoId)
    elseif action == "setPinnedComment" then
        TriggerCallback("tiktok:setPinnedComment", callback, data.commentId, data.videoId)
    elseif action == "toggleLikeComment" then
        TriggerCallback("tiktok:toggleLikeComment", callback, data.id, data.toggle)

        -- Messaging
    elseif action == "getRecentMessages" then
        TriggerCallback("tiktok:getRecentMessages", callback)
    elseif action == "getMessages" then
        TriggerCallback("tiktok:getMessages", callback, data.id, data.page)
    elseif action == "sendMessage" then
        if not CanInteract() then
            return callback(false)
        end
        TriggerCallback("tiktok:sendMessage", callback, data.data)
    elseif action == "getChannelId" then
        TriggerCallback("tiktok:getChannelId", callback, data.username)
    elseif action == "getNotifications" then
        TriggerCallback("tiktok:getNotifications", callback, data.page)
    elseif action == "getUnreadMessages" then
        TriggerCallback("tiktok:getUnreadMessages", callback)
    elseif action == "clearUnreadMessages" then
        TriggerServerEvent("phone:tiktok:clearUnreadMessages", data.id)
    end
end)

-- Handle follower updates
RegisterNetEvent("phone:tiktok:updateFollowers", function(username, method)
    SendReactMessage("tiktok:updateFollowers", {
        username = username,
        method = method
    })
end)

-- Handle following updates
RegisterNetEvent("phone:tiktok:updateFollowing", function(username, method)
    SendReactMessage("tiktok:updateFollowing", {
        username = username,
        method = method
    })
end)

-- Handle video statistics updates
RegisterNetEvent("phone:tiktok:updateVideoStats", function(statType, videoId, method, count)
    local updateData = {
        id = videoId,
        method = method,
        count = count
    }

    if statType == "like" then
        SendReactMessage("tiktok:updateLikes", updateData)
    elseif statType == "save" then
        SendReactMessage("tiktok:updateSaves", updateData)
    elseif statType == "comment" then
        SendReactMessage("tiktok:updateComments", updateData)
    end
end)

-- Handle comment statistics updates
RegisterNetEvent("phone:tiktok:updateCommentStats", function(statType, commentId, method)
    if statType == "reply" then
        SendReactMessage("tiktok:updateReplies", {
            id = commentId,
            method = method
        })
    elseif statType == "like" then
        SendReactMessage("tiktok:updateCommentLikes", {
            id = commentId,
            method = method
        })
    end
end)

-- Handle new message notifications
RegisterNetEvent("phone:tiktok:receivedMessage", function(messageData)
    SendReactMessage("tiktok:receivedMessage", messageData)
end)

-- Handle new video notifications
RegisterNetEvent("phone:tiktok:newVideo", function(videoData)
    TriggerEvent("lb-phone:trendy:newPost", videoData)
end)
