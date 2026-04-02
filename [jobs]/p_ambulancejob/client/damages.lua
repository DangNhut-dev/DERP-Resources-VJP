-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================


-- Initialize Damages state table
Damages = {}
Damages.damages = {}
Damages.bones = {
  head = 31086,
  torso = 24817,
  leftArm = 18905,
  rightArm = 57005,
  leftLeg = 14201,
  rightLeg = 52301,
  mouth = 20279
}
Damages.antiSpam = GetGameTimer()
Damages.pulseChecked = false
Damages.temperatureChecked = false
Damages.effects = {
  blackOut = 0,
  shakeAim = 0
}
Damages.damagesUiState = false
Damages.knockouts = 0
Damages.resolution = {
  x = 1920,
  y = 1080
}
Damages.effectTimer = nil

-- NUI callback to get screen resolution
RegisterNUICallback("getResolution", function(data, cb)
  Damages.resolution = data.res
  cb(1)
end)

-- Initialize visual effects (blackout, aim shake)
function Damages:initEffects()
  Citizen.CreateThread(function()
    while true do
      -- Handle aim shake effect
      if self.effects.shakeAim > 0 then
        if IsPlayerFreeAiming(cache.playerId) then
          if not IsGameplayCamShaking() then
            ShakeGameplayCam("DRUNK_SHAKE", self.effects.shakeAim / 100)
          end
        else
          StopGameplayCamShaking(false)
        end
      else
        StopGameplayCamShaking(false)
      end
      
      -- Handle blackout effect
      if self.effects.blackOut > 0 then
        if not self.blackOut then
          self.blackOut = true
          SendNUIMessage({
            action = "setVisibleBlackout",
            data = true
          })
        end
        
        -- Decrease blackout over time
        self.effects.blackOut = math.max(0, self.effects.blackOut - 5)
        
        local opacity = 100 - self.effects.blackOut
        SendNUIMessage({
          action = "setBlackout",
          data = opacity
        })
      else
        if self.blackOut then
          self.blackOut = false
          SendNUIMessage({
            action = "setVisibleBlackout",
            data = false
          })
        end
      end
      
      Citizen.Wait(1000)
    end
  end)
end

-- Initialize effects system
Citizen.CreateThread(function()
  Damages:initEffects()
end)

-- Get total number of injuries
function Damages:getInjuriesAmount()
  local count = 0
  
  for _, bodyPart in pairs(self.damages) do
    for _, injury in pairs(bodyPart.injuries) do
      count = count + 1
    end
  end
  
  return count
end

-- Collect all healing items from config
function Damages:getAllHealingItems()
  Citizen.Wait(2000)
  
  local itemsData = {}
  
  -- Get items from weapon injuries
  for _, weapon in pairs(Config.Damages.weapons) do
    for _, injury in pairs(weapon.injuries) do
      if injury.items then
        for itemName, _ in pairs(injury.items) do
          local itemData = Bridge.Inventory.getItemData(itemName)
          
          if itemData then
            itemsData[itemName] = {
              item = itemName,
              label = itemData.label,
              image = itemData.image,
              description = itemData.description or "Generic Medical Item"
            }
          else
            lib.print.error(string.format("Item %s not found in your inventory items!", itemName))
          end
        end
      end
    end
    
    -- Get items from advanced injuries
    if weapon.advancedInjuries then
      for _, bodyPartInjuries in pairs(weapon.advancedInjuries) do
        for _, advancedInjury in pairs(bodyPartInjuries) do
          if advancedInjury.items then
            for itemName, _ in pairs(advancedInjury.items) do
              local itemData = Bridge.Inventory.getItemData(itemName)
              
              if itemData then
                itemsData[itemName] = {
                  item = itemName,
                  label = itemData.label,
                  image = itemData.image,
                  description = itemData.description or "Generic Medical Item"
                }
              else
                lib.print.error(string.format("Item %s not found in your inventory items!", itemName))
              end
            end
          end
        end
      end
    end
  end
  
  -- Get temperature items if enabled
  if Config.Temperature and Config.Temperature.enabled and Config.Temperature.items then
    for itemName, _ in pairs(Config.Temperature.items) do
      local itemData = Bridge.Inventory.getItemData(itemName)
      
      if itemData then
        itemsData[itemName] = {
          item = itemName,
          label = itemData.label,
          image = itemData.image,
          description = itemData.description or "Generic Medical Item"
        }
      else
        lib.print.error(string.format("Item %s not found in your inventory items!", itemName))
      end
    end
  end
  
  self.healingItems = itemsData
