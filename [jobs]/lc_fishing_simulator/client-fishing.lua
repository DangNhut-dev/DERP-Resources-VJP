local fishing_rod_object = nil
local fish_ped = nil
local fishing_line_rope = nil
local is_fishing = false
local fishing_areas = {}
local active_rod_slot = nil

-----------------------------------------------------------------------------------------------------------------------------------------
-- Fishing Area
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent('lc_fishing_simulator:startFishing')
AddEventHandler('lc_fishing_simulator:startFishing', function(rod_slot)
    active_rod_slot = rod_slot
    local current_area = getCurrentFishingArea()
    local ped = PlayerPedId()

    if not current_area then
        exports['lc_utils']:notify("error", Utils.translate("area_not_found"))
        return
    end

    local isAtWater, coordForUI = isPointInWater()
    if not isAtWater or not coordForUI then
        exports['lc_utils']:notify("error", Utils.translate("water_not_found"))
        return
    end

    if IsPedInAnyVehicle(ped, false) then
        exports['lc_utils']:notify("error", Utils.translate("cannot_fish_in_vehicle"))
        return
    end

    if IsPedSwimming(ped) or IsPedSwimmingUnderWater(ped) then
        exports['lc_utils']:notify("error", Utils.translate("area_not_found"))
        return
    end

    Utils.Callback.TriggerServerCallback('fishing_simulator:getDataFishing', function(fishing_data)
        if not fishing_data then return end
        initFishing(fishing_data)
    end, current_area, active_rod_slot)
end)

RegisterNetEvent('lc_fishing_simulator:openRodMenu')
AddEventHandler('lc_fishing_simulator:openRodMenu', function(rod_slot, metadata, rod_name)
    local detach_map = {
        hook = "Tháo lưỡi câu",
        line = "Tháo dây câu",
        reel = "Tháo máy câu",
    }

    local rod_item_data = exports.ox_inventory:Items(rod_name)
    local rod_label = rod_item_data and rod_item_data.label or rod_name

    local options = {
        {
            title = "Bắt đầu câu cá",
            icon = "fish",
            onSelect = function()
                TriggerEvent('lc_fishing_simulator:startFishing', rod_slot)
            end
        }
    }

    for eq_type, label in pairs(detach_map) do
        if metadata[eq_type] then
            local attached_name = metadata[eq_type]
            local item_data = exports.ox_inventory:Items(attached_name)
            local attached_label = item_data and item_data.label or attached_name

            table.insert(options, {
                title = label .. " (" .. attached_label .. ")",
                icon = "wrench",
                onSelect = function()
                    TriggerServerEvent("lc_fishing_simulator:detachEquipment", {
                        equipment_type = eq_type,
                        rod_slot = rod_slot,
                    })
                end
            })
        end
    end

    lib.registerContext({
        id = "fishing_rod_menu",
        title = rod_label,
        options = options,
    })
    lib.showContext("fishing_rod_menu")
end)

-- Menu chọn cần câu để gắn phụ kiện
RegisterNetEvent('lc_fishing_simulator:openAttachMenu')
AddEventHandler('lc_fishing_simulator:openAttachMenu', function(eq_type, item_name, eq_slot, rod_list)
    local type_label_map = {
        hook = "lưỡi câu",
        line = "dây câu",
        reel = "máy câu",
    }

    local options = {}
    for _, rod in ipairs(rod_list) do
        local desc = rod.current
            and ("Đang gắn: " .. rod.current .. " → sẽ bị thay thế")
            or "Slot trống"

        table.insert(options, {
            title = rod.label,
            description = desc,
            onSelect = function()
                TriggerServerEvent("lc_fishing_simulator:attachEquipment", {
                    equipment_type = eq_type,
                    equipment_item = item_name,
                    equipment_slot = eq_slot,
                    rod_slot = rod.slot,
                })
            end
        })
    end

    lib.registerContext({
        id = "fishing_attach_menu",
        title = "Gắn " .. (type_label_map[eq_type] or eq_type) .. " vào cần câu",
        options = options,
    })
    lib.showContext("fishing_attach_menu")
end)

Citizen.CreateThread(function()
	for areaKey, areaGroups in pairs(Config.areas_available_to_fish) do
		for areaName, coordinates in pairs(areaGroups) do
			local polyZone = PolyZone:Create(coordinates, {debugGrid = Config.debug_polyzones, debugPoly = Config.debug_polyzones, data = {area = areaKey, areaName = areaName}})
			table.insert(fishing_areas, polyZone)
		end
	end
end)

