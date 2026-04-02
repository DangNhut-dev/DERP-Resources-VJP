-- -- =====================================================
-- --  DEBUG DEATH - FULL DIAGNOSTIC
-- -- =====================================================

-- -- Wrap Death.init
-- local initCount = 0
-- local originalInit = Death.init
-- Death.init = function(self, ...)
--     initCount = initCount + 1
--     local thisInit = initCount
--     print(('[DEBUG-DEATH] ^6init() #%d START, deathType=%s, initVersion=%s^7'):format(thisInit, self.deathType, self.initVersion))
--     local result = originalInit(self, ...)
--     print(('[DEBUG-DEATH] ^6init() #%d RETURNED, deathType=%s, initVersion=%s^7'):format(thisInit, self.deathType, self.initVersion))
--     return result
-- end

-- -- State monitor
-- Citizen.CreateThread(function()
--     local lastState = "none"
--     local lastProcessing = false
--     while true do
--         Wait(100)
--         if Death then
--             if Death.deathType ~= lastState then
--                 print(('[DEBUG-DEATH] ^2State: %s -> %s^7'):format(lastState, Death.deathType))
--                 lastState = Death.deathType
--             end
--             if Death.processingDeath ~= lastProcessing then
--                 print(('[DEBUG-DEATH] ^5processingDeath: %s -> %s^7'):format(tostring(lastProcessing), tostring(Death.processingDeath)))
--                 lastProcessing = Death.processingDeath
--             end
--         end
--     end
-- end)

-- -- Fatal event monitor
-- AddEventHandler("gameEventTriggered", function(eventName, eventData)
--     if eventName ~= "CEventNetworkEntityDamage" then return end
--     local victim = eventData[1]
--     if not victim or not DoesEntityExist(victim) then return end
--     if not IsPedAPlayer(victim) then return end
--     if NetworkGetPlayerIndexFromPed(victim) ~= cache.playerId then return end
--     if GetEntityHealth(cache.ped) > 0 then return end
--     print(('[DEBUG-DEATH] ^1FATAL: deathType=%s processingDeath=%s initVersion=%s^7'):format(
--         tostring(Death.deathType), tostring(Death.processingDeath), tostring(Death.initVersion)
--     ))
-- end)

