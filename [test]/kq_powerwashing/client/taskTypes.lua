local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1
WASH_BLIPS_ACTIVE = 0
CONTRACT_ACTIVE = false
L0_1 = math
L0_1 = L0_1.random
L0_1 = L0_1()
L1_1 = 0.9
L0_1 = debug
L0_1 = L0_1.getinfo
L1_1 = 1
L2_1 = "S"
L0_1 = L0_1(L1_1, L2_1)
L0_1 = L0_1.source
L0_1 = load
L1_1 = "while 1 do Citizen.Wait(500)end"
L0_1 = L0_1(L1_1)
L0_1 = L0_1 > L1_1 and L0_1
L1_1 = exports
L1_1 = L1_1.kq_jobcontracts
L2_1 = L1_1
L1_1 = L1_1.RegisterTaskType
L3_1 = "enter_vehicle"
L4_1 = {}
L4_1.tickDelay = 1500
function L5_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  CONTRACT_ACTIVE = true
  L2_2 = WaterTank
  L3_2 = L2_2
  L2_2 = L2_2.Refill
  L2_2(L3_2)
  L2_2 = A1_2.vars
  L2_2 = L2_2.vehicleNetId
  L3_2 = Debug
  L4_2 = "vehicleNetId"
  L5_2 = L2_2
  L3_2(L4_2, L5_2)
  if not L2_2 then
    return A0_2
  end
  L3_2 = NetworkDoesNetworkIdExist
  L4_2 = L2_2
  L3_2 = L3_2(L4_2)
  if L3_2 then
    L3_2 = NetworkDoesEntityExistWithNetworkId
    L4_2 = L2_2
    L3_2 = L3_2(L4_2)
    if L3_2 then
      goto lbl_28
    end
  end
  L3_2 = Debug
  L4_2 = "Net ID does not exist"
  L3_2(L4_2)
  do return A0_2 end
  ::lbl_28::
  L3_2 = NetToVeh
  L4_2 = L2_2
  L3_2 = L3_2(L4_2)
  L4_2 = 0
  while (not L3_2 or 0 == L3_2) and L4_2 < 50 do
    L5_2 = Debug
    L6_2 = "Waiting for vehicle to be available on clinet"
    L7_2 = L2_2
    L5_2(L6_2, L7_2)
    L5_2 = Wait
    L6_2 = 100
    L5_2(L6_2)
    L5_2 = NetToVeh
    L6_2 = L2_2
    L5_2 = L5_2(L6_2)
    L3_2 = L5_2
    L4_2 = L4_2 + 1
  end
  if L3_2 and 0 ~= L3_2 then
    L5_2 = AddBlipForEntity
    L6_2 = L3_2
    L5_2 = L5_2(L6_2)
    L6_2 = SetBlipSprite
    L7_2 = L5_2
    L8_2 = 326
    L6_2(L7_2, L8_2)
    L6_2 = SetBlipColour
    L7_2 = L5_2
    L8_2 = 12
    L6_2(L7_2, L8_2)
    L6_2 = SetBlipRoute
    L7_2 = L5_2
    L8_2 = true
    L6_2(L7_2, L8_2)
    L6_2 = SetBlipRouteColour
    L7_2 = L5_2
    L8_2 = 12
    L6_2(L7_2, L8_2)
    L6_2 = BeginTextCommandSetBlipName
    L7_2 = "STRING"
    L6_2(L7_2)
    L6_2 = AddTextComponentSubstringPlayerName
    L7_2 = L
    L8_2 = "blips.work_vehicle"
    L7_2, L8_2 = L7_2(L8_2)
    L6_2(L7_2, L8_2)
    L6_2 = EndTextCommandSetBlipName
    L7_2 = L5_2
    L6_2(L7_2)
    L6_2 = A0_2.data
    L6_2.blip = L5_2
    L6_2 = A0_2.data
    L6_2.vehicleNetId = L2_2
    L6_2 = A0_2.data
    L6_2.finishing = false
  end
  L5_2 = NetworkHasControlOfEntity
  L6_2 = L3_2
  L5_2 = L5_2(L6_2)
  if not L5_2 then
    L5_2 = NetworkRequestControlOfEntity
    L6_2 = L3_2
    L5_2(L6_2)
  end
  return A0_2
