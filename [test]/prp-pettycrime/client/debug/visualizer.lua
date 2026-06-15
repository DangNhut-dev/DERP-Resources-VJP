local debugModels = {}
local debugCoords = {}

local function DrawText3D(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 90)
    end
end

RegisterNetEvent("prp-pettycrime:client:registerDebugModel", function(model, typeName)
    debugModels[model] = typeName or "Unknown"
end)

RegisterNetEvent("prp-pettycrime:client:registerDebugCoords", function(id, coords, typeName)
    debugCoords[id] = {coords = coords, type = typeName}
end)

RegisterNetEvent("prp-pettycrime:client:removeDebugCoords", function(id)
    debugCoords[id] = nil
end)

CreateThread(function()
    while true do
        local sleep = 1500
        if Config.Debug then
            local pedCoords = GetEntityCoords(cache.ped)

            -- Find objects with registered models
            local objects = GetGamePool("CObject")
            for i = 1, #objects do
                local obj = objects[i]
                local objCoords = GetEntityCoords(obj)
                local dist = #(pedCoords - objCoords)
                if dist < 15.0 then
                    local model = GetEntityModel(obj)
                    local typeName = debugModels[model]
                    if typeName then
                        sleep = 0
                        -- Draw marker above object
                        DrawMarker(2, objCoords.x, objCoords.y, objCoords.z + 1.2, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.2, 0.2, 0.2, 231, 76, 60, 180, false, true, 2, nil, nil, false)
                        -- Draw 3D label
                        DrawText3D(objCoords + vector3(0.0, 0.0, 1.5), ("~r~[DEBUG]~w~ %s"):format(typeName))
                    end
                end
            end

            -- Find coords registered
            for id, data in pairs(debugCoords) do
                local dist = #(pedCoords - data.coords)
                if dist < 30.0 then
                    sleep = 0
                    -- Draw cylinder/marker
                    DrawMarker(1, data.coords.x, data.coords.y, data.coords.z - 0.95, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.8, 46, 204, 113, 80, false, true, 2, nil, nil, false)
                    -- Draw 3D label
                    DrawText3D(data.coords + vector3(0.0, 0.0, 1.0), ("~g~[ZONE DEBUG]~w~ %s"):format(data.type))
                end
            end
        end
        Wait(sleep)
    end
end)
