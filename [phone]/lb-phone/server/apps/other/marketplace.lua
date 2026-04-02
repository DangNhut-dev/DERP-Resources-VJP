-- Marketplace app server-side functionality
-- Handles marketplace posts, search, creation, and deletion

local POSTS_PER_PAGE = 15

-- Function to get marketplace posts with pagination and filtering
local function GetMarketplacePosts(page, filters)
    if not page then
        page = 0
    end
    
    local params = {}
    local whereConditions = {}
    
    -- Handle search functionality
    if filters and filters.search then
        table.insert(whereConditions, "(title LIKE ? OR description LIKE ?)")
        table.insert(params, "%" .. filters.search .. "%")
        table.insert(params, "%" .. filters.search .. "%")
        
        -- Also search by phone number if not filtering by specific user
        if not filters.from then
            table.insert(whereConditions, "OR phone_number LIKE ?")
            table.insert(params, "%" .. filters.search .. "%")
        end
    end
    
    -- Handle filtering by specific user
    if filters and filters.from then
        local condition = "phone_number = ?"
        if #whereConditions > 0 then
            condition = "AND " .. condition
        end
        table.insert(whereConditions, condition)
        table.insert(params, filters.from)
    end
    
    -- Build the SQL query
    local query = [[
        SELECT
            id,
            phone_number AS `number`,
            title,
            description,
            attachments,
            price,
            `timestamp`
        FROM
            phone_marketplace_posts
        {WHERE}
        ORDER BY
            `timestamp` DESC
        LIMIT ?, ?
    ]]
    
    -- Replace WHERE placeholder
    local whereClause = ""
    if #whereConditions > 0 then
        whereClause = "WHERE " .. table.concat(whereConditions, " ")
    end
    query = query:gsub("{WHERE}", whereClause)
    
    -- Add pagination parameters
    table.insert(params, (page or 0) * POSTS_PER_PAGE)
    table.insert(params, POSTS_PER_PAGE)
    
    return MySQL.query.await(query, params)
end

-- Callback to get marketplace posts
BaseCallback("marketplace:getPosts", function(source, phoneNumber, data)
    return GetMarketplacePosts(data.page, {
        from = data.from,
        search = data.query
    })
end)

-- Callback to create a new marketplace post
BaseCallback("marketplace:createPost", function(source, phoneNumber, postData)
    local title = postData.title
    local description = postData.description
    local attachments = postData.attachments
    local price = postData.price
    
    -- Validate required fields
    if not (title and description and attachments and price) or price < 0 then
        return false
    end
    
    -- Check for blacklisted words in title and description
    if ContainsBlacklistedWord(source, "MarketPlace", title) or 
       ContainsBlacklistedWord(source, "MarketPlace", description) then
        return false
    end
    
    -- Insert post into database
    local postId = MySQL.insert.await("INSERT INTO phone_marketplace_posts (phone_number, title, description, attachments, price) VALUES (?, ?, ?, ?, ?)", {
        phoneNumber,
        title,
        description,
        json.encode(attachments),
        price
    })
    
    if not postId then
        return false
    end
    
    -- Add post ID and phone number to the data
    postData.number = phoneNumber
    postData.id = postId
    
    -- Notify all clients about new post
    TriggerClientEvent("phone:marketplace:newPost", -1, postData)
    
    -- Trigger server event for other resources
    TriggerEvent("lb-phone:marketplace:newPost", postData)
    
    -- Log the marketplace post creation
    Log("Marketplace", source, "info", 
        L("BACKEND.LOGS.MARKETPLACE_NEW_TITLE"),
        L("BACKEND.LOGS.MARKETPLACE_NEW_DESCRIPTION", {
            seller = FormatNumber(phoneNumber),
            title = title,
            price = price,
            description = description,
            attachments = json.encode(attachments),
            id = postId
        })
    )
    
    return postId
end)

-- Callback to delete a marketplace post
BaseCallback("marketplace:deletePost", function(source, phoneNumber, postId)
    local isAdmin = IsAdmin(source)
    local params = {postId}
    local query = "DELETE FROM phone_marketplace_posts WHERE id = ?"
    
    -- If not admin, also check phone number ownership
    if not isAdmin then
        query = query .. " AND phone_number = ?"
        table.insert(params, phoneNumber)
    end
    
    local deleted = MySQL.update.await(query, params)
    
    if deleted > 0 then
        -- Log the deletion
        Log("Marketplace", source, "error",
            L("BACKEND.LOGS.MARKETPLACE_DELETED"),
            string.format("**ID**: %s", postId)
        )
        return true
    end
    
    return false
end)