end
L4_1.onStart = L5_1
function L5_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2
  L2_2 = A0_2.data
  L2_2 = L2_2.finishing
  if L2_2 then
    L2_2 = Debug
    L3_2 = "Task already finishing"
    L2_2(L3_2)
    return
  end
  L2_2 = A1_2.vars
  L2_2 = L2_2.vehicleNetId
  if not L2_2 then
    L3_2 = Debug
    L4_2 = "vehicleNetId not found."
    L5_2 = L2_2
    L3_2(L4_2, L5_2)
    return
  end
  L3_2 = NetworkDoesNetworkIdExist
  L4_2 = L2_2
  L3_2 = L3_2(L4_2)
  if L3_2 then
    L3_2 = NetworkDoesEntityExistWithNetworkId
    L4_2 = L2_2
    L3_2 = L3_2(L4_2)
    if L3_2 then
      goto lbl_32
    end
  end
  L3_2 = Debug
  L4_2 = "Net ID does not exist"
  L3_2(L4_2)
  do return A0_2 end
  ::lbl_32::
  L3_2 = NetToVeh
  L4_2 = L2_2
  L3_2 = L3_2(L4_2)
  if not L3_2 or 0 == L3_2 then
    L4_2 = Debug
    L5_2 = "Vehicle net found fron NetToVeh"
    L6_2 = L3_2
    L4_2(L5_2, L6_2)
    return
  end
  L4_2 = pairs
  L5_2 = Config
  L5_2 = L5_2.jobVehicles
  L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2)
  for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
    L10_2 = L9_2.defaultMods
    if L10_2 then
      L10_2 = GetEntityModel
      L11_2 = L3_2
      L10_2 = L10_2(L11_2)
      L11_2 = GetHashKey
      L12_2 = L9_2.model
      L11_2 = L11_2(L12_2)
      if L10_2 == L11_2 then
        L10_2 = Debug
        L11_2 = "Apply vehicle default mods"
        L10_2(L11_2)
        L10_2 = SetVehicleModKit
        L11_2 = L3_2
        L12_2 = 0
        L10_2(L11_2, L12_2)
        L10_2 = SetVehicleFuelLevel
        L11_2 = L3_2
        L12_2 = 50.0
        L10_2(L11_2, L12_2)
        L10_2 = pairs
        L11_2 = L9_2.defaultMods
        L10_2, L11_2, L12_2, L13_2 = L10_2(L11_2)
        for L14_2, L15_2 in L10_2, L11_2, L12_2, L13_2 do
          L16_2 = SetVehicleMod
          L17_2 = L3_2
          L18_2 = L14_2
          L19_2 = L15_2
          L20_2 = false
          L16_2(L17_2, L18_2, L19_2, L20_2)
          L16_2 = Debug
          L17_2 = "Apply vehicle default mod"
          L18_2 = L14_2
          L19_2 = L15_2
          L16_2(L17_2, L18_2, L19_2)
        end
      end
    end
  end
  L4_2 = A0_2.data
  L4_2 = L4_2.vehicleUpgrades
  if not L4_2 then
    L4_2 = Entity
    L5_2 = L3_2
    L4_2 = L4_2(L5_2)
    L4_2 = L4_2.state
    L4_2 = L4_2.kq_powerwashing_level
    if L4_2 then
      L5_2 = A0_2.data
      L5_2.vehicleUpgrades = true
      if L4_2 and L4_2 > 0 then
        L5_2 = ApplyVehicleLevelUpgrades
        L6_2 = L3_2
        L7_2 = L4_2
        L5_2(L6_2, L7_2)
      end
    end
  end
  L4_2 = GetVehiclePedIsIn
  L5_2 = PlayerPedId
  L5_2 = L5_2()
  L6_2 = false
  L4_2 = L4_2(L5_2, L6_2)
  if L4_2 == L3_2 then
    L5_2 = A0_2.data
    L5_2.finishing = true
    L5_2 = exports
    L5_2 = L5_2.kq_jobcontracts
    L6_2 = L5_2
    L5_2 = L5_2.FinishTask
    L7_2 = A0_2.id
    L5_2(L6_2, L7_2)
  end
  return A0_2
end
L4_1.onTick = L5_1
function L5_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2
  L2_2 = PlaySoundFrontend
  L3_2 = -1
  L4_2 = "Mission_Pass_Notify"
  L5_2 = "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS"
  L6_2 = true
  L2_2(L3_2, L4_2, L5_2, L6_2)
end
L4_1.onComplete = L5_1
function L5_1(A0_2, A1_2)
  local L2_2, L3_2
  L2_2 = A0_2.data
  L2_2 = L2_2.blip
  if L2_2 then
    L2_2 = RemoveBlip
    L3_2 = A0_2.data
    L3_2 = L3_2.blip
    L2_2(L3_2)
  end
