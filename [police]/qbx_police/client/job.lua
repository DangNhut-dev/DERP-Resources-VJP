local config = require 'config.client'
local sharedConfig = require 'config.shared'
local currentGarage = 0
local inFingerprint = false
local fingerprintSessionId = nil
local inStash = false
local inTrash = false
local inHelicopter = false
local inImpound = false
local inGarage = false
local inPrompt = false

local function openFingerprintUi()
    SendNUIMessage({
        type = 'fingerprintOpen'
    })
    SetNuiFocus(true, true)
end

local function setCarItemsInfo()
    local items = {}
    for _, item in pairs(config.carItems) do
        local itemInfo = exports.ox_inventory:Items()[item.name:lower()]
        items[item.slot] = {
            name = itemInfo.name,
            amount = tonumber(item.amount),
            info = item.info,
            label = itemInfo.label,
            description = itemInfo.description or '',
            weight = itemInfo.weight,
            type = itemInfo.type,
            unique = itemInfo.unique,
            useable = itemInfo.useable,
            image = itemInfo.image,
            slot = item.slot
        }
    end
    config.carItems = items
end

local function doCarDamage(currentVehicle, veh)
    local smash = false
    local damageOutside = false
    local popTires = false
    local engine = veh.engine + 0.0
    local body = veh.body + 0.0

    if engine < 200.0 then engine = 200.0 end
    if engine > 1000.0 then engine = 950.0 end
    if body < 150.0 then body = 150.0 end
    if body < 950.0 then smash = true end
    if body < 920.0 then damageOutside = true end
    if body < 920.0 then popTires = true end

    Wait(100)
    SetVehicleEngineHealth(currentVehicle, engine)

    if smash then
        for i = 0, 4 do
            SmashVehicleWindow(currentVehicle, i)
        end
    end

    if damageOutside then
        SetVehicleDoorBroken(currentVehicle, 1, true)
        SetVehicleDoorBroken(currentVehicle, 6, true)
        SetVehicleDoorBroken(currentVehicle, 4, true)
    end

    if popTires then
        for i = 1, 4 do
            SetVehicleTyreBurst(currentVehicle, i, false, 990.0)
        end
    end

    if body < 1000 then
        SetVehicleBodyHealth(currentVehicle, 985.1)
    end
end

local function takeOutImpound(vehicle)
    if not inImpound then return end
    local coords = sharedConfig.locations.impound[currentGarage]
    if not coords then return end

    local netId = lib.callback.await('qbx_policejob:server:spawnVehicle', false, vehicle.vehicle, coords, vehicle.plate, vehicle.id)

    local veh = lib.waitFor(function()
        if NetworkDoesEntityExistWithNetworkId(netId) then
            return NetToVeh(netId)
        end
    end)

    local properties = lib.callback.await('qb-garage:server:GetVehicleProperties', false, vehicle.plate)
    lib.setVehicleProperties(veh, properties)
    SetVehicleFuelLevel(veh, vehicle.fuel)
    doCarDamage(veh, vehicle)
    TriggerServerEvent('police:server:TakeOutImpound', vehicle.plate, currentGarage)
    SetVehicleEngineOn(veh, true, true, false)
end

local function takeOutVehicle(vehicleInfo)
    if not inGarage then return end
    local coords = sharedConfig.locations.vehicle[currentGarage]
    if not coords then return end
    local pattern = ''
    for _ = 1, 8 - #sharedConfig.policePlatePrefix do
        pattern = pattern..'1'
    end
    local plate = sharedConfig.policePlatePrefix..lib.string.random(pattern):upper()
    local netId = lib.callback.await('qbx_policejob:server:spawnVehicle', false, vehicleInfo, coords, plate, true)

    local veh = lib.waitFor(function()
        if NetworkDoesEntityExistWithNetworkId(netId) then
            return NetToVeh(netId)
        end
    end, nil, sharedConfig.timeout)

    assert(veh ~= 0, 'Something went wrong spawning the vehicle')

    setCarItemsInfo()
    SetEntityHeading(veh, coords.w)
    SetVehicleFuelLevel(veh, 100.0)
    if config.vehicleSettings[vehicleInfo] then
        if config.vehicleSettings[vehicleInfo].extras then
            qbx.setVehicleExtras(veh, config.vehicleSettings[vehicleInfo].extras)
        end
        if config.vehicleSettings[vehicleInfo].livery then
            SetVehicleLivery(veh, config.vehicleSettings[vehicleInfo].livery)
        end
    end
    SetVehicleEngineOn(veh, true, true, false)
