-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================


-- Wait for Config to be loaded
while not (Config and Config.Bleeding) do
  Wait(100)
end

-- Exit early if bleeding system is disabled
if not Config.Bleeding.enabled then
  return
end

-- Test function (debugging remnant)
function test()
  local schools = GlobalState["p_dmvschool/Schools"]
  if schools and schools[k] then
    return schools[k].theoryQuestions
  end
end

-- Initialize Bleeding module
Bleeding = {
  initialized = false,
  currentValue = 0
}


-- Export: Get current bleeding value
exports("getBleedingValue", function()
  return Bleeding.currentValue or 0
end)

-- Export: Stop all bleeding
exports("stopBleeding", function()
  Bleeding:clear()
end)

-- Export: Add bleeding value
exports("addBleeding", function(amount)
  Bleeding.currentValue = math.min(Config.Bleeding.maxValue, Bleeding.currentValue + amount)
  Bleeding:init()
end)

-- Export: Remove bleeding value
exports("removeBleeding", function(amount)
  Bleeding.currentValue = math.max(0, Bleeding.currentValue - amount)
  Bleeding:init()
end)


-- Event: Use medical item to stop bleeding or heal
RegisterNetEvent("p_ambulancejob/bleeding/client/useItem", function(itemName, itemConfig)
  -- Check if item should be used (has bleeding or heals health)
  if Bleeding.currentValue < 1 and not itemConfig.health then
    return
  end

  -- Get item data for display
  local itemData = Bridge.Inventory.getItemData(itemName)
  local itemLabel = (itemData and itemData.label) or ""

  -- Show progress bar
  local success = Bridge.Progress.Start({
    duration = itemConfig.duration,
    label = locale("using_item", itemLabel),
    canCancel = true,
    anim = itemConfig.anim,
    disable = Config.Bleeding.disabledControlsWhileUsing or {
      move = false,
      combat = true,
      mouse = false,
      car = true
    }
  })

  if not success then
    return
  end

  -- Handle bleeding reduction
  if Config.Bleeding.enabled and Bleeding.currentValue > 0 then
    -- Remove item from inventory
    TriggerServerEvent("p_bridge/server/removeItem", itemName, 1)

    -- Reduce bleeding
    Bleeding.currentValue = math.max(0, Bleeding.currentValue - itemConfig.value)

    -- Notify player
    if Bleeding.currentValue < 1 then
      Bleeding:clear()
      Bridge.Notify.showNotify(locale("you_stopped_bleeding"), "success")
    else
      Bridge.Notify.showNotify(locale("you_stopped_bleeding_a_little"), "success")
    end
  else
    -- Heal player health
    local newHealth = math.min(200, GetEntityHealth(cache.ped) + (itemConfig.health or 0))
    SetEntityHealth(cache.ped, newHealth)
    TriggerServerEvent("p_bridge/server/removeItem", itemName, 1)
  end
end)


-- Clears bleeding state and resets player
function Bleeding.clear(self)
  self.initialized = false
  self.currentValue = 0

  -- Reset walk animation
  if Config.Bleeding.walkType then
    ResetPedMovementClipset(cache.ped, 1.0)
  end

  -- Trigger custom clear callback
  Config.Bleeding.onClear()
end

-- Creates blood particle effect
function Bleeding.particle(self)
  lib.requestNamedPtfxAsset("core")
  UseParticleFxAssetNextCall("core")

  local particleId = StartParticleFxNonLoopedOnEntity(
    "blood_stab",
    cache.ped,
    0.0, 0.0, 0.0,  -- offset
    0.0, 0.0, 0.0,  -- rotation
    1.0, 1.0, 1.0   -- scale
  )

  -- Remove particle after 3 seconds
  SetTimeout(3000, function()
    RemoveParticleFx(particleId, false)
  end)
end

-- Shows screen bleeding effect (flash)
function Bleeding.effect(self)
  Citizen.CreateThread(function()
    -- Show effect
    SendNUIMessage({
      action = "setVisibleBleeding",
      data = true
    })

    Wait(1000)

    -- Hide effect
    SendNUIMessage({
      action = "setVisibleBleeding",
      data = false
    })
  end)
end

-- Initializes bleeding system when player starts bleeding
function Bleeding.init(self)
  Citizen.CreateThread(function()
    -- Check if damage registration should be prevented
    if Config.Damages.preventRegister then
      if Config.Damages.preventRegister() then
        return
      end
    end

    -- Exit if already initialized or bleeding value too low
    if self.initialized or self.currentValue < 2 then
      return
    end

    -- Trigger custom init callback
    Config.Bleeding.onInit()

    -- Setup walk animation
    local walkAnimSet = nil
    if Config.Bleeding.walkType then
      walkAnimSet = lib.requestAnimSet(Config.Bleeding.walkType)
      SetPedMovementClipset(cache.ped, walkAnimSet, 1000)
    end

    -- Thread to maintain walk animation
    Citizen.CreateThread(function()
      while self.currentValue > 0 do
        Wait(500)

        -- Clear bleeding if player dies
        if LocalPlayer.state.isDead then
          self:clear()
          break
        end

        -- Reapply walk animation if changed
        if Config.Bleeding.walkType then
          local currentClipset = GetPedMovementClipset(cache.ped)
          if self.currentValue > 0 and currentClipset ~= walkAnimSet then
            SetPedMovementClipset(cache.ped, walkAnimSet, 1000)
          end
        end
      end
    end)

    self.initialized = true

    -- Main bleeding loop
    while self.currentValue > 0 do
      -- Calculate health damage based on bleeding value
      local healthDamage = math.floor(GetEntityHealth(cache.ped) - (self.currentValue / 2))
      SetEntityHealth(cache.ped, healthDamage)

      -- Notify player
      Bridge.Notify.showNotify(locale("you_are_bleeding"), "inform")

      -- Show screen effect if threshold reached
      if Config.Bleeding.screenEffect.enabled then
        if self.currentValue >= Config.Bleeding.screenEffect.requiredValue then
          self:effect()
        end
      end

      -- Show blood particle
      self:particle()

      -- Wait before next iteration
      Wait(Config.Bleeding.loopInterval)

      -- Play bleeding sound if available
      if Sounds then
        Sounds:preset("bleeding")
      end
    end

    -- Clean up
    self.initialized = false
    if walkAnimSet then
      RemoveClipSet(walkAnimSet)
    end
  end)
