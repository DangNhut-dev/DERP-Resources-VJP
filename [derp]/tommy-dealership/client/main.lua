local PlayerData       = {}
local currentShop      = nil
local showroomVehicles = {}
local testDriveVehicle = nil
local isTestDriving    = false
local isNearShowroom   = {}
local hasSpawnedVehicles = {}
local selfPurchaseNPC  = nil
local npcZone          = nil

-- Tablet
local tabletDict   = 'amb@world_human_seat_wall_tablet@female@base'
local tabletAnim   = 'base'
local tabletProp   = `prop_cs_tablet`
local tabletBone   = 60309
local tabletOffset = vector3(0.03, 0.002, -0.0)
local tabletRot    = vector3(10.0, 160.0, 0.0)
local isHoldingTablet = false
local tabletObject    = nil

-- Locale
local Locale         = {}
local AvailableLocales = {}

local function LoadLocale(lang)
    local file = LoadResourceFile(GetCurrentResourceName(), ('locales/%s.lua'):format(lang))
    if not file then return {} end
    local fn = load(file)
    return fn and fn() or {}
end

local function LoadAllLocales()
    AvailableLocales = { en = LoadLocale('en'), vi = LoadLocale('vi') }
    Locale = AvailableLocales.vi
end

LoadAllLocales()

-- Tablet animation
local function StartTabletAnimation()
    if isHoldingTablet then return end
    local ped = PlayerPedId()
    lib.requestAnimDict(tabletDict)
    lib.requestModel(tabletProp)
    tabletObject = CreateObject(tabletProp, 0.0, 0.0, 0.0, true, true, false)
    AttachEntityToEntity(tabletObject, ped, GetPedBoneIndex(ped, tabletBone),
        tabletOffset.x, tabletOffset.y, tabletOffset.z,
        tabletRot.x, tabletRot.y, tabletRot.z,
        true, true, false, true, 1, true)
    TaskPlayAnim(ped, tabletDict, tabletAnim, 8.0, 8.0, -1, 49, 0, false, false, false)
    isHoldingTablet = true
end

local function StopTabletAnimation()
    if not isHoldingTablet then return end
    local ped = PlayerPedId()
    StopAnimTask(ped, tabletDict, tabletAnim, 1.0)
    if DoesEntityExist(tabletObject) then
        DeleteObject(tabletObject)
        tabletObject = nil
    end
    ClearPedTasks(ped)
    isHoldingTablet = false
end

local function KeepTabletAnimationPlaying()
    CreateThread(function()
        while isHoldingTablet do
            local ped = PlayerPedId()
            if not IsEntityPlayingAnim(ped, tabletDict, tabletAnim, 3) then
                TaskPlayAnim(ped, tabletDict, tabletAnim, 8.0, 8.0, -1, 49, 0, false, false, false)
            end
            DisableControlAction(0, 24,  true)
            DisableControlAction(0, 25,  true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 257, true)
            Wait(0)
        end
    end)
end

-- Safe vehicle spawn with pcall guard on model load
local function SafeSpawnVehicle(model, coords, networked, mission)
    RequestCollisionAtCoord(coords.x, coords.y, coords.z)

    local ok, err = pcall(lib.requestModel, model)
    if not ok then
        print(('[tommy-dealership] SafeSpawnVehicle: skipped model %s - %s'):format(tostring(model), tostring(err)))
        return nil
    end

    local hash    = type(model) == 'number' and model or GetHashKey(model)
    local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, coords.w, networked or false, mission or false)
    FreezeEntityPosition(vehicle, true)

    local timeout = 0
    while not HasCollisionLoadedAroundEntity(vehicle) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end

    SetEntityCoords(vehicle, coords.x, coords.y, coords.z, false, false, false, true)
    SetEntityHeading(vehicle, coords.w)
    SetVehicleModKit(vehicle, 0)
    SetVehicleDirtLevel(vehicle, 0.0)
    SetVehicleUndriveable(vehicle, false)
    SetVehicleEngineOn(vehicle, true, true, false)
    Wait(100)
    SetVehicleEngineOn(vehicle, false, true, true)
    SetVehicleUndriveable(vehicle, true)
    SetVehicleExtraColours(vehicle, 0, 0)
    ClearVehicleCustomPrimaryColour(vehicle)
    ClearVehicleCustomSecondaryColour(vehicle)
    Wait(100)

    return vehicle
end

