local nearbyPlayers = {}

function GetNearbyPlayers()
  return nearbyPlayers
end

while true do
  local playerCoords = GetEntityCoords(PlayerPedId())
  local players = GetActivePlayers()
  local currentPlayer = PlayerId()
  local newNearby = {}
  
  for _, player in ipairs(players) do
    if player ~= currentPlayer then
      local ped = GetPlayerPed(player)
      local coords = GetEntityCoords(ped)
      local distance = #(playerCoords - coords)
      if distance <= 60.0 then
        table.insert(newNearby, {
          player = player,
          source = GetPlayerServerId(player),
          ped = ped
        })
      end
    end
  end
  nearbyPlayers = newNearby
  Wait(5000)
end