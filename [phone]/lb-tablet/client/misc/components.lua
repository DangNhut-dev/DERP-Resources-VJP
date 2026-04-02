local components = {}

local function generateUniqueId(t)
  local id = math.random(999999999)
  while t[id] do
    id = math.random(999999999)
  end
  return id
end

exports("SetPopUp", function(data)
  assert(type(data.title) == "string", "Expected string for title")
  assert(type(data.description) == "string", "Expected string for description")
  assert(type(data.buttons) == "table", "Expected table for buttons")
  
  local id = generateUniqueId(components)
  local actions = {}
  data.id = id

  if data.buttons then
    for _, button in ipairs(data.buttons) do
      if button.cb then
        local actionId = generateUniqueId(actions)
        actions[actionId] = button.cb
        button.cb = actionId
      end
    end
  end

  if data.inputs then
    for _, input in ipairs(data.inputs) do
      if input.onChange then
        local actionId = generateUniqueId(actions)
        actions[actionId] = input.onChange
        input.onChange = actionId
      end
    end
  end

  if data.textareas then
    for _, textarea in ipairs(data.textareas) do
      if textarea.onChange then
        local actionId = generateUniqueId(actions)
        actions[actionId] = textarea.onChange
        textarea.onChange = actionId
      end
    end
  end

  components[id] = { close = data.close, actions = actions }
  SendReactMessage("showComponent", { type = "popup", data = data })
  return true
end)

exports("SetContextMenu", function(data)
  assert(type(data.buttons) == "table", "Expected table for buttons")
  
  local id = generateUniqueId(components)
  local actions = {}
  data.id = id

  for _, button in ipairs(data.buttons) do
    if button.cb then
      local actionId = generateUniqueId(actions)
      actions[actionId] = button.cb
      button.cb = actionId
    end
  end

  components[id] = { close = data.close, actions = actions }
  SendReactMessage("showComponent", { type = "contextmenu", data = data })
end)

exports("Gallery", function(data)
  local id = generateUniqueId(components)
  local actions = {}
  data.id = id

  if data.onSelect then
    local actionId = generateUniqueId(actions)
    actions[actionId] = data.onSelect
    data.onSelect = actionId
  end

  components[id] = { close = data.close, actions = actions }
  SendReactMessage("showComponent", { type = "gallery", data = data })
end)

exports("ColorPicker", function(data)
  if data.defaultColor and not data.defaultColor:match("^#%x%x%x%x%x%x$") then
    error("Invalid defaultColor, expected hex")
  end

  local id = generateUniqueId(components)
  local actions = {}
  data.id = id

  if data.onSelect then
    local actionId = generateUniqueId(actions)
    actions[actionId] = data.onSelect
    data.onSelect = actionId
  end

  if data.onClose then
    local actionId = generateUniqueId(actions)
    actions[actionId] = data.onClose
    data.onClose = actionId
  end

  components[id] = { close = data.close, actions = actions }
  SendReactMessage("showComponent", { type = "colorpicker", data = data })
end)

RegisterNUICallback("componentResult", function(data, cb)
  cb("ok")
  local component = components[data.componentId]
  if component then
    if data.id then
      local action = component.actions[data.id]
      if action then action(data.data) end
    else
      if component.close then component.close(data.data) end
      components[data.componentId] = nil
    end
  end
end)