--[[
░▒▓████████▓▒░▒▓██████▓▒░       ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░  
   ░▒▓█▓▒░  ░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
   ░▒▓█▓▒░  ░▒▓█▓▒░             ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
   ░▒▓█▓▒░  ░▒▓█▓▒░             ░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░  
   ░▒▓█▓▒░  ░▒▓█▓▒░             ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
   ░▒▓█▓▒░  ░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
   ░▒▓█▓▒░   ░▒▓██████▓▒░       ░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░░▒▓███████▓▒░  
                                                                         
 This File Leaked By TC HUB Team, Join Our Server For More
 DISCORD: - https://discord.gg/k3S8RjkPWc - https://t.me/+RgDxwPX3L7w2ODBk - https://tchub.shop/
--]]

local glm = nil
local glmUp = nil
local glmRight = nil
local glitterBombPoints = {}

function CleanupGlitterBomb(pointId)
    local point = glitterBombPoints[pointId]
    if not point then return end

    if point.entities then
        for i, entity in pairs(point.entities) do
            if DoesEntityExist(entity) then
                bridge.target.removeLocalEntity(entity, "pp_disarm_gb")
                SetEntityAsMissionEntity(entity, true, true)
                DeleteEntity(entity)
            end
            point.entities[i] = nil
        end
    end

    if point.decals then
        for i, decal in pairs(point.decals) do
            if IsDecalAlive(decal) then
                RemoveDecal(decal)
            end
            point.decals[i] = nil
        end
    end

    if point.particles then
        for i, particle in pairs(point.particles) do
            if DoesParticleFxLoopedExist(particle) then
                StopParticleFxLooped(particle, false)
            end
            point.particles[i] = nil
        end
    end
end

function CreateDecal(data)
    return AddDecal(
        data.type,
        data.coords.x, data.coords.y, data.coords.z,
        data.forward.x, data.forward.y, data.forward.z,
        data.right.x, data.right.y, data.right.z,
        data.size.x, data.size.y,
        data.red, data.green, data.blue,
        1.0, -1.0, false, false, true
    )
end

function SpawnGlitterBombObject(pointId, data)
    lib.requestModel(data.hash)

    local obj = CreateObjectNoOffset(data.hash, data.coords.x, data.coords.y, data.coords.z, false, false, false)
    SetEntityAsMissionEntity(obj, true, true)
    FreezeEntityPosition(obj, true)
    PlaceObjectOnGroundProperly(obj)
    SetEntityHeading(obj, data.heading)
    SetModelAsNoLongerNeeded(data.hash)

    bridge.target.addLocalEntity({ obj }, {
        {
            name = "pp_disarm_gb",
            label = locale("target.porch_pirate.disarm"),
            icon = "fas fa-hand",
            distance = 1.5,
            canInteract = function()
                if not Config.GlitterBomb.disarming.jobRequired then
                    return true
                end

                for _, job in ipairs(Config.GlitterBomb.disarming.jobs) do
                    if bridge.fw.hasJob(job.id, job.minGrade, job.duty) then
                        return true
                    end
                end

                return false
            end,
            onSelect = function()
                TriggerServerEvent("prp-pettycrime:server:gbDisarm", pointId)
            end
        }
    })

    return obj
end

function StartGlitterBombParticle(coords, data)
    local entity = GetClosestObjectOfType(coords.x, coords.y, coords.z, 3.0, data.model, false, false, false)
    if not entity or not DoesEntityExist(entity) then return end

    lib.requestNamedPtfxAsset(data.dict)
    UseParticleFxAsset(data.dict)

    local particle = StartParticleFxLoopedOnEntity(
        data.name, entity,
        data.offsetX or 0.0, data.offsetY or 0.0, data.offsetZ or 0.0,
        0.0, 0.0, 0.0,
        data.scale, false, false, false
    )

    CreateThread(function()
        while DoesParticleFxLoopedExist(particle) do
            local sounds = data.sounds or {}
            for _, sound in pairs(sounds) do
                local times = sound.times or 1
                for i = 1, times do
                    PlaySoundFromEntity(-1, sound.name, entity, sound.ref, false, false)
                    Wait(sound.timeBetween or 500)
                end
            end
            Wait(1000)
        end
    end)

    return particle
end

function CreateGlitterBombPoint(pointId, data)
    local point = lib.points.new({
        pointId = pointId,
        coords = data.coords,
        distance = 30.0,
        objects = data.objects or {},
        decalCoords = data.decalCoords or {},
        particleCoords = data.particleModels or {},
        entities = {},
        decals = {},
        particles = {}
    })

    point.onEnter = function(self)
        for _, objData in pairs(self.objects) do
            table.insert(self.entities, SpawnGlitterBombObject(self.pointId, objData))
        end

        for _, decalData in pairs(self.decalCoords) do
            table.insert(self.decals, CreateDecal(decalData))
        end

        for _, particleData in pairs(self.particleCoords) do
            local particle = StartGlitterBombParticle(self.coords, particleData)
            if particle then
                table.insert(self.particles, particle)
            end
        end
    end

    point.onExit = function(self)
        CleanupGlitterBomb(self.pointId)
    end

    return point
end

RegisterNetEvent("prp-pettycrime:client:startup", function(activityType, data)
    if activityType ~= "pp_gbombs" then return end

    for id, bombData in pairs(data.glitterBombs or {}) do
        glitterBombPoints[id] = CreateGlitterBombPoint(id, bombData)
    end
end)

RegisterNetEvent("prp-pettycrime:client:gbAddPoint", function(id, data)
    glitterBombPoints[id] = CreateGlitterBombPoint(id, data)
end)

RegisterNetEvent("prp-pettycrime:client:gbResetPoints", function(ids)
    for _, id in pairs(ids) do
        CleanupGlitterBomb(id)
        if glitterBombPoints[id] then
            glitterBombPoints[id]:remove()
            glitterBombPoints[id] = nil
        end
    end
end)

lib.callback.register("prp-pettycrime:client:getGlitterBombData", function()
    if not glm then
        glm = require("glm")
        glmUp = glm.up()
        glmRight = glm.right()
    end

    local ped = cache.ped
    local forwardCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, 0.0)
    local _, groundZ = GetGroundZFor_3dCoord(forwardCoords.x, forwardCoords.y, forwardCoords.z, false)

    local startCoords = forwardCoords
    local endCoords = vector3(forwardCoords.x, forwardCoords.y, groundZ) - vector3(0.0, 0.0, 10.0)

    local hit, _, hitCoords, surfaceNormal = lib.raycast.fromCoords(startCoords, endCoords, 511)

    if not hit then
        return forwardCoords
    end

    local right = glm.perpendicular(surfaceNormal, -glmUp, glmRight)
    return forwardCoords, hitCoords, -surfaceNormal, right
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    for id, _ in pairs(glitterBombPoints) do
        CleanupGlitterBomb(id)
    end
end)

