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

-- Wait for Config.Insurance to be available
while not (Config and Config.Insurance) do
  Citizen.Wait(100)
end

-- Check if insurance feature is enabled
if not Config.Insurance.enabled then
  return
end

-- Insurance management system
Insurance = {
  active = {}
}

-- Initialize global state
GlobalState["p_ambulancejob/Insurances"] = Insurance.active

-- Background thread to check for expired insurances
function Insurance.thread(self)
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(60000) -- Check every minute
      
      local expiredInsurances = {}
      local currentTime = os.time()
      
      -- Check all active insurances for expiration
      for playerId, insuranceData in pairs(self.active) do
        if currentTime > insuranceData.duration then
          -- Insurance has expired
          table.insert(expiredInsurances, {playerId})
          self.active[playerId] = nil
          Bridge.Debug("Removed expired insurance for:", playerId)
        end
      end
      
      -- Update global state
      GlobalState["p_ambulancejob/Insurances"] = self.active
      
      -- Remove expired insurances from database
      if #expiredInsurances > 0 then
        MySQL.prepare("DELETE FROM health_insurances WHERE owner = ?", expiredInsurances)
      end
    end
  end)
end

-- Load all insurances from database
function Insurance.load(self)
  local insurances = MySQL.query.await("SELECT * FROM health_insurances")
  
  for _, insuranceData in pairs(insurances) do
    self.active[insuranceData.owner] = {
      insurance = insuranceData.insurance,
      duration = insuranceData.duration
    }
  end
  
  GlobalState["p_ambulancejob/Insurances"] = self.active
end

-- Remove a player's insurance
function Insurance.remove(self, playerId)
  MySQL.update.await("DELETE FROM health_insurances WHERE owner = ?", {playerId})
  self.active[playerId] = nil
end

-- Purchase insurance for a player
function Insurance.buy(self, sourcePlayer, insuranceType, hospitalId)
  -- Get player's unique ID
  local uniqueId = Bridge.Framework.getUniqueId(sourcePlayer)
  if not uniqueId then
    return
  end
  
  -- Remove existing insurance if player has one
  if self.active[uniqueId] then
    Insurance:remove(uniqueId)
    Citizen.Wait(1)
  end
  
  -- Get insurance configuration
  local insuranceConfig = Config.Insurance.options[insuranceType]
  if not insuranceConfig then
    return
  end
  
  -- Check player's money
  local playerMoney = Bridge.Framework.getMoney(sourcePlayer)
  Bridge.Debug("Player Money:", playerMoney)
  
  local hasEnoughMoney = false
  local moneyType = nil
  
  -- Check cash first, then bank
  if playerMoney and playerMoney.money and playerMoney.money >= insuranceConfig.price then
    Bridge.Framework.removeMoney(sourcePlayer, "money", insuranceConfig.price)
    hasEnoughMoney = true
    moneyType = "money"
  elseif playerMoney and playerMoney.bank and playerMoney.bank >= insuranceConfig.price then
    Bridge.Framework.removeMoney(sourcePlayer, "bank", insuranceConfig.price)
    hasEnoughMoney = true
    moneyType = "bank"
  else
    Bridge.Notify.showNotify(sourcePlayer, locale("not_enough_money"), "error")
    return
  end
  
  -- Add money to society if configured
  if Config.Insurance.moneyIntoSociety and Bridge.Society then
    Citizen.CreateThread(function()
      local hospital = Config.Hospitals[hospitalId]
      local jobs = hospital and hospital.jobs or {}
      
      for _, jobName in pairs(jobs) do
        Bridge.Society.addMoney(sourcePlayer, jobName, insuranceConfig.price)
      end
    end)
  end
  
  -- Calculate expiration time
  local expirationTime = os.time() + insuranceConfig.duration
  
  -- Insert into database
  MySQL.insert.await(
    "INSERT INTO health_insurances (owner, insurance, duration) VALUES (?, ?, ?)",
    {uniqueId, insuranceType, expirationTime}
  )
  
  -- Add to active insurances
  self.active[uniqueId] = {
    insurance = insuranceType,
    duration = expirationTime
  }
  
  -- Notify player
  Bridge.Notify.showNotify(
    sourcePlayer,
    locale("insurance_purchased", insuranceConfig.label, insuranceConfig.price),
    "success"
  )
  
  Bridge.Debug("Purchased insurance:", uniqueId, insuranceType, expirationTime)
  
  -- Update global state
  GlobalState["p_ambulancejob/Insurances"] = self.active
  
  -- Log the purchase
  local playerName = Bridge.Framework.getPlayerName(sourcePlayer)
  local logMessage = string.format(
    "Player %s bought insurance %s for $ %s",
    playerName,
    insuranceConfig.label,
    insuranceConfig.price
  )
  local webhook = Webhooks and Webhooks.insurance or nil
  Bridge.Logs.Send(sourcePlayer, "Player Bought Insurance", logMessage, webhook)
