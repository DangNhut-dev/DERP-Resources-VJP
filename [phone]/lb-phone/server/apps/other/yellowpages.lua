-- Yellow Pages app server-side functionality
-- Handles yellow pages posts, search, creation, and deletion

local POSTS_PER_PAGE = 10

-- Callback to get yellow pages posts with pagination and filtering
BaseCallback("yellowPages:getPosts", function(source, phoneNumber, page, filters)
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
            attachment,
            price,
            `timestamp`
        FROM
            phone_yellow_pages_posts
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
end)

-- Callback to create a new yellow pages post
BaseCallback("yellowPages:createPost", function(source, phoneNumber, postData)
    -- Validate required fields
    if not (postData and postData.title and postData.description) then
        return false
    end
    
    -- Check for blacklisted words in title and description
    if ContainsBlacklistedWord(source, "Pages", postData.title) or 
       ContainsBlacklistedWord(source, "Pages", postData.description) then
        return false
    end
    
    -- Insert post into database
    local postId = MySQL.insert.await("INSERT INTO phone_yellow_pages_posts (phone_number, title, description, attachment, price) VALUES (@number, @title, @description, @attachment, @price)", {
        ["@number"] = phoneNumber,
        ["@title"] = postData.title,
        ["@description"] = postData.description,
        ["@attachment"] = postData.attachment,
        ["@price"] = tonumber(postData.price)
    })
    
    if not postId then
        return false
    end
    
    -- Add post ID and phone number to the data
    postData.id = postId
    postData.number = phoneNumber
    
    -- Notify all clients about new post
    TriggerClientEvent("phone:yellowPages:newPost", -1, postData)
    
    -- Trigger server event for other resources
    TriggerEvent("lb-phone:pages:newPost", postData)
    
    -- Log the yellow pages post creation
    Log("YellowPages", source, "info",
        L("BACKEND.LOGS.YELLOWPAGES_NEW_TITLE"),
        L("BACKEND.LOGS.YELLOWPAGES_NEW_DESCRIPTION", {
            title = postData.title,
            description = postData.description,
            attachment = postData.attachment or "",
            id = postData.id
        })
    )
    
    return postId
end)

-- Callback to delete a yellow pages post
BaseCallback("yellowPages:deletePost", function(source, phoneNumber, postId)
    local isAdmin = IsAdmin(source)
    local query = "DELETE FROM phone_yellow_pages_posts WHERE id = @id"
    
    -- If not admin, also check phone number ownership
    if not isAdmin then
        query = query .. " AND phone_number = @number"
    end
    
    local deleted = MySQL.update.await(query, {
        ["@id"] = postId,
        ["@number"] = phoneNumber
    })
    
    if deleted > 0 then
        -- Log the deletion
        Log("YellowPages", source, "error",
            L("BACKEND.LOGS.YELLOWPAGES_DELETED"),
            string.format("**ID**: %s", postId)
        )
    end
    
    return true
end)
