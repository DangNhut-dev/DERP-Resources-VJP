-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================


-- Wait for Config.Elevators to be available
while not (Config and Config.Elevators) do
  Citizen.Wait(100)
end

-- Exit if elevators are not enabled
if not Config.Elevators.enabled then
  return
end

Elevators = {}

-- Test function for GlobalState access
function test()
  local schools = GlobalState["p_dmvschool/Schools"]
  if schools and schools[k] then
    return schools[k].theoryQuestions
  end
end

-- Teleport player to specified coordinates with fade effect
function Elevators.teleport(self, coords)
  DoScreenFadeOut(600)
  
  -- Wait for screen to fade out
  while not IsScreenFadedOut() do
    Citizen.Wait(10)
  end
  
  -- Move player to new coordinates
  SetEntityCoordsNoOffset(
    cache.ped,
    coords.x,
    coords.y,
    coords.z,
    true,
    true,
    true
  )
  
  -- Set player heading (default to 0.0 if not specified)
  SetEntityHeading(cache.ped, coords.w or 0.0)
  
  Citizen.Wait(500)
  DoScreenFadeIn(600)
end

-- Show elevator menu with floor options
function Elevators.menu(self, elevatorData)
  local options = {}
  
  -- Build menu options for each floor
  for floorIndex, floor in pairs(elevatorData.floors) do
    options[floorIndex] = {
      title = floor.label,
      description = locale("floor_desc", floor.label),
      icon = "fa-solid fa-arrow-up-right-dots",
      onSelect = function()
        self:teleport(floor.coords)
      end
    }
  end
  
  -- Register and show the context menu
  lib.registerContext({
    id = "elevator_menu",
    title = locale("elevator_menu"),
    options = options
  })
  
  lib.showContext("elevator_menu")
end

-- Initialize elevator interaction zones
Citizen.CreateThread(function()
  -- Wait for elevator points to be available
  while not Config.Elevators.points do
    Wait(100)
  end
  
  -- Create interaction zones for each hospital's elevators
  for hospitalId, elevators in pairs(Config.Elevators.points) do
    local isSelectedHospital, jobRestriction = Utils:isSelectedHospital(hospitalId)
    
    if isSelectedHospital then
      -- Create zones for each elevator in this hospital
      for elevatorIndex, elevator in pairs(elevators) do
        local targetIndex = #targetIds + 1
        
        -- Build unique zone name
        local zoneName = "p_ambulancejob/elevator_" .. hospitalId .. "_" .. elevatorIndex
        
        -- Determine job restriction
        local jobGroups = nil
        if elevator.jobRestricted then
          jobGroups = jobRestriction
        end
        
        -- Create sphere zone for elevator interaction
        targetIds[targetIndex] = Bridge.Target.addSphereZone({
          coords = elevator.coords,
          radius = 0.75,
          options = {
            {
              name = zoneName,
              label = locale("use_elevator"),
              icon = "fa-solid fa-elevator",
              distance = 2.0,
              groups = jobGroups,
              onSelect = function()
                Elevators:menu(elevator)
              end
            }
          }
        })
      end
    end
  end
end)