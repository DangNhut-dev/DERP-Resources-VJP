local QBX = exports.qbx_core
local activeScenes = {}
local drawnScenes = {}
local scenesEnabled = true
local lastUpdate = GetGameTimer()
local updateTimer = 0
local processing = false
local creatingScene = false
local targetZones = {}
local textDimensionCache = {}
local scenesLoaded = false
local needsDistanceCheck = false
local spritesLoaded = false
local function GetColorRGB(colorName)
    for _, color in ipairs(Config.Colors) do
        if color.value == colorName then
            return color.rgb
        end
    end
    return {255, 255, 255}
end

local function RotationToDirection(rotation)
    local pi = math.pi
    local piDivBy180 = pi / 180
    local adjustedRotation = vector3(
        piDivBy180 * rotation.x,
        piDivBy180 * rotation.y,
        piDivBy180 * rotation.z
    )
    local direction = vector3(
        -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        math.sin(adjustedRotation.x)
    )
    return direction
end

local function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination = vector3(
        cameraCoord.x + direction.x * distance,
        cameraCoord.y + direction.y * distance,
        cameraCoord.z + direction.z * distance
    )
    local ray = StartExpensiveSynchronousShapeTestLosProbe(
        cameraCoord.x, cameraCoord.y, cameraCoord.z,
        destination.x, destination.y, destination.z,
        -1, PlayerPedId(), 0
    )
    local _, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(ray)
    return hit == 1, endCoords, entityHit, surfaceNormal
end

local function CalculateTextDimensions(text, scale, font)
    local cacheKey = text .. '_' .. tostring(scale) .. '_' .. tostring(font)
    if textDimensionCache[cacheKey] then
        return textDimensionCache[cacheKey].width, textDimensionCache[cacheKey].height
    end
    SetTextScale(0.0, scale)
    SetTextFont(font)
    BeginTextCommandGetWidth("STRING")
    AddTextComponentSubstringPlayerName(text)
    local width = EndTextCommandGetWidth(true)
    local height = GetRenderedCharacterHeight(scale, font)
    
    textDimensionCache[cacheKey] = {width = width, height = height}
    return width, height
end

local function DrawText3DOnWall(coords, normal, text, color, background, font, fontSize, opacity, hidden, maxDistance, cachedDimensions)
    if not text or opacity <= 0 then return end
    
    local camCoords = GetFinalRenderedCamCoord()
    local distance = #(coords - camCoords)
    
    if maxDistance and distance > maxDistance then return end
    
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    if not onScreen then return end
    
    local scale = math.max(fontSize * (10.0 / distance), 0.1)
    
    local width, height = CalculateTextDimensions(text, scale, font)
    
    local padding = 0.005
    local bgWidth = width + (padding * 2)
    local bgHeight = height + (padding * 2)
    
    local bgAlpha
    local shouldDrawBg = background and background.style ~= 'none'
    
    if shouldDrawBg then
        bgAlpha = background.opacity or (background.style == 'transparent' and 100 or 200)
        bgAlpha = math.ceil(bgAlpha * opacity)
    end
    
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    
    if shouldDrawBg and spritesLoaded then
        local customBg = GetCustomBackgroundData(background.style)
        
        if customBg then
            local spriteWidth = bgWidth * 1.0
            local spriteHeight = bgHeight * 1.0
            DrawCustomBackground(customBg.dict, customBg.texture, spriteWidth, spriteHeight, 0, 0, bgAlpha, background.r, background.g, background.b)
        else
            local spriteWidth = bgWidth * 1.0
            local spriteHeight = bgHeight * 1.0
            
            DrawSprite("commonctx", "whiteblock", 0, 0, spriteWidth, spriteHeight, 0.0,
                background.r, background.g, background.b, bgAlpha)
        end
    elseif shouldDrawBg then
        DrawRect(0, 0, bgWidth, bgHeight, 
            background.r, background.g, background.b, bgAlpha)
    end
    
    local rgb = GetColorRGB(color)
    SetTextColour(rgb[1], rgb[2], rgb[3], math.ceil(255 * opacity))
    
    SetTextScale(0.0, scale)
    SetTextFont(font)
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0, -height * 0.45)
    
    ClearDrawOrigin()
