--[[
░▒▓████████▓▒░▒▓██████▓▒░       ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░  
   ░▒▓█▓▒░  ░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
   ░▒▓█▓▒░  ░▒▓█▓▒░             ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
   ░▒▓█▓▒░  ░▒▓█▓▒░             ░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░  
   ░▒▓█▓▒░  ░▒▓█▓▒░             ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
   ░▒▓█▓▒░  ░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
   ░▒▓█▓▒░   ░▒▓██████▓▒░       ░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░░▒▓███████▓▒░  
                                                                         
 This File Leaked By TC HUB Team, Join Our Server For More
 DISCORD: - https://discord.gg/k3S8RjkPWc - https://t.me/+RgDxwPX3L7w2ODBk - https://tchub.shop/
--]]


local porchLocations = {} 
local availableLocations = {} 
local activeLocations = {} 
local cooldownLocations = {} 
local lootTableWeights = {} 
local itemNameHashMap = {} 

local function getItemId(lootTableName, itemSubfix)
    return ("%s_%s_%s"):format(SvConfig.PorchPirate.packageItemPrefix, lootTableName, itemSubfix)
end

local function getActiveLocationsIds()
    local ids = {}

    for locationId, _ in pairs(activeLocations) do
        table.insert(ids, locationId)
    end

    return ids
end

local function getPotentialAvailableLocations()
    local allLocations = lib.table.deepclone(porchLocations)
    local activeLocationIds = getActiveLocationsIds()
    local locations = {}

    for i = 1, #allLocations do
        local location = allLocations[i]
        if cooldownLocations[location.id] then
            goto skip
        end

        if lib.table.contains(activeLocationIds, location.id) then
            goto skip
        end

        table.insert(locations, {
            id = location.id,
            coords = location.coords,
            lootTables = location.lootTables,
            heading = math.random(1, 360) + 0.0,
        })

        ::skip::
    end

    return locations
end

local function getWeightedLootTables(tableNames)
    local weightedTables = {}

    for _, name in pairs(tableNames) do
        if not lootTableWeights[name] then
            return false
        end

        table.insert(weightedTables, {
            name = name,
            weight = lootTableWeights[name],
        })
    end

    return weightedTables
end

