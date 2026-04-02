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

-- Player interaction system
Interactions = {
  bloodCooldowns = {}
}

-- Helper function to get webhook URL
local function getWebhook(webhookType)
  return Webhooks and Webhooks[webhookType] or nil
end

-- Put player in vehicle
function Interactions.putInVehicle(self, targetPlayerId, seatIndex)
  TriggerClientEvent("p_ambulancejob/client/interactions/putInVehicle", targetPlayerId, seatIndex)
end

-- Take player out of vehicle
function Interactions.takeOutVehicle(self, targetPlayerId, seatIndex)
  TriggerClientEvent("p_ambulancejob/client/interactions/takeOutVehicle", targetPlayerId, seatIndex)
end

-- Take blood from a player
function Interactions.takeBlood(self, sourcePlayer, targetPlayerId, bloodAmount)
  if not Config.Interactions.playerBlood.enabled then
    return
  end
  
  -- Debug logging if enabled
  if Bridge.Config and Bridge.Config.Debug then
    local targetBloodType = Player(targetPlayerId).state.bloodType
    print("blood types enabled?", Config.BloodTypes and Config.BloodTypes.enabled)
    print("target blood type", targetPlayerId, targetBloodType)
    print("giving item", string.format("blood_bag_%s", bloodAmount))
  end
  
  -- Determine blood bag metadata
  local metadata = nil
  if Config.BloodTypes and Config.BloodTypes.enabled then
    metadata = {
      bloodType = Player(targetPlayerId).state.bloodType
    }
  end
  
  -- Give blood bag to medic
  local bloodBagItem = string.format("blood_bag_%s", bloodAmount)
  Bridge.Inventory.addItem(sourcePlayer, bloodBagItem, 1, metadata)
  
  -- Trigger client-side blood taking animation
  TriggerClientEvent("p_ambulancejob/client/interactions/takeBlood", targetPlayerId)
  
  -- Set cooldown for the target player
  local cooldownMinutes = Config.Interactions.playerBlood.cooldownPerPlayer
  
  -- Double cooldown if taking 500ml
  if bloodAmount == 500 and Config.Interactions.playerBlood.doubleCooldown then
    cooldownMinutes = cooldownMinutes * 2
  end
  
  self.bloodCooldowns[targetPlayerId] = os.time() + (cooldownMinutes * 60)
end

-- Carry/uncarry a player
function Interactions.carry(self, sourcePlayer, targetPlayerId)
  local sourceState = Player(sourcePlayer).state
 
  if not sourceState.isCarrying then
    local carryConfig = Config.Interactions.options.carryPlayer
 
    -- Check nếu cần confirm VÀ target không trong trạng thái ngất/chết/còng
    if carryConfig.needConfirm then
      local skipConfirm = false
 
      -- Check target state: dead/bleeding/cuffed → skip confirm
      local targetState = Player(targetPlayerId).state
      local isDead = targetState.isDead or targetState.dead or false
      local deathType = targetState.deathType
      local isInDeathState = isDead or (deathType and deathType ~= 'none')
 
      -- Check cuff via metadata
      local QBCore = exports['qb-core']:GetCoreObject()
      local targetPlayer = QBCore.Functions.GetPlayer(targetPlayerId)
      local isCuffed = targetPlayer and targetPlayer.PlayerData.metadata.ishandcuffed or false
 
      skipConfirm = isInDeathState or isCuffed
 
      if not skipConfirm then
        local sourceName = Bridge.Framework.getPlayerName(sourcePlayer)
        local confirmed = lib.callback.await(
          'p_ambulancejob/server/interactions/canCarry',
          targetPlayerId,
          sourceName,
          sourcePlayer
        )
 
        if not confirmed then
          Bridge.Notify.showNotify(sourcePlayer, locale('carry_request_declined'), 'error')
          return
        end
      end
    end
  end
 
  -- Toggle carrying state (giữ nguyên phần còn lại)
  sourceState:set('isCarrying', not sourceState.isCarrying, true)
  local targetState = Player(targetPlayerId).state
  targetState:set('isCarried', not targetState.isCarried, true)
 
  TriggerClientEvent('p_ambulancejob/client/interactions/toggleCarry', sourcePlayer, {
    id = targetPlayerId,
    isCarrying = true
  })
 
  TriggerClientEvent('p_ambulancejob/client/interactions/toggleCarry', targetPlayerId, {
    id = sourcePlayer,
    isCarrying = false
  })
