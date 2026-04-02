-- Marketplace App for LB Phone
-- Handles marketplace posts, buying/selling items

-- Register NUI callback for Marketplace actions
RegisterNUICallback("MarketPlace", function(data, callback)
    local action = data.action
    
    debugprint("MarketPlace:" .. (action or ""))
    
    if action == "getPosts" then
        -- Get marketplace posts
        local posts = AwaitCallback("marketplace:getPosts", data)
        
        -- Decode JSON attachments for each post
        for i = 1, #posts do
            local post = posts[i]
            if post.attachments then
                post.attachments = json.decode(post.attachments)
            end
        end
        
        callback(posts)
        
    elseif action == "sendPost" then
        -- Create new marketplace post
        TriggerCallback("marketplace:createPost", callback, data.data)
        
    elseif action == "deletePost" then
        -- Delete existing post
        TriggerCallback("marketplace:deletePost", callback, data.id)
    end
end)

-- Handle new marketplace post notifications from server
RegisterNetEvent("phone:marketplace:newPost", function(postData)
    -- Trigger local event for other scripts
    TriggerEvent("lb-phone:marketplace:newPost", postData)
    
    -- Send to React UI
    SendReactMessage("marketPlace:newPost", postData)
end)