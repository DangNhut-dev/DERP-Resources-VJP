RegisterNUICallback("logError", function(data, cb)
  cb("ok")
  infoprint("error", "Your tablet crashed.")
  print("Error:", data.error)
  print("Stack:", data.stack)
  print("Component Stack:", data.componentStack)
  
  if GetResourceMetadata(GetCurrentResourceName(), "ui_page", 0) == "ui/dist/index.html" then
    local errorMsg = data.error or "No error message"
    local stack = data.stack or "No stack"
    local componentStack = data.componentStack or "No component stack"
    TriggerServerEvent("tablet:logError", errorMsg, stack, componentStack)
  end

  local wasOpen = TabletOpen
  ToggleOpen(false)
  Wait(2500)
  if wasOpen then ToggleOpen(true) end

  TriggerEvent("tablet:notifications:new", {
    app = "Settings",
    title = "System Crash",
    content = "Your tablet crashed. Press F8 for more info."
  })
end)