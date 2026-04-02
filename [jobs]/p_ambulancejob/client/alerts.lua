-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================


-- Wait for Config to be loaded
while not (Config and Config.Alerts) do
  Wait(100)
end

-- Test function (debugging remnant)
function test()
  local schools = GlobalState["p_dmvschool/Schools"]
  if schools and schools[k] then
    return schools[k].theoryQuestions
  end
end

-- Initialize Alerts module
Alerts = {
  _index = Alerts,
  blips = {}
}

-- Register blip category for alerts
Citizen.CreateThread(function()
  AddTextEntry("BLIP_CAT_14", locale("ambulance_alerts"))
end)

-- Opens the alerts menu showing all active EMS calls
function Alerts.open(self)
  -- Check if player has ambulance job
  local playerJob = Bridge.Framework.fetchPlayerJob()
  if not playerJob then
    return
  end
  
  -- Ensure allJobs is initialized
  if not Editable.allJobs then
    Editable:getAllJobs()
  end
  
  if not Editable.allJobs[playerJob.name] then
    return
  end

  -- Build menu options from GlobalState alerts
  local options = {}
  local alerts = GlobalState["p_ambulancejob/Alerts"] or {}

  for index, alert in pairs(alerts) do
    options[#options + 1] = {
      title = string.format("%s - %s", alert.code, alert.title),
      description = alert.message,
      icon = "fa-solid fa-ambulance",
      onSelect = function()
        -- Show detailed alert context menu
        local streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(
          alert.coords.x,
          alert.coords.y,
          alert.coords.z
        ))

        lib.registerContext({
          id = "ambulance_alert",
          title = string.format("%s - %s", alert.code, alert.title),
          options = {
            -- Alert message
            {
              title = alert.message,
              description = locale("alert_message"),
              icon = "fa-solid fa-comment",
              color = "white",
              readOnly = true
            },
            -- Street location
            {
              title = streetName,
              icon = "fa-solid fa-location-crosshairs",
              color = "yellow",
              description = locale("alert_street")
            },
            -- Send message to patient
            {
              title = locale("alert_send_message"),
              description = locale("alert_send_message_desc"),
              icon = "fa-solid fa-paper-plane",
              color = "orange",
              onSelect = function()
                local input = lib.inputDialog(locale("alert_send_message"), {
                  {
                    type = "input",
                    label = locale("message_to_patient"),
                    required = true,
                    icon = "fa-solid fa-comment"
                  }
                })

                if not input then
                  return
                end

                TriggerServerEvent("p_ambulancejob/server/alerts/message", alert.id, input[1])
              end
            },
            -- Set GPS waypoint
            {
              title = locale("alert_set_gps"),
              description = locale("alert_set_gps_desc"),
              icon = "fa-solid fa-location-dot",
              color = "blue",
              onSelect = function()
                SetNewWaypoint(alert.coords.x, alert.coords.y)
                Bridge.Notify.showNotify(locale("alert_gps_set"), "success")
              end
            },
            -- Mark as resolved
            {
              title = locale("alert_mark_resolved"),
              description = locale("alert_mark_resolved_desc"),
              icon = "fa-solid fa-check",
              color = "green",
              onSelect = function()
                TriggerServerEvent("p_ambulancejob/server/alerts/resolve", alert.id)
              end
            }
          }
        })

        lib.showContext("ambulance_alert")
      end
    }
  end

  -- Register and show main alerts menu
  lib.registerContext({
    id = "ambulance_alerts",
    title = locale("ambulance_alerts"),
    options = options
  })

  lib.showContext("ambulance_alerts")
end

-- Setup keybind if configured
if Config.Alerts.menuKey and type(Config.Alerts.menuKey) == "string" then
  lib.addKeybind({
    name = "ambulance_alerts1",
    description = locale("open_ambulance_alerts"),
    defaultKey = Config.Alerts.menuKey,
    onPressed = function()
      Alerts:open()
    end
  })
