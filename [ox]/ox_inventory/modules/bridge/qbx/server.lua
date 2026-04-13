assert(lib.checkDependency('qbx_core', '1.18.1'), 'qbx_core v1.18.1 or higher is required')
assert(lib.checkDependency('qbx_vehicles', '1.2.0'), 'qbx_vehicles v1.2.0 or higher is required')
local Inventory = require 'modules.inventory.server'
local db = require 'modules.mysql.server'
local QBX = exports.qbx_core

AddEventHandler('qbx_core:server:playerLoggedOut', server.playerDropped)

AddEventHandler('qbx_core:server:onGroupUpdate', function(source, groupName, groupGrade)
    local inventory = Inventory(source)
    if not inventory then return end
    inventory.player.groups[groupName] = not groupGrade and nil or groupGrade
end)

local function getPlayerAccountName(account)
    return account == 'money' and 'cash' or account
end

local function findFreePlayerSlot(usedSlots, maxSlots)
    for i = 1, maxSlots do
        if not usedSlots[i] then
            return i
        end
    end
end

local function buildPlayerInventoryData(playerData)
    local data = db.loadPlayer(playerData.identifier)

    if type(data) ~= 'table' then
        data = {}
    end

    local accounts = server.accounts
    if type(accounts) ~= 'table' or not next(accounts) then
        return data
    end

    local filtered = {}
    local usedSlots = {}
    local preferredSlots = {}

    for _, item in pairs(data) do
        if type(item) == 'table' and item.name and accounts[item.name] then
            local slot = tonumber(item.slot)
            if slot and not preferredSlots[item.name] then
                preferredSlots[item.name] = slot
            end
        else
            filtered[#filtered + 1] = item

            if type(item) == 'table' then
                local slot = tonumber(item.slot)
                if slot then
                    usedSlots[slot] = true
                end
            end
        end
    end

    local maxSlots = tonumber(shared and shared.playerslots) or 50

    for account in pairs(accounts) do
        local playerAccount = getPlayerAccountName(account)
        local amount = tonumber(playerData.money and playerData.money[playerAccount]) or 0

        if amount > 0 then
            local slot = preferredSlots[account]

            if not slot or usedSlots[slot] then
                slot = findFreePlayerSlot(usedSlots, maxSlots)
            end

            if slot then
                usedSlots[slot] = true
                filtered[#filtered + 1] = {
                    slot = slot,
                    name = account,
                    count = amount,
                    metadata = {}
                }
            end
        end
    end

    table.sort(filtered, function(a, b)
        local aSlot = type(a) == 'table' and tonumber(a.slot) or math.huge
        local bSlot = type(b) == 'table' and tonumber(b.slot) or math.huge
        return aSlot < bSlot
    end)

    return filtered
end

local function setupPlayer(playerData)
    playerData.identifier = playerData.citizenid
    playerData.name = ('%s %s'):format(playerData.charinfo.firstname, playerData.charinfo.lastname)
    server.setPlayerInventory(playerData, buildPlayerInventoryData(playerData))
end

AddStateBagChangeHandler('loadInventory', nil, function(bagName, _, value)
    if not value then return end
    local plySrc = GetPlayerFromStateBagName(bagName)
    if not plySrc then return end
    setupPlayer(QBX:GetPlayer(plySrc).PlayerData)
end)

SetTimeout(500, function()
    local playersData = QBX:GetPlayersData()
    for i = 1, #playersData do setupPlayer(playersData[i]) end
end)

function server.UseItem(source, itemName, data)
    local cb = QBX:CanUseItem(itemName)
    return cb and cb(source, data)
end

---@diagnostic disable-next-line: duplicate-set-field
function server.setPlayerData(player)
    local groups = QBX:GetGroups(player.source)
    return {
        source = player.source,
        name = ('%s %s'):format(player.charinfo.firstname, player.charinfo.lastname),
        groups = groups,
        sex = player.charinfo.gender,
        dateofbirth = player.charinfo.birthdate,
    }
end

---@diagnostic disable-next-line: duplicate-set-field
function server.syncInventory(inv)
    local accounts = Inventory.GetAccountItemCounts(inv)
    if not accounts then return end
    local player = QBX:GetPlayer(inv.id)
    player.Functions.SetPlayerData('items', inv.items)
    for account, amount in pairs(accounts) do
        account = getPlayerAccountName(account)
        if player.Functions.GetMoney(account) ~= amount then
            player.Functions.SetMoney(account, amount, ('Sync %s with inventory'):format(account))
        end
    end
end

---@diagnostic disable-next-line: duplicate-set-field
function server.hasLicense(inv, license)
    local player = QBX:GetPlayer(inv.id)
    return player and player.PlayerData.metadata.licences[license]
end

---@diagnostic disable-next-line: duplicate-set-field
function server.buyLicense(inv, license)
    local player = QBX:GetPlayer(inv.id)
    if not player then return end

    if player.PlayerData.metadata.licences[license.name] then
        return false, 'already_have'
    elseif Inventory.GetItem(inv, 'money', false, true) < license.price then
        return false, 'can_not_afford'
    end

    Inventory.RemoveItem(inv, 'money', license.price)
    player.PlayerData.metadata.licences[license.name] = true
    player.Functions.SetMetaData('licences', player.PlayerData.metadata.licences)

    return true, 'have_purchased'
end

---@diagnostic disable-next-line: duplicate-set-field
function server.isPlayerBoss(playerId, group, grade)
    return QBX:IsGradeBoss(group, grade)
end

---@param entityId number
---@return number | string
---@diagnostic disable-next-line: duplicate-set-field
function server.getOwnedVehicleId(entityId)
    return Entity(entityId).state.vehicleid or exports.qbx_vehicles:GetVehicleIdByPlate(GetVehicleNumberPlateText(entityId))
end
