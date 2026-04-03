BehaviorAnalyzer = {}
BehaviorAnalyzer.ResourceScores = {}
BehaviorAnalyzer.ResourceBehavior = {}

function BehaviorAnalyzer:Initialize()
    CreateThread(function()
        while true do
            Wait(60000)
            self:AnalyzeBehaviors()
            self:ResetCounters()
        end
    end)
end

function BehaviorAnalyzer:TrackHTTPCall(resource, url)
    if not self.ResourceBehavior[resource] then
        self.ResourceBehavior[resource] = {
            httpCalls = 0,
            eventTriggers = 0,
            fileReads = 0,
            urls = {},
            events = {},
            files = {},
        }
    end
    
    self.ResourceBehavior[resource].httpCalls = self.ResourceBehavior[resource].httpCalls + 1
    table.insert(self.ResourceBehavior[resource].urls, url)
end

function BehaviorAnalyzer:TrackEventTrigger(resource, event)
    if not self.ResourceBehavior[resource] then
        self.ResourceBehavior[resource] = {
            httpCalls = 0,
            eventTriggers = 0,
            fileReads = 0,
            urls = {},
            events = {},
            files = {},
        }
    end
    
    self.ResourceBehavior[resource].eventTriggers = self.ResourceBehavior[resource].eventTriggers + 1
    table.insert(self.ResourceBehavior[resource].events, event)
end

function BehaviorAnalyzer:TrackFileRead(resource, file)
    if not self.ResourceBehavior[resource] then
        self.ResourceBehavior[resource] = {
            httpCalls = 0,
            eventTriggers = 0,
            fileReads = 0,
            urls = {},
            events = {},
            files = {},
        }
    end
    
    self.ResourceBehavior[resource].fileReads = self.ResourceBehavior[resource].fileReads + 1
    table.insert(self.ResourceBehavior[resource].files, file)
end

function BehaviorAnalyzer:CalculateScore(resource)
    local behavior = self.ResourceBehavior[resource]
    if not behavior then return 0 end
    
    local score = 0
    
    if behavior.httpCalls > Config.Advanced.MaxHTTPCallsPerMinute then
        score = score + 30
    end
    
    if behavior.eventTriggers > Config.Advanced.MaxEventTriggersPerMinute then
        score = score + 25
    end
    
    if behavior.fileReads > Config.Advanced.MaxFileReadsPerMinute then
        score = score + 20
    end
    
    local uniqueUrls = {}
    for _, url in ipairs(behavior.urls) do
        uniqueUrls[url] = true
    end
    if self:CountTable(uniqueUrls) > 5 then
        score = score + 15
    end
    
    local crossResourceReads = 0
    for _, file in ipairs(behavior.files) do
        if not file:match("^" .. resource) then
            crossResourceReads = crossResourceReads + 1
        end
    end
    if crossResourceReads > 3 then
        score = score + 20
    end
    
    return math.min(score, 100)
end

function BehaviorAnalyzer:CountTable(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

function BehaviorAnalyzer:AnalyzeBehaviors()
    for resource, behavior in pairs(self.ResourceBehavior) do
        local score = self:CalculateScore(resource)
        self.ResourceScores[resource] = score
        
        if score >= Config.Advanced.BehaviorScoreThreshold then
            Alert("CRITICAL", resource,
                "🚨 SUSPICIOUS BEHAVIOR DETECTED (Score: " .. score .. ")",
                string.format("HTTP: %d, Events: %d, Files: %d",
                    behavior.httpCalls, behavior.eventTriggers, behavior.fileReads))
            
            if Config.AutoQuarantine then
                QuarantineResource(resource, "High behavior score: " .. score)
            end
        end
    end
end

function BehaviorAnalyzer:ResetCounters()
    for resource, behavior in pairs(self.ResourceBehavior) do
        behavior.httpCalls = 0
        behavior.eventTriggers = 0
        behavior.fileReads = 0
        behavior.urls = {}
        behavior.events = {}
        behavior.files = {}
    end
end

function BehaviorAnalyzer:GetScore(resource)
    return self.ResourceScores[resource] or 0
end