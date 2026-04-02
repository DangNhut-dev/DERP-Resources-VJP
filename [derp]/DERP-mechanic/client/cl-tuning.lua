function getVehicleTuningConfig(vehicle, tuningOptions)
  local currentConfig = {}
  local options = tuningOptions or Config.Tuning

  for category, _ in pairs(options) do
    local installedValue = false
    if tuningOptions then
      installedValue = tuningOptions[category]
    end

    if category == "turbocharging" then
      if IsToggleModOn(vehicle, 18) then
        installedValue = 1
      end
    end

    if category == "gearboxes" then
      local advancedFlags = getVehicleHandlingValue(vehicle, "CCarHandlingData", "strAdvancedFlags")
      if hasFlag(advancedFlags, ADV_HANDLING_FLAGS.MANUAL) then
        installedValue = 1
      end
    end
    currentConfig[category] = installedValue
  end
  return currentConfig
end

local function setVehicleTuningConfigStatebag(vehicle, tuningConfig)
  if not vehicle or not tuningConfig or type(tuningConfig) ~= "table" then
    print("^1[ERROR] Could not set vehicle tuning data statebag")
    return
  end
  return setVehicleStatebag(vehicle, "tuningConfig", tuningConfig, true)
end

RegisterNUICallback("install-tune", function(data, cb)
  local tuneCategory = data.tune
  local tuneOption = data.option
  local currentOption = data.currentOption
  local isInstalling = data.installed
  local tuningConfig = data.tuningConfig

  local tuneData = Config.Tuning[tuneCategory] and Config.Tuning[tuneCategory][tuneOption]
  if not tuneData then
    return cb(false)
  end

  local connectedVehicleData = LocalPlayer.state.tabletConnectedVehicle
  local vehicle = connectedVehicleData and connectedVehicleData.vehicleEntity
  local plate = connectedVehicleData and connectedVehicleData.plate

  if not DoesEntityExist(vehicle) then
    return cb(false)
  end

  local minigameType = "prop"
  local minigameOptions = { prop = "spanner" }

  if tuneCategory == "engineSwaps" then
    minigameType = "engineSwap"
  elseif tuneCategory == "tyres" then
    minigameOptions = { prop = "wheel" }
  end

  playMinigame(vehicle, minigameType, minigameOptions, function(success)
    showTabletAfterInteractionPrompt()
    SetNuiFocus(true, true)

    if not success then
      return cb(false)
    end

    local serverSuccess
    if isInstalling then
      serverSuccess = lib.callback.await("DERP-mechanic:server:pay-for-tune", false, tuneCategory, tuneOption, currentOption, plate)
      if not serverSuccess then
        return cb(false)
      end
      Framework.Client.Notify(Locale.partInstalled:format(tuneData.name), "success")
    else
      serverSuccess = lib.callback.await("DERP-mechanic:server:remove-tune", false, tuneCategory, tuneOption, plate)
      if not serverSuccess then
        return cb(false)
      end
      Framework.Client.Notify(Locale.partRemoved:format(tuneData.name), "success")
    end

    if setVehicleTuningConfigStatebag(vehicle, tuningConfig) then
      return cb(true)
    end

    return cb(false)
  end)
end)