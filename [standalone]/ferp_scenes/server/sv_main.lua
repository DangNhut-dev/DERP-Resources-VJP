local QBX = exports.qbx_core
local activeScenes = {}

local function CountPlayerScenes(citizenid)
    local count = 0
    for _, scene in pairs(activeScenes) do
        if scene.creator == citizenid then
            count = count + 1
        end
    end
    return count
end

local function CountGlobalScenes()
    local count = 0
    for _ in pairs(activeScenes) do
        count = count + 1
    end
    return count
end

local function LoadScenesFromDB()
    local result = MySQL.query.await([[
        SELECT * FROM scenes 
        WHERE expires_at > UNIX_TIMESTAMP()
        ORDER BY created_at DESC
    ]], {})
    
    if result then
        for _, scene in ipairs(result) do
            local coords = json.decode(scene.coords)
            local normal = json.decode(scene.normal)
            local background = json.decode(scene.background)
            
            local isHidden = false
            if scene.hidden == 1 or scene.hidden == true or scene.hidden == 'true' then
                isHidden = true
            end
            
            activeScenes[scene.id] = {
                id = scene.id,
                coords = vector3(coords.x, coords.y, coords.z),
                normal = vector3(normal.x, normal.y, normal.z),
                text = scene.text,
                color = scene.color,
                font = scene.font,
                fontSize = scene.font_size,
                distance = scene.distance,
                background = background,
                hidden = isHidden,
                revealed = false,
                creator = scene.creator,
                created_at = scene.created_at,
                expires_at = scene.expires_at,
                processed = false
            }
        end
    end
    
    return activeScenes
end

local function CleanupExpiredScenes()
    local deleted = MySQL.query.await([[
        DELETE FROM scenes 
        WHERE expires_at <= UNIX_TIMESTAMP()
    ]], {})
    
    if deleted and deleted.affectedRows > 0 then
        print('[ferp-scenes] Removidas ' .. deleted.affectedRows .. ' cenas expiradas')
    end
end

local function HasPermission(source)
    if not Config.AdminOnly then
        return true
    end
    
    local Player = QBX:GetPlayer(source)
    if not Player then return false end
    
    for _, group in ipairs(Config.AdminGroups) do
        if QBX:HasGroup(source, group) then
            return true
        end
    end
    
    return false
end

RegisterNetEvent('ferp-scenes:requestScenes', function()
    local src = source
    TriggerClientEvent('ferp-scenes:receiveScenes', src, activeScenes)
end)

RegisterNetEvent('ferp-scenes:createScene', function(sceneData)
    local src = source
    
    if not HasPermission(src) then
        lib.notify(src, {
            description = GetTranslation('error_permission'),
            type = 'error'
        })
        return
    end
    
    local Player = QBX:GetPlayer(src)
    if not Player then return end
    
    local globalCount = CountGlobalScenes()
    if globalCount >= Config.MaxScenesGlobal then
        lib.notify(src, {
            description = GetTranslation('error_global_limit'),
            type = 'error'
        })
        return
    end
    
    local playerCount = CountPlayerScenes(Player.PlayerData.citizenid)
    if playerCount >= Config.MaxScenesPerPlayer then
        lib.notify(src, {
            description = GetTranslation('error_player_limit'),
            type = 'error'
        })
        return
    end
    
    if not sceneData.text or #sceneData.text > Config.MaxTextLength then
        lib.notify(src, {
            description = GetTranslation('error_text_invalid'),
            type = 'error'
        })
        return
    end
    
    if not sceneData.distance or sceneData.distance < Config.MinDistance or sceneData.distance > Config.MaxDistance then
        lib.notify(src, {
            description = GetTranslation('error_distance_invalid'),
            type = 'error'
        })
        return
    end
    
    if not sceneData.duration or sceneData.duration < 1 or sceneData.duration > Config.MaxDuration then
        sceneData.duration = Config.DefaultDuration
    end
    
    local expiresAt = os.time() + (sceneData.duration * 3600)
    
    local insertId = MySQL.insert.await([[
        INSERT INTO scenes (
            coords, normal, text, color, font, font_size, 
            distance, background, hidden, creator, 
            created_at, expires_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, UNIX_TIMESTAMP(), ?)
    ]], {
        json.encode(sceneData.coords),
        json.encode(sceneData.normal or vector3(0, 0, 0)),
        sceneData.text,
        sceneData.color,
        sceneData.font,
        sceneData.fontSize,
        sceneData.distance,
        json.encode(sceneData.background),
        sceneData.hidden and 1 or 0,
        Player.PlayerData.citizenid,
        expiresAt
    })
    
    if insertId then
        local newScene = {
            id = insertId,
            coords = sceneData.coords,
            normal = sceneData.normal or vector3(0, 0, 0),
            text = sceneData.text,
            color = sceneData.color,
            font = sceneData.font,
            fontSize = sceneData.fontSize,
            distance = sceneData.distance,
            background = sceneData.background,
            hidden = sceneData.hidden,
            revealed = false,
            creator = Player.PlayerData.citizenid,
            created_at = os.time(),
            expires_at = expiresAt,
            processed = false
        }
        
        print('[ferp-scenes] Cena criada - Hidden: ' .. tostring(sceneData.hidden))
        
        activeScenes[insertId] = newScene
        
        TriggerClientEvent('ferp-scenes:updateScene', -1, insertId, newScene)
        
        lib.notify(src, {
            description = GetTranslation('success_created', sceneData.duration),
            type = 'success'
        })
    else
        lib.notify(src, {
            description = GetTranslation('error_db'),
            type = 'error'
        })
    end
end)

