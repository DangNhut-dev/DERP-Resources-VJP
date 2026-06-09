local crosshairEnabled = true

RegisterCommand('togglecrosshair', function()
    crosshairEnabled = not crosshairEnabled
    if not crosshairEnabled then
        SendNUIMessage({ display = "crosshairHide" })
        lib.notify({ title = 'Crosshair', description = 'Đã tắt tâm ngắm', type = 'error' })
    else
        lib.notify({ title = 'Crosshair', description = 'Đã bật tâm ngắm', type = 'success' })
    end
end, false)

CreateThread(function()
    while true do
        if crosshairEnabled and IsPedArmed(PlayerPedId(), 4 | 2) then
            if IsPlayerFreeAiming(PlayerId()) then
                SendNUIMessage({ display = "crosshairShow" })
                Wait(100)
            else
                SendNUIMessage({ display = "crosshairHide" })
                Wait(100)
            end
        else
            SendNUIMessage({ display = "crosshairHide" })
            Wait(1000)
        end
    end
end)