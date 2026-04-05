-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================



-- Wait for Config.Interactions to be available
while not (Config and Config.Interactions) do
  Citizen.Wait(100)
end

-- Exit if interactions are not enabled
if not Config.Interactions.enabled then
  return
end

-- Test function for GlobalState access
function test()
  local schools = GlobalState["p_dmvschool/Schools"]
  if schools and schools[k] then
    return schools[k].theoryQuestions
  end
end

-- Initialize Interactions object
Interactions = {}

-- Vehicle seat labels
Interactions.seats = {
  ["-1"] = locale("driver_seat"),
  ["0"] = locale("passenger_seat"),
  ["1"] = locale("back_left_passenger"),
  ["2"] = locale("back_right_passenger")
}

-- Carry state tracking
Interactions.carryRole = "none"
Interactions.activeCarry = false
Interactions.carryPlayerId = nil

-- Callback: Request permission to carry player
lib.callback.register("p_ambulancejob/server/interactions/canCarry", function(medicName, targetName)
  local response = lib.alertDialog({
    header = locale("carry_player"),
    content = locale("carry_player_request", medicName, targetName),
    centered = true,
    cancel = true
  })
  
  return response == "confirm"
end)

-- Play carry animation based on role
function Interactions.playCarry(self)
  local animData = Config.Interactions.options.carryPlayer.animData[self.carryRole]
  
  lib.requestAnimDict(animData.dict)
  TaskPlayAnim(
    cache.ped,
    animData.dict,
    animData.clip,
    8.0,
    -8.0,
    -1,
    animData.flag,
    0,
    false,
    false,
    false
  )
end

-- Toggle carry state (start or stop carrying)
function Interactions.carry(self, carryData)
  if self.activeCarry then
    self.activeCarry = false
    ClearPedTasksImmediately(cache.ped)
    DetachEntity(cache.ped, true, false)
    -- Sửa: reset pauseLoop cho tất cả death type, không chỉ bleeding
    if Death.deathType ~= "none" then
      Death.pauseLoop = false
    end
    return
  end
  
  -- Check if target player is bleeding (needs longer wait)
  local targetPlayer = Player(carryData.id)
  local isTargetBleeding = targetPlayer.state.deathType == "bleeding"
  local waitTime = isTargetBleeding and 1000 or 100
  Citizen.Wait(waitTime)
  
  -- Start carrying
  self.activeCarry = true
  self.carryPlayerId = carryData.id
  self.carryRole = carryData.isCarrying and "carrying" or "carried"
  
  local animData = Config.Interactions.options.carryPlayer.animData[self.carryRole]
  
  -- Attach and animate carried player
  if self.carryRole == "carried" then
    if Death.isCrawling then
        Death.isCrawling = false
    end
    Death.pauseLoop = true
    ClearPedTasksImmediately(cache.ped)
    Citizen.Wait(50)
    
    local carrierPed = GetPlayerPed(GetPlayerFromServerId(carryData.id))
    
    AttachEntityToEntity(
      cache.ped,
      carrierPed,
      0,
      animData.offset.coords,
      animData.offset.rotation,
      false,
      false,
      false,
      false,
      2,
      false
    )
    
    Citizen.Wait(10)
    self:playCarry()
  else
    self:playCarry()
  end

  -- Disable attack/aim khi đang cõng (cả 2 bên)
  Citizen.CreateThread(function()
    while self.activeCarry do
      DisableControlAction(0, 24, true)   -- Attack (left click)
      DisableControlAction(0, 257, true)  -- Attack 2
      DisableControlAction(0, 25, true)   -- Aim (right click)
      DisableControlAction(0, 263, true)  -- Melee attack 1
      DisableControlAction(0, 264, true)  -- Melee attack 2
      DisableControlAction(0, 140, true)  -- Melee attack light
      DisableControlAction(0, 141, true)  -- Melee attack heavy
      DisableControlAction(0, 142, true)  -- Melee attack alternate
      DisableControlAction(0, 143, true)  -- Melee block
      Citizen.Wait(0)
    end
  end)
  
  -- Monitor carry state and keep animation playing
  Citizen.CreateThread(function()
    while self.activeCarry do
      Citizen.Wait(250)
      
      if self.activeCarry then
        local currentAnimData = Config.Interactions.options.carryPlayer.animData[self.carryRole]
        
        if currentAnimData then
          -- Restart animation if it stopped
          if not IsEntityPlayingAnim(cache.ped, currentAnimData.dict, currentAnimData.clip, 3) then
            self:playCarry()
          end
        end
        
        -- Verify other player still exists
        local otherPlayerPed = GetPlayerPed(GetPlayerFromServerId(self.carryPlayerId))
        
        if not (otherPlayerPed and otherPlayerPed ~= 0 and DoesEntityExist(otherPlayerPed) and otherPlayerPed ~= cache.ped) then
          -- Other player disconnected or invalid, stop carry
          self:carry({
            id = self.carryPlayerId,
            isCarrying = self.carryRole == "carrying"
          })
          break
        end
      end
    end
  end)
  
  -- Show controls for carrier to stop carrying
  Citizen.CreateThread(function()
    if self.carryRole == "carried" then
      return
    end
    
    lib.showTextUI(locale("stop_carry_textui"), {position = "left-center"})
    
    while self.activeCarry do
      Citizen.Wait(1)
      
      -- Press X to stop carrying
      if IsControlJustReleased(0, 73) then
        TriggerServerEvent("p_ambulancejob/server/interactions/carryPlayer", self.carryPlayerId)
        break
      end
    end
    
    lib.hideTextUI()
  end)