local function generatePackage(skipClientEvent)
    if #availableLocations < 1 then
        availableLocations = getPotentialAvailableLocations()
    end

    if not availableLocations[1] then
        SetTimeout(1000 * 60 * 10, generatePackage)
        return
    end

    local randomKey = math.random(1, #availableLocations)
    local randomLocation = table.remove(availableLocations, randomKey)

    local weightedTables = getWeightedLootTables(randomLocation.lootTables)

    if not weightedTables then
        lib.print.debug("No porch pirate loot table found")
        return
    end

    local lootTable = GetRandomWeightedItem(weightedTables)
    local models = SvConfig.PorchPirate.lootTables[lootTable.name].models
    local randomModel = GetRandomWeightedItem(models)

    randomLocation.lootTables = nil
    randomLocation.tableType = lootTable.name
    randomLocation.itemId = getItemId(lootTable.name, randomModel.itemSubfix)
    randomLocation.modelHash = randomModel.hash
    activeLocations[randomLocation.id] = randomLocation

    CreateUnrepeatableAction(("pirate-%s"):format(randomLocation.id))

    if not skipClientEvent then
        TriggerClientEvent("prp-pettycrime:client:pirateAddLocation", -1, randomLocation)
    end
end

local function generatePackageLocations()
    local packageLimit = SvConfig.PorchPirate.packageLimit
    local packagesToGenerate = packageLimit - #activeLocations

    if packagesToGenerate < 1 then
        return
    end

    for i = 1, packagesToGenerate do
        generatePackage(true)
    end
end

local function registerPackageItem(itemName)
    bridge.fw.registerItemUse(itemName, function(src, item)
        if not item.metaData or not item.metaData.packageType then
            TriggerClientEvent("prp-bridge:notify", src, "error", locale("notifications.porch_pirate.no_contents"))
            return
        end

        local lootData = SvConfig.PorchPirate.lootTables[item.metaData.packageType]
        if not lootData then
            TriggerClientEvent("prp-bridge:notify", src, "error", locale("notifications.porch_pirate.wont_open"))
            return
        end

        if lootData.openingItem and next(lootData.openingItem) then
            local foundOpeningItem = false

            for i = 1, #lootData.openingItem do
                local itemFound = bridge.inv.hasItem(src, lootData.openingItem[i], 1)
                if itemFound then
                    foundOpeningItem = true
                    break
                end
            end

            if not foundOpeningItem then
                TriggerClientEvent("prp-bridge:notify", src, "error", lootData.openingItemMissingText)
                return
            end
        end

        bridge.inv.removeItem(src, item.name, 1, item.metaData, item.slot)

        local glitterBombPercentage = lootData.glitterBombPercentage or 0
        if glitterBombPercentage > math.random(1, 100) then
            local itemHash = itemNameHashMap[itemName]

            TriggerClientEvent("prp-bridge:notify", src, "error", locale("notifications.porch_pirate.glitterbomb"))
            CreateGlitterBomb(src, itemHash)

            local progressBarData = SvConfig.PorchPirate.glitterBomb.triggerProgressBar
            lib.callback.await("prp-bridge:progress", src, {
                duration = progressBarData.duration,
                label = progressBarData.text,
                controlDisables = progressBarData.disable,
                animation = {
                    animDict = progressBarData.anim.dict,
                    animClip = progressBarData.anim.clip,
                    animFlag = progressBarData.anim.flag
                }
            })

            return
        end

        GiveRewards(src, lootData.lootRolls, lootData.lootTable, lootData.guaranteedRarities)
    end)
end

function GetActiveLocations()
    return activeLocations
end

CreateThread(function()
    while GetResourceState("oxmysql") ~= "started" do
        Wait(50)
    end

    exports.oxmysql.awaitConnection()

    local locations =  {}
    local s, e = pcall(function()
        CreatePPTable()
        locations = GetPorchPirateLocations()

        if not SvConfig.PorchPirate.defaultLocations.insert then
            goto continue
        end

        if #locations > 0 then
            goto continue
        end

        for _, location in pairs(SvConfig.PorchPirate.defaultLocations.entries) do
            InsertPorchPirateLocation(location.coords.x, location.coords.y, location.coords.z, location.lootTables)
        end

        ::continue::
    end)

    if not s then
        print(e)
        return
    end

    for i = 1, #locations do
        local location = locations[i]
        table.insert(porchLocations, {
            id = location.id,
            coords = vector3(location.x, location.y, location.z),
            lootTables = json.decode(location.loot_tables),
        })
    end

    for tableName, lootTable in pairs(SvConfig.PorchPirate.lootTables) do
        lootTableWeights[tableName] = lootTable.weight

        for i = 1, #lootTable.models do
            local itemId = getItemId(tableName, lootTable.models[i].itemSubfix)
            itemNameHashMap[itemId] = lootTable.models[i].hash
            registerPackageItem(itemId)
        end
    end

    generatePackageLocations()
end)

AddEventHandler('prp-pettycrime:server:pirateLocationDeleted', function(locationId)
    for k, v in pairs(porchLocations) do
        if v.id == locationId then
            table.remove(porchLocations, k)
        end
    end

    for k, v in pairs(availableLocations) do
        if v.id == locationId then
            table.remove(availableLocations, k)
        end
    end

    if not activeLocations[locationId] then
        return
    end

    TriggerClientEvent('prp-pettycrime:client:pirateDeleteLocation', -1, locationId)
end)

RegisterNetEvent('prp-pettycrime:server:stealPackage', function(locationId)
    if not activeLocations[locationId] then
        return
    end

    local src = source
    local stateId = bridge.fw.getIdentifier(src)
    if not stateId then
        return
    end

    local ped = GetPlayerPed(src)

    if not DoesEntityExist(ped) then
        return
    end

    local activeLocation = activeLocations[locationId] 
    local playerCoords = GetEntityCoords(ped)

    if #(playerCoords - activeLocation.coords) > 3.0 then
        bridge.log.send(
            SvConfig.LogWebhook,
            locale("logs.porch_pirate.too_far.title"),
            locale("logs.porch_pirate.too_far.description"),
            {
                character_id = stateId,
                player_name = GetPlayerName(src),
                player_coords = FormatVec3(playerCoords),
                package_coords = FormatVec3(activeLocation.coords)
            }
        )

        return
    end

    local actionKey = ('pirate-%s'):format(activeLocation.id)
    if not IsUnrepeatableAction(actionKey) then
        return
    end

    local progressBarData = SvConfig.PorchPirate.progressBar
    local finished = lib.callback.await("prp-bridge:progress", src, {
        duration = progressBarData.duration,
        label = progressBarData.text,
        controlDisables = progressBarData.disable,
        canCancel = true,
        animation = {
            animDict = progressBarData.anim.dict,
            animClip = progressBarData.anim.clip,
            animFlag = progressBarData.anim.flag
        }
    })

    if not finished then
        return
    end

    PerformUnrepeatableAction(actionKey)
    activeLocations[locationId] = nil
    cooldownLocations[locationId] = true

    TriggerClientEvent('prp-pettycrime:client:pirateDeleteLocation', -1, locationId)
    HeatAction(src, "porch_pirate", activeLocation.coords)

    local itemId = activeLocation.itemId
    if not itemId then
        TriggerClientEvent("prp-bridge:notify", src, "error", locale("notifications.porch_pirate.vanished"))
        return
    end

    bridge.inv.giveItem(src, itemId, 1, {
        packageType = activeLocation.tableType
    })

    bridge.fw.setMetadata(src, {
        stress = {
            type = "add",
            value = 5
        }
    })

    if SvConfig.PorchPirate.rep.enabled then
        bridge.fw.addRep(src, SvConfig.PorchPirate.rep.type, SvConfig.PorchPirate.rep.amount, "pirate_porch")
    end

    SetTimeout(1000 * 60 * SvConfig.PorchPirate.packageRegenerationTime, generatePackage)
    SetTimeout(1000 * 60 * SvConfig.PorchPirate.packageLocationCooldownTime, function()
        cooldownLocations[locationId] = nil
    end)
end)

