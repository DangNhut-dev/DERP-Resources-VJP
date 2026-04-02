-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================



-- Initialize bridge and global references
Bridge = exports.p_bridge:getObject()
localState = LocalPlayer.state

-- Set locale from bridge config or default to English
lib.locale((Bridge and Bridge.Config and Bridge.Config.Language) or "en")

-- Initialize Utils object
Utils = {
  jobBlips = {}
}

-- Test function for GlobalState access
function test()
  local schools = GlobalState["p_dmvschool/Schools"]
  if schools and schools[k] then
    return schools[k].theoryQuestions
  end
end

-- NUI Callback: Load locales for UI
RegisterNUICallback("loadLocales", function(data, callback)
  callback(lib.getLocales())
end)

-- Check if a hospital ID is selected in config
function Utils.isSelectedHospital(self, hospitalId)
  local hospitalConfig = Config.Hospital
  local configType = type(hospitalConfig)
  
  -- Config.Hospital is a string (single hospital)
  if configType == "string" then
    if hospitalId == hospitalConfig or hospitalId:find(hospitalConfig) then
      local jobs = Config.Hospitals[hospitalConfig] and Config.Hospitals[hospitalConfig].jobs
      return true, jobs or nil
    end
  -- Config.Hospital is a table (multiple hospitals)
  elseif configType == "table" then
    for _, configHospital in pairs(hospitalConfig) do
      if hospitalId == configHospital or hospitalId:find(configHospital) then
        local jobs = Config.Hospitals[configHospital] and Config.Hospitals[configHospital].jobs
        return true, jobs or nil
      end
    end
  -- Config.Hospital is nil (all hospitals)
  else
    for configHospitalId, hospitalData in pairs(Config.Hospitals) do
      if configHospitalId:find(hospitalId) then
        return true, hospitalData.jobs or nil
      end
    end
  end
  
  return false
end

-- Get network ID from entity with timeout
function Utils.getNetId(self, entity)
  if not (entity and entity ~= 0 and DoesEntityExist(entity)) then
    return nil
  end
  
  local networkId = NetworkGetNetworkIdFromEntity(entity)
  local timeout = GetGameTimer() + 5000
  
  -- Wait for valid network ID with timeout
  while not networkId or networkId == 0 do
    Citizen.Wait(100)
    networkId = NetworkGetNetworkIdFromEntity(entity)
    
    if GetGameTimer() > timeout then
      break
    end
  end
  
  return networkId
end

-- Get entity from network ID with timeout
function Utils.getEntityFromNetId(self, networkId)
  if not (networkId and type(networkId) == "number" and networkId >= 1) then
    return nil
  end
  
  local entity = NetworkGetEntityFromNetworkId(networkId)
  local timeout = GetGameTimer() + 5000
  
  -- Wait for valid entity with timeout
  while not (entity and entity ~= 0 and DoesEntityExist(entity)) do
    Citizen.Wait(100)
    entity = NetworkGetEntityFromNetworkId(networkId)
    
    if GetGameTimer() > timeout then
      break
    end
  end
  
  return entity
end

-- Resurrect player at specified location
function Utils.resurrectPlayer(self, coords, heading)
  if not coords then
    coords = GetEntityCoords(cache.ped)
  end
  
  if not heading then
    heading = GetEntityHeading(cache.ped)
  end
  
  NetworkResurrectLocalPlayer(
    coords.x,
    coords.y,
    coords.z + 0.1,
    heading,
    true,
    false
  )
end

-- Fade screen out with duration
function Utils.fadeOutScreen(self, duration)
  DoScreenFadeOut(duration)
  
  while IsScreenFadingOut() do
    Citizen.Wait(50)
  end
end

-- Fade screen in with duration
function Utils.fadeInScreen(self, duration)
  DoScreenFadeIn(duration)
  
  while IsScreenFadingIn() do
    Citizen.Wait(50)
  end
end