-- Spawn self purchase NPC
local function SpawnSelfPurchaseNPC()
    if not Config.SelfPurchaseNPC.enabled then return end

    local cfg   = Config.SelfPurchaseNPC
    local model = GetHashKey(cfg.model)
    lib.requestModel(cfg.model)

    selfPurchaseNPC = CreatePed(4, model, cfg.coords.x, cfg.coords.y, cfg.coords.z, cfg.coords.w, false, true)
    SetEntityHeading(selfPurchaseNPC, cfg.coords.w)
    FreezeEntityPosition(selfPurchaseNPC, cfg.frozen)
    SetEntityInvincible(selfPurchaseNPC, cfg.invincible)
    SetBlockingOfNonTemporaryEvents(selfPurchaseNPC, cfg.blockevents)

    if cfg.scenario then
        TaskStartScenarioInPlace(selfPurchaseNPC, cfg.scenario, 0, true)
    end

    if Config.UsingTarget then
        exports.ox_target:addLocalEntity(selfPurchaseNPC, {
            {
                name     = 'tommy_dealership_self_purchase',
                icon     = 'fas fa-car',
                label    = Locale['open_self_purchase'] or 'Mua Xe',
                distance = 2.5,
                onSelect = function()
                    TriggerEvent('tommy-dealership:client:OpenSelfPurchase')
                end
            }
        })
    else
        local npcCoords = vec3(cfg.coords.x, cfg.coords.y, cfg.coords.z)
        npcZone = lib.zones.sphere({
            coords   = npcCoords,
            radius   = 3.0,
            onEnter  = function()
                lib.showTextUI('[E] ' .. (Locale['open_self_purchase'] or 'Mua Xe'), { position = 'left-center' })
            end,
            onExit   = function()
                lib.hideTextUI()
            end,
            inside   = function()
                if IsControlJustReleased(0, 38) then
                    TriggerEvent('tommy-dealership:client:OpenSelfPurchase')
                end
            end
        })
    end
end

-- Proximity check thread
local function StartProximityCheck()
    CreateThread(function()
        while true do
            local pCoords = GetEntityCoords(PlayerPedId())
            local render  = Config.ShowroomRenderDistance or 100.0

            for shopName, shopData in pairs(Config.Shops) do
                local dist = #(pCoords - shopData.Location)

                if dist < render and not isNearShowroom[shopName] then
                    isNearShowroom[shopName] = true
                    SpawnShowroomVehiclesForShop(shopName)
                elseif dist >= render and isNearShowroom[shopName] then
                    isNearShowroom[shopName]    = false
                    hasSpawnedVehicles[shopName] = false
                    DeleteShowroomVehiclesForShop(shopName)
                end
            end

            Wait(2000)
        end
    end)
end

function SpawnShowroomVehiclesForShop(shopName)
    if hasSpawnedVehicles[shopName] then return end
    hasSpawnedVehicles[shopName] = true

    local shopData = Config.Shops[shopName]

    lib.callback('tommy-dealership:server:GetShowroomVehicles', false, function(vehicles)
        if not vehicles then return end
        for slot, vData in pairs(vehicles) do
            local slotCfg = shopData.ShowroomVehicles[slot]
            if not slotCfg then goto continue end

            local model = vData.vehicle or slotCfg.defaultVehicle
            local color = vData.color or 0

            if model and model ~= '' and model ~= '0' and model ~= 0 then
                CreateThread(function()
                    local vehicle = SafeSpawnVehicle(model, slotCfg.coords, false, false)
                    if not vehicle then return end
                    SetEntityAsMissionEntity(vehicle, true, true)
                    SetVehicleDoorsLocked(vehicle, 2)
                    SetEntityInvincible(vehicle, true)
                    FreezeEntityPosition(vehicle, true)
                    SetVehicleNumberPlateText(vehicle, 'DEALER')
                    SetVehicleEngineOn(vehicle, false, true, true)
                    SetVehicleUndriveable(vehicle, true)
                    SetVehicleDirtLevel(vehicle, 0.0)
                    WashDecalsFromVehicle(vehicle, 1.0)
                    SetVehicleColours(vehicle, color, color)

                    showroomVehicles[#showroomVehicles + 1] = {
                        entity = vehicle,
                        shop   = shopName,
                        slot   = slot,
                        model  = model,
                        color  = color
                    }
                end)
                Wait(200)
            end

            ::continue::
        end
    end, shopName)
end

