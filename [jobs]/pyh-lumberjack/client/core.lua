-- Notify dùng ox_lib
function Notify(msg, typ)
    lib.notify({ description = msg, type = typ })
end

-- Progressbar dùng ox_lib
function ProgBar(name, label, duration, disableOptions, animOptions, onFinish, onCancel)
    Citizen.CreateThread(function()
        local ok = lib.progressBar({
            duration     = duration,
            label        = label,
            useWhileDead = false,
            canCancel    = true,
            disable      = {
                move    = disableOptions.disableMovement,
                car     = disableOptions.disableCarMovement,
                combat  = disableOptions.disableCombat,
            },
            anim = {
                dict = animOptions.animDict,
                clip = animOptions.anim,
            },
        })
        if ok then
            if onFinish then onFinish() end
        else
            if onCancel then onCancel() end
        end
    end)
end