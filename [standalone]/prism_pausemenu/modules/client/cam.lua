local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1, L8_1, L9_1, L10_1, L11_1, L12_1, L13_1, L14_1, L15_1, L16_1, L17_1, L18_1, L19_1, L20_1, L21_1
L0_1 = PlayerPedId
L1_1 = Wait
L2_1 = GetOffsetFromEntityInWorldCoords
L3_1 = CreateCam
L4_1 = SetCamCoord
L5_1 = SetCamFov
L6_1 = SetCamRot
L7_1 = SetCamUseShallowDofMode
L8_1 = SetCamNearDof
L9_1 = SetCamFarDof
L10_1 = SetCamDofStrength
L11_1 = SetCamDofMaxNearInFocusDistance
L12_1 = PointCamAtPedBone
L13_1 = SetCamActiveWithInterp
L14_1 = DestroyCam
L15_1 = SetCamActive
L16_1 = RenderScriptCams
L17_1 = TaskLookAtCoord
L18_1 = SetUseHiDof
L19_1 = {}
Cam = L19_1
L19_1 = nil
L20_1 = Cam
function L21_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
  L4_2 = L0_1
  L4_2 = L4_2()
  while true do
    L5_2 = GetEntitySpeed
    L6_2 = L4_2
    L5_2 = L5_2(L6_2)
    L6_2 = 0.1
    if not (L5_2 > L6_2) then
      break
    end
    L5_2 = L1_1
    L6_2 = 100
    L5_2(L6_2)
  end
  L5_2 = L2_1
  L6_2 = L4_2
  L7_2 = 0.5
  L8_2 = A0_2
  L9_2 = 0
  L5_2 = L5_2(L6_2, L7_2, L8_2, L9_2)
  L6_2 = L3_1
  L7_2 = "DEFAULT_SCRIPTED_CAMERA"
  L8_2 = true
  L6_2 = L6_2(L7_2, L8_2)
  L7_2 = L4_1
  L8_2 = L6_2
  L9_2 = L5_2.x
  L10_2 = L5_2.y
  L11_2 = L5_2.z
  L11_2 = L11_2 + A1_2
  L7_2(L8_2, L9_2, L10_2, L11_2)
  L7_2 = L5_1
  L8_2 = L6_2
  L9_2 = 38.0
  L7_2(L8_2, L9_2)
  L7_2 = L6_1
  L8_2 = L6_2
  L9_2 = 0.0
  L10_2 = 0.0
  L11_2 = GetEntityHeading
  L12_2 = L4_2
  L11_2 = L11_2(L12_2)
  L11_2 = L11_2 + 180
  L7_2(L8_2, L9_2, L10_2, L11_2)
  L7_2 = L7_1
  L8_2 = L6_2
  L9_2 = true
  L7_2(L8_2, L9_2)
  L7_2 = L8_1
  L8_2 = L6_2
  L9_2 = 1.2
  L7_2(L8_2, L9_2)
  L7_2 = L9_1
  L8_2 = L6_2
  L9_2 = 12.0
  L7_2(L8_2, L9_2)
  L7_2 = L10_1
  L8_2 = L6_2
  L9_2 = 1.0
  L7_2(L8_2, L9_2)
  L7_2 = L11_1
  L8_2 = L6_2
  L9_2 = 1.0
  L7_2(L8_2, L9_2)
  if A2_2 and A3_2 then
    L7_2 = L12_1
    L8_2 = L6_2
    L9_2 = L4_2
    L10_2 = A2_2
    L11_2 = A3_2 + 0.5
    L12_2 = 0.0
    L13_2 = 0.0
    L14_2 = 1
    L7_2(L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
  end
  L7_2 = Cam
  L7_2 = L7_2.ExistCam
  L7_2 = L7_2()
  if L7_2 then
    L7_2 = 1000
    L8_2 = L13_1
    L9_2 = L6_2
    L10_2 = L19_1
    L11_2 = L7_2
    L12_2 = true
    L13_2 = true
    L8_2(L9_2, L10_2, L11_2, L12_2, L13_2)
    L8_2 = L1_1
    L9_2 = L7_2
    L8_2(L9_2)
    L8_2 = L14_1
    L9_2 = L19_1
    L10_2 = false
    L8_2(L9_2, L10_2)
  else
    L7_2 = L15_1
    L8_2 = L6_2
    L9_2 = true
    L7_2(L8_2, L9_2)
  end
  L19_1 = L6_2
  L7_2 = L16_1
  L8_2 = true
  L9_2 = true
  L10_2 = 1350
  L11_2 = 1
  L12_2 = 0
  L7_2(L8_2, L9_2, L10_2, L11_2, L12_2)
  L7_2 = L17_1
  L8_2 = L4_2
  L9_2 = L5_2.x
  L10_2 = L5_2.y
  L11_2 = L5_2.z
  L12_2 = 5000
  L13_2 = 1
  L14_2 = 1
  L7_2(L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
  repeat
    L7_2 = L18_1
    L7_2()
    L7_2 = L1_1
    L8_2 = 0
    L7_2(L8_2)
    L7_2 = Cam
    L7_2 = L7_2.ExistCam
    L7_2 = L7_2()
  until not L7_2
end
L20_1.StartCamera = L21_1
L20_1 = Cam
function L21_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2
  L0_2 = L19_1
  if L0_2 then
    L0_2 = L16_1
    L1_2 = false
    L2_2 = true
    L3_2 = 1250
    L4_2 = 1
    L5_2 = 0
    L0_2(L1_2, L2_2, L3_2, L4_2, L5_2)
    L0_2 = L14_1
    L1_2 = L19_1
    L2_2 = false
    L0_2(L1_2, L2_2)
    L0_2 = nil
    L19_1 = L0_2
  end
end
L20_1.DestroyCamera = L21_1
L20_1 = Cam
function L21_1()
  local L0_2, L1_2
  L0_2 = L19_1
  L0_2 = nil ~= L0_2
  return L0_2
end
L20_1.ExistCam = L21_1

