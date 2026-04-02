
-- ========== Global Variables ==========
local lives = {} -- Store active live streams
local calls = {} -- Store active calls

-- ========== Helper Functions ==========
local function getLoggedInInstagramAccount(source)
    local phone = GetEquippedPhoneNumber(source)
    if not phone then return false end
    return GetLoggedInAccount(phone, "Instagram")
end

local function createAuthenticatedInstagramCallback(name, handler, defaultReturn, options)
    BaseCallback("instagram:" .. name, function(source, phoneNumber, ...)
        local account = GetLoggedInAccount(phoneNumber, "Instagram")
        if not account then
            return defaultReturn
        end
        return handler(source, phoneNumber, account, ...)
    end, defaultReturn, options)
end

-- Live streaming helper functions
local function CanGoLive(source, username)
    -- Check if already live
    if lives[username] then
        return false, L("BACKEND.INSTAGRAM.ALREADY_LIVE")
    end
    
    -- For now, just check if already live in memory
    -- Cooldown can be implemented later if needed
    
    return true
end

local function CanCreateStory(source, username)
    -- Check if already has active story (within last 24 hours)
    local hasStory = MySQL.scalar.await("SELECT TRUE FROM phone_instagram_stories WHERE username = @username AND timestamp > DATE_SUB(NOW(), INTERVAL 24 HOUR)", { 
        ["@username"] = username
    })
    if hasStory then
        return false, L("BACKEND.INSTAGRAM.ALREADY_HAS_STORY")
    end
    
    return true
end

local function EndLive(username, endedBy)
    local live = lives[username]
    if not live then return end
    
    -- Remove from lives
    lives[username] = nil
    
    -- Update all participants
    for i = 1, #live.participants do
        local participant = live.participants[i]
        if lives[participant.username] then
            lives[participant.username] = nil
            if participant.source then
                Player(participant.source).state.instapicIsLive = nil
            end
        end
    end
    
    -- Notify clients
    TriggerClientEvent("phone:instagram:updateLives", -1, lives)
    TriggerClientEvent("phone:instagram:endLive", -1, username, endedBy)
end

local function getActiveNumbersByUsername(username)
    local numbers = {}
    local rows = MySQL.query.await("SELECT phone_number FROM phone_logged_in_accounts WHERE app = 'Instagram' AND `active` = 1 AND username = ?", {username})
    for i = 1, #rows do
        numbers[i] = rows[i].phone_number
    end
    return numbers
end

local function notifyInstagramDevices(username, notification, excludePhoneNumber)
    notification.app = "Instagram"
    local numbers = getActiveNumbersByUsername(username)
    for i = 1, #numbers do
        if numbers[i] ~= excludePhoneNumber then
            SendNotification(numbers[i], notification)
        end
    end
end

-- Profile builder
local function getInstagramProfile(username, loggedInPhone)
    username = username:lower()
    local acc = MySQL.single.await([[SELECT display_name, bio, profile_image, verified, private,
        follower_count, following_count, date_joined FROM phone_instagram_accounts WHERE username = ?]], {username})
    if not acc then return false end

    local result = {
        name = acc.display_name,
        username = username,
        bio = acc.bio,
        verified = acc.verified == true,
        private = acc.private == true,
        profile_picture = acc.profile_image,
        followers = acc.follower_count or 0,
        following = acc.following_count or 0,
        date_joined = acc.date_joined
    }

    local loggedInAs = nil
    if loggedInPhone then
        loggedInAs = GetLoggedInAccount(loggedInPhone, "Instagram")
    end
    if loggedInAs then
        result.isFollowing = MySQL.scalar.await("SELECT TRUE FROM phone_instagram_follows WHERE follower=@f AND followed=@u", { ["@f"] = loggedInAs, ["@u"] = username }) ~= nil
        result.isFollowingYou = MySQL.scalar.await("SELECT TRUE FROM phone_instagram_follows WHERE follower=@u AND followed=@f", { ["@u"] = username, ["@f"] = loggedInAs }) ~= nil
        result.requested = MySQL.scalar.await("SELECT TRUE FROM phone_instagram_follow_requests WHERE requester=@f AND requestee=@u", { ["@f"] = loggedInAs, ["@u"] = username }) ~= nil
    end

    -- stories count viewed by you
    result.storyViews = MySQL.scalar.await([[SELECT COUNT(*) FROM phone_instagram_stories_views WHERE viewer = ? AND story_id IN (SELECT id FROM phone_instagram_stories WHERE username=?)]], { loggedInAs, username }) or 0

    return result
end

-- ========== Account Management ==========
RegisterLegacyCallback("instagram:createAccount", function(source, cb, displayName, username, password)
    local phone = GetEquippedPhoneNumber(source)
    if not phone then return cb({ success = false, error = "UNKNOWN" }) end

    username = username:lower()
    if not IsUsernameValid(username) then
        return cb({ success = false, error = "USERNAME_NOT_ALLOWED" })
    end

    debugprint("INSTAGRAM", "%s wants to create an account", phone)
    
    local exists = MySQL.Sync.fetchScalar("SELECT username FROM phone_instagram_accounts WHERE username=@username", { ["@username"] = username })
    if exists then
        debugprint("INSTAGRAM", "%s tried to create an account with an existing username", phone)
        return cb({ success = false, error = "USERNAME_TAKEN" })
    end

    MySQL.Sync.execute("INSERT INTO phone_instagram_accounts (display_name, username, password, phone_number) VALUES (@displayName, @username, @password, @phonenumber)", {
        ["@displayName"] = displayName,
        ["@username"] = username,
        ["@password"] = GetPasswordHash(password),
        ["@phonenumber"] = phone,
    })

    debugprint("INSTAGRAM", "%s created an account", phone)
    AddLoggedInAccount(phone, "Instagram", username)
    cb({ success = true })

    if Config.AutoFollow and Config.AutoFollow.Enabled and Config.AutoFollow.InstaPic and Config.AutoFollow.InstaPic.Accounts then
        for i = 1, #Config.AutoFollow.InstaPic.Accounts do
            MySQL.update.await("INSERT INTO phone_instagram_follows (followed, follower) VALUES (?, ?)", { Config.AutoFollow.InstaPic.Accounts[i], username })
        end
    end
end, { preventSpam = true, rateLimit = 4 })