end

-- Event: Buy insurance
RegisterNetEvent("p_ambulancejob/server/insurance/buyInsurance", function(insuranceType, hospitalId)
  local sourcePlayer = source
  
  -- Validate input
  if not insuranceType or type(insuranceType) ~= "string" then
    return
  end
  
  if not Config.Insurance.options[insuranceType] then
    return
  end
  
  if not hospitalId or not Config.Insurance.points[hospitalId] then
    return
  end
  
  Insurance:buy(sourcePlayer, insuranceType, hospitalId)
end)

-- Callback: Get player's insurance information
lib.callback.register("p_ambulancejob/server/insurance/getInsurance", function(sourcePlayer)
  local uniqueId = Bridge.Framework.getUniqueId(sourcePlayer)
  if not uniqueId then
    return nil
  end
  
  local insuranceData = Insurance.active[uniqueId]
  if insuranceData then
    local insuranceConfig = Config.Insurance.options[insuranceData.insurance]
    local insuranceName = (insuranceConfig and insuranceConfig.label) or insuranceData.insurance
    local timeLeft = insuranceData.duration - os.time()
    
    return {
      name = insuranceName,
      timeLeft = timeLeft
    }
  end
  
  return nil
end)

-- Event: Check player's insurance status
RegisterNetEvent("p_ambulancejob/server/insurance/check", function(targetPlayerId)
  local sourcePlayer = source
  
  -- Validate input
  if not targetPlayerId or type(targetPlayerId) ~= "number" then
    return
  end
  
  local uniqueId = Bridge.Framework.getUniqueId(targetPlayerId)
  if not uniqueId then
    return
  end
  
  local insuranceData = Insurance.active[uniqueId]
  
  if insuranceData then
    local insuranceConfig = Config.Insurance.options[insuranceData.insurance]
    local insuranceName = (insuranceConfig and insuranceConfig.label) or insuranceData.insurance
    
    -- Calculate days remaining
    local timeLeft = insuranceData.duration - os.time()
    local daysLeft = math.floor(timeLeft / 60 / 60 / 24)
    
    Bridge.Notify.showNotify(
      sourcePlayer,
      locale("player_insurance", insuranceName, daysLeft),
      "inform"
    )
  else
    Bridge.Notify.showNotify(
      sourcePlayer,
      locale("player_no_insurance"),
      "inform"
    )
  end
end)

-- Export: Get player's insurance
exports("getPlayerInsurance", function(playerId)
  local uniqueId = Bridge.Framework.getUniqueId(playerId)
  if not uniqueId then
    return nil
  end
  
  local insuranceData = Insurance.active[uniqueId]
  if insuranceData then
    local insuranceConfig = Config.Insurance.options[insuranceData.insurance]
    local insuranceName = (insuranceConfig and insuranceConfig.label) or insuranceData.insurance
    local timeLeft = insuranceData.duration - os.time()
    
    return {
      name = insuranceName,
      duration = insuranceData.duration,
      timeLeft = timeLeft
    }
  end
  
  return nil
end)

-- Export: Remove player's insurance
exports("removePlayerInsurance", function(playerId)
  local uniqueId = Bridge.Framework.getUniqueId(playerId)
  if not uniqueId then
    return false
  end
  
  if Insurance.active[uniqueId] then
    Insurance:remove(uniqueId)
    return true
  end
  
  return false
end)

-- Export: Add insurance to player
exports("addPlayerInsurance", function(playerId, insuranceType)
  -- Validate insurance type
  if not insuranceType or type(insuranceType) ~= "string" then
    return false
  end
  
  if not Config.Insurance.options[insuranceType] then
    return false
  end
  
  local uniqueId = Bridge.Framework.getUniqueId(playerId)
  if not uniqueId then
    return false
  end
  
  -- Remove existing insurance if present
  if Insurance.active[uniqueId] then
    Insurance:remove(uniqueId)
    Citizen.Wait(1)
  end
  
  -- Get insurance configuration
  local insuranceConfig = Config.Insurance.options[insuranceType]
  local expirationTime = os.time() + insuranceConfig.duration
  
  -- Insert into database
  MySQL.insert.await(
    "INSERT INTO health_insurances (owner, insurance, duration) VALUES (?, ?, ?)",
    {uniqueId, insuranceType, expirationTime}
  )
  
  -- Add to active insurances
  Insurance.active[uniqueId] = {
    insurance = insuranceType,
    duration = expirationTime
  }
  
  GlobalState["p_ambulancejob/Insurances"] = Insurance.active
  
  return true
end)

-- Initialize insurance system
Citizen.CreateThread(function()
  Insurance:load()
  Insurance:thread()
end)