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

-- Outfit management system
Outfits = {}

-- Helper function to check if player has outfit access
local function hasOutfitAccess(playerJob)
  local requiredGrade = Config.Outfits.access[playerJob.name]
  if not requiredGrade then
    return false
  end
  
  return tonumber(playerJob.grade) >= requiredGrade
end

-- Create a new outfit
function Outfits.new(self, sourcePlayer, outfitData, skinData)
  -- Parse grade requirements
  local gradeMap = {}
  for _, gradeId in ipairs(outfitData[2]) do
    gradeMap[tostring(gradeId)] = true
  end
  
  -- Parse license requirements if present
  local licenseMap = nil
  if outfitData[5] then
    licenseMap = {}
    for _, licenseType in ipairs(outfitData[5]) do
      licenseMap[licenseType] = true
    end
  end
  
  -- Prepare database parameters
  local params = {
    ["@job"] = outfitData[1],
    ["@grade"] = json.encode(gradeMap),
    ["@label"] = outfitData[3],
    ["@gender"] = outfitData[4],
    ["@license"] = licenseMap and json.encode(licenseMap) or "none",
    ["@requirements"] = outfitData[6],
    ["@skin"] = json.encode(skinData)
  }
  
  -- Insert outfit into database
  local insertId = MySQL.insert.await(
    "INSERT INTO medic_outfits (job, grade, label, gender, license, requirements, skin) VALUES (@job, @grade, @label, @gender, @license, @requirements, @skin)",
    params
  )
  
  if insertId then
    Bridge.Notify.showNotify(
      sourcePlayer,
      locale("outfit_created", outfitData[3], outfitData[1]),
      "success"
    )
  end
end

-- Remove outfits
function Outfits.remove(self, sourcePlayer, outfitIds)
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  
  -- Check access permissions
  if not hasOutfitAccess(playerJob) then
    return
  end
  
  -- Prepare outfit IDs for batch deletion
  local idsToDelete = {}
  for i, outfitId in ipairs(outfitIds) do
    idsToDelete[i] = {outfitId}
  end
  
  -- Delete outfits from database
  MySQL.prepare("DELETE FROM medic_outfits WHERE id = ?", idsToDelete)
  
  Bridge.Notify.showNotify(sourcePlayer, locale("outfits_removed"), "success")
end

-- Get outfits for a player based on their job, grade, and gender
function Outfits.getOutfits(self, sourcePlayer, playerGender)
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  local outfitList = {}
  
  -- Query all outfits for player's job
  local dbOutfits = MySQL.query.await(
    "SELECT * FROM medic_outfits WHERE job = ?",
    {playerJob.name}
  )
  
  for _, outfit in ipairs(dbOutfits) do
    -- Only process outfits matching player's gender
    if outfit.gender == playerGender then
      local gradeMap = json.decode(outfit.grade)
      local licenseMap = (outfit.license ~= "none") and json.decode(outfit.license) or nil
      
      -- Check if player meets grade requirement
      local hasGrade = gradeMap[tostring(playerJob.grade)]
      local hasLicense = false
      local requirements = outfit.requirements
      
      -- Determine if player meets license requirements
      if requirements == "required_license" or requirements == "required_both" then
        if licenseMap then
          local uniqueId = Bridge.Framework.getUniqueId(sourcePlayer)
          local playerLicenses = MySQL.query.await(
            "SELECT * FROM gmt_licenses WHERE owner = ?",
            {uniqueId}
          )
          
          -- Check if player has any required license
          for _, license in ipairs(playerLicenses) do
            if licenseMap[license.type] then
              hasLicense = true
              break
            end
          end
        end
      end
      
      -- Determine if player can access this outfit
      local canAccess = false
      
      if requirements == "required_both" then
        -- Needs both grade and license
        canAccess = hasGrade and hasLicense
      elseif requirements == "required_license" then
        -- Needs only license
        canAccess = hasLicense
      elseif requirements == "required_grade" then
        -- Needs only grade
        canAccess = hasGrade
      end
      
      -- Add outfit to list if accessible
      if canAccess then
        table.insert(outfitList, {
          label = outfit.label,
          skin = outfit.skin
        })
      end
    end
  end
  
  return outfitList
end

-- Event: Create a new outfit
RegisterNetEvent("p_ambulancejob/server/outfits/createOutfit", function(outfitData, skinData)
  local sourcePlayer = source
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  
  -- Check access permissions
  if not hasOutfitAccess(playerJob) then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  Outfits:new(sourcePlayer, outfitData, skinData)
end)

-- Event: Remove outfits
RegisterNetEvent("p_ambulancejob/server/outfits/removeOutfits", function(outfitIds)
  local sourcePlayer = source
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  
  -- Check access permissions
  if not hasOutfitAccess(playerJob) then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  Outfits:remove(sourcePlayer, outfitIds)
end)

-- Callback: Get job data (grades and licenses)
lib.callback.register("p_ambulancejob/server/outfits/getJobData", function(sourcePlayer)
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  
  if not playerJob or not playerJob.name then
    return nil
  end
  
  local jobData = {
    jobName = playerJob.name,
    grades = {},
    licenses = {}
  }
  
  -- Get all grades for the job
  local jobInfo = Bridge.Framework.getJobs()[jobData.jobName]
  
  -- Get licenses if GMT resource is running
  if GetResourceState("piotreq_gmt") == "started" then
    local gmtLicenses = exports.piotreq_gmt:getLicenses()[jobData.jobName]
    
    if gmtLicenses then
      for licenseId, licenseData in pairs(gmtLicenses) do
        table.insert(jobData.licenses, {
          value = licenseId,
          label = licenseData.label
        })
      end
    end
  end
  
  -- Build grade list
  for gradeId, gradeData in pairs(jobInfo) do
    table.insert(jobData.grades, {
      value = tostring(gradeId),
      label = gradeData.label
    })
  end
  
  return jobData
end)

-- Callback: Get outfits for player
lib.callback.register("p_ambulancejob/server/outfits/getOutfits", function(sourcePlayer, playerGender)
  return Outfits:getOutfits(sourcePlayer, playerGender)
end)

-- Callback: Get all outfits for management
lib.callback.register("p_ambulancejob/server/outfits/getAllOutfits", function(sourcePlayer)
  local playerJob = Bridge.Framework.getPlayerJob(sourcePlayer)
  
  return MySQL.query.await(
    "SELECT * FROM medic_outfits WHERE job = ?",
    {playerJob.name}
  )
end)