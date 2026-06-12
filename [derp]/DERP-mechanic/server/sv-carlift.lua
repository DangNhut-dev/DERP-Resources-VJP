local PLATFORM_MODEL = -1375594465 -- prop_car_lift_01
local STAND_MODEL = -277236775 -- prop_car_lift_01_stand
local createdLifts = {}
local liftsInitialized = false

function createCarLift(x, y, z, heading)
    local platformProp = CreateObjectNoOffset(PLATFORM_MODEL, x, y, z - 1.025, true, true, true)
    if not platformProp then return false, false end

    while not DoesEntityExist(platformProp) do
        Wait(1)
    end
    SetEntityHeading(platformProp, heading)
    FreezeEntityPosition(platformProp, true)

    local standProp = CreateObjectNoOffset(STAND_MODEL, x, y, z - 1.0, true, true, true)
    if not standProp then return false, false end

    while not DoesEntityExist(standProp) do
        Wait(1)
    end
    SetEntityHeading(standProp, heading)
    FreezeEntityPosition(standProp, true)

    local platformNetId = NetworkGetNetworkIdFromEntity(platformProp)
    local standNetId = NetworkGetNetworkIdFromEntity(standProp)

    return platformNetId, standNetId
end

function initializeCarLifts()
    liftsInitialized = true

    if GlobalState.carLiftsData then
        for _, locationLifts in pairs(GlobalState.carLiftsData) do
            for _, liftData in ipairs(locationLifts) do
                DeleteEntity(NetworkGetEntityFromNetworkId(liftData.platform))
                DeleteEntity(NetworkGetEntityFromNetworkId(liftData.stand))
            end
        end
    end

    local allLiftsData = {}
    for locationName, locationData in pairs(Config.MechanicLocations) do
        if locationData.carLifts then
            local existingLifts = allLiftsData[locationName]
            if not existingLifts or #existingLifts == 0 then
                for _, coords in ipairs(locationData.carLifts) do
                    local platformNetId, standNetId = createCarLift(coords.x, coords.y, coords.z, coords.w)
                    if not platformNetId or not standNetId then
                        return false
                    end

                    if not allLiftsData[locationName] then
                        allLiftsData[locationName] = {}
                    end

                    local locationLiftsTable = allLiftsData[locationName]
                    local newIndex = #locationLiftsTable + 1
                    locationLiftsTable[newIndex] = {
                        platform = platformNetId,
                        stand = standNetId,
                        coords = coords
                    }
                end
            end
        end
    end

    createdLifts = allLiftsData
    GlobalState:set("carLiftsData", allLiftsData)
end

lib.callback.register("DERP-mechanic:server:get-created-lifts", function()
    if not liftsInitialized then
        initializeCarLifts()
    end

    lib.waitFor(function()
        return createdLifts
    end, "Lifts say they have been created, but they are still false", 30000)

    return createdLifts
end)