function DeleteShowroomVehiclesForShop(shopName)
    for i = #showroomVehicles, 1, -1 do
        local v = showroomVehicles[i]
        if v.shop == shopName then
            if DoesEntityExist(v.entity) then DeleteEntity(v.entity) end
            table.remove(showroomVehicles, i)
        end
    end
end

-- Init
CreateThread(function()
    PlayerData = exports.qbx_core:GetPlayerData()
    SpawnSelfPurchaseNPC()

    for shopName, shopData in pairs(Config.Shops) do
        if shopData.showBlip then
            local blip = AddBlipForCoord(shopData.Location.x, shopData.Location.y, shopData.Location.z)
            SetBlipSprite(blip, shopData.blipSprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.75)
            SetBlipAsShortRange(blip, true)
            SetBlipColour(blip, shopData.blipColor)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(shopData.ShopLabel)
            EndTextCommandSetBlipName(blip)
        end
        isNearShowroom[shopName]    = false
        hasSpawnedVehicles[shopName] = false
    end

    StartProximityCheck()
end)

AddEventHandler('qbx_core:client:onPlayerLoaded', function()
    PlayerData = exports.qbx_core:GetPlayerData()
end)

AddEventHandler('qbx_core:client:onJobUpdate', function(job)
    PlayerData.job = job
end)

AddEventHandler('qbx_core:client:setPlayerData', function(val)
    if val then PlayerData = val end
end)

-- Open self purchase
RegisterNetEvent('tommy-dealership:client:OpenSelfPurchase', function()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local cfg          = Config.SelfPurchaseNPC
    local dist         = #(playerCoords - vec3(cfg.coords.x, cfg.coords.y, cfg.coords.z))

    if dist > cfg.checkDistance then
        lib.notify({ description = Locale['too_far_from_npc'] or 'Bạn đứng quá xa!', type = 'error' })
        return
    end

    currentShop = nil
    for shopName, shopData in pairs(Config.Shops) do
        if #(playerCoords - shopData.Location) < 100.0 then
            currentShop = shopName
            break
        end
    end

    if not currentShop then
        lib.notify({ description = Locale['not_at_dealership'] or 'Bạn không ở đại lý!', type = 'error' })
        return
    end

    lib.callback('tommy-dealership:server:GetSelfPurchaseData', false, function(data)
        if not data then return end
        lib.notify({ description = 'Giá tự mua cao hơn ' .. math.floor(Config.SelfPurchaseMarkup * 100) .. '% so với giá dealer', type = 'inform' })
        SetNuiFocus(true, true)
        SendNUIMessage({ action = 'openSelfPurchase', data = data, locale = AvailableLocales, colors = Config.VehicleColors })
    end, currentShop)
end)

-- Triggered by ox_inventory client.event field on item use
RegisterNetEvent('tommy-dealership:client:OpenTablet', function()
    local currentPlayerData = exports.qbx_core:GetPlayerData()
    if not currentPlayerData or not currentPlayerData.job or currentPlayerData.job.name ~= Config.DealerJob then
        lib.notify({ description = Locale['not_dealer'] or 'Bạn không phải nhân viên đại lý!', type = 'error' })
        return
    end

    local playerCoords = GetEntityCoords(PlayerPedId())
    currentShop        = nil
    for shopName, shopData in pairs(Config.Shops) do
        if #(playerCoords - shopData.Location) < 50.0 then
            currentShop = shopName
            break
        end
    end

    if not currentShop then
        lib.notify({ description = Locale['not_at_dealership'] or 'Bạn không ở đại lý!', type = 'error' })
        return
    end

    StartTabletAnimation()
    KeepTabletAnimationPlaying()

    lib.callback('tommy-dealership:server:GetDealershipData', false, function(data)
        if not data then
            StopTabletAnimation()
            lib.notify({ description = Locale['not_dealer'] or 'Không có quyền truy cập!', type = 'error' })
            return
        end
        SetNuiFocus(true, true)
        SendNUIMessage({ action = 'openTablet', data = data, locale = AvailableLocales, colors = Config.VehicleColors })
    end, currentShop)
end)

