local QBX = exports.qbx_core

local Cooldowns = {}
local ActiveJobs = {}

-- Kiểm tra cooldown theo citizenid
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

    if getOnDutyPoliceCount() < 2 then
        TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Không thể thực hiện được ngay bây giờ' })
        return { allowed = false, reason = 'no_police' }
    end

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

-- Client báo hoàn thành job → set cooldown
RegisterNetEvent('orbit-chopshop:server:jobComplete', function()
    local src = source
    local player = QBX:GetPlayer(src)
    if not player then return end

    local citizenid = player.PlayerData.citizenid
    SetCooldown(citizenid)
    ActiveJobs[citizenid] = nil
end)

-- Client báo hủy job (xe bị xa, v.v.)
RegisterNetEvent('orbit-chopshop:server:jobCancel', function()
    local src = source
    local player = QBX:GetPlayer(src)
    if not player then return end

    local citizenid = player.PlayerData.citizenid
    ActiveJobs[citizenid] = nil
end)

-- Cleanup khi player disconnect
AddEventHandler('playerDropped', function()
    local src = source
    local player = QBX:GetPlayer(src)
    if not player then return end
    ActiveJobs[player.PlayerData.citizenid] = nil
end)

-- Check xem player có thể nhận item không
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

    if data == "wheel1" or data == "wheel2" or data == "wheel3" or data == "wheel4" then
        if not CanCarryItem(src, "car_wheel", 1) then return NotifyFull(src) end
        Player.Functions.AddItem("car_wheel", 1)
    elseif data == "door" then
        if not CanCarryItem(src, "car_door", 1) then return NotifyFull(src) end
        Player.Functions.AddItem("car_door", 1)
    elseif data == "hood" then
        if not CanCarryItem(src, "radiator", 1) then return NotifyFull(src) end
        Player.Functions.AddItem("radiator", 1)
    elseif data == "trunk" then
        if math.random(1, 100) <= 50 then
            local randomitem = math.random(1, #Config.TrunkItems)
            local item = Config.TrunkItems[randomitem]["item"]
            local amount = Config.TrunkItems[randomitem]["amount"]
            if CanCarryItem(src, item, amount) then
                Player.Functions.AddItem(item, amount)
            else
                NotifyFull(src)
            end
        end
        Wait(8500)
        if CanCarryItem(src, "trunk", 1) then
            Player.Functions.AddItem("trunk", 1)
        else
            NotifyFull(src)
        end
    end
end

RegisterNetEvent('orbit-chopshop:server:callCops', function(type, bank, streetLabel, coords, vehicleModel, plate)
    if GetResourceState('lb-tablet') ~= 'started' then return end

    exports['lb-tablet']:AddDispatch({
        priority = 'high',
        code = '10-35',
        title = 'Trộm Xe Đi Rã',
        description = 'Phát hiện hành vi trộm xe tại ' .. (streetLabel or 'không xác định'),
        location = {
            label = streetLabel or 'Không xác định',
            coords = coords and vec2(coords.x, coords.y) or nil,
        },
        time = 120,
        job = 'police',
        fields = {
            { icon = 'fas fa-car', label = 'Biển số', value = plate or 'Không rõ' },
            { icon = 'fas fa-map-marker-alt', label = 'Vị trí', value = streetLabel or 'Không rõ' },
        },
        blip = {
            sprite = 227,
            color = 1,
            size = 1.5,
            label = 'Trộm Xe - ' .. (plate or ''),
        },
    })
end)

RegisterNetEvent("orbit-chopshop:server:rewardplayer", GiveReward)

RegisterNetEvent("orbit-chopshop:syncchopcars", function(list)
    TriggerClientEvent('orbit-chopshop:carlist', -1, list)
end)

RegisterNetEvent("orbit-chopshop:server:chopdoor", function()
    local src = source
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

    Player.Functions.RemoveItem("car_door", 1)
    TriggerClientEvent('orbit-chopshop:doorchopanim', src)
    Wait(12500)
    Player.Functions.AddItem(item, amount)
end)

RegisterNetEvent("orbit-chopshop:server:chopwheel", function()
    local src = source
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

    Player.Functions.RemoveItem("car_wheel", 1)
    TriggerClientEvent('orbit-chopshop:wheelchopanim', src)
    Wait(14000)
    Player.Functions.AddItem(item, amount)
end)

RegisterNetEvent("orbit-chopshop:server:chophood", function()
    local src = source
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

    Player.Functions.RemoveItem("radiator", 1)
    TriggerClientEvent('orbit-chopshop:hoodchopanim', src)
    Wait(12500)
    Player.Functions.AddItem(item, amount)
end)

RegisterNetEvent("orbit-chopshop:server:choptrunk", function()
    local src = source
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

    Player.Functions.RemoveItem("trunk", 1)
    TriggerClientEvent('orbit-chopshop:trunkchopanim', src)
    Wait(12500)
    Player.Functions.AddItem(item, amount)
end)