local ox_inventory = exports.ox_inventory

-- Register useable item cho từng loại điếu qua qbx_core
for itemName in pairs(Config.Items) do
    exports.qbx_core:CreateUseableItem(itemName, function(src)
        if ox_inventory:Search(src, 'count', itemName) < 1 then return end
        TriggerClientEvent('DERP-smokeweed:client:smoke', src, itemName)
    end)
end

-- Trừ item khi consume thành công (client xác nhận progressbar hoàn tất)
RegisterNetEvent('DERP-smokeweed:server:consumed', function(itemName)
    local src = source
    if not Config.Items[itemName] then return end

    if ox_inventory:Search(src, 'count', itemName) < 1 then return end
    ox_inventory:RemoveItem(src, itemName, 1)
end)

-- Cancel event
RegisterNetEvent('DERP-smokeweed:server:cancelled', function(itemName)
    local src = source
    if not Config.Items[itemName] then return end
end)