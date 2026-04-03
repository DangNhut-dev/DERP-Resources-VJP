function CalculateEntropy(str)
    if not str or #str == 0 then return 0 end
    
    local frequency = {}
    local length = #str
    
    for i = 1, length do
        local char = str:sub(i, i)
        frequency[char] = (frequency[char] or 0) + 1
    end
    
    local entropy = 0
    for char, count in pairs(frequency) do
        local probability = count / length
        entropy = entropy - (probability * math.log(probability) / math.log(2))
    end
    
    return entropy
end

function IsHighEntropy(content)
    local sampleSize = math.min(#content, 1000)
    local sample = content:sub(1, sampleSize)
    
    local entropy = CalculateEntropy(sample)
    
    return entropy > Config.Advanced.EntropyThreshold, entropy
end

function DetectObfuscationByEntropy(content)
    local lines = {}
    for line in content:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    
    local highEntropyLines = 0
    local totalLines = #lines
    
    for _, line in ipairs(lines) do
        if #line > 50 then
            local entropy = CalculateEntropy(line)
            if entropy > Config.Advanced.EntropyThreshold then
                highEntropyLines = highEntropyLines + 1
            end
        end
    end
    
    local ratio = highEntropyLines / math.max(totalLines, 1)
    return ratio > 0.3, ratio
end