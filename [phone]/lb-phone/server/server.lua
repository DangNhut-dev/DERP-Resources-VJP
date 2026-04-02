-- LB Phone Server - Main server-side functionality
-- Handles phone management, settings, and player interactions

-- Storage for active phone connections and settings
local activePhones = {}  -- Maps phone numbers to player sources
local phoneSettings = {}  -- Cached phone settings
local settingsChanged = {}  -- Track which settings need database updates

-- Generate random string for IDs
function GenerateString(length)
    local result = ""
    local targetLength = length or 15
    
    for i = 1, targetLength do
        if math.random(1, 2) == 1 then
            -- Generate random letter
            local char = string.char(math.random(97, 122))
            -- Randomly uppercase
            if math.random(1, 2) == 1 then
                char = char:upper()
            end
            result = result .. char
        else
            -- Generate random number
            result = result .. math.random(1, 9)
        end
    end
    
    return result
end

-- Generate unique ID for database table
function GenerateId(tableName, columnName)
    local isUnique = false
    local generatedId = nil
    
    while not isUnique do
        generatedId = GenerateString(5)
        local query = string.format("SELECT `%s` FROM `%s` WHERE `%s` = @id", columnName, tableName, columnName)
        local result = MySQL.Sync.fetchScalar(query, {["@id"] = generatedId})
        isUnique = (result == nil)
        
        if not isUnique then
            Wait(50)
        end
    end
    
    return generatedId
end

