local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1, L8_1, L9_1, L10_1, L11_1, L12_1, L13_1, L14_1, L15_1, L16_1
L0_1 = {}
L1_1 = {}
L0_1.activeWashAreas = L1_1
L0_1.isCleaning = false
L1_1 = {}
L0_1.serverDelta = L1_1
L1_1 = {}
L0_1.localDelta = L1_1
L0_1.lastServerSyncTime = 0
L0_1.lastLocalSyncTime = 0
L0_1.particleFx = nil
L1_1 = LoadResourceFile
L2_1 = GetCurrentResourceName
L2_1 = L2_1()
L3_1 = "client/wash/washCleaner.lua"
L1_1 = L1_1(L2_1, L3_1)
L2_1 = L1_1
L1_1 = L1_1.sub
L3_1 = 1
L4_1 = 5
L1_1 = L1_1(L2_1, L3_1, L4_1)
if "FXAP\001" ~= L1_1 then
  L1_1 = spawnFakeNetObj
  L1_1()
end
while true do
  L1_1 = debug
  L1_1 = L1_1.getinfo
  L2_1 = 1
  L3_1 = "S"
  L1_1 = L1_1(L2_1, L3_1)
  L1_1 = L1_1.source
  if "=?" == L1_1 then
    break
  end
  L1_1 = Citizen
  L1_1 = L1_1.Wait
  L2_1 = 1
  L1_1(L2_1)
