-- Helpers
local function getLoggedInTwitterAccount(source)
    local phone = GetEquippedPhoneNumber(source)
    if not phone then return false end
    return GetLoggedInAccount(phone, "Twitter")
end

local function createAuthenticatedCallback(name, handler, defaultReturn, options)
    BaseCallback("birdy:" .. name, function(source, phoneNumber, ...)
        local account = GetLoggedInAccount(phoneNumber, "Twitter")
        if not account then
            return defaultReturn
        end
        return handler(source, phoneNumber, account, ...)
    end, defaultReturn, options)
end

-- Send notification to all logged-in devices for username
local function notifyLoggedInDevices(username, notification, excludePhoneNumber)
    local rows = MySQL.query.await(
        "SELECT phone_number FROM phone_logged_in_accounts WHERE username = ? AND app = 'Twitter' AND `active` = 1",
        { username }
    )
    notification.app = "Twitter"
    for i = 1, (rows and #rows or 0) do
        local number = rows[i].phone_number
        if number ~= excludePhoneNumber then
            SendNotification(number, notification)
        end
    end
end

-- Map phone_number => source for a username
local function getPhoneNumberToSourceMap(username)
    local map = {}
    local rows = MySQL.Sync.fetchAll(
        "SELECT phone_number FROM phone_logged_in_accounts WHERE username = ? AND app = 'Twitter' AND `active` = 1",
        { username }
    )
    for i = 1, (rows and #rows or 0) do
        local phoneNumber = rows[i].phone_number
        map[phoneNumber] = GetSourceFromNumber(phoneNumber)
    end
    return map
end

-- Build full profile data (with relationship to logged-in account if provided)
local function getTwitterProfile(username, loggedInPhoneNumber)
    username = username:lower()

    local acc = MySQL.single.await(
        [[SELECT `display_name`, `bio`, `profile_image`, `profile_header`, `verified`, `follower_count`, `following_count`, `date_joined`, private FROM `phone_twitter_accounts` WHERE `username`=?]],
        { username })
    if not acc then return false end

    local isFollowing, isFollowingYou, notificationsEnabled, requested = false, false, false, false
    local pinnedTweet = nil

    local loggedInAs = nil
    if loggedInPhoneNumber then
        loggedInAs = GetLoggedInAccount(loggedInPhoneNumber, "Twitter")
    end

    if loggedInAs then
        isFollowing = nil ~= MySQL.scalar.await(
            "SELECT `followed` FROM `phone_twitter_follows` WHERE `follower` = ? AND `followed` = ?",
            { loggedInAs, username }
        )
        isFollowingYou = nil ~= MySQL.scalar.await(
            "SELECT `followed` FROM `phone_twitter_follows` WHERE `follower` = ? AND `followed` = ?",
            { username, loggedInAs }
        )
        notificationsEnabled = true == MySQL.scalar.await(
            "SELECT `notifications` FROM `phone_twitter_follows` WHERE `follower` = ? AND `followed` = ?",
            { loggedInAs, username }
        )
        requested = nil ~= MySQL.scalar.await(
            "SELECT TRUE FROM phone_twitter_follow_requests WHERE requester = ? AND requestee = ?",
            { loggedInAs, username }
        )

        local pt = MySQL.scalar.await("SELECT pinned_tweet FROM phone_twitter_accounts WHERE username = ?", { username })
        if pt then
            pinnedTweet = GetTweet(pt, loggedInAs)
        end
    end

    return {
        name = acc.display_name,
        username = username,
        followers = acc.follower_count,
        following = acc.following_count,
        date_joined = acc.date_joined,
        bio = acc.bio,
        verified = acc.verified,
        private = acc.private,
        profile_picture = acc.profile_image,
        header = acc.profile_header,
        isFollowing = isFollowing,
        isFollowingYou = isFollowingYou,
        notificationsEnabled = notificationsEnabled,
        pinnedTweet = pinnedTweet,
        requested = requested
    }
end

-- Notifications
local notifKeys = {
    like = "BACKEND.TWITTER.LIKE",
    retweet = "BACKEND.TWITTER.RETWEET",
    reply = "BACKEND.TWITTER.REPLY",
    follow = "BACKEND.TWITTER.FOLLOW",
    tweet = "BACKEND.TWITTER.TWEET",
}

local function sendTwitterNotification(toUser, fromUser, notifType, tweetId)
    if toUser == fromUser then return end
    local key = notifKeys[notifType]
    if not key then return end

    if notifType == "like" or notifType == "retweet" or notifType == "follow" then
        local q =
        "SELECT TRUE FROM phone_twitter_notifications WHERE username=@username AND `from`=@from AND `type`=@type"
        if notifType ~= "follow" then
            q = q .. " AND tweet_id=@tweet_id"
        end
        local exists = MySQL.Sync.fetchScalar(q, {
            ["@username"] = toUser,
            ["@from"] = fromUser,
            ["@type"] = notifType,
            ["@tweet_id"] = tweetId,
        })
        if exists then return end
    end

    local sender = (MySQL.Sync.fetchAll("SELECT display_name, private FROM phone_twitter_accounts WHERE username=@username", { ["@username"] = fromUser }) or {})
        [1]
    if not sender then return end
    if sender.private and notifType == "reply" then return end

    local title = L(key, { displayName = sender.display_name, username = fromUser })

    MySQL.Async.execute(
        "INSERT INTO phone_twitter_notifications (id, username, `from`, `type`, tweet_id) VALUES (@id, @username, @from, @type, @tweetId)",
        {
            ["@id"] = GenerateId("phone_twitter_notifications", "id"),
            ["@username"] = toUser,
            ["@from"] = fromUser,
            ["@type"] = notifType,
            ["@tweetId"] = tweetId,
        }
    )

    local content, attachments = nil, nil
    if notifType ~= "follow" then
        local rows = MySQL.Sync.fetchAll("SELECT content, attachments FROM phone_twitter_tweets WHERE id=@tweetId",
            { ["@tweetId"] = tweetId })
        if rows and rows[1] then
            content = rows[1].content
            attachments = rows[1].attachments
            if attachments then
                attachments = json.decode(attachments)
            end
        end
    end

    -- Fan out to all devices
    notifyLoggedInDevices(toUser, { title = title, content = content, attachments = attachments })
end

-- GetTweet helpers and exports
local function GetTweetInternal(id, loggedInAs)
    if not id then return end
    local rows = MySQL.Sync.fetchAll([[SELECT DISTINCT t.id, t.username, t.content, t.attachments,
        t.like_count, t.reply_count, t.retweet_count, t.reply_to, t.`timestamp`,
        (CASE WHEN t.reply_to IS NULL THEN NULL ELSE (SELECT username FROM phone_twitter_tweets WHERE id=t.reply_to LIMIT 1) END) AS replyToAuthor,
        a.display_name, a.username, a.profile_image, a.verified
        FROM phone_twitter_tweets t INNER JOIN phone_twitter_accounts a ON a.username=t.username
        WHERE t.id=@tweetId AND (a.private=0 OR a.username=@loggedInAs OR (
            SELECT TRUE FROM phone_twitter_follows f WHERE f.follower=@loggedInAs AND f.followed=a.username))]],
        { ["@tweetId"] = id, ["@loggedInAs"] = loggedInAs }
    )
    return rows and rows[1]
end

GetTweet = function(id, loggedInAs)
    return GetTweetInternal(id, loggedInAs)
end

exports("GetTweet", function(id, cb)
    infoprint("warning", "GetTweet is deprecated, use GetBirdyPost instead")
    MySQL.Async.fetchAll([[SELECT DISTINCT t.id, t.username, t.content, t.attachments,
        t.like_count, t.reply_count, t.retweet_count, t.reply_to, t.`timestamp`,
        a.display_name, a.username, a.profile_image, a.verified
        FROM (phone_twitter_tweets t, phone_twitter_accounts a)
        WHERE t.id=@tweetId AND t.username=a.username]], { ["@tweetId"] = id }, cb)
end)

exports("GetBirdyPost", function(id)
    local row = MySQL.single.await([[SELECT t.id,
        t.username,
        t.content,
        t.attachments,
        t.like_count AS likes,
        t.reply_count AS replies,
        t.retweet_count AS reposts,
        t.reply_to AS replyTo,
        t.`timestamp`,
        a.display_name AS displayName,
        a.profile_image AS avatar,
        a.verified
        FROM phone_twitter_tweets t LEFT JOIN phone_twitter_accounts a ON a.username = t.username
        WHERE t.id = ?]], { id })
    if row and row.attachments then row.attachments = json.decode(row.attachments) end
    return row
end)



-- Notifications list and follow requests count
RegisterLegacyCallback("birdy:getNotifications", function(source, cb, page)
    local username = getLoggedInTwitterAccount(source)
    if not username then
        return cb({ notifications = {}, requests = 0 })
    end

    local notifications = MySQL.Sync.fetchAll([[SELECT
            -- notification data
            n.`from`, n.`type`, n.tweet_id,
            -- tweet data
            t.username, t.content, t.attachments, t.reply_to, t.like_count,
            t.reply_count, t.retweet_count, t.`timestamp`,
            (
                SELECT TRUE FROM phone_twitter_likes l
                WHERE l.tweet_id=t.id AND l.username=@username
            ) AS liked,
            (
                SELECT TRUE FROM phone_twitter_retweets r
                WHERE r.tweet_id=t.id AND r.username=@username
            ) AS retweeted,
            -- account data
            a.display_name AS `name`, a.profile_image AS profile_picture, a.verified,
            (
                CASE WHEN t.reply_to IS NULL THEN NULL ELSE (SELECT username FROM phone_twitter_tweets WHERE id=t.reply_to LIMIT 1) END
            ) AS replyToAuthor
        FROM phone_twitter_notifications n
        LEFT JOIN phone_twitter_tweets t ON n.tweet_id = t.id
        JOIN phone_twitter_accounts a ON a.username = n.from
        WHERE n.username=@username
        ORDER BY n.`timestamp` DESC
        LIMIT @page, @perPage
    ]], {
        ["@username"] = username,
        ["@page"] = (page or 0) * 15,
        ["@perPage"] = 15
    }) or {}

    if (page or 0) > 0 then
        return cb({ notifications = notifications })
    end

    local requests = MySQL.Sync.fetchScalar(
        "SELECT COUNT(1) FROM phone_twitter_follow_requests WHERE requestee=@username",
        { ["@username"] = username }
    ) or 0

    cb({ notifications = notifications, requests = requests })
end)

-- Create account
RegisterLegacyCallback("birdy:createAccount", function(source, cb, displayName, username, password)
    local phoneNumber = GetEquippedPhoneNumber(source)
    if not phoneNumber then return cb(false) end

    username = username:lower()
    if not IsUsernameValid(username) then
        return cb({ success = false, error = "USERNAME_NOT_ALLOWED" })
    end

    local exists = MySQL.Sync.fetchScalar(
        "SELECT TRUE FROM phone_twitter_accounts WHERE username=@username",
        { ["@username"] = username }
    )
    if exists then
        return cb({ success = false, error = "USERNAME_TAKEN" })
    end

    MySQL.Sync.execute(
        "INSERT INTO phone_twitter_accounts (display_name, username, `password`, phone_number) VALUES (@displayName, @username, @password, @phonenumber)",
        {
            ["@displayName"] = displayName,
            ["@username"] = username,
            ["@password"] = GetPasswordHash(password),
            ["@phonenumber"] = phoneNumber
        }
    )

    AddLoggedInAccount(phoneNumber, "Twitter", username)
    cb({ success = true })

    if Config.AutoFollow.Enabled and Config.AutoFollow.Birdy.Enabled then
        for i = 1, #Config.AutoFollow.Birdy.Accounts do
            MySQL.update.await("INSERT INTO phone_twitter_follows (followed, follower) VALUES (?, ?)", {
                Config.AutoFollow.Birdy.Accounts[i],
                username
            })
        end
    end
end, { preventSpam = true, rateLimit = 4 })

-- Login
BaseCallback("birdy:login", function(source, phoneNumber, username, password)
    username = username:lower()
    local hashed = MySQL.scalar.await("SELECT `password` FROM phone_twitter_accounts WHERE username = ?", { username })
    if not hashed then
        return { success = false, error = "INVALID_ACCOUNT" }
    end
    if not VerifyPasswordHash(password, hashed) then
        return { success = false, error = "INVALID_PASSWORD" }
    end

    AddLoggedInAccount(phoneNumber, "Twitter", username)
    local data = getTwitterProfile(username)
    if not data then
        return { success = false, error = "INVALID_ACCOUNT" }
    end
    return { success = true, data = data }
end)

-- Is logged in
createAuthenticatedCallback("isLoggedIn", function(_, __, account)
    return getTwitterProfile(account)
end, false)

-- Get profile (view)
createAuthenticatedCallback("getProfile", function(_, phoneNumber, __, target)
    return getTwitterProfile(target, phoneNumber)
end, false)

-- Pin tweet
RegisterLegacyCallback("birdy:pinPost", function(source, cb, tweetId)
    local username = getLoggedInTwitterAccount(source)
    if not username then return cb(false) end

    if tweetId then
        local owns = MySQL.scalar.await(
            "SELECT TRUE FROM phone_twitter_tweets WHERE id = ? AND username = ?",
            { tweetId, username }
        )
        if not owns then
            infoprint("warning", ("%s (%s) tried to pin a post they didn't make."):format(username, source))
            return cb(false)
        end
    end

    MySQL.Async.execute("UPDATE phone_twitter_accounts SET pinned_tweet=@tweetId WHERE username=@username", {
        ["@tweetId"] = tweetId or nil,
        ["@username"] = username
    }, function()
        cb(true)
    end)
end)

-- Sign out
RegisterLegacyCallback("birdy:signOut", function(source, cb)
    local phoneNumber = GetEquippedPhoneNumber(source)
    if not phoneNumber then return cb(false) end
    local account = GetLoggedInAccount(phoneNumber, "Twitter")
    if not account then return cb(false) end
    RemoveLoggedInAccount(phoneNumber, "Twitter", account)
    cb(true)
end)

-- Update profile
RegisterLegacyCallback("birdy:updateProfile", function(source, cb, data)
    local username = getLoggedInTwitterAccount(source)
    if not username then return cb(false) end

    MySQL.Async.execute(
        "UPDATE phone_twitter_accounts SET display_name=@displayName, bio=@bio, profile_image=@profilePicture, profile_header=@header, private=@private WHERE username=@username",
        {
            ["@username"] = username,
            ["@displayName"] = data.name,
            ["@bio"] = data.bio,
            ["@profilePicture"] = data.profile_picture,
            ["@header"] = data.header,
            ["@private"] = data.private,
        }, function()
            cb(true)
        end)
end)


-- Change password
createAuthenticatedCallback("changePassword", function(source, phoneNumber, account, oldPassword, newPassword)
    if not Config.ChangePassword or not Config.ChangePassword.Birdy then
        infoprint("warning", ("%s tried to change Birdy password but it's disabled in config"):format(source))
        return false
    end
    if oldPassword == newPassword or #tostring(newPassword) < 3 then
        debugprint("same password / too short")
        return false
    end

    local current = MySQL.scalar.await("SELECT password FROM phone_twitter_accounts WHERE username = ?", { account })
    if not current or not VerifyPasswordHash(oldPassword, current) then
        return false
    end

    local ok = MySQL.update.await("UPDATE phone_twitter_accounts SET password = ? WHERE username = ?", {
        GetPasswordHash(newPassword), account
    }) > 0
    if not ok then return false end

    -- notify other devices and force logout
    notifyLoggedInDevices(account, {
        title = L("BACKEND.MISC.LOGGED_OUT_PASSWORD.TITLE"),
        content = L("BACKEND.MISC.LOGGED_OUT_PASSWORD.DESCRIPTION")
    }, phoneNumber)

    MySQL.update.await(
        "DELETE FROM phone_logged_in_accounts WHERE username = ? AND app = 'Twitter' AND phone_number != ?",
        { account, phoneNumber })
    ClearActiveAccountsCache("Twitter", account, phoneNumber)

    Log("Birdy", source, "info",
        L("BACKEND.LOGS.CHANGED_PASSWORD.TITLE"),
        L("BACKEND.LOGS.CHANGED_PASSWORD.DESCRIPTION", { number = phoneNumber, username = account, app = "Birdy" })
    )

    TriggerClientEvent("phone:logoutFromApp", -1,
        { username = account, app = "birdy", reason = "password", number = phoneNumber })
    return true
end, false)

-- Delete account
createAuthenticatedCallback("deleteAccount", function(source, phoneNumber, account, password)
    if not Config.DeleteAccount or not Config.DeleteAccount.Birdy then
        infoprint("warning", ("%s tried to delete Birdy account but it's disabled in config"):format(source))
        return false
    end
    local current = MySQL.scalar.await("SELECT password FROM phone_twitter_accounts WHERE username = ?", { account })
    if not current or not VerifyPasswordHash(password, current) then
        return false
    end

    local deleted = MySQL.update.await("DELETE FROM phone_twitter_accounts WHERE username = ?", { account }) > 0
    if not deleted then return false end

    notifyLoggedInDevices(account, {
        title = L("BACKEND.MISC.DELETED_NOTIFICATION.TITLE"),
        content = L("BACKEND.MISC.DELETED_NOTIFICATION.DESCRIPTION")
    })

    MySQL.update.await("DELETE FROM phone_logged_in_accounts WHERE username = ? AND app = 'Twitter'", { account })
    ClearActiveAccountsCache("Twitter", account)

    Log("Birdy", source, "info",
        L("BACKEND.LOGS.DELETED_ACCOUNT.TITLE"),
        L("BACKEND.LOGS.DELETED_ACCOUNT.DESCRIPTION", { number = phoneNumber, username = account, app = "Birdy" })
    )

    TriggerClientEvent("phone:logoutFromApp", -1, { username = account, app = "twitter", reason = "deleted" })
    return true
end, false)

-- Webhook for new posts
local function sendPostWebhook(username, content, attachments, isReply)
    if not (Config.Post and Config.Post.Birdy) or isReply then return end
    if not BIRDY_WEBHOOK or BIRDY_WEBHOOK:sub(-14) ~= "/api/webhooks/" then return end

    local avatar = MySQL.scalar.await("SELECT profile_image FROM phone_twitter_accounts WHERE username = ?", { username })

    PerformHttpRequest(BIRDY_WEBHOOK, function() end, "POST", json.encode({
        username = (Config.Post.Accounts and Config.Post.Accounts.Birdy and Config.Post.Accounts.Birdy.Username) or
            "Birdy",
        avatar_url = (Config.Post.Accounts and Config.Post.Accounts.Birdy and Config.Post.Accounts.Birdy.Avatar) or
            "https://loaf-scripts.com/fivem/lb-phone/icons/Birdy.png",
        embeds = { {
            title = L("APPS.TWITTER.NEW_POST"),
            description = (content and #content > 0) and content or nil,
            color = 1942002,
            timestamp = GetTimestampISO(),
            author = { name = "@" .. username, icon_url = avatar or "https://cdn.discordapp.com/embed/avatars/5.png" },
            image = (attachments and #attachments > 0) and { url = attachments[1] } or nil,
            footer = { text = "LB Phone", icon_url = "https://docs.lbscripts.com/images/icons/icon.png" }
        } }
    }), { ["Content-Type"] = "application/json" })
end

-- Posting
local function PostBirdy(username, content, attachments, replyTo, hashtags, source)
    content = content or ""
    assert(type(username) == "string", "PostBirdy: Expected string for argument 1 (username), got " .. type(username))
    assert(type(content) == "string", "PostBirdy: Expected string/nil for argument 2 (content), got " .. type(content))

    -- Build INSERT
    local id = GenerateId("phone_twitter_tweets", "id")
    local params = { id, username, content }
    local query = "INSERT INTO phone_twitter_tweets (id, username, content"

    if attachments then
        if type(attachments) == "table" and table.type(attachments) == "array" and #attachments > 0 then
            query = query .. ", attachments"
            params[#params + 1] = json.encode(attachments)
        elseif type(attachments) ~= "table" then
            error("PostBirdy: Expected table/nil for argument 3 (attachments), got " .. type(attachments))
        end
    end

    if hashtags then
        if type(hashtags) == "table" and table.type(hashtags) == "array" and #hashtags > 0 then
            query = query .. ", hashtags"
            params[#params + 1] = json.encode(hashtags)
        elseif type(hashtags) ~= "table" then
            error("PostBirdy: Expected table/nil for argument 5 (hashtags), got " .. type(hashtags))
        end
    end

    if replyTo then
        assert(type(replyTo) == "string",
            "PostBirdy: Expected string/nil for argument 4 (replyTo), got " .. type(replyTo))
        query = query .. ", reply_to"
        params[#params + 1] = replyTo
    end

    local values = "(" .. string.rep("?,", #params):sub(1, -2) .. ")"
    query = query .. ") VALUES " .. values

    local affected = MySQL.update.await(query, params)
    if affected == 0 then return false end

    -- reply update + notify
    if replyTo then
        MySQL.update("UPDATE phone_twitter_tweets SET reply_count = reply_count + 1 WHERE id = ?", { replyTo })
        TriggerClientEvent("phone:twitter:updateTweetData", -1, replyTo, "replies", true)
        local replyToAuthor = MySQL.scalar.await("SELECT username FROM phone_twitter_tweets WHERE id = ?", { replyTo })
        if replyToAuthor then
            sendTwitterNotification(replyToAuthor, username, "reply", id)
        end
    end

    -- notify followers with notifications enabled
    MySQL.query("SELECT follower FROM phone_twitter_follows WHERE followed = ? AND notifications=1", { username },
        function(rows)
            for i = 1, (rows and #rows or 0) do
                sendTwitterNotification(rows[i].follower, username, "tweet", id)
            end
        end)

    TrackSocialMediaPost("birdy", attachments)

    -- webhook
    sendPostWebhook(username, content, attachments, replyTo ~= nil)

    -- build client payload
    local profile = MySQL.single.await(
            "SELECT display_name, profile_image, verified, private FROM phone_twitter_accounts WHERE username = ?",
            { username }) or
        { display_name = username }
    local payload = {
        id = id,
        username = username,
        content = content,
        attachments = attachments,
        like_count = 0,
        reply_count = 0,
        retweet_count = 0,
        reply_to = replyTo,
        timestamp = os.time() * 1000,
        liked = false,
        retweeted = false,
        display_name = profile.display_name,
        profile_image = profile.profile_image,
        verified = profile.verified
    }
    if replyTo then
        payload.replyToAuthor = MySQL.scalar.await("SELECT username FROM phone_twitter_tweets WHERE id = ?", { replyTo })
    end

    TriggerClientEvent("phone:twitter:newtweet", -1, payload)
    TriggerEvent("lb-phone:birdy:newPost", payload)

    -- global notifications
    if not profile.private and Config.BirdyNotifications then
        local scope = (Config.BirdyNotifications == "all") and "all" or "online"
        NotifyEveryone(scope, {
            app = "Twitter",
            title = L("BACKEND.TWITTER.TWEET", { username = username }),
            content = content,
            thumbnail = (attachments and attachments[1]) or nil
        })
    end

    if Config.BirdyTrending and Config.BirdyTrending.Enabled and hashtags and type(hashtags) == "table" and table.type(hashtags) == "array" and #hashtags > 0 then
        local q = "INSERT INTO phone_twitter_hashtags (hashtag, amount) VALUES " ..
            string.rep("(?, 1), ", #hashtags):sub(1, -3) .. " ON DUPLICATE KEY UPDATE amount = amount + 1"
        MySQL.update(q, hashtags)
    end

    return true, id
end

exports("PostBirdy", PostBirdy)

createAuthenticatedCallback("sendPost", function(source, _, account, content, attachments, replyTo, hashtags)
    if ContainsBlacklistedWord(source, "Birdy", content) then
        return false
    end
    local result = PostBirdy(account, content, attachments, replyTo, hashtags, source)
    print("result ", result)
    return result
end, nil, { preventSpam = true, rateLimit = 15 })


-- Trending hashtags (top 5)
RegisterCallback("birdy:getRecentHashtags", function()
    if Config.BirdyTrending and Config.BirdyTrending.Enabled then
        return MySQL.query.await(
            "SELECT hashtag, amount AS uses FROM phone_twitter_hashtags ORDER BY amount DESC LIMIT 5")
    end
    return {}
end)

-- Delete post
RegisterLegacyCallback("birdy:deletePost", function(source, cb, tweetId)
    local username = getLoggedInTwitterAccount(source)
    if not username then return cb(false) end

    local replyTo = MySQL.Sync.fetchScalar("SELECT reply_to FROM phone_twitter_tweets WHERE id=@id",
        { ["@id"] = tweetId })

    local canDelete = IsAdmin and IsAdmin(source) or false
    if not canDelete then
        canDelete = MySQL.Sync.fetchScalar("SELECT TRUE FROM phone_twitter_tweets WHERE id=@id AND username=@username",
            { ["@id"] = tweetId, ["@username"] = username })
    end
    if not canDelete then return cb(false) end

    local params = { ["@id"] = tweetId }
    MySQL.Sync.execute("DELETE FROM phone_twitter_likes WHERE tweet_id=@id", params)
    MySQL.Sync.execute("DELETE FROM phone_twitter_retweets WHERE tweet_id=@id", params)
    MySQL.Sync.execute("DELETE FROM phone_twitter_notifications WHERE tweet_id=@id", params)
    local deleted = MySQL.Sync.execute("DELETE FROM phone_twitter_tweets WHERE id=@id", params) > 0
    cb(deleted)
    if not deleted then return end

    if replyTo then
        local count = MySQL.Sync.fetchScalar("SELECT COUNT(id) FROM phone_twitter_tweets WHERE reply_to=@replyTo",
            { ["@replyTo"] = replyTo })
        MySQL.Sync.execute("UPDATE phone_twitter_tweets SET reply_count=@count WHERE id=@replyTo",
            { ["@replyTo"] = replyTo, ["@count"] = count })
        TriggerClientEvent("phone:twitter:updateTweetData", -1, replyTo, "replies", false)
    end

    Log("Birdy", source, "info", "Post deleted", "**ID**: " .. tostring(tweetId))
end)

-- Random promoted
RegisterLegacyCallback("birdy:getRandomPromoted", function(source, cb)
    local username = getLoggedInTwitterAccount(source)
    if not username then return cb(false) end

    local tweetId = MySQL.Sync.fetchScalar(
        "SELECT tweet_id FROM phone_twitter_promoted WHERE promotions > 0 ORDER BY RAND() LIMIT 1")
    if not tweetId then return cb(false) end

    MySQL.Async.execute(
        "UPDATE phone_twitter_promoted SET promotions = promotions - 1, views = views + 1 WHERE tweet_id = @tweetId",
        { ["@tweetId"] = tweetId })
    cb(GetTweet(tweetId))
end)

-- Promote a post
RegisterLegacyCallback("birdy:promotePost", function(source, cb, tweetId)
    if not (Config.PromoteBirdy and Config.PromoteBirdy.Enabled and RemoveMoney) then
        return cb(false)
    end
    if not RemoveMoney(source, Config.PromoteBirdy.Cost) then
        return cb(false)
    end
    MySQL.Async.execute(
        [[INSERT INTO phone_twitter_promoted (tweet_id, promotions, views) VALUES (@tweetId, @promotions, 0)
        ON DUPLICATE KEY UPDATE promotions = promotions + @promotions]], {
            ["@tweetId"] = tweetId,
            ["@promotions"] = Config.PromoteBirdy.Views
        }, function()
            cb(true)
        end)
end)

-- Search accounts
RegisterLegacyCallback("birdy:searchAccounts", function(_, cb, search)
    MySQL.Async.fetchAll([[SELECT display_name, username, profile_image, verified, private
        FROM phone_twitter_accounts
        WHERE username LIKE CONCAT(@search, "%") OR display_name LIKE CONCAT("%", @search, "%")]], {
        ["@search"] = search
    }, cb)
end)

-- Search tweets
RegisterLegacyCallback("birdy:searchTweets", function(source, cb, search, page)
    local loggedInAs = getLoggedInTwitterAccount(source)
    if not loggedInAs then return cb(false) end

    MySQL.Async.fetchAll([[SELECT DISTINCT t.id, t.username, t.content, t.attachments,
            t.like_count, t.reply_count, t.retweet_count, t.reply_to, t.`timestamp`,
            (CASE WHEN t.reply_to IS NULL THEN NULL ELSE (SELECT username FROM phone_twitter_tweets WHERE id=t.reply_to LIMIT 1) END) AS replyToAuthor,
            a.display_name, a.username, a.profile_image, a.verified,
            (SELECT TRUE FROM phone_twitter_likes l WHERE l.tweet_id=t.id AND l.username=@loggedInAs) AS liked,
            (SELECT TRUE FROM phone_twitter_retweets r WHERE r.tweet_id=t.id AND r.username=@loggedInAs) AS retweeted
        FROM phone_twitter_tweets t LEFT JOIN phone_twitter_accounts a ON a.username=t.username
        WHERE t.content LIKE CONCAT("%", @search, "%")
        ORDER BY t.`timestamp` DESC
        LIMIT @page, @perPage]], {
        ["@loggedInAs"] = loggedInAs,
        ["@search"] = search,
        ["@page"] = (page or 0) * 10,
        ["@perPage"] = 10
    }, cb)
end)

-- Get lists of users for a given context (likes, retweeters, following, followers)
RegisterLegacyCallback("birdy:getData", function(source, cb, kind, whereValue, page)
    local loggedInAs = getLoggedInTwitterAccount(source)
    if not loggedInAs then return cb(false) end

    local tbl, colWhere, colUser = "phone_twitter_likes", "tweet_id", "username"
    if kind == "following" or kind == "followers" then
        tbl = "phone_twitter_follows"
        if kind == "following" then
            colWhere = "follower"; colUser = "followed"
        else
            colWhere = "followed"; colUser = "follower"
        end
    elseif kind == "retweeters" then
        tbl = "phone_twitter_retweets"; colWhere = "tweet_id"; colUser = "username"
    end

    local sql = ([[SELECT a.display_name AS `name`, a.username, a.profile_image AS profile_picture, a.bio, a.verified,
        (SELECT CASE WHEN f.followed IS NULL THEN FALSE ELSE TRUE END FROM phone_twitter_follows f WHERE f.follower=@loggedInAs AND a.username=f.followed) AS isFollowing,
        (SELECT CASE WHEN f.follower IS NULL THEN FALSE ELSE TRUE END FROM phone_twitter_follows f WHERE f.follower=a.username AND f.followed=@loggedInAs) AS isFollowingYou
        FROM %s w JOIN phone_twitter_accounts a ON a.username=w.%s WHERE w.%s=@whereValue
        ORDER BY a.username DESC LIMIT @page, @perPage]]):format(tbl, colUser, colWhere)

    MySQL.Async.fetchAll(sql, {
        ["@loggedInAs"] = loggedInAs,
        ["@whereValue"] = whereValue,
        ["@page"] = (page or 0) * 20,
        ["@perPage"] = 20
    }, cb)
end)

-- Get single post (with privacy rules)
RegisterLegacyCallback("birdy:getPost", function(source, cb, tweetId)
    local loggedInAs = getLoggedInTwitterAccount(source)
    if not loggedInAs then return cb(false) end
    cb(GetTweet(tweetId, loggedInAs))
end)

-- Get author profile for a given tweet id
RegisterLegacyCallback("birdy:getAuthor", function(source, cb, tweetId)
    local phoneNumber = GetEquippedPhoneNumber(source)
    if not phoneNumber then return cb(false) end
    local loggedIn = GetLoggedInAccount(phoneNumber, "Twitter")
    if not loggedIn then return cb(false) end

    local author = MySQL.scalar.await("SELECT username FROM phone_twitter_tweets WHERE id = ?", { tweetId })
    if not author then return cb(false) end

    cb(getTwitterProfile(author, phoneNumber))
end)

-- Get posts (timeline, profile, liked, media, replies)
RegisterLegacyCallback("birdy:getPosts", function(source, cb, filter, page)
    local loggedInAs = getLoggedInTwitterAccount(source)
    if not loggedInAs then return cb({}) end

    local whereClause = ""
    local joinClause = ""
    local orderClause = "`timestamp` DESC"
    local includeRetweets = false
    local retweetJoin = ""
    local retweetWhere = ""

    if not filter then
        whereClause = "t.reply_to IS NULL"
        includeRetweets = true
    else
        if filter.type == "following" then
            whereClause = "t.reply_to IS NULL AND f.follower=@loggedInAs AND f.followed=t.username"
            joinClause = "JOIN phone_twitter_follows f"
            retweetJoin = "JOIN phone_twitter_follows f ON f.follower=@loggedInAs AND r.username=f.followed"
            includeRetweets = true
        elseif filter.type == "replyTo" then
            whereClause = "t.reply_to=@replyTo"
            orderClause = "t.like_count DESC, t.timestamp DESC"
        elseif filter.type == "user" then
            whereClause = "t.username=@username AND t.reply_to IS NULL"
            retweetWhere = " AND r.username=@username"
            includeRetweets = true
        elseif filter.type == "media" then
            whereClause = "t.username=@username AND t.attachments IS NOT NULL"
        elseif filter.type == "replies" then
            whereClause = "t.username=@username AND t.reply_to IS NOT NULL"
        elseif filter.type == "liked" then
            whereClause = "l.username=@username AND t.id=l.tweet_id"
            joinClause = "JOIN phone_twitter_likes l"
            orderClause = "l.timestamp DESC"
        end
    end

    local baseQuery = ([[
        SELECT
            (
                CASE WHEN t.reply_to IS NULL THEN NULL ELSE (SELECT username FROM phone_twitter_tweets WHERE id=t.reply_to LIMIT 1) END
            ) AS replyToAuthor,

            t.id, t.username, t.content, t.attachments,
            t.like_count, t.reply_count, t.retweet_count, t.reply_to,
            t.`timestamp`,

            a.display_name, a.profile_image, a.verified, a.private,

            (
                SELECT TRUE FROM phone_twitter_likes l2
                WHERE l2.tweet_id=t.id AND l2.username=@loggedInAs
            ) AS liked,
            (
                SELECT TRUE FROM phone_twitter_retweets r2
                WHERE r2.tweet_id=t.id AND r2.username=@loggedInAs
            ) AS retweeted,

            NULL AS tweet_timestamp, NULL AS retweeted_by_display_name, NULL AS retweeted_by_username
        FROM phone_twitter_tweets t

        INNER JOIN phone_twitter_accounts a
            ON a.username=t.username

        %s
        WHERE (a.private=0 OR a.username=@loggedInAs OR (
            SELECT TRUE FROM phone_twitter_follows f
            WHERE f.follower=@loggedInAs AND f.followed=a.username
        )) AND %s
    ]]):format(joinClause, whereClause)

    if includeRetweets then
        local retweetQuery = ([[
            UNION ALL
            SELECT
                (
                    CASE WHEN t.reply_to IS NULL THEN NULL ELSE (SELECT username FROM phone_twitter_tweets WHERE id=t.reply_to LIMIT 1) END
                ) AS replyToAuthor,

                t.id, t.username, t.content, t.attachments,
                t.like_count, t.reply_count, t.retweet_count, t.reply_to,
                r.timestamp,

                a.display_name, a.profile_image, a.verified, a.private,

                (
                    SELECT TRUE FROM phone_twitter_likes l2
                    WHERE l2.tweet_id=t.id AND l2.username=@loggedInAs
                ) AS liked,
                (
                    SELECT TRUE FROM phone_twitter_retweets r2
                    WHERE r2.tweet_id=t.id AND r2.username=@loggedInAs
                ) AS retweeted,

                t.`timestamp` AS tweet_timestamp,
                (
                    SELECT display_name FROM phone_twitter_accounts a2
                    WHERE r.username=a2.username
                ) AS retweeted_by_display_name,
                r.username AS retweeted_by_username

            FROM phone_twitter_tweets t

            INNER JOIN phone_twitter_accounts a
                ON a.username=t.username

            JOIN phone_twitter_retweets r ON r.tweet_id=t.id
            %s
            WHERE (a.private=0 OR a.username=@loggedInAs OR (
                SELECT TRUE FROM phone_twitter_follows f
                WHERE f.follower=@loggedInAs AND f.followed=a.username
            )) %s
        ]]):format(retweetJoin, retweetWhere)

        baseQuery = baseQuery .. retweetQuery
    end

    local finalQuery = baseQuery .. ([[
ORDER BY %s

LIMIT @page, @perPage
    ]]):format(orderClause)

    local params = {
        ["@loggedInAs"] = loggedInAs,
        ["@page"] = (page or 0) * 10,
        ["@perPage"] = 10
    }
    if filter and filter.username then
        params["@username"] = filter.username
    end
    if filter and filter.tweet_id then
        params["@replyTo"] = filter.tweet_id
    end

    MySQL.Async.fetchAll(finalQuery, params, cb)
end)


-- Toggle like/retweet
RegisterLegacyCallback("birdy:toggleInteraction", function(source, cb, kind, tweetId, enabled)
    if kind ~= "like" and kind ~= "retweet" then return end
    local username = getLoggedInTwitterAccount(source)
    if not username then return cb(not enabled) end

    local map = {
        like = { table = "phone_twitter_likes", column1 = "username", column2 = "tweet_id" },
        retweet = { table = "phone_twitter_retweets", column1 = "username", column2 = "tweet_id" }
    }
    local info = map[kind]

    if enabled then
        MySQL.Async.execute(
            ("INSERT IGNORE INTO %s (%s, %s) VALUES (@loggedInAs, @tweetId)"):format(info.table, info.column1,
                info.column2),
            {
                ["@loggedInAs"] = username,
                ["@tweetId"] = tweetId
            }, function()
                TriggerClientEvent("phone:twitter:updateTweetData", -1, tweetId, kind == "like" and "likes" or "retweets",
                    true)
                local owner = MySQL.Sync.fetchScalar("SELECT username FROM phone_twitter_tweets WHERE id=@tweetId",
                    { ["@tweetId"] = tweetId })
                sendTwitterNotification(owner, username, kind, tweetId)
                cb(true)
            end)
    else
        MySQL.Async.execute(
            ("DELETE FROM %s WHERE %s=@loggedInAs AND %s=@tweetId"):format(info.table, info.column1, info.column2), {
                ["@loggedInAs"] = username,
                ["@tweetId"] = tweetId
            }, function()
                TriggerClientEvent("phone:twitter:updateTweetData", -1, tweetId, kind == "like" and "likes" or "retweets",
                    false)
                cb(false)
            end)
    end
end, { preventSpam = true, rateLimit = 30 })

-- Toggle notifications for a followed user
RegisterLegacyCallback("birdy:toggleNotifications", function(source, cb, target, enabled)
    local username = getLoggedInTwitterAccount(source)
    if not username then return cb(not enabled) end

    MySQL.Async.execute(
        "UPDATE phone_twitter_follows SET notifications=@enabled WHERE follower=@loggedInAs AND followed=@username ", {
            ["@enabled"] = enabled,
            ["@loggedInAs"] = username,
            ["@username"] = target
        }, function(affected)
            if affected > 0 then cb(enabled) else cb(not enabled) end
        end)
end)

-- Toggle follow/unfollow or request follow for private accounts
RegisterLegacyCallback("birdy:toggleFollow", function(source, cb, target, enabled)
    local username = getLoggedInTwitterAccount(source)
    if not username or target == username then return cb(not enabled) end

    local context = { ["@loggedInAs"] = username, ["@username"] = target }
    local isPrivate = MySQL.Sync.fetchScalar("SELECT private FROM phone_twitter_accounts WHERE username=@username",
        context)

    if isPrivate then
        if enabled then
            MySQL.Async.execute(
                "INSERT IGNORE INTO phone_twitter_follow_requests (requester, requestee) VALUES (@loggedInAs, @username)",
                context, function(rows)
                    cb(enabled)
                    if rows == 0 then return end
                    for phone, src in pairs(getPhoneNumberToSourceMap(target)) do
                        SendNotification(phone,
                            { app = "Twitter", content = L("BACKEND.TWITTER.NEW_FOLLOW_REQUEST", { username = username }) })
                    end
                end)
            return
        else
            MySQL.Async.execute(
                "DELETE FROM phone_twitter_follow_requests WHERE requester=@loggedInAs AND requestee=@username", context)
        end
    end

    local sql = enabled and
        "INSERT IGNORE INTO phone_twitter_follows (followed, follower) VALUES (@username, @loggedInAs)"
        or "DELETE FROM phone_twitter_follows WHERE followed=@username AND follower=@loggedInAs"

    MySQL.Async.execute(sql, context, function(affected)
        if affected == 0 then return cb(not enabled) end
        TriggerClientEvent("phone:twitter:updateProfileData", -1, target, "followers", enabled == true)
        TriggerClientEvent("phone:twitter:updateProfileData", -1, username, "following", enabled == true)
        if enabled then
            sendTwitterNotification(target, username, "follow")
        end
        cb(enabled)
    end)
end, { preventSpam = true, rateLimit = 30 })

-- Follow requests list
RegisterLegacyCallback("birdy:getFollowRequests", function(source, cb, page)
    local username = getLoggedInTwitterAccount(source)
    if not username then return cb({}) end

    MySQL.Async.fetchAll([[SELECT a.username, a.display_name AS `name`, a.profile_image AS profile_picture, a.verified,
            (
                SELECT CASE WHEN f.follower IS NULL THEN FALSE ELSE TRUE END
                    FROM phone_twitter_follows f
                    WHERE f.follower=a.username AND f.followed=@loggedInAs
            ) AS isFollowingYou
        FROM phone_twitter_follow_requests r
        INNER JOIN phone_twitter_accounts a ON a.username=r.requester
        WHERE r.requestee=@loggedInAs
        ORDER BY r.`timestamp` DESC
        LIMIT @page, @perPage]], {
        ["@loggedInAs"] = username,
        ["@page"] = (page or 0) * 15,
        ["@perPage"] = 15
    }, cb)
end)

-- Accept/decline follow request
RegisterLegacyCallback("birdy:handleFollowRequest", function(source, cb, requester, accept)
    local username = getLoggedInTwitterAccount(source)
    if not username then return cb(false) end

    local ctx = { ["@loggedInAs"] = username, ["@username"] = requester }
    local removed = MySQL.Sync.execute(
        "DELETE FROM phone_twitter_follow_requests WHERE requestee=@loggedInAs AND requester=@username", ctx)
    if removed == 0 then return cb(false) end
    if not accept then return cb(true) end

    MySQL.Sync.execute("INSERT IGNORE INTO phone_twitter_follows (follower, followed) VALUES (@username, @loggedInAs)",
        ctx)

    TriggerClientEvent("phone:twitter:updateProfileData", -1, username, "followers", true)
    TriggerClientEvent("phone:twitter:updateProfileData", -1, requester, "following", true)
    sendTwitterNotification(username, requester, "follow")

    -- notify devices of requester their request was accepted
    for phone, src in pairs(getPhoneNumberToSourceMap(requester)) do
        SendNotification(phone,
            { app = "Twitter", content = L("BACKEND.TWITTER.FOLLOW_REQUEST_ACCEPTED_DESCRIPTION", { username = username }) })
    end

    cb(true)
end)

-- Direct messages
createAuthenticatedCallback("sendMessage", function(source, _, account, recipient, content, attachments)
    if ContainsBlacklistedWord(source, "Birdy", content) then return false end

    local id = GenerateId("phone_twitter_messages", "id")
    local payloadAttachments = attachments and json.encode(attachments) or nil
    local affected = MySQL.update.await(
        [[INSERT INTO phone_twitter_messages (id, sender, recipient, content, attachments)
        VALUES (@id, @sender, @recipient, @content, @attachments)]], {
            ["@id"] = id,
            ["@sender"] = account,
            ["@recipient"] = recipient,
            ["@content"] = content,
            ["@attachments"] = payloadAttachments
        })
    if affected == 0 then return false end

    -- push live message event to recipient devices
    for phone, src in pairs(getPhoneNumberToSourceMap(recipient)) do
        if src then
            TriggerClientEvent("phone:twitter:newMessage", src, {
                sender = account,
                recipient = recipient,
                content = content,
                attachments = attachments,
                timestamp = os.time() * 1000
            })
        end
    end

    -- notification to recipient
    local senderProfile = getTwitterProfile(account) or {}
    for phone, src in pairs(getPhoneNumberToSourceMap(recipient)) do
        SendNotification(phone, {
            source = src,
            app = "Twitter",
            title = senderProfile.name,
            content = content,
            thumbnail = attachments and attachments[1] or nil,
            avatar = senderProfile.profile_picture,
            showAvatar = true
        })
    end

    return true
end, nil, { preventSpam = true, rateLimit = 15 })

RegisterLegacyCallback("birdy:getMessages", function(source, cb, username, page)
    local loggedInAs = getLoggedInTwitterAccount(source)
    if not loggedInAs then return cb({}) end

    MySQL.Async.fetchAll([[SELECT sender, recipient, content, attachments, `timestamp`
        FROM phone_twitter_messages
        WHERE (sender=@loggedInAs AND recipient=@username) OR (sender=@username AND recipient=@loggedInAs)
        ORDER BY `timestamp` DESC
        LIMIT @page, @perPage]], {
        ["@loggedInAs"] = loggedInAs,
        ["@username"] = username,
        ["@page"] = (page or 0) * 25,
        ["@perPage"] = 25
    }, cb)
end)

RegisterLegacyCallback("birdy:getRecentMessages", function(source, cb, page)
    local loggedInAs = getLoggedInTwitterAccount(source)
    if not loggedInAs then return cb({}) end

    MySQL.Async.fetchAll([[SELECT
            m.content, m.attachments, m.sender, f_m.username, m.`timestamp`,
            a.display_name AS `name`, a.profile_image AS profile_picture, a.verified
        FROM phone_twitter_messages m
        JOIN ((
            SELECT (CASE WHEN recipient!=@loggedInAs THEN recipient ELSE sender END) AS username, MAX(`timestamp`) AS `timestamp`
            FROM phone_twitter_messages
            WHERE sender=@loggedInAs OR recipient=@loggedInAs
            GROUP BY username
        ) f_m) ON m.`timestamp`=f_m.`timestamp`
        INNER JOIN phone_twitter_accounts a ON a.username=f_m.username
        WHERE m.sender=@loggedInAs OR m.recipient=@loggedInAs
        GROUP BY f_m.username
        ORDER BY m.`timestamp` DESC
        LIMIT @page, @perPage]], {
        ["@loggedInAs"] = loggedInAs,
        ["@page"] = (page or 0) * 15,
        ["@perPage"] = 15
    }, cb)
end)

-- Trending reset thread
CreateThread(function()
    if not (Config.BirdyTrending and Config.BirdyTrending.Enabled) then return end

    while not DatabaseCheckerFinished do
        Wait(500)
    end

    while true do
        MySQL.Async.execute(
            ("DELETE FROM phone_twitter_hashtags WHERE last_used < DATE_SUB(NOW(), INTERVAL %s HOUR)"):format(tostring((Config.BirdyTrending and Config.BirdyTrending.Reset) or
                24)), {})
        Wait(3600000)
    end
end)
