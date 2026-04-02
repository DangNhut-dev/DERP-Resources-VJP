-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================



-- Global tracking arrays for cleanup
targetIds = {}
pointIds = {}

-- Test function for GlobalState access
function test()
  local schools = GlobalState["p_dmvsool/Schools"]
  if schools and schools[k] then
    return schools[k].theoryQuestions
  end
end

-- Disable spawn manager auto-spawn if present
Citizen.CreateThread(function()
  Citizen.Wait(1000)
  
  if GetResourceState("spawnmanager") == "started" then
    exports.spawnmanager:setAutoSpawn(false)
  end
end)

-- Main initialization thread: Setup hospitals, duty points, wardrobes, and management
Citizen.CreateThread(function()
  Citizen.Wait(1000)
  
  -- Wait for hospital config to load
  while not Config.Hospitals do
    Wait(100)
  end
  
  -- Setup each hospital's features
  for hospitalId, hospitalData in pairs(Config.Hospitals) do
    local isSelectedHospital, jobRestriction = Utils:isSelectedHospital(hospitalId)
    
    if isSelectedHospital then
      -- Create hospital blip
      if hospitalData.blip and hospitalData.blip.enabled then
        Utils:createBlip({
          sprite = hospitalData.blip.sprite,
          color = hospitalData.blip.color,
          scale = hospitalData.blip.scale,
          name = hospitalData.blip.name or locale("hospital"),
          coords = hospitalData.blip.coords
        })
      end
      
      -- Setup duty point
      if hospitalData.duty and hospitalData.duty.enabled then
        -- Create NPC at duty point if configured
        if hospitalData.duty.ped then
          local dutyPoint = lib.points.new({
            coords = vec3(hospitalData.duty.coords.xyz),
            distance = 25
          })
          
          function dutyPoint:onEnter()
            local ped, prop = Utils:createPed({
              model = hospitalData.duty.ped,
              coords = hospitalData.duty.coords,
              anim = hospitalData.duty.anim,
              prop = hospitalData.duty.prop
            })
            self.ped = ped
            self.prop = prop
          end
          
          function dutyPoint:onExit()
            if self.ped and DoesEntityExist(self.ped) then
              DeleteEntity(self.ped)
              self.ped = nil
            end
            if self.prop and DoesEntityExist(self.prop) then
              DeleteEntity(self.prop)
              self.prop = nil
            end
          end
          
          pointIds[#pointIds + 1] = dutyPoint
        end
        
        -- Create duty interaction zone
        local dutyTargetIndex = #targetIds + 1
        targetIds[dutyTargetIndex] = Bridge.Target.addSphereZone({
          coords = hospitalData.duty.coords,
          radius = 0.75,
          options = {
            {
              name = "p_ambulancejob/startDuty_" .. hospitalId,
              label = locale("go_on_duty"),
              icon = "fa-solid fa-clipboard-check",
              distance = 2.0,
              groups = hospitalData.jobs,
              onSelect = function()
                TriggerServerEvent("p_ambulancejob/server/editable/setDuty", true)
              end
            },
            {
              name = "p_ambulancejob/endDuty_" .. hospitalId,
              label = locale("go_off_duty"),
              icon = "fa-solid fa-clipboard",
              distance = 2.0,
              groups = hospitalData.jobs,
              onSelect = function()
                TriggerServerEvent("p_ambulancejob/server/editable/setDuty", false)
              end
            }
          }
        })
      end
      
      -- Setup wardrobe
      if hospitalData.wardrobe then
        local wardrobeTargetIndex = #targetIds + 1
        targetIds[wardrobeTargetIndex] = Bridge.Target.addSphereZone({
          coords = hospitalData.wardrobe,
          radius = 0.75,
          options = {
            {
              name = "p_ambulancejob/openWardrobe_" .. hospitalId,
              label = locale("open_wardrobe"),
              icon = "fa-solid fa-shirt",
              distance = 2.0,
              groups = hospitalData.jobs,
              onSelect = function()
                Outfits:select()
              end
            }
          }
        })
      end
      
      -- Setup management (boss menu)
      if hospitalData.management then
        -- Build allowed grades per job
        local allowedGrades = {}
        for _, jobName in ipairs(hospitalData.jobs) do
          allowedGrades[jobName] = hospitalData.management.allowedGrades or {0}
        end
        
        local managementTargetIndex = #targetIds + 1
        targetIds[managementTargetIndex] = Bridge.Target.addSphereZone({
          coords = hospitalData.management.coords,
          radius = 0.75,
          options = {
            {
              name = "p_ambulancejob/openManagement_" .. hospitalId,
              label = locale("open_boss_menu"),
              icon = "fa-solid fa-briefcase-medical",
              distance = 2.0,
              onSelect = function()
                if Bridge.BossMenu then
                  Bridge.BossMenu.openMenu()
                else
                  lib.print.error("Your Boss Menu script is not supported or you doesnt have one! Please contact with us on discord.gg/piotreqscripts!")
                end
              end,
              canInteract = function()
                local playerJob = Bridge.Framework.fetchPlayerJob()
                if not playerJob then
                  return true
                end
                
                local jobGrades = allowedGrades[playerJob.name]
                if not jobGrades then
                  return false
                end
                
                return lib.table.contains(jobGrades, playerJob.grade)
              end
            }
          }
        })
      end
    end
  end
  
  -- Wait for shops config to load
  while not Config.Shops do
    Wait(100)
  end
  
  -- Setup each shop
  for shopId, shopData in pairs(Config.Shops) do
    local isSelectedHospital, jobRestriction = Utils:isSelectedHospital(shopId)
    
    if isSelectedHospital then
      -- Create shop blip
      if shopData.blip then
        local jobRestrictionForBlip = (isSelectedHospital or shopData.jobRestricted) and jobRestriction or nil
        
        Utils:createBlip({
          sprite = shopData.blip.sprite,
          color = shopData.blip.color,
          scale = shopData.blip.scale,
          name = shopData.blip.name or locale("shop"),
          coords = shopData.coords,
          jobs = jobRestrictionForBlip
        })
      end
      
      -- Create shop NPC if configured
      if shopData.ped then
        local shopPoint = lib.points.new({
          coords = vec3(shopData.coords.xyz),
          distance = 10
        })
        
        function shopPoint:onEnter()
          local ped, prop = Utils:createPed({
            model = shopData.ped,
            coords = shopData.coords,
            anim = shopData.anim,
            prop = shopData.prop
          })
          self.ped = ped
          self.prop = prop
        end
        
        function shopPoint:onExit()
          if self.ped and DoesEntityExist(self.ped) then
            DeleteEntity(self.ped)
            self.ped = nil
          end
          if self.prop and DoesEntityExist(self.prop) then
            DeleteEntity(self.prop)
            self.prop = nil
          end
        end
        
        pointIds[#pointIds + 1] = shopPoint
      end
      
      -- Create shop interaction zone
      local jobRestrictionForTarget = (isSelectedHospital or shopData.jobRestricted) and jobRestriction or nil
      local shopTargetIndex = #targetIds + 1
      
      targetIds[shopTargetIndex] = Bridge.Target.addSphereZone({
        coords = shopData.coords,
        radius = shopData.radius or 0.75,
        options = {
          {
            name = "p_ambulancejob/openShop_" .. shopId,
            label = locale("open_shop", shopData.label),
            icon = "fa-solid fa-cart-shopping",
            groups = jobRestrictionForTarget,
            distance = 2.0,
            onSelect = function()
              Bridge.Inventory.openInventory("shop", {
                type = shopId,
                id = 1,
                items = shopData.items
              })
            end
          }
        }
      })
    end
  end
end)

-- Cleanup on resource stop
AddEventHandler("onResourceStop", function(resourceName)
  if resourceName == GetCurrentResourceName() then
    -- Clean up all spawned entities
    for _, point in ipairs(pointIds) do
      point:onExit()
    end
  end
end)