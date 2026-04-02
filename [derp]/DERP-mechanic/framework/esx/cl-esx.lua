if (Config.Framework == "auto" and GetResourceState("es_extended") == "started") or Config.Framework == "ESX" then
  -- Player data
  Globals.PlayerData = ESX.GetPlayerData()

  RegisterNetEvent("esx:playerLoaded")
  AddEventHandler("esx:playerLoaded", function(xPlayer)
    Globals.PlayerData = xPlayer
    TriggerEvent("DERP-mechanic:client:refresh-mechanic-zones-and-blips")
  end)

  RegisterNetEvent("esx:setJob")
  AddEventHandler("esx:setJob", function(job)
    Globals.PlayerData.job = job
    TriggerEvent("DERP-mechanic:client:refresh-mechanic-zones-and-blips")
  end)
end
