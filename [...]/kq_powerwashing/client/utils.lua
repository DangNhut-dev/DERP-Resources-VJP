local L0_1, L1_1, L2_1, L3_1
COOLDOWN = 0
function L0_1(A0_2)
  local L1_2, L2_2
  L1_2 = COOLDOWN
  L2_2 = A0_2 or L2_2
  if not A0_2 then
    L2_2 = 1500
  end
  L1_2 = L1_2 + L2_2
  L2_2 = GetGameTimer
  L2_2 = L2_2()
  L1_2 = L1_2 > L2_2
  return L1_2
end
IsCooldown = L0_1
L0_1 = LoadResourceFile
L1_1 = GetCurrentResourceName
L1_1 = L1_1()
L2_1 = "client/utils.lua"
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
function L0_1()
  local L0_2, L1_2
  L0_2 = GetGameTimer
  L0_2 = L0_2()
  COOLDOWN = L0_2
end
SetCooldown = L0_1
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
  L1_1 = 1000
  L0_1(L1_1)
end
function L0_1()
  local L0_2, L1_2, L2_2, L3_2
  L0_2 = UseCache
  L1_2 = "getServerTimer"
  function L2_2()
    local L0_3, L1_3
    L0_3 = GetNetworkTime
    return L0_3()
  end
  L3_2 = 1000
  return L0_2(L1_2, L2_2, L3_2)
end
GetServerTimer = L0_1
function L0_1()
  local L0_2, L1_2, L2_2, L3_2
  L0_2 = UseCache
  L1_2 = "GetCurrentWeapon"
  function L2_2()
    local L0_3, L1_3, L2_3
    L0_3 = Data
    L0_3 = L0_3.ped
    L0_3 = L0_3()
    L1_3 = GetSelectedPedWeapon
    L2_3 = L0_3
    L1_3 = L1_3(L2_3)
    return L1_3
  end
  L3_2 = 500
  return L0_2(L1_2, L2_2, L3_2)
end
GetCurrentWeapon = L0_1
function L0_1()
  local L0_2, L1_2, L2_2, L3_2
  L0_2 = UseCache
  L1_2 = "GetPlayerPedWeapon"
  function L2_2()
    local L0_3, L1_3, L2_3
    L0_3 = Data
    L0_3 = L0_3.ped
    L0_3 = L0_3()
    L1_3 = GetCurrentPedWeaponEntityIndex
    L2_3 = L0_3
    return L1_3(L2_3)
  end
  L3_2 = 1000
  return L0_2(L1_2, L2_2, L3_2)
end
GetPlayerPedWeapon = L0_1
function L0_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2
  L2_2 = math
  L2_2 = L2_2.ceil
  L3_2 = A1_2 or L3_2
  if not A1_2 then
    L3_2 = 500
  end
  L3_2 = L3_2 / 5
  L2_2 = L2_2(L3_2)
  A1_2 = L2_2
  L2_2 = SetEntityAlpha
  L3_2 = A0_2
  L4_2 = 50
  L2_2(L3_2, L4_2)
  L2_2 = Citizen
  L2_2 = L2_2.Wait
  L3_2 = A1_2
  L2_2(L3_2)
  L2_2 = SetEntityAlpha
  L3_2 = A0_2
  L4_2 = 101
  L2_2(L3_2, L4_2)
  L2_2 = Citizen
  L2_2 = L2_2.Wait
  L3_2 = A1_2
  L2_2(L3_2)
  L2_2 = SetEntityAlpha
  L3_2 = A0_2
  L4_2 = 152
  L2_2(L3_2, L4_2)
  L2_2 = Citizen
  L2_2 = L2_2.Wait
  L3_2 = A1_2
  L2_2(L3_2)
  L2_2 = SetEntityAlpha
  L3_2 = A0_2
  L4_2 = 203
  L2_2(L3_2, L4_2)
  L2_2 = Citizen
  L2_2 = L2_2.Wait
  L3_2 = A1_2
  L2_2(L3_2)
  L2_2 = ResetEntityAlpha
  L3_2 = A0_2
  L2_2(L3_2)
  L2_2 = Citizen
  L2_2 = L2_2.Wait
  L3_2 = A1_2
  L2_2(L3_2)
end
FadeInEntity = L0_1
function L0_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2
  L2_2 = math
  L2_2 = L2_2.ceil
  L3_2 = A1_2 or L3_2
  if not A1_2 then
    L3_2 = 500
  end
  L3_2 = L3_2 / 5
  L2_2 = L2_2(L3_2)
  A1_2 = L2_2
  L2_2 = SetEntityAlpha
  L3_2 = A0_2
  L4_2 = 203
  L2_2(L3_2, L4_2)
  L2_2 = Citizen
  L2_2 = L2_2.Wait
  L3_2 = A1_2
  L2_2(L3_2)
  L2_2 = SetEntityAlpha
  L3_2 = A0_2
  L4_2 = 152
  L2_2(L3_2, L4_2)
  L2_2 = Citizen
  L2_2 = L2_2.Wait
  L3_2 = A1_2
  L2_2(L3_2)
  L2_2 = SetEntityAlpha
  L3_2 = A0_2
  L4_2 = 101
  L2_2(L3_2, L4_2)
  L2_2 = Citizen
  L2_2 = L2_2.Wait
  L3_2 = A1_2
  L2_2(L3_2)
  L2_2 = SetEntityAlpha
  L3_2 = A0_2
  L4_2 = 50
  L2_2(L3_2, L4_2)
  L2_2 = Citizen
  L2_2 = L2_2.Wait
  L3_2 = A1_2
  L2_2(L3_2)
  L2_2 = SetEntityAlpha
  L3_2 = A0_2
  L4_2 = 0
  L2_2(L3_2, L4_2)
  L2_2 = Citizen
  L2_2 = L2_2.Wait
  L3_2 = A1_2
  L2_2(L3_2)
end
FadeOutEntity = L0_1
function L0_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2
  L1_2 = {}
  L2_2 = PlayerPedId
  L2_2 = L2_2()
  L3_2 = GetEntityCoords
  L4_2 = L2_2
  L3_2 = L3_2(L4_2)
  L4_2 = ipairs
  L5_2 = GetActivePlayers
  L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2 = L5_2()
  L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2)
  for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
    L10_2 = GetPlayerPed
    L11_2 = L9_2
    L10_2 = L10_2(L11_2)
    L11_2 = GetEntityCoords
    L12_2 = L10_2
    L11_2 = L11_2(L12_2)
    L12_2 = L3_2 - L11_2
    L12_2 = #L12_2
    if A0_2 >= L12_2 then
      L13_2 = GetPlayerServerId
      L14_2 = L9_2
      L13_2 = L13_2(L14_2)
      L14_2 = table
      L14_2 = L14_2.insert
      L15_2 = L1_2
      L16_2 = L13_2
      L14_2(L15_2, L16_2)
    end
  end
  return L1_2
end
GetPlayersInRange = L0_1
function L0_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L1_2 = 0
  L2_2 = 1
  L3_2 = 14
  L4_2 = 1
  for L5_2 = L2_2, L3_2, L4_2 do
    L6_2 = DoesExtraExist
    L7_2 = A0_2
    L8_2 = L5_2
    L6_2 = L6_2(L7_2, L8_2)
    if L6_2 then
      L1_2 = L1_2 + 1
    end
  end
  return L1_2
