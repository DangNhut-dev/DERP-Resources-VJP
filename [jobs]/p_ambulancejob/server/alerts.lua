-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--		Cleaned By Said Ak Using Claude Sonnet 4.5
-- =====================================================


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
  alerts = {}
}

-- Sync alerts to GlobalState
GlobalState["p_ambulancejob/Alerts"] = Alerts.alerts

-- Initializes the alert cleanup thread
-- Removes expired alerts every 3 seconds
function Alerts.init(self)
  Citizen.CreateThread(function()
    while true do
      Wait(3000)

      local currentTime = os.time()
      local needsUpdate = false

      -- Check for expired alerts
      for index, alert in pairs(self.alerts) do
        if currentTime >= alert.expire then
          table.remove(self.alerts, index)
          needsUpdate = true
        end
      end

      -- Update GlobalState if any alerts were removed
      if needsUpdate then
        GlobalState["p_ambulancejob/Alerts"] = self.alerts
      end
    end
  end)
end

-- Creates a new alert
-- @param playerId number The player who triggered the alert
-- @param alertData table Alert configuration (code, title, message, coords, expire, blip)
function Alerts.new(self, playerId, alertData)
  if not playerId or playerId == 0 then
    return
  end

  -- Safely get player ped
  local success, ped = pcall(GetPlayerPed, playerId)
  if not (success and ped) or ped == 0 then
    return
  end

  -- Build alert object
  local alert = {
    id = #self.alerts + 1,
    player = playerId,
    code = alertData.code,
    title = alertData.title or "",
    message = alertData.message,
    coords = alertData.coords or GetEntityCoords(ped),
    expire = os.time() + (alertData.expire or 300), -- Default 5 minutes
    blip = alertData.blip
  }

  -- Add to alerts table
  self.alerts[#self.alerts + 1] = alert

  -- Sync to GlobalState
  GlobalState["p_ambulancejob/Alerts"] = self.alerts

  -- Log alert creation
  Bridge.Logs.Send(
    playerId,
    "Alert Created",
    "Player sent an alert to EMS",
    Webhooks and Webhooks.alerts or nil
  )
end

-- Resolves (removes) an alert by ID
-- @param alertId number The ID of the alert to resolve
function Alerts.resolve(self, alertId)
  for index, alert in pairs(self.alerts) do
    if alert.id == alertId then
      table.remove(self.alerts, index)
      GlobalState["p_ambulancejob/Alerts"] = self.alerts
      break
    end
  end
end

-- Sends a message to the player who created an alert
-- @param alertId number The ID of the alert
-- @param message string The message to send
function Alerts.message(self, alertId, message)
  for index, alert in pairs(self.alerts) do
    if alert.id == alertId then
      Bridge.Notify.showNotify(alert.player, message, "inform")
      break
    end
  end
end

-- Event: Create new alert
RegisterNetEvent("p_ambulancejob/server/alerts/new", function(alertData)
  local playerId = source
  Alerts:new(playerId, alertData)
end)

-- Event: Resolve alert
RegisterNetEvent("p_ambulancejob/server/alerts/resolve", function(alertId)
  local playerId = source
  Alerts:resolve(alertId)
  Bridge.Notify.showNotify(playerId, locale("alert_marked_resolved"), "success")
end)

-- Event: Send message to alert creator
RegisterNetEvent("p_ambulancejob/server/alerts/message", function(alertId, message)
  Alerts:message(alertId, message)
end)

-- Export: Get all active alerts
exports("getDispatchAlerts", function()
  return Alerts.alerts
end)

-- Initialize the alerts system
Alerts:init()