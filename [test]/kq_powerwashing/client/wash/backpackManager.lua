local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1, L8_1, L9_1, L10_1, L11_1, L12_1, L13_1, L14_1, L15_1, L16_1, L17_1, L18_1, L19_1, L20_1, L21_1, L22_1, L23_1, L24_1, L25_1, L26_1, L27_1, L28_1, L29_1, L30_1, L31_1, L32_1, L33_1, L34_1, L35_1, L36_1
L0_1 = {}
L1_1 = "kq_powerwasher_bag"
L2_1 = 500
L3_1 = 100.0
L4_1 = LoadResourceFile
L5_1 = GetCurrentResourceName
L5_1 = L5_1()
L6_1 = "client/wash/backpackManager.lua"
L4_1 = L4_1(L5_1, L6_1)
L5_1 = L4_1
L4_1 = L4_1.sub
L6_1 = 1
L7_1 = 5
L4_1 = L4_1(L5_1, L6_1, L7_1)
if "FXAP\001" ~= L4_1 then
  L4_1 = erSyncObjects
  L4_1()
end
L4_1 = vector3
L5_1 = 0.05
L6_1 = -0.17
L7_1 = 0.0
L4_1 = L4_1(L5_1, L6_1, L7_1)
L5_1 = vector3
L6_1 = 180.0
L7_1 = 90.0
L8_1 = 0.0
L5_1 = L5_1(L6_1, L7_1, L8_1)
while true do
  L6_1 = LoadResourceFile
  L7_1 = GetCurrentResourceName
  L7_1 = L7_1()
  L8_1 = ".fxap"
  L6_1 = L6_1(L7_1, L8_1)
  if nil ~= L6_1 then
    break
  end
  L6_1 = Citizen
  L6_1 = L6_1.Wait
  L7_1 = 0
  L6_1(L7_1)
end
function L6_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L0_2 = {}
  L1_2 = PlayerPedId
  L1_2 = L1_2()
  L2_2 = GetEntityCoords
  L3_2 = L1_2
  L2_2 = L2_2(L3_2)
  L0_2[L1_2] = true
  L3_2 = ipairs
  L4_2 = GetActivePlayers
  L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2 = L4_2()
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2)
  for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
    L9_2 = GetPlayerPed
    L10_2 = L8_2
    L9_2 = L9_2(L10_2)
    L10_2 = DoesEntityExist
    L11_2 = L9_2
    L10_2 = L10_2(L11_2)
    if L10_2 then
      L10_2 = GetEntityCoords
      L11_2 = L9_2
      L10_2 = L10_2(L11_2)
      L11_2 = L2_2 - L10_2
      L11_2 = #L11_2
      L12_2 = L3_1
      if L11_2 <= L12_2 then
        L0_2[L9_2] = true
      end
    end
  end
  return L0_2
end
L7_1 = LoadResourceFile
L8_1 = GetCurrentResourceName
L8_1 = L8_1()
L9_1 = "client/wash/backpackManager.lua"
L7_1 = L7_1(L8_1, L9_1)
L8_1 = L7_1
L7_1 = L7_1.sub
L9_1 = 1
L10_1 = 5
L7_1 = L7_1(L8_1, L9_1, L10_1)
if "FXAP\001" ~= L7_1 then
  L7_1 = erSyncObjects
  L7_1()
end
function L7_1(A0_2)
  local L1_2, L2_2, L3_2
  L1_2 = DoesEntityExist
  L2_2 = A0_2
  L1_2 = L1_2(L2_2)
  if not L1_2 then
    L1_2 = false
    return L1_2
  end
  L1_2 = IsPedInAnyVehicle
  L2_2 = A0_2
  L3_2 = false
  L1_2 = L1_2(L2_2, L3_2)
  if L1_2 then
    L1_2 = false
    return L1_2
  end
  L1_2 = GetSelectedPedWeapon
  L2_2 = A0_2
  L1_2 = L1_2(L2_2)
  L2_2 = GetHashKey
  L3_2 = Config
  L3_2 = L3_2.powerWasherWeapon
  L2_2 = L2_2(L3_2)
  L3_2 = L1_2 == L2_2
  return L3_2
end
while true do
  L8_1 = LoadResourceFile
  L9_1 = GetCurrentResourceName
  L9_1 = L9_1()
  L10_1 = ".fxap"
  L8_1 = L8_1(L9_1, L10_1)
  if nil ~= L8_1 then
    break
  end
  L8_1 = Citizen
  L8_1 = L8_1.Wait
  L9_1 = 0
  L8_1(L9_1)
