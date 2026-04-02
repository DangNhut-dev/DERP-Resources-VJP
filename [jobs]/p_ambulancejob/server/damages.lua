-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================



local test

function test()
  local globalState = GlobalState["p_dmvschool/Schools"]
  if globalState then
    globalState = globalState[k]
    if globalState then
      globalState = globalState.theoryQuestions
    end
  end
end

-- Helper function to get webhook URL
local function getWebhook(webhookType)
  return Webhooks and Webhooks[webhookType] or nil
end

-- Helper function to process healing payment
local function processHealingPayment(sourcePlayer, jobName, amount)
  if not Config.Damages.moneyIntoSociety then
    return
  end
  
  if not Bridge.Society then
    return
  end
  
  local medicPercent = Config.Damages.moneyforHealing.medicPercent / 100
  local medicPayment = amount * medicPercent
  local societyPayment = amount - medicPayment
  
  -- Add money to society
  Bridge.Society.addMoney(sourcePlayer, jobName, societyPayment, "Healing payment")
  
  -- Add money to medic's bank
  Bridge.Framework.addMoney(sourcePlayer, "bank", medicPayment, "Healing payment")
end

-- Callback: Heal a specific bone injury
lib.callback.register("p_ambulancejob/server/damages/healBone", function(sourcePlayer, targetPlayerId, data)
  -- Validate input parameters
  if not targetPlayerId or targetPlayerId < 1 or not data or not data.item or not data.bone then
    return false
  end
  
  -- Check if player has required job permissions
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  if not playerJob or not Editable.allJobs[playerJob.name] then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return false
  end
  
  -- Convert weapon to string if provided
  if data.weapon then
    data.weapon = tostring(data.weapon)
  end
  
  -- Get player peds
  local sourcePed = GetPlayerPed(sourcePlayer)
  local targetPed = GetPlayerPed(targetPlayerId)
  
  -- Validate peds exist and are different
  if sourcePed == 0 or targetPed == 0 or sourcePed == targetPed then
    return false
  end
  
  -- Check distance between players
  local sourceCoords = GetEntityCoords(sourcePed)
  local targetCoords = GetEntityCoords(targetPed)
  local distance = #(sourceCoords - targetCoords)
  
  if distance > 6.0 then
    return false
  end
  
  -- Handle temperature items (mouth injury)
  if data.bone == "mouth" then
    local temperatureItem = Config.Temperature.items[data.item]
    if temperatureItem then
      Bridge.Inventory.removeItem(sourcePlayer, data.item, 1)
      TriggerClientEvent("p_ambulancejob/client/temperature/usedItem", targetPlayerId, data.item)
      return true
    end
  end
  
  -- Get player's current damages
  local playerDamages = Player(targetPlayerId).state.damages
  if not playerDamages or not playerDamages[data.bone] then
    return false
  end
  
  local boneInjuries = playerDamages[data.bone].injuries
  if not boneInjuries or not data.weapon then
    return false
  end
  
  -- Check if the specific injury exists
  local injuryData = boneInjuries[data.weapon]
  if not injuryData or not injuryData.data or not injuryData.data.items then
    return false
  end
  
  local itemsRequired = injuryData.data.items[data.item]
  if not itemsRequired then
    return false
  end
  
  -- Handle blood bag with blood type matching
  if data.item:find("blood_bag") and Config.BloodTypes and Config.BloodTypes.enabled then
    local targetBloodType = Player(targetPlayerId).state.bloodType
    local bloodBagCount = Bridge.Inventory.getItemCount(sourcePlayer, data.item, {bloodType = targetBloodType})
    
    if bloodBagCount < 1 then
      Bridge.Notify.showNotify(sourcePlayer, locale("you_need_blood_bag", targetBloodType), "error")
      return false
    end
    
    -- Remove blood bag with specific blood type
    Bridge.Inventory.removeItem(sourcePlayer, data.item, 1, {bloodType = targetBloodType})
  else
    -- Remove regular item
    Bridge.Inventory.removeItem(sourcePlayer, data.item, 1)
  end
  
  -- Decrease items required count
  itemsRequired = itemsRequired - 1
  
  if itemsRequired < 1 then
    -- Remove item requirement from injury
    injuryData.data.items[data.item] = nil
    
    -- Process per-injury payment if configured
    if Config.Damages.moneyIntoSociety and Config.Damages.moneyforHealing.perInjury then
      local amount = Config.Damages.moneyforHealing.amount
      processHealingPayment(sourcePlayer, playerJob.name, amount)
    end
  else
    -- Update remaining items required
    injuryData.data.items[data.item] = itemsRequired
  end
  
  -- Check if injury is fully healed (no items remaining)
  if not next(injuryData.data.items) then
    boneInjuries[data.weapon] = nil
  end
  
  -- Check if all injuries for this bone are healed
  if not next(boneInjuries) then
    playerDamages[data.bone] = nil
  end
  
  -- Update player state with new damage data
  Player(targetPlayerId).state:set("damages", playerDamages, true)
  
  -- Count remaining injuries
  local totalInjuries = 0
  for _ in pairs(playerDamages) do
    totalInjuries = totalInjuries + 1
  end
  
  -- If all injuries healed, revive player
  if totalInjuries < 1 then
    if Player(targetPlayerId).state.isDead then
      -- Player is dead, trigger revive animation with delay
      local reviveDelay = Config.Damages.advancedHealing and 6000 or 100
      
      SetTimeout(reviveDelay, function()
        -- Trigger revive animation on both players
        TriggerClientEvent("p_ambulancejob/client/damages/playRevive", sourcePlayer, {
          isRevived = false,
          targetId = targetPlayerId
        })
        
        TriggerClientEvent("p_ambulancejob/client/damages/playRevive", targetPlayerId, {
          isRevived = true,
          targetId = sourcePlayer
        })
      end)
    else
      -- Player is alive, just trigger client revive
      TriggerClientEvent("p_ambulancejob/client/death/revive", targetPlayerId)
    end
    
    -- Process full healing payment if configured
    if Config.Damages.moneyIntoSociety and not Config.Damages.moneyforHealing.perInjury then
      local amount = Config.Damages.moneyforHealing.amount
      processHealingPayment(sourcePlayer, playerJob.name, amount)
    end
    
    -- Log full healing
    local playerName = Bridge.Framework.getPlayerName(targetPlayerId)
    local logMessage = string.format("Player %s ALL injuries has been healed", playerName)
    Bridge.Logs.Send(sourcePlayer, "Player Injuries Healed", logMessage, getWebhook("damages"))
  end
  
  return true
end)