RegisterLegacyCallback("instagram:logIn", function(source, cb, username, password)
    local phone = GetEquippedPhoneNumber(source)
    if not phone then return cb({ success = false, error = "UNKNOWN" }) end

    debugprint("INSTAGRAM", "%s wants to log in on account %s", phone, username)
    debugprint("INSTAGRAM", "%s is not logged in, checking if account exists", phone)
    
    username = username:lower()
    MySQL.Async.fetchScalar("SELECT password FROM phone_instagram_accounts WHERE username=@username", { ["@username"] = username }, function(hashed)
        if not hashed then
            debugprint("INSTAGRAM", "%s tried to log in on non-existing account %s", phone, username)
            return cb({ success = false, error = "UNKNOWN_ACCOUNT" })
        end
        
        if not VerifyPasswordHash(password, hashed) then
            debugprint("INSTAGRAM", "%s tried to log in on account %s with wrong password", phone, username)
            return cb({ success = false, error = "INCORRECT_PASSWORD" })
        end
        
        debugprint("INSTAGRAM", "%s logged in on account %s", phone, username)
        AddLoggedInAccount(phone, "Instagram", username)
        
        MySQL.Async.fetchAll([[
            SELECT
                display_name AS name, username, profile_image AS avatar, verified
            FROM phone_instagram_accounts
            WHERE username = @username
        ]], { ["@username"] = username }, function(rows)
            debugprint("INSTAGRAM", "%s got account data", phone)
            cb({ success = true, account = rows and rows[1] })
        end)
    end)
end)

RegisterLegacyCallback("instagram:isLoggedIn", function(source, cb)
    local phone = GetEquippedPhoneNumber(source)
    if not phone then return cb(false) end

    local username = GetLoggedInAccount(phone, "Instagram")
    if not username then return cb(false) end

    local account = MySQL.single.await([[
        SELECT display_name AS `name`, username, profile_image AS avatar, verified
        FROM phone_instagram_accounts
        WHERE username = ?
    ]], { username })
    
    if not account then return cb(false) end  
    
    cb(account)
end)

RegisterLegacyCallback("instagram:signOut", function(source, cb)
    local phone = GetEquippedPhoneNumber(source)
    if not phone then return cb(false) end
    
    local username = GetLoggedInAccount(phone, "Instagram")
    if not username then return cb(false) end
    
    RemoveLoggedInAccount(phone, "Instagram", username)
    cb(true)
end)

RegisterLegacyCallback("instagram:getProfile", function(source, cb, target)
    local me = getLoggedInInstagramAccount(source)
    if not me then return cb(false) end
    
    MySQL.Async.fetchAll([[
        SELECT display_name AS name, username, profile_image AS avatar, bio, verified, private, follower_count as followers, following_count as following, post_count as posts,
            (
                IF((SELECT TRUE FROM phone_instagram_follows f WHERE f.followed=@username AND f.follower=@loggedInAs), TRUE, FALSE)
            ) AS isFollowing,
            (
                IF((SELECT TRUE FROM phone_instagram_follow_requests fr WHERE fr.requester=@loggedInAs AND fr.requestee=@username), TRUE, FALSE)
            ) AS requested,

            (SELECT a.story_count > 0) AS hasStory,
            (SELECT a.story_count = (
                SELECT COUNT(*) FROM phone_instagram_stories_views
                WHERE viewer=@loggedInAs
                    AND story_id IN (SELECT id FROM phone_instagram_stories WHERE username=@username)
            )) AS seenStory

        FROM phone_instagram_accounts a

        WHERE a.username=@username
    ]], {
        ["@username"] = target,
        ["@loggedInAs"] = me
    }, function(rows)
        local account = rows and rows[1]
        if account then
            account.isLive = lives[target] and true or false
        end
        cb(account or false)
    end)
end)

-- changePassword / deleteAccount
createAuthenticatedInstagramCallback("changePassword", function(source, phoneNumber, account, oldPassword, newPassword)
    if not (Config.ChangePassword and Config.ChangePassword.InstaPic) then
        infoprint("warning", ("%s tried to change password on InstaPic, but it's not enabled in the config."):format(source))
        return false
    end
    
    if oldPassword == newPassword or #tostring(newPassword) < 3 then
        debugprint("same password / too short")
        return false
    end
    
    if lives[account] then
        debugprint("Can't change password when live")
        return false
    end
    
    local current = MySQL.scalar.await("SELECT password FROM phone_instagram_accounts WHERE username = ?", { account })
    if not current or not VerifyPasswordHash(oldPassword, current) then return false end
    
    local ok = MySQL.update.await("UPDATE phone_instagram_accounts SET password = ? WHERE username = ?", { GetPasswordHash(newPassword), account }) > 0
    if not ok then return false end

    notifyInstagramDevices(account, { 
        title = L("BACKEND.MISC.LOGGED_OUT_PASSWORD.TITLE"), 
        content = L("BACKEND.MISC.LOGGED_OUT_PASSWORD.DESCRIPTION") 
    }, phoneNumber)
    
    MySQL.update.await("DELETE FROM phone_logged_in_accounts WHERE username = ? AND app = 'Instagram' AND phone_number != ?", { account, phoneNumber })
    ClearActiveAccountsCache("Instagram", account, phoneNumber)
    
    Log("InstaPic", source, "info", L("BACKEND.LOGS.CHANGED_PASSWORD.TITLE"), L("BACKEND.LOGS.CHANGED_PASSWORD.DESCRIPTION", { 
        number = phoneNumber, 
        username = account, 
        app = "InstaPic" 
    }))
    
    TriggerClientEvent("phone:logoutFromApp", -1, { 
        username = account, 
        app = "instagram", 
        reason = "password", 
        number = phoneNumber 
    })
    return true
end, false)

createAuthenticatedInstagramCallback("deleteAccount", function(source, phoneNumber, account, password)
    if not (Config.DeleteAccount and Config.DeleteAccount.InstaPic) then
        infoprint("warning", ("%s tried to delete their account on InstaPic, but it's not enabled in the config."):format(source))
        return false
    end
    
    if lives[account] then
        debugprint("Can't delete account when live")
        return false
    end
    
    local current = MySQL.scalar.await("SELECT password FROM phone_instagram_accounts WHERE username = ?", { account })
    if not current or not VerifyPasswordHash(password, current) then return false end
    
    local ok = MySQL.update.await("DELETE FROM phone_instagram_accounts WHERE username = ?", { account }) > 0
    if not ok then return false end

    notifyInstagramDevices(account, { 
        title = L("BACKEND.MISC.DELETED_NOTIFICATION.TITLE"), 
        content = L("BACKEND.MISC.DELETED_NOTIFICATION.DESCRIPTION") 
    })
    
    MySQL.update.await("DELETE FROM phone_logged_in_accounts WHERE username = ? AND app = 'Instagram'", { account })
    ClearActiveAccountsCache("Instagram", account)
    
    Log("InstaPic", source, "info", L("BACKEND.LOGS.DELETED_ACCOUNT.TITLE"), L("BACKEND.LOGS.DELETED_ACCOUNT.DESCRIPTION", { 
        number = phoneNumber, 
        username = account, 
        app = "InstaPic" 
    }))
    
    TriggerClientEvent("phone:logoutFromApp", -1, { 
        username = account, 
        app = "instagram", 
        reason = "deleted" 
    })
    return true
end, false)

