Utils = Utils or exports['lc_utils']:GetUtils()
main_ui_open = false
current_fishing_location_id = nil
cached_translations = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- LOCATIONS
-----------------------------------------------------------------------------------------------------------------------------------------	

-- Main menu locations
function createMarkersThread()
	-- Process the fishing location ui markers
	for fishing_location_id,fishing_location_data in pairs(Config.fishing_locations) do
		Citizen.CreateThreadNow(function()
			while true do
				local timer = 1500
				if not main_ui_open then
					local x,y,z = table.unpack(fishing_location_data.menu_location)
					if Utils.Entity.isPlayerNearCoords(x,y,z,20.0) then
						timer = 2
						Utils.Markers.createMarkerInCoords(fishing_location_id,x,y,z,cached_translations.open,openFishingUiCallback)
					end
				end
				Citizen.Wait(timer)
			end
		end)
	end

	-- Process the fishing properties ui markers
	-- for property_id, property_location_data in pairs(Config.available_items_store.property) do
	-- 	Citizen.CreateThreadNow(function()
	-- 		local timer = 2
	-- 		while true do
	-- 			timer = 1500
	-- 			if not main_ui_open then
	-- 				local x,y,z = table.unpack(property_location_data.location)
	-- 				if Utils.Entity.isPlayerNearCoords(x,y,z,20.0) then
	-- 					timer = 2
	-- 					Utils.Markers.createMarkerInCoords(property_id,x,y,z,cached_translations.open,openPropertyUiCallback)
	-- 				end
	-- 			end
	-- 			Citizen.Wait(timer)
	-- 		end
	-- 	end)
	-- end

	-- Process the fishing stores ui markers
	for fishing_store_id,fishing_store_data in pairs(Config.fish_stores) do
		Citizen.CreateThreadNow(function()
			while true do
				local timer = 1500
				if not main_ui_open then
					local x,y,z = table.unpack(fishing_store_data.menu_location)
					if Utils.Entity.isPlayerNearCoords(x,y,z,20.0) then
						timer = 2
						Utils.Markers.createMarkerInCoords(fishing_store_id,x,y,z,cached_translations.open,openFishingStoreUiCallback)
					end
				end
				Citizen.Wait(timer)
			end
		end)
	end
end

-- Main menu locations
function createTargetsThread()
    -- Process the fishing location ui target
    for fishing_location_id, fishing_location_data in pairs(Config.fishing_locations) do
        local x, y, z = table.unpack(fishing_location_data.menu_location)
        local heading = fishing_location_data.menu_heading
        Utils.Peds.spawnPedAtCoords('a_m_y_stwhi_02', x, y, z + 1.0, heading, true, true, 'WORLD_HUMAN_SMOKING')
        Utils.Target.createTargetInCoords(fishing_location_id, x, y, z + 1.0, openFishingUiCallback, cached_translations.open_main_target, 'fas fa-fish-fins', '#2986cc')
    end

    -- Process the fishing properties ui target
    for property_id, property_location_data in pairs(Config.available_items_store.property) do
        local x, y, z = table.unpack(property_location_data.location)

        Utils.Target.createTargetInCoords(property_id, x, y, z, openPropertyUiCallback, cached_translations.open_property_target, 'fas fa-warehouse', '#2986cc')
    end

    -- Process the fishing stores ui target
    for fishing_store_id, fishing_store_data in pairs(Config.fish_stores) do
        local x, y, z = table.unpack(fishing_store_data.menu_location)
        local heading = fishing_store_data.menu_heading
        Utils.Peds.spawnPedAtCoords('a_m_y_stwhi_02', x, y, z + 1.0, heading, true, true, 'WORLD_HUMAN_SMOKING')
        Utils.Target.createTargetInCoords(fishing_store_id, x, y, z + 1.0, openFishingStoreUiCallback, cached_translations.open_store_target, 'fas fa-store', '#2986cc')
    end
end

function openFishingUiCallback(fishing_location_id)
	current_fishing_location_id = fishing_location_id
	TriggerServerEvent("lc_fishing_simulator:getData",current_fishing_location_id)
end

function openPropertyUiCallback(property_location_id)
	TriggerServerEvent("lc_fishing_simulator:getDataProperty",property_location_id)
end

function openFishingStoreUiCallback(fishing_store_id)
	current_fishing_location_id = fishing_store_id
	TriggerServerEvent("lc_fishing_simulator:getDataStore",fishing_store_id)
end