end

-- Put player into vehicle seat
function Interactions.putInVehicle(self, seatIndex)
  -- Don't allow if already in vehicle
  if cache.vehicle and cache.vehicle ~= 0 then
    return
  end
  
  -- Find closest vehicle
  local vehicle, distance = lib.getClosestVehicle(GetEntityCoords(cache.ped), 5.0, false)
  
  -- Check if seat is available
  if not IsVehicleSeatFree(vehicle, seatIndex) then
    return
  end
  
  Death.inVehicle = true
  Citizen.Wait(10)
  ClearPedTasksImmediately(cache.ped)
  Citizen.Wait(1)
  
  -- Use appropriate function based on death state
  if Death.deathType == "none" then
    TaskWarpPedIntoVehicle(cache.ped, vehicle, seatIndex)
  else
    SetPedIntoVehicle(cache.ped, vehicle, seatIndex)
  end
end

-- Take player out of vehicle
function Interactions.takeOutVehicle(self)
  -- Only allow if in vehicle
  if not (cache.vehicle and cache.vehicle ~= 0) then
    return
  end
  
  Death.inVehicle = false
  Citizen.Wait(10)
  TaskLeaveVehicle(cache.ped, cache.vehicle, 16)
  Citizen.Wait(1000)
  ClearPedTasksImmediately(cache.ped)
end

-- Take blood from player (reduce health)
function Interactions.takeBlood(self)
  if not Config.Interactions.playerBlood.enabled then
    return
  end
  
  local currentHealth = GetEntityHealth(cache.ped)
  local newHealth = math.max(0, currentHealth - Config.Interactions.playerBlood.healthToRemove)
  
  SetEntityHealth(cache.ped, newHealth)
  Bridge.Notify.showNotify(locale("medic_taken_blood_from_you"), "success")
end

-- Network events
RegisterNetEvent("p_ambulancejob/client/interactions/takeBlood", function()
  Interactions:takeBlood()
end)

RegisterNetEvent("p_ambulancejob/client/interactions/putInVehicle", function(seatIndex)
  Interactions:putInVehicle(seatIndex)
end)

RegisterNetEvent("p_ambulancejob/client/interactions/takeOutVehicle", function()
  Interactions:takeOutVehicle()
end)

RegisterNetEvent("p_ambulancejob/client/interactions/toggleCarry", function(carryData)
  Interactions:carry(carryData)
end)

