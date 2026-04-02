Addon = {}
Addon.StarterItems = function(src, charData)
    if not Config.EnableStarterItems then
        return
    end

    local items = Config.StarterItems
    local Player = FrameworkSelected == 'ESX' and ESX.GetPlayerFromId(src)
        or FrameworkSelected == 'QBCore' and QBCore.Functions.GetPlayer(src)

    if FrameworkSelected == 'ESX' then
        for _, v in ipairs(items) do
            Player.addInventoryItem(v.item, v.amount)
        end

        -- Gender lootbox: ESX dùng charData.sex ('m' / 'f')
        local gender = charData and charData.sex == 'f' and 'female' or 'male'
        local lootboxItems = Config.StarterLootbox[gender] or {}
        for _, v in ipairs(lootboxItems) do
            Player.addInventoryItem(v.item, v.amount)
        end

    elseif FrameworkSelected == 'QBCore' then
        for _, v in ipairs(items) do
            local info = {}

            if v.item == "id_card" then
                info.citizenid = Player.PlayerData.citizenid
                info.firstname = Player.PlayerData.charinfo.firstname
                info.lastname = Player.PlayerData.charinfo.lastname
                info.birthdate = Player.PlayerData.charinfo.birthdate
                info.gender = Player.PlayerData.charinfo.gender
                info.nationality = Player.PlayerData.charinfo.nationality
            elseif v.item == "driver_license" then
                info.firstname = Player.PlayerData.charinfo.firstname
                info.lastname = Player.PlayerData.charinfo.lastname
                info.birthdate = Player.PlayerData.charinfo.birthdate
                info.type = "Class C Driver License"
            end

            Player.Functions.AddItem(v.item, v.amount, false, info)
        end

        -- Gender lootbox: QBCore dùng charinfo.gender (0=male, 1=female)
        local playerGender = Player.PlayerData.charinfo.gender
        local gender = (playerGender == 1) and 'female' or 'male'
        local lootboxItems = Config.StarterLootbox[gender] or {}

        for _, v in ipairs(lootboxItems) do
            local info = {}
            if v.metadata then
                info = v.metadata
            end
            Player.Functions.AddItem(v.item, v.amount, false, info)
        end

        if GetResourceState('qb-apartments') == 'started' then
            local ApartmentsData = Apartments.Locations
            local randomApartment = ApartmentsData[getRandomKey(ApartmentsData)]
            local num = CreateApartmentId(randomApartment.name)
            local apartmentId = tostring(randomApartment.name .. num)
            label = tostring(randomApartment.label .. " " .. num)

            MySQL.insert('INSERT INTO apartments (name, type, label, citizenid) VALUES (?, ?, ?, ?)', {
                apartmentId,
                randomApartment.name,
                label,
                Player.PlayerData.citizenid
            })

            TriggerClientEvent("apartments:client:SetHomeBlip", src, randomApartment.name)
        end
    end
end

--reworked qbcore functions
if FrameworkSelected == 'QBCore' then
    function CreateApartmentId(type)
        local UniqueFound = false
        local AparmentId = nil
    
        while not UniqueFound do
            AparmentId = tostring(math.random(1, 9999))
            local result = MySQL.query.await('SELECT COUNT(*) as count FROM apartments WHERE name = ?', { tostring(type .. AparmentId) })
            if result[1].count == 0 then
                UniqueFound = true
            end
            Wait(1000)
        end
        return AparmentId
    end
end

if Config.Commands['setcharacterslots'].use then
    HandleUserSlots = function(targetSource, slots)
        local identifier = GetPlayerIdentifierByType(targetSource, Config.Characters.IdentifierType)
        if identifier == nil then return debugPrint('Player with ID: '..targetSource..' does not exists') end
        MySQL.query.await('UPDATE `derp-multicharacter_slots` SET amount = ? WHERE identifier = ?', {slots, identifier})
        debugPrint('Succesfuly updated slots amount for user ['..targetSource..'] ('..GetPlayerName(targetSource)..') to amount: '..slots)
    end

    if FrameworkSelected == 'QBCore' then
        QBCore.Commands.Add(Config.Commands['setcharacterslots'].commandName, 'Sets character slots for specified user.', { { name = 'id', help = '' }, { name = 'slots', help = ''} }, true, function(source, args)
            local userId = tonumber(args[1])
            local slots = tonumber(args[2])
            HandleUserSlots(userId, slots > 0 and slots or 1)
        end, Config.CommandGroupAllowed)
    elseif FrameworkSelected == 'ESX' then
        ESX.RegisterCommand(Config.Commands['setcharacterslots'].commandName, Config.CommandGroupAllowed, function(xPlayer, args)
            local userId = tonumber(args.targetPlayer)
            local slots = tonumber(args.amount)
            HandleUserSlots(userId, slots > 0 and slots or 1)
        end, true, {
            help = 'Sets character slots',
            validate = true,
            arguments = {
                { name = "targetPlayer", help = 'Target Player ID', type = "number" },
                { name = "amount", help = 'Slots Amount', type = "number" },
            },
        })
    end
end

if Config.Commands['addcharacterslots'].use then
    AddUserSlots = function(targetSource)
        local identifier = GetPlayerIdentifierByType(targetSource, Config.Characters.IdentifierType)
        if identifier == nil then return debugPrint('Player with ID: '..targetSource..' does not exists') end
        local slots = Characters.GetSlots(targetSource)
        MySQL.query.await('UPDATE `derp-multicharacter_slots` SET amount = ? WHERE identifier = ?', {slots + 1, identifier})
        debugPrint('Succesfuly updated slots amount for user ['..targetSource..'] ('..GetPlayerName(targetSource)..') to amount: '..(slots + 1))
    end

    if FrameworkSelected == 'QBCore' then
        QBCore.Commands.Add(Config.Commands['addcharacterslots'].commandName, 'Adds character slot for specified user.', { { name = 'id', help = '' } }, true, function(source, args)
            local userId = tonumber(args[1])
            AddUserSlots(userId)
        end, Config.CommandGroupAllowed)
    elseif FrameworkSelected == 'ESX' then
        ESX.RegisterCommand(Config.Commands['addcharacterslots'].commandName, Config.CommandGroupAllowed, function(xPlayer, args)
            local userId = tonumber(args.targetPlayer)
            AddUserSlots(userId)
        end, true, {
            help = 'Adds character slot',
            validate = true,
            arguments = {
                { name = "targetPlayer", help = 'Target Player ID', type = "number" }
            },
        })
    end
end

if FrameworkSelected == 'QBCore' then
    QBCore.Commands.Add('logout_player', 'Logs out specific user.', { { name = 'id', help = '' } }, true, function(source, args)
        local userId = tonumber(args[1])
        Logout(userId)
    end, Config.CommandGroupAllowed)
elseif FrameworkSelected == 'ESX' then
    ESX.RegisterCommand('logout_player', Config.CommandGroupAllowed, function(xPlayer, args)
        local userId = tonumber(args.targetPlayer)
        Logout(userId)
    end, true, {
        help = 'Logs out specific user.',
        validate = true,
        arguments = {
            { name = "targetPlayer", help = 'Target Player ID', type = "number" }
        },
    })
end