RegisterNetEvent('ferp-scenes:updateScene', function(updateData)
    local src = source
    local sceneId = updateData.sceneId
    
    if not activeScenes[sceneId] then
        lib.notify(src, {
            description = GetTranslation('error_not_found'),
            type = 'error'
        })
        return
    end
    
    local Player = QBX:GetPlayer(src)
    if not Player then return end
    
    local scene = activeScenes[sceneId]
    local isAdmin = false
    
    for _, group in ipairs(Config.AdminGroups) do
        if QBX:HasGroup(src, group) then
            isAdmin = true
            break
        end
    end
    
    if scene.creator ~= Player.PlayerData.citizenid and not isAdmin then
        lib.notify(src, {
            description = GetTranslation('error_permission_edit'),
            type = 'error'
        })
        return
    end
    local updated = MySQL.update.await('UPDATE scenes SET text = ?, color = ?, font = ?, font_size = ?, background = ? WHERE id = ?', {
        updateData.text,
        updateData.color,
        updateData.font,
        updateData.fontSize,
        json.encode(updateData.background),
        sceneId
    })
    
    if updated then
        activeScenes[sceneId].text = updateData.text
        activeScenes[sceneId].color = updateData.color
        activeScenes[sceneId].font = updateData.font
        activeScenes[sceneId].fontSize = updateData.fontSize
        activeScenes[sceneId].background = updateData.background
        
        TriggerClientEvent('ferp-scenes:updateScene', -1, sceneId, activeScenes[sceneId])
        
        lib.notify(src, {
            description = GetTranslation('success_updated'),
            type = 'success'
        })
    else
        lib.notify(src, {
            description = GetTranslation('error_db'),
            type = 'error'
        })
    end
end)

RegisterNetEvent('ferp-scenes:deleteScene', function(sceneId)
    local src = source
    
    if not activeScenes[sceneId] then
        lib.notify(src, {
            description = GetTranslation('error_not_found'),
            type = 'error'
        })
        return
    end
    
    local Player = QBX:GetPlayer(src)
    if not Player then return end
    
    local scene = activeScenes[sceneId]
    local isAdmin = false
    
    for _, group in ipairs(Config.AdminGroups) do
        if QBX:HasGroup(src, group) then
            isAdmin = true
            break
        end
    end
    
    if scene.creator ~= Player.PlayerData.citizenid and not isAdmin then
        lib.notify(src, {
            description = GetTranslation('error_delete_permission'),
            type = 'error'
        })
        return
    end
    
    local deleted = MySQL.query.await([[
        DELETE FROM scenes WHERE id = ?
    ]], {sceneId})
    
    if deleted and deleted.affectedRows > 0 then
        activeScenes[sceneId] = nil
        TriggerClientEvent('ferp-scenes:removeScene', -1, sceneId)
        
        lib.notify(src, {
            description = GetTranslation('success_deleted'),
            type = 'success'
        })
    else
        lib.notify(src, {
            description = GetTranslation('error_delete_failed'),
            type = 'error'
        })
    end
end)

