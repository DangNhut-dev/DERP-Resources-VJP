-- Algorithm constants
local ANGLE_STEP = 4.0
local MAX_DISTANCE = 10.0
local MIN_DISTANCE = 1.5
local DISTANCE_DECREMENT = 1.0
local GOOD_DISTANCE = 5.0
local CAPSULE_RADIUS = 0.25
local MAX_ITERATIONS = 8

-- Check heading and find best direction with clear space
function Algorithms.CheckHeading()
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local iteration = 0
    local checkDistance = MAX_DISTANCE
    
    while checkDistance >= MIN_DISTANCE and iteration < MAX_ITERATIONS do
        iteration = iteration + 1
        local bestHeading = nil
        local bestDistance = 0.0
        
        -- Check all directions in 360 degrees
        for angle = 0, 360 - ANGLE_STEP, ANGLE_STEP do
            local direction = vector3(
                -math.sin(math.rad(angle)),
                math.cos(math.rad(angle)),
                0.0
            )
            
            local targetPos = pedCoords + (direction * checkDistance)
            
            -- Perform shape test to check for obstacles
            local shapeTest = StartShapeTestCapsule(
                pedCoords.x, pedCoords.y, pedCoords.z,
                targetPos.x, targetPos.y, targetPos.z,
                CAPSULE_RADIUS,
                511,
                ped,
                7
            )
            
            local _, hit, endCoords, _, _ = table.unpack({GetShapeTestResult(shapeTest)})
            
            local distance = checkDistance
            if hit ~= 0 or not checkDistance then
                distance = #(endCoords - pedCoords)
            end
            
            -- Track best direction
            if bestDistance < distance then
                bestDistance = distance
                bestHeading = angle
                
                -- Early exit if found good enough direction
                if distance >= GOOD_DISTANCE then
                    NUI.InfoText(false)
                    debugPrint("[CHECK.HEADING] Early exit, direction is good enough")
                    break
                end
            end
        end
        
        -- Apply best heading if found
        if bestHeading and bestDistance >= GOOD_DISTANCE then
            SetEntityHeading(ped, bestHeading + 0.01)
            NUI.InfoText(false)
            debugPrint("[CHECK.HEADING] Applied distance.")
            return
        end
        
        checkDistance = checkDistance - DISTANCE_DECREMENT
        Wait(0)
    end
    
    -- Fallback: Try to find safe coords
    local foundSafe, safeCoords = GetSafeCoordForPed(pedCoords.x, pedCoords.y, pedCoords.z, false, 16)
    
    if foundSafe then
        NUI.InfoText(false)
        SetEntityCoords(ped, safeCoords)
    end
end
