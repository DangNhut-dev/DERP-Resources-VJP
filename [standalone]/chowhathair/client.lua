QBCore = exports['qb-core']:GetCoreObject()

local savedHair = nil

-- Chỉ cần exports này, ox_inventory gọi thẳng vào
exports('useHatItem', function()
    local ped    = PlayerPedId()
    local gender = IsPedMale(ped) and 0 or 1

    if not savedHair then
        if gender == 0 then
            savedHair = {
                drawable = GetPedDrawableVariation(ped, 2),
                texture  = GetPedTextureVariation(ped, 2)
            }
            SetPedComponentVariation(ped, 2, 0, 0, 2)
            QBCore.Functions.Notify("Đội mũ, tóc biến mất!", "success")
        else
            QBCore.Functions.Notify("Chỉ dành cho nhân vật nam.", "error")
        end
    else
        SetPedComponentVariation(ped, 2, savedHair.drawable, savedHair.texture, 2)
        savedHair = nil
        QBCore.Functions.Notify("Tháo mũ, tóc trở lại!", "success")
    end
end)