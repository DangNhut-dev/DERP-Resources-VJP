-- =====================================================
--  p_ambulancejob - death.lua (FINAL FIX)
-- =====================================================

Death = {}
-- local _SetEntityHealth = SetEntityHealth
-- function SetEntityHealth(ped, health, ...)
--   if ped == PlayerPedId() then
--     print(('[HP-DEBUG] set=%s cur=%s deathType=%s time=%s\n%s')
--       :format(health, GetEntityHealth(ped), Death and Death.deathType or '?', GetGameTimer(), debug.traceback()))
--   end
--   return _SetEntityHealth(ped, health, ...)
-- end
Death._index = Death
Death.deathType = "none"
Death.isCrawling = false
Death.antiSpam = GetGameTimer()
Death.antiSpamAlert = GetGameTimer()
Death.inVehicle = false
Death.pauseLoop = false
Death.preventedBleedingAnim = false
Death.processingDeath = false
Death.processingDeathUntil = 0
Death.initVersion = 0
Death.recoveryHealth = 110
Death.isBeingRevived = false

lib.onCache("ped", function()
  SetPlayerHealthRechargeMultiplier(cache.playerId, 0.0)
end)

lib.onCache("vehicle", function()
  if Death.deathType ~= "none" then
    Death.pauseLoop = true
    Citizen.Wait(10)
    ClearPedTasks(cache.ped)
    
    SetTimeout(1000, function()
      Death.pauseLoop = false
    end)
  end
  
  Death.inVehicle = cache.vehicle and cache.vehicle ~= 0
end)

function Death:isAnimal()
  local modelHash = joaat(GetEntityModel(cache.ped))
  
  if Config.Death.animals.enabled then
    local animalAnim = Config.Death.animals.anims[modelHash]
    if animalAnim then
      return animalAnim
    end
  end
  
  return nil
end

