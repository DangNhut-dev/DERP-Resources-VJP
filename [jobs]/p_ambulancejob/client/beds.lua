-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================


-- Wait for Config to be loaded
while not (Config and Config.Beds) do
  Wait(100)
end

-- Exit early if bed system is disabled
if not Config.Beds.enabled then
  return
end

-- Test function (debugging remnant)
function test()
  local schools = GlobalState["p_dmvschool/Schools"]
  if schools and schools[k] then
    return schools[k].theoryQuestions
  end
end

-- Initialize Beds module
Beds = {
  players = {} -- Tracks players on beds
}


Citizen.CreateThread(function()
  -- Initialize player state
  Wait(1000)
  LocalPlayer.state:set("playerOnBed", nil, true)

  -- Collect all unique bed models
  local bedModels = {}
  for model, config in pairs(Config.Beds.models) do
    if not lib.table.contains(bedModels, model) then
      bedModels[#bedModels + 1] = model
    end
  end

  -- Register target interaction for bed models
  Bridge.Target.addModel(bedModels, {
    {
      name = "Lay_on_Bed",
      label = locale("lay_on_bed"),
      icon = "fa-solid fa-bed",
      distance = 2,
      onSelect = function(entity)
        -- Extract entity from data
        local bedEntity = (type(entity) == "number") and entity or entity.entity
        if not bedEntity then
          return
        end

        -- Get bed model
        local bedModel = GetEntityModel(bedEntity)
        if not bedModel then
          return
        end

        -- Verify it's a configured bed
        local bedConfig = Config.Beds.models[bedModel]
        if not bedConfig then
          return
        end

        -- Use the bed
        Beds:use(bedEntity)
      end
    }
  })

  -- Create target zones for specific bed coordinates
  if Config.Beds.coords and #Config.Beds.coords > 0 then
    for index = 1, #Config.Beds.coords do
      local bedCoord = Config.Beds.coords[index]

      Bridge.Target.addSphereZone({
        coords = bedCoord.target,
        size = vec3(1.5, 1.5, 2.0),
        rotation = bedCoord.target.w or 0,
        debug = false,
        options = {
          {
            name = "Lay_on_Bed_Coords_" .. index,
            label = locale("lay_on_bed"),
            icon = "fa-solid fa-bed",
            distance = 2,
            onSelect = function()
              -- Prevent using if already on a bed
              if Beds.currentBed then
                return
              end

              -- Set player state to this specific bed location
              LocalPlayer.state:set("playerOnBed", "coords_" .. index, true)
            end
          }
        }
      })
    end
  end
end)


-- Uses a bed (when interacting with bed entity)
function Beds.use(self, bedEntity)
  local bedModel = joaat(GetEntityModel(bedEntity))
  local bedConfig = Config.Beds.models[bedModel]

  if not bedConfig then
    return
  end

  -- Prevent using if already on a bed
  if self.currentBed then
    return
  end

  -- Set player state
  LocalPlayer.state:set("playerOnBed", bedModel, true)
end

-- Export: Check if player is on a bed
exports("isPlayerOnBed", function(playerId)
  return Player(playerId).state.playerOnBed ~= nil
end)

-- Finds closest bed object near coordinates
function Beds.getClosestBed(self, bedModel, coords)
  local nearbyObjects = lib.getNearbyObjects(coords, 4.0)

  for i = 1, #nearbyObjects do
    local object = nearbyObjects[i]
    local objectModel = joaat(GetEntityModel(object.object))

    if objectModel == bedModel then
      return object.object
    end
  end

  return nil
end

-- Manages bed animation thread
function Beds.thread(self)
  Citizen.CreateThread(function()
    -- Load animation
    local animDict = lib.requestAnimDict(self.currentBed.anim.dict)

    -- Start animation
    TaskPlayAnim(
      cache.ped,
      animDict,
      self.currentBed.anim.clip,
      -8.0,
      8.0,
      -1,
      self.currentBed.anim.flag or 1,
      1.0
    )

    -- Keep animation playing while on bed
    while self.currentBed do
      Wait(1000)

      -- Re-play animation if player is dead and animation stopped
      if self.currentBed and Death.deathType ~= "none" then
        if not IsEntityPlayingAnim(cache.ped, animDict, self.currentBed.anim.clip, 3) then
          TaskPlayAnim(
            cache.ped,
            animDict,
            self.currentBed.anim.clip,
            -8.0,
            8.0,
            -1,
            self.currentBed.anim.flag or 1,
            1.0
          )
        end
      end
    end

    -- Clean up animation dictionary
    RemoveAnimDict(animDict)
  end)
end


-- Handles player bed state changes
AddStateBagChangeHandler("playerOnBed", nil, function(bagName, key, value, reserved, replicated)
  -- Ignore replicated state changes
  if replicated then
    return
  end

  -- Get player from state bag
  local player = GetPlayerFromStateBagName(bagName)
  if player == 0 then
    return
  end

  local ped = GetPlayerPed(player)
  local serverId = GetPlayerServerId(player)

  -- Skip if this is the local player (handled elsewhere)
  if serverId ~= cache.serverId and ped == cache.ped then
    return
  end

  -- Player is getting on a bed
  if value then
    -- Check if using coordinate-based bed
    if type(value) == "string" and value:find("coords_") then
      -- Extract bed index
      local bedIndexStr = value:gsub("coords_", "")
      local bedIndex = tonumber(bedIndexStr)
      if not bedIndex then
        return
      end

      -- Get bed configuration
      local bedCoord = Config.Beds.coords[bedIndex]
      if not bedCoord then
        return
      end

      local targetCoords = bedCoord.target
      local offsetCoords = bedCoord.offset

      -- Store player's current offset for later detachment
      Beds.players[serverId] = {
        offset = GetEntityCoords(ped)
      }

      Wait(10)

      -- Position player at bed
      SetEntityCoordsNoOffset(ped, offsetCoords.x, offsetCoords.y, offsetCoords.z, true, true, true)
      SetEntityHeading(ped, offsetCoords.w or 0.0)

      -- Setup local player bed state
      if serverId == cache.serverId then
        Beds.currentBed = {
          entity = nil,
          anim = Config.Beds.anims[math.random(1, #Config.Beds.anims)]
        }

        Beds:thread()
        lib.showTextUI(locale("get_off_bed_text"), {position = "left-center"})
      end
    else
      -- Using entity-based bed
      local bedEntity = Beds:getClosestBed(value, GetEntityCoords(ped))

      if bedEntity then
        local bedConfig = Config.Beds.models[value]

        -- Attach player to bed
        AttachEntityToEntity(
          ped,
          bedEntity,
          0,
          bedConfig.offset,
          bedConfig.rot,
          false,
          true,
          true,
          false,
          2,
          true
        )

        -- Store bed info for detachment
        Beds.players[serverId] = {
          entity = bedEntity,
          detach = bedConfig.detach or vec3(0.0, -1.0, 0.0)
        }

        -- Setup local player bed state
        if serverId == cache.serverId then
          Beds.currentBed = {
            entity = bedEntity,
            anim = Config.Beds.anims[math.random(1, #Config.Beds.anims)]
          }

          Beds:thread()
          lib.showTextUI(locale("get_off_bed_text"), {position = "left-center"})
        end
      end
    end
  else
    -- Player is getting off bed
    local playerBedData = Beds.players[serverId]
    if not playerBedData then
      return
    end

    -- Calculate detach position
    local detachCoords
    if playerBedData.offset then
      -- For coordinate-based beds, use stored offset
      detachCoords = playerBedData.offset
    else
      -- For entity-based beds, calculate offset from bed
      detachCoords = GetOffsetFromEntityInWorldCoords(
        playerBedData.entity,
        playerBedData.detach
      )
    end

    -- Detach and reposition player
    DetachEntity(ped, true, false)
    SetEntityCoordsNoOffset(ped, detachCoords.x, detachCoords.y, detachCoords.z, true, true, true)
    ClearPedTasks(ped)

    -- Remove from tracking
    Beds.players[serverId] = nil

    -- Clean up local player state
    if serverId == cache.serverId then
      if Beds.currentBed then
        Beds.currentBed = nil
        lib.hideTextUI()
      end
    end
  end
end)

-- Register keybind to get off bed
lib.addKeybind({
  name = "get_off_bed",
  description = locale("get_off_bed"),
  defaultKey = "X",
  onPressed = function()
    if Beds.currentBed then
      LocalPlayer.state:set("playerOnBed", nil, true)
    end
  end
})