-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================



local test

-- Wait for Config.MedicBag to be available
while not (Config and Config.MedicBag) do
  Citizen.Wait(100)
end

-- Check if medic bag feature is enabled
if not Config.MedicBag.enabled then
  return
end

function test()
  local globalState = GlobalState["p_dmvschool/Schools"]
  if globalState then
    globalState = globalState[k]
    if globalState then
      globalState = globalState.theoryQuestions
    end
  end
end

-- Medic bag management system
MedicBag = {}

-- Take an item from a medic bag
function MedicBag.takeItem(self, sourcePlayer, itemName, quantity, bagType)
  -- Validate item exists in the medic bag configuration
  local bagConfig = Config.MedicBag.items[bagType]
  if not bagConfig or not bagConfig[itemName] then
    return
  end
  
  -- Default quantity to 1 if not specified
  local itemAmount = quantity or 1
  
  -- Add item to player's inventory
  Bridge.Inventory.addItem(sourcePlayer, itemName, itemAmount)
  
  -- Log the action
  local logMessage = string.format("Player has taken item %s from medic bag", itemName)
  local webhook = Webhooks and Webhooks.medicbag or nil
  Bridge.Logs.Send(sourcePlayer, "Medic Bag Item Taken", logMessage, webhook)
end

-- Event: Take item from medic bag
RegisterNetEvent("p_ambulancejob/server/medicbag/take", function(itemName, bagNetworkId, quantity, bagType)
  local sourcePlayer = source
  
  -- Check if player has required job permissions
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  if not playerJob or not Editable.allJobs[playerJob.name] then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  -- Get the medic bag entity
  local bagEntity = NetworkGetEntityFromNetworkId(bagNetworkId)
  
  -- Validate entity exists and is a medic bag
  if bagEntity and DoesEntityExist(bagEntity) then
    local entityState = Entity(bagEntity).state
    
    if entityState.isMedicBag then
      MedicBag:takeItem(sourcePlayer, itemName, quantity, bagType)
    end
  end
end)

-- Event: Remove/pickup medic bag
RegisterNetEvent("p_ambulancejob/server/medicbag/remove", function(bagNetworkId)
  local sourcePlayer = source
  
  -- Check if player has required job permissions
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  if not playerJob or not Editable.allJobs[playerJob.name] then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  -- Get the medic bag entity
  local bagEntity = NetworkGetEntityFromNetworkId(bagNetworkId)
  
  -- Validate entity exists and is a medic bag
  if bagEntity and DoesEntityExist(bagEntity) then
    local entityState = Entity(bagEntity).state
    
    if entityState.isMedicBag then
      -- Get bag type from entity state
      local bagType = entityState.isMedicBag
      
      -- Return medic bag item to player's inventory
      Bridge.Inventory.addItem(sourcePlayer, bagType, 1)
      
      -- Delete the bag entity from world
      DeleteEntity(bagEntity)
    end
  end
end)