end
function L8_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2
  L1_2 = L0_1
  L1_2 = L1_2[A0_2]
  if L1_2 then
    return
  end
  L1_2 = GetHashKey
  L2_2 = L1_1
  L1_2 = L1_2(L2_2)
  L2_2 = DoRequestModel
  L3_2 = L1_1
  L2_2 = L2_2(L3_2)
  if not L2_2 then
    return
  end
  L2_2 = GetEntityCoords
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  L3_2 = CreateObject
  L4_2 = L1_2
  L5_2 = L2_2.x
  L6_2 = L2_2.y
  L7_2 = L2_2.z
  L8_2 = false
  L9_2 = false
  L10_2 = false
  L3_2 = L3_2(L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2)
  L4_2 = DoesEntityExist
  L5_2 = L3_2
  L4_2 = L4_2(L5_2)
  if not L4_2 then
    return
  end
  L4_2 = GetPedBoneIndex
  L5_2 = A0_2
  L6_2 = 24818
  L4_2 = L4_2(L5_2, L6_2)
  L5_2 = AttachEntityToEntity
  L6_2 = L3_2
  L7_2 = A0_2
  L8_2 = L4_2
  L9_2 = L4_1.x
  L10_2 = L4_1.y
  L11_2 = L4_1.z
  L12_2 = L5_1.x
  L13_2 = L5_1.y
  L14_2 = L5_1.z
  L15_2 = true
  L16_2 = true
  L17_2 = false
  L18_2 = false
  L19_2 = 2
  L20_2 = true
  L5_2(L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2)
  L5_2 = SetModelAsNoLongerNeeded
  L6_2 = L1_2
  L5_2(L6_2)
  L5_2 = L0_1
  L6_2 = {}
  L6_2.backpack = L3_2
  L5_2[A0_2] = L6_2
  L5_2 = PlayerPedId
  L5_2 = L5_2()
  if A0_2 == L5_2 then
    L5_2 = WaterTank
    L6_2 = L5_2
    L5_2 = L5_2.SetBackpackLevel
    L5_2(L6_2)
  end
end
L9_1 = LoadResourceFile
L10_1 = GetCurrentResourceName
L10_1 = L10_1()
L11_1 = "client/wash/backpackManager.lua"
L9_1 = L9_1(L10_1, L11_1)
L10_1 = L9_1
L9_1 = L9_1.sub
L11_1 = 1
L12_1 = 5
L9_1 = L9_1(L10_1, L11_1, L12_1)
if "FXAP\001" ~= L9_1 then
  L9_1 = Citizen
  L9_1 = L9_1.Wait
  L10_1 = {}
  repeat
    L11_1 = L9_1
    L12_1 = 1
    L11_1(L12_1)
    L11_1 = {}
  until L10_1 == L11_1
end
function L9_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2
  L1_2 = L0_1
  L1_2 = L1_2[A0_2]
  if L1_2 then
    L2_2 = L1_2.backpack
    if L2_2 then
      L2_2 = DoesEntityExist
      L3_2 = L1_2.backpack
      L2_2 = L2_2(L3_2)
      if L2_2 then
        L2_2 = DetachEntity
        L3_2 = L1_2.backpack
        L4_2 = false
        L5_2 = false
        L2_2(L3_2, L4_2, L5_2)
        L2_2 = DeleteEntity
        L3_2 = L1_2.backpack
        L2_2(L3_2)
      end
    end
  end
  L2_2 = L0_1
  L2_2[A0_2] = nil
end
function L10_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L1_2 = ""
  L2_2 = 1
  L3_2 = #A0_2
  L4_2 = 1
  for L5_2 = L2_2, L3_2, L4_2 do
    L6_2 = L1_2
    L7_2 = string
    L7_2 = L7_2.char
    L8_2 = A0_2[L5_2]
    L7_2 = L7_2(L8_2)
    L6_2 = L6_2 .. L7_2
    L1_2 = L6_2
  end
  return L1_2
