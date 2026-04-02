local currentMail = nil

local function processMail(mail)
  if not mail then return false end
  mail.attachments = mail.attachments and json.decode(mail.attachments) or {}
  mail.actions = mail.actions and json.decode(mail.actions) or {}
  return mail
end

RegisterNUICallback("Mail", function(data, cb)
  local action = data.action
  data = data.data or data

  if action == "isLoggedIn" then
    TriggerCallback("mail:isLoggedIn", cb)
  elseif action == "createMail" then
    TriggerCallback("mail:createMail", cb, data.email, data.password)
  elseif action == "login" then
    TriggerCallback("mail:login", cb, data.email, data.password)
  elseif action == "logout" then
    TriggerCallback("mail:logout", cb)
  elseif action == "getMails" then
    TriggerCallback("mail:getMails", cb, data.lastId)
  elseif action == "getMail" then
    local mail = AwaitCallback("mail:getMail", data.id)
    if mail then
      currentMail = processMail(mail)
      cb(currentMail)
    else
      cb(false)
    end
  elseif action == "search" then
    TriggerCallback("mail:search", cb, data.query, data.lastId)
  elseif action == "sendMail" then
    TriggerCallback("mail:sendMail", cb, data)
  elseif action == "action" then
    cb("ok")
    if not currentMail or currentMail.id ~= data.id then
      return debugprint("Invalid mail id")
    end
    local actionId = (data.actionId or 0) + 1
    local actionData = currentMail.actions[actionId] and currentMail.actions[actionId].data
    if not actionData then
      return debugprint("Invalid action id")
    end
    if actionData.qbMail then
      TriggerEvent(actionData.event, actionData.data.data)
    elseif actionData.isServer then
      TriggerServerEvent(actionData.event, data.id, actionData.data)
    else
      TriggerEvent(actionData.event, data.id, actionData.data)
    end
  end
end)

RegisterNetEvent("tablet:mail:newMail", function(mail)
  SendReactMessage("mail:newMail", mail)
end)