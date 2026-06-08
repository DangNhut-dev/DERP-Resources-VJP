-- Core Variables
local CallbackIndex = 0
local Callbacks = {}
local ActiveSounds = {}

-- Movement Module
Movement = {
    SpawnedObjects = {}
}

-- Functions Module
Functions = {}

-- Lerp function: Linear interpolation between two values
function Functions.Lerp(start, target, alpha)
    return start + (target - start) * alpha
end

-- Random float between min and max
function Functions.randomFloat(min, max)
    return min + math.random() * (max - min)
end

-- Normalize a Vector3
function Functions.NormalizeVector3(vector)
    local magnitude = math.sqrt(
        vector.x * vector.x +
        vector.y * vector.y +
        vector.z * vector.z
    )
    
    if magnitude > 0 then
        return {
            x = vector.x / magnitude,
            y = vector.y / magnitude,
            z = vector.z / magnitude
        }
    else
        return {x = 0, y = 0, z = 0}
    end
end

-- Convert rotation to direction vector
function Functions.RotationToDirection(rotation)
    local radians = {
        x = math.pi / 180 * rotation.x,
        y = math.pi / 180 * rotation.y,
        z = math.pi / 180 * rotation.z
    }
    
    local direction = {
        x = -math.sin(radians.z) * math.abs(math.cos(radians.x)),
        y = math.cos(radians.z) * math.abs(math.cos(radians.x)),
        z = math.sin(radians.x)
    }
    
    return vec3(direction.x, direction.y, direction.z)
end

-- Error logging
function Functions.Error(...)
    local args = table.pack(...)
    local message = ""
    local first = true
    
    for _, value in ipairs(args) do
        if first then
            first = false
        else
            message = message .. " "
        end
        message = message .. tostring(value)
    end
    
    print("^5[ERROR]:^1 " .. message)
end

-- Load model
function Functions.LoadModel(model)
    if HasModelLoaded(model) then
        return
    end
    
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
end

-- Request animation dictionary
function Functions.RequestAnimDict(animDict)
    if HasAnimDictLoaded(animDict) then
        return
    end
    
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(0)
    end
end

-- Spawn object with optional callback
function Functions.SpawnObject(model, callback, coords, isNetwork, isFrozen)
    local playerPed = PlayerPedId()
    
    -- Convert string to hash if needed
    if type(model) == "string" then
        model = GetHashKey(model) or model
    end
    
    -- Validate model
    if not IsModelInCdimage(model) then
        Functions.Error("CAN'T SPAWN OBJECT BECAUSE MODEL DOESNT EXIST: " .. model)
        return
    end
    
    -- Set default coordinates if not provided
    if coords then
        if type(coords) == "table" then
            coords = vec3(coords.x, coords.y, coords.z) or coords
        end
    else
        coords = GetEntityCoords(playerPed)
    end
    
    -- Set defaults
    isNetwork = isNetwork == nil or isNetwork
    isFrozen = isFrozen == true or isFrozen
    
    -- Load model and create object
    Functions.LoadModel(model)
    local object = CreateObjectNoOffset(model, coords.x, coords.y, coords.z, isNetwork, true, true)
    
    -- Set heading if vector4
    if type(coords) == "vector4" then
        SetEntityHeading(object, coords.w)
    end
    
    -- Track spawned object
    table.insert(Movement.SpawnedObjects, object)
    
    -- Freeze and set LOD
    FreezeEntityPosition(object, isFrozen)
    SetEntityLodDist(object, 500)
    
    -- Execute callback if provided
    if callback then
        callback(object)
    end
end

-- Delete entity
function Functions.DeleteEntity(entity)
    if entity == nil then
        Functions.Error("ATTEMPTED TO DELETE A NIL OBJECT")
        return
    end
    
    if type(entity) ~= "number" then
        Functions.Error("ATTEMPTED TO DELETE A " .. type(entity) .. " TYPE: " .. entity)
        return
    end
    
    DetachEntity(entity, false, false)
    SetEntityAsMissionEntity(entity, false, true)
    DeleteObject(entity)
    
    -- Remove from spawned objects list
    for index, obj in pairs(Movement.SpawnedObjects) do
        if obj == entity then
            Movement.SpawnedObjects[index] = nil
            return
        end
    end
