RegisterNUICallback("close", function()
    SendNUIMessage({
        action = "toggle",
        value = false,
    })
    CardOpen = false
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
end)