local QBX = exports.qbx_core
local allEvents = {
    ["orbit-chopshop:server:choptrunk"] = false,
    ["orbit-chopshop:server:chophood"] = false,
    ["orbit-chopshop:server:chopwheel"] = false,
    ["orbit-chopshop:server:chopdoor"] = false,
}
local fiveguard_resource = "svc_runtime"
AddEventHandler("fg:ExportsLoaded", function(fiveguard_res, res)
    if res == "*" or res == GetCurrentResourceName() then
        fiveguard_resource = fiveguard_res
        for event,cross_scripts in pairs(allEvents) do
            local retval, errorText = exports[fiveguard_res]:RegisterSafeEvent(event, {
                ban = true,
                log = true
            }, cross_scripts)
            if not retval then
                print("[fiveguard safe-events] "..errorText)
            end
        end
    end
end)

local Cooldowns = {}
local ActiveJobs = {}

local SpawnedJobVehicles = {}
local PendingJobVehicles = {}

local function generatePlate()
    local plate = ""
    for _ = 1, 3 do
        plate = plate .. string.char(math.random(65, 90))
    end
    plate = plate .. tostring(math.random(100, 999))
    return plate
end

local function cleanupJobVehicle(citizenid)
    local data = SpawnedJobVehicles[citizenid]
    if data and data.netId then
        local entity = NetworkGetEntityFromNetworkId(data.netId)
        if entity and entity ~= 0 and DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
    end
    SpawnedJobVehicles[citizenid] = nil
    PendingJobVehicles[citizenid] = nil
end

lib.callback.register('orbit-chopshop:server:reserveJobVehicle', function(source, model, coords)
    local player = QBX:GetPlayer(source)
    if not player then return nil end

    local citizenid = player.PlayerData.citizenid
    if not ActiveJobs[citizenid] then return nil end

    if type(model) ~= 'string' or model == '' then return nil end
    if type(coords) ~= 'table' or not coords.x or not coords.y or not coords.z or not coords.w then return nil end

    PendingJobVehicles[citizenid] = nil
    cleanupJobVehicle(citizenid)
    ActiveJobs[citizenid] = true

    local plate = generatePlate()

    PendingJobVehicles[citizenid] = {
        model = model,
        coords = coords,
        plate = plate,
        reservedAt = os.time(),
    }

    SetTimeout(60 * 60 * 1000, function()
        local pending = PendingJobVehicles[citizenid]
        if pending and pending.reservedAt and (os.time() - pending.reservedAt) >= (60 * 60) then
            PendingJobVehicles[citizenid] = nil
            ActiveJobs[citizenid] = nil
            local target = QBX:GetPlayer(source)
            if target then
                TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Nhiệm vụ đã bị hủy do quá thời gian' })
                TriggerClientEvent('orbit-chopshop:client:forceCancel', source)
            end
        end
    end)

    return { plate = plate }
end)

lib.callback.register('orbit-chopshop:server:spawnReservedVehicle', function(source)
    local player = QBX:GetPlayer(source)
    if not player then return nil end

    local citizenid = player.PlayerData.citizenid
    local pending = PendingJobVehicles[citizenid]
    if not pending then return nil end

    if SpawnedJobVehicles[citizenid] then
        return {
            netId = SpawnedJobVehicles[citizenid].netId,
            plate = SpawnedJobVehicles[citizenid].plate,
        }
    end

    local hash = joaat(pending.model)
    local veh = CreateVehicleServerSetter(hash, 'automobile', pending.coords.x, pending.coords.y, pending.coords.z, pending.coords.w)

    if not veh or veh == 0 or not DoesEntityExist(veh) then
        return nil
    end

    -- Đợi entity stream ổn định
    local timeout = 0
    while not DoesEntityExist(veh) and timeout < 100 do
        Wait(20)
        timeout = timeout + 1
    end

    if not DoesEntityExist(veh) then return nil end

    -- Tăng culling radius để entity không bị despawn khi player đi xa tạm thời
    SetEntityDistanceCullingRadius(veh, 500.0)

    local netId = NetworkGetNetworkIdFromEntity(veh)

    SpawnedJobVehicles[citizenid] = {
        entity = veh,
        netId = netId,
        plate = pending.plate,
    }

    PendingJobVehicles[citizenid] = nil

    TriggerClientEvent('orbit-chopshop:client:repairSpawnedVehicle', source, netId, pending.plate)

    return {
        netId = netId,
        plate = pending.plate,
    }
end)

