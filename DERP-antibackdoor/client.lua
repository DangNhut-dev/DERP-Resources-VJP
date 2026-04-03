local suspiciousEventCount = 0
local monitoredEvents = {}
local menuDetected = false
local lastTimeCheck = GetGameTimer()
local behaviorScore = 0
local anomalyCount = 0

local playerJoinTime = 0
local hasPlayerSpawned = false

local antibackdoorEvents = {
    "antibackdoor:alert",
    "antibackdoor:kick",
    "antibackdoor:suspiciousActivity",
}

local function IsAntibackdoorEvent(eventName)
    for _, event in ipairs(antibackdoorEvents) do
        if eventName == event then
            return true
        end
    end
    return false
end

local function IsPlayerLoading()
    local currentTime = GetGameTimer()
    local timeSinceJoin = currentTime - playerJoinTime
    return timeSinceJoin < 60000
end

AddEventHandler('playerSpawned', function()
    if not hasPlayerSpawned then
        hasPlayerSpawned = true
        playerJoinTime = GetGameTimer()
        print("^2[AntiBackdoor]^7 Client protection active - Grace period: 60s")
    end
end)

CreateThread(function()
    Wait(5000)
    if not hasPlayerSpawned then
        hasPlayerSpawned = true
        playerJoinTime = GetGameTimer()
    end
end)

CreateThread(function()
    while true do
        Wait(60000)
        
        if not IsPlayerLoading() and suspiciousEventCount > 30 then
            TriggerServerEvent('antibackdoor:suspiciousActivity', {
                events = suspiciousEventCount,
                resource = GetCurrentResourceName(),
                details = "High event trigger rate: " .. suspiciousEventCount .. " events/min"
            })
            suspiciousEventCount = 0
        end
        
        if IsPlayerLoading() then
            suspiciousEventCount = 0
        end
        
        behaviorScore = 0
    end
end)

local originalAddEventHandler = AddEventHandler
AddEventHandler = function(eventName, callback)
    local resource = GetCurrentResourceName()
    
    if not monitoredEvents[eventName] then
        monitoredEvents[eventName] = {
            resource = resource,
            count = 0,
            lastTrigger = 0
        }
    end
    
    local wrappedCallback = function(...)
        local now = GetGameTimer()
        monitoredEvents[eventName].count = monitoredEvents[eventName].count + 1
        monitoredEvents[eventName].lastTrigger = now
        
        if not IsPlayerLoading() then
            suspiciousEventCount = suspiciousEventCount + 1
        end
        
        if not IsPlayerLoading() and monitoredEvents[eventName].count > 500 then
            TriggerServerEvent('antibackdoor:suspiciousActivity', {
                event = eventName,
                resource = resource,
                count = monitoredEvents[eventName].count,
                details = "Event spam detected: " .. eventName
            })
            monitoredEvents[eventName].count = 0
            behaviorScore = behaviorScore + 30
        end
        
        return callback(...)
    end
    
    return originalAddEventHandler(eventName, wrappedCallback)
end

local originalRegisterNetEvent = RegisterNetEvent
RegisterNetEvent = function(eventName)
    local resource = GetCurrentResourceName()
    
    if IsAntibackdoorEvent(eventName) then
        return originalRegisterNetEvent(eventName)
    end
    
    if IsPlayerLoading() then
        return originalRegisterNetEvent(eventName)
    end
    
    local lowerEvent = eventName:lower()
    local suspiciousKeywords = {
        "admin", "god", "money", "ban", "kick", 
        "givemoney", "giveitem", "setjob", "setgang",
        "noclip", "teleport", "revive", "heal"
    }
    
    for _, keyword in ipairs(suspiciousKeywords) do
        if lowerEvent:find(keyword, 1, true) then
            TriggerServerEvent('antibackdoor:suspiciousActivity', {
                event = eventName,
                resource = resource,
                details = "Suspicious event registered: " .. eventName
            })
            behaviorScore = behaviorScore + 15
            break
        end
    end
    
    return originalRegisterNetEvent(eventName)
end

CreateThread(function()
    while true do
        Wait(30000)
        
        if IsPlayerLoading() then
            goto continue
        end
        
        local currentTime = GetGameTimer()
        local timeDiff = currentTime - lastTimeCheck
        
        if timeDiff > 35000 or timeDiff < 25000 then
            TriggerServerEvent('antibackdoor:suspiciousActivity', {
                details = "Client time anomaly detected",
                resource = GetCurrentResourceName(),
                timeDiff = timeDiff,
                expected = 30000
            })
            anomalyCount = anomalyCount + 1
            behaviorScore = behaviorScore + 20
        end
        
        lastTimeCheck = currentTime
        
        ::continue::
    end
end)

