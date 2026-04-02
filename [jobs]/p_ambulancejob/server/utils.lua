-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================



-- Initialize Bridge system
Bridge = exports.p_bridge:getObject()

-- Initialize locale system with configured language or default to English
lib.locale(Bridge.Config and Bridge.Config.Language or "en")

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

-- Utility functions
Utils = {}

-- Check if two players are within valid interaction distance (5.0 units)
function Utils:checkDistance(sourcePlayerId, targetPlayerId)
  -- Validate player IDs
  if not sourcePlayerId or not targetPlayerId or sourcePlayerId == 0 or targetPlayerId == 0 then
    return false
  end
  
  -- Safely get player peds (may fail if player disconnected)
  local sourceSuccess, sourcePed = pcall(GetPlayerPed, sourcePlayerId)
  local targetSuccess, targetPed = pcall(GetPlayerPed, targetPlayerId)
  
  -- Validate both peds exist and are valid
  if not sourcePed or sourcePed == 0 or not targetPed or targetPed == 0 then
    return false
  end
  
  -- Calculate distance between players
  local sourceCoords = GetEntityCoords(sourcePed)
  local targetCoords = GetEntityCoords(targetPed)
  local distance = #(sourceCoords - targetCoords)
  
  -- Return true if within 5.0 units
  return distance < 5.0
end

-- Initialize inventory shops for hospitals
Citizen.CreateThread(function()
  Citizen.Wait(3000) -- Wait for resources to load
  
  -- Check if inventory system supports shop creation
  if not Bridge.Inventory or not Bridge.Inventory.createShop then
    return
  end
  
  -- Create a shop for each configured hospital
  for hospitalId, shopConfig in pairs(Config.Shops) do
    local hospital = Config.Hospitals[hospitalId]
    
    -- Build job restrictions if hospital has specific jobs
    local jobRestrictions = nil
    if hospital and hospital.jobs then
      jobRestrictions = {}
      for _, jobName in pairs(hospital.jobs) do
        jobRestrictions[jobName] = 0 -- 0 = minimum grade requirement
      end
    end
    
    -- Determine final job restrictions
    local finalRestrictions = nil
    if shopConfig.jobRestricted and jobRestrictions then
      finalRestrictions = jobRestrictions
    end
    
    -- Create the shop
    Bridge.Inventory.createShop(hospitalId, {
      name = shopConfig.label,
      inventory = shopConfig.items,
      locations = {vec3(shopConfig.coords.xyz)},
      groups = finalRestrictions
    })
  end
end)

-- Server event to restore player needs (hunger, thirst, stress)
RegisterNetEvent('p_ambulancejob/server/death/restoreNeeds', function()
  local source = source
  
  -- QBX smallresources support
  if GetResourceState('qbx_smallresources') == 'started' then
    exports['qbx_smallresources']:SetHunger(source, 100)
    exports['qbx_smallresources']:SetThirst(source, 100)
    Player(source).state:set("stress", 0, true)
  end
end)