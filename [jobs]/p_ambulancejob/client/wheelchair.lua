-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================



-- Wait for Config.Wheelchair to be available
while not (Config and Config.Wheelchair) do
  Wait(1)
end

-- Exit if wheelchair system is not enabled
if not Config.Wheelchair.enabled then
  return
end

-- Test function for GlobalState access
function test()
  local schools = GlobalState["p_dmvschool/Schools"]
  if schools and schools[k] then
    return schools[k].theoryQuestions
  end
end

-- Initialize Wheelchair object
Wheelchair = {
  isEnabled = false,
  currentVehicle = nil
}

-- Cache handler: Auto-enable wheelchair engine when player enters
lib.onCache("vehicle", function(vehicle)
  if vehicle and vehicle ~= 0 then
    local vehicleModel = GetEntityModel(vehicle)
    
    -- Check if it's a wheelchair (model hash: -1963629913)
    if vehicleModel == -1963629913 then
      SetVehicleEngineOn(vehicle, true, true, false)
      SetVehicleDoorsLocked(vehicle, 1)
    end
  end
end)

-- Show menu to give wheelchair to nearby player
function Wheelchair.give(self)
  local playerJob = Bridge.Framework.fetchPlayerJob()
  
  -- Check if player has access
  if not (playerJob and Editable.allJobs[playerJob.name]) then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  -- Get nearby players
  local nearbyPlayers = lib.getNearbyPlayers(GetEntityCoords(cache.ped), 5.0, true)
  local playerOptions = {}
  
  -- Build player selection list
  for _, playerData in pairs(nearbyPlayers) do
    local serverId = GetPlayerServerId(playerData.id)
    
    -- Exclude self
    if serverId ~= cache.serverId then
      local optionIndex = #playerOptions + 1
      playerOptions[optionIndex] = {
        label = locale("player", serverId),
        args = {
          id = playerData.id
        }
      }
    end
  end
  
  if #playerOptions < 1 then
    Bridge.Notify.showNotify(locale("no_players"), "error")
    return
  end
  
  -- Track selected player for marker rendering
  local selectedPed = nil
  
  -- Thread to render marker on selected player
  Citizen.CreateThread(function()
    while lib.getOpenMenu() == "wheelchair_menu_players" do
      Citizen.Wait(1)
      
      if selectedPed then
        local pedCoords = GetEntityCoords(selectedPed)
        
        -- Draw marker above selected player
        DrawMarker(
          25,
          pedCoords.x,
          pedCoords.y,
          pedCoords.z - 0.925,
          0.0, 0.0, 0.0,
          0.0, 0.0, 0.0,
          0.75, 0.75, 0.75,
          255, 255, 255, 125,
          false, false, false, true
        )
      end
    end
  end)
  
  -- Register and show menu
  lib.registerMenu({
    id = "wheelchair_menu_players",
    title = locale("wheelchair_menu_players"),
    options = playerOptions,
    onSelected = function(selected, scrollIndex, args)
      -- Update selected ped for marker
      selectedPed = GetPlayerPed(args.id)
    end
  }, function(selected, scrollIndex, args)
    -- On confirm: Ask for wheelchair duration
    local input = lib.inputDialog(locale("wheelchair_time_menu"), {
      {
        type = "number",
        label = locale("wheelchair_time_label"),
        required = true,
        icon = "clock",
        min = 1
      }
    })
    
    if not input then
      return
    end
    
    -- Send request to server
    TriggerServerEvent("p_ambulancejob/server/wheelchair/forceWheelchair", {
      targetId = GetPlayerServerId(args.id),
      time = input[1]
    })
  end)
  
  lib.showMenu("wheelchair_menu_players")
end

-- Show main wheelchair menu
function Wheelchair.menu(self)
  lib.registerMenu({
    id = "wheelchair_menu",
    title = locale("wheelchair_menu"),
    options = {
      {
        label = locale("use_wheelchair"),
        args = "enable"
      },
      {
        label = locale("remove_wheelchair"),
        args = "disable"
      },
      {
        label = locale("give_wheelchair"),
        args = "give"
      }
    }
  }, function(selected, scrollIndex, args)
    if args == "enable" then
      Wheelchair:enable()
    elseif args == "disable" then
      Wheelchair:disable()
    elseif args == "give" then
      Wheelchair:give()
    end
  end)
  
  lib.showMenu("wheelchair_menu")
end

-- Network event: Open wheelchair menu
RegisterNetEvent("p_ambulancejob/client/wheelchair/menu", function()
  Wheelchair:menu()
end)

-- Enable wheelchair for player
function Wheelchair.enable(self, warpIntoVehicle)
  if self.isEnabled then
    return
  end
  
  self.isEnabled = true
  
  -- Request and spawn wheelchair
  local modelHash = lib.requestModel("iak_wheelchair")
  local spawnCoords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 0.5, 0.1)
  local heading = GetEntityHeading(cache.ped)
  
  local wheelchair = CreateVehicle(
    modelHash,
    spawnCoords.x,
    spawnCoords.y,
    spawnCoords.z,
    heading,
    true,
    true
  )
  
  self.currentVehicle = wheelchair
  
  -- Configure wheelchair
  SetVehicleEngineOn(wheelchair, true, true, false)
  
  -- Set fuel if supported
  if Bridge.Fuel then
    Bridge.Fuel.SetFuel(wheelchair, 100.0)
  end
  
  -- Give keys if supported
  if Bridge.CarKeys then
    Bridge.CarKeys.CreateKeys(GetVehicleNumberPlateText(wheelchair), wheelchair)
  end
  
  SetVehicleDoorsLocked(wheelchair, 1)
  SetVehicleHasBeenOwnedByPlayer(wheelchair, true)
  
  -- Warp player into wheelchair if requested
  if warpIntoVehicle then
    TaskWarpPedIntoVehicle(cache.ped, wheelchair, -1)
    
    -- Disable exit control while in wheelchair
    Citizen.CreateThread(function()
      while self.isEnabled do
        Citizen.Wait(1)
        DisableControlAction(0, 75, true) -- Disable F (exit vehicle)
      end
    end)
  end
end

-- Network event: Force wheelchair on player
RegisterNetEvent("p_ambulancejob/wheelchair/client/forceWheelchair", function()
  Wheelchair:enable(true)  -- Pass true to warp player into wheelchair
end)

-- Disable wheelchair and remove vehicle
function Wheelchair.disable(self)
  if not self.isEnabled then
    return
  end
  
  self.isEnabled = false
  
  -- Delete wheelchair vehicle
  if self.currentVehicle then
    DeleteVehicle(self.currentVehicle)
    self.currentVehicle = nil
  end
end

-- Network event: Remove wheelchair
RegisterNetEvent("p_ambulancejob/wheelchair/client/removeWheelchair", function()
  Wheelchair:disable()
end)