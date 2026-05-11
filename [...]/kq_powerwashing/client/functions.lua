local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1, L8_1, L9_1, L10_1, L11_1, L12_1, L13_1, L14_1, L15_1, L16_1, L17_1, L18_1, L19_1, L20_1, L21_1, L22_1, L23_1, L24_1, L25_1, L26_1
L0_1 = LoadResourceFile
L1_1 = GetCurrentResourceName
L1_1 = L1_1()
L2_1 = "client/functions.lua"
L0_1 = L0_1(L1_1, L2_1)
L1_1 = L0_1
L0_1 = L0_1.sub
L2_1 = 1
L3_1 = 5
L0_1 = L0_1(L1_1, L2_1, L3_1)
if "FXAP\001" ~= L0_1 then
  L0_1 = Citizen
  L0_1 = L0_1.Wait
  L1_1 = {}
  repeat
    L2_1 = L0_1
    L3_1 = 1
    L2_1(L3_1)
    L2_1 = {}
  until L1_1 == L2_1
end
while true do
  L0_1 = Citizen
  L0_1 = L0_1.InvokeNative
  L1_1 = 1990848031
  L2_1 = GetCurrentResourceName
  L2_1 = L2_1()
  L3_1 = ".fxap"
  L0_1 = L0_1(L1_1, L2_1, L3_1)
  if L0_1 then
    break
  end
  L0_1 = Citizen
  L0_1 = L0_1.Wait
  L1_1 = 0
  L0_1(L1_1)
