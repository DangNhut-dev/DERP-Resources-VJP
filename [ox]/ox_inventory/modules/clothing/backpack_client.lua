-- modules/clothing/backpack_client.lua
-- Client-side backpack: request data from server, sync with NUI

local BackpackConfig = require 'modules.clothing.backpack_shared'

local BackpackClient = {}

-- Current backpack state
local currentBackpack = nil -- { idbalo, level, stashName, slots, maxWeight, label, items, weight }

-- ── Helpers ────────────────────────────────────────────────────

-- Convert items table to string-keyed object to prevent
-- Lua→JSON→JS array 0-index offset issue.
-- Lua table {[1]=a, [3]=b} encodes as JSON array [a,null,b] → JS arr[0]=a (WRONG)
-- String keys {"s1":a, "s3":b} encodes as JSON object → JS obj["s1"]=a (CORRECT)
---@param items table
---@param totalSlots number
---@return table stringKeyed
local function itemsToStringKeys(items, totalSlots)
    local result = {}
    for slot = 1, totalSlots do
        if items[slot] then
            result['s' .. slot] = items[slot]
        end
    end
    return result
end

-- ── Getters ────────────────────────────────────────────────────

---@return table|nil
function BackpackClient.GetCurrent()
    return currentBackpack
end

---@return boolean
function BackpackClient.IsEquipped()
    return currentBackpack ~= nil
end

-- ── Request backpack data from server ──────────────────────────

function BackpackClient.RequestSync()
    TriggerServerEvent('ox_inventory:requestBackpackData')
end

-- ── Server sends backpack data ─────────────────────────────────

RegisterNetEvent('ox_inventory:backpackData', function(data)
    if not data then
        currentBackpack = nil
        SendNUIMessage({
            action = 'backpackData',
            data = nil,
        })
        return
    end

    currentBackpack = data

    SendNUIMessage({
        action = 'backpackData',
        data = {
            idbalo = data.idbalo,
            level = data.level,
            label = data.label,
            stashName = data.stashName,
            slots = data.slots,
            maxWeight = data.maxWeight,
            weight = data.weight,
            items = itemsToStringKeys(data.items, data.slots),
        },
    })
end)

-- ── Server sends backpack item updates ─────────────────────────

RegisterNetEvent('ox_inventory:backpackUpdate', function(data)
    if not data or not currentBackpack then return end

    currentBackpack.items = data.items
    currentBackpack.weight = data.weight

    local totalSlots = currentBackpack.slots

    SendNUIMessage({
        action = 'backpackUpdate',
        data = {
            weight = data.weight,
            items = itemsToStringKeys(data.items, totalSlots),
            slots = totalSlots,
        },
    })
end)

-- ── NUI callbacks ──────────────────────────────────────────────

-- Swap between player/backpack inventories
RegisterNUICallback('backpackSwap', function(data, cb)
    if not currentBackpack then return cb(false) end

    TriggerServerEvent('ox_inventory:backpackSwap', {
        fromSlot = data.fromSlot,
        toSlot = data.toSlot,
        fromType = data.fromType, -- 'player' | 'backpack'
        toType = data.toType,     -- 'player' | 'backpack'
        count = data.count,
    })

    cb('ok')
end)

-- ── Clean up on backpack unequip ───────────────────────────────

function BackpackClient.OnUnequip()
    currentBackpack = nil
    SendNUIMessage({
        action = 'backpackData',
        data = nil,
    })
end

-- ── Export ──────────────────────────────────────────────────────

exports('getBackpackData', function()
    return currentBackpack
end)

return BackpackClient