-- Initialize target interactions
Citizen.CreateThread(function()
  Citizen.Wait(3000)
  
  local targets = {
    player = {},
    vehicle = {}
  }
  
  -- Build interaction options from config
  for interactionName, interactionData in pairs(Config.Interactions.options) do
    if interactionName == "putPlayerInVehicle" then
      -- Create separate option for each vehicle seat
      for seatIndex = -1, 6 do
        local seatLabel = Interactions.seats[tostring(seatIndex)] or locale("additional_seat")
        
        table.insert(targets.player, {
          name = "p_ambulancejob/interaction/" .. interactionName .. "/" .. seatIndex,
          label = string.format("%s (%s)", interactionData.label, seatLabel),
          icon = interactionData.icon,
          distance = interactionData.distance,
          groups = interactionData.jobs,
          onSelect = function(entity)
            interactionData.onSelect(entity, seatIndex)
          end,
          canInteract = function(entity)
            return interactionData.canInteract(entity, seatIndex)
          end
        })
      end
    elseif interactionName == "takeIncapacitatedFromVehicle" then
      for seatIndex = 0, 6 do
        local seatLabel = Interactions.seats[tostring(seatIndex)] or locale("additional_seat")
 
        table.insert(targets.vehicle, {
          name = "p_ambulancejob/interaction/" .. interactionName .. "/" .. seatIndex,
          label = string.format("%s (%s)", interactionData.label, seatLabel),
          icon = interactionData.icon,
          distance = interactionData.distance,
          groups = interactionData.jobs,
          onSelect = function(entity)
            interactionData.onSelect(entity, seatIndex)
          end,
          canInteract = function(entity)
            return interactionData.canInteract(entity, seatIndex)
          end
        })
      end
    else
      -- Standard interaction (no seat selection)
      table.insert(targets[interactionData.type], {
        name = "p_ambulancejob/interaction/" .. interactionName,
        label = interactionData.label,
        icon = interactionData.icon,
        distance = interactionData.distance,
        groups = interactionData.jobs,
        onSelect = interactionData.onSelect,
        canInteract = interactionData.canInteract
      })
    end
  end
  
  -- Register player interactions
  if #targets.player > 0 then
    Bridge.Target.addPlayer(targets.player)
  end
  
  -- Register vehicle interactions
  if #targets.vehicle > 0 then
    Bridge.Target.addVehicle(targets.vehicle)
  end
end)

-- =====================================================
-- THÊM vào file client interactions (interactions.lua client)
-- Paste vào cuối file, trước phần CreateThread init target
-- =====================================================

-- Cho người đang cõng lên xe
function Interactions.putCarriedInVehicle(self, seatIndex)
    if not self.activeCarry or self.carryRole ~= 'carrying' then return end
    if not self.carryPlayerId then return end

    -- Dừng cõng trước
    local carriedPlayerId = self.carryPlayerId
    self.activeCarry = false
    ClearPedTasksImmediately(cache.ped)
    DetachEntity(cache.ped, true, false)

    -- Gửi event đưa người lên xe
    Citizen.Wait(200)
    TriggerServerEvent('p_ambulancejob/server/interactions/putCarriedInVehicle', {
        seat = seatIndex,
        player = carriedPlayerId,
    })
end

-- Đưa người ngất/chết/còng xuống xe
function Interactions.takeIncapacitatedFromVehicle(self, targetPlayerId)
    -- Animation kéo người xuống
    local dict = 'missfinale_c2ig_11'
    local anim = 'pushout_driver_player'
    lib.requestAnimDict(dict)
    TaskPlayAnim(cache.ped, dict, anim, 4.0, -4.0, 2000, 49, 0, false, false, false)

    Citizen.Wait(1500)
    ClearPedTasks(cache.ped)
    RemoveAnimDict(dict)
end

-- ── Network Events ─────────────────────────────────────────────

RegisterNetEvent('p_ambulancejob/client/interactions/putCarriedInVehicle', function(seatIndex)
    Interactions:putInVehicle(seatIndex)
end)

RegisterNetEvent('p_ambulancejob/client/interactions/takeIncapacitatedFromVehicle', function()
    Interactions:takeOutVehicle()
end)


-- =====================================================
-- SỬA phần CreateThread init target ở cuối file
-- Trong vòng for interactionName, thêm xử lý cho
-- 'takeIncapacitatedFromVehicle' giống 'takeOutPlayerVehicle'
-- (tạo option cho từng ghế)
--
-- Tìm block:
--   elseif invType == 'drop' then
-- Và thêm trước block else cuối cùng:
-- =====================================================

-- Trong phần init target, block for interactionName cần thêm:
--[[
    elseif interactionName == "takeIncapacitatedFromVehicle" then
      -- Tạo option cho từng ghế (từ ghế phụ trở đi)
      for seatIndex = 0, 6 do
        local seatLabel = Interactions.seats[tostring(seatIndex)] or locale("additional_seat")
        
        table.insert(targets.vehicle, {
          name = "p_ambulancejob/interaction/" .. interactionName .. "/" .. seatIndex,
          label = string.format("%s (%s)", interactionData.label, seatLabel),
          icon = interactionData.icon,
          distance = interactionData.distance,
          groups = interactionData.jobs,
          onSelect = function(entity)
            interactionData.onSelect(entity, seatIndex)
          end,
          canInteract = function(entity)
            return interactionData.canInteract(entity, seatIndex)
          end
        })
      end
--]]

-- putCarriedInVehicle KHÔNG cần tách theo ghế vì tự tìm ghế trống
-- Nó dùng type = 'vehicle' và được thêm bình thường như standard interaction