end

-- Event: Take blood from a player
RegisterNetEvent("p_ambulancejob/server/interactions/takeBlood", function(targetPlayerId, bloodAmount)
  -- Validate target player ID
  if not targetPlayerId or type(targetPlayerId) ~= "number" or targetPlayerId < 1 then
    return
  end
  
  local sourcePlayer = source
  
  -- Check distance
  if not Utils:checkDistance(sourcePlayer, targetPlayerId) then
    return
  end
  
  -- Check if player has required job permissions
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  if not playerJob or not Editable.allJobs[playerJob.name] then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  -- Check if player is on cooldown
  local cooldownExpiry = Interactions.bloodCooldowns[targetPlayerId]
  if cooldownExpiry and cooldownExpiry > os.time() then
    Bridge.Notify.showNotify(sourcePlayer, locale("you_cant_take_blood_again"), "error")
    return
  end
  
  -- Take blood from player
  Interactions:takeBlood(sourcePlayer, targetPlayerId, bloodAmount)
  
  -- Log the action
  local sourceName = Bridge.Framework.getPlayerName(sourcePlayer)
  local targetName = Bridge.Framework.getPlayerName(targetPlayerId)
  local logMessage = string.format("Player %s has taken blood from %s", sourceName, targetName)
  Bridge.Logs.Send(sourcePlayer, "Blood Taken", logMessage, getWebhook("interactions"))
end)

-- Event: Put player in vehicle
RegisterNetEvent("p_ambulancejob/server/interactions/putInPlayer", function(data)
  local targetPlayerId = data.player
  local seatIndex = data.seat
  
  -- Validate parameters
  if not targetPlayerId or type(targetPlayerId) ~= "number" or targetPlayerId < 1 or not seatIndex then
    return
  end
  
  local sourcePlayer = source
  
  -- Check distance
  if not Utils:checkDistance(sourcePlayer, targetPlayerId) then
    return
  end
  
  -- Check if player has required job permissions
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  if not playerJob or not Editable.allJobs[playerJob.name] then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  -- Put player in vehicle
  Interactions:putInVehicle(targetPlayerId, seatIndex)
  
  -- Log the action
  local targetName = Bridge.Framework.getPlayerName(targetPlayerId)
  local logMessage = string.format("Player %s has been put in vehicle seat %s", targetName, seatIndex)
  Bridge.Logs.Send(sourcePlayer, "Player Put In Vehicle", logMessage, getWebhook("interactions"))
end)

-- Event: Take player out of vehicle
RegisterNetEvent("p_ambulancejob/server/interactions/takeOutPlayer", function(data)
  local targetPlayerId = data.player
  local seatIndex = data.seat
  
  -- Validate parameters
  if not targetPlayerId or type(targetPlayerId) ~= "number" or targetPlayerId < 1 or not seatIndex then
    return
  end
  
  local sourcePlayer = source
  
  -- Check distance
  if not Utils:checkDistance(sourcePlayer, targetPlayerId) then
    return
  end
  
  -- Check if player has required job permissions
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  if not playerJob or not Editable.allJobs[playerJob.name] then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  -- Take player out of vehicle
  Interactions:takeOutVehicle(targetPlayerId, seatIndex)
  
  -- Log the action
  local targetName = Bridge.Framework.getPlayerName(targetPlayerId)
  local logMessage = string.format("Player %s has been taken out of vehicle seat %s", targetName, seatIndex)
  Bridge.Logs.Send(sourcePlayer, "Player Took Out Vehicle", logMessage, getWebhook("interactions"))
end)