-- Verify plate sau khi client repair - nếu sai thì force set lại
RegisterNetEvent('orbit-chopshop:server:confirmPlate', function(netId, actualPlate)
    local src = source
    local player = QBX:GetPlayer(src)
    if not player then return end

    local citizenid = player.PlayerData.citizenid
    local spawned = SpawnedJobVehicles[citizenid]
    if not spawned then return end

    if spawned.netId ~= netId then return end

    local cleanActual = actualPlate and actualPlate:gsub('%s+', '') or ''
    local cleanExpect = spawned.plate and spawned.plate:gsub('%s+', '') or ''

    if cleanActual ~= cleanExpect then
        TriggerClientEvent('orbit-chopshop:client:forceSetPlate', src, netId, spawned.plate)
    end
end)

local function isResourceStarted(resourceName)
    return GetResourceState(resourceName) == 'started'
end

local function getItemLabel(itemName)
    if not itemName or itemName == '' then
        return ''
    end

    if not isResourceStarted('ox_inventory') then
        return tostring(itemName)
    end

    local ok, itemData = pcall(function()
        return exports.ox_inventory:Items(itemName)
    end)

    if ok and type(itemData) == 'table' and itemData.label and itemData.label ~= '' then
        return tostring(itemData.label)
    end

    return tostring(itemName)
end

local function formatLogItem(itemName, count, metadata, prefix)
    local item = tostring(itemName or '')
    local amount = math.floor(tonumber(count) or 0)
    local label = getItemLabel(item)
    local display = item

    if label ~= '' and label ~= item then
        display = ('%s(%s)'):format(item, label)
    end

    if type(metadata) == 'table' and metadata.worth ~= nil then
        display = ('%s [worth:%s]'):format(display, math.floor(tonumber(metadata.worth) or 0))
    end

    if amount > 0 then
        return ('%s%s x%s'):format(prefix or '+', display, amount)
    end

    return ('%s%s'):format(prefix or '+', display)
end

local function forwardActionLog(anyPlayer, actionText, opts)
    if not actionText or actionText == '' then
        return false
    end

    opts = opts or {}

    if isResourceStarted('ox_inventory') then
        local ok = pcall(function()
            exports.ox_inventory:AddActionLog(anyPlayer, actionText, opts)
        end)

        if ok then
            return true
        end
    end

    if isResourceStarted('js_ranking') then
        local ok = pcall(function()
            exports['js_ranking']:AddActionLog(anyPlayer, actionText, opts)
        end)

        if ok then
            return true
        end
    end

    return false
end

exports('AddActionLog', forwardActionLog)

