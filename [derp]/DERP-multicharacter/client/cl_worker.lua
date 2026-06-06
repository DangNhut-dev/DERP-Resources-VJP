WorkerBeforeInitiliazation = function() end
WorkerAfterInitialization = function() end
WorkerBeforePlayerSelection = function() end
WorkerAfterPlayerSelection = function() end
WorkerAfterPlayerSwapCharacter = function() end
WorkerBeforeLocationsInitialization = function() end
WorkerAfterLocationsAreInitialized = function() end
WorkerBeforeLocationsUnload = function() end
WorkerAfterLocationsUnload = function() end
WorkerAfterSettingsInitiated = function() end
WorkerAfterSettingsUnloaded = function() end
WorkerGetUserStorage = function(data) end
WorkerUpdatedUserStorage = function(setting, data) end
HandleHud = function(hideHud) end

CreateThread(function()
    Wait(0)

    -- patch Locations.Data.last
    setmetatable(Locations.Data, {
        __newindex = function(t, k, v)
            if k == 'last' then
                local currentChar = Entity.Vars.currentCharacter
                local allowLast = currentChar and currentChar.allowLastLocation

                if not allowLast then
                    for _, loc in pairs(Config.Locations) do
                        rawset(t, k, {
                            coords = loc.coords,
                            type = loc.type or 'default',
                            label = loc.label or 'Default'
                        })
                        return
                    end
                end
            end
            rawset(t, k, v)
        end
    })

    local _OriginalEntityInit = Entity.Init
    Entity.Init = function(character)
        if character and not character.allowLastLocation and not character.isInJail then
            for _, loc in pairs(Config.Locations) do
                character.position = {
                    x = loc.coords.x,
                    y = loc.coords.y,
                    z = loc.coords.z,
                    heading = 0.0
                }
                break
            end
        end

        if character and character.isInJail then
            SendNUIMessage({
                type = "SET_SPAWN_LOCATION_VISIBILITY",
                state = false
            })
            SendNUIMessage({
                type = "OVERRIDE_LOCATIONS_STATE",
                state = true
            })
        end

        _OriginalEntityInit(character)
    end
end)