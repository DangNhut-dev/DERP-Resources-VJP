-- Statistics tracking system for phone resource
-- Tracks usage events and sends analytics data

-- Get resource version
local version = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
if not version then
    version = "0.0.0"
end

-- Check if using custom UI (not default dist)
local isCustomUI = GetResourceMetadata(GetCurrentResourceName(), "ui_page", 0) ~= "ui/dist/index.html"

-- Configuration
local maxEventsBeforeSend = 25
local videoExtensions = {"webm", "mp4", "mov"}
local events = {}
local eventCount = 0
local serverId = nil

-- Validate version format
if not version:match("^%d+%.%d+%.%d+$") then
    version = "0.0.0"
end

-- Function to send statistics to tracking server
local function SendStatistics(forceFlush)
    -- Don't send if we haven't reached the threshold and not forcing
    if not forceFlush and eventCount < maxEventsBeforeSend then
        return
    end
    
    -- Don't send if no events to send
    if eventCount == 0 then
        return
    end
    
    -- Get server ID from web_baseUrl if not cached
    if not serverId then
        local baseUrl = GetConvar("web_baseUrl", "")
        if baseUrl == "" then
            return
        end
        
        -- Extract server ID from CFX.re URL
        local urlLength = #baseUrl
        local reversedUrl = baseUrl:reverse()
        local dashPos = reversedUrl:find("-")
        
        if not dashPos then
            dashPos = #baseUrl + 1
        end
        
        local startPos = urlLength - dashPos + 2
        local endPos = #baseUrl - #".users.cfx.re"
        
        serverId = string.sub(baseUrl, startPos, endPos)
    end
    
    -- Prepare payload
    local payload = json.encode({
        serverId = serverId,
        version = version,
        events = events
    })
    
    -- Reset counters and events
    eventCount = 0
    events = {}
    
    -- Send to tracking server
    PerformHttpRequest("https://track.lbscripts.com/", function()
        -- Empty callback - fire and forget
    end, "POST", payload, {
        ["Content-Type"] = "application/json"
    })
end

-- Function to track simple events
function TrackSimpleEvent(eventName)
    -- Don't track if using custom UI
    if isCustomUI then
        return
    end
    
    eventCount = eventCount + 1
    events[eventCount] = {
        event = eventName
    }
    
    SendStatistics()
end

-- Function to track social media posts with media analysis
function TrackSocialMediaPost(appName, mediaFiles)
    -- Don't track if using custom UI
    if isCustomUI then
        return
    end
    
    local photoCount = 0
    local videoCount = 0
    
    -- Analyze media files if provided
    if mediaFiles then
        for i = 1, #mediaFiles do
            local file = mediaFiles[i]
            local extension = file:match("%.([^.]+)$")
            
            if not extension then
                extension = "webp"  -- Default assumption
            end
            
            -- Check if it's a video file
            if table.contains(videoExtensions, extension) then
                videoCount = videoCount + 1
            else
                photoCount = photoCount + 1
            end
        end
    end
    
    eventCount = eventCount + 1
    events[eventCount] = {
        event = "social_media_post",
        app = appName,
        amountVideos = videoCount,
        amountPhotos = photoCount
    }
    
    SendStatistics()
end

-- Send statistics before scheduled restart (1 minute warning)
AddEventHandler("txAdmin:events:scheduledRestart", function(eventData)
    if eventData.secondsRemaining == 60 then
        SendStatistics(true)
    end
end)

-- Send statistics on server shutdown
AddEventHandler("txAdmin:events:serverShuttingDown", function()
    SendStatistics(true)
end)

-- Send statistics when resource stops
AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        SendStatistics(true)
    end
end)