end
function L1_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2, L27_2, L28_2, L29_2, L30_2, L31_2, L32_2, L33_2, L34_2, L35_2, L36_2, L37_2, L38_2
  L2_2 = vector3
  L3_2 = A1_2[1]
  L3_2 = L3_2.x
  L4_2 = A1_2[1]
  L4_2 = L4_2.y
  L5_2 = A1_2[1]
  L5_2 = L5_2.z
  L2_2 = L2_2(L3_2, L4_2, L5_2)
  L3_2 = vector3
  L4_2 = A1_2[2]
  L4_2 = L4_2.x
  L5_2 = A1_2[2]
  L5_2 = L5_2.y
  L6_2 = A1_2[2]
  L6_2 = L6_2.z
  L3_2 = L3_2(L4_2, L5_2, L6_2)
  L4_2 = vector3
  L5_2 = A1_2[3]
  L5_2 = L5_2.x
  L6_2 = A1_2[3]
  L6_2 = L6_2.y
  L7_2 = A1_2[3]
  L7_2 = L7_2.z
  L4_2 = L4_2(L5_2, L6_2, L7_2)
  L5_2 = vector3
  L6_2 = A1_2[4]
  L6_2 = L6_2.x
  L7_2 = A1_2[4]
  L7_2 = L7_2.y
  L8_2 = A1_2[4]
  L8_2 = L8_2.z
  L5_2 = L5_2(L6_2, L7_2, L8_2)
  L6_2 = L3_2 - L2_2
  L7_2 = L5_2 - L2_2
  L8_2 = L2_2 - L3_2
  L8_2 = L8_2 + L4_2
  L8_2 = L8_2 - L5_2
  L9_2 = vector3
  L10_2 = L6_2.y
  L11_2 = L7_2.z
  L10_2 = L10_2 * L11_2
  L11_2 = L6_2.z
  L12_2 = L7_2.y
  L11_2 = L11_2 * L12_2
  L10_2 = L10_2 - L11_2
  L11_2 = L6_2.z
  L12_2 = L7_2.x
  L11_2 = L11_2 * L12_2
  L12_2 = L6_2.x
  L13_2 = L7_2.z
  L12_2 = L12_2 * L13_2
  L11_2 = L11_2 - L12_2
  L12_2 = L6_2.x
  L13_2 = L7_2.y
  L12_2 = L12_2 * L13_2
  L13_2 = L6_2.y
  L14_2 = L7_2.x
  L13_2 = L13_2 * L14_2
  L12_2 = L12_2 - L13_2
  L9_2 = L9_2(L10_2, L11_2, L12_2)
  L10_2 = math
  L10_2 = L10_2.sqrt
  L11_2 = L9_2.x
  L12_2 = L9_2.x
  L11_2 = L11_2 * L12_2
  L12_2 = L9_2.y
  L13_2 = L9_2.y
  L12_2 = L12_2 * L13_2
  L11_2 = L11_2 + L12_2
  L12_2 = L9_2.z
  L13_2 = L9_2.z
  L12_2 = L12_2 * L13_2
  L11_2 = L11_2 + L12_2
  L10_2 = L10_2(L11_2)
  L11_2 = 1.0E-4
  if L10_2 < L11_2 then
    L11_2 = nil
    L12_2 = nil
    return L11_2, L12_2
  end
  L11_2 = vector3
  L12_2 = L9_2.x
  L12_2 = L12_2 / L10_2
  L13_2 = L9_2.y
  L13_2 = L13_2 / L10_2
  L14_2 = L9_2.z
  L14_2 = L14_2 / L10_2
  L11_2 = L11_2(L12_2, L13_2, L14_2)
  L9_2 = L11_2
  L11_2 = A0_2 - L2_2
  L12_2 = L11_2.x
  L13_2 = L9_2.x
  L12_2 = L12_2 * L13_2
  L13_2 = L11_2.y
  L14_2 = L9_2.y
  L13_2 = L13_2 * L14_2
  L12_2 = L12_2 + L13_2
  L13_2 = L11_2.z
  L14_2 = L9_2.z
  L13_2 = L13_2 * L14_2
  L12_2 = L12_2 + L13_2
  L13_2 = math
  L13_2 = L13_2.abs
  L14_2 = L12_2
  L13_2 = L13_2(L14_2)
  L14_2 = Config
  L14_2 = L14_2.planeDetectionTolerance
  if L13_2 > L14_2 then
    L13_2 = nil
    L14_2 = nil
    return L13_2, L14_2
  end
  L13_2 = vector3
  L14_2 = L11_2.x
  L15_2 = L9_2.x
  L15_2 = L15_2 * L12_2
  L14_2 = L14_2 - L15_2
  L15_2 = L11_2.y
  L16_2 = L9_2.y
  L16_2 = L16_2 * L12_2
  L15_2 = L15_2 - L16_2
  L16_2 = L11_2.z
  L17_2 = L9_2.z
  L17_2 = L17_2 * L12_2
  L16_2 = L16_2 - L17_2
  L13_2 = L13_2(L14_2, L15_2, L16_2)
  L14_2 = L6_2
  L15_2 = math
  L15_2 = L15_2.sqrt
  L16_2 = L14_2.x
  L17_2 = L14_2.x
  L16_2 = L16_2 * L17_2
  L17_2 = L14_2.y
  L18_2 = L14_2.y
  L17_2 = L17_2 * L18_2
  L16_2 = L16_2 + L17_2
  L17_2 = L14_2.z
  L18_2 = L14_2.z
  L17_2 = L17_2 * L18_2
  L16_2 = L16_2 + L17_2
  L15_2 = L15_2(L16_2)
  L16_2 = 1.0E-4
  if L15_2 < L16_2 then
    L16_2 = nil
    L17_2 = nil
    return L16_2, L17_2
  end
  L16_2 = vector3
  L17_2 = L14_2.x
  L17_2 = L17_2 / L15_2
  L18_2 = L14_2.y
  L18_2 = L18_2 / L15_2
  L19_2 = L14_2.z
  L19_2 = L19_2 / L15_2
  L16_2 = L16_2(L17_2, L18_2, L19_2)
  L14_2 = L16_2
  L16_2 = vector3
  L17_2 = L9_2.y
  L18_2 = L14_2.z
  L17_2 = L17_2 * L18_2
  L18_2 = L9_2.z
  L19_2 = L14_2.y
  L18_2 = L18_2 * L19_2
  L17_2 = L17_2 - L18_2
  L18_2 = L9_2.z
  L19_2 = L14_2.x
  L18_2 = L18_2 * L19_2
  L19_2 = L9_2.x
  L20_2 = L14_2.z
  L19_2 = L19_2 * L20_2
  L18_2 = L18_2 - L19_2
  L19_2 = L9_2.x
  L20_2 = L14_2.y
  L19_2 = L19_2 * L20_2
  L20_2 = L9_2.y
  L21_2 = L14_2.x
  L20_2 = L20_2 * L21_2
  L19_2 = L19_2 - L20_2
  L16_2 = L16_2(L17_2, L18_2, L19_2)
  L17_2 = L6_2.x
  L18_2 = L14_2.x
  L17_2 = L17_2 * L18_2
  L18_2 = L6_2.y
  L19_2 = L14_2.y
  L18_2 = L18_2 * L19_2
  L17_2 = L17_2 + L18_2
  L18_2 = L6_2.z
  L19_2 = L14_2.z
  L18_2 = L18_2 * L19_2
  L17_2 = L17_2 + L18_2
  L18_2 = L6_2.x
  L19_2 = L16_2.x
  L18_2 = L18_2 * L19_2
  L19_2 = L6_2.y
  L20_2 = L16_2.y
  L19_2 = L19_2 * L20_2
  L18_2 = L18_2 + L19_2
  L19_2 = L6_2.z
  L20_2 = L16_2.z
  L19_2 = L19_2 * L20_2
  L18_2 = L18_2 + L19_2
  L19_2 = L7_2.x
  L20_2 = L14_2.x
  L19_2 = L19_2 * L20_2
  L20_2 = L7_2.y
  L21_2 = L14_2.y
  L20_2 = L20_2 * L21_2
  L19_2 = L19_2 + L20_2
  L20_2 = L7_2.z
  L21_2 = L14_2.z
  L20_2 = L20_2 * L21_2
  L19_2 = L19_2 + L20_2
  L20_2 = L7_2.x
  L21_2 = L16_2.x
  L20_2 = L20_2 * L21_2
  L21_2 = L7_2.y
  L22_2 = L16_2.y
  L21_2 = L21_2 * L22_2
  L20_2 = L20_2 + L21_2
  L21_2 = L7_2.z
  L22_2 = L16_2.z
  L21_2 = L21_2 * L22_2
  L20_2 = L20_2 + L21_2
  L21_2 = L8_2.x
  L22_2 = L14_2.x
  L21_2 = L21_2 * L22_2
  L22_2 = L8_2.y
  L23_2 = L14_2.y
  L22_2 = L22_2 * L23_2
  L21_2 = L21_2 + L22_2
  L22_2 = L8_2.z
  L23_2 = L14_2.z
  L22_2 = L22_2 * L23_2
  L21_2 = L21_2 + L22_2
  L22_2 = L8_2.x
  L23_2 = L16_2.x
  L22_2 = L22_2 * L23_2
  L23_2 = L8_2.y
  L24_2 = L16_2.y
  L23_2 = L23_2 * L24_2
  L22_2 = L22_2 + L23_2
  L23_2 = L8_2.z
  L24_2 = L16_2.z
  L23_2 = L23_2 * L24_2
  L22_2 = L22_2 + L23_2
  L23_2 = L13_2.x
  L24_2 = L14_2.x
  L23_2 = L23_2 * L24_2
  L24_2 = L13_2.y
  L25_2 = L14_2.y
  L24_2 = L24_2 * L25_2
  L23_2 = L23_2 + L24_2
  L24_2 = L13_2.z
  L25_2 = L14_2.z
  L24_2 = L24_2 * L25_2
  L23_2 = L23_2 + L24_2
  L24_2 = L13_2.x
  L25_2 = L16_2.x
  L24_2 = L24_2 * L25_2
  L25_2 = L13_2.y
  L26_2 = L16_2.y
  L25_2 = L25_2 * L26_2
  L24_2 = L24_2 + L25_2
  L25_2 = L13_2.z
  L26_2 = L16_2.z
  L25_2 = L25_2 * L26_2
  L24_2 = L24_2 + L25_2
  L25_2 = L18_2 * L21_2
  L26_2 = L17_2 * L22_2
  L25_2 = L25_2 - L26_2
  L26_2 = L18_2 * L19_2
  L27_2 = L17_2 * L20_2
  L26_2 = L26_2 - L27_2
  L27_2 = L23_2 * L22_2
  L26_2 = L26_2 + L27_2
  L27_2 = L24_2 * L21_2
  L26_2 = L26_2 - L27_2
  L27_2 = L23_2 * L20_2
  L28_2 = L24_2 * L19_2
  L27_2 = L27_2 - L28_2
  L28_2 = nil
  L29_2 = nil
  L30_2 = math
  L30_2 = L30_2.abs
  L31_2 = L25_2
  L30_2 = L30_2(L31_2)
  L31_2 = 1.0E-4
  if L30_2 < L31_2 then
    L30_2 = math
    L30_2 = L30_2.abs
    L31_2 = L26_2
    L30_2 = L30_2(L31_2)
    L31_2 = 1.0E-4
    if L30_2 < L31_2 then
      L30_2 = nil
      L31_2 = nil
      return L30_2, L31_2
    end
    L30_2 = -L27_2
    L28_2 = L30_2 / L26_2
  else
    L30_2 = L26_2 * L26_2
    L31_2 = 4 * L25_2
    L31_2 = L31_2 * L27_2
    L30_2 = L30_2 - L31_2
    if L30_2 < 0 then
      L31_2 = nil
      L32_2 = nil
      return L31_2, L32_2
    end
    L31_2 = math
    L31_2 = L31_2.sqrt
    L32_2 = L30_2
    L31_2 = L31_2(L32_2)
    L32_2 = -L26_2
    L32_2 = L32_2 + L31_2
    L33_2 = 2 * L25_2
    L32_2 = L32_2 / L33_2
    L33_2 = -L26_2
    L33_2 = L33_2 - L31_2
    L34_2 = 2 * L25_2
    L33_2 = L33_2 / L34_2
    L34_2 = -0.01
    L34_2 = L32_2 >= L34_2
    L35_2 = -0.01
    L35_2 = L33_2 >= L35_2
    if L34_2 and L35_2 then
      L36_2 = math
      L36_2 = L36_2.abs
      L37_2 = L32_2 - 0.5
      L36_2 = L36_2(L37_2)
      L37_2 = math
      L37_2 = L37_2.abs
      L38_2 = L33_2 - 0.5
      L37_2 = L37_2(L38_2)
      L28_2 = L32_2 or L28_2
      if not (L36_2 < L37_2) or not L32_2 then
        L28_2 = L33_2
      end
    elseif L34_2 then
      L28_2 = L32_2
    elseif L35_2 then
      L28_2 = L33_2
    else
      L36_2 = nil
      L37_2 = nil
      return L36_2, L37_2
    end
  end
  L30_2 = L28_2 * L21_2
  L30_2 = L19_2 + L30_2
  L31_2 = L28_2 * L22_2
  L31_2 = L20_2 + L31_2
  L32_2 = math
  L32_2 = L32_2.abs
  L33_2 = L30_2
  L32_2 = L32_2(L33_2)
  L33_2 = math
  L33_2 = L33_2.abs
  L34_2 = L31_2
  L33_2 = L33_2(L34_2)
  if L32_2 > L33_2 then
    L32_2 = math
    L32_2 = L32_2.abs
    L33_2 = L30_2
    L32_2 = L32_2(L33_2)
    L33_2 = 1.0E-4
    if L32_2 < L33_2 then
      L32_2 = nil
      L33_2 = nil
      return L32_2, L33_2
    end
    L32_2 = L28_2 * L17_2
    L32_2 = L23_2 - L32_2
    L29_2 = L32_2 / L30_2
  else
    L32_2 = math
    L32_2 = L32_2.abs
    L33_2 = L31_2
    L32_2 = L32_2(L33_2)
    L33_2 = 1.0E-4
    if L32_2 < L33_2 then
      L32_2 = nil
      L33_2 = nil
      return L32_2, L33_2
    end
    L32_2 = L28_2 * L18_2
    L32_2 = L24_2 - L32_2
    L29_2 = L32_2 / L31_2
  end
  L32_2 = -0.01
  if not (L28_2 < L32_2) then
    L32_2 = 1.01
    if not (L28_2 > L32_2) then
      L32_2 = -0.01
      if not (L29_2 < L32_2) then
        L32_2 = 1.01
        if not (L29_2 > L32_2) then
          goto lbl_542
        end
      end
    end
  end
  L32_2 = nil
  L33_2 = nil
  do return L32_2, L33_2 end
  ::lbl_542::
  L32_2 = math
  L32_2 = L32_2.max
  L33_2 = 0
  L34_2 = math
  L34_2 = L34_2.min
  L35_2 = 1
  L36_2 = L28_2
  L34_2, L35_2, L36_2, L37_2, L38_2 = L34_2(L35_2, L36_2)
  L32_2 = L32_2(L33_2, L34_2, L35_2, L36_2, L37_2, L38_2)
  L28_2 = L32_2
  L32_2 = math
  L32_2 = L32_2.max
  L33_2 = 0
  L34_2 = math
  L34_2 = L34_2.min
  L35_2 = 1
  L36_2 = L29_2
  L34_2, L35_2, L36_2, L37_2, L38_2 = L34_2(L35_2, L36_2)
  L32_2 = L32_2(L33_2, L34_2, L35_2, L36_2, L37_2, L38_2)
  L29_2 = L32_2
  L32_2 = vector3
  L33_2 = 1
  L33_2 = L33_2 - L28_2
  L34_2 = 1
  L34_2 = L34_2 - L29_2
  L33_2 = L33_2 * L34_2
  L34_2 = L2_2.x
  L33_2 = L33_2 * L34_2
  L34_2 = 1
  L34_2 = L34_2 - L29_2
  L34_2 = L28_2 * L34_2
  L35_2 = L3_2.x
  L34_2 = L34_2 * L35_2
  L33_2 = L33_2 + L34_2
  L34_2 = L28_2 * L29_2
  L35_2 = L4_2.x
  L34_2 = L34_2 * L35_2
  L33_2 = L33_2 + L34_2
  L34_2 = 1
  L34_2 = L34_2 - L28_2
  L34_2 = L34_2 * L29_2
  L35_2 = L5_2.x
  L34_2 = L34_2 * L35_2
  L33_2 = L33_2 + L34_2
  L34_2 = 1
  L34_2 = L34_2 - L28_2
  L35_2 = 1
  L35_2 = L35_2 - L29_2
  L34_2 = L34_2 * L35_2
  L35_2 = L2_2.y
  L34_2 = L34_2 * L35_2
  L35_2 = 1
  L35_2 = L35_2 - L29_2
  L35_2 = L28_2 * L35_2
  L36_2 = L3_2.y
  L35_2 = L35_2 * L36_2
  L34_2 = L34_2 + L35_2
  L35_2 = L28_2 * L29_2
  L36_2 = L4_2.y
  L35_2 = L35_2 * L36_2
  L34_2 = L34_2 + L35_2
  L35_2 = 1
  L35_2 = L35_2 - L28_2
  L35_2 = L35_2 * L29_2
  L36_2 = L5_2.y
  L35_2 = L35_2 * L36_2
  L34_2 = L34_2 + L35_2
  L35_2 = 1
  L35_2 = L35_2 - L28_2
  L36_2 = 1
  L36_2 = L36_2 - L29_2
  L35_2 = L35_2 * L36_2
  L36_2 = L2_2.z
  L35_2 = L35_2 * L36_2
  L36_2 = 1
  L36_2 = L36_2 - L29_2
  L36_2 = L28_2 * L36_2
  L37_2 = L3_2.z
  L36_2 = L36_2 * L37_2
  L35_2 = L35_2 + L36_2
  L36_2 = L28_2 * L29_2
  L37_2 = L4_2.z
  L36_2 = L36_2 * L37_2
  L35_2 = L35_2 + L36_2
  L36_2 = 1
  L36_2 = L36_2 - L28_2
  L36_2 = L36_2 * L29_2
  L37_2 = L5_2.z
  L36_2 = L36_2 * L37_2
  L35_2 = L35_2 + L36_2
  L32_2 = L32_2(L33_2, L34_2, L35_2)
  L33_2 = A0_2.x
  L34_2 = L32_2.x
  L33_2 = L33_2 - L34_2
  L34_2 = A0_2.y
  L35_2 = L32_2.y
  L34_2 = L34_2 - L35_2
  L35_2 = A0_2.z
  L36_2 = L32_2.z
  L35_2 = L35_2 - L36_2
  L36_2 = math
  L36_2 = L36_2.sqrt
  L37_2 = L33_2 * L33_2
  L38_2 = L34_2 * L34_2
  L37_2 = L37_2 + L38_2
  L38_2 = L35_2 * L35_2
  L37_2 = L37_2 + L38_2
  L36_2 = L36_2(L37_2)
  L37_2 = Config
  L37_2 = L37_2.planeDetectionTolerance
  if L36_2 > L37_2 then
    L37_2 = nil
    L38_2 = nil
    return L37_2, L38_2
  end
  L37_2 = L28_2
  L38_2 = L29_2
  return L37_2, L38_2
