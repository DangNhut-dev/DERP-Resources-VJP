-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================



-- Initialize Outfits object
Outfits = {}

-- Test function for GlobalState access
function test()
  local schools = GlobalState["p_dmvschool/Schools"]
  if schools and schools[k] then
    return schools[k].theoryQuestions
  end
end

-- Show outfit selection menu
function Outfits.select(self)
  local playerJob = Bridge.Framework.fetchPlayerJob()
  
  -- Check if player has access
  if not (playerJob and Editable.allJobs[playerJob.name]) then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  -- Determine player gender
  local pedModel = GetEntityModel(cache.ped)
  local gender = (pedModel == -1667301416) and "female" or "male"
  
  -- Get available outfits from server
  local outfits = lib.callback.await("p_ambulancejob/server/outfits/getOutfits", false, gender)
  
  if not outfits then
    return
  end
  
  local options = {}
  
  -- First option: Set private/civilian outfit
  options[1] = {
    title = locale("set_private_outfit"),
    description = locale("set_private_outfit_info"),
    arrow = true,
    onSelect = function()
      local skinData = Bridge.Appearance and Bridge.Appearance.fetchDatabaseSkin()
      
      if not skinData then
        return lib.print.error("No skin data found, make sure you are using supported appearance script")
      end
      
      Editable:playClothesAnim()
      Bridge.Appearance.setPlayerClothing(skinData, "private")
    end
  }
  
  -- Add job outfit options
  for i = 1, #outfits do
    local optionIndex = #options + 1
    
    options[optionIndex] = {
      title = outfits[i].label,
      description = locale("set_medic_outfit", outfits[i].label),
      arrow = true,
      onSelect = function()
        Editable:playClothesAnim()
        Bridge.Appearance.setPlayerClothing(outfits[i].skin, "job")
      end
    }
  end
  
  -- Register and show menu
  lib.registerContext({
    id = "medic_outfits_menu",
    title = locale("medic_outfits_menu"),
    options = options
  })
  
  lib.showContext("medic_outfits_menu")
end

-- Remove existing outfits (requires management access)
function Outfits.remove(self)
  local playerJob = Bridge.Framework.fetchPlayerJob()
  local requiredGrade = Config.Outfits.access[playerJob.name]
  
  -- Check if player has management access
  if requiredGrade and requiredGrade > tonumber(playerJob.grade) then
    return
  end
  
  -- Get all outfits from server
  local allOutfits = lib.callback.await("p_ambulancejob/server/outfits/getAllOutfits", false)
  
  -- Build selection options
  local outfitOptions = {}
  for i = 1, #allOutfits do
    outfitOptions[i] = {
      label = string.format("%s [%s]", allOutfits[i].label, allOutfits[i].job),
      value = allOutfits[i].id
    }
  end
  
  -- Show selection dialog
  local input = lib.inputDialog(locale("remove_outfit_menu"), {
    {
      type = "multi-select",
      icon = "shirt",
      options = outfitOptions,
      label = locale("select_outfit"),
      required = true
    }
  })
  
  if not input then
    return
  end
  
  -- Remove selected outfits
  TriggerServerEvent("p_ambulancejob/server/outfits/removeOutfits", input[1])
end

-- Create new outfit (requires management access)
function Outfits.create(self)
  local playerJob = Bridge.Framework.fetchPlayerJob()
  local requiredGrade = Config.Outfits.access[playerJob.name]
  
  -- Check if player has management access
  if requiredGrade and requiredGrade > tonumber(playerJob.grade) then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  -- Get job data from server (available grades, licenses, etc.)
  local jobData = lib.callback.await("p_ambulancejob/server/outfits/getJobData", false)
  
  if not jobData then
    return lib.print.error("No job data received from server for outfits")
  end
  
  -- Show outfit creation dialog
  local input = lib.inputDialog(locale("create_outfit"), {
    -- Job name
    {
      type = "input",
      icon = "briefcase",
      default = jobData.jobName,
      label = locale("set_outfit_job"),
      required = true
    },
    -- Required grades
    {
      type = "multi-select",
      icon = "briefcase",
      options = jobData.grades,
      label = locale("set_outfit_grade"),
      required = true
    },
    -- Outfit label/name
    {
      type = "input",
      icon = "sign",
      default = "Example outfit",
      label = locale("set_outfit_label"),
      required = true
    },
    -- Gender
    {
      type = "select",
      icon = "venus-mars",
      default = "male",
      label = locale("set_outfit_gender"),
      required = true,
      options = {
        {value = "male", label = locale("male")},
        {value = "female", label = locale("female")}
      }
    },
    -- Required licenses
    {
      type = "multi-select",
      icon = "id-badge",
      options = jobData.licenses,
      label = locale("set_outfit_license"),
      required = false
    },
    -- Requirement type
    {
      type = "select",
      default = "required_grade",
      label = locale("set_outfit_requirements"),
      required = true,
      options = {
        {value = "required_grade", label = locale("required_only_grade")},
        {value = "required_license", label = locale("required_only_license")},
        {value = "required_both", label = locale("required_both")}
      }
    }
  })
  
  if not input then
    return
  end
  
  -- Get current player appearance
  local currentSkin = Bridge.Appearance and Bridge.Appearance.fetchCurrentSkin()
  
  if not currentSkin then
    return lib.print.error("No skin data found for outfit, make sure you are using supported appearance script")
  end
  
  -- Send outfit data to server
  TriggerServerEvent("p_ambulancejob/server/outfits/createOutfit", input, currentSkin)
end

-- Command: Create medic outfit
RegisterCommand("medicOutfit", function()
  if not Config.Outfits.enabled then
    return
  end
  
  Outfits:create()
end)

-- Command: Remove medic outfit
RegisterCommand("removeMedicOutfit", function()
  if not Config.Outfits.enabled then
    return
  end
  
  Outfits:remove()
end)