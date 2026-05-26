math.randomseed(os.time())

---@param first { price: integer }
---@param second { price: integer }
local function sortByPrice(first, second)
    return first.price < second.price
end

table.sort(Config.fishingRods, sortByPrice)
table.sort(Config.baits, sortByPrice)

for _, zone in ipairs(Config.fishingZones) do
    if zone.includeOutside then
        for _, fishName in ipairs(Config.outside.fishList) do
            table.insert(zone.fishList, fishName)
        end
    end
end

---@param fish string[]
local function getRandomFish(fish)
    local sum = 0

    for _, fishName in ipairs(fish) do
        sum += Config.fish[fishName].chance
    end

    sum = math.floor(sum)

    local value = math.random(sum)
    local last = 1

    for i = 1, #fish do
        local current = Config.fish[fish[i]].chance

        if value >= last and value < last + current then
            return fish[i]
        end

        last += current
    end
end

---@param player Player
---@return FishingBait?
local function getBestBait(player)
    for i = #Config.baits, 1, -1 do
        local bait = Config.baits[i]

        if player:getItemCount(bait.name) > 0 then
            return bait
        end
    end
end

local function getZoneName(currentZone)
    if not currentZone then
        return 'Biển mở'
    end

    local zone = Config.fishingZones[currentZone.index]

    if not zone then
        return ('Zone %s'):format(tostring(currentZone.index))
    end

    if zone.blip and zone.blip.name and zone.blip.name ~= '' then
        return zone.blip.name
    end

    return ('Zone %s'):format(tostring(currentZone.index))
end

---@type table<integer, boolean>
local busy = {}

