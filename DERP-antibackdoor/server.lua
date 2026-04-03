local violations = {}
local httpCache = {}
local resourceFiles = {}
local fileHashes = {}
local quarantinedResources = {}
local networkCallCount = {}
local startTime = os.time()

CreateThread(function()
    Wait(Config.InitialScanDelay)
    print("^3[AntiBackdoor v3.0]^7 Initializing advanced protection...")
    
    if Config.Advanced.EnableBehaviorAnalysis then
        BehaviorAnalyzer:Initialize()
        print("^2[AntiBackdoor]^7 Behavior analysis: ENABLED")
    end
    
    print("^3[AntiBackdoor]^7 Starting comprehensive scan...")
    ScanAllResources()
    print("^2[AntiBackdoor]^7 Initial scan complete! Advanced protection active.")
end)

CreateThread(function()
    while true do
        Wait(Config.FileScanInterval)
        CheckResourceFileChanges()
    end
end)

if Config.EnableHashCheck then
    CreateThread(function()
        while true do
            Wait(Config.HashCheckInterval)
            VerifyFileIntegrity()
        end
    end)
end

CreateThread(function()
    while true do
        Wait(Config.NetworkCheckInterval)
        AnalyzeNetworkActivity()
        networkCallCount = {}
    end
end)

function ScanAllResources()
    local resources = {}
    local numResources = GetNumResources()
    
    for i = 0, numResources - 1 do
        local resourceName = GetResourceByFindIndex(i)
        if resourceName and GetResourceState(resourceName) == "started" then
            table.insert(resources, resourceName)
        end
    end
    
    for _, resourceName in ipairs(resources) do
        if not IsWhitelisted(resourceName) and not quarantinedResources[resourceName] then
            ScanResource(resourceName)
        end
    end
end

function ScanResource(resourceName)
    if quarantinedResources[resourceName] then
        return
    end
    
    local files = {}
    
    local numMetadata = GetNumResourceMetadata(resourceName, 'file') or 0
    for i = 0, numMetadata - 1 do
        local file = GetResourceMetadata(resourceName, 'file', i)
        if file then table.insert(files, file) end
    end
    
    local numClient = GetNumResourceMetadata(resourceName, 'client_script') or 0
    for i = 0, numClient - 1 do
        local file = GetResourceMetadata(resourceName, 'client_script', i)
        if file then table.insert(files, file) end
    end
    
    local numServer = GetNumResourceMetadata(resourceName, 'server_script') or 0
    for i = 0, numServer - 1 do
        local file = GetResourceMetadata(resourceName, 'server_script', i)
        if file then table.insert(files, file) end
    end
    
    for _, file in ipairs(files) do
        CheckFile(resourceName, file, true)
    end
    
    resourceFiles[resourceName] = files
end