-- Event: Carry a player
RegisterNetEvent("p_ambulancejob/server/interactions/carryPlayer", function(targetPlayerId)
  -- Validate target player ID
  if not targetPlayerId or type(targetPlayerId) ~= "number" or targetPlayerId < 1 then
    return
  end
  
  local sourcePlayer = source
  
  -- Check distance
  if not Utils:checkDistance(sourcePlayer, targetPlayerId) then
    return
  end
  
  -- Toggle carrying
  Interactions:carry(sourcePlayer, targetPlayerId)
  
  -- Log the action
  local sourceName = Bridge.Framework.getPlayerName(sourcePlayer)
  local targetName = Bridge.Framework.getPlayerName(targetPlayerId)
  local logMessage = string.format("Player %s has started carrying %s", sourceName, targetName)
  Bridge.Logs.Send(sourcePlayer, "Player Carried", logMessage, getWebhook("interactions"))
end)

-- =====================================================
-- THÊM vào file server interactions
-- Paste vào cuối file
-- =====================================================

-- Cho người đang cõng lên xe
RegisterNetEvent('p_ambulancejob/server/interactions/putCarriedInVehicle', function(data)
    local sourcePlayer = source
    local seat = data.seat
    local targetPlayerId = data.player
    local isEscort = data.isEscort
 
    if seat == nil or type(seat) ~= 'number' then return end
    if not targetPlayerId or type(targetPlayerId) ~= 'number' or targetPlayerId < 1 then return end
 
    -- Check distance
    if not Utils:checkDistance(sourcePlayer, targetPlayerId) then return end
 
    local sourceState = Player(sourcePlayer).state
 
    if isEscort then
        -- Escort case: dùng event police để handle đúng
        -- police:client:PutInVehicle tự reset IsEscorted, detach, warp
        TriggerClientEvent('police:client:PutInVehicle', targetPlayerId)
    else
        -- Carry case (p_ambulancejob)
        if sourceState.isCarrying then
            sourceState:set('isCarrying', false, true)
            Player(targetPlayerId).state:set('isCarried', false, true)
 
            TriggerClientEvent('p_ambulancejob/client/interactions/toggleCarry', sourcePlayer, {
                id = targetPlayerId,
                isCarrying = true,
            })
            TriggerClientEvent('p_ambulancejob/client/interactions/toggleCarry', targetPlayerId, {
                id = sourcePlayer,
                isCarrying = false,
            })
        end
 
        Citizen.Wait(300)
        Interactions:putInVehicle(targetPlayerId, seat)
    end
 
    -- Log
    local sourceName = Bridge.Framework.getPlayerName(sourcePlayer)
    local targetName = Bridge.Framework.getPlayerName(targetPlayerId)
    local logMessage = string.format('Player %s put player %s into vehicle seat %s', sourceName, targetName, seat)
    Bridge.Logs.Send(sourcePlayer, 'Player Put In Vehicle', logMessage, getWebhook('interactions'))
end)

-- Đưa người ngất/chết/còng xuống xe
RegisterNetEvent('p_ambulancejob/server/interactions/takeIncapacitatedFromVehicle', function(data)
    local sourcePlayer = source
    local targetPlayerId = data.player
    local seat = data.seat

    if not targetPlayerId or type(targetPlayerId) ~= 'number' or targetPlayerId < 1 then
        return
    end
    if seat == nil then
        return
    end

    if not Utils:checkDistance(sourcePlayer, targetPlayerId) then return end

    local targetState = Player(targetPlayerId).state
    local isDead = targetState.isDead or targetState.dead or false
    local deathType = targetState.deathType
    local isInDeathState = isDead or (deathType and deathType ~= 'none')

    local QBCore = exports['qb-core']:GetCoreObject()
    local targetPlayer = QBCore.Functions.GetPlayer(targetPlayerId)
    local isCuffed = targetPlayer and targetPlayer.PlayerData.metadata.ishandcuffed or false

    if not (isInDeathState or isCuffed) then return end

    Interactions:takeOutVehicle(targetPlayerId, seat)
end)