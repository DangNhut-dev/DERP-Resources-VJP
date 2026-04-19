Utils = {}

-- Tinh so NPC unlock dua tren tong trust
function Utils.GetUnlockedCount(totalTrust)
    local count = 0
    for i = 1, #Config.UnlockTiers do
        if totalTrust >= Config.UnlockTiers[i] then
            count = i
        else
            break
        end
    end
    if count > #NPCs then count = #NPCs end
    return count
end

-- Random tin nhan template
function Utils.PickTemplate(key)
    local list = Config.ChatTemplates[key]
    if not list or #list == 0 then return '' end
    return list[math.random(#list)]
end

-- Format tien
function Utils.FormatMoney(n)
    if not n then return '0' end
    local formatted = tostring(math.floor(n))
    local k
    repeat
        formatted, k = formatted:gsub('^(-?%d+)(%d%d%d)', '%1,%2')
    until k == 0
    return formatted
end

-- Convert phut game -> giay real
function Utils.GameMinutesToRealSeconds(gameMinutes)
    return gameMinutes * Config.GameToRealSecondsRatio
end

-- Convert giay real -> phut game
function Utils.RealSecondsToGameMinutes(realSeconds)
    return math.floor(realSeconds / Config.GameToRealSecondsRatio)
end

-- Tinh gia NPC san sang tra dua tren trust va item quality
-- trust: 0-100, item: config item
-- return: gia/gram NPC chap nhan
function Utils.CalculateAcceptablePrice(trust, item)
    if not item then return 0 end
    local t = math.max(0, math.min(100, trust or 0))
    local biasFactor = 1 - ((item.qualityBias or 1) - 1) * 0.1
    local trustFactor = t / 100
    local price = item.priceMin + (item.priceMax - item.priceMin) * trustFactor * biasFactor
    return math.floor(price)
end

-- Gia offer khoi diem cua NPC (thap hon acceptable de co cho deal)
function Utils.CalculateInitialOffer(trust, item)
    local acceptable = Utils.CalculateAcceptablePrice(trust, item)
    local offer = acceptable * (0.7 + math.random() * 0.15)
    return math.max(item.priceMin, math.floor(offer))
end
