RegisterNetEvent("0r_idcard:server:showCard", function(target, data, isJobCard, shown)
    TriggerClientEvent("0r_idcard:client:showCard", target, data, isJobCard, shown)
end)

RegisterNetEvent("0r_idcard:server:saveHeadshot", function(shot)
    local src = source
    local player = getExtendedPlayer(src)
    local license = getPlayerLicense(player)

    if license then
        local result = mysqlQuery("SELECT photo FROM 0r_idcard WHERE license = @license", {["@license"] = license})

        if result[1] then
            mysqlQuery("UPDATE 0r_idcard SET photo = @photo WHERE license = @license", {["@photo"] = shot, ["@license"] = license})
        else
            mysqlQuery("INSERT INTO 0r_idcard (license, photo) VALUES (@license, @photo)", {["@license"] = license, ["@photo"] = shot})
        end
    end
end)

RegisterNetEvent("0r_idcard:server:loadCard", function(shot)
    local src = source
    local player = getExtendedPlayer(src)

    if player == nil then
        return
    end

    local license = getPlayerLicense(player)

    if license then
        local result = mysqlQuery("SELECT photo FROM 0r_idcard WHERE license = @license", {["@license"] = license})

        if not result[1] then
            mysqlQuery("INSERT INTO 0r_idcard (license, photo) VALUES (@license, @photo)", {["@license"] = license, ["@photo"] = shot})
        end
    end

    TriggerClientEvent("0r_idcard:client:setCardData", src, useIdCard(src))
end)

RegisterNetEvent("0r_idcard:server:createFakeCard", function(name, surname, job, date, male, female, shot, cardtype)
    local src = source
    local gender = male and "Male" or "Female"

    if removeMoney(src, Config.FakeCardPrice) then
        local player = getExtendedPlayer(src)
        local license = getPlayerLicense(player)
        local result = mysqlQuery("SELECT * FROM 0r_idcard_fakecards WHERE license = @license", {["@license"] = license})
        local updated = false

        local timestamp = math.floor(date / 1000)
        local birthdate = os.date('%Y-%m-%d', timestamp)

        for k, v in pairs(result) do
            if v.card_type == "citizen" and job == 'citizen' then
                updated = true

                mysqlQuery("UPDATE 0r_idcard_fakecards SET card_name = @card_name, card_surname = @card_surname, card_birthdate = @card_birthdate, card_sex = @card_sex, card_photo = @card_photo WHERE license = @license AND card_type = 'citizen'",
                {["@card_name"] = name, ["@card_surname"] = surname, ["@card_birthdate"] = birthdate, ["@card_sex"] = gender, ["@card_photo"] = shot, ["@license"] = license})
                TriggerClientEvent("0r_idcard:client:notify", src, "Your ID card has been updated", "success")
            elseif v.card_type ~= "citizen" and job ~= 'citizen' then
                updated = true

                mysqlQuery("UPDATE 0r_idcard_fakecards SET card_name = @card_name, card_surname = @card_surname, card_birthdate = @card_birthdate, card_sex = @card_sex, card_photo = @card_photo, card_type = @card_type WHERE license = @license AND card_type NOT LIKE 'citizen'",
                {["@card_name"] = name, ["@card_surname"] = surname, ["@card_birthdate"] = birthdate, ["@card_sex"] = gender, ["@card_photo"] = shot, ["@license"] = license, ["@card_type"] = job})
                TriggerClientEvent("0r_idcard:client:notify", src, "Your job card has been updated", "success")
            end
        end

        if not updated then
            mysqlQuery("INSERT INTO 0r_idcard_fakecards (license, card_type, card_name, card_surname, card_birthdate, card_sex, card_photo) VALUES (@license, @card_type, @card_name, @card_surname, @card_birthdate, @card_sex, @card_photo)",
            {["@license"] = license, ["@card_type"] = job, ["@card_name"] = name, ["@card_surname"] = surname, ["@card_birthdate"] = birthdate, ["@card_sex"] = gender , ["@card_photo"] = shot})
            TriggerClientEvent("0r_idcard:client:notify", src, "Your ID card has been created", "success")
        end

        addItem(src, cardtype == 'citizen' and Config.FakeIdCard or Config.FakeJobCard, 1)
    else
        TriggerClientEvent("0r_idcard:client:notify", src, "You don't have enough money", "error")
    end
end)