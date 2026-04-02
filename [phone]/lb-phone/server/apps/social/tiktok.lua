-- TikTok App for LB Phone
-- Deobfuscated version

-- Get logged in TikTok account for a player
local function getLoggedInTikTokAccount(playerId)
    local phoneNumber = GetEquippedPhoneNumber(playerId)
    if not phoneNumber then
        return false
    end
    return GetLoggedInAccount(phoneNumber, "TikTok")
end

-- Create authenticated callback wrapper
local function createAuthenticatedCallback(callbackName, handler, defaultReturn)
    BaseCallback("tiktok:" .. callbackName, function(source, phoneNumber, ...)
        local account = GetLoggedInAccount(phoneNumber, "TikTok")
        if not account then
            return defaultReturn
        end
        return handler(source, phoneNumber, account, ...)
    end, defaultReturn)
end

-- Send notification to all logged in accounts
local function sendNotificationToAllAccounts(username, notification, excludePhoneNumber)
    local accounts = MySQL.query.await(
    "SELECT phone_number FROM phone_logged_in_accounts WHERE username = ? AND app = 'TikTok' AND `active` = 1",
        { username })
    notification.app = "TikTok"

    for i = 1, #accounts do
        local phoneNumber = accounts[i].phone_number
        if phoneNumber ~= excludePhoneNumber then
            SendNotification(phoneNumber, notification)
        end
    end
end

-- Get TikTok account profile
local function getTikTokProfile(username, loggedInUsername)
    local fields =
    "`name`, bio, avatar, username, verified, follower_count, following_count, like_count, twitter, instagram, show_likes"
    local profile = nil

    if loggedInUsername then
        local query = [[
            SELECT %s,
                (SELECT TRUE FROM phone_tiktok_follows WHERE follower = @username AND followed = @loggedIn) AS isFollowingYou,
                (SELECT TRUE FROM phone_tiktok_follows WHERE follower = @loggedIn AND followed = @username) AS isFollowing
            FROM phone_tiktok_accounts WHERE username = @username
        ]]
        profile = MySQL.Sync.fetchAll(query:format(fields), {
            ["@username"] = username,
            ["@loggedIn"] = loggedInUsername
        })
        if profile then
            profile = profile[1]
        end
    else
        local query = "SELECT %s FROM phone_tiktok_accounts WHERE username = @username"
        profile = MySQL.Sync.fetchAll(query:format(fields), {
            ["@username"] = username
        })
        if profile then
            profile = profile[1]
        end
    end

    if profile then
        profile.isFollowing = profile.isFollowing == 1
        profile.isFollowingYou = profile.isFollowingYou == 1
    end

    return profile
end

-- Notification types
local notificationTypes = {
    like = "BACKEND.TIKTOK.LIKE",
    save = "BACKEND.TIKTOK.SAVE",
    comment = "BACKEND.TIKTOK.COMMENT",
    follow = "BACKEND.TIKTOK.FOLLOW",
    like_comment = "BACKEND.TIKTOK.LIKED_COMMENT",
    reply = "BACKEND.TIKTOK.REPLIED_COMMENT",
    message = "BACKEND.TIKTOK.DM"
}

-- Send TikTok notification
local function sendTikTokNotification(toUsername, fromUsername, notificationType, videoId, commentId, messageData)
    local notificationKey = notificationTypes[notificationType]
    if not notificationKey or toUsername == fromUsername then
        return
    end

    local toProfile = getTikTokProfile(fromUsername)
    if not toProfile then
        return
    end

    -- Check for duplicate notifications (except messages)
    if notificationType ~= "message" then
        local params = { toUsername, fromUsername, notificationType }
        local query = "SELECT 1 FROM phone_tiktok_notifications WHERE username = ? AND `from` = ? AND `type` = ?"

        if videoId then
            query = query .. " AND video_id = ?"
            table.insert(params, videoId)
        end

        if commentId then
            query = query .. " AND comment_id = ?"
            table.insert(params, commentId)
        end

        local exists = MySQL.scalar.await(query, params) == 1
        if exists then
            return
        end

        -- Insert notification
        MySQL.insert(
        "INSERT INTO phone_tiktok_notifications (username, `from`, `type`, video_id, comment_id) VALUES (?, ?, ?, ?, ?)",
            {
                toUsername, fromUsername, notificationType, videoId, commentId
            })
    end

    -- Get video thumbnail if applicable
    local videoThumbnail = nil
    if videoId then
        videoThumbnail = MySQL.Sync.fetchScalar("SELECT src FROM phone_tiktok_videos WHERE id = @id", {
            ["@id"] = videoId
        })
    end

    -- Create notification object
    local notification = {
        app = "TikTok",
        title = L(notificationKey, { displayName = toProfile.name }),
        thumbnail = videoThumbnail
    }

    if notificationType == "message" then
        notification.avatar = toProfile.avatar
        notification.content = messageData.content
        notification.showAvatar = true
    end

    -- Send to all logged in accounts
    local accounts = MySQL.query.await(
    "SELECT phone_number FROM phone_logged_in_accounts WHERE username = ? AND app = 'TikTok' AND `active` = 1",
        { toUsername })
    for i = 1, #accounts do
        SendNotification(accounts[i].phone_number, notification)
    end
end

