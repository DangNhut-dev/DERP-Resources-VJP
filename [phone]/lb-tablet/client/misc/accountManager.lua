local accountConfigs = { Mail = "mail" }

RegisterNUICallback("AccountSwitcher", function(A0_2, A1_2)
  local action = A0_2.action
  local app = A0_2.app
  local appConfig = accountConfigs[app]
  if not appConfig then
    A1_2(false)
    return
  end
  if action == "switch" then
    TriggerCallback("accountManager:switch", A1_2, appConfig, A0_2.account)
  elseif action == "getAccounts" then
    TriggerCallback("accountManager:getAccounts", A1_2, appConfig)
  end
end)