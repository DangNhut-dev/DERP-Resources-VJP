local DEBUG = Config.DEBUG

AnimalLootMultiplier = {}

function AnimalLootMultiplier:new(ped, options)
    if not ped then return end
    if not self[ped] then self[ped] = {} end
    if not self[ped]['bones'] then self[ped]['bones'] = {} end
    if options.bone ~= nil then table.insert(self[ped]['bones'], options.bone) end
    if options.weapon ~= nil then self[ped]['weapon'] = options.weapon end
end

function AnimalLootMultiplier:read(ped)
    return self[ped] or false
end

function createCustomBlips(data)
    for _, v in pairs(data) do
        local Blip
        if v.BlipsCoords ~= nil and v.showBlip then
            Blip = AddBlipForCoord(v.BlipsCoords.x, v.BlipsCoords.y, v.BlipsCoords.z)
        elseif v.BlipsCoords == nil and v.showBlip then
            Blip = AddBlipForCoord(v.coord.x, v.coord.y, v.coord.z)
        end

        if not Blip then return end

        SetBlipAsShortRange(Blip, true)

        if v.radius then
            if v.showBlip then
                SetBlipSprite(Blip, 141)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(v.name)
                EndTextCommandSetBlipName(Blip)

                local RadiusBlip = AddBlipForRadius(v.coord.x, v.coord.y, v.coord.z, v.radius)
                AddCircleZone(v.name, v.llegal, v.coord, v.radius, {
                    name = "circle_zone",
                    debugPoly = DEBUG
                })
                SetBlipRotation(RadiusBlip, 0)
                SetBlipColour(RadiusBlip, v.llegal == false and 1 or 4)
                SetBlipAlpha(RadiusBlip, 64)
            end
        else
            SetBlipSprite(Blip, 442)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.name)
            EndTextCommandSetBlipName(Blip)
        end

        SetBlipDisplay(Blip, 4)
        SetBlipScale(Blip, 0.6)
        SetBlipColour(Blip, 49)
    end
end

-- ============================
--   OX_TARGET
-- ============================

-- function initSellspotsQbTargets(sellspot)
--     for _, v in pairs(sellspot) do
--         local spotData = v
--         local npcCfg   = v.SellerNpc

--         Citizen.CreateThread(function()
--             local model = GetHashKey(npcCfg.model)
--             RequestModel(model)
--             while not HasModelLoaded(model) do Citizen.Wait(10) end

--             local npc = CreatePed(4, model, npcCfg.coords.x, npcCfg.coords.y, npcCfg.coords.z - 1.0, npcCfg.coords.w, false, true)
--             while not DoesEntityExist(npc) do Citizen.Wait(10) end

--             SetEntityAsMissionEntity(npc, true, true)
--             SetBlockingOfNonTemporaryEvents(npc, true)
--             SetPedDiesWhenInjured(npc, false)
--             SetEntityInvincible(npc, true)
--             FreezeEntityPosition(npc, true)
--             SetPedCanRagdoll(npc, false)
--             SetModelAsNoLongerNeeded(model)

--             Citizen.Wait(100)

--             exports['ox_target']:addLocalEntity(npc, {
--                 {
--                     label    = spotData.targetLabel or 'Bán thú săn',
--                     icon     = spotData.targetIcon  or 'fas fa-dollar-sign',
--                     distance = spotData.targetDist  or 2.5,
--                     onSelect = function()
--                         openSellMenu(spotData)
--                     end,
--                 }
--             })
--         end)
--     end
-- end

function openSellMenu(spotData)
    local options = {}

    -- Auto generate từ Config.HideSystem.grades (chỉ bán da)
    if Config.HideSystem and Config.HideSystem.enabled then
        for _, grade in ipairs(Config.HideSystem.grades) do
            local g = grade
            table.insert(options, {
                title       = g.label .. '  —  $' .. g.sellPrice .. ' / unit',
                description = 'Da ' .. g.star .. ' sao | Ti le: ' .. g.chance .. '%',
                icon        = 'fas fa-sack-dollar',
                onSelect    = function()
                    TriggerServerEvent('DERP-hunting:server:sellHide', g.item, g.sellPrice)
                end,
            })
        end
    end

    lib.registerContext({
        id      = 'hunting_sell_menu',
        title   = 'Ban da thu san',
        options = options,
    })
    lib.showContext('hunting_sell_menu')