-- Cleanup old notifications thread
CreateThread(function()
    while true do
        if not DatabaseCheckerFinished then
            Wait(500)
        else
            break
        end
    end

    while true do
        MySQL.Async.execute("DELETE FROM phone_tiktok_notifications WHERE `timestamp` < DATE_SUB(NOW(), INTERVAL 7 DAY)",
            {})
        Wait(3600000) -- 1 hour
    end
end)

-- Get notifications
RegisterLegacyCallback("tiktok:getNotifications", function(source, cb, page)
    local account = getLoggedInTikTokAccount(source)
    if not account then
        return cb({ success = false, error = "not_logged_in" })
    end

    local query = [[
        SELECT
            n.`type`, n.`timestamp`, n.video_id AS videoId,
            a.`name`, a.avatar, a.username, a.verified,
            CASE
                WHEN n.video_id IS NOT NULL THEN
                    v.src
                ELSE NULL
            END AS videoSrc,
            n.comment_id,
            CASE
                WHEN n.comment_id IS NOT NULL THEN
                    c.comment
                ELSE NULL
            END AS commentText,
            CASE
                WHEN n.`type` = 'follow' THEN
                    CASE
                        WHEN f.follower IS NOT NULL THEN
                            TRUE
                        ELSE FALSE
                    END
                ELSE NULL
            END AS isFollowing,
            CASE
                WHEN n.`type` = 'reply' THEN
                c_original.comment
                ELSE NULL
            END AS originalText
        FROM
            phone_tiktok_notifications n
            LEFT JOIN phone_tiktok_accounts a ON n.from = a.username
            LEFT JOIN phone_tiktok_videos v ON n.video_id = v.id
            LEFT JOIN phone_tiktok_comments c ON n.comment_id = c.id
            LEFT JOIN phone_tiktok_comments c_original ON c.reply_to = c_original.id
            LEFT JOIN phone_tiktok_follows f ON n.username = f.follower AND n.from = f.followed
        WHERE
            n.username = @username
        ORDER BY
            n.`timestamp` DESC
        LIMIT @page, @perPage
    ]]

    MySQL.Async.fetchAll(query, {
        ["@username"] = account,
        ["@page"] = (page or 0) * 15,
        ["@perPage"] = 15
    }, function(results)
        cb({ success = true, data = results })
    end)
end)

-- Login
RegisterLegacyCallback("tiktok:login", function(source, cb, username, password)
    local phoneNumber = GetEquippedPhoneNumber(source)
    if not phoneNumber then
        return cb({ success = false, error = "no_number" })
    end

    username = username:lower()

    MySQL.Async.fetchScalar("SELECT password FROM phone_tiktok_accounts WHERE username = @username", {
        ["@username"] = username
    }, function(hashedPassword)
        if not hashedPassword then
            return cb({ success = false, error = "invalid_username" })
        end

        if not VerifyPasswordHash(password, hashedPassword) then
            return cb({ success = false, error = "incorrect_password" })
        end

        local profile = getTikTokProfile(username)
        if not profile then
            return cb({ success = false, error = "invalid_username" })
        end

        AddLoggedInAccount(phoneNumber, "TikTok", username)
        cb({ success = true, data = profile })
    end)
end)

-- Signup
RegisterLegacyCallback("tiktok:signup", function(source, cb, username, password, displayName)
    local phoneNumber = GetEquippedPhoneNumber(source)
    if not phoneNumber then
        return cb({ success = false, error = "UNKNOWN" })
    end

    username = username:lower()

    if not IsUsernameValid(username) then
        return cb({ success = false, error = "USERNAME_NOT_ALLOWED" })
    end

    local exists = MySQL.Sync.fetchScalar("SELECT TRUE FROM phone_tiktok_accounts WHERE username = @username", {
        ["@username"] = username
    })
    if exists then
        return cb({ success = false, error = "USERNAME_TAKEN" })
    end

    MySQL.Sync.execute(
    "INSERT INTO phone_tiktok_accounts (`name`, username, password, phone_number) VALUES (@displayName, @username, @password, @phoneNumber)",
        {
            ["@displayName"] = displayName,
            ["@username"] = username,
            ["@password"] = GetPasswordHash(password),
            ["@phoneNumber"] = phoneNumber
        })

    AddLoggedInAccount(phoneNumber, "TikTok", username)
    cb({ success = true })

    -- Auto follow trendy accounts if enabled
    if Config.AutoFollow.Enabled and Config.AutoFollow.Trendy.Enabled then
        for i = 1, #Config.AutoFollow.Trendy.Accounts do
            MySQL.update.await("INSERT INTO phone_tiktok_follows (followed, follower) VALUES (?, ?)", {
                Config.AutoFollow.Trendy.Accounts[i],
                username
            })
        end
    end
end, { preventSpam = true, rateLimit = 4 })

