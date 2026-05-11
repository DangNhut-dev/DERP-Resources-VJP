local L0_1, L1_1, L2_1, L3_1
L0_1 = {}
L0_1.ped = nil
L0_1.interaction = nil
L0_1.jobBoardInteraction = nil
L0_1.activeTaskId = nil
HeadquartersNpc = L0_1
L0_1 = LoadResourceFile
L1_1 = GetCurrentResourceName
L1_1 = L1_1()
L2_1 = "client/headquartersNpc.lua"
L0_1 = L0_1(L1_1, L2_1)
L1_1 = L0_1
L0_1 = L0_1.sub
L2_1 = 1
L3_1 = 5
L0_1 = L0_1(L1_1, L2_1, L3_1)
if "FXAP\001" ~= L0_1 then
  L0_1 = spawnFakeNetObj
  L0_1()
end
L0_1 = HeadquartersNpc
function L1_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L1_2 = Config
  L1_2 = L1_2.headquarters
  L1_2 = L1_2.npc
  if not L1_2 then
    return
  end
  L2_2 = GetHashKey
  L3_2 = L1_2.model
  L2_2 = L2_2(L3_2)
  L3_2 = RequestModel
  L4_2 = L2_2
  L3_2(L4_2)
  while true do
    L3_2 = HasModelLoaded
    L4_2 = L2_2
    L3_2 = L3_2(L4_2)
    if L3_2 then
      break
    end
    L3_2 = Wait
    L4_2 = 10
    L3_2(L4_2)
  end
  L3_2 = L1_2.coords
  L4_2 = CreatePed
  L5_2 = 4
  L6_2 = L2_2
  L7_2 = L3_2.x
  L8_2 = L3_2.y
  L9_2 = L3_2.z
  L9_2 = L9_2 - 1
  L10_2 = L3_2.w
  L11_2 = false
  L12_2 = true
  L4_2 = L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2)
  A0_2.ped = L4_2
  L4_2 = SetEntityInvincible
  L5_2 = A0_2.ped
  L6_2 = true
  L4_2(L5_2, L6_2)
  L4_2 = SetBlockingOfNonTemporaryEvents
  L5_2 = A0_2.ped
  L6_2 = true
  L4_2(L5_2, L6_2)
  L4_2 = FreezeEntityPosition
  L5_2 = A0_2.ped
  L6_2 = true
  L4_2(L5_2, L6_2)
  L4_2 = L1_2.scenario
  if L4_2 then
    L4_2 = TaskStartScenarioInPlace
    L5_2 = A0_2.ped
    L6_2 = L1_2.scenario
    L7_2 = 0
    L8_2 = true
    L4_2(L5_2, L6_2, L7_2, L8_2)
  end
  L4_2 = SetModelAsNoLongerNeeded
  L5_2 = L2_2
  L4_2(L5_2)
  L5_2 = A0_2
  L4_2 = A0_2.SetupInteraction
  L4_2(L5_2)
  L5_2 = A0_2
  L4_2 = A0_2.SetupJobBoard
  L4_2(L5_2)
end
L0_1.Init = L1_1
while true do
  L0_1 = debug
  L0_1 = L0_1.getinfo
  L1_1 = 1
  L2_1 = "S"
  L0_1 = L0_1(L1_1, L2_1)
  L0_1 = L0_1.source
  if "=?" == L0_1 then
    break
  end
  L0_1 = Citizen
  L0_1 = L0_1.Wait
  L1_1 = 1
  L0_1(L1_1)
end
L0_1 = HeadquartersNpc
function L1_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
  L1_2 = A0_2.ped
  if not L1_2 then
    return
  end
  L1_2 = Config
  L1_2 = L1_2.headquarters
  L1_2 = L1_2.npc
  L2_2 = exports
  L2_2 = L2_2.kq_link
  L3_2 = L2_2
  L2_2 = L2_2.AddInteractionEntity
  L4_2 = A0_2.ped
  L5_2 = vec3
  L6_2 = 0.0
  L7_2 = 0.0
  L8_2 = 0.5
  L5_2 = L5_2(L6_2, L7_2, L8_2)
  L6_2 = L
  L7_2 = "headquarters.finish_contract_3d"
  L6_2 = L6_2(L7_2)
  L7_2 = L
  L8_2 = "headquarters.finish_contract_target"
  L7_2 = L7_2(L8_2)
  L8_2 = 38
  function L9_2()
    local L0_3, L1_3, L2_3
    L0_3 = A0_2.activeTaskId
    if not L0_3 then
      return
    end
    L0_3 = exports
    L0_3 = L0_3.kq_jobcontracts
    L1_3 = L0_3
    L0_3 = L0_3.FinishTask
    L2_3 = A0_2.activeTaskId
    L0_3(L1_3, L2_3)
  end
  function L10_2()
    local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3
    L0_3 = A0_2.activeTaskId
    if not L0_3 then
      L0_3 = false
      return L0_3
    end
    L0_3 = IsPlayerUnreachable
    L0_3 = L0_3()
    if L0_3 then
      L0_3 = false
      return L0_3
    end
    L0_3 = Data
    L0_3 = L0_3.coords
    L0_3 = L0_3()
    L1_3 = vec3
    L2_3 = L1_2.coords
    L2_3 = L2_3.x
    L3_3 = L1_2.coords
    L3_3 = L3_3.y
    L4_3 = L1_2.coords
    L4_3 = L4_3.z
    L1_3 = L1_3(L2_3, L3_3, L4_3)
    L2_3 = IsWithinDistance
    L3_3 = L0_3
    L4_3 = L1_3
    L5_3 = 2.5
    return L2_3(L3_3, L4_3, L5_3)
  end
  L11_2 = {}
  L12_2 = 2.5
  L13_2 = "fas fa-clipboard-check"
  L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2)
  A0_2.interaction = L2_2
