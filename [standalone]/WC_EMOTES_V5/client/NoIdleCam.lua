RegisterCommand('idlecamoff', function()
    local playerPed = PlayerPedId()

    QBCore.Functions.Notify("Idle Cam đã được tắt", "success", 5000)

    DisableIdleCamera(true)
    SetPedCanPlayAmbientAnims(playerPed, false)
    SetResourceKvp("idleCam", "off")
end)


RegisterCommand('idlecamon', function()
    local playerPed = PlayerPedId()

    QBCore.Functions.Notify("Idle Cam đã được bật", "success", 5000)

    DisableIdleCamera(false)
    SetPedCanPlayAmbientAnims(playerPed, true)
    SetResourceKvp("idleCam", "on")
end)

Citizen.CreateThread(function()
  TriggerEvent("chat:addSuggestion", "/idlecamon", "Re-enables the idle cam")
  TriggerEvent("chat:addSuggestion", "/idlecamoff", "Disables the idle cam")

  local idleCamDisabled = GetResourceKvpString("idleCam") == "off"
  DisableIdleCamera(idleCamDisabled)
end)
