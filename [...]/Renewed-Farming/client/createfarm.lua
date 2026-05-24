local cSpots = {
    vec3(0.5, 0.5, -0.06),
    vec3(0.5, 1.5, -0.06),
    vec3(1.5, 0.5, -0.06),
    vec3(1.5, 1.5, -0.06),

    vec3(-0.5, -0.5, -0.06),
    vec3(-0.5, -1.5, -0.06),
    vec3(-1.5, -0.5, -0.06),
    vec3(-1.5, -1.5, -0.06),

    vec3(-0.5, 0.5, -0.06),
    vec3(-0.5, 1.5, -0.06),
    vec3(-1.5, 0.5, -0.06),
    vec3(-1.5, 1.5, -0.06),

    vec3(0.5, -0.5, -0.06),
    vec3(0.5, -1.5, -0.06),
    vec3(1.5, -0.5, -0.06),
    vec3(1.5, -1.5, -0.06),
}

--
local function createnew(coords, heading)
    lib.requestModel(`ep_planter_large`)
    local object = CreateObject(`ep_planter_large`, coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(object, heading)
    SetEntityVisible(object, false)

    local points = {}

    for i = 1, #cSpots do
        local spot = cSpots[i]

        points[#points + 1] = GetOffsetFromEntityInWorldCoords(object, spot.x, spot.y, spot.z)
    end

    DeleteEntity(object)

    return points
end

lib.callback.register('Renewed-Farming:client:placeFarm', function()
    local coords, heading = Renewed.placeObject(`ep_planter_large`, 30.0, true, nil, nil, vec3(0.0, 0.0, -0.2))

    if not coords then return false end

    local locations = createnew(coords, heading)

    return vec4(coords.x, coords.y, coords.z, heading), locations
end)