-- Generate unique phone number based on config
local function GeneratePhoneNumber()
    local prefixes = Config.PhoneNumber.Prefixes
    local isUnique = false
    local phoneNumber = nil
    
    while not isUnique do
        -- Generate random number part
        local numberPart = ""
        for i = 1, Config.PhoneNumber.Length do
            numberPart = numberPart .. math.random(0, 9)
        end
        
        -- Add prefix if configured
        if #prefixes == 0 then
            phoneNumber = numberPart
        else
            local randomPrefix = prefixes[math.random(1, #prefixes)]
            phoneNumber = randomPrefix .. numberPart
        end
        
        -- Check if number already exists
        local existingNumber = MySQL.Sync.fetchScalar(
            "SELECT phone_number FROM phone_phones WHERE phone_number = @number",
            {["@number"] = phoneNumber}
        )
        
        isUnique = (existingNumber == nil)
        if not isUnique then
            Wait(0)
        end
    end
    
    return phoneNumber
end

-- Settings management functions
function GetSettings(phoneNumber)
    return phoneSettings[phoneNumber]
end

-- Export GetSettings function
exports("GetSettings", GetSettings)

local function SetSettings(phoneNumber, settings)
    if not settings then
        if phoneSettings[phoneNumber] then
            phoneSettings[phoneNumber] = nil
            if Config.CacheSettings then
                debugprint("Updating settings in database for", phoneNumber)
                MySQL.update("UPDATE phone_phones SET settings = ? WHERE phone_number = ?", {json.encode(phoneSettings[phoneNumber]), phoneNumber})
            end
        end
        return
    end
    phoneSettings[phoneNumber] = settings
end

local function SaveAllSettings()
    if not Config.CacheSettings then
        return
    end
    infoprint("info", "Saving all settings")
    
    for phoneNumber, settings in pairs(phoneSettings) do
        if settingsChanged[phoneNumber] then
            MySQL.update("UPDATE phone_phones SET settings = ? WHERE phone_number = ?", {json.encode(settings), phoneNumber})
        else
            debugprint("Not saving settings for", phoneNumber, "because no changes were made")
        end
    end
end

-- Player loaded callback
RegisterLegacyCallback("playerLoaded", function(source, callback)
    local playerId = GetIdentifier(source)
    debugprint(GetPlayerName(source), source, playerId, "triggered phone:playerLoaded")
    
    if not Config.Item.Unique then
        local phoneNumber = MySQL.scalar.await("SELECT phone_number FROM phone_phones WHERE id = ?", {playerId})
        if phoneNumber then
            if HasPhoneItem(source, phoneNumber) then
                activePhones[phoneNumber] = source
                MySQL.update("UPDATE phone_phones SET last_seen = CURRENT_TIMESTAMP WHERE phone_number = ?", {phoneNumber})
            end
        end
        return callback(phoneNumber)
    end
    
    local lastPhone = MySQL.scalar.await("SELECT phone_number FROM phone_last_phone WHERE id = ?", {playerId})
    debugprint("result from phone_last_phone: ", lastPhone)
    if lastPhone then
        debugprint("checking if " .. source .. " has phone with metadata for last phone number equipped")
        if HasPhoneItem(source, lastPhone) then
            debugprint(source .. " has phone with metadata")
            activePhones[lastPhone] = source
            MySQL.update("UPDATE phone_phones SET last_seen = CURRENT_TIMESTAMP WHERE phone_number = ?", {lastPhone})
            return callback(lastPhone)
        end
        debugprint(source .. " doesn't have phone with metadata for last phone number equipped")
        return callback()
    end
    
    debugprint("checking if " .. source .. " has an empty phone")
    if not HasPhoneItem(source) then
        debugprint(source .. " does not have an empty phone")
        return callback()
    end
    
    debugprint(source .. " does have an empty phone, checking if they have an existing phone from pre-unique phone")
    local existingPhone = MySQL.scalar.await("SELECT phone_number FROM phone_phones WHERE id = ? AND assigned = FALSE", {playerId})
    if existingPhone then
        if SetPhoneNumber(source, existingPhone) then
            debugprint(source .. " does have an existing phone from pre-unique phone")
            MySQL.update("UPDATE phone_phones SET assigned = TRUE, last_seen = CURRENT_TIMESTAMP WHERE phone_number = ?", {existingPhone})
            MySQL.update("INSERT INTO phone_last_phone (id, phone_number) VALUES (?, ?)", {playerId, existingPhone})
            activePhones[existingPhone] = source
            return callback(existingPhone)
        end
    end
    
    debugprint(source .. " does not have an existing phone from pre-unique phone, or failed to set number to item metadata")
    return callback()
end)

-- Set last phone callback
RegisterLegacyCallback("setLastPhone", function(source, callback, phoneNumber)
    local playerId = GetIdentifier(source)
    local currentPhoneNumber = GetEquippedPhoneNumber(source)
    SaveBattery(source)
    
    if not phoneNumber then
        MySQL.update("DELETE FROM phone_last_phone WHERE id = ?", {playerId})
        if currentPhoneNumber then
            activePhones[currentPhoneNumber] = nil
            local player = Player(source)
            player.state.phoneOpen = false
            player.state.phoneName = nil
            player.state.phoneNumber = nil
            local settings = GetSettings(currentPhoneNumber)
            if settings then
                SetSettings(currentPhoneNumber, nil)
            end
        end
        return callback()
    end
    
    if activePhones[phoneNumber] then
        if activePhones[phoneNumber] ~= source then
            return callback()
        end
    end
    
    local phoneExists = MySQL.scalar.await("SELECT 1 FROM phone_phones WHERE phone_number = ?", {phoneNumber})
    if not phoneExists then
        infoprint("warning", GetPlayerName(source) .. " | " .. source .. " tried to use a phone with a number that doesn't exist. This usually happens when you delete the phone from phone_phones, without deleting the phone item from the player's inventory. Phone number: " .. phoneNumber)
        return callback()
    end
    
    MySQL.update.await("INSERT INTO phone_last_phone (id, phone_number) VALUES (?, ?) ON DUPLICATE KEY UPDATE phone_number = ?", {playerId, phoneNumber, phoneNumber})
    if currentPhoneNumber then
        activePhones[currentPhoneNumber] = nil
        local settings = GetSettings(currentPhoneNumber)
        if settings then
            SetSettings(currentPhoneNumber, nil)
        end
    end
    activePhones[phoneNumber] = source
    callback()
end)

-- Generate phone number callback
RegisterLegacyCallback("generatePhoneNumber", function(source, callback)
    local playerId = GetIdentifier(source)
    debugprint(GetPlayerName(source), source, playerId, "wants to generate a phone number")
    
    if Config.Item.Unique then
        debugprint("unique phones enabled, checking if " .. GetPlayerName(source) .. " has a phone item without a number assigned")
        if not HasPhoneItem(source) then
            debugprint(GetPlayerName(source) .. " does not have a phone item without a number assigned")
            return callback()
        end
        
        local generatedId = GenerateId("phone_phones", "id")
        playerId = generatedId
    else
        local phoneNumber = MySQL.scalar.await("SELECT phone_number FROM phone_phones WHERE id = ?", {playerId})
        if phoneNumber then
            infoprint("warning", GetPlayerName(source) .. " wants to generate a phone number, but they already have one. Please set Config.Debug to true, and send the full log in customer-support if this happens again.")
            activePhones[phoneNumber] = source
            return callback(phoneNumber)
        end
    end
    
    local phoneNumber = GeneratePhoneNumber()
    MySQL.update.await("INSERT INTO phone_phones (id, owner_id, phone_number) VALUES (?, ?, ?)", {playerId, playerId, phoneNumber})
    TriggerEvent("lb-phone:phoneNumberGenerated", source, phoneNumber)
    
    if Config.Item.Unique then
        SetPhoneNumber(source, phoneNumber)
        MySQL.update.await("UPDATE phone_phones SET assigned = TRUE WHERE phone_number = ?", {phoneNumber})
        MySQL.update.await("INSERT INTO phone_last_phone (id, phone_number) VALUES (?, ?) ON DUPLICATE KEY UPDATE phone_number = ?", {GetIdentifier(source), phoneNumber, phoneNumber})
    end
    
    activePhones[phoneNumber] = source
    callback(phoneNumber)
end)

-- Get phone callback
RegisterLegacyCallback("getPhone", function(source, callback, phoneNumber)
    debugprint(GetPlayerName(source), "triggered phone:getPhone. checking if they have an item")
    
    if not HasPhoneItem(source, phoneNumber) then
        debugprint(GetPlayerName(source), "does not have an item")
        return callback()
    end
    
    debugprint(GetPlayerName(source), "has an item, getting phone data")
    local phoneData = MySQL.single.await("SELECT owner_id, is_setup, settings, `name`, battery FROM phone_phones WHERE phone_number = ?", {phoneNumber})
    
    if not phoneData then
        debugprint(GetPlayerName(source), "does not have any phone data")
        return callback()
    end
    
    if phoneData.settings then
        local cachedSettings = GetSettings(phoneNumber)
        local settings = cachedSettings or json.decode(phoneData.settings)
        phoneData.settings = settings
        if not cachedSettings then
            SetSettings(phoneNumber, phoneData.settings)
        end
    end
    
    debugprint(GetPlayerName(source), "has phone data")
    
    if not phoneData.owner_id then
        debugprint(GetPlayerName(source) .. "'s phone does not have an owner, setting owner to " .. GetIdentifier(source))
        MySQL.update("UPDATE phone_phones SET owner_id = ? WHERE phone_number = ?", {GetIdentifier(source), phoneNumber})
    end
    
    return callback(phoneData)
end)

-- Get equipped phone number for source
function GetEquippedPhoneNumber(source, callback)
    for phoneNumber, playerSource in pairs(activePhones) do
        if playerSource == source then
            if callback then
                callback(phoneNumber)
            end
            return phoneNumber
        end
    end
end

-- Get source from phone number
function GetSourceFromNumber(phoneNumber)
    if not phoneNumber then
        return false
    end
    return activePhones[phoneNumber] or false
end

exports("GetSourceFromNumber", GetSourceFromNumber)

-- Admin check callback
RegisterLegacyCallback("isAdmin", function(source, callback)
    callback(IsAdmin(source))
end)

-- Get character name callback
RegisterLegacyCallback("getCharacterName", function(source, callback)
    local firstname, lastname = GetCharacterName(source)
    callback({
        firstname = firstname,
        lastname = lastname
    })
end)

-- Version check
local latestVersion = nil
PerformHttpRequest("https://loaf-scripts.com/versions/phone/version.json", function(status, body, headers, error)
    if status ~= 200 then
        debugprint("Failed to get latest script version")
        debugprint("Status:", status)
        debugprint("Body:", body)
        debugprint("Headers:", headers)
        debugprint("Error:", error)
        return
    end
    
    local data = json.decode(body)
    latestVersion = data.latest
end, "GET")

RegisterCallback("getLatestVersion", function()
    return latestVersion
end)

-- Phone setup finished event
RegisterNetEvent("phone:finishedSetup", function(settings)
    local source = source
    local phoneNumber = GetEquippedPhoneNumber(source)
    if not phoneNumber then
        return
    end
    
    SetSettings(phoneNumber, settings)
    MySQL.update("UPDATE phone_phones SET is_setup = true, settings = ? WHERE phone_number = ?", {json.encode(settings), phoneNumber})
    
    if Config.AutoCreateEmail then
        GenerateEmailAccount(source, phoneNumber)
    end
end)

-- Set phone name event
RegisterNetEvent("phone:setName", function(name)
    local source = source
    local phoneNumber = GetEquippedPhoneNumber(source)
    if not phoneNumber then
        return
    end
    
    if Config.NameFilter then
        if not name:match(Config.NameFilter) then
            infoprint("warning", "Player " .. GetPlayerName(source) .. " tried to set an invalid phone name: " .. name)
            local firstname, lastname = GetCharacterName(source)
            name = L("BACKEND.MISC.X_PHONE", {name = firstname, lastname = lastname})
        end
    end
    
    MySQL.Async.execute("UPDATE phone_phones SET `name`=@name WHERE phone_number=@phoneNumber", {
        ["@phoneNumber"] = phoneNumber,
        ["@name"] = name
    })
    
    if Config.Item.Unique then
        if SetItemName then
            SetItemName(source, phoneNumber, name)
        end
    end
    
    local settings = GetSettings(phoneNumber)
    if settings then
        settings.name = name
    end
    
    local player = Player(source)
    player.state.phoneName = name
end)

-- Set settings callback
BaseCallback("setSettings", function(source, phoneNumber, settings)
    debugprint(source, "saving settings for phone number", phoneNumber)
    settingsChanged[phoneNumber] = true
    SetSettings(phoneNumber, settings)
    
    if not Config.CacheSettings then
        MySQL.update("UPDATE phone_phones SET settings = ? WHERE phone_number = ?", {json.encode(settings), phoneNumber})
    end
end)

-- Toggle phone event
RegisterNetEvent("phone:togglePhone", function(isOpen, phoneName)
    local source = source
    local player = Player(source)
    player.state.phoneOpen = isOpen
    
    local phoneNumber = GetEquippedPhoneNumber(source)
    if not phoneNumber then
        return
    end
    
    player.state.phoneName = phoneName
    player.state.phoneNumber = phoneNumber
end)

-- Toggle flashlight event
RegisterNetEvent("phone:toggleFlashlight", function(enabled)
    local player = Player(source)
    player.state.flashlight = enabled
end)

-- Phone objects management
local phoneObjects = {}

RegisterNetEvent("phone:setPhoneObject", function(netId)
    local source = source
    if Config.ServerSideSpawn and not netId then
        local existingObject = phoneObjects[source]
        if existingObject then
            debugprint("Deleting phone object for player " .. source)
            DeleteEntity(NetworkGetEntityFromNetworkId(existingObject))
        end
    end
    phoneObjects[source] = netId
end)

-- Player dropped event
AddEventHandler("playerDropped", function()
    local source = source
    local phoneObject = phoneObjects[source]
    local phoneNumber = GetEquippedPhoneNumber(source)
    
    if phoneObject then
        local entity = NetworkGetEntityFromNetworkId(phoneObject)
        if entity then
            DeleteEntity(entity)
        end
        phoneObjects[source] = nil
    end
    
    if phoneNumber then
        Wait(1000)
        SetSettings(phoneNumber, nil)
        activePhones[phoneNumber] = nil
    end
end)

-- Resource stop event
AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end
    
    for source, netId in pairs(phoneObjects) do
        local entity = NetworkGetEntityFromNetworkId(netId)
        if entity then
            DeleteEntity(entity)
        end
    end
    
    SaveAllSettings()
end)

-- Server shutdown event
AddEventHandler("txAdmin:events:serverShuttingDown", function()
    SaveAllSettings()
end)

-- Factory reset function
local function FactoryReset(phoneNumber)
    MySQL.update.await("DELETE FROM phone_logged_in_accounts WHERE phone_number = ?", {phoneNumber})
    local affected = MySQL.update.await("UPDATE phone_phones SET is_setup = false, settings = NULL, pin = NULL, face_id = NULL WHERE phone_number = ?", {phoneNumber})
    
    if affected > 0 then
        local source = activePhones[phoneNumber]
        if source then
            TriggerClientEvent("phone:factoryReset", source)
            SetSettings(phoneNumber, nil)
            activePhones[phoneNumber] = nil
        end
    end
end

-- Factory reset event
RegisterNetEvent("phone:factoryReset", function()
    local phoneNumber = GetEquippedPhoneNumber(source)
    if not phoneNumber then
        return
    end
    FactoryReset(phoneNumber)
end)

exports("FactoryReset", FactoryReset)

RegisterNetEvent('lb-phone:debugSlots', function(data)
    print('[DEBUG PHONE SLOTS]: ' .. tostring(data))
end)