end

local function addGarageMenuItems(destinationOptions, sourceOptions)
    for veh, label in pairs(sourceOptions) do
        destinationOptions[#destinationOptions + 1] = {
            title = label,
            onSelect = function()
                takeOutVehicle(veh)
            end,
        }
    end

    return destinationOptions
end

local function openGarageMenu()
    local authorizedVehicles = config.authorizedVehicles[QBX.PlayerData.job.grade.level]
    local options = {}

    options = addGarageMenuItems(options, authorizedVehicles)
    options = addGarageMenuItems(options, config.whitelistedVehicles)

    lib.registerContext({
        id = 'vehicleMenu',
        title = locale('menu.garage_title'),
        options = options,
    })
    lib.showContext('vehicleMenu')
end

local function openImpoundMenu()
    local options = {}
    local result = lib.callback.await('police:GetImpoundedVehicles', false)
    if not result then
        exports.qbx_core:Notify(locale('error.no_impound'), 'error')
    else
        local vehicles = exports.qbx_core:GetVehiclesByName()
        for _, v in pairs(result) do
            local enginePercent = qbx.math.round(v.engine / 10, 0)
            local currentFuel = v.fuel
            local vName = vehicles[v.vehicle].name

            options[#options + 1] = {
                title = vName..' ['..v.plate..']',
                onSelect = function()
                    takeOutImpound(v)
                end,
                metadata = {
                    {label = 'Engine', value = enginePercent .. ' %'},
                    {label = 'Fuel', value = currentFuel .. ' %'}
                },
            }
        end
    end

    lib.registerContext({
        id = 'impoundMenu',
        title = locale('menu.impound'),
        options = options
    })
    lib.showContext('impoundMenu')
end

---TODO: global evidence lockers instead of location specific
local function openEvidenceLockerSelectInput(currentEvidence)
    local input = lib.inputDialog(locale('info.evidence_stash', currentEvidence), {locale('info.slot')})
    if not input then return end
    local slotNumber = tonumber(input[1])
    TriggerServerEvent('inventory:server:OpenInventory', 'stash', locale('info.current_evidence', currentEvidence, slotNumber), {
        maxweight = 4000000,
        slots = 500,
    })
    TriggerEvent('inventory:client:SetCurrentStash', locale('info.current_evidence', currentEvidence, slotNumber))
end

local function openEvidenceMenu()
    local pos = GetEntityCoords(cache.ped)
    for k, v in pairs(sharedConfig.locations.evidence) do
        if #(pos - v) < 1 then
            openEvidenceLockerSelectInput(k)
            return
        end
    end
end

local function spawnHelicopter()
    if not inHelicopter then return end
    local plyCoords = GetEntityCoords(cache.ped)
    local coords = vec4(plyCoords.x, plyCoords.y, plyCoords.z, GetEntityHeading(cache.ped))
    local netId = lib.callback.await('qbx_policejob:server:spawnVehicle', false, config.policeHelicopter, coords, 'ZULU'..lib.string.random('1111'), true)
    local heli = lib.waitFor(function()
        if NetworkDoesEntityExistWithNetworkId(netId) then
            return NetToVeh(netId)
        end
    end, nil, sharedConfig.timeout)
    SetVehicleLivery(heli , 0)
    SetVehicleMod(heli, 0, 48, false)
    SetEntityHeading(heli, coords.w)
    SetVehicleFuelLevel(heli, 100.0)
    SetVehicleEngineOn(heli, true, true, false)