function Death:init()
  self.initVersion = (self.initVersion or 0) + 1
  local myVersion = self.initVersion
  
  local stageType = self.deathType == "none" and "alive" or self.deathType
  local stageConfig = Config.Death.stages[stageType]
  
  if stageConfig and stageConfig.onInit then
    stageConfig.onInit()
  end

  -- Toan bo logic co Wait chay trong thread rieng
  Citizen.CreateThread(function()
    local bleedingAnim = nil

    SetPedCombatMovement(cache.ped, 0)
    Citizen.Wait(1000)
    if self.initVersion ~= myVersion then return end
    
    if IsEntityOnFire(cache.ped) then
      while IsEntityOnFire(cache.ped) and self.initVersion == myVersion do
        Citizen.Wait(100)
      end
      if self.initVersion ~= myVersion then return end
      Citizen.Wait(500)
      ClearPedTasks(cache.ped)
    end
    
    self.preventedBleedingAnim = false
    
    local previousVehicle = cache.vehicle
    local previousSeat = cache.seat
    local movementTimeout = GetGameTimer() + 5000
    
    while self.deathType ~= "none" and self.initVersion == myVersion do
      local playerSpeed = GetEntitySpeed(cache.ped)
      if playerSpeed <= 1.25 and not IsPedInAnyVehicle(cache.ped, false) then break end
      Citizen.Wait(100)
      if GetGameTimer() > movementTimeout then break end
    end
    
    if self.initVersion ~= myVersion then return end
    
    self.antiSpamAlert = GetGameTimer()
    
    if self.deathType == "none" and self.wasRecovering then
      local animDict = lib.requestAnimDict("get_up@directional@movement@from_knees@injured")
      TaskPlayAnim(cache.ped, animDict, "getup_l_0", -8.0, 8.0, 2000, 1, 0.0)
      RemoveAnimDict(animDict)
      Citizen.Wait(2000)
      ClearPedTasks(cache.ped)
      if Config.Death.commands.revive.clientFunction then
        Config.Death.commands.revive.clientFunction()
      end
      self.wasRecovering = false
      SetTimeout(1500, function()
        FreezeEntityPosition(cache.ped, false)
        SetEntityHealth(cache.ped, self.recoveryHealth or 150)
      end)
    else
      ClearPedTasks(cache.ped)
      local wasInVehicle = IsPedInAnyVehicle(cache.ped, false)
      if wasInVehicle and previousVehicle and previousVehicle ~= 0 then
        SetEntityHealth(cache.ped, GetEntityMaxHealth(cache.ped))
        SetPedArmour(cache.ped, GetPedArmour(cache.ped))
      else
        Utils:resurrectPlayer()
        self.inVehicle = IsPedInAnyVehicle(PlayerPedId(), false)
        if previousVehicle and previousVehicle ~= 0 then
          Citizen.Wait(100)
          TaskWarpPedIntoVehicle(cache.ped, previousVehicle, previousSeat)
        end
      end
    end
    
    if self.initVersion ~= myVersion then return end

    -- Bleeding prevention thread
    -- Bleeding prevention thread
    Citizen.CreateThread(function()
      while self.deathType == "bleeding" and self.initVersion == myVersion do
        local ok, err = pcall(function()
          local preventFunc = Config.Death.stages.bleeding.preventAnimation
          self.preventedBleedingAnim = preventFunc and preventFunc() or false
        end)
        if not ok then print('[DEATH] bleed prevent error: ' .. tostring(err)) end
        Citizen.Wait(1000)
      end
    end)

    local wasBeingCarried = false
    local forceReplay = false

    while self.deathType ~= "none" and self.initVersion == myVersion do
      local ped = PlayerPedId()
      
      if ped and ped ~= 0 and DoesEntityExist(ped) then
        DisableAllControlActions(0)
        DisableAllControlActions(1)
        
        if Config.Death.enabledKeys then
          for _, key in pairs(Config.Death.enabledKeys) do
            EnableControlAction(0, key, true)
            EnableControlAction(1, key, true)
          end
        end

        if self.deathType == "death" then
          SetEntityInvincible(ped, true)
        else
          SetEntityInvincible(ped, false)
        end

        local isBeingCarried = Interactions and Interactions.activeCarry and Interactions.carryRole == 'carried'

        if not isBeingCarried and wasBeingCarried then
          forceReplay = true
          ClearPedTasks(ped)
        end
        wasBeingCarried = isBeingCarried

        if self.deathType == "death" then
          local deathAnim = self.animalAnim
          if not deathAnim then
            local stageKey = self.inVehicle and "vehicle" or self.deathType
            local stage = Config.Death.stages[stageKey]
            deathAnim = stage and stage.anim or nil
          end
          if deathAnim and not self.pauseLoop and not (Damages and Damages.activeCPR) and not isBeingCarried then
            if forceReplay or not IsEntityPlayingAnim(ped, deathAnim.dict, deathAnim.clip, 3) then
              lib.requestAnimDict(deathAnim.dict)
              TaskPlayAnim(ped, deathAnim.dict, deathAnim.clip, -8.0, 8.0, -1, deathAnim.flag or 1, 1.0)
              forceReplay = false
            end
          end
          if IsDisabledControlPressed(0, 47) and self.antiSpamAlert < GetGameTimer() then
            self.antiSpamAlert = GetGameTimer() + 30000
            Citizen.CreateThread(function() Config.Death.stages.death.alert() end)
            Bridge.Notify.showNotify(locale("death_alert_sent"), "success")
          end

        elseif self.deathType == "bleeding" then
          local animChanged = forceReplay
          
          if Config.Death.stages.bleeding.enableAlert and IsDisabledControlPressed(0, 47) and self.antiSpamAlert < GetGameTimer() then
            self.antiSpamAlert = GetGameTimer() + 30000
            Citizen.CreateThread(function() Config.Death.stages.death.alert() end)
            Bridge.Notify.showNotify(locale("death_alert_sent"), "success")
          end
          
          local cuffOk, cuffVal = pcall(function() return exports.qbx_police:IsHandcuffed() end)
          local isCuffed = cuffOk and cuffVal == true
          
          if not self.inVehicle and Config.Death.stages.bleeding.movement and not self.preventedBleedingAnim and not isCuffed and not self.isBeingRevived then
            if IsDisabledControlPressed(0, 32) then
              if self.antiSpam < GetGameTimer() and not self.isCrawling then
                animChanged = true; self.isCrawling = true; self.antiSpam = GetGameTimer() + 1000
              end
            elseif IsDisabledControlPressed(0, 33) then
              if self.antiSpam < GetGameTimer() and self.isCrawling then
                animChanged = true; self.isCrawling = false; self.antiSpam = GetGameTimer() + 1000
              end
            elseif IsDisabledControlPressed(0, 34) or IsDisabledControlPressed(0, 35) then
              SetEntityHeading(ped, GetEntityHeading(ped) + (IsDisabledControlPressed(0, 34) and 0.5 or -0.5))
            end
          end
          
          if self.isCrawling and self.preventedBleedingAnim then self.isCrawling = false; animChanged = true end
          
          if not bleedingAnim then
            local animList = Config.Death.stages.bleeding.anims
            if animList and #animList > 0 then
              bleedingAnim = animList[math.random(1, #animList)]
              if bleedingAnim then lib.requestAnimDict(bleedingAnim.dict) end
            end
          end
          
          if self.inVehicle then
            local vehicleAnim = Config.Death.stages.vehicle and Config.Death.stages.vehicle.anim
            if not self.pauseLoop and vehicleAnim and not (Damages and Damages.activeCPR) and not isBeingCarried then
              if animChanged or not IsEntityPlayingAnim(ped, vehicleAnim.dict, vehicleAnim.clip, 3) then
                lib.requestAnimDict(vehicleAnim.dict)
                TaskPlayAnim(ped, vehicleAnim.dict, vehicleAnim.clip, -8.0, 8.0, -1, vehicleAnim.flag or 1, 1.0)
                forceReplay = false
              end
            end
          else
            if isBeingCarried then
              -- skip
            elseif isCuffed then
              if not IsEntityPlayingAnim(ped, 'dead', 'dead_a', 3) then
                lib.requestAnimDict('dead')
                local coords = GetEntityCoords(ped)
                local heading = GetEntityHeading(ped)
                TaskPlayAnimAdvanced(ped, 'dead', 'dead_a', coords.x, coords.y, coords.z, 1.0, 0.0, heading, 8.0, 1.0, 1.0, 1, 1.0, 0, 0)
                forceReplay = false
              end
            elseif self.preventedBleedingAnim then
              local preventAnim = Config.Death.stages.bleeding.animWhilePrevented
              if type(self.preventedBleedingAnim) ~= "string" and preventAnim and not (Damages and Damages.activeCPR) then
                if not IsEntityPlayingAnim(ped, preventAnim.dict, preventAnim.clip, 3) or animChanged then
                  lib.requestAnimDict(preventAnim.dict)
                  TaskPlayAnim(ped, preventAnim.dict, preventAnim.clip, -8.0, 8.0, -1, preventAnim.flag or 1, 1.0)
                  forceReplay = false
                end
              end
            elseif not (Damages and Damages.activeCPR) and bleedingAnim then
              if not IsEntityPlayingAnim(ped, bleedingAnim.dict, bleedingAnim.clip, 3) or animChanged then
                -- forceReplay bypass IsEntityAttached check
                if forceReplay or (not self.preventedBleedingAnim and not IsEntityAttached(ped)) then
                  local coords = GetEntityCoords(ped)
                  local heading = GetEntityHeading(ped)
                  TaskPlayAnimAdvanced(ped, bleedingAnim.dict, bleedingAnim.clip, coords.x, coords.y, coords.z, 1.0, 0.0, heading, 8.0, 1.0, 1.0, self.isCrawling and 47 or 46, 1.0, 0, 0)
                  forceReplay = false
                end
              end
            end
          end

        elseif self.deathType == "recovering" then
          local stageKey = self.inVehicle and "vehicle" or self.deathType
          local recoveryAnim = Config.Death.stages[stageKey] and Config.Death.stages[stageKey].anim
          if recoveryAnim and not (Damages and Damages.activeCPR) and not isBeingCarried then
            if forceReplay or not IsEntityPlayingAnim(ped, recoveryAnim.dict, recoveryAnim.name, 3) then
              lib.requestAnimDict(recoveryAnim.dict)
              TaskPlayAnim(ped, recoveryAnim.dict, recoveryAnim.clip, -8.0, 8.0, -1, recoveryAnim.flag or 1, 1.0)
              forceReplay = false
            end
          end
        end
      end
      
      Citizen.Wait(1)
    end
    
    if bleedingAnim then RemoveAnimDict(bleedingAnim.dict) end
    SetEntityInvincible(cache.ped, false)
  end)
end

function Death:setState(stateData, damageInfo)
  if not stateData or type(stateData) ~= "table" or not stateData.type then
    return
  end
  
  if stateData.state and stateData.type == self.deathType then
    return
  end
  
  if stateData.type == "bleeding" and not Config.Death.stages.bleeding.enabled then
    stateData.type = "death"
  end
  
  local previousDeathType = self.deathType
  self.deathType = "none"
  
  if previousDeathType ~= "none" and not stateData.state then
    ClearPedTasksImmediately(cache.ped)
    ClearPedSecondaryTask(cache.ped)
    StopAnimTask(cache.ped, "dead", "dead_a", 3.0)
    StopAnimTask(cache.ped, "combat@damage@rb_writhe", "rb_writhe_loop", 3.0)
    ResetPedMovementClipset(cache.ped, 0)
  end
  
  local animalAnim = self:isAnimal()
  
  if animalAnim then
    self.deathType = stateData.state and "death" or "none"
    self.animalAnim = animalAnim
  else
    self.animalAnim = nil
    self.deathType = stateData.state and stateData.type or "none"
  end
  
  if self.deathType ~= "none" then
    localState:set("isDead", true, true)
    localState:set("dead", true, true)
    localState:set("deathType", self.deathType, true)
    
    local deathTime = stateData.time
    if not deathTime then
      local stageConfig = Config.Death.stages[stateData.type]
      deathTime = stageConfig and stageConfig.time or 0
    end
    
    DeathScreen:setVisibility({
      state = true,
      time = deathTime,
      type = self.deathType,
      weapon = damageInfo and damageInfo.weaponLabel or nil
    })
  else
    CheckIn.AiMedicActive = false
    
    if Bleeding and Bleeding.clear then
      Bleeding:clear()
    end
    
    SetEntityInvincible(cache.ped, false)
    
    DeathScreen:setVisibility({ state = false })
    localState:set("isDead", false, true)
    localState:set("dead", false, true)
    localState:set("deathType", self.deathType, true)
  end
  
  self.inVehicle = cache.vehicle and cache.vehicle ~= 0 or false
  self:init()

  TriggerEvent("p_ambulancejob/onDeathStateChange", self.deathType, damageInfo)
  TriggerServerEvent("p_ambulancejob/onDeathStateChange", self.deathType, damageInfo)
  
  self.wasRecovering = stateData.type == "recovering"

  if self.deathType == "bleeding" then
    local healthVersion = self.initVersion
    CreateThread(function()
      Wait(2000)
      if self.initVersion ~= healthVersion or self.deathType ~= "bleeding" then return end
      local ped = cache.ped
      local maxHp = GetEntityMaxHealth(ped)
      SetEntityHealth(ped, math.floor(100 + 0.35 * (maxHp - 100)))
    end)
  end
end

Death.setDeathState = Death.setState

exports("getDeathInfo", function()
  return {
    isDead = Death.deathType ~= "none",
    stage = Death.deathType
  }
end)

AddEventHandler("gameEventTriggered", function(eventName, eventData)
  if eventName ~= "CEventNetworkEntityDamage" then
    return
  end
 
  local victim = eventData[1]
  local attacker = eventData[2]
  local weaponHash = eventData[7]
 
  if not victim or not DoesEntityExist(victim) then return end
  if not IsPedAPlayer(victim) then return end
 
  local victimPlayerId = NetworkGetPlayerIndexFromPed(victim)
  if victimPlayerId ~= cache.playerId then return end
  if GetEntityHealth(cache.ped) > 0 then return end
  if Death.processingDeath then return end
  if GetGameTimer() < Death.processingDeathUntil then return end
  if Death.deathType == "death" then return end
 
  if Config.Death.preventDeath and Config.Death.preventDeath() then return end
 
  Death.processingDeath = true
 
  local recoveringConfig = Config.Death.stages.recovering
  local weaponLabel = nil
  local recoveryTime = nil
 
  if Death.deathType == "none" and recoveringConfig.enabled then
    local weaponConfig = recoveringConfig.weapons[weaponHash]
    if weaponConfig then
      local maxKnockouts = recoveringConfig.maxKnockoutsToDeath or 0
      if Damages.knockouts < maxKnockouts then
        weaponLabel = weaponConfig.label
        recoveryTime = weaponConfig.recoveryTime
        Death.recoveryHealth = weaponConfig.healthAfterRecover or 100
        Damages.knockouts = Damages.knockouts + 1
      end
    end
  end
 
  local attackerServerId = nil
  if attacker and attacker > 0 and DoesEntityExist(attacker) then
    local attackerPlayerId = NetworkGetPlayerIndexFromPed(attacker)
    if attackerPlayerId then
      attackerServerId = GetPlayerServerId(attackerPlayerId)
    end
  end
 
  local victimCoords = GetEntityCoords(cache.ped)
  local attackerCoords = (attackerServerId and attacker and DoesEntityExist(attacker)) and GetEntityCoords(attacker) or nil
 
  local damageInfo = {
    victimCoords = victimCoords,
    killerCoords = attackerCoords,
    distance = nil,
    killer = attackerServerId,
    cause = GetPedCauseOfDeath(cache.ped),
    weapon = weaponHash,
    weaponLabel = weaponLabel
  }
 
  if attackerServerId and attackerCoords then
    damageInfo.distance = #(victimCoords - attackerCoords)
  end
 
  Citizen.Wait(1)
 
  local deathType
  if weaponLabel then
    deathType = "recovering"
  elseif Death.deathType == "bleeding" then
    deathType = "death"
  else
    deathType = "bleeding"
  end
 
  Death:setDeathState({
    state = true,
    time = weaponLabel and recoveryTime or nil,
    type = deathType
  }, damageInfo)
 
  Death.processingDeath = false
  Death.processingDeathUntil = GetGameTimer() + 2000
end)

local killEvents = {
  "hospital:client:KillPlayer",
  "p_ambulancejob/client/death/kill",
  "qbx_admin:client:killPlayer"
}

for _, eventName in pairs(killEvents) do
  RegisterNetEvent(eventName, function()
    if Death.deathType == "death" then
      return
    end
    SetEntityHealth(cache.ped, 0)
  end)
end

local reviveEvents = {
  "esx_ambulancejob:revive",
  "hospital:client:RevivePlayer",
  "hospital:client:Revive",
  "p_ambulancejob/client/death/revive",
  "qbx_medical:client:playerRevived"
}

for _, eventName in pairs(reviveEvents) do
  RegisterNetEvent(eventName, function()
    local invokingResource = GetInvokingResource() or GetCurrentResourceName()
    
    if Config.Death.commands.revive.canUseEvent then
      if not Config.Death.commands.revive.canUseEvent(invokingResource) then
        return
      end
    end
    
    local currentArmour = GetPedArmour(cache.ped)
    local isInVehicle = IsPedInAnyVehicle(cache.ped, false)
    
    if not isInVehicle then
      ClearPedTasksImmediately(cache.ped)
    end
    ClearPedSecondaryTask(cache.ped)
    SetEntityInvincible(cache.ped, false)
    
    local maxHealth = GetEntityMaxHealth(cache.ped)
    SetEntityMaxHealth(cache.ped, maxHealth)
    SetEntityHealth(cache.ped, maxHealth)
    
    Config.Death.commands.revive.clientFunction()
    TriggerServerEvent("p_ambulancejob/server/death/reviveUtils")
    
    if Bleeding and Bleeding.clear then
      Bleeding:clear()
    end
    
    Damages:clear()
    
    if Pulse and Pulse.reset then
      Pulse:reset(true)
    end
    
    if Temperature and Temperature.reset then
      Temperature:reset(true)
    end

    Death.processingDeath = false
    
    Death:setDeathState({
      state = false,
      type = "death"
    })
    
    Citizen.Wait(3000)
    SetPedArmour(cache.ped, currentArmour)
  end)
end

RegisterNetEvent("p_ambulancejob/client/death/heal", function()
  local invokingResource = GetInvokingResource() or GetCurrentResourceName()
  
  if Config.Death.commands.heal.canUseEvent then
    if not Config.Death.commands.heal.canUseEvent(invokingResource) then
      return
    end
  end
  
  local maxHealth = GetEntityMaxHealth(cache.ped)
  SetEntityHealth(cache.ped, maxHealth)
  
  if Config.Death.commands.heal.clientFunction then
    Config.Death.commands.heal.clientFunction()
  end
  
  TriggerServerEvent("p_ambulancejob/server/death/healUtils")
  
  if Bleeding and Bleeding.clear then
    Bleeding:clear()
  end
  
  Damages:clear()
  
  if Pulse and Pulse.reset then
    Pulse:reset(true)
  end
  
  if Temperature and Temperature.reset then
    Temperature:reset(true)
  end
end)

AddStateBagChangeHandler("ambulanceData", nil, function(bagName, key, value, reserved, replicated)
  if replicated then return end
  
  local player = GetPlayerFromStateBagName(bagName)
  if player == 0 then return end
  
  local playerServerId = GetPlayerServerId(player)
  if playerServerId ~= cache.serverId then return end
  if not value then return end
  
  if not value.health then
    value.health = 200
  end
  
  if value.health < 1 then
    while not Death do
      Citizen.Wait(1000)
    end
    
    Death:setDeathState({
      state = true,
      type = value.type or "death"
    })
  else
    if Config.Death.spawnFullHealthIfAlive then
      value.health = GetEntityMaxHealth(PlayerPedId())
    end
    
    SetEntityHealth(PlayerPedId(), value.health or GetEntityMaxHealth(PlayerPedId()))
    SetPedArmour(PlayerPedId(), value.armour or 0)
  end
end)

Citizen.CreateThread(function()
  local inventoryState = GetResourceState("ox_inventory")
  if inventoryState == "missing" then return end
  
  while GetResourceState("ox_inventory") ~= "started" do
    Citizen.Wait(1000)
  end
  
  exports.ox_inventory:displayMetadata("bloodType", locale("blood_type"))
end)

Citizen.CreateThread(function()
  Wait(2000)
  
  if localState.isDead or localState.deathType and localState.deathType ~= "none" then
    local deathType = localState.deathType or "death"
    
    Death.deathType = deathType
    localState:set("isDead", true, true)
    localState:set("dead", true, true)
    localState:set("deathType", deathType, true)
    
    local stageConfig = Config.Death.stages[deathType]
    local deathTime = stageConfig and stageConfig.time or 0
    
    DeathScreen:setVisibility({
      state = true,
      time = deathTime,
      type = deathType,
      weapon = nil
    })
    
    Death:init()
  end
end)

Citizen.CreateThread(function()
  while not Config or not Config.Death do
    Citizen.Wait(100)
  end
  
  if not Config.Death.targetRevive or not Config.Death.targetRevive.enabled then
    return
  end
  
  Bridge.Target.addPlayer({
    {
      name = "p_ambulancejob/revive/target",
      icon = "fa-solid fa-heart-pulse",
      label = locale("revive_player"),
      distance = 3.0,
      onSelect = function(data)
        local targetEntity = type(data) == "number" and data or data.entity
        local targetServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetEntity))
        Config.Death.targetRevive.onStart(targetServerId)
      end,
      canInteract = function(entity)
        local targetServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
        local targetPlayer = Player(targetServerId)
        local deathType = targetPlayer.state.deathType
        return Config.Death.targetRevive.allowedDeathStage[deathType]
      end
    }
  })
end)

-- Citizen.CreateThread(function()
--   while true do
--     Citizen.Wait(3000)
--     if Death.deathType == "bleeding" and not Death.inVehicle and not Death.pauseLoop then
--       local ped = PlayerPedId()
--       if ped and ped ~= 0 and DoesEntityExist(ped) and not IsPedRagdoll(ped) then
--         local isCPR = Damages and Damages.activeCPR
--         local isCarried = Interactions and Interactions.activeCarry and Interactions.carryRole == 'carried'
        
--         if not isCPR and not isCarried then
--           local animList = Config.Death.stages.bleeding.anims
--           if animList and #animList > 0 then
--             local anim = animList[1]
--             local isPlaying = IsEntityPlayingAnim(ped, anim.dict, anim.clip, 3)
--             print(('[SAFETY] ped=%s playing=%s dict=%s clip=%s'):format(ped, tostring(isPlaying), anim.dict, anim.clip))
            
--             if not isPlaying then
--               print('[SAFETY] ^1FORCE PLAY^7')
--               lib.requestAnimDict(anim.dict)
--               TaskPlayAnim(ped, anim.dict, anim.clip, 8.0, -8.0, -1, 1, 0, false, false, false)
--             end
--           end
--         end
--       end
--     end
--   end
-- end)