function CheckFile(resourceName, fileName, isInitialScan)
    for _, pattern in ipairs(Config.IgnoreFilePatterns) do
        if fileName:match(pattern) then
            return
        end
    end
    
    if fileName:sub(1, 1) == "." then
        local blocked = BlockThreat("CRITICAL", resourceName, 
            "🚨 HIDDEN FILE BLOCKED!", fileName)
        
        if blocked then
            return
        end
    end
    
    if not IsLegitimateResource(resourceName) then
        local lowerName = fileName:lower()
        
        if lowerName:match("backdoor") or lowerName:match("inject") or 
           lowerName:match("exploit") or lowerName:match("dump") then
            BlockThreat("HIGH", resourceName, "Suspicious filename", fileName)
        end
        
        if lowerName:match("[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]") 
            and not lowerName:match("%.") then
            BlockThreat("HIGH", resourceName, "Hex-like filename", fileName)
        end
    end
    
    local content = LoadResourceFile(resourceName, fileName)
    if not content then return end
    
    if #content < Config.MinFileSizeToScan then return end
    if #content > Config.MaxFileSizeToScan then
        Alert("MEDIUM", resourceName, "File too large to scan", fileName .. " (" .. #content .. " bytes)")
        return
    end
    
    if Config.EnableHashCheck and isInitialScan then
        local hash = GetFileHash(content)
        if not fileHashes[resourceName] then
            fileHashes[resourceName] = {}
        end
        fileHashes[resourceName][fileName] = hash
    end
    
    CheckFileContent(resourceName, fileName, content)
end

function CheckFileContent(resourceName, fileName, content)
    for _, pattern in ipairs(Config.IgnoreFilePatterns) do
        if fileName:match(pattern) then return end
    end
    
    for _, pattern in ipairs(Config.CriticalPatterns) do
        if content:match(pattern) then
            BlockThreat("CRITICAL", resourceName,
                "🚨 BACKDOOR PATTERN DETECTED: " .. pattern,
                fileName)
            return
        end
    end
    
    if content:match("for%s*%(.-%%.charCodeAt") or 
       content:match("%.charCodeAt%([^)]*%)%s*%^") or
       content:match("String%.fromCharCode%([^)]*%^") then
        BlockThreat("CRITICAL", resourceName, 
            "🚨 XOR obfuscation detected (backdoor pattern)!", 
            fileName)
        return
    end
    
    if content:match("eval%s*%([^)]*fromCharCode") or
       content:match("eval%s*%([^)]*atob") or
       content:match("eval%s*%([^)]*\\x") then
        BlockThreat("CRITICAL", resourceName,
            "🚨 eval() with obfuscated code - BACKDOOR!",
            fileName)
        return
    end
    
    local arrayCount = 0
    for _ in content:gmatch("%[%s*%d+%s*,%s*%d+%s*,%s*%d+") do
        arrayCount = arrayCount + 1
    end
    if arrayCount > 10 then
        Alert("HIGH", resourceName,
            "Large number array (possible obfuscated payload)",
            fileName .. " (" .. arrayCount .. " arrays)")
    end
    
    local hexCount = 0
    for _ in content:gmatch("\\x[0-9a-fA-F][0-9a-fA-F]") do
        hexCount = hexCount + 1
    end
    
    if hexCount > Config.HexThreshold then
        local hexRatio = hexCount / #content
        if hexRatio > Config.HexRatioThreshold then
            BlockThreat("CRITICAL", resourceName, 
                "Heavy hex obfuscation detected", 
                fileName .. " (" .. hexCount .. " sequences, " .. 
                string.format("%.1f", hexRatio * 100) .. "%)")
        end
    end
    
    if Config.Advanced.EnableEntropyAnalysis then
        local isObfuscated, ratio = DetectObfuscationByEntropy(content)
        if isObfuscated then
            Alert("HIGH", resourceName,
                "🔍 High entropy detected (possible obfuscation)",
                fileName .. string.format(" (%.1f%% high entropy lines)", ratio * 100))
        end
    end
    
    if Config.Advanced.EnableCodeAnalysis and fileName:match("%.lua$") then
        local score, findings = CodeAnalyzer:AnalyzeLuaCode(content, fileName)
        
        if score > 50 then
            local findingsText = table.concat(findings, ", ")
            BlockThreat("CRITICAL", resourceName,
                "🧠 Code analysis score: " .. score,
                fileName .. " | " .. findingsText)
            return
        elseif score > 30 then
            local findingsText = table.concat(findings, ", ")
            Alert("HIGH", resourceName,
                "⚠️ Code analysis warning (score: " .. score .. ")",
                fileName .. " | " .. findingsText)
        end
        
        local hasChain, chain = CodeAnalyzer:DetectCallChain(content)
        if hasChain then
            local shouldIgnore = false
            if Config.Advanced.IgnoreCallChainResources then
                for _, ignoreRes in ipairs(Config.Advanced.IgnoreCallChainResources) do
                    if resourceName:lower():find(ignoreRes, 1, true) then
                        shouldIgnore = true
                        break
                    end
                end
            end
            
            if not shouldIgnore then
                Alert("HIGH", resourceName,
                    "Suspicious call chain detected: " .. chain,
                    fileName)
            end
        end
    end
    
    for _, pattern in ipairs(Config.SuspiciousPatterns) do
        local matches = {}
        for match in content:gmatch(pattern) do
            table.insert(matches, match)
        end
        
        if #matches > 0 and #matches <= 5 then
            if ShouldAlertPattern(pattern, fileName, resourceName, #matches) then
                Alert("HIGH", resourceName, 
                    "Suspicious pattern: " .. pattern, 
                    fileName .. " (" .. #matches .. " occurrences)")
            end
        end
    end
end

function ShouldAlertPattern(pattern, fileName, resourceName, matchCount)
    if IsLegitimateResource(resourceName) then
        return false
    end
    
    if pattern:find("%.charCodeAt") then
        if fileName:match("%.js$") or 
           fileName:match("%.html$") or 
           fileName:match("html/") or
           fileName:match("script%.") then
            return false
        end
    end
    
    if pattern:find("Function") then
        if fileName:match("%.html$") or 
           fileName:match("html/") or
           fileName:match("camera%.lua") or
           fileName:match("player%.lua") or
           fileName:match("main%.lua") or
           fileName:match("ComboZone") or
           matchCount > 10 then
            return false
        end
    end
    
    if pattern:find("parseInt") then
        if fileName:match("%.js$") or 
           fileName:match("%.html$") or
           fileName:match("html/") then
            return false
        end
    end
    
    if pattern:find("ExecuteCommand") then
        if fileName:match("config%.lua") or 
           fileName:match("main%.lua") or
           fileName:match("events%.lua") then
            return false
        end
    end
    
    if pattern:find("io%.popen") or pattern:find("io%.open") then
        if fileName:match("getFilesInDirectory") or
           fileName:match("getFiles") or
           fileName:match("imports") or
           fileName:match("logger") or
           fileName:match("filesystem") or
           fileName:match("utils") then
            return false
        end
    end
    
    if pattern:find("os%.execute") then
        if fileName:match("install") or
           fileName:match("setup") or
           fileName:match("build") then
            return false
        end
    end
    
    if pattern:find("fromCharCode") then
        if fileName:match("%.js$") or 
           fileName:match("%.html$") or
           fileName:match("html/") or
           fileName:match("%.min%.") then
            return false
        end
    end
    
    if pattern:find("loadstring") then
        if fileName:match("test") or
           fileName:match("sandbox") or
           fileName:match("compiler") then
            return false
        end
    end
    
    return true
end

function VerifyFileIntegrity()
    for resourceName, files in pairs(fileHashes) do
        if GetResourceState(resourceName) == "started" and not quarantinedResources[resourceName] then
            for fileName, originalHash in pairs(files) do
                local content = LoadResourceFile(resourceName, fileName)
                if content then
                    local currentHash = GetFileHash(content)
                    
                    if currentHash ~= originalHash then
                        BlockThreat("CRITICAL", resourceName,
                            "🚨 FILE MODIFIED AT RUNTIME!",
                            fileName .. " (hash mismatch)")
                        
                        if fileHashes[resourceName] and fileHashes[resourceName][fileName] then
                            fileHashes[resourceName][fileName] = currentHash
                        end
                        
                        break
                    end
                end
            end
        end
    end
end

function GetFileHash(content)
    local hash = 0
    for i = 1, #content do
        hash = (hash * 31 + string.byte(content, i)) % 2147483647
    end
    return hash
end

function AnalyzeNetworkActivity()
    for url, data in pairs(networkCallCount) do
        if data.count > Config.RateLimitRequests then
            if not IsDomainWhitelisted(url) then
                Alert("CRITICAL", data.resource,
                    "⚠️ High-frequency network calls (rate limit exceeded)",
                    url .. " (" .. data.count .. " calls in " .. Config.NetworkCheckInterval/1000 .. "s)")
                
                if Config.BlockSuspiciousHTTP then
                    QuarantineResource(data.resource, "Excessive HTTP requests")
                end
            end
        end
    end
end

local originalLoadResourceFile = LoadResourceFile
LoadResourceFile = function(resourceName, fileName)
    local invokingResource = GetInvokingResource() or "unknown"
    
    if Config.Advanced.EnableBehaviorAnalysis and invokingResource ~= "unknown" then
        BehaviorAnalyzer:TrackFileRead(invokingResource, resourceName .. "/" .. fileName)
    end
    
    if Config.BlockCrossResourceAccess and invokingResource ~= resourceName then
        local accessKey = invokingResource .. "->" .. resourceName
        local isAllowed = false
        
        for _, allowed in ipairs(Config.AllowedCrossAccess) do
            if accessKey == allowed then
                isAllowed = true
                break
            end
        end
        
        if not isAllowed and invokingResource ~= "unknown" then
            Alert("CRITICAL", invokingResource, 
                "🚨 BLOCKED: Cross-resource file access attempt!",
                "Trying to read: " .. resourceName .. "/" .. fileName)
            
            if Config.BlockMode then
                return nil
            end
        end
    end
    
    return originalLoadResourceFile(resourceName, fileName)
end

local originalPerformHttpRequest = PerformHttpRequest
PerformHttpRequest = function(url, callback, method, data, headers, options)
    local resource = GetInvokingResource() or "unknown"
    
    if resource:find("antibackdoor") or resource == "unknown" then
        return originalPerformHttpRequest(url, callback, method, data, headers, options)
    end
    
    if Config.Advanced.EnableBehaviorAnalysis then
        BehaviorAnalyzer:TrackHTTPCall(resource, url)
    end
    
    if not networkCallCount[url] then
        networkCallCount[url] = {count = 0, resource = resource}
    end
    networkCallCount[url].count = networkCallCount[url].count + 1
    
    if Config.Advanced.EnableNetworkDeepInspection then
        local isDNSTunnel, tunnelInfo = NetworkAnalyzer:DetectDNSTunneling(url)
        if isDNSTunnel then
            BlockThreat("CRITICAL", resource,
                "🌐 DNS TUNNELING DETECTED!",
                tunnelInfo)
            
            if Config.BlockSuspiciousHTTP then
                return
            end
        end
        
        local hasHighTraffic, trafficInfo = NetworkAnalyzer:TrackTrafficPattern(resource, url, data and #data or 0)
        if hasHighTraffic then
            Alert("HIGH", resource, "High volume network traffic", trafficInfo)
        end
    end
    
    if not IsDomainWhitelisted(url) then
        Alert("HIGH", resource, "HTTP request to external URL", url)
        
        if data and type(data) == "string" then
            if Config.Advanced.EnableNetworkDeepInspection then
                local hasSuspicious, findings = NetworkAnalyzer:AnalyzePayload(url, data)
                if hasSuspicious then
                    local findingsText = table.concat(findings, ", ")
                    BlockThreat("CRITICAL", resource,
                        "🔍 SUSPICIOUS PAYLOAD DETECTED!",
                        url .. " | " .. findingsText)
                    
                    if Config.BlockSuspiciousHTTP then
                        return
                    end
                end
            end
            
            if #data > Config.MaxPayloadSize then
                BlockThreat("CRITICAL", resource,
                    "🚨 Large payload detected (data exfiltration?)",
                    url .. " (" .. #data .. " bytes)")
                
                if Config.BlockSuspiciousHTTP then
                    return
                end
            end
            
            local lowerData = data:lower()
            for _, pattern in ipairs(Config.SuspiciousPayloadPatterns) do
                if lowerData:find(pattern, 1, true) then
                    BlockThreat("CRITICAL", resource,
                        "🚨 Sensitive data in payload: " .. pattern,
                        url)
                    
                    if Config.BlockSuspiciousHTTP then
                        return
                    end
                end
            end
        end
        
        if Config.BlockSuspiciousHTTP and Config.BlockMode then
            Alert("CRITICAL", resource,
                "🚫 BLOCKED: HTTP request to non-whitelisted domain",
                url)
            return
        end
    end
    
    return originalPerformHttpRequest(url, callback, method, data, headers, options)
end

local originalTriggerEvent = TriggerEvent
TriggerEvent = function(eventName, ...)
    if Config.Advanced.EnableBehaviorAnalysis then
        local resource = GetInvokingResource() or "unknown"
        if resource ~= "unknown" then
            BehaviorAnalyzer:TrackEventTrigger(resource, eventName)
        end
    end
    
    return originalTriggerEvent(eventName, ...)
end

function BlockThreat(level, resource, message, details)
    Alert(level, resource, message, details)
    
    if Config.BlockMode and Config.AutoQuarantine then
        QuarantineResource(resource, message)
        return true
    end
    
    return false
end

function QuarantineResource(resourceName, reason)
    if quarantinedResources[resourceName] then
        return
    end
    
    quarantinedResources[resourceName] = {
        reason = reason,
        timestamp = os.time(),
        state = GetResourceState(resourceName)
    }
    
    print(string.format(
        "^1[AntiBackdoor] ⛔ QUARANTINED: ^6%s^7 | Reason: %s",
        resourceName, reason
    ))
    
    if GetResourceState(resourceName) == "started" then
        StopResource(resourceName)
    end
    
    if Config.DiscordWebhook and Config.DiscordWebhook ~= "" then
        SendDiscordQuarantine(resourceName, reason)
    end
end

function CheckResourceFileChanges()
    for resourceName, oldFiles in pairs(resourceFiles) do
        if GetResourceState(resourceName) == "started" and 
           not IsWhitelisted(resourceName) and 
           not quarantinedResources[resourceName] then
            
            local currentFiles = GetCurrentResourceFiles(resourceName)
            
            for _, file in ipairs(currentFiles) do
                local found = false
                for _, oldFile in ipairs(oldFiles) do
                    if file == oldFile then
                        found = true
                        break
                    end
                end
                
                if not found then
                    BlockThreat("CRITICAL", resourceName, 
                        "🚨 NEW FILE DETECTED (runtime injection?)", file)
                    CheckFile(resourceName, file, false)
                end
            end
            
            resourceFiles[resourceName] = currentFiles
        end
    end
end

function GetCurrentResourceFiles(resourceName)
    local files = {}
    local numMetadata = GetNumResourceMetadata(resourceName, 'file') or 0
    
    for i = 0, numMetadata - 1 do
        local file = GetResourceMetadata(resourceName, 'file', i)
        if file then table.insert(files, file) end
    end
    
    return files
end

function IsWhitelisted(resourceName)
    for _, whitelisted in ipairs(Config.WhitelistResources) do
        if resourceName == whitelisted then
            return true
        end
    end
    return false
end

function IsLegitimateResource(resourceName)
    for _, pattern in ipairs(Config.LegitimateResourcePatterns) do
        if resourceName:lower():find(pattern, 1, true) then
            return true
        end
    end
    return false
end

function IsDomainWhitelisted(url)
    local domain = url:match("://([^/]+)")
    if not domain then return false end
    
    domain = domain:lower()
    
    for _, whitelisted in ipairs(Config.WhitelistDomains) do
        if domain:find(whitelisted, 1, true) or url:find(whitelisted, 1, true) then
            return true
        end
    end
    
    return false
end

function Alert(level, resource, message, details)
    if Config.LogLevel == 0 then return end
    if Config.LogLevel == 1 and level ~= "CRITICAL" then return end
    if Config.LogLevel == 2 and (level ~= "CRITICAL" and level ~= "HIGH") then return end
    
    local color = "^7"
    if level == "CRITICAL" then
        color = "^1"
    elseif level == "HIGH" then
        color = "^3"
    elseif level == "MEDIUM" then
        color = "^5"
    end
    
    local alertMsg = string.format(
        "%s[AntiBackdoor] [%s]^7 %s | Resource: ^6%s^7 | Details: %s",
        color, level, message, resource, details or "N/A"
    )
    
    print(alertMsg)
    
    if Config.DiscordWebhook and Config.DiscordWebhook ~= "" then
        SendDiscordAlert(level, resource, message, details)
    end
end

function SendDiscordAlert(level, resource, message, details)
    local color = 15158332
    if level == "HIGH" then color = 16776960 end
    if level == "MEDIUM" then color = 3447003 end
    
    local embed = {{
        ["color"] = color,
        ["title"] = "🚨 Security Alert - " .. level,
        ["description"] = message,
        ["fields"] = {
            {
                ["name"] = "Resource",
                ["value"] = resource,
                ["inline"] = true
            },
            {
                ["name"] = "Details",
                ["value"] = details or "N/A",
                ["inline"] = true
            },
            {
                ["name"] = "Timestamp",
                ["value"] = os.date("%Y-%m-%d %H:%M:%S"),
                ["inline"] = false
            }
        },
        ["footer"] = {
            ["text"] = "AntiBackdoor v3.0 Advanced"
        }
    }}
    
    PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', 
        json.encode({username = "AntiBackdoor v3.0", embeds = embed}), 
        {['Content-Type'] = 'application/json'})
end

function SendDiscordQuarantine(resourceName, reason)
    local embed = {{
        ["color"] = 16711680,
        ["title"] = "⛔ RESOURCE QUARANTINED",
        ["description"] = "A resource has been automatically stopped due to security threat.",
        ["fields"] = {
            {
                ["name"] = "Resource",
                ["value"] = resourceName,
                ["inline"] = true
            },
            {
                ["name"] = "Reason",
                ["value"] = reason,
                ["inline"] = false
            },
            {
                ["name"] = "Action Required",
                ["value"] = "Review resource and use `/unquarantine " .. resourceName .. "` if false positive",
                ["inline"] = false
            },
            {
                ["name"] = "Timestamp",
                ["value"] = os.date("%Y-%m-%d %H:%M:%S"),
                ["inline"] = false
            }
        },
        ["footer"] = {
            ["text"] = "AntiBackdoor v3.0 - Auto-Quarantine"
        }
    }}
    
    PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', 
        json.encode({username = "AntiBackdoor v3.0", embeds = embed}), 
        {['Content-Type'] = 'application/json'})
end

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    violations[source] = 0
end)

AddEventHandler('playerDropped', function()
    local source = source
    violations[source] = nil
end)

local dangerousEvents = {
    'esx:getSharedObject',
    'bank:transfer',
    'esx:giveInventoryItem',
    'esx:giveMoney',
}

for _, eventName in ipairs(dangerousEvents) do
    RegisterNetEvent(eventName)
    AddEventHandler(eventName, function(...)
        local source = source
        local resource = GetInvokingResource() or "unknown"
        
        if not IsWhitelisted(resource) then
            violations[source] = (violations[source] or 0) + 1
            
            Alert("HIGH", resource, 
                "Player triggered sensitive event: " .. eventName, 
                "Player: " .. GetPlayerName(source) .. " [" .. source .. "]")
            
            if Config.AutoKick and violations[source] >= Config.MaxViolations then
                DropPlayer(source, "Suspicious activity detected")
            end
        end
    end)
end

RegisterNetEvent('antibackdoor:suspiciousActivity')
AddEventHandler('antibackdoor:suspiciousActivity', function(data)
    local source = source
    local playerName = GetPlayerName(source)
    
    Alert("HIGH", data.resource or "client", 
        "Client-side activity: " .. (data.details or "Unknown"),
        "Player: " .. playerName .. " [" .. source .. "]")
    
    violations[source] = (violations[source] or 0) + 1
    
    if Config.AutoKick and violations[source] >= Config.MaxViolations then
        DropPlayer(source, "Suspicious client-side activity")
    end
end)

RegisterCommand('scanresources', function(source, args)
    if source == 0 or IsPlayerAceAllowed(source, "antibackdoor.scan") then
        print("^3[AntiBackdoor]^7 Manual scan initiated...")
        ScanAllResources()
        print("^2[AntiBackdoor]^7 Manual scan complete!")
        
        if source ~= 0 then
            TriggerClientEvent('chat:addMessage', source, {
                args = {"^2[AntiBackdoor]", "Scan complete! Check server console."}
            })
        end
    end
end)

RegisterCommand('antibackdoor', function(source, args)
    if source == 0 or IsPlayerAceAllowed(source, "antibackdoor.admin") then
        local numResources = 0
        for _ in pairs(resourceFiles) do
            numResources = numResources + 1
        end
        
        local quarantineCount = 0
        for _ in pairs(quarantinedResources) do
            quarantineCount = quarantineCount + 1
        end
        
        local uptime = os.time() - startTime
        local hours = math.floor(uptime / 3600)
        local mins = math.floor((uptime % 3600) / 60)
        
        print("^2[AntiBackdoor] v3.0 Advanced Stats:")
        print("^7  Monitored resources: ^3" .. numResources)
        print("^7  Quarantined resources: ^1" .. quarantineCount)
        print("^7  Uptime: ^3" .. hours .. "h " .. mins .. "m")
        print("^7  Block mode: ^3" .. (Config.BlockMode and "ENABLED" or "DISABLED"))
        print("^7  Hash checking: ^3" .. (Config.EnableHashCheck and "ENABLED" or "DISABLED"))
        print("^7  Behavior analysis: ^3" .. (Config.Advanced.EnableBehaviorAnalysis and "ENABLED" or "DISABLED"))
        print("^7  Entropy analysis: ^3" .. (Config.Advanced.EnableEntropyAnalysis and "ENABLED" or "DISABLED"))
        print("^7  Network deep inspection: ^3" .. (Config.Advanced.EnableNetworkDeepInspection and "ENABLED" or "DISABLED"))
    end
end)

RegisterCommand('behaviorscores', function(source, args)
    if source == 0 or IsPlayerAceAllowed(source, "antibackdoor.admin") then
        print("^2[AntiBackdoor] Behavior Scores:")
        
        local scores = {}
        for resource, score in pairs(BehaviorAnalyzer.ResourceScores) do
            table.insert(scores, {resource = resource, score = score})
        end
        
        table.sort(scores, function(a, b) return a.score > b.score end)
        
        for i, data in ipairs(scores) do
            if i <= 10 then
                local color = "^2"
                if data.score >= 75 then
                    color = "^1"
                elseif data.score >= 50 then
                    color = "^3"
                elseif data.score >= 25 then
                    color = "^5"
                end
                
                print(string.format("^7  %d. %s%s^7 - Score: %s%d^7", 
                    i, "^6", data.resource, color, data.score))
            end
        end
        
        if #scores == 0 then
            print("^7  No behavior data available yet.")
        end
    end
end)

RegisterCommand('quarantine', function(source, args)
    if source == 0 or IsPlayerAceAllowed(source, "antibackdoor.admin") then
        if not args[1] then
            print("^3Usage: /quarantine <resourcename>")
            return
        end
        
        QuarantineResource(args[1], "Manual quarantine by admin")
        print("^2[AntiBackdoor]^7 Resource quarantined: ^6" .. args[1])
    end
end)

RegisterCommand('unquarantine', function(source, args)
    if source == 0 or IsPlayerAceAllowed(source, "antibackdoor.admin") then
        if not args[1] then
            print("^3Usage: /unquarantine <resourcename>")
            return
        end
        
        local resourceName = args[1]
        if quarantinedResources[resourceName] then
            quarantinedResources[resourceName] = nil
            print("^2[AntiBackdoor]^7 Resource unquarantined: ^6" .. resourceName)
            print("^3You can now manually restart it if needed.")
        else
            print("^3[AntiBackdoor]^7 Resource not in quarantine: ^6" .. resourceName)
        end
    end
end)

RegisterCommand('listquarantine', function(source, args)
    if source == 0 or IsPlayerAceAllowed(source, "antibackdoor.admin") then
        print("^2[AntiBackdoor] Quarantined Resources:")
        
        local count = 0
        for resourceName, data in pairs(quarantinedResources) do
            count = count + 1
            print(string.format("^7  %d. ^6%s^7 - %s", count, resourceName, data.reason))
        end
        
        if count == 0 then
            print("^7  No resources in quarantine.")
        end
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        Wait(1000)
        if not IsWhitelisted(resourceName) and not quarantinedResources[resourceName] then
            Alert("MEDIUM", resourceName, "Resource started - scanning...", "")
            ScanResource(resourceName)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    resourceFiles[resourceName] = nil
    
    SetTimeout(300000, function()
        if fileHashes[resourceName] then
            fileHashes[resourceName] = nil
        end
    end)
end)

print([[
^2
 ██████╗ ███████╗      ████████╗███████╗ █████╗ ███╗   ███╗
 ██╔══██╗██╔════╝      ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
 ██║  ██║█████╗  █████╗   ██║   █████╗  ███████║██╔████╔██║
 ██║  ██║██╔══╝  ╚════╝   ██║   ██╔══╝  ██╔══██║██║╚██╔╝██║
 ██████╔╝███████╗         ██║   ███████╗██║  ██║██║ ╚═╝ ██║
 ╚═════╝ ╚══════╝         ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
^7
 Advanced Backdoor Detection & Prevention System v1.0
 Author: TommyNguyenx
  
^3Commands:^7
  /scanresources      - Manual scan all resources
  /antibackdoor       - View system stats
  /behaviorscores     - View resource behavior scores
  /quarantine <name>  - Manually quarantine a resource
  /unquarantine <name>- Remove from quarantine
  /listquarantine     - List quarantined resources
^2
Advanced Features:
   Behavior Analysis: ]] .. (Config.Advanced.EnableBehaviorAnalysis and "^2ENABLED" or "^1DISABLED") .. [[^2
   Entropy Analysis: ]] .. (Config.Advanced.EnableEntropyAnalysis and "^2ENABLED" or "^1DISABLED") .. [[^2
   Network Deep Inspection: ]] .. (Config.Advanced.EnableNetworkDeepInspection and "^2ENABLED" or "^1DISABLED") .. [[^2
   Code Analysis: ]] .. (Config.Advanced.EnableCodeAnalysis and "^2ENABLED" or "^1DISABLED") .. [[^2

Protection Status:
   File blocking: ]] .. (Config.BlockHiddenFiles and "^2ENABLED" or "^1DISABLED") .. [[^2
   HTTP blocking: ]] .. (Config.BlockSuspiciousHTTP and "^2ENABLED" or "^1DISABLED") .. [[^2
   Auto-quarantine: ]] .. (Config.AutoQuarantine and "^2ENABLED" or "^1DISABLED") .. [[^2
   Hash verification: ]] .. (Config.EnableHashCheck and "^2ENABLED" or "^1DISABLED") .. [[^2
  
^7
]])