-- ========== Posts ==========
local function sendInstagramNotification(toUser, fromUser, notifType, postId)
    if toUser == fromUser then return end
    -- Dedup
    local base = "SELECT TRUE FROM phone_instagram_notifications WHERE username=@username AND `from`=@from AND `type`=@type"
    if notifType ~= "follow" then base = base .. " AND post_id=@post" end
    local exists = MySQL.Sync.fetchScalar(base, { ["@username"] = toUser, ["@from"] = fromUser, ["@type"] = notifType, ["@post"] = postId })
    if exists then return end

    MySQL.Async.execute("INSERT INTO phone_instagram_notifications (id, username, `from`, `type`, post_id) VALUES (@id, @username, @from, @type, @postId)", {
        ["@id"] = GenerateId("phone_instagram_notifications", "id"),
        ["@username"] = toUser,
        ["@from"] = fromUser,
        ["@type"] = notifType,
        ["@postId"] = postId
    })

    -- Optionally include first media as thumbnail in notification
    local thumb = MySQL.Sync.fetchScalar([[SELECT TRIM(BOTH '"' FROM JSON_EXTRACT(media, '$[0]')) FROM phone_instagram_posts WHERE id=@id]], { ["@id"] = postId })
    notifyInstagramDevices(toUser, { title = L("BACKEND.INSTAGRAM." .. notifType:upper(), { username = fromUser }), thumbnail = thumb })
end

createAuthenticatedInstagramCallback("createPost", function(source, phoneNumber, account, mediaJson, caption, location)
    if ContainsBlacklistedWord(source, "InstaPic", caption or "") then return false end
    local id = GenerateId("phone_instagram_posts", "id")
    MySQL.Sync.execute("INSERT INTO phone_instagram_posts (id, username, media, caption, location) VALUES (@id, @username, @media, @caption, @location)", {
        ["@id"] = id, 
        ["@username"] = account, 
        ["@media"] = mediaJson, 
        ["@caption"] = caption, 
        ["@location"] = location
    })

    -- Trigger events
    local postData = {
        username = account,
        media = mediaJson,
        caption = caption,
        location = location,
        id = id
    }
    TriggerClientEvent("phone:instagram:newPost", -1, postData)
    TriggerEvent("lb-phone:instapic:newPost", postData)

    -- Log post details
    local mediaArray = json.decode(mediaJson) or {}
    local logMessage = "**Caption**: " .. (caption or "") .. "\n\n**Photos**:\n"
    for i = 1, #mediaArray do
        logMessage = logMessage .. string.format("[Photo %s](%s)\n", i, mediaArray[i])
    end
    logMessage = logMessage .. "**ID:** " .. id
    
    Log("InstaPic", source, "info", "New post", logMessage)
    TrackSocialMediaPost("instapic", mediaArray)

    -- Webhook
    if Config.Post and Config.Post.InstaPic and INSTAPIC_WEBHOOK and string.sub(INSTAPIC_WEBHOOK, -14) == "/api/webhooks/" then
        local avatar = MySQL.Sync.fetchScalar("SELECT profile_image FROM phone_instagram_accounts WHERE username=@username", { ["@username"] = account })
        PerformHttpRequest(INSTAPIC_WEBHOOK, function() end, "POST", json.encode({
            username = (Config.Post.Accounts and Config.Post.Accounts.InstaPic and Config.Post.Accounts.InstaPic.Username) or "InstaPic",
            avatar_url = (Config.Post.Accounts and Config.Post.Accounts.InstaPic and Config.Post.Accounts.InstaPic.Avatar) or "https://loaf-scripts.com/fivem/lb-phone/icons/InstaPic.png",
            embeds = {{
                title = L("APPS.INSTAGRAM.NEW_POST"),
                description = caption and #caption > 0 and caption or nil,
                color = 9059001,
                timestamp = GetTimestampISO(),
                author = { 
                    name = "@" .. account, 
                    icon_url = avatar or "https://cdn.discordapp.com/embed/avatars/5.png" 
                },
                image = { url = mediaArray[1] },
                footer = { text = "LB Phone", icon_url = "https://docs.lbscripts.com/images/icons/icon.png" }
            }}
        }), { ["Content-Type"] = "application/json" })
    end

    return true
end, nil, { preventSpam = true, rateLimit = 6 })

RegisterLegacyCallback("instagram:deletePost", function(source, cb, id)
    local username = getLoggedInInstagramAccount(source)
    if not username then return cb(false) end

    local isAdmin = IsAdmin and IsAdmin(source)
    local owns = MySQL.Sync.fetchScalar("SELECT TRUE FROM phone_instagram_posts WHERE id=@id AND username=@username", { 
        ["@id"] = id, 
        ["@username"] = username 
    })
    if not (owns or isAdmin) then return cb(false) end

    local params = { ["@id"] = id }
    MySQL.Sync.execute("DELETE FROM phone_instagram_likes WHERE id=@id", params)
    MySQL.Sync.execute("DELETE FROM phone_instagram_notifications WHERE post_id=@id", params)
    MySQL.Sync.execute("DELETE FROM phone_instagram_comments WHERE post_id=@id", params)
    local deleted = MySQL.Sync.execute("DELETE FROM phone_instagram_posts WHERE id=@id", params) > 0
    
    if deleted then
        Log("InstaPic", source, "error", "Deleted post", "**ID**: " .. id)
    end
    
    cb(deleted)
end)

RegisterLegacyCallback("instagram:getPost", function(source, cb, id)
    local loggedInAs = getLoggedInInstagramAccount(source)
    if not loggedInAs then return cb(false) end

    MySQL.Async.fetchAll([[
        SELECT
            p.id, p.media, p.caption, p.username, p.timestamp, p.like_count, p.comment_count, p.location,

            a.verified, a.profile_image AS avatar,

            (IF((
                SELECT TRUE FROM phone_instagram_likes l
                WHERE l.id=p.id AND l.username=@loggedInAs AND l.is_comment=FALSE
            ), TRUE, FALSE)) AS liked

        FROM phone_instagram_posts p

        INNER JOIN phone_instagram_accounts a
            ON p.username = a.username

        WHERE p.id=@id
    ]], {
        ["@id"] = id,
        ["@loggedInAs"] = loggedInAs
    }, function(rows)
        local row = rows and rows[1]
    if not row then return cb(false) end
    cb(row)
    end)
end)

