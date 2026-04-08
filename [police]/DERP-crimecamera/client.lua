local active = false
local cam = nil
local currentFov = Config.DefaultFov
local charName = ''
local isCapturing = false
local isViewing = false

local GetEntityCoords = GetEntityCoords
local GetStreetNameAtCoord = GetStreetNameAtCoord
local GetStreetNameFromHashKey = GetStreetNameFromHashKey
local PlayerPedId = PlayerPedId
local IsControlJustPressed = IsControlJustPressed
local IsControlPressed = IsControlPressed
local SetCamFov = SetCamFov
local Wait = Wait

-- Lấy tên nhân vật
local function getCharName()
    local player = exports.qbx_core:GetPlayerData()
    if player and player.charinfo then
        return player.charinfo.firstname .. ' ' .. player.charinfo.lastname
    end
    return 'Không xác định'
end

-- Lấy tên đường từ tọa độ
local function getStreetName(coords)
    local streetHash, crossHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local street = GetStreetNameFromHashKey(streetHash)
    local cross  = GetStreetNameFromHashKey(crossHash)
    if cross and cross ~= '' then
        return street .. ' / ' .. cross
    end
    return street
end

-- Tạo camera
local function createCamera()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)

    local forward = GetEntityForwardVector(ped)
    local camPos = coords + forward * 0.8 + vector3(0.0, 0.0, 0.7)

    SetCamCoord(cam, camPos.x, camPos.y, camPos.z)
    SetCamRot(cam, 0.0, 0.0, heading, 2)
    SetCamFov(cam, currentFov)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, false)
end

-- Hủy camera
local function destroyCamera()
    if cam then
        SetCamActive(cam, false)
        RenderScriptCams(false, false, 0, true, false)
        DestroyCam(cam, false)
        cam = nil
    end
end

-- Xử lý zoom
local function handleZoom()
    if IsControlPressed(0, 241) then
        currentFov = math.max(Config.MinFov, currentFov - Config.ZoomSpeed)
    elseif IsControlPressed(0, 242) then
        currentFov = math.min(Config.MaxFov, currentFov + Config.ZoomSpeed)
    end
    if cam then
        SetCamFov(cam, currentFov)
    end
end

-- Cập nhật rotation camera theo mouse
local function updateCamRotation()
    if not cam then return end
    local rot = GetCamRot(cam, 2)
    local mouseX = GetDisabledControlNormal(0, 1) * 8.0
    local mouseY = GetDisabledControlNormal(0, 2) * 8.0

    local newX = math.max(math.min(rot.x - mouseY, 89.0), -89.0)
    local newZ = rot.z - mouseX

    SetCamRot(cam, newX, 0.0, newZ, 2)
end

-- Vẽ HUD camera
local function drawCameraHUD()
    local coords = GetEntityCoords(PlayerPedId())
    local street = getStreetName(coords)
    local hour, minute, second = GetClockHours(), GetClockMinutes(), GetClockSeconds()
    local day, month, year = GetClockDayOfMonth(), GetClockMonth() + 1, GetClockYear()
    local time = ('%02d:%02d:%02d - %02d/%02d/%04d'):format(hour, minute, second, day, month, year)

    local lines = {
        '~b~[ẢNH HIỆN TRƯỜNG ]',
        '~w~Thời gian: ' .. time,
        '~w~Vị trí: ' .. street,
        '~w~Sĩ quan: ~b~' .. charName,
        '',
        -- '~g~[E]~w~ Chụp ảnh  ~r~[X]~w~ Thoát  ~y~[Scroll]~w~ Phóng to/thu nhỏ',
    }

    local startY = 0.72
    for i, line in ipairs(lines) do
        SetTextFont(4)
        SetTextScale(0.0, 0.45)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(2, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 255)
        SetTextOutline()
        SetTextEntry('STRING')
        AddTextComponentString(line)
        DrawText(0.65, startY + (i - 1) * 0.032)
    end
end

-- Animation giơ máy ảnh
local function playAnim()
    local dict = 'amb@world_human_paparazzi@male@idle_a'
    lib.requestAnimDict(dict)
    TaskPlayAnim(PlayerPedId(), dict, 'idle_a', 2.0, 2.0, -1, 49, 0, false, false, false)
end

-- Dừng animation
local function stopAnim()
    ClearPedTasks(PlayerPedId())
end

