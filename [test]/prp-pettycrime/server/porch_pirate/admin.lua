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

local playersEditing = {}
local playersLootTables = {}
local lootTablesOptions = {}

CreateThread(function()
    for lootTable, _ in pairs(SvConfig.PorchPirate.lootTables) do
        table.insert(lootTablesOptions, {value = lootTable})
    end
end)

bridge.fw.registerCommand(SvConfig.PorchPirate.adminMenu.command, locale("commands.porch_pirate.admin.help"), {}, SvConfig.PorchPirate.adminMenu.permission, function(source)
    TriggerClientEvent("prp-pettycrime:client:adminPirateMenu", source)
end)

lib.callback.register('prp-pettycrime:server:adminPirateGetPlayerLootTables', function(source)
    local src = source
    if not bridge.fw.isAdmin(src) then
        return
    end

    if not playersLootTables[src] then
        playersLootTables[src] = SvConfig.PorchPirate.defaultLootTables
    end

    return playersLootTables[src]
end)

RegisterNetEvent('prp-pettycrime:server:adminPirateStartEditing', function()
    local src = source

    if not bridge.fw.isAdmin(src) then
        return
    end

    playersEditing[src] = true

    local locations = GetPorchPirateLocations()

    for _, location in pairs(locations) do
        location.loot_tables = json.decode(location.loot_tables)
    end

    TriggerClientEvent('prp-pettycrime:client:adminPirateStartEditing', src, locations)
end)

RegisterNetEvent('prp-pettycrime:server:adminPirateStopEditing', function()
    local src = source

    if not bridge.fw.isAdmin(src) then
        return
    end

    playersEditing[src] = nil

    TriggerClientEvent('prp-pettycrime:client:adminPirateStopEditing', src)
end)

RegisterNetEvent('prp-pettycrime:server:adminPirateSelectLootTables', function()
    local src = source

    if not bridge.fw.isAdmin(src) then
        return
    end

    local input = lib.callback.await(
        "prp-pettycrime:client:inputDialog",
        src,
        locale("input.porch_pirate.loot_table_title"),
        {
            {
                type = 'multi-select',
                label = locale("input.porch_pirate.loot_table_title"),
                description = locale("input.porch_pirate.loot_tables"),
                icon = 'fas fa-box-open',
                required = true,
                options = lootTablesOptions,
                default = playersLootTables[src]
            },
        }
    )

    if not input or not input[1] then
        return
    end

    playersLootTables[src] = input[1]

    TriggerClientEvent('prp-pettycrime:client:adminPirateUpdateLootTables', src, playersLootTables[src])
end)

RegisterNetEvent('prp-pettycrime:server:adminPirateAddLocation', function(coords)
    local src = source

    if not bridge.fw.isAdmin(src) then
        return
    end

    local newId = InsertPorchPirateLocation(coords.x, coords.y, coords.z, playersLootTables[src])

    for pId, _ in pairs(playersEditing) do
        TriggerClientEvent('prp-pettycrime:client:adminPirateAddLocation', pId, newId, coords, playersLootTables[src])
    end
end)

RegisterNetEvent('prp-pettycrime:server:adminPirateEditLocation', function(locationId)
    local src = source

    if not bridge.fw.isAdmin(src) then
        return
    end

    local location = GetPorchPirateLocation(locationId)
    local locationCoords = vector3(location.x, location.y, location.z)
    local currentLootTables = json.decode(location.loot_tables)
    local input = lib.callback.await(
        "prp-pettycrime:client:inputDialog",
        src,
        locale("input.porch_pirate.loot_table_title"),
        {
            {
                type = 'multi-select',
                label = locale("input.porch_pirate.loot_table_title"),
                description = locale("input.porch_pirate.set_loot_table_locations"),
                icon = 'fas fa-box-open',
                required = true,
                options = lootTablesOptions,
                default = currentLootTables
            },
        }
    )

    if not input or not input[1] then
        return
    end

    UpdatePorchPirateLocationLootTables(location.id, input[1])

    for pId, _ in pairs(playersEditing) do
        TriggerClientEvent('prp-pettycrime:client:adminPirateUpdateLocation', pId, location.id, locationCoords, input[1])
    end
end)

RegisterNetEvent('prp-pettycrime:server:adminPirateDeleteLocation', function(locationId)
    local src = source

    if not bridge.fw.isAdmin(src) then
        return
    end

    DeletePorchPirateLocation(locationId)

    for pId, _ in pairs(playersEditing) do
        TriggerClientEvent('prp-pettycrime:client:adminPirateDeleteLocation', pId, locationId)
    end

    TriggerEvent('prp-pettycrime:server:pirateLocationDeleted', locationId)
end)

RegisterNetEvent('prp-pettycrime:server:adminPirateActiveLocations', function()
    local src = source

    if not bridge.fw.isAdmin(src) then
        return
    end

    TriggerClientEvent('prp-pettycrime:client:adminPirateActiveLocations', src, GetActiveLocations())
end)

