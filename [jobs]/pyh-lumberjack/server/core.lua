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