-- Vòng lặp chính của camera
local function cameraLoop()
    active = true
    charName = getCharName()
    currentFov = Config.DefaultFov
    playAnim()
    Wait(500)
    createCamera()

    CreateThread(function()
        while active do
            DisableAllControlActions(0)
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
            EnableControlAction(0, 241, true)
            EnableControlAction(0, 242, true)
            EnableControlAction(0, Config.CaptureKey, true)
            EnableControlAction(0, Config.ExitKey, true)

            updateCamRotation()
            handleZoom()
            drawCameraHUD()

            if IsControlJustPressed(0, Config.CaptureKey) and not isCapturing then
                capturePhoto()
            end

            if IsControlJustPressed(0, Config.ExitKey) then
                exitCamera()
            end

            Wait(0)
        end
    end)
end

-- Chụp ảnh
function capturePhoto()
    if isCapturing then return end
    isCapturing = true

    local input = lib.inputDialog('Ảnh Hiện Trường', {
        { type = 'input', label = 'Nhãn ảnh', placeholder = 'Ví dụ: Hiện trường vụ án...', required = true, max = 100 },
    })

    if not input or not input[1] or input[1] == '' then
        isCapturing = false
        return
    end

    local label  = input[1]
    local coords = GetEntityCoords(PlayerPedId())
    local street = getStreetName(coords)
    local hour, minute, second = GetClockHours(), GetClockMinutes(), GetClockSeconds()
    local day, month, year = GetClockDayOfMonth(), GetClockMonth() + 1, GetClockYear()
    local time = ('%02d:%02d:%02d - %02d/%02d/%04d'):format(hour, minute, second, day, month, year)

    lib.notify({ description = 'Đang chụp ảnh...', type = 'inform', duration = 2000 })

    exports['screenshot-basic']:requestScreenshotUpload(
        'https://api.fivemanage.com/api/image',
        'file',
        {
            headers = {
                ['Authorization'] = 'Vuk1rXoWtwksWrdEo1YxRmYzEMj8gowf',
            },
        },
        function(data)
            local resp = json.decode(data)
            if resp and resp.url then
                TriggerServerEvent('DERP-crimecamera:server:savePhoto', {
                    label    = label,
                    url      = resp.url,
                    street   = street,
                    time     = time,
                    coords   = { x = coords.x, y = coords.y, z = coords.z },
                    officer  = charName,
                })
                lib.notify({ description = 'Đã chụp ảnh thành công!', type = 'success', duration = 3000 })
            else
                lib.notify({ description = 'Lỗi tải ảnh lên!', type = 'error', duration = 3000 })
            end
            isCapturing = false
        end
    )
end

-- Thoát camera
function exitCamera()
    active = false
    destroyCamera()
    stopAnim()
    currentFov = Config.DefaultFov
    isCapturing = false
end

-- ═══════════════════════════════════════════════
-- SỬ DỤNG ITEM CRIMECAMERA (mở chế độ chụp)
-- ═══════════════════════════════════════════════

RegisterNetEvent('DERP-crimecamera:client:use', function()
    if active then return end

    local playerData = exports.qbx_core:GetPlayerData()
    if not playerData or not playerData.job then return end
    if not Config.AllowedJobs[playerData.job.name] then
        lib.notify({ description = 'Bạn không có quyền sử dụng', type = 'error' })
        return
    end

    cameraLoop()
end)

-- ═══════════════════════════════════════════════
-- HIỂN THỊ ẢNH QUA NUI (cho bản thân + người gần)
-- ═══════════════════════════════════════════════

RegisterNetEvent('DERP-crimecamera:client:showPhoto', function(data)
    if not data or type(data.url) ~= 'string' then return end
    if isViewing then return end

    isViewing = true

    local dict = 'cellphone@'
    lib.requestAnimDict(dict)
    TaskPlayAnim(PlayerPedId(), dict, 'cellphone_photo_idle', 2.0, 2.0, -1, 49, 0, false, false, false)

    SetNuiFocus(true, false)
    SendNUIMessage({
        action   = 'showPhoto',
        url      = data.url,
        label    = data.label or '',
        time     = data.time or '',
        street   = data.street or '',
        officer  = data.officer or '',
        duration = 10000,
    })

    SetTimeout(10500, function()
        if isViewing then
            isViewing = false
            SetNuiFocus(false, false)
            SendNUIMessage({ action = 'hidePhoto' })
            ClearPedTasks(PlayerPedId())
        end
    end)
end)

CreateThread(function()
    while true do
        if isViewing then
            if IsControlJustPressed(0, 200) then
                isViewing = false
                SetNuiFocus(false, false)
                SendNUIMessage({ action = 'hidePhoto' })
                ClearPedTasks(PlayerPedId())
            end
        end
        Wait(0)
    end
end)

RegisterNUICallback('closeViewer', function(_, cb)
    isViewing = false
    SetNuiFocus(false, false)
    ClearPedTasks(PlayerPedId())
    cb('ok')
end)