RegisterCommand('clearscenes', function(source, args, rawCommand)
    local src = source
    
    local hasPermission = false
    for _, group in ipairs(Config.AdminGroups) do
        if QBX:HasGroup(src, group) then
            hasPermission = true
            break
        end
    end
    
    if not hasPermission then
        lib.notify(src, {
            description = GetTranslation('cmd_clearscenes_error'),
            type = 'error'
        })
        return
    end
    
    CleanupExpiredScenes()
    
    activeScenes = LoadScenesFromDB()
    TriggerClientEvent('ferp-scenes:receiveScenes', -1, activeScenes)
    
    lib.notify(src, {
        description = GetTranslation('cmd_clearscenes_success'),
        type = 'success'
    })
end, false)

RegisterCommand('deletescene', function(source, args, rawCommand)
    local src = source
    local sceneId = tonumber(args[1])
    
    if not sceneId then
        lib.notify(src, {
            description = GetTranslation('cmd_deletescene_usage'),
            type = 'error'
        })
        return
    end
    
    local hasPermission = false
    for _, group in ipairs(Config.AdminGroups) do
        if QBX:HasGroup(src, group) then
            hasPermission = true
            break
        end
    end
    
    if not hasPermission then
        lib.notify(src, {
            description = GetTranslation('error_no_permission_cmd'),
            type = 'error'
        })
        return
    end
    
    if not activeScenes[sceneId] then
        lib.notify(src, {
            description = GetTranslation('cmd_deletescene_not_found'),
            type = 'error'
        })
        return
    end
    
    MySQL.query.await([[
        DELETE FROM scenes WHERE id = ?
    ]], {sceneId})
    
    activeScenes[sceneId] = nil
    TriggerClientEvent('ferp-scenes:removeScene', -1, sceneId)
    
    lib.notify(src, {
        description = GetTranslation('cmd_deletescene_deleted', sceneId),
        type = 'success'
    })
end, false)

RegisterCommand('listscenes', function(source, args, rawCommand)
    local src = source
    
    local hasPermission = false
    for _, group in ipairs(Config.AdminGroups) do
        if QBX:HasGroup(src, group) then
            hasPermission = true
            break
        end
    end
    
    if not hasPermission then
        lib.notify(src, {
            description = GetTranslation('error_no_permission_cmd'),
            type = 'error'
        })
        return
    end
    
    local sceneList = {}
    
    for id, scene in pairs(activeScenes) do
        local timeLeft = scene.expires_at - os.time()
        local hoursLeft = math.floor(timeLeft / 3600)
        
        table.insert(sceneList, {
            id = id,
            text = scene.text:sub(1, 30) .. (scene.text:len() > 30 and '...' or ''),
            creator = scene.creator,
            expires = hoursLeft .. 'h'
        })
    end
    
    if #sceneList == 0 then
        lib.notify(src, {
            description = GetTranslation('error_no_scenes'),
            type = 'info'
        })
    else
        print('[ferp-scenes] Cenas Ativas:')
        for _, scene in ipairs(sceneList) do
            print(string.format('ID: %d | Texto: %s | Criador: %s | Expira: %s', 
                scene.id, scene.text, scene.creator, scene.expires))
        end
        
        lib.notify(src, {
            description = GetTranslation('info_check_console'),
            type = 'info'
        })
    end
end, false)

RegisterCommand('scenescount', function(source, args, rawCommand)
    local src = source
    local globalCount = CountGlobalScenes()
    
    print('^2[ferp-scenes] Contagem Global: ' .. globalCount .. '/' .. Config.MaxScenesGlobal .. '^7')
    
    local Player = QBX:GetPlayer(src)
    if Player then
        local playerCount = CountPlayerScenes(Player.PlayerData.citizenid)
        print('^2[ferp-scenes] Suas Cenas: ' .. playerCount .. '/' .. Config.MaxScenesPerPlayer .. '^7')
        
        lib.notify(src, {
            description = GetTranslation('info_count', globalCount, Config.MaxScenesGlobal, playerCount, Config.MaxScenesPerPlayer),
            type = 'info'
        })
    end
end, false)

CreateThread(function()
    CleanupExpiredScenes()
    
    activeScenes = LoadScenesFromDB()
    
    print('[ferp-scenes] Sistema iniciado com ' .. #activeScenes .. ' cenas ativas')
    
    while true do
        Wait(3600000)
        CleanupExpiredScenes()
        activeScenes = LoadScenesFromDB()
        TriggerClientEvent('ferp-scenes:receiveScenes', -1, activeScenes)
    end
end)