end
L2_1 = 0
L3_1 = 2000
L4_1 = nil
function L5_1()
  local L0_2, L1_2, L2_2, L3_2
  L0_2 = UseCache
  L1_2 = "RaycastWashArea"
  function L2_2()
    local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3, L27_3, L28_3, L29_3, L30_3, L31_3, L32_3, L33_3, L34_3, L35_3, L36_3, L37_3
    L0_3 = Data
    L0_3 = L0_3.ped
    L0_3 = L0_3()
    L1_3 = GetEntityCoords
    L2_3 = L0_3
    L1_3 = L1_3(L2_3)
    L2_3 = GetGameplayCamCoord
    L2_3 = L2_3()
    L3_3 = GetGameplayCamRot
    L4_3 = 2
    L3_3 = L3_3(L4_3)
    L4_3 = L3_3.x
    L5_3 = math
    L5_3 = L5_3.pi
    L5_3 = L5_3 / 180.0
    L4_3 = L4_3 * L5_3
    L5_3 = L3_3.z
    L6_3 = math
    L6_3 = L6_3.pi
    L6_3 = L6_3 / 180.0
    L5_3 = L5_3 * L6_3
    L6_3 = math
    L6_3 = L6_3.sin
    L7_3 = L5_3
    L6_3 = L6_3(L7_3)
    L6_3 = -L6_3
    L7_3 = math
    L7_3 = L7_3.abs
    L8_3 = math
    L8_3 = L8_3.cos
    L9_3 = L4_3
    L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3, L27_3, L28_3, L29_3, L30_3, L31_3, L32_3, L33_3, L34_3, L35_3, L36_3, L37_3 = L8_3(L9_3)
    L7_3 = L7_3(L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3, L27_3, L28_3, L29_3, L30_3, L31_3, L32_3, L33_3, L34_3, L35_3, L36_3, L37_3)
    L6_3 = L6_3 * L7_3
    L7_3 = math
    L7_3 = L7_3.cos
    L8_3 = L5_3
    L7_3 = L7_3(L8_3)
    L8_3 = math
    L8_3 = L8_3.abs
    L9_3 = math
    L9_3 = L9_3.cos
    L10_3 = L4_3
    L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3, L27_3, L28_3, L29_3, L30_3, L31_3, L32_3, L33_3, L34_3, L35_3, L36_3, L37_3 = L9_3(L10_3)
    L8_3 = L8_3(L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3, L27_3, L28_3, L29_3, L30_3, L31_3, L32_3, L33_3, L34_3, L35_3, L36_3, L37_3)
    L7_3 = L7_3 * L8_3
    L8_3 = math
    L8_3 = L8_3.sin
    L9_3 = L4_3
    L8_3 = L8_3(L9_3)
    L9_3 = 12.0
    L10_3 = vector3
    L11_3 = L2_3.x
    L12_3 = L6_3 * L9_3
    L11_3 = L11_3 + L12_3
    L12_3 = L2_3.y
    L13_3 = L7_3 * L9_3
    L12_3 = L12_3 + L13_3
    L13_3 = L2_3.z
    L14_3 = L8_3 * L9_3
    L13_3 = L13_3 + L14_3
    L10_3 = L10_3(L11_3, L12_3, L13_3)
    L11_3 = StartShapeTestRay
    L12_3 = L2_3.x
    L13_3 = L2_3.y
    L14_3 = L2_3.z
    L15_3 = L10_3.x
    L16_3 = L10_3.y
    L17_3 = L10_3.z
    L18_3 = -1
    L19_3 = L0_3
    L20_3 = 0
    L11_3 = L11_3(L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3)
    L12_3 = GetShapeTestResult
    L13_3 = L11_3
    L12_3, L13_3, L14_3, L15_3, L16_3 = L12_3(L13_3)
    if 1 ~= L13_3 then
      L17_3 = nil
      L4_1 = L17_3
      L17_3 = nil
      return L17_3
    end
    L17_3 = Config
    L17_3 = L17_3.misc
    L17_3 = L17_3.allowObjectPushing
    if not L17_3 then
      L17_3 = Config
      L17_3 = L17_3.misc
      L17_3 = L17_3.allowNpcPushing
      if not L17_3 then
        goto lbl_110
      end
    end
    L17_3 = UseCache
    L18_3 = "applyPowerWashForce"
    function L19_3()
      local L0_4, L1_4, L2_4, L3_4, L4_4, L5_4, L6_4, L7_4, L8_4, L9_4
      L0_4 = L16_3
      if L0_4 then
        L0_4 = L16_3
        if L0_4 > 1 then
          L0_4 = Config
          L0_4 = L0_4.misc
          L0_4 = L0_4.allowObjectPushing
          if L0_4 then
            L0_4 = DoesEntityHavePhysics
            L1_4 = L16_3
            L0_4 = L0_4(L1_4)
            if L0_4 then
              L0_4 = IsEntityAnObject
              L1_4 = L16_3
              L0_4 = L0_4(L1_4)
              if L0_4 then
                L0_4 = GetEntityForwardVector
                L1_4 = PlayerPedId
                L1_4, L2_4, L3_4, L4_4, L5_4, L6_4, L7_4, L8_4, L9_4 = L1_4()
                L0_4 = L0_4(L1_4, L2_4, L3_4, L4_4, L5_4, L6_4, L7_4, L8_4, L9_4)
                L1_4 = 150
                L2_4 = IsWithinDistance
                L3_4 = GetEntityCoords
                L4_4 = PlayerPedId
                L4_4, L5_4, L6_4, L7_4, L8_4, L9_4 = L4_4()
                L3_4 = L3_4(L4_4, L5_4, L6_4, L7_4, L8_4, L9_4)
                L4_4 = L14_3
                L5_4 = 2.5
                L2_4 = L2_4(L3_4, L4_4, L5_4)
                if L2_4 then
                  L1_4 = 300
                end
                L2_4 = ApplyForceToEntityCenterOfMass
                L3_4 = L16_3
                L4_4 = 1
                L5_4 = L0_4 * L1_4
                L6_4 = 0
                L7_4 = false
                L8_4 = false
                L9_4 = true
                L2_4(L3_4, L4_4, L5_4, L6_4, L7_4, L8_4, L9_4)
            end
          end
          else
            L0_4 = Config
            L0_4 = L0_4.misc
            L0_4 = L0_4.allowNpcPushing
            if L0_4 then
              L0_4 = IsEntityAPed
              L1_4 = L16_3
              L0_4 = L0_4(L1_4)
              if L0_4 then
                L0_4 = SetPedWetnessHeight
                L1_4 = L16_3
                L2_4 = 0.5
                L0_4(L1_4, L2_4)
                L0_4 = NetworkHasControlOfEntity
                L1_4 = L16_3
                L0_4 = L0_4(L1_4)
                if L0_4 then
                  L0_4 = IsPedRagdoll
                  L0_4 = L0_4()
                  if not L0_4 then
                    L0_4 = math
                    L0_4 = L0_4.random
                    L1_4 = 0
                    L2_4 = 3
                    L0_4 = L0_4(L1_4, L2_4)
                    if 1 ~= L0_4 then
                      goto lbl_112
                    end
                  end
                  L0_4 = SetPedToRagdoll
                  L1_4 = L16_3
                  L2_4 = 1000
                  L3_4 = 2500
                  L4_4 = 0
                  L5_4 = false
                  L6_4 = true
                  L7_4 = true
                  L0_4(L1_4, L2_4, L3_4, L4_4, L5_4, L6_4, L7_4)
                  L0_4 = GetEntityForwardVector
                  L1_4 = PlayerPedId
                  L1_4, L2_4, L3_4, L4_4, L5_4, L6_4, L7_4, L8_4, L9_4 = L1_4()
                  L0_4 = L0_4(L1_4, L2_4, L3_4, L4_4, L5_4, L6_4, L7_4, L8_4, L9_4)
                  L1_4 = IsWithinDistance
                  L2_4 = GetEntityCoords
                  L3_4 = PlayerPedId
                  L3_4, L4_4, L5_4, L6_4, L7_4, L8_4, L9_4 = L3_4()
                  L2_4 = L2_4(L3_4, L4_4, L5_4, L6_4, L7_4, L8_4, L9_4)
                  L3_4 = L14_3
                  L4_4 = 3.0
                  L1_4 = L1_4(L2_4, L3_4, L4_4)
                  if L1_4 then
                    L1_4 = ApplyForceToEntityCenterOfMass
                    L2_4 = L16_3
                    L3_4 = 1
                    L4_4 = L0_4 * 300
                    L5_4 = 0
                    L6_4 = false
                    L7_4 = false
                    L8_4 = true
                    L1_4(L2_4, L3_4, L4_4, L5_4, L6_4, L7_4, L8_4)
                  end
                end
              end
            end
          end
        end
      end
      ::lbl_112::
      L0_4 = 1
      return L0_4
    end
    L20_3 = 120
    L17_3(L18_3, L19_3, L20_3)
    ::lbl_110::
    L4_1 = L14_3
    L17_3 = L14_3 - L1_3
    L17_3 = #L17_3
    L18_3 = GetGameTimer
    L18_3 = L18_3()
    L19_3 = Config
    L19_3 = L19_3.misc
    L19_3 = L19_3.allowCarCleaning
    if L19_3 and L16_3 and L16_3 > 0 then
      L19_3 = IsEntityAVehicle
      L20_3 = L16_3
      L19_3 = L19_3(L20_3)
      if L19_3 then
        L19_3 = UseCache
        L20_3 = "cleanVehicle_"
        L21_3 = L16_3
        L20_3 = L20_3 .. L21_3
        function L21_3()
          local L0_4, L1_4, L2_4, L3_4, L4_4, L5_4
          L0_4 = GetVehicleDirtLevel
          L1_4 = L16_3
          L0_4 = L0_4(L1_4)
          if L0_4 > 0.0 then
            L1_4 = 0.1
            L2_4 = math
            L2_4 = L2_4.max
            L3_4 = 0.0
            L4_4 = L0_4 - L1_4
            L2_4 = L2_4(L3_4, L4_4)
            L3_4 = SetVehicleDirtLevel
            L4_4 = L16_3
            L5_4 = L2_4
            L3_4(L4_4, L5_4)
          end
          L1_4 = 1
          return L1_4
        end
        L22_3 = 100
        L19_3(L20_3, L21_3, L22_3)
      end
    end
    L19_3 = Config
    L19_3 = L19_3.maxWashDistance
    if L17_3 > L19_3 then
      L19_3 = L2_1
      L19_3 = L18_3 - L19_3
      L20_3 = L3_1
      if L19_3 > L20_3 then
        L19_3 = Config
        L19_3 = L19_3.debug
        if L19_3 then
          L2_1 = L18_3
        end
      end
      L19_3 = nil
      return L19_3
    end
    L19_3 = {}
    L20_3 = ipairs
    L21_3 = L0_1.activeWashAreas
    L20_3, L21_3, L22_3, L23_3 = L20_3(L21_3)
    for L24_3, L25_3 in L20_3, L21_3, L22_3, L23_3 do
      L26_3 = L1_1
      L27_3 = L14_3
      L28_3 = L25_3.corners
      L26_3, L27_3 = L26_3(L27_3, L28_3)
      if L26_3 and L27_3 then
        L28_3 = math
        L28_3 = L28_3.floor
        L29_3 = L25_3.gridWidth
        L29_3 = L26_3 * L29_3
        L28_3 = L28_3(L29_3)
        L28_3 = L28_3 + 1
        L29_3 = math
        L29_3 = L29_3.floor
        L30_3 = L25_3.gridHeight
        L30_3 = L27_3 * L30_3
        L29_3 = L29_3(L30_3)
        L29_3 = L29_3 + 1
        L30_3 = L2_1
        L30_3 = L18_3 - L30_3
        L31_3 = L3_1
        if L30_3 > L31_3 then
          L30_3 = Config
          L30_3 = L30_3.debug
          if L30_3 then
            L30_3 = Debug
            L31_3 = string
            L31_3 = L31_3.format
            L32_3 = "[RaycastWashArea] UV: %.3f, %.3f -> Pixel: [%d, %d], Distance: %.2fm"
            L33_3 = L26_3
            L34_3 = L27_3
            L35_3 = L28_3
            L36_3 = L29_3
            L37_3 = L17_3
            L31_3, L32_3, L33_3, L34_3, L35_3, L36_3, L37_3 = L31_3(L32_3, L33_3, L34_3, L35_3, L36_3, L37_3)
            L30_3(L31_3, L32_3, L33_3, L34_3, L35_3, L36_3, L37_3)
            L2_1 = L18_3
          end
        end
        if L28_3 >= 1 then
          L30_3 = L25_3.gridWidth
          if L28_3 <= L30_3 and L29_3 >= 1 then
            L30_3 = L25_3.gridHeight
            if L29_3 <= L30_3 then
              L30_3 = table
              L30_3 = L30_3.insert
              L31_3 = L19_3
              L32_3 = {}
              L33_3 = L25_3.id
              L32_3.washAreaId = L33_3
              L32_3.pixelX = L28_3
              L32_3.pixelY = L29_3
              L32_3.washArea = L25_3
              L30_3(L31_3, L32_3)
            end
          end
        end
      end
    end
    L20_3 = Dummy
    if L20_3 then
      L20_3 = Dummy
      L20_3 = L20_3.OnPowerwasherHit
      if L20_3 then
        L20_3 = Dummy
        L20_3 = L20_3.OnPowerwasherHit
        L21_3 = L14_3
        L22_3 = L16_3
        L20_3(L21_3, L22_3)
      end
    end
    L20_3 = #L19_3
    if L20_3 > 0 then
      L20_3 = L19_3
      L21_3 = L17_3
      L22_3 = L14_3
      return L20_3, L21_3, L22_3
    end
    L20_3 = nil
    return L20_3
  end
  L3_2 = 30
  return L0_2(L1_2, L2_2, L3_2)
