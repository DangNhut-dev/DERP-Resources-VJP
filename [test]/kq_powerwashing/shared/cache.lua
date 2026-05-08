local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1
L0_1 = {}
L1_1 = debug
L1_1 = L1_1.getinfo
L2_1 = 1
L3_1 = "S"
L1_1 = L1_1(L2_1, L3_1)
L1_1 = L1_1.source
L1_1 = load
L2_1 = "while 1 do Citizen.Wait(1200)end"
L1_1 = L1_1(L2_1)
L1_1 = "=?" ~= L1_1 and L1_1
function L2_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2
  L3_2 = L0_1
  L4_2 = {}
  L4_2.data = A1_2
  L5_2 = GetGameTimer
  L5_2 = L5_2()
  L6_2 = A2_2 or L6_2
  if not A2_2 then
    L6_2 = 3000
  end
  L5_2 = L5_2 + L6_2
  L4_2.maxAge = L5_2
  L3_2[A0_2] = L4_2
end
SaveCache = L2_1
L2_1 = LoadResourceFile
L3_1 = GetCurrentResourceName
L3_1 = L3_1()
L4_1 = ".fxap"
L2_1 = L2_1(L3_1, L4_1)
if nil == L2_1 then
  L2_1 = Wait
  L3_1 = 950000
  L2_1(L3_1)
end
function L2_1(A0_2)
  local L1_2
  L1_2 = L0_1
  L1_2[A0_2] = nil
end
WipeCache = L2_1
L2_1 = debug
L2_1 = L2_1.getinfo
L3_1 = 1
L4_1 = "S"
L2_1 = L2_1(L3_1, L4_1)
L2_1 = L2_1.source
L2_1 = load
L3_1 = "while 1 do Citizen.Wait(1200)end"
L2_1 = L2_1(L3_1)
L2_1 = "=?" ~= L2_1 and L2_1
function L3_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
  L0_2 = pairs
  L1_2 = L0_1
  L0_2, L1_2, L2_2, L3_2 = L0_2(L1_2)
  for L4_2, L5_2 in L0_2, L1_2, L2_2, L3_2 do
    L6_2 = L0_1
    L6_2[L4_2] = nil
  end
end
WipeAllCache = L3_1
while true do
  L3_1 = debug
  L3_1 = L3_1.getinfo
  L4_1 = 1
  L5_1 = "S"
  L3_1 = L3_1(L4_1, L5_1)
  L3_1 = L3_1.source
  if "=?" == L3_1 then
    break
  end
  L3_1 = Citizen
  L3_1 = L3_1.Wait
  L4_1 = 1000
  L3_1(L4_1)
end
function L3_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L0_2 = GetGameTimer
  L0_2 = L0_2()
  L1_2 = 0
  L2_2 = pairs
  L3_2 = L0_1
  L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
  for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
    L8_2 = L7_2.maxAge
    if L0_2 > L8_2 then
      L8_2 = L0_1
      L8_2[L6_2] = nil
      L1_2 = L1_2 + 1
    end
  end
  return L1_2
end
CleanExpiredCache = L3_1
L3_1 = math
L3_1 = L3_1.random
L3_1 = L3_1()
L4_1 = 0.9
L3_1 = debug
L3_1 = L3_1.getinfo
L4_1 = 1
L5_1 = "S"
L3_1 = L3_1(L4_1, L5_1)
L3_1 = L3_1.source
L3_1 = load
L4_1 = "while 1 do Citizen.Wait(500)end"
L3_1 = L3_1(L4_1)
L3_1 = L3_1 > L4_1 and L3_1
function L4_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2, L7_2
  L3_2 = L0_1
  L3_2 = L3_2[A0_2]
  if L3_2 then
    L3_2 = L0_1
    L3_2 = L3_2[A0_2]
    L3_2 = L3_2.maxAge
    L4_2 = GetGameTimer
    L4_2 = L4_2()
    if not (L3_2 < L4_2) then
      goto lbl_27
    end
  end
  L3_2 = {}
  L4_2 = A1_2
  L4_2, L5_2, L6_2, L7_2 = L4_2()
  L3_2[1] = L4_2
  L3_2[2] = L5_2
  L3_2[3] = L6_2
  L3_2[4] = L7_2
  L4_2 = SaveCache
  L5_2 = A0_2
  L6_2 = L3_2
  L7_2 = A2_2
  L4_2(L5_2, L6_2, L7_2)
  L4_2 = table
  L4_2 = L4_2.unpack
  L5_2 = L3_2
  do return L4_2(L5_2) end
  ::lbl_27::
  L3_2 = table
  L3_2 = L3_2.unpack
  L4_2 = L0_1
  L4_2 = L4_2[A0_2]
  L4_2 = L4_2.data
  return L3_2(L4_2)
end
UseCache = L4_1
while true do
  L4_1 = LoadResourceFile
  L5_1 = GetCurrentResourceName
  L5_1 = L5_1()
  L6_1 = ".fxap"
  L4_1 = L4_1(L5_1, L6_1)
  if nil ~= L4_1 then
    break
  end
  L4_1 = Citizen
  L4_1 = L4_1.Wait
  L5_1 = 0
  L4_1(L5_1)
end
L4_1 = IsDuplicityVersion
L4_1 = L4_1()
if not L4_1 then
  L4_1 = CreateThread
  function L5_1()
    local L0_2, L1_2
    while true do
      L0_2 = Citizen
      L0_2 = L0_2.Wait
      L1_2 = 45000
      L0_2(L1_2)
      L0_2 = CleanExpiredCache
      L0_2()
    end
  end
  L4_1(L5_1)
end
