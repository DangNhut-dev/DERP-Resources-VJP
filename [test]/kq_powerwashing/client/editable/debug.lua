RESTARTING = false

local function DebugDeleteAllEntities()
    local entities = table.merge(GetGamePool('CObject'), GetGamePool('CVehicle'))

    for k, entity in pairs(entities) do
        if DoesEntityExist(entity) then
            if GetEntityScript(entity) == GetCurrentResourceName() then
                SetEntityAsMissionEntity(entity, true, true)
                DeleteEntity(entity)
            end
        end
    end
end
DebugDeleteAllEntities()

--- SAFE RESTART FUNCTIONALITY
RegisterNetEvent(GetCurrentResourceName() .. ':client:safeRestart')
AddEventHandler(GetCurrentResourceName() .. ':client:safeRestart', function(caller)
    RESTARTING = true
    Citizen.Wait(600)

    DebugDeleteAllEntities()

    Citizen.CreateThread(function()
        while true do
            SetCurrentPedWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'), true)
            Citizen.Wait(1)
        end
    end)

    if caller == GetPlayerServerId(PlayerId()) then
        RemoveWeaponAsset(GetHashKey(Config.powerWasherWeapon))

        Citizen.Wait(1500)

        if not Config.debug then
            Citizen.Wait(1500)
        end

        ExecuteCommand('ensure ' .. GetCurrentResourceName())
    end
end)



if not Config.debug then return end

local isSelectingArea = false
local currentStep = 1
local corners = {}
local selectionMode = "wall"
local surfaceType = nil
local surfaceNormal = nil
local zOffset = 0.01

local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

local function RaycastCamera(distance)
    local camCoord = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)

    local rotX = camRot.x * (math.pi / 180.0)
    local rotZ = camRot.z * (math.pi / 180.0)

    local dirX = -math.sin(rotZ) * math.abs(math.cos(rotX))
    local dirY = math.cos(rotZ) * math.abs(math.cos(rotX))
    local dirZ = math.sin(rotX)

    local endCoord = vector3(
        camCoord.x + dirX * distance,
        camCoord.y + dirY * distance,
        camCoord.z + dirZ * distance
    )

    local ray = StartShapeTestRay(camCoord.x, camCoord.y, camCoord.z, endCoord.x, endCoord.y, endCoord.z, -1, PlayerPedId(), 0)
    local _, hit, coords, surfaceNormal, entity = GetShapeTestResult(ray)

    return hit == 1, coords, surfaceNormal, entity
end

local function DetectSurfaceType(surfaceNormal)
    if not surfaceNormal then return "unknown" end

    local dotUp = math.abs(surfaceNormal.z)

    if dotUp > 0.7 then
        return "horizontal"
    else
        return "vertical"
    end
end

local function ResetSelection()
    isSelectingArea = false
    currentStep = 1
    corners = {}
    surfaceType = nil
    surfaceNormal = nil
    zOffset = 0.01
end

local function DrawQuadPreview(c1, c2, c3, c4, mode)
    local r, g, b = 0, 255, 0

    -- Draw front-facing
    DrawPoly(c1.x, c1.y, c1.z, c2.x, c2.y, c2.z, c3.x, c3.y, c3.z, r, g, b, 100)
    DrawPoly(c1.x, c1.y, c1.z, c3.x, c3.y, c3.z, c4.x, c4.y, c4.z, r, g, b, 100)

    -- Draw back-facing (reversed winding order)
    DrawPoly(c1.x, c1.y, c1.z, c3.x, c3.y, c3.z, c2.x, c2.y, c2.z, r, g, b, 100)
    DrawPoly(c1.x, c1.y, c1.z, c4.x, c4.y, c4.z, c3.x, c3.y, c3.z, r, g, b, 100)
end

-- Universal winding order fix: ensures polygon faces towards the player
local function FixWindingOrder(c1, c2, c3, c4)
    -- Calculate polygon normal using cross product of two edges
    local edge1 = vector3(c2.x - c1.x, c2.y - c1.y, c2.z - c1.z)
    local edge2 = vector3(c4.x - c1.x, c4.y - c1.y, c4.z - c1.z)

    local normal = vector3(
        edge1.y * edge2.z - edge1.z * edge2.y,
        edge1.z * edge2.x - edge1.x * edge2.z,
        edge1.x * edge2.y - edge1.y * edge2.x
    )

    -- Get polygon center
    local center = vector3(
        (c1.x + c2.x + c3.x + c4.x) / 4,
        (c1.y + c2.y + c3.y + c4.y) / 4,
        (c1.z + c2.z + c3.z + c4.z) / 4
    )

    -- Get player camera position (where they were looking from when selecting)
    local camPos = GetGameplayCamCoord()

    -- Direction from polygon center to player
    local toPlayer = vector3(
        camPos.x - center.x,
        camPos.y - center.y,
        camPos.z - center.z
    )

    -- Dot product: if negative, normal points away from player
    local dot = normal.x * toPlayer.x + normal.y * toPlayer.y + normal.z * toPlayer.z

    -- If normal points away from player, flip the winding order
    if dot < 0 then
        return {c1, c4, c3, c2}
    end

    return {c1, c2, c3, c4}
