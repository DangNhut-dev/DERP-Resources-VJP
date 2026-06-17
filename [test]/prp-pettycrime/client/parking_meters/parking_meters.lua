local parkingMeterModels = {}
local parkingMeterWeapons = {}
local currentWeapon = GetSelectedPedWeapon(cache.ped)

lib.onCache("weapon", function(weapon)
    currentWeapon = weapon
end)

RegisterNetEvent("prp-pettycrime:client:startup", function(activityType, data)
    if activityType ~= "parking_meters" then return end

    parkingMeterModels = data.models
    parkingMeterWeapons = data.weapons

    if Config.Debug then
        for _, model in ipairs(parkingMeterModels) do
            TriggerEvent("prp-pettycrime:client:registerDebugModel", model, "Parking Meter")
        end
    end

    bridge.target.addModel(parkingMeterModels, {
        {
            name = "parkingmeter-steal",
            icon = "fas fa-hammer",
            label = locale("target.smash_parking_meter"),
            onSelect = function(data)
                local entity = data.entity
                local coords = GetEntityCoords(entity)
                local model = GetEntityModel(entity)
                local archetypeName = GetEntityArchetypeName(entity)
                local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
                local streetName = GetStreetNameFromHashKey(streetHash)
                local zoneName = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
                local locationLabel = (streetName ~= "" and ("%s, %s"):format(streetName, zoneName)) or zoneName

                TriggerServerEvent("prp-pettycrime:server:parkingMeterSteal", archetypeName, model, coords, locationLabel)
            end,
            canInteract = function(entity, distance)
                if not IsInsideParkingMeterZone() then
                    return false
                end

                if not currentWeapon or not parkingMeterWeapons[currentWeapon] then
                    return false
                end

                if distance > Config.ParkingMeters.targetDistance then
                    return false
                end

                if not DoesEntityExist(entity) or cache.vehicle then
                    return false
                end

                local isBroken = false
                local status, result = pcall(HasObjectBeenBroken, entity)
                if status then
                    isBroken = result
                else
                    isBroken = true
                end

                if isBroken then
                    return false
                end

                return true
            end
        }
    })
end)

AddEventHandler("onResourceStop", function(resourceName)
    if cache.resource ~= resourceName then return end

    bridge.target.removeModel(parkingMeterModels, { "parkingmeter-steal" })
end)