RegisterLegacyCallback("instagram:getPosts", function(source, cb, filters, page)
    local loggedInAs = getLoggedInInstagramAccount(source)
    if not loggedInAs then return cb({}) end
    filters = filters or {}

    local whereClause = ""
    local orderClause = "p.timestamp DESC"
    
    if filters.following then
        whereClause = [[
            JOIN phone_instagram_follows f
            WHERE f.follower=@loggedInAs
                AND f.followed=p.username
        ]]
    elseif filters.profile then
        whereClause = "WHERE p.username=@username"
    else
        whereClause = [[
            WHERE a.private=FALSE
        ]]
    end

    local sql = ([[
        SELECT
            p.id, p.media, p.caption, p.username, p.timestamp, p.like_count, p.comment_count, p.location,

            a.verified, a.profile_image AS avatar,

            (IF((
                SELECT TRUE FROM phone_instagram_likes l
                WHERE l.id=p.id AND l.username=@loggedInAs AND l.is_comment=FALSE
            ), TRUE, FALSE)) AS liked

        FROM phone_instagram_posts p

        INNER JOIN phone_instagram_accounts a
            ON p.username = a.username

        %s

        ORDER BY %s

        LIMIT @page, @perPage
    ]]):format(whereClause, orderClause)

    MySQL.Async.fetchAll(sql, {
        ["@loggedInAs"] = loggedInAs,
        ["@username"] = filters.username,
        ["@page"] = (page or 0) * 15,
        ["@perPage"] = 15
    }, cb)
end)

-- ========== Comments & Likes ==========
RegisterLegacyCallback("instagram:getComments", function(source, cb, postId, page)
    local me = getLoggedInInstagramAccount(source)
    if not me then return cb({}) end
    MySQL.Async.fetchAll([[
        SELECT
            c.id, c.comment, c.`timestamp`, c.like_count,
            a.username, a.profile_image, a.verified,

            (IF((
                SELECT TRUE FROM phone_instagram_likes l
                WHERE l.id=c.id AND l.username=@loggedInAs AND l.is_comment=TRUE
            ), TRUE, FALSE)) AS liked,

            (IF((
                SELECT TRUE FROM phone_instagram_follows f
                WHERE f.follower=@loggedInAs AND f.followed=a.username
            ), TRUE, FALSE)) AS following

        FROM phone_instagram_comments c

        INNER JOIN phone_instagram_accounts a
            ON c.username = a.username

        WHERE c.post_id=@postId

        ORDER BY following DESC, c.like_count DESC, c.`timestamp` DESC

        LIMIT @page, @perPage
    ]], {
        ["@loggedInAs"] = me, 
        ["@postId"] = postId, 
        ["@page"] = (page or 0) * 20, 
        ["@perPage"] = 20
    }, cb)
end)

createAuthenticatedInstagramCallback("postComment", function(source, _, account, postId, content)
    if ContainsBlacklistedWord(source, "InstaPic", content or "") then return false end
    local id = GenerateId("phone_instagram_comments", "id")
    MySQL.Async.execute("INSERT INTO phone_instagram_comments (id, post_id, username, comment) VALUES (@id, @postId, @username, @comment)", {
        ["@id"] = id, 
        ["@postId"] = postId, 
        ["@username"] = account, 
        ["@comment"] = content
    }, function(affected)
        if affected == 0 then return end
        
        MySQL.Async.fetchScalar("SELECT username FROM phone_instagram_posts WHERE id=@id", { ["@id"] = postId }, function(owner)
            if owner then
                sendInstagramNotification(owner, account, "comment", id)
            end
        end)
        
        TriggerClientEvent("phone:instagram:updatePostData", -1, postId, "comment_count", true)
        return id
    end)
end, nil, { preventSpam = true, rateLimit = 10 })

RegisterLegacyCallback("instagram:toggleLike", function(source, cb, postId, enabled, isComment)
    if not postId then return cb(false) end
    
    local me = getLoggedInInstagramAccount(source)
    if not me then return cb(false) end

    local function onComplete(affected)
        if affected == 0 then return cb(enabled) end
        
        cb(enabled)
        
        if isComment then
            TriggerClientEvent("phone:instagram:updateCommentLikes", -1, postId, enabled)
        else
            TriggerClientEvent("phone:instagram:updatePostData", -1, postId, "like_count", enabled)
        end
        
        if enabled then
            local tableName = isComment and "phone_instagram_comments" or "phone_instagram_posts"
            MySQL.Async.fetchScalar("SELECT username FROM " .. tableName .. " WHERE id=@postId", { ["@postId"] = postId }, function(owner)
                if owner then
                    local notifType = "like_" .. (isComment and "comment" or "photo")
                    sendInstagramNotification(owner, me, notifType, postId)
                end
            end)
        end
    end

    if enabled then
        MySQL.Async.execute("INSERT IGNORE INTO phone_instagram_likes (id, username, is_comment) VALUES (@postId, @loggedInAs, @isComment)", { 
            ["@postId"] = postId, 
            ["@loggedInAs"] = me, 
            ["@isComment"] = isComment 
        }, onComplete)
    else
        MySQL.Async.execute("DELETE FROM phone_instagram_likes WHERE id=@postId AND username=@loggedInAs AND is_comment=@isComment", { 
            ["@postId"] = postId, 
            ["@loggedInAs"] = me, 
            ["@isComment"] = isComment 
        }, onComplete)
    end
end)

-- ========== Social (Follow/Followers & Data) ==========
RegisterLegacyCallback("instagram:getData", function(source, cb, kind, data)
    local me = getLoggedInInstagramAccount(source)
    if not me then return cb({}) end

    local tableName, joinCol, whereClause, orderCol = "", "", "", ""

    if kind == "likes" then
        tableName = "phone_instagram_likes"
        joinCol = "username"
        whereClause = "id=@postId AND is_comment=@isComment"
        orderCol = "a.username"
    elseif kind == "followers" then
        tableName = "phone_instagram_follows"
        joinCol = "follower"
        whereClause = "q.followed=@username"
        orderCol = "q.follower"
    elseif kind == "following" then
        tableName = "phone_instagram_follows"
        joinCol = "followed"
        whereClause = "q.follower=@username"
        orderCol = "q.followed"
    end

    local sql = ([[SELECT a.username, a.display_name AS name, a.profile_image AS avatar, a.verified,
        (IF((
            SELECT TRUE FROM phone_instagram_follows f
            WHERE f.followed=a.username AND f.follower=@loggedInAs
        ), TRUE, FALSE)) AS isFollowing
        FROM phone_instagram_accounts a
        INNER JOIN %s q ON q.%s=a.username
        WHERE %s
        ORDER BY %s DESC
        LIMIT @page, @perPage]]):format(tableName, joinCol, whereClause, orderCol)

    MySQL.Async.fetchAll(sql, {
        ["@username"] = data.username,
        ["@postId"] = data.postId,
        ["@isComment"] = data.isComment == true,
        ["@loggedInAs"] = me,
        ["@page"] = (data.page or 0) * 20,
        ["@perPage"] = 20
    }, cb)
end)

