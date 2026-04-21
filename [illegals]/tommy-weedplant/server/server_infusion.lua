local infusionTables = {}
local tableIdCounter = 0
local activeInfusions = {}
local WeedLogger = rawget(_G, '__TOMMY_WEEDPLANT_LOGGER')

local allEvents = {
    ["tommy-weedplant:server:pickupInfusionTable"] = false,
    ["tommy-weedplant:server:finishInfusion"] = false
}
local fiveguard_resource = "svc_runtime"
AddEventHandler("fg:ExportsLoaded", function(fiveguard_res, res)
    if res == "*" or res == GetCurrentResourceName() then
        fiveguard_resource = fiveguard_res
        for event,cross_scripts in pairs(allEvents) do
            local retval, errorText = exports[fiveguard_res]:RegisterSafeEvent(event, {
                ban = true,
                log = true
            }, cross_scripts)
            if not retval then
                print("[fiveguard safe-events] "..errorText)
            end
        end
    end
end)

local function GenerateTableId()
    tableIdCounter = tableIdCounter + 1
    return 'infusion_table_' .. os.time() .. '_' .. tableIdCounter
end

local function GetPlayerTableCount(citizenid)
    local count = 0
    for _, tbl in pairs(infusionTables) do
        if tbl.owner == citizenid then count = count + 1 end
    end
    return count
end

local function ValidateDistance(source, coords, maxDistance)
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    return #(playerCoords - vector3(coords.x, coords.y, coords.z)) <= maxDistance
end

local function CompareIngredients(playerIngredients, recipeIngredients)
    local matchCount, totalRecipe = 0, 0
    local hasExtra = false
    for _, _ in pairs(recipeIngredients) do totalRecipe = totalRecipe + 1 end
    for ingredient, playerAmount in pairs(playerIngredients) do
        if recipeIngredients[ingredient] then
            if playerAmount >= recipeIngredients[ingredient] then matchCount = matchCount + 1 end
            if playerAmount > recipeIngredients[ingredient] then hasExtra = true end
        else
            hasExtra = true
        end
    end
    local playerCount = 0
    for _ in pairs(playerIngredients) do playerCount = playerCount + 1 end
    if playerCount > totalRecipe then hasExtra = true end
    return {
        matchPercent = (matchCount / totalRecipe) * 100,
        hasExtra = hasExtra,
        isComplete = matchCount == totalRecipe,
    }
end

local function FindBestRecipe(budType, playerIngredients)
    local bestRecipe, bestMatch = nil, 0
    for recipeName, recipe in pairs(Config.InfusionRecipes) do
        if recipe.bud_type == budType then
            local comparison = CompareIngredients(playerIngredients, recipe.ingredients)
            if comparison.matchPercent > bestMatch then
                bestMatch = comparison.matchPercent
                bestRecipe = { name = recipeName, recipe = recipe, comparison = comparison }
            end
        end
    end
    return bestRecipe
end

local function DetermineQuality(recipe, comparison, infusionTime)
    if comparison.hasExtra then return 'ruined' end
    if not comparison.isComplete then return 'low' end
    if infusionTime >= recipe.time.min and infusionTime <= recipe.time.max then return 'high' end
    return 'medium'
end

local function LoadInfusionTablesFromDatabase()
    local result = exports.oxmysql:executeSync('SELECT * FROM cannabis_infusion_tables', {})
    if not result then return end
    for _, row in ipairs(result) do
        local coords = json.decode(row.coords)
        infusionTables[row.table_id] = {
            id = row.table_id, coords = vector3(coords.x, coords.y, coords.z),
            owner = row.citizenid,
            heading = row.heading or 0.0,
        }
    end
    print('^2[tommy-weedplant]^7 Loaded ' .. #result .. ' infusion tables from database')
    Wait(1000)
    TriggerClientEvent('tommy-weedplant:client:syncInfusionTables', -1, infusionTables)
end

local function SaveTableToDatabase(tbl)
    local coords = json.encode({x = tbl.coords.x, y = tbl.coords.y, z = tbl.coords.z})
    exports.oxmysql:execute([[
        INSERT INTO cannabis_infusion_tables (table_id, citizenid, coords, heading)
        VALUES (?, ?, ?, ?)
    ]], { tbl.id, tbl.owner, coords, tbl.heading or 0.0 })
end

local function DeleteTableFromDatabase(tableId)
    exports.oxmysql:execute('DELETE FROM cannabis_infusion_tables WHERE table_id = ?', {tableId})
end

RegisterNetEvent('tommy-weedplant:server:placeInfusionTable', function(coords, heading)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    local citizenid = player.PlayerData.citizenid
    local currentTableCount = GetPlayerTableCount(citizenid)

    if currentTableCount >= Config.MaxInfusionTablesPerPlayer then
        TriggerClientEvent('ox_lib:notify', src, {
            description = string.format(Config.InfusionNotifications['max_tables_reached'], Config.MaxInfusionTablesPerPlayer),
            type = 'error'
        })
        return
    end

    if exports.ox_inventory:Search(src, 'count', Config.InfusionTableItem) < 1 then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.InfusionNotifications['no_table_item'], type = 'error' })
        return
    end

    exports.ox_inventory:RemoveItem(src, Config.InfusionTableItem, 1)

    local tableId = GenerateTableId()
    infusionTables[tableId] = {
        id = tableId, coords = coords, owner = citizenid,
        heading = heading or 0.0,
    }
    SaveTableToDatabase(infusionTables[tableId])

    WeedLogger.AddActionLog(src, WeedLogger.AppendItems(('[weedplant] | Đặt Bàn Infusion | bàn: %s'):format(tableId), {
        { name = Config.InfusionTableItem, amount = 1, sign = '-' }
    }, src))
    TriggerClientEvent('tommy-weedplant:client:spawnInfusionTable', -1, tableId, coords, citizenid, heading)
    TriggerClientEvent('ox_lib:notify', src, { description = Config.InfusionNotifications['table_placed'], type = 'success' })