end

function putQbTargetAllOnAnimals()
    for _, v in pairs(Config.Animals) do
        exports['ox_target']:addModel(v.model, {
            {
                icon     = 'fa-brands fa-mandalorian',
                label    = 'Lột da',
                distance = 1.5,
                canInteract = function(entity)
                    if IsPedAPlayer(entity) then return false end
                    return IsEntityDead(entity) == 1 or IsEntityDead(entity) == true
                end,
                onSelect = function(data)
                    TriggerEvent('DERP-hunting:client:slaughterAnimal', data.entity)
                end,
            }
        })
    end
end

function putQbTargetOnEntity(ped)
    exports['ox_target']:addEntity(ped, {
        {
            icon     = 'fa-brands fa-mandalorian',
            label    = 'Lột da',
            distance = 1.5,
            canInteract = function(entity)
                return IsEntityDead(entity) == 1 or IsEntityDead(entity) == true
            end,
            onSelect = function(data)
                if not (IsEntityDead(data.entity) == 1 or IsEntityDead(data.entity) == true) then return end
                TriggerEvent('DERP-hunting:client:slaughterAnimal', data.entity)
            end,
        }
    })
end

-- ============================
--   SPAWN LOCATION (chỉ trong zone)
-- ============================

-- Lấy zone mặc định đầu tiên trong config
local function getDefaultZone()
    return Config.HuntingArea and Config.HuntingArea[1] or nil
end

-- Spawn xung quanh trung tâm zone
-- zone param: override zone (từ mission), fallback về Config.HuntingArea[1]
function getSpawnLocationInZone(baitCoord, zone)
    local activeZone = zone or getDefaultZone()
    local origin     = activeZone and activeZone.coord or baitCoord
    local zoneRadius = activeZone and activeZone.radius or 500.0

    local spawnMax = zoneRadius * 0.75
    local spawnMin = math.max(zoneRadius * 0.05, 20.0)

    local finished = false
    local index    = 0
    local posX, posY, posZ, heading

    while not finished and index <= 100 do
        local angle = math.rad(math.random(0, 359))
        local dist  = math.random(math.floor(spawnMin), math.floor(spawnMax))
        posX    = origin.x + (dist * math.cos(angle))
        posY    = origin.y + (dist * math.sin(angle))
        heading = math.random(0, 359) + .0

        local found, groundZ = GetGroundZFor_3dCoord(posX, posY, origin.z + 100.0, false)
        posZ = found and groundZ or origin.z

        local safe, _ = GetSafeCoordForPed(posX, posY, posZ, false, 16)
        finished = safe

        index = index + 1
        Citizen.Wait(0)
    end

    if not finished then
        posX    = origin.x + math.random(50, 150)
        posY    = origin.y + math.random(50, 150)
        posZ    = origin.z
        heading = math.random(0, 359) + .0
    end

    return vector4(posX, posY, posZ, heading)
end

function getSpawnLocation(coord)
    return getSpawnLocationInZone(coord, nil)
end

-- ============================
--   MISC FUNCTIONS
-- ============================

function getAnimalMatch(hash)
    for _, v in pairs(Config.Animals) do
        if v.hash == hash then return v end
    end
    return false
end

function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(0)
    end
end

