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

local porchPoints = {}

function CreatePorchPoint(id, coords, modelHash, heading)
    local point = lib.points.new({
        locationId = id,
        coords = coords,
        distance = 100.0,
        modelHash = modelHash,
        heading = heading
    })

    if Config.Debug then
        TriggerEvent("prp-pettycrime:client:registerDebugCoords", "pp_"..id, coords, "Porch Pirate Package")
    end

    point.onEnter = function(self)
        lib.requestModel(self.modelHash)

        local packageObj = CreateObjectNoOffset(self.modelHash, self.coords.x, self.coords.y, self.coords.z, false, false, false)
        SetEntityAsMissionEntity(packageObj, true, true)
        FreezeEntityPosition(packageObj, true)
        SetEntityHeading(packageObj, self.heading)

        bridge.target.addLocalEntity({ packageObj }, {
            {
                name = "porch_pirate_steal",
                label = locale("target.porch_pirate.steal"),
                icon = "fas fa-mask",
                distance = 1.5,
                onSelect = function()
                    TriggerServerEvent("prp-pettycrime:server:stealPackage", self.locationId)
                end
            }
        })

        SetModelAsNoLongerNeeded(self.modelHash)
        self.handle = packageObj
    end

    point.onExit = function(self)
        if self.handle then
            bridge.target.removeLocalEntity({ self.handle }, "porch_pirate_steal")
            DeleteEntity(self.handle)
            self.handle = nil
        end
    end

    porchPoints[id] = point
end

function DeletePorchPoint(id)
    local point = porchPoints[id]
    if not point then return end

    if Config.Debug then
        TriggerEvent("prp-pettycrime:client:removeDebugCoords", "pp_"..id)
    end

    if point.handle and DoesEntityExist(point.handle) then
        DeleteEntity(point.handle)
    end

    point:remove()
    porchPoints[id] = nil
end

function CreatePorchPoints(locations)
    for _, location in pairs(locations) do
        CreatePorchPoint(location.id, location.coords, location.modelHash, location.heading)
    end
end

RegisterNetEvent("prp-pettycrime:client:startup", function(activityType, data)
    if activityType ~= "pp_locations" then return end
    CreatePorchPoints(data)
end)

RegisterNetEvent("prp-pettycrime:client:pirateAddLocation", function(data)
    CreatePorchPoint(data.id, data.coords, data.modelHash, data.heading)
end)

RegisterNetEvent("prp-pettycrime:client:pirateDeleteLocation", function(id)
    DeletePorchPoint(id)
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    for _, point in pairs(porchPoints) do
        if point.handle and DoesEntityExist(point.handle) then
            DeleteEntity(point.handle)
        end
    end
end)