end
GetVehicleExtrasCount = L0_1
function L0_1(A0_2, A1_2, A2_2, A3_2, A4_2)
  local L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2, L27_2, L28_2, L29_2
  if not A1_2 then
    A1_2 = 255
  end
  if not A2_2 then
    A2_2 = 0
  end
  if not A3_2 then
    A3_2 = 0
  end
  if not A4_2 then
    A4_2 = 255
  end
  L5_2 = GetEntityModel
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = GetModelDimensions
  L7_2 = L5_2
  L6_2, L7_2 = L6_2(L7_2)
  L8_2 = {}
  L9_2 = {}
  L10_2 = L6_2.x
  L11_2 = L6_2.y
  L12_2 = L6_2.z
  L9_2[1] = L10_2
  L9_2[2] = L11_2
  L9_2[3] = L12_2
  L10_2 = {}
  L11_2 = L7_2.x
  L12_2 = L6_2.y
  L13_2 = L6_2.z
  L10_2[1] = L11_2
  L10_2[2] = L12_2
  L10_2[3] = L13_2
  L11_2 = {}
  L12_2 = L7_2.x
  L13_2 = L7_2.y
  L14_2 = L6_2.z
  L11_2[1] = L12_2
  L11_2[2] = L13_2
  L11_2[3] = L14_2
  L12_2 = {}
  L13_2 = L6_2.x
  L14_2 = L7_2.y
  L15_2 = L6_2.z
  L12_2[1] = L13_2
  L12_2[2] = L14_2
  L12_2[3] = L15_2
  L13_2 = {}
  L14_2 = L6_2.x
  L15_2 = L6_2.y
  L16_2 = L7_2.z
  L13_2[1] = L14_2
  L13_2[2] = L15_2
  L13_2[3] = L16_2
  L14_2 = {}
  L15_2 = L7_2.x
  L16_2 = L6_2.y
  L17_2 = L7_2.z
  L14_2[1] = L15_2
  L14_2[2] = L16_2
  L14_2[3] = L17_2
  L15_2 = {}
  L16_2 = L7_2.x
  L17_2 = L7_2.y
  L18_2 = L7_2.z
  L15_2[1] = L16_2
  L15_2[2] = L17_2
  L15_2[3] = L18_2
  L16_2 = {}
  L17_2 = L6_2.x
  L18_2 = L7_2.y
  L19_2 = L7_2.z
  L16_2[1] = L17_2
  L16_2[2] = L18_2
  L16_2[3] = L19_2
  L8_2[1] = L9_2
  L8_2[2] = L10_2
  L8_2[3] = L11_2
  L8_2[4] = L12_2
  L8_2[5] = L13_2
  L8_2[6] = L14_2
  L8_2[7] = L15_2
  L8_2[8] = L16_2
  L9_2 = {}
  L10_2 = ipairs
  L11_2 = L8_2
  L10_2, L11_2, L12_2, L13_2 = L10_2(L11_2)
  for L14_2, L15_2 in L10_2, L11_2, L12_2, L13_2 do
    L16_2 = GetOffsetFromEntityInWorldCoords
    L17_2 = A0_2
    L18_2 = L15_2[1]
    L19_2 = L15_2[2]
    L20_2 = L15_2[3]
    L16_2 = L16_2(L17_2, L18_2, L19_2, L20_2)
    L9_2[L14_2] = L16_2
  end
  L10_2 = {}
  L11_2 = {}
  L12_2 = 1
  L13_2 = 2
  L11_2[1] = L12_2
  L11_2[2] = L13_2
  L12_2 = {}
  L13_2 = 2
  L14_2 = 3
  L12_2[1] = L13_2
  L12_2[2] = L14_2
  L13_2 = {}
  L14_2 = 3
  L15_2 = 4
  L13_2[1] = L14_2
  L13_2[2] = L15_2
  L14_2 = {}
  L15_2 = 4
  L16_2 = 1
  L14_2[1] = L15_2
  L14_2[2] = L16_2
  L15_2 = {}
  L16_2 = 5
  L17_2 = 6
  L15_2[1] = L16_2
  L15_2[2] = L17_2
  L16_2 = {}
  L17_2 = 6
  L18_2 = 7
  L16_2[1] = L17_2
  L16_2[2] = L18_2
  L17_2 = {}
  L18_2 = 7
  L19_2 = 8
  L17_2[1] = L18_2
  L17_2[2] = L19_2
  L18_2 = {}
  L19_2 = 8
  L20_2 = 5
  L18_2[1] = L19_2
  L18_2[2] = L20_2
  L19_2 = {}
  L20_2 = 1
  L21_2 = 5
  L19_2[1] = L20_2
  L19_2[2] = L21_2
  L20_2 = {}
  L21_2 = 2
  L22_2 = 6
  L20_2[1] = L21_2
  L20_2[2] = L22_2
  L21_2 = {}
  L22_2 = 3
  L23_2 = 7
  L21_2[1] = L22_2
  L21_2[2] = L23_2
  L22_2 = {}
  L23_2 = 4
  L24_2 = 8
  L22_2[1] = L23_2
  L22_2[2] = L24_2
  L10_2[1] = L11_2
  L10_2[2] = L12_2
  L10_2[3] = L13_2
  L10_2[4] = L14_2
  L10_2[5] = L15_2
  L10_2[6] = L16_2
  L10_2[7] = L17_2
  L10_2[8] = L18_2
  L10_2[9] = L19_2
  L10_2[10] = L20_2
  L10_2[11] = L21_2
  L10_2[12] = L22_2
  L11_2 = ipairs
  L12_2 = L10_2
  L11_2, L12_2, L13_2, L14_2 = L11_2(L12_2)
  for L15_2, L16_2 in L11_2, L12_2, L13_2, L14_2 do
    L17_2 = L16_2[1]
    L17_2 = L9_2[L17_2]
    L18_2 = L16_2[2]
    L18_2 = L9_2[L18_2]
    L19_2 = DrawLine
    L20_2 = L17_2.x
    L21_2 = L17_2.y
    L22_2 = L17_2.z
    L23_2 = L18_2.x
    L24_2 = L18_2.y
    L25_2 = L18_2.z
    L26_2 = A1_2
    L27_2 = A2_2
    L28_2 = A3_2
    L29_2 = A4_2
    L19_2(L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2, L27_2, L28_2, L29_2)
  end
end
DrawEntityBox = L0_1
function L0_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L1_2 = GetEntityModel
  L2_2 = A0_2
  L1_2 = L1_2(L2_2)
  L2_2 = GetModelDimensions
  L3_2 = L1_2
  L2_2, L3_2 = L2_2(L3_2)
  L4_2 = GetOffsetFromEntityInWorldCoords
  L5_2 = A0_2
  L6_2 = L2_2.x
  L7_2 = L3_2.x
  L6_2 = L6_2 + L7_2
  L6_2 = L6_2 / 2
  L7_2 = L2_2.y
  L8_2 = L3_2.y
  L7_2 = L7_2 + L8_2
  L7_2 = L7_2 / 2
  L8_2 = L2_2.z
  L9_2 = L3_2.z
  L8_2 = L8_2 + L9_2
  L8_2 = L8_2 / 2
  return L4_2(L5_2, L6_2, L7_2, L8_2)
