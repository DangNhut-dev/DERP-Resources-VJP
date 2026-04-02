-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================



-- Wait for Config.Insurance to be available
while not (Config and Config.Insurance) do
  Citizen.Wait(100)
end

-- Exit if insurance is not enabled
if not Config.Insurance.enabled then
  return
end

-- Test function for GlobalState access
function test()
  local schools = GlobalState["p_dmvschool/Schools"]
  if schools and schools[k] then
    return schools[k].theoryQuestions
  end
end

-- Initialize Insurance object
Insurance = {}

-- Initialize insurance interaction points
function Insurance.init(self)
  Citizen.CreateThread(function()
    -- Wait for insurance points to be available
    while not Config.Insurance.points do
      Wait(100)
    end
    
    -- Create insurance points for each hospital
    for hospitalId, pointData in pairs(Config.Insurance.points) do
      local isSelectedHospital, jobRestriction = Utils:isSelectedHospital(hospitalId)
      
      if isSelectedHospital then
        -- Create interaction point
        local point = lib.points.new({
          coords = vec3(pointData.coords.xyz),
          distance = 25.0
        })
        
        -- On enter: spawn NPC and prop
        function point:onEnter()
          local ped, prop = Utils:createPed({
            model = pointData.ped,
            coords = pointData.coords,
            anim = pointData.anim,
            prop = pointData.prop
          })
          
          if ped then
            self.ped = ped
          end
          if prop then
            self.prop = prop
          end
        end
        
        -- On exit: remove NPC and prop
        function point:onExit()
          if self.ped and DoesEntityExist(self.ped) then
            DeleteEntity(self.ped)
            self.ped = nil
          end
          
          if self.prop and DoesEntityExist(self.prop) then
            DeleteEntity(self.prop)
            self.prop = nil
          end
        end
        
        -- Store point reference
        local pointIndex = #pointIds + 1
        pointIds[pointIndex] = point
        
        -- Create target interaction zone
        local targetIndex = #targetIds + 1
        targetIds[targetIndex] = Bridge.Target.addSphereZone({
          coords = pointData.coords,
          radius = 0.75,
          options = {
            {
              name = "p_ambulancejob/insurance_" .. hospitalId,
              label = locale("get_insurance"),
              icon = "fa-solid fa-file-invoice",
              distance = 2.0,
              onSelect = function()
                Insurance:menu(hospitalId)
              end
            }
          }
        })
      end
    end
  end)
end

-- Show insurance menu with current insurance and purchase options
function Insurance.menu(self, hospitalId)
  -- Get current insurance from server
  local currentInsurance = lib.callback.await("p_ambulancejob/server/insurance/getInsurance", false)
  
  local options = {}
  
  -- First option: Display current insurance status
  local statusTitle = currentInsurance 
    and locale("your_insurance", currentInsurance.name) 
    or locale("no_current_insurance")
  
  local statusDescription
  if currentInsurance then
    local daysLeft = math.floor((currentInsurance.timeLeft or 0) / 24 / 60 / 60)
    statusDescription = locale("insurance_expires_in", daysLeft)
  else
    statusDescription = locale("no_insurance_desc")
  end
  
  options[1] = {
    title = statusTitle,
    description = statusDescription
  }
  
  -- Add purchase options for each insurance plan
  for insuranceId, insuranceData in pairs(Config.Insurance.options) do
    local optionIndex = #options + 1
    local daysValid = math.floor(insuranceData.duration / 24 / 60 / 60)
    
    options[optionIndex] = {
      title = insuranceData.label,
      description = locale("buy_insurance", insuranceData.price, daysValid),
      onSelect = function()
        -- Show confirmation dialog
        local daysValidConfirm = math.floor(insuranceData.duration / 24 / 60 / 60)
        local response = lib.alertDialog({
          header = locale("confirm_purchase"),
          content = locale("confirm_insurance", insuranceData.label, insuranceData.price, daysValidConfirm),
          centered = true,
          cancel = true
        })
        
        if response ~= "confirm" then
          return
        end
        
        -- Purchase insurance
        TriggerServerEvent("p_ambulancejob/server/insurance/buyInsurance", insuranceId, hospitalId)
      end
    }
  end
  
  -- Register and show menu
  lib.registerContext({
    id = "insurance_menu",
    title = locale("insurance_menu"),
    options = options
  })
  
  lib.showContext("insurance_menu")
end

-- Initialize insurance system
Citizen.CreateThread(function()
  Insurance:init()
end)