function initFishing(fishing_data)
	if is_fishing == false then

		local area = getCurrentFishingArea()
		if not area then
			exports['lc_utils']:notify("error", Utils.translate("area_not_found"))
			return
		end

		local isAtWater, coordForUI = isPointInWater()
		if not isAtWater or not coordForUI then
			exports['lc_utils']:notify("error", Utils.translate("water_not_found"))
			return
		end

		is_fishing = true

		createRodAndStartAnim(coordForUI)
		disableActions()
		SetNuiFocus(true, true)
		SetNuiFocusKeepInput(true)
		local _, _x,_y = GetScreenCoordFromWorldCoord(coordForUI.x,coordForUI.y,coordForUI.z)
		fishing_data.fishing_simulator_user.x = _x
		fishing_data.fishing_simulator_user.y = _y
		TriggerServerEvent('lc_fishing_simulator:fishingInitialized')
		SendNUIMessage({
			startFishing = true,
			resourceName = GetCurrentResourceName(),
			utils = { config = Utils.Config, lang = Utils.Lang },
			fishing_difficulties = Utils.Table.deepCopy(Config.fishing_difficulties),
			equipments_upgrades = Utils.Table.deepCopy(Config.equipments_upgrades),
			fishing_simulator_user = fishing_data.fishing_simulator_user,
			selected_equipments = fishing_data.selected_equipments,
			time_bait = fishing_data.time_bait,
			time_hook = fishing_data.time_hook,
		});
		updateFishingCoords(coordForUI)
	end
end

function updateFishingCoords(coordForUI)
	Citizen.CreateThread(function()
		while is_fishing do
			Wait(10)
			local onScreen, _x,_y = GetScreenCoordFromWorldCoord(coordForUI.x,coordForUI.y,coordForUI.z)
			SendNUIMessage({
				updateFishingCoords = true,
				x = _x,
				y = _y
			});
		end
	end)
end

RegisterNUICallback('generateFish', function(body, cb)
	Utils.Callback.TriggerServerCallback('fishing_simulator:generateFish', function(fishing_data)
		cb(fishing_data)
	end, getCurrentFishingArea())
end)

function closeFishingUI()
	SetNuiFocus(false, false)
	TriggerScreenblurFadeOut(1000)
	TriggerServerEvent('lc_fishing_simulator:closeUI')
end

RegisterNetEvent('lc_fishing_simulator:endFishingGame')
AddEventHandler('lc_fishing_simulator:endFishingGame', function(data)
	if data.success then
		TriggerServerEvent('lc_fishing_simulator:receiveFish', getCurrentFishingArea(), data.released)
		if data.released then
			stopAnimAndClearItems()
		end
	else
		exports['lc_utils']:notify("error", Utils.translate("fishing_lost"))
		stopAnimAndClearItems()
	end
	SetNuiFocus(false, false)
	SetNuiFocusKeepInput(false)
end)

RegisterNetEvent('lc_fishing_simulator:StopFishingGetFish')
AddEventHandler('lc_fishing_simulator:StopFishingGetFish', function()
	ClearPedTasks(PlayerPedId())
	local forwardVector = GetEntityForwardVector(PlayerPedId())
	local forwardPos = vector3(GetEntityCoords(PlayerPedId())["x"] + forwardVector["x"] * 5, GetEntityCoords(PlayerPedId())["y"] + forwardVector["y"] * 5, GetEntityCoords(PlayerPedId())["z"])
	local fishHandle = Utils.Peds.spawnPedAtCoords(Config.fish_model, forwardPos.x, forwardPos.y, forwardPos.z + 1, 0.0, false, false, false)
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(100)
			local asd = GetEntityCoords(fishHandle, false)
			if Vdist(GetEntityCoords(fishHandle, false), forwardPos) <= 1.5 then
				local plypos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, -25.0, 0.4)

				local x = plypos.x - asd.x
				local y = plypos.y - asd.y
				local z = plypos.z - asd.z
				ApplyForceToEntity(fishHandle, 3, x, y, z+1, 0.0, 0.0, 0.0, 1, false, false, true, false, false)
				Citizen.Wait(1500)
				SetEntityCoords(fishHandle, plypos)
				Utils.Animations.loadAnimDict( "random@domestic" )
				TaskPlayAnim( PlayerPedId(), "random@domestic", "pickup_low", 100.0, 1.0, 1000, 0, 0, false, false, false)
				Citizen.Wait(500)
				AttachEntityToEntity(fishHandle, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
				Citizen.Wait(1000)
				Utils.Peds.deletePed(fishHandle)
				stopAnimAndClearItems()
			else
				break
			end
		end
	end)
end)

function disableActions()
	Citizen.CreateThreadNow(function()
		while is_fishing do
			DisablePlayerFiring(PlayerPedId(), true) -- Disable weapon firing
			DisableControlAction(1, 140, true) -- Disables the pointing action
			Wait(0)
		end
	end)
end

