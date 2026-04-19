local ox_inventory = exports.ox_inventory

-- Cooldown chong spam mo phone
local openCooldown = {}
local COOLDOWN_MS = 500

-- Validate source co item phone khong
local function HasPhone(src)
    if not src or src <= 0 then return false end
    local count = ox_inventory:Search(src, 'count', Config.Item)
    return type(count) == 'number' and count > 0
end

-- Event mo phone (goi tu item client trigger hoac keybind)
RegisterNetEvent('derp-blackphone:server:requestOpen', function()
    local src = source
    if not src or src <= 0 then return end

    local now = GetGameTimer()
    if openCooldown[src] and now - openCooldown[src] < COOLDOWN_MS then return end
    openCooldown[src] = now

    if not HasPhone(src) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Phone',
            description = 'Bạn không có điện thoại',
            type = 'error'
        })
        return
    end

    TriggerClientEvent('derp-blackphone:client:open', src)
end)

-- Cleanup cooldown khi player roi server
AddEventHandler('playerDropped', function()
    local src = source
    openCooldown[src] = nil
end)

-- Export cho resource khac check
exports('hasPhone', HasPhone)