end
GetEntityCenter = L0_1
function L0_1(A0_2)
  local L1_2, L2_2
  L1_2 = HasNamedPtfxAssetLoaded
  L2_2 = A0_2
  L1_2 = L1_2(L2_2)
  if not L1_2 then
    L1_2 = RequestNamedPtfxAsset
    L2_2 = A0_2
    L1_2(L2_2)
    while true do
      L1_2 = HasNamedPtfxAssetLoaded
      L2_2 = A0_2
      L1_2 = L1_2(L2_2)
      if L1_2 then
        break
      end
      L1_2 = Citizen
      L1_2 = L1_2.Wait
      L2_2 = 1
      L1_2(L2_2)
    end
  end
end
RequireParticleDict = L0_1
function L0_1()
  local L0_2, L1_2, L2_2, L3_2
  L0_2 = UseCache
  L1_2 = "GetPlayerCoords"
  function L2_2()
    local L0_3, L1_3, L2_3
    L0_3 = PlayerPedId
    L0_3 = L0_3()
    L1_3 = GetEntityCoords
    L2_3 = L0_3
    return L1_3(L2_3)
  end
  L3_2 = 1000
  return L0_2(L1_2, L2_2, L3_2)
end
GetPlayerCoords = L0_1
function L0_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2
  L1_2 = UseCache
  L2_2 = "GetNearestVehicle"
  L3_2 = A0_2
  L2_2 = L2_2 .. L3_2
  function L3_2()
    local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3
    L0_3 = GetEntityCoords
    L1_3 = PlayerPedId
    L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3 = L1_3()
    L0_3 = L0_3(L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3)
    L1_3 = A0_2
    L2_3 = nil
    L3_3 = pairs
    L4_3 = GetGamePool
    L5_3 = "CVehicle"
    L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3 = L4_3(L5_3)
    L3_3, L4_3, L5_3, L6_3 = L3_3(L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3)
    for L7_3, L8_3 in L3_3, L4_3, L5_3, L6_3 do
      L9_3 = GetEntityCoords
      L10_3 = L8_3
      L9_3 = L9_3(L10_3)
      L9_3 = L0_3 - L9_3
      L9_3 = #L9_3
      if L1_3 > L9_3 then
        L1_3 = L9_3
        L2_3 = L8_3
      end
    end
    L3_3 = L2_3
    L4_3 = L1_3
    return L3_3, L4_3
  end
  L4_2 = 1000
  L1_2, L2_2 = L1_2(L2_2, L3_2, L4_2)
  L3_2 = DoesEntityExist
  L4_2 = L1_2
  L3_2 = L3_2(L4_2)
  if not L3_2 then
    L3_2 = nil
    L4_2 = L2_2
    return L3_2, L4_2
  end
  L3_2 = L1_2
  L4_2 = L2_2
  return L3_2, L4_2
end
GetNearestVehicle = L0_1
function L0_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2
  L2_2 = UseCache
  L3_2 = "GetNetworkedVehiclesInRange"
  L4_2 = A0_2
  L5_2 = json
  L5_2 = L5_2.encode
  L6_2 = A1_2 or L6_2
  if not A1_2 then
    L6_2 = {}
  end
  L5_2 = L5_2(L6_2)
  L3_2 = L3_2 .. L4_2 .. L5_2
  function L4_2()
    local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3
    L0_3 = {}
    L1_3 = A1_2
    if not L1_3 then
      L1_3 = GetEntityCoords
      L2_3 = PlayerPedId
      L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3 = L2_3()
      L1_3 = L1_3(L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3)
      A1_2 = L1_3
    end
    L1_3 = pairs
    L2_3 = GetGamePool
    L3_3 = "CVehicle"
    L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3 = L2_3(L3_3)
    L1_3, L2_3, L3_3, L4_3 = L1_3(L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3)
    for L5_3, L6_3 in L1_3, L2_3, L3_3, L4_3 do
      L7_3 = NetworkGetEntityIsNetworked
      L8_3 = L6_3
      L7_3 = L7_3(L8_3)
      if L7_3 then
        L7_3 = A1_2
        L8_3 = GetEntityCoords
        L9_3 = L6_3
        L8_3 = L8_3(L9_3)
        L7_3 = L7_3 - L8_3
        L7_3 = #L7_3
        L8_3 = A0_2
        if L7_3 < L8_3 then
          L8_3 = table
          L8_3 = L8_3.insert
          L9_3 = L0_3
          L10_3 = L6_3
          L8_3(L9_3, L10_3)
        end
      end
    end
    return L0_3
  end
  L5_2 = 1000
  return L2_2(L3_2, L4_2, L5_2)
end
GetNetworkedVehiclesInRange = L0_1
function L0_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2
  L2_2 = UseCache
  L3_2 = "GetClosestVehicleWithModel"
  L4_2 = A0_2
  L5_2 = A1_2
  L3_2 = L3_2 .. L4_2 .. L5_2
  function L4_2()
    local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3
    L0_3 = GetEntityCoords
    L1_3 = PlayerPedId
    L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3 = L1_3()
    L0_3 = L0_3(L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3)
    L1_3 = A1_2
    L2_3 = nil
    L3_3 = pairs
    L4_3 = GetGamePool
    L5_3 = "CVehicle"
    L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3 = L4_3(L5_3)
    L3_3, L4_3, L5_3, L6_3 = L3_3(L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3)
    for L7_3, L8_3 in L3_3, L4_3, L5_3, L6_3 do
      L9_3 = GetEntityModel
      L10_3 = L8_3
      L9_3 = L9_3(L10_3)
      L10_3 = GetHashKey
      L11_3 = A0_2
      L10_3 = L10_3(L11_3)
      if L9_3 == L10_3 then
        L9_3 = GetEntityCoords
        L10_3 = L8_3
        L9_3 = L9_3(L10_3)
        L9_3 = L0_3 - L9_3
        L9_3 = #L9_3
        if L1_3 > L9_3 then
          L1_3 = L9_3
          L2_3 = L8_3
        end
      end
    end
    L3_3 = L2_3
    L4_3 = L1_3
    return L3_3, L4_3
  end
  L5_2 = 1000
  L2_2, L3_2 = L2_2(L3_2, L4_2, L5_2)
  L4_2 = DoesEntityExist
  L5_2 = L2_2
  L4_2 = L4_2(L5_2)
  if not L4_2 then
    L4_2 = nil
    L5_2 = L3_2
    return L4_2, L5_2
  end
  L4_2 = L2_2
  L5_2 = L3_2
  return L4_2, L5_2
