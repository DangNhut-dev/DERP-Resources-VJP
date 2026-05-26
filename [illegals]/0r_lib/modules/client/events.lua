RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
	TriggerServerEvent('0R:Core:NewPlayerJoined')
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
	TriggerServerEvent('0R:Core:NewPlayerJoined')
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    Resmon.Lib.PlayerData.job = job
    TriggerServerEvent("0R:Core:SetPlayerJob", job)
end)

RegisterNetEvent("QBCore:Client:OnJobUpdate")
AddEventHandler("QBCore:Client:OnJobUpdate", function(job)
    Resmon.Lib.PlayerData.job = job
    TriggerServerEvent("0R:Core:SetPlayerJob", job)
end)

RegisterNetEvent('qb-spawn:client:openUI', function()
	TriggerServerEvent('0R:Core:NewPlayerJoined')
end)

AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	    return
	end
	TriggerServerEvent('0R:Core:NewPlayerJoined')
end)

RegisterNetEvent("0R:Core:SetPlayerData", function(PlayerData)
    Resmon.Lib.PlayerData = PlayerData
end)

RegisterNetEvent('0R:Core:ServerCallback', function(requestId, ...)
	Resmon.Lib.ServerCallbacks[requestId](...)
	Resmon.Lib.ServerCallbacks[requestId] = nil
end)