end

local function scanFingerprint()
    if not inFingerprint then return end
    local playerId = lib.getClosestPlayer(GetEntityCoords(cache.ped), 2.5, false)
    if not playerId then
        return exports.qbx_core:Notify(locale('error.none_nearby'), 'error')
    end
    TriggerServerEvent('police:server:showFingerprint', GetPlayerServerId(playerId))
end

local function uiPrompt(promptType, id)
    if QBX.PlayerData.job.type ~= 'leo' then return end
    CreateThread(function()
        while inPrompt do
            Wait(0)
            if IsControlJustReleased(0, 38) then
                if promptType == 'duty' then
                    ToggleDuty()
                    lib.hideTextUI()
                    break
                elseif promptType == 'garage' then
                    if not inGarage then return end
                    if cache.vehicle then
                        DeleteVehicle(cache.vehicle)
                        lib.hideTextUI()
                        break
                    else
                        openGarageMenu()
                        lib.hideTextUI()
                        break
                    end
                elseif promptType == 'evidence' then
                    openEvidenceMenu()
                    lib.hideTextUI()
                    break
                elseif promptType == 'impound' then
                    if not inImpound then return end
                    if cache.vehicle then
                        DeleteVehicle(cache.vehicle)
                        lib.hideTextUI()
                        break
                    else
                        openImpoundMenu()
                        lib.hideTextUI()
                        break
                    end
                elseif promptType == 'heli' then
                    if not inHelicopter then return end
                    if cache.vehicle then
                        DeleteVehicle(cache.vehicle)
                        lib.hideTextUI()
                        break
                    else
                        spawnHelicopter()
                        lib.hideTextUI()
                        break
                    end
                elseif promptType == 'fingerprint' then
                    scanFingerprint()
                    lib.hideTextUI()
                    break
                elseif promptType == 'trash' then
                    if not inTrash then return end
                    exports.ox_inventory:openInventory('stash', ('policetrash_%s'):format(id))
                    break
                elseif promptType == 'stash' then
                    if not inStash then return end
                    exports.ox_inventory:openInventory('stash', {id = 'policelocker'})
                    break
                end
            end
        end
    end)
end