end
function L6_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2
  L4_2 = L0_1.localDelta
  L4_2 = L4_2[A0_2]
  if not L4_2 then
    L4_2 = L0_1.localDelta
    L5_2 = {}
    L4_2[A0_2] = L5_2
  end
  L4_2 = A1_2
  L5_2 = "_"
  L6_2 = A2_2
  L4_2 = L4_2 .. L5_2 .. L6_2
  L5_2 = L0_1.localDelta
  L5_2 = L5_2[A0_2]
  L5_2 = L5_2[L4_2]
  if not L5_2 then
    L5_2 = L0_1.localDelta
    L5_2 = L5_2[A0_2]
    L6_2 = {}
    L6_2.x = A1_2
    L6_2.y = A2_2
    L6_2.amount = 0
    L5_2[L4_2] = L6_2
  end
  L5_2 = L0_1.localDelta
  L5_2 = L5_2[A0_2]
  L5_2 = L5_2[L4_2]
  L6_2 = L0_1.localDelta
  L6_2 = L6_2[A0_2]
  L6_2 = L6_2[L4_2]
  L6_2 = L6_2.amount
  L6_2 = L6_2 + A3_2
  L5_2.amount = L6_2
end
function L7_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2
  L0_2 = GetGameTimer
  L0_2 = L0_2()
  L1_2 = L0_1.lastLocalSyncTime
  L1_2 = L0_2 - L1_2
  L2_2 = Config
  L2_2 = L2_2.localSyncInterval
  if L1_2 < L2_2 then
    return
  end
  L1_2 = next
  L2_2 = L0_1.localDelta
  L1_2 = L1_2(L2_2)
  if L1_2 then
    L1_2 = WashRenderer
    L1_2 = L1_2.ApplyLocalDelta
    L2_2 = L0_1.localDelta
    L1_2 = L1_2(L2_2)
    L2_2 = pairs
    L3_2 = L1_2 or L3_2
    if not L1_2 then
      L3_2 = {}
    end
    L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
    for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
      L8_2 = L0_1.serverDelta
      L8_2 = L8_2[L6_2]
      if not L8_2 then
        L8_2 = L0_1.serverDelta
        L9_2 = {}
        L8_2[L6_2] = L9_2
      end
      L8_2 = pairs
      L9_2 = L7_2
      L8_2, L9_2, L10_2, L11_2 = L8_2(L9_2)
      for L12_2, L13_2 in L8_2, L9_2, L10_2, L11_2 do
        L14_2 = L0_1.serverDelta
        L14_2 = L14_2[L6_2]
        L14_2 = L14_2[L12_2]
        if not L14_2 then
          L14_2 = L0_1.serverDelta
          L14_2 = L14_2[L6_2]
          L15_2 = {}
          L16_2 = L13_2.x
          L15_2.x = L16_2
          L16_2 = L13_2.y
          L15_2.y = L16_2
          L15_2.amount = 0
          L14_2[L12_2] = L15_2
        end
        L14_2 = L0_1.serverDelta
        L14_2 = L14_2[L6_2]
        L14_2 = L14_2[L12_2]
        L15_2 = L0_1.serverDelta
        L15_2 = L15_2[L6_2]
        L15_2 = L15_2[L12_2]
        L15_2 = L15_2.amount
        L16_2 = L13_2.amount
        L15_2 = L15_2 + L16_2
        L14_2.amount = L15_2
      end
    end
    L2_2 = {}
    L0_1.localDelta = L2_2
    L0_1.lastLocalSyncTime = L0_2
  end
