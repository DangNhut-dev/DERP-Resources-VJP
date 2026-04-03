Config = {}

Config.DiscordWebhook = "https://discordapp.com/api/webhooks/1470329207534911528/cQyKY9j-20x-IQLMrh3NLDQpGfCk2nJkBXIk1ETtro7ijIf-bG7h2tP6sCtGJukK6FJg"
Config.LogLevel = 2

Config.BlockMode = true
Config.AutoQuarantine = true
Config.AutoKick = false
Config.MaxViolations = 3
Config.BlockSuspiciousHTTP = true

Config.BlockHiddenFiles = true
Config.BlockCrossResourceAccess = true

Config.AllowedCrossAccess = {
    "qb-core->qb-inventory",
    "qb-core->qb-shops",
    "ox_inventory->ox_lib",
}

Config.EnableHashCheck = true
Config.HashCheckInterval = 120000

Config.WhitelistDomains = {
    "github.com",
    "raw.githubusercontent.com",
    "api.ipify.org",
    "cfx.re",
    "fivem.net",
}

Config.RateLimitRequests = 10
Config.RateLimitWindow = 60
Config.MaxPayloadSize = 50000

Config.SuspiciousPayloadPatterns = {
    "identifiers",
    "token",
    "license:",
    "steam:",
    "discord:",
    "password",
    "apikey",
}

Config.WhitelistResources = {
    "spawnmanager",
    "mapmanager",
    "chat",
    "sessionmanager",
    "hardcap",
    "rconlog",
    "antibackdoor",
    "DERP-antibackdoor",
    "DERP-bossmenu",
    "ox_inventory",
    "DERP-ambulancejob",
    "WC_EMOTES_V5",
    "DERP-slideshow",
}

Config.IgnoreFilePatterns = {
    "%.min%.js$",
    "%.min%.css$",
    "/dist/",
    "/build/",
    "/bundle/",
    "/vendor/",
    "/node_modules/",
    "webpack",
    "%.bundle%.js$",
    "%.prod%.js$",
    "script%.js$",
    "index%.html$",
    "app%.js$",
    "/html/",
    "ComboZone",
    "%.png$",
    "%.jpg$",
    "%.jpeg$",
    "%.gif$",
    "%.svg$",
    "%.webp$",
    "%.ogg$",
    "%.mp3$",
    "%.wav$",
    "%.awc$",
    "%.ytyp$",
    "%.ymap$",
    "%.ymt$",
    "%.dat54$",
    "%.dat151$",
    "%.rel$",
    "%.nametable$",
    "%.ttf$",
    "%.otf$",
    "%.woff$",
    "%.woff2$",
    "/stream/",
    "/audio/",
    "/audiodirectory/",
    "/audiodata/",
    "/snd/",
}

Config.CriticalPatterns = {
    "for%s*%(.-%%.charCodeAt.-%^",
    "%.charCodeAt%([^)]*%)%s*%^",
    "String%.fromCharCode%([^)]*%^",
    "eval%s*%(%s*atob",
    "eval%s*%(%s*String%.fromCharCode",
    "eval%s*%([^)]*dmlgjjyeyvp",
    "eval%s*%(%s*%[.-%]%.map",
}

Config.SuspiciousPatterns = {
    "\\x[0-9a-fA-F][0-9a-fA-F]",
    "loadstring%s*%(",
    "Function%s*%(",
    "fromCharCode",
    "%.charCodeAt%(",
    "parseInt%(.-%,%s*16%)",
    "os%.execute",
    "io%.popen",
    "io%.open",
    "ExecuteCommand%s*%(%s*['\"]restart",
    "ExecuteCommand%s*%(%s*['\"]stop",
}

Config.LegitimateResourcePatterns = {
    "ox_lib",
    "qbx_",
    "qb%-",
}

Config.HexThreshold = 150
Config.HexRatioThreshold = 0.08
Config.MinFileSizeToScan = 100

Config.InitialScanDelay = 5000
Config.FileScanInterval = 120000
Config.NetworkCheckInterval = 60000
Config.MaxFileSizeToScan = 500000

Config.Advanced = {
    EnableBehaviorAnalysis = true,
    EnableEntropyAnalysis = true,
    EnableNetworkDeepInspection = true,
    EnableCodeAnalysis = true,
    
    EntropyThreshold = 5.5,
    
    BehaviorScoreThreshold = 75,
    
    SuspiciousCallChains = {
        {"loadstring", "PerformHttpRequest"},
        {"eval", "fetch"},
        {"Function", "XMLHttpRequest"},
    },
    
    IgnoreCallChainResources = {
        "monitor",
        "ox_lib",
        "qbx_core",
        "DERP-ambulancejob",
    },
    
    MaxHTTPCallsPerMinute = 20,
    MaxEventTriggersPerMinute = 100,
    MaxFileReadsPerMinute = 50,
    
    KnownC2Patterns = {
        "/api/v1/data",
        "/webhook",
        "/collector",
        "/beacon",
        "/c2",
    },
    
    SuspiciousFunctionNames = {
        "backdoor",
        "inject",
        "exploit",
        "payload",
        "shell",
        "rootkit",
        "keylog",
        "stealer",
    },

    IgnoreHighEntropyFiles = {
        "weapons%.lua$",
        "shared%.lua$",
        "config%.lua$",
        "items%.lua$",
        "vehicles%.lua$",
        "jobs%.lua$",
        "gangs%.lua$",
    },
    
    LearningMode = true,
    AutoWhitelistAfterDays = 7,
}