RegisterNUICallback('closeFingerprint', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNetEvent('police:client:showFingerprint', function(playerId)
    openFingerprintUi()
    fingerprintSessionId = playerId
end)

RegisterNetEvent('police:client:showFingerprintId', function(fid)
    SendNUIMessage({
        type = 'updateFingerprintId',
        fingerprintId = fid
    })
    PlaySound(-1, 'Event_Start_Text', 'GTAO_FM_Events_Soundset', false, 0, true)
end)

RegisterNUICallback('doFingerScan', function(_, cb)
    TriggerServerEvent('police:server:showFingerprintId', fingerprintSessionId)
    cb('ok')
end)

RegisterNetEvent('police:client:SendEmergencyMessage', function(coords, message)
    TriggerServerEvent('police:server:SendEmergencyMessage', coords, message)
    TriggerEvent('police:client:CallAnim')
end)

RegisterNetEvent('police:client:EmergencySound', function()
    PlaySound(-1, 'Event_Start_Text', 'GTAO_FM_Events_Soundset', false, 0, true)
end)

RegisterNetEvent('police:client:CallAnim', function()
    local isCalling = true
    local callCount = 5
    lib.playAnim(cache.ped, 'cellphone@', 'cellphone_call_listen_base', 3.0, -1, -1, 49, 0, false, false, false)
    Wait(1000)
    CreateThread(function()
        while isCalling do
            Wait(1000)
            callCount -= 1
            if callCount <= 0 then
                isCalling = false
                StopAnimTask(cache.ped, 'cellphone@', 'cellphone_call_listen_base', 1.0)
            end
        end
    end)
end)

RegisterNetEvent('police:client:ImpoundVehicle', function(fullImpound, price)
    local coords = GetEntityCoords(cache.ped)
    local vehicle = lib.getClosestVehicle(coords)
    if not vehicle or not DoesEntityExist(vehicle) then return end

    local bodyDamage = math.ceil(GetVehicleBodyHealth(vehicle))
    local engineDamage = math.ceil(GetVehicleEngineHealth(vehicle))
    local totalFuel = GetVehicleFuelLevel(vehicle)

    if cache.vehicle or #(GetEntityCoords(cache.ped) - GetEntityCoords(vehicle)) > 5.0 then return end

    if lib.progressCircle({
        duration = 5000,
        position = 'bottom',
        label = locale('progressbar.impound'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true,
            mouse = false
        },
        anim = {
            dict = 'missheistdockssetup1clipboard@base',
            clip = 'base',
            flags = 1
        },
        prop = {
            {
                model = `prop_notepad_01`,
                bone = 18905,
                pos = vec3(0.1, 0.02, 0.05),
                rot = vec3(10.0, 0.0, 0.0)
            },
            {
                model = 'prop_pencil_01',
                bone = 58866,
                pos = vec3(0.11, -0.02, 0.001),
                rot = vec3(-120.0, 0.0, 0.0)
            }
        },
    })
    then
        local plate = qbx.getVehiclePlate(vehicle)
        TriggerServerEvent('police:server:Impound', plate, fullImpound, price, bodyDamage, engineDamage, totalFuel)
        DeleteVehicle(vehicle)
        exports.qbx_core:Notify(locale('success.impounded'), 'success')
    else
        exports.qbx_core:Notify(locale('error.canceled'), 'error')
    end

    ClearPedTasks(cache.ped)
end)

RegisterNetEvent('police:client:CheckStatus', function()
    if QBX.PlayerData.job.type ~= 'leo' then return end

    local playerId = lib.getClosestPlayer(GetEntityCoords(cache.ped), 5.0, false)
    if not playerId then
        return exports.qbx_core:Notify(locale('error.none_nearby'), 'error')
    end
    local result = lib.callback.await('police:GetPlayerStatus', false, GetPlayerServerId(playerId))
    if not next(result) then return end
    for _, v in pairs(result) do
        exports.qbx_core:Notify(v, 'success')
    end
end)

function ToggleDuty()
    TriggerServerEvent('QBCore:ToggleDuty')
    TriggerServerEvent('police:server:UpdateCurrentCops')
end

if config.useTarget then
    CreateThread(function()
        for i = 1, #sharedConfig.locations.duty do
            exports.ox_target:addBoxZone({
                coords = sharedConfig.locations.duty[i],
                size = vec3(1,1,3),
                debug = config.polyDebug,
                options = {{
                    distance = 1.5,
                    label = locale('info.onoff_duty'),
                    icon = 'fa-solid fa-sign-in-alt',
                    onSelect = ToggleDuty,
                    groups = 'police'
                }}
            })
        end
    end)
else
    for i = 1, #sharedConfig.locations.duty do
        lib.zones.box({
            coords = sharedConfig.locations.duty[i],
            size = vec3(2, 2, 2),
            rotation = 0.0,
            debug = config.polyDebug,
            onEnter = function()
                if QBX.PlayerData.job.type ~= 'leo' then return end
                inPrompt = true
                lib.showTextUI(locale(QBX.PlayerData.job.onduty and 'info.off_duty' or 'info.on_duty'), { position = 'left-center' })
                uiPrompt('duty')
            end,
            onExit = function()
                inPrompt = false
                lib.hideTextUI()
            end
        })
    end
end

CreateThread(function()
    -- Police Trash
    for i = 1, #sharedConfig.locations.trash do
        lib.zones.box({
            coords = sharedConfig.locations.trash[i],
            size = vec3(2, 2, 2),
            rotation = 0.0,
            debug = config.polyDebug,
            onEnter = function()
                if QBX.PlayerData.job.type ~= 'leo' or not QBX.PlayerData.job.onduty then return end
                inTrash = true
                inPrompt = true
                lib.showTextUI(locale('info.trash_enter'), { position = 'left-center' })
                uiPrompt('trash', i)
            end,
            onExit = function()
                inTrash = false
                inPrompt = false
                lib.hideTextUI()
            end
        })
    end

    -- Fingerprints
    for i = 1, #sharedConfig.locations.fingerprint do
        lib.zones.box({
            coords = sharedConfig.locations.fingerprint[i],
            size = vec3(2, 2, 2),
            rotation = 0.0,
            debug = config.polyDebug,
            onEnter = function()
                if QBX.PlayerData.job.type ~= 'leo' or not QBX.PlayerData.job.onduty then return end
                inFingerprint = true
                inPrompt = true
                lib.showTextUI(locale('info.scan_fingerprint'), { position = 'left-center' })
                uiPrompt('fingerprint')
            end,
            onExit = function()
                inFingerprint = false
                inPrompt = false
                lib.hideTextUI()
            end
        })
    end

    -- Helicopter
    for i = 1, #sharedConfig.locations.helicopter do
        lib.zones.box({
            coords = sharedConfig.locations.helicopter[i],
            size = vec3(4, 4, 4),
            rotation = 0.0,
            debug = config.polyDebug,
            onEnter = function()
                if QBX.PlayerData.job.type ~= 'leo' or not QBX.PlayerData.job.onduty then return end
                inHelicopter = true
                inPrompt = true
                uiPrompt('heli')
                lib.showTextUI(locale(cache.vehicle and 'info.store_heli' or 'info.take_heli'), { position = 'left-center' })
            end,
            onExit = function()
                inHelicopter = false
                inPrompt = false
                lib.hideTextUI()
            end
        })
    end

    -- Police Impound
    for i = 1, #sharedConfig.locations.impound do
        lib.zones.box({
            coords = sharedConfig.locations.impound[i],
            size = vec3(2, 2, 2),
            rotation = 0.0,
            debug = config.polyDebug,
            onEnter = function()
                if QBX.PlayerData.job.type ~= 'leo' or not QBX.PlayerData.job.onduty then return end
                inImpound = true
                inPrompt = true
                currentGarage = i
                lib.showTextUI(locale(cache.vehicle and 'info.impound_veh' or 'menu.pol_impound'), { position = 'left-center' })
                uiPrompt('impound')
            end,
            onExit = function()
                inImpound = false
                inPrompt = false
                lib.hideTextUI()
                currentGarage = 0
            end
        })
    end

    -- Police Garage
    for i = 1, #sharedConfig.locations.vehicle do
        lib.zones.box({
            coords = sharedConfig.locations.vehicle[i],
            size = vec3(2, 2, 2),
            rotation = 0.0,
            debug = config.polyDebug,
            onEnter = function()
                if QBX.PlayerData.job.type ~= 'leo' or not QBX.PlayerData.job.onduty then return end
                inGarage = true
                inPrompt = true
                currentGarage = i
                lib.showTextUI(locale(cache.vehicle and 'info.store_veh' or 'info.grab_veh'), { position = 'left-center' })
                uiPrompt('garage')
            end,
            onExit = function()
                inGarage = false
                inPrompt = false
                lib.hideTextUI()
            end
        })
    end
end)

CreateThread(function()
    exports.ox_target:addGlobalPlayer({
        {
            name = 'police:escort:target',
            label = 'Áp giải',
            icon = 'fas fa-people-pulling',
            distance = 2.5,
            groups = 'police',
            onSelect = function(data)
                local entity = type(data) == 'number' and data or data.entity
                if not entity or entity == 0 then return end
                local playerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                if QBX.PlayerData.metadata.ishandcuffed or IsEscorted then return end
                TriggerServerEvent('police:server:EscortPlayer', playerId)
 
                Wait(500)
                local hasAttached = false
                local players = GetActivePlayers()
                for _, p in ipairs(players) do
                    local ped = GetPlayerPed(p)
                    if ped ~= cache.ped and IsEntityAttachedToEntity(ped, cache.ped) then
                        hasAttached = true
                        break
                    end
                end
 
                if hasAttached then
                    lib.showTextUI('[X] Ngưng áp giải', { position = 'left-center', icon = 'hand' })
 
                    CreateThread(function()
                        while true do
                            Wait(0)
                            -- Check còn escort không
                            local stillEscorting = false
                            local activePlayers = GetActivePlayers()
                            for _, p in ipairs(activePlayers) do
                                local ped = GetPlayerPed(p)
                                if ped ~= cache.ped and IsEntityAttachedToEntity(ped, cache.ped) then
                                    stillEscorting = true
                                    break
                                end
                            end
 
                            if not stillEscorting then
                                lib.hideTextUI()
                                break
                            end
 
                            if IsControlJustPressed(0, 73) then -- X
                                TriggerServerEvent('police:server:EscortPlayer', playerId)
                                lib.hideTextUI()
                                break
                            end
                        end
                    end)
                end
            end,
            canInteract = function(entity)
                if QBX.PlayerData.metadata.ishandcuffed or IsEscorted then return false end
                if not QBX.PlayerData.job.onduty then return false end
                if not entity or entity == 0 or not IsPedAPlayer(entity) then return false end
 
                local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                if not targetId or targetId == 0 then return false end
 
                local targetState = Player(targetId).state
                local isDead = targetState.isDead or targetState.dead or false
                local deathType = targetState.deathType
                local isInDeathState = isDead or (deathType and deathType ~= 'none')
                local isCuffed = IsPedCuffed(entity)
                    or IsEntityPlayingAnim(entity, 'mp_arresting', 'idle', 3)
                    or IsEntityPlayingAnim(entity, 'mp_arrest_paired', 'crook_p2_back_right', 3)
 
                return isInDeathState or isCuffed
            end,
        },
        {
            name = 'police:checkstatus:target',
            label = 'Kiểm tra tình trạng',
            icon = 'fas fa-heart-pulse',
            distance = 5.0,
            groups = 'police',
            onSelect = function(data)
                local entity = type(data) == 'number' and data or data.entity
                if not entity or entity == 0 then return end
                local playerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                local result = lib.callback.await('police:GetPlayerStatus', false, playerId)
                if not result or not next(result) then
                    return exports.qbx_core:Notify(locale('error.none_nearby'), 'error')
                end
                for _, v in pairs(result) do
                    exports.qbx_core:Notify(v, 'success')
                end
            end,
            canInteract = function(entity)
                if not QBX.PlayerData.job.onduty then return false end
                if not entity or entity == 0 or not IsPedAPlayer(entity) then return false end
                return true
            end,
        },
        {
            name = 'police:searchplayer:target',
            label = 'Khám người',
            icon = 'fas fa-magnifying-glass',
            distance = 2.5,
            groups = 'police',
            onSelect = function(data)
                local entity = type(data) == 'number' and data or data.entity
                if not entity or entity == 0 then return end
                local playerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                exports.ox_inventory:openNearbyInventory()
                TriggerServerEvent('police:server:SearchPlayer', playerId)
            end,
            canInteract = function(entity)
                if QBX.PlayerData.metadata.ishandcuffed or IsEscorted then return false end
                if not QBX.PlayerData.job.onduty then return false end
                if not entity or entity == 0 or not IsPedAPlayer(entity) then return false end
 
                -- Target phải đang còng, chết, hoặc giơ tay
                local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                if not targetId or targetId == 0 then return false end
 
                local targetState = Player(targetId).state
                local isDead = targetState.isDead or targetState.dead or false
                local deathType = targetState.deathType
                local isInDeathState = isDead or (deathType and deathType ~= 'none')
                local isCuffed = IsPedCuffed(entity)
                    or IsEntityPlayingAnim(entity, 'mp_arresting', 'idle', 3)
                local isHandsUp = IsEntityPlayingAnim(entity, 'missminuteman_1ig_2', 'handsup_base', 3)
 
                return isInDeathState or isCuffed or isHandsUp
            end,
        },
    })
 
    -- Rob qua ox_target (tất cả người chơi KHÔNG phải police)
    exports.ox_target:addGlobalPlayer({
        {
            name = 'civilian:robplayer:target',
            label = 'Cướp',
            icon = 'fas fa-hand-holding-dollar',
            distance = 2.5,
            onSelect = function(data)
                local entity = type(data) == 'number' and data or data.entity
                if not entity or entity == 0 then return end
                local playerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                local targetPed = entity
 
                -- Check: giơ tay, còng, hoặc chết/ngất (state bags)
                local isHandsUp = IsEntityPlayingAnim(targetPed, 'missminuteman_1ig_2', 'handsup_base', 3)
                local isCuffed = IsPedCuffed(targetPed)
                    or IsEntityPlayingAnim(targetPed, 'mp_arresting', 'idle', 3)
                local targetState = Player(playerId).state
                local isDead = targetState.isDead or targetState.dead or false
                local deathType = targetState.deathType
                local isInDeathState = isDead or (deathType and deathType ~= 'none')
 
                if not (isHandsUp or isCuffed or isInDeathState) then
                    return exports.qbx_core:Notify(locale('error.no_rob'), 'error')
                end
 
                if lib.progressBar({
                    duration = math.random(5000, 7000),
                    label = locale('progressbar.robbing'),
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        move = true,
                        car = true,
                        combat = true,
                        mouse = false
                    },
                    anim = {
                        dict = 'random@shop_robbery',
                        clip = 'robbery_action_b',
                        flags = 16
                    }
                }) then
                    local playerCoords = GetEntityCoords(targetPed)
                    local pos = GetEntityCoords(cache.ped)
                    if #(pos - playerCoords) < 2.5 then
                        StopAnimTask(cache.ped, 'random@shop_robbery', 'robbery_action_b', 1.0)
                        TriggerServerEvent('police:server:RobPlayer', playerId)
                        TriggerServerEvent('police:server:RobOpenInventory', playerId)
                    else
                        exports.qbx_core:Notify(locale('error.none_nearby'), 'error')
                    end
                else
                    StopAnimTask(cache.ped, 'random@shop_robbery', 'robbery_action_b', 1.0)
                    exports.qbx_core:Notify(locale('error.canceled'), 'error')
                end
            end,
            canInteract = function(entity)
                -- Không cho police rob
                if QBX.PlayerData.job.type == 'leo' then return false end
                if QBX.PlayerData.metadata.ishandcuffed then return false end
                if IsPedInAnyVehicle(cache.ped, false) then return false end
 
                if not entity or entity == 0 or not IsPedAPlayer(entity) then return false end
                if IsPedInAnyVehicle(entity, false) then return false end
 
                local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                if not targetId or targetId == 0 then return false end
 
                -- Target phải giơ tay, còng, hoặc chết
                local isHandsUp = IsEntityPlayingAnim(entity, 'missminuteman_1ig_2', 'handsup_base', 3)
                local isCuffed = IsPedCuffed(entity)
                    or IsEntityPlayingAnim(entity, 'mp_arresting', 'idle', 3)
                local targetState = Player(targetId).state
                local isDead = targetState.isDead or targetState.dead or false
                local deathType = targetState.deathType
                local isInDeathState = isDead or (deathType and deathType ~= 'none')
 
                return isHandsUp or isCuffed or isInDeathState
            end,
        },
    })
end)