end

-- Join multiple tables into one
function Functions.TableJoin(...)
    local result = {}
    local tables = table.pack(...)
    
    for _, tbl in ipairs(tables) do
        for _, value in ipairs(tbl) do
            table.insert(result, value)
        end
    end
    
    return result
end

-- Calculate dot product of two vectors
function Functions.DotProduct(vec1, vec2)
    return vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z
end

-- Deep copy a table
function Functions.DeepCopy(original)
    local originalType = type(original)
    local copy
    
    if originalType == 'table' then
        copy = {}
        for key, value in next, original, nil do
            copy[Functions.DeepCopy(key)] = Functions.DeepCopy(value)
        end
        setmetatable(copy, Functions.DeepCopy(getmetatable(original)))
    else
        copy = original
    end
    
    return copy
end

-- Rotate point around another point
function Functions.RotateAroundPoint(pivotX, pivotY, pivotZ, yaw, pitch, roll, pointX, pointY, pointZ)
    local sinYaw = math.sin(math.rad(yaw))
    local cosYaw = math.cos(math.rad(yaw))
    local sinPitch = math.sin(math.rad(pitch))
    local cosPitch = math.cos(math.rad(pitch))
    local sinRoll = math.sin(math.rad(roll))
    local cosRoll = math.cos(math.rad(roll))
    
    -- Translate point to origin
    pointX = pointX - pivotX
    pointY = pointY - pivotY
    pointZ = pointZ - pivotZ
    
    -- Rotate around Z axis (yaw)
    local tempY = pointY * cosYaw - pointZ * sinYaw
    local tempZ = pointY * sinYaw + pointZ * cosYaw
    pointY = tempY
    pointZ = tempZ
    
    -- Rotate around Y axis (pitch)
    local tempX = pointX * cosPitch + pointZ * sinPitch
    tempZ = pointZ * cosPitch - pointX * sinPitch
    pointX = tempX
    pointZ = tempZ
    
    -- Rotate around X axis (roll)
    tempX = pointX * cosRoll - pointY * sinRoll
    tempY = pointX * sinRoll + pointY * cosRoll
    pointX = tempX
    pointY = tempY
    
    -- Translate back
    pointX = pointX + pivotX
    pointY = pointY + pivotY
    pointZ = pointZ + pivotZ
    
    return vector3(pointX, pointY, pointZ)
end

-- Convert network IDs to entities in a table
function Functions.NetIdTableToEntity(netIdTable)
    local entityTable = {}
    
    for key, value in pairs(netIdTable) do
        local startTime = GetGameTimer()
        
        if type(value) == "number" then
            -- Wait for network ID to exist
            while not NetworkDoesNetworkIdExist(value) do
                if GetGameTimer() - startTime > 1500 then
                    Functions.Error(string.format("Cloudn't find entity with NetId: %s (%s)", value, key))
                end
                Wait(100)
            end
            
            -- Convert network ID to entity
            while true do
                if entityTable[key] and entityTable[key] ~= value then
                    break
                end
                
                entityTable[key] = NetToObj(value)
                
                if GetGameTimer() - startTime > 1500 then
                    Functions.Error(string.format("Cloudn't find entity with NetId: %s (%s)", value, key))
                end
                
                if entityTable[key] and entityTable[key] ~= value then
                    break
                end
                
                Wait(100)
            end
        else
            entityTable[key] = Functions.NetIdTableToEntity(value)
        end
    end
    
    return entityTable
end

-- Audio Functions
function Functions.PlaySound(audioFile, volume, looped, soundId)
    local volumeMultiplier = Config.SoundVolumeMultipler or 1.0
    volume = volume * volumeMultiplier
    
    local id = #ActiveSounds + 1
    if soundId then
        id = soundId
    end
    
    ActiveSounds[id] = true
    
    SendNUIMessage({
        action = "playSound",
        id = id,
        audioFile = audioFile,
        volume = volume,
        looped = looped
    })
end