end

-- Get available healing items from player inventory
function Damages:getHealingItems()
  local availableItems = {}
  
  for itemName, itemData in pairs(self.healingItems) do
    local itemCount = Bridge.Inventory.getItemCount(itemName)
    
    if itemCount and itemCount > 0 then
      table.insert(availableItems, {
        name = itemName,
        label = itemData.label,
        image = itemData.image,
        description = itemData.description,
        count = itemCount
      })
    end
  end
  
  SendNUIMessage({
    action = "setHealingItems",
    data = availableItems
  })
end

-- Initialize damages state
Citizen.CreateThread(function()
  localState:set("damages", {}, true)
  Damages:getAllHealingItems()
end)

-- Find which body part a bone belongs to
function Damages:findBone(boneId)
  for bodyPartName, bones in pairs(Config.Damages.bones) do
    local boneIdStr = tostring(boneId)
    if bones[boneIdStr] then
      return bodyPartName
    end
  end
  
  return nil
end

-- Apply visual effects based on damage
function Damages:effect(bodyPart, damageValue)
  local chance = math.random(1, 100)
  
  if chance <= Config.Damages.effects.chance then
    local effectConfig = Config.Damages.effects.bones[bodyPart]
    
    if effectConfig then
      local effectType = effectConfig.effect
      
      if self.effects[effectType] then
        self.effects[effectType] = self.effects[effectType] + (effectConfig.value or damageValue)
      end
    end
  end
end

-- Clear all damages and effects
function Damages:clear()
  self.knockouts = 0
  self.damages = {}
  self.effects = {
    blackOut = 0,
    shakeAim = 0
  }
  
  localState:set("damages", self.damages, true)
end

-- Register new damage/injury
function Damages:new(boneId, weaponHash)
  if not boneId then
    return
  end
  
  local bodyPart = self:findBone(boneId)
  if not bodyPart then
    return
  end
  
  local weaponConfig = Config.Damages.weapons[weaponHash]
  if not weaponConfig then
    return
  end
  
  -- Check if damage registration should be prevented
  if Config.Damages.preventRegister then
    if Config.Damages.preventRegister(weaponHash) then
      return
    end
  end
  
  -- Initialize body part if it doesn't exist
  if not self.damages[bodyPart] then
    self.damages[bodyPart] = {
      bodyPart = bodyPart,
      injuries = {}
    }
  end
  
  local injuries = self.damages[bodyPart].injuries
  local weaponKey = tostring(weaponHash)
  
  -- Update existing injury or create new one
  if injuries[weaponKey] then
    local currentHits = injuries[weaponKey].hits + 1
    local newInjuryData = weaponConfig.injuries[currentHits]
    
    -- Check for advanced injuries
    if not newInjuryData then
      if weaponConfig.advancedInjuries and weaponConfig.advancedInjuries[bodyPart] then
        newInjuryData = weaponConfig.advancedInjuries[bodyPart][currentHits]
      end
    end
    
    if newInjuryData then
      injuries[weaponKey] = {
        hits = currentHits,
        data = newInjuryData,
        weapon = weaponHash
      }
    else
      injuries[weaponKey].hits = currentHits
    end
  else
    -- Create new injury entry
    local initialInjury = weaponConfig.injuries[1]
    
    if weaponConfig.advancedInjuries and weaponConfig.advancedInjuries[bodyPart] then
      initialInjury = weaponConfig.advancedInjuries[bodyPart][1] or initialInjury
    end
    
    injuries[weaponKey] = {
      hits = 1,
      data = initialInjury or {},
      weapon = weaponHash
    }
  end
  
  -- Play damage sound if threshold reached
  if Sounds then
    local hitCount = injuries[weaponKey] and injuries[weaponKey].hits or 0
    if hitCount >= 5 then
      Sounds:preset("damage")
    end
  end
  
  if Bridge and Bridge.Config and Bridge.Config.Debug then
    lib.print.info(injuries)
  end
  
  -- Apply visual effects
  if Config.Damages.effects.enabled then
    self:effect(bodyPart, math.random(1, 10))
  end
  
  -- Increase pulse
  if Pulse and Pulse.add then
    Pulse:add(math.random(1, 3))
  end
  
  localState:set("damages", self.damages, true)
