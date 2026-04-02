local L0_1, L1_1, L2_1
L0_1 = Functions
L0_1 = L0_1.RegisterCallback
L1_1 = "close"
function L2_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2
  L2_2 = Functions
  L2_2 = L2_2.TogglePauseMenu
  L3_2 = false
  L2_2(L3_2)
  L2_2 = Functions
  L2_2 = L2_2.StopAnim
  L3_2 = CFG
  L3_2 = L3_2.Anim
  L3_2 = L3_2.DictName
  L4_2 = CFG
  L4_2 = L4_2.Anim
  L4_2 = L4_2.AnimName
  L2_2(L3_2, L4_2)
  L2_2 = Cam
  L2_2 = L2_2.ExistCam
  L2_2 = L2_2()
  if L2_2 then
    L2_2 = Cam
    L2_2 = L2_2.DestroyCamera
    L2_2()
  end
  L2_2 = A1_2
  L3_2 = true
  L2_2(L3_2)
end
L0_1(L1_1, L2_1)
L0_1 = Functions
L0_1 = L0_1.RegisterCallback
L1_1 = "open_settings"
function L2_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2
  L2_2 = Functions
  L2_2 = L2_2.StopAnim
  L3_2 = CFG
  L3_2 = L3_2.Anim
  L3_2 = L3_2.DictName
  L4_2 = CFG
  L4_2 = L4_2.Anim
  L4_2 = L4_2.AnimName
  L2_2(L3_2, L4_2)
  L2_2 = Cam
  L2_2 = L2_2.ExistCam
  L2_2 = L2_2()
  if L2_2 then
    L2_2 = Cam
    L2_2 = L2_2.DestroyCamera
    L2_2()
  end
  L2_2 = Functions
  L2_2 = L2_2.OpenSettings
  L2_2()
end
L0_1(L1_1, L2_1)
L0_1 = Functions
L0_1 = L0_1.RegisterCallback
L1_1 = "open_map"
function L2_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2
  L2_2 = Functions
  L2_2 = L2_2.StopAnim
  L3_2 = CFG
  L3_2 = L3_2.Anim
  L3_2 = L3_2.DictName
  L4_2 = CFG
  L4_2 = L4_2.Anim
  L4_2 = L4_2.AnimName
  L2_2(L3_2, L4_2)
  L2_2 = Cam
  L2_2 = L2_2.ExistCam
  L2_2 = L2_2()
  if L2_2 then
    L2_2 = Cam
    L2_2 = L2_2.DestroyCamera
    L2_2()
  end
  L2_2 = Functions
  L2_2 = L2_2.OpenMap
  L2_2()
end
L0_1(L1_1, L2_1)
L0_1 = Functions
L0_1 = L0_1.RegisterCallback
L1_1 = "exit"
function L2_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2
  L2_2 = Functions
  L2_2 = L2_2.TogglePauseMenu
  L3_2 = false
  L2_2(L3_2)
  L2_2 = Functions
  L2_2 = L2_2.StopAnim
  L3_2 = CFG
  L3_2 = L3_2.Anim
  L3_2 = L3_2.DictName
  L4_2 = CFG
  L4_2 = L4_2.Anim
  L4_2 = L4_2.AnimName
  L2_2(L3_2, L4_2)
  L2_2 = Cam
  L2_2 = L2_2.ExistCam
  L2_2 = L2_2()
  if L2_2 then
    L2_2 = Cam
    L2_2 = L2_2.DestroyCamera
    L2_2()
  end
  L2_2 = Wait
  L3_2 = 300
  L2_2(L3_2)
  L2_2 = TriggerServerEvent
  L3_2 = "prism_pausemenu:disconnect"
  L4_2 = GetPlayerServerId
  L5_2 = PlayerId
  L5_2 = L5_2()
  L4_2, L5_2 = L4_2(L5_2)
  L2_2(L3_2, L4_2, L5_2)
end
L0_1(L1_1, L2_1)

-- Handle NUI request to execute donate command
RegisterNUICallback('executeDonate', function(data, cb)
    ExecuteCommand('donate')
    cb('ok')
end)