function createThreadAnimalTraveledDistanceToBaitTracker(baitCoord, entity)
    Citizen.CreateThread(function()
        local playerPed = PlayerPedId()
        local finished  = false
        local FleeView  = Config.AnimalsFleeView

        TaskGoToCoordAnyMeans(entity, baitCoord, 2.0, 0, 786603, 0xbf800000)

        while not IsPedDeadOrDying(entity) and not finished do
            local playerCoord = GetEntityCoords(playerPed)
            local entityCoord = GetEntityCoords(entity)

            if #(baitCoord - entityCoord) < 1 then
                ClearPedTasks(entity)
                Citizen.Wait(1500)
                TaskStartScenarioInPlace(entity, "WORLD_DEER_GRAZING", 0, true)
                Citizen.SetTimeout(Config.AnimalsEatingSpeed, function()
                    finished = true
                end)
            end

            if #(entityCoord - playerCoord) < FleeView then
                finished = true
            end

            animalAntiStuck(entity, baitCoord)
            Citizen.Wait(1000)
        end

        if not IsPedDeadOrDying(entity) then
            TaskSmartFleePed(entity, playerPed, 600.0, -1)
        end
    end)
end

function animalAntiStuck(entity, baitCoord)
    local coord       = GetEntityCoords(PlayerPedId())
    local animalCoord = GetEntityCoords(entity)
    local distance    = #(baitCoord - animalCoord)

    if IsPedStill(entity) and distance >= 25.0 then
        local tmpcord = getSpawnLocationInZone(coord)
        SetEntityCoordsNoOffset(entity, tmpcord.x, tmpcord.y, tmpcord.z, 1)
        TaskGoToCoordAnyMeans(entity, baitCoord, 2.0, 0, 786603, 0xbf800000)
    end
end

-- Các hash vũ khí xe/collision không phải súng hợp lệ
-- GetPedCauseOfDeath trả về 0 khi bị xe cán (hoặc hash không phải súng)
local VALID_WEAPON_HASHES = nil  -- lazy init
local function isValidHuntingWeapon(weaponHash)
    -- weaponHash = 0 nghĩa là bị xe/collision/tay không
    if weaponHash == 0 then return false end
    -- Danh sách vũ khí hợp lệ từ config
    if not VALID_WEAPON_HASHES then
        VALID_WEAPON_HASHES = {}
        for k, _ in pairs(Config.weaponQualityMultiplier) do
            if k ~= 'default' then
                VALID_WEAPON_HASHES[GetHashKey(k)] = true
            end
        end
    end
    -- Nếu không có trong danh sách config thì kiểm tra có phải weapon hash hợp lệ không
    -- GetWeaponCategory: nếu trả về 0 nghĩa là không phải vũ khí hợp lệ
    if next(VALID_WEAPON_HASHES) then
        return VALID_WEAPON_HASHES[weaponHash] ~= nil
    end
    return true
end

-- Lấy zone đang active (mission hoặc default hunting area)
local function getActiveZoneForAnimal()
    if currentMission and currentMission.zone then
        return currentMission.zone
    end
    return Config.HuntingArea and Config.HuntingArea[1] or nil
end

-- Check xem entity có trong zone không
local function isEntityInZone(entity, zone)
    if not zone then return true end -- không có zone = không giới hạn
    local coord = GetEntityCoords(entity)
    local dist  = #(vector3(coord.x, coord.y, coord.z) - vector3(zone.coord.x, zone.coord.y, zone.coord.z))
    return dist <= zone.radius
end

-- killedByVehicle[entity] = true nếu thú bị xe cán chết
killedByVehicle = killedByVehicle or {}

