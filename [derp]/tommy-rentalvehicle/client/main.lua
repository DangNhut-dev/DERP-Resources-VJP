local RentedCars = {}

CreateThread(function()
    Wait(1000)
    for k, v in pairs(Config.Rentals) do
        local hash = joaat(v.pedhash)
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Wait(1)
        end
        local ped = CreatePed(5, hash, v.spawnpoint.x, v.spawnpoint.y, v.spawnpoint.z - 1, v.spawnpoint.w, false, true)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_CLIPBOARD', 0, true)
        SetModelAsNoLongerNeeded(hash)

        local blip = AddBlipForCoord(v.spawnpoint.x, v.spawnpoint.y, v.spawnpoint.z)
        SetBlipSprite(blip, v.blip.sprite or 225)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, v.blip.scale or 0.8)
        SetBlipColour(blip, v.blip.color or 3)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(v.title)
        EndTextCommandSetBlipName(blip)

        exports.ox_target:addLocalEntity(ped, {
            {
                name     = ('rental_%s'):format(k),
                icon     = v.icon,
                label    = v.title,
                distance = 3.0,
                onSelect = function()
                    TriggerEvent('qb-rental:client:startrent', {
                        rentid      = k,
                        label       = v.title,
                        vehicledata = Config.VehicleList[v.vehiclelist],
                    })
                end,
            },
        })
    end
end)

AddEventHandler('qb-rental:client:startrent', function(data)
    local resourceName = GetCurrentResourceName()
    local menuOptions = {
        {
            title       = Lang:t('menu.return_header'),
            description = Lang:t('menu.return_text'),
            icon        = 'car',
            onSelect    = function()
                local ped       = PlayerPedId()
                local currentVeh = GetVehiclePedIsIn(ped, false)
                if currentVeh == 0 then
                    lib.notify({ title = 'Thuê xe', description = 'Bạn chưa ngồi trong xe', type = 'error' })
                    return
                end
                local currentNetId = NetworkGetNetworkIdFromEntity(currentVeh)
                local isRented = false
                for _, netId in pairs(RentedCars) do
                    if netId == currentNetId then
                        isRented = true
                        break
                    end
                end
                if not isRented then
                    lib.notify({ title = 'Thuê xe', description = 'Đây không phải xe thuê của bạn', type = 'error' })
                    return
                end
                TriggerServerEvent('qb-rental:server:startreturnvehicle', currentNetId)
            end,
        },
    }

    for _, v in pairs(data.vehicledata) do
        local vehdata = v
        menuOptions[#menuOptions + 1] = {
            title       = vehdata.name,
            description = ('Giá: %s $'):format(vehdata.price),
            image       = ('nui://%s/images/%s.png'):format(resourceName, vehdata.model),
            onSelect    = function()
                TriggerServerEvent('qb-rental:server:rentcar', {
                    rentid  = data.rentid,
                    vehdata = vehdata,
                })
            end,
        }
    end

    lib.registerContext({
        id      = 'rental_menu',
        title   = data.label,
        options = menuOptions,
    })
    lib.showContext('rental_menu')
end)

RegisterNetEvent('qb-rental:client:setupvehicle', function(netId)
    local veh = NetworkGetEntityFromNetworkId(netId)
    RentedCars[#RentedCars + 1] = netId
    exports['cdn-fuel']:SetFuel(veh, 100.0)
end)