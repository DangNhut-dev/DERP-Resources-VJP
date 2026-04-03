function DetectDynamicCodeExecution(content)
    local patterns = {
        "_G%[.-%]%s*%(", 
        "getfenv%s*%(",
        "setfenv%s*%(",
        "debug%.getinfo",
        "debug%.setmetatable",
    }
    
    local matches = {}
    for _, pattern in ipairs(patterns) do
        for match in content:gmatch(pattern) do
            table.insert(matches, {pattern = pattern, match = match})
        end
    end
    
    return #matches > 0, matches
end

function DetectSuspiciousStringConcatenation(content)
    local patterns = {
        'local%s+%w+%s*=%s*"[^"]*"%s*%.%.%s*"[^"]*"%s*%.%.',
        'local%s+%w+%s*=%s*\'[^\']*\'%s*%.%.%s*\'[^\']*\'%s*%.%.',
        'string%.char%s*%(',
    }
    
    local suspiciousCount = 0
    for _, pattern in ipairs(patterns) do
        for _ in content:gmatch(pattern) do
            suspiciousCount = suspiciousCount + 1
        end
    end
    
    return suspiciousCount > 5, suspiciousCount
end

function DetectPolymorphicCode(content)
    local varTablePattern = "local%s+%w+%s*=%s*{.-}"
    local tables = {}
    
    for match in content:gmatch(varTablePattern) do
        table.insert(tables, match)
    end
    
    if #tables > 20 then
        local indexAccessCount = 0
        for _ in content:gmatch("%w+%[%d+%]") do
            indexAccessCount = indexAccessCount + 1
        end
        
        if indexAccessCount > 50 then
            return true, {tables = #tables, accesses = indexAccessCount}
        end
    end
    
    return false, nil
end