-- Update showroom vehicle
RegisterNetEvent('tommy-dealership:client:UpdateShowroomVehicle', function(shopName, slot, vehicleModel, color)
    if not isNearShowroom[shopName] then return end

    for i, v in pairs(showroomVehicles) do
        if v.shop == shopName and v.slot == slot then
            if DoesEntityExist(v.entity) then DeleteEntity(v.entity) end
            table.remove(showroomVehicles, i)
            break
        end
    end

    if vehicleModel then
        CreateThread(function()
            local shopData = Config.Shops[shopName]
            local coords   = shopData.ShowroomVehicles[slot].coords
            local vehicle  = SafeSpawnVehicle(vehicleModel, coords, false, false)
            if not vehicle then return end

            SetEntityAsMissionEntity(vehicle, true, true)
            SetVehicleDoorsLocked(vehicle, 2)
            SetEntityInvincible(vehicle, true)
            FreezeEntityPosition(vehicle, true)
            SetVehicleNumberPlateText(vehicle, 'DEALER')
            SetVehicleEngineOn(vehicle, false, true, true)
            SetVehicleUndriveable(vehicle, true)
            SetVehicleDirtLevel(vehicle, 0.0)
            WashDecalsFromVehicle(vehicle, 1.0)
            SetVehicleColours(vehicle, color or 0, color or 0)
            SetVehicleExtraColours(vehicle, 0, 0)
            ClearVehicleCustomPrimaryColour(vehicle)
            ClearVehicleCustomSecondaryColour(vehicle)

            showroomVehicles[#showroomVehicles + 1] = {
                entity = vehicle,
                shop   = shopName,
                slot   = slot,
                model  = vehicleModel,
                color  = color or 0
            }
        end)
    end
end)

-- Spawn purchased vehicle
RegisterNetEvent('tommy-dealership:client:SpawnVehicle', function(vehicleData, shop)
    local shopData = Config.Shops[shop]
    local coords   = shopData.VehicleSpawn

    CreateThread(function()
        local vehicle = SafeSpawnVehicle(vehicleData.model, coords, true, false)
        if not vehicle then
            lib.notify({ description = 'Không thể spawn xe! Liên hệ admin.', type = 'error' })
            return
        end
        SetVehicleColours(vehicle, vehicleData.color or 0, vehicleData.color or 0)
        SetVehicleExtraColours(vehicle, vehicleData.color or 0, vehicleData.color or 0)
        SetVehicleModKit(vehicle, 0)
        for i = 0, 49 do RemoveVehicleMod(vehicle, i) end
        for i = 0, 20 do SetVehicleExtra(vehicle, i, 1) end
        SetVehicleWindowTint(vehicle, 0)
        SetVehicleNeonLightsColour(vehicle, 255, 255, 255)
        for i = 0, 3 do SetVehicleNeonLightEnabled(vehicle, i, false) end
        SetVehicleNumberPlateText(vehicle, vehicleData.plate)
        SetVehicleEngineHealth(vehicle, 1000.0)
        SetVehicleBodyHealth(vehicle, 1000.0)
        SetVehiclePetrolTankHealth(vehicle, 1000.0)
        SetVehicleFuelLevel(vehicle, 100.0)
        SetVehicleOilLevel(vehicle, 100.0)
        SetVehicleDirtLevel(vehicle, 0.0)
        WashDecalsFromVehicle(vehicle, 1.0)
        FreezeEntityPosition(vehicle, false)
        Wait(500)
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        local netId = NetworkGetNetworkIdFromEntity(vehicle)
        lib.callback.await('qbx_vehiclekeys:server:giveKeys', false, netId)
    end)
end)

