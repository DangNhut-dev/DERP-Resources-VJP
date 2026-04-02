-- Crypto App for LB Phone
-- Handles cryptocurrency trading and portfolio management

-- Check if crypto is enabled in config
if not (Config.Crypto and Config.Crypto.Enabled) then
    return
end

local cryptoData = {}
local isUpdating = false

-- Function to find crypto by ID
local function findCryptoById(cryptoId)
    for i = 1, #cryptoData do
        local crypto = cryptoData[i]
        if crypto.id == cryptoId then
            return i, crypto
        end
    end
    return false
end

-- Function to update QBit crypto data
local function updateQBitData()
    if not (Config.Crypto.QBit and Config.Framework == "qb") then
        return
    end
    
    local index = findCryptoById("qbit")
    if not index then
        index = #cryptoData + 1
    end
    
    local qbitData = GetQBit()
    local history = {}
    
    -- Process history data
    for i = 1, #qbitData.History do
        table.insert(history, qbitData.History[i].PreviousWorth)
        table.insert(history, qbitData.History[i].NewWorth)
    end
    
    -- Generate fake history if none exists
    if #qbitData.History == 0 then
        for i = 1, 10 do
            local randomChange = math.random(-10, 10)
            table.insert(history, qbitData.Worth + randomChange)
        end
    end
    
    cryptoData[index] = {
        id = "qbit",
        name = "QBit",
        price = qbitData.Worth,
        history = history,
        owned = qbitData.Crypto or 0,
        change = 0 -- Calculate from history if needed
    }
end

-- Function to update all crypto data
local function updateCryptoData()
    if isUpdating then return end
    isUpdating = true
    
    -- Update QBit if enabled
    updateQBitData()
    
    -- Get other crypto data from server
    local serverCryptos = AwaitCallback("crypto:getCryptos")
    if serverCryptos then
        for _, crypto in pairs(serverCryptos) do
            local index = findCryptoById(crypto.id)
            if not index then
                index = #cryptoData + 1
            end
            cryptoData[index] = crypto
        end
    end
    
    isUpdating = false
end

-- Register NUI callback for Crypto actions
RegisterNUICallback("Crypto", function(data, callback)
    local action = data.action
    
    debugprint("Crypto:" .. (action or ""))
    
    if action == "getCryptos" then
        updateCryptoData()
        callback(cryptoData)
        
    elseif action == "buyCrypto" then
        TriggerCallback("crypto:buyCrypto", callback, data.cryptoId, data.amount)
        
    elseif action == "sellCrypto" then
        TriggerCallback("crypto:sellCrypto", callback, data.cryptoId, data.amount)
        
    elseif action == "getCryptoHistory" then
        local _, crypto = findCryptoById(data.cryptoId)
        if crypto then
            callback(crypto.history or {})
        else
            callback({})
        end
    end
end)

-- Handle crypto updates from server
RegisterNetEvent("phone:crypto:update", function(cryptoId, newData)
    local index = findCryptoById(cryptoId)
    if index then
        cryptoData[index] = newData
        SendReactMessage("crypto:update", newData)
    end
end)

-- Initialize crypto data on resource start
CreateThread(function()
    Wait(1000) -- Wait for framework to load
    updateCryptoData()
end)
