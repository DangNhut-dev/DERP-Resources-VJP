local cameraOpen = false
local tipHidden = false
local hudInterval = nil
local baseUrl = nil
local imageTypes = {
  selfies = "selfie",
  screenshots = "screenshot",
  imports = "import"
}
function GetBaseUrl()
  if not baseUrl then
    baseUrl = AwaitCallback("camera:getBaseUrl")
  end
  return baseUrl
end
local function getUploadMethod(uploadType)
  local method = nil
  if CustomGetUploadMethod then
    method = CustomGetUploadMethod(uploadType)
  else
    local uploadMethods = UploadMethods[Config.UploadMethod[uploadType]]
    if not uploadMethods then
      infoprint("error", "Upload methods not found for ", uploadType)
      return
    end
    method = uploadMethods[uploadType] or method
    if not method then
      method = uploadMethods.Default
    end
    if not method then
      infoprint("error", "Upload method not found for ", uploadType)
      return
    end
  end
  if not method.method then
    method.method = Config.UploadMethod[uploadType]
  end
  if method.sendPlayer then
    if TabletId then
      local playerData = {
        identifier = TabletId,
        name = GetPlayerName(PlayerId())
      }
      method.player = playerData
    end
  end
  if method.url:find("BASE_URL") then
    method.url = method.url:gsub("BASE_URL", GetBaseUrl())
  end
  local needsApiKey = false
  if method.url:find("API_KEY") then
    needsApiKey = true
  else
    if method.headers then
      for _, headerValue in pairs(method.headers) do
        if headerValue:find("API_KEY") then
          needsApiKey = true
          break
        end
      end
    end
  end
  if needsApiKey then
    local apiKey = AwaitCallback("camera:getUploadApiKey", uploadType)
    method.url = method.url:gsub("API_KEY", apiKey)
    if method.headers then
      for key, headerValue in pairs(method.headers) do
        method.headers[key] = headerValue:gsub("API_KEY", apiKey)
      end
    end
  end
  if method.url:find("PRESIGNED_URL") then
    local presignedUrl = AwaitCallback("camera:getPresignedUrl", uploadType)
    if not presignedUrl then
      infoprint("error", "Failed to get presigned url for " .. uploadType)
      return
    end
    method.presignedUrl = method.url:gsub("PRESIGNED_URL", presignedUrl)
  end
  return method
end
local function getPhotos(filter, page, lastId)
  if not filter then
    filter = {}
  end
  if filter.album == "recents" then
    filter.album = nil
  elseif filter.album == "favourites" then
    filter.album = nil
    filter.favourites = true
  end
  if filter.type == "videos" then
    filter = {
      showPhotos = false,
      showVideos = true
    }
  end
  if filter.type then
    filter.album = nil
    local mappedType = imageTypes[filter.type]
    if mappedType then
      filter.type = mappedType
    else
      if filter.type == "duplicates" then
        filter.type = nil
        filter.duplicates = true
      else
        filter.type = nil
      end
    end
  end
  if not filter.showPhotos and not filter.showVideos then
    filter.showPhotos = true
    filter.showVideos = true
  end
  local photos = AwaitCallback("camera:getPhotos", filter, page or 0, lastId)
  local formatted = {}
  for i = 1, #photos do
    local photo = photos[i]
    local formattedPhoto = {
      id = photo.id,
      src = photo.link,
      isVideo = photo.is_video,
      type = photo.metadata,
      favourite = photo.is_favourite,
      timestamp = photo.created_at,
      size = photo.size
    }
    formatted[i] = formattedPhoto
  end
  return formatted
