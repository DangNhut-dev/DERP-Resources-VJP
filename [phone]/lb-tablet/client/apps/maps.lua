local playerPed = PlayerPedId()
local lastCoords = vector3(0, 0, 0)
local lastHeading = 0.0
local updateInterval = nil

local function updateCoords()
  if not TabletOpen then return end
  local coords = GetEntityCoords(playerPed)
  local heading = GetEntityHeading(playerPed)
  
  if #(lastCoords - coords) < 1.0 and math.abs(lastHeading - heading) < 5.0 then
    return
  end
  
  lastCoords = coords
  lastHeading = heading
  SendReactMessage("maps:updateCoords", {
    x = math.floor(coords.x + 0.5),
    y = math.floor(coords.y + 0.5),
    heading = math.floor(heading + 0.5)
  })
end

ReactCallback("Maps", function(data)
  if data.action == "toggleUpdateCoords" then
    if data.toggle then
      if not updateInterval then
        playerPed = PlayerPedId()
        lastCoords = GetEntityCoords(playerPed)
        lastHeading = GetEntityHeading(playerPed)
        updateInterval = SetInterval(updateCoords, 250)
        SendReactMessage("maps:updateCoords", {
          x = lastCoords.x,
          y = lastCoords.y,
          heading = lastHeading
        })
      end
    else
      if updateInterval then
        ClearInterval(updateInterval)
        updateInterval = nil
      end
    end
    return "ok"
  elseif data.action == "getCurrentLocation" then
    local coords = GetEntityCoords(PlayerPedId())
    return { x = coords.x, y = coords.y }
  elseif data.action == "setWaypoint" then
    local x = tonumber(data.coords.x)
    local y = tonumber(data.coords.y)
    if x and y then
      SetNewWaypoint(x / 1, y / 1)
    end
    return "ok"
  end
end)