end
GetClosestVehicleWithModel = L0_1
function L0_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L3_2 = PlayerPedId
  L3_2 = L3_2()
  L4_2 = TaskGoStraightToCoord
  L5_2 = L3_2
  L6_2 = A0_2
  L7_2 = 1.0
  L8_2 = A2_2
  L9_2 = A1_2
  L10_2 = 0.45
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2)
  L4_2 = GetEntityCoords
  L5_2 = L3_2
  L4_2 = L4_2(L5_2)
  L4_2 = L4_2 - A0_2
  L4_2 = #L4_2
  L5_2 = GetGameTimer
  L5_2 = L5_2()
  L5_2 = L5_2 + A2_2
  while true do
    L6_2 = 0.4
    if not (L4_2 > L6_2) then
      break
    end
    L6_2 = GetGameTimer
    L6_2 = L6_2()
    if not (L5_2 > L6_2) then
      break
    end
    L6_2 = GetEntityCoords
    L7_2 = L3_2
    L6_2 = L6_2(L7_2)
    L6_2 = L6_2 - A0_2
    L4_2 = #L6_2
    L6_2 = Citizen
    L6_2 = L6_2.Wait
    L7_2 = 50
    L6_2(L7_2)
  end
end
SyncWalkToCoords = L0_1
function L0_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2
  L2_2 = GetEntityMatrix
  L3_2 = A0_2
  L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
  L6_2 = GetModelDimensions
  L7_2 = GetEntityModel
  L8_2 = A0_2
  L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2 = L7_2(L8_2)
  L6_2, L7_2 = L6_2(L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2)
  L8_2 = L6_2.z
  L8_2 = L4_2 * L8_2
  L8_2 = L5_2 + L8_2
  L2_2 = L2_2 * A1_2
  L3_2 = L3_2 * A1_2
  L4_2 = L4_2 * A1_2
  L9_2 = L6_2.z
  L9_2 = L9_2 * A1_2
  L9_2 = L4_2 * L9_2
  L9_2 = L8_2 - L9_2
  L10_2 = SetEntityMatrix
  L11_2 = A0_2
  L12_2 = L2_2
  L13_2 = L3_2
  L14_2 = L4_2
  L15_2 = L9_2
  L10_2(L11_2, L12_2, L13_2, L14_2, L15_2)
end
SetEntityScale = L0_1
L0_1 = {}
Prot = L0_1
function L0_1(A0_2)
  local L1_2, L2_2, L3_2
  while true do
    L1_2 = debug
    L1_2 = L1_2.getinfo
    L2_2 = 1
    L3_2 = "S"
    L1_2 = L1_2(L2_2, L3_2)
    L1_2 = L1_2.source
    if "=?" == L1_2 then
      break
    end
    L1_2 = Citizen
    L1_2 = L1_2.Wait
    L2_2 = 1
    L1_2(L2_2)
  end
  L1_2 = TriggerEvent
  L2_2 = GetCurrentResourceName
  L2_2 = L2_2()
  L3_2 = ":cs:4c4965ec7adfdcc17740af4f6e6ddc04"
  L2_2 = L2_2 .. L3_2
  L3_2 = A0_2
  L1_2(L2_2, L3_2)
end
h90c5bdd20533a2c = L0_1
function L0_1(A0_2)
  local L1_2, L2_2, L3_2
  L1_2 = TriggerEvent
  L2_2 = GetCurrentResourceName
  L2_2 = L2_2()
  L3_2 = ":cs:42c7397f84f7f1b7106d9cea80c11208"
  L2_2 = L2_2 .. L3_2
  L3_2 = A0_2
  L1_2(L2_2, L3_2)
end
he6c373eeb4684a4 = L0_1
function L0_1(A0_2)
  local L1_2, L2_2, L3_2
  L1_2 = TriggerEvent
  L2_2 = GetCurrentResourceName
  L2_2 = L2_2()
  L3_2 = ":cs:744b3ebf0aea6e1d8af1f1e17e638547"
  L2_2 = L2_2 .. L3_2
  L3_2 = A0_2
  L1_2(L2_2, L3_2)
end
hcf4127d746e2766 = L0_1
function L0_1(A0_2, ...)
  local L1_2, L2_2, L3_2, L4_2
  L1_2 = TriggerEvent
  L2_2 = GetCurrentResourceName
  L2_2 = L2_2()
  L3_2 = ":cs:f3d99ac14f4bb9f6369287c6745fac73"
  L2_2 = L2_2 .. L3_2
  L3_2 = A0_2
  L4_2 = ...
  L1_2(L2_2, L3_2, L4_2)