function createDespawnThread(baitAnimal, was_llegal, baitcoord)
    local animalCoordAtSpawn = GetEntityCoords(baitAnimal)
    local outOfZoneTimer     = 0   -- bộ đếm ms khi ra ngoài zone
    local OUT_OF_ZONE_LIMIT  = 15000  -- 15 giây

    -- Thread 1: quản lý despawn + zone boundary
    Citizen.CreateThread(function()
        local finished = false
        local range    = Config.animalDespawnRange

        while not finished do
            if not DoesEntityExist(baitAnimal) then break end

            local coord       = GetEntityCoords(PlayerPedId())
            local animalCoord = GetEntityCoords(baitAnimal)
            local isDead      = IsEntityDead(baitAnimal)
            local distance    = #(coord - animalCoord)

            if isDead then
                local chance = callPoliceChance()
                if was_llegal == false and chance == 1 then
                    Config.llegalHuntingNotification(animalCoord)
                end
                finished = true

            elseif distance >= range then
                -- Ra quá xa player → despawn
                SetModelAsNoLongerNeeded(baitAnimal)
                SetPedAsNoLongerNeeded(baitAnimal)
                finished = true

            else
                -- Kiểm tra zone boundary
                local activeZone = getActiveZoneForAnimal()
                if activeZone and not isEntityInZone(baitAnimal, activeZone) then
                    outOfZoneTimer = outOfZoneTimer + 1000
                    if outOfZoneTimer >= OUT_OF_ZONE_LIMIT then
                        -- Thú ra ngoài zone quá 15 giây → despawn + respawn
                        print('[hunting] Animal out of zone > 15s, despawning and respawning')
                        local spawnCoord = animalCoordAtSpawn  -- vị trí spawn ban đầu
                        DeleteEntity(baitAnimal)
                        AnimalLootMultiplier[baitAnimal] = nil
                        -- Yêu cầu server spawn lại
                        TriggerServerEvent(
                            'DERP-hunting:server:choiceWhichAnimalToSpawn',
                            spawnCoord,
                            vector4(spawnCoord.x, spawnCoord.y, spawnCoord.z, math.random(0,359)+.0),
                            was_llegal,
                            currentMission and currentMission.animals or {}
                        )
                        finished = true
                    end
                else
                    outOfZoneTimer = 0  -- reset nếu quay lại zone
                end
            end

            Wait(1000)
        end
    end)

    -- Thread 2: theo dõi damage để record multiplier + check vũ khí hợp lệ
    Citizen.CreateThread(function()
        local tmpHealth = GetPedMaxHealth(baitAnimal)
        killedByVehicle[baitAnimal] = false

        while not IsPedDeadOrDying(baitAnimal) do
            if not DoesEntityExist(baitAnimal) then return end
            local currentHealth = GetEntityHealth(baitAnimal)
            if currentHealth ~= tmpHealth then
                local _, outBone = GetPedLastDamageBone(baitAnimal)
                AnimalLootMultiplier:new(baitAnimal, { bone = outBone })
                tmpHealth = currentHealth
            end
            Wait(50)
        end

        if not DoesEntityExist(baitAnimal) then return end

        Wait(100)
        local _, outBone    = GetPedLastDamageBone(baitAnimal)
        local weaponHash    = GetPedCauseOfDeath(baitAnimal)
        local WeaponQuality = getWeaponQualityMultiplier(weaponHash)
        AnimalLootMultiplier:new(baitAnimal, { bone = outBone, weapon = WeaponQuality })

        -- Đánh dấu nếu bị xe cán (weaponHash = 0 hoặc không hợp lệ)
        if not isValidHuntingWeapon(weaponHash) then
            killedByVehicle[baitAnimal] = true
            print('[hunting] Animal killed by vehicle/invalid weapon: ' .. tostring(weaponHash))
        end
    end)
end

function getWeaponQualityMultiplier(weaponHash)
    for key, value in pairs(Config.weaponQualityMultiplier) do
        if GetHashKey(key) == weaponHash then return value end
    end
    return Config.weaponQualityMultiplier.default
end

function callPoliceChance()
    return Alias_table_wrapper(Config.callPoliceChance)
end

function makeEntityFaceEntity(entity1, entity2)
    local p1 = GetEntityCoords(entity1, true)
    local p2 = GetEntityCoords(entity2, true)
    SetEntityHeading(entity1, GetHeadingFromVector_2d(p2.x - p1.x, p2.y - p1.y))
end

function ToggleSlaughterAnimation(toggle, animalEnity)
    local ped = PlayerPedId()
    Wait(250)
    if toggle then
        makeEntityFaceEntity(ped, animalEnity)
        loadAnimDict('amb@medic@standing@kneel@base')
        loadAnimDict('anim@gangops@facility@servers@bodysearch@')
        TaskPlayAnim(ped, "amb@medic@standing@kneel@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
        TaskPlayAnim(ped, "anim@gangops@facility@servers@bodysearch@", "player_search", 8.0, -8.0, -1, 1, 0, false, false, false)
    else
        SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
        ClearPedTasks(ped)
    end
end