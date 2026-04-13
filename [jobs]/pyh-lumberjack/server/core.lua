-- Lấy player object từ qbx_core
function GetPlayer(src)
    return exports.qbx_core:GetPlayer(src)
end

-- Notify server→client qua ox_lib
function Notify(src, msg, typ)
    TriggerClientEvent('ox_lib:notify', src, { description = msg, type = typ })
end

-- Thêm item qua ox_inventory
function AddItem(src, item, amount)
    return exports.ox_inventory:AddItem(src, item, amount)
end

-- Xóa item qua ox_inventory
function RemoveItem(src, item, amount)
    return exports.ox_inventory:RemoveItem(src, item, amount)
end

-- Lấy số lượng item
function GetItemCount(src, item)
    return exports.ox_inventory:GetItemCount(src, item) or 0
end

-- Đăng ký item useable qua qbx_core
function RegisterUsable(item, cb)
    exports.qbx_core:CreateUseableItem(item, cb)
end

function GetMoneySnapshot(src)
    local player = GetPlayer(src)
    local out = {}

    if not player or not player.PlayerData then
        return out
    end

    local money = player.PlayerData.money or {}
    for k, v in pairs(money) do
        out[k] = tonumber(v) or 0
    end

    if out.cash == nil and out.money ~= nil then
        out.cash = tonumber(out.money) or 0
    elseif out.money == nil and out.cash ~= nil then
        out.money = tonumber(out.cash) or 0
    end

    return out
end

function GetItemLabel(item)
    if Config and Config.itemLabels and Config.itemLabels[item] then
        return Config.itemLabels[item]
    end

    local ok, data = pcall(function()
        return exports.ox_inventory:Items(item)
    end)

    if ok and type(data) == 'table' then
        return data.label or data.name or item
    end

    return item
end

function BuildItemLogList(entries)
    if type(entries) ~= 'table' then
        return ''
    end

    local formatted = {}

    for i = 1, #entries do
        local entry = entries[i]
        if type(entry) == 'table' then
            local name = entry.name or entry.item
            local count = tonumber(entry.count or entry.amount or 0) or 0

            if name and count > 0 then
                formatted[#formatted + 1] = ('%sx %s(%s)'):format(count, name, GetItemLabel(name))
            end
        end
    end

    return table.concat(formatted, ', ')
end

function AddRankingLog(src, actionText, opts)
    if GetResourceState('js_ranking') ~= 'started' then
        return false
    end

    local ok = pcall(function()
        exports['js_ranking']:AddActionLog(src, actionText, opts or {})
    end)

    return ok
end
