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

local adminBlips = {}
local adminPoints = {}
local selectedLootTables = {}
local isAddingLocation = false
local disabledControls = { 177, 200, 202, 322 }

function StartDisableControlsLoop()
    CreateThread(function()
        while isAddingLocation do
            for _, control in ipairs(disabledControls) do
                DisableControlAction(0, control, true)
            end
            Wait(0)
        end
    end)
end

function CreateAdminBlip(coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipScale(blip, 0.3)
    SetBlipSprite(blip, 394)
    SetBlipColour(blip, 3)
    return blip
end

function DrawAdminText(coords, text)
    local onScreen, screenX, screenY = World3dToScreen2d(coords.x, coords.y, coords.z + 0.25)
    if not onScreen then return end

    SetTextScale(0.4, 0.4)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    DrawText(screenX, screenY)
end

function CreateAdminPoint(id, coords, lootTables)
    adminBlips[id] = CreateAdminBlip(coords)

    local point = lib.points.new({
        coords = coords,
        distance = 50.0,
        lootTables = lootTables,
        formattedLootTables = table.concat(lootTables, ", ")
    })

    point.onEnter = function(self)
        self.targetZone = bridge.target.addSphereZone({
            name = "pp_admin_point",
            coords = self.coords,
            radius = 0.25,
            debug = isAddingLocation,
            options = {
                {
                    name = "admin_porch_pirate_edit",
                    label = locale("target.porch_pirate.edit"),
                    icon = "fa-solid fa-pencil-alt",
                    onSelect = function()
                        TriggerServerEvent("prp-pettycrime:server:adminPirateEditLocation", id)
                    end,
                    canInteract = function(entity, distance)
                        return distance < 1.5
                    end
                },
                {
                    name = "admin_porch_pirate_delete",
                    label = locale("target.porch_pirate.delete"),
                    icon = "fa-solid fa-trash",
                    onSelect = function()
                        TriggerServerEvent("prp-pettycrime:server:adminPirateDeleteLocation", id)
                    end,
                    canInteract = function(entity, distance)
                        return distance < 1.5
                    end
                }
            }
        })
    end

    point.onExit = function(self)
        if self.targetZone then
            bridge.target.removeZone(self.targetZone)
            self.targetZone = nil
        end
    end

    point.nearby = function(self)
        if isAddingLocation then
            DrawAdminText(self.coords, self.formattedLootTables)
        end
    end

    adminPoints[id] = point
end

function RemoveAdminPoint(id)
    if adminBlips[id] then
        RemoveBlip(adminBlips[id])
        adminBlips[id] = nil
    end

    if adminPoints[id] then
        if adminPoints[id].targetZone then
            bridge.target.removeZone(adminPoints[id].targetZone)
        end
        adminPoints[id]:remove()
        adminPoints[id] = nil
    end
end

function RefreshAdminPoints()
    local currentPoints = {}
    for id, point in pairs(adminPoints) do
        currentPoints[id] = { coords = point.coords, lootTables = point.lootTables }
        RemoveAdminPoint(id)
    end

    for id, data in pairs(currentPoints) do
        CreateAdminPoint(id, data.coords, data.lootTables)
    end
end

function StartAddLocationSession()
    isAddingLocation = true

    local instructions = string.format("%s / %s %s",
        locale("text.porch_pirate.add"),
        locale("text.porch_pirate.loot_tables"),
        table.concat(selectedLootTables, ", ")
    )
    bridge.fw.showTextUI(instructions)

    StartDisableControlsLoop()

    while isAddingLocation do
        DisablePlayerFiring(cache.playerId, true)
        DisableControlAction(0, 25, true) 

        local hit, entity, hitCoords = lib.raycast.cam(17, 4, 50.0)

        if hit and hitCoords then
            local playerCoords = GetEntityCoords(cache.ped)
            DrawLine(playerCoords.x, playerCoords.y, playerCoords.z, hitCoords.x, hitCoords.y, hitCoords.z, 255, 42, 24, 255)
            DrawMarker(28, hitCoords.x, hitCoords.y, hitCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 255, 42, 24, 100, false, false, 2, true, false, false, false)

            if IsDisabledControlJustPressed(0, 38) then 
                TriggerServerEvent("prp-pettycrime:server:adminPirateAddLocation", hitCoords)
            end
        end

        if IsDisabledControlJustReleased(0, 177) then 
            isAddingLocation = false
        end
        Wait(0)
    end

    DisablePlayerFiring(cache.playerId, false)
    bridge.fw.hideTextUI()
    RefreshAdminPoints()
end

function OpenAdminPorchPirateMenu()
    local options = {
        {
            title = locale("menu.porch_pirate.current_locations_title"),
            description = locale("menu.porch_pirate.current_locations_desc"),
            icon = "location-dot",
            serverEvent = "prp-pettycrime:server:adminPirateActiveLocations"
        },
        {
            title = locale("menu.porch_pirate.edit_locations_title"),
            description = locale("menu.porch_pirate.edit_locations_desc"),
            icon = "pencil",
            disabled = isAddingLocation,
            serverEvent = "prp-pettycrime:server:adminPirateStartEditing"
        },
        {
            title = locale("menu.porch_pirate.finish_editing_title"),
            description = locale("menu.porch_pirate.finish_editing_desc"),
            icon = "floppy-disk",
            disabled = not isAddingLocation,
            serverEvent = "prp-pettycrime:server:adminPirateStopEditing"
        },
        {
            title = locale("menu.porch_pirate.loot_tables"),
            description = string.format("%s\n%s %s",
                locale("menu.porch_pirate.which_ones_will_apply"),
                locale("menu.porch_pirate.current"),
                table.concat(selectedLootTables, ", ")
            ),
            icon = "box-open",
            serverEvent = "prp-pettycrime:server:adminPirateSelectLootTables"
        }
    }

    bridge.fw.contextMenu({
        id = "pc-admin-pirate",
        title = locale("menu.porch_pirate.title"),
        menu = "pc-admin",
        options = options
    })

    bridge.fw.showContext("pc-admin-pirate")
end

RegisterNetEvent("prp-pettycrime:client:adminPirateAddLocation", function(id, coords, lootTables)
    RemoveAdminPoint(id)
    CreateAdminPoint(id, coords, lootTables)

    lib.notify({
        description = locale("notifications.porch_pirate.location_added"),
        type = "success"
    })
end)

RegisterNetEvent("prp-pettycrime:client:adminPirateUpdateLocation", function(id, coords, lootTables)
    RemoveAdminPoint(id)
    CreateAdminPoint(id, coords, lootTables)

    lib.notify({
        description = locale("notifications.porch_pirate.location_updated"),
        type = "info"
    })
end)

RegisterNetEvent("prp-pettycrime:client:adminPirateDeleteLocation", function(id)
    RemoveAdminPoint(id)

    lib.notify({
        description = locale("notifications.porch_pirate.location_deleted"),
        type = "error"
    })
end)

RegisterNetEvent("prp-pettycrime:client:adminPirateStartEditing", function(locations)
    for id, _ in pairs(adminPoints) do
        RemoveAdminPoint(id)
    end

    for _, loc in pairs(locations) do
        CreateAdminPoint(loc.id, vector3(loc.x, loc.y, loc.z), loc.loot_tables)
    end

    lib.notify({
        description = locale("notifications.porch_pirate.start_editing"),
        type = "info"
    })

    StartAddLocationSession()
end)

RegisterNetEvent("prp-pettycrime:client:adminPirateStopEditing", function()
    for id, _ in pairs(adminPoints) do
        RemoveAdminPoint(id)
    end

    isAddingLocation = false
    RefreshAdminPoints()

    lib.notify({
        description = locale("notifications.porch_pirate.finished_editing"),
        type = "info"
    })
end)

RegisterNetEvent("prp-pettycrime:client:adminPirateUpdateLootTables", function(lootTables)
    selectedLootTables = lootTables

    lib.notify({
        description = locale("notifications.porch_pirate.loot_tables_updated"),
        type = "info"
    })

    OpenAdminPorchPirateMenu()

    if isAddingLocation then
        bridge.fw.hideTextUI()
        bridge.fw.showTextUI(string.format("%s / %s %s",
            locale("text.porch_pirate.add"),
            locale("text.porch_pirate.loot_tables"),
            table.concat(selectedLootTables, ", ")
        ))
    end
end)

RegisterNetEvent("prp-pettycrime:client:adminPirateMenu", function()
    local lootTables = lib.callback.await("prp-pettycrime:server:adminPirateGetPlayerLootTables")
    if not lootTables then return end

    selectedLootTables = lootTables
    OpenAdminPorchPirateMenu()
end)

RegisterNetEvent("prp-pettycrime:client:adminPirateActiveLocations", function(locations)
    local options = {}

    for _, loc in pairs(locations) do
        local street1, street2 = GetStreetNameAtCoord(loc.coords.x, loc.coords.y, loc.coords.z)
        local streetName = string.format("%s) %s, %s",
            loc.id,
            GetStreetNameFromHashKey(street1),
            GetStreetNameFromHashKey(street2)
        )

        table.insert(options, {
            title = streetName,
            description = locale("menu.porch_pirate.select_teleport", loc.itemId or "N/A"),
            arrow = true,
            onSelect = function()
                SetEntityCoords(cache.ped, loc.coords.x, loc.coords.y, loc.coords.z + 1.0, false, false, false, false)
            end
        })
    end

    bridge.fw.contextMenu({
        id = "pc-admin-pirate-locations",
        title = locale("menu.porch_pirate.current_locations_title"),
        menu = "pc-admin-pirate",
        options = options
    })

    bridge.fw.showContext("pc-admin-pirate-locations")
end)