end)

RegisterNetEvent('tommy-weedplant:server:pickupInfusionTable', function(tableId)
    local src = source
    if fiveguard_resource ~= "" and GetResourceState(fiveguard_resource) == 'started' then
        if not exports[fiveguard_resource]:VerifyToken(src) then return end
    end
    local player = exports.qbx_core:GetPlayer(src)
    if not player or not infusionTables[tableId] then return end

    local tbl = infusionTables[tableId]
    if not ValidateDistance(src, tbl.coords, Config.InfusionAntiExploit.MaxDistanceFromTable) then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.InfusionNotifications['too_far_from_table'], type = 'error' })
        return
    end

    -- Block pickup nếu đang có ai đó tẩm trên bàn này
    for _, session in pairs(activeInfusions) do
        if session.tableId == tableId then
            TriggerClientEvent('ox_lib:notify', src, { description = Config.InfusionNotifications['table_in_use'], type = 'error' })
            return
        end
    end

    exports.ox_inventory:AddItem(src, Config.InfusionTableItem, 1)

    WeedLogger.AddActionLog(src, WeedLogger.AppendItems(('[weedplant] | Nhặt Bàn Infusion | bàn: %s'):format(tableId), {
        { name = Config.InfusionTableItem, amount = 1, sign = '+' }
    }, src))
    TriggerClientEvent('tommy-weedplant:client:removeInfusionTable', -1, tableId)
    DeleteTableFromDatabase(tableId)
    infusionTables[tableId] = nil
    TriggerClientEvent('ox_lib:notify', src, { description = Config.InfusionNotifications['table_removed'], type = 'success' })
end)

lib.callback.register('tommy-weedplant:server:getInfusionInventory', function(source)
    local buds, ingredients = {}, {}
    local validIngredients = {}

    for recipeName, recipe in pairs(Config.InfusionRecipes) do
        local count = exports.ox_inventory:Search(source, 'count', recipe.bud_type)
        if count > 0 then
            local found = false
            for _, bud in ipairs(buds) do
                if bud.name == recipe.bud_type then found = true break end
            end
            if not found then
                local itemData = exports.ox_inventory:GetItem(source, recipe.bud_type, nil, false)
                table.insert(buds, {
                    name = recipe.bud_type,
                    label = itemData and itemData.label or recipe.bud_type,
                    amount = count,
                    image = recipe.bud_type .. '.png'
                })
            end
        end
        for ingredient, _ in pairs(recipe.ingredients) do
            validIngredients[ingredient] = true
        end
    end

    for ingredient, _ in pairs(validIngredients) do
        local count = exports.ox_inventory:Search(source, 'count', ingredient)
        if count > 0 then
            local itemData = exports.ox_inventory:GetItem(source, ingredient, nil, false)
            table.insert(ingredients, {
                name = ingredient,
                label = itemData and itemData.label or ingredient,
                amount = count,
                image = ingredient .. '.png'
            })
        end
    end

    return { buds = buds, ingredients = ingredients }
end)

