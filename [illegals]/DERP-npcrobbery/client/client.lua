local isRobbing       = false
local robbingNPC      = nil
local robbingCam      = nil
local zonesdone       = {}
local targetZones     = {}
local currentNPC      = nil
local weaponCheckThread = nil

local function isWeaponWhitelisted()
    local weapon = GetSelectedPedWeapon(cache.ped)
    return Config.WhitelistedWeapons[weapon] == true
end

local function cleanupRob()
    isRobbing   = false
    robbingNPC  = nil
    zonesdone   = {}

    if robbingCam and DoesCamExist(robbingCam) then
        SetCamActive(robbingCam, false)
        RenderScriptCams(false, true, 500, true, false)
        DestroyCam(robbingCam, false)
        robbingCam = nil
    end

    SendNUIMessage({ action = 'hide' })
    SetNuiFocus(false, false)

    if DoesEntityExist(currentNPC) then
        SetBlockingOfNonTemporaryEvents(currentNPC, false)
        SetPedFleeAttributes(currentNPC, 2, true)
        TaskSmartFleePed(currentNPC, cache.ped, 100.0, -1, false, false)
    end
    currentNPC = nil
end

local function zoomCamToNPC(npc)
    local npcCoords = GetEntityCoords(npc)
    local heading   = GetEntityHeading(npc)
    local rad       = math.rad(heading)
    local dist = 2.0
    local sideRad = math.rad(heading - 90)
    local camX = npcCoords.x - dist * math.sin(rad) + 0.8 * math.sin(sideRad)
    local camY = npcCoords.y + dist * math.cos(rad) - 0.8 * math.cos(sideRad)
    local camZ = npcCoords.z + 0.65

    robbingCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(robbingCam, camX, camY, camZ)
    PointCamAtCoord(robbingCam, npcCoords.x, npcCoords.y, npcCoords.z + 0.55)
    SetCamFov(robbingCam, 55.0)
    SetCamActive(robbingCam, true)
    RenderScriptCams(true, true, 700, true, false)
end

local function tryNpcResist(npc, chance)
    if math.random(100) <= chance then
        if DoesEntityExist(npc) then
            GiveWeaponToPed(npc, `weapon_pistol`, 60, false, true)
            SetPedDropsWeaponsWhenDead(npc, false)
            SetBlockingOfNonTemporaryEvents(npc, false)
            TaskCombatPed(npc, cache.ped, 0, 16)
            return true
        end
    end
    return false
end

local function startZoneRob(zoneId)
    if not isRobbing or not DoesEntityExist(currentNPC) then return end
    if zonesdone[zoneId] then
        lib.notify({ title = 'Cướp', description = 'Vị trí này đã lục rồi.', type = 'error' })
        return
    end

    local success = lib.progressBar({
        duration     = Config.ProgressDuration,
        label        = 'Đang lục ' .. Config.Zones[zoneId].label .. '...',
        useWhileDead = false,
        canCancel    = true,
        disable      = { move = true, car = true, combat = true },
        anim         = { dict = 'random@shop_robbery', clip = 'robbery_action_b', flags = 16 },
    })

    if not isRobbing then return end

    if success then
        zonesdone[zoneId] = true
        TriggerServerEvent('derp_npcrobbery:server:robZone', zoneId)
        SendNUIMessage({ action = 'zoneComplete', id = zoneId })

        local allDone = true
        for i = 1, #Config.Zones do
            if not zonesdone[i] then allDone = false break end
        end

        if allDone then
            lib.notify({ title = 'Cướp', description = 'Cướp xong! Rời đi nhanh.', type = 'success' })
            cleanupRob()
        end
    else
        tryNpcResist(currentNPC, Config.NpcResistOnFail)
        lib.notify({ title = 'Cướp', description = 'Bị gián đoạn!', type = 'error' })
    end
end

