-- rcore_gangs only; blame Scorpion for this code...
if GetResourceState("rcore_gangs") == "started" then
  RegisterNetEvent("rcore_gangs:server:set_rank", function(...)
    local src = source

    if src and src > 0 then
      TriggerClientEvent("DERP-hud:client:rcore-refresh-gang", src)
    else
      TriggerClientEvent("DERP-hud:client:rcore-refresh-gang", -1)
    end
  end)
end