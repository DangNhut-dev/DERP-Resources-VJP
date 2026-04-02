local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1, L8_1, L9_1, L10_1, L11_1, L12_1, L13_1, L14_1, L15_1, L16_1, L17_1, L18_1, L19_1, L20_1, L21_1, L22_1, L23_1, L24_1, L25_1, L26_1, L27_1, L28_1
L0_1 = DisableControlAction
L1_1 = Wait
L2_1 = CreateThread
L3_1 = SetNuiFocus
L4_1 = SendNUIMessage
L5_1 = IsPedInAnyVehicle
L6_1 = PlayerPedId
L7_1 = RequestAnimDict
L8_1 = HasAnimDictLoaded
L9_1 = GetHashKey
L10_1 = RequestMode
L11_1 = GetGameTimer
L12_1 = TaskPlayAnim
L13_1 = GetEntityCoords
L14_1 = CreateObject
L15_1 = AttachEntityToEntity
L16_1 = GetPedBoneIndex
L17_1 = GetStreetNameAtCoord
L18_1 = GetStreetNameFromHashKey
L19_1 = IsEntityPlayingAnim
L20_1 = DeleteEntity
L21_1 = ClearPedTasks
L22_1 = RegisterNuiCallback
L23_1 = ActivateFrontendMenu
L24_1 = IsFrontendReadyForControl
L25_1 = SetControlNormal
L26_1 = {}
L26_1.PauseMenuOpen = false
L26_1.LastShow = nil
PlayerState = L26_1
L26_1 = {}
Functions = L26_1
Object = nil
L26_1 = false
L27_1 = Functions
function L28_1()
  local L0_2, L1_2, L2_2, L3_2
  repeat
    L0_2 = L0_1
    L1_2 = 1
    L2_2 = 200
    L3_2 = true
    L0_2(L1_2, L2_2, L3_2)
    L0_2 = L1_1
    L1_2 = 0
    L0_2(L1_2)
    L0_2 = PlayerState
    L0_2 = L0_2.PauseMenuOpen
  until not L0_2
end
L27_1.MainLoop = L28_1
L27_1 = Functions
function L28_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2
  L2_2 = L2_1
  L3_2 = Functions
  L3_2 = L3_2.MainLoop
  L2_2(L3_2)
  L2_2 = L3_1
  L3_2 = A0_2
  L4_2 = A0_2
  L2_2(L3_2, L4_2)
  L2_2 = L4_1
  L3_2 = {}
  L3_2.type = A0_2
  L3_2.data = A1_2
  L2_2(L3_2)
  L2_2 = PlayerState
  L2_2.PauseMenuOpen = A0_2
  L2_2 = PlayerState
  if A1_2 then
    L3_2 = A1_2.show
    if L3_2 then
      goto lbl_25
    end
  end
  L3_2 = PlayerState
  L3_2 = L3_2.LastShow
  ::lbl_25::
  L2_2.LastShow = L3_2
  if A0_2 then
    L2_2 = L2_1
    function L3_2()
      local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3
      while true do
        L0_3 = PlayerState
        L0_3 = L0_3.PauseMenuOpen
        if not L0_3 then
          break
        end
        L0_3 = nil
        L1_3 = CFG
        L1_3 = L1_3.Framework
        if "esx" == L1_3 then
          L1_3 = TriggerServerCallback
          L2_3 = "esx:getplayerData"
          L1_3 = L1_3(L2_3)
          L0_3 = L1_3
        else
          L1_3 = CFG
          L1_3 = L1_3.Framework
          if "qbox" == L1_3 then
            L1_3 = TriggerServerCallback
            L2_3 = "qbox:getPlayerData"
            L1_3 = L1_3(L2_3)
            L0_3 = L1_3
          else
            L1_3 = CFG
            L1_3 = L1_3.Framework
            if "qb" == L1_3 then
              L1_3 = TriggerServerCallback
              L2_3 = "qb:getPlayerData"
              L1_3 = L1_3(L2_3)
              L0_3 = L1_3
            end
          end
        end
        if L0_3 then
          L1_3 = Functions
          L1_3 = L1_3.getPlayerStreetName
          L1_3 = L1_3()
          L2_3 = {}
          L3_3 = CFG
          L3_3 = L3_3.Style
          if not L3_3 then
            L3_3 = {}
          end
          L2_3.style = L3_3
          L3_3 = Locales
          L4_3 = CFG
          L4_3 = L4_3.Locale
          L3_3 = L3_3[L4_3]
          if not L3_3 then
            L3_3 = Locales
            L3_3 = L3_3.en
            if not L3_3 then
              L3_3 = {}
            end
          end
          L2_3.lang = L3_3
          L3_3 = CFG
          L3_3 = L3_3.Links
          if not L3_3 then
            L3_3 = {}
          end
          L2_3.links = L3_3
          L3_3 = {}
          L3_3.location = L1_3
          L2_3.strings = L3_3
          L2_3.personalData = L0_3
          L3_3 = PlayerState
          L3_3 = L3_3.LastShow
          L2_3.show = L3_3
          L3_3 = CFG
          L3_3 = L3_3.Debug
          if L3_3 then
            L3_3 = L2_3.personalData
            if L3_3 then
              L3_3 = L2_3.personalData
              L3_3 = L3_3.playTime
              if L3_3 then
                goto lbl_86
              end
            end
            L3_3 = L2_3.playTime
            ::lbl_86::
            L4_3 = DebugPrint
            L5_3 = "[UI] refresh tick, playTime="
            L6_3 = tostring
            L7_3 = L3_3
            L6_3 = L6_3(L7_3)
            L5_3 = L5_3 .. L6_3
            L4_3(L5_3)
          end
          L3_3 = L4_1
          L4_3 = {}
          L4_3.type = true
          L4_3.data = L2_3
          L3_3(L4_3)
        end
        L1_3 = L1_1
        L2_3 = 60000
        L1_3(L2_3)
      end
    end
    L2_2(L3_2)
  end