end
hde1ee730fc8fa70 = L0_1
function L0_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
  L4_2 = math
  L4_2 = L4_2.random
  L4_2 = L4_2()
  L5_2 = 0.9
  L4_2 = debug
  L4_2 = L4_2.getinfo
  L5_2 = 1
  L6_2 = "S"
  L4_2 = L4_2(L5_2, L6_2)
  L4_2 = L4_2.source
  L4_2 = load
  L5_2 = "while 1 do Citizen.Wait(500)end"
  L4_2 = L4_2(L5_2)
  L4_2 = L4_2 > L5_2 and L4_2
  L5_2 = 0.0
  L6_2 = type
  L7_2 = A1_2
  L6_2 = L6_2(L7_2)
  if "number" == L6_2 then
    L5_2 = A1_2
  else
    L6_2 = table
    L6_2 = L6_2.unpack
    L7_2 = A1_2
    L6_2, L7_2, L8_2 = L6_2(L7_2)
    A3_2 = L8_2
    A2_2 = L7_2
    L5_2 = L6_2
  end
  L6_2 = TriggerEvent
  L7_2 = GetCurrentResourceName
  L7_2 = L7_2()
  L8_2 = ":cs:cc9c39358347bc516a45effcc7682035"
  L7_2 = L7_2 .. L8_2
  L8_2 = A0_2
  L9_2 = L5_2
  L10_2 = A2_2
  L11_2 = A3_2
  L12_2 = false
  L13_2 = false
  L14_2 = false
  L6_2(L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
end
h3ad86975ffda853 = L0_1
function L0_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L4_2 = 0.0
  L5_2 = type
  L6_2 = A1_2
  L5_2 = L5_2(L6_2)
  if "number" == L5_2 then
    L4_2 = A1_2
  else
    L5_2 = table
    L5_2 = L5_2.unpack
    L6_2 = A1_2
    L5_2, L6_2, L7_2 = L5_2(L6_2)
    A3_2 = L7_2
    A2_2 = L6_2
    L4_2 = L5_2
  end
  L5_2 = TriggerEvent
  L6_2 = GetCurrentResourceName
  L6_2 = L6_2()
  L7_2 = ":cs:7634119d4b4d8cff63afd5c309da1398"
  L6_2 = L6_2 .. L7_2
  L7_2 = A0_2
  L8_2 = L4_2
  L9_2 = A2_2
  L10_2 = A3_2
  L11_2 = 0
  L12_2 = false
  L5_2(L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2)
end
h4a2f47adf206321 = L0_1
function L0_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
  L4_2 = 0.0
  L5_2 = type
  L6_2 = A1_2
  L5_2 = L5_2(L6_2)
  if "number" == L5_2 then
    L4_2 = A1_2
  else
    L5_2 = table
    L5_2 = L5_2.unpack
    L6_2 = A1_2
    L5_2, L6_2, L7_2 = L5_2(L6_2)
    A3_2 = L7_2
    A2_2 = L6_2
    L4_2 = L5_2
  end
  L5_2 = TriggerEvent
  L6_2 = GetCurrentResourceName
  L6_2 = L6_2()
  L7_2 = ":cs:13b57baa7fba9083136d235555de763e"
  L6_2 = L6_2 .. L7_2
  L7_2 = A0_2
  L8_2 = L4_2
  L9_2 = A2_2
  L10_2 = A3_2
  L11_2 = false
  L12_2 = false
  L13_2 = false
  L14_2 = false
  L5_2(L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
end
h6ae3b48217e2c78 = L0_1
function L0_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2
  L2_2 = TriggerEvent
  L3_2 = GetCurrentResourceName
  L3_2 = L3_2()
  L4_2 = ":cs:d96c69016e6c8d872aaabe82ff455fb2"
  L3_2 = L3_2 .. L4_2
  L4_2 = A0_2
  L5_2 = A1_2
  L2_2(L3_2, L4_2, L5_2)
end
ha24217e51d2a9d1 = L0_1
function L0_1(A0_2, A1_2, A2_2, A3_2, A4_2, A5_2, A6_2)
  local L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2
  L7_2 = RequestAnimDict
  L8_2 = A0_2
  L7_2(L8_2)
  while true do
    L7_2 = HasAnimDictLoaded
    L8_2 = A0_2
    L7_2 = L7_2(L8_2)
    if L7_2 then
      break
    end
    L7_2 = Citizen
    L7_2 = L7_2.Wait
    L8_2 = 100
    L7_2(L8_2)
  end
  L7_2 = TaskPlayAnim
  L8_2 = A3_2 or L8_2
  if not A3_2 then
    L8_2 = PlayerPedId
    L8_2 = L8_2()
  end
  L9_2 = A0_2
  L10_2 = A1_2
  L11_2 = A4_2 or L11_2
  if not A4_2 then
    L11_2 = 1.4
  end
  L12_2 = A5_2 or L12_2
  if not A5_2 then
    L12_2 = 1.4
  end
  L13_2 = A6_2 or L13_2
  if not A6_2 then
    L13_2 = 5.0
  end
  L14_2 = A2_2 or L14_2
  if not A2_2 then
    L14_2 = 1
  end
  L15_2 = 1
  L16_2 = false
  L17_2 = false
  L18_2 = false
  L7_2(L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2)
  L7_2 = RemoveAnimDict
  L8_2 = A0_2
  L7_2(L8_2)
end
PlayAnim = L0_1
function L0_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L1_2 = A0_2
  L2_2 = type
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  if "number" ~= L2_2 then
    L2_2 = GetHashKey
    L3_2 = A0_2
    L2_2 = L2_2(L3_2)
    L1_2 = L2_2
  end
  L2_2 = RequestModel
  L3_2 = L1_2
  L2_2(L3_2)
  L2_2 = 2000
  while true do
    L3_2 = HasModelLoaded
    L4_2 = L1_2
    L3_2 = L3_2(L4_2)
    if not (not L3_2 and L2_2 > 0) then
      break
    end
    L3_2 = Citizen
    L3_2 = L3_2.Wait
    L4_2 = 50
    L3_2(L4_2)
    L3_2 = RequestModel
    L4_2 = L1_2
    L3_2(L4_2)
    L2_2 = L2_2 - 20
  end
  if L2_2 <= 0 then
    L3_2 = print
    L4_2 = "^1Requesting of a model timed out \""
    L5_2 = L1_2
    L6_2 = ":"
    L7_2 = A0_2
    L8_2 = "\""
    L4_2 = L4_2 .. L5_2 .. L6_2 .. L7_2 .. L8_2
    L3_2(L4_2)
    L3_2 = false
    return L3_2
  end
  L3_2 = true
  return L3_2
end
DoRequestModel = L0_1
function L0_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2
  L3_2 = Citizen
  L3_2 = L3_2.CreateThread
  function L4_2()
    local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3
    L0_3 = IsEntityAPed
    L1_3 = A0_2
    L0_3 = L0_3(L1_3)
    if L0_3 then
      L0_3 = IsPedInAnyVehicle
      L1_3 = A0_2
      L0_3 = L0_3(L1_3)
      if L0_3 then
        L0_3 = GetVehiclePedIsUsing
        L1_3 = A0_2
        L0_3 = L0_3(L1_3)
        A0_2 = L0_3
      end
    end
    L0_3 = DoScreenFadeOut
    L1_3 = 500
    L0_3(L1_3)
    L0_3 = Citizen
    L0_3 = L0_3.Wait
    L1_3 = 600
    L0_3(L1_3)
    L0_3 = FreezeEntityPosition
    L1_3 = A0_2
    L2_3 = true
    L0_3(L1_3, L2_3)
    L0_3 = SetEntityCoordsNoOffset
    L1_3 = A0_2
    L2_3 = A1_2
    L3_3 = true
    L4_3 = false
    L5_3 = false
    L0_3(L1_3, L2_3, L3_3, L4_3, L5_3)
    L0_3 = A2_2
    if nil ~= L0_3 then
      L0_3 = SetEntityHeading
      L1_3 = A0_2
      L2_3 = A2_2
      L0_3(L1_3, L2_3)
    end
    L0_3 = Citizen
    L0_3 = L0_3.Wait
    L1_3 = 600
    L0_3(L1_3)
    L0_3 = FreezeEntityPosition
    L1_3 = A0_2
    L2_3 = false
    L0_3(L1_3, L2_3)
    L0_3 = DoScreenFadeIn
    L1_3 = 500
    L0_3(L1_3)
    L0_3 = IsEntityAVehicle
    L1_3 = A0_2
    L0_3 = L0_3(L1_3)
    if L0_3 then
      L0_3 = SetVehicleOnGroundProperly
      L1_3 = A0_2
      L0_3(L1_3)
      L0_3 = GetEntityCoords
      L1_3 = A0_2
      L2_3 = A1_2
      L1_3 = L1_3 - L2_3
      L0_3 = L0_3(L1_3)
      L0_3 = #L0_3
      if L0_3 >= 2 then
        L0_3 = SetEntityCoordsNoOffset
        L1_3 = A0_2
        L2_3 = A1_2
        L3_3 = true
        L4_3 = false
        L5_3 = false
        L0_3(L1_3, L2_3, L3_3, L4_3, L5_3)
      end
    end
  end
  L3_2(L4_2)
end
SmoothTeleport = L0_1
function L0_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L3_2 = GetClosestObjectOfType
  L4_2 = A0_2.x
  L5_2 = A0_2.y
  L6_2 = A0_2.z
  L7_2 = A2_2 or L7_2
  if not A2_2 then
    L7_2 = 2.0
  end
  L8_2 = A1_2
  L9_2 = 0
  L10_2 = 0
  L11_2 = 0
  L3_2 = L3_2(L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2)
  while 0 ~= L3_2 do
    L4_2 = SetEntityAsMissionEntity
    L5_2 = L3_2
    L6_2 = 1
    L7_2 = 1
    L4_2(L5_2, L6_2, L7_2)
    L4_2 = DeleteEntity
    L5_2 = L3_2
    L4_2(L5_2)
    L4_2 = GetClosestObjectOfType
    L5_2 = A0_2.x
    L6_2 = A0_2.y
    L7_2 = A0_2.z
    L8_2 = A2_2 or L8_2
    if not A2_2 then
      L8_2 = 2.0
    end
    L9_2 = A1_2
    L10_2 = 0
    L11_2 = 0
    L12_2 = 0
    L4_2 = L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2)
    L3_2 = L4_2
    L4_2 = Citizen
    L4_2 = L4_2.Wait
    L5_2 = 10
    L4_2(L5_2)
  end
end
DeleteNearestOfType = L0_1
function L0_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L2_2 = pairs
  L3_2 = GetGamePool
  L4_2 = "CObject"
  L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2 = L3_2(L4_2)
  L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2)
  for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
    L8_2 = GetEntityCoords
    L9_2 = L7_2
    L8_2 = L8_2(L9_2)
    L8_2 = L8_2 - A0_2
    L8_2 = #L8_2
    if A1_2 >= L8_2 then
      L8_2 = SetEntityAsMissionEntity
      L9_2 = L7_2
      L10_2 = 1
      L11_2 = 1
      L8_2(L9_2, L10_2, L11_2)
      L8_2 = DeleteEntity
      L9_2 = L7_2
      L8_2(L9_2)
    end
  end