-- Change password
createAuthenticatedCallback("changePassword", function(source, phoneNumber, account, oldPassword, newPassword)
    if not Config.ChangePassword.Trendy then
        infoprint("warning",
            string.format("%s tried to change password on Trendy, but it's not enabled in the config.", source))
        return false
    end

    if oldPassword == newPassword or #newPassword < 3 then
        debugprint("same password / too short")
        return false
    end

    local currentPassword = MySQL.scalar.await("SELECT password FROM phone_tiktok_accounts WHERE username = ?", { account })
    if not currentPassword or not VerifyPasswordHash(oldPassword, currentPassword) then
        return false
    end

    local updated = MySQL.update.await("UPDATE phone_tiktok_accounts SET password = ? WHERE username = ?", {
        GetPasswordHash(newPassword),
        account
    }) > 0

    if not updated then
        return false
    end

    -- Notify other devices and log out
    sendNotificationToAllAccounts(account, {
        title = L("BACKEND.MISC.LOGGED_OUT_PASSWORD.TITLE"),
        content = L("BACKEND.MISC.LOGGED_OUT_PASSWORD.DESCRIPTION")
    }, phoneNumber)

    MySQL.update.await(
    "DELETE FROM phone_logged_in_accounts WHERE username = ? AND app = 'TikTok' AND phone_number != ?", {
        account, phoneNumber
    })

    ClearActiveAccountsCache("TikTok", account, phoneNumber)

    Log("Trendy", source, "info",
        L("BACKEND.LOGS.CHANGED_PASSWORD.TITLE"),
        L("BACKEND.LOGS.CHANGED_PASSWORD.DESCRIPTION", {
            number = phoneNumber,
            username = account,
            app = "Trendy"
        })
    )

    TriggerClientEvent("phone:logoutFromApp", -1, {
        username = account,
        app = "tiktok",
        reason = "password",
        number = phoneNumber
    })

    return true
end, false)

-- Delete account
createAuthenticatedCallback("deleteAccount", function(source, phoneNumber, account, password)
    if not Config.DeleteAccount.Trendy then
        infoprint("warning",
            string.format("%s tried to delete their account on Trendy, but it's not enabled in the config.", source))
        return false
    end

    local currentPassword = MySQL.scalar.await("SELECT password FROM phone_tiktok_accounts WHERE username = ?", { account })
    if not currentPassword or not VerifyPasswordHash(password, currentPassword) then
        return false
    end

    local deleted = MySQL.update.await("DELETE FROM phone_tiktok_accounts WHERE username = ?", { account }) > 0
    if not deleted then
        return false
    end

    -- Notify and cleanup
    sendNotificationToAllAccounts(account, {
        title = L("BACKEND.MISC.DELETED_NOTIFICATION.TITLE"),
        content = L("BACKEND.MISC.DELETED_NOTIFICATION.DESCRIPTION")
    })

    MySQL.update.await("DELETE FROM phone_logged_in_accounts WHERE username = ? AND app = 'TikTok'", { account })
    ClearActiveAccountsCache("TikTok", account)

    Log("Trendy", source, "info",
        L("BACKEND.LOGS.DELETED_ACCOUNT.TITLE"),
        L("BACKEND.LOGS.DELETED_ACCOUNT.DESCRIPTION", {
            number = phoneNumber,
            username = account,
            app = "Trendy"
        })
    )

    TriggerClientEvent("phone:logoutFromApp", -1, {
        username = account,
        app = "tiktok",
        reason = "deleted"
    })

    return true
end, false)

-- Logout
RegisterLegacyCallback("tiktok:logout", function(source, cb)
    local account = getLoggedInTikTokAccount(source)
    if not account then
        return cb(false)
    end

    local phoneNumber = GetEquippedPhoneNumber(source)
    if not phoneNumber then
        return cb(false)
    end

    RemoveLoggedInAccount(phoneNumber, "TikTok", account)
    cb(true)
end)

-- Check if logged in
RegisterLegacyCallback("tiktok:isLoggedIn", function(source, cb)
    local account = getLoggedInTikTokAccount(source)
    local profile = account and getTikTokProfile(account) or false
    cb(profile)
end)

-- Get profile
RegisterLegacyCallback("tiktok:getProfile", function(source, cb, username)
    local loggedInAccount = getLoggedInTikTokAccount(source)
    cb(getTikTokProfile(username, loggedInAccount))
end)

-- Update profile
RegisterLegacyCallback("tiktok:updateProfile", function(source, cb, profileData)
    local phoneNumber = GetEquippedPhoneNumber(source)
    if not phoneNumber then
        return cb({ success = false, error = "no_number" })
    end

    local account = getLoggedInTikTokAccount(source)
    if not account then
        return cb({ success = false, error = "not_logged_in" })
    end

    local name = profileData.name
    local bio = profileData.bio
    local avatar = profileData.avatar
    local twitter = profileData.twitter
    local instagram = profileData.instagram
    local showLikes = profileData.show_likes

    if #name > 30 then
        return cb({ success = false, error = "display_name_too_long" })
    end

    if bio and #bio > 150 then
        return cb({ success = false, error = "bio_too_long" })
    end

    -- Validate Twitter account
    if twitter then
        local validTwitter = MySQL.Sync.fetchScalar(
        "SELECT TRUE FROM phone_logged_in_accounts WHERE phone_number = @phoneNumber and app = @app and username = @username",
            {
                ["@phoneNumber"] = phoneNumber,
                ["@app"] = "Twitter",
                ["@username"] = twitter
            })
        if not validTwitter then
            return cb({ success = false, error = "invalid_twitter" })
        end
    end

    -- Validate Instagram account
    if instagram then
        local validInstagram = MySQL.Sync.fetchScalar(
        "SELECT TRUE FROM phone_logged_in_accounts WHERE phone_number = @phoneNumber and app = @app and username = @username",
            {
                ["@phoneNumber"] = phoneNumber,
                ["@app"] = "Instagram",
                ["@username"] = instagram
            })
        if not validInstagram then
            return cb({ success = false, error = "invalid_instagram" })
        end
    end

    MySQL.Async.execute(
    "UPDATE phone_tiktok_accounts SET `name` = @displayName, bio = @bio, avatar = @avatar, twitter = @twitter, instagram = @instagram, `show_likes` = @showLikes WHERE username = @username",
        {
            ["@displayName"] = name,
            ["@bio"] = bio,
            ["@avatar"] = avatar,
            ["@twitter"] = twitter,
            ["@instagram"] = instagram,
            ["@showLikes"] = showLikes == true,
            ["@username"] = account
        }, function()
        cb({ success = true })
    end)
end)

