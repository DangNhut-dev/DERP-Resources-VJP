local cooldowns = {}

local VALID_ITEM_TYPES = { mask = true, backpack = true }

local NOTIFY_LABELS = {
    mask     = 'mặt nạ',
    backpack = 'balo',
}

local SLOT_EMPTY_MSGS = {
    mask     = 'Người chơi không đeo mặt nạ',
    backpack = 'Người chơi không mang balo',
}

local function IsPoliceOnDuty(src)
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return false end
    local job = player.PlayerData.job
    return job.name == Config.PoliceJob and job.onduty == true
end

local function CheckCooldown(src)
    local now = GetGameTimer()
    if cooldowns[src] and (now - cooldowns[src]) < Config.CooldownMs then
        return false
    end
    cooldowns[src] = now
    return true
end

local function Notify(src, ntype, msg)
    TriggerClientEvent('DERP-unequipmaskandbaloPD:notify', src, ntype, msg)
end

RegisterNetEvent('DERP-unequipmaskandbaloPD:requestUnequip', function(targetSrc, itemType)
    local src = source

    targetSrc = tonumber(targetSrc)
    if not targetSrc or not VALID_ITEM_TYPES[itemType] then return end
    if src == targetSrc then return end

    if not CheckCooldown(src) then
        return Notify(src, 'error', 'Thao tác quá nhanh')
    end

    if not IsPoliceOnDuty(src) then
        return Notify(src, 'error', 'Bạn không phải cảnh sát đang làm việc')
    end

    if not GetPlayerName(targetSrc) then
        return Notify(src, 'error', 'Người chơi không hợp lệ')
    end

    local clothSlot = Config.ClothSlots[itemType]

    local result = exports['ox_inventory']:ForceStripClothSlot(targetSrc, clothSlot)

    if not result or not result.success then
        local err = result and result.err
        if err == 'slot_empty' then
            return Notify(src, 'error', SLOT_EMPTY_MSGS[itemType])
        else
            return Notify(src, 'error', 'Thao tác thất bại: ' .. tostring(err))
        end
    end

    local itemData = result.itemData
    if not itemData or not itemData.name then
        return Notify(src, 'error', 'Không lấy được thông tin vật phẩm')
    end

    local canCarry = exports.ox_inventory:CanCarryItem(src, itemData.name, 1)
    if not canCarry then
        return Notify(src, 'error', 'Túi đồ của bạn không đủ chỗ')
    end

    local added = exports.ox_inventory:AddItem(src, itemData.name, 1, itemData.metadata)
    if not added then
        return Notify(src, 'error', 'Không thể thêm vật phẩm vào túi')
    end

    local label = NOTIFY_LABELS[itemType]
    Notify(src, 'success', ('Đã tháo %s và cất vào túi'):format(label))
    Notify(targetSrc, 'error', ('Cảnh sát đã tháo %s của bạn'):format(label))
end)

AddEventHandler('playerDropped', function()
    cooldowns[source] = nil
end)