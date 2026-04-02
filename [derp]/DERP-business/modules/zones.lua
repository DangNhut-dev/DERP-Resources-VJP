-- modules/zones.lua
local playerJob = nil
local blips     = {}
local zoneIds   = {}

local function getPlayerData()
    return exports.qbx_core:GetPlayerData()
end

local function buildRecipeString(recipe)
    local parts = {}
    for item, count in pairs(recipe) do
        parts[#parts + 1] = count .. 'x ' .. item
    end
    return table.concat(parts, ', ')
end

local function askQuantity(callback)
    local input = lib.inputDialog('Số Lượng Chế Biến', {
        { type = 'number', label = 'Số lượng', default = 1, min = 1, max = 99, required = true }
    })
    if not input or not input[1] then return end
    local qty = math.floor(tonumber(input[1]) or 0)
    if qty < 1 then return end
    callback(qty)
end

local function openCraftMenu(businessKey, craftIndex, craftZone)
    local options = {}
    for itemKey, itemData in pairs(craftZone.items) do
        options[#options + 1] = {
            title       = itemData.label,
            description = 'Nguyên liệu: ' .. buildRecipeString(itemData.recipe),
            icon        = itemData.type == 'food' and 'fa-solid fa-burger' or 'fa-solid fa-mug-hot',
            onSelect    = function()
                askQuantity(function(qty)
                    TriggerServerEvent('DERP-business:craft', businessKey, craftIndex, itemKey, qty)
                end)
            end
        }
    end

    lib.registerContext({
        id      = 'craft_menu_' .. businessKey .. '_' .. craftIndex,
        title   = craftZone.label .. ' - Chế Biến',
        options = options
    })
    lib.showContext('craft_menu_' .. businessKey .. '_' .. craftIndex)
end

local function cleanBusiness(businessKey)
    if blips[businessKey] and DoesBlipExist(blips[businessKey]) then
        RemoveBlip(blips[businessKey])
        blips[businessKey] = nil
    end

    if zoneIds[businessKey] then
        local ids = zoneIds[businessKey]
        if ids.duty and ids.duty ~= 0 then
            pcall(function() exports.ox_target:removeZone(ids.duty) end)
            ids.duty = nil
        end
        if ids.crafts then
            for k, id in ipairs(ids.crafts) do
                if id and id ~= 0 then
                    pcall(function() exports.ox_target:removeZone(id) end)
                    ids.crafts[k] = nil
                end
            end
        end
        zoneIds[businessKey] = nil
    end
end

local function setupBusiness(businessKey, config)
    cleanBusiness(businessKey)

    if config.blip and config.blip.enable then
        local blip = AddBlipForCoord(config.blip.coords.x, config.blip.coords.y, config.blip.coords.z)
        SetBlipSprite(blip, config.blip.sprite)
        SetBlipColour(blip, config.blip.color)
        SetBlipScale(blip, config.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(config.blip.label)
        EndTextCommandSetBlipName(blip)
        blips[businessKey] = blip
    end

    local ids = { crafts = {} }

    local dutyId = exports.ox_target:addSphereZone({
        coords  = config.duty.coords,
        radius  = config.duty.radius or 1.5,
        options = {
            {
                name        = 'duty_on_' .. businessKey,
                label       = 'Vào Ca Làm Việc',
                icon        = 'fas fa-play',
                canInteract = function()
                    local data = getPlayerData()
                    return data and data.job and data.job.name == config.job and not data.job.onduty
                end,
                onSelect    = function()
                    TriggerServerEvent('DERP-business:toggleDuty', businessKey)
                end
            },
            {
                name        = 'duty_off_' .. businessKey,
                label       = 'Kết Thúc Ca Làm',
                icon        = 'fas fa-stop',
                canInteract = function()
                    local data = getPlayerData()
                    return data and data.job and data.job.name == config.job and data.job.onduty == true
                end,
                onSelect    = function()
                    TriggerServerEvent('DERP-business:toggleDuty', businessKey)
                end
            }
        }
    })
    ids.duty = dutyId

    for i, craftZone in ipairs(config.crafts) do
        local craftId = exports.ox_target:addSphereZone({
            coords  = craftZone.coords,
            radius  = craftZone.radius or 1.5,
            options = {
                {
                    name        = 'craft_' .. businessKey .. '_' .. i,
                    label       = craftZone.label or 'Chế Biến',
                    icon        = 'fas fa-utensils',
                    canInteract = function()
                        local data = getPlayerData()
                        return data and data.job and data.job.name == config.job and data.job.onduty == true
                    end,
                    onSelect    = function()
                        openCraftMenu(businessKey, i, craftZone)
                    end
                }
            }
        })
        ids.crafts[#ids.crafts + 1] = craftId
    end

    zoneIds[businessKey] = ids
end

local function refreshAll()
    for businessKey, config in pairs(Config.Businesses) do
        setupBusiness(businessKey, config)
    end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    local data = getPlayerData()
    if data then playerJob = data.job.name end
    refreshAll()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(jobData)
    playerJob = jobData.name
    refreshAll()
end)

AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    CreateThread(function()
        local data = nil
        local attempts = 0
        while not data and attempts < 20 do
            Wait(300)
            data = getPlayerData()
            attempts = attempts + 1
        end
        if data then
            playerJob = data.job.name
        end
        refreshAll()
    end)
end)