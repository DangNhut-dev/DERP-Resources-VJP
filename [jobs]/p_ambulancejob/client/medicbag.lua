-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================



-- Wait for Config.MedicBag to be available
while not (Config and Config.MedicBag) do
  Citizen.Wait(100)
end

-- Exit if medic bag is not enabled
if not Config.MedicBag.enabled then
  return
end

-- Test function for GlobalState access
function test()
  local schools = GlobalState["p_dmvschool/Schools"]
  if schools and schools[k] then
    return schools[k].theoryQuestions
  end
end

-- Initialize MedicBag object
MedicBag = {}

-- Setup target interactions for medic bag prop
Citizen.CreateThread(function()
  Bridge.Target.addModel(Config.MedicBag.prop.model, {
    -- Option 1: Open medic bag
    {
      name = "p_ambulancejob/medicbag/open",
      label = locale("open_medic_bag"),
      icon = "fa-solid fa-bag-shopping",
      distance = 2,
      onSelect = function(entity)
        MedicBag:open()
      end,
      canInteract = function(entity)
        -- Get network ID if entity is networked
        local networkId = nil
        if NetworkGetEntityIsNetworked(entity) then
          networkId = NetworkGetNetworkIdFromEntity(entity)
        end
        
        -- Only interact with the player's own medic bag
        return networkId and MedicBag.netId == networkId
      end
    },
    -- Option 2: Remove medic bag
    {
      name = "p_ambulancejob/medicbag/remove",
      label = locale("remove_medic_bag"),
      icon = "fa-solid fa-trash",
      distance = 2,
      onSelect = function(entity)
        MedicBag:remove()
      end,
      canInteract = function(entity)
        -- Get network ID if entity is networked
        local networkId = nil
        if NetworkGetEntityIsNetworked(entity) then
          networkId = NetworkGetNetworkIdFromEntity(entity)
        end
        
        -- Only interact with the player's own medic bag
        return networkId and MedicBag.netId == networkId
      end
    }
  })
end)

-- Network event: Use medic bag item
RegisterNetEvent("p_ambulancejob/client/medicbag/use", function(medicBagType)
  MedicBag:use(medicBagType)
end)

-- Place medic bag on ground
function MedicBag.use(self, medicBagType)
  local playerJob = Bridge.Framework.fetchPlayerJob()
  
  -- Check if player has access
  if not (playerJob and Editable.allJobs[playerJob.name]) then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  -- Show progress bar for placing bag
  local progressCompleted = Bridge.Progress.Start({
    duration = 1200,
    label = locale("putting_down_medic_bag"),
    canCancel = true,
    anim = Config.MedicBag.anims.putdown
  })
  
  if progressCompleted then
    -- Remove item from inventory
    TriggerServerEvent("p_bridge/server/removeItem", medicBagType, 1)
    
    -- Calculate position in front of player
    local spawnCoords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 0.75, 0.0)
    
    -- Create medic bag object
    local modelHash = lib.requestModel(Config.MedicBag.prop.model)
    local bagObject = CreateObject(
      modelHash,
      spawnCoords.x,
      spawnCoords.y,
      spawnCoords.z - 0.95,
      true,
      true,
      true
    )
    
    SetEntityAsMissionEntity(bagObject, true, true)
    NetworkRequestControlOfEntity(bagObject)
    FreezeEntityPosition(bagObject, true)
    SetModelAsNoLongerNeeded(modelHash)
    
    -- Store medic bag data
    local networkId = Utils:getNetId(bagObject)
    self.netId = networkId
    self.object = bagObject
    self.medicBagType = medicBagType
    
    -- Set entity state
    Entity(self.object).state:set("isMedicBag", medicBagType, true)
    
    ClearPedTasks(cache.ped)
  end
end

-- Pick up medic bag from ground
function MedicBag.remove(self)
  if self.object and DoesEntityExist(self.object) then
    -- Show progress bar for picking up bag
    local progressCompleted = Bridge.Progress.Start({
      duration = 1200,
      label = locale("picking_up_medic_bag"),
      canCancel = true,
      anim = Config.MedicBag.anims.pickup
    })
    
    if progressCompleted then
      -- Notify server to give item back
      TriggerServerEvent(
        "p_ambulancejob/server/medicbag/remove",
        NetworkGetNetworkIdFromEntity(self.object)
      )
      
      self.object = nil
      ClearPedTasks(cache.ped)
    end
  end
end

-- Open medic bag menu to take items
function MedicBag.open(self)
  local options = {}
  
  -- Build menu options for each item in the bag
  for itemName, itemData in pairs(Config.MedicBag.items[self.medicBagType]) do
    local itemInfo = Bridge.Inventory.getItemData(itemName)
    local itemLabel = (itemInfo and itemInfo.label) or itemName
    local itemIcon = (itemInfo and itemInfo.image) or "fa-solid fa-hand"
    
    local optionIndex = #options + 1
    options[optionIndex] = {
      title = itemLabel,
      description = locale("take_item", itemLabel),
      icon = itemIcon,
      onSelect = function()
        -- Ask player how many items to take
        local input = lib.inputDialog(locale("take_item", itemLabel), {
          {
            type = "number",
            label = locale("amount"),
            default = 1,
            required = true,
            min = 1,
            max = 10
          }
        })
        
        if not input then
          return
        end
        
        -- Take items from bag
        TriggerServerEvent(
          "p_ambulancejob/server/medicbag/take",
          itemName,
          NetworkGetNetworkIdFromEntity(self.object),
          input[1],
          self.medicBagType
        )
        
        -- Reopen menu
        lib.showContext("p_ambulancejob/medicbag")
      end
    }
  end
  
  -- Register and show menu
  lib.registerContext({
    id = "p_ambulancejob/medicbag",
    title = locale("medic_bag"),
    options = options
  })
  
  lib.showContext("p_ambulancejob/medicbag")
end