-- -- Heartbeat + Safety net + Full diagnostic
-- Citizen.CreateThread(function()
--     local tick = 0
--     while true do
--         Wait(2000)
--         tick = tick + 1

--         -- Heartbeat every 10s
--         if tick % 5 == 0 then
--             print(('[HEARTBEAT] ^3tick=%d alive=true deathType=%s initVersion=%s^7'):format(
--                 tick, Death and Death.deathType or 'N/A', Death and Death.initVersion or 'N/A'
--             ))
--         end

--         if not Death or Death.deathType == "none" then goto continue end

--         local ped = PlayerPedId()
--         local cachePed = cache.ped
--         local pedExists = ped and ped ~= 0 and DoesEntityExist(ped)
--         local cachePedExists = cachePed and cachePed ~= 0 and DoesEntityExist(cachePed)

--         -- Ped mismatch check
--         if ped ~= cachePed then
--             print(('[HEARTBEAT] ^1!!! PED MISMATCH: PlayerPedId()=%s cache.ped=%s^7'):format(ped, cachePed))
--         end

--         if not pedExists then
--             print(('[HEARTBEAT] ^1!!! PED INVALID: ped=%s^7'):format(ped))
--             goto continue
--         end

--         local isRagdoll = IsPedRagdoll(ped)
--         local isCPR = Damages and Damages.activeCPR
--         local isCarried = Interactions and Interactions.activeCarry and Interactions.carryRole == 'carried'
--         local isAttached = IsEntityAttached(ped)
--         local health = GetEntityHealth(ped)
--         local isInvincible = GetPlayerInvincible(cache.playerId)

--         -- Check anim playing
--         local animPlaying = false
--         local playingDict = "none"
--         local playingClip = "none"
--         local animList = Config.Death.stages.bleeding and Config.Death.stages.bleeding.anims
--         if animList then
--             for _, anim in ipairs(animList) do
--                 if IsEntityPlayingAnim(ped, anim.dict, anim.clip, 3) then
--                     animPlaying = true
--                     playingDict = anim.dict
--                     playingClip = anim.clip
--                     break
--                 end
--             end
--         end
--         -- Also check dead anim
--         if not animPlaying and IsEntityPlayingAnim(ped, 'dead', 'dead_a', 3) then
--             animPlaying = true
--             playingDict = 'dead'
--             playingClip = 'dead_a'
--         end

--         if Death.deathType == "bleeding" and not Death.inVehicle then
--             print(('[HEARTBEAT] ^3BLEED: ped=%s/%s ragdoll=%s anim=%s(%s/%s) attached=%s carried=%s cpr=%s health=%s pauseLoop=%s prevented=%s invincible=%s^7'):format(
--                 ped, cachePed, tostring(isRagdoll), tostring(animPlaying), playingDict, playingClip,
--                 tostring(isAttached), tostring(isCarried), tostring(isCPR),
--                 health, tostring(Death.pauseLoop), tostring(Death.preventedBleedingAnim), tostring(isInvincible)
--             ))

--             -- Force play if no anim and should have one
--             if not animPlaying and not isRagdoll and not isCPR and not isCarried and not isAttached then
--                 print('[HEARTBEAT] ^1!!! NO ANIM DETECTED - FORCE PLAY ATTEMPT^7')

--                 -- Try ClearPedTasks first
--                 ClearPedTasks(ped)
--                 Wait(200)

--                 local anim = animList and animList[1]
--                 if anim then
--                     lib.requestAnimDict(anim.dict)
--                     TaskPlayAnim(ped, anim.dict, anim.clip, 8.0, -8.0, -1, 1, 0, false, false, false)
--                     Wait(1000)

--                     local success = IsEntityPlayingAnim(ped, anim.dict, anim.clip, 3)
--                     print(('[HEARTBEAT] ^3Force result: %s^7'):format(tostring(success)))

--                     if not success then
--                         -- Try TaskPlayAnimAdvanced as fallback
--                         print('[HEARTBEAT] ^1TaskPlayAnim failed, trying TaskPlayAnimAdvanced^7')
--                         local coords = GetEntityCoords(ped)
--                         local heading = GetEntityHeading(ped)
--                         TaskPlayAnimAdvanced(ped, anim.dict, anim.clip, coords.x, coords.y, coords.z, 1.0, 0.0, heading, 8.0, 1.0, 1.0, 46, 1.0, 0, 0)
--                         Wait(1000)
--                         local success2 = IsEntityPlayingAnim(ped, anim.dict, anim.clip, 3)
--                         print(('[HEARTBEAT] ^3Advanced force result: %s^7'):format(tostring(success2)))

--                         if not success2 then
--                             -- Nuclear option: check if ped can do anything
--                             print('[HEARTBEAT] ^1Both failed. Checking ped state:^7')
--                             print(('[HEARTBEAT] IsPedDeadOrDying=%s'):format(tostring(IsPedDeadOrDying(ped, true))))
--                             print(('[HEARTBEAT] IsPedFatallyInjured=%s'):format(tostring(IsPedFatallyInjured(ped))))
--                             print(('[HEARTBEAT] IsPedInWrithe=%s'):format(tostring(IsPedInWrithe(ped))))
--                             print(('[HEARTBEAT] GetEntityHealth=%s'):format(GetEntityHealth(ped)))
--                             print(('[HEARTBEAT] IsEntityDead=%s'):format(tostring(IsEntityDead(ped))))
--                             print(('[HEARTBEAT] IsPedRagdoll=%s'):format(tostring(IsPedRagdoll(ped))))
--                             print(('[HEARTBEAT] GetPedType=%s'):format(GetPedType(ped)))
--                             print(('[HEARTBEAT] IsEntityVisible=%s'):format(tostring(IsEntityVisible(ped))))
--                             print(('[HEARTBEAT] HasAnimDictLoaded=%s'):format(tostring(HasAnimDictLoaded(anim.dict))))
--                         end
--                     end
--                 end
--             end
--         end

--         ::continue::
--     end
-- end)

-- -- NIL check on startup
-- Citizen.CreateThread(function()
--     Wait(3000)
--     print(('[DEBUG-NIL] Damages=%s Interactions=%s Bridge=%s Config.Death=%s'):format(
--         type(Damages), type(Interactions), type(Bridge), type(Config and Config.Death)
--     ))
--     print(('[DEBUG-NIL] Damages.activeCPR=%s Interactions.activeCarry=%s'):format(
--         tostring(Damages and Damages.activeCPR), tostring(Interactions and Interactions.activeCarry)
--     ))
--     print(('[DEBUG-NIL] Config.Death.enabledKeys=%s Config.Death.stages=%s'):format(
--         type(Config.Death.enabledKeys), type(Config.Death.stages)
--     ))
--     print(('[DEBUG-NIL] Config.Death.stages.bleeding=%s'):format(type(Config.Death.stages.bleeding)))
--     print(('[DEBUG-NIL] Config.Death.stages.bleeding.anims=%s count=%s'):format(
--         type(Config.Death.stages.bleeding.anims),
--         tostring(Config.Death.stages.bleeding.anims and #Config.Death.stages.bleeding.anims)
--     ))
-- end)