end

-- Get the most severe injury data for a body part
function Damages:getBoneData(injuries)
  local mostSevere = nil
  
  for _, injury in pairs(injuries) do
    if injury.data and injury.data.items then
      if not mostSevere or (injury.hits > (mostSevere.hits or 0)) then
        mostSevere = lib.table.deepclone(injury.data)
        mostSevere.weapon = injury.weapon
      end
    end
  end
  
  if not mostSevere then
    return nil
  end
  
  -- Enrich item data with inventory information
  if mostSevere.items then
    for itemName, itemCount in pairs(mostSevere.items) do
      local itemData = Bridge.Inventory.getItemData(itemName)
      
      mostSevere.items[itemName] = {
        name = itemName,
        label = itemData and itemData.label or itemName,
        count = itemCount,
        image = itemData and itemData.image or nil
      }
    end
  end
  
  return mostSevere
end

-- Handle damage events
AddEventHandler("gameEventTriggered", function(eventName, eventData)
  if eventName ~= "CEventNetworkEntityDamage" then return end

  local victim = eventData[1]
  if not victim or not DoesEntityExist(victim) then return end
  if not IsPedAPlayer(victim) then return end

  local victimPlayerId = NetworkGetPlayerIndexFromPed(victim)
  if victimPlayerId ~= cache.playerId then return end
  
  local victim = eventData[1]
  local isFatal = eventData[4]
  local weaponHash = eventData[7]
  
  -- Check if victim is a player
  if not IsPedAPlayer(victim) then
    return
  end
  
  -- Check if it's the local player
  local victimPlayerId = NetworkGetPlayerIndexFromPed(victim)
  if victimPlayerId ~= cache.playerId then
    return
  end
  
  -- Don't register damage if already dead
  if Death.deathType == "death" then
    return
  end
  
  -- Get the damaged bone
  local success, boneId = GetPedLastDamageBone(victim)
  
  if success and boneId then
    Damages:new(boneId, weaponHash)
    
    -- Show blood effect
    if Config.Damages.effects.generalEffect then
      if Damages.effectTimer then
        Damages.effectTimer:forceEnd(true)
        Citizen.Wait(1)
      end
      
      SendNUIMessage({
        action = "setVisibleBlood",
        data = true
      })
      
      Damages.effectTimer = lib.timer(100, function()
        SendNUIMessage({
          action = "setVisibleBlood",
          data = false
        })
      end, true)
    end
  end
end)

