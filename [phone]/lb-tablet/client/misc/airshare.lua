local function getNearbyPlayers()
  local nearbyPlayers = {}
  local players = GetNearbyPlayers()
  local playerCoords = GetEntityCoords(PlayerPedId())
  for _, player in ipairs(players) do
    local playerState = Player(player.source).state
    local distance = #(playerCoords - GetEntityCoords(player.ped))
    if distance <= 7.5 then
      if playerState.lbTabletOpen and playerState.lbTabletName then
        table.insert(nearbyPlayers, {
          name = playerState.lbTabletName,
          source = player.source,
          device = "tablet"
        })
      elseif Config.LBPhone and playerState.phoneOpen and playerState.phoneName then
        table.insert(nearbyPlayers, {
          name = playerState.phoneName,
          source = player.source,
          device = "phone"
        })
      end
    end
  end
  return nearbyPlayers
end

ReactCallback("AirShare", function(A0_2)
  local action = A0_2.action
  if action == "getNearby" then
    return getNearbyPlayers()
  elseif action == "share" then
    return AwaitCallback("airShare:share", A0_2.source, A0_2.device, A0_2.data)
  elseif action == "accept" then
    TriggerServerEvent("tablet:airShare:interacted", A0_2.source, A0_2.device, true)
  elseif action == "deny" then
    TriggerServerEvent("tablet:airShare:interacted", A0_2.source, A0_2.device, false)
  end
end, "ok")

RegisterNetEvent("tablet:airShare:received", function(data)
  SendReactMessage("airShare:received", data)
end)

RegisterNetEvent("tablet:airShare:interacted", function(source, accepted)
  SendReactMessage("airShare:interacted", { source = source, accepted = accepted })
end)