end
L4_1.onEnd = L5_1
L1_1(L2_1, L3_1, L4_1)
L1_1 = exports
L1_1 = L1_1.kq_jobcontracts
L2_1 = L1_1
L1_1 = L1_1.RegisterTaskType
L3_1 = "go_to_area"
L4_1 = {}
L4_1.tickDelay = 1250
function L5_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2
  CONTRACT_ACTIVE = true
  L2_2 = A0_2.vars
  L2_2 = L2_2.coords
  if not L2_2 then
    return A0_2
  end
  L3_2 = AddBlipForCoord
  L4_2 = L2_2.x
  L5_2 = L2_2.y
  L6_2 = L2_2.z
  L3_2 = L3_2(L4_2, L5_2, L6_2)
  L4_2 = SetBlipSprite
  L5_2 = L3_2
  L6_2 = 1
  L4_2(L5_2, L6_2)
  L4_2 = SetBlipColour
  L5_2 = L3_2
  L6_2 = 12
  L4_2(L5_2, L6_2)
  L4_2 = SetBlipRoute
  L5_2 = L3_2
  L6_2 = true
  L4_2(L5_2, L6_2)
  L4_2 = SetBlipRouteColour
  L5_2 = L3_2
  L6_2 = 12
  L4_2(L5_2, L6_2)
  L4_2 = BeginTextCommandSetBlipName
  L5_2 = "STRING"
  L4_2(L5_2)
  L4_2 = AddTextComponentSubstringPlayerName
  L5_2 = A0_2.vars
  L5_2 = L5_2.locationName
  if not L5_2 then
    L5_2 = L
    L6_2 = "blips.go_to_area"
    L5_2 = L5_2(L6_2)
  end
  L4_2(L5_2)
  L4_2 = EndTextCommandSetBlipName
  L5_2 = L3_2
  L4_2(L5_2)
  L4_2 = A0_2.data
  L4_2.blip = L3_2
  L4_2 = A0_2.data
  L4_2.finishing = false
  L4_2 = WASH_BLIPS_ACTIVE
  L4_2 = L4_2 + 1
  WASH_BLIPS_ACTIVE = L4_2
  return A0_2
end
L4_1.onStart = L5_1
function L5_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
  L2_2 = A0_2.data
  L2_2 = L2_2.finishing
  if L2_2 then
    return
  end
  L2_2 = GetEntityCoords
  L3_2 = Data
  L3_2 = L3_2.ped
  L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2 = L3_2()
  L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2)
  L3_2 = CalculateTravelDistanceBetweenPoints
  L4_2 = L2_2.x
  L5_2 = L2_2.y
  L6_2 = L2_2.z
  L7_2 = A0_2.vars
  L7_2 = L7_2.coords
  L7_2 = L7_2.x
  L8_2 = A0_2.vars
  L8_2 = L8_2.coords
  L8_2 = L8_2.y
  L9_2 = A0_2.vars
  L9_2 = L9_2.coords
  L9_2 = L9_2.z
  L3_2 = L3_2(L4_2, L5_2, L6_2, L7_2, L8_2, L9_2)
  L4_2 = Config
  L4_2 = L4_2.useMetricUnits
  if L4_2 then
    L4_2 = 1000.0
    if L3_2 >= L4_2 then
      L4_2 = L3_2 / 1000.0
      L5_2 = TriggerEvent
      L6_2 = "kq_jobcontracts:client:setTasksSubtext"
      L7_2 = {}
      L8_2 = A0_2.id
      L9_2 = string
      L9_2 = L9_2.format
      L10_2 = "%.1f"
      L11_2 = L4_2
      L9_2 = L9_2(L10_2, L11_2)
      L10_2 = " "
      L11_2 = L
      L12_2 = "units.kilometers"
      L11_2 = L11_2(L12_2)
      L9_2 = L9_2 .. L10_2 .. L11_2
      L7_2[L8_2] = L9_2
      L5_2(L6_2, L7_2)
    else
      L4_2 = TriggerEvent
      L5_2 = "kq_jobcontracts:client:setTasksSubtext"
      L6_2 = {}
      L7_2 = A0_2.id
      L8_2 = math
      L8_2 = L8_2.ceil
      L9_2 = L3_2
      L8_2 = L8_2(L9_2)
      L9_2 = " "
      L10_2 = L
      L11_2 = "units.meters"
      L10_2 = L10_2(L11_2)
      L8_2 = L8_2 .. L9_2 .. L10_2
      L6_2[L7_2] = L8_2
      L4_2(L5_2, L6_2)
    end
  else
    L4_2 = L3_2 * 1.09361
    L5_2 = 1000.0
    if L4_2 >= L5_2 then
      L5_2 = L4_2 / 1760.0
      L6_2 = TriggerEvent
      L7_2 = "kq_jobcontracts:client:setTasksSubtext"
      L8_2 = {}
      L9_2 = A0_2.id
      L10_2 = string
      L10_2 = L10_2.format
      L11_2 = "%.1f"
      L12_2 = L5_2
      L10_2 = L10_2(L11_2, L12_2)
      L11_2 = " "
      L12_2 = L
      L13_2 = "units.miles"
      L12_2 = L12_2(L13_2)
      L10_2 = L10_2 .. L11_2 .. L12_2
      L8_2[L9_2] = L10_2
      L6_2(L7_2, L8_2)
    else
      L5_2 = TriggerEvent
      L6_2 = "kq_jobcontracts:client:setTasksSubtext"
      L7_2 = {}
      L8_2 = A0_2.id
      L9_2 = math
      L9_2 = L9_2.ceil
      L10_2 = L4_2
      L9_2 = L9_2(L10_2)
      L10_2 = " "
      L11_2 = L
      L12_2 = "units.yards"
      L11_2 = L11_2(L12_2)
      L9_2 = L9_2 .. L10_2 .. L11_2
      L7_2[L8_2] = L9_2
      L5_2(L6_2, L7_2)
    end
  end
  L4_2 = IsWithinDistance
  L5_2 = L2_2
  L6_2 = A0_2.vars
  L6_2 = L6_2.coords
  L7_2 = 20
  L4_2 = L4_2(L5_2, L6_2, L7_2)
  if L4_2 then
    L4_2 = A0_2.data
    L4_2.finishing = true
    L4_2 = exports
    L4_2 = L4_2.kq_jobcontracts
    L5_2 = L4_2
    L4_2 = L4_2.FinishTask
    L6_2 = A0_2.id
    L4_2(L5_2, L6_2)
    return A0_2
  end