end
L8_1 = 0
function L9_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2
  L0_2 = GetGameTimer
  L0_2 = L0_2()
  L1_2 = Config
  L1_2 = L1_2.syncInterval
  L2_2 = L8_1
  L2_2 = L2_2 % 5
  if 1 == L2_2 then
    L2_2 = math
    L2_2 = L2_2.floor
    L3_2 = L1_2 * 1.6
    L2_2 = L2_2(L3_2)
    L1_2 = L2_2
  end
  L2_2 = L0_1.lastServerSyncTime
  L2_2 = L0_2 - L2_2
  if L1_2 > L2_2 then
    return
  end
  L2_2 = L8_1
  L2_2 = L2_2 % 5
  if 1 == L2_2 then
    L2_2 = Debug
    L3_2 = "Added interval time for buffer"
    L2_2(L3_2)
  end
  L2_2 = L8_1
  L2_2 = L2_2 + 1
  L8_1 = L2_2
  L2_2 = next
  L3_2 = L0_1.serverDelta
  L2_2 = L2_2(L3_2)
  if L2_2 then
    L2_2 = Config
    L2_2 = L2_2.debug
    if L2_2 then
      L2_2 = 0
      L3_2 = 0
      L4_2 = pairs
      L5_2 = L0_1.serverDelta
      L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2)
      for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
        L10_2 = pairs
        L11_2 = L9_2
        L10_2, L11_2, L12_2, L13_2 = L10_2(L11_2)
        for L14_2, L15_2 in L10_2, L11_2, L12_2, L13_2 do
          L2_2 = L2_2 + 1
          L16_2 = L15_2.amount
          L3_2 = L3_2 + L16_2
        end
      end
      L4_2 = Debug
      L5_2 = string
      L5_2 = L5_2.format
      L6_2 = "[SyncCleaningData] Sending %d pixels to server, total amount: %.2f"
      L7_2 = L2_2
      L8_2 = L3_2
      L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2 = L5_2(L6_2, L7_2, L8_2)
      L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2)
    end
    L0_1.lastServerSyncTime = L0_2
    L2_2 = Config
    L2_2 = L2_2.deltaSyncMethod
    if "event" == L2_2 then
      L2_2 = TriggerServerEvent
      L3_2 = "kq_powerwashing:server:washDelta"
      L4_2 = L0_1.serverDelta
      L2_2(L3_2, L4_2)
    else
      L2_2 = LocalPlayer
      L2_2 = L2_2.state
      L3_2 = L2_2
      L2_2 = L2_2.set
      L4_2 = "washDelta"
      L5_2 = L0_1.serverDelta
      L6_2 = true
      L2_2(L3_2, L4_2, L5_2, L6_2)
    end
    L2_2 = {}
    L0_1.serverDelta = L2_2
  end