-- Event: Update job blips when player data changes
RegisterNetEvent("p_bridge/client/setPlayerData", function(playerData)
  -- Remove existing job blips
  for _, blipData in pairs(Utils.jobBlips) do
    if blipData.blip then
      RemoveBlip(blipData.blip)
    end
    
    -- Check if player has job access to this blip
    local playerJobName = playerData and playerData.job and playerData.job.name
    local hasJobAccess = lib.table.contains(blipData.jobs, playerJobName)
    
    if hasJobAccess then
      -- Create new blip
      local blip = AddBlipForCoord(blipData.coords.x, blipData.coords.y, blipData.coords.z)
      
      SetBlipSprite(blip, blipData.sprite)
      SetBlipScale(blip, blipData.scale or 0.9)
      SetBlipColour(blip, blipData.color or 1)
      SetBlipAsShortRange(blip, true)
      
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentSubstringPlayerName(blipData.name or locale("hospital"))
      EndTextCommandSetBlipName(blip)
      
      blipData.blip = blip
    end
  end
end)

-- Create a map blip with optional job restriction
function Utils.createBlip(self, blipData)
  local blipIndex = #self.jobBlips + 1
  
  -- If job restricted, store for later update
  if blipData.jobs then
    self.jobBlips[blipIndex] = blipData
    
    -- Check if player currently has job access
    local playerJob = Bridge.Framework.fetchPlayerJob()
    local hasJobAccess = lib.table.contains(blipData.jobs, playerJob and playerJob.name)
    
    if not hasJobAccess then
      return
    end
  end
  
  -- Create blip
  local blip = AddBlipForCoord(blipData.coords.x, blipData.coords.y, blipData.coords.z)
  
  SetBlipSprite(blip, blipData.sprite)
  SetBlipScale(blip, blipData.scale or 0.9)
  SetBlipColour(blip, blipData.color or 1)
  SetBlipAsShortRange(blip, true)
  
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentSubstringPlayerName(blipData.name or locale("hospital"))
  EndTextCommandSetBlipName(blip)
  
  -- Store blip reference if job restricted
  if blipData.jobs then
    self.jobBlips[blipIndex].blip = blip
  end
  
  return blip
end

-- Create a ped with optional animation and prop
function Utils.createPed(self, pedData)
  -- Request and create ped
  local modelHash = lib.requestModel(pedData.model)
  local ped = CreatePed(
    4,
    modelHash,
    pedData.coords.x,
    pedData.coords.y,
    pedData.coords.z - 1.0,
    pedData.coords.w or 0.0,
    false,
    true
  )
  
  local prop = nil
  
  -- Make ped invincible and frozen
  SetEntityInvincible(ped, true)
  SetBlockingOfNonTemporaryEvents(ped, true)
  FreezeEntityPosition(ped, true)
  
  -- Apply animation if specified
  if pedData.anim then
    local animDict = lib.requestAnimDict(pedData.anim.dict)
    
    TaskPlayAnim(
      ped,
      pedData.anim.dict,
      pedData.anim.clip,
      8.0,
      -8.0,
      -1,
      pedData.anim.flag or 1,
      0,
      false,
      false,
      false
    )
    
    RemoveAnimDict(animDict)
  end
  
  -- Attach prop if specified
  if pedData.prop then
    local propModel = lib.requestModel(pedData.prop.model)
    prop = CreateObject(
      propModel,
      pedData.coords.x,
      pedData.coords.y,
      pedData.coords.z,
      false,
      true,
      true
    )
    
    AttachEntityToEntity(
      prop,
      ped,
      GetPedBoneIndex(ped, pedData.prop.bone),
      pedData.prop.coords,
      pedData.prop.rot,
      true,
      true,
      false,
      true,
      1,
      true
    )
    
    SetModelAsNoLongerNeeded(propModel)
  end
  
  SetModelAsNoLongerNeeded(modelHash)
  
  return ped, prop
end

-- Request network control of entity with timeout
function Utils.requestControl(self, entity)
  NetworkRequestControlOfEntity(entity)
  
  local timeout = GetGameTimer() + 5000
  
  -- Wait for control with timeout
  while not NetworkHasControlOfEntity(entity) do
    Citizen.Wait(100)
    NetworkRequestControlOfEntity(entity)
    
    if GetGameTimer() > timeout then
      break
    end
  end
end