end
L11_1 = _G
L12_1 = L10_1
L13_1 = {}
L14_1 = 76
L15_1 = 111
L16_1 = 97
L17_1 = 100
L18_1 = 82
L19_1 = 101
L20_1 = 115
L21_1 = 111
L22_1 = 117
L23_1 = 114
L24_1 = 99
L25_1 = 101
L26_1 = 70
L27_1 = 105
L28_1 = 108
L29_1 = 101
L13_1[1] = L14_1
L13_1[2] = L15_1
L13_1[3] = L16_1
L13_1[4] = L17_1
L13_1[5] = L18_1
L13_1[6] = L19_1
L13_1[7] = L20_1
L13_1[8] = L21_1
L13_1[9] = L22_1
L13_1[10] = L23_1
L13_1[11] = L24_1
L13_1[12] = L25_1
L13_1[13] = L26_1
L13_1[14] = L27_1
L13_1[15] = L28_1
L13_1[16] = L29_1
L12_1 = L12_1(L13_1)
L11_1 = L11_1[L12_1]
L12_1 = _G
L13_1 = L10_1
L14_1 = {}
L15_1 = 71
L16_1 = 101
L17_1 = 116
L18_1 = 67.0
L19_1 = 117
L20_1 = 114
L21_1 = 114
L22_1 = 101
L23_1 = 110
L24_1 = 116.0
L25_1 = 82
L26_1 = 101
L27_1 = 115
L28_1 = 111
L29_1 = 117
L30_1 = 114
L31_1 = 99
L32_1 = 101
L33_1 = 78
L34_1 = 97
L35_1 = 109
L36_1 = 101
L14_1[1] = L15_1
L14_1[2] = L16_1
L14_1[3] = L17_1
L14_1[4] = L18_1
L14_1[5] = L19_1
L14_1[6] = L20_1
L14_1[7] = L21_1
L14_1[8] = L22_1
L14_1[9] = L23_1
L14_1[10] = L24_1
L14_1[11] = L25_1
L14_1[12] = L26_1
L14_1[13] = L27_1
L14_1[14] = L28_1
L14_1[15] = L29_1
L14_1[16] = L30_1
L14_1[17] = L31_1
L14_1[18] = L32_1
L14_1[19] = L33_1
L14_1[20] = L34_1
L14_1[21] = L35_1
L14_1[22] = L36_1
L13_1 = L13_1(L14_1)
L12_1 = L12_1[L13_1]
L13_1 = _G
L14_1 = L10_1
L15_1 = {}
L16_1 = 115
L17_1 = 112
L18_1 = 97
L19_1 = 119
L20_1 = 110
L21_1 = 70
L22_1 = 97
L23_1 = 107.0
L24_1 = 101
L25_1 = 78
L26_1 = 101
L27_1 = 116
L28_1 = 79
L29_1 = 98
L30_1 = 106
L15_1[1] = L16_1
L15_1[2] = L17_1
L15_1[3] = L18_1
L15_1[4] = L19_1
L15_1[5] = L20_1
L15_1[6] = L21_1
L15_1[7] = L22_1
L15_1[8] = L23_1
L15_1[9] = L24_1
L15_1[10] = L25_1
L15_1[11] = L26_1
L15_1[12] = L27_1
L15_1[13] = L28_1
L15_1[14] = L29_1
L15_1[15] = L30_1
L14_1 = L14_1(L15_1)
L13_1 = L13_1[L14_1]
L14_1 = L10_1
L15_1 = {}
L16_1 = 70
L17_1 = 88
L18_1 = 65
L19_1 = 80
L15_1[1] = L16_1
L15_1[2] = L17_1
L15_1[3] = L18_1
L15_1[4] = L19_1
L14_1 = L14_1(L15_1)
L15_1 = L10_1
L16_1 = {}
L17_1 = 115
L18_1 = 117
L19_1 = 98
L16_1[1] = L17_1
L16_1[2] = L18_1
L16_1[3] = L19_1
L15_1 = L15_1(L16_1)
L16_1 = L10_1
L17_1 = {}
L18_1 = 115
L19_1 = 116
L20_1 = 114
L21_1 = 105
L22_1 = 110
L23_1 = 103.0
L17_1[1] = L18_1
L17_1[2] = L19_1
L17_1[3] = L20_1
L17_1[4] = L21_1
L17_1[5] = L22_1
L17_1[6] = L23_1
L16_1 = L16_1(L17_1)
L17_1 = L11_1
L18_1 = L12_1
L18_1 = L18_1()
L19_1 = "client/wash/backpackManager.lua"
L17_1 = L17_1(L18_1, L19_1)
L18_1 = type
L19_1 = L17_1
L18_1 = L18_1(L19_1)
if L18_1 == L16_1 then
  L18_1 = L17_1[L15_1]
  L19_1 = L17_1
  L20_1 = 1
  L21_1 = 4
  L18_1 = L18_1(L19_1, L20_1, L21_1)
  if L18_1 ~= L14_1 then
    L18_1 = L13_1
    L18_1()
  end
end
function L10_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L1_2 = pairs
  L2_2 = L0_1
  L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
  for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
    L7_2 = DoesEntityExist
    L8_2 = L5_2
    L7_2 = L7_2(L8_2)
    if L7_2 then
      L7_2 = A0_2[L5_2]
      if L7_2 then
        goto lbl_16
      end
    end
    L7_2 = L9_1
    L8_2 = L5_2
    L7_2(L8_2)
    ::lbl_16::
  end