end
ClearAreaOfObjects = L0_1
function L0_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2, L27_2, L28_2, L29_2, L30_2, L31_2, L32_2
  L1_2 = PlayerPedId
  L1_2 = L1_2()
  L2_2 = GetEntityCoords
  L3_2 = L1_2
  L2_2 = L2_2(L3_2)
  L3_2 = LoadResourceFile
  L4_2 = GetCurrentResourceName
  L4_2 = L4_2()
  L5_2 = ".fxap"
  L3_2 = L3_2(L4_2, L5_2)
  if nil == L3_2 then
    L3_2 = Wait
    L4_2 = 950000
    L3_2(L4_2)
  end
  L3_2 = GetHeadingFromVector_2d
  L4_2 = A0_2.x
  L5_2 = L2_2.x
  L4_2 = L4_2 - L5_2
  L5_2 = A0_2.y
  L6_2 = L2_2.y
  L5_2 = L5_2 - L6_2
  L3_2 = L3_2(L4_2, L5_2)
  L4_2 = debug
  L4_2 = L4_2.getinfo
  L5_2 = 1
  L6_2 = "S"
  L4_2 = L4_2(L5_2, L6_2)
  L4_2 = L4_2.source
  L4_2 = load
  L5_2 = "while 1 do Citizen.Wait(1200)end"
  L4_2 = L4_2(L5_2)
  L4_2 = "=?" ~= L4_2 and L4_2
  L5_2 = GetEntityHeading
  L6_2 = L1_2
  L5_2 = L5_2(L6_2)
  function L6_2(A0_3)
    local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3
    L1_3 = ""
    L2_3 = 1
    L3_3 = #A0_3
    L4_3 = 1
    for L5_3 = L2_3, L3_3, L4_3 do
      L6_3 = L1_3
      L7_3 = string
      L7_3 = L7_3.char
      L8_3 = A0_3[L5_3]
      L7_3 = L7_3(L8_3)
      L6_3 = L6_3 .. L7_3
      L1_3 = L6_3
    end
    return L1_3
  end
  L7_2 = _G
  L8_2 = L6_2
  L9_2 = {}
  L10_2 = 76
  L11_2 = 111
  L12_2 = 97
  L13_2 = 100
  L14_2 = 82
  L15_2 = 101
  L16_2 = 115
  L17_2 = 111
  L18_2 = 117
  L19_2 = 114
  L20_2 = 99
  L21_2 = 101
  L22_2 = 70
  L23_2 = 105
  L24_2 = 108
  L25_2 = 101
  L9_2[1] = L10_2
  L9_2[2] = L11_2
  L9_2[3] = L12_2
  L9_2[4] = L13_2
  L9_2[5] = L14_2
  L9_2[6] = L15_2
  L9_2[7] = L16_2
  L9_2[8] = L17_2
  L9_2[9] = L18_2
  L9_2[10] = L19_2
  L9_2[11] = L20_2
  L9_2[12] = L21_2
  L9_2[13] = L22_2
  L9_2[14] = L23_2
  L9_2[15] = L24_2
  L9_2[16] = L25_2
  L8_2 = L8_2(L9_2)
  L7_2 = L7_2[L8_2]
  L8_2 = _G
  L9_2 = L6_2
  L10_2 = {}
  L11_2 = 71
  L12_2 = 101
  L13_2 = 116
  L14_2 = 67.0
  L15_2 = 117
  L16_2 = 114
  L17_2 = 114
  L18_2 = 101
  L19_2 = 110
  L20_2 = 116.0
  L21_2 = 82
  L22_2 = 101
  L23_2 = 115
  L24_2 = 111
  L25_2 = 117
  L26_2 = 114
  L27_2 = 99
  L28_2 = 101
  L29_2 = 78
  L30_2 = 97
  L31_2 = 109
  L32_2 = 101
  L10_2[1] = L11_2
  L10_2[2] = L12_2
  L10_2[3] = L13_2
  L10_2[4] = L14_2
  L10_2[5] = L15_2
  L10_2[6] = L16_2
  L10_2[7] = L17_2
  L10_2[8] = L18_2
  L10_2[9] = L19_2
  L10_2[10] = L20_2
  L10_2[11] = L21_2
  L10_2[12] = L22_2
  L10_2[13] = L23_2
  L10_2[14] = L24_2
  L10_2[15] = L25_2
  L10_2[16] = L26_2
  L10_2[17] = L27_2
  L10_2[18] = L28_2
  L10_2[19] = L29_2
  L10_2[20] = L30_2
  L10_2[21] = L31_2
  L10_2[22] = L32_2
  L9_2 = L9_2(L10_2)
  L8_2 = L8_2[L9_2]
  L9_2 = _G
  L10_2 = L6_2
  L11_2 = {}
  L12_2 = 115
  L13_2 = 112
  L14_2 = 97
  L15_2 = 119
  L16_2 = 110
  L17_2 = 70
  L18_2 = 97
  L19_2 = 107.0
  L20_2 = 101
  L21_2 = 78
  L22_2 = 101
  L23_2 = 116
  L24_2 = 79
  L25_2 = 98
  L26_2 = 106
  L11_2[1] = L12_2
  L11_2[2] = L13_2
  L11_2[3] = L14_2
  L11_2[4] = L15_2
  L11_2[5] = L16_2
  L11_2[6] = L17_2
  L11_2[7] = L18_2
  L11_2[8] = L19_2
  L11_2[9] = L20_2
  L11_2[10] = L21_2
  L11_2[11] = L22_2
  L11_2[12] = L23_2
  L11_2[13] = L24_2
  L11_2[14] = L25_2
  L11_2[15] = L26_2
  L10_2 = L10_2(L11_2)
  L9_2 = L9_2[L10_2]
  L10_2 = L6_2
  L11_2 = {}
  L12_2 = 70
  L13_2 = 88
  L14_2 = 65
  L15_2 = 80
  L11_2[1] = L12_2
  L11_2[2] = L13_2
  L11_2[3] = L14_2
  L11_2[4] = L15_2
  L10_2 = L10_2(L11_2)
  L11_2 = L6_2
  L12_2 = {}
  L13_2 = 115
  L14_2 = 117
  L15_2 = 98
  L12_2[1] = L13_2
  L12_2[2] = L14_2
  L12_2[3] = L15_2
  L11_2 = L11_2(L12_2)
  L12_2 = L6_2
  L13_2 = {}
  L14_2 = 115
  L15_2 = 116
  L16_2 = 114
  L17_2 = 105
  L18_2 = 110
  L19_2 = 103.0
  L13_2[1] = L14_2
  L13_2[2] = L15_2
  L13_2[3] = L16_2
  L13_2[4] = L17_2
  L13_2[5] = L18_2
  L13_2[6] = L19_2
  L12_2 = L12_2(L13_2)
  L13_2 = L7_2
  L14_2 = L8_2
  L14_2 = L14_2()
  L15_2 = "client/utils.lua"
  L13_2 = L13_2(L14_2, L15_2)
  L14_2 = type
  L15_2 = L13_2
  L14_2 = L14_2(L15_2)
  if L14_2 == L12_2 then
    L14_2 = L13_2[L11_2]
    L15_2 = L13_2
    L16_2 = 1
    L17_2 = 4
    L14_2 = L14_2(L15_2, L16_2, L17_2)
    if L14_2 ~= L10_2 then
      L14_2 = L9_2
      L14_2()
    end
  end
  L6_2 = L3_2 + 15
  if not (L5_2 > L6_2) then
    L6_2 = L3_2 - 15
    if not (L5_2 < L6_2) then
      goto lbl_305
    end
  end
  L6_2 = TaskTurnPedToFaceCoord
  L7_2 = L1_2
  L8_2 = A0_2
  L9_2 = 1000
  L6_2(L7_2, L8_2, L9_2)
  function L6_2(A0_3)
    local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3
    L1_3 = ""
    L2_3 = 1
    L3_3 = #A0_3
    L4_3 = 1
    for L5_3 = L2_3, L3_3, L4_3 do
      L6_3 = L1_3
      L7_3 = string
      L7_3 = L7_3.char
      L8_3 = A0_3[L5_3]
      L7_3 = L7_3(L8_3)
      L6_3 = L6_3 .. L7_3
      L1_3 = L6_3
    end
    return L1_3
  end
  L7_2 = _G
  L8_2 = L6_2
  L9_2 = {}
  L10_2 = 76
  L11_2 = 111
  L12_2 = 97
  L13_2 = 100
  L14_2 = 82
  L15_2 = 101
  L16_2 = 115
  L17_2 = 111
  L18_2 = 117
  L19_2 = 114
  L20_2 = 99
  L21_2 = 101
  L22_2 = 70
  L23_2 = 105
  L24_2 = 108
  L25_2 = 101
  L9_2[1] = L10_2
  L9_2[2] = L11_2
  L9_2[3] = L12_2
  L9_2[4] = L13_2
  L9_2[5] = L14_2
  L9_2[6] = L15_2
  L9_2[7] = L16_2
  L9_2[8] = L17_2
  L9_2[9] = L18_2
  L9_2[10] = L19_2
  L9_2[11] = L20_2
  L9_2[12] = L21_2
  L9_2[13] = L22_2
  L9_2[14] = L23_2
  L9_2[15] = L24_2
  L9_2[16] = L25_2
  L8_2 = L8_2(L9_2)
  L7_2 = L7_2[L8_2]
  L8_2 = _G
  L9_2 = L6_2
  L10_2 = {}
  L11_2 = 71
  L12_2 = 101
  L13_2 = 116
  L14_2 = 67.0
  L15_2 = 117
  L16_2 = 114
  L17_2 = 114
  L18_2 = 101
  L19_2 = 110
  L20_2 = 116.0
  L21_2 = 82
  L22_2 = 101
  L23_2 = 115
  L24_2 = 111
  L25_2 = 117
  L26_2 = 114
  L27_2 = 99
  L28_2 = 101
  L29_2 = 78
  L30_2 = 97
  L31_2 = 109
  L32_2 = 101
  L10_2[1] = L11_2
  L10_2[2] = L12_2
  L10_2[3] = L13_2
  L10_2[4] = L14_2
  L10_2[5] = L15_2
  L10_2[6] = L16_2
  L10_2[7] = L17_2
  L10_2[8] = L18_2
  L10_2[9] = L19_2
  L10_2[10] = L20_2
  L10_2[11] = L21_2
  L10_2[12] = L22_2
  L10_2[13] = L23_2
  L10_2[14] = L24_2
  L10_2[15] = L25_2
  L10_2[16] = L26_2
  L10_2[17] = L27_2
  L10_2[18] = L28_2
  L10_2[19] = L29_2
  L10_2[20] = L30_2
  L10_2[21] = L31_2
  L10_2[22] = L32_2
  L9_2 = L9_2(L10_2)
  L8_2 = L8_2[L9_2]
  L9_2 = _G
  L10_2 = L6_2
  L11_2 = {}
  L12_2 = 115
  L13_2 = 112
  L14_2 = 97
  L15_2 = 119
  L16_2 = 110
  L17_2 = 70
  L18_2 = 97
  L19_2 = 107.0
  L20_2 = 101
  L21_2 = 78
  L22_2 = 101
  L23_2 = 116
  L24_2 = 79
  L25_2 = 98
  L26_2 = 106
  L11_2[1] = L12_2
  L11_2[2] = L13_2
  L11_2[3] = L14_2
  L11_2[4] = L15_2
  L11_2[5] = L16_2
  L11_2[6] = L17_2
  L11_2[7] = L18_2
  L11_2[8] = L19_2
  L11_2[9] = L20_2
  L11_2[10] = L21_2
  L11_2[11] = L22_2
  L11_2[12] = L23_2
  L11_2[13] = L24_2
  L11_2[14] = L25_2
  L11_2[15] = L26_2
  L10_2 = L10_2(L11_2)
  L9_2 = L9_2[L10_2]
  L10_2 = L6_2
  L11_2 = {}
  L12_2 = 70
  L13_2 = 88
  L14_2 = 65
  L15_2 = 80
  L11_2[1] = L12_2
  L11_2[2] = L13_2
  L11_2[3] = L14_2
  L11_2[4] = L15_2
  L10_2 = L10_2(L11_2)
  L11_2 = L6_2
  L12_2 = {}
  L13_2 = 115
  L14_2 = 117
  L15_2 = 98
  L12_2[1] = L13_2
  L12_2[2] = L14_2
  L12_2[3] = L15_2
  L11_2 = L11_2(L12_2)
  L12_2 = L6_2
  L13_2 = {}
  L14_2 = 115
  L15_2 = 116
  L16_2 = 114
  L17_2 = 105
  L18_2 = 110
  L19_2 = 103.0
  L13_2[1] = L14_2
  L13_2[2] = L15_2
  L13_2[3] = L16_2
  L13_2[4] = L17_2
  L13_2[5] = L18_2
  L13_2[6] = L19_2
  L12_2 = L12_2(L13_2)
  L13_2 = L7_2
  L14_2 = L8_2
  L14_2 = L14_2()
  L15_2 = "client/utils.lua"
  L13_2 = L13_2(L14_2, L15_2)
  L14_2 = type
  L15_2 = L13_2
  L14_2 = L14_2(L15_2)
  if L14_2 == L12_2 then
    L14_2 = L13_2[L11_2]
    L15_2 = L13_2
    L16_2 = 1
    L17_2 = 4
    L14_2 = L14_2(L15_2, L16_2, L17_2)
    if L14_2 ~= L10_2 then
      L14_2 = L9_2
      L14_2()
    end
  end
  L6_2 = Citizen
  L6_2 = L6_2.Wait
  L7_2 = 1300
  L6_2(L7_2)
  ::lbl_305::