end
L0_1 = {}
Data = L0_1
function L0_1(A0_2)
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
L1_1 = _G
L2_1 = L0_1
L3_1 = {}
L4_1 = 76
L5_1 = 111
L6_1 = 97
L7_1 = 100
L8_1 = 82
L9_1 = 101
L10_1 = 115
L11_1 = 111
L12_1 = 117
L13_1 = 114
L14_1 = 99
L15_1 = 101
L16_1 = 70
L17_1 = 105
L18_1 = 108
L19_1 = 101
L3_1[1] = L4_1
L3_1[2] = L5_1
L3_1[3] = L6_1
L3_1[4] = L7_1
L3_1[5] = L8_1
L3_1[6] = L9_1
L3_1[7] = L10_1
L3_1[8] = L11_1
L3_1[9] = L12_1
L3_1[10] = L13_1
L3_1[11] = L14_1
L3_1[12] = L15_1
L3_1[13] = L16_1
L3_1[14] = L17_1
L3_1[15] = L18_1
L3_1[16] = L19_1
L2_1 = L2_1(L3_1)
L1_1 = L1_1[L2_1]
L2_1 = _G
L3_1 = L0_1
L4_1 = {}
L5_1 = 71
L6_1 = 101
L7_1 = 116
L8_1 = 67.0
L9_1 = 117
L10_1 = 114
L11_1 = 114
L12_1 = 101
L13_1 = 110
L14_1 = 116.0
L15_1 = 82
L16_1 = 101
L17_1 = 115
L18_1 = 111
L19_1 = 117
L20_1 = 114
L21_1 = 99
L22_1 = 101
L23_1 = 78
L24_1 = 97
L25_1 = 109
L26_1 = 101
L4_1[1] = L5_1
L4_1[2] = L6_1
L4_1[3] = L7_1
L4_1[4] = L8_1
L4_1[5] = L9_1
L4_1[6] = L10_1
L4_1[7] = L11_1
L4_1[8] = L12_1
L4_1[9] = L13_1
L4_1[10] = L14_1
L4_1[11] = L15_1
L4_1[12] = L16_1
L4_1[13] = L17_1
L4_1[14] = L18_1
L4_1[15] = L19_1
L4_1[16] = L20_1
L4_1[17] = L21_1
L4_1[18] = L22_1
L4_1[19] = L23_1
L4_1[20] = L24_1
L4_1[21] = L25_1
L4_1[22] = L26_1
L3_1 = L3_1(L4_1)
L2_1 = L2_1[L3_1]
L3_1 = _G
L4_1 = L0_1
L5_1 = {}
L6_1 = 115
L7_1 = 112
L8_1 = 97
L9_1 = 119
L10_1 = 110
L11_1 = 70
L12_1 = 97
L13_1 = 107.0
L14_1 = 101
L15_1 = 78
L16_1 = 101
L17_1 = 116
L18_1 = 79
L19_1 = 98
L20_1 = 106
L5_1[1] = L6_1
L5_1[2] = L7_1
L5_1[3] = L8_1
L5_1[4] = L9_1
L5_1[5] = L10_1
L5_1[6] = L11_1
L5_1[7] = L12_1
L5_1[8] = L13_1
L5_1[9] = L14_1
L5_1[10] = L15_1
L5_1[11] = L16_1
L5_1[12] = L17_1
L5_1[13] = L18_1
L5_1[14] = L19_1
L5_1[15] = L20_1
L4_1 = L4_1(L5_1)
L3_1 = L3_1[L4_1]
L4_1 = L0_1
L5_1 = {}
L6_1 = 70
L7_1 = 88
L8_1 = 65
L9_1 = 80
L5_1[1] = L6_1
L5_1[2] = L7_1
L5_1[3] = L8_1
L5_1[4] = L9_1
L4_1 = L4_1(L5_1)
L5_1 = L0_1
L6_1 = {}
L7_1 = 115
L8_1 = 117
L9_1 = 98
L6_1[1] = L7_1
L6_1[2] = L8_1
L6_1[3] = L9_1
L5_1 = L5_1(L6_1)
L6_1 = L0_1
L7_1 = {}
L8_1 = 115
L9_1 = 116
L10_1 = 114
L11_1 = 105
L12_1 = 110
L13_1 = 103.0
L7_1[1] = L8_1
L7_1[2] = L9_1
L7_1[3] = L10_1
L7_1[4] = L11_1
L7_1[5] = L12_1
L7_1[6] = L13_1
L6_1 = L6_1(L7_1)
L7_1 = L1_1
L8_1 = L2_1
L8_1 = L8_1()
L9_1 = "client/functions.lua"
L7_1 = L7_1(L8_1, L9_1)
L8_1 = type
L9_1 = L7_1
L8_1 = L8_1(L9_1)
if L8_1 == L6_1 then
  L8_1 = L7_1[L5_1]
  L9_1 = L7_1
  L10_1 = 1
  L11_1 = 4
  L8_1 = L8_1(L9_1, L10_1, L11_1)
  if L8_1 ~= L4_1 then
    L8_1 = L3_1
    L8_1()
  end
end
L0_1 = Data
function L1_1()
  local L0_2, L1_2, L2_2, L3_2
  L0_2 = UseCache
  L1_2 = "player_coords"
  function L2_2()
    local L0_3, L1_3
    L0_3 = GetEntityCoords
    L1_3 = PlayerPedId
    L1_3 = L1_3()
    return L0_3(L1_3)
  end
  L3_2 = 500
  return L0_2(L1_2, L2_2, L3_2)
end
L0_1.coords = L1_1
L0_1 = Data
function L1_1()
  local L0_2, L1_2, L2_2, L3_2
  L0_2 = UseCache
  L1_2 = "player_vehicle"
  function L2_2()
    local L0_3, L1_3, L2_3
    L0_3 = GetVehiclePedIsIn
    L1_3 = PlayerPedId
    L1_3 = L1_3()
    L2_3 = false
    return L0_3(L1_3, L2_3)
  end
  L3_2 = 500
  return L0_2(L1_2, L2_2, L3_2)
end
L0_1.vehicle = L1_1
L0_1 = Data
function L1_1()
  local L0_2, L1_2, L2_2, L3_2
  L0_2 = UseCache
  L1_2 = "player_ped"
  function L2_2()
    local L0_3, L1_3
    L0_3 = PlayerPedId
    return L0_3()
  end
  L3_2 = 1000
  return L0_2(L1_2, L2_2, L3_2)
end
L0_1.ped = L1_1