-- Open healing menu for a target player
function Damages:openMenu(targetServerId)
  if self.antiSpam > GetGameTimer() then
    return
  end
  
  if self.isOpened then
    return
  end
  
  local targetPed = GetPlayerPed(GetPlayerFromServerId(targetServerId))
  
  -- Validate target exists and is not self
  if not targetPed or targetPed == 0 or targetPed == cache.ped then
    return
  end
  
  -- Wait for NUI to close if focused
  if IsNuiFocused() then
    Citizen.Wait(300)
  end
  
  -- Check job permissions
  local playerJob = Bridge.Framework.fetchPlayerJob()
  
  if not playerJob or not Editable.allJobs[playerJob.name] then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  -- Update healing items
  self:getHealingItems()
  
  self.isOpened = true
  self.pulseChecked = false
  self.temperatureChecked = false
  self.targetId = targetServerId
  
  -- Load animation
  local animDict = lib.requestAnimDict("amb@medic@standing@tendtodead@base")
  
  -- Setup camera
  local targetState = Player(targetServerId).state
  local cameraOffset
  
  if targetState.isDead then
    cameraOffset = GetOffsetFromEntityInWorldCoords(targetPed, 0.1, 0.05, 1.5)
  else
    cameraOffset = GetOffsetFromEntityInWorldCoords(targetPed, 0.0, 2.65, 0.4)
  end
  
  self.camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
  SetCamCoord(self.camera, cameraOffset)
  SetCamFov(self.camera, 42.0)
  PointCamAtEntity(self.camera, targetPed, 0.0, 0.0, 0.0, true)
  SetCamActive(self.camera, true)
  RenderScriptCams(true, true, 1000, true, true)
  
  -- Open UI
  SetNuiFocus(true, true)
  SendNUIMessage({
    action = "setVisibleHealing",
    data = true
  })
  
  -- Play medic animation
  TaskPlayAnim(cache.ped, animDict, "base", 8.0, -8.0, -1, 1, 0, false, false, false)
  
  -- Get target damages
  local targetDamages = Player(targetServerId).state.damages or {}
  local damageCount = 0
  
  for _ in pairs(targetDamages) do
    damageCount = damageCount + 1
  end
  
  -- Auto-resolve alert if enabled
  if Config.Alerts and Config.Alerts.enabled and Config.Alerts.autoResolveAlert then
    exports.p_ambulancejob:resolvePlayerAlert(targetServerId)
  end
  
  -- Check if no injuries and patient is dead - perform CPR
  if damageCount < 1 then
    if targetState.isDead then
      self.isOpened = false
      TriggerServerEvent("p_ambulancejob/server/damages/performCPR", targetServerId)
      return
    end
  end
  
  -- Inform and freeze target if enabled
  if Config.Damages.informAndFreeze then
    TriggerServerEvent("p_ambulancejob/server/damages/treatedPlayer", {
      player = targetServerId,
      state = true
    })
  end
  
  local previousInjuries = {}
  local currentInjuries = {}
  
  -- Main menu loop - continuously update injury display
  while self.isOpened do
    local refreshRate = Config.Damages.refreshRate or 500
    Citizen.Wait(refreshRate)
    
    local bonesData = {}
    currentInjuries = {}
    
    -- Refresh target state
    local targetPlayer = Player(targetServerId)
    targetDamages = targetPlayer.state.damages
    
    -- Process each bone/body part
    for bodyPartName, boneHash in pairs(self.bones) do
      local boneIndex = GetPedBoneIndex(targetPed, boneHash)
      
      if boneIndex and boneIndex ~= -1 then
        local boneWorldPos = GetWorldPositionOfEntityBone(targetPed, boneIndex)
        local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(boneWorldPos.x, boneWorldPos.y, boneWorldPos.z)
        
        local resolutionX = Damages.resolution.x
        local resolutionY = Damages.resolution.y
        
        -- Get injury data for this body part
        local injuryData = nil
        if targetDamages[bodyPartName] then
          injuryData = self:getBoneData(targetDamages[bodyPartName].injuries or {})
        end
        
        -- Add to injury list if there's damage
        if injuryData then
          table.insert(currentInjuries, {
            bone = bodyPartName,
            boneLabel = locale(bodyPartName) or bodyPartName,
            weapon = injuryData.weapon or "unknown",
            items = injuryData.items or {},
            label = injuryData.label or bodyPartName,
            color = injuryData.color or "red"
          })
        end
        
        -- Calculate screen position
        local screenPosX = onScreen and (screenX * resolutionX) or 0
        local screenPosY = onScreen and (screenY * resolutionY) or 0
        
        bonesData[bodyPartName] = {
          injury = injuryData,
          position = {
            x = screenPosX,
            y = screenPosY
          }
        }
      end
    end
    
    if Bridge and Bridge.Config and Bridge.Config.Debug then
      lib.print.info("[Damages] Sending player bones:", bonesData)
    end
    
    -- Update bone positions in UI
    SendNUIMessage({
      action = "setPlayerBones",
      data = bonesData or {}
    })
    
    -- Update injury list if changed
    if not lib.table.matches(previousInjuries, currentInjuries) then
      previousInjuries = currentInjuries
      
      if Bridge and Bridge.Config and Bridge.Config.Debug then
        lib.print.info("[Damages] Sending player injuries:", previousInjuries)
      end
      
      SendNUIMessage({
        action = "setPlayerInjuries",
        data = previousInjuries or {}
      })
    end
    
    if Bridge and Bridge.Config and Bridge.Config.Debug then
      lib.print.info("Sending player pulse and temperature")
    end
    
    -- Update vital signs
    SendNUIMessage({
      action = "setPlayerData",
      data = {
        pulse = self.pulseChecked and targetPlayer.state.pulse or nil,
        temperature = self.temperatureChecked and targetPlayer.state.temperature or nil
      }
    })
  end