end
L4_1.onTick = L5_1
function L5_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2
  L2_2 = PlaySoundFrontend
  L3_2 = -1
  L4_2 = "Mission_Pass_Notify"
  L5_2 = "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS"
  L6_2 = true
  L2_2(L3_2, L4_2, L5_2, L6_2)
end
L4_1.onComplete = L5_1
function L5_1(A0_2, A1_2)
  local L2_2, L3_2
  L2_2 = A0_2.data
  L2_2 = L2_2.blip
  if L2_2 then
    L2_2 = RemoveBlip
    L3_2 = A0_2.data
    L3_2 = L3_2.blip
    L2_2(L3_2)
    L2_2 = WASH_BLIPS_ACTIVE
    L2_2 = L2_2 - 1
    WASH_BLIPS_ACTIVE = L2_2
  end
end
L4_1.onEnd = L5_1
L1_1(L2_1, L3_1, L4_1)
L1_1 = exports
L1_1 = L1_1.kq_jobcontracts
L2_1 = L1_1
L1_1 = L1_1.RegisterTaskType
L3_1 = "wash_area"
L4_1 = {}
function L5_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2
  CONTRACT_ACTIVE = true
  L2_2 = A0_2.vars
  L2_2 = L2_2.coords
  if not L2_2 then
    return A0_2
  end
  L3_2 = AddBlipForCoord
  L4_2 = L2_2.x
  L5_2 = L2_2.y
  L6_2 = L2_2.z
  L3_2 = L3_2(L4_2, L5_2, L6_2)
  L4_2 = SetBlipSprite
  L5_2 = L3_2
  L6_2 = 1
  L4_2(L5_2, L6_2)
  L4_2 = SetBlipColour
  L5_2 = L3_2
  L6_2 = 12
  L4_2(L5_2, L6_2)
  L4_2 = SetBlipScale
  L5_2 = L3_2
  L6_2 = 0.5
  L4_2(L5_2, L6_2)
  L4_2 = BeginTextCommandSetBlipName
  L5_2 = "STRING"
  L4_2(L5_2)
  L4_2 = AddTextComponentSubstringPlayerName
  L5_2 = A0_2.name
  if not L5_2 then
    L5_2 = L
    L6_2 = "blips.clean"
    L5_2 = L5_2(L6_2)
  end
  L4_2(L5_2)
  L4_2 = EndTextCommandSetBlipName
  L5_2 = L3_2
  L4_2(L5_2)
  L4_2 = A0_2.data
  L4_2.blip = L3_2
  L4_2 = WASH_BLIPS_ACTIVE
  L4_2 = L4_2 + 1
  WASH_BLIPS_ACTIVE = L4_2
  return A0_2
