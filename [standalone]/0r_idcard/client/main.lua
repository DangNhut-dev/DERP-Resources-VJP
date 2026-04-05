CardOpen = false
gCreatedBadgeProp = nil
PData = {}
Peds = {}
DoScreenFadeIn(0)

CreateThread(function()
    local sleep = 1000
    
    while true do
        Wait(sleep)

        local shot = GetBase64(PlayerPedId())
        TriggerServerEvent("0r_idcard:server:loadCard", shot.base64)

        if next(PData) == nil then
            sleep = 1000
        else
            sleep = 10000
        end
    end
end)

CreateThread(function()
    local ped = createPedOnCoord(Config.HeadshotPed.model, Config.HeadshotPed.coords.x, Config.HeadshotPed.coords.y, Config.HeadshotPed.coords.z, Config.HeadshotPed.coords.w)
    local fakeCardPed = createPedOnCoord(Config.FakeCardPed.model, Config.FakeCardPed.coords.x, Config.FakeCardPed.coords.y, Config.FakeCardPed.coords.z, Config.FakeCardPed.coords.w)
    table.insert(Peds, ped)
    table.insert(Peds, fakeCardPed)
    local sleep = 1000

    while true do
        Wait(sleep)

        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local dist = #(coords - vector3(Config.HeadshotPed.coords.x, Config.HeadshotPed.coords.y, Config.HeadshotPed.coords.z))
        local dist2 = #(coords - vector3(Config.FakeCardPed.coords.x, Config.FakeCardPed.coords.y, Config.FakeCardPed.coords.z))

        if dist < 2 then
            sleep = 0
            DrawText3D("~g~[E]~s~ Để Chụp Ảnh Giấy Tờ", Config.HeadshotPed.coords.x, Config.HeadshotPed.coords.y, Config.HeadshotPed.coords.z + 1, 0.03, 0.03)
        
            if IsControlJustPressed(0, 38) then
                startMugshotAnimation()
                Wait(250)
                local result = GetBase64(PlayerPedId())
                local shot = "assets/default.png"
            
                if result.success then
                    shot = result.base64
                end

                Config.Notify(_t("headshot_taken"), "success")

                TriggerServerEvent("0r_idcard:server:saveHeadshot", shot)
                TriggerServerEvent("0r_idcard:server:checkGiveIdCard")
            end
        elseif dist2 < 2 then
            sleep = 0
            DrawText3D("~g~[E]~s~ Để Làm Giấy Tờ Giả", Config.FakeCardPed.coords.x, Config.FakeCardPed.coords.y, Config.FakeCardPed.coords.z + 1, 0.03, 0.03)
        
            if IsControlJustPressed(0, 38) then
                lib.showContext('fake_id_card')
            end
        else
            sleep = 1000
        end
    end
end)

lib.registerContext({
    id = 'fake_id_card',
    title = 'Create Fake ID Card',
    options = {
        {
            title = 'Create ID Card',
            description = 'Create a fake ID Card',
            onSelect = function()
                local input = lib.inputDialog('Create ID Card', {
                    {type = 'input', label = 'Name', description = 'Enter the name that will shown on the card', required = true, min = 2},
                    {type = 'input', label = 'Surname', description = 'Enter the surname that will shown on the card', required = true, min = 2},
                    {type = 'date',  label = 'Birthdate', icon = {'far', 'calendar'}, default = true, required = true, format = "DD/MM/YYYY"},
                    {type = 'checkbox', label = 'Male'},
                    {type = 'checkbox', label = 'Female'},
                })

                if input then
                    local name = input[1]
                    local surname = input[2]
                    local birthdate = input[3]
                    local male = input[4]
                    local female = input[5]

                    if male and female then
                        Config.Notify("You can only select one gender", "error")
                    elseif not male and not female then
                        Config.Notify("You must select a gender", "error")
                    else
                        local shot = GetBase64(PlayerPedId())
                        TriggerServerEvent("0r_idcard:server:createFakeCard", name, surname, "citizen", birthdate, male, female, shot.base64, "citizen")
                    end
                end
            end,
        },
        {
            title = 'Create Job ID Card',
            description = 'Create a fake job ID Card',
            onSelect = function()
                local jobs = ""

                for k, v in pairs(Config.CardTypes) do
                    if k ~= "citizen" then
                        jobs = jobs .. k .. ", "
                    end	
                end

                local input = lib.inputDialog('Create Job ID Card', {
                    {type = 'input', label = 'Name', description = 'Enter the name that will shown on the card', required = true, min = 2},
                    {type = 'input', label = 'Surname', description = 'Enter the surname that will shown on the card', required = true, min = 2},
                    {type = 'input', label = 'Job', description = 'Jobs are ' .. jobs, required = true, min = 2},
                    {type = 'date',  label = 'Birthdate', icon = {'far', 'calendar'}, default = true, required = true, format = "DD/MM/YYYY"},
                    {type = 'checkbox', label = 'Male'},
                    {type = 'checkbox', label = 'Female'},
                })

                if input then
                    local name = input[1]
                    local surname = input[2]
                    local job = input[3]
                    local birthdate = input[4]
                    local male = input[5]
                    local female = input[6]

                    if not table_includes(Config.CardTypes, job) then
                        Config.Notify("This job is not available", "error")
                    elseif male and female then
                        Config.Notify("You can only select one gender", "error")
                    elseif not male and not female then
                        Config.Notify("You must select a gender", "error")
                    else
                        local shot = GetBase64(PlayerPedId())
                        TriggerServerEvent("0r_idcard:server:createFakeCard", name, surname, job, birthdate, male, female, shot.base64, "job")
                    end
                end
            end,
        }
    }
})