end
local function CalculateScenesToDraw()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local hasChanges = false
    
    for id, scene in pairs(activeScenes) do
        local dist = #(scene.coords - playerCoords)
        local isNearby = dist < scene.distance and dist < Config.CheckDistance
        local isCurrentlyDrawn = drawnScenes[id] ~= nil
        
        if isNearby and not isCurrentlyDrawn then
            if not scene.processed then
                scene.fade = { type = "in", fade = 0 }
                scene.processed = true
            end
            drawnScenes[id] = scene
            hasChanges = true
        elseif not isNearby and isCurrentlyDrawn then
            if scene.fade and scene.fade.type == "in" then
                scene.fade = { type = "out", fade = 100 }
                hasChanges = true
            end
        end
    end
end
local function CreateSceneTarget(id, scene)
    if targetZones[id] then
        exports.ox_target:removeZone(targetZones[id])
    end
    
    local options = {}
    
    if scene.hidden then
        if not scene.revealed then
            table.insert(options, {
                name = 'scene_reveal_' .. id,
                icon = 'fas fa-eye',
                label = GetTranslation('label_reveal'),
                onSelect = function()
                    scene.revealed = true
                    lib.notify({
                        description = GetTranslation('reveal_text', scene.text),
                        type = 'success'
                    })
                    CreateSceneTarget(id, scene)
                end
            })
        else
            table.insert(options, {
                name = 'scene_hide_' .. id,
                icon = 'fas fa-eye-slash',
                label = GetTranslation('label_hide'),
                onSelect = function()
                    scene.revealed = false
                    lib.notify({
                        description = GetTranslation('hide_text'),
                        type = 'info'
                    })
                    CreateSceneTarget(id, scene)
                end
            })
        end
    end
    
    local Player = QBX:GetPlayerData()
    table.insert(options, {
        name = 'scene_edit_' .. id,
        icon = 'fas fa-edit',
        label = GetTranslation('label_edit'),
        canInteract = function()
            if not Player or not Player.citizenid then return false end
            
            for _, group in ipairs(Config.AdminGroups) do
                if Player.job and Player.job.name == group then
                    return true
                end
                if Player.gang and Player.gang.name == group then
                    return true
                end
                if Player.groups and Player.groups[group] then
                    return true
                end
            end
            
            return scene.creator == Player.citizenid
        end,
        onSelect = function()
            OpenEditSceneMenu(id, scene)
        end
    })
    table.insert(options, {
        name = 'scene_delete_' .. id,
        icon = 'fas fa-trash',
        label = GetTranslation('label_delete'),
        canInteract = function()
            if not Player or not Player.citizenid then return false end
            
            for _, group in ipairs(Config.AdminGroups) do
                if Player.job and Player.job.name == group then
                    return true
                end
                if Player.gang and Player.gang.name == group then
                    return true
                end
                if Player.groups and Player.groups[group] then
                    return true
                end
            end
            
            return scene.creator == Player.citizenid
        end,
        onSelect = function()
            local alert = lib.alertDialog({
                header = GetTranslation('dialog_delete_scene'),
                content = GetTranslation('dialog_delete_confirm'),
                centered = true,
                cancel = true
            })
            
            if alert == 'confirm' then
                TriggerServerEvent('ferp-scenes:deleteScene', id)
            end
        end
    })
    
    targetZones[id] = exports.ox_target:addSphereZone({
        coords = scene.coords,
        radius = 0.5,
        options = options,
        distance = 1.5
    })
end