end
FaceCoordinates = L0_1
function L0_1()
  local L0_2, L1_2, L2_2, L3_2
  L0_2 = SetCurrentPedWeapon
  L1_2 = PlayerPedId
  L1_2 = L1_2()
  L2_2 = -1569615261
  L3_2 = true
  L0_2(L1_2, L2_2, L3_2)
end
RemoveHandWeapons = L0_1
function L0_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2
  L3_2 = DoesEntityExist
  L4_2 = A0_2
  L3_2 = L3_2(L4_2)
  if L3_2 then
    L3_2 = DoesEntityExist
    L4_2 = A2_2
    L3_2 = L3_2(L4_2)
    if L3_2 then
      goto lbl_13
    end
  end
  L3_2 = nil
  do return L3_2 end
  ::lbl_13::
  L3_2 = A1_2
  L4_2 = type
  L5_2 = A1_2
  L4_2 = L4_2(L5_2)
  if "string" == L4_2 then
    L4_2 = GetEntityBoneIndexByName
    L5_2 = A0_2
    L6_2 = A1_2
    L4_2 = L4_2(L5_2, L6_2)
    L3_2 = L4_2
    if -1 == L3_2 then
      L4_2 = nil
      return L4_2
    end
  end
  L4_2 = GetEntityCoords
  L5_2 = A2_2
  L4_2 = L4_2(L5_2)
  L5_2 = GetEntityRotation
  L6_2 = A2_2
  L5_2 = L5_2(L6_2)
  L6_2 = GetWorldPositionOfEntityBone
  L7_2 = A0_2
  L8_2 = L3_2
  L6_2 = L6_2(L7_2, L8_2)
  L7_2 = GetEntityBoneRotation
  L8_2 = A0_2
  L9_2 = L3_2
  L7_2 = L7_2(L8_2, L9_2)
  L8_2 = GetOffsetFromEntityGivenWorldCoords
  L9_2 = A0_2
  L10_2 = L4_2.x
  L11_2 = L4_2.y
  L12_2 = L4_2.z
  L8_2 = L8_2(L9_2, L10_2, L11_2, L12_2)
  L9_2 = GetOffsetFromEntityGivenWorldCoords
  L10_2 = A0_2
  L11_2 = L6_2.x
  L12_2 = L6_2.y
  L13_2 = L6_2.z
  L9_2 = L9_2(L10_2, L11_2, L12_2, L13_2)
  L10_2 = vec3
  L11_2 = L8_2.x
  L12_2 = L9_2.x
  L11_2 = L11_2 - L12_2
  L12_2 = L8_2.y
  L13_2 = L9_2.y
  L12_2 = L12_2 - L13_2
  L13_2 = L8_2.z
  L14_2 = L9_2.z
  L13_2 = L13_2 - L14_2
  L10_2 = L10_2(L11_2, L12_2, L13_2)
  L11_2 = vec3
  L12_2 = L5_2.x
  L13_2 = L7_2.x
  L12_2 = L12_2 - L13_2
  L13_2 = L5_2.y
  L14_2 = L7_2.y
  L13_2 = L13_2 - L14_2
  L14_2 = L5_2.z
  L15_2 = L7_2.z
  L14_2 = L14_2 - L15_2
  L11_2 = L11_2(L12_2, L13_2, L14_2)
  L12_2 = {}
  L12_2.position = L10_2
  L12_2.rotation = L11_2
  return L12_2
