local insideParkingMeter = false
local insideLetterBox = false
local insidePostBox = false

local createdZones = {}

function IsInsideParkingMeterZone()
    if not Config.ParkingMeters.zones or #Config.ParkingMeters.zones == 0 then
        return true
    end
    return insideParkingMeter
end

function IsInsideLetterBoxZone()
    if not Config.LetterBoxes.zones or #Config.LetterBoxes.zones == 0 then
        return true
    end
    return insideLetterBox
end

function IsInsidePostBoxZone()
    if not Config.PostBoxes.zones or #Config.PostBoxes.zones == 0 then
        return true
    end
    return insidePostBox
end

local function initializeJobZones(jobName, zonesConfig, insideCallback)
    if not zonesConfig then return end
    
    for i, zoneData in ipairs(zonesConfig) do
        local zone = lib.zones.sphere({
            coords = zoneData.coords,
            radius = zoneData.radius or 50.0,
            debug = Config.Debug,
            onEnter = function()
                insideCallback(true)
            end,
            onExit = function()
                insideCallback(false)
            end
        })
        table.insert(createdZones, zone)
    end
end

CreateThread(function()
    -- Parking Meters Zones
    initializeJobZones("parking_meters", Config.ParkingMeters.zones, function(isInside)
        insideParkingMeter = isInside
    end)

    -- Letter Boxes Zones
    initializeJobZones("letter_boxes", Config.LetterBoxes.zones, function(isInside)
        insideLetterBox = isInside
    end)

    -- Post Boxes Zones
    initializeJobZones("post_boxes", Config.PostBoxes.zones, function(isInside)
        insidePostBox = isInside
    end)
end)

AddEventHandler("onResourceStop", function(resourceName)
    if cache.resource ~= resourceName then return end
    for _, zone in ipairs(createdZones) do
        zone:remove()
    end
end)
