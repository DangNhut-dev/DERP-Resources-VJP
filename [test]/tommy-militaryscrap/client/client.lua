local lib = lib
local cache = cache

local spawnedCrates = {}
local activeCrate = nil
local insideZones = {}

local function spawnCrate(id, model, coords)
    if spawnedCrates[id] and DoesEntityExist(spawnedCrates[id]) then
        DeleteEntity(spawnedCrates[id])
        spawnedCrates[id] = nil
    end

    local hash = type(model) == 'string' and joaat(model) or model
    lib.requestModel(hash, 10000)

    local obj = CreateObjectNoOffset(hash, coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(obj, coords.w)
    FreezeEntityPosition(obj, true)
    SetEntityInvincible(obj, true)
    SetModelAsNoLongerNeeded(hash)

    spawnedCrates[id] = obj

    exports.ox_target:addLocalEntity(obj, {
        {
            name = 'militaryscrap:crate_' .. id,
            label = 'Cạy thùng quân dụng',
            icon = 'fa-solid fa-lock-open',
            distance = Config.CrateInteractDistance,
            onSelect = function()
                TriggerEvent('tommy-militaryscrap:client:tryLockpick', id)
            end
        }
    })
end

local function despawnCrate(id)
    local obj = spawnedCrates[id]
    if obj and DoesEntityExist(obj) then
        exports.ox_target:removeLocalEntity(obj)
        DeleteEntity(obj)
    end
    spawnedCrates[id] = nil
end

local function spawnAllCrates()
    for _, crate in ipairs(Config.Crates) do
        spawnCrate(crate.id, crate.model, crate.coords)
    end
end

local function clearAllCrates()
    for id, obj in pairs(spawnedCrates) do
        if DoesEntityExist(obj) then
            exports.ox_target:removeLocalEntity(obj)
            DeleteEntity(obj)
        end
        spawnedCrates[id] = nil
    end
end

local function createZoneBlip(zone)
    local blip = AddBlipForRadius(zone.coords.x, zone.coords.y, zone.coords.z, zone.radius)
    SetBlipColour(blip, zone.blip and zone.blip.color or 1)
    SetBlipAlpha(blip, zone.blip and zone.blip.alpha or 128)

    local marker = AddBlipForCoord(zone.coords.x, zone.coords.y, zone.coords.z)
    SetBlipSprite(marker, zone.blip and zone.blip.sprite or 568)
    SetBlipColour(marker, zone.blip and zone.blip.color or 1)
    SetBlipScale(marker, zone.blip and zone.blip.scale or 0.9)
    SetBlipAsShortRange(marker, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(zone.label)
    EndTextCommandSetBlipName(marker)
end

local function setupZones()
    for i, zone in ipairs(Config.RedZones) do
        createZoneBlip(zone)

        lib.zones.sphere({
            coords = zone.coords,
            radius = zone.radius,
            debug = false,
            onEnter = function()
                insideZones[i] = true
                lib.notify({
                    title = 'Khu vực nguy hiểm',
                    description = 'Bạn đang bước vào khu vực quân dụng.',
                    type = 'error',
                    position = 'top'
                })
            end,
            onExit = function()
                insideZones[i] = nil
            end
        })
    end
end

local function isInsideAnyZone()
    for _ in pairs(insideZones) do
        return true
    end
    return false
end

local function setupRefinery(coords)
    local hash = joaat('prop_tool_bench02')
    lib.requestModel(hash, 10000)
    local obj = CreateObjectNoOffset(hash, coords.x, coords.y, coords.z - 1.0, false, false, false)
    FreezeEntityPosition(obj, true)
    SetModelAsNoLongerNeeded(hash)

    exports.ox_target:addLocalEntity(obj, {
        {
            name = 'militaryscrap:refinery',
            label = 'Tinh chế linh kiện',
            icon = 'fa-solid fa-screwdriver-wrench',
            distance = Config.RefineryInteractDistance,
            onSelect = function()
                TriggerEvent('tommy-militaryscrap:client:openRefinery')
            end
        }
    })
end

local function setupRefineries()
    for _, coords in ipairs(Config.RefineryLocations) do
        setupRefinery(coords)
    end
end

RegisterNetEvent('tommy-militaryscrap:client:tryLockpick', function(crateId)
    if activeCrate then return end

    local crate = nil
    for _, c in ipairs(Config.Crates) do
        if c.id == crateId then crate = c break end
    end
    if not crate then return end

    local ped = cache.ped
    local pcoords = GetEntityCoords(ped)
    if #(pcoords - vector3(crate.coords.x, crate.coords.y, crate.coords.z)) > Config.CrateInteractDistance + 1.0 then
        return
    end

    if IsPedInAnyVehicle(ped, false) then
        lib.notify({ title = 'Lỗi', description = 'Không thể thực hiện trong xe', type = 'error' })
        return
    end

    activeCrate = crateId

    local canStart = lib.callback.await('tommy-militaryscrap:server:startLockpick', false, crateId)
    if not canStart then
        activeCrate = nil
        return
    end

    local minigameResult = exports['lockpick']:startLockpick()

    if not minigameResult then
        TriggerServerEvent('tommy-militaryscrap:server:lockpickFailed', crateId)
        activeCrate = nil
        lib.notify({ title = 'Thất bại', description = 'Cạy khóa không thành công', type = 'error' })
        return
    end

    TriggerServerEvent('tommy-militaryscrap:server:lockpickSuccess', crateId)

    RequestAnimDict('mini@repair')
    while not HasAnimDictLoaded('mini@repair') do Wait(10) end
    TaskPlayAnim(ped, 'mini@repair', 'fixing_a_ped', 8.0, -8.0, -1, 1, 0, false, false, false)

    local pbSuccess = lib.progressBar({
        duration = Config.LockpickDuration,
        label = 'Đang mở thùng quân dụng...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true
        }
    })

    ClearPedTasks(ped)
    activeCrate = nil

    if not pbSuccess then
        TriggerServerEvent('tommy-militaryscrap:server:cancelLockpick', crateId)
        return
    end

    TriggerServerEvent('tommy-militaryscrap:server:finishLockpick', crateId)
end)

RegisterNetEvent('tommy-militaryscrap:client:despawnCrate', function(crateId)
    despawnCrate(crateId)
end)

RegisterNetEvent('tommy-militaryscrap:client:respawnCrate', function(crateId)
    for _, c in ipairs(Config.Crates) do
        if c.id == crateId then
            spawnCrate(c.id, c.model, c.coords)
            return
        end
    end
end)

RegisterNetEvent('tommy-militaryscrap:client:openRefinery', function()
    local options = {}
    for i, recipe in ipairs(Config.RefineryRecipes) do
        local inputItem  = exports.ox_inventory:Items(recipe.input.item)
        local outputItem = exports.ox_inventory:Items(recipe.output.item)
        local inputLabel  = (inputItem  and inputItem.label)  or recipe.input.item
        local outputLabel = (outputItem and outputItem.label) or recipe.output.item

        options[#options + 1] = {
            title = recipe.label,
            description = ('Cần %dx %s -> %dx %s'):format(
                recipe.input.amount, inputLabel,
                recipe.output.amount, outputLabel
            ),
            icon = 'fa-solid fa-gears',
            onSelect = function()
                TriggerEvent('tommy-militaryscrap:client:refine', i)
            end
        }
    end

    lib.registerContext({
        id = 'militaryscrap_refinery',
        title = 'Bình Tinh Luyện',
        options = options
    })
    lib.showContext('militaryscrap_refinery')
end)

RegisterNetEvent('tommy-militaryscrap:client:refine', function(recipeIndex)
    local recipe = Config.RefineryRecipes[recipeIndex]
    if not recipe then return end

    local canStart = lib.callback.await('tommy-militaryscrap:server:canRefine', false, recipeIndex)
    if not canStart then return end

    local success = lib.progressBar({
        duration = recipe.duration,
        label = recipe.label,
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true
        },
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped'
        }
    })

    ClearPedTasks(cache.ped)

    if not success then return end

    TriggerServerEvent('tommy-militaryscrap:server:finishRefine', recipeIndex)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    clearAllCrates()
end)

CreateThread(function()
    Wait(500)
    setupZones()
    setupRefineries()
    spawnAllCrates()
end)