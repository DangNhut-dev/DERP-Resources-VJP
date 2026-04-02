-- Cache for pending album shares
local pendingAlbumShares = {}

-- Callback for sharing content via AirShare
BaseCallback("airShare:share", function(source, phoneNumber, targetSource, targetDevice, shareData)
    -- Get sender's phone name
    local senderName = Player(source).state.phoneName
    if not senderName then
        debugprint("No sender name")
        return false
    end
    
    -- Create sender info
    local senderInfo = {
        name = senderName,
        source = source,
        device = "phone"
    }
    shareData.sender = senderInfo
    
    -- Handle different target devices
    if targetDevice == "tablet" then
        -- Check if tablet resource is available
        if GetResourceState("lb-tablet") == "started" then
            -- Check if target has tablet open
            if Player(targetSource).state.lbTabletOpen then
                TriggerClientEvent("tablet:airShare:received", targetSource, shareData)
            else
                return false
            end
        else
            return false
        end
    elseif targetDevice == "phone" then
        -- Check if target phone is open
        if not Player(targetSource).state.phoneOpen then
            debugprint("sendToSource's phone is not open")
            return false
        end
        
        TriggerClientEvent("phone:airShare:received", targetSource, shareData)
    end
    
    -- Handle album sharing (requires confirmation)
    if shareData.type == "album" then
        -- Initialize pending shares for target if needed
        if not pendingAlbumShares[targetSource] then
            pendingAlbumShares[targetSource] = {}
        end
        
        -- Store the album ID for confirmation
        pendingAlbumShares[targetSource][source] = shareData.album.id
    end
    
    return true
end, false)
-- Handle AirShare interaction responses (accept/deny)
RegisterNetEvent("phone:airShare:interacted", function(senderSource, senderDevice, accepted)
    local targetSource = source
    
    -- Validate parameters
    if type(senderSource) ~= "number" or type(senderDevice) ~= "string" then
        debugprint("AirShare:interacted: Invalid senderSource or senderDevice", senderSource, senderDevice)
        return
    end
    
    -- Notify the sender about the interaction
    if senderDevice == "tablet" then
        TriggerClientEvent("tablet:airShare:interacted", senderSource, targetSource, accepted)
    elseif senderDevice == "phone" then
        TriggerClientEvent("phone:airShare:interacted", senderSource, targetSource, accepted)
    end
    
    -- Handle album share confirmation
    if pendingAlbumShares[targetSource] and pendingAlbumShares[targetSource][senderSource] then
        local albumId = pendingAlbumShares[targetSource][senderSource]
        
        -- Clean up the pending share
        pendingAlbumShares[targetSource][senderSource] = nil
        if not next(pendingAlbumShares[targetSource]) then
            pendingAlbumShares[targetSource] = nil
        end
        
        if not accepted then
            debugprint("AirShare: denied album share", albumId)
            return
        end
        
        debugprint("AirShare: accepted album share", albumId)
        HandleAcceptAirShareAlbum(targetSource, senderSource, albumId)
    end
end)
-- Supported share types
local supportedShareTypes = {
    image = true,
    contact = true,
    location = true,
    note = true,
    voicememo = true
}

-- Export function for external AirShare usage
exports("AirShare", function(senderSource, targetSource, shareType, shareData)
    -- Validate parameters
    assert(type(senderSource) == "number", "Invalid sender")
    assert(type(targetSource) == "number", "Invalid target")
    assert(supportedShareTypes[shareType], "Invalid shareType")
    assert(type(shareData) == "table", "Invalid data")
    
    -- Check if sender has a phone equipped
    local phoneNumber = GetEquippedPhoneNumber(senderSource)
    if not phoneNumber then
        return false
    end
    
    -- Create share data structure
    local sharePacket = {
        type = shareType
    }
    
    -- Create sender info
    local senderName = Player(senderSource).state.phoneName
    if not senderName then
        senderName = phoneNumber
    end
    
    sharePacket.sender = {
        name = senderName,
        source = senderSource,
        device = "phone"
    }
    
    -- Validate and process different share types
    if shareType == "image" then
        sharePacket.attachment = shareData
        assert(shareData.src, "Invalid image data (missing src)")
        
        -- Add timestamp if not present
        if not sharePacket.attachment.timestamp then
            sharePacket.attachment.timestamp = os.time() * 1000
        end
        
    elseif shareType == "contact" then
        sharePacket.contact = shareData
        assert(type(sharePacket.contact.number) == "string", "Invalid/missing contact data (contact.number)")
        assert(type(sharePacket.contact.firstname) == "string", "Invalid/missing contact data (contact.firstname)")
        
    elseif shareType == "location" then
        assert(shareData.location, "Invalid location data (missing location)")
        assert(type(shareData.name) == "string", "Invalid/missing location data (location.name)")
        
        sharePacket.location = shareData.location
        sharePacket.name = shareData.name
        
    elseif shareType == "note" then
        sharePacket.note = shareData
        assert(type(sharePacket.note.title) == "string", "Invalid/missing note data (note.title)")
        assert(type(sharePacket.note.content) == "string", "Invalid/missing note data (note.content)")
        
    elseif shareType == "voicememo" then
        sharePacket.voicememo = shareData
        assert(type(sharePacket.voicememo.title) == "string", "Invalid/missing voicememo data (voicememo.title)")
        assert(type(sharePacket.voicememo.src) == "string", "Invalid/missing voicememo data (voicememo.src)")
        assert(type(sharePacket.voicememo.duration) == "number", "Invalid/missing voicememo data (voicememo.duration)")
    end
    
    -- Send to target
    TriggerClientEvent("phone:airShare:received", targetSource, sharePacket)
end)
-- Clean up pending shares when player disconnects
AddEventHandler("playerDropped", function()
    local playerSource = source
    pendingAlbumShares[playerSource] = nil
end)