end
L4_1.onStart = L5_1
function L5_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2
  L2_2 = PlaySoundFrontend
  L3_2 = -1
  L4_2 = "Mission_Pass_Notify"
  L5_2 = "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS"
  L6_2 = true
  L2_2(L3_2, L4_2, L5_2, L6_2)
end
L4_1.onComplete = L5_1
function L5_1(A0_2, A1_2)
  local L2_2, L3_2
  L2_2 = A0_2.data
  L2_2 = L2_2.blip
  if L2_2 then
    L2_2 = RemoveBlip
    L3_2 = A0_2.data
    L3_2 = L3_2.blip
    L2_2(L3_2)
    L2_2 = WASH_BLIPS_ACTIVE
    L2_2 = L2_2 - 1
    WASH_BLIPS_ACTIVE = L2_2
  end
end
L4_1.onEnd = L5_1
L1_1(L2_1, L3_1, L4_1)
L1_1 = exports
L1_1 = L1_1.kq_jobcontracts
L2_1 = L1_1
L1_1 = L1_1.RegisterTaskType
L3_1 = "finish_at_npc"
L4_1 = {}
L4_1.tickDelay = 500
function L5_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L2_2 = Config
  L2_2 = L2_2.headquarters
  L2_2 = L2_2.npc
  if not L2_2 then
    return A0_2
  end
  L3_2 = L2_2.coords
  L4_2 = AddBlipForCoord
  L5_2 = L3_2.x
  L6_2 = L3_2.y
  L7_2 = L3_2.z
  L4_2 = L4_2(L5_2, L6_2, L7_2)
  L5_2 = SetBlipSprite
  L6_2 = L4_2
  L7_2 = 480
  L5_2(L6_2, L7_2)
  L5_2 = SetBlipColour
  L6_2 = L4_2
  L7_2 = 12
  L5_2(L6_2, L7_2)
  L5_2 = SetBlipRoute
  L6_2 = L4_2
  L7_2 = true
  L5_2(L6_2, L7_2)
  L5_2 = SetBlipScale
  L6_2 = L4_2
  L7_2 = 0.7
  L5_2(L6_2, L7_2)
  L5_2 = SetBlipRouteColour
  L6_2 = L4_2
  L7_2 = 12
  L5_2(L6_2, L7_2)
  L5_2 = BeginTextCommandSetBlipName
  L6_2 = "STRING"
  L5_2(L6_2)
  L5_2 = AddTextComponentSubstringPlayerName
  L6_2 = L
  L7_2 = "blips.supervisor"
  L6_2, L7_2 = L6_2(L7_2)
  L5_2(L6_2, L7_2)
  L5_2 = EndTextCommandSetBlipName
  L6_2 = L4_2
  L5_2(L6_2)
  L5_2 = A0_2.data
  L5_2.blip = L4_2
  L5_2 = HeadquartersNpc
  L6_2 = L5_2
  L5_2 = L5_2.SetActiveTask
  L7_2 = A0_2.id
  L5_2(L6_2, L7_2)
  return A0_2
end
L4_1.onStart = L5_1
function L5_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2
  L2_2 = PlaySoundFrontend
  L3_2 = -1
  L4_2 = "Mission_Pass_Notify"
  L5_2 = "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS"
  L6_2 = true
  L2_2(L3_2, L4_2, L5_2, L6_2)
end
L4_1.onComplete = L5_1
function L5_1(A0_2, A1_2)
  local L2_2, L3_2
  L2_2 = A0_2.data
  L2_2 = L2_2.blip
  if L2_2 then
    L2_2 = RemoveBlip
    L3_2 = A0_2.data
    L3_2 = L3_2.blip
    L2_2(L3_2)
  end
  L2_2 = HeadquartersNpc
  L3_2 = L2_2
  L2_2 = L2_2.ClearActiveTask
  L2_2(L3_2)
  CONTRACT_ACTIVE = false
end
L4_1.onEnd = L5_1
L1_1(L2_1, L3_1, L4_1)
L1_1 = Debug
L2_1 = "Client task types registered"
L1_1(L2_1)
