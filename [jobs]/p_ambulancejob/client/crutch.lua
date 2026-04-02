-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================


-- Wait for Config.Crutch to be available
while not (Config and Config.Crutch) do
  Wait(1)
end

-- Exit early if crutch system is disabled
if not Config.Crutch.enabled then
  return
end

-- Initialize Crutch module
Crutch = {}
Crutch._index = Crutch
Crutch.isEnabled = false

-- Test function (legacy)
function test()
  local schools = GlobalState["p_dmvschool/Schools"]
  if schools and schools[k] then
    return schools[k].theoryQuestions
  end
end

-- Setup target interaction to remove crutch from players
Citizen.CreateThread(function()
  Citizen.Wait(1000)
  
  Bridge.Target.addPlayer({
    {
      name = "p_ambulancejob/crutch/remove",
      label = locale("remove_crutch"),
      icon = "fa-solid fa-person-walking-with-cane",
      distance = 2,
      groups = Config.Crutch.allowedJobs,
      onSelect = function(data)
        local targetEntity = (type(data) == "number") and data or data.entity
        local targetServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetEntity))
        TriggerServerEvent("p_ambulancejob/server/crutch/remove", targetServerId)
      end,
      canInteract = function(targetPed)
        local targetServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
        local crutchPlayers = GlobalState["p_ambulancejob/crutchPlayers"]
        return crutchPlayers and crutchPlayers[targetServerId] or false
      end
    }
  })
end)

-- Give crutch to nearby player (medic function)
function Crutch:give()
  local playerJob = Bridge.Framework.fetchPlayerJob()
  
  -- Check if player has permission
  if not (playerJob and Config.Crutch.allowedJobs[playerJob.name]) then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  -- Get nearby players
  local nearbyPlayers = lib.getNearbyPlayers(GetEntityCoords(cache.ped), 5.0, true)
  local playerOptions = {}
  
  for _, player in pairs(nearbyPlayers) do
    local serverId = GetPlayerServerId(player.id)
    
    if serverId ~= cache.serverId then
      playerOptions[#playerOptions + 1] = {
        label = locale("player", serverId),
        args = { id = player.id }
      }
    end
  end
  
  -- Check if any players nearby
  if #playerOptions < 1 then
    Bridge.Notify.showNotify(locale("no_players"), "error")
    return
  end
  
  local selectedPed = nil
  
  -- Thread to draw marker on selected player
  Citizen.CreateThread(function()
    while lib.getOpenMenu() == "crutch_menu_players" do
      Citizen.Wait(1)
      
      if selectedPed then
        local coords = GetEntityCoords(selectedPed)
        DrawMarker(25, coords.x, coords.y, coords.z - 0.925, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.75, 0.75, 0.75, 255, 255, 255, 125, false, false, false, true)
      end
    end
  end)
  
  -- Register and show player selection menu
  lib.registerMenu({
    id = "crutch_menu_players",
    title = locale("crutch_menu_players"),
    options = playerOptions,
    onSelected = function(selected, scrollIndex, args)
      selectedPed = GetPlayerPed(args.id)
    end
  }, function(selected, scrollIndex, args)
    -- Get crutch duration from user
    local input = lib.inputDialog(locale("crutch_time_menu"), {
      {
        type = "number",
        label = locale("crutch_time_label"),
        required = true,
        icon = "clock",
        min = 1
      }
    })
    
    if not input then
      return
    end
    
    TriggerServerEvent("p_ambulancejob/server/crutch/forceCrutch", {
      targetId = GetPlayerServerId(args.id),
      time = input[1]
    })
  end)
  
  lib.showMenu("crutch_menu_players")
end

-- Show crutch menu for player
function Crutch:menu()
  lib.registerMenu({
    id = "crutch_menu",
    title = locale("crutch_menu"),
    options = {
      {
        label = locale("use_crutch"),
        args = "enable"
      },
      {
        label = locale("remove_crutch"),
        args = "disable"
      },
      {
        label = locale("give_crutch"),
        args = "give"
      }
    }
  }, function(selected, scrollIndex, args)
    if args == "enable" then
      Crutch:enable()
    elseif args == "disable" then
      Crutch:disable()
    elseif args == "give" then
      Crutch:give()
    end
  end)
  
  lib.showMenu("crutch_menu")
end

RegisterNetEvent("p_ambulancejob/client/crutch/menu", function()
  Crutch:menu()
end)

-- Enable crutch for player
function Crutch:enable()
  if self.isEnabled then
    return
  end
  
  self.isEnabled = true
  
  local playerPed = cache.ped
  
  -- Save original movement clipset
  self.clipSet = GetPedMovementClipset(playerPed)
  
  -- Apply crutch walking animation
  lib.requestAnimSet("move_heist_lester")
  SetPedMovementClipset(playerPed, "move_heist_lester", 100)
  RemoveClipSet("move_heist_lester")
  
  -- Spawn and attach crutch prop
  local model = lib.requestModel("prop_mads_crutch01")
  local coords = GetEntityCoords(playerPed)
  local crutchObject = CreateObject(model, coords, true, true, false)
  self.currentObject = crutchObject
  
  AttachEntityToEntity(crutchObject, playerPed, 70, 1.18, -0.36, -0.2, -20.0, -87.0, -20.0, true, true, false, true, 1, true)
  SetModelAsNoLongerNeeded(model)
  
  -- Thread to disable controls while using crutch
  Citizen.CreateThread(function()
    while self.isEnabled do
      Citizen.Wait(1)
      
      for _, control in pairs(Config.Crutch.disabledControls) do
        DisableControlAction(0, control, true)
      end
    end
  end)
  
  -- Thread to monitor and recreate crutch prop if deleted
  Citizen.CreateThread(function()
    while self.isEnabled do
      Citizen.Wait(1000)
      
      if self.isEnabled and not DoesEntityExist(self.currentObject) then
        local crutchModel = lib.requestModel("prop_mads_crutch01")
        local pedCoords = GetEntityCoords(cache.ped)
        local newCrutch = CreateObject(crutchModel, pedCoords, true, true, false)
        self.currentObject = newCrutch
        
        AttachEntityToEntity(newCrutch, cache.ped, 70, 1.18, -0.36, -0.2, -20.0, -87.0, -20.0, true, true, false, true, 1, true)
        SetModelAsNoLongerNeeded(crutchModel)
      end
    end
  end)
end

-- Export to check if crutch is enabled
exports("isCrutchEnabled", function()
  return Crutch.isEnabled
end)

RegisterNetEvent("p_ambulancejob/crutch/client/forceCrutch", function()
  Crutch:enable()
end)

-- Disable crutch for player
function Crutch:disable()
  if not self.isEnabled then
    return
  end
  
  self.isEnabled = false
  
  -- Remove crutch prop
  if self.currentObject then
    DeleteEntity(self.currentObject)
    self.currentObject = nil
  end
  
  -- Reset movement animation
  ResetPedMovementClipset(cache.ped, 1.0)
end

RegisterNetEvent("p_ambulancejob/crutch/client/removeCrutch", function()
  Crutch:disable()
end)

-- Export to assign crutch with time limit
exports("assignCrutch", function(time)
  if Crutch.isEnabled then
    return
  end
  
  TriggerServerEvent("p_ambulancejob/server/crutch/forceSelfCrutch", time)
end)