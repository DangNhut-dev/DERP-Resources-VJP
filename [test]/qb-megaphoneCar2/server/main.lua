
function setTalkingMegaphone(talking)
	for player, _ in pairs(GetPlayers()) do
		if player ~= source then
			TriggerClientEvent('pma-voice:setTalkingMegaphone', player, source, talking)
		end
	end
end

RegisterNetEvent('pma-voice:setTalkingMegaphone', setTalkingMegaphone)
