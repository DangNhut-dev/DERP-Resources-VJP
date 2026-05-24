local Config = require 'shared.Market'

local ox_inventory = exports.ox_inventory
local dummyPrices = Config.prices

local function hasItem(currentShop, name)
    for i = 1, #currentShop do
        if currentShop[i].name == name then
            return true, i
        end
    end

    return false
end

local function reformatInventory(items)
    local changed = false
    local currentShop = {}
    local shopAmt = 0


    for _, v in pairs(items) do
        if dummyPrices[v.name] then
            local success, index = hasItem(currentShop, v.name)

            if success and index then
                currentShop[index].count += v.count
            else
                shopAmt += 1
                currentShop[shopAmt] = {
                    name = v.name,
                    count = v.count,
                    price = dummyPrices[v.name] + Config.upsale,
                }
            end

            changed = true
        end
    end

    if changed then
        table.sort(currentShop, function(a, b) return a.name < b.name end)

        ox_inventory:RegisterShop('Renewed_Farming_Market', {
            name = locale('farmers_market'),
            inventory = currentShop,
            locations = {
                Config.ped.coords.xyz,
            }
        })
    end
end


CreateThread(function()
    -- Money Stash noone can access --
    ox_inventory:RegisterStash('Farming_market_main', locale('farmers_market'), 90, 90000000, 'renewed', 'renewed', vec3(0.0, 0.0, 0.0))

    reformatInventory(ox_inventory:GetInventoryItems('Farming_market_main'))
end)

exports['Renewed-Lib']:CreateSaleStash('farming', 'Farmers Market', Config.prices, Config.ped.coords.xyz)

AddEventHandler('Renewed-Lib:server:soldStashItems', function(_, inventoryId, items)
    if inventoryId == 'stashshop_farming' then

        for _, v in pairs(items) do
            if v and v.name then
                ox_inventory:AddItem('Farming_market_main', v.name, v.count)
            end
        end

        reformatInventory(ox_inventory:GetInventoryItems('Farming_market_main'))
    end
end)

ox_inventory:registerHook('buyItem', function(payload)
    return ox_inventory:RemoveItem('Farming_market_main', payload.itemName, payload.count)
end, {
    typeFilter = {
        Renewed_Farming_Market = true
    }
})