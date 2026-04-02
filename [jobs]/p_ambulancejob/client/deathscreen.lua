-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================


-- Test function (legacy)
function test()
  local schools = GlobalState["p_dmvschool/Schools"]
  if schools and schools[k] then
    return schools[k].theoryQuestions
  end
end

-- Initialize DeathScreen module
DeathScreen = {}
DeathScreen.antiSpam = GetGameTimer()

-- Set death screen visibility and configure data
function DeathScreen:setVisibility(data)
  -- Validate data parameter
  if not data or type(data) ~= "table" then
    return
  end
  
  local dropItemsConfig = Config.Death.stages.death.dropItems
  data.dropItems = false
  
  -- Determine if items should be dropped on death
  if data.state and data.type == "death" then
    if dropItemsConfig and dropItemsConfig.enabled then
      if dropItemsConfig.type == "chance" then
        local randomChance = math.random(1, 100)
        
        if randomChance <= dropItemsConfig.chance then
          data.dropItems = true
        end
      elseif dropItemsConfig.type == "medics" then
        local medicsCount = GlobalState["p_ambulancejob/medicsCount"] or 0
        
        if medicsCount >= dropItemsConfig.minMedics then
          data.dropItems = true
        end
      end
    end
  end
  
  -- Set additional death screen data
  data.bleedingMovement = Config.Death.stages.bleeding.movement
  data.droppingItems = dropItemsConfig.enabled
  data.enableAlert = Config.Death.stages.bleeding.enableAlert
  
  -- Send data to NUI if death screen is enabled
  if Config.DeathScreen.enabled then
    SendNUIMessage({
      action = "setDeathScreenData",
      data = data
    })
  end
  
  -- Set visibility
  if Config.DeathScreen.enabled then
    SendNUIMessage({
      action = "setVisibleDeathScreen",
      data = data.state
    })
  else
    -- Use custom visibility handler if provided
    Config.DeathScreen.setVisibility(data.state, data)
  end
end

-- Handle death timer completion from NUI
RegisterNUICallback("finishedDeathTimer", function(data)
  local deathType = Death.deathType
  local dropItems = data.dropItems
  
  if deathType == "recovering" then
    -- Player has recovered
    Death:setDeathState({
      state = false,
      type = "recovering"
    })
  elseif deathType == "bleeding" then
    -- Bleeding out - transition to death
    Death:setDeathState({
      state = true,
      type = "death"
    })
  elseif deathType == "death" then
    -- Monitor for respawn key press (E key)
    Citizen.CreateThread(function()
      while Death.deathType == "death" do
        Citizen.Wait(1)
        
        -- Check if E key is pressed
        if IsControlPressed(0, 38) or IsDisabledControlPressed(0, 38) then
          local currentTime = GetGameTimer()
          
          -- Anti-spam check
          if DeathScreen.antiSpam < currentTime then
            DeathScreen.antiSpam = currentTime + 1000
            CheckIn:localRespawn(dropItems)
          end
        end
      end
    end)
  end
end)

-- Export: Open respawn menu
exports("openRespawnMenu", function(dropItems)
  if dropItems == nil then
    dropItems = false
  end
  
  CheckIn:localRespawn(dropItems)
end)

-- Export: Trigger distress alert
exports("distressAlert", function()
  local alertConfig = Config.Death.stages.death.alert
  
  if alertConfig then
    alertConfig()
  end
end)

-- Monitor medic count changes to update drop items status
AddStateBagChangeHandler("p_ambulancejob/medicsCount", "global", function(bagName, key, value)
  -- Only process if player is dead
  if Death.deathType ~= "death" then
    return
  end
  
  if not value then
    return
  end
  
  -- Check if drop items feature is configured for medic count
  local dropItemsConfig = Config.Death.stages.death.dropItems
  
  if not (dropItemsConfig and dropItemsConfig.enabled and dropItemsConfig.type == "medics") then
    return
  end
  
  -- Only update if death screen is enabled
  if not Config.DeathScreen.enabled then
    return
  end
  
  local medicsCount = GlobalState["p_ambulancejob/medicsCount"]
  local shouldDropItems = medicsCount >= dropItemsConfig.minMedics
  
  -- Update NUI with new drop items status
  SendNUIMessage({
    action = "setDropItems",
    data = shouldDropItems
  })
end)