-- Test drive
RegisterNetEvent('tommy-dealership:client:StartTestDriveForCustomer', function(vehicle, color, timeLimit, shop)
    local targetShop = shop
    if not targetShop then
        local pCoords = GetEntityCoords(PlayerPedId())
        for shopName, shopData in pairs(Config.Shops) do
            if #(pCoords - shopData.Location) < 100.0 then
                targetShop = shopName
                break
            end
        end
    end

    if not targetShop then
        lib.notify({ description = 'Not near any dealership', type = 'error' })
        return
    end

    local spawnCoords = Config.Shops[targetShop].TestDriveSpawn

    CreateThread(function()
        testDriveVehicle = SafeSpawnVehicle(vehicle, spawnCoords, true, false)
        if not testDriveVehicle then
            lib.notify({ description = 'Không thể spawn xe test drive!', type = 'error' })
            return
        end
        SetVehicleColours(testDriveVehicle, color or 0, color or 0)
        SetVehicleModKit(testDriveVehicle, 0)
        for i = 0, 49 do RemoveVehicleMod(testDriveVehicle, i) end
        SetVehicleNumberPlateText(testDriveVehicle, 'TEST')
        FreezeEntityPosition(testDriveVehicle, false)
        Wait(1500)
        TaskWarpPedIntoVehicle(PlayerPedId(), testDriveVehicle, -1)
        local netId = NetworkGetNetworkIdFromEntity(testDriveVehicle)
        lib.callback.await('qbx_vehiclekeys:server:giveKeys', false, netId)
        isTestDriving = true
        currentShop   = targetShop

        local remaining    = timeLimit
        local displayText  = (Locale['test_drive_started'] or 'Test Drive') .. ': ' .. remaining .. 's'

        -- Frame render thread
        CreateThread(function()
            while isTestDriving do
                SetTextFont(4)
                SetTextProportional(true)
                SetTextScale(0.0, 0.45)
                SetTextColour(255, 255, 255, 255)
                SetTextOutline()
                SetTextEntry('STRING')
                AddTextComponentSubstringPlayerName(displayText)
                DrawText(0.5, 0.92)
                Wait(0)
            end
        end)

        -- Countdown loop
        while remaining > 0 and isTestDriving do
            Wait(1000)
            remaining    = remaining - 1
            displayText  = (Locale['test_drive_started'] or 'Test Drive') .. ': ' .. remaining .. 's'
        end
        if isTestDriving then
            TriggerServerEvent('tommy-dealership:server:EndTestDrive', targetShop)
        end
    end)
end)

RegisterNetEvent('tommy-dealership:client:EndTestDrive', function(returnCoords)
    if DoesEntityExist(testDriveVehicle) then DeleteEntity(testDriveVehicle) end
    SetEntityCoords(PlayerPedId(), returnCoords.x, returnCoords.y, returnCoords.z)
    lib.notify({ description = Locale['test_drive_ended'], type = 'success' })
    isTestDriving    = false
    testDriveVehicle = nil
end)

-- NUI callbacks
RegisterNUICallback('closeTablet', function(_, cb)
    SetNuiFocus(false, false)
    StopTabletAnimation()
    cb('ok')
end)

