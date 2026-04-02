local flashlightEnabled = false

local function drawFlashlight(ped)
  local coords = GetPedBoneCoords(ped, 28422, 0.05, 0.01, -0.04)
  local direction = GetEntityForwardVector(ped)
  DrawSpotLightWithShadow(coords.x, coords.y, coords.z, direction.x, direction.y, direction.z,
    255, 255, 255, 15.0, 3.0, 0.0, 50.0, 100.0, 1)
  DrawSpotLightWithShadow(coords.x, coords.y, coords.z, direction.x, direction.y, direction.z,
    255, 255, 255, 30.0, 10.0, 0.0, 20.0, 25.0, 1)
end

local function toggleFlashlight(state)
  state = state == true
  if flashlightEnabled == state then return end
  flashlightEnabled = state
  TriggerServerEvent("tablet:toggleFlashlight", flashlightEnabled)
  
  if not flashlightEnabled then return end
  Citizen.CreateThreadNow(function()
    local ped = PlayerPedId()
    while flashlightEnabled do
      drawFlashlight(ped)
      Wait(0)
    end
  end)
end

ReactCallback("toggleFlashlight", function(state)
  toggleFlashlight(state)
  Wait(100)
end, "ok")

exports("ToggleFlashlight", function(state)
  toggleFlashlight(state)
  SendReactMessage("toggleFlashlight", flashlightEnabled)
end)

if not Config.SyncFlashlight then return end

local nearbyFlashlights = {}
local flashlightInterval

local function drawNearbyFlashlights()
  for _, ped in ipairs(nearbyFlashlights) do
    drawFlashlight(ped)
  end
end

local function updateFlashlightInterval()
  if #nearbyFlashlights > 0 and not flashlightInterval then
    flashlightInterval = SetInterval(drawNearbyFlashlights)
  elseif #nearbyFlashlights == 0 and flashlightInterval then
    ClearInterval(flashlightInterval)
    flashlightInterval = nil
  end
end

AddStateBagChangeHandler("lbTabletFlashlight", nil, function(bagName, key, value, reserved, replicated)
  local player = GetPlayerFromStateBagName(bagName)
  if not player or player == 0 or player == PlayerId() then return end
  
  local ped = GetPlayerPed(player)
  local distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(ped))
  if distance > 30.0 then return end

  local index = table.indexOf(nearbyFlashlights, ped)
  if not index and value then
    table.insert(nearbyFlashlights, ped)
  elseif index and not value then
    table.remove(nearbyFlashlights, index)
  end
  updateFlashlightInterval()
end)

CreateThread(function()
  while true do
    table.wipe(nearbyFlashlights)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local players = GetNearbyPlayers()
    
    for _, player in ipairs(players) do
      local state = Player(player.source).state
      if state.lbTabletFlashlight and state.lbTabletOpen then
        local distance = #(playerCoords - GetEntityCoords(player.ped))
        if distance <= 30.0 then
          table.insert(nearbyFlashlights, player.ped)
        end
      end
    end
    updateFlashlightInterval()
    Wait(1000)
  end
end)