RegisterNetEvent('lc_fishing_simulator:open')
AddEventHandler('lc_fishing_simulator:open', function(data,isUpdate)
	data.config.available_items_store = Utils.Table.deepCopy(Config.available_items_store)

	TriggerScreenblurFadeIn(1000)
	SendNUIMessage({
		openOwnerUI = true,
		isUpdate = isUpdate,
		data = data,
		utils = { config = Utils.Config, lang = Utils.Lang },
		resourceName = GetCurrentResourceName()
	})
	if isUpdate == false then
		main_ui_open = true
		SetNuiFocus(true,true)
	end
end)

RegisterNetEvent('lc_fishing_simulator:openProperty')
AddEventHandler('lc_fishing_simulator:openProperty', function(data, property)
	TriggerScreenblurFadeIn(1000)
	SendNUIMessage({
		openPropertyUI = true,
		property = property,
		data = data,
		utils = { config = Utils.Config, lang = Utils.Lang },
		resourceName = GetCurrentResourceName()
	})
	main_ui_open = true
	SetNuiFocus(true,true)
end)


RegisterNetEvent('lc_fishing_simulator:openStore')
AddEventHandler('lc_fishing_simulator:openStore', function(data)
	TriggerScreenblurFadeIn(1000)
	SendNUIMessage({
		openFishStoreUI = true,
		data = data,
		utils = { config = Utils.Config, lang = Utils.Lang },
		resourceName = GetCurrentResourceName()
	})
	main_ui_open = true
	SetNuiFocus(true,true)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- CALLBACKS
-----------------------------------------------------------------------------------------------------------------------------------------

local cooldown = nil
RegisterNUICallback('post', function(body, cb)
	if cooldown == nil then
		cooldown = true

		if body.event == "close" then
			closeUI()
		elseif body.event == "closeFishingUI" then
			closeFishingUI()
		elseif body.event == "focusFishingUI" then
			SetNuiFocusKeepInput(false)
			SetNuiFocus(true, true)
		elseif body.event == "endFishingGame" then
			TriggerEvent("lc_fishing_simulator:endFishingGame", body.data)
		else
			TriggerServerEvent('lc_fishing_simulator:'..body.event,current_fishing_location_id,body.data)
		end
		cb(200)

		SetTimeout(5,function()
			cooldown = nil
		end)
	end
end)

RegisterNUICallback('close', function(data, cb)
	closeUI()
	cb(200)
end)

RegisterNetEvent('lc_fishing_simulator:closeUI')
AddEventHandler('lc_fishing_simulator:closeUI', function()
	closeUI()
end)

function closeUI()
	current_fishing_location_id = nil
	main_ui_open = false
	SetNuiFocus(false,false)
	SendNUIMessage({ hidemenu = true })
	TriggerScreenblurFadeOut(1000)
	TriggerServerEvent('lc_fishing_simulator:closeUI')
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------

local route_blip
RegisterNetEvent('lc_fishing_simulator:startContract')
AddEventHandler('lc_fishing_simulator:startContract', function(contract_data)
	closeUI()

	contract_data.delivery_location = json.decode(contract_data.delivery_location)
	local x,y,z = table.unpack(contract_data.delivery_location)

	route_blip = Utils.Blips.createBlipForCoords(x,y,z,1,5,Utils.translate('contract_destination_blip'),1.0,true)

	local timer
	while DoesBlipExist(route_blip) do
		timer = 3000
		local distance = #(GetEntityCoords(PlayerPedId()) - vector3(x,y,z))
		if distance <= 20.0 then
			timer = 2
			Utils.Markers.drawMarker(21,x,y,z,0.5)
			if distance <= 2.0 then
				Utils.Markers.drawText3D(x,y,z-0.6,Utils.translate('contract_finish_delivery'))
				if IsControlJustPressed(0,38) then
					TriggerServerEvent("lc_fishing_simulator:finishContract")
				end
			end
		end
		Citizen.Wait(timer)
	end
end)

RegisterNetEvent('lc_fishing_simulator:cancelContract')
AddEventHandler('lc_fishing_simulator:cancelContract', function()
	Utils.Blips.removeBlip(route_blip)
end)

RegisterNetEvent('lc_fishing_simulator:viewLocation')
AddEventHandler('lc_fishing_simulator:viewLocation', function(location)
	closeUI()
	SetNewWaypoint(location[1],location[2])
end)

local swinSuit = {
	mask = 0,
	tank = 0,
}

RegisterNetEvent('lc_fishing_simulator:toggleswimsuit')
AddEventHandler('lc_fishing_simulator:toggleswimsuit', function()
	if swinSuit.mask ~= 0 and swinSuit.tank ~= 0 then
		deleteSwinSuit()
	else
		local maskModel = GetHashKey("p_d_scuba_mask_s")
		local tankModel = GetHashKey("p_s_scuba_tank_s")
		local ped = PlayerPedId()

		Utils.Entity.loadModel(tankModel)
		local tankObject = CreateObject(tankModel, 1.0, 1.0, 1.0, true, true, false)
		local bone1 = GetPedBoneIndex(ped, 24818)
		AttachEntityToEntity(tankObject, ped, bone1, -0.25, -0.25, 0.0, 180.0, 90.0, 0.0, true, true, false, false, 2, true)
		swinSuit.tank = tankObject

		Utils.Entity.loadModel(maskModel)
		local maskObject = CreateObject(maskModel, 1.0, 1.0, 1.0, true, true, false)
		local bone2 = GetPedBoneIndex(ped, 12844)
		AttachEntityToEntity(maskObject, ped, bone2, 0.0, 0.0, 0.0, 180.0, 90.0, 0.0, true, true, false, false, 2, true)
		swinSuit.mask = maskObject

		SetEnableScuba(ped, true)
		SetPedDiesInWater(PlayerPedId(), false)
		ClearPedTasks(ped)
	end
end)

function deleteSwinSuit()
	if swinSuit.mask ~= 0 then
		DetachEntity(swinSuit.mask, false, true)
		DeleteEntity(swinSuit.mask)
		swinSuit.mask = 0
	end
	if swinSuit.tank ~= 0 then
		DetachEntity(swinSuit.tank, false, true)
		DeleteEntity(swinSuit.tank)
		swinSuit.tank = 0
	end
	SetEnableScuba(PlayerPedId(), false)
	SetPedDiesInWater(PlayerPedId(), true)
end

local dive_area_blip
local chest
local isPlayerInDive = false
RegisterNetEvent('lc_fishing_simulator:startDive')
AddEventHandler('lc_fishing_simulator:startDive', function(dive_data)
	closeUI()
	isPlayerInDive = true 
	dive_data.dive_location = json.decode(dive_data.dive_location)
	local x,y,z = table.unpack(dive_data.dive_location)
	x = x + 0.001
	y = y + 0.001
	z = z + 1.001
	local radius = 90.0
	local randomX, randomY = randomPositionWithinCircle(x, y, radius)
	dive_area_blip = Utils.Blips.createBlipForArea(randomX, randomY, z, radius + 10.0, 3, 128, true)

	local timer
	while isPlayerInDive do
		timer = 3000
		local playerCoords = GetEntityCoords(PlayerPedId())
		local distance = #(playerCoords - vector3(x, y, z))
		if distance < 80.0 and not chest then
			local success, groundZ = GetGroundZExcludingObjectsFor_3dCoord(x, y, z, false)
			if success then
				z = groundZ
			else
				print("No ground found.")
			end
			chest = CreateObject(Config.chest_model, x, y, z, false, false, false)
			PlaceObjectOnGroundProperly_2(chest)
		elseif distance >= 120.0 and chest then
			DeleteObject(chest)
			chest = nil
		end

		if distance <= 50.0 then
			timer = 2
			Utils.Markers.drawMarker(21, x, y, z + 2.2, 1.2, 12, 120, 200, 90)
			if distance <= 3.0 then
				Utils.Markers.drawText3D(x, y, z + 1.2, Utils.translate('dive_finish'))
				if IsControlJustPressed(0, 38) then
					TriggerServerEvent("lc_fishing_simulator:finishDive")
				end
			end
		end
		Citizen.Wait(timer)
	end
end)

function randomPositionWithinCircle(centerX, centerY, radius)
	local angle = math.random() * 2 * math.pi
	local distance = math.sqrt(math.random()) * radius
	local x = centerX + distance * math.cos(angle)
	local y = centerY + distance * math.sin(angle)
	return x, y
end

RegisterNetEvent('lc_fishing_simulator:cancelDive')
AddEventHandler('lc_fishing_simulator:cancelDive', function()
	isPlayerInDive = false
	Utils.Blips.removeBlip(dive_area_blip)
	if chest then
		DeleteObject(chest)
		chest = nil
	end
end)

local vehicle,vehicle_blip
local update_vehicle_status = 0
RegisterNetEvent('lc_fishing_simulator:spawnVehicle')
AddEventHandler('lc_fishing_simulator:spawnVehicle', function(vehicle_data,garage_to_spawn,teleport_location,blip_config)
	if IsEntityAVehicle(vehicle) then
		exports['lc_utils']:notify("error",Utils.translate('vehicle_already_spawned'))
		return
	end

	closeUI()

	local i = #garage_to_spawn
	local x,y,z,h
	while i > 0 do
		x,y,z,h = table.unpack(garage_to_spawn[i])
		if not Utils.Vehicles.isSpawnPointClear({['x']=x,['y']=y,['z']=z},5.001) then
			if i <= 1 then
				exports['lc_utils']:notify("error",Utils.translate('occupied_places'))
				return
			end
		else
			break
		end
		i = i - 1
	end

	vehicle_data.properties = json.decode(vehicle_data.properties) or {}
	vehicle_data.properties.plate = vehicle_data.properties.plate or Utils.Vehicles.generateTempVehiclePlateWithPrefix(GetCurrentResourceName())
	vehicle_data.properties.bodyHealth = vehicle_data.health
	vehicle_data.properties.engineHealth = vehicle_data.health
	vehicle_data.properties.fuelLevel = vehicle_data.fuel
	local blip_data = { name = Utils.translate('vehicle_blip'), sprite = blip_config.sprite, color = blip_config.color }
	vehicle,vehicle_blip = Utils.Vehicles.spawnVehicle(vehicle_data.vehicle,x,y,z,h,blip_data,vehicle_data.properties)
	exports['lc_utils']:notify("success",Utils.translate('vehicle_spawned'))

	local timer = 2
	local engine_health = GetVehicleEngineHealth(vehicle)
	local vehicle_fuel = GetVehicleFuelLevel(vehicle)
	local body_health = GetVehicleBodyHealth(vehicle)

	local is_frozen = false
	if GetVehicleType(vehicle) == "boat" or GetVehicleType(vehicle) == "submarine" then
		SetTimeout(2000,function()
			FreezeEntityPosition(vehicle,true)
			is_frozen = true
		end)
		SetTimeout(20000,function()
			FreezeEntityPosition(vehicle,false)
			is_frozen = false
		end)
	end
	while IsEntityAVehicle(vehicle) do
		timer = 2000
		local coords = GetEntityCoords(vehicle)
		local ped = PlayerPedId()
		if oldpos ~= nil then
			if is_frozen and #(coords - GetEntityCoords(ped)) < 10 then
				FreezeEntityPosition(vehicle,false)
				is_frozen = false
			end
			local dist = #(coords - oldpos)
			vehicle_data.traveled_distance = vehicle_data.traveled_distance + dist
			veh = GetVehiclePedIsIn(ped,false)
			if veh == vehicle then
				for k,mark in pairs(garage_to_spawn) do
					local x,y,z = table.unpack(mark)
					local distance = #(GetEntityCoords(PlayerPedId()) - vector3(x,y,z))
					if distance <= 20.0 then
						timer = 2
						Utils.Markers.drawMarker(36,x,y,z,1.0)
						if distance <= 2.0 then
							Utils.Markers.drawText2D(Utils.translate('press_e_to_store_vehicle'), 8,0.5,0.95,0.50,255,255,255,180)
							if IsControlJustPressed(0,38) and IsEntityAVehicle(vehicle) then
								DoScreenFadeOut(500)
								Wait(500)
								TriggerServerEvent("lc_fishing_simulator:updateVehicleStatus",vehicle_data,GetVehicleEngineHealth(vehicle),GetVehicleBodyHealth(vehicle),GetVehicleFuelLevel(vehicle),Utils.Vehicles.getVehicleProperties(vehicle))
								Utils.Vehicles.deleteVehicle(vehicle)
								Utils.Blips.removeBlip(vehicle_blip)
								if teleport_location then
									SetEntityCoords(ped,teleport_location[1],teleport_location[2],teleport_location[3],true,false,false,true)
								end
								Wait(500)
								DoScreenFadeIn(500)
								return
							end
						end
					end
				end
			end

			if IsEntityAVehicle(vehicle) and update_vehicle_status == 0 and (engine_health ~= GetVehicleEngineHealth(vehicle) or vehicle_fuel ~= GetVehicleFuelLevel(vehicle)) then
				update_vehicle_status = 3
				engine_health = GetVehicleEngineHealth(vehicle)
				body_health = GetVehicleBodyHealth(vehicle)
				vehicle_fuel = GetVehicleFuelLevel(vehicle)
				TriggerServerEvent("lc_fishing_simulator:updateVehicleStatus",vehicle_data,engine_health,body_health,vehicle_fuel,Utils.Vehicles.getVehicleProperties(vehicle))
			end
		end

		local vehicles = { vehicle }
		local peds = { ped }
		local has_error, error_message = Utils.Entity.isThereSomethingWrongWithThoseBoys(vehicles,peds)
		if has_error then
			Utils.Framework.removeVehicleKeysFromPlate(vehicle_data.properties.plate, vehicle_data.vehicle)
			Utils.Blips.removeBlip(route_blip)
			Utils.Blips.removeBlip(vehicle_blip)
			PlaySoundFrontend(-1, "PROPERTY_PURCHASE", "HUD_AWARDS", false)
			if Utils.Table.contains({'vehicle_almost_destroyed','vehicle_undriveable','ped_is_dead'}, error_message) then
				SetVehicleEngineHealth(vehicle,-4000)
				SetVehicleUndriveable(vehicle,true)
			end
			if error_message == 'ped_is_dead' then
				exports['lc_utils']:notify("error",Utils.translate('you_died'))
			else
				exports['lc_utils']:notify("error",Utils.translate('vehicle_destroyed'))
			end
			TriggerServerEvent("lc_fishing_simulator:updateVehicleStatus",vehicle_data,engine_health,body_health,vehicle_fuel)
			return
		end

		oldpos = coords
		Citizen.Wait(timer)
	end
	Utils.Blips.removeBlip(vehicle_blip)
	exports['lc_utils']:notify("error",Utils.translate('vehicle_lost'))
	TriggerServerEvent("lc_fishing_simulator:updateVehicleStatus",vehicle_data,engine_health,body_health,vehicle_fuel)
end)

Citizen.CreateThread(function()
	while true do
		timer = 10000
		if update_vehicle_status > 0 then
			update_vehicle_status = update_vehicle_status - 1
		end
		Citizen.Wait(timer)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- TOURNAMENTS
-----------------------------------------------------------------------------------------------------------------------------------------

if Config.fishing_tournaments.enabled then
	RegisterCommand(Config.fishing_tournaments.command,function(source)
		Utils.Callback.TriggerServerCallback('fishing_simulator:getTournamentScoreboard', function(fishing_simulator_tournaments_users)
			if Utils.Table.tableLength(fishing_simulator_tournaments_users) > 0 then
				SendNUIMessage({
					openTournamentUI = true,
					fishing_simulator_tournaments_users = fishing_simulator_tournaments_users,
					utils = { config = Utils.Config, lang = Utils.Lang },
					resourceName = GetCurrentResourceName()
				})
				SetNuiFocus(true,true)
			end
		end)
	end, false)
end

local tournament_blip_id = nil
local tournament_area_blip_id = nil
RegisterNetEvent('lc_fishing_simulator:createTournamentBlip')
AddEventHandler('lc_fishing_simulator:createTournamentBlip', function(location, set_waypoint)
	if tournament_blip_id and DoesBlipExist(tournament_blip_id) then
		Utils.Blips.removeBlip(tournament_blip_id)
		tournament_blip_id = nil
	end
	if tournament_area_blip_id and DoesBlipExist(tournament_area_blip_id) then
		Utils.Blips.removeBlip(tournament_area_blip_id)
		tournament_area_blip_id = nil
	end

	tournament_blip_id = Utils.Blips.createBlipForCoords(location[1],location[2],location[3],Config.fishing_tournaments.blip.id,Config.fishing_tournaments.blip.color,Config.fishing_tournaments.blip.name,Config.fishing_tournaments.blip.scale,false)
	tournament_area_blip_id = Utils.Blips.createBlipForArea(location[1],location[2],location[3],Config.fishing_tournaments.radius + 0.0,Config.fishing_tournaments.blip.color,128,true)
end)

RegisterNetEvent('lc_fishing_simulator:removeTournamentBlip')
AddEventHandler('lc_fishing_simulator:removeTournamentBlip', function()
	Utils.Blips.removeBlip(tournament_blip_id)
	Utils.Blips.removeBlip(tournament_area_blip_id)
	tournament_blip_id = nil
	tournament_area_blip_id = nil
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- OTHERS
-----------------------------------------------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
	for _,fishing_location_data in pairs(Config.fishing_locations) do
		local x,y,z = table.unpack(fishing_location_data.menu_location)
		local blips = fishing_location_data.blips
		if blips then
			Utils.Blips.createBlipForCoords(x,y,z,blips.id,blips.color,blips.name,blips.scale,false)
		end
	end

	for _,store_data in pairs(Config.fish_stores) do
		local x,y,z = table.unpack(store_data.menu_location)
		local blips = store_data.blips
		if blips then
			Utils.Blips.createBlipForCoords(x,y,z,blips.id,blips.color,blips.name,blips.scale,false)
		end
	end
end)

RegisterNetEvent('lc_fishing_simulator:Notify')
AddEventHandler('lc_fishing_simulator:Notify', function(type,message)
	exports['lc_utils']:notify(type,message)
end)

Citizen.CreateThread(function()
	Wait(1000)
	SetNuiFocus(false,false)
	SetNuiFocusKeepInput(false)

	Utils.loadLanguageFile(Lang)

	cached_translations = {
		open = Utils.translate('open'),
		open_main_target = Utils.translate('open_main_target'),
		open_property_target = Utils.translate('open_property_target'),
		open_store_target = Utils.translate('open_store_target'),
	}

	if Utils.Config.custom_scripts_compatibility.target == "disabled" then
		createMarkersThread()
	else
		createTargetsThread()
	end

	if Config.anchor_boat.enable then
		RegisterKeyMapping(Config.anchor_boat.command, Utils.translate('anchor_boat_command'), "keyboard", Config.anchor_boat.shortcut)
	end

	-- for _, property_data in pairs(Config.available_items_store.property) do
	-- 	property_data.address = GetStreetNameFromHashKey(GetStreetNameAtCoord(property_data.location[1],property_data.location[2],property_data.location[3]))
	-- end

	-- Translate the contracts texts
	for _, contract in pairs(Config.available_contracts.contracts) do
		contract.name = Utils.translate(contract.name)
		contract.description = Utils.translate(contract.description)
		for _, item_data in pairs(contract.required_items) do
			if item_data.name then
				local fish_data = Config.fishes_available[item_data.name]
				if fish_data then
					item_data.display_name = item_data.display_name or fish_data.name
				else
					item_data.display_name = item_data.display_name or item_data.name
				end
			end
		end
	end

	for _, dive in pairs(Config.available_dives.dives) do
		dive.name = Utils.translate(dive.name)
		dive.description = Utils.translate(dive.description)
	end

	if Config.fish_prices.enable then
		for _, fish_data in pairs(Config.fishes_available) do
			local rarity_price = Config.fish_prices.prices[fish_data.rarity]
			if rarity_price then
				fish_data.sale_value = math.random(rarity_price.min, rarity_price.max)
			end
		end
	end
end)

AddEventHandler('onResourceStop', function(resourceName)
	if GetCurrentResourceName() ~= resourceName then return end
	if chest then
		DeleteObject(chest)
	end
	stopAnimAndClearItems() -- Do not put anything after this
end)

Citizen.CreateThread(function() while true do Citizen.Wait(30000) collectgarbage() end end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- ANCHOR BOAT
-----------------------------------------------------------------------------------------------------------------------------------------	

if Config.anchor_boat.enable then
	RegisterCommand(Config.anchor_boat.command,function(source)
		local ped = PlayerPedId()
		if IsPedInAnyBoat(ped) then
			local boat = GetVehiclePedIsIn(ped, false)
			if GetPedInVehicleSeat(boat, -1) == ped then
				if GetEntitySpeed(ped) <= 3 then -- KM/H
					toggleBoatAnchor(boat)
				else
					exports['lc_utils']:notify("error",Utils.translate('anchor_too_fast'))
				end
			end
		end
	end, false)
end

function toggleBoatAnchor(boat)
	if IsBoatAnchoredAndFrozen(boat) then
		SetBoatAnchor(boat, false)
		SetBoatFrozenWhenAnchored(boat, false)
		SetForcedBoatLocationWhenAnchored(boat, false)
		exports['lc_utils']:notify("success",Utils.translate('anchor_raised'))
	else
		if CanAnchorBoatHere(boat) then
			SetBoatAnchor(boat, true)
			SetBoatFrozenWhenAnchored(boat, true)
			SetForcedBoatLocationWhenAnchored(boat, true)
			exports['lc_utils']:notify("success",Utils.translate('anchor_lowered'))
		else
			exports['lc_utils']:notify("error",Utils.translate('anchor_not_allowed'))
		end
	end
end