end

-- Setup command if configured
if Config.Alerts.menuCommand and type(Config.Alerts.menuCommand) == "string" then
  RegisterCommand(Config.Alerts.menuCommand, function()
    Alerts:open()
  end)
end


-- Export: Open dispatch menu
exports("openDispatch", function()
  Alerts:open()
end)

-- Export: Get all active alerts
exports("getDispatchAlerts", function()
  return GlobalState["p_ambulancejob/Alerts"] or {}
end)

-- Export: Resolve alert for specific player
exports("resolvePlayerAlert", function(playerId)
  local alerts = GlobalState["p_ambulancejob/Alerts"] or {}
  
  for index, alert in pairs(alerts) do
    if alert.player == playerId then
      TriggerServerEvent("p_ambulancejob/server/alerts/resolve", alert.id)
      break
    end
  end
end)


-- Manages map blips when alerts change
AddStateBagChangeHandler("p_ambulancejob/Alerts", "global", function(bagName, key, newAlerts)
  -- Check if player has ambulance job
  local playerJob = Bridge.Framework.fetchPlayerJob()
  if not playerJob then
    -- Clean up all blips if player is not EMS
    for index, blipPair in pairs(Alerts.blips) do
      if DoesBlipExist(blipPair[1]) then
        RemoveBlip(blipPair[1])
      end
      if blipPair[2] and DoesBlipExist(blipPair[2]) then
        RemoveBlip(blipPair[2])
      end
    end
    Alerts.blips = {}
    return
  end
  
  -- Ensure allJobs is initialized
  if not Editable.allJobs then
    Editable:getAllJobs()
  end
  
  if not Editable.allJobs[playerJob.name] then
    -- Clean up all blips if player is not EMS
    for index, blipPair in pairs(Alerts.blips) do
      if DoesBlipExist(blipPair[1]) then
        RemoveBlip(blipPair[1])
      end
      if blipPair[2] and DoesBlipExist(blipPair[2]) then
        RemoveBlip(blipPair[2])
      end
    end
    Alerts.blips = {}
    return
  end

  -- Remove blips for alerts that no longer exist
  for index, blipPair in pairs(Alerts.blips) do
    if not newAlerts[index] then
      if DoesBlipExist(blipPair[1]) then
        RemoveBlip(blipPair[1])
      end
      if blipPair[2] and DoesBlipExist(blipPair[2]) then
        RemoveBlip(blipPair[2])
      end
      Alerts.blips[index] = nil
    end
  end

  -- Create blips for new alerts
  for index, alert in pairs(newAlerts) do
    if not Alerts.blips[index] then
      -- Create main blip
      local mainBlip = AddBlipForCoord(alert.coords.x, alert.coords.y, alert.coords.z)
      SetBlipSprite(mainBlip, alert.blip.sprite)
      SetBlipColour(mainBlip, alert.blip.color)
      SetBlipScale(mainBlip, alert.blip.scale)
      SetBlipCategory(mainBlip, 14) -- Emergency category
      SetBlipAsShortRange(mainBlip, true)
      
      -- Set blip name
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(string.format("%s - %s", alert.code, alert.title))
      EndTextCommandSetBlipName(mainBlip)

      -- Create pulse blip if enabled
      local pulseBlip = nil
      if alert.blip.pulse then
        pulseBlip = AddBlipForCoord(alert.coords.x, alert.coords.y, alert.coords.z)
        SetBlipSprite(pulseBlip, 161) -- Radius sprite
        SetBlipColour(pulseBlip, alert.blip.color)
        SetBlipScale(pulseBlip, 2.0)
        SetBlipAsShortRange(pulseBlip, true)
      end

      -- Store blip references
      Alerts.blips[index] = {mainBlip, pulseBlip}

      -- Notify player of new alert
      Bridge.Notify.showNotify(locale("new_alert"), "inform")
    end
  end
end)