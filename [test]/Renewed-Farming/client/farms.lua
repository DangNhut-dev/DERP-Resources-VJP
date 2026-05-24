local Farms = {}
local playerFarms = {}
local Plants = require 'shared.Config'.Plants
local wateringCan = require 'shared.Config'.wateringCan.item
local RentalConfig = require 'shared.Rental'

local function ensureVec3(v)
    if not v then return vec3(0, 0, 0) end
    if type(v) == 'vector3' then return v end
    if type(v) == 'table' then
        return vec3(v.x or v[1] or 0, v.y or v[2] or 0, v.z or v[3] or 0)
    end
    return vec3(0, 0, 0)
end

local function ensureVec4(v)
    if not v then return vec4(0, 0, 0, 0) end
    if type(v) == 'vector4' then return v end
    if type(v) == 'table' then
        return vec4(v.x or v[1] or 0, v.y or v[2] or 0, v.z or v[3] or 0, v.w or v.heading or v[4] or 0)
    end
    return vec4(0, 0, 0, 0)
end

function Farms.addFarm(id, coords, spots, owner)
    local newSpots = {}
    coords = ensureVec4(coords)

    if spots then
        for i = 1, #spots do
            if spots[i] and spots[i].coords then
                newSpots[i] = {
                    coords = ensureVec3(spots[i].coords),
                    inUse = false
                }
            end
        end
    end

    playerFarms[id] = {
        coords = coords,
        spots = newSpots,
        owner = owner
    }

    local isRentalPlot = false
    for _, plot in pairs(RentalConfig.plots) do
        if plot.id == id then
            isRentalPlot = true
            break
        end
    end

    -- Always add the planter object, Z offset matches the placeObject offset used during farm creation
    Renewed.addObject({
        object = `ep_planter_large`,
        coords = vec3(coords.x, coords.y, coords.z - 0.2),
        heading = coords.w,
        freeze = true,
        dist = 260,
    })
end

function Farms.updateOwner(id, owner)
    if playerFarms[id] then
        playerFarms[id].owner = owner
    end
end

function Farms.canInteract(id)
    local farm = playerFarms[id]
    if not farm then return false end
    
    local isRentalPlot = false
    for _, plot in pairs(RentalConfig.plots) do
        if plot.id == id then
            isRentalPlot = true
            break
        end
    end

    if isRentalPlot then
        if not farm.owner then return false end
        local PlayerData = exports.qbx_core:GetPlayerData()
        return PlayerData and PlayerData.citizenid == farm.owner
    end

    return true
end

function Farms.getFarm(coords)
    if not coords then return end

    for k, v in pairs(playerFarms) do
        if #(coords - vec3(v.coords.x, v.coords.y, v.coords.z)) < 2.0 then
            return k
        end
    end

    return false
end

function Farms.getClosestSpot(id, coords)
    local Farm = id and playerFarms[id]

    if not Farm then return end

    local spots = {}
    local spotAmt = 0

    for i = 1, #Farm.spots do
        local spot = Farm.spots[i]

        if not spot.inUse then
            spotAmt += 1
            spots[spotAmt] = {
                dist = #(coords - spot.coords),
                coords = spot.coords,
                index = i,
            }
        end
    end

    table.sort(spots, function(a, b) return a.dist < b.dist end)

    return spots, spotAmt
end

function Farms.getPlantsInDist(farm, coords)
    local currentFarm = farm and playerFarms[farm]

    if not currentFarm then return end

    local plants = {}
    local plantAmt = 0
    local myCoords = GetEntityCoords(cache.ped)
    for i = 1, #currentFarm.spots do
        local spot = currentFarm.spots[i]

        if spot.inUse and #(coords - spot.coords) < 0.8 then
            plantAmt += 1
            plants[plantAmt] = {
                dist = #(myCoords - spot.coords),
                coords = spot.coords,
                index = i,
            }
        end
    end

    return plants
