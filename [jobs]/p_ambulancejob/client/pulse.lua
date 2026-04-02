-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================



-- Wait for Config.Pulse to be available
while not (Config and Config.Pulse) do
  Citizen.Wait(100)
end

-- Exit if pulse system is not enabled
if not Config.Pulse.enabled then
  return
end

-- Initialize Pulse object
Pulse = {
  value = math.random(Config.Pulse.minPulse, Config.Pulse.minPulse + 30),
  antiSpam = GetGameTimer(),
  critical = false,
  canGetCritical = true
}

-- Test function for GlobalState access
function test()
  local schools = GlobalState["p_dmvschool/Schools"]
  if schools and schools[k] then
    return schools[k].theoryQuestions
  end
end

-- Event: Increase pulse when player shoots
AddEventHandler("CEventGunShot", function(entities, eventEntity, args)
  -- Check if player is shooting and anti-spam timer allows
  if not (IsPedShooting(cache.ped) and Pulse.antiSpam <= GetGameTimer()) then
    return
  end
  
  -- Update anti-spam timer
  Pulse.antiSpam = GetGameTimer() + 1000
  
  -- Increase pulse by random amount
  Pulse:add(math.random(1, 3))
end)

-- Initialize pulse monitoring system
function Pulse.init(self)
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(5000)
      
      local injuryCount = Damages:getInjuriesAmount()
      
      if injuryCount < 1 then
        -- No injuries: slowly decrease pulse back to normal
        self.value = math.max(
          Config.Pulse.minPulse,
          self.value - math.random(1, 5)
        )
        
        LocalPlayer.state:set("pulse", self.value, true)
      else
        -- Has injuries: check for critical pulse condition
        if Config.Pulse.critical.enabled then
          local criticalThreshold = Config.Pulse.critical.requiredInjuries
          
          if injuryCount >= criticalThreshold and not self.critical and self.canGetCritical then
            -- Roll chance for critical pulse
            local roll = math.random(1, 100)
            
            if roll <= Config.Pulse.critical.chance then
              -- Critical pulse triggered
              Bridge.Notify.showNotify(locale("critical_pulse"), "inform")
              
              -- Set pulse to critical value (randomly high or low)
              self.value = Config.Pulse.critical.pulse[math.random(1, 2)]
              self.critical = true
              self.canGetCritical = false
              
              -- Update player state
              LocalPlayer.state:set("pulse", self.value, true)
              LocalPlayer.state:set("criticalPulse", true, true)
            end
          end
        end
      end
    end
  end)
end

-- Reset pulse to normal stable range
function Pulse.reset(self, canGetCriticalAgain)
  if canGetCriticalAgain == nil then
    canGetCriticalAgain = true
  end
  
  -- Reset to random normal pulse
  self.value = math.random(Config.Pulse.minPulse, Config.Pulse.minPulse + 30)
  self.critical = false
  self.canGetCritical = canGetCriticalAgain
  
  -- Update player state
  LocalPlayer.state:set("pulse", self.value, true)
  LocalPlayer.state:set("criticalPulse", false, true)
  
  Bridge.Notify.showNotify(locale("pulse_stable"), "inform")
end

-- Network event: Reset pulse (called by medic)
RegisterNetEvent("p_ambulancejob/client/pulse/reset", function()
  Pulse:reset(false)
end)

-- Add value to pulse (capped at max)
function Pulse.add(self, amount)
  self.value = math.min(Config.Pulse.maxPulse, self.value + amount)
  LocalPlayer.state:set("pulse", self.value, true)
end

-- Export: Reset pulse to normal
exports("resetPulse", function()
  Pulse:reset()
end)

-- Export: Add to pulse value
exports("addPulse", function(amount)
  Pulse:add(amount)
end)

-- Start pulse monitoring system
Citizen.CreateThread(function()
  Pulse:init()
end)