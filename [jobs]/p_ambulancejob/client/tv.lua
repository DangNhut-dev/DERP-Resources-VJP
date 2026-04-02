-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================



-- Wait for Config.TV to be available
while not (Config and Config.TV) do
  Wait(1)
end

-- Exit if TV system is not enabled
if not Config.TV.enabled then
  return
end

-- Test function for GlobalState access
function test()
  local schools = GlobalState["p_dmvschool/Schools"]
  if schools and schools[k] then
    return schools[k].theoryQuestions
  end
end

-- Initialize TV object
TV = {
  tvs = {},
  currentPoint = nil
}

-- Create a TV display at specified location
function TV.create(self, hospitalId, tvId, tvData)
  local isSelectedHospital, jobRestriction = Utils:isSelectedHospital(hospitalId)
  
  if not isSelectedHospital then
    return
  end
  
  -- Initialize hospital TV array if needed
  if not self.tvs[hospitalId] then
    self.tvs[hospitalId] = {}
  end
  
  -- Store TV configuration
  self.tvs[hospitalId][tvId] = {
    coords = tvData.coords,
    rot = tvData.rot
  }
  
  -- Create interaction point for TV
  local point = lib.points.new({
    coords = vec3(tvData.coords.x, tvData.coords.y, tvData.coords.z),
    distance = 20.0
  })
  
  -- On enter: Create TV object and DUI screen
  function point:onEnter()
    -- Request and create TV model
    local modelHash = lib.requestModel("ex_prop_ex_tv_flat_01")
    local tvObject = CreateObject(modelHash, tvData.coords, false, true, true)
    self.tvObject = tvObject
    
    SetEntityRotation(tvObject, tvData.rot, 2, true)
    FreezeEntityPosition(tvObject, true)
    
    -- Get existing terminal data if available
    local terminalData = nil
    if GlobalState["p_ambulancejob/TV"] and 
       GlobalState["p_ambulancejob/TV"][hospitalId] and 
       GlobalState["p_ambulancejob/TV"][hospitalId][tvId] then
      terminalData = GlobalState["p_ambulancejob/TV"][hospitalId][tvId]
    end
    
    -- Create DUI (in-game browser) for TV screen
    local dui = lib.dui:new({
      url = string.format("nui://%s/web/tv.html", cache.resource),
      width = 1920,
      height = 1080,
      debug = (Bridge and Bridge.Config and Bridge.Config.Debug) or false
    })
    self.dui = dui
    
    -- Initialize terminal with data
    Citizen.Wait(1000)
    dui:sendMessage({
      action = "setTerminal",
      value = {
        data = terminalData or nil,
        locales = lib.getLocales()
      }
    })
    
    -- Store current point reference
    TV.currentPoint = {
      point = self,
      hospital = hospitalId,
      tv = tvId,
      dui = dui
    }
    
    -- Apply DUI texture to TV screen
    Citizen.Wait(10)
    AddReplaceTexture(
      "ex_prop_ex_tv_flat_01",
      "script_rt_ex_tvscreen",
      dui.dictName,
      dui.txtName
    )
    
    -- Add target interaction to clear terminal
    Bridge.Target.addLocalEntity(tvObject, {
      {
        name = "p_ambulancejob/clearTerminal",
        label = locale("clear_terminal"),
        icon = "fa-solid fa-trash",
        distance = 3.0,
        groups = jobRestriction,
        onSelect = function()
          TriggerServerEvent("p_ambulancejob/server/tv/setTerminal", {
            hospital = hospitalId,
            tv = tvId,
            clear = true
          })
        end
      }
    })
  end
  
  -- On exit: Clean up TV object and DUI
  function point:onExit()
    TV.currentPoint = nil
    RemoveReplaceTexture("ex_prop_ex_tv_flat_01", "script_rt_ex_tvscreen")
    
    -- Delete TV object
    if self.tvObject and DoesEntityExist(self.tvObject) then
      DeleteEntity(self.tvObject)
      self.tvObject = nil
    end
    
    -- Remove DUI
    if self.dui then
      pcall(function()
        self.dui:remove()
      end)
      self.dui = nil
    end
  end
end

