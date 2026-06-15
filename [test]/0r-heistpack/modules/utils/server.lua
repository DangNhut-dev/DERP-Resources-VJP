--[[ Contains server-side helper functions. ]]

--[[ Dependencies ]]

local Framework = require "modules.framework.init"

local Utils = {}

-- Get active police count
function Utils.getPoliceCount()
    local count = 0
    local requiredOnDuty = Config.policeOptions.requiredOnDuty
    for _, playerId in pairs(GetPlayers()) do
        local numPlayerId = tonumber(playerId)
        if numPlayerId then
            local xPlayerJob = Framework.getPlayerJob(numPlayerId)
            local isPlayerPolice = xPlayerJob and
                lib.table.contains(Config.policeOptions.jobNames or {}, xPlayerJob.name)
            if isPlayerPolice then
                if requiredOnDuty then
                    if xPlayerJob.onDuty then
                        count = count + 1
                    end
                else
                    count = count + 1
                end
            end
        end
    end
    return count
end

-- Deletes a networked object by its network ID(s)
function Utils.deleteNetworkedObjects(objectNetId)
    if (type(objectNetId) ~= "table") then
        objectNetId = { objectNetId }
    end
    if #objectNetId == 0 then return false end

    for _, netId in ipairs(objectNetId) do
        local entity = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
    end

    return true
end

-- Selects random reward items based on their chance configuration
---@param items RewardItem[]
---@return { name: string, count: number }[]
function Utils.selectRandomRewards(items)
    local selectedItems = {}

    for _, item in pairs(items or {}) do
        local randomChance = math.random()
        if randomChance <= (item.chance or 1.0) then
            local quantity = item.quantity or { min = 1, max = 1 }
            local count = math.random(quantity.min or 1, quantity.max or 1)
            table.insert(selectedItems, { name = item.itemName, count = count })
        end
    end

    return selectedItems
end

function Utils.generateUniquePin(digitCount)
    digitCount = math.max(1, math.min(digitCount or 3, 9))

    local digits = {}
    while #digits < digitCount do
        local digit = math.random(1, 9)
        if not lib.table.contains(digits, digit) then
            table.insert(digits, digit)
        end
    end

    return digits
end

local DispatchMap = {
    ammunation_robbery = { code = '10-90', title = 'Cướp Ammunation', blip = { sprite = 110, color = 1, size = 1.5 } },
    atm_robbery        = { code = '10-65', title = 'Cướp ATM',                 blip = { sprite = 500, color = 1, size = 1.3 } },
    truck_robbery      = { code = '10-66', title = 'Cướp Xe Tải Container',     blip = { sprite = 477, color = 1, size = 1.5 } },
}

RegisterNetEvent('utils:triggerPoliceAlert', function(key, message, coords, streetLabel)
    local cfg = DispatchMap[key]
    if not cfg then return end

    exports['lb-tablet']:AddDispatch({
        priority = 'high',
        code = cfg.code,
        title = cfg.title,
        description = message,
        location = {
            label = streetLabel or 'Không xác định',
            coords = coords and vec2(coords.x, coords.y) or nil,
        },
        time = 120,
        job = 'police',
        fields = {
            { icon = 'fas fa-map-marker-alt', label = 'Vị trí', value = streetLabel or 'Không rõ' },
        },
        blip = {
            sprite = cfg.blip.sprite,
            color = cfg.blip.color,
            size = cfg.blip.size,
            label = cfg.title,
        },
    })
end)

return Utils