RegisterLegacyCallback("instagram:toggleFollow", function(source, cb, target, enabled)
    local me = getLoggedInInstagramAccount(source)
    if not me or me == target then return cb(not enabled) end

    local function onComplete(affected)
        if affected == 0 then return cb(enabled) end
        
        TriggerClientEvent("phone:instagram:updateProfileData", -1, target, "followers", enabled)
        TriggerClientEvent("phone:instagram:updateProfileData", -1, me, "following", enabled)
        if enabled then
            sendInstagramNotification(target, me, "follow")
        end
        cb(enabled)
    end

    local params = {
        ["@username"] = target,
        ["@loggedInAs"] = me
    }
    
    local isPrivate = MySQL.Sync.fetchScalar("SELECT private FROM phone_instagram_accounts WHERE username=@username", params)

    if isPrivate then
        if enabled then
            MySQL.Async.execute("INSERT IGNORE INTO phone_instagram_follow_requests (requester, requestee) VALUES (@loggedInAs, @username)", params, function(affected)
                cb(enabled)
                if affected == 0 then return end
                
                local displayName = MySQL.Sync.fetchScalar("SELECT display_name FROM phone_instagram_accounts WHERE username=@loggedInAs", { ["@loggedInAs"] = me })
                local numbers = getActiveNumbersByUsername(target)
                for i = 1, #numbers do
                    SendNotification(numbers[i], {
                        app = "Instagram",
                        title = L("BACKEND.INSTAGRAM.NEW_FOLLOW_REQUEST_TITLE"),
                        content = L("BACKEND.INSTAGRAM.NEW_FOLLOW_REQUEST_DESCRIPTION", { 
                            displayName = displayName, 
                            username = me 
                        })
                    })
                end
            end)
            return
        else
            MySQL.Async.execute("DELETE FROM phone_instagram_follow_requests WHERE requester=@loggedInAs AND requestee=@username", params)
        end
    end

    local sql = enabled and "INSERT IGNORE INTO phone_instagram_follows (followed, follower) VALUES (@username, @loggedInAs)" or "DELETE FROM phone_instagram_follows WHERE followed=@username AND follower=@loggedInAs"
    MySQL.Async.execute(sql, params, onComplete)
end)

RegisterLegacyCallback("instagram:getFollowRequests", function(source, cb, page)
    local me = getLoggedInInstagramAccount(source)
    if not me then return cb({}) end
    MySQL.Async.fetchAll([[
        SELECT a.username, a.display_name AS `name`, a.profile_image AS avatar, a.verified
        FROM phone_instagram_follow_requests r
        INNER JOIN phone_instagram_accounts a
            ON a.username = r.requester
        WHERE r.requestee=@loggedInAs
        ORDER BY r.`timestamp` DESC
        LIMIT @page, @perPage
    ]], {
        ["@loggedInAs"] = me, 
        ["@page"] = (page or 0) * 15, 
        ["@perPage"] = 15
    }, cb)
end)

RegisterLegacyCallback("instagram:handleFollowRequest", function(source, cb, requester, accept)
    local me = getLoggedInInstagramAccount(source)
    if not me then return cb(false) end

    local params = {
        ["@loggedInAs"] = me,
        ["@username"] = requester
    }
    
    local removed = MySQL.Sync.execute("DELETE FROM phone_instagram_follow_requests WHERE requestee=@loggedInAs AND requester=@username", params)
    if removed == 0 then return cb(false) end
    if not accept then return cb(true) end

    MySQL.Sync.execute("INSERT IGNORE INTO phone_instagram_follows (follower, followed) VALUES (@username, @loggedInAs)", params)
    TriggerClientEvent("phone:instagram:updateProfileData", -1, me, "followers", true)
    TriggerClientEvent("phone:instagram:updateProfileData", -1, requester, "following", true)
    
    -- Get display name for notification
    local displayName = MySQL.Sync.fetchScalar("SELECT display_name FROM phone_instagram_accounts WHERE username=@loggedInAs", { ["@loggedInAs"] = me })
    if displayName then
        local numbers = getActiveNumbersByUsername(requester)
        for i = 1, #numbers do
            SendNotification(numbers[i], {
                app = "Instagram",
                title = L("BACKEND.INSTAGRAM.FOLLOW_REQUEST_ACCEPTED_TITLE"),
                content = L("BACKEND.INSTAGRAM.FOLLOW_REQUEST_ACCEPTED_DESCRIPTION", { 
                    displayName = displayName, 
                    username = me 
                })
            })
        end
    end
    
    cb(true)
end)

-- ========== Notifications ==========
RegisterLegacyCallback("instagram:getNotifications", function(source, cb, page)
    local me = getLoggedInInstagramAccount(source)
    if not me then return cb({ notifications = {}, requests = { recent = {}, total = 0 } }) end

    local rows = MySQL.Sync.fetchAll([[
        SELECT
            (
                SELECT CASE WHEN f.followed IS NULL THEN FALSE ELSE TRUE END
                    FROM phone_instagram_follows f
                    WHERE f.follower=@username AND f.followed=n.`from`
            ) AS isFollowing,
            -- notification data
            n.`from` AS username,
            n.`type`,
            n.`timestamp`,
            -- post photo
            TRIM(BOTH '"' FROM JSON_EXTRACT(p.media, '$[0]')) AS photo,
            p.id AS postId,
            -- comment text
            c.`comment`,
            c.id AS commentId,
            -- account data
            a.profile_image AS avatar,
            a.verified

        FROM phone_instagram_notifications n

        LEFT JOIN phone_instagram_comments c
            ON n.post_id = c.id

        LEFT JOIN phone_instagram_posts p
            ON p.id = (CASE
                WHEN n.`type`="like_photo"
                THEN n.post_id

                WHEN n.`type`="comment"
                THEN c.post_id

                WHEN n.`type`="like_comment"
                THEN c.post_id

                ELSE NULL
                END
            )

        LEFT JOIN phone_instagram_accounts a
            ON a.username=n.`from`

        WHERE n.username=@username

        ORDER BY n.`timestamp` DESC

        LIMIT @page, @perPage
    ]], { 
        ["@username"] = me, 
        ["@page"] = (page or 0) * 15, 
        ["@perPage"] = 15 
    }) or {}

    local requestData = { recent = {}, total = 0 }
    if (page or 0) == 0 then
        local recentRequests = MySQL.Sync.fetchAll([[
            SELECT a.username, a.profile_image AS avatar
            FROM phone_instagram_follow_requests r
            INNER JOIN phone_instagram_accounts a
                ON a.username = r.requester
            WHERE r.requestee=@username
            ORDER BY r.`timestamp` DESC
            LIMIT 2
        ]], { ["@username"] = me }) or {}
        
        local totalRequests = MySQL.Sync.fetchScalar("SELECT COUNT(1) FROM phone_instagram_follow_requests WHERE requestee=@username", { ["@username"] = me }) or 0
        
        requestData = { recent = recentRequests, total = totalRequests }
    end

    cb({ notifications = rows, requests = requestData })
end)