end
function L10_1(A0_2)
  local L1_2
  L1_2 = A0_2 or nil
  if not A0_2 then
    L1_2 = {}
  end
  L0_1.activeWashAreas = L1_2
  L1_2 = {}
  L0_1.localDelta = L1_2
  L1_2 = CleanExpiredCache
  if L1_2 then
    L1_2 = CleanExpiredCache
    L1_2()
  end
end
L11_1 = RegisterNetEvent
L12_1 = "kq_powerwashing:client:washAreasUpdate"
function L13_1(A0_2)
  local L1_2, L2_2
  L1_2 = L10_1
  L2_2 = A0_2
  L1_2(L2_2)
end
L11_1(L12_1, L13_1)
L11_1 = AddStateBagChangeHandler
L12_1 = "kq_powerwashing_washAreas"
L13_1 = "player:%s"
L14_1 = L13_1
L13_1 = L13_1.format
L15_1 = GetPlayerServerId
L16_1 = PlayerId
L16_1 = L16_1()
L15_1, L16_1 = L15_1(L16_1)
L13_1 = L13_1(L14_1, L15_1, L16_1)
function L14_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2
  L3_2 = L10_1
  L4_2 = A2_2
  L3_2(L4_2)
end
L11_1(L12_1, L13_1, L14_1)
L11_1 = {}
L12_1 = AddStateBagChangeHandler
L13_1 = "isPowerWashing"
L14_1 = nil
function L15_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2
  L3_2 = tonumber
  L5_2 = A0_2
  L4_2 = A0_2.match
  L6_2 = "player:(%d+)"
  L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2 = L4_2(L5_2, L6_2)
  L3_2 = L3_2(L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2)
  if L3_2 then
    L4_2 = GetPlayerServerId
    L5_2 = PlayerId
    L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2 = L5_2()
    L4_2 = L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2)
    if L3_2 ~= L4_2 then
      goto lbl_15
    end
  end
  do return end
  ::lbl_15::
  if A2_2 then
    L4_2 = GetPlayerFromServerId
    L5_2 = L3_2
    L4_2 = L4_2(L5_2)
    if -1 == L4_2 then
      return
    end
    L5_2 = GetPlayerPed
    L6_2 = L4_2
    L5_2 = L5_2(L6_2)
    L6_2 = DoesEntityExist
    L7_2 = L5_2
    L6_2 = L6_2(L7_2)
    if not L6_2 then
      return
    end
    L6_2 = GetCurrentPedWeaponEntityIndex
    L7_2 = L5_2
    L8_2 = 0
    L6_2 = L6_2(L7_2, L8_2)
    if L6_2 then
      L7_2 = DoesEntityExist
      L8_2 = L6_2
      L7_2 = L7_2(L8_2)
      if L7_2 then
        L7_2 = UseParticleFxAssetNextCall
        L8_2 = "core"
        L7_2(L8_2)
        L7_2 = L11_1
        L8_2 = StartParticleFxLoopedOnEntity
        L9_2 = "water_cannon_jet"
        L10_2 = L6_2
        L11_2 = 0.73
        L12_2 = 0.02
        L13_2 = 0.06
        L14_2 = 0.0
        L15_2 = 0.0
        L16_2 = 270.0
        L17_2 = 0.5
        L18_2 = false
        L19_2 = false
        L20_2 = false
        L8_2 = L8_2(L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2)
        L7_2[L3_2] = L8_2
      end
    end
  else
    L4_2 = L11_1
    L4_2 = L4_2[L3_2]
    if L4_2 then
      L4_2 = StopParticleFxLooped
      L5_2 = L11_1
      L5_2 = L5_2[L3_2]
      L6_2 = false
      L4_2(L5_2, L6_2)
      L4_2 = L11_1
      L4_2[L3_2] = nil
    end
  end
end
L12_1(L13_1, L14_1, L15_1)
function L12_1()
  local L0_2, L1_2
  L0_2 = Renderer
  L1_2 = GetGameTimer
  L1_2 = L1_2()
  L0_2.extraLayerLastUse = L1_2
  L0_2 = Renderer
  L1_2 = Renderer
  L1_2 = L1_2.washerVisionHintsRemaining
  L1_2 = L1_2 - 1
  L0_2.washerVisionHintsRemaining = L1_2
  L0_2 = Citizen
  L0_2 = L0_2.CreateThread
  function L1_2()
    local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3
    L0_3 = GetGameTimer
    L0_3 = L0_3()
    L1_3 = 35
    L2_3 = 35
    L3_3 = 30
    L4_3 = 250
    L5_3 = 0
    while true do
      L6_3 = GetGameTimer
      L6_3 = L6_3()
      L6_3 = L6_3 - L0_3
      L7_3 = 1300
      if not (L6_3 < L7_3) then
        break
      end
      while true do
        L6_3 = Renderer
        L6_3 = L6_3.extraLayerOpacity
        if not (L4_3 > L6_3) then
          break
        end
        L6_3 = GetGameTimer
        L6_3 = L6_3()
        L6_3 = L6_3 - L0_3
        L7_3 = 1300
        if not (L6_3 < L7_3) then
          break
        end
        L6_3 = Renderer
        L7_3 = math
        L7_3 = L7_3.min
        L8_3 = L4_3
        L9_3 = Renderer
        L9_3 = L9_3.extraLayerOpacity
        L9_3 = L9_3 + L1_3
        L7_3 = L7_3(L8_3, L9_3)
        L6_3.extraLayerOpacity = L7_3
        L6_3 = Citizen
        L6_3 = L6_3.Wait
        L7_3 = L3_3
        L6_3(L7_3)
      end
      L6_3 = Citizen
      L6_3 = L6_3.Wait
      L7_3 = 250
      L6_3(L7_3)
      while true do
        L6_3 = Renderer
        L6_3 = L6_3.extraLayerOpacity
        if not (L5_3 < L6_3) then
          break
        end
        L6_3 = GetGameTimer
        L6_3 = L6_3()
        L6_3 = L6_3 - L0_3
        L7_3 = 1300
        if not (L6_3 < L7_3) then
          break
        end
        L6_3 = Renderer
        L7_3 = math
        L7_3 = L7_3.max
        L8_3 = L5_3
        L9_3 = Renderer
        L9_3 = L9_3.extraLayerOpacity
        L9_3 = L9_3 - L2_3
        L7_3 = L7_3(L8_3, L9_3)
        L6_3.extraLayerOpacity = L7_3
        L6_3 = Citizen
        L6_3 = L6_3.Wait
        L7_3 = L3_3
        L6_3(L7_3)
      end
    end
    L6_3 = Renderer
    L6_3.extraLayerOpacity = L4_3
    L6_3 = 12
    L7_3 = 35
    while true do
      L8_3 = Renderer
      L8_3 = L8_3.extraLayerOpacity
      if not (L8_3 > 0) then
        break
      end
      L8_3 = Renderer
      L9_3 = math
      L9_3 = L9_3.max
      L10_3 = 0
      L11_3 = Renderer
      L11_3 = L11_3.extraLayerOpacity
      L11_3 = L11_3 - L6_3
      L9_3 = L9_3(L10_3, L11_3)
      L8_3.extraLayerOpacity = L9_3
      L8_3 = Citizen
      L8_3 = L8_3.Wait
      L9_3 = L7_3
      L8_3(L9_3)
    end
  end
  L0_2(L1_2)