local function OpenCreateSceneMenu()
    if creatingScene then
        lib.notify({
            description = GetTranslation('error_already_creating'),
            type = 'error'
        })
        return
    end
    
    creatingScene = true
    
    lib.notify({
        description = GetTranslation('info_aim'),
        type = 'info',
        duration = 5000
    })
    
    local previewThread = CreateThread(function()
        while creatingScene do
            local hit, coords, entity, normal = RayCastGamePlayCamera(20.0)
            if hit then
                DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                    0.2, 0.2, 0.2, 0, 255, 0, 100, false, false, 2, nil, nil, false)
                
                lib.showTextUI(GetTranslation('prompt_place_scene') .. " | " .. GetTranslation('prompt_cancel_scene'), {
                    position = "top-center",
                    icon = "info"
                })
                
                if IsControlJustPressed(0, 38) then
                    creatingScene = false
                    ShowSceneCreationMenu(coords, normal)
                end
                
                if IsControlJustPressed(0, 177) then
                    creatingScene = false
                    lib.hideTextUI()
                    lib.notify({
                        description = GetTranslation('info_aim'),
                        type = 'info'
                    })
                end
            end
            Wait(0)
        end
        lib.hideTextUI()
    end)
end

function ShowSceneCreationMenu(coords, normal)
    local input = lib.inputDialog(GetTranslation('dialog_create_scene'), {
        {
            type = 'textarea',
            label = GetTranslation('label_text'),
            description = GetTranslation('help_text', Config.MaxTextLength),
            required = true,
            max = Config.MaxTextLength
        },
        {
            type = 'select',
            label = GetTranslation('label_color'),
            options = Config.Colors,
            default = 'white',
            required = true
        },
        {
            type = 'select',
            label = GetTranslation('label_font'),
            options = Config.Fonts,
            default = 4,
            required = true
        },
        {
            type = 'slider',
            label = GetTranslation('label_font_size'),
            description = GetTranslation('help_size'),
            min = 0.1,
            max = 2.0,
            step = 0.1,
            default = 0.7,
            required = true
        },
        {
            type = 'number',
            label = GetTranslation('label_distance'),
            description = GetTranslation('help_distance', Config.MinDistance, Config.MaxDistance),
            default = Config.DefaultDistance,
            min = Config.MinDistance,
            max = Config.MaxDistance,
            required = true
        },
        {
            type = 'select',
            label = GetTranslation('label_background_style'),
            options = Config.BackgroundStyles,
            default = 'transparent'
        },
        {
            type = 'select',
            label = GetTranslation('label_background_color'),
            options = Config.Colors,
            default = 'black'
        },
        {
            type = 'slider',
            label = GetTranslation('label_background_opacity'),
            description = GetTranslation('help_opacity'),
            min = 0,
            max = 255,
            step = 5,
            default = 200,
            required = true
        },
        {
            type = 'slider',
            label = GetTranslation('label_background_width'),
            description = GetTranslation('help_background_width'),
            min = 0.1,
            max = 2.0,
            step = 0.1,
            default = 1.0,
            required = true
        },
        {
            type = 'slider',
            label = GetTranslation('label_background_height'),
            description = GetTranslation('help_background_height'),
            min = 0.1,
            max = 2.0,
            step = 0.1,
            default = 1.0,
            required = true
        },
        {
            type = 'checkbox',
            label = GetTranslation('label_hidden'),
            description = GetTranslation('help_hidden')
        },
        {
            type = 'number',
            label = GetTranslation('label_duration'),
            description = GetTranslation('help_duration'),
            default = Config.DefaultDuration,
            min = 1,
            max = Config.MaxDuration,
            required = true
        }
    })
    
    if not input then
        creatingScene = false
        return
    end
    
    local bgColor = GetColorRGB(input[7])
    
    local sceneData = {
        coords = coords,
        normal = normal,
        text = input[1],
        color = input[2],
        font = input[3],
        fontSize = input[4],
        distance = input[5],
        background = {
            style = input[6],
            r = bgColor[1],
            g = bgColor[2],
            b = bgColor[3],
            opacity = input[8],
            width = input[9],
            height = input[10]
        },
        hidden = input[11] or false,
        duration = input[12]
    }
    
    TriggerServerEvent('ferp-scenes:createScene', sceneData)
    creatingScene = false
