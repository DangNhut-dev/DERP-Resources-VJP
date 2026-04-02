-- Yellow Pages App for LB Phone
-- Handles yellow pages posts, search, and notifications

-- Register NUI callback for Yellow Pages actions
RegisterNUICallback("YellowPages", function(data, callback)
    local action = data.action
    
    debugprint("Pages:" .. (action or ""))
    
    if action == "getPosts" then
        -- Get posts with pagination and search
        local searchData = {
            search = data.query
        }
        TriggerCallback("yellowPages:getPosts", callback, data.page, searchData)
        
    elseif action == "sendPost" then
        -- Create new yellow pages post
        TriggerCallback("yellowPages:createPost", callback, data.data)
        
    elseif action == "deletePost" then
        -- Delete existing post
        TriggerCallback("yellowPages:deletePost", callback, data.id)
    end
end)

-- Handle new post notifications from server
RegisterNetEvent("phone:yellowPages:newPost", function(postData)
    -- Trigger local event for other scripts
    TriggerEvent("lb-phone:pages:newPost", postData)
    
    -- Send to React UI
    SendReactMessage("yellowPages:newPost", postData)
end)