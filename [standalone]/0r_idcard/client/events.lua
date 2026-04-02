RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    Wait(3000)
    local result = GetBase64(PlayerPedId())
    local shot = "assets/default.png"

    if result.success then
        shot = result.base64
    end

    TriggerServerEvent("0r_idcard:server:loadCard", shot)
end)

RegisterNetEvent("esx:playerLoaded", function()
    Wait(3000)
    local result = GetBase64(PlayerPedId())
    local shot = "assets/default.png"

    if result.success then
        shot = result.base64
    end

    TriggerServerEvent("0r_idcard:server:loadCard", shot)
end)

RegisterNetEvent("0r_idcard:client:showCard", function(data, isJobCard, shown)
    openCard(data, isJobCard, shown)
end)

RegisterNetEvent("0r_idcard:client:notify", function(message, type)
    Config.Notify(message, type)
end)

RegisterNetEvent("0r_idcard:client:setCardData", function(data)
    PData = data
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        for k, v in pairs(Peds) do
            DeleteEntity(v)
        end

        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
    end
end)