-- ========== Messaging ==========
RegisterLegacyCallback("instagram:getRecentMessages", function(source, cb, page)
    local me = getLoggedInInstagramAccount(source)
    if not me then return cb({}) end
    MySQL.Async.fetchAll([[SELECT m.content, m.attachments, m.sender, f_m.username, m.`timestamp`, a.display_name AS name, a.profile_image AS profile_picture, a.verified
        FROM phone_instagram_messages m JOIN ((SELECT (CASE WHEN recipient!=@me THEN recipient ELSE sender END) AS username, MAX(`timestamp`) AS `timestamp` FROM phone_instagram_messages WHERE sender=@me OR recipient=@me GROUP BY username) f_m)
            ON m.`timestamp`=f_m.`timestamp`
        INNER JOIN phone_instagram_accounts a ON a.username=f_m.username
        WHERE m.sender=@me OR m.recipient=@me GROUP BY f_m.username ORDER BY m.`timestamp` DESC LIMIT @page, @perPage]], { ["@me"] = me, ["@page"] = (page or 0) * 15, ["@perPage"] = 15 }, cb)
end)

RegisterLegacyCallback("instagram:getMessages", function(source, cb, username, page)
    local me = getLoggedInInstagramAccount(source)
    if not me then return cb({}) end
    MySQL.Async.fetchAll([[SELECT sender, recipient, content, attachments, `timestamp` FROM phone_instagram_messages WHERE (sender=@me AND recipient=@u) OR (sender=@u AND recipient=@me) ORDER BY `timestamp` DESC LIMIT @page, @perPage]], {
        ["@me"] = me, ["@u"] = username, ["@page"] = (page or 0) * 25, ["@perPage"] = 25
    }, cb)
end)

createAuthenticatedInstagramCallback("sendMessage", function(source, _, me, recipient, messageData)
    if ContainsBlacklistedWord(source, "InstaPic", messageData.content or "") then return false end
    local id = GenerateId("phone_instagram_messages", "id")
    local attachments = messageData.attachments and json.encode(messageData.attachments) or nil
    local ok = MySQL.update.await("INSERT INTO phone_instagram_messages (id, sender, recipient, content, attachments) VALUES (@id, @s, @r, @c, @att)", { 
        ["@id"] = id, 
        ["@s"] = me, 
        ["@r"] = recipient, 
        ["@c"] = messageData.content,
        ["@att"] = attachments
    }) > 0
    if not ok then return false end

    -- Get sender info for notifications
    local senderInfo = MySQL.single.await("SELECT display_name, username, profile_image FROM phone_instagram_accounts WHERE username = ?", { me })
    if not senderInfo then return false end

    -- Push to recipient devices
    local numbers = getActiveNumbersByUsername(recipient)
    for i = 1, #numbers do
        local src = GetSourceFromNumber(numbers[i])
        if src then
            TriggerClientEvent("phone:instagram:newMessage", src, { 
                sender = me, 
                recipient = recipient, 
                content = messageData.content, 
                attachments = messageData.attachments, 
                timestamp = os.time() * 1000 
            })
        end
        
        -- Check for story reply
        local notificationContent = messageData.content
        if string.find(messageData.content, "<!REPLIED_STORY-DATA=") then
            notificationContent = L("APPS.INSTAGRAM.REPLIED_TO_YOUR_STORY")
        end
        
        SendNotification(numbers[i], { 
            app = "Instagram", 
            title = senderInfo.display_name, 
            content = notificationContent,
            thumbnail = messageData.attachments and messageData.attachments[1] or nil,
            avatar = senderInfo.profile_image,
            showAvatar = true
        })
    end

    return true
end, nil, { preventSpam = true, rateLimit = 15 })

