RegisterNUICallback("Notes", function(data, cb)
  local action = data.action
  data = data.data or data

  if action == "create" then
    TriggerCallback("notes:create", cb, data.title, data.content)
  elseif action == "save" then
    TriggerCallback("notes:save", cb, data.id, data.title, data.content)
  elseif action == "fetch" then
    TriggerCallback("notes:fetch", cb, data.page or 0)
  elseif action == "remove" then
    TriggerCallback("notes:remove", cb, data.id)
  end
end)