local spawnedPed = nil

CreateThread(function()
    -- Spawn NPC
    local model = GetHashKey('csb_prologuedriver')
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    spawnedPed = CreatePed(4, model, Config.StartLoc.x, Config.StartLoc.y, Config.StartLoc.z, Config.StartLoc.w, false, true)
    FreezeEntityPosition(spawnedPed, true)
    SetEntityInvincible(spawnedPed, true)
    SetBlockingOfNonTemporaryEvents(spawnedPed, true)
    TaskStartScenarioInPlace(spawnedPed, 'WORLD_HUMAN_CLIPBOARD', 0, true)
    SetModelAsNoLongerNeeded(model)

    -- ox_target cho NPC
    exports.ox_target:addLocalEntity(spawnedPed, {
        {
            name = 'chopshop_talk',
            icon = 'fas fa-car',
            label = 'Nói chuyện',
            distance = 1.5,
            onSelect = function()
                TriggerEvent('orbit-chopshop:jobaccept')
            end,
        },
    })

    -- ox_target cho bàn rã phụ tùng
    exports.ox_target:addBoxZone({
        coords = vec3(471.5797, -1312.1295, 29.33),
        size = vec3(1.40, 1.35, 1.1),
        rotation = 113.1992,
        debug = false,
        options = {
            {
                name = 'chopshop_parts',
                icon = 'fas fa-hammer',
                label = 'Rã Nguyên Liệu',
                distance = 3.5,
                onSelect = function()
                    TriggerEvent('orbit-chopshop:StartMenu')
                end,
            },
        },
    })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if spawnedPed and DoesEntityExist(spawnedPed) then
        DeleteEntity(spawnedPed)
    end
end)