-- State bag handler: Update TV terminal when data changes
AddStateBagChangeHandler("p_ambulancejob/TV", "global", function(bagName, key, value)
  if not TV.currentPoint then
    return
  end
  
  -- Get data for current TV
  local hospitalData = value[TV.currentPoint.hospital]
  if hospitalData then
    local terminalData = hospitalData[TV.currentPoint.tv]
    
    -- Update DUI with new terminal data
    TV.currentPoint.dui:sendMessage({
      action = "setTerminal",
      value = {
        data = terminalData or nil,
        locales = lib.getLocales()
      }
    })
  end
end)

-- Open terminal input dialog to set patient information
function TV.terminal(self)
  local playerJob = Bridge.Framework.fetchPlayerJob()
  
  -- Check if player has access
  if not (playerJob and Editable.allJobs[playerJob.name]) then
    Bridge.Notify.showNotify(locale("no_access"), "error")
    return
  end
  
  -- Build list of available TVs
  local tvOptions = {}
  local optionIndex = 1
  
  for hospitalId, tvList in pairs(Config.TV.points) do
    local hospitalConfig = Config.Hospitals[hospitalId]
    local isSelectedHospital, jobRestriction = Utils:isSelectedHospital(hospitalId)
    
    if isSelectedHospital and hospitalConfig then
      local hasJobAccess = lib.table.contains(hospitalConfig.jobs, playerJob.name)
      
      if hasJobAccess then
        for tvId, tvData in pairs(tvList) do
          tvOptions[optionIndex] = {
            label = tvId,
            value = tvId,
            hospital = hospitalId
          }
          optionIndex = optionIndex + 1
        end
      end
    end
  end
  
  if #tvOptions < 1 then
    Bridge.Notify.showNotify(locale("not_founded_tvs"), "error")
    return
  end
  
  -- Show input dialog
  local input = lib.inputDialog(locale("set_terminal"), {
    -- TV selection
    {
      type = "select",
      label = locale("select_tv"),
      options = tvOptions,
      required = true
    },
    -- Patient name
    {
      type = "input",
      label = locale("set_name")
    },
    -- Patient age
    {
      type = "number",
      label = locale("set_age"),
      min = 0,
      max = 100
    },
    -- Patient gender
    {
      type = "select",
      label = locale("set_gender"),
      options = {
        {value = locale("male"), label = locale("male")},
        {value = locale("female"), label = locale("female")}
      }
    },
    -- Patient condition
    {
      type = "select",
      label = locale("set_condition"),
      options = {
        {value = locale("stable"), label = locale("stable")},
        {value = locale("critical"), label = locale("critical")}
      }
    },
    -- ETA (minutes)
    {
      type = "number",
      label = locale("set_eta"),
      min = 0,
      max = 120,
      description = locale("set_eta_desc")
    }
  })
  
  if not input then
    return
  end
  
  -- Find which hospital the selected TV belongs to
  local selectedHospital = nil
  for _, tvOption in pairs(tvOptions) do
    if tvOption.value == input[1] then
      selectedHospital = tvOption.hospital
      break
    end
  end
  
  -- Send terminal data to server
  TriggerServerEvent("p_ambulancejob/server/tv/setTerminal", {
    hospital = selectedHospital,
    tv = input[1],
    name = input[2],
    age = input[3],
    gender = input[4],
    condition = input[5],
    eta = input[6]
  })
end

-- Command: Open terminal dialog
RegisterCommand("openTerminal", function()
  TV:terminal()
end, false)

-- Initialize all TV displays
Citizen.CreateThread(function()
  Citizen.Wait(2000)
  
  -- Wait for TV points config to load
  while not Config.TV.points do
    Wait(100)
  end
  
  -- Create all configured TVs
  for hospitalId, tvList in pairs(Config.TV.points) do
    for tvId, tvData in pairs(tvList) do
      TV:create(hospitalId, tvId, tvData)
    end
  end
end)

-- Cleanup on resource stop
AddEventHandler("onResourceStop", function(resourceName)
  if resourceName ~= cache.resource then
    return
  end
  
  -- Clean up current TV if exists
  if TV.currentPoint and TV.currentPoint.point and TV.currentPoint.point.onExit then
    pcall(function()
      TV.currentPoint.point:onExit()
    end)
  end
end)