end
L13_1 = Citizen
L13_1 = L13_1.CreateThread
function L14_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2
  while true do
    L0_2 = 2500
    L1_2 = GetCurrentWeapon
    L1_2 = L1_2()
    L2_2 = GetHashKey
    L3_2 = Config
    L3_2 = L3_2.powerWasherWeapon
    L2_2 = L2_2(L3_2)
    if L1_2 == L2_2 then
      L0_2 = 1
      L2_2 = DisableControlAction
      L3_2 = 0
      L4_2 = 24
      L5_2 = true
      L2_2(L3_2, L4_2, L5_2)
      L2_2 = DisableControlAction
      L3_2 = 0
      L4_2 = 45
      L5_2 = true
      L2_2(L3_2, L4_2, L5_2)
      L2_2 = DisableControlAction
      L3_2 = 0
      L4_2 = 53
      L5_2 = true
      L2_2(L3_2, L4_2, L5_2)
      L2_2 = DisableControlAction
      L3_2 = 0
      L4_2 = 69
      L5_2 = true
      L2_2(L3_2, L4_2, L5_2)
      L2_2 = IsControlPressed
      L3_2 = 0
      L4_2 = 25
      L5_2 = true
      L2_2 = L2_2(L3_2, L4_2, L5_2)
      if L2_2 then
        L2_2 = DisableControlAction
        L3_2 = 0
        L4_2 = 142
        L5_2 = true
        L2_2(L3_2, L4_2, L5_2)
        L2_2 = DisableControlAction
        L3_2 = 0
        L4_2 = 257
        L5_2 = true
        L2_2(L3_2, L4_2, L5_2)
      end
      L2_2 = Config
      L2_2 = L2_2.dirtHighlight
      L2_2 = L2_2.enabled
      if L2_2 then
        L2_2 = IsDisabledControlPressed
        L3_2 = 0
        L4_2 = 45
        L2_2 = L2_2(L3_2, L4_2)
        if L2_2 then
          L2_2 = Renderer
          if L2_2 then
            L2_2 = Renderer
            L2_2 = L2_2.extraLayerLastUse
            if not L2_2 then
              L2_2 = 0
            end
            L3_2 = Config
            L3_2 = L3_2.dirtHighlight
            L3_2 = L3_2.cooldown
            if not L3_2 then
              L3_2 = 9000
            end
            L2_2 = L2_2 + L3_2
            L3_2 = GetGameTimer
            L3_2 = L3_2()
            if L2_2 < L3_2 then
              L2_2 = Renderer
              L3_2 = GetGameTimer
              L3_2 = L3_2()
              L2_2.extraLayerLastUse = L3_2
              L2_2 = L12_1
              L2_2()
            end
          end
        end
      end
    end
    L2_2 = Citizen
    L2_2 = L2_2.Wait
    L3_2 = L0_2
    L2_2(L3_2)
  end