RegisterNUICallback('closeSelfPurchase', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('toggleSelfPurchase', function(data, cb)
    lib.callback('tommy-dealership:server:ToggleSelfPurchase', false, function(success, message)
        if success then
            lib.notify({ description = message, type = 'success' })
        else
            lib.notify({ description = message, type = 'error' })
        end
        cb(success)
    end, currentShop, data.vehicle, data.enabled)
end)

RegisterNUICallback('purchaseVehicleSelf', function(data, cb)
    lib.callback('tommy-dealership:server:PurchaseVehicleSelf', false, function(success, message)
        if success then
            lib.notify({ description = message, type = 'success' })
            SetNuiFocus(false, false)
        else
            lib.notify({ description = message, type = 'error' })
        end
        cb(success)
    end, currentShop, data)
end)

RegisterNUICallback('sellVehicle', function(data, cb)
    lib.callback('tommy-dealership:server:SellVehicle', false, function(success, message)
        if success then
            lib.notify({ description = message, type = 'success' })
            RefreshTabletData()
        else
            lib.notify({ description = message, type = 'error' })
        end
        cb(success)
    end, currentShop, data)
end)

RegisterNUICallback('restockVehicle', function(data, cb)
    lib.callback('tommy-dealership:server:RestockVehicle', false, function(success, message)
        if success then
            lib.notify({ description = message, type = 'success' })
            RefreshTabletData()
        else
            lib.notify({ description = message, type = 'error' })
        end
        cb(success)
    end, currentShop, data)
end)

RegisterNUICallback('importVehicle', function(data, cb)
    lib.callback('tommy-dealership:server:ImportVehicle', false, function(success, message)
        if success then
            lib.notify({ description = message, type = 'success' })
            RefreshTabletData()
        else
            lib.notify({ description = message, type = 'error' })
        end
        cb(success)
    end, currentShop, data)
end)

RegisterNUICallback('changeShowroomVehicle', function(data, cb)
    lib.callback('tommy-dealership:server:ChangeShowroomVehicle', false, function(success, message)
        if success then
            lib.notify({ description = message, type = 'success' })
            RefreshTabletData()
        else
            lib.notify({ description = message, type = 'error' })
        end
        cb(success)
    end, currentShop, data)
end)

RegisterNUICallback('clearShowroomSlot', function(data, cb)
    lib.callback('tommy-dealership:server:ClearShowroomSlot', false, function(success, message)
        if success then
            lib.notify({ description = message, type = 'success' })
            RefreshTabletData()
        else
            lib.notify({ description = message, type = 'error' })
        end
        cb(success)
    end, currentShop, data)
end)

RegisterNUICallback('changeShowroomColor', function(data, cb)
    lib.callback('tommy-dealership:server:ChangeShowroomColor', false, function(success, message)
        if success then
            lib.notify({ description = message, type = 'success' })
            RefreshTabletData()
        else
            lib.notify({ description = message, type = 'error' })
        end
        cb(success)
    end, currentShop, data)
end)

RegisterNUICallback('startTestDrive', function(data, cb)
    lib.callback('tommy-dealership:server:StartTestDrive', false, function(success, message)
        if success then
            lib.notify({ description = message, type = 'success' })
        else
            lib.notify({ description = message, type = 'error' })
        end
        cb(success)
    end, currentShop, data)
end)

RegisterNUICallback('getNearbyPlayers', function(_, cb)
    lib.callback('tommy-dealership:server:GetNearbyPlayers', false, function(players)
        cb(players or {})
    end)
end)

RegisterNUICallback('refreshData', function(_, cb)
    lib.callback('tommy-dealership:server:GetDealershipData', false, function(data)
        cb(data)
    end, currentShop)
end)

RegisterNUICallback('changeLanguage', function(data, cb)
    local lang = data.language
    if AvailableLocales[lang] then
        Locale = AvailableLocales[lang]
        cb(Locale)
    else
        cb(nil)
    end
end)

RegisterNUICallback('updateVehiclePrice', function(data, cb)
    lib.callback('tommy-dealership:server:UpdateVehiclePrice', false, function(success, message)
        if success then
            lib.notify({ description = message, type = 'success' })
            RefreshTabletData()
        else
            lib.notify({ description = message, type = 'error' })
        end
        cb(success)
    end, currentShop, data)
end)

RegisterNUICallback('updateVehicleDescription', function(data, cb)
    lib.callback('tommy-dealership:server:UpdateVehicleDescription', false, function(success, message)
        if success then
            lib.notify({ description = message, type = 'success' })
            RefreshTabletData()
        else
            lib.notify({ description = message, type = 'error' })
        end
        cb(success)
    end, currentShop, data)
end)

RegisterNUICallback('updateVehicleGCPrice', function(data, cb)
    lib.callback('tommy-dealership:server:UpdateVehicleGCPrice', false, function(success, message)
        if success then
            lib.notify({ description = message, type = 'success' })
            RefreshTabletData()
        else
            lib.notify({ description = message, type = 'error' })
        end
        cb(success)
    end, currentShop, data)
end)

-- Helpers
function RefreshTabletData()
    lib.callback('tommy-dealership:server:GetDealershipData', false, function(data)
        if not data then return end
        SendNUIMessage({ action = 'refreshData', data = data })
    end, currentShop)
end

-- Command
RegisterCommand('respawnshowroom', function()
    if not PlayerData.job or PlayerData.job.name ~= Config.DealerJob then return end
    local pCoords = GetEntityCoords(PlayerPedId())
    for shopName, shopData in pairs(Config.Shops) do
        if #(pCoords - shopData.Location) < 100.0 then
            DeleteShowroomVehiclesForShop(shopName)
            hasSpawnedVehicles[shopName] = false
            Wait(500)
            SpawnShowroomVehiclesForShop(shopName)
            lib.notify({ description = 'Showroom vehicles respawned for ' .. shopName, type = 'success' })
            break
        end
    end
end, false)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if isHoldingTablet then StopTabletAnimation() end
    if npcZone then npcZone:remove() end
    SetNuiFocus(false, false)
    for _, v in pairs(showroomVehicles) do
        if DoesEntityExist(v.entity) then DeleteEntity(v.entity) end
    end
    if DoesEntityExist(selfPurchaseNPC) then DeleteEntity(selfPurchaseNPC) end
end)

AddEventHandler('gameEventTriggered', function(name, args)
    if name ~= 'CEventNetworkEntityDamage' then return end
    local victim = args[1]
    local isDead = args[4]
    if victim == PlayerPedId() and isDead == 1 and isHoldingTablet then
        StopTabletAnimation()
        SetNuiFocus(false, false)
        SendNUIMessage({ action = 'closeUI' })
    end
end)