function Functions.PlayAudioAtCoords(audioFile, volume, coords, maxDistance, followEntity, looped, soundId)
    local playerCoords = GetEntityCoords(PlayerPedId())
    
    -- Get entity coords if entity exists
    if DoesEntityExist(coords) then
        coords = GetEntityCoords(coords) or coords
    end
    
    -- Check if player is within range
    local distance = #(playerCoords - coords)
    if distance > maxDistance then
        return
    end
    
    local volumeMultiplier = Config.SoundVolumeMultipler or 1.0
    volume = volume * volumeMultiplier
    
    local id = #ActiveSounds + 1
    if soundId then
        id = soundId
    end
    
    ActiveSounds[id] = true
    Functions.UpdateSound(id)
    
    -- Follow entity if specified
    if followEntity then
        local entity = coords
        coords = GetEntityCoords(entity)
        local lastX, lastY, lastZ
        
        CreateThread(function()
            Wait(200)
            while ActiveSounds[id] do
                coords = GetEntityCoords(entity)
                
                if coords and (lastX ~= coords.x or lastY ~= coords.y or lastZ ~= coords.z) then
                    SendNUIMessage({
                        action = "updateSoundCoords",
                        id = id,
                        x = coords.x,
                        y = coords.y,
                        z = coords.z
                    })
                    lastX, lastY, lastZ = coords.x, coords.y, coords.z
                end
                
                Wait(100)
            end
        end)
    end
    
    SendNUIMessage({
        action = "playSound3D",
        id = id,
        audioFile = audioFile,
        volume = volume,
        x = coords.x,
        y = coords.y,
        z = coords.z,
        maxDistance = maxDistance,
        looped = looped
    })
end

function Functions.StopSound(soundId)
    SendNUIMessage({
        action = "stopSound",
        id = soundId
    })
end

-- NUI Callback for sound end
RegisterNUICallback("soundsEnd", function(data)
    ActiveSounds[data.id] = nil
end)

-- Update sound position for 3D audio
function Functions.UpdateSound(soundId)
    CreateThread(function()
        local lastX, lastY, lastZ, lastHeading
        
        while ActiveSounds[soundId] ~= nil do
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local heading = GetEntityHeading(playerPed)
            
            if lastX ~= coords.x or lastY ~= coords.y or lastZ ~= coords.z or lastHeading ~= heading then
                SendNUIMessage({
                    action = "updateSound",
                    id = soundId,
                    x = coords.x,
                    y = coords.y,
                    z = coords.z,
                    h = heading
                })
                lastX, lastY, lastZ, lastHeading = coords.x, coords.y, coords.z, heading
            end
            
            -- Ensure all sounds are active
            for id, isActive in pairs(ActiveSounds) do
                if not isActive then
                    ActiveSounds[id] = true
                end
            end
            
            Wait(10)
        end
    end)
end

-- Callback System
function Functions.TriggerServerCallback(name, callback, ...)
    CallbackIndex = CallbackIndex + 1
    local currentIndex = CallbackIndex
    
    Callbacks[name] = Callbacks[name] or {}
    Callbacks[name][currentIndex] = callback
    
    TriggerServerEvent("17mov_Callbacks:GetResponse" .. GetCurrentResourceName(), name, currentIndex, ...)
end

RegisterNetEvent("17mov_Callbacks:receiveData" .. GetCurrentResourceName(), function(name, index, ...)
    if not Callbacks[name] or not Callbacks[name][index] then
        return
    end
    
    Callbacks[name][index](...)
    
    if Callbacks[name] and Callbacks[name][index] then
        Callbacks[name][index] = nil
    end
    
    if Callbacks[name] and #Callbacks[name] == 0 then
        Callbacks[name] = nil
    end
end)

-- Cleanup on resource stop
AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    
    -- Delete all spawned objects
    for _, object in pairs(Movement.SpawnedObjects) do
        if type(object) == "table" then
            for _, subObject in pairs(object) do
                if type(subObject) == "number" then
                    DeleteEntity(subObject)
                end
            end
        elseif type(object) == "number" then
            if DoesEntityExist(object) then
                DeleteEntity(object)
            end
        end
    end
end)