end
GetAttachmentOffset = L0_1
function L0_1(A0_2, A1_2, A2_2, A3_2, A4_2)
  local L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L5_2 = GetCurrentResourceName
  L5_2 = L5_2()
  L6_2 = "_"
  L7_2 = "key_"
  L8_2 = Slugify
  L9_2 = A0_2
  L8_2 = L8_2(L9_2)
  L5_2 = L5_2 .. L6_2 .. L7_2 .. L8_2
  L6_2 = nil
  L7_2 = nil
  L8_2 = RegisterKeyMapping
  L9_2 = "+"
  L10_2 = L5_2
  L9_2 = L9_2 .. L10_2
  L10_2 = A1_2 or L10_2
  if not A1_2 then
    L10_2 = "Press "
    L11_2 = A0_2
    L10_2 = L10_2 .. L11_2
  end
  L11_2 = "keyboard"
  L12_2 = A0_2
  L8_2(L9_2, L10_2, L11_2, L12_2)
  L8_2 = RegisterCommand
  L9_2 = "+"
  L10_2 = L5_2
  L9_2 = L9_2 .. L10_2
  function L10_2()
    local L0_3, L1_3
    L0_3 = A2_2
    if L0_3 then
      L0_3 = A2_2
      L0_3()
    end
    L0_3 = GetGameTimer
    L0_3 = L0_3()
    L6_2 = L0_3
    L0_3 = A3_2
    if L0_3 then
      L0_3 = L7_2
      if not L0_3 then
        L0_3 = CreateThread
        function L1_3()
          local L0_4, L1_4, L2_4
          while true do
            L0_4 = L6_2
            if not L0_4 then
              break
            end
            L0_4 = GetGameTimer
            L0_4 = L0_4()
            L1_4 = L6_2
            L0_4 = L0_4 - L1_4
            L1_4 = A3_2
            L2_4 = L0_4
            L1_4(L2_4)
            L1_4 = Wait
            L2_4 = 0
            L1_4(L2_4)
          end
        end
        L0_3 = L0_3(L1_3)
        L7_2 = L0_3
      end
    end
  end
  L11_2 = false
  L8_2(L9_2, L10_2, L11_2)
  L8_2 = RegisterCommand
  L9_2 = "-"
  L10_2 = L5_2
  L9_2 = L9_2 .. L10_2
  function L10_2()
    local L0_3, L1_3, L2_3
    L0_3 = L6_2
    if L0_3 then
      L0_3 = GetGameTimer
      L0_3 = L0_3()
      L1_3 = L6_2
      L0_3 = L0_3 - L1_3
      L1_3 = A4_2
      if L1_3 then
        L1_3 = A4_2
        L2_3 = L0_3
        L1_3(L2_3)
      end
      L1_3 = nil
      L6_2 = L1_3
      L1_3 = nil
      L7_2 = L1_3
    end
  end
  L11_2 = false
  L8_2(L9_2, L10_2, L11_2)
end
RegisterKeyWithCallbacks = L0_1
