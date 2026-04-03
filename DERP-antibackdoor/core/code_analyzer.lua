CodeAnalyzer = {}

function CodeAnalyzer:AnalyzeLuaCode(content, fileName)
    local findings = {}
    local score = 0
    
    local hasDynamic, matches = DetectDynamicCodeExecution(content)
    if hasDynamic then
        table.insert(findings, "Dynamic code execution detected")
        score = score + 30
    end
    
    local hasSuspiciousConcat, count = DetectSuspiciousStringConcatenation(content)
    if hasSuspiciousConcat then
        table.insert(findings, "Suspicious string concatenation: " .. count)
        score = score + 20
    end
    
    local isPolymorphic, data = DetectPolymorphicCode(content)
    if isPolymorphic then
        table.insert(findings, "Polymorphic code pattern detected")
        score = score + 40
    end
    
    for _, funcName in ipairs(Config.Advanced.SuspiciousFunctionNames) do
        if content:lower():find(funcName, 1, true) then
            table.insert(findings, "Suspicious function name: " .. funcName)
            score = score + 15
        end
    end
    
    local isObfuscated, ratio = DetectObfuscationByEntropy(content)
    if isObfuscated then
        table.insert(findings, string.format("High entropy obfuscation: %.1f%%", ratio * 100))
        score = score + 35
    end
    
    return score, findings
end

function CodeAnalyzer:DetectCallChain(content)
    for _, chain in ipairs(Config.Advanced.SuspiciousCallChains) do
        local hasAll = true
        for _, func in ipairs(chain) do
            if not content:find(func, 1, true) then
                hasAll = false
                break
            end
        end
        
        if hasAll then
            return true, table.concat(chain, " -> ")
        end
    end
    
    return false, nil
end