-- ========== Profile Management ==========
createAuthenticatedInstagramCallback("updateProfile", function(source, phoneNumber, account, profileData)
    local updates = {}
    if profileData.name then
        updates[#updates + 1] = "display_name=@displayName"
    end
    if profileData.bio then
        updates[#updates + 1] = "bio=@bio"
    end
    if profileData.avatar then
        updates[#updates + 1] = "profile_image=@avatar"
    end
    if type(profileData.private) == "boolean" then
        updates[#updates + 1] = "private=@private"
    end
    
    if #updates == 0 then return false end
    
    local updateStr = table.concat(updates, ",")
    local sql = "UPDATE phone_instagram_accounts SET " .. updateStr .. " WHERE username=@username"
    
    MySQL.Async.execute(sql, {
        ["@displayName"] = profileData.name,
        ["@bio"] = profileData.bio,
        ["@avatar"] = profileData.avatar,
        ["@username"] = account,
        ["@private"] = profileData.private
    }, function(affected)
        return affected > 0
    end)
end, false)

-- ========== Search ==========
RegisterLegacyCallback("instagram:search", function(_, cb, query)
    MySQL.Async.fetchAll([[SELECT display_name, username, profile_image, verified, private FROM phone_instagram_accounts WHERE username LIKE CONCAT(@q, "%") OR display_name LIKE CONCAT("%", @q, "%")]], { ["@q"] = query }, cb)
end)

-- ========== Live ==========
local lives = {}

RegisterLegacyCallback("instagram:getLives", function(source, cb)
    local me = getLoggedInInstagramAccount(source)
    if not me then return cb({}) end

    local visible = {}
    for username, data in pairs(lives) do
        if data.private then
            local follows = MySQL.Sync.fetchScalar("SELECT TRUE FROM phone_instagram_follows WHERE follower=@f AND followed=@u", { ["@f"] = me, ["@u"] = username })
            if follows then
                visible[username] = data
            end
        else
            visible[username] = data
        end
    end

    cb(visible)
end)

RegisterLegacyCallback("instagram:getLiveViewers", function(_, cb, username)
    local live = lives[username]
    if not live then return cb({}) end

    local viewers = live.viewers or {}
    local results = {}
    for i = 1, #viewers do
        local number = GetEquippedPhoneNumber(viewers[i])
        if number then
            local rows = MySQL.Sync.fetchAll([[SELECT a.profile_image AS avatar, a.verified, a.display_name AS `name`, a.username
                FROM phone_logged_in_accounts l INNER JOIN phone_instagram_accounts a ON l.username = a.username
                WHERE l.phone_number = ? AND l.active = 1 AND l.app = 'Instagram']], { number })
            if rows and rows[1] then
                results[#results + 1] = rows[1]
            end
        end
    end

    cb(results)
end)

RegisterLegacyCallback("instagram:canGoLive", function(source, cb)
    local me = getLoggedInInstagramAccount(source)
    if not me then return cb(false) end

    local allowed, reason = CanGoLive(source, me)
    if not allowed then
        local number = GetEquippedPhoneNumber(source)
        if number then
            SendNotification(number, { app = "Instagram", title = reason or L("BACKEND.INSTAGRAM.NOT_ALLOWED_LIVE") })
        end
    end
    cb(allowed)
end)

RegisterLegacyCallback("instagram:getLives", function(source, cb)
    local me = getLoggedInInstagramAccount(source)
    if not me then return cb({}) end
    
    local result = {}
    for username, live in pairs(lives) do
        if not live.private then
            result[username] = live
        else
            local follows = MySQL.scalar.await("SELECT TRUE FROM phone_instagram_follows WHERE follower=@follower AND followed=@followed", { 
                ["@follower"] = me, 
                ["@followed"] = username 
            })
            if follows then
                result[username] = live
            end
        end
    end
    cb(result)
end)

RegisterLegacyCallback("instagram:canCreateStory", function(source, cb)
    local me = getLoggedInInstagramAccount(source)
    if not me then return cb(false) end

    local allowed, reason = CanCreateStory(source, me)
    if not allowed then
        local number = GetEquippedPhoneNumber(source)
        if number then
            SendNotification(number, { app = "Instagram", title = reason or L("BACKEND.INSTAGRAM.NOT_ALLOWED_STORY") })
        end
    end
    cb(allowed)
end)

RegisterLegacyCallback("instagram:addToStory", function(source, cb, media, metadata)
    local me = getLoggedInInstagramAccount(source)
    if not me then return cb(false) end
    
    local allowed = CanCreateStory(source, me)
    if not allowed then return cb(false) end
    
    local id = GenerateId("phone_instagram_stories", "id")
    
    MySQL.update.await([[
        INSERT INTO phone_instagram_stories (id, username, image, metadata)
        VALUES (@id, @username, @image, @metadata)
    ]], {
        ["@id"] = id,
        ["@username"] = me,
        ["@image"] = media,
        ["@metadata"] = metadata
    })
    
    cb(true)
end)

RegisterLegacyCallback("instagram:removeFromStory", function(source, cb, id)
    local me = getLoggedInInstagramAccount(source)
    if not me then return cb(false) end
    
    local deleted = MySQL.update.await("DELETE FROM phone_instagram_stories WHERE id = @id AND username = @username", {
        ["@id"] = id,
        ["@username"] = me
    }) > 0
    
    cb(deleted)
end)

RegisterLegacyCallback("instagram:getStories", function(source, cb)
    local me = getLoggedInInstagramAccount(source)
    if not me then return cb({}) end
    
    MySQL.Async.fetchAll([[
        SELECT s.id, s.username, s.image, s.metadata, s.timestamp,
            a.display_name, a.profile_image, a.verified
        FROM phone_instagram_stories s
        INNER JOIN phone_instagram_accounts a ON a.username = s.username
        WHERE s.timestamp > DATE_SUB(NOW(), INTERVAL 24 HOUR)
        ORDER BY s.timestamp DESC
    ]], {}, cb)
end)

RegisterLegacyCallback("instagram:getStory", function(source, cb, username)
    local me = getLoggedInInstagramAccount(source)
    if not me then return cb({}) end
    
    MySQL.Async.fetchAll([[
        SELECT s.id, s.username, s.image, s.metadata, s.timestamp,
            a.display_name, a.profile_image, a.verified
        FROM phone_instagram_stories s
        INNER JOIN phone_instagram_accounts a ON a.username = s.username
        WHERE s.username = @username AND s.timestamp > DATE_SUB(NOW(), INTERVAL 24 HOUR)
        ORDER BY s.timestamp DESC
    ]], { ["@username"] = username }, cb)
end)

RegisterLegacyCallback("instagram:getViewers", function(source, cb, id, page)
    local me = getLoggedInInstagramAccount(source)
    if not me then return cb({}) end
    
    MySQL.Async.fetchAll([[
        SELECT v.viewer as username, v.timestamp as viewed_at,
            a.display_name, a.profile_image, a.verified
        FROM phone_instagram_stories_views v
        INNER JOIN phone_instagram_accounts a ON a.username = v.viewer
        WHERE v.story_id = @id
        ORDER BY v.timestamp DESC
        LIMIT @page, @perPage
    ]], {
        ["@id"] = id,
        ["@page"] = (page or 0) * 15,
        ["@perPage"] = 15
    }, cb)
end)

RegisterLegacyCallback("instagram:viewedStory", function(source, cb, id)
    local me = getLoggedInInstagramAccount(source)
    if not me then return cb(false) end
    
    -- Check if already viewed
    local alreadyViewed = MySQL.scalar.await("SELECT TRUE FROM phone_instagram_stories_views WHERE story_id = @id AND viewer = @viewer", {
        ["@id"] = id,
        ["@viewer"] = me
    })
    
    if not alreadyViewed then
        MySQL.update.await("INSERT INTO phone_instagram_stories_views (story_id, viewer) VALUES (@id, @viewer)", {
            ["@id"] = id,
            ["@viewer"] = me
        })
    end
    
    cb(true)
end)

RegisterLegacyCallback("instagram:viewLive", function(source, cb, username)
    local me = getLoggedInInstagramAccount(source)
    if not me then return cb(false) end
    
    local live = lives[username]
    if not live then return cb(false) end
    
    -- Check privacy
    if live.private then
        local follows = MySQL.scalar.await("SELECT TRUE FROM phone_instagram_follows WHERE follower=@follower AND followed=@followed", { 
            ["@follower"] = me, 
            ["@followed"] = username 
        })
        if not follows then return cb(false) end
    end
    
    -- Add viewer
    local alreadyViewing = false
    for i = 1, #live.viewers do
        if live.viewers[i] == source then
            alreadyViewing = true
            break
        end
    end
    
    if not alreadyViewing then
        live.viewers[#live.viewers + 1] = source
    end
    
    cb({
        id = live.id,
        username = username,
        title = live.title or "Live Stream",
        host = live.host,
        participants = live.participants,
        viewers = live.viewers
    })
end)

RegisterLegacyCallback("instagram:stopViewing", function(source, cb, username)
    local me = getLoggedInInstagramAccount(source)
    if not me then return cb(false) end
    
    local live = lives[username]
    if not live then return cb(false) end
    
    for i = #live.viewers, 1, -1 do
        if live.viewers[i] == source then
            table.remove(live.viewers, i)
            break
        end
    end
    
    cb(true)
end)

RegisterLegacyCallback("instagram:joinLive", function(source, cb, username, streamId)
    local me = getLoggedInInstagramAccount(source)
    if not me then return cb(false) end
    
    local live = lives[username]
    if not live or not live.participants then return cb(false) end
    
    -- Check if already live
    if lives[me] then return cb(false) end
    
    -- Check if invited
    if live.invites and live.invites[me] then
        live.invites[me] = nil
    end
    
    -- Check participant limit
    if #live.participants >= 3 then return cb(false) end
    
    -- Check if already participating
    for i = 1, #live.participants do
        if live.participants[i].username == me then
            return cb(false)
        end
    end
    
    local acc = MySQL.single.await("SELECT profile_image, verified, display_name FROM phone_instagram_accounts WHERE username=@username", { ["@username"] = me })
    if not acc then return cb(false) end
    
    -- Add participant
    live.participants[#live.participants + 1] = {
        username = me,
        name = acc.display_name,
        avatar = acc.profile_image,
        verified = acc.verified,
        id = streamId,
        source = source
    }
    
    -- Create participant live
    lives[me] = {
        id = streamId,
        avatar = acc.profile_image,
        verified = acc.verified,
        name = acc.display_name,
        host = source,
        nearby = {},
        viewers = {},
        participant = username
    }
    
    Player(source).state.instapicIsLive = me
    TriggerClientEvent("phone:instagram:updateLives", -1, lives)
    
    -- Notify followers
    local followers = MySQL.query.await("SELECT follower FROM phone_instagram_follows WHERE followed = @username", { ["@username"] = me })
    for i = 1, #followers do
        notifyInstagramDevices(followers[i].follower, { 
            title = L("APPS.INSTAGRAM.TITLE"), 
            content = L("BACKEND.INSTAGRAM.JOINED_LIVE", { invitee = me, inviter = username }) 
        })
    end
    
    cb(true)
end)

RegisterLegacyCallback("instagram:endLive", function(source, cb)
    local me = getLoggedInInstagramAccount(source)
    if not me then return cb(false) end
    
    local live = lives[me]
    if not live then return cb(false) end
    
    local wasHost = live.host == source
    local participant = live.participant
    
    -- Remove from lives
    lives[me] = nil
    Player(source).state.instapicIsLive = nil
    
    -- If was host, end the main live
    if wasHost then
        if participant then
            EndLive(participant, me)
        else
            EndLive(me, me)
        end
    else
        -- If was participant, remove from main live
        if participant and lives[participant] then
            for i = #lives[participant].participants, 1, -1 do
                if lives[participant].participants[i].username == me then
                    table.remove(lives[participant].participants, i)
                    break
                end
            end
        end
    end
    
    TriggerClientEvent("phone:instagram:updateLives", -1, lives)
    TriggerClientEvent("phone:instagram:endLive", -1, me, me)
    
    cb(true)
end)

RegisterNetEvent("phone:instagram:startLive", function(streamId)
    local src = source
    local me = getLoggedInInstagramAccount(src)
    if not me then return end
    if lives[me] then return end

    local allowed = CanGoLive(src, me)
    if not allowed then return end

    local acc = MySQL.single.await("SELECT profile_image, verified, display_name, private FROM phone_instagram_accounts WHERE username = ?", { me })
    if not acc then return end

    lives[me] = {
        id = streamId,
        avatar = acc.profile_image,
        verified = acc.verified,
        name = acc.display_name,
        private = acc.private,
        host = src,
        viewers = {},
        nearby = {},
        invites = {},
        participants = {}
    }

    Player(src).state.instapicIsLive = me
    TriggerClientEvent("phone:instagram:updateLives", -1, lives)

    Log("InstaPic", src, "success", L("BACKEND.LOGS.LIVE_TITLE"), L("BACKEND.LOGS.STARTED_LIVE", { username = me }))
    TrackSimpleEvent("go_live")

    if Config.InstaPicLiveNotifications then
        local mode = (Config.InstaPicLiveNotifications == "all") and "all" or "online"
        NotifyEveryone(mode, { app = "Instagram", title = L("APPS.INSTAGRAM.TITLE"), content = L("BACKEND.INSTAGRAM.STARTED_LIVE", { username = me }) })
    else
        local followers = MySQL.query.await("SELECT follower FROM phone_instagram_follows WHERE followed = @username", { ["@username"] = me })
        for i = 1, #followers do
            notifyInstagramDevices(followers[i].follower, { title = L("APPS.INSTAGRAM.TITLE"), content = L("BACKEND.INSTAGRAM.STARTED_LIVE", { username = me }) })
        end
    end
end)

RegisterNetEvent("phone:instagram:sendLiveMessage", function(messageData)
    local src = source
    local me = getLoggedInInstagramAccount(src)
    if not me then return end
    
    messageData.username = me
    messageData.timestamp = os.time()
    
    TriggerClientEvent("phone:instagram:addLiveMessage", -1, messageData)
end)

RegisterNetEvent("phone:instagram:addCall", function(callId)
    local src = source
    local me = getLoggedInInstagramAccount(src)
    if not me then return end
    
    -- Handle call logic here
    TriggerClientEvent("phone:instagram:addCall", -1, {
        id = callId,
        username = me,
        source = src
    })
end)

RegisterNetEvent("phone:instagram:inviteLive", function(username)
    local src = source
    local me = getLoggedInInstagramAccount(src)
    if not me then return end
    
    local live = lives[me]
    if not live then return end
    
    -- Add to invites
    if not live.invites then live.invites = {} end
    live.invites[username] = true
    
    -- Send invitation to target user
    TriggerClientEvent("phone:instagram:invitedLive", -1, {
        from = me,
        to = username,
        source = src
    })
end)

RegisterNetEvent("phone:instagram:removeLive", function(username)
    local src = source
    local me = getLoggedInInstagramAccount(src)
    if not me then return end
    
    local live = lives[me]
    if not live then return end
    
    -- Remove from participants
    for i = #live.participants, 1, -1 do
        if live.participants[i].username == username then
            local participant = live.participants[i]
            table.remove(live.participants, i)
            
            -- End their live
            if lives[username] then
                lives[username] = nil
                local participantSrc = participant.source
                if participantSrc then
                    Player(participantSrc).state.instapicIsLive = nil
                    TriggerClientEvent("phone:instagram:removedLive", participantSrc)
                end
            end
            break
        end
    end
    
    TriggerClientEvent("phone:instagram:updateLives", -1, lives)
end)

-- Handle player disconnection
AddEventHandler("playerDropped", function()
    local src = source
    
    -- Check all live streams for this player
    for username, live in pairs(lives) do
        -- Check if player is a viewer
        for i = #live.viewers, 1, -1 do
            if live.viewers[i] == src then
                table.remove(live.viewers, i)
                TriggerClientEvent("phone:instagram:updateViewers", -1, username, #live.viewers)
                break
            end
        end
        
        -- Check if player is the host
        if live.host == src then
            local participant = live.participant
            if participant then
                EndLive(participant, username)
            else
                EndLive(username, username)
            end
        else
            -- Check if player is a participant
            for i = #live.participants, 1, -1 do
                if live.participants[i].source == src then
                    local participant = live.participants[i]
                    table.remove(live.participants, i)
                    
                    -- End their live
                    if lives[participant.username] then
                        lives[participant.username] = nil
                        TriggerClientEvent("phone:instagram:leftLive", -1, username, participant.username, src)
                    end
                    break
                end
            end
        end
    end
    
    TriggerClientEvent("phone:instagram:updateLives", -1, lives)
end)