-- Search accounts
RegisterLegacyCallback("tiktok:searchAccounts", function(source, cb, query, page)
    local account = getLoggedInTikTokAccount(source)
    if not account then
        return cb(false)
    end

    local searchQuery = [[
        SELECT `name`, username, avatar, verified, follower_count, video_count,
            (SELECT TRUE FROM phone_tiktok_follows WHERE follower = @username AND followed = a.username) AS isFollowing

        FROM phone_tiktok_accounts a
        WHERE username LIKE @query OR `name` LIKE @query
        ORDER BY username
        LIMIT @page, @perPage
    ]]

    MySQL.Async.fetchAll(searchQuery, {
        ["@query"] = "%" .. query .. "%",
        ["@username"] = account,
        ["@page"] = (page or 0) * 10,
        ["@perPage"] = 10
    }, cb)
end)

-- Toggle follow
RegisterLegacyCallback("tiktok:toggleFollow", function(source, cb, targetUsername, isFollowing)
    local account = getLoggedInTikTokAccount(source)
    if not account then
        return cb({ success = false, error = "not_logged_in" })
    end

    if targetUsername == account then
        return cb({ success = false, error = "cannot_follow_self" })
    end

    local targetProfile = getTikTokProfile(targetUsername)
    if not targetProfile then
        return cb({ success = false, error = "invalid_username" })
    end

    cb({ success = true })

    local query = isFollowing == true and
        "INSERT IGNORE INTO phone_tiktok_follows (follower, followed) VALUES (@follower, @followed)" or
        "DELETE FROM phone_tiktok_follows WHERE follower = @follower AND followed = @followed"

    MySQL.Async.execute(query, {
        ["@follower"] = account,
        ["@followed"] = targetUsername
    }, function(affectedRows)
        if affectedRows == 0 then
            return
        end

        local action = isFollowing == true and "add" or "remove"

        TriggerClientEvent("phone:tiktok:updateFollowers", -1, targetUsername, action)
        TriggerClientEvent("phone:tiktok:updateFollowing", -1, account, action)

        if isFollowing == true then
            sendTikTokNotification(targetUsername, account, "follow")
        end
    end)
end, { preventSpam = true })

-- Get following list
RegisterLegacyCallback("tiktok:getFollowing", function(source, cb, username, page)
    local account = getLoggedInTikTokAccount(source)
    if not account then
        return cb({})
    end

    local query = [[
        SELECT
            a.username, a.`name`, a.avatar, a.verified,
                (SELECT TRUE FROM phone_tiktok_follows WHERE follower = a.username AND followed = @loggedIn) AS isFollowingYou,
                (SELECT TRUE FROM phone_tiktok_follows WHERE follower = @loggedIn AND followed = a.username) AS isFollowing
        FROM phone_tiktok_follows f
        INNER JOIN phone_tiktok_accounts a ON a.username = f.followed
        WHERE f.follower = @username
        ORDER BY a.username
        LIMIT @page, @perPage
    ]]

    MySQL.Async.fetchAll(query, {
        ["@username"] = username,
        ["@loggedIn"] = account,
        ["@page"] = (page or 0) * 15,
        ["@perPage"] = 15
    }, cb)
end)

-- Get followers list
RegisterLegacyCallback("tiktok:getFollowers", function(source, cb, username, page)
    local account = getLoggedInTikTokAccount(source)
    if not account then
        return cb({})
    end

    local query = [[
        SELECT
            a.username, a.`name`, a.avatar, a.verified,
                (SELECT TRUE FROM phone_tiktok_follows WHERE follower = @username AND followed = @loggedIn) AS isFollowingYou,
                (SELECT TRUE FROM phone_tiktok_follows WHERE follower = @loggedIn AND followed = @username) AS isFollowing
        FROM phone_tiktok_follows f
        INNER JOIN phone_tiktok_accounts a ON a.username = f.follower
        WHERE f.followed = @username
        ORDER BY a.username
        LIMIT @page, @perPage
    ]]

    MySQL.Async.fetchAll(query, {
        ["@username"] = username,
        ["@loggedIn"] = account,
        ["@page"] = (page or 0) * 15,
        ["@perPage"] = 15
    }, cb)
end)