end

local function StartAreaSelection()
    if isSelectingArea then
        return
    end

    selectionMode = "auto"
    isSelectingArea = true
    currentStep = 1
    corners = {}
    surfaceType = nil

    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        multiline = true,
        args = {"[Debug]", "Select 4 corners in order\n1: Top Left | 2: Top Right | 3: Bottom Right | 4: Bottom Left\nAim at TOP LEFT corner and press E\nUse Mouse Wheel to adjust Z offset"}
    })

    CreateThread(function()
        while isSelectingArea do
            Wait(0)

            if IsControlJustPressed(0, 14) then
                zOffset = zOffset - 0.01
            end
            if IsControlJustPressed(0, 15) then
                zOffset = zOffset + 0.01
            end

            local hit, coords, hitSurfaceNormal, entity = RaycastCamera(100.0)

            if hit then
                coords = vector3(coords.x, coords.y, coords.z + zOffset)
                local detectedType = DetectSurfaceType(hitSurfaceNormal)
                local displayMode = selectionMode

                if selectionMode == "auto" then
                    displayMode = detectedType == "horizontal" or "wall"
                end

                local sphereColors = {
                    {255, 0, 0},
                    {255, 165, 0},
                    {255, 255, 0},
                    {0, 255, 0}
                }
                local currentColor = sphereColors[currentStep]

                DrawSphere(coords.x, coords.y, coords.z, 0.03, currentColor[1], currentColor[2], currentColor[3], 0.9)

                local typeLabel = ""
                if currentStep == 1 then
                    typeLabel = detectedType == "horizontal" and " (~b~FLOOR~w~)" or " (~r~WALL~w~)"
                end

                local cornerLabels = {
                    "~r~TOP LEFT~w~",
                    "~o~TOP RIGHT~w~",
                    "~y~BOTTOM RIGHT~w~",
                    "~g~BOTTOM LEFT~w~"
                }
                local offsetLabel = zOffset ~= 0.0 and string.format(" ~y~[Z: %+.2fm]~w~", zOffset) or ""
                DrawText3D(coords.x, coords.y, coords.z + 0.3, cornerLabels[currentStep] .. " - Press ~g~E~w~" .. typeLabel .. offsetLabel)
                DrawText3D(coords.x, coords.y, coords.z + 0.15, "~w~Scroll: Adjust Z")

                if #corners == 2 then
                    local tempC3 = coords
                    local tempC4 = vector3(corners[1].x, corners[1].y, coords.z)
                    -- Draw both sides
                    DrawPoly(corners[1].x, corners[1].y, corners[1].z, corners[2].x, corners[2].y, corners[2].z, tempC3.x, tempC3.y, tempC3.z, 0, 200, 100, 80)
                    DrawPoly(corners[1].x, corners[1].y, corners[1].z, tempC3.x, tempC3.y, tempC3.z, corners[2].x, corners[2].y, corners[2].z, 0, 200, 100, 80)
                elseif #corners == 3 then
                    DrawQuadPreview(corners[1], corners[2], corners[3], coords, displayMode)
                end

                if IsControlJustPressed(0, 38) then
                    table.insert(corners, coords)

                    if currentStep == 1 then
                        surfaceType = detectedType
                        surfaceNormal = hitSurfaceNormal
                    end

                    zOffset = 0.01

                    if currentStep < 4 then
                        currentStep = currentStep + 1
                        local cornerNames = {"", "TOP RIGHT", "BOTTOM RIGHT", "BOTTOM LEFT"}
                        TriggerEvent('chat:addMessage', {
                            color = {0, 255, 0},
                            multiline = false,
                            args = {"[Debug]", "Corner set! Now aim at " .. cornerNames[currentStep] .. " corner and press E"}
                        })
                    else
                        local areaType = surfaceType == "horizontal" or "Wall"

                        -- Always fix winding order to face towards the player
                        local finalCorners = FixWindingOrder(corners[1], corners[2], corners[3], corners[4])

                        local formattedCorners = "corners = {\n"
                        for i, corner in ipairs(finalCorners) do
                            formattedCorners = formattedCorners .. string.format("    vec3(%.2f, %.2f, %.2f),\n", corner.x, corner.y, corner.z)
                        end
                        formattedCorners = formattedCorners .. "},"

                        exports.kq_jobcontracts:CopyToClipboard(formattedCorners)

                        TriggerEvent('chat:addMessage', {
                            color = {0, 255, 0},
                            multiline = false,
                            args = {"[Debug]", "Area coordinates copied to clipboard!"}
                        })

                        ResetSelection()
                    end
                end
            else
                local camPos = GetGameplayCamCoord()
                DrawText3D(camPos.x, camPos.y, camPos.z - 1.0, "~r~No surface found")
            end
        end
    end)
end

RegisterCommand('selectarea', function(source, args)
    StartAreaSelection()
end, false)
