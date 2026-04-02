-- client.lua
local preloaded         = {}
local isCraftingLocally = false
local craftConfirmState = nil
local minigameResult    = nil

RegisterNetEvent('DERP-business:craftConfirmed', function(success)
    craftConfirmState = success
end)

RegisterNUICallback('minigameResult', function(data, cb)
    minigameResult = data.success == true
    cb('ok')
end)

local function preloadAssets()
    for _, business in pairs(Config.Businesses) do
        for _, craft in pairs(business.crafts) do
            for _, itemData in pairs(craft.items) do
                if itemData.anim then
                    local dict = itemData.anim.dict
                    if dict and not preloaded[dict] then
                        RequestAnimDict(dict)
                        local timeout = 0
                        while not HasAnimDictLoaded(dict) do
                            Wait(10)
                            timeout = timeout + 10
                            if timeout > 5000 then break end
                        end
                        preloaded[dict] = true
                    end

                    if itemData.anim.prop then
                        local hash = GetHashKey(itemData.anim.prop.model)
                        if not HasModelLoaded(hash) then
                            RequestModel(hash)
                            local timeout = 0
                            while not HasModelLoaded(hash) do
                                Wait(10)
                                timeout = timeout + 10
                                if timeout > 5000 then break end
                            end
                        end
                    end
                end
            end
        end
    end
end

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    preloadAssets()
end)

AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    preloadAssets()
end)

local function attachProp(ped, propData)
    local hash = GetHashKey(propData.model)
    if not HasModelLoaded(hash) then return nil end

    local prop = CreateObject(hash, 0.0, 0.0, 0.0, true, true, false)
    AttachEntityToEntity(
        prop, ped,
        GetPedBoneIndex(ped, propData.bone),
        propData.pos.x, propData.pos.y, propData.pos.z,
        propData.rot.x, propData.rot.y, propData.rot.z,
        true, true, false, true, 1, true
    )
    return prop
end

local function runMinigame(itemType)
    minigameResult = nil
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'show', itemType = itemType })

    local elapsed = 0
    while minigameResult == nil do
        Wait(50)
        elapsed = elapsed + 50
        if elapsed >= 60000 then
            SendNUIMessage({ action = 'hide' })
            SetNuiFocus(false, false)
            minigameResult = nil
            return false
        end
    end

    local result   = minigameResult
    minigameResult = nil
    SetNuiFocus(false, false)
    return result == true
end

local function runOneCraft(itemLabel, duration, anim)
    local ped  = PlayerPedId()
    local prop = nil

    if anim then
        if not HasAnimDictLoaded(anim.dict) then
            RequestAnimDict(anim.dict)
            local timeout = 0
            while not HasAnimDictLoaded(anim.dict) do
                Wait(10)
                timeout = timeout + 10
                if timeout > 3000 then break end
            end
        end

        if HasAnimDictLoaded(anim.dict) then
            TaskPlayAnim(ped, anim.dict, anim.clip, 2.0, -2.0, -1, 1, 0, false, false, false)
        end

        if anim.prop then
            prop = attachProp(ped, anim.prop)
        end
    end

    local completed = lib.progressBar({
        duration     = duration,
        label        = 'Đang chế biến: ' .. itemLabel,
        useWhileDead = false,
        canCancel    = true,
        disable      = { move = true, car = true, combat = true },
    })

    ClearPedTasks(ped)

    if prop and DoesEntityExist(prop) then
        DeleteObject(prop)
    end

    return completed
end

local function confirmWithServer()
    craftConfirmState = nil
    TriggerServerEvent('DERP-business:craftOneCompleted')

    local elapsed = 0
    while craftConfirmState == nil do
        Wait(50)
        elapsed = elapsed + 50
        if elapsed >= 5000 then
            craftConfirmState = nil
            return false
        end
    end

    local result      = craftConfirmState
    craftConfirmState = nil
    return result == true
end

RegisterNetEvent('DERP-business:craftBatchStart', function(itemLabel, duration, anim, total, recipe, itemType)
    if isCraftingLocally then return end
    isCraftingLocally = true
    craftConfirmState = nil

    local passed = runMinigame(itemType or 'food')
    if not passed then
        isCraftingLocally = false
        craftConfirmState = nil
        TriggerServerEvent('DERP-business:craftCancelled', 0)
        lib.notify({ title = 'Đã hủy', description = 'Dừng chế biến', type = 'error' })
        return
    end

    local completed = 0

    for i = 1, total do
        if recipe then
            for itemName, count in pairs(recipe) do
                lib.notify({
                    title       = 'Nguyên liệu',
                    description = 'Dùng ' .. count .. 'x ' .. itemName,
                    type        = 'inform'
                })
            end
        end

        local ok = runOneCraft(itemLabel, duration, anim)

        if not ok then
            isCraftingLocally = false
            craftConfirmState = nil
            TriggerServerEvent('DERP-business:craftCancelled', completed)
            lib.notify({
                title       = 'Đã hủy',
                description = 'Đã chế biến ' .. completed .. '/' .. total .. ', hoàn trả nguyên liệu còn lại',
                type        = 'inform'
            })
            return
        end

        local confirmed = confirmWithServer()

        if not confirmed then
            isCraftingLocally = false
            craftConfirmState = nil
            lib.notify({ title = 'Lỗi', description = 'Mất kết nối server, dừng chế biến', type = 'error' })
            return
        end

        completed = completed + 1

        lib.notify({
            title       = 'Hoàn thành',
            description = 'Đã tạo: ' .. itemLabel .. ' (' .. completed .. '/' .. total .. ')',
            type        = 'success'
        })
    end

    lib.notify({
        title       = 'Hoàn tất',
        description = 'Tổng cộng đã tạo ' .. total .. 'x ' .. itemLabel,
        type        = 'success'
    })

    isCraftingLocally = false
    craftConfirmState = nil
end)

RegisterNetEvent('DERP-business:craftFailed', function(reason)
    lib.notify({ title = 'Thất bại', description = reason, type = 'error' })
end)