-- Upload video
RegisterLegacyCallback("tiktok:uploadVideo", function(source, cb, videoData)
    local account = getLoggedInTikTokAccount(source)
    if not account then
        return cb({ success = false, error = "not_logged_in" })
    end

    if ContainsBlacklistedWord(source, "Trendy", videoData.caption) then
        return cb(false)
    end

    if not videoData.src or type(videoData.src) ~= "string" or #videoData.src == 0 then
        return cb({ success = false, error = "invalid_src" })
    end

    if not videoData.caption or type(videoData.caption) ~= "string" or #videoData.caption == 0 then
        return cb({ success = false, error = "invalid_caption" })
    end

    local videoId = GenerateId("phone_tiktok_videos", "id")

    MySQL.Async.execute(
    "INSERT INTO phone_tiktok_videos (id, username, src, caption, metadata, music) VALUES (@id, @username, @src, @caption, @metadata, @music)",
        {
            ["@id"] = videoId,
            ["@username"] = account,
            ["@src"] = videoData.src,
            ["@caption"] = videoData.caption,
            ["@metadata"] = videoData.metadata,
            ["@music"] = videoData.music
        }, function()
        cb({ success = true, id = videoId })

        local videoInfo = {
            username = account,
            caption = videoData.caption,
            videoUrl = videoData.src,
            id = videoId
        }

        TriggerClientEvent("phone:tiktok:newVideo", -1, videoInfo)
        TriggerEvent("lb-phone:trendy:newPost", videoInfo)
        TrackSocialMediaPost("trendy", { videoData.src })

        Log("Trendy", source, "success",
            L("BACKEND.LOGS.TRENDY_UPLOAD_TITLE"),
            L("BACKEND.LOGS.TRENDY_UPLOAD_DESCRIPTION", {
                username = account,
                caption = videoData.caption,
                id = videoId
            })
        )
    end)
end, { preventSpam = true, rateLimit = 6 })

-- Delete video
RegisterLegacyCallback("tiktok:deleteVideo", function(source, cb, videoId)
    local account = getLoggedInTikTokAccount(source)
    if not account then
        return cb({ success = false, error = "not_logged_in" })
    end

    local query = "DELETE FROM phone_tiktok_videos WHERE id = @id"
    if not IsAdmin(source) then
        query = query .. " AND username = @username"
    end

    MySQL.Async.execute(query, {
        ["@id"] = videoId,
        ["@username"] = account
    }, function(affectedRows)
        cb({ success = affectedRows > 0 })

        if affectedRows > 0 then
            Log("Trendy", source, "error",
                L("BACKEND.LOGS.TRENDY_DELETE_TITLE"),
                L("BACKEND.LOGS.TRENDY_DELETE_DESCRIPTION", {
                    username = account,
                    id = videoId
                })
            )
        end
    end)
end)

-- Toggle pinned video
RegisterLegacyCallback("tiktok:togglePinnedVideo", function(source, cb, videoId, isPinned)
    local account = getLoggedInTikTokAccount(source)
    if not account then
        return cb({ success = false, error = "not_logged_in" })
    end

    if isPinned then
        local pinnedCount = MySQL.Sync.fetchScalar(
        "SELECT COUNT(*) FROM phone_tiktok_pinned_videos WHERE username = @username", {
            ["@username"] = account
        })
        if pinnedCount >= 3 and isPinned then
            return cb({ success = false, error = "max_pinned" })
        end
    end

    local query = isPinned and
        "INSERT INTO phone_tiktok_pinned_videos (username, video_id) VALUES (@username, @videoId)" or
        "DELETE FROM phone_tiktok_pinned_videos WHERE username = @username AND video_id = @videoId"

    MySQL.Async.execute(query, {
        ["@videoId"] = videoId,
        ["@username"] = account
    }, function(affectedRows)
        cb({ success = affectedRows > 0 })
    end)
end)

-- Base video query for getting videos with all necessary joins
local baseVideoQuery = [[
    SELECT
        v.id, v.src, v.caption, v.`timestamp`,
        p.video_id IS NOT NULL AS pinned,

        v.likes, v.comments, v.views, v.saves,
        (SELECT TRUE FROM phone_tiktok_likes WHERE username = @loggedIn AND video_id = v.id) AS liked,
        (SELECT TRUE FROM phone_tiktok_saves WHERE username = @loggedIn AND video_id = v.id) AS saved,
        w.video_id IS NOT NULL AS viewed,

        v.metadata, v.music,

        a.username, a.`name`, a.avatar, a.verified,
        (SELECT TRUE FROM phone_tiktok_follows WHERE follower = @username AND followed = a.username) AS following

    FROM phone_tiktok_videos v
    INNER JOIN phone_tiktok_accounts a ON a.username = v.username
    LEFT JOIN phone_tiktok_views w ON v.id = w.video_id AND w.username = @loggedIn
    LEFT JOIN phone_tiktok_pinned_videos p ON p.video_id = v.id AND p.username = @loggedIn
]]

-- Get single video
RegisterLegacyCallback("tiktok:getVideo", function(source, cb, videoId)
    local account = getLoggedInTikTokAccount(source)
    if not account then
        return cb({ success = false, error = "not_logged_in" })
    end

    local query = baseVideoQuery .. [[
        WHERE v.id = @id
    ]]

    MySQL.Async.fetchAll(query, {
        ["@id"] = videoId,
        ["@loggedIn"] = account,
        ["@username"] = account
    }, function(results)
        if #results == 0 then
            return cb({ success = false, error = "invalid_id" })
        end
        cb({ success = true, video = results[1] })
    end)
end)