end


-- Handles damage events to add bleeding
AddEventHandler("gameEventTriggered", function(eventName, eventData)
  -- Only process damage events
  if eventName ~= "CEventNetworkEntityDamage" then
    return
  end

  local victim = eventData[1]
  local weaponHash = eventData[7]

  if not victim or not DoesEntityExist(victim) then return end

  -- Ensure victim is a player
  if not IsPedAPlayer(victim) then
    return
  end

  -- Ensure victim is the local player
  local victimPlayer = NetworkGetPlayerIndexFromPed(victim)
  if victimPlayer ~= cache.playerId then
    return
  end

  -- Get bleeding value for weapon
  local bleedingAmount = Config.Bleeding.weapons[weaponHash] or 0

  -- Add bleeding if weapon causes bleeding
  if bleedingAmount > 0 then
    Bleeding.currentValue = math.min(
      Config.Bleeding.maxValue,
      Bleeding.currentValue + bleedingAmount
    )
  end

  -- Initialize bleeding system
  Bleeding:init()
end)

-- First aid target: allow other players to revive a bleeding player
Citizen.CreateThread(function()
    while not Config or not Config.Bleeding do
        Wait(100)
    end

    exports.ox_target:addGlobalPlayer({
        {
            name    = "p_ambulancejob/firstAid",
            icon    = "fa-solid fa-kit-medical",
            label   = locale("first_aid") or "Sơ cứu",
            distance = 2.0,
            canInteract = function(entity)
                if entity == cache.ped then return false end
                local playerId = NetworkGetPlayerIndexFromPed(entity)
                if playerId == -1 then return false end
                local serverId = GetPlayerServerId(playerId)
                if not serverId or serverId == 0 then return false end
                return Player(serverId).state.deathType == "bleeding"
            end,
            onSelect = function(data)
              local targetPlayerId = NetworkGetPlayerIndexFromPed(data.entity)
              local targetServerId = GetPlayerServerId(targetPlayerId)
              if not targetServerId or targetServerId == 0 then return end

              local itemCount = exports.ox_inventory:Search('count', 'bandage')
              if not itemCount or itemCount < 5 then
                  lib.notify({ type = 'error', description = locale("no_bandage") or "Bạn không đủ băng gạc" })
                  return
              end

              TriggerServerEvent("p_ambulancejob/server/firstAid/lock", targetServerId)

              local success = lib.progressBar({
                  duration     = 30000,
                  label        = locale("first_aid_progress") or "Đang sơ cứu...",
                  useWhileDead = false,
                  canCancel    = true,
                  disable      = { move = true, combat = true, car = true },
                  anim         = {
                      dict = "mini@cpr@char_a@cpr_str",
                      clip = "cpr_pumpchest"
                  }
              })

              TriggerServerEvent("p_ambulancejob/server/firstAid/unlock", targetServerId)

              if not success then return end

              TriggerServerEvent("p_ambulancejob/server/firstAid", targetServerId)
          end
        }
    })
end)

-- Revive bleeding player with 15% health via Death's built-in recovery flow
RegisterNetEvent("p_ambulancejob/client/death/firstAid", function()
    if not Death then return end

    if Bleeding and Bleeding.clear then
        Bleeding:clear()
    end

    if Damages and Damages.clear then
        Damages:clear()
    end

    Death:setDeathState({
        state = false,
        type  = "bleeding"
    })

    TriggerServerEvent("p_ambulancejob/server/death/reviveUtils")

    -- set sau setState vì setState overwrite wasRecovering
    SetTimeout(1600, function()
        SetEntityHealth(cache.ped, 110)
    end)
end)

RegisterNetEvent("p_ambulancejob/client/firstAid/lock", function()
    Death.isBeingRevived = true
    if Death.isCrawling then
        Death.isCrawling = false
        local ped = PlayerPedId()
        if ped and ped ~= 0 and DoesEntityExist(ped) then
            ClearPedTasks(ped)
        end
    end
    LocalPlayer.state:set("isBeingRevived", true, false)
    Citizen.CreateThread(function()
        while LocalPlayer.state.isBeingRevived do
            DisableAllControlActions(0)
            DisableAllControlActions(1)
            Citizen.Wait(0)
        end
        Death.isBeingRevived = false
    end)
end)

RegisterNetEvent("p_ambulancejob/client/firstAid/unlock", function()
    LocalPlayer.state:set("isBeingRevived", false, false)
end)