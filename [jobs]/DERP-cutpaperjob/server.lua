local cooldowns = {}

local COOLDOWN_MS = Config.Work.interval - 2000

-- ============================
--   GIVE ITEM
-- ============================

RegisterNetEvent('DERP-cutpaper:server:giveItem', function(isDouble)
    local src = source
    if not src or src <= 0 then return end

    local now = GetGameTimer()
    if cooldowns[src] and (now - cooldowns[src]) < COOLDOWN_MS then return end
    cooldowns[src] = now

    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return end

    if GetEntityHealth(ped) <= 0 then return end
    if GetVehiclePedIsIn(ped, false) ~= 0 then return end

    local coords = GetEntityCoords(ped)
    local dist   = #(coords - Config.Zone.coord)
    if dist > Config.Zone.radius + 5.0 then return end

    local amount = isDouble == true and Config.Work.doubleAmount or Config.Work.itemAmount

    local scissorsSlots = exports.ox_inventory:Search(src, 'slots', Config.Work.requiredItem)
    if not scissorsSlots or not next(scissorsSlots) then return end
    local hasUsable = false
    for _, slot in pairs(scissorsSlots) do
        local dur = slot.metadata and slot.metadata.durability
        if dur == nil or dur > 0 then
            hasUsable = true
            break
        end
    end
    if not hasUsable then return end

    local success = exports.ox_inventory:AddItem(src, Config.Work.item, amount)
    if success then
        TriggerClientEvent('ox_lib:notify', src, {
            title       = 'Cắt Giấy',
            description = 'Nhận được ' .. amount .. 'x ' .. Config.Work.itemLabel,
            type        = 'success',
        })
    end
end)

-- ============================
--   CLEANUP ON DROP
-- ============================

AddEventHandler('playerDropped', function()
    cooldowns[source] = nil
end)