-- Get videos (feed, profile, liked, saved)
RegisterLegacyCallback("tiktok:getVideos", function(source, cb, options, page)
    local account = getLoggedInTikTokAccount(source)
    if not account then
        return cb({})
    end

    local query = nil
    local perPage = nil

    if options.full then
        if options.type == "recent" then
            if options.id then
                if options.username then
                    query = baseVideoQuery .. [[
                        WHERE v.username = @username AND v.`timestamp` %s (SELECT `timestamp` FROM phone_tiktok_videos WHERE id = @id)
                        ORDER BY (w.username IS NOT NULL), v.timestamp DESC
                        LIMIT @page, @perPage
                    ]]
                    query = query:format(options.backwards and ">" or "<")
                else
                    query = baseVideoQuery .. [[
                        WHERE v.username != @loggedIn AND v.`timestamp` %s (SELECT `timestamp` FROM phone_tiktok_videos WHERE id = @id)
                        ORDER BY (w.username IS NOT NULL), v.timestamp DESC
                        LIMIT @page, @perPage
                    ]]
                    query = query:format(options.backwards and ">" or "<")
                end
            else
                query = baseVideoQuery .. [[
                    WHERE v.username != @loggedIn
                    ORDER BY (w.username IS NOT NULL), v.timestamp DESC
                    LIMIT @page, @perPage
                ]]
            end
        elseif options.type == "following" then
            query = baseVideoQuery .. [[
                INNER JOIN phone_tiktok_follows f ON f.followed = v.username
                WHERE f.follower = @loggedIn
                ORDER BY (w.username IS NOT NULL), v.timestamp DESC
                LIMIT @page, @perPage
            ]]
        end
        perPage = 5
    else
        if options.type == "recent" then
            if options.username then
                if page == 0 then
                    query = [[
                        SELECT
                            v.id, v.src, v.views,
                            p.video_id IS NOT NULL AS pinned
                        FROM phone_tiktok_videos v
                        LEFT JOIN phone_tiktok_pinned_videos p ON p.video_id = v.id AND p.username = @username
                        WHERE v.username = @username
                        ORDER BY (p.video_id IS NOT NULL) DESC, v.`timestamp` DESC
                        LIMIT @page, @perPage
                    ]]
                else
                    query = [[
                        SELECT id, src, views
                        FROM phone_tiktok_videos
                        WHERE username = @username
                        ORDER BY `timestamp` DESC
                        LIMIT @page, @perPage
                    ]]
                end
            end
        elseif options.type == "liked" then
            query = [[
                SELECT v.id, v.src, v.views
                FROM phone_tiktok_videos v
                INNER JOIN phone_tiktok_likes l ON l.video_id = v.id
                WHERE l.username = @username
                ORDER BY v.`timestamp` DESC
                LIMIT @page, @perPage
            ]]
        elseif options.type == "saved" then
            if account ~= options.username then
                debugprint("wrong account", account, #account, options.username, #options.username)
                return cb({})
            end
            query = [[
                SELECT v.id, v.src, v.views
                FROM phone_tiktok_videos v
                INNER JOIN phone_tiktok_saves s ON s.video_id = v.id
                WHERE s.username = @username
                ORDER BY v.`timestamp` DESC
                LIMIT @page, @perPage
            ]]
        end
        perPage = 15
    end

    if not query then
        return cb({})
    end


    
    MySQL.Async.fetchAll(query, {
        ["@username"] = options.username,
        ["@loggedIn"] = account,
        ["@id"] = options.id,
        ["@page"] = (page or 0) * perPage,
        ["@perPage"] = perPage
    }, cb)
end)

-- Set video as viewed
RegisterNetEvent("phone:tiktok:setViewed", function(videoId)
    local account = getLoggedInTikTokAccount(source)
    if not account then
        return
    end

    MySQL.Async.execute("INSERT IGNORE INTO phone_tiktok_views (username, video_id) VALUES (@username, @videoId)", {
        ["@username"] = account,
        ["@videoId"] = videoId
    })
end)

-- Toggle video action (like/save)
RegisterLegacyCallback("tiktok:toggleVideoAction", function(source, cb, action, videoId, isActive)
    if action ~= "like" and action ~= "save" then
        return cb({ success = false, error = "invalid_action" })
    end

    local account = getLoggedInTikTokAccount(source)
    if not account then
        return cb({ success = false, error = "not_logged_in" })
    end

    local videoOwner = MySQL.Sync.fetchScalar("SELECT username FROM phone_tiktok_videos WHERE id = @id", {
        ["@id"] = videoId
    })
    if not videoOwner then
        return cb({ success = false, error = "invalid_id" })
    end

    cb({ success = true })

    local tableName = action == "like" and "likes" or "saves"
    local query = isActive == true and
        ("INSERT IGNORE INTO phone_tiktok_%s (username, video_id) VALUES (@username, @videoId)"):format(tableName) or
        ("DELETE FROM phone_tiktok_%s WHERE username = @username AND video_id = @videoId"):format(tableName)

    MySQL.Async.execute(query, {
        ["@username"] = account,
        ["@videoId"] = videoId
    }, function(affectedRows)
        if affectedRows == 0 then
            return
        end

        local actionType = isActive == true and "add" or "remove"
        TriggerClientEvent("phone:tiktok:updateVideoStats", -1, action, videoId, actionType)

        if isActive then
            sendTikTokNotification(videoOwner, account, action, videoId)
        end
    end)
end, { preventSpam = true, rateLimit = 30 })

-- Post comment
RegisterLegacyCallback("tiktok:postComment", function(source, cb, videoId, replyToId, comment)
    local account = getLoggedInTikTokAccount(source)
    if not account then
        return cb({ success = false, error = "not_logged_in" })
    end

    if not comment or #comment == 0 or #comment > 500 then
        return cb({ success = false, error = "invalid_comment" })
    end

    if ContainsBlacklistedWord(source, "Trendy", comment) then
        return cb(false)
    end

    local videoOwner = MySQL.Sync.fetchScalar("SELECT username FROM phone_tiktok_videos WHERE id = @id", {
        ["@id"] = videoId
    })
    if not videoOwner then
        return cb({ success = false, error = "invalid_id" })
    end

    local replyToOwner = replyToId and
    MySQL.Sync.fetchScalar("SELECT username FROM phone_tiktok_comments WHERE id = @id", {
        ["@id"] = replyToId
    }) or nil
    if replyToId and not replyToOwner then
        return cb({ success = false, error = "invalid_reply_to" })
    end

    local commentId = GenerateId("phone_tiktok_comments", "id")

    MySQL.Async.execute(
    "INSERT INTO phone_tiktok_comments (id, reply_to, video_id, username, comment) VALUES (@id, @replyTo, @videoId, @loggedIn, @comment)",
        {
            ["@id"] = commentId,
            ["@replyTo"] = replyToId,
            ["@videoId"] = videoId,
            ["@loggedIn"] = account,
            ["@comment"] = comment
        }, function(affectedRows)
        if affectedRows == 0 then
            return cb({ success = false, error = "failed_insert" })
        end

        TriggerClientEvent("phone:tiktok:updateVideoStats", -1, "comment", videoId, "add")

        if replyToId then
            MySQL.Async.execute("UPDATE phone_tiktok_comments SET replies = replies + 1 WHERE id = @id", {
                ["@id"] = replyToId
            })
            TriggerClientEvent("phone:tiktok:updateCommentStats", -1, "reply", replyToId, "add")
            sendTikTokNotification(replyToOwner, account, "reply", videoId, commentId)
        end

        cb({ success = true, id = commentId })
        sendTikTokNotification(videoOwner, account, "comment", videoId, commentId)
    end)
end, { preventSpam = true, rateLimit = 10 })

-- Delete comment
RegisterLegacyCallback("tiktok:deleteComment", function(source, cb, commentId, videoId)
    local account = getLoggedInTikTokAccount(source)
    if not account then
        return cb({ success = false, error = "not_logged_in" })
    end

    local adminCheck = ""
    if not IsAdmin(source) then
        adminCheck = " AND username = @username"
    end

    local replyCount = 0
    local replyToId = MySQL.Sync.fetchScalar("SELECT reply_to FROM phone_tiktok_comments WHERE id = @id" .. adminCheck, {
        ["@id"] = commentId,
        ["@username"] = account
    })

    if replyToId then
        MySQL.Async.execute("UPDATE phone_tiktok_comments SET replies = replies - 1 WHERE id = @id", {
            ["@id"] = replyToId
        })
        TriggerClientEvent("phone:tiktok:updateCommentStats", -1, "reply", replyToId, "remove")
    else
        replyCount = MySQL.Sync.fetchScalar("SELECT COUNT(*) FROM phone_tiktok_comments WHERE reply_to = @id", {
            ["@id"] = commentId
        })
    end

    MySQL.Async.execute("DELETE FROM phone_tiktok_comments WHERE id = @id" .. adminCheck, {
        ["@id"] = commentId,
        ["@username"] = account
    }, function(affectedRows)
        if affectedRows > 0 then
            cb({ success = true })
            TriggerClientEvent("phone:tiktok:updateVideoStats", -1, "comment", videoId, "remove", replyCount + 1)
        else
            cb({ success = false, error = "failed_delete" })
        end
    end)
end)

-- Set pinned comment
RegisterLegacyCallback("tiktok:setPinnedComment", function(source, cb, commentId, videoId)
    local account = getLoggedInTikTokAccount(source)
    if not account then
        return cb({ success = false, error = "not_logged_in" })
    end

    local ownsVideo = MySQL.Sync.fetchScalar(
    "SELECT TRUE FROM phone_tiktok_videos WHERE id = @id AND username = @username", {
        ["@id"] = videoId,
        ["@username"] = account
    })
    if not ownsVideo then
        return cb({ success = false, error = "invalid_id" })
    end

    if commentId ~= nil then
        local ownsComment = MySQL.Sync.fetchScalar(
        "SELECT TRUE FROM phone_tiktok_comments WHERE id = @id AND username = @username", {
            ["@id"] = commentId,
            ["@username"] = account
        })
        if not ownsComment then
            return cb({ success = false, error = "invalid_comment" })
        end
    end

    MySQL.Async.execute("UPDATE phone_tiktok_videos SET pinned_comment = @commentId WHERE id = @id", {
        ["@commentId"] = commentId,
        ["@id"] = videoId
    }, function(affectedRows)
        if affectedRows > 0 then
            cb({ success = true })
        else
            cb({ success = false, error = "failed_update" })
        end
    end)
end)

-- Get comments
RegisterLegacyCallback("tiktok:getComments", function(source, cb, videoId, commentId, page, sortBy, getReplies)
    local account = getLoggedInTikTokAccount(source)
    if not account then
        return cb({})
    end

    local query = [[
        SELECT
            c.id, c.comment, c.`timestamp`, c.likes, c.replies,
            (SELECT TRUE FROM phone_tiktok_comments_likes WHERE username = @loggedIn AND comment_id = c.id) AS liked,
            a.username, a.`name`, a.avatar, a.verified,
            v.pinned_comment = c.id AS pinned
        FROM phone_tiktok_comments c
        INNER JOIN phone_tiktok_accounts a ON a.username = c.username
        INNER JOIN phone_tiktok_videos v ON v.id = c.video_id
        WHERE c.video_id = @videoId
    ]]

    local params = {
        ["@videoId"] = videoId,
        ["@loggedIn"] = account,
        ["@page"] = (tonumber(page) or 0) * 15,
        ["@perPage"] = 15
    }

    if getReplies and commentId then
        query = query .. " AND c.reply_to = @commentId"
        params["@commentId"] = commentId
    else
        query = query .. " AND c.reply_to IS NULL"
    end

    if sortBy == "newest" then
        query = query .. " ORDER BY c.`timestamp` DESC"
    else
        query = query .. " ORDER BY c.likes DESC, c.`timestamp` DESC"
    end

    query = query .. " LIMIT @page, @perPage"

    MySQL.Async.fetchAll(query, params, function(comments)
        cb({ success = true, comments = comments })
    end)
end)

-- Toggle comment like
RegisterLegacyCallback("tiktok:toggleCommentLike", function(source, cb, commentId, isLiked)
    local account = getLoggedInTikTokAccount(source)
    if not account then
        return cb({ success = false, error = "not_logged_in" })
    end

    local commentOwner = MySQL.Sync.fetchScalar("SELECT username FROM phone_tiktok_comments WHERE id = @id", {
        ["@id"] = commentId
    })
    if not commentOwner then
        return cb({ success = false, error = "invalid_id" })
    end

    cb({ success = true })

    local query = isLiked == true and
        "INSERT IGNORE INTO phone_tiktok_comments_likes (username, comment_id) VALUES (@username, @commentId)" or
        "DELETE FROM phone_tiktok_comments_likes WHERE username = @username AND comment_id = @commentId"

    MySQL.Async.execute(query, {
        ["@username"] = account,
        ["@commentId"] = commentId
    }, function(affectedRows)
        if affectedRows == 0 then
            return
        end

        local action = isLiked == true and "add" or "remove"
        TriggerClientEvent("phone:tiktok:updateCommentStats", -1, "like", commentId, action)

        if isLiked then
            sendTikTokNotification(commentOwner, account, "like_comment", nil, commentId)
        end
    end)
end, { preventSpam = true })

-- Backwards-compatible alias to match client call name
RegisterLegacyCallback("tiktok:toggleLikeComment", function(source, cb, commentId, isLiked)
    local account = getLoggedInTikTokAccount(source)
    if not account then
        return cb({ success = false, error = "not_logged_in" })
    end

    local commentOwner = MySQL.Sync.fetchScalar("SELECT username FROM phone_tiktok_comments WHERE id = @id", {
        ["@id"] = commentId
    })
    if not commentOwner then
        return cb({ success = false, error = "invalid_id" })
    end

    cb({ success = true })

    local query = isLiked == true and
        "INSERT IGNORE INTO phone_tiktok_comments_likes (username, comment_id) VALUES (@username, @commentId)" or
        "DELETE FROM phone_tiktok_comments_likes WHERE username = @username AND comment_id = @commentId"

    MySQL.Async.execute(query, {
        ["@username"] = account,
        ["@commentId"] = commentId
    }, function(affectedRows)
        if affectedRows == 0 then
            return
        end

        local action = isLiked == true and "add" or "remove"
        TriggerClientEvent("phone:tiktok:updateCommentStats", -1, "like", commentId, action)

        if isLiked then
            sendTikTokNotification(commentOwner, account, "like_comment", nil, commentId)
        end
    end)
end, { preventSpam = true })

-- Get channel id between logged-in user and target username
RegisterLegacyCallback("tiktok:getChannelId", function(source, cb, username)
    local account = getLoggedInTikTokAccount(source)
    if not account then
        return cb({ success = false, error = "not_logged_in" })
    end

    local channelId = MySQL.Sync.fetchScalar(
        "SELECT id FROM phone_tiktok_channels WHERE (member_1 = @loggedIn AND member_2 = @username) OR (member_1 = @username AND member_2 = @loggedIn)",
        {
            ["@loggedIn"] = account,
            ["@username"] = username
        }
    )

    if not channelId then
        return cb({ success = false, error = "no_channel" })
    end

    cb({ success = true, id = channelId })
end)
