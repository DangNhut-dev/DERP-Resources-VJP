
function FormatVec3(coords)
    return ("vector3(%.2f, %.2f, %.2f)"):format(coords.x, coords.y, coords.z)
end

function GetRandomWeightedItem(pool)
    local poolsize = 0
    for _, v in pairs(pool) do
        poolsize = poolsize + v.weight
    end

    local selection = math.random(1, poolsize)
    local result

    for _, v in pairs(pool) do
        selection = selection - v.weight
        if (selection <= 0) then
            result = v
            break
        end
    end

    return result
end

function GetLootReward(lootRolls, lootTable, guaranteedRarities)
    if not lootRolls then
        lootRolls = 1
    end

    for _, loot in pairs(lootTable) do
        for _, item in pairs(loot) do
            if item.name:match("weapon_") then
                item.metadata = item.metadata or {}
                item.metadata.scratchedSerial = true
            end
        end
    end

    local loot = exports["prp-bridge"]:GenerateLoot(lootTable, lootRolls, guaranteedRarities)

    return loot
end

function GiveRewards(source, lootRolls, lootTable, guaranteedRarities)
    local loot = GetLootReward(lootRolls, lootTable, guaranteedRarities)
    for k, v in pairs(loot or {}) do
        bridge.inv.giveItem(source, v.name, v.count, v.metaData)
    end

    return loot
end
