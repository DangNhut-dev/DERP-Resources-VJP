FX = {}

-- Load bucket animation with effects
function FX.LoadBucketAnim()
    if not Config.Effects.useEffects then
        return
    end

    -- Send entrance FX to NUI
    SendNUIMessage({
        type = "FX_PLAY",
        data = {
            fx = "FX_ENTRANCE"
        }
    })

    Citizen.CreateThread(function()
        Wait(2000)

        -- Shake camera
        local camera = (Identity.Cam == false and Entity.Vars.MainCamera) or Identity.Cam
        ShakeCam(camera, "VIBRATE_SHAKE", 0.6)

        debugPrint("Preparing bucket sphere [/]")

        -- Draw bucket sphere effect
        if Config.Effects.useBucketSphere then
            local ped = PlayerPedId()
            local startTime = GetGameTimer()
            local duration = 2600
            local endTime = startTime + duration
            local currentTime = startTime
            local progress = 0.0

            while endTime > currentTime do
                local coords = GetEntityCoords(ped)
                progress = (endTime - currentTime) / duration

                local radius = (1.0 - progress) * 1000.0
                local intensity = Config.SphereIntensity * progress

                -- Draw sphere at entity position
                DrawGlowSphere(
                    coords.x,
                    coords.y,
                    coords.z,
                    radius,
                    Config.SphereColor[1],
                    Config.SphereColor[2],
                    Config.SphereColor[3],
                    intensity,
                    false,
                    false
                )

                -- Draw sphere above entity
                DrawGlowSphere(
                    coords.x,
                    coords.y,
                    coords.z + 1000,
                    radius,
                    Config.SphereColor[1],
                    Config.SphereColor[2],
                    Config.SphereColor[3],
                    intensity,
                    false,
                    false
                )

                currentTime = GetGameTimer()
                Wait(0)
            end

            debugPrint("Bucket sphere loop done")
        end
    end)
end