end
function DisplayCameraTip()
  if hudInterval or tipHidden or (cameraOpen and Config.Camera.ShowTip == false) then
    return
  end
  local tips = {}
  if Config.KeyBinds.TakePhoto and Config.KeyBinds.TakePhoto.bindData then
    tips[#tips + 1] = L("BACKEND.CAMERA.TAKE_PHOTO", {
      key = Config.KeyBinds.TakePhoto.bindData.instructional
    })
  end
  if Config.KeyBinds.FlipCamera and Config.KeyBinds.FlipCamera.bindData then
    tips[#tips + 1] = L("BACKEND.CAMERA.FLIP_CAMERA", {
      key = Config.KeyBinds.FlipCamera.bindData.instructional
    })
  end
  if Config.KeyBinds.ToggleFlash and Config.KeyBinds.ToggleFlash.bindData then
    tips[#tips + 1] = L("BACKEND.CAMERA.TOGGLE_FLASH", {
      key = Config.KeyBinds.ToggleFlash.bindData.instructional
    })
  end
  if Config.KeyBinds.LeftMode and Config.KeyBinds.LeftMode.bindData and Config.KeyBinds.RightMode and Config.KeyBinds.RightMode.bindData then
    tips[#tips + 1] = L("BACKEND.CAMERA.CHANGE_MODE", {
      key = Config.KeyBinds.LeftMode.bindData.instructional,
      key2 = Config.KeyBinds.RightMode.bindData.instructional
    })
  end
  if Config.KeyBinds.RollLeft and Config.KeyBinds.RollLeft.bindData and Config.KeyBinds.RollRight and Config.KeyBinds.RollRight.bindData then
    tips[#tips + 1] = L("BACKEND.CAMERA.ROLL", {
      key = Config.KeyBinds.RollLeft.bindData.instructional,
      key2 = Config.KeyBinds.RollRight.bindData.instructional
    })
  end
  if Config.Camera and Config.Camera.Freeze and Config.Camera.Freeze.Enabled and Config.KeyBinds.FreezeCamera and Config.KeyBinds.FreezeCamera.bindData then
    local freezeAction = IsCameraFrozen() and "UNFREEZE" or "FREEZE"
    tips[#tips + 1] = L("BACKEND.CAMERA." .. freezeAction, {
      key = Config.KeyBinds.FreezeCamera.bindData.instructional
    })
  end
  if Config.KeyBinds.Focus and Config.KeyBinds.Focus.bindData then
    tips[#tips + 1] = L("BACKEND.CAMERA.TOGGLE_CURSOR", {
      key = Config.KeyBinds.Focus.bindData.instructional
    })
  end
  if Config.KeyBinds.ToggleCameraTip and Config.KeyBinds.ToggleCameraTip.bindData then
    tips[#tips + 1] = L("BACKEND.CAMERA.TOGGLE_TIP", {
      key = Config.KeyBinds.ToggleCameraTip.bindData.instructional
    })
  end
  if #tips > 0 then
    local tipText = table.concat(tips, "\n")
    AddTextEntry("LB_TABLET_CAMERA_TIP", tipText)
    BeginTextCommandDisplayHelp("LB_TABLET_CAMERA_TIP")
    EndTextCommandDisplayHelp(0, true, false, 0)
  end
end
RegisterNUICallback("Camera", function(data, cb)
  local action = data.action
  if action == "toggleHud" then
    if data.hide then
      if not hudInterval then
        hudInterval = SetInterval(HideHudComponents)
        Wait(100)
      end
    else
      if hudInterval then
        hudInterval = ClearInterval(hudInterval)
      end
    end
    cb(true)
  elseif action == "getLastPhoto" then
    TriggerCallback("camera:getLastPhoto", cb)
  elseif action == "getImages" then
    cb(getPhotos(data.filter, data.page, data.lastId))
  elseif action == "saveToGallery" then
    TriggerCallback("camera:saveToGallery", cb, data.url, data.size, data.isVideo == true, data.type, data.shouldLog)
  elseif action == "deleteFromGallery" then
    TriggerCallback("camera:deleteFromGallery", cb, data.ids)
  elseif action == "createAlbum" then
    TriggerCallback("camera:createAlbum", cb, data.title)
  elseif action == "renameAlbum" then
    TriggerCallback("camera:renameAlbum", cb, data.id, data.title)
  elseif action == "deleteAlbum" then
    TriggerCallback("camera:deleteAlbum", cb, data.id)
  elseif action == "addToAlbum" then
    TriggerCallback("camera:addToAlbum", cb, data.album, data.ids)
  elseif action == "removeFromAlbum" then
    TriggerCallback("camera:removeFromAlbum", cb, data.album, data.ids)
  elseif action == "toggleFavourites" then
    TriggerCallback("camera:toggleFavourites", cb, data.favourite, data.ids)
  elseif action == "getAlbums" then
    TriggerCallback("camera:getHomePageData", cb)
  elseif action == "getPhoneAlbum" then
    TriggerCallback("camera:getPhoneAlbum", cb)
  elseif action == "importFromPhone" then
    TriggerCallback("camera:importFromPhone", cb, data.ids)
  elseif action == "getUploadMethod" then
    cb(getUploadMethod(data.uploadType) or false)
  elseif action == "open" then
    cameraOpen = true
    DisplayCameraTip()
    EnableWalkableCam()
    cb(true)
  elseif action == "flipCamera" then
    ToggleSelfieCam(data.value)
    cb(true)
  elseif action == "close" then
    cameraOpen = false
    ClearAllHelpMessages()
    DisableWalkableCam()
    if hudInterval then
      hudInterval = ClearInterval(hudInterval)
    end
    cb(true)
  end
end)

AddEventHandler("lb-tablet:keyPressed", function(key)
  if key == "ToggleCameraTip" then
    tipHidden = not tipHidden
    if tipHidden then
      ClearAllHelpMessages()
    else
      DisplayCameraTip()
    end
  end
end)
