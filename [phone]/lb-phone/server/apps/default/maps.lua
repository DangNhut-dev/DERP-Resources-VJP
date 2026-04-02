-- Maps app server-side handlers


-- Get saved locations for a phone number
BaseCallback("maps:getSavedLocations", function(source, phoneNumber)
    local locations = MySQL.query.await(
    "SELECT id, `name`, x_pos, y_pos FROM phone_maps_locations WHERE phone_number = ? ORDER BY `name` ASC", { phoneNumber })

    -- Transform database results to expected format
    for i = 1, #locations do
        local location = locations[i]
        locations[i] = {
            id = location.id,
            name = location.name,
            position = { location.y_pos, location.x_pos } -- [y, x] format
        }
    end


    return (locations)
end)

-- Add a new location
BaseCallback("maps:addLocation", function(source, phoneNumber, locationName, xPos, yPos)
    local locationId = MySQL.insert.await(
    "INSERT INTO phone_maps_locations (phone_number, `name`, x_pos, y_pos) VALUES (?, ?, ?, ?)", {
        phoneNumber,
        locationName,
        xPos,
        yPos
    })
    return (locationId)
end)

-- Rename an existing location
BaseCallback("maps:renameLocation", function(source, phoneNumber, locationId, newName)
    local success = MySQL.update.await("UPDATE phone_maps_locations SET `name` = ? WHERE id = ? AND phone_number = ?", {
        newName,
        locationId,
        phoneNumber
    })
    return (success > 0)
end)

-- Remove a saved location
BaseCallback("maps:removeLocation", function(source, phoneNumber, locationId)
    local success = MySQL.update.await("DELETE FROM phone_maps_locations WHERE id = ? AND phone_number = ?", {
        locationId,
        phoneNumber
    })
    return (success > 0)
end)