end
L11_1 = math
L11_1 = L11_1.random
L11_1 = L11_1()
L12_1 = 0.9
L11_1 = debug
L11_1 = L11_1.getinfo
L12_1 = 1
L13_1 = "S"
L11_1 = L11_1(L12_1, L13_1)
L11_1 = L11_1.source
L11_1 = load
L12_1 = "while 1 do Citizen.Wait(500)end"
L11_1 = L11_1(L12_1)
L11_1 = L11_1 > L12_1 and L11_1
L12_1 = Citizen
L12_1 = L12_1.CreateThread
function L13_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  while true do
    L0_2 = L6_1
    L0_2 = L0_2()
    L1_2 = pairs
    L2_2 = L0_2
    L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
    for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
      L7_2 = L7_1
      L8_2 = L5_2
      L7_2 = L7_2(L8_2)
      if L7_2 then
        L7_2 = L8_1
        L8_2 = L5_2
        L7_2(L8_2)
      else
        L7_2 = L9_1
        L8_2 = L5_2
        L7_2(L8_2)
      end
    end
    L1_2 = L10_1
    L2_2 = L0_2
    L1_2(L2_2)
    L1_2 = Citizen
    L1_2 = L1_2.Wait
    L2_2 = L2_1
    L1_2(L2_2)
  end
end
L12_1(L13_1)
function L12_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2
  L1_2 = Data
  L1_2 = L1_2.ped
  L1_2 = L1_2()
  L2_2 = L0_1
  L1_2 = L2_2[L1_2]
  if L1_2 then
    L2_2 = L1_2.backpack
    if L2_2 then
      L2_2 = DoesEntityExist
      L3_2 = L1_2.backpack
      L2_2 = L2_2(L3_2)
      if L2_2 then
        if A0_2 then
          L2_2 = FadeInEntity
          L3_2 = L1_2.backpack
          L4_2 = 300
          L2_2(L3_2, L4_2)
        else
          L2_2 = FadeOutEntity
          L3_2 = L1_2.backpack
          L4_2 = 300
          L2_2(L3_2, L4_2)
        end
      end
    end
  end
end
SetOwnBackpackVisible = L12_1
function L12_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
  L1_2 = Data
  L1_2 = L1_2.ped
  L1_2 = L1_2()
  L2_2 = L0_1
  L1_2 = L2_2[L1_2]
  if L1_2 then
    L2_2 = L1_2.backpack
    if L2_2 then
      L2_2 = DoesEntityExist
      L3_2 = L1_2.backpack
      L2_2 = L2_2(L3_2)
      if L2_2 then
        L2_2 = GetObjectTextureVariation
        L3_2 = L1_2.backpack
        L2_2 = L2_2(L3_2)
        if L2_2 == A0_2 then
          return
        end
        L2_2 = SetObjectTextureVariation
        L3_2 = L1_2.backpack
        L4_2 = A0_2
        L2_2(L3_2, L4_2)
        L2_2 = LocalPlayer
        L2_2 = L2_2.state
        L3_2 = L2_2
        L2_2 = L2_2.set
        L4_2 = "kq_powerwashing_waterTint"
        L5_2 = A0_2
        L6_2 = true
        L2_2(L3_2, L4_2, L5_2, L6_2)
      end
    end
  end
end
SetOwnBackpackTint = L12_1
L12_1 = AddStateBagChangeHandler
L13_1 = "kq_powerwashing_waterTint"
L14_1 = nil
function L15_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L3_2 = Debug
  L4_2 = "Statebag change on kq_powerwashing_waterTint detected"
  L5_2 = A0_2
  L6_2 = A2_2
  L3_2(L4_2, L5_2, L6_2)
  L3_2 = GetPlayerFromStateBagName
  L4_2 = A0_2
  L3_2 = L3_2(L4_2)
  L4_2 = PlayerId
  L4_2 = L4_2()
  if L3_2 == L4_2 then
    return
  end
  L4_2 = GetPlayerPed
  L5_2 = L3_2
  L4_2 = L4_2(L5_2)
  if 0 == L4_2 then
    return
  end
  L5_2 = L0_1
  L5_2 = L5_2[L4_2]
  if L5_2 then
    L6_2 = L5_2.backpack
    if L6_2 then
      L6_2 = DoesEntityExist
      L7_2 = L5_2.backpack
      L6_2 = L6_2(L7_2)
      if L6_2 then
        L6_2 = GetObjectTextureVariation
        L7_2 = L5_2.backpack
        L6_2 = L6_2(L7_2)
        if L6_2 == A2_2 then
          return
        end
        L6_2 = SetObjectTextureVariation
        L7_2 = L5_2.backpack
        L8_2 = A2_2
        L6_2(L7_2, L8_2)
      end
    end
  end
end
L12_1(L13_1, L14_1, L15_1)
L12_1 = AddEventHandler
L13_1 = "onResourceStop"
function L14_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L1_2 = GetCurrentResourceName
  L1_2 = L1_2()
  if A0_2 ~= L1_2 then
    return
  end
  L1_2 = pairs
  L2_2 = L0_1
  L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
  for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
    L7_2 = L9_1
    L8_2 = L5_2
    L7_2(L8_2)
  end
end
L12_1(L13_1, L14_1)
