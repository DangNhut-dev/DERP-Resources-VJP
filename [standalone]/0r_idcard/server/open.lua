RegisterNetEvent('esx_dmvschool:addLicense')
AddEventHandler('esx_dmvschool:addLicense', function(type)
    local source = source
    exports['0r-idcard']:setPlayerLicense('driver_license', source, 1)
end)

registerItem(Config.DriverLicense, function(source)
    local found = false

    if Config.UseDatabaseForDriverLicense then
        local license = getPlayerLicense(getExtendedPlayer(source))
        local result = mysqlQuery("SELECT * FROM 0r_idcard WHERE license = @license", {["@license"] = license})
        local driverLicense = result[1].driver_license

        if driverLicense == 0 then
            TriggerClientEvent("0r_idcard:client:notify", source, "You don't have a driver license.", "error")
            return
        end
    elseif Config.UseQbLicense then
        local player = getExtendedPlayer(source)
        local driverLicense = player.PlayerData.metadata["licences"]["driver"]

        if driverLicense == nil or driverLicense == 0 then
            TriggerClientEvent("0r_idcard:client:notify", source, "You don't have a driver license.", "error")
            return
        end
    elseif Config.UseEsxLicense then
        TriggerEvent('esx_license:getLicenses', source, function(licenses)
            for k, v in pairs(licenses) do
                if v.type == "driver" or v.type == "driver_license" then
                    found = true
                end
            end
        end)

        if not found then
            TriggerClientEvent("0r_idcard:client:notify", source, "You don't have a driver license.", "error")
            return
        end
    end

    local data = useIdCard(source)
    data.cardType = "driver"
    data.jobGrade = 0

    TriggerClientEvent("0r_idcard:client:showCard", source, data, false, false)
end)

registerItem(Config.WeaponLicense, function(source)
    local found = false

    if Config.UseDatabaseForWeaponLicense then
        local license = getPlayerLicense(getExtendedPlayer(source))
        local result = mysqlQuery("SELECT * FROM 0r_idcard WHERE license = @license", {["@license"] = license})
        local weaponLicense = result[1].weapon_license

        if weaponLicense == 0 then
            TriggerClientEvent("0r_idcard:client:notify", source, "You don't have a weapon license.", "error")
            return
        end
    elseif Config.UseQbLicense then
        local player = getExtendedPlayer(source)
        local weaponLicense = player.PlayerData.metadata["licences"]["weapon"]

        if weaponLicense == nil or weaponLicense == 0 then
            TriggerClientEvent("0r_idcard:client:notify", source, "You don't have a weapon license.", "error")
            return
        end
    elseif Config.UseEsxLicense then
        TriggerEvent('esx_license:getLicenses', source, function(licenses)
            for k, v in pairs(licenses) do
                if v.type == "weapon" or v.type == "weapon_license" then
                    found = true
                end
            end
        end)

        if not found then
            TriggerClientEvent("0r_idcard:client:notify", source, "You don't have a weapon license.", "error")
            return
        end
    end

    local data = useIdCard(source)
    data.cardType = "weapon"
    data.jobGrade = 0

    TriggerClientEvent("0r_idcard:client:showCard", source, data, false, false)
end)

function getPlayerName(player)
    if Config.Framework == "qb" then
        return { firstname = player.PlayerData.charinfo.firstname, lastname = player.PlayerData.charinfo.lastname }
    elseif Config.Framework == "esx" then
        local name = player.getName()
        local names = splitString(name, " ")
        if #names > 1 then
            local lastname = ""
            for i = 2, #names do
                if names[i] ~= nil then
                    lastname = lastname .. names[i] .. " "
                end
            end

            return { firstname = names[1], lastname = lastname }
        else
            return { firstname = name, lastname = "" }
        end
    end
end

function splitString(text)
    local t = {}
    for str in string.gmatch(text, "([^%s]+)") do
        table.insert(t, str)
    end
    return t
end

function getBirthDate(player)
    if Config.Framework == "qb" then
        return player.PlayerData.charinfo.birthdate
    elseif Config.Framework == "esx" then
        return player.variables.dateofbirth
    end
end

function getPlayerLicense(player)
    if Config.Framework == "qb" then
        return player.PlayerData.citizenid
    elseif Config.Framework == "esx" then
        return player.getIdentifier()
    end
end

function getGender(player)
    if Config.Framework == "qb" then
        return player.PlayerData.charinfo.gender == 0 and "Male" or "Female"
    elseif Config.Framework == "esx" then
        return player.variables.sex == "m" and "Male" or "Female"
    end
end

function getPlayerJob(src)
    local player = getExtendedPlayer(src)

    while player == nil do
        Citizen.Wait(100)
        player = getExtendedPlayer(src)
    end

    if Config.Framework == "qb" then
        return { name = player.PlayerData.job.name, grade = player.PlayerData.job.grade.level }
    elseif Config.Framework == "esx" then
        return { name = player.job.name, grade = player.job.grade }
    end
end

function getPlayerNation(src)
    local player = getExtendedPlayer(src)

    while player == nil do
        Citizen.Wait(100)
        player = getExtendedPlayer(src)
    end

    if Config.Framework == "qb" then
        return doesNationIncludesFlag(player.PlayerData.charinfo.nationality)
    elseif Config.Framework == "esx" then
        return doesNationIncludesFlag(player.variables.nationality)
    end
end

function doesNationIncludesFlag(nation)
    if not nation then
        return "us"
    end

    for k, v in pairs(Nations) do
        if string.lower(k) == string.lower(nation) then
            return v
        end
    end

    return 'us'
end