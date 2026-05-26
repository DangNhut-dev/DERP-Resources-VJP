lib.callback.register("DERP-mechanic:server:dyno-share-with-player", function(source, targetPlayerId, results)
  local targetPlayer = Player(targetPlayerId)
  if targetPlayer.state and targetPlayer.state.isBusy then
    Framework.Server.Notify(source, Locale.playerIsBusy, "error")
    return false
  end
  TriggerClientEvent("DERP-mechanic:client:dyno-show-results-sheet", targetPlayerId, results)
  return true
end)