end
L27_1.TogglePauseMenu = L28_1
L27_1 = Functions
function L28_1()
  local L0_2, L1_2, L2_2, L3_2
  L0_2 = L6_1
  L0_2 = L0_2()
  L1_2 = L5_1
  L2_2 = L0_2
  L3_2 = false
  return L1_2(L2_2, L3_2)
end
L27_1.PedIsInVehicle = L28_1
L27_1 = Functions
function L28_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2
  L3_2 = L26_1
  if L3_2 then
    L3_2 = CFG
    L3_2 = L3_2.Debug
    if L3_2 then
      L3_2 = DebugPrint
      L4_2 = "[ANIM] Animation already started, skipping"
      L3_2(L4_2)
    end
    return
  end
  L3_2 = L6_1
  L3_2 = L3_2()
  L4_2 = Object
  if L4_2 then
    L4_2 = DoesEntityExist
    L5_2 = Object
    L4_2 = L4_2(L5_2)
    if L4_2 then
      L4_2 = L20_1
      L5_2 = Object
      L4_2(L5_2)
      Object = nil
    end
  end
  L4_2 = L7_1
  L5_2 = A1_2
  L4_2(L5_2)
  while true do
    L4_2 = L8_1
    L5_2 = A1_2
    L4_2 = L4_2(L5_2)
    if L4_2 then
      break
    end
    L4_2 = L1_1
    L5_2 = 0
    L4_2(L5_2)
  end
  L4_2 = L9_1
  L5_2 = A2_2
  L4_2 = L4_2(L5_2)
  L5_2 = RequestModel
  L6_2 = L4_2
  L5_2(L6_2)
  L5_2 = L11_1
  L5_2 = L5_2()
  L5_2 = L5_2 + 5000
  while true do
    L6_2 = HasModelLoaded
    L7_2 = L4_2
    L6_2 = L6_2(L7_2)
    if L6_2 then
      break
    end
    L6_2 = L1_1
    L7_2 = 0
    L6_2(L7_2)
    L6_2 = L11_1
    L6_2 = L6_2()
    if L5_2 < L6_2 then
      L6_2 = print
      L7_2 = "Error: model not loaded"
      L6_2(L7_2)
      L6_2 = nil
      return L6_2
    end
  end
  L6_2 = L12_1
  L7_2 = L3_2
  L8_2 = A1_2
  L9_2 = A0_2
  L10_2 = 2.0
  L11_2 = 2.0
  L12_2 = -1
  L13_2 = 51
  L14_2 = 0
  L15_2 = false
  L16_2 = false
  L17_2 = false
  L6_2(L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2)
  L6_2 = L13_1
  L7_2 = L3_2
  L6_2 = L6_2(L7_2)
  L7_2 = L14_1
  L8_2 = L4_2
  L9_2 = L6_2.x
  L10_2 = L6_2.y
  L11_2 = L6_2.z
  L11_2 = L11_2 + 0.2
  L12_2 = true
  L13_2 = false
  L14_2 = false
  L7_2 = L7_2(L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
  L8_2 = L15_1
  L9_2 = L7_2
  L10_2 = L3_2
  L11_2 = L16_1
  L12_2 = L3_2
  L13_2 = 28422
  L11_2 = L11_2(L12_2, L13_2)
  L12_2 = 0.0
  L13_2 = -0.03
  L14_2 = 0.0
  L15_2 = 20.0
  L16_2 = -90.0
  L17_2 = 0.0
  L18_2 = true
  L19_2 = true
  L20_2 = false
  L21_2 = true
  L22_2 = 1
  L23_2 = true
  L8_2(L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2)
  L8_2 = true
  L26_1 = L8_2
  Object = L7_2
  L8_2 = CFG
  L8_2 = L8_2.Debug
  if L8_2 then
    L8_2 = DebugPrint
    L9_2 = "[ANIM] Animation started successfully"
    L8_2(L9_2)
  end
  return L7_2
end
L27_1.StartPlayerAnim = L28_1
L27_1 = Functions
function L28_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2
  L0_2 = L6_1
  L0_2 = L0_2()
  L1_2 = L13_1
  L2_2 = L0_2
  L1_2 = L1_2(L2_2)
  L2_2 = L17_1
  L3_2 = L1_2.x
  L4_2 = L1_2.y
  L5_2 = L1_2.z
  L2_2, L3_2 = L2_2(L3_2, L4_2, L5_2)
  L4_2 = L18_1
  L5_2 = L2_2
  L4_2 = L4_2(L5_2)
  L5_2 = L4_2 or L5_2
  if not L4_2 then
    L5_2 = "Unknown Street"
  end
  return L5_2
end
L27_1.getPlayerStreetName = L28_1
L27_1 = Functions
function L28_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L2_2 = L6_1
  L2_2 = L2_2()
  L3_2 = L26_1
  if L3_2 then
    L3_2 = L19_1
    L4_2 = L2_2
    L5_2 = A0_2
    L6_2 = A1_2
    L7_2 = 3
    L3_2 = L3_2(L4_2, L5_2, L6_2, L7_2)
    if L3_2 then
      L3_2 = CFG
      L3_2 = L3_2.Debug
      if L3_2 then
        L3_2 = DebugPrint
        L4_2 = "[ANIM] Stopping animation"
        L3_2(L4_2)
      end
      L3_2 = ClearPedTasksImmediately
      L4_2 = L2_2
      L3_2(L4_2)
    end
  end
  L3_2 = Object
  if L3_2 then
    L3_2 = DoesEntityExist
    L4_2 = Object
    L3_2 = L3_2(L4_2)
    if L3_2 then
      L3_2 = L20_1
      L4_2 = Object
      L3_2(L4_2)
      Object = nil
      L3_2 = CFG
      L3_2 = L3_2.Debug
      if L3_2 then
        L3_2 = DebugPrint
        L4_2 = "[ANIM] Object deleted"
        L3_2(L4_2)
      end
    end
  end
  L3_2 = false
  L26_1 = L3_2
end
L27_1.StopAnim = L28_1
L27_1 = Functions
function L28_1()
  local L0_2, L1_2
  L0_2 = Object
  if L0_2 then
    L0_2 = DoesEntityExist
    L1_2 = Object
    L0_2 = L0_2(L1_2)
    if L0_2 then
      L0_2 = L20_1
      L1_2 = Object
      L0_2(L1_2)
      Object = nil
    end
  end
  L0_2 = false
  L26_1 = L0_2
  L0_2 = CFG
  L0_2 = L0_2.Debug
  if L0_2 then
    L0_2 = DebugPrint
    L1_2 = "[ANIM] Animation state reset"
    L0_2(L1_2)
  end
end
L27_1.ResetAnimationState = L28_1
L27_1 = Functions
function L28_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2
  if A0_2 then
    L2_2 = type
    L3_2 = A1_2
    L2_2 = L2_2(L3_2)
    if "function" == L2_2 then
      goto lbl_9
    end
  end
  do return end
  ::lbl_9::
  L2_2 = L22_1
  L3_2 = A0_2
  function L4_2(A0_3, A1_3)
    local L2_3, L3_3, L4_3
    L2_3 = A1_2
    L3_3 = A0_3
    L4_3 = A1_3
    L2_3(L3_3, L4_3)
  end
  L2_2(L3_2, L4_2)
end
L27_1.RegisterCallback = L28_1
L27_1 = Functions
function L28_1()
  local L0_2, L1_2, L2_2, L3_2
  L0_2 = Functions
  L0_2 = L0_2.TogglePauseMenu
  L1_2 = false
  L0_2(L1_2)
  L0_2 = L1_1
  L1_2 = 300
  L0_2(L1_2)
  L0_2 = L23_1
  L1_2 = -1171018317
  L2_2 = 0
  L3_2 = -1
  L0_2(L1_2, L2_2, L3_2)
  while true do
    L0_2 = L24_1
    L0_2 = L0_2()
    if L0_2 then
      break
    end
    L0_2 = L1_1
    L1_2 = 10
    L0_2(L1_2)
  end
  L0_2 = L1_1
  L1_2 = 20
  L0_2(L1_2)
  L0_2 = L25_1
  L1_2 = 2
  L2_2 = 201
  L3_2 = 1.0
  L0_2(L1_2, L2_2, L3_2)
end
L27_1.OpenMap = L28_1
L27_1 = Functions
function L28_1()
  local L0_2, L1_2, L2_2, L3_2
  L0_2 = Functions
  L0_2 = L0_2.TogglePauseMenu
  L1_2 = false
  L0_2(L1_2)
  L0_2 = L1_1
  L1_2 = 300
  L0_2(L1_2)
  L0_2 = L23_1
  L1_2 = -1031775802
  L2_2 = 0
  L3_2 = -1
  L0_2(L1_2, L2_2, L3_2)
end
L27_1.OpenSettings = L28_1