end

function OpenEditSceneMenu(sceneId, scene)
    local input = lib.inputDialog(GetTranslation('dialog_edit_scene'), {
        {
            type = 'textarea',
            label = GetTranslation('label_text'),
            description = GetTranslation('help_text', Config.MaxTextLength),
            required = true,
            max = Config.MaxTextLength,
            default = scene.text
        },
        {
            type = 'select',
            label = GetTranslation('label_color'),
            options = Config.Colors,
            default = scene.color,
            required = true
        },
        {
            type = 'select',
            label = GetTranslation('label_font'),
            options = Config.Fonts,
            default = scene.font,
            required = true
        },
        {
            type = 'slider',
            label = GetTranslation('label_font_size'),
            description = GetTranslation('help_size'),
            min = 0.1,
            max = 2.0,
            step = 0.1,
            default = scene.fontSize,
            required = true
        },
        {
            type = 'number',
            label = GetTranslation('label_distance'),
            description = GetTranslation('help_distance', Config.MinDistance, Config.MaxDistance),
            default = scene.distance,
            min = Config.MinDistance,
            max = Config.MaxDistance,
            required = true
        },
        {
            type = 'select',
            label = GetTranslation('label_background_style'),
            options = Config.BackgroundStyles,
            default = scene.background.style
        },
        {
            type = 'select',
            label = GetTranslation('label_background_color'),
            options = Config.Colors,
            default = 'black'
        },
        {
            type = 'slider',
            label = GetTranslation('label_background_opacity'),
            description = GetTranslation('help_opacity'),
            min = 0,
            max = 255,
            step = 5,
            default = scene.background.opacity,
            required = true
        },
        {
            type = 'slider',
            label = GetTranslation('label_background_width'),
            description = GetTranslation('help_background_width'),
            min = 0.1,
            max = 2.0,
            step = 0.1,
            default = scene.background.width,
            required = true
        },
        {
            type = 'slider',
            label = GetTranslation('label_background_height'),
            description = GetTranslation('help_background_height'),
            min = 0.1,
            max = 2.0,
            step = 0.1,
            default = scene.background.height,
            required = true
        },
    })
    
    if not input then
        return
    end
    
    local bgColor = GetColorRGB(input[7])
    
    local updateData = {
        sceneId = sceneId,
        text = input[1],
        color = input[2],
        font = input[3],
        fontSize = input[4],
        distance = input[5],
        background = {
            style = input[6],
            r = bgColor[1],
            g = bgColor[2],
            b = bgColor[3],
            opacity = input[8],
            width = input[9],
            height = input[10]
        }
    }
    
    TriggerServerEvent('ferp-scenes:updateScene', updateData)
end

RegisterNetEvent('ferp-scenes:receiveScenes', function(scenes)
    activeScenes = {}
    drawnScenes = {}
    
    for id, scene in pairs(scenes) do
        if not scene.revealed then
            scene.revealed = false
        end
        if not scene.fade then
            scene.fade = { type = "in", fade = 0 }
        end
        if not scene.processed then
            scene.processed = false
        end
        
        if not scene.cachedDimensions then
            scene.cachedDimensions = {}
            SetTextScale(0.0, scene.fontSize)
            SetTextFont(scene.font)
            BeginTextCommandGetWidth("STRING")
            AddTextComponentSubstringPlayerName(scene.text)
            local width = EndTextCommandGetWidth(true)
            local height = GetRenderedCharacterHeight(scene.fontSize, scene.font)
            scene.cachedDimensions[tostring(scene.fontSize)] = {width = width, height = height}
        end
        
        activeScenes[id] = scene
        CreateSceneTarget(id, scene)
    end
    
    scenesLoaded = true
    needsDistanceCheck = true
end)

