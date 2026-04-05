Framework = Config.CoreExport()

function useIdCard(source)
    local player = getExtendedPlayer(source)
    local job = getPlayerJob(source)
    local jobName = job.name
    local jobGrade = job.grade
    local name = getPlayerName(player)
    local nationality = getPlayerNation(source)

    local playerData = {
        name = getPlayerName(player),
        jobName = jobName,
        jobGrade = jobGrade,
        birthDate = getBirthDate(player),
        license = getPlayerLicense(player),
        sex = getGender(player),
        headshot = getPlayerHeadshot(source),
        nationality = nationality
    }

    return playerData
end

function registerItem(...)
    if Config.Framework == "qb" then
        Framework.Functions.CreateUseableItem(...)
    else
        Framework.RegisterUsableItem(...)
    end
end

function mysqlQuery(query, params)
	if Config.MySQL == "oxmysql" then
		return exports["oxmysql"]:query_async(query, params)
	elseif Config.MySQL == "mysql-async" then
		local p = promise.new()

		exports['mysql-async']:mysql_execute(query, params, function(result)
			p:resolve(result)
		end)

		return Citizen.Await(p)
	elseif Config.MySQL == "ghmattimysql" then
		return exports['ghmattimysql']:executeSync(query, params)
	end
end

function registerServerCallback(...)
    if Config.Framework == "qb" then
        Framework.Functions.CreateCallback(...)
    else
        Framework.RegisterServerCallback(...)
    end
end

function getExtendedPlayer(src)
    if Config.Framework == "qb" then
        return Framework.Functions.GetPlayer(src)
    elseif Config.Framework == "esx" then
        return Framework.GetPlayerFromId(src)
    end
end

function hasMoney(src, money)
    local player = getExtendedPlayer(src)

    while player == nil do
        Citizen.Wait(100)
        player = getExtendedPlayer(src)
    end

    if Config.Framework == "qb" then
        return player.Functions.GetMoney("cash") >= money
    elseif Config.Framework == "esx" then
        return player.getMoney() >= money
    end
end

function removeMoney(src, amount)
    local player = getExtendedPlayer(src)

    while player == nil do
        Citizen.Wait(100)
        player = getExtendedPlayer(src)
    end

    if hasMoney(src, amount) then
        if Config.Framework == "qb" then
            player.Functions.RemoveMoney("cash", amount)
        elseif Config.Framework == "esx" then
            player.removeMoney(amount)
        end

        return true
    end

    return false
end

function addItem(src, item, amoumt)
    local player = getExtendedPlayer(src)

    while player == nil do
        Citizen.Wait(100)
        player = getExtendedPlayer(src)
    end

    if Config.Framework == "qb" then
        player.Functions.AddItem(item, amoumt)
    elseif Config.Framework == "esx" then
        player.addInventoryItem(item, amoumt)
    end
end

function getPlayerHeadshot(source)
    local player = getExtendedPlayer(source)
    local license = getPlayerLicense(player)
    local result = mysqlQuery("SELECT photo FROM 0r_idcard WHERE license = @license", {["@license"] = license})

    if result[1] then
        return result[1].photo
    end

    return "assets/default.png"
end

registerItem(Config.IdCard, function(source)
    local data = useIdCard(source)
    TriggerClientEvent("0r_idcard:client:showCard", source, data, false, false)
end)

registerItem(Config.JobCard, function(source)
    local data = useIdCard(source)
    TriggerClientEvent("0r_idcard:client:showCard", source, data, true, false)
end)

registerItem(Config.FakeIdCard, function(source)
    local data = mysqlQuery("SELECT * FROM 0r_idcard_fakecards WHERE license = @license", {["@license"] = getPlayerLicense(getExtendedPlayer(source))})
    
    for k, v in pairs(data) do
        if v.card_type == "citizen" then

            local newData = {
                name = {
                    firstname = v.card_name,
                    lastname = v.card_surname,
                },
                jobName = "Citizen",
                jobGrade = 0,
                birthDate = v.card_birthdate,
                license = v.license,
                sex = v.card_sex,
                headshot = v.card_photo,
            }
    
            TriggerClientEvent("0r_idcard:client:showCard", source, newData, false, false)
        end
    end
end)

registerItem(Config.FakeJobCard, function(source)
    local data = mysqlQuery("SELECT * FROM 0r_idcard_fakecards WHERE license = @license", {["@license"] = getPlayerLicense(getExtendedPlayer(source))})

    for k, v in pairs(data) do
        if v.card_type ~= "citizen" then
            local newData = {
                name = {
                    firstname = v.card_name,
                    lastname = v.card_surname,
                },
                jobName = v.card_type,
                jobGrade = 0,
                birthDate = v.card_birthdate,
                license = v.license,
                sex = v.card_sex,
                headshot = v.card_photo,
            }

            TriggerClientEvent("0r_idcard:client:showCard", source, newData, true, false)
        end
    end
end)

function doesPlayerHasLicense(type, source)
    local license = getPlayerLicense(getExtendedPlayer(source))
    local result = mysqlQuery("SELECT * FROM 0r_idcard WHERE license = @license", {["@license"] = license})

    if type == "driver" then
        return result[1].driver_license == 1
    elseif type == "weapon" then
        return result[1].weapon_license == 1
    end
end

exports("doesPlayerHasLicense", isPlayerHasLicense)

function setPlayerLicense(type, source, value)
    local license = getPlayerLicense(getExtendedPlayer(source))

    if type == "driver" then
        mysqlQuery("UPDATE 0r_idcard SET driver_license = @value WHERE license = @license", {["@value"] = value, ["@license"] = license})
    elseif type == "weapon" then
        mysqlQuery("UPDATE 0r_idcard SET weapon_license = @value WHERE license = @license", {["@value"] = value, ["@license"] = license})
    end
end

exports("setPlayerLicense", setPlayerLicense)

RegisterServerEvent('0r_idcard:server:checkGiveIdCard')
AddEventHandler('0r_idcard:server:checkGiveIdCard', function()
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end

    local hasCard = exports.ox_inventory:Search(src, 'count', 'id_card')
    if not hasCard or hasCard < 1 then
        exports.ox_inventory:AddItem(src, 'id_card', 1)
    end
end)