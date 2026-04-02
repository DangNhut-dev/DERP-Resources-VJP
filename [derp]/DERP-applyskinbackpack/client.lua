local npcEntity = nil
local isUIOpen = false

local function SpawnNPC()
    if npcEntity then return end

    local cfg = Config.NPC
    lib.requestModel(cfg.model)

    npcEntity = CreatePed(0, cfg.model, cfg.coords.x, cfg.coords.y, cfg.coords.z, cfg.coords.w, false, true)
    SetEntityHeading(npcEntity, cfg.coords.w)
    FreezeEntityPosition(npcEntity, true)
    SetEntityInvincible(npcEntity, true)
    SetBlockingOfNonTemporaryEvents(npcEntity, true)

    if cfg.scenario then
        TaskStartScenarioInPlace(npcEntity, cfg.scenario, 0, true)
    end

    exports.ox_target:addLocalEntity(npcEntity, {
        {
            name = 'derp_applyskin_open',
            label = Config.Target.label,
            icon = Config.Target.icon,
            distance = Config.Target.distance,
            onSelect = function()
                OpenUI()
            end,
        },
    })
end

local function DeleteNPC()
    if not npcEntity then return end
    exports.ox_target:removeLocalEntity(npcEntity, 'derp_applyskin_open')
    DeleteEntity(npcEntity)
    npcEntity = nil
end

-- ── UI ─────────────────────────────────────────────────────────

function OpenUI()
    if isUIOpen then return end
    isUIOpen = true

    local playerItems = lib.callback.await('DERP-applyskinbackpack:getItems', false)

    SendNUIMessage({
        action = 'open',
        data = {
            backpacks = playerItems.backpacks,
            skins = playerItems.skins,
            rarityTiers = playerItems.rarityTiers,
        },
    })

    SetNuiFocus(true, true)
end

function CloseUI()
    if not isUIOpen then return end
    isUIOpen = false
    SendNUIMessage({ action = 'close' })
    SetNuiFocus(false, false)
end

RegisterNUICallback('close', function(_, cb)
    CloseUI()
    cb('ok')
end)

RegisterNUICallback('apply', function(data, cb)
    if not data or not data.backpackSlot or not data.skinSlot then
        return cb({ success = false })
    end

    local result = lib.callback.await('DERP-applyskinbackpack:apply', false, {
        backpackSlot = data.backpackSlot,
        skinSlot = data.skinSlot,
    })

    cb(result or { success = false })
end)

RegisterNUICallback('refreshItems', function(_, cb)
    local playerItems = lib.callback.await('DERP-applyskinbackpack:getItems', false)
    cb(playerItems)
end)

-- ── Lifecycle ──────────────────────────────────────────────────

CreateThread(function()
    SpawnNPC()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    CloseUI()
    DeleteNPC()
end)