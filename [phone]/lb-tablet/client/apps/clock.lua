ReactCallback("Clock", function(A0_2)
  if A0_2.action == "getAlarms" then
    return AwaitCallback("clock:getAlarms")
  elseif A0_2.action == "createAlarm" then
    return AwaitCallback("clock:createAlarm", A0_2.label, A0_2.hours, A0_2.minutes)
  elseif A0_2.action == "deleteAlarm" then
    return AwaitCallback("clock:deleteAlarm", A0_2.id)
  elseif A0_2.action == "updateAlarm" then
    return AwaitCallback("clock:updateAlarm", A0_2.id, A0_2.label, A0_2.hours, A0_2.minutes)
  elseif A0_2.action == "toggleAlarm" then
    return AwaitCallback("clock:toggleAlarm", A0_2.id, A0_2.enabled)
  end
end)