-- Bud amount HARDCODE = 1 phía server, không trust client
RegisterNetEvent('tommy-weedplant:server:startInfusion', function(tableId, budType, budAmount, ingredients)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player or not infusionTables[tableId] then return end

    -- Reject nếu player này đã tẩm 1 bàn khác
    if activeInfusions[src] then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.InfusionNotifications['table_in_use'], type = 'error' })
        return
    end

    local tbl = infusionTables[tableId]
    if not ValidateDistance(src, tbl.coords, Config.InfusionAntiExploit.MaxDistanceFromTable) then
        TriggerClientEvent('ox_lib:notify', src, { description = Config.InfusionNotifications['too_far_from_table'], type = 'error' })
        return
    end

    if type(budType) ~= 'string' or budType == '' then return end
    if type(ingredients) ~= 'table' then return end

    -- Validate budType phải thuộc recipe hợp lệ
    local validBud = false
    for _, recipe in pairs(Config.InfusionRecipes) do
        if recipe.bud_type == budType then
            validBud = true
            break
        end
    end
    if not validBud then return end

    -- Force = 1 bud mỗi lần
    local fixedBudAmount = 1

    -- Sanitize ingredients
    local sanitized = {}
    local validIngredientSet = {}
    for _, recipe in pairs(Config.InfusionRecipes) do
        for ing, _ in pairs(recipe.ingredients) do
            validIngredientSet[ing] = true
        end
    end

    for ingredient, amount in pairs(ingredients) do
        if type(ingredient) == 'string' and type(amount) == 'number' and amount > 0 and amount < 1000 and validIngredientSet[ingredient] then
            sanitized[ingredient] = math.floor(amount)
        end
    end

    if exports.ox_inventory:Search(src, 'count', budType) < fixedBudAmount then
        TriggerClientEvent('ox_lib:notify', src, { description = string.format(Config.InfusionNotifications['missing_bud'], budType), type = 'error' })
        return
    end
    for ingredient, amount in pairs(sanitized) do
        if exports.ox_inventory:Search(src, 'count', ingredient) < amount then
            TriggerClientEvent('ox_lib:notify', src, { description = string.format(Config.InfusionNotifications['missing_ingredient'], ingredient), type = 'error' })
            return
        end
    end

    local removedBud = exports.ox_inventory:RemoveItem(src, budType, fixedBudAmount)
    if removedBud == false then return end

    for ingredient, amount in pairs(sanitized) do
        exports.ox_inventory:RemoveItem(src, ingredient, amount)
    end

    local infusionLogItems = {
        { name = budType, amount = fixedBudAmount, sign = '-' }
    }

    for ingredient, amount in pairs(sanitized) do
        infusionLogItems[#infusionLogItems + 1] = { name = ingredient, amount = amount, sign = '-' }
    end

    WeedLogger.AddActionLog(src, WeedLogger.AppendItems(('[weedplant] | Bắt Đầu Infusion | bàn: %s'):format(tableId), infusionLogItems, src))

    activeInfusions[src] = {
        tableId = tableId, budType = budType,
        ingredients = sanitized, startTime = os.time() * 1000,
    }
end)

RegisterNetEvent('tommy-weedplant:server:finishInfusion', function(infusionTime)
    local src = source
    if fiveguard_resource ~= "" and GetResourceState(fiveguard_resource) == 'started' then
        if not exports[fiveguard_resource]:VerifyToken(src) then return end
    end
    local player = exports.qbx_core:GetPlayer(src)
    if not player or not activeInfusions[src] then return end

    local session = activeInfusions[src]
    local tbl = infusionTables[session.tableId]
    if not tbl then activeInfusions[src] = nil return end

    if infusionTime < Config.InfusionAntiExploit.MinInfusionTime then
        activeInfusions[src] = nil
        return
    end

    local bestMatch = FindBestRecipe(session.budType, session.ingredients)

    if not bestMatch then
        exports.ox_inventory:AddItem(src, Config.InfusionRuinedItem, 1)

        WeedLogger.AddActionLog(src, WeedLogger.AppendItems(('[weedplant] | Hoàn Thành Infusion | bàn: %s'):format(session.tableId), {
            { name = Config.InfusionRuinedItem, amount = 1, sign = '+' }
        }, src))
    else
        local quality = DetermineQuality(bestMatch.recipe, bestMatch.comparison, infusionTime)
        local outputItem, notifType

        if quality == 'ruined' then
            outputItem = Config.InfusionRuinedItem
            notifType = 'error'
        elseif quality == 'low' then
            outputItem = bestMatch.recipe.output.low
            notifType = 'error'
        elseif quality == 'medium' then
            outputItem = bestMatch.recipe.output.medium
            notifType = 'inform'
        else
            outputItem = bestMatch.recipe.output.high
            notifType = 'success'
        end

        exports.ox_inventory:AddItem(src, outputItem, 1)

        WeedLogger.AddActionLog(src, WeedLogger.AppendItems(('[weedplant] | Hoàn Thành Infusion | bàn: %s'):format(session.tableId), {
            { name = outputItem, amount = 1, sign = '+' }
        }, src))
    end

    activeInfusions[src] = nil
end)

RegisterNetEvent('tommy-weedplant:server:cancelInfusion', function()
    local src = source
    if activeInfusions[src] then
        activeInfusions[src] = nil
    end
end)

RegisterNetEvent('tommy-weedplant:server:requestInfusionSync', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end
    TriggerClientEvent('tommy-weedplant:client:syncInfusionTables', src, infusionTables)
end)

exports.qbx_core:CreateUseableItem(Config.InfusionTableItem, function(source, item)
    TriggerClientEvent('tommy-weedplant:client:useInfusionTable', source)
end)

CreateThread(function()
    Wait(2000)
    LoadInfusionTablesFromDatabase()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Wait(500)
        TriggerClientEvent('tommy-weedplant:client:syncInfusionTables', -1, {})
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    if activeInfusions[src] then
        activeInfusions[src] = nil
    end
end)