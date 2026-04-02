local customApps = {}
local appCallbacks = {}

function AddCustomApp(appData)
  local resource = GetInvokingResource() or GetCurrentResourceName()
  
  assert(type(appData) == "table", "AddCustomApp: expected appData to have type table, got " .. type(appData))
  assert(type(appData.identifier) == "string", "AddCustomApp: expected identifier to have type string, got " .. type(appData.identifier))
  assert(type(appData.name) == "string", "AddCustomApp: expected name to have type string, got " .. type(appData.name))
  
  if customApps[appData.identifier] then
    return false, "APP_ALREADY_EXISTS"
  end

  if appData.ui and not appData.ui:find("^http") then
    appData.ui = resource .. "/" .. appData.ui
  end

  if appData.icon and not appData.icon:find("^http") then
    appData.icon = "https://cfx-nui-" .. resource .. "/" .. appData.icon
  end

  if appData.images then
    for i = 1, #appData.images do
      if not appData.images[i]:find("^http") then
        appData.images[i] = "https://cfx-nui-" .. resource .. "/" .. appData.images[i]
      end
    end
  end

  appCallbacks[appData.identifier] = {
    install = appData.onInstall,
    open = appData.onOpen,
    close = appData.onClose,
    uninstall = appData.onUninstall
  }

  customApps[appData.identifier] = {
    identifier = appData.identifier,
    resource = resource,
    custom = true,
    name = appData.name,
    description = appData.description,
    icon = appData.icon,
    price = appData.price,
    images = appData.images,
    developer = appData.developer,
    size = appData.size or 0,
    ui = appData.ui,
    removable = appData.defaultApp ~= true
  }

  TriggerEvent("lb-tablet:customAppAdded", customApps[appData.identifier])
  SendReactMessage("addCustomApp", customApps[appData.identifier])
  return true
end

exports("AddCustomApp", AddCustomApp)

function RemoveCustomApp(identifier)
  local resource = GetInvokingResource()
  assert(type(identifier) == "string", "RemoveCustomApp: expected identifier to have type string, got " .. type(identifier))
  
  if not customApps[identifier] then
    return false, "INVALID_APP"
  end
  if customApps[identifier].resource ~= resource then
    return false, "WRONG_RESOURCE"
  end
  
  customApps[identifier] = nil
  appCallbacks[identifier] = nil
  TriggerEvent("lb-tablet:customAppRemoved", identifier)
  SendReactMessage("removeCustomApp", identifier)
end

exports("RemoveCustomApp", RemoveCustomApp)

exports("SendCustomAppMessage", function(identifier, action, data)
  if not customApps[identifier] then
    return false, "INVALID_APP"
  end
  SendReactMessage("customApp:sendMessage", {
    identifier = identifier,
    message = {
      action = action,
      data = data
    }
  })
  return true
end)

AddEventHandler("onResourceStop", function(resource)
  for identifier, app in pairs(customApps) do
    if app.resource == resource then
      customApps[identifier] = nil
      appCallbacks[identifier] = nil
      SendReactMessage("removeCustomApp", identifier)
      debugprint("Removed custom app", identifier, "due to resource stop")
    end
  end
end)

RegisterNUICallback("CustomApp", function(data, cb)
  cb("ok")
  if appCallbacks[data.app] and appCallbacks[data.app][data.action] then
    appCallbacks[data.app][data.action]()
  end
end)

function GetCustomApps()
  return customApps
end

if Config.CustomApps and #Config.CustomApps > 0 then
  for _, app in ipairs(Config.CustomApps) do
    AddCustomApp(app)
  end
end