local function addChopshopActionLog(src, actionTitle, details, itemEntries)
    local parts = {
        ('[chopshop] | %s'):format(tostring(actionTitle or 'Chopshop'))
    }

    if details and details ~= '' then
        parts[#parts + 1] = tostring(details)
    end

    if type(itemEntries) == 'table' and #itemEntries > 0 then
        local formattedItems = {}

        for i = 1, #itemEntries do
            local entry = itemEntries[i]
            if type(entry) == 'table' and entry.name then
                formattedItems[#formattedItems + 1] = formatLogItem(entry.name, entry.count, entry.metadata, entry.prefix)
            end
        end

        if #formattedItems > 0 then
            parts[#parts + 1] = ('item: %s'):format(table.concat(formattedItems, ', '))
        end
    end

    if #parts <= 1 then
        return false
    end

    return forwardActionLog(src, table.concat(parts, ' | '), {
        source = src,
        deferMs = 0,
    })
end

local function getRewardActionTitle(data)
    if data == 'door' then
        return 'Tháo Cửa Xe'
    elseif data == 'hood' then
        return 'Tháo Két Nước'
    elseif data == 'trunk' then
        return 'Tháo Cốp Xe'
    elseif data == 'wheel1' or data == 'wheel2' or data == 'wheel3' or data == 'wheel4' then
        return 'Tháo Bánh Xe'
    end

    return 'Tháo Bộ Phận Xe'
end

local function IsOnCooldown(citizenid)
    if not Cooldowns[citizenid] then return false end
    return (os.time() - Cooldowns[citizenid]) < (Config.CoolDown * 60)
end

local function GetCooldownRemaining(citizenid)
    if not Cooldowns[citizenid] then return 0 end
    local remaining = (Config.CoolDown * 60) - (os.time() - Cooldowns[citizenid])
    return math.max(0, math.ceil(remaining / 60))
end

local function SetCooldown(citizenid)
    Cooldowns[citizenid] = os.time()
end

local function getOnDutyPoliceCount()
    local count = 0
    for _, v in pairs(exports.qbx_core:GetQBPlayers()) do
        if v and v.PlayerData.job.type == 'leo' and v.PlayerData.job.onduty then
            count = count + 1
        end
    end
    return count
end

lib.callback.register('orbit-chopshop:server:requestJob', function(source)
    local player = QBX:GetPlayer(source)
    if not player then return { allowed = false } end

    -- if getOnDutyPoliceCount() < 1 then
    --     return { allowed = false, reason = 'no_police' }
    -- end

    local citizenid = player.PlayerData.citizenid

    if ActiveJobs[citizenid] then
        return { allowed = false, reason = 'active' }
    end

    if IsOnCooldown(citizenid) then
        return { allowed = false, reason = 'cooldown', remaining = GetCooldownRemaining(citizenid) }
    end

    ActiveJobs[citizenid] = true
    return { allowed = true }
end)

RegisterNetEvent('orbit-chopshop:server:jobComplete', function()
    local src = source
    local player = QBX:GetPlayer(src)
    if not player then return end

    local citizenid = player.PlayerData.citizenid
    SetCooldown(citizenid)
    ActiveJobs[citizenid] = nil
    cleanupJobVehicle(citizenid)
end)

RegisterNetEvent('orbit-chopshop:server:jobCancel', function()
    local src = source
    local player = QBX:GetPlayer(src)
    if not player then return end

    local citizenid = player.PlayerData.citizenid
    ActiveJobs[citizenid] = nil
    cleanupJobVehicle(citizenid)
end)

AddEventHandler('playerDropped', function()
    local src = source
    local player = QBX:GetPlayer(src)
    if not player then return end
    local citizenid = player.PlayerData.citizenid
    ActiveJobs[citizenid] = nil
    cleanupJobVehicle(citizenid)
end)

local function CanCarryItem(src, item, amount)
    local canCarry = exports.ox_inventory:CanCarryItem(src, item, amount)
    return canCarry
end

local function NotifyFull(src)
    TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Balo đã đầy, không thể nhận thêm!' })
end

local function GiveReward(data)
    local src = source
    local Player = QBX:GetPlayer(src)
    if not Player then return end

    local rewardedItems = {}

    if data == "wheel1" or data == "wheel2" or data == "wheel3" or data == "wheel4" then
        if not CanCarryItem(src, "car_wheel", 1) then return NotifyFull(src) end
        local added = Player.Functions.AddItem("car_wheel", 1)

        if added ~= false then
            rewardedItems[#rewardedItems + 1] = { name = 'car_wheel', count = 1, prefix = '+' }
        end
    elseif data == "door" then
        if not CanCarryItem(src, "car_door", 1) then return NotifyFull(src) end
        local added = Player.Functions.AddItem("car_door", 1)

        if added ~= false then
            rewardedItems[#rewardedItems + 1] = { name = 'car_door', count = 1, prefix = '+' }
        end
    elseif data == "hood" then
        if not CanCarryItem(src, "radiator", 1) then return NotifyFull(src) end
        local added = Player.Functions.AddItem("radiator", 1)

        if added ~= false then
            rewardedItems[#rewardedItems + 1] = { name = 'radiator', count = 1, prefix = '+' }
        end
    elseif data == "trunk" then
        if math.random(1, 100) <= 50 then
            local randomitem = math.random(1, #Config.TrunkItems)
            local item = Config.TrunkItems[randomitem]["item"]
            local amount = Config.TrunkItems[randomitem]["amount"]

            if CanCarryItem(src, item, amount) then
                local addedRandom = Player.Functions.AddItem(item, amount)

                if addedRandom ~= false then
                    rewardedItems[#rewardedItems + 1] = { name = item, count = amount, prefix = '+' }
                end
            else
                NotifyFull(src)
            end
        end
        Wait(8500)
        if CanCarryItem(src, "trunk", 1) then
            local added = Player.Functions.AddItem("trunk", 1)

            if added ~= false then
                rewardedItems[#rewardedItems + 1] = { name = 'trunk', count = 1, prefix = '+' }
            end
        else
            NotifyFull(src)
        end
    end

    if #rewardedItems > 0 then
        addChopshopActionLog(src, getRewardActionTitle(data), nil, rewardedItems)
    end
end

RegisterNetEvent('orbit-chopshop:server:callCops', function(type, bank, streetLabel, coords, vehicleModel, plate)
    if GetResourceState('lb-tablet') ~= 'started' then return end

    -- exports['lb-tablet']:AddDispatch({
    --     priority = 'high',
    --     code = '10-35',
    --     title = 'Trộm Xe Đi Rã',
    --     description = 'Phát hiện hành vi trộm xe tại ' .. (streetLabel or 'không xác định'),
    --     location = {
    --         label = streetLabel or 'Không xác định',
    --         coords = coords and vec2(coords.x, coords.y) or nil,
    --     },
    --     time = 120,
    --     job = 'police',
    --     fields = {
    --         { icon = 'fas fa-car', label = 'Biển số', value = plate or 'Không rõ' },
    --         { icon = 'fas fa-map-marker-alt', label = 'Vị trí', value = streetLabel or 'Không rõ' },
    --     },
    --     blip = {
    --         sprite = 227,
    --         color = 1,
    --         size = 1.5,
    --         label = 'Trộm Xe - ' .. (plate or ''),
    --     },
    -- })
end)

RegisterNetEvent("orbit-chopshop:server:rewardplayer", GiveReward)

RegisterNetEvent("orbit-chopshop:syncchopcars", function(list)
    TriggerClientEvent('orbit-chopshop:carlist', -1, list)
end)

RegisterNetEvent("orbit-chopshop:server:chopdoor", function()
    local src = source
    if fiveguard_resource ~= "" and GetResourceState(fiveguard_resource) == 'started' then
        if not exports[fiveguard_resource]:VerifyToken(src) then return end
    end
    local Player = QBX:GetPlayer(src)
    if not Player then return end

    if not Player.Functions.GetItemByName("car_door") then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Bạn không có cửa xe để rã' })
        return
    end

    local randomitem = math.random(1, #Config.DoorItems)
    local item = Config.DoorItems[randomitem]["item"]
    local amount = Config.DoorItems[randomitem]["amount"]

    if not CanCarryItem(src, item, amount) then return NotifyFull(src) end

    local removed = Player.Functions.RemoveItem("car_door", 1)
    if removed == false then return end

    TriggerClientEvent('orbit-chopshop:doorchopanim', src)
    Wait(12500)

    local added = Player.Functions.AddItem(item, amount)
    if added ~= false then
        addChopshopActionLog(src, 'Rã Cửa Xe', nil, {
            { name = 'car_door', count = 1, prefix = '-' },
            { name = item, count = amount, prefix = '+' },
        })
    end
end)

RegisterNetEvent("orbit-chopshop:server:chopwheel", function()
    local src = source
    if fiveguard_resource ~= "" and GetResourceState(fiveguard_resource) == 'started' then
        if not exports[fiveguard_resource]:VerifyToken(src) then return end
    end
    local Player = QBX:GetPlayer(src)
    if not Player then return end

    if not Player.Functions.GetItemByName("car_wheel") then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Bạn không có bánh xe để rã' })
        return
    end

    local randomitem = math.random(1, #Config.WheelItems)
    local item = Config.WheelItems[randomitem]["item"]
    local amount = Config.WheelItems[randomitem]["amount"]

    if not CanCarryItem(src, item, amount) then return NotifyFull(src) end

    local removed = Player.Functions.RemoveItem("car_wheel", 1)
    if removed == false then return end

    TriggerClientEvent('orbit-chopshop:wheelchopanim', src)
    Wait(14000)

    local added = Player.Functions.AddItem(item, amount)
    if added ~= false then
        addChopshopActionLog(src, 'Rã Bánh Xe', nil, {
            { name = 'car_wheel', count = 1, prefix = '-' },
            { name = item, count = amount, prefix = '+' },
        })
    end
end)

RegisterNetEvent("orbit-chopshop:server:chophood", function()
    local src = source
    if fiveguard_resource ~= "" and GetResourceState(fiveguard_resource) == 'started' then
        if not exports[fiveguard_resource]:VerifyToken(src) then return end
    end
    local Player = QBX:GetPlayer(src)
    if not Player then return end

    if not Player.Functions.GetItemByName("radiator") then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Bạn không có nắp capô để rã' })
        return
    end

    local randomitem = math.random(1, #Config.DoorItems)
    local item = Config.DoorItems[randomitem]["item"]
    local amount = Config.DoorItems[randomitem]["amount"]

    if not CanCarryItem(src, item, amount) then return NotifyFull(src) end

    local removed = Player.Functions.RemoveItem("radiator", 1)
    if removed == false then return end

    TriggerClientEvent('orbit-chopshop:hoodchopanim', src)
    Wait(12500)

    local added = Player.Functions.AddItem(item, amount)
    if added ~= false then
        addChopshopActionLog(src, 'Rã Két Nước', nil, {
            { name = 'radiator', count = 1, prefix = '-' },
            { name = item, count = amount, prefix = '+' },
        })
    end
end)

RegisterNetEvent("orbit-chopshop:server:choptrunk", function()
    local src = source
    if fiveguard_resource ~= "" and GetResourceState(fiveguard_resource) == 'started' then
        if not exports[fiveguard_resource]:VerifyToken(src) then return end
    end
    local Player = QBX:GetPlayer(src)
    if not Player then return end

    if not Player.Functions.GetItemByName("trunk") then
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Bạn không có cốp xe để rã' })
        return
    end

    local randomitem = math.random(1, #Config.DoorItems)
    local item = Config.DoorItems[randomitem]["item"]
    local amount = Config.DoorItems[randomitem]["amount"]

    if not CanCarryItem(src, item, amount) then return NotifyFull(src) end

    local removed = Player.Functions.RemoveItem("trunk", 1)
    if removed == false then return end

    TriggerClientEvent('orbit-chopshop:trunkchopanim', src)
    Wait(12500)

    local added = Player.Functions.AddItem(item, amount)
    if added ~= false then
        addChopshopActionLog(src, 'Rã Cốp Xe', nil, {
            { name = 'trunk', count = 1, prefix = '-' },
            { name = item, count = amount, prefix = '+' },
        })
    end
end)

RegisterNetEvent('orbit-chopshop:server:cleanupJobVehicle', function()
    local src = source
    local player = QBX:GetPlayer(src)
    if not player then return end
    cleanupJobVehicle(player.PlayerData.citizenid)
end)