end

function Farms.isSpotUsed(farm, spot)
    local currentFarm = farm and playerFarms[farm]

    if not currentFarm then return end

    return currentFarm.spots[spot].inUse
end

function Farms.addSeed(farm, spot, seed)
    local currentFarm = farm and playerFarms[farm]?.spots
    local plantSettings = currentFarm and Plants[seed]

    if plantSettings then
        currentFarm[spot].inUse = true

        local coords = currentFarm[spot].coords

        local zOffset = plantSettings.plantOffset or 0.0

        Renewed.addObject({
            id = ('Renewed-Farming-%s-%s'):format(farm, spot),
            object = plantSettings.stages[1].stage,
            coords = vec3(coords.x, coords.y, coords.z + zOffset),
            heading = 0,
            colissions = false,
            dist = 130,
        })

        currentFarm[spot].target = exports.ox_target:addSphereZone({
            coords = vec(coords.x, coords.y, coords.z + 0.2),
            radius = 0.4,
            debug = false,
            options = {
                {
                    label = locale('view_info'),
                    onSelect = function()
                        local data = lib.callback.await('Renewed-Farming:server:getPlantInfo', false, farm, spot)
                        if not data then return end

                        lib.registerContext({
                            id = 'farming-plant-info',
                            title = locale('plant_info'),
                            options = {
                                {
                                    title = locale('growth_label'),
                                    description = ('%d%%'):format(data.growth),
                                    progress = data.growth,
                                    colorScheme = 'teal',
                                },
                                {
                                    title = locale('water_label'),
                                    description = ('%d%%'):format(data.water),
                                    progress = data.water,
                                    colorScheme = 'blue',
                                },
                                {
                                    title = locale('add_water'),
                                    onSelect = function()
                                        if not Farms.canInteract(farm) then return lib.notify({type = 'error', description = locale('not_your_plot')}) end
                                        TriggerServerEvent('Renewed-Farming:server:waterPlant', farm, spot)
                                    end,
                                }
                            }
                        })
                        lib.showContext('farming-plant-info')
                    end,
                    distance = 2.0
                }
            }
        })
    end
end


function Farms.changeSeed(farm, spot, seed, stage)
    if not farm or not spot or not seed or not stage then return end

    local plantData = playerFarms[farm] and playerFarms[farm].spots[spot]
    local stageData = plantData and Plants[seed] and Plants[seed].stages[stage]

    if stageData then
        Renewed.changeObject(('Renewed-Farming-%s-%s'):format(farm, spot), stageData.stage, plantData.coords + stageData.offset)
    end
end
--
function Farms.deadPlants(farm, spot, seed, delete)
    local currentFarm = farm and playerFarms[farm]

    if currentFarm then
        local id = ('Renewed-Farming-%s-%s'):format(farm, spot)

        if delete then
            currentFarm.spots[spot].inUse = false
            Renewed.removeObject(id)

            exports.ox_target:removeZone(currentFarm.spots[spot].target)
        else
            local plantData = playerFarms[farm].spots[spot]
            local stageData = Plants[seed].deadplant

            Renewed.changeObject(id, stageData.stage, plantData.coords + stageData.offset)
        end
    end
end

function Farms.waterPlant(farm, spot)
    local currentFarm = farm and playerFarms[farm]

    if currentFarm then
        local plantData = spot and currentFarm.spots[spot]

        if plantData then
            Renewed.addObject({
                id = ('Renewed-Farming-water-%s-%s'):format(farm, spot),
                object = `ep_plot_watered`,
                coords = vec3(plantData.coords.x, plantData.coords.y, plantData.coords.z + 0.275),
                heading = 0,
                colissions = false,
                dist = 65,
            })
        end
    end
end

function Farms.driedSpot(farm, spot)
    Renewed.removeObject(('Renewed-Farming-water-%s-%s'):format(farm, spot))
end

return Farms