-- modules/clothing/backpack_shared.lua
-- Backpack level config: slots, maxWeight per level

local BackpackConfig = {}

BackpackConfig.levels = {
    [0] = { slots = 10, maxWeight = 10000,  label = 'Ba lô' },
    [1] = { slots = 15, maxWeight = 15000,  label = 'Ba lô' },
    [2] = { slots = 15, maxWeight = 30000,  label = 'Ba lô' },
    [3] = { slots = 20, maxWeight = 35000,  label = 'Ba lô' },
    [4] = { slots = 20, maxWeight = 40000,  label = 'Ba lô' },
    [5] = { slots = 25, maxWeight = 50000,  label = 'Ba lô' },
    [6] = { slots = 30, maxWeight = 55000,  label = 'Ba lô' },
    [7] = { slots = 30, maxWeight = 65000,  label = 'Ba lô' },
    [8] = { slots = 35, maxWeight = 65000,  label = 'Ba lô' },
    [9] = { slots = 40, maxWeight = 70000,  label = 'Ba lô' },
    [10] = { slots = 50, maxWeight = 100000,  label = 'Ba lô' },
}

---@param level number
---@return table|nil { slots: number, maxWeight: number, label: string }
function BackpackConfig.GetLevel(level)
    return BackpackConfig.levels[level]
end

---@param idbalo string|number
---@return string
function BackpackConfig.GetStashName(idbalo)
    return ('balo_%s'):format(idbalo)
end

---@return string Unique balo ID
function BackpackConfig.GenerateId()
    return ('%s_%s'):format(os.time(), math.random(100000, 999999))
end

return BackpackConfig