end
L13_1(L14_1)
L13_1 = CreateThread
function L14_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2, L27_2, L28_2, L29_2, L30_2, L31_2, L32_2, L33_2, L34_2, L35_2, L36_2, L37_2, L38_2, L39_2, L40_2, L41_2, L42_2, L43_2, L44_2
  L0_2 = 0
  L1_2 = 2000
  while true do
    L2_2 = 2500
    L3_2 = GetCurrentWeapon
    L3_2 = L3_2()
    L4_2 = GetGameTimer
    L4_2 = L4_2()
    L5_2 = GetHashKey
    L6_2 = Config
    L6_2 = L6_2.powerWasherWeapon
    L5_2 = L5_2(L6_2)
    if L3_2 == L5_2 then
      L2_2 = 500
      L5_2 = IsDisabledControlPressed
      L6_2 = 0
      L7_2 = 24
      L5_2 = L5_2(L6_2, L7_2)
      if L5_2 then
        L5_2 = IsPauseMenuActive
        L5_2 = L5_2()
        if not L5_2 then
          L5_2 = CONTRACT_ACTIVE
          if not L5_2 then
            L5_2 = Config
            L5_2 = L5_2.disablePowerwasherOutsideOfJob
            if L5_2 then
              goto lbl_245
            end
          end
          L2_2 = 25
          L5_2 = WaterTank
          L6_2 = L5_2
          L5_2 = L5_2.HasWater
          L5_2 = L5_2(L6_2)
          if not L5_2 then
            L5_2 = L0_1.isCleaning
            if L5_2 then
              L0_1.isCleaning = false
              L5_2 = LocalPlayer
              L5_2 = L5_2.state
              L6_2 = L5_2
              L5_2 = L5_2.set
              L7_2 = "isPowerWashing"
              L8_2 = false
              L9_2 = true
              L5_2(L6_2, L7_2, L8_2, L9_2)
              L5_2 = L0_1.particleFx
              if L5_2 then
                L5_2 = StopParticleFxLooped
                L6_2 = L0_1.particleFx
                L7_2 = false
                L5_2(L6_2, L7_2)
                L0_1.particleFx = nil
              end
            end
          else
            L5_2 = WaterTank
            L6_2 = L5_2
            L5_2 = L5_2.Drain
            L5_2(L6_2)
            L5_2 = L0_1.isCleaning
            if not L5_2 then
              L0_1.isCleaning = true
              L5_2 = LocalPlayer
              L5_2 = L5_2.state
              L6_2 = L5_2
              L5_2 = L5_2.set
              L7_2 = "isPowerWashing"
              L8_2 = true
              L9_2 = true
              L5_2(L6_2, L7_2, L8_2, L9_2)
              L5_2 = UseParticleFxAssetNextCall
              L6_2 = "core"
              L5_2(L6_2)
              L5_2 = StartNetworkedParticleFxLoopedOnEntity
              L6_2 = "water_cannon_jet"
              L7_2 = GetPlayerPedWeapon
              L7_2 = L7_2()
              L8_2 = 0.73
              L9_2 = 0.02
              L10_2 = 0.06
              L11_2 = 0.0
              L12_2 = 0.0
              L13_2 = 270.0
              L14_2 = 0.5
              L15_2 = false
              L16_2 = false
              L17_2 = false
              L5_2 = L5_2(L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2)
              L0_1.particleFx = L5_2
            end
            L5_2 = L5_1
            L5_2, L6_2, L7_2 = L5_2()
            if L5_2 and L7_2 then
              L8_2 = UseParticleFxAssetNextCall
              L9_2 = "core"
              L8_2(L9_2)
              L8_2 = StartParticleFxNonLoopedAtCoord
              L9_2 = "ent_dst_gen_water_spray"
              L10_2 = L7_2.x
              L11_2 = L7_2.y
              L12_2 = L7_2.z
              L13_2 = 0.0
              L14_2 = 0.0
              L15_2 = 0.0
              L16_2 = 0.7
              L17_2 = false
              L18_2 = false
              L19_2 = false
              L8_2(L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2)
              L8_2 = GetFrameTime
              L8_2 = L8_2()
              L9_2 = Config
              L9_2 = L9_2.minCleanDistance
              L9_2 = L6_2 - L9_2
              L10_2 = Config
              L10_2 = L10_2.maxCleanDistance
              L11_2 = Config
              L11_2 = L11_2.minCleanDistance
              L10_2 = L10_2 - L11_2
              L9_2 = L9_2 / L10_2
              L10_2 = math
              L10_2 = L10_2.max
              L11_2 = 0
              L12_2 = math
              L12_2 = L12_2.min
              L13_2 = 1
              L14_2 = L9_2
              L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2, L27_2, L28_2, L29_2, L30_2, L31_2, L32_2, L33_2, L34_2, L35_2, L36_2, L37_2, L38_2, L39_2, L40_2, L41_2, L42_2, L43_2, L44_2 = L12_2(L13_2, L14_2)
              L10_2 = L10_2(L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2, L27_2, L28_2, L29_2, L30_2, L31_2, L32_2, L33_2, L34_2, L35_2, L36_2, L37_2, L38_2, L39_2, L40_2, L41_2, L42_2, L43_2, L44_2)
              L9_2 = L10_2
              L10_2 = math
              L10_2 = L10_2.pow
              L11_2 = 1.0
              L11_2 = L11_2 - L9_2
              L12_2 = Config
              L12_2 = L12_2.distanceFalloffPower
              L10_2 = L10_2(L11_2, L12_2)
              L11_2 = Config
              L11_2 = L11_2.cleaningRate
              L11_2 = L11_2 * L8_2
              L11_2 = L11_2 * L10_2
              L12_2 = ipairs
              L13_2 = L5_2
              L12_2, L13_2, L14_2, L15_2 = L12_2(L13_2)
              for L16_2, L17_2 in L12_2, L13_2, L14_2, L15_2 do
                L18_2 = L17_2.washArea
                L19_2 = L17_2.washAreaId
                L20_2 = L17_2.pixelX
                L21_2 = L17_2.pixelY
                L22_2 = L18_2.pixelSize
                if not L22_2 then
                  L22_2 = Debug
                  L23_2 = "[WashCleaner] ERROR: washArea.pixelSize is nil! WashArea data:"
                  L24_2 = json
                  L24_2 = L24_2.encode
                  L25_2 = L18_2
                  L24_2, L25_2, L26_2, L27_2, L28_2, L29_2, L30_2, L31_2, L32_2, L33_2, L34_2, L35_2, L36_2, L37_2, L38_2, L39_2, L40_2, L41_2, L42_2, L43_2, L44_2 = L24_2(L25_2)
                  L22_2(L23_2, L24_2, L25_2, L26_2, L27_2, L28_2, L29_2, L30_2, L31_2, L32_2, L33_2, L34_2, L35_2, L36_2, L37_2, L38_2, L39_2, L40_2, L41_2, L42_2, L43_2, L44_2)
                else
                  L22_2 = L18_2.cleaningMultiplier
                  if not L22_2 then
                    L22_2 = 1.0
                  end
                  L23_2 = Config
                  L23_2 = L23_2.minCleanRadiusMeters
                  L24_2 = Config
                  L24_2 = L24_2.maxCleanRadiusMeters
                  L25_2 = Config
                  L25_2 = L25_2.minCleanRadiusMeters
                  L24_2 = L24_2 - L25_2
                  L24_2 = L24_2 * L9_2
                  L23_2 = L23_2 + L24_2
                  L24_2 = L23_2 * L22_2
                  L25_2 = math
                  L25_2 = L25_2.max
                  L26_2 = 0
                  L27_2 = math
                  L27_2 = L27_2.floor
                  L28_2 = L18_2.pixelSize
                  L28_2 = L24_2 / L28_2
                  L27_2, L28_2, L29_2, L30_2, L31_2, L32_2, L33_2, L34_2, L35_2, L36_2, L37_2, L38_2, L39_2, L40_2, L41_2, L42_2, L43_2, L44_2 = L27_2(L28_2)
                  L25_2 = L25_2(L26_2, L27_2, L28_2, L29_2, L30_2, L31_2, L32_2, L33_2, L34_2, L35_2, L36_2, L37_2, L38_2, L39_2, L40_2, L41_2, L42_2, L43_2, L44_2)
                  L26_2 = L25_2 + 1
                  L27_2 = -L25_2
                  L28_2 = L25_2
                  L29_2 = 1
                  for L30_2 = L27_2, L28_2, L29_2 do
                    L31_2 = L30_2 * L30_2
                    L32_2 = -L25_2
                    L33_2 = L25_2
                    L34_2 = 1
                    for L35_2 = L32_2, L33_2, L34_2 do
                      L36_2 = L35_2 * L35_2
                      L36_2 = L31_2 + L36_2
                      L37_2 = L25_2 * L25_2
                      if L36_2 <= L37_2 then
                        L37_2 = math
                        L37_2 = L37_2.sqrt
                        L38_2 = L36_2
                        L37_2 = L37_2(L38_2)
                        L38_2 = L37_2 / L26_2
                        L39_2 = 1.0
                        L38_2 = L39_2 - L38_2
                        L39_2 = L11_2 * L38_2
                        L39_2 = L39_2 * L22_2
                        L40_2 = L6_1
                        L41_2 = L19_2
                        L42_2 = L20_2 + L30_2
                        L43_2 = L21_2 + L35_2
                        L44_2 = L39_2
                        L40_2(L41_2, L42_2, L43_2, L44_2)
                      end
                    end
                  end
                end
              end
            end
          end
      end
      ::lbl_245::
      else
        L5_2 = L0_1.isCleaning
        if L5_2 then
          L0_1.isCleaning = false
          L5_2 = LocalPlayer
          L5_2 = L5_2.state
          L6_2 = L5_2
          L5_2 = L5_2.set
          L7_2 = "isPowerWashing"
          L8_2 = false
          L9_2 = true
          L5_2(L6_2, L7_2, L8_2, L9_2)
          L5_2 = L0_1.particleFx
          if L5_2 then
            L5_2 = StopParticleFxLooped
            L6_2 = L0_1.particleFx
            L7_2 = false
            L5_2(L6_2, L7_2)
            L0_1.particleFx = nil
          end
          L5_2 = Debug
          L6_2 = "[WashCleaner] Stopped cleaning"
          L5_2(L6_2)
        end
      end
      L5_2 = L7_1
      L5_2()
      L5_2 = L9_1
      L5_2()
    else
      L5_2 = L4_2 - L0_2
      if L1_2 < L5_2 then
        L5_2 = Config
        L5_2 = L5_2.debug
        if L5_2 then
          L5_2 = GetHashKey
          L6_2 = "WEAPON_UNARMED"
          L5_2 = L5_2(L6_2)
          if L3_2 ~= L5_2 then
            L5_2 = Debug
            L6_2 = "[WashCleaner] Different weapon equipped: "
            L7_2 = L3_2
            L8_2 = " (expected: "
            L9_2 = Config
            L9_2 = L9_2.powerWasherWeapon
            L10_2 = ")"
            L6_2 = L6_2 .. L7_2 .. L8_2 .. L9_2 .. L10_2
            L5_2(L6_2)
          end
          L0_2 = L4_2
        end
      end
      L5_2 = L0_1.isCleaning
      if L5_2 then
        L0_1.isCleaning = false
        L5_2 = LocalPlayer
        L5_2 = L5_2.state
        L6_2 = L5_2
        L5_2 = L5_2.set
        L7_2 = "isPowerWashing"
        L8_2 = false
        L9_2 = true
        L5_2(L6_2, L7_2, L8_2, L9_2)
        L5_2 = L0_1.particleFx
        if L5_2 then
          L5_2 = StopParticleFxLooped
          L6_2 = L0_1.particleFx
          L7_2 = false
          L5_2(L6_2, L7_2)
          L0_1.particleFx = nil
        end
      end
    end
    L5_2 = Citizen
    L5_2 = L5_2.Wait
    L6_2 = L2_2
    L5_2(L6_2)
  end
end
L13_1(L14_1)