end

Damages.menu = Damages.openMenu

-- Handle being treated notification
RegisterNetEvent("p_ambulancejob/client/damages/setBeingHealed", function(isFrozen)
  FreezeEntityPosition(cache.ped, isFrozen)
  
  if isFrozen then
    Bridge.Notify.showNotify(locale("you_are_being_treated"), "inform")
  end
end)

-- Close healing menu
function Damages:close()
  self.antiSpam = GetGameTimer() + 1500
  
  -- Destroy camera
  if self.camera and DoesCamExist(self.camera) then
    RenderScriptCams(false, true, 1000, true, true)
    DestroyCam(self.camera, false)
    self.camera = nil
  end
  
  -- Unfreeze target
  if Config.Damages.informAndFreeze then
    TriggerServerEvent("p_ambulancejob/server/damages/treatedPlayer", {
      player = self.targetId,
      state = false
    })
  end
  
  SetNuiFocus(false, false)
  SendNUIMessage({
    action = "setVisibleHealing",
    data = false
  })
  
  ClearPedTasks(cache.ped)
  self.isOpened = false
end

-- NUI callback to heal a specific injury
RegisterNUICallback("damages/healBone", function(data, cb)
  if not data or not data.bone or not data.item then
    cb(false)
    return
  end
  
  local targetState = Player(Damages.targetId).state
  local criticalPulse = targetState.criticalPulse
  local criticalTemperature = targetState.criticalTemperature
  
  -- Check if pulse/temperature needs stabilization first
  if (criticalPulse or criticalTemperature) and data.bone ~= "mouth" then
    Bridge.Notify.showNotify(locale("stabilize_player_pulse_or_temperature"), "error")
    cb(false)
    return
  end
  
  -- Request server to process healing
  local success = lib.callback.await("p_ambulancejob/server/damages/healBone", false, Damages.targetId, data)
  
  if success then
    if Sounds then
      -- Play healing animation if advanced healing is enabled
      if Config.Damages.advancedHealing then
        local itemData = Bridge.Inventory.getItemData(data.item)
        local animVariations = {"idle_a", "idle_b", "idle_c"}
        
        local progressSuccess = Bridge.Progress.Start({
          duration = 5000,
          label = locale("using_item", itemData and itemData.label or ""),
          canCancel = false,
          anim = {
            dict = "amb@medic@standing@tendtodead@idle_a",
            clip = animVariations[math.random(1, 3)]
          },
          disable = {
            move = false,
            combat = true,
            mouse = false,
            car = true
          }
        })
        
        if progressSuccess then
          TaskPlayAnim(cache.ped, "amb@medic@standing@tendtodead@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
        end
      end
      
      Sounds:preset("heal")
    end
  end
  
  cb(success)
end)

-- NUI callback to check pulse
RegisterNUICallback("damages/checkPulse", function()
  if Damages.antiSpam > GetGameTimer() then
    return
  end
  
  Damages.antiSpam = GetGameTimer() + 5000
  
  local success = Bridge.Progress.StartCircle({
    duration = 5000,
    label = locale("checking_pulse"),
    position = "bottom"
  })
  
  if success then
    Damages.pulseChecked = true
  end
end)

-- NUI callback to check temperature
RegisterNUICallback("damages/checkTemperature", function()
  if Damages.antiSpam > GetGameTimer() then
    return
  end
  
  Damages.antiSpam = GetGameTimer() + 5000
  
  local success = Bridge.Progress.StartCircle({
    duration = 5000,
    label = locale("checking_temperature"),
    position = "bottom"
  })
  
  if success then
    Damages.temperatureChecked = true
  end
end)

-- NUI callback to hide frame
RegisterNUICallback("hideFrame", function(data)
  if data.name == "setVisibleHealing" then
    Damages:close()
  end
end)

-- CPR/Revive animation clips
Damages.reviveClips = {
  {"cpr_def", "cpr_intro", 14000},
  {"cpr_str", "cpr_pumpchest", 10000},
  {"cpr_str", "cpr_success", 33000}
}

-- Play CPR/revive animation
function Damages:playRevive(reviveData)
  if not Config.Damages.reviveAnimation then
    if reviveData.isRevived then
      TriggerEvent("p_ambulancejob/client/death/revive")
      Citizen.Wait(500)
      self.activeCPR = false
    else
      self.activeCPR = false
    end
    return
  end
  
  self.activeCPR = true
  
  -- Determine medic and patient peds
  local medicPed, patientPed
  if reviveData.isRevived then
    medicPed = GetPlayerPed(GetPlayerFromServerId(reviveData.targetId))
    patientPed = cache.ped
  else
    medicPed = cache.ped
    patientPed = GetPlayerPed(GetPlayerFromServerId(reviveData.targetId))
  end
  
  -- Position medic next to patient
  local patientOffset = GetOffsetFromEntityInWorldCoords(medicPed, 0.0, 0.8, 0.0)
  SetEntityCoordsNoOffset(patientPed, patientOffset.x, patientOffset.y, patientOffset.z, true, true, true)
  SetEntityHeading(patientPed, GetEntityHeading(medicPed) + 90.0)
  
  Citizen.Wait(100)
  
  -- Load animation dictionaries
  local defAnimDict = lib.requestAnimDict(reviveData.isRevived and "mini@cpr@char_b@cpr_def" or "mini@cpr@char_a@cpr_def")
  local strAnimDict = lib.requestAnimDict(reviveData.isRevived and "mini@cpr@char_b@cpr_str" or "mini@cpr@char_a@cpr_str")
  
  -- Play animation sequence
  for i = 1, #self.reviveClips do
    local clip = self.reviveClips[i]
    local animDict = clip[1] == "cpr_def" and defAnimDict or strAnimDict
    
    TaskPlayAnim(cache.ped, animDict, clip[2], 8.0, -8.0, clip[3], 1, 0, false, false, false)
    
    if i == 3 then
      self:close()
    end
    
    local waitTime = i == 3 and (clip[3] - 3000) or clip[3]
    Citizen.Wait(waitTime)
  end
  
  RemoveAnimDict(defAnimDict)
  RemoveAnimDict(strAnimDict)
  
  if reviveData.isRevived then
    TriggerEvent("p_ambulancejob/client/death/revive")
    Citizen.Wait(500)
    self.activeCPR = false
  else
    self.activeCPR = false
  end
end

-- Network event to play revive animation
RegisterNetEvent("p_ambulancejob/client/damages/playRevive", function(reviveData)
  Damages:playRevive(reviveData)
end)

-- Network event to clear animations
RegisterNetEvent("p_ambulancejob/client/damages/clearAnim", function()
  ClearPedTasks(cache.ped)
end)

-- Toggle damage UI display
function Damages:damagesUI()
  if not Config.Damages.enabled or not Config.Damages.damagesUI then
    return
  end
  
  self.damagesUiState = not self.damagesUiState
  
  if not self.damagesUiState then
    SendNUIMessage({
      action = "setVisibleBody",
      data = false
    })
    return
  end
  
  local damagesList = {}
  
  for bodyPart, bodyPartData in pairs(self.damages) do
    local hasInjuries = false
    
    for _ in pairs(bodyPartData.injuries) do
      hasInjuries = true
      break
    end
    
    table.insert(damagesList, {
      part = bodyPart,
      damage = hasInjuries and 1 or 0
    })
  end
  
  SendNUIMessage({
    action = "setVisibleBody",
    data = true
  })
  
  SendNUIMessage({
    action = "setBodyDamages",
    data = damagesList
  })
end

-- Apply weapon damage modifiers
function Damages:applyModifiers()
  for weaponHash, modifier in pairs(Config.Damages.modifiers) do
    SetWeaponDamageModifier(weaponHash, modifier)
  end
end

-- Wait for config to load
while not Config or not Config.Damages do
  Citizen.Wait(100)
end

-- Setup damage UI keybind if enabled
if Config.Damages.damagesUI and Config.Damages.damagesUIKey then
  lib.addKeybind({
    name = "damagesUI",
    description = locale("check_your_body_damages"),
    defaultKey = Config.Damages.damagesUIKey,
    onPressed = function()
      Damages:damagesUI()
    end
  })
end

-- Apply damage modifiers on startup
Citizen.CreateThread(function()
  Damages:applyModifiers()
end)