function isPointInWater()
	local playerPed = PlayerPedId()
	local playerCoords = GetEntityCoords(playerPed)
	local forwardVector = GetEntityForwardVector(playerPed)

	local waterPoint = vector3(playerCoords.x + forwardVector.x * 40, playerCoords.y + forwardVector.y * 40, playerCoords.z - 2.0)

	-- Function to check if a single point is in water
	local function isSinglePointInWater(point)
		local waterFound, waterHeight = GetWaterHeight(point.x, point.y, point.z)
		if waterFound and waterHeight then
			return true, vec3(point.x, point.y, waterHeight)
		else
			return false
		end
	end

	-- Check if the entire path is in water
	local numSamples = 5
	local isInWater = true
	local waterHeightPoint = nil

	for i = 1, numSamples do
		local t = i / numSamples
		local interpolatedPoint = vector3(
			playerCoords.x + (waterPoint.x - playerCoords.x) * t,
			playerCoords.y + (waterPoint.y - playerCoords.y) * t,
			playerCoords.z + (waterPoint.z - playerCoords.z) * t
		)
		local singlePointInWater, heightPoint = isSinglePointInWater(interpolatedPoint)

		if not singlePointInWater then
			local entity = Utils.Peds.spawnPedAtCoords(Config.fish_model, interpolatedPoint.x, interpolatedPoint.y, interpolatedPoint.z, 0.0, false, false, false)
			SetEntityVisible(entity, false, false)
			Wait(100)
			if not IsEntityInWater(entity) then
				isInWater = false
				break
			else
				waterHeightPoint = interpolatedPoint
			end
			Utils.Peds.deletePed(entity)
		else
			waterHeightPoint = heightPoint
		end
	end

	if isInWater and waterHeightPoint then
		return true, waterHeightPoint
	else
		return false
	end
end

function getCurrentFishingArea()
	local plyPos = GetEntityCoords(PlayerPedId())
	for _, spot in pairs(fishing_areas) do
		if spot:isPointInside(plyPos) then
			return spot.data.area, spot.data.areaName
		end
	end
	return nil
end

function executeAnim(dict, anim, flag)
	Utils.Animations.loadAnimDict(dict)

	TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 8.0, 5000.0, flag, 0, false, false, false)
	RemoveAnimDict(dict)
end

function createRodAndStartAnim(fishPosition)
	local playerPed = PlayerPedId()
	local playerCoords = GetEntityCoords(playerPed)

	local fishingRodHash = GetHashKey(Config.rod_model)
	Utils.Entity.loadModel(fishingRodHash)

	fishing_rod_object = CreateObject(fishingRodHash, playerCoords.x, playerCoords.y, playerCoords.z, true, false, false)
	AttachEntityToEntity(fishing_rod_object, playerPed, GetPedBoneIndex(playerPed, 18905), 0.1, 0.05, 0, 80.0, 120.0, 160.0, true, true, false, true, 1, true)
	SetModelAsNoLongerNeeded(fishingRodHash)

	if not Config.disable_fishing_line then
		RopeLoadTextures()
		while not RopeAreTexturesLoaded() do
			Wait(0)
			RopeLoadTextures()
		end
		fishing_line_rope = nil
		fishing_line_rope = AddRope(fishPosition.x, fishPosition.y, fishPosition.z, 0.0, 0.0, 0.0, 40.0, 5, 1000.0, 0.0, 1.0, false, false, false, 1.0, true)
		while not DoesRopeExist(fishing_line_rope) do
			Wait(0)
		end
		Wait(50)
		ActivatePhysics(fishing_line_rope)
		Wait(50)
		fish_ped = Utils.Peds.spawnPedAtCoords(Config.fish_model, fishPosition.x, fishPosition.y, fishPosition.z, 0.0, true, false, false)

		local fishingRodPos = GetOffsetFromEntityInWorldCoords(fishing_rod_object, 0.0, 0.01, 2.5)
		AttachEntitiesToRope(fishing_line_rope, fish_ped, fishing_rod_object, fishPosition.x, fishPosition.y, fishPosition.z, fishingRodPos.x, fishingRodPos.y, fishingRodPos.z, 40.0, false, false, nil, nil)
	end

	executeAnim("amb@world_human_stand_fishing@idle_a", "idle_c", 1)
end

function stopAnimAndClearItems()
    RopeUnloadTextures()
    if fishing_line_rope then DeleteRope(fishing_line_rope) end
	if fishing_rod_object then DeleteEntity(fishing_rod_object) end
	if fish_ped then Utils.Peds.deletePed(fish_ped) end
	ClearPedTasks(PlayerPedId())

	fishing_rod_object = nil
	fish_ped = nil
	is_fishing = false
	main_ui_open = false
	Wait(1000)
end