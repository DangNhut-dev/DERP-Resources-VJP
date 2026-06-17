local letterBoxModels = {}
local letterBoxItems = {}

RegisterNetEvent("prp-pettycrime:client:startup", function(activityType, data)
    if activityType ~= "letter_boxes" then return end

    letterBoxModels = data.models
    letterBoxItems = data.items

    if Config.Debug then
        for _, model in ipairs(letterBoxModels) do
            TriggerEvent("prp-pettycrime:client:registerDebugModel", model, "Letter Box")
        end
    end

    bridge.target.addModel(letterBoxModels, {
        {
            name = "letterbox-steal",
            icon = "fas fa-hand-fist",
            label = locale("target.letterbox"),
            onSelect = function(data)
                local entity = data.entity
                local coords = GetEntityCoords(entity)
                local model = GetEntityModel(entity)
                local archetypeName = GetEntityArchetypeName(entity)
                local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
                local streetName = GetStreetNameFromHashKey(streetHash)
                local zoneName = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
                local locationLabel = (streetName ~= "" and ("%s, %s"):format(streetName, zoneName)) or zoneName

                TriggerServerEvent("prp-pettycrime:server:letterboxSteal", archetypeName, model, coords, locationLabel)
            end,
            canInteract = function(entity, distance)
                if not IsInsideLetterBoxZone() then
                    return false
                end

                if distance > Config.LetterBoxes.targetDistance then
                    return false
                end

                if HasObjectBeenBroken(entity) or cache.vehicle then
                    return false
                end

                -- for _, item in ipairs(letterBoxItems) do
                --     if bridge.inv.hasItem(item, 1) then
                --         return true
                --     end
                -- end

                return true
            end
        }
    })
end)

AddEventHandler("onResourceStop", function(resourceName)
    if cache.resource ~= resourceName then return end

    bridge.target.removeModel(letterBoxModels, { "letterbox-steal" })
end)
