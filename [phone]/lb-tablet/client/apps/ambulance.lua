function IsAmbulance()
  if not FrameworkLoaded then
    return false
  end
  local job = GetJob()
  return Config.Ambulance.Permissions[job] ~= nil
end
local function getChatMessages(chatId, lastId)
  local messages = AwaitCallback("ambulance:getChatMessages", chatId, lastId)
  local formatted = {}
  for i = 1, #messages do
    local message = messages[i]
    local attachments = nil
    if message.attachments then
      attachments = json.decode(message.attachments)
    end
    formatted[i] = {
      id = message.id,
      content = message.message,
      attachments = attachments,
      timestamp = message.sent_at,
      sender = {
        id = message.author,
        name = message.display_name or "",
        avatar = message.avatar
      }
    }
  end
  return formatted
end
local function searchUsers(query, filter, page)
  local users = AwaitCallback("ambulance:searchUsers", query, filter, page)
  for i = 1, #users do
    users[i].isMale = users[i].isMale == 1
  end
  return users
end
local function fetchProfile(playerId)
  local profile = AwaitCallback("ambulance:fetchProfile", playerId)
  if profile then
    profile.isMale = profile.isMale == 1
  end
  return profile
end
local function getReport(reportId)
  local report = AwaitCallback("ambulance:getReport", reportId)
  if not report then
    return false
  end
  report.patient = {
    id = report.patient,
    name = report.patient_name,
    dob = report.patient_dob
  }
  local gallery = {}
  for i = 1, #report.gallery do
    gallery[#gallery + 1] = report.gallery[i].attachment
  end
  report.gallery = gallery
  return report
end
ReactCallback("Ambulance", function(data)
  local action = data.action
  if action == "getUser" then
    return AwaitCallback("ambulance:getLoggedIn")
  elseif action == "updateUser" then
    return AwaitCallback("ambulance:updateOwnAccount", data.callsign, data.avatar)
  elseif action == "getPermissions" then
    return GetPermissions("Ambulance")
  elseif action == "getLogs" then
    return AwaitCallback("ambulance:getLogs", data.query, data.lastId)
  elseif action == "getActiveUnits" then
    return AwaitCallback("ambulance:getActiveUnits")
  elseif action == "getEmployees" then
    return AwaitCallback("ambulance:getEmployees")
  end
  if action == "getUnits" then
    return AwaitCallback("ambulance:getUnits")
  elseif action == "addUnit" then
    return AwaitCallback("ambulance:addUnit", data.name)
  elseif action == "deleteUnit" then
    return AwaitCallback("ambulance:deleteUnit", data.unit)
  elseif action == "updateUnitStatus" then
    return AwaitCallback("ambulance:updateUnitStatus", data.unit, data.status)
  elseif action == "renameUnit" then
    return AwaitCallback("ambulance:renameUnit", data.unit, data.name)
  elseif action == "assignOfficerToUnit" then
    return AwaitCallback("ambulance:assignOfficerToUnit", data.unit, data.officerId)
  elseif action == "removeOfficerFromUnit" then
    return AwaitCallback("ambulance:removeOfficerFromUnit", data.officerId)
  end
  if action == "getTags" then
    return AwaitCallback("ambulance:getTags")
  elseif action == "createTag" then
    return AwaitCallback("ambulance:createTag", data.tag, data.color, data.type)
  elseif action == "deleteTag" then
    return AwaitCallback("ambulance:deleteTag", data.id)
  end
  if action == "searchProfiles" then
    return searchUsers(data.query, data.filter, data.page)
  elseif action == "fetchProfile" then
    return fetchProfile(data.id)
  elseif action == "updateProfile" then
    return AwaitCallback("ambulance:updateProfile", data)
  elseif action == "addTag" then
    return AwaitCallback("ambulance:addTag", data.id, data.tag)
  elseif action == "removeTag" then
    return AwaitCallback("ambulance:removeTag", data.id, data.tag)
  elseif action == "billPlayer" then
    return AwaitCallback("ambulance:billPlayer", data.id, data.fine, data.label)
  end
  if action == "saveReport" then
    return AwaitCallback("ambulance:saveReport", data)
  elseif action == "getReports" then
    return AwaitCallback("ambulance:getReports", data.query, data.page)
  elseif action == "getReport" then
    return getReport(data.id)
  elseif action == "deleteReport" then
    return AwaitCallback("ambulance:deleteReport", data.id)
  end
  if action == "getBulletinBoard" then
    return AwaitCallback("ambulance:getBulletinBoard", data.page, data.search)
  elseif action == "saveBulletin" then
    return AwaitCallback("ambulance:saveBulletin", data)
  elseif action == "toggleBulletinPinned" then
    return AwaitCallback("ambulance:toggleBulletinPinned", data.id, data.pinned)
  elseif action == "deleteBulletin" then
    return AwaitCallback("ambulance:deleteBulletin", data.id)
  end
  if action == "getConditions" then
    return AwaitCallback("ambulance:getConditions")
  elseif action == "addConditionCategory" then
    return AwaitCallback("ambulance:addConditionCategory", data.name)
  elseif action == "updateConditionCategory" then
    return AwaitCallback("ambulance:updateConditionCategory", data.oldName, data.newName)
  elseif action == "deleteConditionCategory" then
    return AwaitCallback("ambulance:deleteConditionCategory", data.name)
  elseif action == "addCondition" then
    return AwaitCallback("ambulance:addCondition", data.category, data.name, data.price)
  elseif action == "updateCondition" then
    return AwaitCallback("ambulance:updateCondition", data.id, data.category, data.name, data.price)
  elseif action == "deleteCondition" then
    return AwaitCallback("ambulance:deleteCondition", data.id)
  end
  if action == "getUnreadChats" then
    return AwaitCallback("ambulance:getUnreadChats")
  elseif action == "getChatRooms" then
    return AwaitCallback("ambulance:getChatRooms", data.page, data.search)
  elseif action == "getPublicChatRooms" then
    return AwaitCallback("ambulance:getPublicChatRooms", data.page, data.search)
  elseif action == "createChat" then
    return AwaitCallback("ambulance:createChat", data.name, data.members)
  elseif action == "togglePrivate" then
    return AwaitCallback("ambulance:togglePrivate", data.id, data.private)
  elseif action == "setChatRoomAvatar" then
    return AwaitCallback("ambulance:setChatRoomAvatar", data.id, data.url)
  elseif action == "addUserToChat" then
    return AwaitCallback("ambulance:addUserToChat", data.id, data.user)
  elseif action == "kickFromChat" then
    return AwaitCallback("ambulance:kickFromChat", data.id, data.user)
  elseif action == "getMessages" then
    return getChatMessages(data.id, data.lastId)
  elseif action == "sendMessage" then
    return AwaitCallback("ambulance:sendMessage", data.id, data.content, data.attachments)
  elseif action == "leaveChat" then
    return AwaitCallback("ambulance:leaveChat", data.id)
  elseif action == "joinChat" then
    return AwaitCallback("ambulance:joinChat", data.id)
  elseif action == "clearChatNotifications" then
    return AwaitCallback("ambulance:clearChatNotifications", data.id)
  end
  debugprint("Unknown action Ambulance:" .. tostring(action))
end)

RegisterNetEvent("tablet:ambulance:bulletinCreated", function(data)
  SendReactMessage("ambulance:bulletinCreated", data)
end)
RegisterNetEvent("tablet:ambulance:bulletinUpdated", function(data)
  SendReactMessage("ambulance:bulletinUpdated", data)
end)
RegisterNetEvent("tablet:ambulance:bulletinDeleted", function(data)
  SendReactMessage("ambulance:bulletinDeleted", data)
end)
RegisterNetEvent("tablet:ambulance:addConditionCategory", function(data)
  SendReactMessage("ambulance:addConditionCategory", data)
end)
RegisterNetEvent("tablet:ambulance:updateConditionCategory", function(oldCategory, newCategory)
  SendReactMessage("ambulance:updateConditionCategory", {
    oldCategory = oldCategory,
    newCategory = newCategory
  })
end)
RegisterNetEvent("tablet:ambulance:deleteConditionCategory", function(data)
  SendReactMessage("ambulance:deleteConditionCategory", data)
end)
RegisterNetEvent("tablet:ambulance:addCondition", function(data)
  SendReactMessage("ambulance:addCondition", data)
end)
RegisterNetEvent("tablet:ambulance:updateCondition", function(data)
  SendReactMessage("ambulance:updateCondition", data)
end)
RegisterNetEvent("tablet:ambulance:deleteCondition", function(data)
  SendReactMessage("ambulance:deleteCondition", data)
end)
SetTimeout(500, function()
  RegisterDutyBlipsListener("ambulance", IsAmbulance)
end)
RegisterNetEvent("tablet:ambulance:createdTag", function(data)
  SendReactMessage("ambulance:tagCreated", data)
end)

RegisterNetEvent("tablet:ambulance:deletedTag", function(data)
  SendReactMessage("ambulance:tagDeleted", data)
end)

RegisterNetEvent("tablet:ambulance:addedTag", function(id, type, tagId)
  SendReactMessage("ambulance:tagAdded", {
    id = id,
    type = type,
    tagId = tagId
  })
end)

RegisterNetEvent("tablet:ambulance:removedTag", function(id, type, tagId)
  SendReactMessage("ambulance:tagRemoved", {
    id = id,
    type = type,
    tagId = tagId
  })
end)

RegisterNetEvent("tablet:ambulance:profileUpdated", function(data)
  SendReactMessage("ambulance:profileUpdated", data)
end)

RegisterNetEvent("tablet:ambulance:reportUpdated", function(data)
  SendReactMessage("ambulance:reportUpdated", data)
end)

RegisterNetEvent("tablet:ambulance:reportDeleted", function(data)
  SendReactMessage("ambulance:reportDeleted", data)
end)
AddEventHandler("lb-tablet:jobUpdated", function()
  debugprint("Ambulance: job updated, refreshing permissions etc")
  local hasAccess = IsAmbulance()
  if Config.RequireDutyMDT then
    local onDuty = IsOnDuty()
    if not onDuty then
      debugprint("Not on duty, removing ambulance app")
      hasAccess = false
    end
  end
  local appData = {
    app = "ambulance",
    hasAccess = hasAccess,
    appData = hasAccess and AmbulanceAppData or nil
  }
  debugprint("Ambulance: setHasAccess:", appData)
  SendReactMessage("ambulance:updatePermissions", GetPermissions("Ambulance"))
  SendReactMessage("app:setHasAccess", appData)
end)
