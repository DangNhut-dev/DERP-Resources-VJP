NetworkAnalyzer = {}
NetworkAnalyzer.DNSCache = {}
NetworkAnalyzer.TrafficPatterns = {}

function NetworkAnalyzer:AnalyzePayload(url, data)
    if not data or type(data) ~= "string" then
        return false, "No payload"
    end
    
    local findings = {}
    
    local base64Count = 0
    for _ in data:gmatch("[A-Za-z0-9+/]+=*") do
        base64Count = base64Count + 1
    end
    if base64Count > 10 then
        table.insert(findings, "High base64 content")
    end
    
    for _, pattern in ipairs(Config.SuspiciousPayloadPatterns) do
        if data:lower():find(pattern, 1, true) then
            table.insert(findings, "Sensitive data: " .. pattern)
        end
    end
    
    if #data > Config.MaxPayloadSize then
        table.insert(findings, "Large payload: " .. #data .. " bytes")
    end
    
    for _, c2pattern in ipairs(Config.Advanced.KnownC2Patterns) do
        if url:find(c2pattern, 1, true) then
            table.insert(findings, "C2 pattern in URL: " .. c2pattern)
        end
    end
    
    local isHighEntropy, entropy = IsHighEntropy(data)
    if isHighEntropy then
        table.insert(findings, "High entropy payload: " .. string.format("%.2f", entropy))
    end
    
    return #findings > 0, findings
end

function NetworkAnalyzer:DetectDNSTunneling(url)
    local domain = url:match("://([^/]+)")
    if not domain then return false end
    
    local subdomains = {}
    for subdomain in domain:gmatch("([^%.]+)") do
        table.insert(subdomains, subdomain)
    end
    
    if #subdomains > 5 then
        local totalLength = 0
        for _, sub in ipairs(subdomains) do
            totalLength = totalLength + #sub
        end
        
        if totalLength > 100 then
            return true, "Suspicious long domain: " .. domain
        end
    end
    
    local hexCount = 0
    for _, sub in ipairs(subdomains) do
        if sub:match("^[0-9a-f]+$") and #sub > 8 then
            hexCount = hexCount + 1
        end
    end
    
    if hexCount > 2 then
        return true, "Multiple hex subdomains: " .. domain
    end
    
    return false, nil
end

function NetworkAnalyzer:TrackTrafficPattern(resource, url, size)
    if not self.TrafficPatterns[resource] then
        self.TrafficPatterns[resource] = {
            urls = {},
            totalBytes = 0,
            requests = 0,
        }
    end
    
    local pattern = self.TrafficPatterns[resource]
    pattern.urls[url] = (pattern.urls[url] or 0) + 1
    pattern.totalBytes = pattern.totalBytes + (size or 0)
    pattern.requests = pattern.requests + 1
    
    if pattern.requests > 50 and pattern.totalBytes > 1000000 then
        return true, "High volume traffic: " .. pattern.totalBytes .. " bytes in " .. pattern.requests .. " requests"
    end
    
    return false, nil
end