RegisterNetEvent('ferp-scenes:updateScene', function(id, scene)
    scene.revealed = false
    scene.fade = { type = "in", fade = 0 }
    scene.processed = false
    
    drawnScenes[id] = nil
    
    activeScenes[id] = scene
    CreateSceneTarget(id, scene)
    needsDistanceCheck = true
end)

RegisterNetEvent('ferp-scenes:removeScene', function(id)
    activeScenes[id] = nil
    drawnScenes[id] = nil
    
    if targetZones[id] then
        exports.ox_target:removeZone(targetZones[id])
        targetZones[id] = nil
    end
end)

RegisterNetEvent('ferp-scenes:toggleScenes', function()
    scenesEnabled = not scenesEnabled
    lib.notify({
        description = scenesEnabled and GetTranslation('info_enabled') or GetTranslation('info_disabled'),
        type = 'info'
    })
end)

RegisterCommand('scene', function()
    if Config.AdminOnly then
        local Player = QBX:GetPlayerData()
        local hasPermission = false
        
        for _, group in ipairs(Config.AdminGroups) do
            if Player.job and Player.job.name == group then
                hasPermission = true
                break
            end
            if Player.gang and Player.gang.name == group then
                hasPermission = true
                break
            end
            if Player.groups and Player.groups[group] then
                hasPermission = true
                break
            end
        end
        
        if not hasPermission then
            lib.notify({
                description = GetTranslation('error_client_permission'),
                type = 'error'
            })
            return
        end
    end
    
    OpenCreateSceneMenu()
end, false)

RegisterCommand('togglescenes', function()
    TriggerEvent('ferp-scenes:toggleScenes')
end, false)

CreateThread(function()
    Wait(1000)
    -- TriggerEvent('chat:addMessage', {
    --     color = {0, 255, 0},
    --     multiline = true,
    --     args = {"Scenes", "Sistema de cenas carregado"}
    -- })
    spritesLoaded = true
    TriggerServerEvent('ferp-scenes:requestScenes')
end)

CreateThread(function()
    while true do
        if scenesEnabled and scenesLoaded then
            local currentTime = GetGameTimer()
            
            if needsDistanceCheck and currentTime - updateTimer > Config.UpdateInterval and not processing then
                CreateThread(function()
                    processing = true
                    CalculateScenesToDraw()
                    needsDistanceCheck = false
                    processing = false
                end)
                updateTimer = currentTime
            end
            
            if not next(drawnScenes) then
                lastUpdate = currentTime
                Wait(100)
            else
                for id, scene in pairs(drawnScenes) do
                    local opacity = scene.fade.fade / 100
                    
                    if scene.fade.type == "in" then
                        scene.fade.fade = math.min(scene.fade.fade + Config.FadeSpeed * (currentTime - lastUpdate), 100)
                    elseif scene.fade.type == "out" then
                        scene.fade.fade = math.max(scene.fade.fade - Config.FadeSpeed * (currentTime - lastUpdate), 0)
                        
                        if math.floor(scene.fade.fade) == 0 then
                            scene.fade = { type = "in", fade = 0 }
                            drawnScenes[id] = nil
                        end
                    end
                    
                    local shouldDraw = (not scene.hidden) or (scene.hidden and scene.revealed)
                    
                    if shouldDraw then
                        DrawText3DOnWall(
                            scene.coords,
                            scene.normal,
                            scene.text,
                            scene.color,
                            scene.background,
                            scene.font,
                            scene.fontSize,
                            opacity,
                            scene.hidden,
                            Config.CheckDistance,
                            scene.cachedDimensions
                        )
                    end
                end
                
                lastUpdate = currentTime
                Wait(0)
            end
            
            if not needsDistanceCheck and currentTime - updateTimer > Config.UpdateInterval * 2 then
                needsDistanceCheck = true
            end
        else
            Wait(100)
        end
    end
end)