for _, rod in ipairs(Config.fishingRods) do
    Framework.registerUsableItem(rod.name, function(source)
        local player = Framework.getPlayerFromId(source)

        if not player or player:getItemCount(rod.name) == 0 or busy[source] then return end

        busy[source] = true

        ---@type boolean, { index: integer, locationIndex: integer }?
        local hasWater, currentZone = lib.callback.await('derp-fishing:getCurrentZone', source)

        if not hasWater then
            busy[source] = nil
            return
        end

        if currentZone then
            local data = Config.fishingZones[currentZone.index]
            local coords = data.locations[currentZone.locationIndex]

            if #(GetEntityCoords(GetPlayerPed(source)) - coords) > data.radius then
                busy[source] = nil
                return
            end
        end

        local fishList = currentZone and Config.fishingZones[currentZone.index].fishList or Config.outside.fishList
        local playerLevel = math.floor(GetPlayerLevel(player))

        local availableFish = {}
        for _, fishName in ipairs(fishList) do
            if Config.fish[fishName] and Config.fish[fishName].minLevel <= playerLevel then
                availableFish[#availableFish + 1] = fishName
            end
        end

        if #availableFish == 0 then
            TriggerClientEvent('derp-fishing:showNotification', source, locale('no_fish_available'), 'error')
            busy[source] = nil
            return
        end

        local bait = getBestBait(player)

        if not bait then
            TriggerClientEvent('derp-fishing:showNotification', source, locale('no_bait'), 'error')
            busy[source] = nil
            return
        end

        local fishName = getRandomFish(availableFish)

        if not player:canCarryItem(fishName, 1) then
            busy[source] = nil
            return
        end

        local zoneName = getZoneName(currentZone)
        player:removeItem(bait.name, 1)
        local success = lib.callback.await('derp-fishing:itemUsed', source, bait, Config.fish[fishName])

        if success then
            player:addItem(fishName, 1)
            AddPlayerLevel(player, Config.progressPerCatch)
            Utils.logToDiscord(source, player, ('Caught a %s.'):format(Utils.getItemLabel(fishName)))
            Utils.logAction(source, 'Câu cá thành công', {
                { 'khu', zoneName },
                { 'danh sách', Utils.formatItemListLog({
                    { name = bait.name, count = 1, mode = 'remove' },
                    { name = fishName, count = 1, mode = 'add' }
                }) },
                { 'mồi', Utils.formatItemLog(bait.name, 1, 'remove') },
                { 'cá', Utils.formatItemLog(fishName, 1, 'add') },
            })
        else
            local brokeRod = math.random(100) <= rod.breakChance
            local itemLogs = {
                { name = bait.name, count = 1, mode = 'remove' }
            }

            if brokeRod then
                player:removeItem(rod.name, 1)
                itemLogs[#itemLogs + 1] = { name = rod.name, count = 1, mode = 'remove' }
                TriggerClientEvent('derp-fishing:showNotification', source, locale('rod_broke'), 'error')

                Utils.logAction(source, 'Câu hụt - gãy cần', {
                    { 'khu', zoneName },
                    { 'danh sách', Utils.formatItemListLog(itemLogs) },
                    { 'mồi', Utils.formatItemLog(bait.name, 1, 'remove') },
                    { 'cần', Utils.formatItemLog(rod.name, 1, 'remove') },
                })
            else
                Utils.logAction(source, 'Câu hụt', {
                    { 'khu', zoneName },
                    { 'danh sách', Utils.formatItemListLog(itemLogs) },
                    { 'mồi', Utils.formatItemLog(bait.name, 1, 'remove') },
                })
            end
        end

        busy[source] = nil
    end)
end


local autoFishing = {}
 
-- Tim can cau tot nhat player dang co
local function getBestRod(player)
    for i = #Config.fishingRods, 1, -1 do
        local rod = Config.fishingRods[i]
        if player:getItemCount(rod.name) > 0 then
            return rod
        end
    end
end
 
lib.addCommand('autofish', {
    help = 'Bat/tat tu dong cau ca'
}, function(source)
    local player = Framework.getPlayerFromId(source)
    if not player then return end
 
    local citizenid = exports.qbx_core:GetPlayer(source).PlayerData.citizenid
 
    if not Config.autofishWhitelist[citizenid] then
        TriggerClientEvent('derp-fishing:showNotification', source, 'Bạn không có quyền sử dụng lệnh này.', 'error')
        return
    end
 
    if autoFishing[source] then
        autoFishing[source] = false
        TriggerClientEvent('derp-fishing:showNotification', source, 'Đã tắt tự động câu cá.', 'inform')
        return
    end
 
    autoFishing[source] = true
    TriggerClientEvent('derp-fishing:showNotification', source, 'Đã bật tự động câu cá.', 'success')
 
    CreateThread(function()
        while autoFishing[source] do
            if busy[source] then
                Wait(500)
                goto continue
            end
 
            busy[source] = true
 
            local rod = getBestRod(player)
            if not rod then
                autoFishing[source] = false
                busy[source] = nil
                TriggerClientEvent('derp-fishing:showNotification', source, 'Không có cần câu.', 'error')
                break
            end
 
            local hasWater, currentZone = lib.callback.await('derp-fishing:getCurrentZone', source)
 
            if not hasWater then
                autoFishing[source] = false
                busy[source] = nil
                TriggerClientEvent('derp-fishing:showNotification', source, 'Không có nước phía trước.', 'error')
                break
            end
 
            if currentZone then
                local data = Config.fishingZones[currentZone.index]
                local coords = data.locations[currentZone.locationIndex]
                if #(GetEntityCoords(GetPlayerPed(source)) - coords) > data.radius then
                    busy[source] = nil
                    Wait(1000)
                    goto continue
                end
            end
 
            local bait = getBestBait(player)
            if not bait then
                autoFishing[source] = false
                busy[source] = nil
                TriggerClientEvent('derp-fishing:showNotification', source, 'Hết mồi câu, dừng tự động.', 'error')
                break
            end
 
            local fishList = currentZone and Config.fishingZones[currentZone.index].fishList or Config.outside.fishList
            local playerLevel = math.floor(GetPlayerLevel(player))
 
            local availableFish = {}
            for _, fishName in ipairs(fishList) do
                if Config.fish[fishName] and Config.fish[fishName].minLevel <= playerLevel then
                    availableFish[#availableFish + 1] = fishName
                end
            end
 
            if #availableFish == 0 then
                busy[source] = nil
                goto continue
            end
 
            local fishName = getRandomFish(availableFish)
 
            local zone = Config.fishingZones[currentZone and currentZone.index] or Config.outside
            player:removeItem(bait.name, 1)

            if not exports.ox_inventory:CanCarryItem(source, fishName, 1) then
                player:addItem(bait.name, 1)
                autoFishing[source] = false
                busy[source] = nil
                TriggerClientEvent('derp-fishing:showNotification', source, 'Túi đồ đầy, dừng tự động.', 'error')
                break
            end

            local success = lib.callback.await('derp-fishing:itemUsedAuto', source, zone)

            if success then
                player:addItem(fishName, 1)
                AddPlayerLevel(player, Config.progressPerCatch)
            end
 
            busy[source] = nil
            ::continue::
        end
 
        autoFishing[source] = nil
    end)
end)
 
-- Cleanup khi player disconnect
AddEventHandler('playerDropped', function()
    local src = source
    autoFishing[src] = nil
    busy[src] = nil
end)