local sitting = false

-- QB Target
if config.qb_target then
	exports['qb-target']:AddTargetModel(config.chairs, {
		options = {
			{
				label = "Ngồi ghế", icon = config.targetIcon,
				canInteract = function() return not sitting end,
				action = function(entity) return sit(entity) end
			},
		},
		distance = 1.5,
	})
end

-- OX Target
if config.ox_target then
	exports.ox_target:addModel(config.chairs, {
		{
			label = "Ngồi ghế", name = "nvsit", icon = config.targetIcon, distance = 1.5,
			canInteract = function() return not sitting end,
			onSelect = function(data) return sit(data.entity, data.coords) end
		},
	})
end

function sit(entity, newCoords)
	local playerPed = PlayerPedId()
	local playerCoords = GetEntityCoords(playerPed)
	local entityCoords = GetEntityCoords(entity)
	local name = GetEntityArchetypeName(entity)
	local heading = GetEntityHeading(entity) + 180.0
	if string.find(name, "bench") then
		entityCoords = newCoords
	end
	if name == "prop_table_01_chr_b" then heading += 90 end
	if name == "ic_wedding_chair" then heading -= 33 end
	localEntity = entity
	FreezeEntityPosition(localEntity, true)
	local direction = vector3(playerCoords.x - entityCoords.x, playerCoords.y - entityCoords.y, 0.0)
	local distance = #(playerCoords - entityCoords)
	if GetEntityArchetypeName(entity) == "apa_mp_h_yacht_barstool_01" then
		playerCoords = vec3(playerCoords.x, playerCoords.y, playerCoords.z + 0.25)
		TaskStartScenarioAtPosition(playerPed, "PROP_HUMAN_SEAT_BENCH", entityCoords.x, entityCoords.y, playerCoords.z - 0.5, heading, 0, true, true)
	else
		TaskStartScenarioAtPosition(playerPed, "PROP_HUMAN_SEAT_BENCH", entityCoords.x, entityCoords.y, playerCoords.z - 0.5, heading, 0, true, true)
	end
	if config.forceFPVonSit then
		Wait(1000)
		SetFollowPedCamViewMode(4)
	end
	sitting = true
	lib.showTextUI("[X] Đứng dậy", { position = "left-center" })
end

RegisterKeyMapping('neveradev:sit:stand_up_x', 'Stand Up X', 'keyboard', "X")
RegisterCommand('neveradev:sit:stand_up_x', function() ExecuteCommand('neveradev:sit:stand_up') end)

RegisterCommand('neveradev:sit:stand_up', function()
	if sitting then
		sitting = false
		lib.hideTextUI()
		local playerPed = PlayerPedId()
		ClearPedTasks(playerPed)
		TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_STAND_IDLE", 0, true)
		FreezeEntityPosition(localEntity, false)
		if attachedEntity ~= nil then
			DetachEntity(PlayerPedId(), true, false)
			attachedEntity = nil
		end
		Wait(500)
		SetFollowPedCamViewMode(1)
	end
end)