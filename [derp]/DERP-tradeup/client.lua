local tradeNPC  = nil
local isUIOpen  = false

-- Xoa toan bo ped cung model gan coords truoc khi spawn moi
local function ClearOldNPCs()
    local model  = joaat(Config.NPC.model)
    local coords = vec3(Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z)
    local peds   = GetGamePool('CPed')

    for _, ped in ipairs(peds) do
        if GetEntityModel(ped) == model and not IsPedAPlayer(ped) then
            local dist = #(GetEntityCoords(ped) - coords)
            if dist < 5.0 and DoesEntityExist(ped) then
                SetEntityAsMissionEntity(ped, true, true)
                DeleteEntity(ped)
            end
        end
    end
end

-- Spawn NPC tai coords va dang ky ox_target len entity do
local function SpawnNPC()
    ClearOldNPCs()

    local model = joaat(Config.NPC.model)
    lib.requestModel(model)

    tradeNPC = CreatePed(
        4,
        model,
        Config.NPC.coords.x,
        Config.NPC.coords.y,
        Config.NPC.coords.z - 1.0,
        Config.NPC.coords.w,
        false, false
    )
    SetEntityAsMissionEntity(tradeNPC, true, true)
    SetBlockingOfNonTemporaryEvents(tradeNPC, true)
    SetPedDiesWhenInjured(tradeNPC, false)
    SetPedCanPlayAmbientAnims(tradeNPC, true)
    SetPedCanRagdollFromPlayerImpact(tradeNPC, false)
    SetEntityInvincible(tradeNPC, true)
    FreezeEntityPosition(tradeNPC, true)
    SetModelAsNoLongerNeeded(model)

    if Config.NPC.scenario and Config.NPC.scenario ~= '' then
        TaskStartScenarioInPlace(tradeNPC, Config.NPC.scenario, 0, true)
    end

    exports.ox_target:addLocalEntity(tradeNPC, {
        {
            name     = 'tradeup_open',
            label    = 'Trao Đổi Quần Áo',
            icon     = 'fas fa-arrows-up-down',
            distance = 2.0,
            onSelect = function()
                if isUIOpen then return end
                lib.callback('DERP-tradeup:getItems', false, function(data)
                    if not data then return end
                    isUIOpen = true
                    SetNuiFocus(true, true)
                    SendNUIMessage({
                        action       = 'open',
                        resourceName = GetCurrentResourceName(),
                        data         = data,
                    })
                end)
            end,
        },
    })
end

CreateThread(SpawnNPC)

AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    SpawnNPC()
end)

AddEventHandler('onClientResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    if tradeNPC and DoesEntityExist(tradeNPC) then
        exports.ox_target:removeLocalEntity(tradeNPC)
        SetEntityAsMissionEntity(tradeNPC, true, true)
        DeleteEntity(tradeNPC)
        tradeNPC = nil
    end
    if isUIOpen then
        SetNuiFocus(false, false)
        isUIOpen = false
    end
end)

RegisterNUICallback('closeUI', function(_, cb)
    isUIOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Gui request trade-up len server qua lib.callback, tra ket qua cho NUI
RegisterNUICallback('startTradeUp', function(data, cb)
    if not data or not data.materialSlots or data.gender == nil then
        return cb({ error = 'invalid_data' })
    end
    lib.callback('DERP-tradeup:tradeUp', false, function(result)
        cb(result or { error = 'timeout' })
    end, data.materialSlots, data.gender)
end)

-- Refresh material list sau khi trade-up thanh cong
RegisterNUICallback('refreshItems', function(_, cb)
    lib.callback('DERP-tradeup:getItems', false, function(data)
        cb(data or { materials = {} })
    end)
end)