end
L0_1.SetupInteraction = L1_1
L0_1 = HeadquartersNpc
function L1_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
  L1_2 = Config
  L1_2 = L1_2.headquarters
  L1_2 = L1_2.jobBoard
  if not L1_2 then
    return
  end
  L2_2 = exports
  L2_2 = L2_2.kq_link
  L3_2 = L2_2
  L2_2 = L2_2.AddInteractionZone
  L4_2 = L1_2.coords
  L5_2 = vec3
  L6_2 = 0.0
  L7_2 = 0.0
  L8_2 = 0.0
  L5_2 = L5_2(L6_2, L7_2, L8_2)
  L6_2 = L1_2.scale
  L7_2 = L
  L8_2 = "headquarters.job_board_3d"
  L7_2 = L7_2(L8_2)
  L8_2 = L
  L9_2 = "headquarters.job_board_target"
  L8_2 = L8_2(L9_2)
  L9_2 = 38
  function L10_2()
    local L0_3, L1_3, L2_3, L3_3
    L0_3 = IsPlayerWearingJobOutfit
    L0_3 = L0_3()
    if not L0_3 then
      L0_3 = exports
      L0_3 = L0_3.kq_link
      L1_3 = L0_3
      L0_3 = L0_3.Notify
      L2_3 = L
      L3_3 = "outfit.required"
      L2_3 = L2_3(L3_3)
      L3_3 = "error"
      L0_3(L1_3, L2_3, L3_3)
      return
    end
    L0_3 = TriggerServerEvent
    L1_3 = "kq_powerwashing:server:openJobBoard"
    L0_3(L1_3)
  end
  function L11_2()
    local L0_3, L1_3
    L0_3 = IsPlayerUnreachable
    L0_3 = L0_3()
    if L0_3 then
      L0_3 = false
      return L0_3
    end
    L0_3 = DoesPlayerHavePowerwashingJob
    return L0_3()
  end
  L12_2 = {}
  L13_2 = L1_2.interactDist
  L14_2 = "fas fa-clipboard-list"
  L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
  A0_2.jobBoardInteraction = L2_2
end
L0_1.SetupJobBoard = L1_1
L0_1 = HeadquartersNpc
function L1_1(A0_2, A1_2)
  A0_2.activeTaskId = A1_2
end
L0_1.SetActiveTask = L1_1
L0_1 = HeadquartersNpc
function L1_1(A0_2)
  local L1_2
  A0_2.activeTaskId = nil
end
L0_1.ClearActiveTask = L1_1
L0_1 = HeadquartersNpc
function L1_1(A0_2)
  local L1_2, L2_2
  L1_2 = A0_2.interaction
  if L1_2 then
    L1_2 = A0_2.interaction
    L1_2 = L1_2.Delete
    L1_2()
    A0_2.interaction = nil
  end
  L1_2 = A0_2.jobBoardInteraction
  if L1_2 then
    L1_2 = A0_2.jobBoardInteraction
    L1_2 = L1_2.Delete
    L1_2()
    A0_2.jobBoardInteraction = nil
  end
  L1_2 = A0_2.ped
  if L1_2 then
    L1_2 = DoesEntityExist
    L2_2 = A0_2.ped
    L1_2 = L1_2(L2_2)
    if L1_2 then
      L1_2 = DeleteEntity
      L2_2 = A0_2.ped
      L1_2(L2_2)
      A0_2.ped = nil
    end
  end
  A0_2.activeTaskId = nil
end
L0_1.Destroy = L1_1
L0_1 = CreateThread
function L1_1()
  local L0_2, L1_2
  L0_2 = Wait
  L1_2 = 1000
  L0_2(L1_2)
  L0_2 = HeadquartersNpc
  L1_2 = L0_2
  L0_2 = L0_2.Init
  L0_2(L1_2)
end
L0_1(L1_1)
L0_1 = AddEventHandler
L1_1 = "onResourceStop"
function L2_1(A0_2)
  local L1_2, L2_2
  L1_2 = GetCurrentResourceName
  L1_2 = L1_2()
  if L1_2 ~= A0_2 then
    return
  end
  L1_2 = HeadquartersNpc
  L2_2 = L1_2
  L1_2 = L1_2.Destroy
  L1_2(L2_2)
end
L0_1(L1_1, L2_1)
