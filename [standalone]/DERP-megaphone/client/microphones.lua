-- ────────────────────────────────────────────────────────────
-- STAGE MICROPHONES — dùng ox_target
-- ────────────────────────────────────────────────────────────

CreateThread(function()
    if not Config.targetOptions.enabled then return end

    if Config.microphoneLocations and #Config.microphoneLocations > 0 then
        -- Vị trí cố định
        for i, location in ipairs(Config.microphoneLocations) do
            exports.ox_target:addSphereZone({
                coords   = location.coords,
                radius   = Config.targetOptions.distance,
                debug    = Config.debug,
                options  = {
                    {
                        name    = 'DERP-megaphone:mic_' .. i,
                        icon    = Config.targetOptions.icon,
                        label   = location.label or 'Sử dụng Microphone',
                        onSelect = function()
                            createMicZoneAtLocation(location)
                        end
                    }
                }
            })
        end
    else
        -- Theo model
        for _, model in ipairs(Config.models) do
            exports.ox_target:addModel(model, {
                {
                    name     = 'DERP-megaphone:model_' .. model,
                    icon     = Config.targetOptions.icon,
                    label    = 'Sử dụng Microphone',
                    distance = Config.targetOptions.distance,
                    onSelect = function(data)
                        createMicPoly(GetEntityModel(data.entity))
                    end
                }
            })
        end
    end
end)