local function startRobNPC(npc)
    if isRobbing then return end
    if not isWeaponWhitelisted() then
        lib.notify({ title = 'Cướp', description = 'Bạn cần cầm vũ khí phù hợp.', type = 'error' })
        return
    end

    lib.callback('derp_npcrobbery:server:checkCooldown', false, function(ok)
        if not ok then
            lib.notify({ title = 'Cướp', description = 'Bạn cần đợi mọi chuyện lắng xuống trước khi cướp tiếp.', type = 'error' })
            return
        end

        isRobbing  = true
        currentNPC = npc
        zonesdone  = {}

        SetBlockingOfNonTemporaryEvents(npc, true)
        SetPedFleeAttributes(npc, 0, false)
        SetPedCombatAttributes(npc, 46, true)

        lib.requestAnimDict('random@mugging3')
        TaskPlayAnim(npc, 'random@mugging3', 'handsup_standing_base', 8.0, -8.0, -1, 1, 0, false, false, false)

        CreateThread(function()
            while isRobbing and DoesEntityExist(npc) do
                if not IsEntityPlayingAnim(npc, 'random@mugging3', 'handsup_standing_base', 3) then
                    TaskPlayAnim(npc, 'random@mugging3', 'handsup_standing_base', 8.0, -8.0, -1, 1, 0, false, false, false)
                end
                Wait(1000)
            end
        end)

        lib.requestAnimDict('random@shop_robbery')
        TaskPlayAnim(cache.ped, 'random@shop_robbery', 'robbery_action_a', 3.0, 1.0, 2000, 49, 0, false, false, false)
        Wait(1500)
        ClearPedTasks(cache.ped)

        local resisted = tryNpcResist(npc, Config.NpcResistChance)

        if resisted then
            lib.notify({ title = 'Cướp', description = 'Cướp không thành!', type = 'error' })
            cleanupRob()
            return
        end

        zoomCamToNPC(npc)

        local coords = GetEntityCoords(npc)
        local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
        local streetLabel = GetStreetNameFromHashKey(streetHash)
        TriggerServerEvent('derp_npcrobbery:server:dispatch', { x = coords.x, y = coords.y, z = coords.z }, streetLabel)

        local zonesData = {}
        for _, z in ipairs(Config.Zones) do
            table.insert(zonesData, { id = z.id, label = z.label, color = z.color })
        end
        SendNUIMessage({ action = 'show', zones = zonesData })
        SetNuiFocus(true, true)
        CreateThread(function()
            while isRobbing and currentNPC and DoesEntityExist(currentNPC) do
                local positions = {}
                for _, z in ipairs(Config.Zones) do
                    local offsets = { [1] = 0.0, [2] = 0.0, [3] = 0.0 }
                    local off  = z.offset or vec3(0.0, 0.0, 0.0)
                    local bone = GetPedBoneCoords(currentNPC, z.bone, off.x, off.y, off.z)
                    local onScreen, sx, sy = World3dToScreen2d(bone.x, bone.y, bone.z)
                    table.insert(positions, {
                        id      = z.id,
                        x       = sx,
                        y       = sy,
                        visible = onScreen,
                        done    = zonesdone[z.id] or false,
                    })
                end
                SendNUIMessage({ action = 'updatePositions', zones = positions })
                Wait(0)
            end
        end)
    end)
end

-- Watch weapon + add/remove target
CreateThread(function()
    local hasTarget   = false
    local targetedPed = nil

    while true do
        Wait(500)

        if not isRobbing then
            local armed = isWeaponWhitelisted()

            if armed then
                local coords = GetEntityCoords(cache.ped)
                local ped = lib.getClosestPed(coords, 5.0, true)
                local dist = ped and #(coords - GetEntityCoords(ped)) or 999

                local popType = GetEntityPopulationType(ped)
                if ped and dist < 5.0 and not IsPedAPlayer(ped) and IsPedHuman(ped) and popType >= 1 and popType <= 5 then
                    if targetedPed ~= ped then
                        if targetedPed then
                            exports.ox_target:removeLocalEntity(targetedPed, 'derp_rob_npc')
                        end
                        targetedPed = ped
                        exports.ox_target:addLocalEntity(ped, {
                            {
                                name     = 'derp_rob_npc',
                                icon     = 'fas fa-hand-holding-usd',
                                label    = 'Cướp',
                                distance = 2.5,
                                onSelect = function()
                                    startRobNPC(ped)
                                end,
                            }
                        })
                        hasTarget = true
                    end
                else
                    if targetedPed then
                        exports.ox_target:removeLocalEntity(targetedPed, 'derp_rob_npc')
                        targetedPed = nil
                        hasTarget   = false
                    end
                end
            else
                if targetedPed then
                    exports.ox_target:removeLocalEntity(targetedPed, 'derp_rob_npc')
                    targetedPed = nil
                    hasTarget   = false
                end
            end
        end
    end
end)

RegisterNUICallback('zoneClick', function(data, cb)
    local zoneId = tonumber(data.id)
    cb('ok')
    if zoneId then
        SetNuiFocus(false, false)
        CreateThread(function()
            startZoneRob(zoneId)
            if isRobbing then
                SetNuiFocus(true, true)
            end
        end)
    end
end)

RegisterNUICallback('closeUI', function(_, cb)
    cleanupRob()
    cb('ok')
end)
