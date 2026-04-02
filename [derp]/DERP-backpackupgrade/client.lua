local upgradeProp = nil
local isUIOpen    = false

-- Xóa toàn bộ object cùng model gần coords trước khi spawn mới
local function ClearOldProps()
    local model  = joaat(Config.PropModel)
    local coords = vec3(Config.PropCoords.x, Config.PropCoords.y, Config.PropCoords.z)
    local objs   = GetGamePool('CObject')

    for _, obj in ipairs(objs) do
        if GetEntityModel(obj) == model then
            local dist = #(GetEntityCoords(obj) - coords)
            if dist < 5.0 and DoesEntityExist(obj) and not IsEntityAttached(obj) then
                SetEntityAsMissionEntity(obj, true, true)
                DeleteObject(obj)
            end
        end
    end
end

-- Spawn prop tại coords và đăng ký ox_target lên entity đó
local function SpawnProp()
    ClearOldProps()

    local model = joaat(Config.PropModel)
    lib.requestModel(model)

    upgradeProp = CreateObject(
        model,
        Config.PropCoords.x,
        Config.PropCoords.y,
        Config.PropCoords.z - 1,
        false, false, false
    )
    SetEntityHeading(upgradeProp, Config.PropCoords.w)
    FreezeEntityPosition(upgradeProp, true)
    SetEntityAsMissionEntity(upgradeProp, true, true)
    SetModelAsNoLongerNeeded(model)

    exports.ox_target:addLocalEntity(upgradeProp, {
        {
            name     = 'backpack_upgrade_open',
            label    = 'Nâng cấp balo',
            icon     = 'fas fa-arrow-up',
            distance = 2.0,
            onSelect = function()
                if isUIOpen then return end
                lib.callback('DERP-backpackupgrade:getItems', false, function(data)
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

CreateThread(SpawnProp)

AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    SpawnProp()
end)

AddEventHandler('onClientResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    if upgradeProp and DoesEntityExist(upgradeProp) then
        exports.ox_target:removeLocalEntity(upgradeProp)
        SetEntityAsMissionEntity(upgradeProp, true, true)
        DeleteObject(upgradeProp)
        upgradeProp = nil
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

-- Gửi request upgrade lên server qua lib.callback, trả về kết quả cho NUI
RegisterNUICallback('startUpgrade', function(data, cb)
    if not data or not data.baloSlot or not data.materialSlots then
        return cb({ error = 'invalid_data' })
    end
    local arcStartDeg = type(data.arcStartDeg) == 'number' and data.arcStartDeg or 0
    lib.callback('DERP-backpackupgrade:upgrade', false, function(result)
        cb(result or { error = 'timeout' })
    end, data.baloSlot, data.materialSlots, arcStartDeg)
end)

RegisterNUICallback('confirmUpgrade', function(data, cb)
    if not data or not data.token then return cb('error') end
    TriggerServerEvent('DERP-backpackupgrade:confirmUpgrade', data.token)
    cb('ok')
end)