CreateThread(function()
    while true do
        Wait(45000)
        
        if IsPlayerLoading() then
            goto continue
        end
        
        local suspiciousGlobals = {
            "_menuPool",
            "MenuPool",
            "NativeUI",
        }
        
        for _, globalName in ipairs(suspiciousGlobals) do
            if _G[globalName] and type(_G[globalName]) == "table" and not menuDetected then
                local resource = GetCurrentResourceName()
                
                local manifestCheck = GetResourceMetadata(resource, globalName, 0)
                if not manifestCheck then
                    TriggerServerEvent('antibackdoor:suspiciousActivity', {
                        details = "Undeclared global variable (possible menu injection)",
                        global = globalName,
                        resource = resource
                    })
                    menuDetected = true
                    behaviorScore = behaviorScore + 40
                end
            end
        end
        
        ::continue::
    end
end)

CreateThread(function()
    while true do
        Wait(60000)
        
        if IsPlayerLoading() then
            goto continue
        end
        
        local startTime = GetGameTimer()
        
        for i = 1, 100 do
            local dummy = i * 2
        end
        
        local endTime = GetGameTimer()
        local execTime = endTime - startTime
        
        if execTime > 50 then
            TriggerServerEvent('antibackdoor:suspiciousActivity', {
                details = "Possible debugger detected (slow execution)",
                resource = GetCurrentResourceName(),
                execTime = execTime,
                expected = "< 5ms"
            })
            behaviorScore = behaviorScore + 25
        end
        
        ::continue::
    end
end)

local nativeCallCount = 0
local lastNativeReset = GetGameTimer()

local originalCitizen = Citizen
if originalCitizen and originalCitizen.InvokeNative then
    local originalInvokeNative = originalCitizen.InvokeNative
    
    Citizen.InvokeNative = function(hash, ...)
        if not IsPlayerLoading() then
            nativeCallCount = nativeCallCount + 1
        end
        
        local now = GetGameTimer()
        if now - lastNativeReset > 1000 then
            if not IsPlayerLoading() and nativeCallCount > 10000 then
                TriggerServerEvent('antibackdoor:suspiciousActivity', {
                    details = "Excessive native calls detected",
                    resource = GetCurrentResourceName(),
                    count = nativeCallCount,
                    timeWindow = "1 second"
                })
                behaviorScore = behaviorScore + 20
            end
            
            nativeCallCount = 0
            lastNativeReset = now
        end
        
        return originalInvokeNative(hash, ...)
    end
end

CreateThread(function()
    while true do
        Wait(120000)
        
        if IsPlayerLoading() then
            goto continue
        end
        
        local playerPed = PlayerPedId()
        
        if GetPlayerInvincible(playerPed) then
            TriggerServerEvent('antibackdoor:suspiciousActivity', {
                details = "Player invincibility detected",
                resource = GetCurrentResourceName(),
                playerId = PlayerId()
            })
            behaviorScore = behaviorScore + 50
        end
        
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            local speed = GetEntitySpeed(vehicle)
            
            if speed > 200.0 then
                TriggerServerEvent('antibackdoor:suspiciousActivity', {
                    details = "Abnormal vehicle speed detected",
                    resource = GetCurrentResourceName(),
                    speed = speed,
                    vehicle = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
                })
            end
        end
        
        ::continue::
    end
end)

CreateThread(function()
    while true do
        Wait(90000)
        
        if IsPlayerLoading() then
            goto continue
        end
        
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        if playerCoords.z > 1000.0 or playerCoords.z < -500.0 then
            TriggerServerEvent('antibackdoor:suspiciousActivity', {
                details = "Player at abnormal height",
                resource = GetCurrentResourceName(),
                coords = playerCoords,
                height = playerCoords.z
            })
            behaviorScore = behaviorScore + 15
        end
        
        ::continue::
    end
end)

local resourceStartCount = 0
local lastResourceStartReset = GetGameTimer()
local firstResourceStartTime = 0

AddEventHandler('onClientResourceStart', function(resourceName)
    if not hasPlayerSpawned then
        hasPlayerSpawned = true
        playerJoinTime = GetGameTimer()
    end
    
    if IsPlayerLoading() then
        return
    end
    
    local now = GetGameTimer()
    
    if resourceStartCount == 0 then
        firstResourceStartTime = now
    end
    
    if now - lastResourceStartReset > 10000 then
        resourceStartCount = 0
        lastResourceStartReset = now
        firstResourceStartTime = now
    end
    
    resourceStartCount = resourceStartCount + 1
    
    if resourceStartCount > 100 then
        TriggerServerEvent('antibackdoor:suspiciousActivity', {
            details = "Rapid resource starts detected (potential resource injection)",
            resource = GetCurrentResourceName(),
            count = resourceStartCount,
            lastResource = resourceName
        })
        behaviorScore = behaviorScore + 25
        resourceStartCount = 0
    end
end)

RegisterNetEvent('antibackdoor:alert')
AddEventHandler('antibackdoor:alert', function(message)
    print("^1[AntiBackdoor Alert]^7 " .. message)
end)

RegisterNetEvent('antibackdoor:kick')
AddEventHandler('antibackdoor:kick', function(reason)
    print("^1[AntiBackdoor]^7 You are being kicked: " .. reason)
end)

CreateThread(function()
    Wait(2000)
    print("^2[AntiBackdoor v3.0]^7 Client protection initialized")
end)