-- Event: Perform CPR on a player
RegisterNetEvent("p_ambulancejob/server/damages/performCPR", function(targetPlayerId)
  local sourcePlayer = source
  
  -- Check distance
  if not Utils:checkDistance(sourcePlayer, targetPlayerId) then
    return
  end
  
  -- Check if player has required job permissions
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  if not playerJob or not Editable.allJobs[playerJob.name] then
    return
  end
  
  -- Trigger CPR/revive animations on both players
  TriggerClientEvent("p_ambulancejob/client/damages/playRevive", sourcePlayer, {
    isRevived = false,
    targetId = targetPlayerId
  })
  
  TriggerClientEvent("p_ambulancejob/client/damages/playRevive", targetPlayerId, {
    isRevived = true,
    targetId = sourcePlayer
  })
end)

-- Event: Set player's being treated state
RegisterNetEvent("p_ambulancejob/server/damages/treatedPlayer", function(data)
  local sourcePlayer = source
  
  -- Check distance
  if not Utils:checkDistance(sourcePlayer, data.player) then
    return
  end
  
  -- Check if player has required job permissions
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  if not playerJob or not Editable.allJobs[playerJob.name] then
    return
  end
  
  -- Update target player's being healed state
  TriggerClientEvent("p_ambulancejob/client/damages/setBeingHealed", data.player, data.state)
end)