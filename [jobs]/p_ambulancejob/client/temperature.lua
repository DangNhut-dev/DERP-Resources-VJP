-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================



-- Wait for Config.Temperature to be available
while not (Config and Config.Temperature) do
  Citizen.Wait(100)
end

-- Exit if temperature system is not enabled
if not Config.Temperature.enabled then
  return
end

-- Test function for GlobalState access
function test()
  local schools = GlobalState["p_dmvschool/Schools"]
  if schools and schools[k] then
    return schools[k].theoryQuestions
  end
end

-- Initialize Temperature object
Temperature = {
  value = math.random(Config.Temperature.minTemperature, Config.Temperature.maxTemperature),
  canGetCritical = true,
  critical = false
}

-- Helper: Update temperature state
local function updateTemperatureState(value)
  LocalPlayer.state:set("temperature", value, true)
end

-- Helper: Update critical temperature state
local function updateCriticalState(isCritical)
  LocalPlayer.state:set("criticalTemperature", isCritical, true)
end

-- Initialize temperature monitoring system
function Temperature.init(self)
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(5000)
      
      local injuryCount = Damages:getInjuriesAmount()
      
      if injuryCount < 1 then
        -- No injuries: slowly return to normal temperature (if not critical)
        if not self.critical then
          self.value = math.max(
            Config.Temperature.minTemperature,
            self.value - math.random(1, 5)
          )
          updateTemperatureState(self.value)
        end
      else
        -- Has injuries: check for critical temperature condition
        if Config.Temperature.critical.enabled then
          local criticalThreshold = Config.Temperature.critical.requiredInjuries
          
          if injuryCount >= criticalThreshold and not self.critical and self.canGetCritical then
            -- Roll chance for critical temperature
            local roll = math.random(1, 100)
            
            if roll <= Config.Temperature.critical.chance then
              -- Critical temperature triggered (hypothermia or hyperthermia)
              local criticalTemp = Config.Temperature.critical.temperature[math.random(1, 2)]
              self.value = criticalTemp
              self.critical = true
              self.canGetCritical = false
              
              -- Update player state
              updateTemperatureState(self.value)
              updateCriticalState(true)
              
              -- Notify player of condition
              if self.value < Config.Temperature.minTemperature then
                Bridge.Notify.showNotify(locale("temperature_low"), "inform")
              else
                Bridge.Notify.showNotify(locale("temperature_high"), "inform")
              end
            end
          end
        end
      end
    end
  end)
end

-- Network event: Use temperature-modifying item (ice pack, heating pad, etc.)
RegisterNetEvent("p_ambulancejob/client/temperature/usedItem", function(itemName)
  if not (itemName and Config.Temperature.items[itemName]) then
    return
  end
  
  local temperatureChange = Config.Temperature.items[itemName]
  Temperature.value = Temperature.value + temperatureChange
  
  -- Clamp temperature to critical thresholds if exceeded
  local lowCritical = Config.Temperature.critical.temperature[1] - 3
  local highCritical = Config.Temperature.critical.temperature[2] + 3
  
  if Temperature.value < lowCritical then
    Temperature.value = Config.Temperature.critical.temperature[1]
  elseif Temperature.value > highCritical then
    Temperature.value = Config.Temperature.critical.temperature[2]
  end
  
  updateTemperatureState(Temperature.value)
  
  -- Check if temperature is now in normal range
  local minTemp = Config.Temperature.minTemperature
  local maxTemp = Config.Temperature.maxTemperature
  
  if Temperature.value >= minTemp and Temperature.value <= maxTemp then
    -- Temperature normalized
    Temperature:reset(false)
  elseif Temperature.value < minTemp then
    Bridge.Notify.showNotify(locale("temperature_low"), "inform")
  else
    Bridge.Notify.showNotify(locale("temperature_high"), "inform")
  end
end)

-- Reset temperature to normal stable range
function Temperature.reset(self, canGetCriticalAgain)
  if canGetCriticalAgain == nil then
    canGetCriticalAgain = true
  end
  
  -- Reset to random normal temperature
  self.value = math.random(Config.Temperature.minTemperature, Config.Temperature.maxTemperature)
  self.critical = false
  self.canGetCritical = canGetCriticalAgain
  
  -- Update player state
  updateTemperatureState(self.value)
  updateCriticalState(false)
  
  Bridge.Notify.showNotify(locale("temperature_stable"), "inform")
end

-- Network event: Reset temperature (called by medic)
RegisterNetEvent("p_ambulancejob/client/temperature/reset", function()
  Temperature:reset()
end)

-- Add value to temperature (capped at max)
function Temperature.add(self, amount)
  self.value = math.min(Config.Temperature.maxTemperature, self.value + amount)
  updateTemperatureState(self.value)
end

-- Export: Reset temperature to normal
exports("resetTemperature", function()
  Temperature:reset()
end)

-- Export: Add to temperature value
exports("addTemperature", function(amount)
  Temperature:add(amount)
end)

-- Start temperature monitoring system
Citizen.CreateThread(function()
  Temperature:init()
end)